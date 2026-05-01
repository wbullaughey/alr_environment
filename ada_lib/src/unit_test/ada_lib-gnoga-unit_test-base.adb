-- with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases;
with Ada_Lib.Options.Unit_Test;
--with Ada_Lib.Options.Verification;
--with Ada_Lib.Strings;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Unit_Test;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with Gnoga.Application.Multi_Connect;
with Gnoga.Gui.Base;
with Gnoga.Gui.Window;
with GNOGA_Ada_Lib.Base;

package body Ada_Lib.GNOGA.Unit_Test.Base is

   procedure Connect_Browser_Handler (
      Main_Window                : in out Standard.Gnoga.Gui.Window.Window_Type'Class;
      Connection                 : access Standard.Gnoga.Application.Multi_Connect.Connection_Holder_Type);

   procedure Create_Main_Window_Handler (
      Main_Window                : in out Standard.Gnoga.Gui.Window.Window_Type'Class;
      Connection                 : access Standard.Gnoga.Application.Multi_Connect.Connection_Holder_Type);

   procedure Main_Window_With_Exit_Button_Handler (
      Main_Window          : in out Standard.Gnoga.Gui.Window.Window_Type'Class;
      Connection           : access Standard.Gnoga.Application.Multi_Connect.Connection_Holder_Type);

   procedure Start_Test (
      Handler              : in     Standard.Gnoga.Application.Multi_Connect.Application_Connect_Event;
      Window_Name          : in     String);

   Connect_Browser_Name    : constant String := "Connect_Browser";
   Create_Main_Window_Name : constant String := "Create_Main_Window";
   Debug                   : Boolean renames Options.Unit_Test.
                              Ada_Lib_GNOGA_Unit_Test.Base_Debug;
   Dummy_Window            : constant String := "CAC GNOGA Base Test";
   Main_Window_With_Exit_Button_Name
                           : constant String := "Main_Window_With_Exit_Button";

   ---------------------------------------------------------------
   procedure Button_On_Exit (
      Object            : in out Standard.Gnoga.Gui.Base.Base_Type'Class) is
   ---------------------------------------------------------------

      Connection_Data   : constant Form_Connection_Class_Access :=
                           Form_Connection_Class_Access (Object.Connection_Data);

   begin
      Connection_Data.Display_Window.New_Line;
      Connection_Data.Display_Window.Put_Line ("Closing application and every connection!");

      Connection_Data.Button.Disabled;
      GNOGA_Ada_Lib.Base.Message_Loop_Signal.Completed;
   end Button_On_Exit;

   ---------------------------------------------------------------
   procedure Connect_Browser(
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
      pragma Unreferenced (Test);
   ---------------------------------------------------------------

   begin
      Log_In (Debug);
      Start_Test (Connect_Browser_Handler'access, Connect_Browser_Name);
      Log_Out (Debug);
   end Connect_Browser;

   ---------------------------------------------------------------
   procedure Connect_Browser_Handler (
      Main_Window                : in out Standard.Gnoga.Gui.Window.Window_Type'Class;
      Connection                 : access Standard.Gnoga.Application.Multi_Connect.Connection_Holder_Type) is
      pragma Unreferenced (Connection);
   ---------------------------------------------------------------

      URL                        : constant String := Main_Window.Document.URL;

   begin
      Log_In (Debug, Quote ("URL", URL));
--    Window_Lock.Set_Window (Main_Window'unchecked_access);
      Pause_On_Flag ("exit handler");
      GNOGA_Ada_Lib.Base.Set_Main_Created (True);
      GNOGA_Ada_Lib.Base.Message_Loop_Signal.Completed;
      Log_Out (Debug);
   end Connect_Browser_Handler;

   ---------------------------------------------------------------
   procedure Create_Main_Window (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
      pragma Unreferenced (Test);
   ---------------------------------------------------------------

   begin
      Log_In (Debug);
      Start_Test (Create_Main_Window_Handler'access,Create_Main_Window_Name);
      Log_Out (Debug);
   end Create_Main_Window;

   ---------------------------------------------------------------
   procedure Create_Main_Window_Handler (
      Main_Window                : in out Standard.Gnoga.Gui.Window.Window_Type'Class;
      Connection                 : access Standard.Gnoga.Application.Multi_Connect.Connection_Holder_Type) is
   pragma Unreferenced (Connection);
   ---------------------------------------------------------------

   begin
      Log_In (Debug);
      declare
         Connection_Data   : constant Form_Connection_Class_Access :=
                              Form_Connection_Class_Access (
                                 Ada_Lib.GNOGA.Get_Window_Connection_Data);
         URL               : constant String := Main_Window.Document.URL;

      begin
         Log_Here (Debug, Quote ("URL", URL));
--       Ada_Lib.Test_States.Set_Window_Connection;
         Main_Window.Document.Title (Create_Main_Window_Name);
         Connection_Data.Display_Window.Create (Main_Window, "main_window_id");
         Connection_Data.Display_Window.Put_Line ("test window content");
         Main_Window.Connection_Data (Connection_Data);
         Pause_On_Flag ("exit handler");
         GNOGA_Ada_Lib.Base.Set_Main_Created (True);
         GNOGA_Ada_Lib.Base.Message_Loop_Signal.Completed;
      end;
      Log_Out (Debug);

exception
   when Fault: others =>
      Log_Exception (True, Fault);
      raise;

   end Create_Main_Window_Handler;

   ---------------------------------------------------------------
   procedure Main_Window_With_Exit_Button (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
      pragma Unreferenced (Test);
   ---------------------------------------------------------------

   begin
      Log_In (Debug);
      Start_Test (Main_Window_With_Exit_Button_Handler'access,
         Main_Window_With_Exit_Button_Name);
      Log_Out (Debug);
   end Main_Window_With_Exit_Button;

   ---------------------------------------------------------------
   procedure Main_Window_With_Exit_Button_Handler (
      Main_Window                : in out Standard.Gnoga.Gui.Window.Window_Type'Class;
      Connection                 : access Standard.Gnoga.Application.Multi_Connect.Connection_Holder_Type) is
   pragma Unreferenced (Connection);
   ---------------------------------------------------------------

   begin
      Log_In (Debug);
      declare
         Connection_Data   : constant Form_Connection_Class_Access :=
                              Form_Connection_Class_Access (
                                 Ada_Lib.GNOGA.Get_Window_Connection_Data);
         URL               : constant String := Main_Window.Document.URL;

      begin
         Log_Here (Debug, Quote ("URL", URL));
         Main_Window.Document.Title (Main_Window_With_Exit_Button_Name);
         Main_Window.Connection_Data (Connection_Data);
         Connection_Data.Display_Window.Create (Main_Window, "main_window_id");
         Connection_Data.Form.Create (
            Parent         => Connection_Data.Display_Window,
            ID             =>"Display_Window_id");
         Connection_Data.Button.Create (
            Parent         => Connection_Data.Form,
            Content        => "exit",
            ID             => "button_id");
         Connection_Data.Button.On_Click_Handler (Button_On_Exit'Unrestricted_Access);
         Pause_On_Flag ("handler set");
         Button_On_Exit (Connection_Data.Button);
         GNOGA_Ada_Lib.Base.Set_Main_Created (True);
         GNOGA_Ada_Lib.Base.Message_Loop_Signal.Completed;
         Pause_On_Flag ("exit handler");
      end;
      Log_Out (Debug);

exception
   when Fault: others =>
      Log_Exception (True, Fault);
      raise;

   end Main_Window_With_Exit_Button_Handler;

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
      Log_In (Debug);
      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Connect_Browser'access,
         Routine_Name   => AUnit.Format (Connect_Browser_Name)));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Create_Main_Window'access,
         Routine_Name   => AUnit.Format (Create_Main_Window_Name)));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Main_Window_With_Exit_Button'access,
         Routine_Name   => AUnit.Format ("Main_Window_With_Exit_Button")));

      Log_Out (Debug);
   end Register_Tests;

------------------------------------------------------------------------------
--   overriding
--   procedure Set_Up (Test : in out Test_Type) is
------------------------------------------------------------------------------
--
--   begin
--      Log_In (Debug or Trace_Set_Up_Tear_Down);
----    Test_Completed := False;
--      GNOGA_Ada_Lib.Set_Connection_Data (new Connection_Type);
--         -- needs to be set by more specific unit test set_up
--      Ada_Lib.GNOGA.Unit_Test.GNOGA_Tests_Type (Test).Set_Up;
--      Log_Out (Debug or Trace_Set_Up_Tear_Down);
--   end Set_Up;

------------------------------------------------------------------------------
--   procedure Start (
--      Base                       : in out Test_Base_Type) is
------------------------------------------------------------------------------
--
--   begin
--      Log_In (Debug);
--      Log_Out (Debug);
--   end Start;

   ---------------------------------------------------------------
   procedure Start_Test (
      Handler                    : in     Standard.Gnoga.Application.Multi_Connect.Application_Connect_Event;
      Window_Name                : in     String) is
   ---------------------------------------------------------------

--    Options     : Ada_Lib.Options.Unit_Test.
--                   Ada_Lib_Unit_Test_Program_Options_Type'class renames
--                      Ada_Lib.Options.Unit_Test.
--                         Ada_Lib_Unit_Test_Options_Constant_Class_Access (
--                            Ada_Lib.Options.Verification.Get_Ada_Lib_Read_Only_Nested_Options).all;
   begin
not_implemented;
--      Log_In (Debug, "handler " & Ada_Lib.Strings.Image (Handler.all'address));
--      Standard.GNOGA.Application.Open_URL;
--      GNOGA_Ada_Lib.Base.Initialize_GNOGA (Handler,
--         Application_Title    => Window_Name,
--         Port                 => Options.Library_Options.GNOGA_Options.HTTP_Port,
--         Verbose              => True, -- GNOGA_Options.Verbose
--         Wait_For_Message_Loop_Exit  => True);
--      Log_Here (Debug);
----    while not Test_Completed loop
----       delay 0.1;
----    end loop;
----    Get_Base.Terminated;
--      Log_Out (Debug);
   end Start_Test;

----------------------------------------------------------------------------
   function Suite return AUnit.Test_Suites.Access_Test_Suite is
----------------------------------------------------------------------------

      Test_Suite                 : constant AUnit.Test_Suites.Access_Test_Suite :=
                                    new AUnit.Test_Suites.Test_Suite;
      Tests                      : constant Test_Access := new Test_Type;

   begin
      Log_In (Debug);
      Ada_Lib.Unit_Test.Suite (Suite_Name);  -- used for listing suites
      Test_Suite.Add_Test (Tests);
      Log_Out (Debug);
      return Test_Suite;
   end Suite;

----------------------------------------------------------------------------
   overriding
   procedure Tear_Down (Test : in out Test_Type) is
----------------------------------------------------------------------------

   begin
      Log_In (Debug or Trace_Set_Up_Tear_Down);
--    GNOGA_Ada_Lib.Clear_Connection_Data;
      GNOGA_Ada_Lib.Base.Set_Main_Created (False);
      Ada_Lib.GNOGA.Unit_Test.GNOGA_Tests_Type (Test).Tear_Down;
      Log_Out (Debug or Trace_Set_Up_Tear_Down);
   end Tear_Down;

------------------------------------------------------------------------------
--   procedure Terminated (
--      Base                       : in out Test_Base_Type) is
------------------------------------------------------------------------------
--
--   begin
--      Log_In (Debug);
--      Log_Out (Debug);
--   end Terminated;

begin
   if Trace_Tests then
      Debug := True;
   end if;
--Debug := True;
   Log_Here (Elaborate or Trace_Options);
end Ada_Lib.GNOGA.Unit_Test.Base;

