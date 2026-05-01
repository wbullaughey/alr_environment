-- with Ada.Strings.Fixed;
with Ada.Text_IO;
-- with Ada_Lib.Directory;
with Ada_Lib.OS;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
-- with Ada.Text_IO;
with Ada_Lib.Trace; use Ada_Lib.Trace;

-- pragma Elaborate (Ada_Lib.OS);

package body Ada_Lib.Mail is

   ---------------------------------------------------------------
   function Create_Message_File (
      Message                    : in     String;
      Subject                    : in     String
   ) return String is  -- temporary file name
   ---------------------------------------------------------------

      Message_File               : Ada_Lib.OS.File_Descriptor;
      Temporary_File_Name        : Ada_Lib.OS.Temporary_File_Name;

   begin
      Log_In (Debug, Quote ("Subject", Subject) & Quote (" Message", Message));
      Ada_Lib.OS.Create_Scratch_File (Message_File, Temporary_File_Name);
      Log_Here (Debug, Quote ("Temporary_File_Name", Temporary_File_Name));

      declare
         Message_File               : Ada.Text_IO.File_Type;
         Message_File_Name          : String renames Temporary_File_Name (
                                       Temporary_File_Name'first ..
                                          Temporary_File_Name'last - 1);

      begin
         Ada.Text_IO.Open (Message_File, Ada.Text_IO.Out_File,
            Message_File_Name);
         Ada.Text_IO.Put_Line (Message_File, "Subject: " & Subject);
         Ada.Text_IO.Put_Line (Message_File, Message);
         Ada.Text_IO.Close (Message_File);
         return Message_File_Name; -- (Message_File_Name'first .. Message_File_Name'last - 1);
      end;
   end Create_Message_File;

   ---------------------------------------------------------------
   procedure Initialize (
      Credential                 :    out Credentials_Type;
      Name                       : in     String;
      Password                   : in     String;
      From_Address               : in     String := "") is
   ---------------------------------------------------------------

   begin
      Log_In (Debug, Quote ("Name", Name) & Quote (" Password", Password) &
         Quote (" From_Address", From_Address));

      Credential.From_Address.Construct(
         if From_Address = "" then Name else From_Address);
      Credential.Name.Construct (Name);
      Credential.Password.Construct (Password);
      delay 0.5;     -- make sure conntect completed

      Log_Out (Debug);
   end Initialize;

end Ada_Lib.Mail;
