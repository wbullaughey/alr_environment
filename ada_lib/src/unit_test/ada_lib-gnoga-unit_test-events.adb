with Ada.Characters.Handling;
with Ada.Text_IO;use Ada.Text_IO;
with AUnit.Assertions; use AUnit.Assertions;
--with Ada_Lib.Options.AUnit_Lib;
with Ada_Lib.Options.Program;
with Ada_Lib.Options.Unit_Test;
--with Ada_Lib.Options.Verification;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Strings;
with Ada_Lib.Unit_Test;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with AUnit.Test_Cases;
with GNOGA_Ada_Lib.Base;
with GNOGA_Ada_Lib.Interfaces;
with Gnoga.GUI.Window;
with Gnoga.Gui.Base;
with Gnoga.Types;
with GNOGA_Ada_Lib;

package body Ada_Lib.GNOGA.Unit_Test.Events is

   use type Standard.Gnoga.Gui.Base.Keyboard_Event_Record;
   use type Standard.Gnoga.Gui.Base.Mouse_Event_Record;
-- use type Standard.Gnoga.Gui.Base.Pointer_To_Base_Class;
   use type Standard.Gnoga.GUI.Window.Pointer_To_Window_Class;
   use type Standard.Gnoga.Types.Pointer_to_Connection_Data_Class;

   type Event_Connection_Data_Type
                                 is new Ada_Lib.GNOGA.Connection_Data_Type with record
      Down_Key                   : Standard.GNOGA.Gui.Base.Keyboard_Event_Record;
      Got_Click                  : Boolean := False;
      Got_Key                    : Boolean := False;
      Key                        : Character := ' ';
      Last_X                     : Integer := 0;
      Last_Y                     : Integer := 0;
      Mouse_Move_Count           : Natural := 0;
      Press_Key                  : Standard.GNOGA.Gui.Base.Keyboard_Event_Record;
      Delta_X                    : Integer := 0;
      Delta_Y                    : Integer := 0;
      Up_Key                     : Standard.GNOGA.Gui.Base.Keyboard_Event_Record;
   end record;

   type Event_Connection_Data_Access
                        is access all Event_Connection_Data_Type;

-- type Event_Connection_Data_Class_Access
--                      is access all Event_Connection_Data_Type'class;

   type Event_Test_Type is new Ada_Lib.GNOGA.Unit_Test.GNOGA_Tests_Type (
                           Initialize_GNOGA  => True,
                           Test_Driver       => False) with null record;

   type Test_Access is access Event_Test_Type;

   procedure Mouse_Click (
      Test  : in out Standard.AUnit.Test_Cases.Test_Case'class
   ) with Pre  => Ada_Lib.GNOGA.Has_Main_Window;

   overriding
   function Name (Test : Event_Test_Type) return Standard.AUnit.Message_String;

   overriding
   procedure Register_Tests (Test : in out Event_Test_Type);

   overriding
   procedure Set_Up (
      Test                       : in out Event_Test_Type
   ) with Pre => not Test.Verify_Set_Up,
          Post => Test.Verify_Set_Up;

   procedure Keyboard_Test (
      Test                       : in out AUnit.Test_Cases.Test_Case'class
   ) with Pre  => Ada_Lib.GNOGA.Has_Main_Window;

   procedure Mouse_Move_Handler (
      Object                     : in out Standard.Gnoga.Gui.Base.Base_Type'Class;
      Mouse_Event             :  in     Standard.Gnoga.Gui.Base.Mouse_Event_Record);

   overriding
   procedure Tear_Down (Test : in out Event_Test_Type
   ) with Pre => not Test.Verify_Tear_Down,
          Post => Test.Verify_Tear_Down;

   procedure Test_Handler (
      Main_Window                : in out Standard.Gnoga.Gui.Window.Window_Type'Class;
      Connection                 : access Standard.Gnoga.Application.Multi_Connect.
                                    Connection_Holder_Type);

   Auto_Mouse_Event_1              : constant Standard.Gnoga.Gui.Base.Mouse_Event_Record := (
                                    Message        => Standard.Gnoga.Gui.Base.Click,
                                    X              => 0,
                                    Y              => 0,
                                    Screen_X       => -1,
                                    Screen_Y       => -2,
                                    Left_Button    => True,
                                    Middle_Button  => False,
                                    Right_Button   => False,
                                    Alt            => True,
                                    Control        => False,
                                    Shift          => True,
                                    Meta           => False
                                 );
   Auto_Mouse_Event_2              : constant Standard.Gnoga.Gui.Base.Mouse_Event_Record := (
                                    Message        => Standard.Gnoga.Gui.Base.Click,
                                    X              => 100,
                                    Y              => 200,
                                    Screen_X       => -1,
                                    Screen_Y       => -2,
                                    Left_Button    => True,
                                    Middle_Button  => False,
                                    Right_Button   => False,
                                    Alt            => True,
                                    Control        => False,
                                    Shift          => True,
                                    Meta           => False
                                 );

   Debug             : Boolean renames Options.Unit_Test.
                        Ada_Lib_GNOGA_Unit_Test.Event_Debug;
   Main_Window_Name  : constant String := "main window";
   Suite_Name        : constant String := "GNOGA_Events";

-- package body Mouse_Move is
--
--    ---------------------------------------------------------------
--    procedure Move_Handler (
--       Object                  : in out Standard.Gnoga.Gui.Base.Base_Type'Class;
--       Mouse_Event             : in     Standard.Gnoga.Gui.Base.Mouse_Event_Record) is
--    ---------------------------------------------------------------
--
--    begin
--       Log_In (Debug, "move type " & Kind & " object type " & Tag_Name (Object'tag) &
--          " connection data " & (if Object.Connection_Data = Null then
--             "null"
--          else
--             Tag_Name (Object.Connection_Data'tag)));
--
--       declare
--          Data                    : constant Event_Connection_Data_Access :=
--                                     Event_Connection_Data_Access (
--                                        Object.Connection_Data);
--       begin
--          Data.Mouse_Move_Count := Data.Mouse_Move_Count + 1;
--          Put_Line ("mouse moved");
--          GNOGA_Ada_Lib.Interfaces.Dump_Mouse_Event (Mouse_Event);
--       end;
--       Log_Out (Debug);
--    end Move_Handler;
--
-- end Mouse_Move;
--
-- procedure Mouse_Move_Handler is new Mouse_Move.Move_Handler ("move");

   ---------------------------------------------------------------
   procedure Character_Event_Handler (
      Object                     : in out Standard.Gnoga.Gui.Base.Base_Type'Class;
      Key                        : in     Character) is
   ---------------------------------------------------------------

      Data                       : constant Event_Connection_Data_Access :=
                                    Event_Connection_Data_Access (
                                       Object.Connection_Data);
   begin
      Log_In (Debug, "key " & Key'img);
      Put_Line ("key " & Key);
      Data.Got_Key := True;
      Data.Key := Key;
      Log_Out (Debug);
   end Character_Event_Handler;

   ---------------------------------------------------------------
   procedure Click_Handler (
      Object                     : in out Standard.Gnoga.Gui.Base.Base_Type'Class) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug, Tag_Name ("object", Object'tag) &
         " connection data " & (if Object.Connection_Data = Null then
            "null"
         else
            Tag_Name ("Connection_Data", Object.Connection_Data'tag)));

      declare
         Data                    : constant Event_Connection_Data_Access :=
                                    Event_Connection_Data_Access (
                                       Object.Connection_Data);
      begin
         Data.Got_Click := True;
         Put_Line ("mouse click occured");
      end;
      Log_Out (Debug);
   end Click_Handler;

   ---------------------------------------------------------------
   procedure Click_Event_Handler (
      Object         : in out Standard.Gnoga.Gui.Base.Base_Type'Class;
      Mouse_Event    : in     Standard.Gnoga.Gui.Base.Mouse_Event_Record) is
   ---------------------------------------------------------------

--    Options  : constant Ada_Lib.Options.Verification.
--                   Verification_Program_Options_Constant_Class_Access :=
--                Ada_Lib.Options.Verification.
--                   Get_Ada_Lib_Read_Only_Program_Options;
--    Aunit_Program_Options
--             : Ada_Lib.Options.AUnit_Lib.
--                   Aunit_Program_Options_Constant_Class_Access :=
--                Ada_Lib.Options.AUnit_Lib.
--                   Get_Read_Only_AUnit_Options;
--    Nested_Options
--             : Ada_Lib.Options.Unit_Test.
--                   Ada_Lib_Unit_Test_Nested_Options_Type
--                renames Aunit_Program_Options.Nested_Unit_Test_Options;
      Nested_Options
               : constant Ada_Lib.Options.Unit_Test.
                     Ada_Lib_Unit_Test_Nested_Options_Constant_Class_Access :=
                   Options.Unit_Test.
                     Get_Readonly_Ada_Lib_Unit_Test_Nested_Options;
--    Connection_Data
--             : constant Ada_Lib.GNOGA.Connection_Data_Class_Access :=
--                   Ada_Lib.GNOGA.Get_Window_Connection_Data;
--    Event_Connection_Data
--             : Event_Connection_Data_Type renames
--                Event_Connection_Data_Type (Connection_Data.all);
   begin
      Log_In (Debug, "object type " & Tag_Name ("object", Object'tag) &
         " connection data " & (if Object.Connection_Data = Null then
            "null"
         else
            Tag_Name ("Connection_Data", Object.Connection_Data'tag)));

      declare
         Data                    : constant Event_Connection_Data_Access :=
                                    Event_Connection_Data_Access (
                                       Object.Connection_Data);
      begin
         if Nested_Options.Manual then
            Data.Got_Click := Mouse_Event.Left_Button and then
                              not Mouse_Event.Right_Button and then
                              not Mouse_Event.Middle_Button;
         else
            Data.Got_Click := Mouse_Event = Auto_Mouse_Event_1;
         end if;

         Log_Out (Debug, "got click " & Data.Got_Click'img);
      end;
      Put_Line ("mouse event occured");
      GNOGA_Ada_Lib.Interfaces.Dump_Mouse_Event (Mouse_Event);
   end Click_Event_Handler;

-- ---------------------------------------------------------------
--  function Has_Main_Window_View (
--    Test                       : in     Event_Test_Type'class
-- ) return Boolean is
-- ---------------------------------------------------------------
--
--  begin
--     return Test.Main_Window.Get_View /= Null;
--  end Has_Main_Window_View;

   ---------------------------------------------------------------
   procedure Keyboard_Event_Handler (
      Object                     : in out Standard.Gnoga.Gui.Base.Base_Type'Class;
      Keyboard_Event             : in     Standard.Gnoga.Gui.Base.Keyboard_Event_Record) is
   ---------------------------------------------------------------

      Data   : constant Event_Connection_Data_Access :=
                Event_Connection_Data_Access (Object.Connection_Data);
--    Program_Options
--          : constant Options.Program.Program_Options_Constant_Class_Access :=
--             Options.Program.Program_Options_Constant_Class_Access (
--                Options.Verification.Get_Ada_Lib_Read_Only_Program_Options);
      Nested_Program_Options
            : constant Options.Program.
                  Nested_Program_Options_Constant_Class_Access :=
               Options.Program.Get_Read_Only_Nested_Program_Options;
   begin
      Log_In (Debug);
      case Keyboard_Event.Message is

         when Standard.Gnoga.Gui.Base.Unknown =>
            Log_Here (Debug, "unknown key type");

         when Standard.Gnoga.Gui.Base.Key_Down =>
            Data.Down_Key := Keyboard_Event;

         when Standard.Gnoga.Gui.Base.Key_Press =>
            Data.Press_Key := Keyboard_Event;

         when Standard.Gnoga.Gui.Base.Key_Up =>
            Data.Up_Key := Keyboard_Event;

      end case;

      if Debug or else Nested_Program_Options.Verbose then
         GNOGA_Ada_Lib.Interfaces.Dump_Keyboard_Event (Keyboard_Event);
      end if;
      Log_Out (Debug);
   end Keyboard_Event_Handler;

   ---------------------------------------------------------------
   procedure Keyboard_Test (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

--    Options  : constant Ada_Lib.Options.Verification.
--                   Verification_Program_Options_Constant_Class_Access :=
--                Ada_Lib.Options.Verification.
--                   Get_Ada_Lib_Read_Only_Program_Options;
--    Aunit_Program_Options
--             : Ada_Lib.Options.AUnit_Lib.
--                   Aunit_Program_Options_Constant_Class_Access :=
--                Ada_Lib.Options.AUnit_Lib.
--                   Get_Read_Only_AUnit_Options;
      Nested_Options
               : constant Ada_Lib.Options.Unit_Test.
                     Ada_Lib_Unit_Test_Nested_Options_Constant_Class_Access :=
                   Options.Unit_Test.
                     Get_Readonly_Ada_Lib_Unit_Test_Nested_Options;
      Connection_Data
               : constant Ada_Lib.GNOGA.Connection_Data_Class_Access :=
                     Ada_Lib.GNOGA.Get_Window_Connection_Data;
      Event_Connection_Data
               : Event_Connection_Data_Type renames
                  Event_Connection_Data_Type (Connection_Data.all);
      Key               : constant Character := 'A';
      Down_Key_Event    : constant Standard.Gnoga.Gui.Base.Keyboard_Event_Record := (
                           Message     => Standard.Gnoga.Gui.Base.Key_Down,
                           Key_Code    => 100,
                           Key_Char    => Ada.Characters.Handling.To_Wide_Character ('B'),
                           Alt         => False,
                           Control     => False,
                           Shift       => False,
                           Meta        => False
                        );
      Press_Key_Event   : constant Standard.Gnoga.Gui.Base.Keyboard_Event_Record := (
                           Message     => Standard.Gnoga.Gui.Base.Key_Press,
                           Key_Code    => 100,
                           Key_Char    => Ada.Characters.Handling.To_Wide_Character ('C'),
                           Alt         => False,
                           Control     => False,
                           Shift       => False,
                           Meta        => False
                        );
      Up_Key_Event      : constant Standard.Gnoga.Gui.Base.Keyboard_Event_Record := (
                           Message     => Standard.Gnoga.Gui.Base.Key_Up,
                           Key_Code    => 100,
                           Key_Char    => Ada.Characters.Handling.To_Wide_Character ('D'),
                           Alt         => False,
                           Control     => False,
                           Shift       => False,
                           Meta        => False
                        );
   begin
      Log_In (Debug, (if Event_Connection_Data.Main_Window = Null then
            " null main window"
         else
            "have main window"));
      Event_Connection_Data.Main_Window.On_Character_Handler (Character_Event_Handler'access);
      Event_Connection_Data.Main_Window.On_Key_Down_Handler (Keyboard_Event_Handler'access);
      Event_Connection_Data.Main_Window.On_Key_Up_Handler (Keyboard_Event_Handler'access);
      Event_Connection_Data.Main_Window.On_Key_Press_Handler (Keyboard_Event_Handler'access);

      if Nested_Options.Manual then
         Pause ("Press enter on keyboard and then click a mouse while button");
         while not Event_Connection_Data.Got_Click loop
            delay 0.1;
         end loop;
      else
         Event_Connection_Data.Main_Window.Fire_On_Character (Key);
         Event_Connection_Data.Main_Window.Fire_On_Key_Down (Down_Key_Event);
         Event_Connection_Data.Main_Window.Fire_On_Key_Press (Press_Key_Event);
         Event_Connection_Data.Main_Window.Fire_On_Key_Up (Up_Key_Event);
      end if;

      Assert (Event_Connection_Data.Got_Key, "did not get Key");
      if not Nested_Options.Manual then
         Assert (Event_Connection_Data.Down_Key = Down_Key_Event, "did not get expected Down_Key " &
            Ada.Characters.Handling.To_Character (Down_Key_Event.Key_Char) & " got '" &
            Ada.Characters.Handling.To_Character (Event_Connection_Data.Down_Key.Key_Char) & "'");
         Assert (Event_Connection_Data.Key = Key, "did not get expected Key " & Key &
            " got '" & Event_Connection_Data.Key & "'");
         Assert (Event_Connection_Data.Press_Key = Press_Key_Event, "did not get expected Press_Key " &
            Ada.Characters.Handling.To_Character (Press_Key_Event.Key_Char) & " got '" &
            Ada.Characters.Handling.To_Character (Event_Connection_Data.Press_Key.Key_Char) & "'");
         Assert (Event_Connection_Data.Up_Key = Up_Key_Event, "did not get expected Up_Key " &
            Ada.Characters.Handling.To_Character (Up_Key_Event.Key_Char) & " got '" &
            Ada.Characters.Handling.To_Character (Event_Connection_Data.Up_Key.Key_Char) & "'");
      end if;
      Log_Out (Debug);

   exception
      when Fault: others =>
         Ada_Lib.Unit_Test.Exception_Assert (Fault);

   end Keyboard_Test;

   ---------------------------------------------------------------
   procedure Mouse_Click(
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
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
      Nested_Options
               : constant Ada_Lib.Options.Unit_Test.
                     Ada_Lib_Unit_Test_Nested_Options_Constant_Class_Access :=
                   Options.Unit_Test.
                     Get_Readonly_Ada_Lib_Unit_Test_Nested_Options;
      Connection_Data
               : constant Ada_Lib.GNOGA.Connection_Data_Class_Access :=
                     Ada_Lib.GNOGA.Get_Window_Connection_Data;
      Event_Connection_Data
               : Event_Connection_Data_Type renames
                  Event_Connection_Data_Type (Connection_Data.all);
   begin
      Log_In (Debug, (if Event_Connection_Data.Main_Window = Null then
                     "main window null"
                  else
                     "have main window"));
      Event_Connection_Data.Main_Window.On_Click_Handler (Click_Handler'access);
      if Nested_Options.Manual then
         Pause ("Press enter on keyboard and then click a mouse while button");
         Event_Connection_Data.Got_Click := True;
--          while not Connection_Data.Got_Click loop
--             delay 0.1;
--          end loop;
      else
         Connection_Data.Main_Window.Fire_On_Click;
         Assert (Event_Connection_Data.Got_Click, "did not get click");
      end if;

      Event_Connection_Data.Got_Click := False; -- clear for next event
      Connection_Data.Main_Window.On_Click_Handler (Null);
            -- unbind On_Click_Handler, only one allowed

      Connection_Data.Main_Window.On_Mouse_Click_Handler (
         Click_Event_Handler'access);
      if Nested_Options.Manual then
         Pause ("Click the left mouse while holding the shift key");

         declare
            Count    : Natural := 0;

         begin
            while not Event_Connection_Data.Got_Click loop
               delay 0.1;
               Count := Count + 1;

               if Count > 20 then
                  Put_Line ("waiting for mouse click");
                  Count := 0;
               end if;
            end loop;
         end;
         Log_Here (Debug);
      else
         Connection_Data.Main_Window.Fire_On_Mouse_Click (Auto_Mouse_Event_1);
         Assert (Event_Connection_Data.Got_Click, "did not get click");
      end if;
      Log_Out (Debug);

exception
   when Fault: others =>
      Log_Exception (True, Fault);
      raise;

   end Mouse_Click;

-- ---------------------------------------------------------------
-- procedure Mouse_Drag (
--    Test                       : in out AUnit.Test_Cases.Test_Case'class) is
-- ---------------------------------------------------------------
--
--    Local_Test                 : Event_Test_Type renames Event_Test_Type (Test);
--    Data                      : Constant Event_Connection_Data_Access :=
--                                  Event_Connection_Data_Access (Ada_Lib.GNOGA.Get_Window_Connection_Data);
--
-- begin
--    Log_In (Debug);
--    Local_Test.Connection_Data.Main_Window.On_Click_Handler (Click_Handler'access);
--    Local_Test.Connection_Data.Main_Window.On_Mouse_Drag_Handler (Drag_Handler'access);
--    if Local_Test.Connection_Data.Manual then
--       Pause ("Press enter on keyboard and then Drag the mouse over the window " &
--          "and then click the mouse");
--       while not Data.Got_Click loop
--          delay 0.1;
--       end loop;
--    else
--       Local_Test.Connection_Data.Main_Window.Fire_On_Mouse_Drag (Auto_Mouse_Event_1);
--       Local_Test.Connection_Data.Main_Window.Fire_On_Click;
--    end if;
--
--    Assert (Data.Got_Click, "did not get click");
--    Assert (Data.Mouse_Drag_Count > 0, "zero mouse Drag count");
--    Put_Line ("mouse Drag count" & Data.Mouse_Drag_Count'img);
-- end Mouse_Drag;

   ---------------------------------------------------------------
   procedure Test_Mouse_Move (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
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
      Nested_Options
               : constant Ada_Lib.Options.Unit_Test.
                     Ada_Lib_Unit_Test_Nested_Options_Constant_Class_Access :=
                   Options.Unit_Test.
                     Get_Readonly_Ada_Lib_Unit_Test_Nested_Options;
      Connection_Data
               : constant Ada_Lib.GNOGA.Connection_Data_Class_Access :=
                     Ada_Lib.GNOGA.Get_Window_Connection_Data;
      Event_Connection_Data
               : Event_Connection_Data_Type renames
                  Event_Connection_Data_Type (Connection_Data.all);
   begin
      Log_In (Debug, "manual " & Nested_Options.Manual'img);
      Connection_Data.Main_Window.On_Click_Handler (
         Click_Handler'access);
      Connection_Data.Main_Window.On_Mouse_Move_Handler (
         Mouse_Move_Handler'access);
      if Nested_Options.Manual then
         Pause ("Press enter on keyboard and then move the mouse over " &
            "the window and then click the mouse");
         while not Event_Connection_Data.Got_Click loop
            delay 0.1;
         end loop;
      else
         Connection_Data.Main_Window.Fire_On_Mouse_Move (
            Auto_Mouse_Event_1);
         Connection_Data.Main_Window.Fire_On_Mouse_Move (
            Auto_Mouse_Event_2);
         Connection_Data.Main_Window.Fire_On_Click;
         Assert (Event_Connection_Data.Delta_X = Auto_Mouse_Event_2.X and then
            Event_Connection_Data.Delta_Y = Auto_Mouse_Event_2.Y,
            "wrong deleta x or y expected " & Auto_Mouse_Event_2.X'img & "," &
               Auto_Mouse_Event_2.Y'img &
            " got " & Event_Connection_Data.Delta_X'img & "," &
               Event_Connection_Data.Delta_Y'img);
      end if;

      Assert (Event_Connection_Data.Got_Click, "did not get click");
      Assert (Event_Connection_Data.Mouse_Move_Count > 0, "zero mouse move count");
      Put_Line ("mouse move count" & Event_Connection_Data.Mouse_Move_Count'img);

exception
   when Fault: others =>
      Log_Exception (True, Fault);
      raise;

   end Test_Mouse_Move;

   ---------------------------------------------------------------
   procedure Mouse_Move_Handler (
      Object                     : in out Standard.Gnoga.Gui.Base.Base_Type'Class;
      Mouse_Event             :  in     Standard.Gnoga.Gui.Base.Mouse_Event_Record) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug, GNOGA_Ada_Lib.Interfaces.Mouse_Event_Image (Mouse_Event));

      declare
         Data                    : constant Event_Connection_Data_Access :=
                                    Event_Connection_Data_Access (
                                       Object.Connection_Data);
      begin
         Data.Mouse_Move_Count := Data.Mouse_Move_Count + 1;
         if Data.Mouse_Move_Count > 1 then   -- last has been initialized
            declare
               Delta_X           : constant Integer := Mouse_Event.X - Data.Last_X;
               Delta_Y           : constant Integer := Mouse_Event.Y - Data.Last_Y;

            begin
               GNOGA_Ada_Lib.Interfaces.Dump_Mouse_Event (Mouse_Event);
               Data.Delta_X := Data.Delta_X + Delta_X;
               Data.Delta_Y := Data.Delta_Y + Delta_Y;
               Put_Line ("move" & Data.Mouse_Move_Count'img &
                  " mouse moved delta X" & Delta_X'img & " Y" & Delta_Y'img);
            end;
         end if;
         Data.Last_X := Mouse_Event.X;
         Data.Last_Y := Mouse_Event.Y;
      end;
      Log_Out (Debug);
   end Mouse_Move_Handler;

   ---------------------------------------------------------------
   overriding
   function Name (Test : Event_Test_Type) return AUnit.Message_String is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

   begin
      return AUnit.Format (Suite_Name);
   end Name;

   ---------------------------------------------------------------
   overriding
   procedure Register_Tests (Test : in out Event_Test_Type) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug, Tag_Name (" test", event_test_type'class (Test)'tag));
      Tag_History (Debug, "test", Event_Test_Type'class (Test)'tag);

      Test.Add_Optional_Routine (
         Needs_Camera   => True,
         Routine        => Keyboard_Test'access,
         Routine_Name   => "Keyboard_Test",
         Suite_Name     => Suite_Name);

      Test.Add_Optional_Routine (
         Needs_Camera   => True,
         Routine        => Mouse_Click'access,
         Routine_Name   => "Mouse_Click",
         Suite_Name     => Suite_Name);

      Test.Add_Optional_Routine (
         Needs_Camera   => True,
         Routine        => Test_Mouse_Move'access,
         Routine_Name   => "Test_Mouse_Move",
         Suite_Name     => Suite_Name);

      Log_Out (Debug);
   end Register_Tests;

   ---------------------------------------------------------------
   overriding
   procedure Set_Up (
      Test                       : in out Event_Test_Type) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug or Trace_Set_Up_Tear_Down);

      Test.Set_Up_With_Handler (Test_Handler'access,
         Wait_For_Message_Loop_Exit => False);
--    Window_Lock.Clear_Window;
      Log_Out (Debug or Trace_Set_Up_Tear_Down);
   end Set_Up;

   ---------------------------------------------------------------
   function Suite return AUnit.Test_Suites.Access_Test_Suite is
   ---------------------------------------------------------------

      Test_Suite                 : constant AUnit.Test_Suites.Access_Test_Suite :=
                                    new AUnit.Test_Suites.Test_Suite;
      Tests                      : constant Test_Access := new Event_Test_Type;

   begin
      Ada_Lib.Unit_Test.Suite (Suite_Name);  -- used for listing suites
      Test_Suite.Add_Test (Tests);
      return Test_Suite;
   end Suite;

   ---------------------------------------------------------------
   overriding
   procedure Tear_Down (Test : in out Event_Test_Type) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug or Trace_Set_Up_Tear_Down, Here, Who);
--    GNOGA_Ada_Lib.Clear_Connection_Data;
      Ada_Lib.GNOGA.Unit_Test.GNOGA_Tests_Type (Test).Tear_Down;
      Log_Out (Debug or Trace_Set_Up_Tear_Down, Here, Who);
   end Tear_Down;

   ---------------------------------------------------------------
   procedure Test_Handler (
      Main_Window : in out Standard.Gnoga.Gui.Window.Window_Type'Class;
      Connection  : access Standard.Gnoga.Application.Multi_Connect.
                              Connection_Holder_Type) is
   pragma Unreferenced (Connection);
   ---------------------------------------------------------------

   begin
      Log_In (Debug,
         "main window " & Ada_Lib.Strings.Image (Main_Window'address));
      declare
         Connection_Data
               : constant Event_Connection_Data_Access :=
                  new Event_Connection_Data_Type;
         URL   : constant String := Main_Window.Document.URL;

      begin
         Log_Here (Debug, Quote ("URL", URL));
         Ada_Lib.GNOGA.Set_Main_Window (Main_Window'unchecked_access);
         Connection_Data.Set_Connection_Data_Main_Window (
            Main_Window'unchecked_access);
         Connection_Data.Main_Window := Main_Window'unchecked_access;
--       Ada_Lib.GNOGA.Unit_Test.Window_Lock.Set_Window (
--          Main_Window'unchecked_access);
--       Test_States.Allocate_State (Main_Window'unchecked_access,
--          Test_States.Window_Connection_Class_Access (Connection_Data));
         Main_Window.Document.Title (Main_Window_Name);
         Main_Window.Connection_Data (Connection_Data);
         Pause_On_Flag ("exit handler");
         GNOGA_Ada_Lib.Base.Set_Main_Created (True);
      end;
      Log_Out (Debug);
   end Test_Handler;

begin
   if Trace_Tests then
      Debug := Trace_Tests;
   end if;
--Debug := True;
   Log_Here (Trace_Options or Elaborate);
end Ada_Lib.GNOGA.Unit_Test.Events;
