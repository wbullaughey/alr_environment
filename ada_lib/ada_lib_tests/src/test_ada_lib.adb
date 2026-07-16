with Ada.Text_IO;use Ada.Text_IO;
--with Ada_Lib.Options.Flags;
with Ada_Lib.Command_Line_Iterator;
with Ada_Lib.Help;
--with Ada_Lib.Options.Flags;
with Ada_Lib.Options.AUnit_Lib;
with Ada_Lib.Options.Program;
with Ada_Lib.Options.Unit_Test;
with Ada_Lib.Options.Verification;
with Ada_Lib.OS;
with Ada_Lib.Test.Run_Suite;
--with Ada_Lib.Timer;
with Ada_lib.Trace; use Ada_Lib.Trace;
with Ada_Lib.Trace_Tasks;
with Gnoga.Application.Multi_Connect;
--with Gnoga_Ada_Lib;

procedure Test_Ada_Lib is

   Result   : Ada_Lib.OS.OS_Exit_Code_Type := Ada_Lib.OS.No_Error;

begin
   Put_Line ("test_ada_lib");
   declare
      Aunit_Options  : aliased Ada_Lib.Options.AUnit_Lib.
                        Aunit_Program_Options_Type (
         Multi_Test        => True,
         Options_Selection => Ada_Lib.Options.AUnit_Lib.
                                 Unit_Test_With_Database_And_Template);
      Command_Parameters
            : aliased constant Ada_Lib.Options.Argument_Array := (1 .. 0 => <>);
      Debug          : Boolean renames
                        Ada_Lib.Options.Unit_Test.Ada_Lib_AUnit.Tester_Debug;
--    Nested_Program_Options
--                   : aliased Ada_Lib.Options.
--                      Unit_Test.Ada_Lib_Unit_Test_Nested_Options_Type;
   begin
--Debug := True;
      Log_Here (Debug);
      Ada_Lib.Options.Program.Set_Command_Parameters (
         Command_Parameters'unchecked_access);
      Ada_Lib.Options.Verification.Set_Ada_Lib_Program_Options (
         Ada_Lib.Options.Verification.Verification_Program_Options_Type'class (
            Aunit_Options)'unchecked_access,
         Ada_Lib.Options.Program.Nested_Program_Options_Type'class (
            Aunit_Options.Nested_Unit_Test_Options)'unchecked_access);

      if    Aunit_Options.Initialize then
         Log_Here (Debug);
         if Aunit_Options.Process (
                  Include_Options      => True,
                  Include_Non_Options  => True,
                  Modifiers            => Ada_Lib.Help.Modifiers) then
            Log_Here (Debug);
            Aunit_Options.Post_Process;
            Log_Here (Debug);
            if Ada_Lib.Options.Ada_Lib_Environment.Help_Test then
               Put_Line ("help test " & (if Ada_Lib.Exception_Occured then
                     "failed"
                  else
                     "completed"));
               if Ada_Lib.Exception_Occured then
                  Result := Ada_Lib.OS.Assertion_Exit;
               end if;
            else
               Log_Here (Debug);
               Ada_Lib.Trace_Tasks.Start ("main");
               Log_Here (Debug);
               Ada_Lib.Test.Run_Suite (Aunit_Options);
               Gnoga.Application.Multi_Connect.End_Application;
               Log_Here (Debug, "exit on done " &
                  Aunit_Options.Nested_Unit_Test_Options.Exit_On_Done'img);
               if Aunit_Options.Nested_Unit_Test_Options.Exit_On_Done then
                  Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.No_Error);
               end if;

               Ada_Lib.Trace_Tasks.Stop;
               Ada_Lib.Trace_Tasks.Report;
            end if;
         else
            Put_Line ("Options.Process failed");
         end if;
      else
         Put_Line ("initialiation failed");
      end if;
   end;
   Ada_Lib.OS.Immediate_Halt (Result);

exception
      when Fault: Ada_Lib.Command_Line_Iterator.Not_Option =>
         Trace_Exception (True, Fault, Here);
         Put_Line ("could not process command line options");
         Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.Exception_Exit);

   when Deadlock =>
      Put_Line ("Deadlock in trace at " &Here);
      Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.Exception_Exit);

   when Fault: others =>
      Trace_Exception (True, Fault, Here);
      Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.Exception_Exit);

end Test_Ada_Lib;
