with AUnit.Test_Cases;
with AUnit.Test_Suites;
with Ada_Lib.Unit_Test.Test_Cases;

package Ada_Lib.Parser.Tests is

   type Test_Type is new Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type with null record;

   type Test_Access is access Test_Type;

   procedure Basic_Operations (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   overriding
   function Name (Test : Test_Type) return AUnit.Message_String;

   overriding
   procedure Register_Tests (Test : in out Test_Type);

-- overriding
-- procedure Set_Up (Test : in out Test_Type)

   function Suite return AUnit.Test_Suites.Access_Test_Suite;

-- overriding
-- procedure Tear_Down (Test : in out Test_Type)

   Suite_Name                    : constant String := "Parser";

end Ada_Lib.Parser.Tests;

