with Ada.Strings.Fixed.Hash;
with Ada.Unchecked_Deallocation;
--with Ada_Lib.Trace;
with Ada_Lib.Trace; use Ada_Lib.Trace;
--with Ada_Lib.Trace_Traces; use Ada_Lib.Trace_Traces;

package body Ada_Lib.Maps.Element is

   procedure Free is new Ada.Unchecked_Deallocation (
      Name  => Key_Access,
      Object   => String);

   ---------------------------------------------------------------------------
   overriding
   function "=" (
      Left, Right          : in   Element_Type
   ) return Boolean is
   ---------------------------------------------------------------------------

   begin
      return Equivalent_Keys (Key (Left), Key (Right));
   end "=";

   ---------------------------------------------------------------------------
   function "=" (
      Left, Right          : in   Limited_Element_Type
   ) return Boolean is
   ---------------------------------------------------------------------------

   begin
      return Equivalent_Keys (Key (Left), Key (Right));
   end "=";

   ---------------------------------------------------------------------------
   overriding
   procedure Adjust (
      Object               : in out Element_Type) is
   ---------------------------------------------------------------------------

   begin
      if Object.Key /= Null then
         Object.Key := new String'(Object.Key.all);
         Object.Allocated := True;
      end if;
   end Adjust;

   ---------------------------------------------------------------------------
   function Equivalent_Keys (
      Left, Right          : Key_Type
   ) return Boolean is
   ---------------------------------------------------------------------------

      Result               : constant Boolean := Left.all = Right.all;

   begin
      if Test ("Containers", High) then
         Log_Here (Ada_Lib.Trace.Who & " " &Left.all & " " & Right.all &
            " result " & Result'img);
      end if;

      return Result;
   end Equivalent_Keys;

   ---------------------------------------------------------------------------
   overriding
   procedure Finalize   (
      Object               : in out Element_Type) is
   ---------------------------------------------------------------------------

   begin
      if Object.Key = Null then
         Log_Here ("finalize null key");
      else
         if Test ("Finalization", Low) then
            Log_Here ("finalize " & Object.Key.all);
         end if;

         Free (Object.Key);
         if Test ("Finalization", Low) then
            Log_Here (" exit ");
         end if;
      end if;
--    Object_Type (Object).Finalize;
   end Finalize;

   ---------------------------------------------------------------------------
   overriding
   procedure Finalize   (
      Object               : in out Limited_Element_Type) is
   ---------------------------------------------------------------------------

   begin
      if Object.Key = Null then
         Log_Here ("finalize null key");
      else
         if Test ("Finalization", Low) then
            Log_Here ("finalize " & Object.Key.all);
         end if;

         Free (Object.Key);
         if Test ("Finalization", Low) then
            Log_Here (" exit ");
         end if;
      end if;
--    Object_Type (Object).Finalize;
   end Finalize;

   ---------------------------------------------------------------------------
   function Hash (
      Key               : in   Key_Type
   ) return Ada.Containers.Hash_Type is
   ---------------------------------------------------------------------------

   begin
      return Ada.Strings.Fixed.Hash (Key.all);
   end Hash;

   ---------------------------------------------------------------------------
   function Key (
      Element              : in   Element_Type
   ) return Key_Type is
   ---------------------------------------------------------------------------

   begin
      return Key_Type (Element.Key);
   end Key;

   ---------------------------------------------------------------------------
   function Key (
      Element              : in   Limited_Element_Type
   ) return Key_Type is
   ---------------------------------------------------------------------------

   begin
      return Key_Type (Element.Key);
   end Key;

   ---------------------------------------------------------------------------
   procedure Set_Key (
      Element              : in out Element_Type;
      Key                  : in   String) is
   ---------------------------------------------------------------------------

   begin
      pragma Assert (Element.Key = Null);
      Element.Allocated := True;
      Element.Key := new String'(Key);
   end Set_Key;

   ---------------------------------------------------------------------------
   procedure Set_Key (
      Element              : in out Limited_Element_Type;
      Key                  : in   String) is
   ---------------------------------------------------------------------------

   begin
      pragma Assert (Element.Key = Null);
      Element.Key := new String'(Key);
   end Set_Key;

end Ada_Lib.Maps.Element;

