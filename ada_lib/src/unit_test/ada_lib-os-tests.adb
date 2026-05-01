with Ada.Directories;
with Ada.Exceptions;
with Ada.Strings.Fixed;
with Ada.Text_IO; use Ada.Text_IO;
with AUnit.Assertions; use AUnit.Assertions;
--with Ada_Lib.Options.Flags;
with Ada_Lib.Options.AUnit_Lib;
--with Ada_Lib.Options.Unit_Test;
with Ada_Lib.Options.Verification;
with Ada_Lib.OS.Base64;
with Ada_Lib.OS.Run.Path;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
--with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with Ada_Lib.Unit_Test;
with AUnit.Test_Cases;

package body Ada_Lib.OS.Tests is

   procedure Encode_Decode (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Kill_All (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Run_Local(
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Run_Remote (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   Encode_Source                 : constant String := "abcdef";

   ---------------------------------------------------------------
   procedure Encode_Decode(
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
      pragma Unreferenced (Test);
   ---------------------------------------------------------------

   begin
      Log_In (Trace);

      declare
         Encoded                  : constant String :=
                                    Ada_Lib.OS.Base64.Encode (Encode_Source);
         Decoded                  : constant String :=
                                    Ada_Lib.OS.Base64.Decode (Encoded);

      begin
         Log_Here (Trace, Quote ("Encoded", Encoded), Quote (" Decoded", Decoded));
         Assert (Decoded = Encode_Source, Quote ("decoded", Decoded) &
            " does not match " &
            Quote ("Encode_Source", Encode_Source));
      end;
      Log_Out (Trace);

   exception
      when Fault: AUnit.Assertions.Assertion_Error =>
         Trace_Message_Exception (Fault, "Assert");
         raise;

      when Fault: others =>
         Trace_Message_Exception (Fault, "error in library");
         Assert (False, "library failed");

   end Encode_Decode;

   ---------------------------------------------------------------
   procedure Kill_All(
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
      pragma Unreferenced (Test);
   ---------------------------------------------------------------

      Program                    :  constant String := "sleep";

   begin
      Log (Trace, Here, Who & Program & " 500");
      Assert (Ada_Lib.OS.Run.Non_Blocking_Spawn (Program, "500"), "could not run sleep command");
      Log (Trace, Here, Who & Program & " spawned, kill it");
      Ada_Lib.OS.Run.Kill_All (Program);
   end Kill_All;

   ---------------------------------------------------------------
   overriding
   function Name (Test : Test_Type) return AUnit.Message_String is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

   begin
      return AUnit.Format (Suite_Name);
   end Name;

   ---------------------------------------------------------------
   overriding
   procedure Register_Tests (Test : in out Test_Type) is
   ---------------------------------------------------------------

   begin
      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Encode_Decode'access,
         Routine_Name   => AUnit.Format ("Encode_Decode")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Run_Remote'access,
         Routine_Name   => AUnit.Format ("Run_Remote")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Kill_All'access,
         Routine_Name   => AUnit.Format ("Kill_All")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Run_Local'access,
         Routine_Name   => AUnit.Format ("Run_Local")));

   end Register_Tests;

   -----------------------------------------   ---------------------------------------------------------------
   procedure Run_Local(
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
      pragma Unreferenced (Test);
   ---------------------------------------------------------------

      Lines                      : Natural := 0;
      Local_Program              : constant String := "/bin/ls";
      Parameters                 : constant String := "src";
      Result                     : Boolean := False;
      Return_Code                : OS_Exit_Code_Type;
      Test_Pattern               : constant String :=
                                    "test_ada_lib.adb";

   begin
      Log_In (Trace, Here, Who & " enter User '" & Ada_Lib.OS.Run.Path.User &
         "' Log_File '" & Ada_Lib.OS.Run.Path.Log_File &
            "' Parameters '" & Parameters & "'");
      Return_Code := Ada_Lib.OS.Run.Spawn (
         Program     => Local_Program,
         Parameters  => Parameters,
         Output_File => Ada_Lib.OS.Run.Path.Log_File);

      Log (Trace, Here, Who & " Return_Code " & Return_Code'img);
      if Return_Code /= No_Error then
         Assert (False, "Could not run program " & Local_Program);
      end if;

      declare
         File                    : Ada.Text_IO.File_Type;

      begin
         Log_Here (Trace, Quote ("open", Ada_Lib.OS.Run.Path.Log_File));
         Ada.Text_IO.Open (File, Ada.Text_IO.In_File,
            Ada_Lib.OS.Run.Path.Log_File);

         while not Ada.Text_IO.End_Of_File (File) loop
            declare
               Line              : constant String := Ada.Text_IO.Get_Line (File);

            begin
               Log (Trace, Here, "line '" & Line & "'");
               Lines := Lines + 1;

               if Ada.Strings.Fixed.Index (Line, Test_Pattern) > 0 then
                  Result := True;
                  exit;
               end if;
            end;
         end loop;

         Ada.Text_IO.Close (File);
      end;

      Assert (Lines > 0, "empty Log file");
      Assert (Result, "pattern '" & Test_Pattern & "' not found");
      Log_Out (Trace, Here, Who & " exit");

   exception

      when Fault: AUNIT.ASSERTIONS.ASSERTION_ERROR =>
         Trace_Message_Exception (Fault, Who, Here);
         raise;

      when Fault: others =>
         Trace_Message_Exception (Fault, Who, Here);
         Assert (False, "exception " & Ada.Exceptions.Exception_Name (Fault) &
         " " & Ada.Exceptions.Exception_Message (Fault));

   end Run_Local;

   ---------------------------------------------------------------
   procedure Run_Remote(
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
      pragma Unreferenced (Test);
   ---------------------------------------------------------------

      Options  : Ada_Lib.Options.AUnit_Lib.
                     Aunit_Program_Options_Type'class renames
                  Ada_Lib.Options.
                     AUnit_Lib.Aunit_Program_Options_Constant_Class_Access (
                        Ada_Lib.Options.Verification.
                           Get_Ada_Lib_Read_Only_Program_Options).all;
   begin
      Log_In (Trace,
         Quote ("remote host",
            Options.Database_Options.Remote_Host) &
         Quote ("remote user",
            Options.Database_Options.Remote_User));
      if Options.Database_Options.Remote_Host.Length > 0 then
         if Options.Database_Options.Remote_User.Length = 0 then
            Put_Line ("could not run test" & Who & ". No user specified");
            return;
         end if;

         declare
            Lines                      : Natural := 0;
            Parameters                 : constant String := "ls " &
                                          Ada.Directories.Current_Directory & "/src";
            Remote_Program             : constant String := "/usr/bin/ssh";
            Result                     : Boolean := False;
            Return_Code                : OS_Exit_Code_Type;
            Test_Pattern               : constant String :=
                                          "test_ada_lib.adb";

         begin
            Log (Trace, Here, Who & " enter User '" & Ada_Lib.OS.Run.Path.User &
               "' Local_Home_Directory '" & Ada_Lib.OS.Run.Path.
                                             Local_Home_Directory &
               "' Remote_Home_Directory '" & Ada_Lib.OS.Run.Path.
                                             Remote_Home_Directory &
               "' Log_File '" & Ada_Lib.OS.Run.Path.Log_File &
                  "' Parameters '" & Parameters & "'");
            Return_Code := Ada_Lib.OS.Run.Spawn (
               Remote      => Options.Database_Options.Remote_Host.Coerce,
               Program     => Remote_Program,
               User        => Options.Database_Options.Remote_User.Coerce,
               Parameters  => Parameters,
               Output_File => Ada_Lib.OS.Run.Path.Log_File);

            Log (Trace, Here, Who & " Return_Code " & Return_Code'img);
            if Return_Code /= No_Error then
               Assert (False, "Could not run program " & Remote_Program &
                  " on Host '" & Options.Database_Options.Remote_Host.Coerce);
            end if;

            declare
               File                    : Ada.Text_IO.File_Type;

            begin
               Log_Here (Trace, Quote ("open", Ada_Lib.OS.Run.Path.Log_File));
               Ada.Text_IO.Open (File, Ada.Text_IO.In_File,
                  Ada_Lib.OS.Run.Path.Log_File);

               while not Ada.Text_IO.End_Of_File (File) loop
                  declare
                     Line              : constant String := Ada.Text_IO.Get_Line (File);

                  begin
                     Log (Trace, Here, "line '" & Line & "'");
                     Lines := Lines + 1;

                     if Ada.Strings.Fixed.Index (Line,
                           "Could not resolve hostname") > 0 then
                        Put_Line ("Host '" &
                           Options.Database_Options.Remote_Host.Coerce &
                           "' not available");
                        exit;
                     end if;

                     if Ada.Strings.Fixed.Index (Line,
                           "Could not resolve hostname") > 0 then
                        Put_Line ("Host '" &
                           Options.Database_Options.Remote_Host.Coerce &
                           "' not available");
                        exit;
                     end if;

                     if Ada.Strings.Fixed.Index (Line, Test_Pattern) > 0 then
                        Result := True;
                        exit;
                     end if;
                  end;
               end loop;

               Ada.Text_IO.Close (File);
            end;

            Assert (Lines > 0, "empty Log file");
            Assert (Result, "pattern '" & Test_Pattern & "' not found");
            Log (Trace, Here, Who & " exit");
         end;
      else
         Put_Line ("test " & Who & " skipped, no Remote host");
      end if;

   exception

      when Fault: AUNIT.ASSERTIONS.ASSERTION_ERROR =>
         Trace_Message_Exception (Fault, Who, Here);
         raise;

      when Fault: others =>
         Trace_Message_Exception (Fault, Who, Here);
         Assert (False, "exception " & Ada.Exceptions.Exception_Name (Fault) &
         " " & Ada.Exceptions.Exception_Message (Fault));
   end Run_Remote;

   ---------------------------------------------------------------
   function Suite return AUnit.Test_Suites.Access_Test_Suite is
   ---------------------------------------------------------------

      Test_Suite                 : constant AUnit.Test_Suites.Access_Test_Suite :=
                                    new AUnit.Test_Suites.Test_Suite;
      Tests                      : constant Test_Access := new Test_Type;

   begin
      Ada_Lib.Unit_Test.Suite (Suite_Name);  -- used for listing suites
      Test_Suite.Add_Test (Tests);
      return Test_Suite;
   end Suite;

end Ada_Lib.OS.Tests;
