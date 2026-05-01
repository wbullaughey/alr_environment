with Ada.Unchecked_Conversion;
with Hex_IO;

package body Ada_Lib.Mask is

   package body Word is

      use type Interfaces.Unsigned_32;

      subtype Word_Type       is Interfaces.Unsigned_32;

      function Coerce_Word is new Ada.Unchecked_Conversion (
         Source   => Data_Type,
         Target   => Word_Type);

      function Coerce_Word is new Ada.Unchecked_Conversion (
         Source   => Word_Type,
         Target   => Data_Type);

      -------------------------------------------------------------------
      function Mask_OR (
         Left              : in   Data_Type;
         Right             : in   Data_Type
      ) return Data_Type is
      -------------------------------------------------------------------

      begin
         return Coerce_Word (Coerce_Word (Left) or Coerce_Word (Right));
      end Mask_OR;

      -------------------------------------------------------------------
      function Coerce (
         Value             : in   Data_Type
      ) return Interfaces.Unsigned_32 is
      -------------------------------------------------------------------

      begin
         return Coerce_Word (Value);
      end Coerce;

      -------------------------------------------------------------------
      function Hex (
         Value             : in   Data_Type
      ) return String is
      -------------------------------------------------------------------

      begin
         return Hex_IO.Hex (Coerce (Value));
      end Hex;

      -------------------------------------------------------------------
      function Invert (
         Value             : in   Data_Type
      ) return Data_Type is
      -------------------------------------------------------------------

      begin
         return Coerce_Word (not Coerce_Word (Value));
      end Invert;

      -------------------------------------------------------------------
      function Zero (
         Value             : in   Data_Type;
         Mask              : in   Data_Type
      ) return Boolean is
      -------------------------------------------------------------------

      begin
         return (Coerce_Word (Value) and Coerce_Word (Mask)) = 0;
      end Zero;

   end Word;
end Ada_Lib.Mask;
