with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Trace; use Ada_Lib.Trace;

package body Ada_Lib.Mail.GMail is

   ---------------------------------------------------------------
   overriding
   procedure Initialize (
      Credential                 :    out GMail_Credentials_Type;
      Name                       : in     String;
      Password                   : in     String;
      From_Address               : in     String := "") is
   ---------------------------------------------------------------

   begin
      Log_In (Debug, Quote ("Name", Name) & Quote (" Password", Password) &
         Quote (" From_Address", From_Address));

      Credentials_Type (Credential).Initialize (Name, Password, From_Address);
      Credential.Port := 465;
      Credential.URL.Construct ("smtp.gmail.com");
      Log_Out (Debug);
   end Initialize;

   ---------------------------------------------------------------
   overriding
   procedure Send (
      Credential                 : in out GMail_Credentials_Type;
      To_Address                 : in     String;
      Message                    : in     String;
      Subject                    : in     String := "";
      Verbose                    : in     Boolean := False) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug, Quote ("To_Address", To_Address) &
         Quote (" Subject", Subject) &
         Quote (" Message", Message));

      Credential.Send (To_Address, Message,
         Subject, Verbose);
      Log_Out (Debug);
   end Send;

   ---------------------------------------------------------------
   overriding
   procedure Send_File (
      Credential                 : in out GMail_Credentials_Type;
      To_Address                 : in     String;
      Path                       : in     String;
      Subject                    : in     String := "";
      Verbose                    : in     Boolean := False) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug,
         Quote ("To_Address", To_Address) &
         Quote (" Subject", Subject) &
         Quote (" Path", Path));

      Credential.Send_File (To_Address, Path,
         Subject, Verbose);
      Log_Out (Debug);
   end Send_File;

end Ada_Lib.Mail.GMail;
