with Ada.Text_IO;use Ada.Text_IO;
with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases;
with Ada_Lib.Options.AUnit_Lib;
with Ada_Lib.Options.Program;
with Ada_Lib.Options.Unit_Test;
with Ada_Lib.Options.Verification;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Unit_Test;
with GNOGA_Ada_Lib.Interfaces;
with Ada_Lib.Trace; use Ada_Lib.Trace;
--with GNOGA_Ada_Lib.Base;
with Gnoga.Gui.Base;
with Gnoga.Gui.Element.Common;
with Gnoga.Gui.Element.Form;
with Gnoga.Types.Colors;
with Gnoga.Gui.View;

package body Ada_Lib.GNOGA.Unit_Test.Window_Events is

   type Window_Connection_Data_Type
                                 is new Ada_Lib.GNOGA.Form_Connection_Type with record
--    Button                     : Standard.gnoga.Gui.Element.Common.Button_Type;
--    Form                       : Standard.gnoga.Gui.Element.Form.Form_Type;
      Delta_X                    : Integer := 0;
      Delta_Y                    : Integer := 0;
      Drag_Source_View           : Standard.gnoga.Gui.Element.Common.Div_Type;
      Drag_Target_View           : Standard.gnoga.Gui.Element.Common.Div_Type;
      Key_Pressed                : Boolean := False;
      Last_X                     : Integer;
      Last_Y                     : Integer;
      Mouse_Location             : Standard.gnoga.Gui.Element.Form.Text_Type;
      Mouse_X                    : Integer;
      Mouse_Y                    : Integer;
      Left_Position              : Integer;
--    Left_View                  : Standard.gnoga.Gui.Element.Common.Div_Type;
      Move_Count                 : Natural := 0;
      Moving                     : Boolean := False;
      Move_Started               : Boolean := False;
      Moved                      : Boolean := False;
      Move_Stopped               : Boolean := False;
--    Selection                  : Standard.gnoga.Gui.Element.Form.Selection_Type;
      Start_Left                    : Integer;
      Start_Top                    : Integer;
      Stop                       : Boolean := False;
      Text                       : Standard.gnoga.Gui.Element.Form.Text_Area_Type;
      Top_Position               : Integer;
      Top_View                   : Standard.gnoga.Gui.View.View_Type;
   end record;

   type Window_Connection_Data_Access
                        is access all Window_Connection_Data_Type;

-- type Window_Connection_Data_Class_Access
--                      is access all Window_Connection_Data_Type'class;

   type Window_Event_Test_Type   is
                        new Ada_Lib.GNOGA.Unit_Test.
                           GNOGA_Tests_Type (True, False) with null record;

   type Window_Evemt_Test_Access is access Window_Event_Test_Type;

   procedure Mouse_Move (
      Test                       : in out Standard.AUnit.Test_Cases.Test_Case'class);

   overriding
   function Name (Test : Window_Event_Test_Type) return Standard.AUnit.Message_String;

   overriding
   procedure Register_Tests (Test : in out Window_Event_Test_Type);

   overriding
   procedure Set_Up (
      Test                       : in out Window_Event_Test_Type
   ) with Pre => not Test.Verify_Set_Up,
          Post => Test.Verify_Set_Up;

   overriding
   procedure Tear_Down (
      Test : in out Window_Event_Test_Type
   ) with post => Test.Verify_Tear_Down;

   procedure Test_Handler (
      Main_Window    : in out Standard.Gnoga.Gui.Window.Window_Type'Class;
      Connection     : access Standard.Gnoga.Application.Multi_Connect.
                        Connection_Holder_Type);

   Suite_Name                    : constant String := "GNOGA_Window_Events";

   procedure Keyboard_Down_Handler (
      Object                     : in out Standard.Gnoga.Gui.Base.Base_Type'Class;
      Keyboard_Event                : in     Standard.Gnoga.Gui.Base.Keyboard_Event_Record);

   procedure Mouse_Drag_End_Handler (
      Object                     : in out Standard.Gnoga.Gui.Base.Base_Type'Class);

   procedure Mouse_Drag_Enter_Handler (
      Object                     : in out Standard.Gnoga.Gui.Base.Base_Type'Class);

   procedure Mouse_Drag_Handler (
      Object                     : in out Standard.Gnoga.Gui.Base.Base_Type'Class);

   procedure Mouse_Drop_Handler (
      Object                     : in out Standard.Gnoga.Gui.Base.Base_Type'Class;
      X, Y                       : in     Integer;
      Drag_Text                  : in     String);

   procedure Mouse_Drag_Leave_Handler (
      Object                     : in out Standard.Gnoga.Gui.Base.Base_Type'Class);

   procedure Mouse_Drag_Start_Handler (
      Object                     : in out Standard.Gnoga.Gui.Base.Base_Type'Class);

   procedure Mouse_Move_Handler (
      Object                     : in out Standard.Gnoga.Gui.Base.Base_Type'Class;
      Mouse_Event                : in     Standard.Gnoga.Gui.Base.Mouse_Event_Record);

   Debug                   : Boolean renames Options.Unit_Test.
                              Ada_Lib_GNOGA_Unit_Test.Event_Debug;
   Left_View_Height        : constant := 100;
   Left_View_Width         : constant := 200;
   Main_Window_Name        : constant String := "main window";
   Top_View_Height         : constant := 400;
   Top_View_Width          : constant := 800;

   ---------------------------------------------------------------
   procedure Button_Click_Handler (
      Object                     : in out Standard.Gnoga.Gui.Base.Base_Type'Class) is
   ---------------------------------------------------------------

      Connection_Data            : constant Window_Connection_Data_Access :=
                                    Window_Connection_Data_Access (
                                       Object.Connection_Data);
   begin
      Log_In (Debug);
      Connection_Data.Move_Started := not Connection_Data.Move_Started;
      Connection_Data.Button.Border (Color => (
         if Connection_Data.Move_Started then
               Standard.Gnoga.Types.Colors.Red
            else
               Standard.Gnoga.Types.Colors.Black));
      Log_Out (Debug, "move started " & Connection_Data.Move_Started'img);
   end Button_Click_Handler;

   ---------------------------------------------------------------
   procedure Keyboard_Press (
      Test                    : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

      Options  : constant Ada_Lib.Options.Verification.
                     Verification_Program_Options_Constant_Class_Access :=
                  Ada_Lib.Options.Verification.
                     Get_Ada_Lib_Read_Only_Program_Options;
      Aunit_Program_Options
               : Ada_Lib.Options.AUnit_Lib.
                     Aunit_Program_Options_Constant_Class_Access renames
                  Ada_Lib.Options.AUnit_Lib.
                     Aunit_Program_Options_Constant_Class_Access (Options);
      Connection_Data
               : constant Ada_Lib.GNOGA.Connection_Data_Class_Access :=
                     Ada_Lib.GNOGA.Get_Window_Connection_Data;
      Nested_Options
               : Ada_Lib.Options.Unit_Test.
                     Ada_Lib_Unit_Test_Nested_Options_Type
                  renames Aunit_Program_Options.Nested_Unit_Test_Options;
--    Nested_Program_Options
--             : Ada_Lib.Options.Program.Nested_Program_Options_Type'class renames
--                Ada_Lib.Options.Program.Nested_Program_Options_Type'class (
--                   Aunit_Program_Options.Nested_Program_Options);
      Press_Event
               : constant Standard.Gnoga.Gui.Base.
                  Keyboard_Event_Record := (
                    Message     => Standard.Gnoga.
                                   Gui.Base.Key_Down,
                    Key_Code    => GNOGA_Ada_Lib.Interfaces.
                                      Right_Arrow,
                    Key_Char    => '>',
                    Alt         => False,
                    Control     => False,
                    Shift       => False,
                    Meta        => False
                  );
      Window_Connection_Data
               : Window_Connection_Data_Type renames
                  Window_Connection_Data_Type (Connection_Data.all);
   begin
     Log_In (Debug);
     Pause_On_Flag ("start of test");

     Window_Connection_Data.Form.Create (Parent => Window_Connection_Data.Top_View);
     Window_Connection_Data.Form.Text_Alignment (Value => Standard.Gnoga.Gui.Element.Center);
     Window_Connection_Data.Form.Put_Line (Message => "type 'x' in the text field to stop test");
     Window_Connection_Data.Text.Create (
        Form  => Window_Connection_Data.Form,
        ID    => "Text_ID");
     Window_Connection_Data.Text.On_Key_Down_Handler (
        Handler => Keyboard_Down_Handler'Unrestricted_Access);
     Window_Connection_Data.Left_Position := Window_Connection_Data.Top_View.Position_Left;
     Window_Connection_Data.Top_Position := Window_Connection_Data.Top_View.Position_Top;

     if Nested_Options.Manual then
        Put_Line ("enter key directions for 20 seconds");
        Log_Here (Debug, "stop " & Window_Connection_Data.Stop'img);
        while not Window_Connection_Data.Stop loop
           delay 0.2;
        end loop;
        Log_Here (Debug);
     else
        Log_Here (Debug);

        for Count in 1 .. 10 loop
           delay 0.25;
           Window_Connection_Data.Text.Fire_On_Key_Down (Press_Event);
        end loop;

        Pause_On_Flag ("press fired");

     end if;
     Assert (Window_Connection_Data.Key_Pressed, "Key Down Handler not moved");
     Log_Out (Debug);

   exception

      when Fault: others =>
         Trace_Exception (Fault);
         raise;

   end Keyboard_Press;

   ---------------------------------------------------------------
   procedure Keyboard_Down_Handler (
      Object         : in out Standard.Gnoga.Gui.Base.Base_Type'Class;
      Keyboard_Event : in     Standard.Gnoga.Gui.Base.Keyboard_Event_Record) is
   pragma Unreferenced (Object);
   ---------------------------------------------------------------

--    Options  : constant Ada_Lib.Options.Verification.
--                   Verification_Program_Options_Constant_Class_Access :=
--                Ada_Lib.Options.Verification.
--                   Get_Ada_Lib_Read_Only_Program_Options;
--    Aunit_Program_Options
--             : Ada_Lib.Options.AUnit_Lib.
--                   Aunit_Program_Options_Constant_Class_Access renames
--                Ada_Lib.Options.AUnit_Lib.
--                   Aunit_Program_Options_Constant_Class_Access (Options);
      Connection_Data
               : constant Ada_Lib.GNOGA.Connection_Data_Class_Access :=
                     Ada_Lib.GNOGA.Get_Window_Connection_Data;
--    Nested_Options
--             : Ada_Lib.Options.Unit_Test.
--                   Ada_Lib_Unit_Test_Nested_Options_Type
--                renames Aunit_Program_Options.Nested_Unit_Test_Options;
      Nested_Program_Options
               : constant Options.Program.
                     Nested_Program_Options_Constant_Class_Access :=
                  Options.Program.Get_Read_Only_Nested_Program_Options;
      Window_Connection_Data
               : Window_Connection_Data_Type renames
                  Window_Connection_Data_Type (Connection_Data.all);
      Stop_Code   : constant := 88;

   begin
      Log_In (Debug, GNOGA_Ada_Lib.Interfaces.Keyboard_Event_Image (Keyboard_Event));

      if Nested_Program_Options.Verbose then
         Put_Line (GNOGA_Ada_Lib.Interfaces.Keyboard_Event_Image (Keyboard_Event));
      end if;

      if Debug or else Nested_Program_Options.Verbose then
         GNOGA_Ada_Lib.Interfaces.Dump_Keyboard_Event (Keyboard_Event);
      end if;

      case Keyboard_Event.Message is

         when Standard.Gnoga.Gui.Base.Key_Down =>
            Window_Connection_Data.Key_Pressed := True;

            case Keyboard_Event.Key_Code is

               when GNOGA_Ada_Lib.Interfaces.Down_Arrow =>
                  Window_Connection_Data.Top_Position := Window_Connection_Data.Top_Position + 1;
                  Window_Connection_Data.Top_View.Top (Window_Connection_Data.Top_Position, "px");

               when GNOGA_Ada_Lib.Interfaces.Left_Arrow =>
                  Window_Connection_Data.Left_Position := Window_Connection_Data.Left_Position - 1;
                  Window_Connection_Data.Top_View.Left (Window_Connection_Data.Left_Position, "px");

               when GNOGA_Ada_Lib.Interfaces.Right_Arrow =>
                  Window_Connection_Data.Left_Position := Window_Connection_Data.Left_Position + 1;
                  Window_Connection_Data.Top_View.Left (Window_Connection_Data.Left_Position, "px");

               when GNOGA_Ada_Lib.Interfaces.Up_Arrow =>
                  Window_Connection_Data.Top_Position := Window_Connection_Data.Top_Position - 1;
                  Window_Connection_Data.Top_View.Top (Window_Connection_Data.Top_Position, "px");

               when others =>
                  Log_Here (Debug, "code" & Keyboard_Event.Key_Code'img);

                  if Keyboard_Event.Key_Code = Stop_Code then
                     Window_Connection_Data.Stop := True;
                  end if;

            end case;

         when others =>
            Log_Here (Debug, "code" & Keyboard_Event.Key_Code'img);

      end case;

      Log_Out (Debug);
   end Keyboard_Down_Handler;

   ---------------------------------------------------------------
   procedure Mouse_Drag (
      Test                    : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

      Options  : constant Ada_Lib.Options.Verification.
                     Verification_Program_Options_Constant_Class_Access :=
                  Ada_Lib.Options.Verification.
                     Get_Ada_Lib_Read_Only_Program_Options;
      Aunit_Program_Options
               : Ada_Lib.Options.AUnit_Lib.
                     Aunit_Program_Options_Constant_Class_Access renames
                  Ada_Lib.Options.AUnit_Lib.
                     Aunit_Program_Options_Constant_Class_Access (Options);
      Nested_Options
               : Ada_Lib.Options.Unit_Test.
                     Ada_Lib_Unit_Test_Nested_Options_Type
                  renames Aunit_Program_Options.Nested_Unit_Test_Options;
--    Nested_Program_Options
--             : Ada_Lib.Options.Program.Nested_Program_Options_Type'class renames
--                Ada_Lib.Options.Program.Nested_Program_Options_Type'class (
--                   Aunit_Program_Options.Nested_Program_Options);
      Connection_Data
               : constant Ada_Lib.GNOGA.Connection_Data_Class_Access :=
                     Ada_Lib.GNOGA.Get_Window_Connection_Data;
      Window_Connection_Data
               : Window_Connection_Data_Type renames
                  Window_Connection_Data_Type (Connection_Data.all);
   begin
      Log_In (Debug);
      Pause_On_Flag ("start of test");

      Window_Connection_Data.Drag_Source_View.Create (
        Window_Connection_Data.Top_View, ID => "Source_ID");
        Window_Connection_Data.Drag_Source_View.Border (
           Width       => "2px",
           Style       => Standard.Gnoga.Gui.Element.Double,
           Color       => Standard.Gnoga.Types.Colors.Blue);
      Window_Connection_Data.Drag_Source_View.Position (Standard.Gnoga.Gui.Element.Fixed);
      Window_Connection_Data.Drag_Source_View.Top (20);
      Window_Connection_Data.Drag_Source_View.Left (20);
      Window_Connection_Data.Drag_Source_View.Height (50);
      Window_Connection_Data.Drag_Source_View.Width (50);
      Window_Connection_Data.Drag_Source_View.Draggable;
      Window_Connection_Data.Drag_Target_View.Create (Window_Connection_Data.Top_View, ID => "Target_ID");
      Window_Connection_Data.Drag_Target_View.Border (
        Width       => "10px",
        Style       => Standard.Gnoga.Gui.Element.Dashed,
        Color       => Standard.Gnoga.Types.Colors.Red);
      Window_Connection_Data.Drag_Target_View.Position (Standard.Gnoga.Gui.Element.Fixed);
      Window_Connection_Data.Drag_Target_View.Top (50);
      Window_Connection_Data.Drag_Target_View.Height (Left_View_Height);
      Window_Connection_Data.Drag_Target_View.Width (Left_View_Width);
      Window_Connection_Data.Drag_Target_View.Left (100);
      Window_Connection_Data.Left_Position := Window_Connection_Data.Drag_Target_View.Position_Left;
      Window_Connection_Data.Top_Position := Window_Connection_Data.Drag_Target_View.Position_Top;
      Log_Here (Debug, "Initial left: " & Window_Connection_Data.Left_Position'img &
        " top: " & Window_Connection_Data.Top_Position'img);
      Window_Connection_Data.Drag_Target_View.On_Drag_End_Handler (Mouse_Drag_End_Handler'access);
      Window_Connection_Data.Drag_Source_View.On_Drag_End_Handler (Mouse_Drag_End_Handler'access);
      Window_Connection_Data.Drag_Target_View.On_Drag_Enter_Handler (Mouse_Drag_Enter_Handler'access);
      Window_Connection_Data.Drag_Target_View.On_Drag_Handler (Mouse_Drag_Handler'access);
      Window_Connection_Data.Drag_Target_View.On_Drop_Handler (Mouse_Drop_Handler'access);
      Window_Connection_Data.Drag_Target_View.On_Drag_Leave_Handler (Mouse_Drag_Leave_Handler'access);
      Window_Connection_Data.Drag_Source_View.On_Drag_Start_Handler (Mouse_Drag_Start_Handler'access, "test drag");

      if Nested_Options.Manual then
        Pause ("drag the object");
      else
        Log_Here (Debug);
        Window_Connection_Data.Drag_Source_View.Fire_On_Drag_Start;

        for Count in 1 .. 10 loop
           Window_Connection_Data.Drag_Source_View.Fire_On_Drag;
           delay 0.2;
        end loop;

        Window_Connection_Data.Drag_Target_View.Fire_On_Drop (50, 75, "dropped");
        Window_Connection_Data.Drag_Source_View.Fire_On_Drag_End;
        Window_Connection_Data.Drag_Target_View.Fire_On_Drag_Enter;
        Window_Connection_Data.Drag_Target_View.Fire_On_Drag_Leave;
        Pause_On_Flag ("Drag fired");

      end if;
--    Assert (Window_Connection_Data.Drag_Started, "Drag Handler not started");
--    Assert (Window_Connection_Data.Dragd, "Drag Handler not Dragd");
--    Assert (Window_Connection_Data.Drag_Stopped, "Drag Handler not stopped");
      Log_Out (Debug);

exception
   when Fault: others =>
      Log_Exception (True, Fault);
      raise;

   end Mouse_Drag;

   ---------------------------------------------------------------
   procedure Mouse_Drag_End_Handler (
      Object                     : in out Standard.Gnoga.Gui.Base.Base_Type'Class) is
   pragma Unreferenced (Object);
   ---------------------------------------------------------------

--    Connection_Data            : constant Window_Connection_Data_Access :=
--                                  Window_Connection_Data_Access (
--                                     Object.Connection_Data);
   begin
      Log_In (Debug);

      Log_Out (Debug);
   end Mouse_Drag_End_Handler;

   ---------------------------------------------------------------
   procedure Mouse_Drag_Enter_Handler (
      Object                     : in out Standard.Gnoga.Gui.Base.Base_Type'Class) is
   pragma Unreferenced (Object);
   ---------------------------------------------------------------

--    Connection_Data            : constant Window_Connection_Data_Access :=
--                                  Window_Connection_Data_Access (
--                                     Object.Connection_Data);
   begin
      Log_In (Debug);

      Log_Out (Debug);
   end Mouse_Drag_Enter_Handler;

   ---------------------------------------------------------------
   procedure Mouse_Drag_Handler (
      Object                     : in out Standard.Gnoga.Gui.Base.Base_Type'Class) is
   pragma Unreferenced (Object);
   ---------------------------------------------------------------

--    Connection_Data            : constant Window_Connection_Data_Access :=
--                                  Window_Connection_Data_Access (
--                                     Object.Connection_Data);
   begin
      Log_In (Debug);

      Log_Out (Debug);
   end Mouse_Drag_Handler;

   ---------------------------------------------------------------
   procedure Mouse_Drop_Handler (
      Object                     : in out Standard.Gnoga.Gui.Base.Base_Type'Class;
      X, Y                       : in     Integer;
      Drag_Text                  : in     String) is
   pragma Unreferenced (Object);
   ---------------------------------------------------------------

--    Connection_Data            : constant Window_Connection_Data_Access :=
--                                  Window_Connection_Data_Access (
--                                     Object.Connection_Data);
   begin
      Log_In (Debug, "x " & X'img & " y " & Y'img & Quote (" text", Drag_Text));

      Log_Out (Debug);
   end Mouse_Drop_Handler;

   ---------------------------------------------------------------
   procedure Mouse_Drag_Leave_Handler (
      Object                     : in out Standard.Gnoga.Gui.Base.Base_Type'Class) is
   pragma Unreferenced (Object);
   ---------------------------------------------------------------

--    Connection_Data            : constant Window_Connection_Data_Access :=
--                                  Window_Connection_Data_Access (
--                                     Object.Connection_Data);
   begin
      Log_In (Debug);

      Log_Out (Debug);
   end Mouse_Drag_Leave_Handler;

   ---------------------------------------------------------------
   procedure Mouse_Drag_Start_Handler (
      Object                     : in out Standard.Gnoga.Gui.Base.Base_Type'Class) is
   pragma Unreferenced (Object);
   ---------------------------------------------------------------

--    Connection_Data            : constant Window_Connection_Data_Access :=
--                                  Window_Connection_Data_Access (
--                                     Object.Connection_Data);
   begin
      Log_In (Debug);
      Log_Out (Debug);
   end Mouse_Drag_Start_Handler;

   ---------------------------------------------------------------
   function Mouse_Location (
      Connection_Data            : in        Window_Connection_Data_Type
   ) return String is
   ---------------------------------------------------------------

      Result                     : constant String :=
                                    "pan " & Connection_Data.Mouse_X'img &
                                    " tilt " & Connection_Data.Mouse_y'img &
                                    " delta x " & Connection_Data.Delta_X'img &
                                    " y " & Connection_Data.Delta_Y'img;

   begin
      Log_Here (Debug, Result);
      return Result;
   end Mouse_Location;

   ---------------------------------------------------------------
   procedure Mouse_Move (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

      Options  : constant Ada_Lib.Options.Verification.
                     Verification_Program_Options_Constant_Class_Access :=
                  Ada_Lib.Options.Verification.
                     Get_Ada_Lib_Read_Only_Program_Options;
      Aunit_Program_Options
               : Ada_Lib.Options.AUnit_Lib.
                     Aunit_Program_Options_Constant_Class_Access renames
                  Ada_Lib.Options.AUnit_Lib.
                     Aunit_Program_Options_Constant_Class_Access (Options);
      Nested_Options
               : Ada_Lib.Options.Unit_Test.
                     Ada_Lib_Unit_Test_Nested_Options_Type
                  renames Aunit_Program_Options.Nested_Unit_Test_Options;
      Connection_Data
               : constant Ada_Lib.GNOGA.Connection_Data_Class_Access :=
                     Ada_Lib.GNOGA.Get_Window_Connection_Data;
      Window_Connection_Data
               : Window_Connection_Data_Type renames
                  Window_Connection_Data_Type (Connection_Data.all);
      Move_Event
               : Standard.Gnoga.Gui.Base.Mouse_Event_Record := (
                  Message       => Standard.Gnoga.Gui.Base.Mouse_Move,
                  X             => 0,
                  Y             => 0,
                  Screen_X      => 30,
                  Screen_Y      => 40,
                  Left_Button   => True,
                  Middle_Button => False,
                  Right_Button  => False,
                  Alt           => True,
                  Control       => False,
                  Shift         => True,
                  Meta          => False
               );
      Steps    : constant Natural := (if Nested_Options.Short_Test then
                     10
                  else
                     100);
      Move_Steps
               : constant Natural := Steps - 1;
   begin
      Log_In (Debug);
      Pause_On_Flag ("start of test");
      Window_Connection_Data.Button.Create (
         Parent         => Window_Connection_Data.Top_View,
         Content        => "Move",
         ID             => "Button_ID");
      Window_Connection_Data.Button.On_Click_Handler (
         Button_Click_Handler'Unrestricted_Access);
      Window_Connection_Data.Form.Create (
         Action         => "form",
         ID             => "Form_ID",
         Parent         => Window_Connection_Data.Top_View,
         Target         => "target");

      Window_Connection_Data.Form.Position (Standard.Gnoga.Gui.Element.Relative);
      Window_Connection_Data.Form.Top (0);
      Window_Connection_Data.Form.Left (0);
      Window_Connection_Data.Form.Border (Color => Standard.GNOGA.Types.Colors.Blue);
      Window_Connection_Data.Text.Create (
         Form     => Window_Connection_Data.Form,
         ID       => "Text_ID");
      Window_Connection_Data.Top_View.On_Mouse_Down_Handler (Mouse_Move_Handler'access);
      Window_Connection_Data.Top_View.On_Mouse_Move_Handler (Mouse_Move_Handler'access);

      if Nested_Options.Manual then
         Window_Connection_Data.Moving := true;
         Pause ("move the mouse");
      else
         Move_Event.Message  := Standard.Gnoga.Gui.Base.Mouse_Down;
         Window_Connection_Data.Top_View.Fire_On_Mouse_Down (Move_Event);
         Move_Event.Message  := Standard.Gnoga.Gui.Base.Mouse_Move;

         for Count in 1 .. Steps loop
            Move_Event.X := Move_Event.X + 1;
            Move_Event.y := Move_Event.y + 1;
            Window_Connection_Data.Top_View.Fire_On_Mouse_Move (Move_Event);
            delay 0.2;
         end loop;

         Move_Event.Message  := Standard.Gnoga.Gui.Base.Mouse_Down;
         Window_Connection_Data.Top_View.Fire_On_Mouse_Down (Move_Event);

         Assert (Window_Connection_Data.Delta_X = Move_Steps and then
            Window_Connection_Data.Delta_Y = Move_Steps,
            "wrong deleta x or y expected " & Move_Steps'img & "," &
            Move_Steps'img &
            " got " & Window_Connection_Data.Delta_X'img & "," &
               Window_Connection_Data.Delta_Y'img);
         Pause_On_Flag ("move fired");

      end if;
      Pause_On_Flag ("end of test");
      Assert (Window_Connection_Data.Move_Started, "Move Handler not started");
      Assert (Window_Connection_Data.Moved, "Move Handler not moved");
      Assert (Window_Connection_Data.Move_Stopped, "Move Handler not stopped");
      Log_Out (Debug);

   exception

      when Fault: others =>
         Log_Exception (True, Fault);
         raise;

   end Mouse_Move;

   ---------------------------------------------------------------
   procedure Mouse_Move_Handler (
      Object                  : in out Standard.Gnoga.Gui.Base.Base_Type'Class;
      Mouse_Event             : in     Standard.Gnoga.Gui.Base.Mouse_Event_Record) is
   pragma Unreferenced (Object);
   ---------------------------------------------------------------

--    Options  : constant Ada_Lib.Options.Verification.
--                   Verification_Program_Options_Constant_Class_Access :=
--                Ada_Lib.Options.Verification.
--                   Get_Ada_Lib_Read_Only_Program_Options;
--    Aunit_Program_Options
--             : Ada_Lib.Options.AUnit_Lib.
--                   Aunit_Program_Options_Constant_Class_Access renames
--                Ada_Lib.Options.AUnit_Lib.
--                   Aunit_Program_Options_Constant_Class_Access (Options);
--    Nested_Options
--             : Ada_Lib.Options.Unit_Test.
--                   Ada_Lib_Unit_Test_Nested_Options_Type
--                renames Aunit_Program_Options.Nested_Unit_Test_Options;
      Nested_Program_Options
               : constant Options.Program.
                     Nested_Program_Options_Constant_Class_Access :=
                  Options.Program.Get_Read_Only_Nested_Program_Options;
      Connection_Data
               : constant Ada_Lib.GNOGA.Connection_Data_Class_Access :=
                     Ada_Lib.GNOGA.Get_Window_Connection_Data;
      Window_Connection_Data
               : Window_Connection_Data_Type renames
                  Window_Connection_Data_Type (Connection_Data.all);
   begin
      Log_In (Debug, "moveing " & Window_Connection_Data.Moving'img &
         " event " & Mouse_Event.Message'img);

      if Nested_Program_Options.Verbose then
         Put_Line (GNOGA_Ada_Lib.Interfaces.Mouse_Event_Image (Mouse_Event));
      end if;

      if Debug then
         GNOGA_Ada_Lib.Interfaces.Dump_Mouse_Event (Mouse_Event);
      end if;

     case Mouse_Event.Message is

        when Standard.Gnoga.Gui.Base.Mouse_Down =>
           Window_Connection_Data.Moving := not Window_Connection_Data.Moving;

           if Window_Connection_Data.Moving then
              Window_Connection_Data.Move_Started := True;
           else
              Window_Connection_Data.Move_Stopped := True;
           end if;

        when Standard.Gnoga.Gui.Base.Mouse_Move =>
            if Window_Connection_Data.Moving then
               Window_Connection_Data.Move_Count := Window_Connection_Data.Move_Count + 1;
               declare
                  X              : constant Integer :=  Mouse_Event.X;
                  Y              : constant Integer :=  Mouse_Event.Y;
                  Delta_X        : constant Integer :=
                                    X - Window_Connection_Data.Mouse_X;
                  Delta_Y        : constant Integer :=
                                    Y - Window_Connection_Data.Mouse_Y;

               begin
                  Log_Here (Debug,
                     " current left " & Window_Connection_Data.Left_Position'img &
                        " top" & Window_Connection_Data.Top_Position'img &
                     " x: " & X'img & " y: " & Y'img &
                     " last x: " & Window_Connection_Data.Mouse_X'img & " y: " & Window_Connection_Data.Mouse_Y'img &
                     " delta x:" & Delta_X'img & " y:" & Delta_Y'img &
                     Mouse_Location (Window_Connection_Data));

                  if Window_Connection_Data.Move_Count > 1 then
                     Window_Connection_Data.Delta_X := Window_Connection_Data.Delta_X + Delta_X;
                     Window_Connection_Data.Delta_Y := Window_Connection_Data.Delta_Y + Delta_Y;
                     Window_Connection_Data.Text.Text (Mouse_Location (Window_Connection_Data));
                  end if;

                  Window_Connection_Data.Moved := True;
                  Window_Connection_Data.Mouse_X := X;
                  Window_Connection_Data.Mouse_Y := Y;
               end;
            end if;

         when others =>
            raise Fault with "unexpected mouse event " & Mouse_Event.Message'img;

      end case;

      Log_Out (Debug);
   end Mouse_Move_Handler;

   ---------------------------------------------------------------
   overriding
   function Name (Test : Window_Event_Test_Type) return AUnit.Message_String is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

   begin
      return AUnit.Format (Suite_Name);
   end Name;

   ---------------------------------------------------------------
   overriding
   procedure Register_Tests (Test : in out Window_Event_Test_Type) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug);

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Mouse_Move'access,
         Routine_Name   => AUnit.Format ("Mouse_Move")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Mouse_Drag'access,
         Routine_Name   => AUnit.Format ("Mouse_Drag")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Keyboard_Press'access,
         Routine_Name   => AUnit.Format ("Keyboard_Press")));

      Log_Out (Debug);
   end Register_Tests;

   ---------------------------------------------------------------
   overriding
   procedure Set_Up (
      Test                       : in out Window_Event_Test_Type) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug or Trace_Set_Up_Tear_Down);
      GNOGA.Create_Main_Window_Package.Lock_Create;
      Ada_Lib.GNOGA.Unit_Test.Set_Up_With_Handler (
         Test                    => GNOGA_Tests_Type'class (Test),
         Test_Handler            => Test_Handler'access,
         Wait_For_Message_Loop_Exit => False);

      declare
         Connection_Data   : constant Window_Connection_Data_Access :=
                              Window_Connection_Data_Access (
                                 Ada_Lib.GNOGA.Get_Window_Connection_Data);
      begin
         Connection_Data.Top_View.Create (
            Ada_Lib.GNOGA.Create_Main_Window_Package.Get_Main_Window.all,
            "Top_View_ID");
         Connection_Data.Top_View.Border (
            Width       => "3px",
            Style       => Standard.Gnoga.Gui.Element.Solid,
            Color       => Standard.Gnoga.Types.Colors.Black);
         Connection_Data.Top_View.Position (Standard.Gnoga.Gui.Element.Absolute);
         Connection_Data.Top_View.Top (20);
         Connection_Data.Top_View.Height (Top_View_Height);
         Connection_Data.Top_View.Left (20);
         Connection_Data.Top_View.Width (Top_View_Width);
   --    GNOGA_Ada_Lib.Base.Wait_For_Message_Loop_Exit;
   --log_here;
   --      Test.Main_Window := Window_Lock.Get_Window;
   --      Window_Lock.Clear_Window;
      end;
      GNOGA_Tests_Type (Test).Set_Up;
      GNOGA.Create_Main_Window_Package.Unlock_Create;
      Log_Out (Debug or Trace_Set_Up_Tear_Down);

   exception

      when Fault: others =>
         Trace_Exception (Fault);
         raise;

   end Set_Up;

   ---------------------------------------------------------------
   function Suite return AUnit.Test_Suites.Access_Test_Suite is
   ---------------------------------------------------------------

      Test_Suite                 : constant AUnit.Test_Suites.Access_Test_Suite :=
                                    new AUnit.Test_Suites.Test_Suite;
      Tests                      : constant Window_Evemt_Test_Access :=
                                    new Window_Event_Test_Type;

   begin
      Ada_Lib.Unit_Test.Suite (Suite_Name);  -- used for listing suites
      Test_Suite.Add_Test (Tests);
      return Test_Suite;
   end Suite;

   ---------------------------------------------------------------
   overriding
   procedure Tear_Down (Test : in out Window_Event_Test_Type) is
   ---------------------------------------------------------------

   begin
      Log (Debug or Trace_Set_Up_Tear_Down, Here, Who);
--    GNOGA_Ada_Lib.Clear_Connection_Data;
--    Window_Lock.Clear_Window;
      Ada_Lib.GNOGA.Unit_Test.GNOGA_Tests_Type (Test).Tear_Down;
   end Tear_Down;

   ---------------------------------------------------------------
   procedure Test_Handler (
      Main_Window    : in out Standard.Gnoga.Gui.Window.Window_Type'Class;
      Connection     : access Standard.Gnoga.Application.Multi_Connect.
                        Connection_Holder_Type) is
   pragma Unreferenced (Connection);
   ---------------------------------------------------------------

   begin
      Log_In (Debug);
      Ada_Lib.GNOGA.Create_Main_Window_Package.Set_Main_Window (
         Main_Window'unchecked_access);
      declare
         Connection_Data
               : constant Window_Connection_Data_Access :=
                     new Window_Connection_Data_Type;

      begin
         Main_Window.Document.Title (Main_Window_Name);
         Connection_Data.Main_Window := Main_Window'unchecked_access;
         Main_Window.Connection_Data (Connection_Data);
         Pause_On_Flag ("exit handler");
         Ada_Lib.GNOGA.Get_Window_Connection_Data.Set_Main_Created;
      end;
      Log_Out (Debug);
   end Test_Handler;


begin
--Debug := True;
--Elaborate := True;
   if Trace_Tests then
      Debug := True;
   end if;
--Trace_Options := True;
   Log_Here (Trace_Options or Elaborate);
end Ada_Lib.GNOGA.Unit_Test.Window_Events;
