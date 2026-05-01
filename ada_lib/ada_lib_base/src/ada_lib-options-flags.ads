--with  Ada.Characters.Latin_1;
--with Ada.Finalization;
--with Ada.Tags;
with Ada_Lib.Trace; -- use Ada_Lib.Trace;
--with GNAT.Source_Info;

package Ada_Lib.Options.Flags is


  type Flag_Option_Type              is new Base_Flag_Option_Type with null record;

  type Flag_Option_Access           is access Flag_Option_Type;
  type Flag_Option_Class_Access     is access Flag_Option_Type'class;

  function Allocate_Option (       -- create a single option
     Option                     : in     Character;
     Modifier                   : in     Character;
     From                       : in     String := Ada_Lib.Trace.Here
  ) return Flag_Option_Access;

   function Allocate_Option (
      Option                     : in     Character;
      Modifier                   : in     Character;
      From                       : in     String := Ada_Lib.Trace.Here
   ) return Flag_Option_Type;

   overriding
   function Has_Option (   -- tests if option is registered for a catagory
      Option                        : in     Flag_Option_Type;
      Options_With_Parameters       : in     Flag_List_Type'class;
      Options_Without_Parameters    : in     Flag_List_Type'class;
      From                          : in     String := Options_Here
   ) return Boolean;

  overriding
  function Image (
     Option                     : in     Flag_Option_Type;
     Quote                      : in     Boolean := True
  ) return String;

  overriding
  function Less (
     Left, Right                : in     Flag_Option_Type
  ) return Boolean;

  overriding
  function Modified (
     Option                     : in     Flag_Option_Type
  ) return Boolean;

  overriding
  function Modifier (
     Option                     : in     Flag_Option_Type
  ) return Character;

   Null_Flag_Option              : constant Flags.Flag_Option_Type :=
                                    Flags.Flag_Option_Type'(
                                       Kind     => Nil_Option,
                                       Modifier => Unmodified_flag,
                                       Option   => Not_Flag_Option);
end Ada_Lib.Options.Flags;
