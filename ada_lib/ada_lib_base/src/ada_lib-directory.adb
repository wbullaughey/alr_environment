with Ada.Directories; use Ada.Directories;
with Ada.IO_Exceptions;
--with Ada.Streams.Stream_IO;
--with Ada.Streams.Stream_IO.Text_Streams;
with Ada.Text_IO; use Ada.Text_IO;

with Ada.Exceptions;
with Ada_Lib.Options;
with Ada_Lib.OS.Environment;
with Ada_Lib.OS.Run;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Strings;
with Ada_Lib.Trace; use Ada_Lib.Trace;

-- pragma Elaborate (Ada_Lib.OS);

package body Ada_Lib.Directory is

   use type Ada_Lib.OS.OS_Exit_Code_Type ;

   Stat_Program                  : constant String := "/usr/bin/stat";
   Debug : Boolean renames Options.Ada_Lib_Directory.Debug;


   ---------------------------------------------------------------
   procedure Delete (
      Name                       : in     String;
      Allow                      : in     Allow_Type := Default_Allow;
      Must_Exist                 : in     Boolean := False) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug, Quote ("Name", Name) & " must exist " & Must_Exist'img);

      if Exists (Name) then
         declare
            File_Kind            : constant Ada.Directories.File_Kind := Kind (Name);

         begin
            Log_Here (Debug, "kind " & File_Kind'img);
            if not Allow (File_Kind) then
               raise Failed with Quote ("Name", Name) & " kind " & File_Kind'img &
                  " not allowed to be deleted";
            end if;

            case File_Kind is

               when  Ada.Directories.Ordinary_File |
                     Ada.Directories.Special_File =>
                  Ada.Directories.Delete_File (Name);

               when Ada.Directories.Directory =>
                  Ada.Directories.Delete_Tree (Name);

            end case;
         end;
      else
         if Must_Exist then
            raise Failed with Quote ("Name", Name) & " does not exist " & Here;
         end if;
      end if;

      Log_Out (Debug);

   exception

      when Fault: others =>
         Trace_Message_Exception (Fault, Who, Here);
         raise Failed with Quote ("Name", Name) & " could not be delete. Exceptin: " &
            Ada.Exceptions.Exception_Name (Fault);

   end Delete;

   ---------------------------------------------------------------
   function Exists (
      Name                       : in     String
   ) return Boolean is
   ---------------------------------------------------------------

      Result                     : constant Boolean := Ada.Directories.Exists (Name);

   begin
      Log_Here (Debug, Quote ("Name", Name) & " result " & Result'img);
      return Result;
   end Exists;

   ---------------------------------------------------------------
   function Full_Name (
      Name                       : in     String
   ) return String is
   ---------------------------------------------------------------

   begin
      return Ada.Directories.Full_Name (
         (if Name (Name'first) = '~' then
               Ada_Lib.OS.Environment.Get ("HOME") &
                  (if Name'length > 1 then
                        Name (Name'first + 1 .. Name'last)
                     else
                        "")
            else
               Name));
   end Full_Name;

   ---------------------------------------------------------------
   function Kind (
      Name                       : in     String
   ) return Ada.Directories.File_Kind is
   ---------------------------------------------------------------

   begin
      return Ada.Directories.Kind (Name);
   end Kind;

   ---------------------------------------------------------------
   function Is_Executable (
      File_Name                  : String
   ) return Boolean is
   ---------------------------------------------------------------

   begin
      Log_In (Debug, Quote ("File_Name", File_Name));

      if File_Name = Stat_Program then  -- prevent recursion
         return Log_Out (True, Debug);
      end if;

      declare
         Output_File : constant String := Ada_Lib.OS.Create_Scratch_File;
--       Success     : Boolean := False;
         Exit_Code   : constant Ada_Lib.OS.OS_Exit_Code_Type :=
                        Ada_Lib.OS.Run.Spawn (
                           Stat_Program, File_Name, Output_File);
      begin
         Log_In (Debug, Quote ("File_Name", File_Name) &
            " exit code " & Exit_Code'img &
            " output file " & Output_File);
         if Exit_Code /= Ada_Lib.OS.No_Error then
            raise FAiled with "could not spawn stat to get file status for " &
               Quote ("File_Name", File_Name);
         end if;
         declare
            File           : Ada.Text_IO.File_Type;

         begin
            Ada.Text_IO.Open (File, Ada.Text_IO.In_File, Output_File);

            declare
               Line           : constant String := Ada.Text_IO.Get_Line (File);
               Dash           : constant Integer := Ada_Lib.Strings.Index (Line, "-");

            begin
               Log_Here (Debug, Quote ("line", Line) & " dash" & Dash'img);
               Ada.Text_IO.Close (File);

               declare
                  Permissions : constant String := Line (Dash .. Line'last);

               begin
                  Log_Here (Debug, Quote ("permissions", Permissions) &
                     " first" & Permissions'first'img);
                  return Log_Out (
                     Permissions (Permissions'first + 3) = 'x' or else
                     Permissions (Permissions'first + 6) = 'x' or else
                     Permissions (Permissions'first + 9) = 'x',
                     Debug);
               end;
            end;
         end;
      end;

   exception

      when Fault: Ada.IO_Exceptions.Status_Error =>
         Log_Exception (Debug, Fault, "could not get status of " & File_Name);
         raise;

   end Is_Executable;

begin
--Debug := True;
--Elaborate := True;
   Log_Here (Debug or Elaborate);
end Ada_Lib.Directory;
