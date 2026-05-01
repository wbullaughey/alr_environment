with Ada.Characters.Latin_1;
with Ada.Strings.Maps;
with Interfaces;

package Command_Line_Iterator is

   Invalid_Option          : exception;
   Invalid_Number          : exception;
   No_Argument             : exception;
   No_Parameter            : exception;
   No_Selection            : exception;
   Not_Argument            : exception;
   Not_Option              : exception;

   type Iterator_Type         is tagged private;

   No_Prefix               : Character renames Ada.Characters.Latin_1.NUL;

   -- raises No_Argument, Invalid_Option
   procedure Advance (
      Iterator          : in out Iterator_Type);

   -- raises Not_Option, No_Parameter, No_Argument
   procedure Advance_Parameter (
      Iterator          : in out Iterator_Type);

   function At_End (
      Iterator          : in   Iterator_Type
   ) return Boolean;

   function Get_Argument (
      Iterator          : in   Iterator_Type
   ) return String;

   function Get_Option (
      Iterator          : in   Iterator_Type
   ) return Character;

   function Get_Parameter (
      Iterator          : in   Iterator_Type
   ) return String;

   -- raise Invalid_Number
   function Get_Number (
      Iterator          : in   Iterator_Type
   ) return Integer;

   -- raise Invalid_Number
   function Get_Number (
      Iterator          : in   Iterator_Type
   ) return float;

   -- raise Invalid_Number
   function Get_Number (
      Iterator          : in   Iterator_Type;
      Base              : in   Positive := 16
   ) return Interfaces.Unsigned_64;

   generic
      type Value_Type         is range <>;

   -- raise Invalid_Number
   function Get_Signed (
      Iterator          : in   Iterator_Type
   ) return Value_Type;

   function Has_Parameter (
      Iterator          : in   Iterator_Type
   ) return Boolean;

   -- raises No_Selection, Invalid_Option
   function Initialize (
      Include_Options         : in   Boolean;
      Include_Non_Options     : in   Boolean;
      Options_With_Parameters : in   String  := "";
      Option_Prefix           : in Character := '-';
      Skip                    : in   Natural := 0
   ) return Iterator_Type;

   -- raises No_Argument
   function Is_Option (
      Iterator          : in   Iterator_Type
   ) return Boolean;

   procedure Make;               -- dummy used to force recomplation

private

   type Iterator_Type         is tagged record
      Argument_Index       : Positive;
      At_End               : Boolean;
      Character_Index         : Natural;
      Has_Parameter        : Boolean;
      In_Options           : Boolean;
      Include_Non_Options     : Boolean;
      Include_Options         : Boolean;
      Option               : Character;
      Option_Prefix        : Character;
      Options_With_Parameters : Ada.Strings.Maps.Character_Set;
      Parameter_Index         : Positive;
   end record;

end Command_Line_Iterator;
