with Ada.Exceptions;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;

package body Ada_Lib.GenList is

   ---------------------------------------------------------------------
   -- Support for dynamic strings
   ---------------------------------------------------------------------

    subtype Dynamic_String_Type is Ada_Lib.Strings.Unlimited.String_Type;

-- function Coerce (
--    Source               : in   String
-- ) return Ada_Lib.Strings.Unlimited.String_Type
-- renames Ada_Lib.Strings.Unlimited.To_Unbounded_String;

-- function Coerce (
--    Source               : in   Ada_Lib.Strings.Unlimited.String_Type
-- ) return String
-- renames Ada_Lib.Strings.Unlimited.To_String;
--
-- procedure Append (
--    Source               : in out Ada_Lib.Strings.Unlimited.String_Type;
--    New_Item          : in   String)
-- renames  Ada_Lib.Strings.Unlimited.Append;

   ------------------------------------------------------------------------
   procedure Add
      (List             : in  out List_Type;
       Item             : in      Datum_Type)
   ------------------------------------------------------------------------
   is
   begin
        if List.Length = Natural (Range_Type'Last) then
         Ada.Exceptions.Raise_Exception (Out_Of_Bounds'Identity,
                                 "Item Add oveflowed");
      end if;

      if List.Length = 0 then
         List.Length := Natural (Range_Type'First);
      else
         List.Length := List.Length + 1;
      end if;
        List.Elements (Range_Type (List.Length)) := Item;
   end Add;

   ------------------------------------------------------------------------
   procedure Add
      (List             : in  out List_Type;
       Item_List           : in      List_Type)
   ------------------------------------------------------------------------
   is
   begin
        if List.Length = Natural (Range_Type'Last) or else
         (List.Length + Item_List.Length) > Natural (Range_Type'Last)
      then
         Ada.Exceptions.Raise_Exception (Out_Of_Bounds'Identity,
                                 "List Add oveflowed");
      end if;

      if List.Length = 0 then
         List.Length := Item_List.Length;
         List.Elements := Item_List.Elements;
      elsif Item_List.Length = 0 then
         null;
      else
         for Index in Range_Type'Range loop
            Add (List, Item_List.Elements (Index));
            exit when Natural (Index) = Item_List.Length;
         end loop;
      end if;
   end Add;

   ------------------------------------------------------------------------
   function Contains
      (List             : in      List_Type;
       Item             : in      Datum_Type)
      return boolean
   ------------------------------------------------------------------------
   is
      Found                : Boolean := False;
   begin
      for Index in Range_Type'First..Last_Index(List) loop
         if Equal (List.Elements (Index), Item) then
            Found := True;
            exit;
         end if;
      end loop;

      return Found;

   end Contains;

   ------------------------------------------------------------------------
   function Get
      (List             : in      List_Type;
       Index               : in      Range_Type)
      return Datum_Type
   ------------------------------------------------------------------------
   is
   begin
      if List.Length = 0 then
         Ada.Exceptions.Raise_Exception (Out_Of_Bounds'Identity,
                                 "Attempted Get of element" &
                                 Index'Img &
                                 " from an empty list");
      end if;

      if Natural(Index) > List.Length then
         Ada.Exceptions.Raise_Exception (Out_Of_Bounds'Identity,
                                 "Attempted Get of element" &
                                 Index'Img &
                                 ", first =" & Range_Type'First'Img &
                                 ", last =" & List.Length'Img);
      end if;

      return List.Elements (Index);
   end Get;

   ------------------------------------------------------------------------
   function Format
      (List             : in      List_Type)
      return String
   ------------------------------------------------------------------------
   is
      Buffer               : Dynamic_String_Type;
   begin
      if List.Length = 0 then
         return "";
      end if;

      for Index in Range_Type'First..Range_Type(List.Length) loop
         if Index > Range_Type'First then
            Buffer.Append (", ");
         end if;
         Buffer.Append (Image (List.Elements (Index)));
      end loop;

      return Buffer.Coerce;
   end Format;

   ------------------------------------------------------------------------
   function Index_Of
      (List             : in      List_Type;
       Item             : in      Datum_Type)
      return Range_Type
   ------------------------------------------------------------------------
   is
   begin

      for Index in Range_Type'First..Last_Index(List) loop
         if Equal (List.Elements (Index), Item) then
            return Index;
         end if;
      end loop;

      Ada.Exceptions.Raise_Exception (Out_Of_Bounds'Identity,
                                 "Index_Of: item not found");
   end Index_Of;

   ------------------------------------------------------------------------
   procedure Insert
      (List             : in  out List_Type;
       Item             : in      Datum_Type)
   ------------------------------------------------------------------------
   is
   begin
        if List.Length = Natural (Range_Type'Last) then
         Ada.Exceptions.Raise_Exception (Out_Of_Bounds'Identity,
                                 "Item Insert overflowed");
      end if;

      if List.Length = 0 then
         List.Length := Natural (Range_Type'First);
         List.Elements (Range_Type (List.Length)) := Item;
      else
         declare
            Found       : Boolean := False;
            Position    : Range_Type;
         begin
            for Index in Range_Type'First..Last_Index(List) loop
               if Greater (List.Elements (Index), Item) then
                  Found := True;
                  Position := Index;
                  exit;
               end if;
            end loop;
            if Found then
               for Index in reverse Position..Last_Index(List) loop
                  List.Elements (Index + 1) := List.Elements (Index);
               end loop;
               List.Elements (Position) := Item;
               List.Length := List.Length + 1;
            else
               Add (List, Item);
            end if;
         end;
      end if;
   end Insert;

   ------------------------------------------------------------------------
   function JSON
      (List             : in      List_Type)
      return String
   ------------------------------------------------------------------------
   is
      Buffer               : Dynamic_String_Type;
   begin
      if List.Length = 0 then
         return "[]";
      end if;

      Buffer.Append ("[");
      for Index in Range_Type'First..Range_Type(List.Length) loop
         if Index > Range_Type'First then
            Buffer.Append (",");
         end if;
         Buffer.Append (JSON (List.Elements (Index)));
      end loop;
      Buffer.Append ("]");

      return Buffer.Coerce;
   end JSON;

   ------------------------------------------------------------------------
   function Last_Index
      (List             : in      List_Type)
      return Range_Type
   ------------------------------------------------------------------------
   is
   begin
      if List.Length = 0 then
         return Range_Type'First;
      else
         return Range_Type (List.Length);
      end if;
   end Last_Index;

   ------------------------------------------------------------------------
   function Length
      (List             : in      List_Type)
      return Natural
   ------------------------------------------------------------------------
   is
   begin
      return List.Length - Natural (Range_Type'First) + 1;
   end Length;

   ------------------------------------------------------------------------
   procedure Remove
      (List             : in  out List_Type;
       Index               : in      Range_Type)
   ------------------------------------------------------------------------
   is
   begin
      if List.Length = 0 then
         Ada.Exceptions.Raise_Exception (Out_Of_Bounds'Identity,
                                 "Attempted Remove of element" &
                                 Index'Img &
                                 " from an empty list");
      end if;
      if Natural(Index) > List.Length then
         Ada.Exceptions.Raise_Exception (Out_Of_Bounds'Identity,
                                 "Attempted Remove of element" &
                                 Index'Img &
                                 ", first =" & Range_Type'First'Img &
                                 ", last =" & List.Length'Img);
      end if;

      if List.Length = Natural (Range_Type'First) then
         Reset (List);
      else
         for Idx in Index..Range_Type(List.Length - 1) loop
            List.Elements (Idx) := List.Elements (Idx + 1);
         end loop;
      end if;
   end Remove;

   ------------------------------------------------------------------------
   procedure Reset
      (List             : in  out List_Type)
   ------------------------------------------------------------------------
   is
   begin
      List.Length := 0;
   end Reset;

   ------------------------------------------------------------------------
   function Sort
      (List             : in      List_Type)
      return List_Type
   ------------------------------------------------------------------------
   is
      New_List : List_Type;
   begin
      for Index in Range_Type'First .. Last_Index (List) loop
         Insert (New_List, List.Elements (Index));
      end loop;

      return New_List;
   end Sort;

end Ada_Lib.GenList;
