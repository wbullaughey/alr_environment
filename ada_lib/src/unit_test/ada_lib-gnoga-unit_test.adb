--with Ada_Lib.Options.AUnit_Lib;
with Ada_Lib.Options.Program;
with Ada_Lib.Options.Unit_Test;
--with Ada_Lib.Options.Verification;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with GNOGA_Ada_Lib.Base;

package body Ada_Lib.GNOGA.Unit_Test is

-- use type Standard.Gnoga.Gui.Window.Pointer_To_Window_Class;

   Debug             : Boolean renames Options.Unit_Test.
                        Ada_Lib_GNOGA_Unit_Test.Test_Debug;
-- Window_Lock_Description
--                   : aliased constant String := "test states window lock";


   ---------------------------------------------------------------
   procedure Set_Up_With_Handler (
      Test           : in out GNOGA_Tests_Type;
      Test_Handler   : in     Standard.Gnoga.Application.Multi_Connect.
                                 Application_Connect_Event;
      Wait_For_Message_Loop_Exit
                     : in     Boolean) is
   ---------------------------------------------------------------

--    Options  : constant Ada_Lib.Options.Verification.
--                   Verification_Program_Options_Constant_Class_Access :=
--                Ada_Lib.Options.Verification.
--                   Get_Ada_Lib_Read_Only_Program_Options;
--    Unit_Test_Program_Options
--             : Ada_Lib.Options.AUnit_Lib.
--                Aunit_Program_Options_Constant_Class_Access renames
--                   Ada_Lib.Options.AUnit_Lib.
--                      Aunit_Program_Options_Constant_Class_Access (Options);
--    Prgram_Options
--             : Ada_Lib.Options.Program.Program_Options_Constant_Class_Access
--                renames Ada_Lib.Options.Program.
--                   Program_Options_Constant_Class_Access (
--                      Unit_Test_Program_Options);
--    Nested_Program_Options
--             : Ada_Lib.Options.Program.Nested_Program_Options_Type renames
--                Prgram_Options.Nested_Program_Options;
--    Nested_Program_Options
--             : constant Ada_Lib.Options.Program.
--                   Nested_Program_Options_Constant_Class_Access :=
--                 Options.Program.
--                   Nested_Program_Options_Constant_Class_Access;
      GNOGA_Ada_Lib_Options
               : constant Gnoga_Ada_Lib.
                     GNOGA_Ada_Lib_Options_Constant_Class_Access :=
                  Options.Program.Get_Read_Only_GNOGA_Ada_Lib_Option;

   begin
      Log_In (Debug or Trace_Set_Up_Tear_Down,
         "Initialize_GNOGA " & Test.Initialize_GNOGA'img &
         " test driver " & Test.Test_Driver'img &
         " Wait_For_Message_Loop_Exit " & Wait_For_Message_Loop_Exit'img);
--tag_history (options.all'tag);
--not_implemented;
      Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type (Test).Set_Up;
      if not Test.Test_Driver then
         Log_Here (Debug, -- "URL_Opened " & URL_Opened'img &
            " Initialize_GNOGA " & Test.Initialize_GNOGA'img);
         if Test.Initialize_GNOGA then
            Log_Here (Debug);
            Standard.GNOGA.Application.Open_URL;
            GNOGA_Ada_Lib.Base.Initialize_GNOGA (Test_Handler,
               Application_Title    => "Unit_Test",
   --          Start_Message_Loop   => True,
               Port                 => GNOGA_Ada_Lib_Options.Get_HTTP_Port,
               Verbose              => True, -- GNOGA_Options.Verbose);
               Wait_For_Message_Loop_Exit  => Wait_For_Message_Loop_Exit);
            Log_Here (Debug);
         end if;
      end if;
      Log_Out (Debug or Trace_Set_Up_Tear_Down);
   end Set_Up_With_Handler;

   ---------------------------------------------------------------
   overriding
   procedure Tear_Down (
      Test                       : in out GNOGA_Tests_Type) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug or Trace_Set_Up_Tear_Down,
         "Initialize_GNOGA " & Test.Initialize_GNOGA'img);
      if Test.Initialize_GNOGA then
         Standard.Gnoga.Application.Multi_Connect.End_Application;
         delay 0.2;  -- let server stop
      end if;

      GNOGA_Ada_Lib.Base.Set_Main_Created (False);
      Clear_Main_Window;
      Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type (Test).Tear_Down;
      Log_Out (Debug or Trace_Set_Up_Tear_Down);

   exception
      when Fault: others =>
         Trace_Exception (Debug or Trace_Set_Up_Tear_Down, Fault);
         Log_Out (Debug or Trace_Set_Up_Tear_Down);

   end Tear_Down;

-- ---------------------------------------------------------------
-- overriding
-- function Verify_Set_Up (
--    Test                       : in     GNOGA_Tests_Type
-- )  return Boolean is
-- ---------------------------------------------------------------
--
-- begin
--    return Log_Here (Test.Connection_Data /= Null and then
--           Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type (Test).Verify_Set_Up,
--       Debug, (
--          if Test.Connection_Data = Null then
--             " Test.Connection_Data is Null"
--          else
--             ""
--          ) &
--          (if Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type (Test).Verify_Set_Up then
--             ""
--          else
--             " Verify_Set_Up failed"
--          ));
-- end Verify_Set_Up;

begin
--Trace_Tests := True;
   if Trace_Tests then
      Debug := Trace_Tests;
   end if;
--Debug := True;
--Debug_Options := True;
--Trace_Options := True;
   Log_Here (Trace_Options or Elaborate);
end Ada_Lib.GNOGA.Unit_Test;
