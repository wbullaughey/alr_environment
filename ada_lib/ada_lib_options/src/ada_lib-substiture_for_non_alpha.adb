--with Ada.Characters.Latin_1;
with Ada.Strings.Fixed;
with Ada.Strings.Maps;

package body Ada_Lib.Substiture_For_Non_Alpha is

   Printable_Characters          : constant Ada.Strings.Maps.Character_Set :=
                                    Ada.Strings.Maps.To_Set (
                                       Ada.Strings.Maps.Character_Range'(' ', '~'));

   -------------------------------------------------------------------
   function Mapper (
      Letter                  : in     Character
   ) return Character is
   -------------------------------------------------------------------

   begin
      return (if Ada.Strings.Maps.Is_In (Letter, Printable_Characters) then
            Letter
         else
            '#'); -- Ada.Characters.Latin_1.UC_O_Oblique_Stroke);
   end Mapper;

   -------------------------------------------------------------------
   function Substitute (
      Source                     : in     String
   ) return String is
   -------------------------------------------------------------------

   begin
      return Ada.Strings.Fixed.Translate (Source, Mapper'access);
   end Substitute;

end Ada_Lib.Substiture_For_Non_Alpha;

