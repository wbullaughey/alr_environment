with Ada.Directories;
with Ada.Exceptions;
with Ada.Text_IO;
with AUnit.Assertions; use AUnit.Assertions;
--with Ada_Lib.Unit_Test;
-- with Ada_Lib.Mail.GMail;
with Ada_Lib.OS;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Trace; use Ada_Lib.Trace;
-- with Ada_Lib.Unit_Test.Test_Cases;

-- pragma Elaborate (Ada_Lib.OS);

package body Ada_Lib.Mail.Tests is

   Account                       : constant String := "wbullaughey@gmail.com";
-- Account_Base64                : constant String := "d2J1bGxhdWdoZXlAZ21haWwuY29tCg==";
   Message                       : constant String := "test message body";
   Password                      : constant String := "nvvjhdzbfthfwyey";
-- Password_Base64               : constant String := "bnZ2amhkemJmdGhmd3lleQo=";
   Subject                       : constant String := "test subject";
   To_Address                    : constant String := "wlb122@verizon.net";

   ---------------------------------------------------------------
   overriding
   function Name (
      Test                       : in     Test_Type) return AUnit.Message_String is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

   begin
      return AUnit.Format (Suite_Name);
   end Name;

   ---------------------------------------------------------------
   overriding
   procedure Register_Tests (
      Test                       : in out CURL_Test_Type) is
   ---------------------------------------------------------------

   begin
      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Send_CURL_Mail'access,
         Routine_Name   => AUnit.Format ("Send_CURL_Mail")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Send_CURL_File_Mail'access,
         Routine_Name   => AUnit.Format ("Send_CURL_File_Mail")));

   end Register_Tests;

   ---------------------------------------------------------------
   overriding
   procedure Register_Tests (
      Test                       : in out SMTP_Test_Type) is
   ---------------------------------------------------------------

   begin
--    Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
--       Routine        => Send_SMTP_Mail'access,
--       Routine_Name   => AUnit.Format ("Send_SMTP_Mail")));

--    Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
--       Routine        => Send_SMTP_File_Mail'access,
--       Routine_Name   => AUnit.Format ("Send_SMTP_File_Mail")));
null;
   end Register_Tests;

   ---------------------------------------------------------------
   procedure Send_CURL_Mail(
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

      Local_Test                 : CURL_Test_Type renames CURL_Test_Type (Test);

   begin
      Log_In (Debug);
      Local_Test.Credential.Send (To_Address, "CURLL " & Message, Subject);
      Log_Out (Debug);

   exception
      when Fault: others =>
         Trace_Message_Exception (Fault, "error in library");
         Assert (False, "library failed");

   end Send_CURL_Mail;

   ---------------------------------------------------------------
   procedure Send_CURL_File_Mail (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

      Local_Test                 : CURL_Test_Type renames CURL_Test_Type (Test);
      Message_File_Name          : constant String :=
                                    Create_Message_File (Message, Subject);
   begin
      Log_In (Debug);
      Local_Test.Credential.Send_File (To_Address, Message_File_Name, Subject);
      if not Debug then
         Ada.Directories.Delete_File (Message_File_Name);
      end if;
      Log_Out (Debug);

   exception
      when Fault: others =>
         Trace_Message_Exception (Fault, "error in library");
         Assert (False, "library failed");

   end Send_CURL_File_Mail;

   ---------------------------------------------------------------
   procedure Send_SMTP_Mail(
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

      Local_Test                 : SMTP_Test_Type renames SMTP_Test_Type (Test);

   begin
      Log_In (Debug);
      Local_Test.Credential.Send (To_Address, Message, Subject);
      Log_Out (Debug);

   exception
      when Fault: others =>
         Trace_Message_Exception (Fault, "error in library");
         Assert (False, "library failed");

   end Send_SMTP_Mail;

   ---------------------------------------------------------------
   procedure Send_SMTP_File_Mail (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

      Local_Test                 : SMTP_Test_Type renames SMTP_Test_Type (Test);
      Message_File               : Ada_Lib.OS.File_Descriptor;
      Temporary_File_Name        : Ada_Lib.OS.Temporary_File_Name;


   begin
      Log_In (Debug);
      Ada_Lib.OS.Create_Scratch_File (Message_File, Temporary_File_Name);
      Log_Here (Debug, Quote ("Temporary_File_Name", Temporary_File_Name));

      declare
         Message_File            : Ada.Text_IO.File_Type;
         Message_File_Name       : String renames Temporary_File_Name (
                                    Temporary_File_Name'first ..
                                       Temporary_File_Name'last - 1);

      begin
         Ada.Text_IO.Open (Message_File, Ada.Text_IO.Out_File,
            Message_File_Name);
         Ada.Text_IO.Put_Line (Message_File, "Subject: " & Subject);
         Ada.Text_IO.Put_Line (Message_File, "File Send " & "SMTP " & Message);
         Ada.Text_IO.Close (Message_File);
         Local_Test.Credential.Send_File (To_Address, Message_File_Name,
            Subject);
         if not Debug then
            Ada.Directories.Delete_File (Message_File_Name);
         end if;
      end;
      Log_Out (Debug);

   exception
      when Fault: others =>
         Trace_Message_Exception (Fault, "error in library");
         Assert (False, "library failed");

   end Send_SMTP_File_Mail;

   ---------------------------------------------------------------
   overriding
   procedure Set_Up (
      Test                       : in out CURL_Test_Type) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug or Trace_Set_Up_Tear_Down);
      Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type (Test).Set_Up;
      Test.Credential.Initialize (Account, Password);
      Log_Out (Debug or Trace_Set_Up_Tear_Down);

   exception
      when Fault: others =>
         Trace_Exception (Debug, Fault);
         Assert (False, "exception message " & Ada.Exceptions.Exception_Message (Fault));

   end Set_Up;

   ---------------------------------------------------------------
   overriding
   procedure Set_Up (
      Test                       : in out SMTP_Test_Type) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug or Trace_Set_Up_Tear_Down);
      Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type (Test).Set_Up;
      Test.Credential.Initialize (Account, Password);
      Log_Out (Debug or Trace_Set_Up_Tear_Down);

   exception
      when Fault: others =>
         Trace_Exception (Debug, Fault);
         Assert (False, "exception message " & Ada.Exceptions.Exception_Message (Fault));

   end Set_Up;

   ---------------------------------------------------------------
   function Suite return AUnit.Test_Suites.Access_Test_Suite is
   ---------------------------------------------------------------

      Test_Suite                 : constant AUnit.Test_Suites.Access_Test_Suite :=
                                    new AUnit.Test_Suites.Test_Suite;
      CURL_Tests                 : constant CURL_Test_Access := new CURL_Test_Type;
      Description                : aliased constant String := "smtp";
      SMTP_Tests                 : constant SMTP_Test_Access :=
                                    new SMTP_Test_Type (Description'unchecked_access);

   begin
      Ada_Lib.Unit_Test.Suite (Suite_Name);  -- used for listing suites
      Test_Suite.Add_Test (CURL_Tests);
      Test_Suite.Add_Test (SMTP_Tests);
      return Test_Suite;
   end Suite;

   ---------------------------------------------------------------
   overriding
   procedure Tear_Down (
      Test                       : in out SMTP_Test_Type) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug or Trace_Set_Up_Tear_Down);
      Test.Credential.Close;
      Test_Type (Test).Tear_Down;
      Log_Out (Debug or Trace_Set_Up_Tear_Down);
   end Tear_Down;

begin
if Trace_Tests then
      Debug := Trace_Tests;
   end if;
--Debug := True;
   Log_Here (Elaborate or Trace_Options);
end Ada_Lib.Mail.Tests;
