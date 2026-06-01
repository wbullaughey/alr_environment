with Interfaces.C;
with System.Storage_Elements;

package Hex_IO is

   Width_Error                   : exception;

   procedure Dump_8 (
      Source                     : in     System.Address;
      Size                       : in     Positive;      -- size in bits
      Width                      : in     Positive := 16;
      Message                    : in     String := "");

   procedure Dump_16 (
      Source                     : in     System.Address;
      Size                       : in     Positive;      -- size in bits
      Width                      : in     Positive := 8;
      Message                    : in     String := "");

   procedure Dump_32 (
      Source                     : in     System.Address;
      Size                       : in     Positive;        -- size in bits
      Width                      : in     Positive := 4;
      Message                    : in     String := "");

   procedure Dump_64 (
      Source                     : in     System.Address;
      Size                       : in     Positive := 64;        -- size in bits
      Width                      : in     Positive := 64;
      Message                    : in     String := "");

   function Hex (
      Source               : in   String
   ) return Integer;

   function Hex (
      Source               : in   String
   ) return Interfaces.Integer_8;

   function Hex (
      Source               : in   String
   ) return Interfaces.Integer_16;

   function Hex (
      Source               : in   String
   ) return Interfaces.Integer_32;

   function Hex (
      Source               : in   String
   ) return Interfaces.Integer_64;

   function Hex (
      Source               : in   String
   ) return Interfaces.Unsigned_8;

   function Hex (
      Source               : in   String
   ) return Interfaces.Unsigned_16;

   function Hex (
      Source               : in   String
   ) return Interfaces.Unsigned_32;

   function Hex (
      Source               : in   String
   ) return Interfaces.Unsigned_64;

   function Hex (
      Value             : in   character
   ) return String;

   function Hex (
      Value             : in   Integer;
      Width             : in   Positive := 8
   ) return String;

   function Hex (
      Value             : in   Interfaces.C.Unsigned
   ) return String;

   function Hex (
      Address              : in   System.Address
   ) return String;

   function Hex (
      Address              : in   System.Storage_Elements.Storage_Offset
   ) return String;

   function Hex (
      Value             : in   Interfaces.Unsigned_8;
      Width             : in   Positive := 2
   ) return String;

   function Hex (
      Value             : in   Interfaces.Unsigned_16;
      Width             : in   Positive := 4
   ) return String;

   function Hex (
      Value             : in   Interfaces.Unsigned_32;
      Width             : in   Positive := 8
   ) return String;

   -- raises Width_Error
   function Hex (
      Value             : in   Interfaces.Unsigned_64;
      Width             : in   Positive := 16
   ) return String;

   function Hex (
      Value             : in   Interfaces.Integer_8;
      Width             : in   Positive := 2
   ) return String;

   function Hex (
      Value             : in   Interfaces.Integer_16;
      Width             : in   Positive := 4
   ) return String;

   function Hex (
      Value             : in   Interfaces.Integer_32;
      Width             : in   Positive := 8
   ) return String;

   function Hex (
      Value             : in   Interfaces.Integer_64;
      Width             : in   Positive := 16
   ) return String;

   function Hex (
      Value             : in   Interfaces.C.Unsigned_Char
   ) return String;

   generic
      type Data_Type       is range <>;

   function Integer_Hex (
      Value             : in   Data_Type;
      Width             : in   Positive := Data_Type'size / 4
   ) return String;

   generic
      type Data_Type       is mod <> ;

   function Modular_Hex (
      Value             : in   Data_Type;
      Width             : in   Positive := Data_Type'size / 4
   ) return String;

   function Modular_Hex_Address (
      Address           : in   System.Address;
      Width             : in   Positive   -- in bytes
   ) return String;

end Hex_IO;
