-- with Ada.Directories;
with Ada.Strings.Fixed;
with Ada.Text_IO;
with Ada_Lib.Directory;
with Ada_Lib.OS.Run;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace; use Ada_Lib.Trace;

-- pragma Elaborate (Ada_Lib.OS);

package body Ada_Lib.Mail.CURL is

   ---------------------------------------------------------------
   overriding
   procedure Close (
      Credential                 :    out CURL_Credentials_Type) is
   pragma Unreferenced (Credential);
   ---------------------------------------------------------------

   begin
      Log_Here (Debug);
   end Close;

   ---------------------------------------------------------------
   overriding
   procedure Initialize (
      Credential                 :    out CURL_Credentials_Type;
      Name                       : in     String;
      Password                   : in     String;
      From_Address               : in     String := "") is
   ---------------------------------------------------------------

   begin
      Log_In (Debug, Quote ("Name", Name) & Quote (" Password", Password) &
         Quote (" From_Address", From_Address));

      Ada_Lib.Mail.GMail.GMail_Credentials_Type (Credential).Initialize (Name, Password, From_Address);
      Log_Out (Debug);
   end Initialize;

   ---------------------------------------------------------------
   overriding
   procedure Send (
      Credential                 : in out CURL_Credentials_Type;
      To_Address                 : in     String;
      Message                    : in     String;
      Subject                    : in     String := "";
      Verbose                    : in     Boolean := False) is
   ---------------------------------------------------------------

      Message_File_Name          : constant String :=
                                    Create_Message_File (Message, Subject);
   begin
      Log_In (Debug, Quote ("To_Address", To_Address) &
         Quote (" Message", Message) & Quote (" Message_File_Name", Message_File_Name));
      Credential.Send_File (To_Address, Message_File_Name, Subject, Verbose);

      if not Debug then
         Ada_Lib.Directory.Delete (Message_File_Name);
      end if;
      Log_Out (Debug);
   end Send;

   ---------------------------------------------------------------
   overriding
   procedure Send_File (
      Credential                 : in out CURL_Credentials_Type;
      To_Address                 : in     String;
      Path                       : in     String;
      Subject                    : in     String := "";
      Verbose                    : in     Boolean := False) is
   ---------------------------------------------------------------

      Command_File               : Ada_Lib.OS.File_Descriptor;
      Command_Temporary_File_Name: Ada_Lib.OS.Temporary_File_Name;
      Response_File              : Ada_Lib.OS.File_Descriptor;
      Response_Temporary_File_Name
                                 : Ada_Lib.OS.Temporary_File_Name;

   begin
      Log_In (Debug,
         Quote ("To_Address", To_Address) &
         Quote (" From_Address", Credential.From_Address) &
         Quote (" Subject", Subject) &
         Quote (" Path", Path));

      Ada_Lib.OS.Create_Scratch_File (Command_File, Command_Temporary_File_Name);
      Ada_Lib.OS.Close_File (Command_File);
      Ada_Lib.OS.Create_Scratch_File (Response_File, Response_Temporary_File_Name);
      Ada_Lib.OS.Close_File (Response_File);

      declare
         Command_File            : Ada.Text_IO.File_Type;
         Command_File_Name       : String renames Command_Temporary_File_Name (
                                    Command_Temporary_File_Name'first ..
                                       Command_Temporary_File_Name'last - 1);
         Response_File_Name      : String renames Response_Temporary_File_Name (
                                    Response_Temporary_File_Name'first ..
                                       Response_Temporary_File_Name'last - 1);
         Parameter               : constant String := Command_File_Name;

      begin
         Log_Here (Debug, " command file " & Command_File_Name);
         Ada.Text_IO.Open (Command_File, Ada.Text_IO.Out_File,
            Command_Temporary_File_Name);
         Ada.Text_IO.Put (Command_File, "CURL ");
         Ada.Text_IO.Put (Command_File, " --ssl-reqd");
         Ada.Text_IO.Put (Command_File, " --url 'smtps://" & Credential.URL.Coerce &
            ":" & Ada_Lib.Strings.Trim (Credential.Port'img) & "'");
         Ada.Text_IO.Put (Command_File, " --user '" & Credential.Name.Coerce & ":" &
            Credential.Password.Coerce & "'");
         Ada.Text_IO.Put (Command_File, " --mail-from '" &
            Credential.From_Address.Coerce & "'");
         Ada.Text_IO.Put (Command_File, " --mail-rcpt '" & To_Address & "'");
--       Ada.Text_IO.Put (Command_File, " --subject 'test message'");
         Ada.Text_IO.Put_Line (Command_File, " --upload-file '" & Path & "'");
         Ada.Text_IO.Close (Command_File);

         declare
            Result               : constant Ada_Lib.OS.OS_Exit_Code_Type :=
                                    Ada_Lib.OS.Run.Spawn (
                                       "/bin/bash", Parameter, Response_File_Name);
         begin
            Log_Here (Debug, "result " & Result'img &
               " response file " & Response_File_Name);

            if Debug or Verbose then
               declare
                  Response_File     : Ada.Text_IO.File_Type;

               begin
                  Ada.Text_IO.Open (Response_File, Ada.Text_IO.In_File,
                     Response_File_Name);

                  while not Ada.Text_IO.End_Of_File (Response_File) loop
                     declare
                        Line     : constant String :=
                                    Ada.Text_IO.Get_Line (Response_File);
                     begin
                        if Debug or Verbose then
                           Ada.Text_IO.Put_Line (Line);
                        end if;

                        if Ada.Strings.Fixed.Index (Line, "Login denied") > 0 then
                           raise Failed with Quote ("log in to email server failed for user",
                              Credential.Name.Coerce) & Quote (" password", Credential.Password.Coerce);
                        end if;
                     end;
                  end loop;

               end;
            end if;
         end;

         if not Debug then
            Ada_Lib.Directory.Delete (Command_File_Name);
            Ada_Lib.Directory.Delete (Response_File_Name);
         end if;
      end;

      Log_Out (Debug);
   end Send_File;


end Ada_Lib.Mail.CURL;
