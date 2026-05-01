with Ada_Lib.Socket_IO;
with Ada_Lib.Strings.Unlimited;-- use Ada_Lib.Strings.Unlimited;

package Ada_Lib.Mail.GMail is

   type GMail_Credentials_Type   is abstract new Credentials_Type and
                                       Protocol_Interface with record
      Port                       : Ada_Lib.Socket_IO.Port_Type;
      URL                        : Ada_Lib.Strings.Unlimited.String_Type;
   end record;

   overriding
   procedure Initialize (
      Credential                 :    out GMail_Credentials_Type;
      Name                       : in     String;
      Password                   : in     String;
      From_Address               : in     String := "");

   overriding
   procedure Send (
      Credential                 : in out GMail_Credentials_Type;
      To_Address                 : in     String;
      Message                    : in     String;
      Subject                    : in     String := "";
      Verbose                    : in     Boolean := False);

   overriding
   procedure Send_File (
      Credential                 : in out GMail_Credentials_Type;
      To_Address                 : in     String;
      Path                       : in     String;
      Subject                    : in     String := "";
      Verbose                    : in     Boolean := False);

-- private
--
--   type GMail_Credentials_Type      is abstract new Credentials_Type and
--                                       Protocol_Interface with null record;
--
end Ada_Lib.Mail.GMail;
