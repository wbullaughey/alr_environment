with Ada.Text_IO;
with GNAT.OS_Lib;

package Ada_Lib.OS.Run is

   Failed                        : exception;

   procedure Kill_All (
      Name                       : in     String);

   procedure Kill_Remote (
      Process_ID                 : in     GNAT.OS_Lib.Process_Id;
      Tree                       : in     Boolean := False);

   function Non_Blocking_Spawn (                   -- run on remote host
      Remote                     : in     String;
      Program                    : in     String;
      User                       : in     String;
      Parameters                 : in     String;
      Process_ID                 : access GNAT.OS_Lib.Process_Id := Null;
      Output_File                : in     String := ""
   ) return Boolean;

   function Non_Blocking_Spawn (                   -- run local
      Program                    : in     String;
      Parameters                 : in     String;
      Process_ID                 : access GNAT.OS_Lib.Process_Id := Null;
      Output_File                : in     String := ""
   ) return Boolean;

   function Spawn (                                -- run on remote host
      Remote                     : in     String;
      Program                    : in     String;
      User                       : in     String;
      Parameters                 : in     String;
      Output_File                : in     String := "";
      Zero_Ok                    : in     Boolean := False
   ) return OS_Exit_Code_Type;

   -- returns 1st line from output file. raises exception for failure
   function Spawn (
      Program                    : in     String;
      Parameters                 : in     String;
      Zero_Ok                    : in     Boolean := False
   ) return String;

   -- returns 0 on success, optionally output written to output file
   function Spawn (                                -- run local
      Program                    : in     String;
      Parameters                 : in     String;
      Output_File                : in     String := "";
      Zero_Ok                    : in     Boolean := False
   ) return OS_Exit_Code_Type;

   generic
      type Context_Type is tagged private;   -- used to pass data to caller

   package Spawn_Package is
   -- calls a callback procedure to handle data from output file

      -- callback passed open file descripter
      type File_Callback_Access is access procedure (
         Context                 : in out Context_Type;
         File                    : in out Ada.Text_IO.File_Type);

      -- callback called for each line of output file
      type Line_Callback_Access is access procedure (
         Context                 : in out Context_Type;
         Line                    : in     String);

      procedure Spawn (
         Program                 : in     String;
         Parameters              : in     String;
         Context                 : in out Context_Type;
         Callback                : in     File_Callback_Access;
         Zero_Ok                 : in     Boolean := False);

      procedure Spawn (
         Program                 : in     String;
         Parameters              : in     String;
         Context                 : in out Context_Type;
         Callback                : in     Line_Callback_Access;
         Zero_Ok                 : in     Boolean := False);

   end Spawn_Package;

   procedure Wait_For_Remote (
      Process_ID                 :     out GNAT.OS_Lib.Process_Id);

   Debug                         : aliased Boolean := False;
end Ada_Lib.OS.Run;
