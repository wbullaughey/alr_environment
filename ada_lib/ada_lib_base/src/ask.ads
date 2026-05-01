with Ada.Text_IO;

package Ask is

   function Ask_Character (
      Question             : in   String
   ) return Character;

   function Ask_String (
      Question             : in   String
   ) return String;

   procedure Ask_Float (
      Question             : in   String;
      Value                : in out Float;
      Fore                 : in   Natural := 0;
      Aft                     : in   Natural := 0;
      Exp                     : in   Natural := 0);

   procedure Ask_Integer (
      Question             : in   String;
      Value                : in out Integer);

   procedure Ask_Time (
      Question             : in   String;
      Value                : in out Duration);

   generic

      type Value_Type            is digits <>;

      Default_Fore            : in Natural := 0;
      Default_Aft             : in Natural := 0;
      Default_Exp             : in Natural := 0;

   procedure Floating_Point (
      Question             : in   String;
      Value                : in out Value_Type;
      Fore                 : in   Natural := Default_Fore;
      Aft                     : in   Natural := Default_Aft;
      Exp                     : in   Natural := Default_Exp);

   generic

      type Value_Type            is ( <> );

   procedure Integer_Decimal (
      Question             : in   String;
      Value                : in out Value_Type);

   generic

      type Value_Type            is range <>;

   procedure Integer_Hex (
      Question             : in   String;
      Value                : in out Value_Type);

   procedure Lock_Input;

   generic

      type Value_Type            is mod <>;

   procedure Modular_Hex (
      Question             : in   String;
      Value                : in out Value_Type);

   procedure Push (
      Value                : in     Character);

   procedure Push (
      Value                : in     String);

   procedure Push_Line (
      Value                : in     String);

   procedure Set_Output_File (
      File                 : in   Ada.Text_IO.File_Access);

   -- raises:
   --       an asserting failure
   procedure Unlock_Input;

   function Yes_No (
      Question             : in   String
   ) return Boolean;

   function Yes_No (
      Question             : in   String;
      Was                     : in   Boolean
   ) return Boolean;

end Ask;
