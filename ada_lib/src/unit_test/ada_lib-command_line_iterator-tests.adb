with Ada.Exceptions;
with Ada.Text_IO;use Ada.Text_IO;
with AUnit.Assertions; use AUnit.Assertions;
with Ada_Lib.Help;
--with Ada_Lib.Options.Create;
with Ada_Lib.Options.Runstring;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Trace; use Ada_Lib.Trace;
--with Ada_Lib.Unit_Test.Test_Cases;

package body Ada_Lib.Command_Line_Iterator.Tests is

-- use type Ada.Strings.Maps.Character_Set;

   procedure Run_String (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Test_Quote (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   Debug                         : Boolean renames Options.
                                    Ada_Lib_Command_Line_Iterator.Debug;

   ---------------------------------------------------------------
   procedure Options(
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
      pragma Unreferenced (Test);
   ---------------------------------------------------------------

      use Ada_Lib.Options;

      B        : constant Character := 'b';
      B_Option : constant Ada_Lib.Options.Flag_Option_Type :=
                  Ada_Lib.Options.Initialize (B, Ada_Lib.Help.Trace_Modifier);
      Options_With_Modifiers
               : constant String := "b";
      Options_Without_Modifiers
               : constant String := "ac";
      Options  : constant Ada_Lib.Options.Flag_List_Type :=
                  Ada_Lib.Options.Initialize (
                     Options_With_Modifiers, Ada_Lib.Help.Trace_Modifier) &
                  Ada_Lib.Options.Initialize (
                     Options_Without_Modifiers,
                     Ada_Lib.Options.Unmodified_Flag);
      Expected_All_Options
               : constant String := Ada_Lib.Help.Trace_Modifier & "bac";
   begin
      Log_In (Debug);
      Assert (B_Option.Modified, "B option not modified");
      Ada_Lib.Options.Runstring.Options.Reset;

      Ada_Lib.Options.Runstring.Options.Register (
         Ada_Lib.Options.Runstring.Without_Parameters, Options);

      declare
         Got_Without_Parameters  : constant String :=
                                    Ada_Lib.Options.Runstring.
                                       Options.All_Options (False);
         Test_Result             : constant Boolean :=
                                    Expected_All_Options = Got_Without_Parameters;
      begin
         Log_Here (Debug, "Test_Result " & Test_Result'img &
            Quote (" Expected_All_Options", Expected_All_Options) &
            Quote (" Got_Without_Parameters", Got_Without_Parameters));
         Assert (Test_Result, "wrong options with parameters '" &
            Got_Without_Parameters & "' expected '" & Expected_All_Options & "'");
      end;
      Log_Out (Debug);

   exception

      when Fault: others =>
         Trace_Exception (Fault);
         raise;

   end Options;

   ---------------------------------------------------------------
   procedure Process(
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
      pragma Unreferenced (Test);
   ---------------------------------------------------------------

      use Ada_Lib.Options;

      With_Parameters            : aliased constant String := "st";
      Without_Parameters              : aliased constant String := "xyz";

   begin
      Log_In (Debug);
      Ada_Lib.Options.Runstring.Options.Reset;
      Log_Here (Debug);

      Ada_Lib.Options.Runstring.Options.Register (
         Ada_Lib.Options.Runstring.With_Parameters,
            Ada_Lib.Options.Initialize (With_Parameters,
            Ada_Lib.Options.Unmodified_Flag));

      Ada_Lib.Options.Runstring.Options.Register (
         Ada_Lib.Options.Runstring.Without_Parameters,
            Ada_Lib.Options.Initialize (
            Without_Parameters, Ada_Lib.Options.Unmodified_Flag));
      Log_Here (Debug);

      declare
         Got_Argument            : Boolean := False;
         Got_Parameter_S         : Boolean := False;
         Got_Parameter_T         : Boolean := False;
         Got_T                   : Boolean := False;
         Got_X                   : Boolean := False;
         Got_Y                   : Boolean := False;
         Got_Z                   : Boolean := False;
         Source                  : constant String := String'(
                                    "-txyz " &  -- option with inline parameter
                                    "abc " &    -- non optin argument
                                    "-xyz " &   -- multiple no parameter options
                                    "-xys 123");-- no option paramers fillowed by
                                                -- option with non inline paramer
         Iterator                : Internal.Iterator_Type;

      begin
         Iterator.Initialize (
            Source                     => Source,
            Include_Options            => True,
            Include_Non_Options        => True,
            Option_Prefix              => '-',
            Skip                       => 0);

         Put_Line ("Process");
         while not Iterator.At_End loop
            Log_Here (Debug);
            if Iterator.Is_Option then
               Log_Here (Debug, "got option");
               declare
                  Option   : constant Ada_Lib.Options.Flag_Option_Type'class :=
                              Iterator.Get_Option;

               begin
                  Log_Here (Debug, Option.Image);
                  if Option.Modified then
                     Assert (False, "unexpected modified options");
                  end if;
                  case Option.Option is

                     when 's' =>
                        declare
                           Parameter: constant String := Iterator.Get_Parameter;

                        begin
                           Log_Here (Debug, Quote ("parameter ", Parameter));
                           Got_X := True;
                           Assert (Parameter = "123", "wrong parameter for -s " &
                              " expected 123 got " & Parameter);
                           Got_Parameter_S := True;
                        end;

                     when 't' =>
                        declare
                           Parameter: constant String := Iterator.Get_Parameter;

                        begin
                           Log_Here (Debug, Quote ("parameter ", Parameter));
                           Got_T := True;
                           Assert (Parameter = "xyz", "wrong parameter for -t " &
                              " expected xyz got " & Parameter);
                           Got_Parameter_T := True;
                        end;

                     when 'x' =>
                        Got_X := True;

                     when 'y' =>
                        Got_Y := True;

                     when 'z' =>
                        Got_Z := True;

                     when others =>
                        Assert (False, "unexpected option '" & Option.Image & "'");

                  end case;
               end;
            else
               Log_Here (Debug);
               declare
                  Argument          : constant String := Iterator.Get_Argument;

               begin
                  Assert (Argument = "abc",
                     "got wrong argument. expected abc. got '" & Argument & "'");
                  Got_Argument := True;
               end;
            end if;

            Log_Here (Debug);
            Iterator.Advance;
         end loop;

         Assert (Got_Argument, "did not get Argument");
         Assert (Got_Parameter_S, "did not get parameter s");
         Assert (Got_Parameter_T, "did not get parameter t");
         Assert (Got_X, "did not get -s");
         Assert (Got_T, "did not get -t");
         Assert (Got_X, "did not get -x");
         Assert (Got_Y, "did not get -y");
         Assert (Got_Z, "did not get -z");
      end;
      Log_Out (Debug);

   exception
      when Fault: others =>
         Trace_Exception (Debug, Fault, Here);
         Log_Exception (Debug, "error in library");
         Assert (False, "library failed with exception " &
            Ada.Exceptions.Exception_Name (Fault) &
            " message " & Ada.Exceptions.Exception_Message (Fault));

   end Process;

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
         Routine        => Process'access,
         Routine_Name   => AUnit.Format ("Process")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Options'access,
         Routine_Name   => AUnit.Format ("Options")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Test_Quote'access,
         Routine_Name   => AUnit.Format ("Test_Quote")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Run_String'access,
         Routine_Name   => AUnit.Format ("Run_String")));

      Log_Out (Debug);
   end Register_Tests;

   ---------------------------------------------------------------
   procedure Run_String (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
      pragma Unreferenced (Test);
   ---------------------------------------------------------------

      use Ada_Lib.Options;

      Arguments                  : constant Ada_Lib.Strings.
                                       Constant_String_Array := (
                                    new String'("program name"),
                                    new String'("-pxyz"),
                                    new String'("abc"),
                                    new String'("xyz 123"),
                                    new String'("-q"),
                                    new String'("-r"),   -- option the following
                                                         -- argument is its parameter
                                    new String'("-2 3"));
      Argument_Count             : constant Positive := Arguments'Length;

      type Test_Iterator_Type is new Ada_Lib.Command_Line_Iterator.Run_String.
                                    Runstring_Iterator_Type with record
         Arguments               : Ada_Lib.Strings.Constant_String_Array (
                                    1 .. Argument_Count);
      end record;

      overriding
      function Get_Argument (
         Iterator                : in     Test_Iterator_Type;
         Index                   : in     Positive
      ) return String;

      overriding
      function Number_Arguments (
         Iterator                : in   Test_Iterator_Type
      ) return Natural;

      ---------------------------------------------------------------
      overriding
      function Get_Argument (
         Iterator                : in     Test_Iterator_Type;
         Index                   : in     Positive
      ) return String is
      ---------------------------------------------------------------

      begin
         Log_Here (Debug, "Number_Arguments" & Argument_Count'img &
            Quote (" argument" & Index'img, Iterator.Arguments (Index).all));

         return Iterator.Arguments (Index).all;
      end Get_Argument;

      ---------------------------------------------------------------
      overriding
      function Number_Arguments (
         Iterator                : in   Test_Iterator_Type
      ) return Natural is
      ---------------------------------------------------------------

      begin
         Log_Here (Debug, "Number_Arguments" & Argument_Count'img);
         return Iterator.Arguments'length;
      end Number_Arguments;
      ---------------------------------------------------------------


      With_Parameters            : aliased constant String := "pr";
      Without_Parameters         : aliased constant String := "q";
      Save_Debug                 : constant Boolean :=
                                    Ada_Lib.Command_Line_Iterator.Debug;
      Iterator_Arguments         : constant array (Positive range <>) of Positive := (
                                    1 => 3,
                                    2 => 4);

   begin
      Log_In (Debug);
      Ada_Lib.Command_Line_Iterator.Debug := Debug;
      Ada_Lib.Options.Runstring.Options.Reset;
      Log_Here (Debug);

      Ada_Lib.Options.Runstring.Options.Register (
         Ada_Lib.Options.Runstring.With_Parameters,
         Ada_Lib.Options.Initialize (
         With_Parameters, Ada_Lib.Options.Unmodified_Flag));
      Ada_Lib.Options.Runstring.Options.Register (
         Ada_Lib.Options.Runstring.Without_Parameters,
         Ada_Lib.Options.Initialize (
            Without_Parameters, Ada_Lib.Options.Unmodified_Flag));

      Log_Here (Debug);

      declare
         Current_Argument        : Positive := 1;
         Got_Argument            : array (1 .. 2) of Boolean :=
                                    (others => False);
         Got_Parameter_P         : Boolean := False;
         Got_Parameter_R         : Boolean := False;
         Got_P                   : Boolean := False;
         Got_Q                   : Boolean := False;
         Got_R                   : Boolean := False;
         Iterator                : Test_Iterator_Type;

      begin
         Iterator.Arguments := Arguments;

         Iterator.Initialize (
            Include_Options            => True,
            Include_Non_Options        => True,
            Option_Prefix              => '-',
            Skip                       => 1);

         Put_Line ("Process");
         while not Iterator.At_End loop
            if Iterator.Is_Option then
               Log_Here (Debug, "got option");
               declare
                  Option   : constant Ada_Lib.Options.Flag_Option_Type'class :=
                              Iterator.Get_Option;

               begin
                  Log_Here (Debug, "option " & Option.Image);
                  if Option.Modified then
                     Assert (False, "unexpected modified options");
                  end if;
                  case Option.Option is

                     when 'p' =>
                        declare
                           Parameter: constant String := Iterator.Get_Parameter;

                        begin
                           Log_Here (Debug, Quote ("parameter ", Parameter));
                           Got_P := True;
                           Assert (Parameter = "xyz", "wrong parameter for -s " &
                              " expected xyz got " & Parameter);
                           Got_Parameter_P := True;
                        end;

                     when 'q' =>
                        Got_Q := True;
                        Assert (not Iterator.Has_Parameter,
                           "argument after -q should not have a parameter");

                     when 'r' =>
                        Got_R := True;
                        Assert (Iterator.Has_Parameter,
                           "argument after -r should have a parameter");

--                      Iterator.Advance;
                        declare
                           Parameter: constant String := Iterator.Get_Parameter;

                        begin
                           Log_Here (Debug, Quote ("Parameter ", Parameter));
                           Assert (Parameter = "-2 3", "wrong Parameter for -r " &
                              " expected 2 3 got " & Parameter);
                           Got_Parameter_R := True;
                        end;

                     when others =>
                        Assert (False, "unexpected option '" & Option.Image & "'");

                  end case;
               end;
            else
               Log_Here (Debug, "Current_Argument" & Current_Argument'img);
               declare
                  Argument          : constant String := Iterator.Get_Argument;
                  Expected          : constant String_Constant_Access :=
                                       Iterator.Arguments (
                                          Iterator_Arguments (Current_Argument));
               begin
                  Log_Here (Debug, "Argument index" &
                     Iterator_Arguments (Current_Argument)'img &
                     Quote (" expected", Expected));
                  if Argument = Expected.all then
                     Got_Argument (Current_Argument) := True;
                  else
                     Assert (False, "got wrong argument. expected " & Expected.all &
                        " Got '" & Argument & "'");
                  end if;
                  Current_Argument := Current_Argument + 1;
               end;

            end if;

            Log_Here (Debug);
            Iterator.Advance;
         end loop;

         for Index in Got_Argument'range loop
            Assert (Got_Argument (Index), "did not get Argument");
         end loop;
         Assert (Got_Parameter_P, "did not get parameter p");
         Assert (Got_Parameter_R, "did not get parameter r");
         Assert (Got_P, "did not get -p");
         Assert (Got_Q, "did not get -q");
         Assert (Got_R, "did not get -r");
      end;
      Ada_Lib.Command_Line_Iterator.Debug := Save_Debug;
      Log_Out (Debug);

   exception
      when Fault: others =>
         Trace_Exception (Debug, Fault, Here);
         Log_Exception (Debug, "error in library");
         Assert (False, "library failed");

   end Run_String;

   ---------------------------------------------------------------
   overriding
   procedure Set_Up (Test : in out Test_Type) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug or Trace_Set_Up_Tear_Down);
      Ada_Lib.Options.Runstring.Options.Reset;
      Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type (Test).Set_Up;
      Log_Out (Debug or Trace_Set_Up_Tear_Down);
   end Set_Up;

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

   ---------------------------------------------------------------
   overriding
   procedure Tear_Down (Test : in out Test_Type) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug or Trace_Set_Up_Tear_Down);
      Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type (Test).Tear_Down;
      Log_Out (Debug or Trace_Set_Up_Tear_Down);
   end Tear_Down;

   ---------------------------------------------------------------
   procedure Test_Quote (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
      pragma Unreferenced (Test);
   ---------------------------------------------------------------

      use Ada_Lib.Options;

      With_Parameters            : aliased constant String := "pq";
      Without_Parameters              : aliased constant String := "n";

   begin
      Log_In (Debug);
      Ada_Lib.Options.Runstring.Options.Reset;
      Log_Here (Debug);

      Ada_Lib.Options.Runstring.Options.Register (
         Ada_Lib.Options.Runstring.With_Parameters,
         Ada_Lib.Options.Initialize (
            With_Parameters, Ada_Lib.Options.Unmodified_Flag));

      Ada_Lib.Options.Runstring.Options.Register (
         Ada_Lib.Options.Runstring.Without_Parameters,
         Ada_Lib.Options.Initialize (
            Without_Parameters, Ada_Lib.Options.Unmodified_Flag));
      Log_Here (Debug);

      declare
         Got_Argument            : Boolean := False;
         Got_Parameter_P         : Boolean := False;     -- unquoted
         Got_Parameter_Q         : Boolean := False;     -- quoted
         Got_N                   : Boolean := False;
         Got_P                   : Boolean := False;
         Got_Q                   : Boolean := False;
         Got_Quoted_Argument     : Boolean := False;
         Source                  : constant String := String'(
                                    "-pxyz " &  -- option with inline parameter
                                    "abc " &    -- non optin argument
                                    "-n " &     -- no parameter option
                                    "|xyz 123|" & -- quoted argument
                                    " -q |1 2 3|");-- option with quoted paramter
                                                -- option with non inline paramer
         Iterator                : Internal.Iterator_Type;

      begin
         Iterator.Initialize (
            Source                     => Source,
            Include_Options            => True,
            Include_Non_Options        => True,
            Option_Prefix              => '-',
            Quote                      => '|',
            Skip                       => 0);

         Put_Line ("Process");
         while not Iterator.At_End loop
            if Iterator.Is_Option then
               Log_Here (Debug, "got option");
               declare
                  Option   : constant Ada_Lib.Options.Flag_Option_Type'class :=
                              Iterator.Get_Option;

               begin
                  Log_Here (Debug, "option " & Option.Image);
                  if Option.Modified then
                     Assert (False, "unexpected modified options");
                  end if;
                  case Option.Option is

                     when 'n' =>
                        Got_N := True;

                     when 'p' =>
                        declare
                           Parameter: constant String := Iterator.Get_Parameter;

                        begin
                           Log_Here (Debug, Quote ("parameter ", Parameter));
                           Got_P := True;
                           Assert (Parameter = "xyz", "wrong parameter for -s " &
                              " expected xyz got " & Parameter);
                           Got_Parameter_P := True;
                        end;

                     when 'q' =>
                        declare
                           Parameter: constant String := Iterator.Get_Parameter;

                        begin
                           Log_Here (Debug, Quote ("parameter ", Parameter));
                           Got_Q := True;
                           Assert (Parameter = "1 2 3", "wrong parameter for -t " &
                              " expected 1 2 3 got " & Parameter);
                           Got_Parameter_Q := True;
                        end;

                     when others =>
                        Assert (False, "unexpected option '" & Option.Image & "'");

                  end case;
               end;
            else
               Log_Here (Debug);
               declare
                  Argument          : constant String := Iterator.Get_Argument;

               begin
                  if Argument = "abc" then
                     Got_Argument := True;
                  elsif Argument = "xyz 123" then
                     Got_Quoted_Argument := True;
                  else
                     Assert (False, "got wrong argument. expected abc or xyz 123." &
                        " Got '" & Argument & "'");
                  end if;
               end;
            end if;

            Log_Here (Debug);
            Iterator.Advance;
         end loop;

         Assert (Got_Argument, "did not get Argument");
         Assert (Got_Quoted_Argument, "did not get  Quoted Argument");
         Assert (Got_Parameter_P, "did not get parameter p");
         Assert (Got_Parameter_Q, "did not get parameter q");
         Assert (Got_N, "did not get -n");
         Assert (Got_P, "did not get -p");
         Assert (Got_Q, "did not get -q");
      end;
      Log_Out (Debug);

   exception
      when Fault: others =>
         Trace_Exception (Debug, Fault, Here);
         Log_Exception (Debug, "error in library");
         Assert (False, "library failed");

   end Test_Quote;

   ---------------------------------------------------------------

begin
   if Trace_Tests then
      Debug := Trace_Tests;
   end if;
--debug := True;
   Log_Here (Debug or Elaborate or Trace_Options);
end Ada_Lib.Command_Line_Iterator.Tests;
