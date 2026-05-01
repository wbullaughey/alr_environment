with Interfaces.C;
with System;

package Ada_Lib.OS.IOCTL is

   function IOCTL (
      Module               : in   System.Address;
      Code              : in   Interfaces.C.Int;
      Input             : in   Interfaces.C.Int;
      Output               : in   Interfaces.C.Int;
      Length               : in   Interfaces.C.Int;
      Address              : in   System.Address
   ) return Interfaces.C.Int;

      pragma Import (C, IOCTL, "lr_ioctlx_banyan");

end Ada_Lib.OS.IOCTL;
