with AUnit.Test_Cases;
with Ada_Lib.Unit_Test.Test_Cases;
with AUnit.Test_Suites;

package Ada_Lib.Template.Tests is

   Suite_Name                    : constant String := "Template";

   type Test_Type is new Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type with null record;
   type Test_Access is access Test_Type;

   overriding
   function Name (Test : Test_Type) return AUnit.Message_String;

   overriding
   procedure Register_Tests (Test : in out Test_Type);

   procedure Test_Simple_Template (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Test_Simple_Variable_Template (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Test_Expression_Template (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Test_If_Expression_Template (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   function Suite return AUnit.Test_Suites.Access_Test_Suite;

end Ada_Lib.Template.Tests;
