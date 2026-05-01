with Ada.Containers.Hashed_Maps;
with Ada.Finalization;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada.Text_IO;
-- with Ada_Lib.Strings;

-- package map using a string as a key
package Ada_Lib.Strings.Map is

--  type Cursor_Type is tagged private;

   Failed                        : Exception;

   type Abstract_Element_Type is abstract new Ada.Finalization.Limited_Controlled with private;

    type Abstract_Iterator_Parameter_Type  is tagged null record;

    subtype String_Type          is Ada_Lib.Strings.Unlimited.String_Type;

--  function Coerce (
--    Source                     : in     String
--  ) return String_Type renames Ada_Lib.Strings.Unlimited.To_Unbounded_String;
--
--  function Coerce (
--    Source                     : in     String_Type
--  ) return String renames Ada_Lib.Strings.Unlimited.To_String;

    function Get_Key (
        Element        : in      Abstract_Element_Type
    ) return String;

--  function Length (
--      Source                     : in     String_Type
--  ) return Natural renames Ada_Lib.Strings.Unlimited.Length;

   subtype Key_Type                 is Ada_Lib.Strings.String_Access_All;

   function Hash (
      Key                     : in     Key_Type
   ) return Ada.Containers.Hash_Type;

   procedure Iterator_Callback (
      Element                    : in out Abstract_Element_Type;
      Parameter                  : in out Abstract_Iterator_Parameter_Type'class;
      Stop                       :    out Boolean);

   function Key_Equal (
      Left                    : in     Key_Type;
      Right                   : in     Key_Type
   ) return Boolean;

    procedure Store_Element (
        Element                 : in     Abstract_Element_Type;
        File                    : in out Ada.Text_IO.File_Type);

   generic
      type Element_Type (<>) is abstract new Abstract_Element_Type with private;

   package Generic_Map is

       Failure                      : exception;
       Not_Found                    : exception;

      type Element_Class_Access     is access all Element_Type'class;

      package Map_Package is new Ada.Containers.Hashed_Maps (
         Hash           => Hash,
         Equivalent_Keys=> Key_Equal,
         Key_Type       => Key_Type,
         Element_Type   => Element_Class_Access);

      subtype Element_Reference     is Map_Package.Constant_Reference_Type;
      subtype Cursor_Type           is Map_Package.Cursor;
--    subtype Iterator_Type         is Map_Package.Map_Iterator_Interfaces.Forward_Iterator;
      subtype Map_Type              is Map_Package.Map;
      type Map_Access               is access all Map_Type;

      type Iterator_Parameter_Type  is new Abstract_Iterator_Parameter_Type with record
         Map                        : Map_Access := Null;
      end record;

      procedure Add (
         Map                        : in out Map_Type;
         Name                       : in     String;
         Element                    : in     Element_Class_Access);

--    function Element (
--       Cursor                     : in     Cursor_Type
--    ) return Abstract_Element_Type renames Map_Package.Element;

      function Find (
         Map                        : in     Map_Type;
         Key                        : in     String
      ) return Element_Class_Access;

      function Has_Element (
         Cursor                     : in     Cursor_Type
      ) return Boolean renames Map_Package.Has_Element;

      function Has_Element (
         Map                        : in     Map_Type;
         Key                        : in     String
      ) return Boolean;

      function Next (
         Cursor                     : in     Cursor_Type
      ) return Cursor_Type renames Map_Package.Next;

--    procedure Query_Element (
--          Position                    : in    Cursor_Type;
--          Process                     : not null access procedure (
--              Element                 : in    Element_Class_Access));

      procedure Iterate (
         Map                        : in out Map_Type;
         Parameter                  : in out Iterator_Parameter_Type'class);

--       Process                    : not null access procedure (
--          Position                : in     Cursor));
--
--    function Iterate (
--       Container                  : in     Map_Type
--    ) return Map_Package.Map_Iterator_Interfaces.Forward_Iterator'Class renames Map_Package.Iterate;

   end Generic_Map;

   Ada_Lib_Lib_Debug           : aliased Boolean := False;

private

    type Abstract_Element_Type is new Ada.Finalization.Limited_Controlled with record
        Key                        : Key_Type;
    end record;

--  type Abstract_Iterator_Parameter_Type  is tagged null record;

   overriding
    procedure Finalize (
     Element        : in out Abstract_Element_Type);

end Ada_Lib.Strings.Map;


