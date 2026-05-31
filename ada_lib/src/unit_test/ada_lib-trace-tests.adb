with Ada.Characters.Latin_1;
--with Ada.Exceptions;
with Ada.Numerics.Float_Random;
--with Ada.Strings.Fixed;
--with Ada.Strings.Maps.Constants;
with Ada.Text_IO;
with Ada_Lib.Options.AUnit_Lib;
with Ada_Lib.Options.Program;
with Ada_Lib.Options.Unit_Test;
with Ada_Lib.Options.Verification;
with Ada_Lib.Parser;
with Ada_Lib.Strings;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
--with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Time;
with AUnit.Assertions; -- use AUnit.Assertions;
with AUnit.Simple_Test_Cases;
with AUnit.Test_Cases;

pragma Elaborate (Ada_Lib.Parser);

package body Ada_Lib.Trace.Tests is

   Test_Exception                : exception;

-- use type Ada_Lib.Time.Time_Type;

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

   Debug             : Boolean renames Ada_Lib.Options.Unit_Test.
                        Ada_Lib_Options_Trace_Tests.Debug_Unit_Test;

   ---------------------------------------------------------------
   procedure Check_Output (
      Output                     : in     Output_Package.List;
      Exception_Test             : in     Boolean;
      Expected                   : in     Output_List_Type;
      Start_Offset               : in     Duration) is
   ---------------------------------------------------------------

      type Direction_Type        is (Head, Tail);
      Line_Count                 : Natural := 0;

      ------------------------------------------------------------
      function Trim (
         Source                  : in     String;
         Pattern                 : in     String;
         Direction               : in     Direction_Type
      ) return String is
      ------------------------------------------------------------

--       Pattern_Length
--                : constant Positive := Pattern'length;
         Stop     : constant Natural := Ada_Lib.Strings.Index (
                     Source, Pattern);
         Message_1: constant String := "direction " & Direction'img &
            Quote (" source", Source) &
            Quote (" pattern", Pattern) &
            " stop" & Stop'img; -- & " pattern length" & Pattern_Length'img;

      begin
         Log_In (Debug, Message_1);

         declare
            Trimmed  : constant String := (if Stop = 0 then
                           Source
                        else (
                           case Direction is

                              when Head =>
                                 Source (Stop + 1 .. Source'last),

                              when Tail =>
                                 Source (Source'first .. Stop - 1)
                           )
                        );
            Message_2  : constant String := Message_1 &
               Quote (" trimmed", Trimmed);

         begin
            Log_Out (Debug, Message_2);
            return Trimmed;

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
      function Trim_Start (
         Parameter: in     String;
         Source   : in     String
      ) return String is
      ------------------------------------------------------------

         Shifted           : constant String := Strings.Up_Shift (Source);
         Stop_Trimmed      : constant String := Trim (Shifted, String'(
                              1 => Ada.Characters.Latin_1.LF), Tail);
         Main_Task_Trimmed : constant String := Trim (Stop_Trimmed, "main_task", Head);
         ADB_Trimmed       : constant String := Trim (Main_Task_Trimmed, ".ADB", Tail);
         Caught_At_Trimmed : constant String := Trim (ADB_Trimmed, "CAUGHT AT", Head);

      begin
         Log_Here (Debug, Parameter &
            Quote (" Shifted", Shifted) &
            Quote (" Stop_Trimmed", Stop_Trimmed) &
            Quote (" ADB_TrimmedADB_Trimmed", Stop_Trimmed) &
            Quote (" Caught_At_Trimmed", Caught_At_Trimmed));
         return Caught_At_Trimmed;
      end Trim_Start;
      ------------------------------------------------------------

   begin
      Log_In (Debug,
         "Exception_Test " & Exception_Test'img &
         " start offset " & Start_Offset'img);

      for Line of Output loop
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
            Log_Here (Debug, "Exception_Test " & Exception_Test'img &
               " count" & Line_Count'img &
               Quote (" line", Line) &
               " expected level" & Expected_Entry.Level'img &
               Quote (" expected line", Expected_Line) &
               " expected seconds " & Expected_Seconds'img &
               " expected hundreds " & Expected_Hundreds'img &
               " raw expected" & Raw_Expected'img);
            if Ada_Lib.Options.AUnit_Lib.
                  Aunit_Program_Options_Constant_Class_Access (
                     Program_Options).Get_Read_Only_Nested_Program_Options.Verbose then
               Ada.Text_IO.Put_Line (Quote ("line", Line));
            end if;

            if Exception_Test then
               declare
                  Pattern  : constant String := Trim_Start (
                              "Expected_Line", Expected_Line);
                  Trimmed  : constant String := Trim_Start (
                              "Line", Line.Coerce);
                  Test     : constant Boolean :=
                              Trimmed = Pattern;

               begin
                  Log_Here(Debug, "test " & Test'img &
                     Quote (" line", Line) &
                     Quote (" pattern", Pattern) & " length" & Pattern'length'img &
                     Quote (" trimmed", Trimmed) & " length" & Trimmed'length'img);
                     AUnit.Assertions.Assert (Test,
                        Quote ("trimmed line", Trimmed) &
                        Quote (" Pattern", Pattern) & " line" & Line_Count'img);
               end;
            else
               declare
                  Expected_Level       : Level_Type renames Expected (Line_Count).Level;
                  Output_Line          : constant String := Line.Coerce;
                  Closed_Bracket       : constant Natural :=
                                          Ada_Lib.Strings.Index (Output_Line, "]");
                  Closed_Perenthesis   : constant Natural :=
                                          Ada_Lib.Strings.Index (Output_Line, ")");
                  Open_Bracket         : constant Natural :=
                                          Ada_Lib.Strings.Index (Output_Line, "[");
                  Open_Perenthesis     : constant Natural :=
                                          Ada_Lib.Strings.Index (Output_Line, "(");
                  Start_Pattern        : constant Natural :=
                                          Ada_Lib.Strings.Index (Output_Line, "->");
                  Stop_Pattern         : constant Natural :=
                                          Ada_Lib.Strings.Index (Output_Line, "<-");
               begin
                  Log_Here (Debug, Quote ("line", Output_line) &
                     " [" & Open_Bracket'img & " ]" & Closed_Bracket'img &
                     " (" & Open_Perenthesis'img & " )" & Closed_Perenthesis'img &
                     " start" & Start_Pattern'img & Stop_Pattern'img);

                  AUnit.Assertions.Assert (Open_Perenthesis > 1, "bad open perenthesis" &
                     Open_Perenthesis'img & " line" & Line_Count'img);
                  AUnit.Assertions.Assert (Closed_Perenthesis > Open_Perenthesis + 1,
                     "bad closed perenthesis" & Open_Perenthesis'img & " line" & Line_Count'img);

                  AUnit.Assertions.Assert (Start_Pattern > Closed_Perenthesis,
                     "bad start pattern" & Start_Pattern'img & " line" & Line_Count'img);
                  AUnit.Assertions.Assert (Stop_Pattern < Output_Line'length, "bad stop pattern" &
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
                     Log_Here (Debug, Quote ("Time_Text", Time_Text) &
                        " Hours " & Parsed_Time.Hours'img &
                        " Hundreds " & Parsed_Time.Hundreds'img &
                        " Minutes " & Parsed_Time.Minutes'img &
                        " Parsed_Hundreds " & Parsed_Time.Parsed_Hundreds'img &
                        " Seconds " & Parsed_Time.Seconds'img);
                     Log_Here (Debug,
                        "Parsed_Time.Seconds " & Parsed_Time.Seconds'img &
                        " Parsed_Time.Hundreds " & Parsed_Time.Hundreds'img);
                     AUnit.Assertions.Assert (Parsed_Time.Minutes = 0,
                        "should not have any minutes. line" & Line_Count'img);
                     AUnit.Assertions.Assert (Parsed_Time.Seconds = Expected_Seconds,
                        "wrong number of seconds got " & Parsed_Time.Seconds'img &
                        " expected " & Expected_Seconds'img &
                        ". line" & Line_Count'img);
                     AUnit.Assertions.Assert (abs (Parsed_Time.Hundreds - Expected_Hundreds) <= 3,
                        "wrong number of hundreds got " & Parsed_Time.Hundreds'img &
                        " expected " & Expected_Hundreds'img &
                        ". line" & Line_Count'img);
                     declare
                        Level_Text        : constant String := Output_Line (
                                             Open_Perenthesis + 1 .. Closed_Perenthesis - 1);
                     begin
                        Log_Here(Debug,Quote ("level", Level_Text));
                        declare
                           Level             : constant Level_Type :=
                                                Level_Type'value (Level_Text);
                           Stripped          : constant String :=
                                                Output_Line (Start_Pattern + 2 ..
                                                   Stop_Pattern - 1);
                        begin
                           AUnit.Assertions.Assert (Level = Expected_Level, " wrong level" & Level'img &
                              " expected" & Expected_Level'img);
                           AUnit.Assertions.Assert (Stripped = Expected_Line, "unexpected" &
                              Quote (" Stripped", Stripped) &
                              Quote (" expected", Expected_Line));
                        end;
                     end;
                  end;
               end;
            end if;
         end;
      end loop;

      AUnit.Assertions.Assert (Line_Count = Expected'last, " wrong number (" & Line_Count'img &
         ") of lines received. expected" & Expected'last'img);
      Log_Out (Debug);

   exception
      when Fault: others =>
         Trace_Message_Exception (Debug, Fault, "exception in check output");
         Log_Out (Debug);
         raise;
   end Check_Output;

   ---------------------------------------------------------------
   procedure End_Test (
      Test                       : in out Test_Type) is
   ---------------------------------------------------------------

      Previous_File              : File_Class_Access;

   begin
--ada.Text_io.put_line (here);
      Replace_Output_File (Test.Saved_Output_File, Previous_File);
--ada.Text_io.put_line (here);
      Log_Here (Debug);
--ada.Text_io.put_line (here);
   end End_Test;

   ---------------------------------------------------------------
   procedure Exception_Test (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

      Local_Test                 : Test_Type renames
                                    Test_Type (Test);
--    Line_Number                : Positive := 1;
      Message                    : constant String :=
                                    "caught expected test exception";
      Expected_Output            : constant Output_List_Type := (
         ( 0, new String'("----------- exception --------------"), 0, 0),
         ( 0, new String'("Exception name:Ada_Lib.Trace.TESTS.TEST_EXCEPTION"), 0, 0),
         ( 0, new String'("Exception message:ada_lib-trace-tests.adb:*"), 0, 0),
         ( 0, new String'("handler message:'" & Message & "'"), 0, 0),
         ( 0, new String'("caught at ada_lib-trace-tests.adb:*"), 0, 0),
         ( 0, new String'("------------------------------------"), 0, 0));
      Start_Time                 : constant Ada_Lib.Time.Time_Type :=
                                    Ada_Lib.Time.Now;

   begin
      Log_In (Debug, "In Debug " & Debug'img );

      Start_Test (Local_Test);
      begin
         Log_Here (Debug);
         raise Test_Exception;

      exception

         when Fault: Test_Exception =>
            Trace_Message_Exception (Fault, Message);
--             Tag_Output (Expected_Output (1).Line.all));

      end;
      End_Test (Local_Test);
      Check_Output (Local_Test.Output.List, True, Expected_Output,
         Ada_Lib.Time.From_Start (Start_Time));
      Log_Out (Debug);

   exception

      when Fault: others =>
         Trace_Message_Exception (Debug, Fault, "error in library");
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
      T (Debug);
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

--    Start_Time                 : constant Ada_Lib.Time.Time_Type :=
--                                  Ada_Lib.Time.Now;

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
      for Index in Tests'range loop
         declare
            Test                 : Test_Type renames Tests (Index);
            Parsed_Time          : constant Parsed_Time_Type :=
                                    Time_Parser (Test.Source.all);
         begin
            Log_Here (Debug, "test" & Index'img &
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
         Log_In (Debug, "id" & ID'img);
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
         Log_Out (Debug);

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
         Log_In (Debug);
         accept Start (
            ID                   : in     Natural) do

            Task_ID := ID;
         end Start;
         Thread_Body (Task_ID);
         Log_Out (Debug);
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
      Log_In (Debug, Quote ("data", Data));
      Output_Package.Append (File.List,
         Ada_Lib.Strings.Unlimited.Coerce (Data));
      if Debug then
         Ada.Text_IO.Put_Line ("=======[" & Data & "]=======");
      else
         Ada.Text_IO.Put (Data);
      end if;
      Log_Out (Debug);
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
      if Debug then
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
      Start_Time                 : constant Ada_Lib.Time.Time_Type :=
                                    Ada_Lib.Time.Now;
   begin
      Log_In (Debug, "In");
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
      Check_Output (Local_Test.Output.List, False, Expected_Output,
         Ada_Lib.Time.From_Start (Start_Time));
      Log_Out (Debug, "Out");

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
      Log_In (Debug);
      Override_Level (0);
--Debug_Trace := True;
log_here;
      Replace_Output_File (Test.Output'unchecked_access,
         Test.Saved_Output_File);
--Log_Here_Non_Locking;
      Log_Out (Debug);
--Log_Here_Non_Locking;

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
      Log_In (Debug or Trace_Set_Up_Tear_Down);
      Output_Package.Clear (Test.Output.List);
      Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type (Test).Tear_Down;
      Log_Out (Debug or Trace_Set_Up_Tear_Down);
   end Tear_Down;

   ---------------------------------------------------------------
   function Time_Parser (
      Text                       : in     String
   ) return Parsed_Time_Type is
   ---------------------------------------------------------------

      Parser                     : Ada_Lib.Parser.Iterator_Type;
      Result                     : Parsed_Time_Type;

   begin
      Log_In (Debug, Quote ("text", Text));
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
      Log_Out (Debug, "seconds" & Result.Seconds'img &
         " hundreds " & Result.Parsed_Hundreds'img & Result.Hundreds'img);
      return Result;
   end Time_Parser;

begin
--Debug := True;
--Trace_Options := True;
   Log_Here (Elaborate or Trace_Options);
end Ada_Lib.Trace.Tests;
