with Ada_Lib.Mail.GMail;

package Ada_Lib.Mail.CURL is

   type CURL_Credentials_Type    is new Ada_Lib.Mail.GMail.GMail_Credentials_Type and
                                    Protocol_Interface with private;

   overriding
   procedure Close (
      Credential                 :    out CURL_Credentials_Type);

   overriding
   procedure Initialize (
      Credential                 :    out CURL_Credentials_Type;
      Name                       : in     String;
      Password                   : in     String;
      From_Address               : in     String := "");

   overriding
   procedure Send (
      Credential                 : in out CURL_Credentials_Type;
      To_Address                 : in     String;
      Message                    : in     String;
      Subject                    : in     String := "";
      Verbose                    : in     Boolean := False);

   overriding
   procedure Send_File (
      Credential                 : in out CURL_Credentials_Type;
      To_Address                 : in     String;
      Path                       : in     String;
      Subject                    : in     String := "";
      Verbose                    : in     Boolean := False);

private

   type CURL_Credentials_Type    is new Ada_Lib.Mail.GMail.GMail_Credentials_Type and
                                    Protocol_Interface with null record;
end Ada_Lib.Mail.CURL;
