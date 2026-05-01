with Ada.Exceptions;
with Ada.Unchecked_Deallocation;
--with Ada_Lib.Trace;
with Ada_Lib.Trace;use Ada_Lib.Trace;
--with Ada_Lib.Trace_Traces;

package body Ada_Lib.Maps.Table is

-- use type Selection_Type;

   type Element_Type_Access      is access all Element_Type;

   procedure Free is new Ada.Unchecked_Deallocation (
      Name  => Element_Type_Access,
      Object   => Element_Type);

   ---------------------------------------------------------------------------
   procedure Add (
      Table             : in out Map_Type;
      Key                  : in   String;
      Initializer          : in   Initializer_Type;
      New_Element          :   out Element_Access) is
   ---------------------------------------------------------------------------

   begin
      New_Element := Allocator (Initializer);

      New_Element.Set_Key (Key);
      Table_Package.Insert (Table.Map, New_Element.Key, New_Element);

      if Test ("Containers", Low) then
         Log_Here ("" & Key);
      end if;
   end Add;

   ---------------------------------------------------------------------------
   procedure Delete (
      Table             : in out Map_Type;
      Key                  : in   String) is
   ---------------------------------------------------------------------------

      Local_Name           : aliased String := Key;
      Cursor               : Table_Package.Cursor :=
                           Table_Package.Find (Table.Map, Local_Name'Unchecked_Access);
      Element              : Element_Access := Table_Package.Element (Cursor);

   begin
      Table_Package.Delete (Table.Map, Cursor);
      Free (Element_Type_Access (Element));
      if Test ("Containers", Low) then
         Log_Here ("delete " & Key);
      end if;
   end Delete;

   ---------------------------------------------------------------------------
   function "=" (
      Left, Right          : in   Element_Access
   ) return Boolean is
   ---------------------------------------------------------------------------

   begin
      return Left."="(Right.all);
   end "=";

   ---------------------------------------------------------------------------
   function Element (
      Cursor               : in   Cursor_Type
   ) return Element_Access is
   ---------------------------------------------------------------------------

   begin
      return Table_Package.Element (Cursor.Cursor);
   end Element;

   ---------------------------------------------------------------------------
   function Exists (
      Cursor               : in   Cursor_Type
   ) return Boolean is
   ---------------------------------------------------------------------------

   begin
      return Table_Package.Has_Element (Cursor.Cursor);
   end Exists;

   ---------------------------------------------------------------------------
   function Find (
      Table             : in   Map_Type;
      Key                  : in   String
   ) return Cursor_Type'class is
   ---------------------------------------------------------------------------

      Local_Key            : aliased String := Key;

   begin
      return Cursor_Type'(Cursor => Table_Package.Find (Table.Map, Local_Key'unchecked_access));
   end Find;

   ---------------------------------------------------------------------------
   function Get (
      Table             : in   Map_Type;
      Key                  : in   String
   ) return Element_Access is
   ---------------------------------------------------------------------------

      Local_Name           : aliased String := Key;

   begin
      if Test ("Containers", High) then
         Log_Here ("'" & Local_Name & "'");
      end if;

      return Table_Package.Element (Table.Map, Local_Name'Unchecked_Access);

   exception
      when Fault: Constraint_Error =>
         Trace_Message_Exception (Fault, "'" & Key & "' for " & Name);
         Ada.Exceptions.Raise_Exception (Not_Found'identity,
                Ada.Exceptions.Exception_Message(Fault) & " Key '" & Key & "' not found for " & Name);

      when Fault: others =>
         Trace_Message_Exception (Fault, "'" & Key &"' for " & Name);
         Ada.Exceptions.Raise_Exception (Ada.Exceptions.Exception_Identity (Fault),
                Ada.Exceptions.Exception_Message(Fault) & " Key '" & Key & "' for " & Name);
   end get;

   ---------------------------------------------------------------------------
   function Get (
      Cursor               : in   Cursor_Type
   ) return Element_Access is
   ---------------------------------------------------------------------------

   begin
      return Table_Package.Element (Cursor.Cursor);
   end Get;

   ---------------------------------------------------------------------------
   function Is_In (
      Table             : in   Map_Type;
      Key               : in   String
   ) return Boolean is
   ---------------------------------------------------------------------------

      Local_Name           : aliased String := Key;
      Result               : constant Boolean := Table_Package.Contains (Table.Map,
                           Local_Name'Unchecked_Access);

   begin
      if Test ("Containers", High) then
         Log_Here ("'" & Local_Name & "' result " & Result'img);
      end if;

      return Result;
   end Is_In;

   ---------------------------------------------------------------------------
   procedure Iterate (
      Table                : in   Map_Type;
      Callback             : in   Callback_Access) is
   ---------------------------------------------------------------------------

      procedure Local_Callback (
         Cursor            : Table_Package.Cursor) is

      begin
         Callback (Cursor_Type'(Cursor => Cursor));
      end Local_Callback;

   begin
      Table_Package.Iterate (Table.Map, Local_Callback'access);
   end Iterate;

   ---------------------------------------------------------------------------
   function Length (
      Table             : in   Map_Type
   ) return Natural is
   ---------------------------------------------------------------------------

   begin
      return Natural (Table_Package.Length (Table.Map));
   end Length;

end Ada_Lib.Maps.Table;
