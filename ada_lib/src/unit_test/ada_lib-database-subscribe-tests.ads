
with AUnit.Test_Cases;
with AUnit.Test_Suites;
-- with Ada_Lib.Database.Server;
with Ada_Lib.Unit_Test.Test_Cases;

package Ada_Lib.Database.Subscribe.Tests is

   type Test_Table_Type is new Ada_Lib.Database.Subscribe.Table_Type with null record;

   overriding
   procedure Load (
      Table                      : in out Test_Table_Type;
      Path                       : in     String);

   type Test_Type is new Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type  with record
      Subscribed                 : Boolean := False;
      Table                      : Test_Table_Type;
   end record;

   overriding
   procedure Set_Up (
      Test                       : in out Test_Type
   ) with Pre => not Test.Verify_Set_Up,
          Post => Test.Verify_Set_Up;

   function Subscribe_Suite (
      Which_Host              : in    Ada_Lib.Database.Which_Host_Type
   ) return AUnit.Test_Suites.Access_Test_Suite;

   overriding
   procedure Tear_Down (
      Test                       : in out Test_Type
   ) with post => Test.Verify_Tear_Down;

   Suite_Name                    : constant String := "Subscribe";

private

   procedure Load_Subscription (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   overriding
   function Name (Test : Test_Type) return AUnit.Message_String;

   -- register individual tests that access the DBDaemon
   overriding
   procedure Register_Tests (Test : in out Test_Type);

   procedure Store_Subscription (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

-- procedure Store_Load_Subscription (
--    Test                       : in out AUnit.Test_Cases.Test_Case'class);

end Ada_Lib.Database.Subscribe.Tests;
