with Ada.Characters.Latin_1;
with Ada.Streams;
-- with Ada.Strings.Fixed;
with Ada.Text_IO;
-- with Ada_Lib.Directory;
-- with Ada_Lib.OS.Run;
-- with Ada_Lib.Socket_IO.Client;
with Ada_Lib.Socket_IO.Stream_IO;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
-- with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace; use Ada_Lib.Trace;
-- with GNAT.Sockets;

package body Ada_Lib.Mail.SMTP is

-- use type Ada_Lib.Mail.Credentials_Type;

   ---------------------------------------------------------------
   overriding
   procedure Close (
      Credential                 :    out SMTP_Credentials_Type) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug);
      Credential.Socket.Close;
      Log_Out (Debug);
   end Close;

   ---------------------------------------------------------------
   overriding
   procedure Finalize (
      Credential                 : in out SMTP_Credentials_Type) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug);
      Credential.Socket.Close;
      Log_Out (Debug);
   end Finalize;

   ---------------------------------------------------------------
   overriding
   procedure Initialize (
      Credential                 :    out SMTP_Credentials_Type;
      Name                       : in     String;
      Password                   : in     String;
      From_Address               : in     String := "") is
   ---------------------------------------------------------------

   begin
      Log_In (Debug, Quote ("name", Name));
      Ada_Lib.Mail.GMail.GMail_Credentials_Type (Credential).Initialize (Name, Password, From_Address);
      Credential.Socket.Connect (Credential.URL.Coerce, 465);
--    Credential.Socket.Create_Stream;

      declare
         Buffer_Length           : constant Natural := Natural (Credential.Socket.In_Buffer);
         Response                : String (1 .. Buffer_Length);
         Buffer                  : Ada_Lib.Socket_IO.Buffer_Type (
                                    1 .. Ada.Streams.Stream_Element_Offset (
                                       Buffer_Length));
         for Buffer'Address use Response'address;

      begin
         if Buffer_Length > 0 then
            Credential.Socket.Read (Buffer, Timeout_Length => 2.0);
            Log_Out (Debug, Quote ("Response", Response ));
         else
            Log_Out (Debug);
         end if;

      exception
         when Fault: Ada_Lib.SOCKET_IO.STREAM_IO.TIMEOUT =>
            Trace_Exception (Debug, Fault, "no response from read");

         when Fault: others =>
            Trace_Exception (Debug, Fault);
            raise;

      end;
   end Initialize;

   ---------------------------------------------------------------
   overriding
   procedure Send (
      Credential                 : in out SMTP_Credentials_Type;
      To_Address                 : in     String;
      Message                    : in     String;
      Subject                    : in     String := "";
      Verbose                    : in     Boolean := False) is
   ---------------------------------------------------------------

      Character_Set              : constant String := "UTF-8";
      CR_LF                      : constant String := String'(
                                    Ada.Characters.Latin_1.CR &
                                    Ada.Characters.Latin_1.LF);
--    Client_Entry               : constant GNAT.Sockets.Host_Entry_Type :=
--                                     GNAT.Sockets.Get_Host_By_Name ("localhost");
--    IP_Address                 : constant GNAT.Sockets.Inet_Addr_Type := GNAT.Sockets.Addresses (Client_Entry);
      Hello                      : constant String := "EHLO " &
                                    "wbullaughey.dyndns-server.com" & CR_LF;
      Login                      : constant String := "AUTH LOGIN" & CR_LF &
                                    Credential.Name.Coerce & CR_LF & Credential.Password.Coerce;
      From                       : constant String := "MAIL FROM: " & Credential.From_Address.Coerce & CR_LF;
      Reply_To                   : constant String := "RCPT TO: " & Credential.Name.Coerce & CR_LF;
      MIME                       : constant String := "text/plain";
      Quit                       : constant String := "QUIT" & CR_LF;
      Request                    : constant String :=
                                    "DATE: 4/9/2023" & CR_LF &
                                    "X-Mailer: Ada_Lib.Mail" & CR_LF &
                                    "FROM: " & Credential.From_Address.Coerce & CR_LF &
                                    "TO: & To_Address: " & CR_LF &
                                    "Subject: " & Subject & CR_LF &
                                    "MIME-Version: 1.0" & CR_LF &
                                    "Content - type: " & MIME & "; charset=" & Character_Set & CR_LF & CR_LF;

      ------------------------------------------------------------
      procedure Send_Receive (
         Request                 : in     String) is
      ------------------------------------------------------------

         Last                    : Ada_Lib.Socket_IO.Index_Type;
         Receive_Buffer          : Ada_Lib.Socket_IO.Buffer_Type (1 .. 100);
         Output_Buffer           : constant String := Request & CR_LF;
         Send_Buffer             : Ada_Lib.Socket_IO.Buffer_Type (1 ..
                                    Ada_Lib.Socket_IO.Index_Type (Request'length));
         for Send_Buffer'address use Output_Buffer'address;

      begin
         Log_In (Debug, Quote ("Request", Request));
         Credential.Socket.Write (Send_Buffer);
         delay 0.5;
         Credential.Socket.Read (Receive_Buffer, Last);

         declare
            Response             : String (1 .. Natural (Last));
            for Response'address use Receive_Buffer'address;

         begin
            if Verbose then
               Ada.Text_IO.Put_Line (Response);
            end if;
            Log_Here (Debug, Quote ("Response", Response));
         end;

         if    Credential.Socket.Reader_Stopped or else
               Credential.Socket.Writer_Stopped then
            Log_Exception (Debug);
            raise Failed with "reader or write task stopped";
         end if;

         Log_Out (Debug);
      end Send_Receive;
      ------------------------------------------------------------

   begin
      Log_In (Debug, Quote ("To_Address", To_Address) & Quote (" Message", Message));

      Send_Receive (Hello);
      Send_Receive (Login);
      Send_Receive (From);
      Send_Receive (Reply_To);
      Send_Receive (Request & Message);
      Send_Receive (Quit);
      Log_Out (Debug);
   end Send;

   ---------------------------------------------------------------
   overriding
   procedure Send_File (
      Credential                 : in out SMTP_Credentials_Type;
      To_Address                 : in     String;
      Path                       : in     String;
      Subject                    : in     String := "";
      Verbose                    : in     Boolean := False) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug,
         Quote ("To_Address", To_Address) &
         Quote (" From_Address", Credential.From_Address) &
         Quote (" Subject", Subject) &
         Quote (" Path", Path));

--         Parameter               : constant String := Command_File_Name;
--
--      begin
--         Log_Here (Debug, " command file " & Command_File_Name);
--         Ada.Text_IO.Open (Command_File, Ada.Text_IO.Out_File,
--            Command_Temporary_File_Name);
--         Ada.Text_IO.Put (Command_File, "CURL ");
--         Ada.Text_IO.Put (Command_File, " --ssl-reqd");
--         Ada.Text_IO.Put (Command_File, " --url '" & URL & "'");
--         Ada.Text_IO.Put (Command_File, " --user '" & Credential.Name.Coerce & ":" &
--            Credential.Password.Coerce & "'");
--         Ada.Text_IO.Put (Command_File, " --mail-from '" &
--            Credential.From_Address.Coerce & "'");
--         Ada.Text_IO.Put (Command_File, " --mail-rcpt '" & To_Address & "'");
----       Ada.Text_IO.Put (Command_File, " --subject 'test message'");
--         Ada.Text_IO.Put_Line (Command_File, " --upload-file '" & Path & "'");
--         Ada.Text_IO.Close (Command_File);
--
--         declare
--            Result               : constant Integer := Ada_Lib.OS.Run.Spawn (
--                                    "/bin/bash", Parameter, Response_File_Name);
--         begin
--            Log_Here (Debug, "result " & Result'img &
--               " response file " & Response_File_Name);
--
--            if Debug then
--               declare
--                  Response_File     : Ada.Text_IO.File_Type;
--
--               begin
--                  Ada.Text_IO.Open (Response_File, Ada.Text_IO.In_File,
--                     Response_File_Name);
--
--                  while not Ada.Text_IO.End_Of_File (Response_File) loop
--                     declare
--                        Line     : constant String :=
--                                    Ada.Text_IO.Get_Line (Response_File);
--                     begin
--                        if Verbose then
--                           Ada.Text_IO.Put_Line (Line);
--                        end if;
--
--                        if Ada.Strings.Fixed.Index (Line, "Login denied") > 0 then
--                           raise Failed with Quote ("log in to email server failed for user",
--                              Credential.Name.Coerce) & Quote (" password", Credential.Password.Coerce);
--                        end if;
--                     end;
--                  end loop;
--
--               end;
--            end if;
--         end;
--
--         if not Debug then
--            Ada_Lib.Directory.Delete (Command_File_Name);
--            Ada_Lib.Directory.Delete (Response_File_Name);
--         end if;
--      end;
--
      Log_Out (Debug);
   end Send_File;


end Ada_Lib.Mail.SMTP;
