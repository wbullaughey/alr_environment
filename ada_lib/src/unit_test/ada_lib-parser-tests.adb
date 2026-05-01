-- with Ada.Strings.Maps;
with Ada.Strings.Fixed;
with Ada.Text_IO;use Ada.Text_IO;
-- with Ask;
with AUnit.Assertions; use AUnit.Assertions;
--with Ada_Lib.Options.Flags;
with Ada_Lib.Options.Unit_Test;
with Ada_Lib.Unit_Test;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Trace; use Ada_Lib.Trace;

package body Ada_Lib.Parser.Tests is

   Debug : Boolean renames Options.Unit_Test.Ada_Lib_Unit_Test.Parser_Debug;

-- ---------------------------------------------------------------
-- function Debug
-- return Boolean is
-- ---------------------------------------------------------------
--
--    Options           : Ada_Lib.Options.AUnit_Lib.Aunit_Program_Options_Type'class
--                         renames Ada_Lib.Options.AUnit_Lib.
--                            Aunit_Program_Options_Constant_Class_Access (
--                               Ada_Lib.Options.Verification.Get_Ada_Lib_Read_Only_Nested_Options).all;
-- begin
--    return Options.Debug;
-- end Debug;

   ---------------------------------------------------------------
   procedure Basic_Operations(
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
      pragma Unreferenced (Test);
   ---------------------------------------------------------------

      -----------------------------------------------------------
      function Uncomment (
         Source                  : in     String;
         Comment_Character       : in     Character
      ) return String is
      -----------------------------------------------------------

         Comment_Index           : constant Natural  := Ada.Strings.Fixed.Index (
                                    Source, String'(1 => Comment_Character), Source'first);
      begin
         if Comment_Index > 1 then
            return Source (Source'first .. Comment_Index - 1);
         else
            return Source;
         end if;
      end Uncomment;

      -----------------------------------------------------------

      type Result_Type is record
         Parsed                  : Ada_Lib.Strings.String_Constant_Access;     -- part of buffer already parsed
         Remainder               : Ada_Lib.Strings.String_Constant_Access;     -- part of buffer not parsed
         Quoted                  : Boolean;                    -- true if value return was quoted
         Seperator               : Character;
         Value                   : Ada_Lib.Strings.String_Constant_Access;     -- value expected to be returned
      end record;

      type Result_Access is access constant Result_Type;

      type Results_Type is array (Positive range 1 .. 100) of Result_Access;

      type Test_Case_Type is record
         Comment_Seperator       : Character;
         Ignore_Multiple_Seperators
                                 : Boolean;
         Pattern                 : Ada_Lib.Strings.String_Constant_Access;
         Quotes                  : Ada_Lib.Strings.String_Constant_Access;
         Seperators              : Ada_Lib.Strings.String_Constant_Access;
         Trim_Spaces             : Boolean;
         Results                 : Results_Type;
      end record;

      Test_Cases                 : constant array ( Positive range <>) of Test_Case_Type := (
                                    (  -- 1
                                       Comment_Seperator       => '#',
                                       Ignore_Multiple_Seperators
                                                               => False,
                                       Pattern                 => new String'("abc"),
                                       Quotes                  => new String'(""""),
                                       Seperators              => new String'(","),
                                       Trim_Spaces             => False,
                                       Results                 => (
                                          1 => new Result_Type'(
                                             Parsed => new String'("abc"),
                                             Remainder   => new String'(""),
                                             Quoted      => False,
                                             Seperator   => Ada_Lib.Parser.No_Seperator,
                                             Value       => new String'("abc")
                                          ),
                                          others => Null
                                       )
                                    ),
                                    ( -- 2
                                       Comment_Seperator       => '#',
                                       Ignore_Multiple_Seperators
                                                               => False,
                                       Pattern                 => new String'("a,b"),
                                       Quotes                  => new String'(""""),
                                       Seperators              => new String'(","),
                                       Trim_Spaces             => False,
                                       Results                 => (
                                          new Result_Type'(
                                             Parsed => new String'("a,"),
                                             Remainder   => new String'("b"),
                                             Seperator   => ',', -- Ada_Lib.Parser.No_Seperator,
                                             Quoted      => False,
                                             Value       => new String'("a")
                                          ),
                                          new Result_Type'(
                                             Parsed => new String'("a,b"),
                                             Remainder   => new String'(""),
                                             Seperator   => Ada_Lib.Parser.No_Seperator,
                                             Quoted      => False,
                                             Value       => new String'("b")
                                          ),
                                          others => Null
                                       )
                                    ),
                                    ( -- 3
                                       Comment_Seperator       => '#',
                                       Ignore_Multiple_Seperators
                                                               => False,
                                       Pattern                 => new String'("'a',b"),
                                       Quotes                  => new String'("'"),
                                       Seperators              => new String'(","),
                                       Trim_Spaces             => False,
                                       Results                 => (
                                          new Result_Type'(
                                             Parsed => new String'("'a',"),
                                             Remainder   => new String'("b"),
                                             Seperator   => ',', -- Ada_Lib.Parser.No_Seperator,
                                             Quoted      => True,
                                             Value       => new String'("a")
                                          ),
                                          new Result_Type'(
                                             Parsed => new String'("'a',b"),
                                             Remainder   => new String'(""),
                                             Seperator   => Ada_Lib.Parser.No_Seperator,
                                             Quoted      => False,
                                             Value       => new String'("b")
                                          ),
                                          others => Null
                                       )
                                    ),
                                    ( -- 4
                                       Comment_Seperator       => '#',
                                       Ignore_Multiple_Seperators
                                                               => False,
                                       Pattern                 => new String'("'a',b;c# comment"),
                                       Quotes                  => new String'("'"),
                                       Seperators              => new String'(",;"),
                                       Trim_Spaces             => False,
                                       Results                 => (
                                          new Result_Type'(
                                             Parsed => new String'("'a',"),
                                             Remainder   => new String'("b;c"),
                                             Seperator   => ',', -- Ada_Lib.Parser.No_Seperator,
                                             Quoted      => True,
                                             Value       => new String'("a")
                                          ),
                                          new Result_Type'(
                                             Parsed => new String'("'a',b;"),
                                             Remainder   => new String'("c"),
                                             Seperator   => ';',
                                             Quoted      => False,
                                             Value       => new String'("b")
                                          ),
                                          new Result_Type'(
                                             Parsed => new String'("'a',b;c"),
                                             Remainder   => new String'(""),
                                             Seperator   => Ada_Lib.Parser.No_Seperator,
                                             Quoted      => False,
                                             Value       => new String'("c")
                                          ),
                                          others => Null
                                       )
                                    ),
                                    ( -- 5 test with spaces and quoted
                                       Comment_Seperator       => No_Seperator,
                                       Ignore_Multiple_Seperators
                                                               => False,
                                       Pattern                 => new String'("a , ""b "" "),
                                       Quotes                  => new String'(""""),
                                       Seperators              => new String'(","),
                                       Trim_Spaces             => True,
                                       Results                 => (
                                          new Result_Type'(
                                             Parsed => new String'("a ,"),
                                             Remainder   => new String'(" ""b """),
                                             Seperator   => ',',
                                             Quoted      => False,
                                             Value       => new String'("a")
                                          ),
                                          new Result_Type'(
                                             Parsed => new String'(("a , ""b """)),
                                             Remainder   => new String'(""),
                                             Seperator   => No_Seperator,
                                             Quoted      => True,
                                             Value       => new String'("b ")
                                          ),
                                          others => Null
                                       )
                                    )
                                 );
--          subtype Range_Type   is Positive range 5 .. 5;
            subtype Range_Type   is Positive range Test_Cases'range;

   begin
      Put_Line ("Basic Operations");
      for Test_Case_Index in Range_Type loop
         declare
            Test_Case            : Test_Case_Type renames Test_Cases (Test_Case_Index);
            Iterator             : Iterator_Type := Initialize (
                                    Test_Case.Pattern.all,
                                    Test_Case.Seperators.all,
                                    Test_Case.Ignore_Multiple_Seperators,
                                    Test_Case.Comment_Seperator,
                                    Test_Case.Trim_Spaces,
                                    Test_Case.Quotes.all);
            Step                 : Positive := 1;

         begin
            Log_Here (Debug, "test case index" & Test_Case_Index'img);

            declare
               Original          : constant String := Iterator.Get_Original;
               Uncommented       : constant String := Uncomment (Test_Case.Pattern.all, Test_Case.Comment_Seperator);
               Expected          : constant String := (if Test_Case.Trim_Spaces then Ada_Lib.Strings.Trim (Uncommented) else Uncommented);

            begin
               Assert (Original = Expected,
                  Quote ("get original failed got", Original) & Quote (" expected", Expected));
            end;

            for Result of Test_Case.Results loop
               if Result /= Null then
                  Log_Here (Debug, "step" & Step'img);
                  Assert (not Iterator.At_End, "early end of iterator step" & Step'img);
                  declare
                     On_What        : constant String := " case" & Test_Case_Index'img & " step" & Step'img;
                     Parsed         : constant String := Iterator.Get_Parsed;
                     Quoted         : constant Boolean := Iterator.Is_Quoted;
                     Remainder      : constant String := Iterator.Get_Remainder;
                     Seperator      : constant Character := Iterator.Get_Seperator;
                     Value          : constant String := Iterator.Get_Value (Do_Next => False);

                  begin
                     Assert (Parsed = Result.Parsed.all, Quote ("unexpected Parsed", Parsed) &
                        Quote (" expected", Result.Parsed.all) & On_What);
                     Assert (Quoted = Result.Quoted, " unexpected Quoted " & Quoted'img & " expected " &
                        Result.Quoted'img & On_What);
                     Assert (Remainder = Result.Remainder.all, Quote ("unexpected Remainder", Remainder) &
                        Quote (" expected", Result.Remainder.all) & On_What);
                     Assert (Seperator = Result.Seperator, Quote ("unexpected Seperator", Seperator) &
                        Quote (" expected", Result.Seperator) & On_What);
                     Assert (Value = Result.Value.all, Quote ("unexpected value", Value) &
                        Quote (" expected", Result.Value.all) & On_What);
                  end;

                  Iterator.Next;
                  Step := Step + 1;
               end if;
            end loop;

            Assert (Iterator.At_End, "Iterator not exhausted");
         end;
      end loop;
   end Basic_Operations;

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
         Routine        => Basic_Operations'access,
         Routine_Name   => AUnit.Format ("Basic_Operations")));
      Log_Out (Debug);
   end Register_Tests;

-- ---------------------------------------------------------------
-- procedure Set_Debug is
-- ---------------------------------------------------------------
--
--    Options  : Ada_Lib.Options.AUnit_Lib.Aunit_Program_Options_Type'class
--                renames Ada_Lib.Options.AUnit_Lib.
--                   Aunit_Program_Options_Class_Access (Ada_Lib.Options.Flags.
--                      Get_Ada_Lib_Modifiable_Nested_Options).all;
-- begin
--    Options.Debug := True;
-- end Set_Debug;

-- ---------------------------------------------------------------
-- procedure Set_Up (Test : in out Test_Type) is
-- ---------------------------------------------------------------
--
--    Seperator               : character;
--
-- begin
-- Log (Here, Who);
--    Log (Debug, Here, Who);
-- end Set_Up;

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

-- ---------------------------------------------------------------
-- procedure Tear_Down (Test : in out Test_Type) is
-- ---------------------------------------------------------------
--
-- begin
--    Log (Debug, Here, Who);
--    Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type (Test).Tear_Down;
-- end Tear_Down;

begin
   Log_Here (Debug or Elaborate);
end Ada_Lib.Parser.Tests;
