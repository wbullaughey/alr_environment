with AUnit.Test_Cases;
with AUnit.Test_Suites;
with Ada_Lib.Unit_Test.Test_Cases;
-- with Ada_Lib.Unit_Test.Test_Cases;

package Ada_Lib.Text.Textbelt.Tests is

   Suite_Name                    : constant String := "Textbelt";

   type Test_Type is new Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type with null record;

   type Test_Access is access Test_Type;

   overriding
   function Name (Test : Test_Type) return AUnit.Message_String;

   procedure Send_Text_Invalid_Number (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Send_Text_Valid_Number (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   overriding
   procedure Register_Tests (Test : in out Test_Type);

-- overriding
-- procedure Set_Up (Test : in out Test_Type)
-- with post => Test.Verify_Set_Up;
--
   function Suite return AUnit.Test_Suites.Access_Test_Suite;

-- overriding
-- procedure Tear_Down (Test : in out Test_Type)
-- with post => Verify_Set_Up (Test);

   procedure Test_Parse (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

end Ada_Lib.Text.Textbelt.Tests;
