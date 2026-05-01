with Ada.Finalization;
-- with Ada_Lib.Socket_IO.Stream_IO;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;

package Ada_Lib.Mail is

   Failed                        : exception;

   type Credentials_Type         is abstract new  Ada.Finalization.
                                    Limited_Controlled with record
      From_Address               : Ada_Lib.Strings.Unlimited.String_Type;
      Name                       : Ada_Lib.Strings.Unlimited.String_Type;
      Password                   : Ada_Lib.Strings.Unlimited.String_Type;
   end record;

   procedure Initialize (
      Credential                 :    out Credentials_Type;
      Name                       : in     String;
      Password                   : in     String;
      From_Address               : in     String := "");

   type Protocol_Interface       is limited Interface;

   procedure Close (
      Credential                 :    out Protocol_Interface) is abstract;

   procedure Send (
      Credential                 : in out Protocol_Interface;
      To_Address                 : in     String;
      Message                    : in     String;
      Subject                    : in     String := "";
      Verbose                    : in     Boolean := False) is abstract;

   procedure Send_File (
      Credential                 : in out Protocol_Interface;
      To_Address                 : in     String;
      Path                       : in     String;
      Subject                    : in     String := "";
      Verbose                    : in     Boolean := False) is abstract;

   Debug                         : Boolean := False;

private

   function Create_Message_File (
      Message                    : in     String;
      Subject                    : in     String
   ) return String;  -- temporary file name

end Ada_Lib.Mail;
