with Ada_Lib.Strings;

package Ada_Lib.Specifications is

   type Specification_Type       is tagged record
      Option                     : Character;
      Prompt                     : Ada_Lib.Strings.String_Constant_Access;
   end record;

   function Get_Option (
      Specification              : in     Specification_Type
   ) return Character;

   function Get_Prompt (
      Specification              : in     Specification_Type
   ) return Ada_Lib.Strings.String_Constant_Access;

   generic
      type Priority_Type               is ( <> );
      type Selection_Type           is ( <> );

   package Selection_Package is

      type Specification_Level_Type
                                 is new Specification_Type with record
         Priority                   : Priority_Type;
      end record;

      type Specification_Array   is array (Selection_Type) of
                                   Specification_Level_Type;
      function Get_Level (
         Specification           : in     Specification_Level_Type
      ) return Priority_Type;

   end Selection_Package;

   generic     -- body commented out so parameters not referenced

      type Priority_Type            is ( <> );
      type Selection_Type        is ( <> );
      type Specification_Type    is tagged private;
--    type Specifications_Array  is array (Selection_Type) of Specification_Type;

--    Specifications             : in Specifications_Array;
   pragma Unreferenced (Selection_Type, Specification_Type);

   package Specification_Package is

      Invalid                 : exception;

      procedure Help;

      function Test (
         Which                   : in   String;
         Priority                : in   Priority_Type := Priority_Type'first
      ) return Boolean;

      procedure Set (
         Which                   : in   String;
         Priority                : in   Priority_Type := Priority_Type'first);

      procedure Set (
         Options              : in   String);

   end Specification_Package;

end Ada_Lib.Specifications;
