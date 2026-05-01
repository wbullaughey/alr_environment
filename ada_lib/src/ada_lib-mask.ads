with Interfaces;

package Ada_Lib.Mask is

   generic

      type Data_Type (<>) is limited private;

   package Word is

      function Mask_OR (
         Left              : in   Data_Type;
         Right             : in   Data_Type
      ) return Data_Type;

      function Coerce (
         Value             : in   Data_Type
      ) return Interfaces.Unsigned_32;

      function Hex (
         Value             : in   Data_Type
      ) return String;

      function Invert (
         Value             : in   Data_Type
      ) return Data_Type;

      function Zero (
         Value             : in   Data_Type;
         Mask              : in   Data_Type
      ) return Boolean;

   end Word;
end Ada_Lib.Mask;
