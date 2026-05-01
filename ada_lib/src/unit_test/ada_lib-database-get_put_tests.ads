with AUnit.Test_Cases;
with AUnit.Test_Suites;
with Ada_Lib.Database.Unit_Test;
with Ada_Lib.Unit_Test.Test_Cases;

package Ada_Lib.Database.Get_Put_Tests is

   -- used for tests which access DBDaemon
   type Database_Test_Type is new Ada_Lib.Database.Unit_Test.Test_Case_Type with null record;

   -- used for tests which do not access DBDaemon
   type No_Database_Test_Type is new Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type with null record;
   type No_Database_Test_Access is access No_Database_Test_Type;

   -- creates a test suite for all get_put tests that use DBDaemon
   -- adds a test list for local and Remote test to the test suite
   function Database_Suite (
      Which_Host              : in    Ada_Lib.Database.Which_Host_Type
   ) return AUnit.Test_Suites.Access_Test_Suite;

   -- creates a test suite for all get_put tests that no not use DBDaemon
   function No_Database_Suite return AUnit.Test_Suites.Access_Test_Suite;

   Suite_Name                    : constant String := "Get_Put";
private

   -- register individual tests that access the DBDaemon
   overriding
   procedure Register_Tests (Test : in out Database_Test_Type);

   -- register individual tests that do not access the DBDaemon
   overriding
   procedure Register_Tests (Test : in out No_Database_Test_Type);

   procedure Flush_Input (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Is_Open_True (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Is_Open_False (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   -- returns the name of the test list
   overriding
   function Name (Test : Database_Test_Type) return AUnit.Message_String;

   -- returns the name of the test list
   overriding
   function Name (Test : No_Database_Test_Type) return AUnit.Message_String;

   procedure Parse_Line (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Post_Get (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Post_Get_With_Token (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Name_Value_Get (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Name_Value_Get_With_Token (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   overriding
   procedure Set_Up (               -- opens database
      Test                       : in out Database_Test_Type
   ) with Pre => not Test.Verify_Set_Up,
          Post => Test.Verify_Set_Up;

   overriding
   procedure Tear_Down (
      Test                       : in out Database_Test_Type)
      with post => Verify_Tear_Down (Test);

   procedure Timeout_Get (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Wild_Get (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

end Ada_Lib.Database.Get_Put_Tests;
