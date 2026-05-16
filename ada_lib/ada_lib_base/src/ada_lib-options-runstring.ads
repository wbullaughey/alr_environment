with Ada.Containers.Doubly_Linked_Lists;
--with Ada_Lib.Options.Flags;
--with Ada_Lib.Options.Create;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace;

package Ada_Lib.Options.Runstring is

   Duplicate_Options       : exception;
   Failed                  : exception;

   type Kind_Type             is (With_Parameters, Without_Parameters);

   type Registration_Type;
   type Registration_Constant_Access
                              is access constant Registration_Type;

   type Element_Type          is tagged record
      From                    : Ada_Lib.Strings.Unlimited.String_Type;
      Kind                    : Kind_Type;
      Option                  : Flag_Option_Class_Access;
   end record;

   type Element_Access        is access all Element_Type;
   type Element_Constant_Access
                              is access constant Element_Type;

   overriding
   function "=" (
      Left, Right             : in     Element_Type
   ) return Boolean;

   function Image (
      Element                 : in     Element_Type
   ) return String;

   package Registrations_Package is new
                              Ada.Containers.Doubly_Linked_Lists (
      Element_Type   => Element_Type,
      "="            => "=");

   type Registrations_Type is new  Registrations_Package.List with null record;

   subtype Constant_Reference_Type
                           is Registrations_Package.Constant_Reference_Type;

   function Image (
      Registrations        : in     Registrations_Type
   ) return String;

   protected type Registration_Type is

      function All_Options(
         Quote                   : in     Boolean := True
      ) return String;

      function All_Registered(
         Quote                   : in     Boolean := True
      ) return String;

      function Has_Parameter (
         Option                  : in     Flag_Option_Type
      ) return Boolean;

      function Is_Registered (   -- tests if option was registered for the whole program
         Option                  : in     Flag_Option_Type
      ) return Boolean;

      procedure Register (
         Kind                    : in     Kind_Type;
         Options                 : in     Flag_List_Type'class;
         From                    : in     String := Ada_Lib.Trace.Here);

      function Registration (
         Option                  : in     Flag_Option_Type
      ) return String;

      procedure Reset;                 -- clears sets if need different iterator sets

   private
      Registrations              : aliased Registrations_Type;

   end Registration_Type;

-- function Get_Options (
--    Kind                       : in     Kind_Type
-- ) return Registration_Constant_Access;

   Options                       : aliased Registration_Type;

end Ada_Lib.Options.Runstring;
