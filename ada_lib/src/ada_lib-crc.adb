with Hex_IO;
with System.Address_To_Access_Conversions;
with System.Storage_Elements;

package body Ada_Lib.CRC is

   package Conversion         is new System.Address_To_Access_Conversions (
      Character);

   use type System.Address;
   use type System.Storage_Elements.Storage_Offset;

   -------------------------------------------------------------------
   function CRC (
      Address              : in   System.Address;
      Size              : in   Positive      -- in bits
   ) return CRC_Type is
   -------------------------------------------------------------------

      State             : State_Type;

   begin
      Initialize (State);
      Calculate (State, Address, Size);
      return Value (State);
   end CRC;

   -------------------------------------------------------------------
   function Image (
      CRC                  : in   CRC_Type
   ) return String is
   -------------------------------------------------------------------

   begin
      return Hex_IO.Hex (Interfaces.Unsigned_32 (CRC), 8);
   end Image;

   -------------------------------------------------------------------
   procedure Initialize (
      State             :   out State_Type) is
   -------------------------------------------------------------------

   begin
      GNAT.CRC32.Initialize (State);
   end Initialize;

   -------------------------------------------------------------------
   procedure Calculate (
      State             : in out State_Type;
      Address              : in   System.Address;
      Size              : in   Positive) is  -- in bits
   -------------------------------------------------------------------

      Bytes             : constant Positive := Size / System.Storage_Unit;
      Increment            : constant System.Storage_Elements.Storage_Offset := 1;
      Pointer              : System.Address := Address;

   begin
      pragma Assert (Bytes*System.Storage_Unit = Size);
      for Counter in 1 .. Bytes loop
         GNAT.CRC32.Update (State, Conversion.To_Pointer (Pointer).all);
         Pointer := Pointer + Increment;
      end loop;
   end Calculate;

   -------------------------------------------------------------------
   function Value (
      State             : in   State_Type
   ) return CRC_Type is
   -------------------------------------------------------------------

   begin
      return CRC_Type (GNAT.CRC32.Get_Value (State));
   end Value;
end Ada_Lib.CRC;
