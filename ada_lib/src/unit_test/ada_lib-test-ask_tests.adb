with Ada.Text_IO;use Ada.Text_IO;
--with Ada_Lib.Test.Tests;
with Ask;
with AUnit.Assertions; use AUnit.Assertions;
with Ada_Lib.Options.Unit_Test;
with Ada_Lib.Unit_Test;
with Ada_Lib.Trace; use Ada_Lib.Trace;
--with Ada_Lib.Test;

--pragma Elaborate (Ada_Lib.Test);

package body Ada_Lib.Test.Ask_Tests is

-- type Test_Suite_Type is new Ada_Lib.Test.Tests.Test_Suite_Type with null record;

   function Near is new Ada_Lib.Test.Near (Float);

   Debug : Boolean renames Options.Unit_Test.Ada_Lib_Ask_Tests.Debug;

   ---------------------------------------------------------------
   procedure Basic_Operations(
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
      pragma Unreferenced (Test);
   ---------------------------------------------------------------

      Float_Answer               : Float := 0.0;
      Integer_Answer             : Integer := 0;
      Time_Answer                : Duration := 0.0;
      Tolerance                  : constant Float := 0.0001;

   begin
      Put_Line ("Basic Operations");
      Ask.Push ('a');
      Assert (Ask.Ask_Character ("ask character") = 'a', "ask character failed");
      Ask.Push ("abc");
      Assert (Ask.Ask_String ("ask string") = "abc", "ask string failed");
      Ask.Push ("1.2");
      Ask.Ask_Float ("ask float", Float_Answer);
      Assert (Near (Float_Answer, 1.2, Tolerance), "ask float failed");
      Ask.Push ("12");
      Ask.Ask_Integer ("ask integer", Integer_Answer);
      Assert (Integer_Answer = 12, "ask integer failed");
      Ask.Push ("2.1");
      Ask.Ask_Time ("ask time", Time_Answer);
      Assert (Near (Float (Time_Answer), 2.1, Tolerance), "ask time failed");
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

--    Test_Suite                 : constant AUnit.Test_Suites.Access_Test_Suite :=
--                                  new Test_Suite_Type;
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

end Ada_Lib.Test.Ask_Tests;
