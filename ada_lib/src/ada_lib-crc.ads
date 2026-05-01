with GNAT.CRC32;
with Interfaces;
with System;

package Ada_Lib.CRC is

   type CRC_Type           is new Interfaces.Unsigned_32;

   subtype State_Type         is GNAT.CRC32.CRC32;

   function CRC (
      Address              : in   System.Address;
      Size              : in   Positive      -- in bits
   ) return CRC_Type;

   function Image (
      CRC                  : in   CRC_Type
   ) return String;

   procedure Initialize (
      State             :   out State_Type);

   procedure Calculate (
      State             : in out State_Type;
      Address              : in   System.Address;
      Size              : in   Positive); -- in bits

   function To_String (
      CRC                  : in   CRC_Type
   ) return String renames Image;

   function Value (
      State             : in   State_Type
   ) return CRC_Type;

end Ada_Lib.CRC;
