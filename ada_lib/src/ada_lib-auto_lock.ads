with Ada.Finalization;
with Ada_Lib.Lock;


package Ada_Lib.Auto_Lock is
   pragma Elaborate_Body;

   subtype Lock_Type       is Ada_Lib.Lock.Lock_Type;

   type Lock_Access        is access all Lock_Type;

   type Conditional_Type (
      Reference            : Lock_Access) is new Ada.Finalization.Limited_Controlled with private;

   type Unconditional_Type (
      Reference            : Lock_Access) is new Ada.Finalization.Limited_Controlled with private;

   function Locked (
      Lock              : in   Conditional_Type
   ) return Boolean;

   Ada_Lib_Lib_Debug           : aliased Boolean := False;

private

   type Conditional_Type (
      Reference            : Lock_Access) is new Ada.Finalization.Limited_Controlled with record
      Got_Lock          : Boolean;
   end record;

   overriding
   procedure Initialize (
      Object               : in out Conditional_Type);

    overriding
    procedure Finalize (
      Object               : in out Conditional_Type);

   type Unconditional_Type (
      Reference            : Lock_Access) is new Ada.Finalization.Limited_Controlled with null record;

   overriding
   procedure Initialize (
      Object               : in out Unconditional_Type);

    overriding
    procedure Finalize (
      Object               : in out Unconditional_Type);

end Ada_Lib.Auto_Lock;