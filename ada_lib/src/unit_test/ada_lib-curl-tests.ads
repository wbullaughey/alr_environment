with Ada_Lib.Unit_Test.Test_Cases;
with AUnit.Test_Cases;
with AUnit.Test_Suites;

package Ada_Lib.Curl.Tests is

   Suite_Name                    : constant String := "Curl";

   type Test_Type                is new Ada_Lib.Unit_Test.Test_Cases.
                                    Test_Case_Type with null record;

   overriding
   function Name (
      Test                       : in     Test_Type) return AUnit.Message_String;

   overriding
   procedure Register_Tests (
      Test                       : in out Test_Type);

   procedure Expand_Template (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

-- overriding
-- procedure Set_Up (Test : in out Test_Type)
-- with post => Test.Verify_Set_Up;

   function Suite return AUnit.Test_Suites.Access_Test_Suite;

-- overriding
-- procedure Tear_Down (Test : in out Test_Type)
-- with post => Verify_Set_Up (Test);

end Ada_Lib.Curl.Tests;