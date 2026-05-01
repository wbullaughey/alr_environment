with Ada_Lib.Strings;
with Ada_Lib.Trace; use Ada_Lib.Trace;

package body Ada_Lib.Auto_Lock is

   -------------------------------------------------------------------
    overriding
    procedure Finalize (
      Object               : in out Conditional_Type) is
   -------------------------------------------------------------------

   begin
      Log (Ada_Lib_Lib_Debug, Here, Who & " enter " & Ada_Lib.Strings.Image (Object'address));
      if Object.Got_Lock then
         Object.Reference.Unlock;
      end if;
      Log (Ada_Lib_Lib_Debug, Here, Who & " exit");
   end Finalize;

   -------------------------------------------------------------------
   overriding
   procedure Initialize (
      Object               : in out Conditional_Type) is
   -------------------------------------------------------------------

   begin
      Log_In (Ada_Lib_Lib_Debug, "address " & Ada_Lib.Strings.Image (Object'address));
      if Object.Reference.Is_Locked then
         Object.Got_Lock := False;
      else
         Object.Reference.Lock;
      end if;
      Log_Out (Ada_Lib_Lib_Debug, " got lock " & Object.Got_Lock'img);
   end Initialize;

   -------------------------------------------------------------------
   function Locked (
      Lock              : in   Conditional_Type
   ) return Boolean is
   -------------------------------------------------------------------

   begin
      return Lock.Got_Lock;
   end Locked;

   -------------------------------------------------------------------
   overriding
   procedure Initialize (
      Object               : in out Unconditional_Type) is
   -------------------------------------------------------------------

   begin
      Log (Ada_Lib_Lib_Debug, Here, Who & " enter " & Ada_Lib.Strings.Image (Object'address));
      Object.Reference.Lock;
      Log (Ada_Lib_Lib_Debug, Here, Who & " exit");
   end Initialize;

   -------------------------------------------------------------------
    overriding
    procedure Finalize (
      Object               : in out Unconditional_Type) is
   -------------------------------------------------------------------

   begin
      Log (Ada_Lib_Lib_Debug, Here, Who & " enter " & Ada_Lib.Strings.Image (Object'address));
      Object.Reference.Unlock;
      Log (Ada_Lib_Lib_Debug, Here, Who & " exit");
   end Finalize;

end Ada_Lib.Auto_Lock;
