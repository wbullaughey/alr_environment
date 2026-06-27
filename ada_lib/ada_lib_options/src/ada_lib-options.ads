with Ada.Characters.Latin_1;
with Ada_Lib.Strings.Unlimited;
with GNAT.Source_Info;
with Interfaces;

package Ada_Lib.Options is

   Failed                        : exception;

   function Options_Here
   return String renames GNAT.Source_Info.Source_Location;

   function Options_Who
   return String renames GNAT.Source_Info.Enclosing_Entity;

   type Help_Mode_Type           is (Program_Mode, Trace_Mode);

   type Initialization_Step_Type is (  -- must be in sequentual order
      Initialized, Processed, Post_Processed);

   type Mode_Type                is (Driver_Suites, List_Suites, Print_Suites,
                                       Run_Tests);

   type Argument_Array   is array (Positive range <>) of
                           Ada_Lib.Strings.Unlimited.String_Type;

   type Argument_Array_Access
                        is access Argument_Array;

   type Argument_Array_Constant_Access
                        is access constant Argument_Array;

   type Flag_Option_Kind_Type    is (Nil_Option, Plain, Modified);
   type SubFlag_Option_Kind_Type is (Plain, Modified);


   Not_Flag_Option               : constant Character :=
                                    Ada.Characters.Latin_1.NUL;
   Unmodified_Flag               : constant Character :=
                                    Ada.Characters.Latin_1.NUL;

   type Flag_Option_Type;
-- type Flag_Option_Access  is access all Flag_Option_Type;
   type Flag_Option_Class_Access
                                 is access all Flag_Option_Type;
   function Initialize (
     Option       : in     Character;
     Modifier     : in     Character;
     Who          : in     String := Options_Who;
     From         : in     String := Options_Here
   ) return Flag_Option_Type;

   type Flag_List_Type           is tagged private;
-- type Flag_List_Access   is access Flag_List_Type;

   function "&" (
      Left, Right                : in        Flag_List_Type
   ) return Flag_List_Type
   with Pre    => Left.Has_Options and then
                  Right.Has_Options;

   function Has_Options (
      Flags                   : in        Flag_List_Type
   ) return Boolean;

   function Image (
      Flags                   : in        Flag_List_Type
   ) return String
   with Pre    => Flags.Has_Options;

   procedure Initialize (
      Flags       :    out Flag_List_Type;
      Option      : in     Character;
      Modifier    : in     Character;
      Who         : in     String := Options_Who;
      From        : in     String := Options_Here);

   function Initialize (
      Options     : in     Character;
      Modifier    : in     Character;
      Who         : in     String := Options_Who;
      From        : in     String := Options_Here
   ) return Flag_List_Type;

   procedure Initialize (
      Flags       :    out Flag_List_Type;
      Options     : in     String;
      Modifier    : in     Character;
      Who         : in     String := Options_Who;
      From        : in     String := Options_Here);

   function Initialize (
      Options     : in     String;
      Modifier    : in     Character;
      Who         : in     String := Options_Who;
      From        : in     String := Options_Here
   ) return Flag_List_Type;

   procedure Iterate (
      Flags                      : in     Flag_List_Type;
      Callback                   : access procedure (
         Option                  : in     Flag_Option_Type))
   with Pre    => Flags.Has_Options;

   function Length (
      Flags                      : in     Flag_List_Type
   ) return Natural
   with Pre    => Flags.Has_Options;

   function Option (
      Flags                      : in     Flag_List_Type;
      Index                      : in     Natural
   ) return Character
   with Pre    => Flags.Has_Options;

   function Modifier (
      Flags                      : in     Flag_List_Type;
      Index                      : in     Natural
   ) return Character
   with Pre    => Flags.Has_Options;

   type Flag_Option_Type    is tagged record
     Kind                   : Flag_Option_Kind_Type := Nil_Option;
     Modifier               : Character := Unmodified_flag;
     Option                 : Character;
   end record;

   function Has_Option (   -- tests if option is registered for a catagory
      Option                     : in     Flag_Option_Type;
      Options_With_Parameters    : in     Flag_List_Type'class;
      Options_Without_Parameters : in     Flag_List_Type'class;
      Who                        : in     String := Options_Who;
      From                       : in     String := Options_Here
   ) return Boolean;

   function Image (
     Option                     : in     Flag_Option_Type;
     Quote                      : in     Boolean := True;
     Kind                       : in     Boolean := True
   ) return String;

   function Less (
     Left, Right                : in     Flag_Option_Type
   ) return Boolean;

   function Modified (
     Option                     : in     Flag_Option_Type
   ) return Boolean;

   function Modifier (
     Option                     : in     Flag_Option_Type
   ) return Character;

   type Command_Line_Iterator_Interface
                                is interface;

   procedure Advance (
     Iterator          : in out Command_Line_Iterator_Interface) is abstract;

   function At_End (
     Iterator          : in   Command_Line_Iterator_Interface
   ) return Boolean is abstract;

   procedure Dump_Iterator (
     Iterator                : in     Command_Line_Iterator_Interface;
     What                    : in     String;
     Where                   : in     String := Options_Here
   ) is abstract;

   function Get_Argument (
     Iterator                : in     Command_Line_Iterator_Interface
   ) return String is abstract;

   function Get_Argument (
     Iterator                : in     Command_Line_Iterator_Interface;
     Index                   : in     Positive
   ) return String is abstract;

   function Get_Option (
     Iterator          : in   Command_Line_Iterator_Interface
   ) return Flag_Option_Type'class is abstract;

   -- parameter of an option
   function Get_Parameter (
     Iterator          : in out Command_Line_Iterator_Interface
   ) return String is abstract;

   -- numeric parameter of an option
   -- raise Invalid_Number
   function Get_Integer (
     Iterator          : in out Command_Line_Iterator_Interface
   ) return Integer  is abstract;

   -- numeric parameter of an option
   -- raise Invalid_Number
   function Get_Float (
     Iterator          : in out Command_Line_Iterator_Interface
   ) return float is abstract;

   -- numeric parameter of an option
   -- raise Invalid_Number
   function Get_Unsigned (
     Iterator          : in out Command_Line_Iterator_Interface;
     Base              : in   Positive := 16
   ) return Interfaces.Unsigned_64 is abstract;


   function Is_Option (
     Iterator                : in   Command_Line_Iterator_Interface
   ) return Boolean is abstract;

   type Abstract_Runtime_Options_Type
                     is limited interface;

   type Abstract_Runtime_Options_Class_Access
                     is access all Abstract_Runtime_Options_Type'class;
   type Abstract_Runtime_Options_Constant_Class_Access
                     is access constant Abstract_Runtime_Options_Type'class;

   procedure Bad_Option (        -- raises Failed exception
      Options                    : in     Abstract_Runtime_Options_Type;
      What                       : in     Character;
      Message                    : in     String := "";
      Where                      : in     String := Options_Here) is abstract;

   procedure Bad_Option (        -- raises Failed exception
      Options                    : in     Abstract_Runtime_Options_Type;
      What                       : in     String;
      Message                    : in     String := "";
      Where                      : in     String := Options_Here) is abstract;

   procedure Bad_Option (        -- raises Failed exception
      Options                    : in     Abstract_Runtime_Options_Type;
      Option                     : in     Flag_Option_Type'class;
      Message                    : in     String := "";
      Where                      : in     String := Options_Here) is abstract;

   procedure Bad_Trace_Option (  -- raises Failed exception
      Options                    : in     Abstract_Runtime_Options_Type;
      Trace_Option               : in     Character;
      What                       : in     Character;
      Modifier          : in     Character := Ada.Characters.Latin_1.Nul;
      Message                    : in     String := "";
      Where                      : in     String := Options_Here) is abstract;

   procedure Display_Help (            -- common for all programs that use GNOGA_Options
                              -- prints full help, aborts program
     Options                     : in     Abstract_Runtime_Options_Type;  -- only used for dispatch
     Parameters                  : in     Argument_Array;
     Message                     : in     String := "";   -- leave blank no error help
     Halt                        : in     Boolean := True) is abstract;

   function Image (
     Options                     : in     Abstract_Runtime_Options_Type
   ) return String is abstract;

   -- direct decendent should return true
   -- indirect decentdent should return initialize of parent
   function Initialize (
     Options                     : in out Abstract_Runtime_Options_Type;
     From                        : in     String := Options_Here
   ) return Boolean is abstract;

   procedure Post_Process (      -- final initialization
     Options      : in out Abstract_Runtime_Options_Type) is abstract;

-- function Post_Process_Completed (      -- final post process
--   Options                    : in out Abstract_Runtime_Options_Type
-- ) return Boolean is abstract;

   function Process (     -- processes whole command line calling Process_Option for each option
     Options                     : in out Abstract_Runtime_Options_Type;
     Include_Options             : in     Boolean;
     Include_Non_Options         : in     Boolean;
     Option_Prefix               : in     Character := '-';
     Modifiers                   : in     String := ""
   ) return Boolean is abstract;

   function Process_Argument (  -- process one argument
     Options                     : in out Abstract_Runtime_Options_Type;
     Iterator                    : in out Command_Line_Iterator_Interface'class;
     Argument                    : in     String
   ) return Boolean is abstract;

   function Process_Option (  -- process one option
     Options                     : in out Abstract_Runtime_Options_Type;
     Iterator                    : in out Command_Line_Iterator_Interface'class;
     Option                      : in     Flag_Option_Type'class
   ) return Boolean is abstract;

   procedure Program_Help (      -- common for all programs that use GNOGA_Options
     Options                     : in     Abstract_Runtime_Options_Type;  -- only used for dispatch
     Help_Mode                   : in     Help_Mode_Type) is abstract;

   procedure Trace_Parse (
      Options                    : in out Abstract_Runtime_Options_Type;
      Iterator                   : in out Command_Line_Iterator_Interface'class
   ) is abstract;

   procedure Update_Filter (
      Options                    : in out Abstract_Runtime_Options_Type) is abstract;

-- function Verify_Initialized (
--    Options                    : in     Abstract_Runtime_Options_Type;
--    From                       : in     String := Options_Here
-- ) return Boolean is abstract;
--
-- function Verify_Preinitialize (
--    Options           : in     Abstract_Runtime_Options_Type;
--    From              : in     String := Options_Here
-- ) return Boolean is abstract;

   function Verify_Step (
      Options  : in     Abstract_Runtime_Options_Type;
      Step     : in     Initialization_Step_Type;
      From     : in     String := Options_Here;
      Who      : in     String := GNAT.Source_Info.Enclosing_Entity
   ) return Boolean is abstract;

   procedure Option_Log (
      Enable            : in     Boolean := True;
      Message           : in     String := "";
      Who               : in     String := Options_Who;
      Where             : in     String := Options_Here);

   function Option_Log (
      Result            : in     Boolean;
      Enable            : in     Boolean := True;
      Message           : in     String := "";
      Who               : in     String := Options_Who;
      Where             : in     String := Options_Here
   ) return Boolean;

   -- raises assert
   procedure Options_Not_Implemented (
      Why               : in     String := "";
      Who               : in     String := Options_Who;
      Here              : in     String := Options_Here);

  procedure Parsing_Failed;
  function Parsing_Failed return Boolean;

   Null_Flag_List                   : constant Flag_List_Type;

   package Ada_Lib_Command_Line_Iterator is
      Debug                      : Boolean := False;
      Tests_Debug                : Boolean := False;
   end Ada_Lib_Command_Line_Iterator;

   package Ada_Lib_Configuration is
      Trace                      : Boolean := False;
   end Ada_Lib_Configuration;

   package Ada_Lib_Database is
      Connection_Debug           : Boolean := False;
      Debug_Subscribe            : Boolean := False;
      Event_Trace                : Boolean := False;
      Server_Trace               : Boolean := False;
      Server_Trace_All           : Boolean := False;
      Trace                      : Boolean := False;
      Trace_All                  : Boolean := False;
      Trace_Get_Post             : Boolean := False;
      Updater_Trace              : Boolean := False;
      Wild_Trace                 : Boolean := False;
   end Ada_Lib_Database;

   package Ada_Lib_Directory is
      Debug                      : Boolean := False;
   end Ada_Lib_Directory;

   package Ada_Lib_EMail is
      Debug                      : Boolean := False;
   end Ada_Lib_EMail;

   package Ada_Lib_Event is
      Debug                      : Boolean := False;
   end Ada_Lib_Event;

   package Ada_Lib_Environment is

      Debug                      : Boolean := False;
      Help_Test                  : Boolean := False;
      Unit_Testing               : constant Boolean := False;
--    := Ada_Lib_Environment.
--                         Parse_Environment_Variable (
--                            Ada_Lib_Environment.Unit_Test_Kind);

   end Ada_Lib_Environment;

   package Ada_Lib_GNOGA is  -- options for the Ada_Lib GNOGA library
      Ada_Lib_Debug              : aliased Boolean := False;   -- Ada_Lib.GNOGA
      Debug                      : aliased Boolean := False;
      Base_Debug                 : aliased Boolean := False;
   end Ada_Lib_GNOGA;

   package Ada_Lib_Help is
      Debug                      : Boolean := False;
   end Ada_Lib_Help;

   package Ada_Lib_ICON is
      Debug                      : Boolean := False;
   end Ada_Lib_ICON;

   package Ada_Lib_Interrupt is
      Debug                      : Boolean := False;
   end Ada_Lib_Interrupt;

   package Ada_Lib_Lock is
      Debug                      : Boolean := False;
   end Ada_Lib_Lock;

   package Ada_Lib_Mail is
      Debug                      : Boolean := False;
   end Ada_Lib_Mail;

   package Ada_Lib_Options is -- switch to using this for all 1/18/26
      Debug                         : Boolean := False;
      Debug_All                     : constant Boolean := False;
      Debug_Options                 : constant Boolean := False;
      Hex_Debug                     : Boolean := False;
      Specifications_Debug          : Boolean := False;
      Strings_Debug                 : Boolean := False;
      Use_Options_Prefix            : constant Boolean := True;
   end Ada_Lib_Options;

   package Ada_Lib_Options_Flags is
      Debug                         : Boolean := False;
   end Ada_Lib_Options_Flags;

   package Ada_Lib_Options_Program is
      Debug                         : Boolean := False;
   end Ada_Lib_Options_Program;

   package Ada_Lib_Options_Runstring is
      Debug                         : Boolean := False;
   end Ada_Lib_Options_Runstring;

   package Ada_Lib_Options_Template is
      Debug                         : Boolean := False;
   end Ada_Lib_Options_Template;

   package Ada_Lib_Options_Verification is
      Debug                         : Boolean := False;
   end Ada_Lib_Options_Verification;

   package Ada_Lib_OS is
      Trace                         : Boolean := False;
      Run_Debug                     : Boolean := False;
   end Ada_Lib_OS;

   package Ada_Lib_Parser is
      Debug                      : Boolean := False;
   end Ada_Lib_Parser;

   package Ada_Lib_Socket_IO is
      Trace                         : Boolean := False;
      Trace_IO                      : Boolean := False;
      Tracing                       : Boolean := False;
   end Ada_Lib_Socket_IO;

   package Ada_Lib_Strings is
      Debug                         : Boolean := False;
   end Ada_Lib_Strings;

   package Ada_Lib_Template is
      Trace_Compile                 : Boolean := False;
      Trace_Evaluate                : Boolean := False;
      Trace_Expand                  : Boolean := False;
      Trace_Load                    : Boolean := False;
   end Ada_Lib_Template;

   package Ada_Lib_Text is
      Debug                         : Boolean := False;
   end Ada_Lib_Text;

   package Ada_Lib_Timer is
      Debug                         : Boolean := False;
   end Ada_Lib_Timer;

   package Ada_Lib_Trace_Tasks is
      Debug                         : Boolean := False;
   end Ada_Lib_Trace_Tasks;

   package Aunit is
      Debug                      : Boolean := False;
   end Aunit;

   package GNOGA is  -- options for the GNOGA Library
      Debug        : aliased Boolean := False; -- GNOGA_Ada_Lib.Base
      Library_Debug     : aliased Boolean := False; -- GNOGA library
      Options_Debug     : aliased Boolean := False; -- GNOGA Options
      Server_Debug      : aliased Boolean := False; -- GNOGA server
   end GNOGA;

   package ICON is
      Debug             : Boolean := False;
   end ICON;

   package Trace is
      Include_Hundreds              : Boolean := False;
      Include_Task                  : Boolean := False;
      Include_Time                  : Boolean := False;
      Inhibit_Trace                 : Boolean := False;
   end TRace;

   Null_Flag_Option              : constant Flag_Option_Type;

private

   type Options_Array       is array (Positive range <>) of
                                    Flag_Option_Type;

   type Options_Array_Access     is access all Options_Array;

   type Flag_List_Type           is tagged record
      Options                    : Options_Array_Access;
   end record;

   Null_Flag_List             : constant Flag_List_Type := (
      Options  => new Options_Array (1 .. 0)
   );

   Null_Flag_Option              : constant Flag_Option_Type :=
                                    Flag_Option_Type'(
                                       Kind     => Nil_Option,
                                       Modifier => Unmodified_flag,
                                       Option   => Not_Flag_Option);
end Ada_Lib.Options;
