with AUnit.Test_Suites;
--with Ada_Lib.Unit_Test.Test_Cases;
--with GNOGA_Ada_Lib;
--with Gnoga.Gui.Element.Common;
--with Gnoga.Gui.Element.Form;
--with Gnoga.Gui.View;

package Ada_Lib.Gnoga.Unit_Test.Base is

-- type Test_Base_Type is new Base_Type with null record;

-- procedure Start (
--    Base                       : in out Test_Base_Type);
--
-- procedure Terminated (
--    Base                       : in out Test_Base_Type);

   type Test_Type is new GNOGA_Tests_Type (
      Initialize_GNOGA  => False,
      Test_Driver       => False) with null record;

   type Test_Access is access Test_Type;

   overriding
   function Name (Test : Test_Type) return AUnit.Message_String;

   overriding
   procedure Register_Tests (Test : in out Test_Type);

-- overriding
-- procedure Set_Up (
--    Test                       : in out Test_Type
-- ) with Pre => not Test.Verify_Set_Up,
--        Post => Test.Verify_Set_Up;

   function Suite return AUnit.Test_Suites.Access_Test_Suite;

   overriding
   procedure Tear_Down (
      Test : in out Test_Type
   ) with post => Test.Verify_Tear_Down;

   Suite_Name                    : constant String := "Main";

end Ada_Lib.GNOGA.Unit_Test.Base;

