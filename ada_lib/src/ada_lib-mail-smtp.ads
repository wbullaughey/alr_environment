with Ada_Lib.Mail.GMail;
with Ada_Lib.Socket_IO.Client;
-- with Ada_Lib.Socket_IO.Stream_IO;

package Ada_Lib.Mail.SMTP is

   Failed                        : exception;

   type SMTP_Credentials_Type (
      Description    : Ada_Lib.Strings.String_Constant_Access
                        ) is new Ada_Lib.Mail.GMail.GMail_Credentials_Type and
                        Protocol_Interface with private;

   overriding
   procedure Close (
      Credential                 :    out SMTP_Credentials_Type);

   overriding
   procedure Initialize (
      Credential                 :    out SMTP_Credentials_Type;
      Name                       : in     String;
      Password                   : in     String;
      From_Address               : in     String := "");

   overriding
   procedure Send (
      Credential                 : in out SMTP_Credentials_Type;
      To_Address                 : in     String;
      Message                    : in     String;
      Subject                    : in     String := "";
      Verbose                    : in     Boolean := False);

   overriding
   procedure Send_File (
      Credential                 : in out SMTP_Credentials_Type;
      To_Address                 : in     String;
      Path                       : in     String;
      Subject                    : in     String := "";
      Verbose                    : in     Boolean := False);

private

   Description                   : aliased constant String := "SMTP";

   type SMTP_Credentials_Type (
      Description    : Ada_Lib.Strings.String_Constant_Access
                        ) is new Ada_Lib.Mail.GMail.GMail_Credentials_Type and
                        Protocol_Interface with record
      Socket         : Ada_Lib.Socket_IO.Client.Client_Socket_Type (
                        Description);
   end record;

   overriding
   procedure Finalize (
      Credential                 : in out SMTP_Credentials_Type);

end Ada_Lib.Mail.SMTP;
