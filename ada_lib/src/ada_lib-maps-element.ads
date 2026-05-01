with Ada.Containers;
with Ada.Finalization;

package Ada_Lib.Maps.Element is

   type Key_Access            is access all String;
   type Key_Type           is access constant String;

   type Limited_Element_Type  is abstract new Ada.Finalization.Limited_Controlled with private;
   type Element_Type       is abstract new Ada.Finalization.Controlled with private;

   overriding
   function "=" (
      Left, Right          : in   Element_Type
   ) return Boolean;

   function "=" (
      Left, Right          : in   Limited_Element_Type
   ) return Boolean;

   function Equivalent_Keys (
      Left, Right          : Key_Type
   ) return Boolean;

   function Hash (
      Key               : in   Key_Type
   ) return Ada.Containers.Hash_Type;

   function Key (
      Element              : in   Limited_Element_Type
   ) return Key_Type;

   function Key (
      Element              : in   Element_Type
   ) return Key_Type;

   procedure Set_Key (
      Element              : in out Limited_Element_Type;
      Key                  : in   String);

   procedure Set_Key (
      Element              : in out Element_Type;
      Key                  : in   String);

private

   overriding
   procedure Adjust (
      Object               : in out Element_Type);

   overriding
   procedure Finalize  (
      Object               : in out Limited_Element_Type);

   overriding
   procedure Finalize  (
      Object               : in out Element_Type);

   type Limited_Element_Type
                        is abstract new Ada.Finalization.Limited_Controlled with record
      Key                  : Key_Access;
   end record;

   type Element_Type       is abstract new Ada.Finalization.Controlled with record
      Allocated            : Boolean := False;
      Key                  : Key_Access;
   end record;

end Ada_Lib.Maps.Element;

