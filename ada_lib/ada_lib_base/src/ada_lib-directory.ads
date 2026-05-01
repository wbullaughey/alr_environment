with Ada.Directories;

package Ada_Lib.Directory is

   IO_Failed                     : exception;
   Bad_Path                      : exception;
   Failed                        : exception;

   type Allow_Type is array (Ada.Directories.File_Kind) of Boolean;

   Default_Allow                 : constant Allow_Type := (
      Ada.Directories.Ordinary_File => True,
      others                        => False);

   procedure Delete (
      Name                       : in     String;
      Allow                      : in     Allow_Type := Default_Allow;
      Must_Exist                 : in     Boolean := False);

   function Exists (
      Name                       : in     String
   ) return Boolean
   with pre => Name'length > 0;

   function Full_Name (
      Name                       : in     String
   ) return String
   with pre => Name'length > 0;

   function Kind (
      Name                       : in     String
   ) return Ada.Directories.File_Kind
   with pre => Name'length > 0;

   function Is_Executable (
      File_Name                  : String
   ) return Boolean;

end Ada_Lib.Directory;
