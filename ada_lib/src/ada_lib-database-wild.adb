with Ada_Lib.Options;
with Ada_Lib.Trace; use Ada_Lib.Trace;

package body Ada_Lib.Database.Wild is

   Timeout  : constant Duration := 0.5;
   Trace    : Boolean renames Options.Ada_Lib_Database.Wild_Trace;

   -------------------------------------------------------------------
   function Wild_Get (
      Database                   : in out Database_Type'class;
      Pattern                    : in   String
   ) return Response_Type is
   -------------------------------------------------------------------

      Response                   : Response_Type;

   begin
      Log_Here ("pattern", Pattern);

      Post (Database, Pattern);

      loop
         declare
            Line                 : constant String := Database.Get (Timeout);

         begin
            Log (Trace, Here, Who & " line '" & Line & "'");

            if Line'length = 0 then
               Log (Trace, Here, Who & " end of wild list");
               exit;
            end if;

            declare
               Name_Value        : constant Name_Value_Type := Parse (Line);

            begin
               Log (Trace, Here, Who & " add " & Name_Value.To_String);
               Response.Append (Name_Value);

            end;
         end;
      end loop;

      return Response;
   end Wild_Get;

   -------------------------------------------------------------------
   function Count (
      Response          : in   Response_Type
   ) return Natural is
   -------------------------------------------------------------------

   begin
      return Natural (Response.Length);
   end Count;

   -------------------------------------------------------------------
   function Index (
      Response          : in   Response_Type;
      Index             : in   Positive
   ) return Cursor_Type is
   -------------------------------------------------------------------

      Count             : Natural := 1;
      Cursor            : Cursor_Type := Response.First;

   begin
      loop
         if not Response_Package.Has_Element (Cursor) then
            raise Not_Found with "no element at" & Index'img;
         end if;

         if Count = Index then
            Log (Trace, Here, Who & Count'img & " " & Response_Package.Element (Cursor).To_String);
            return Cursor;
         end if;

         Cursor := Response_Package.Next (Cursor);
         Count := Count + 1;
      end loop;
   end Index;

   -------------------------------------------------------------------
   function Name (
      Response          : in   Response_Type;
      Positition           : in   Positive
   ) return String is
   -------------------------------------------------------------------

   begin
      return Response_Package.Element (Index (Response, Positition)).Name.Coerce;
   end Name;

   -------------------------------------------------------------------
   function Value (
      Response          : in   Response_Type;
      Positition           : in   Positive
   ) return String is
   -------------------------------------------------------------------

   begin
      return Response_Package.Element (Index (Response, Positition)).Value.Coerce;
   end Value;

end Ada_Lib.Database.Wild;