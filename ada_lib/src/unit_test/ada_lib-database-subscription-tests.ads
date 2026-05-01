
with AUnit.Test_Cases;
with AUnit.Test_Suites;
-- with Ada_Lib.Database.Server;
with Ada_Lib.Database.Subscribe;
with Ada_Lib.Database.Updater;
with Ada_Lib.Unit_Test.Test_Cases;

package Ada_Lib.Database.Subscription.Tests is

   type Subscription_Table_Type is new Ada_Lib.Database.Subscribe.Table_Type with null record;

   overriding
   procedure Load (
      Table                      : in out Subscription_Table_Type;
      Path                       : in     String);

   type Subscription_Type is new Ada_Lib.Database.Updater.Abstract_Updater_Type with null record;

-- function "=" (
--    Left, Right                : in     Subscription_Type
-- ) return Boolean;

-- procedure Load (
--    Table                      :    out Subscription_Type;
--    Path                       : in     String);

-- procedure Load (
--    Subscription               :    out Subscription_Type;
--    File                       : in out Ada.Text_IO.File_Type;
--    Got_Subscription           :    out Boolean);

   overriding
   function Name_Value (
      Subscription               : in     Subscription_Type
   ) return Name_Value_Type'class;

   overriding
   procedure Update (
     Subscription               : in out Subscription_Type;
     Address                    : in     Ada_Lib.Database.Updater.Abstract_Address_Type'class;
     Tag                        : in     String;
     Value                      : in     String;
     Update_Kind                : in     Ada_Lib.Database.Updater.Update_Kind_Type;
     From                       : in     String := Ada_Lib.Trace.Here);

   type Test_Type is new Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type  with null record;

   function Subscription_Suite (
      Which_Host              : in    Ada_Lib.Database.Which_Host_Type
   ) return AUnit.Test_Suites.Access_Test_Suite;

   Suite_Name                    : constant String := "Subscription";

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

   procedure Store_Load_Subscription (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

end Ada_Lib.Database.Subscription.Tests;
