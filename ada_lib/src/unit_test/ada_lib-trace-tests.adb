with Ada.Characters.Handling;
with Ada.Characters.Latin_1;
with Ada.Numerics.Float_Random;
with Ada.Text_IO;
with Ada_Lib.Options.AUnit_Lib;
with Ada_Lib.Options.Program;
with Ada_Lib.Options.Unit_Test;
with Ada_Lib.Options.Verification;
with Ada_Lib.Parser;
with Ada_Lib.Strings;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Time;
with AUnit.Assertions; -- use AUnit.Assertions;
with AUnit.Simple_Test_Cases;
with AUnit.Test_Cases;

pragma Elaborate (Ada_Lib.Parser);

package body Ada_Lib.Trace.Tests is

   Test_Exception                : exception;


   type Output_Type              is record
      Level                      : Level_Type;
      Line                       : Ada_Lib.Strings.String_Access;
      Seconds                    : Natural;
      Hundreds                   : Natural;
   end record;

   type Output_List_Type         is array (Positive range <>) of Output_Type;

   type Parsed_Time_Type         is record
      Hours                      : Natural;
      Hundreds                   : Natural;
      Minutes                    : Natural;
      Parsed_Hundreds            : Boolean;
      Seconds                    : Natural;
   end record;

   procedure End_Test (
      Test                       : in out Test_Type);

   procedure Exception_Test (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Parsed_Time (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Multi_Thread (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Simple (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Start_Test (
      Test                       : in out Test_Type);

   function Tag_Output (
      Line                       : in     String
   ) return String;

   function Time_Parser (
      Text                       : in     String
   ) return Parsed_Time_Type;

   Debug_Detail             : Boolean renames Ada_Lib.Options.Unit_Test.
                        Ada_Lib_Options_Trace_Tests.Debug_Detail;
   Debug_Test        : Boolean renames Ada_Lib.Options.Unit_Test.
                        Ada_Lib_Options_Trace_Tests.Debug_Test ;
   Debug_All_Tests   : Boolean renames Ada_Lib.Options.Unit_Test.
                        Ada_Lib_Options_Trace_Tests.Debug_All_Tests;

   ---------------------------------------------------------------
   procedure Check_Output (
      Test                       : in out Test_Type;
      Exception_Test             : in     Boolean;
      Expected                   : in     Output_List_Type;
      Start_Offset               : in     Duration) is
   ---------------------------------------------------------------

      type Direction_Type        is (Head, Tail);
      Line_Count                 : Natural := 0;
      Output                     : Test_File_Type renames Test.Output;
      List                       : Output_Package.List renames Output.List;

      ------------------------------------------------------------
      function Remove_Numbers (
         Source                  : in     String
      ) return String is
      ------------------------------------------------------------

         To                      : Positive := 1;
         Result                  : String (1 .. Source'length);

      begin
         for From of Source loop
            if not Ada.Characters.Handling.Is_Digit (From) then
               Result (To) := From;
               To := To + 1;
            end if;
         end loop;
         return Result (1 .. To - 1);
      end Remove_Numbers;

      ------------------------------------------------------------
      function Trim (
         Source                  : in     String;
         Pattern                 : in     String;
         Direction               : in     Direction_Type;
         Offset                  : in     Natural
      ) return String is
      ------------------------------------------------------------

         Stop     : constant Natural := Ada_Lib.Strings.Index (
                     Source, Pattern);
         Message_1: constant String := "direction " & Direction'img &
            Quote (" source", Source) &
            Quote (" pattern", Pattern) &
            " stop" & Stop'img &  -- & " pattern length" & Pattern_Length'img;
            " offset" & Offset'img;

      begin
         Log_In (Debug_Detail, Message_1);

         declare
            Trimmed  : constant String := (if Stop = 0 then
                           Source
                        else (
                           case Direction is

                              when Head =>
                                 Source (Stop + Offset + 1 .. Source'last),

                              when Tail =>
                                 Source (Source'first .. Stop - 1)
                           )
                        );
            Message_2  : constant String := Message_1 &
               Quote (" trimmed", Trimmed) & " length" & Trimmed'length'img;

         begin
            Log_Out (Debug_Detail, Message_2);
            return (if Trimmed'length = 0 then
               Source
            else
               Trimmed);

         exception

            when Fault: others =>
               Ada_Lib.Trace.Trace_Message_Exception (Fault,
                  "trim failed with " & Message_2);
               raise;
         end;

      exception

         when Fault: others =>
            Ada_Lib.Trace.Trace_Message_Exception (Fault,
               "trim failed with " & Message_1);
            raise;

      end Trim;

      ------------------------------------------------------------
      procedure Trim_Start (
         Parameter   : in     String;
         Source      : in     String;
         Result      :    out String;
         Length      :    out Positive) is
      ------------------------------------------------------------

         Saved_File : File_Class_Access;
         Unused     : File_Class_Access;

      begin
         if Debug_Detail then
            Replace_Output_File (Test.Saved_Output_File, Saved_File);
         end if;

         declare
            Shifted           : constant String := Strings.Up_Shift (Source);
            Stop_Trimmed      : constant String := Trim (Shifted, String'(
                                 1 => Ada.Characters.Latin_1.LF), Tail, 0);
            End_Trimmed       : constant String := Ada_Lib.Strings.Trim (
                                 Stop_Trimmed, Right);
            Main_Task_Trimmed : constant String := Trim (End_Trimmed,
                                 "MAIN_TASK", Head, 26);
            Time_Trimmed      : constant String := Trim (Main_Task_Trimmed, "]",
                                 Head, 1);
            Head_Trimmed      : constant String := Ada_Lib.Strings.Trim (
                                 Time_Trimmed, Left);
            Numbers_Removed   : constant String := Remove_Numbers (Head_Trimmed);

         begin
            Log_Here (Debug_Detail, Parameter &
               Quote (" Shifted", Shifted) &
               Quote (" Stop_Trimmed", Stop_Trimmed) &
               Quote (" End_Trimmed", End_Trimmed) &
               Quote (" Main_Task_Trimmed", Main_Task_Trimmed) &
               Quote (" Time_Trimmed", Time_Trimmed) &
               Quote (" Head_Trimmed", Head_Trimmed) &
               Quote (" numbers removed", Numbers_Removed));

            if Debug_Detail then
               Replace_Output_File (Saved_File, Unused);
            end if;

            Result (Result'First .. Numbers_Removed'last) := Numbers_Removed;
            Length := Numbers_Removed'length;
         end;
      end Trim_Start;
      ------------------------------------------------------------

   begin
      Log_In (Debug_Test,
         "Exception_Test " & Exception_Test'img &
         " start offset " & Start_Offset'img);

      for Line of List loop
         Line_Count := Line_Count + 1;
         if Line_Count > Expected'length then
            AUnit.Assertions.Assert (False, Quote ("too many output lines", Line));
         end if;

         declare
            Expected_Entry       : Output_Type renames Expected (Line_Count);
            Expected_Line        : String renames Expected_Entry.Line.all;
            Raw_Expected         : constant Natural := (
                                    Expected_Entry.Seconds * 10000 +
                                    Expected_Entry.Hundreds * 100 +
                                    Natural (Start_Offset * 10000.0)) / 100;
            Expected_Seconds     : constant Natural := Raw_Expected / 100;
            Expected_Hundreds    : constant Natural := Raw_Expected mod 100;
            Program_Options
               : constant Options.Program.
                  Program_Options_Constant_Class_Access := Options.Program.
                     Program_Options_Constant_Class_Access (
                        Options.Verification.
                           Get_Ada_Lib_Read_Only_Program_Options);

         begin
            Log_Here (Debug_Test, "Exception_Test " & Exception_Test'img &
               " count" & Line_Count'img &
               Quote (" line", Line) &
               " expected level" & Expected_Entry.Level'img &
               Quote (" expected line", Expected_Line) &
               " expected seconds " & Expected_Seconds'img &
               " expected hundreds " & Expected_Hundreds'img &
               " raw expected" & Raw_Expected'img);
            if Ada_Lib.Options.AUnit_Lib.
                  Aunit_Program_Options_Constant_Class_Access (
                     Program_Options).
                        Get_Read_Only_Nested_Program_Options.Verbose then
               Ada.Text_IO.Put_Line (Quote ("line", Line));
            end if;

            if Exception_Test then
               declare
                  Pattern           : String (1 ..  Expected_Line'last);
                  Pattern_Length    : Positive;
                  Trimmed           : String (1 ..  Line.Length);
                  Trimmed_Length    : Positive;
                  Test              : Boolean;

               begin
                  Trim_Start ("Expected_Line", Expected_Line, Pattern, Pattern_Length);
                  Trim_Start ("Line", Line.Coerce, Trimmed, Trimmed_Length);
                  Test := Trimmed (Trimmed'first .. Trimmed_Length) =
                     Pattern (Pattern'first .. Pattern_Length);
                  Log_Here(Debug_Test, "test " & Test'img &
                     Quote (" line", Line) &
                     Quote (" pattern", Pattern (Pattern'first .. Pattern_Length)) &
                     " length" & Pattern_Length'img &
                     Quote (" trimmed", Trimmed (Trimmed'first .. Trimmed_Length)) &
                     " length" & Trimmed_Length'img);
                     AUnit.Assertions.Assert (Test,
                        Quote ("trimmed line", Trimmed) &
                        Quote (" Pattern", Pattern) &
                        " line" & Line_Count'img & " from " & GNAT.Source_Info.Source_Location);
               end;
            else
               declare
                  Expected_Level : Level_Type renames
                                    Expected (Line_Count).Level;
                  Output_Line    : constant String := Line.Coerce;
                  Closed_Bracket : constant Natural :=
                                    Ada_Lib.Strings.Index (Output_Line, "]");
                  Closed_Perenthesis
                                 : constant Natural :=
                                    Ada_Lib.Strings.Index (Output_Line, ")");
                  Open_Bracket   : constant Natural :=
                                    Ada_Lib.Strings.Index (Output_Line, "[");
                  Open_Perenthesis
                                 : constant Natural :=
                                    Ada_Lib.Strings.Index (Output_Line, "(");
                  Start_Pattern  : constant Natural :=
                                    Ada_Lib.Strings.Index (Output_Line, "->");
                  Stop_Pattern   : constant Natural :=
                                    Ada_Lib.Strings.Index (Output_Line, "<-");
               begin
                  Log_Here (Debug_Test, Quote ("line", Output_line) &
                     " [" & Open_Bracket'img & " ]" & Closed_Bracket'img &
                     " (" & Open_Perenthesis'img & " )" &
                     Closed_Perenthesis'img &
                     " start" & Start_Pattern'img & Stop_Pattern'img);

                  AUnit.Assertions.Assert (Open_Perenthesis > 1,
                     "bad open perenthesis" &
                     Open_Perenthesis'img & " Output_Line " & Output_Line &
                     " count" & Line_Count'img &
                     " from " & GNAT.Source_Info.Source_Location);
                  AUnit.Assertions.Assert (
                     Closed_Perenthesis > Open_Perenthesis + 1,
                     "bad closed perenthesis" & Open_Perenthesis'img &
                     " Output_Line " & Output_Line &
                     " count" & Line_Count'img &
                     " from " & GNAT.Source_Info.Source_Location);

                  AUnit.Assertions.Assert (Start_Pattern > Closed_Perenthesis,
                     "bad start pattern" & Start_Pattern'img &
                     " Output_Line " & Output_Line &
                     " count" & Line_Count'img &
                     " from " & GNAT.Source_Info.Source_Location);
                  AUnit.Assertions.Assert (Stop_Pattern < Output_Line'length,
                     "bad stop pattern" &
                     Stop_Pattern'img);

                  declare
                     Time_Text   : constant String := (if Open_Bracket > 0 then
                                       Output_Line (Open_Bracket + 1 ..
                                          Closed_Bracket - 1)
                                    else
                                       Output_Line);
                     Parsed_Time : constant Parsed_Time_Type :=
                                    Time_Parser (Time_Text);
                  begin
                     Log_Here (Debug_Test, Quote ("Time_Text", Time_Text) &
                        " Hours " & Parsed_Time.Hours'img &
                        " Hundreds " & Parsed_Time.Hundreds'img &
                        " Minutes " & Parsed_Time.Minutes'img &
                        " Parsed_Hundreds " & Parsed_Time.Parsed_Hundreds'img &
                        " Seconds " & Parsed_Time.Seconds'img);
                     Log_Here (Debug_Test,
                        "Parsed_Time.Seconds " & Parsed_Time.Seconds'img &
                        " Parsed_Time.Hundreds " & Parsed_Time.Hundreds'img);
                     AUnit.Assertions.Assert (Parsed_Time.Minutes = 0,
                        "should not have any minutes. line " & Output_Line &
                        " count" & Line_Count'img &
                        " from " & GNAT.Source_Info.Source_Location);
                     AUnit.Assertions.Assert (
                        Parsed_Time.Seconds = Expected_Seconds,
                        "wrong seconds got " &
                        Parsed_Time.Seconds'img &
                        " expected " & Expected_Seconds'img &
                        ". line " & Output_Line &
                        " count" & Line_Count'img &
                        " from " & GNAT.Source_Info.Source_Location);
                     AUnit.Assertions.Assert (
                        abs (Parsed_Time.Hundreds - Expected_Hundreds) <= 3,
                        "wrong hundreds got " &
                           Parsed_Time.Hundreds'img &
                        " expected " & Expected_Hundreds'img &
                        ". line " & Output_Line &
                        " count" & Line_Count'img &
                        " from " & GNAT.Source_Info.Source_Location);
                     declare
                        Level_Text  : constant String := Output_Line (
                                       Open_Perenthesis + 1 ..
                                          Closed_Perenthesis - 1);
                     begin
                        Log_Here(Debug_Test,Quote ("level", Level_Text));
                        declare
                           Level    : constant Level_Type :=
                                       Level_Type'value (Level_Text);
                           Stripped : constant String :=
                                       Output_Line (Start_Pattern + 2 ..
                                          Stop_Pattern - 1);
                        begin
                           AUnit.Assertions.Assert (Level = Expected_Level,
                              " wrong level" & Level'img &
                              " expected" & Expected_Level'img);
                           AUnit.Assertions.Assert (Stripped = Expected_Line,
                              "unexpected" &
                              Quote (" Stripped", Stripped) &
                              Quote (" expected", Expected_Line));
                        end;
                     end;
                  end;
               end;
            end if;
         end;
      end loop;

      AUnit.Assertions.Assert (Line_Count = Expected'last,
         " wrong number (" & Line_Count'img &
         ") of lines received. expected" & Expected'last'img);
      Log_Out (Debug_Test);

   exception
      when Fault: others =>
         Trace_Message_Exception (Debug_Test, Fault,
            "exception in check output");
         Log_Out (Debug_Test);
         raise;
   end Check_Output;

   ---------------------------------------------------------------
   procedure End_Test (
      Test                       : in out Test_Type) is
   ---------------------------------------------------------------

      Previous_File              : File_Class_Access;

   begin
      Replace_Output_File (Test.Saved_Output_File, Previous_File);
      Log_Here (Debug_Test);
   end End_Test;

   ---------------------------------------------------------------
   procedure Exception_Test (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

      Local_Test                 : Test_Type renames
                                    Test_Type (Test);
      Message                    : constant String :=
                                    "caught expected test exception";
      Expected_Output            : constant Output_List_Type := (
         ( 0, new String'("ada_lib-trace-tests.adb: " &
            "Ada_Lib.Trace.Tests.Exception_Test () expected trace"), 0, 0),
         ( 0, new String'("----------- exception --------------"), 0, 0),
         ( 0, new String'(
            "Exception name:Ada_Lib.Trace.TESTS.TEST_EXCEPTION"), 0, 0),
         ( 0, new String'("Exception message:ada_lib-trace-tests.adb:"), 0, 0),
         ( 0, new String'("handler message:'" & Message & "'"), 0, 0),
         ( 0, new String'("() caught at ada_lib-trace-tests.adb: " &
            "who Ada_Lib.Trace.Tests.Exception_Test"), 0, 0),
         ( 0, new String'("------------------------------------"), 0, 0));
      Start_Time                 : constant Ada_Lib.Time.Time_Type :=
                                    Ada_Lib.Time.Now;

   begin
      Log_In (Debug_Test, "In Debug_Detail " & Debug_Detail'img &
         " Debug_All_Tests " & Debug_All_Tests'img);
      Start_Test (Local_Test);
      begin
         Log_Here ("expected trace");   -- need to keep this to match expected
         raise Test_Exception;

      exception

         when Fault: Test_Exception =>
            Trace_Message_Exception (True, Fault, Message);

      end;
      End_Test (Local_Test);
      Check_Output (Local_Test, True, Expected_Output,
         Ada_Lib.Time.From_Start (Start_Time));
      Log_Out (Debug_Test);

   exception

      when Fault: others =>
         Trace_Message_Exception (Debug_Detail or else Debug_Test, Fault,
            "error in library");
         AUnit.Assertions.Assert (False, "library failed with exception message: " &
            Ada.Exceptions.Exception_Message (Fault) &
            " name " & Ada.Exceptions.Exception_Name (Fault));

   end Exception_Test;

   ---------------------------------------------------------------
   overriding
   procedure Flush (
      File                       : in     Test_File_Type) is
   ---------------------------------------------------------------

   begin
      T (Debug_Detail);
   end Flush;

   ---------------------------------------------------------------
   procedure Parsed_Time (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

      type Test_Type             is record
         Source                  : Ada_Lib.Strings.String_Access;
         Include_Hundreds       : Boolean;
         Hours                   : Natural;
         Minutes                 : Natural;
         Seconds                 : Natural;
         Hundreds               : Natural;
      end record;

      Tests          : constant array (Positive range <>) of Test_Type := (
                        (
                           Source      => new String'("01:02:03"),
                           Include_Hundreds
                                       => False,
                           Hours       => 1,
                           Minutes     => 2,
                           Seconds     => 3,
                           Hundreds    => 0),
                        (
                           Source      => new String'("11:22:33.44"),
                           Include_Hundreds
                                       => True,
                           Hours       => 11,
                           Minutes     => 22,
                           Seconds     => 33,
                           Hundreds    => 44)
                        );

   begin
      Log_In (Debug_Detail);
      for Index in Tests'range loop
         declare
            Test                 : Test_Type renames Tests (Index);
            Parsed_Time          : constant Parsed_Time_Type :=
                                    Time_Parser (Test.Source.all);
         begin
            Log_Here (Debug_Detail, "test" & Index'img &
               Quote (" source", Test.Source.all) &
               " minutes" & Test.Minutes'img &
               " seconds" & Test.Seconds'img &
               " Hundreds" & Test.Hundreds'img &
               " parsed minutes" & Parsed_Time.Minutes'img &
               " seconds" & Parsed_Time.Seconds'img &
               " Hundreds" & Parsed_Time.Hundreds'img);
            AUnit.Assertions.Assert (Parsed_Time.Hours = Test.Hours, "test" & index'img &
               " wrong hours got" & Parsed_Time.Hours'img &
               " expected" & Test.Hours'img);
            AUnit.Assertions.Assert (Parsed_Time.Minutes = Test.Minutes, "test" & index'img &
               " wrong minutes got" & Parsed_Time.Minutes'img &
               " expected" & Test.Minutes'img);
            AUnit.Assertions.Assert (Parsed_Time.Seconds = Test.Seconds, "test" & index'img &
               " wrong seconds got" & Parsed_Time.Seconds'img &
               " expected" & Test.Seconds'img);
            if Test.Include_Hundreds then
               AUnit.Assertions.Assert (Parsed_Time.Hundreds = Test.Hundreds, "test" & index'img &
                  " wrong Hundreds got" & Parsed_Time.Hundreds'img &
                  " expected" & Test.Hundreds'img);
            end if;
         end;
      end loop;

      Log_Out (Debug_Detail);
   end Parsed_Time;

   ---------------------------------------------------------------
   procedure Multi_Thread (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

      task type Task_Type is

         entry Start (
            ID                   : Natural);

      end Task_Type;

      Randome_Generator          : Ada.Numerics.Float_Random.Generator;
      Local_Test                 : Test_Type renames Test_Type (Test);
      Number_Iterations          : constant := 10; -- 100;
      Number_Tasks               : constant := 3; -- 10;

      ------------------------------------------------------------
      procedure Thread_Body (
         ID                      : in     Natural) is
      ------------------------------------------------------------

      begin
         Log_In (Debug_Detail, "id" & ID'img);
         for Counter in 1 .. Number_Iterations loop
            declare
               Time              : constant Float :=
                                    Ada.Numerics.Float_Random.Random (
                                       Randome_Generator);
            begin
               Ada.Text_IO.Put ("   " &
                  (if ID = 0 then
                        "main"
                     else
                        "thread" & ID'img) &
                     " delay " & Ada_Lib.Strings.Image (Duration (Time),
                        Hundreds => True) &
                     " count" & Counter'img);
               delay Duration (Time);
            end;
            Ada.Text_IO.New_Line;
         end loop;
         Log_Out (Debug_Detail);

      exception

         when Fault: others =>
            Trace_Message_Exception (Fault, "error in library");
            AUnit.Assertions.Assert (False, "library failed with exception message: " &
               Ada.Exceptions.Exception_Message (Fault) &
               " name " & Ada.Exceptions.Exception_Name (Fault));
      end Thread_Body;

      ------------------------------------------------------------
      task body Task_Type is

         Task_ID                 :  Natural;

      begin
         Log_In (Debug_Detail);
         accept Start (
            ID                   : in     Natural) do

            Task_ID := ID;
         end Start;
         Thread_Body (Task_ID);
         Log_Out (Debug_Detail);
      end Task_Type;

   begin
      Log_In (False);

      declare
         Tasks                   : array (1 .. Number_Tasks) of Task_Type;

      begin
         Ada.Text_IO.Put_Line ("expected");
         for Index in Tasks'range loop
            Tasks (Index).Start (Index);
         end loop;
         Thread_Body (0);
         Ada.Text_IO.New_Line;
      end;
      End_Test (Local_Test);
   end Multi_Thread;

 ---------------------------------------------------------------
   overriding
   function Name (
      Test                       : in     Test_Type) return AUnit.Message_String is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

   begin
      return AUnit.Format (Suite_Name);
   end Name;

   ---------------------------------------------------------------
   overriding
   procedure Output (
      File                       : in out Test_File_Type;
      Data                       : in     String) is
   ---------------------------------------------------------------

   begin
      Output_Package.Append (File.List,
         Ada_Lib.Strings.Unlimited.Coerce (Data));
      if Debug_Detail then
         Ada.Text_IO.Put_Line ("=======[" & Data & "]=======");
      else
         Ada.Text_IO.Put (Data);
      end if;
   end Output;

   ---------------------------------------------------------------
   overriding
   procedure Register_Tests (
      Test                       : in out Test_Type) is
   ---------------------------------------------------------------

   begin
      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Simple'access,
         Routine_Name   => AUnit.Format ("Simple")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Exception_Test'access,
         Routine_Name   => AUnit.Format ("Exception_Test")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Parsed_Time'access,
         Routine_Name   => AUnit.Format ("Parsed_Time")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Multi_Thread'access,
         Routine_Name   => AUnit.Format ("Multi_Thread")));

   end Register_Tests;

   ---------------------------------------------------------------
   overriding
   procedure Set_Up (
      Test                       : in out Test_Type) is
   ---------------------------------------------------------------

   begin
      Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type (Test).Set_Up;
      if Debug_Test then
         delay (2.5);
      end if;
   end Set_Up;

   ---------------------------------------------------------------
   procedure Simple (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

      Local_Test                 : Test_Type renames
                                    Test_Type (Test);
      Expected_Output            : constant Output_List_Type := (
                                    ( 0, new String'("log here 1"), 0, 1),
                                    ( 1, new String'("log in 2"), 0, 1),
                                    ( 1, new String'("log here 3"), 2,21),
                                    ( 2, new String'("log in 4"), 2, 21),
                                    ( 2, new String'("log here 5"), 2, 21),
                                    ( 2, new String'("log out 6"), 2, 21),
                                    ( 1, new String'("log out 7"), 2, 21),
                                    ( 0, new String'("log here 8"), 2, 21));
      Pause_Time                 : constant := 2.2;
      Save_Include_Hundreds      : constant Boolean := Include_Hundreds;
      Start_Time                 : constant Ada_Lib.Time.Time_Type :=
                                    Ada_Lib.Time.Now;
   begin
      Log_In (Debug_Test, "In Include_Hundreds " & Include_Hundreds'img);
      Include_Hundreds := True;
      Start_Test (Local_Test);
      Log_Here ("expected " & Tag_Output (Expected_Output (1).Line.all));
      Log_In (True, "expected " & Tag_Output (Expected_Output (2).Line.all));
      delay Pause_Time;
      Log_Here ("expected " & Tag_Output (Expected_Output (3).Line.all));
      Log_In (True, "expected " & Tag_Output (Expected_Output (4).Line.all));
      Log_Here ("expected " & Tag_Output (Expected_Output (5).Line.all));
      Log_Out (True, "expected " & Tag_Output (Expected_Output (6).Line.all));
      Log_Out (True, "expected " & Tag_Output (Expected_Output (7).Line.all));
      Log_Here ("expected " & Tag_Output (Expected_Output (8).Line.all));
      End_Test (Local_Test);
      Check_Output (Local_Test, False, Expected_Output,
         Ada_Lib.Time.From_Start (Start_Time));
      Include_Hundreds := Save_Include_Hundreds;
      Log_Out (Debug_Test, "Out");

   exception

      when Fault: others =>
         Trace_Message_Exception (Fault, "error in library");
         AUnit.Assertions.Assert (False, "library failed with exception message: " &
            Ada.Exceptions.Exception_Message (Fault) &
            " name " & Ada.Exceptions.Exception_Name (Fault));

   end Simple;

   ---------------------------------------------------------------
   procedure Start_Test (
      Test                       : in out Test_Type) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug_Test);
      Override_Level (0);
      Replace_Output_File (Test.Output'unchecked_access,
         Test.Saved_Output_File);

   end Start_Test;

   ---------------------------------------------------------------
   function Suite return AUnit.Test_Suites.Access_Test_Suite is
   ---------------------------------------------------------------

      Test_Suite                 : constant AUnit.Test_Suites.Access_Test_Suite :=
                                    new AUnit.Test_Suites.Test_Suite;
      Tests                      : constant AUnit.Assertions.Test_Access :=
                                    new Test_Type;

   begin
      Ada_Lib.Unit_Test.Suite (Suite_Name);  -- used for listing suites
      Test_Suite.Add_Test (AUnit.Simple_Test_Cases.Test_Case_Access (Tests));
      return Test_Suite;
   end Suite;

   ---------------------------------------------------------------
   function Tag_Output (
      Line                       : in     String
   ) return String is
   ---------------------------------------------------------------

   begin
      return "->" & Line & "<-";
   end Tag_Output;

   ---------------------------------------------------------------
   overriding
   procedure Tear_Down (Test : in out Test_Type) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug_Test or Trace_Set_Up_Tear_Down);
      Output_Package.Clear (Test.Output.List);
      Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type (Test).Tear_Down;
      Log_Out (Debug_Test or Trace_Set_Up_Tear_Down);
   end Tear_Down;

   ---------------------------------------------------------------
   function Time_Parser (
      Text                       : in     String
   ) return Parsed_Time_Type is
   ---------------------------------------------------------------

      Parser                     : Ada_Lib.Parser.Iterator_Type;
      Result                     : Parsed_Time_Type;

   begin
      Log_In (Debug_Detail, Quote ("text", Text));
      Parser.Initialize (Text, Seperators => ":.");
      Result.Hours := Parser.Get_Number (Do_Next => True);
      Result.Minutes := Parser.Get_Number (Do_Next => True);
      Result.Seconds := Parser.Get_Number (Do_Next => True);
      if Parser.At_End then
         Result.Hundreds := 0;
         Result.Parsed_Hundreds := False;
      else
         Result.Hundreds := Parser.Get_Number (Do_Next => False);
         Result.Parsed_Hundreds := True;
      end if;
      Log_Out (Debug_Detail, "seconds" & Result.Seconds'img &
         " hundreds " & Result.Parsed_Hundreds'img & Result.Hundreds'img);
      return Result;
   end Time_Parser;

begin
--Debug_Detail := True;
--Debug_Test := True;
--Debug_All_Tests := True;
--Debug_Trace := True;
--Trace_Options := True;
   Log_Here (Elaborate or Trace_Options);
end Ada_Lib.Trace.Tests;
