with AUnit.Test_Cases;
with AUnit.Test_Suites;
--with Ada_Lib.Options.Unit_Test;
with Ada_Lib.Unit_Test.Test_Cases;
-- with Ada_Lib.Unit_Test.Test_Cases;

package Ada_Lib.Command_Line_Iterator.Tests is

-- use type Ada_Lib.Options.Unit_Test.Aunit_Program_Options_Constant_Class_Access;

   Suite_Name                    : constant String := "Command_Line_Iterator";

   type Test_Type is new Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type with
                     null record;

   type Test_Access is access Test_Type;

   overriding
   function Name (Test : Test_Type) return AUnit.Message_String;

   procedure Process (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   overriding
   procedure Register_Tests (Test : in out Test_Type);

   overriding
   procedure Set_Up (
      Test                       : in out Test_Type
   ) with pre => not Test.Verify_Set_Up,
          post => Test.Verify_Set_Up;

   function Suite return AUnit.Test_Suites.Access_Test_Suite;

   overriding
   procedure Tear_Down (
      Test : in out Test_Type
   ) with post => Test.Verify_Tear_Down;

end Ada_Lib.Command_Line_Iterator.Tests;
