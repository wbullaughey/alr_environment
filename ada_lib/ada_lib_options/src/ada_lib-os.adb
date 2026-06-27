with Ada.Characters.Latin_1;
--with Ada.Dynamic_Priorities;
with Ada.Text_IO; use  Ada.Text_IO;
--with Ada_Lib.Options;
with Ada_Lib.OS_Strings;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Strings;
with Ada_lib.Trace; use Ada_Lib.Trace;
with Command_Name;
with GNAT.Sockets;
with Interfaces.C;

package body Ada_Lib.OS is


   function getpid
   return Interfaces.C.Int;

   pragma Import (C, getpid);

-- Shell_File_Name            : constant String := "/bin/sh";

   -------------------------------------------------------------------
   -- creates scrtach file and returns its name
   function Create_Scratch_File
   return String is
   -------------------------------------------------------------------

      File                       : File_Descriptor;
      Name                       : Temporary_File_Name;
      Zero_String                : constant String (1 .. 1) := (
                                    1 => Ada.Characters.Latin_1.NUL);
   begin
      Create_Scratch_File (File, Name);
      declare
         Terminator              : constant Integer := Ada_Lib.Strings.Index (Name, Zero_String);

      begin
         if Terminator < Name'length - 1 then
            raise Failed with "invalid scratch file name terminator" & Terminator'img;
         end if;
         Close_File (File);
         return String (Name (Name'first .. Terminator - 1));
      end;
   end Create_Scratch_File;

   -------------------------------------------------------------------
   procedure Exception_Halt (
      Fault                      : in     Ada.Exceptions.Exception_Occurrence;
      Message                    : in     String := "";
      From                       : in     String := GNAT.Source_Info.Source_Location) is
   -------------------------------------------------------------------

   begin
      Put_Line ("Aborting " & (if Message'length > 0 then
         Message & " "
      else
         "")
      & " From " & From & ". Exception: " &
      Ada.Exceptions.Exception_Name (Fault) &
      " message: " & Ada.Exceptions.Exception_Message (Fault));
      Ada_Lib.Trace.Trace_Message_Exception (Fault, Message, From);
      Immediate_Halt (Ada_Lib.OS.Exception_Exit);

   end Exception_Halt;

   -------------------------------------------------------------------
   procedure Immediate_Halt (
      Exit_Code            : in   OS_Exit_Code_Type;
      Message                    : in     String := "";
      From                       : in     String := GNAT.Source_Info.Source_Location) is
   -------------------------------------------------------------------

   begin
      if Trace then
         Put_Line ("Exit_Code " & Exit_Code'img &
            Integer (OS_Exit_Code_Type'pos (Exit_Code))'img & " for " & Command_Name &
            Quote (" message", Message) & " from " & From);
      end if;
      if Message'length > 0 then
         Put_Line (Message);
      end if;

      GNAT.OS_Lib.OS_Exit (Integer (OS_Exit_Code_Type'pos (Exit_Code)));
   end Immediate_Halt;

   -------------------------------------------------------------------
   function Get_Environment (
      Name                       : in     String
   ) return String is
   -------------------------------------------------------------------

      Value                      : GNAT.OS_Lib.String_Access := GNAT.OS_Lib.Getenv (Name);
      Result                     : constant String := Value.all;

   begin
      GNAT.OS_Lib.Free (Value);
      return Result;
   end Get_Environment;

   -------------------------------------------------------------------
   function Get_Host_Name
   return String is
   -------------------------------------------------------------------

   begin
      return GNAT.Sockets.Host_Name;
   end Get_Host_Name;

   -------------------------------------------------------------------
   function Get_User
   return String is
   -------------------------------------------------------------------

   begin
      return Get_Environment (Ada_Lib.OS_Strings.User_Environment_Variable);
   end Get_User;

-- -------------------------------------------------------------------
-- function Scratch_File_Name
-- return String is
-- -------------------------------------------------------------------
--
-- begin
--    return Ada_Lib.OS_Strings.Scratch_File_Path & "/abc";
-- end Scratch_File_Name;

   -------------------------------------------------------------------
   function Self
   return Process_Id_Type is
   -------------------------------------------------------------------

   begin
      return Process_Id_Type (getpid);
   end Self;
   -------------------------------------------------------------------

   -------------------------------------------------------------------
   function Self
   return String is
   -------------------------------------------------------------------

   begin
      return Process_Id_Type'image (Self);
   end Self;

--   -------------------------------------------------------------------
--   function Shell_Script (
--      Script               : in   String;
--      Arguments            : in   Argument_Array
--   ) return Integer is
--   -------------------------------------------------------------------
--
--      Argument_List        : Argument_Array (
--                           Arguments'first .. Arguments'last + 1);
--      Result               : Integer;
--
--   begin
--      Argument_list (Argument_list'first) := new String'(Script);
--
--      Argument_List (Argument_list'first + 1 .. Argument_list'last) := Arguments;
--      Result := GNAT.OS_Lib.Spawn (Shell_File_Name, Argument_List);
--
----    Trace.Log (Trace.Load_FPGA, Trace.Here, "spawn (" &
----       Argument_List (Argument_List'first).all & "," &
----       Argument_List (Argument_List'last).all & ")");
--
--      GNAT.OS_Lib.Free (Argument_list (Argument_list'first));
--      return Result;
--   end Shell_Script;

   -------------------------------------------------------------------
   procedure Set_Priority (
      Priority          : in   Priority_Type) is separate;
   -------------------------------------------------------------------

-- begin
--    Ada.Dynamic_Priorities.Set_Priority (Priority);
--       -- Sets current task's priority
-- end Set_Priority;

begin
--Trace := True;
-- if Trace then
--    Put_Line (" Ada_Lib.Options.Ada_Lib_Environment.Unit_Testing " & Ada_Lib.Options.Ada_Lib_Environment.Unit_Testing'img & " " &
--       GNAT.Source_Info.Source_Location);
-- end if;
   Log_Here (Elaborate or else Trace);
end Ada_Lib.OS;
