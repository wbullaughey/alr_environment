with Ada.Exceptions;

separate (Ada_Lib.OS)

   -------------------------------------------------------------------
   procedure Set_Priority (
      Priority          : in   Priority_Type) is
   -------------------------------------------------------------------

   use type Interfaces.C.Int;

   function setpriority (
      Which             : in   Interfaces.C.Int;
      Who                  : in   Interfaces.C.Int;
      Amount               : in   Interfaces.C.Int
   ) return Interfaces.C.Int;

   pragma Import (C, setpriority);

   begin
      if setpriority (PRIO_PROCESS, 0, Interfaces.C.Int (Priority)) /= 0 then
         Ada.Exceptions.Raise_Exception (
            Failed'identity, "OS nice failed with error code " &
            GNAT.OS_Lib.Errno'img);
      end if;

   end Set_Priority;
