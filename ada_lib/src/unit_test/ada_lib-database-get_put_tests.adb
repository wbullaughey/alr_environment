with Ada.Exceptions;
with Ada.Text_IO;use Ada.Text_IO;
with Ada_Lib.Database.Common;
with AUnit.Assertions; use AUnit.Assertions;
with Ada_Lib.Options.AUnit_Lib;
with Ada_Lib.Options.Unit_Test;
with Ada_Lib.Options.Verification;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace; use Ada_Lib.Trace;

package body Ada_Lib.Database.Get_Put_Tests is

   use type Ada_Lib.Options.Mode_Type;
-- use type Ada_Lib.Strings.Unlimited.String_Type;

-- type Test_Suite_Type is new Ada_Lib.Test.Tests.Test_Suite_Type with null record;

   type Local_Database_Test_Type is new Database_Test_Type with null record;

   type Remote_Database_Test_Type is new Database_Test_Type with null record;

   function Construct (
      Source                     : in     String;
      Append                     : in     Ada_Lib.Strings.Unlimited.String_Type
   ) return String renames Ada_Lib.Strings.Unlimited.Construct;

   Debug       : Boolean renames
                  Options.Unit_Test.Ada_Lib_Database_Unit_Test.
                  Get_Put_Debug;
   Value       : constant String := "xyz";
   Value_Name        : constant String := "abc";
   Name_Value  : constant String := Value_Name & "=" & Value;
   Test_Timeout: constant Duration := 0.1;

   ---------------------------------------------------------------
   function Database_Suite (
      Which_Host                 : in    Ada_Lib.Database.Which_Host_Type
   ) return AUnit.Test_Suites.Access_Test_Suite is
   ---------------------------------------------------------------

      Test_Suite                 : constant AUnit.Test_Suites.Access_Test_Suite :=
                                    new AUnit.Test_Suites.Test_Suite;
      Tests                      : constant Ada_Lib.Unit_Test.Test_Cases.Test_Case_Class_Access :=
                                    Ada_Lib.Unit_Test.Test_Cases.Test_Case_Class_Access'(case Which_Host is

                                       when Ada_Lib.Database.Local =>
                                          new Local_Database_Test_Type,

                                       when Ada_Lib.Database.Remote =>
                                          new Remote_Database_Test_Type,

                                       when Ada_Lib.Database.No_Host |
                                            Ada_Lib.Database.Unset =>
                                          Null
                                    );

   begin
      Log (Debug, Here, Who & " Which_Host " & Which_Host'img);
      Ada_Lib.Unit_Test.Suite (Suite_Name);  -- used for listing suites
      Test_Suite.Add_Test (Tests);
      return Test_Suite;
   end Database_Suite;

   ---------------------------------------------------------------
   procedure Flush_Input (
      Test                          : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

      Coerced_Test                  : Database_Test_Type renames Database_Test_Type (Test);

   begin
      Log (Debug, Here, Who & " enter");
      Assert (Coerced_Test.Get_Database.Is_Open, "data base not open");
      Coerced_Test.Get_Database.Post (Name_Value, Test_Timeout);
      Coerced_Test.Get_Database.Post (Value_Name, Test_Timeout);
      delay Test_Timeout;
      Coerced_Test.Get_Database.Flush_Input;

      declare
         Residual                : constant String := Coerced_Test.Get_Database.all.Get (Test_Timeout);

      begin
         Log_Here (Debug, Quote ("Residual", Residual));
         Assert (Residual'length = 0, "input flushed");
      end;
      Log (Debug, Here, Who & " exit");

   exception
      when Fault: others =>
         Trace_Message_Exception (Fault, Who, Here);
         raise;

   end Flush_Input;

   ---------------------------------------------------------------
   procedure Is_Open_False (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
      pragma Unreferenced (Test);
   ---------------------------------------------------------------

      pragma Warnings (Off, "variable ""Database"" is read but never assigned");
      Database                   : Ada_Lib.Database.Database_Type;
      pragma Warnings (On, "variable ""Database"" is read but never assigned");

   begin
      Log (Debug, Here, Who);
      if not Assert (not Database.Is_Open, "data base not open") then
         Log_Here ("was open");
      end if;
   end Is_Open_False;

   ---------------------------------------------------------------
   procedure Is_Open_True (
      Test                    : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

      Coerced_Test                  : Database_Test_Type renames Database_Test_Type (Test);

   begin
      Log (Debug, Here, Who);
      if not Assert (Coerced_Test.Get_Database /= Null, "data base was not opened") then
         Log_Here ("was not open");
      elsif not Assert (Coerced_Test.Get_Database.Is_Open, "data base was not open") then
         Log_Here ("was not open");
      end if;
   end Is_Open_True;

   ---------------------------------------------------------------
   overriding
   function Name (Test : Database_Test_Type) return AUnit.Message_String is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

   begin
      return AUnit.Format (Suite_Name);
   end Name;

   ---------------------------------------------------------------
   overriding
   function Name (Test : No_Database_Test_Type) return AUnit.Message_String is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

   begin
      return AUnit.Format (Suite_Name);
   end Name;

   ---------------------------------------------------------------
   procedure Name_Value_Get (
      Test                          : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

      Coerced_Test                  : Database_Test_Type renames Database_Test_Type (Test);

   begin
      Log (Debug, Here, Who);
      Assert (Coerced_Test.Get_Database.Is_Open, "data base not open");
      Coerced_Test.Get_Database.Post (Name_Value, Test_Timeout);
      Coerced_Test.Get_Database.Post (Value_Name, Test_Timeout);

      declare
         Response                : constant Ada_Lib.Database.Name_Value_Class_Type := Coerced_Test.Get_Database.all.Get (Test_Timeout);

      begin
         Log_Here (Debug, Quote ("response", Response.To_String));
         Assert (Response.Name = Value_Name, "got expected name");
         Assert (Response.Value = Value, "got expected value");
      end;
   end Name_Value_Get;

   ---------------------------------------------------------------
   procedure Name_Value_Get_With_Token (
      Test                          : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

      Coerced_Test                  : Database_Test_Type renames Database_Test_Type (Test);

   begin
      Log (Debug, Here, Who);
      Assert (Coerced_Test.Get_Database.Is_Open, "data base not open");
      Coerced_Test.Get_Database.Post (Name_Value, Test_Timeout);

      declare
         Response                : constant Ada_Lib.Database.Name_Value_Class_Type :=
                                    Coerced_Test.Get_Database.all.Get (
                                       Value_Name, Ada_Lib.Database.No_Vector_Index, "", Test_Timeout, True);
      begin
         Log_Here (Debug, Quote ("response", Response.To_String));
         Assert (Response.Name = Value_Name, "got expected name");
         Assert (Response.Value = Value, "got expected value");
      end;
   end Name_Value_Get_With_Token;

   ---------------------------------------------------------------
   function No_Database_Suite return AUnit.Test_Suites.Access_Test_Suite is
   ---------------------------------------------------------------

      Test_Suite                 : constant AUnit.Test_Suites.Access_Test_Suite :=
                                    new AUnit.Test_Suites.Test_Suite;
      Tests                      : constant No_Database_Test_Access := new No_Database_Test_Type;

   begin
      Ada_Lib.Unit_Test.Suite (Suite_Name);  -- used for listing suites
      Test_Suite.Add_Test (Tests);
      return Test_Suite;
   end No_Database_Suite;

   ---------------------------------------------------------------
   procedure Parse_Line (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

   type String_Access is access constant String;

   type Tests_Type (
      Ok                         : Boolean := True) is record
      Line                       : String_Access;
      case Ok is

         when False =>
            null;

         when True =>
            Index                : Ada_Lib.Database.Optional_Vector_Index_Type := Ada_Lib.Database.No_Vector_Index;
            Name                 : String_Access := Null;
            Tag                  : String_Access := Null;
            Value                : String_Access := Null;

      end case;
   end record;

   Tests                         : constant array (Positive range <>) of Tests_Type := (
                                    Tests_Type'(
                                       Index => Ada_Lib.Database.No_Vector_Index,
                                       Line  => new String'(""),
                                       Name  => Null,
                                       Ok    => True,
                                       Tag => Null,
                                       Value => Null
                                    ),
                                    Tests_Type'(
                                       Index => Ada_Lib.Database.No_Vector_Index,
                                       Line  => new String'("a"),
                                       Name  => new String'("a"),
                                       Ok    => True,
                                       Tag => Null,
                                       Value => Null
                                    ),
                                    Tests_Type'(
                                       Index => Ada_Lib.Database.No_Vector_Index,
                                       Line  => new String'("abc"),
                                       Name  => new String'("abc"),
                                       Ok    => True,
                                       Tag => Null,
                                       Value => Null
                                    ),
                                    Tests_Type'(
                                       Index => Ada_Lib.Database.No_Vector_Index,
                                       Line  => new String'("a=b"),
                                       Name  => new String'("a"),
                                       Ok    => True,
                                       Tag => Null,
                                       Value =>new String'("b")
                                    ),
                                    Tests_Type'(
                                       Index => Ada_Lib.Database.No_Vector_Index,
                                       Line  => new String'("abc=xyz"),
                                       Name  => new String'("abc"),
                                       Ok    => True,
                                       Tag => Null,
                                       Value =>new String'("xyz")
                                    ),
                                    Tests_Type'(
                                       Index => Ada_Lib.Database.No_Vector_Index,
                                       Line  => new String'("a=b"),
                                       Name  => new String'("a"),
                                       Ok    => True,
                                       Tag => Null,
                                       Value =>new String'("b")
                                    ),
                                    Tests_Type'(
                                       Index => 1,
                                       Line  => new String'("x!a.1=b"),
                                       Name  => new String'("a"),
                                       Ok    => True,
                                       Tag => new String'("x"),
                                       Value => new String'("b")
                                    ),
                                    Tests_Type'(
                                       Index => 1,
                                       Line  => new String'("def!abc.1=xyz"),
                                       Name  => new String'("abc"),
                                       Ok    => True,
                                       Tag => new String'("def"),
                                       Value => new String'("xyz")
                                    ),
                                    Tests_Type'(
                                       Line  => new String'("a="),
                                       Ok    => False
                                    ),
                                    Tests_Type'(
                                       Index => 1,
                                       Line  => new String'("a.1"),
                                       Name  => new String'("a"),
                                       Ok    => True,
                                       Tag => Null,
                                       Value => Null
                                    ),
                                    Tests_Type'(
                                       Index => 123,
                                       Line  => new String'("abc.123=xyz"),
                                       Name  => new String'("abc"),
                                       Ok    => True,
                                       Tag => Null,
                                       Value =>new String'("xyz")
                                    ),
                                    Tests_Type'(
                                       Index => 0,
                                       Line  => new String'("a.0"),
                                       Name  => new String'("a"),
                                       Ok    => True,
                                       Tag => Null,
                                       Value => Null
                                    ),
                                    Tests_Type'(
                                       Line  => new String'("!a"),
                                       Ok    => False
                                    ),
                                    Tests_Type'(
                                       Line  => new String'("="),
                                       Ok    => False
                                    ),
                                    Tests_Type'(
                                       Line  => new String'("!="),
                                       Ok    => False
                                    )
                                 );
   begin
      Log (Debug, Here, Who);

      for Test of Tests loop
         declare
            Line                 : constant String := Test.Line.all;

         begin
            Log (Debug, Here, Who & Quote (" line", Line) & " ok " & Test.Ok'img);

            if not Test.Ok then
               Put_Line ("expect exception for " & Quote ("line", Line));
            end if;

            declare
               Name_Value        : constant Ada_Lib.Database.Name_Value_Type := Ada_Lib.Database.Parse (Line);

            begin
               Assert (Test.Ok, "Parse should have thrown an exception for" & Quote (" line", Line));

               if Test.Name = Null then
                  Assert (Name_Value.Name.length = 0, "Expected null Name. got " & Name_Value.Name.Coerce);
               else
                  Assert (Name_Value.Name = Test.Name.all, "Wrong Name. got " & Name_Value.Name.Coerce &
                     " expected " & Test.Name.all);
               end if;

               if Test.Value = Null then
                  Assert (Name_Value.Value.length = 0, "Expected null Value. got " & Name_Value.Value.Coerce);
               else
                  Assert (Name_Value.Value = Test.Value.all, "Wrong Value. got " & Name_Value.Value.Coerce &
                     " expected " & Test.Value.all);
               end if;

               if Test.Tag = Null then
                  Assert (Name_Value.Tag.length = 0, "Expected null Tag. got " & Name_Value.Tag.Coerce);
               else
                  Assert (Name_Value.Tag = Test.Tag.all, "Wrong Tag. got " & Name_Value.Tag.Coerce &
                     " expected " & Test.Tag.all);
               end if;

               Assert (Name_Value.Index = Test.Index, "Wrong index. got " & Name_Value.Index'img &
                  " expected " & Test.Index'img);
            end;

         exception
            when Fault: Ada_Lib.Database.Invalid =>
               Trace_Message_Exception (Debug or else Test.Ok, Fault,
                  Quote (" line", Test.Line.all) &
                  (if Test.Ok then " exception not expected" else " exception expected"));

               Assert (not Test.Ok, "should not have thrown exception for" & Quote (" line", Test.Line.all));
         end;

      end loop;

   exception
      when Fault: others =>
         Trace_Exception (Fault);
   end Parse_Line;

   -------------   ---------------------------------------------------------------
   procedure Post_Get (
      Test                          : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

      Data                          : constant String := Name_Value;
      Coerced_Test                     : Database_Test_Type renames Database_Test_Type (Test);


   begin
      Log (Debug, Here, Who);
      Assert (Coerced_Test.Get_Database.Is_Open, "data base not open");
      Coerced_Test.Get_Database.Post (Data, Test_Timeout);

      declare
         Response                : constant String := Coerced_Test.Get_Database.all.Get (
                                    Value_Name, Ada_Lib.Database.No_Vector_Index, "", Test_Timeout);

      begin
         Log_Here (Debug, Quote ("data" & Data) &
            Quote ("response", Response));
         Assert (Response = Data, "got wrong data expected '" & Data & "' got '" & Response & "'");
      end;
   end Post_Get;

   ---------------------------------------------------------------
   procedure Post_Get_With_Token (
      Test                          : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

      Data                        : constant String := Name_Value;
      Coerced_Test                  : Database_Test_Type renames Database_Test_Type (Test);

   begin
      Log (Debug, Here, Who);
      Assert (Coerced_Test.Get_Database.Is_Open, "data base not open");
      Coerced_Test.Get_Database.Post (Data, Test_Timeout);

      declare
         Response                : constant Ada_Lib.Database.Name_Value_Class_Type :=
                                    Coerced_Test.Get_Database.all.Get (Value_Name,
                                    Ada_Lib.Database.No_Vector_Index, "", Test_Timeout, Use_Token => True);

      begin
         Log (Debug, Here, Who);
         Assert (Response.Name = Value_Name, Construct ("got wrong name '",
            Response.Name & "' expected '" & Value_Name & "'"));
         Assert (Response.Value = Value, Construct ("got wrong value '", Response.Value & "' expected '" & Value & "'"));
      end;
   end Post_Get_With_Token;

   --------------------------------------------------
   overriding
   procedure Register_Tests (Test : in out Database_Test_Type) is
   ---------------------------------------------------------------

   use Ada_Lib.Options.Unit_Test;

      Options  : Ada_Lib.Options.AUnit_Lib.
                     Aunit_Program_Options_Type'class renames
                  Ada_Lib.Options.
                     AUnit_Lib.Aunit_Program_Options_Constant_Class_Access (
                        Ada_Lib.Options.Verification.
                           Get_Ada_Lib_Read_Only_Program_Options).all;
      Listing_Suites
               : constant Boolean := Options.Nested_Unit_Test_Options.Mode /=
                                       Ada_Lib.Options.Run_Tests;
      Star_Names
               : constant String := (if Listing_Suites then "*" else "");
   begin
--not_implemented;
      Log (Debug, Here, Who & " enter Which_Host " & Test.Which_Host'img);

      if Listing_Suites or else
            Options.Nested_Unit_Test_Options.Suite_Set (
               Ada_Lib.Options.Unit_Test.Database_Server) then
         Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
            Routine        => Is_Open_True'access,
            Routine_Name   => AUnit.Format ("Is_Open_True" & Star_Names)));

         Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
            Routine        => Flush_Input'access,
            Routine_Name   => AUnit.Format ("Flush_Input" & Star_Names)));

         Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
            Routine        => Post_Get'access,
            Routine_Name   => AUnit.Format ("Post_Get" & Star_Names)));

         Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
            Routine        => Post_Get_With_Token'access,
            Routine_Name   => AUnit.Format ("Post_Get_With_Token" & Star_Names)));

         Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
            Routine        => Name_Value_Get'access,
            Routine_Name   => AUnit.Format ("Name_Value_Get" & Star_Names)));

         Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
            Routine        => Name_Value_Get_With_Token'access,
            Routine_Name   => AUnit.Format ("Name_Value_Get_With_Token" & Star_Names)));

         Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
            Routine        => Timeout_Get'access,
            Routine_Name   => AUnit.Format ("Timeout_Get" & Star_Names)));

         Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
            Routine        => Wild_Get'access,
            Routine_Name   => AUnit.Format ("Wild_Get" & Star_Names)));
      end if;
-- Log_Here ("exit");
   end Register_Tests;

   ---------------------------------------------------------------
   overriding
   procedure Register_Tests (Test : in out No_Database_Test_Type) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug);
      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Is_Open_False'access,
         Routine_Name   => AUnit.Format ("Is_Open_False")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Parse_Line'access,
         Routine_Name   => AUnit.Format ("Parse_Line")));

      Log_Out (Debug);
   end Register_Tests;

   ---------------------------------------------------------------
   overriding
   procedure Set_Up (
      Test                          : in out Database_Test_Type) is
   ---------------------------------------------------------------

   begin
      Log (Debug or Trace_Set_Up_Tear_Down, Here, Who & " enter which host " & Test.Which_Host'img);
      Ada_Lib.Database.Unit_Test.Test_Case_Type (Test).Set_Up;
      Log (Debug or Trace_Set_Up_Tear_Down, Here, Who & " exit");

   exception
      when Fault: others =>
         Trace_Message_Exception (Fault, Who, Here);
         Test.Set_Up_Message_Exception (Fault, Here, Who, "could not open database");
         Log (Debug, Here, Who & " kill");
   end Set_Up;

   ---------------------------------------------------------------
   overriding
   procedure Tear_Down (
      Test                          : in out Database_Test_Type) is
   ---------------------------------------------------------------

--    Options                    : constant Standard.GNOGA_Options.Database.AUnit.Aunit_Program_Options_Constant_Class_Access :=
--                                     Runtime_Options.Get_Options;
   begin
      Log (Debug or Trace_Set_Up_Tear_Down, Here, Who & " enter");
      Pause (Pause_Flag, "Pause before Tear Down cleanup", Here, Debug);
      Ada_Lib.Database.Unit_Test.Test_Case_Type (Test).Tear_Down;
--       Test.Get_Database.Delete (Value_Name);
      Log (Debug or Trace_Set_Up_Tear_Down, Here, Who & " exit");
   end Tear_Down;

   ---------------------------------------------------------------
   procedure Timeout_Get (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

      Coerced_Test                  : Database_Test_Type renames Database_Test_Type (Test);

   begin
      Log (Debug, Here, Who);
      Assert (Coerced_Test.Get_Database.Is_Open, "data base not open");

      declare
         Response                : constant String := Coerced_Test.Get_Database.all.Get (Test_Timeout);

      begin
         if not Assert (Response'length = 0, "null response expected") then
            Log_Here ("unexpected response '" & Response & "'");
         end if;
      end;
   end Timeout_Get;

   ---------------------------------------------------------------
   procedure Wild_Get (    -- needs new dbdaemon
      Test                          : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

      Coerced_Test                  : Database_Test_Type renames Database_Test_Type (Test);

   begin
      Ada_Lib.Database.Common.Wild_Get (Coerced_Test.Get_Database.all);

   exception
      when Fault: Ada_Lib.Database.Common.Failed =>
         raise Failed with Ada.Exceptions.Exception_Message (Fault);
   end Wild_Get;

begin
   if Trace_Tests then
      Debug := Trace_Tests;
   end if;
end Ada_Lib.Database.Get_Put_Tests;
