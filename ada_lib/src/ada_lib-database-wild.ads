with Ada.Containers.Doubly_Linked_Lists;

package Ada_Lib.Database.Wild is

   Failed                        : exception;
   Not_Found                     : exception;

   package Response_Package is new Ada.Containers.Doubly_Linked_Lists (
      Name_Value_Type, "=");

   type Response_Type            is new Response_Package.List with null record;

   type Response_Access is access Response_Package.List;

   subtype Cursor_Type is Response_Package.Cursor;


   function Wild_Get (
      Database                   : in out Database_Type'class;
      Pattern                    : in   String
   ) return Response_Type;

   function Count (
      Response                   : in   Response_Type
   ) return Natural;

   function Name (
      Response                   : in   Response_Type;
      Positition                 : in   Positive
   ) return String;

   function Value (
      Response                   : in   Response_Type;
      Positition                 : in   Positive
   ) return String;

end Ada_Lib.Database.Wild;