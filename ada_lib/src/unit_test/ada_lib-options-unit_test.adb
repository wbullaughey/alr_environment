with Ada.Real_Time;
with Ada.Text_IO; use Ada.Text_IO;
--with Ada_Lib.Event.Unit_Test;
--with Ada_Lib.GNOGA.Unit_Test;
with Ada_Lib.Help;
--with GNOGA_Options;
with Ada_Lib.OS;
with Ada_Lib.Options.AUnit_Lib;
--with Ada_Lib.Options.Create;
--with Ada_Lib.Options.Nested;
with Ada_Lib.Options.Runstring;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Trace; use Ada_Lib.Trace;
--with Ada_Lib.Unit_Test.Test_Cases;
with AUnit.Ada_Lib; -- debug moved to Ada_Lib.Options.Aunit
--with Debug_Options;

-- pragma Elaborate (Ada_Lib.OS);

-- tests for the test_ada_lib
package body Ada_Lib.Options.Unit_Test is


   Debug       : Boolean renames Ada_Lib_Options_Unit_Test.Debug;
   Debug_All   : Boolean renames Ada_Lib_Options.Debug_All;
   Driver_List_Option         : constant Character := 'd';
   Trace_Option               : constant Character := 'U';
   Trace_Modifier             : character renames Ada_Lib.Help.Trace_Modifier;
   Options_With_Parameters    : aliased constant
                                 Ada_Lib.Options.Flag_List_Type :=
                                    Ada_Lib.Options.Initialize (
                                       "es" & Trace_Option,
                                       Ada_Lib.Options.Unmodified_flag) &
                                 Ada_Lib.Options.Initialize (
                                    "AnR", Ada_Lib.Help.Modifier);
   Options_Without_Parameters : aliased constant
                                 Flag_List_Type :=
                                    Initialize (
                                       "nx", Unmodified_flag) &
                                    Initialize (
                                       Driver_List_Option & "lmPsSu",
                                       Ada_Lib.Help.Modifier);

   Initialized_Recursed : Boolean := False;
-- Unit_Test_Options    : Ada_Lib_Unit_Test_Nested_Options_Class_Access := Null;

   ---------------------------------------------------------------ada   -------------
   procedure Check_Test_Suite_And_Routine (
      Options                    : in     Ada_Lib_Unit_Test_Nested_Options_Type) is
   ----------------------------------------------------------------------------

   begin
      Log_In (Debug, "Multi_Test " & Options.Multi_Test'img &
            " mode " & Options.Mode'img);

      if not (Options.Multi_Test or else
            Options.Mode = Ada_Lib.Options.Run_Tests) then
         if    Options.Routine.Length = 0 or else
               Options.Suite_Name.Length = 0 then
            raise Failed with "single unit test must have both " &
               "suite name and routine name";
         end if;
      end if;
      Log_Out (Debug);
   end Check_Test_Suite_And_Routine;

   ------------------------------------------------------------
   function Get_Modifiable_Ada_Lib_Unit_Test_Nested_Options (
      From                       : in  String := Options_Here
   ) return Ada_Lib_Unit_Test_Nested_Options_Class_Access is
   ------------------------------------------------------------

      Aunit_Program_Options
         : constant AUnit_Lib.Aunit_Program_Options_Class_Access :=
            AUnit_Lib.Get_Modifiable_AUnit_Options (From);
   begin
      Log_Here (Trace_Conversions, "from " & From);
      return Aunit_Program_Options.Nested_Unit_Test_Options'unchecked_access;
   end Get_Modifiable_Ada_Lib_Unit_Test_Nested_Options;

   ------------------------------------------------------------
   function Get_Readonly_Ada_Lib_Unit_Test_Nested_Options (
      From                       : in  String := Options_Here
   ) return Ada_Lib_Unit_Test_Nested_Options_Constant_Class_Access is
   ------------------------------------------------------------

      Aunit_Program_Options
         : constant AUnit_Lib.Aunit_Program_Options_Constant_Class_Access :=
            AUnit_Lib.Get_Read_Only_AUnit_Options (From);
   begin
      Log_Here (Trace_Conversions, "from " & From);
      return Aunit_Program_Options.Nested_Unit_Test_Options'unchecked_access;
   end Get_Readonly_Ada_Lib_Unit_Test_Nested_Options;

-- ----------------------------------------------------------------------------
-- function Have_Unit_Test_Options
-- return Boolean is
-- ----------------------------------------------------------------------------
--
--    Result   : constant Boolean := Unit_Test_Options /= Null;
--
-- begin
--    return Log_Here (Result,
--       Debug or Trace_Pre_Post_Conditions or not Result,
--       "unit test options not set");
-- end Have_Unit_Test_Options;

   ----------------------------------------------------------------------------
   overriding
   function Image (
     Options                     : in     Ada_Lib_Unit_Test_Nested_Options_Type
   ) return String is
   ----------------------------------------------------------------------------

   begin
not_implemented;
return "";
   end Image;

   ----------------------------------------------------------------------------
   overriding
   function Initialize (
     Options                     : in out Ada_Lib_Unit_Test_Nested_Options_Type;
     From                        : in     String := Standard.Ada_Lib.Trace.Here
   ) return Boolean is
   ----------------------------------------------------------------------------

      Message        : constant String :=
         Tag_Name ("options",
            Ada_Lib_Unit_Test_Nested_Options_Type'class (Options)'tag) &
         Tag_Name (" options parent",
            Program.Nested_Program_Options_Type 'class (Options)'tag) &
         " from " & From &
         " options with parameters " & Options_With_Parameters.Image &
         " with out " & Options_Without_Parameters.Image;

   begin
     Log_In_Checked (Initialized_Recursed,
     Debug or Trace_Options, Message);

     Tag_History (Debug or Trace_Options, "Options",
       Ada_Lib_Unit_Test_Nested_Options_Type'class (Options)'tag);

      Ada_Lib.Options.Runstring.Options.Register (
         Ada_Lib.Options.Runstring.With_Parameters,
            Options_With_Parameters);
      Ada_Lib.Options.Runstring.Options.Register (
         Ada_Lib.Options.Runstring.Without_Parameters,
         Options_Without_Parameters);

      return Log_Out_Checked (Initialized_Recursed,
--       Options.Library_Options.GNOGA_Options.Initialize and then
            Program.Nested_Program_Options_Type (Options).Initialize,
         Debug or Trace_Options, Message);

   end Initialize;

-- ----------------------------------------------------------------------------
-- function Options (
--    From                       : in     String :=
--                                           Standard.GNAT.Source_Info.Source_Location
-- ) return Unit_Test_Options_Constant_Class_Access is
-- ----------------------------------------------------------------------------
--
-- begin
--    if Ada_Lib.Options.Get_Ada_Lib_Read_Only_Options = Null then
--       raise Failed with "Get_Ada_Lib_Read_Only_Options not set called from " & From;
--    end if;
--
--    Log_Here (Debug, "from " & From &
--       Tag_Name (" Get_Ada_Lib_Read_Only_Options",
--          Ada_Lib.Options.Get_Ada_Lib_Read_Only_Options.all'tag));
--
--    return Unit_Test_Options_Constant_Class_Access (
--       Ada_Lib.Options.Get_Ada_Lib_Read_Only_Options);
-- end Options;

   ----------------------------------------------------------------------------
   overriding
   procedure Post_Process (
     Options         : in out Ada_Lib_Unit_Test_Nested_Options_Type) is
   ----------------------------------------------------------------------------

      -------------------------------------------------------------------------
      procedure List_Seeds is
      -------------------------------------------------------------------------

      begin
         for Index in 1 .. Options.Number_Random_Generators loop
            Log_Here (Debug or Trace_Options,
               "seed" & Index'img & ":" & Options.Random_Seeds (Index)'img);
            if Options.Report_Random then
               Put_Line ("random seed" & Index'img & " =" &
                  Options.Random_Seeds (Index)'img);
            end if;
         end loop;

      end List_Seeds;
      -------------------------------------------------------------------------

   begin
      Log_In (Debug or Trace_Options,
         "Random_Seed_Mode " & Options.Random_Seed_Mode'img);
      case Options.Random_Seed_Mode is

         when Default_Seed =>
            Options.Random_Seeds := (others =>
               Default_Random_Seed);

         when Seed_Not_Set =>
            Options.Random_Seeds := (others =>
               Default_Random_Seed);
            Options.Random_Seed_Mode :=
               Default_Seed;

         when Specified_Seed =>
            List_Seeds; -- should already be set

         when Random_Seed =>
            declare
               Now         : constant Ada.Real_Time.Time :=
                              Ada.Real_Time.Clock;
               Offset      : Duration;
               Seconds     : Ada.Real_Time.Seconds_Count;
               Seed        : Integer;
               for Seed'address use Offset'address;
               Time_Span   : Ada.Real_Time.Time_Span;

            begin
               Ada.Real_Time.Split (Now, Seconds, Time_Span);
               Offset := Ada.Real_Time.To_Duration (Time_Span);
               Log_Here (Debug or Trace_Options, "offset " & Ada_Lib.Strings.Image (Offset, True));

               for Index in 1 .. Options.Number_Random_Generators loop
                  Options.Random_Seeds (Index) := Seed;
                  Seed := Seed / 2;
               end loop;
               List_Seeds;
            end;
      end case;

      Program.Nested_Program_Options_Type (Options).Post_Process   ;
      Log_Out (Debug or Trace_Options);

   end Post_Process;

   ----------------------------------------------------------------------------
   -- processes options it knows about and calls parent for others
   overriding
   function Process_Option (
      Options  : in out Ada_Lib_Unit_Test_Nested_Options_Type;
      Iterator : in out Ada_Lib.Options.Command_Line_Iterator_Interface'class;
      Option   : in     Ada_Lib.Options.Flag_Option_Type'class
   ) return Boolean is
   ----------------------------------------------------------------------------

      ----------------------------------------------------------------------------
      procedure Bad_Options (
         From                    : in     String := Here) is
      ----------------------------------------------------------------------------

      begin
         if not Ada_Lib.Options.Ada_Lib_Environment.Help_Test then
            Options.Bad_Option ("bad options: Routine (-e) or Suite Name (-s) " &
               "cannot be combined" &
               " with List_Suites (-@l) or Driver_Suites (-@d) called from " & From);
         end if;
      end Bad_Options;
      ----------------------------------------------------------------------------

--    use Standard.Ada_Lib.Options;

   begin
      Log_In (Trace_Options or Debug, Option.Image &
         " mode " & Options.Mode'img &
         Quote (" option", Option.Option));

      if Has_Option (Option, Options_With_Parameters,
            Options_Without_Parameters) then
         case Option.Kind is

            when Plain =>

               case Option.Option is

                  when 'e' =>    -- routine name
                     if Options.Mode /= Run_Tests then
                        Bad_Options;
                     end if;

                     if Options.Routine.Length = 0 then
                        Options.Routine.Set (Iterator.Get_Parameter);
                     else
                        Options.Bad_Option ("Only one routine is allowed");
                     end if;
                     Options.Update_Filter;
                     Log_Here (Trace_Options or Debug,
                        Ada_Lib.Strings.Unlimited.Quote ("filter Routine",
                           Options.Routine));

                  when 'n' =>    -- no camera
                     Options.Have_Camera := False;

                  when 's' =>    -- suites to include
                     if Options.Mode /= Run_Tests then
                        Bad_Options;
                     end if;
                     if Options.Suite_Name.Length = 0 then
                        Options.Suite_Name.Set (Iterator.Get_Parameter);
                     else
                        Options.Bad_Option ("Only one suite is allowed");
                     end if;
                     Options.Update_Filter;
                     Log_Here (Trace_Options or Debug,
                        Ada_Lib.Strings.Unlimited.Quote ("filter Suite_Name",
                           Options.Suite_Name));

                  when 'U' =>       -- trace options
                     Options.Trace_Parse (Iterator);

                  when 'x' =>
                     Options.Exit_On_Done := True;

                  when others =>
                     Log_Exception (Trace_Options or Debug, " other option" & Option.Image);
                     raise Failed with "Has_Option incorrectly passed " & Option.Image;

               end case;

            when Modified =>
               case Option.Option is

                  when 'd' =>
                     if Options.Routine.Length > 0 or else
                           Options.Suite_Name.Length > 0 then
                        Bad_Options;
                     end if;
                     Options.Mode := Driver_Suites;

                  when 'A' =>       -- enable default disabled tests
                     declare
                        Parameter: constant String := Iterator.Get_Parameter;

                     begin
                        for Letter of Parameter loop
                           case Letter is

                              when 'a' =>
                                 for Index in Options.Suite_Set'range loop
                                    Options.Suite_Set (Index) := True;
                                 end loop;

                              when 'd' =>
                                 Options.Suite_Set (Database_Server) := True;

                              when 't' =>
                                 Options.Suite_Set (Textbelt) := True;

                              when others =>
                                 Options.Bad_Option (Quote (
                                    "unexpected test suite selection", Letter));

                           end case;
                        end loop;
                     end;

                  when 'l' =>
                     if Options.Routine.Length > 0 or else
                           Options.Suite_Name.Length > 0 then
                        Bad_Options;
                     end if;
                     Options.Mode := List_Suites;

                  when 'm' =>    -- manual operation
                     Options.Manual := True;

                  when 'n' =>
                     Options.Number_Random_Generators :=
                        Random_Generator_Index_Type (Iterator.Get_Integer);
                     Log_Here (Trace_Options, "Number_Random_Generators" &
                        Options.Number_Random_Generators'img);

                  when 'P' => -- print test suites
                     if Options.Routine.Length > 0 or else
                           Options.Suite_Name.Length > 0 then
                        Bad_Options;
                     end if;
                     Options.Mode := Print_Suites;
--                   Options.Update_Filter;   -- sets filter name

                  when 'R' => -- set random seed to argument
                     if Options.Number_Random_Generators = 0 and then
                           not Ada_Lib.Options.Ada_Lib_Environment.Help_Test then
                        raise Failed with
                           "number randoom number generators not set at " &
                           Here;
                     end if;
                     Options.Random_Seed_Mode := Specified_Seed;
                     Log_Here (Trace_Options, "number seeds" &
                        Options.Number_Random_Generators'img);

                     Options.Random_Seed_Count := Options.Random_Seed_Count + 1;
                     if Options.Random_Seed_Count > Options.Number_Random_Generators then
                        raise Failed with "too many random seeds";
                     end if;

                     Options.Random_Seeds (Options.Random_Seed_Count) :=
                        Iterator.Get_Integer;
                     Log_Here (Trace_Options, "random seed " &
                        Options.Random_Seeds (Options.Random_Seed_Count)'img);
                     if Options.Report_Random then
                        Put_Line ("random seed" & Options.Random_Seed_Count'img & " =" &
                           Options.Random_Seeds (Options.Random_Seed_Count)'img);
                     end if;

                  when 's' =>
                     Options.Short_Test := True;

                  when 'S' =>
                     Options.Report_Random := True;

                  when 'u' => -- generator uses time based seed
                     if Options.Random_Seed_Mode /= Seed_Not_Set then
                        raise Failed with "random seed mode already set";
                     end if;
                     if Options.Number_Random_Generators = 0 and then
                           not Ada_Lib.Options.Ada_Lib_Environment.Help_Test then
                        raise Failed with
                           "number randoom number generators not set at " &
                           Here;
                     end if;
                     Options.Random_Seed_Mode := Random_Seed;

                  when 'x' =>
                     Options.Exit_On_Done := True;

                  when others =>
                     Log_Exception (Trace_Options or Debug, " other option" &
                        Option.Image);
                     raise Failed with "Has_Option incorrectly passed " &
                        Option.Image;
               end case;

            when Nil_Option =>
               pragma Assert (False, "unexpected kind");

         end case;

         return Log_Out (True,
--          Program.Nested_Program_Options_Type (
--             Options).Process_Option (Iterator, Option),
            Trace_Options or Debug,
            " " & Option.Image & " handled mode " & Options.Mode'img);
      else
         return Log_Out (
            Program.Nested_Program_Options_Type (Options).Process_Option (
               Iterator, Option),
            Trace_Options or Debug,
            "other option" & " Option " & Option.Image);
      end if;
   end Process_Option;

   ----------------------------------------------------------------------------
   overriding
   procedure Program_Help (
      Options                    : in      Ada_Lib_Unit_Test_Nested_Options_Type;  -- only used for dispatch
      Help_Mode                  : in      Ada_Lib.Options.Help_Mode_Type) is
   ----------------------------------------------------------------------------

      Component                  : constant String := "test_ada_lib";

   begin
      Log_In (Debug or Trace_Options, "mode " & Help_Mode'img);
--    Options.Library_Options.GNOGA_Options.Program_Help (Help_Mode);
      Program.Nested_Program_Options_Type (
         Options).Program_Help (Help_Mode);

      case Help_Mode is

      when Ada_Lib.Options.Program_Mode =>
         -- options without modifier
         Ada_Lib.Help.Create_Option ('e', False, "routine", "routine to test.", Component, Ada_Lib.Options.Unmodified_Flag);
         Ada_Lib.Help.Create_Option ('s', False, "suite to test", "select test suite to run.",
            Component, Ada_Lib.Options.Unmodified_Flag);
         Ada_Lib.Help.Create_Option ('A', False, "suites", "enable default disabled suites.",
            Component, Ada_Lib.Help.Modifier);
         Ada_Lib.Help.Create_Option ('U', True, "unit test trace Ada_Lib",
            "select trace", Component, Ada_Lib.Options.Unmodified_Flag);
         Ada_Lib.Help.Create_Option ('x', False, "", "exit on tests complete", Component,
            Ada_Lib.Options.Unmodified_Flag);
         -- options with modifier
         Ada_Lib.Help.Create_Option ('d', False, "", "driver suites", Component,
            Ada_Lib.Help.Modifier);
         Ada_Lib.Help.Create_Option ('l', False, "", "List test suites", Component,
            Ada_Lib.Help.Modifier);
         Ada_Lib.Help.Create_Option ('m', False, "", "manual operations.", Component,
            Ada_Lib.Help.Modifier);
         Ada_Lib.Help.Create_Option ('n', False, "", "no camera", Component,
            Ada_Lib.Options.Unmodified_Flag);
         Ada_Lib.Help.Create_Option ('S', False, "trace options", "trace flags",
            Component, Ada_Lib.Options.Unmodified_Flag);
         Ada_Lib.Help.Create_Option ('n', False, "number of random seeds", "number seeds.",
            Component,
            Ada_Lib.Help.Modifier);
         Ada_Lib.Help.Create_Option ('P', False, "", "Print test suites.", Component,
            Ada_Lib.Help.Modifier);
         Ada_Lib.Help.Create_Option ('s', False, "", "short test", Component,
            Ada_Lib.Help.Modifier);
         Ada_Lib.Help.Create_Option ('S', False, "", "report random seed", Component,
            Ada_Lib.Help.Modifier);
         Ada_Lib.Help.Create_Option ('R', False, "seed", "set random seed", Component,
            Ada_Lib.Help.Modifier);
         Ada_Lib.Help.Create_Option ('u', False, "", "use random seed", Component,
            Ada_Lib.Help.Modifier);

      when Ada_Lib.Options.Trace_Mode =>
         Ada_Lib.Help.Set_Has_Trace ('U', Ada_Lib.Options.Unmodified_Flag);
         Put_Line ("Ada_Lib unit test library trace options (-" &
            Trace_Option & ")");
         Put_Line ("      a               all");
         Put_Line ("      A               all unit tests");
         Put_Line ("      d               Unit_Test Database");
         Put_Line ("      e               Ada_Lib.Trace.Trace_Exceptions");
         Put_Line ("      E               Ada_Lib.Evemt.Unit_Test.Debug");
         Put_Line ("      f               Fixtures Debug");
         Put_Line ("      g               Database Get,Put Debug");
         Put_Line ("      i               ICON Unit Test Debug");
         Put_Line ("      p               test programs");
         Put_Line ("      P               Parser Debug");
         Put_Line ("      r               Runtime_Options");
         Put_Line ("      R               Reporter Debug");
         Put_Line ("      s               Trace Set_Up Tear_Down");
         Put_Line ("      S               Database Server Tests");
         Put_Line ("      t               Ada_Lib.Test.Debug");
         Put_Line ("      T               Ada_Lib.Trace.Debug_Trace");
         Put_Line ("      u               Ada_Lib.Unit_Test.Debug Library");
         Put_Line ("      U               Ada_Lib.Unit_Test.Test_Cases.Debug Library");
         Put_Line ("      " & Trace_Modifier &
                         "a              Ada_Lib_Aunit.Debug");
         Put_Line ("      " & Trace_Modifier &
                         "A              AUnit.Ada_Lib.Debug");
         Put_Line ("      " & Trace_Modifier &
                         "s              Ada_Lib.Unit_Test.Test_States.Debug");
         Put_Line ("      " & Trace_Modifier &
                         "S              Database Server Debug");
         Put_Line ("      " & Trace_Modifier &
                         "u              Unit_Test Debug");
         Put_Line ("      " & Trace_Modifier &
                         "U              AUnit Debug");

         New_Line;
         Put_Line ("Enable suites disabled by default (-S)");
         Put_Line ("      a               enable all");
         Put_Line ("      d               database server");
         Put_Line ("      t               text");
         New_Line;

      end case;

      Log_Out (Debug or Trace_Options);
   end Program_Help;

   ------------------------------------------------------------
   procedure Routine_Action (
      Suite                      : in     String;
      Routine                    : in     String;
      Mode                       : in     Mode_Type) is
   ------------------------------------------------------------

   begin
      Log_In (Debug, Quote ("Suite", Suite) & Quote (" Routine", Routine) &
         " Suites_Mode " & Mode'img);

      case Mode is

         when Ada_Lib.Options.Driver_Suites =>
            Put_Line ("suite: " & Suite & " routine: " & Routine);

         when Ada_Lib.Options.List_Suites =>
            Put_Line (Suite & " " & Routine);

         when Ada_Lib.Options.Print_Suites =>
            Put_Line ("      " & Routine);

         when Ada_Lib.Options.Run_Tests =>
            null;

      end case;
      Log_Out (Debug);
   end Routine_Action;

-- ------------------------------------------------------------
-- procedure Set_Ada_Lib_Unit_Test_Options (
--    Options     : in     Ada_Lib_Unit_Test_Nested_Options_Class_Access) is
-- ------------------------------------------------------------
--
-- begin
--    Unit_Test_Options := Options;
-- end Set_Ada_Lib_Unit_Test_Options;

   ------------------------------------------------------------
   procedure Suite_Action (
      Suite                      : in     String;
      First                      : in out Boolean;
      Mode                       : in     Mode_Type) is
   ------------------------------------------------------------

   begin
      Log_In (Debug, Quote ("Suite", Suite) & " first " & First'img &
         " Mode " & Mode'img);

      case Mode is

         when Ada_Lib.Options.Driver_Suites |
              Ada_Lib.Options.List_Suites |
              Ada_Lib.Options.Run_Tests =>
            null;

         when Ada_Lib.Options.Print_Suites =>
            if First then
               Put_Line ("test suites: ");
               First := False;
            end if;
            Put_Line ("   " & Suite);

      end case;
      Log_Out (Debug);
   end Suite_Action;

   ----------------------------------------------------------------------------
   overriding
   procedure Trace_Parse (
      Options     : in out Ada_Lib_Unit_Test_Nested_Options_Type;
      Iterator    : in out Command_Line_Iterator_Interface'class) is
   ----------------------------------------------------------------------------

      Parameter                  : constant String := Iterator.Get_Parameter;
      Suboption                  : Flag_Option_Kind_Type := Plain;

   begin
      Log_In (Trace_Options or Debug,  Quote ("parameter", Parameter));
      for Trace of Parameter loop
         Log_Here (Trace_Options or Debug, Quote ("trace", Trace) &
            " Suboption " & Suboption'img);

         case Suboption is
            when Plain =>

               case Trace is

                  when 'a' =>
                     Debug := True;
                     Ada_Lib.Trace.Trace_Pre_Post_Conditions := True;
                     Ada_Lib.Trace.Trace_Set_Up_Tear_Down := True;
                     Ada_Lib.Trace.Trace_Tests := True;
                     Ada_Lib_Database_Unit_Test.Debug := True;
                     Ada_Lib_Database_Unit_Test.Get_Put_Debug := True;
                     Ada_Lib_Database_Unit_Test.Server_Tests_Trace := True;
                     Ada_Lib_Database_Unit_Test.Subscribe_Debug := True;
                     Ada_Lib_Event_Unit_Test.Debug := True;
                     Ada_Lib_ICON_Unit_Test.Debug := True;
                     Ada_Lib_Options_Unit_Test.Client_Debug := True;
                     Ada_Lib_Options_Unit_Test.Debug := True;
                     Ada_Lib_Unit_Test.Fixtures_Debug := True;
                     Ada_Lib_Unit_Test.Parser_Debug := True;
                     Ada_Lib_Unit_Test.Reporter_Debug := True;
                     Ada_Lib_Unit_Test.Tests_Debug := True;
                     Options.Debug := True;
                     Ada_Lib_Unit_Test_Test_Cases.Debug := True;
                     Ada_Lib_Test_States.Debug := True;
                     Standard.AUnit.Ada_Lib.Debug := True;

                  when 'A' =>
                     Ada_Lib.Trace.Trace_Tests := True;

                  when 'd' =>
                     Ada_Lib_Database_Unit_Test.Debug := True;

                  when 'E' =>
                     Ada_Lib_Event_Unit_Test.Debug := True;

                  when 'f' =>
                     Ada_Lib_Unit_Test.Fixtures_Debug := True;

                  when 'g' =>
                     Ada_Lib_Database_Unit_Test.Get_Put_Debug := True;

                  when 'i' =>
                     Ada_Lib_ICON_Unit_Test.Debug := True;

                  when 'p' =>
                     Options.Debug := True;

                  when 'P' =>
                     Ada_Lib_Unit_Test.Parser_Debug := True;

                  when 'r' =>
                     Debug := True;

                  when 'R' =>
                     Ada_Lib_Unit_Test.Reporter_Debug := True;

                  when 's' =>
                     Ada_Lib.Trace.Trace_Set_Up_Tear_Down := True;

                  when 'S' =>
                     Ada_Lib_Database_Unit_Test.Server_Tests_Trace := True;

                  when 't' =>
                     Ada_Lib_Options_Unit_Test.Debug := True;

                  when 'T' =>
                     Ada_Lib.Trace.Debug_Trace := True;

                  when 'u' =>
                     Ada_Lib_Unit_Test.Debug := True;

                  when 'U' =>
                     Ada_Lib_Unit_Test_Test_Cases.Debug := True;

                  when Trace_Modifier =>
                     Suboption := Ada_Lib.Options.Modified;

                  when others =>
                     declare
                        Message        : constant String :=
                                          Quote ("unexpected trace option", Trace) &
                                          " for 'U'";

                     begin
                        Log_Exception (Trace_Options or Debug, Message);
                        raise Failed with Message;
                     end;

               end case;

         when Modified =>
               case Trace is

                  when 'a' =>
                     Ada_Lib_Aunit.Debug := True;

                  when 'A' =>
                     Standard.AUnit.Ada_Lib.Debug := True;

                  when 's' =>
                     Ada_Lib_Test_States.Debug := True;

                  when 'S' =>
                     Ada_Lib_Database_Unit_Test.Subscribe_Debug := True;

                  when 't' =>
                     Ada_Lib_Unit_Test.Tests_Debug := True;

                  when 'u' =>
                     Ada_Lib_Unit_Test.Debug := True;

                  when 'U' =>
                     AUnit.Debug := True;

                  when others =>
                     Options.Bad_Option (Quote (
                        "unexpected trace option",
                        Trace) &
                     " suboption " & Suboption'img &
                     " for '" & Trace_Option & "'");

               end case;
               Suboption := Ada_Lib.Options.Plain;

         when Nil_Option =>
            Not_Implemented;

         end case;

      end loop;
      Log_Out (Debug or Trace_Options);
   end Trace_Parse;

   ----------------------------------------------------------------------------
   overriding
   procedure Update_Filter (
      Options                    : in out Ada_Lib_Unit_Test_Nested_Options_Type) is
   ----------------------------------------------------------------------------

   begin
      Log_In (Debug or Trace_Options, "options " &
         Ada_Lib.Strings.Image (Options'address) & " filter " &
         Ada_Lib.Strings.Image (Options.Filter'address) &
         Ada_Lib.Strings.Unlimited.Quote (" Suite", Options.Suite_Name) &
         Ada_Lib.Strings.Unlimited.Quote (" routine", Options.Routine));
      if Options.Suite_Name.Length > 0 then
         if Options.Routine.Length > 0 then
            Log_Here (Debug,
               Ada_Lib.Strings.Unlimited.Quote ("suite", Options.Suite_Name) &
               Ada_Lib.Strings.Unlimited.Quote (" routine", Options.Routine));
            Options.Filter.Set_Name (Options.Suite_Name.Coerce & " : " & Options.Routine.Coerce);
         else
            Log_Here (Debug,
               Ada_Lib.Strings.Unlimited.Quote ("suite", Options.Suite_Name) &
               " no routine");
            Options.Filter.Set_Name (Options.Suite_Name.Coerce);
         end if;
      end if;
      Log_Out (Debug);
   end Update_Filter;

begin
--Ada_Lib.Trace.Trace_Tests := True;
--Elaborate := True;
   Debug := Debug or Debug_All;
--Debug := True;
--Trace_Options := True;
--AUnit.Debug := True;
   Log_Here (Debug or Elaborate or Trace_Options);

exception
   when Fault: others =>
      Trace_Exception (Fault);
      Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.Exception_Exit);

end Ada_Lib.Options.Unit_Test;
