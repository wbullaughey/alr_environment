--$Header$

with Ada.Characters.Latin_1;
--with Ada.Finalization;
with Ada.Strings.Maps;
with Ada_Lib.Options.Flags;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace;
with Interfaces;

package Ada_Lib.Command_Line_Iterator is

   Failed                  : exception;
   Invalid_Option          : exception;
   Invalid_Quote           : exception;
   Invalid_Number          : exception;
   No_Argument             : exception;
   No_Parameter            : exception;
   No_Selection            : exception;
   Not_Argument            : exception;
   Not_Option              : exception;
   Too_Many_Arguments      : exception;

   subtype Character_Set   is Ada.Strings.Maps.Character_Set;

   type Get_Argument_Access      is access function (
      Index                      : in     Positive
   ) return String;

   type Iterator_State_Type      is (Argument, At_End, Initial, Option,
                                    Option_With_Parameter, Quoted);

   type Iterator_State_Set_Type  is array (Iterator_State_Type) of Boolean;

   Active_States                 : constant Iterator_State_Set_Type := (
                                    Initial                 => False,
                                    At_End                  => False,
                                    others                  => True);
   Option_States                 : constant Iterator_State_Set_Type := (
                                    Option                  => True,
                                    Option_With_Parameter   => True,
                                    others                  => False);

   package Abstract_Package is
      type Abstract_Iterator_Type   is abstract new Ada_Lib.Options.
                                       Command_Line_Iterator_Interface with private;
      type Iterator_Class_Access
                           is access Abstract_Iterator_Type'class;

      -- assumes state left at end of previous Advance or initialized state
      overriding
      procedure Advance (
         Iterator          : in out Abstract_Iterator_Type);

      overriding
      function At_End (
         Iterator          : in   Abstract_Iterator_Type
      ) return Boolean;

      overriding
      procedure Dump_Iterator (
         Iterator                : in     Abstract_Iterator_Type;
         What                    : in     String;
         Where                   : in     String := Ada_Lib.Trace.Here);

      overriding
      function Get_Argument (
         Iterator                : in     Abstract_Iterator_Type
      ) return String
      with Pre => Iterator.Get_State /= At_End;

      overriding
      function Get_Option (
         Iterator          : in   Abstract_Iterator_Type
      ) return Options.Base_Flag_Option_Type'class
      with Pre => Option_States (Iterator.Get_State);

      -- parameter of an option
      overriding
      function Get_Parameter (
         Iterator          : in out Abstract_Iterator_Type
      ) return String
      with Pre => Iterator.Unchecked_Has_Parameter;

      -- numeric parameter of an option
      -- raise Invalid_Number
      overriding
      function Get_Integer (
         Iterator          : in out Abstract_Iterator_Type
      ) return Integer
      with Pre => Iterator.Unchecked_Has_Parameter;

      -- numeric parameter of an option
      -- raise Invalid_Number
      overriding
      function Get_Float (
         Iterator          : in out Abstract_Iterator_Type
      ) return float
      with Pre => Iterator.Unchecked_Has_Parameter;

      -- numeric parameter of an option
      -- raise Invalid_Number
      overriding
      function Get_Unsigned (
         Iterator          : in out Abstract_Iterator_Type;
         Base              : in   Positive := 16
      ) return Interfaces.Unsigned_64
      with Pre => Iterator.Unchecked_Has_Parameter;

      generic
         type Value_Type         is range <>;

      -- numeric parameter of an option
      -- raise Invalid_Number
      function Get_Signed (
         Iterator          : in out Abstract_Iterator_Type
      ) return Value_Type
      with Pre => Iterator.Unchecked_Has_Parameter;

      function Get_State (
         Iterator          : in   Abstract_Iterator_Type
      ) return Iterator_State_Type;

      -- test if option has parameter
      function Has_Parameter (
         Iterator          : in   Abstract_Iterator_Type
      ) return Boolean
      with Pre => (case Iterator.Get_State is
                     when Option | Option_With_Parameter => True,
                     when others => False);

      -- raises No_Selection, Invalid_Option
      procedure Initialize (
         Iterator                : in out Abstract_Iterator_Type;
         Number_Arguments        : in     Natural;
         Include_Options         : in     Boolean;
         Include_Non_Options     : in     Boolean;
         Option_Prefix           : in     Character := '-';
         Modifiers               : in     String := "";
         Skip                    : in     Natural := 0);

      -- raises No_Argument
      overriding
      function Is_Option (
         Iterator                : in   Abstract_Iterator_Type
      ) return Boolean;
--    with Pre => Active_States (Iterator.Get_State);

      function Number_Arguments (
         Iterator                : in   Abstract_Iterator_Type
      ) return Natural;

      -- test if option has parameter
      function Unchecked_Has_Parameter (
         Iterator          : in   Abstract_Iterator_Type
      ) return Boolean;

   private

      No_Modifiers               : constant Character_Set :=
                                    Ada.Strings.Maps.Null_Set;

      type Abstract_Iterator_Type is abstract new Ada_Lib.Options.
                                    Command_Line_Iterator_Interface
                                       with record
         Argument                : Ada_Lib.Strings.Unlimited.String_Type;
         Argument_Count          : Natural;
         Argument_Index          : Natural;
         Character_Index         : Natural;
         Current                 : Character;
         Has_Parameter           : Boolean;
         Include_Non_Options     : Boolean;
         Include_Options         : Boolean;
         Modifiers               : Character_Set;
         Option                  : Ada_Lib.Options.Flags.Flag_Option_Type;
         Option_Prefix           : Character;
         Parameter_Index         : Positive;
         State                   : Iterator_State_Type;
      end record;

      function Internal_Get_Argument (
         Iterator                : in     Abstract_Iterator_Type
      ) return String;

   end Abstract_Package;

   subtype Abstract_Iterator_Class_Access
                                 is Abstract_Package.Iterator_Class_Access;
   package Run_String is

      type Runstring_Iterator_Type
                                 is new Abstract_Package.Abstract_Iterator_Type
                                    with null record;

      -- raises No_Selection, Invalid_Option
      procedure Initialize (
         Iterator                   :    out Runstring_Iterator_Type;
         Include_Options            : in     Boolean;
         Include_Non_Options        : in     Boolean;
         Option_Prefix              : in     Character := '-';
         Modifiers                  : in     String := "";
         Skip                       : in     Natural := 0);

      Overriding
      function Number_Arguments (
         Iterator                : in   Runstring_Iterator_Type
      ) return Natural;

   private
      overriding
      function Get_Argument (
         Iterator                : in     Runstring_Iterator_Type;
         Index                   : in     Positive
      ) return String;

   end Run_String;

   package Internal is

      type Iterator_Type         is new Abstract_Package.Abstract_Iterator_Type
                                    with private;

      -- raises No_Selection, Invalid_Option
      procedure Initialize (
         Iterator                :    out Iterator_Type;
         Source                  : in     String;
         Include_Options         : in     Boolean;
         Include_Non_Options     : in     Boolean;
         Argument_Seperator      : in     Character := ' ';
         Option_Prefix           : in     Character := '-';
         Modifiers               : in     String := "";
         Skip                    : in     Natural := 0;
         Quote                   : in     Character := Ada.Characters.Latin_1.Nul);

   private

      Max_Arguments              : constant := 50;

      type Argument_Type is record
         Start                      : Positive;
         Stop                       : Positive;
      end record;

      type Arguments_Type is array (1 .. Max_Arguments) of Argument_Type;

      type Iterator_Type is new Abstract_Package.Abstract_Iterator_Type with record
         Argument_Seperator         : Character;
         Arguments                  : Arguments_Type;
--       Quote                      : Character;
         Seperator_Set              : Ada.Strings.Maps.Character_Set;
         Source                     : Ada_Lib.Strings.String_Constant_Access;
         Start                      : Positive;
      end record;

      overriding
      procedure Dump_Iterator (
         Iterator                : in     Iterator_Type;
         What                    : in     String;
         Where                   : in     String := Ada_Lib.Trace.Here);

      overriding
      function Get_Argument (
         Iterator                : in     Iterator_Type;
         Index                   : in     Positive
      ) return String;

   end Internal;

   procedure Make;               -- dummy used to force recomplation

   Debug                         : aliased Boolean := False;
   Null_Option                     : Character renames Ada.Characters.Latin_1.NUL;

end Ada_Lib.Command_Line_Iterator;

