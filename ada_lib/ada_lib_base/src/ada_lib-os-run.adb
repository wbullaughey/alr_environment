with Ada.Directories;
with Ada.Text_IO;use Ada.Text_IO;
with Ada_Lib.Directory;
--with Ada_Lib.OS;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.OS.Run.Paths;
with Ada_Lib.Trace; use Ada_Lib.Trace;

-- pragma Elaborate (Ada_Lib.OS);

package body Ada_Lib.OS.Run is

   use type GNAT.OS_Lib.Process_Id;

   function Translate_Return_Code (
      Return_Code                : in     Integer;
      Zero_OK                    : in     Boolean
   ) return OS_Exit_Code_Type;

   ---------------------------------------------------------------------------
   procedure Check_Program (
      Program     : in     String) is
   ---------------------------------------------------------------------------

   begin
      Log_In (Debug, Quote ("program", Program) &
         Quote (" CWD", Ada.Directories.Current_Directory));
      if not Ada_Lib.Directory.Exists (Program) then
         declare
            Message     : constant String := Quote ("program", Program) &
               " does not exist";
         begin
            Log_Exception (Debug, Message);
            raise Failed with Message;
         end;
      end if;

      if not Ada_Lib.Directory.Is_Executable(Program) then
         declare
            Message     : constant String := Quote ("program", Program) &
               " is not executable";
         begin
            Log_Exception (Debug, Message);
            raise Failed with Message;
         end;
      end if;
      Log_Out (Debug);
   end Check_Program;

   ---------------------------------------------------------------------------
   procedure Kill_All (
      Name                       : in     String) is
   ---------------------------------------------------------------------------

      Parameters                 : constant String := "-9 " & Name;
      Program                    : constant String := "/usr/bin/killall";

   begin
      Log_In (Debug, "program '" & Program & "' name '" & Name & "'");

      declare
         Result                  : constant OS_Exit_Code_Type :=
                                    Spawn (Program, Parameters, "/tmp/list");

      begin
         Log_Out (Debug, "kill result" & Result'img);
      end;

    exception
        when Fault: others =>
            Trace_Message_Exception (Fault, Who, Here);

   end Kill_All;

   ---------------------------------------------------------------------------
   procedure Kill_Remote (
      Process_ID                 : in     GNAT.OS_Lib.Process_Id;
      Tree                       : in     Boolean := False) is
   ---------------------------------------------------------------------------

   begin
      if Tree then
         GNAT.OS_Lib.Kill_Process_Tree (Process_ID);
      else
         GNAT.OS_Lib.Kill (Process_ID);
      end if;
   end Kill_Remote;

   ---------------------------------------------------------------------------
   function Non_Blocking_Spawn (
      Remote                     : in     String;
      Program                    : in     String;
      User                       : in     String;
      Parameters                 : in     String;
      Process_ID                 : access GNAT.OS_Lib.Process_Id := Null;
      Output_File                : in     String := ""
   ) return Boolean is
   ---------------------------------------------------------------------------

      Arguments                  : constant GNAT.OS_Lib.Argument_List_Access :=
                                    GNAT.OS_Lib.Argument_String_To_List (User & "@" & Remote & " " &
                                       Program & " " & Parameters);
      ID                         : GNAT.OS_Lib.Process_Id := GNAT.OS_Lib.Invalid_Pid;

   begin
      if Debug then
         Log_Here ("enter remote '" & Remote &
            "' remote program '" & Run.Paths.Remote_Program &
            "' program '" & Program &
            "' user '" & User & "' Output_File '" & Output_File &
            "' parameters '" & Parameters & "'");
         for Index in Arguments.all'range loop
            Put (Arguments.all (Index).all & " ");
         end loop;
         New_Line;
      end if;

      if Output_File = "" then
         ID := GNAT.OS_Lib.Non_Blocking_Spawn (Ada_Lib.OS.Run.Paths.Remote_Program, Arguments.all);
      else
         ID := GNAT.OS_Lib.Non_Blocking_Spawn (Ada_Lib.OS.Run.Paths.Remote_Program, Arguments.all, Output_File);
      end if;
      Log (Debug, Here, Who & " exit ID" & GNAT.OS_Lib.Pid_To_Integer (ID)'img);
      if ID = GNAT.OS_Lib.Invalid_Pid then
         return False;
      else
         if Process_ID /= Null then
            Process_ID.all := ID;
         end if;
         return True;
      end if;
   end Non_Blocking_Spawn;

   ---------------------------------------------------------------------------
   function Non_Blocking_Spawn (
      Program                    : in     String;
      Parameters                 : in     String;
      Process_ID                 : access GNAT.OS_Lib.Process_Id := Null;
      Output_File                : in     String := ""
   ) return Boolean is
   ---------------------------------------------------------------------------

      Arguments                  : constant GNAT.OS_Lib.Argument_List_Access :=
                                    GNAT.OS_Lib.Argument_String_To_List (Parameters);
      ID                         : GNAT.OS_Lib.Process_Id := GNAT.OS_Lib.Invalid_Pid;

   begin
      if Debug then
         Log (Debug, Here, Who & " enter program '" & Program &
            "' Output_File '" & Output_File &
            "' parameters '" & Parameters & "'");
         for Index in Arguments.all'range loop
            Put (Arguments.all (Index).all & " ");
         end loop;
         New_Line;
      end if;

      if Output_File = "" then
         ID := GNAT.OS_Lib.Non_Blocking_Spawn (Program, Arguments.all);
      else
         ID := GNAT.OS_Lib.Non_Blocking_Spawn (Program, Arguments.all, Output_File);
      end if;
      Log (Debug, Here, Who & " exit ID" & GNAT.OS_Lib.Pid_To_Integer (ID)'img);
      if ID = GNAT.OS_Lib.Invalid_Pid then
         return False;
      else
         if Process_ID /= Null then
            Process_ID.all := ID;
         end if;
         return True;
      end if;
   end Non_Blocking_Spawn;

   ---------------------------------------------------------------------------
   function Spawn (
      Remote                     : in     String;
      Program                    : in     String;
      User                       : in     String;
      Parameters                 : in     String;
      Output_File                : in     String := "";
      Zero_Ok                    : in     Boolean := False
   ) return OS_Exit_Code_Type is
   ---------------------------------------------------------------------------

      Arguments                  : constant GNAT.OS_Lib.Argument_List_Access :=
                                    GNAT.OS_Lib.Argument_String_To_List (User & "@" & Remote & " " &
                                       Parameters);
      Return_Code                : Integer;
      Success                    : Boolean;

   begin
      if Debug then
         Log_In (True, "enter remote '" & Remote & "' program '" & Program &
            "' user '" & User & "' Output_File '" & Output_File &
            "' parameters '" & Parameters & "'");
         Put ("arguments: '");
         for Index in Arguments.all'range loop
            Put (Arguments.all (Index).all & "','");
         end loop;
         Put_Line ("'");
      end if;

      if Output_File = "" then
         GNAT.OS_Lib.Spawn (Program, Arguments.all, Success);
      else
         GNAT.OS_Lib.Spawn (
            Program_Name   => Program,
            Args           => Arguments.all,
            Output_File    => Output_File,
            Return_Code    => Return_Code,
            Success        => Success,
            Err_To_Out     => True);
      end if;
      Log_Here (Debug, "success " & Success'img & " Return_Code" &
         Return_Code'img);
      if Success then
         declare
            Result               : constant OS_Exit_Code_Type :=
                                    Translate_Return_Code (
                                       Return_Code, Zero_Ok);
         begin
            Log_Out (Debug, "result " & Result'img);
            return Result;
         end;
      else
         Log_Exception (Debug, "spawn filed");
         raise Failed with "GNAT.OS_Lib.Spawn failed running '" &
            Ada_Lib.OS.Run.Paths.Remote_Program & "' to connect to " & Remote;
      end if;
   end Spawn;

   ---------------------------------------------------------------------------
   function Spawn (
      Program                    : in     String;
      Parameters                 : in     String;
      Output_File                : in     String := "";
      Zero_Ok                    : in     Boolean := False
   ) return OS_Exit_Code_Type is
   ---------------------------------------------------------------------------

      Arguments                  : constant GNAT.OS_Lib.Argument_List_Access :=
                                    GNAT.OS_Lib.Argument_String_To_List (Parameters);
      Success                    : Boolean;

   begin
      if Debug then
         Log_In (True, "enter program '" & Program &
            "' Output_File '" & Output_File &
            "' parameters '" & Parameters & "'");
         for Index in Arguments.all'range loop
            Put_Line (Quote (Arguments.all (Index).all));
         end loop;
         New_Line;
      end if;

      Check_Program (Program);

      if Output_File = "" then
         GNAT.OS_Lib.Spawn (Program, Arguments.all, Success);
         Log_Here (Debug, "success " & Success'img);
      else
         declare
            Return_Code          : Integer;

         begin
            GNAT.OS_Lib.Spawn (Program, Arguments.all, Output_File, Success,
               Return_Code);
            Log_Here (Debug, "success " & Success'img &
               " Return_Code" & Return_Code'img);
            if Success then
               declare
                  Result               : constant OS_Exit_Code_Type :=
                                          Translate_Return_Code (
                                             Return_Code, Zero_Ok);
               begin
                  Log_Out ( Debug, "result " & Result'img);
                  return Result;
               end;
            else
               Log_Exception (Debug, "spawn filed");
               raise Failed with "GNAT.OS_Lib.Spawn failed with code " &
                  Return_Code'img & " running '" & Program & "";
            end if;
         end;
      end if;
      if Success then
         Log_Out (Debug, "success");
         return No_Error;
      else
         Log_Exception (Debug, "spawn filed");
         raise Failed with "GNAT.OS_Lib.Spawn running '" & Program & "";
      end if;

   exception
      when Fault: others =>
         Log_Exception (Debug, Fault);
         raise;

   end Spawn;

   ---------------------------------------------------------------------------
   function Spawn (
      Program                    : in     String;
      Parameters                 : in     String;
      Zero_Ok                    : in     Boolean := False
   ) return String is
   ---------------------------------------------------------------------------

      Output_File                : File_Descriptor;
      Temporary_File_Name        : Ada_Lib.OS.Temporary_File_Name;

   begin
      Log_In (Debug, Quote ("Parameter", Parameters) &
         Quote (" Parameter", Parameters));
      Create_Scratch_File (Output_File, Temporary_File_Name);
      Log_Here (Debug, Quote ("Temporary_File_Name", Temporary_File_Name));

      declare
         Output_File             : Ada.Text_IO.File_Type;
         Output_File_Name        : String renames Temporary_File_Name (
                                    Temporary_File_Name'first ..
                                       Temporary_File_Name'last - 1);
         Result                  : constant OS_Exit_Code_Type :=
                                    Run.Spawn (
                                       Program, Parameters, Output_File_Name,
                                       Zero_OK);

      begin
         Log_Here (Debug, "result " & Result'img &
            Quote (" Output_File_Name", Output_File_Name));

         if Result /= No_Error then
            Log_Exception (Debug);
            raise Failed with Program &
               " failed with return value " & Result'img;
         end if;

         Ada.Text_IO.Open (Output_File, Ada.Text_IO.In_File,
            Output_File_Name);

         declare
            Data                 : constant String :=
                                    Ada.Text_IO.Get_Line (Output_File);
         begin
            Ada.Text_IO.Close (Output_File);

            if not Debug then
               Ada_Lib.Directory.Delete (Output_File_Name);
            end if;

            Log_Out (Debug, Quote ("Data", Data));
            return Data;
         end;
      end;
   end Spawn;

   package body Spawn_Package is

      ---------------------------------------------------------------------------
      procedure Spawn (
         Program                    : in     String;
         Parameters                 : in     String;
         Context                    : in out Context_Type;
         Callback                   : in     Line_Callback_Access;
         Zero_Ok                    : in     Boolean := False) is
      ---------------------------------------------------------------------------

         Output_File                : File_Descriptor;
         Temporary_File_Name        : Ada_Lib.OS.Temporary_File_Name;

      begin
         Log_In (Debug, Quote ("Parameter", Parameters) &
            Quote (" Parameter", Parameters));
         Create_Scratch_File (Output_File, Temporary_File_Name);
         Log_Here (Debug, Quote ("Temporary_File_Name", Temporary_File_Name));

         declare
            Output_File             : Ada.Text_IO.File_Type;
            Output_File_Name        : String renames Temporary_File_Name (
                                       Temporary_File_Name'first ..
                                          Temporary_File_Name'last - 1);
            Result                  : constant OS_Exit_Code_Type :=
                                       Run.Spawn (
                                          Program, Parameters, Output_File_Name,
                                          Zero_OK);

         begin
            Log_Here (Debug, "result " & Result'img &
               Quote (" Output_File_Name", Output_File_Name));

            if Result /= No_Error then
               raise Failed with Program &
                  " failed with return value " & Result'img;
            end if;

            Ada.Text_IO.Open (Output_File, Ada.Text_IO.In_File,
               Output_File_Name);

            while not Ada.Text_IO.End_Of_File (Output_File) loop
               Callback (Context, Ada.Text_IO.Get_Line (Output_File));
            end loop;

            Ada.Text_IO.Close (Output_File);

            if not Debug then
               Ada_Lib.Directory.Delete (Output_File_Name);
            end if;
         end;
         Log_Out (Debug);
      end Spawn;

      ---------------------------------------------------------------------------
      procedure Spawn (             -- run local
         Program                    : in     String;
         Parameters                 : in     String;
         Context                    : in out Context_Type;
         Callback                   : in     File_Callback_Access;
         Zero_Ok                    : in     Boolean := False) is
      ---------------------------------------------------------------------------

         Output_File                : File_Descriptor;
         Temporary_File_Name        : Ada_Lib.OS.Temporary_File_Name;

      begin
         Log_In (Debug, Quote ("Parameters", Parameters));
         Create_Scratch_File (Output_File, Temporary_File_Name);
         Log_Here (Debug, Quote ("Temporary_File_Name", Temporary_File_Name));

         declare
            Output_File             : Ada.Text_IO.File_Type;
            Output_File_Name        : String renames Temporary_File_Name (
                                       Temporary_File_Name'first ..
                                          Temporary_File_Name'last - 1);
            Result                  : constant OS_Exit_Code_Type :=
                                       Run.Spawn (
                                          Program, Parameters, Output_File_Name,
                                          Zero_OK);

         begin
            Log_Here (Debug, "result " & Result'img &
               Quote (" Output_File_Name", Output_File_Name));

            if Result /= No_Error then
               Log_Exception (Debug);
               raise Failed with Program &
                  " failed with return value " & Result'img;
            end if;

            Ada.Text_IO.Open (Output_File, Ada.Text_IO.In_File,
               Output_File_Name);
            Callback (Context, Output_File);
            Ada.Text_IO.Close (Output_File);

            if not Debug then
               Ada_Lib.Directory.Delete (Output_File_Name);
            end if;
         end;
         Log_Out (Debug);
      end Spawn;

   end Spawn_Package;

   ---------------------------------------------------------------------------
   function Translate_Return_Code (
      Return_Code                : in     Integer;
      Zero_OK                    : in     Boolean
   ) return OS_Exit_Code_Type is
   ---------------------------------------------------------------------------

   begin
      if Return_Code > OS_Exit_Code_Type'pos (Unassigned) or else
            Return_Code < 0 then
         Put_Line ("unexpected return code " & Return_Code'img);
         return Unassigned;
      elsif Return_Code = 0 and then Zero_Ok then
         return No_Error;
      else
         return OS_Exit_Code_Type'val (Return_Code);
      end if;
   end Translate_Return_Code;

   ---------------------------------------------------------------------------
   procedure Wait_For_Remote (
      Process_ID                 :     out GNAT.OS_Lib.Process_Id) is
   ---------------------------------------------------------------------------

      Success                    : Boolean;

   begin
      GNAT.OS_Lib.Wait_Process (Process_ID, Success);
      if not Success then
         raise Failed;
      end if;
   end Wait_For_Remote;

begin
--Debug := True;
   Log_Here (Elaborate);
end Ada_Lib.OS.Run;
