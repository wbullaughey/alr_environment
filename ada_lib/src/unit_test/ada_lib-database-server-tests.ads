
with AUnit.Test_Cases;
with AUnit.Test_Suites;
with Ada_Lib.Database.Server.State;
with Ada_Lib.Database.Unit_Test;

package Ada_Lib.Database.Server.Tests is

-- -- used for test open and close, not done by setup DBDaemon
-- type Server_Open_Close_Test_Type is new Ada_Lib.Test.Tests.Test_Case_Type with record
--    Server                  : Ada_Lib.Database.Server.Server_Access := Null;
--    Started                 : Boolean := False;
-- end record;

   -- used for tests which access DBDaemon, open close done by set_up,tear_down
   type Server_Test_Type is new Ada_Lib.Database.Unit_Test.Test_Case_Type  with record
      Started                 : Boolean := False;
   end record;
   -- creates a test suite for all get_put tests that use DBDaemon
   -- adds a test list for local and Remote test to the test suite
   function Server_Suite (
      Which_Host              : in    Ada_Lib.Database.Which_Host_Type
   ) return AUnit.Test_Suites.Access_Test_Suite;

   Debug                         : Boolean := False;
   Server_State                  : aliased Ada_Lib.Database.Server.State.Server_Type;
   Suite_Name                    : constant String := "Database_Server";

private

   procedure Delete (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Delete_All (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Duplicate_Subscription (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Flush_Input (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Iterate_Subscriptions (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Start_Stop (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

-- -- returns the name of the test list
-- overriding
-- function Name (Test : Server_Open_Close_Test_Type) return AUnit.Message_String;

   overriding
   function Name (Test : Server_Test_Type) return AUnit.Message_String;

   procedure Name_Value_Get (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

-- procedure Name_Value_Get_With_Token (
--    Test                       : in out AUnit.Test_Cases.Test_Case'class);

-- -- register individual tests that access the DBDaemon
-- overriding
-- procedure Register_Tests (Test : in out Server_Open_Close_Test_Type);

   -- register individual tests that access the DBDaemon
   overriding
   procedure Register_Tests (Test : in out Server_Test_Type);

   procedure Post_Get (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

-- procedure Post_Get_With_Token (
--    Test                       : in out AUnit.Test_Cases.Test_Case'class);
--
   procedure Read (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Resubscribe (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

-- -- allocates Server
-- overriding
-- procedure Set_Up (               -- allocates database
--    Test                       : in out Server_Open_Close_Test_Type)

   -- allocates Server
   -- calls Server.Open
   overriding
   procedure Set_Up (               -- allocates and opens database
      Test                       : in out Server_Test_Type)
   with Pre => not Test.Verify_Set_Up,
        Post => Test.Verify_Set_Up;

   procedure Subscribe (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Subscribe_Unsubscribe (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

-- procedure Subscription_State (
--    Test                       : in out AUnit.Test_Cases.Test_Case'class);

-- overriding
-- procedure Tear_Down (         -- frees database
--    Test                       : in out Server_Open_Close_Test_Type)

   overriding
   procedure Tear_Down (         -- closes, frees database
      Test                       : in out Server_Test_Type)
      with post => Verify_Tear_Down (Test);

   procedure Timeout_Get (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

---- overriding
--   procedure Update (
--      Subscription               : in out Subscription_Tests_Updated_Value_Type);
--
---- overriding
--   procedure Update (
--      Subscription               : in out Update_Test_Updated_Value_Type);

-- procedure Set_Subscription_Mode (
--    Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Wild_Get (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

end Ada_Lib.Database.Server.Tests;
