with AUnit.Test_Cases;
with AUnit.Test_Suites;
with Ada_Lib.Mail.CURL;
with Ada_Lib.Mail.SMTP;
with Ada_Lib.Unit_Test.Test_Cases;
-- with Ada_Lib.Unit_Test.Test_Cases;

package Ada_Lib.Mail.Tests is

   Suite_Name                    : constant String := "Send_Mail";

   type Test_Type                is abstract new Ada_Lib.Unit_Test.Test_Cases.
                                    Test_Case_Type with null record;

   overriding
   function Name (
      Test                       : in     Test_Type) return AUnit.Message_String;

   type CURL_Test_Type           is new Test_Type with record
      Credential                 : Ada_Lib.Mail.CURL.CURL_Credentials_Type;
   end record;

   type  CURL_Test_Access is access CURL_Test_Type;

   overriding
   procedure Register_Tests (
      Test                       : in out CURL_Test_Type);

   procedure Send_CURL_Mail (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Send_CURL_File_Mail (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   overriding
   procedure Set_Up (
      Test                       : in out CURL_Test_Type
   ) with Pre => not Test.Verify_Set_Up,
          Post => Test.Verify_Set_Up;

   type SMTP_Test_Type (
      Description    : Ada_Lib.Strings.String_Constant_Access
                        ) is new Test_Type with record
      Credential     : Ada_Lib.Mail.SMTP.SMTP_Credentials_Type (
                        Description);
   end record;

   type  SMTP_Test_Access is access SMTP_Test_Type;

   overriding
   procedure Register_Tests (
      Test                       : in out SMTP_Test_Type);

   procedure Send_SMTP_Mail (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Send_SMTP_File_Mail (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   overriding
   procedure Set_Up (
      Test                       : in out SMTP_Test_Type
   ) with Pre => not Test.Verify_Set_Up,
          Post => Test.Verify_Set_Up;

   function Suite return AUnit.Test_Suites.Access_Test_Suite;

   overriding
   procedure Tear_Down (
      Test : in out SMTP_Test_Type
   ) with post => Test.Verify_Tear_Down;

   Debug                         : Boolean := False;
end Ada_Lib.Mail.Tests;
