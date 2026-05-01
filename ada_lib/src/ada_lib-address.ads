with Ada.Unchecked_Conversion;
with System;

package Ada_Lib.Address is

   type Address_Type is range -(2**63) .. +(2**63 - 1);
   for Address_Type'Size use 64;

   function Convert is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => Address_Type);

end Ada_Lib.Address;
