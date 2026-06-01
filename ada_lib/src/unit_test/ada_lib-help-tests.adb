with Ada.Text_IO; use Ada.Text_IO;
--with Ada_Lib.Options.Create;
with Ada_Lib.Options.Unit_Test;
with Ada_Lib.Unit_Test;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Unit_Test.Test_Cases;
with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases;

package body Ada_Lib.Help.Tests is

   use Ada_Lib.Options;

   type String_Pointer           is access constant String;

   type Test_Case_Type           is record
      Option                     : Ada_Lib.Options.Flag_List_Type;
      Parameter                  : String_Pointer;
      Description                : String_Pointer;
   end record;

   type Test_Cases_Type is array (Positive range <>) of Test_Case_Type;

   procedure Test_Help (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Test_Prefix_Help (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   type Test_Type is new Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type with null record;

   type Test_Access is access Test_Type;

   overriding
   function Name (Test : Test_Type) return AUnit.Message_String;

   overriding
   procedure Register_Tests (Test : in out Test_Type);

-- overriding
-- procedure Set_Up (Test : in out Test_Type)

   overriding
   procedure Tear_Down (
      Test : in out Test_Type
   )  with post => Test.Verify_Tear_Down;

   Debug       : Boolean renames Ada_Lib.Options.Unit_Test
                                    .Ada_Lib_Help_Unit_Test.Debug;
   Suite_Name  : constant String := "Help";

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
      Log_In (Trace_Set_Up_Tear_Down or Debug);

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Test_Help'access,
         Routine_Name   => AUnit.Format ("Test_Help")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Test_Prefix_Help'access,
         Routine_Name   => AUnit.Format ("Test_Prefix_Help")));

      Log_Out (Trace_Set_Up_Tear_Down or Debug);
   end Register_Tests;

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
      Log_In (Trace_Set_Up_Tear_Down or Debug);
      Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type (Test).Tear_Down;
      Ada_Lib.Help.Reset;
      Log_Out (Trace_Set_Up_Tear_Down or Debug);
   end Tear_Down;

   ---------------------------------------------------------------
   procedure Test_Help (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
      pragma Unreferenced (Test);
   ---------------------------------------------------------------

      Test_Case                  : constant Test_Cases_Type := (
         Test_Case_Type'(
            Option      => Initialize ('b', Ada_Lib.Options.Unmodified_Flag),
            Parameter   => new String'("b parameter"),
            Description => new String'("b option")
         ),
         Test_Case_Type'(
            Option      => Initialize ('c', Ada_Lib.Options.Unmodified_Flag),
            Parameter   => new String'("c parameter"),
            Description => new String'("c option")
         ),
         Test_Case_Type'(
            Option      => Initialize ('a', Ada_Lib.Options.Unmodified_Flag),
            Parameter   => new String'("a parameter"),
            Description => new String'("a option")
         )
      );

      Expected                   : constant array (Positive range <>) of
                                    String_Pointer := (
            new String'("-a <a parameter>  : a option"),
            new String'("-b <b parameter>  : b option"),
            new String'("-c <c parameter>  : c option")
      );

      Counter                    : Positive := 1;

      ------------------------------------------------------------
      procedure Check_Test_Suite_And_Routine (
         Line                    : in     String) is
      ------------------------------------------------------------

      begin
         Put_Line (Line);
         Log_Here (Trace_Set_Up_Tear_Down or Debug, "counter" & Counter'img &
            " expected last " & Natural'(Expected'last)'img);
         if Counter > Expected'last then
            Assert (False, "too many lines (" & Counter'img &
               " ) generated");
            return;
         end if;
         Assert (Line = Expected (Counter).all, Quote ("Line", Line) &
            Quote (" Expected" & Counter'img, Expected (Counter).all));
         Counter := Counter + 1;
      end Check_Test_Suite_And_Routine;
      ------------------------------------------------------------

   begin
      Log_In (Debug);
      for Line of Test_Case loop
         Ada_Lib.Help.Create_Option (Line.Option.Option (1), False, (
            if Line.Parameter = Null then "" else Line.Parameter.all),
         Line.Description.all, "", Unmodified_Flag);
      end loop;

      Ada_Lib.Help.Display (Check_Test_Suite_And_Routine'access);
      Log_Out (Debug);
   end Test_Help;

   ---------------------------------------------------------------
   procedure Test_Prefix_Help (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
      pragma Unreferenced (Test);
   ---------------------------------------------------------------

      type String_Pointer        is access constant String;
      Modifier                   : constant Character := '@';

      Test_Case                  : constant Test_Cases_Type := (
         Test_Case_Type'(
            Option      => Initialize ('B', Modifier),
            Parameter   => new String'(Modifier & "B parameter"),
            Description => new String'(Modifier & "B option")
         ),
         Test_Case_Type'(
            Option      => Initialize ('a', Modifier),
            Parameter   => new String'(Modifier & "a parameter"),
            Description => new String'(Modifier & "a option")
         ),
         Test_Case_Type'(
            Option      => Initialize ('b', Ada_Lib.Options.Unmodified_Flag),
            Parameter   => new String'("b parameter"),
            Description => new String'("b option")
         ),
         Test_Case_Type'(
            Option      => Initialize ('b', Modifier),
            Parameter   => new String'(Modifier & "b parameter"),
            Description => new String'(Modifier & "b option")
         )
      );

      -- list is sorted 1st with options with out modifier and then alphabetically
      Expected                   : constant array (Positive range <>)
                                    of String_Pointer := (
            new String'("-b <b parameter>   : b option"),
            new String'("-" & Modifier & "a <@a parameter> : @a option"),
            new String'("-" & Modifier & "b <@b parameter> : @b option"),
            new String'("-" & Modifier & "B <@B parameter> : @B option")
      );

      Counter                    : Positive := 1;

      ------------------------------------------------------------
      procedure Check_Test_Suite_And_Routine (
         Line                    : in     String) is
      ------------------------------------------------------------

      begin
         Put_Line (Quote ("line", Line) & " counter" & Counter'img);
         Log_Here (Trace_Set_Up_Tear_Down or Debug, "counter" & Counter'img &
            " expected last " & Natural'(Expected'last)'img);
         if Counter > Expected'last then
            Assert (False, "too many lines (" & Counter'img & " ) generated");
            return;
         end if;
         Assert (Line = Expected (Counter).all, "'" & Line & "' did not match '" &
            "expected " & Expected (Counter).all & "' at" & Counter'img);
         Counter := Counter + 1;
      end Check_Test_Suite_And_Routine;
      ------------------------------------------------------------

   begin
      Log_In (Debug);
      for Line of Test_Case loop
--log_here (Line.Option.Options.Image);
         Ada_Lib.Help.Create_Option (
            Component      => "",
            Description    => Line.Description.all,
            Modifier       => Line.Option.Modifier (1),
            Option         => Line.Option.Option (1),
            Parameter      => (if Line.Parameter = Null then
                              ""
                           else
                              Line.Parameter.all),
            Trace_Option   => False);
      end loop;

      Ada_Lib.Help.Display (Check_Test_Suite_And_Routine'access);
      Log_out (Debug);
   end Test_Prefix_Help;

begin
--debug := True;
--Trace_Options := True;
   Log_Here (Trace_Options or Debug);
end Ada_Lib.Help.Tests;

