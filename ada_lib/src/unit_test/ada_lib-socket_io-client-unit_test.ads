with Ada_Lib.Unit_Test.Test_Cases;
with AUnit.Test_Suites;

package Ada_Lib.Socket_IO.Client.Unit_Test is

   type Socket_Client_Test_Type is new Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type
                                    with null record;
   type Socket_Client_Test_Access is access Socket_Client_Test_Type;

   overriding
   function Name (
      Test                       : Socket_Client_Test_Type
   ) return Standard.AUnit.Message_String;

   overriding
   procedure Register_Tests (
      Test                       : in out Socket_Client_Test_Type);

   overriding
   procedure Set_Up (
      Test                       : in out Socket_Client_Test_Type
   ) with Pre => not Test.Verify_Set_Up,
          Post => Test.Verify_Set_Up;

   function Suite return Standard.AUnit.Test_Suites.Access_Test_Suite;

-- overriding
-- procedure Tear_Down (Test : in out Socket_Client_Test_Type);

   Suite_Name                    : constant String := "Client_Socket_IO";


end Ada_Lib.Socket_IO.Client.Unit_Test;
