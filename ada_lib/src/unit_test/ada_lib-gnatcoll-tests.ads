with AUnit.Test_Cases;
with AUnit.Test_Suites;
with Ada_Lib.Unit_Test.Test_Cases;

package Ada_Lib.GNATCOLL.Tests is

   Suite_Name                    : constant String := "GNATCOLL";

   type Test_Type                is abstract new Ada_Lib.Unit_Test.Test_Cases.
                                    Test_Case_Type with null record;

   overriding
   function Name (
      Test                       : in     Test_Type) return AUnit.Message_String;

   type Template_Test_Type           is new Test_Type with null record;

   type  Template_Test_Access is access Template_Test_Type;

   overriding
   procedure Register_Tests (
      Test                       : in out Template_Test_Type);

   procedure Expand_Template (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

-- overriding
-- procedure Set_Up (Test : in out Template_Test_Type)
-- with post => Test.Verify_Set_Up;

   function Suite return AUnit.Test_Suites.Access_Test_Suite;

-- overriding
-- procedure Tear_Down (Test : in out Template_Test_Type)
-- with post => Verify_Set_Up (Test);

   Debug                         : Boolean := False;
end Ada_Lib.GNATCOLL.Tests;
