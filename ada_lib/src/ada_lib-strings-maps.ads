with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;

package Ada_Lib.Strings.Maps is

   Failed   : exception;

   generic
      type Names_Type   is array (Positive range <>) of
                           Ada_Lib.Strings.Unlimited.String_Type;
      type Kind_Type    is private;
      type Kinds_Type   is array (Positive range <>) of Kind_Type;

      Kinds             : Kinds_Type;
      Names             : Names_Type;

   package Mapper is

      function Map_Name (
         Name     : in     String
      ) return Kind_Type;

      function Map_Name (
         Name     : in     Ada_Lib.Strings.Unlimited.String_Type
      ) return Kind_Type;

      function Map_Kind (
         Kind     : in     Kind_Type
      ) return String;

      function Map_Kind (
         Kind     : in     Kind_Type
      ) return Ada_Lib.Strings.Unlimited.String_Type;

   end Mapper;

end Ada_Lib.Strings.Maps;
