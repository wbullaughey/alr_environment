with Ada_Lib.Trace;
with GNAT.Source_Info;

package Ada_Lib.Options.Verification is

   package Verification_Package is

      type Verification_Options_Type is abstract
            limited new Abstract_Runtime_Options_Type with private;

      type Verification_Options_Access        is access all Verification_Options_Type;
      type Verification_Options_Class_Access  is access all Verification_Options_Type'class;
      type Verification_Options_Constant_Class_Access
                                 is access constant Verification_Options_Type'class;

      overriding
      procedure Bad_Option (        -- raises Failed exception
         Options                    : in     Verification_Options_Type;
         What                       : in     Character;
         Message                    : in     String := "";
         Where                      : in     String := Ada_Lib.Trace.Here);

      overriding
      procedure Bad_Option (        -- raises Failed exception
         Options                    : in     Verification_Options_Type;
         What                       : in     String;
         Message                    : in     String := "";
         Where                      : in     String := Ada_Lib.Trace.Here);

      overriding
      procedure Bad_Option (        -- raises Failed exception
         Options                    : in     Verification_Options_Type;
         Option                     : in     Flag_Option_Type'class;
         Message                    : in     String := "";
         Where                      : in     String := Ada_Lib.Trace.Here);

      overriding
      procedure Bad_Trace_Option (  -- raises Failed exception
         Options                    : in     Verification_Options_Type;
         Trace_Option               : in     Character;
         What                       : in     Character;
         Modifier          : in     Character := Ada.Characters.Latin_1.Nul;
         Message                    : in     String := "";
         Where                      : in     String := Ada_Lib.Trace.Here);

      procedure Display_Help (            -- common for all programs that use GNOGA_Options
                                 -- prints full help, aborts program
        Options                     : in     Verification_Options_Type;  -- only used for dispatch
        Message                     : in     String := "";   -- leave blank no error help
        Halt                        : in     Boolean := True);

      function Has_Trace (
        Options                     : in     Verification_Options_Type
      ) return Boolean;

      overriding
      function Initialize (
         Options                 : in out Verification_Options_Type;
         From                    : in     String := Standard.Ada_Lib.Trace.Here
      ) return Boolean
      with Pre    => not Options.Verify_Step (Initialized),
           Post   => Options.Verify_Step (Initialized);

      overriding
      procedure Post_Process (      -- final post process
        Options                    : in out Verification_Options_Type
      ) with Pre  => not Options.Verify_Step (Post_Processed),
             Post => Options.Verify_Step (Post_Processed);

--    overriding
--    function Post_Process_Completed (      -- final post process
--      Options                    : in out Verification_Options_Type
--    ) return Boolean;

      overriding
      function Process (     -- processes whole command line calling Process_Option for each option
        Options                     : in out Verification_Options_Type;
        Include_Options             : in     Boolean;
        Include_Non_Options         : in     Boolean;
        Option_Prefix               : in     Character := '-';
        Modifiers                   : in     String := ""
      ) return Boolean;

      overriding
      function Process_Argument (  -- process one argument
         Options                  : in out Verification_Options_Type;
         Iterator                 : in out Command_Line_Iterator_Interface'class;
         Argument                 : in     String
      ) return Boolean;

      overriding
      procedure Trace_Parse (
         Options                    : in out Verification_Options_Type;
         Iterator                   : in out Command_Line_Iterator_Interface'class);

      overriding
      procedure Update_Filter (
         Options                    : in out Verification_Options_Type);

--    overriding
--    function Verify_Initialized (
--       Options                 : in     Verification_Options_Type;
--       From                    : in     String := GNAT.Source_Info.Source_Location
--    ) return Boolean;
--
--    overriding
--    function Verify_Preinitialize (
--       Options                 : in     Verification_Options_Type;
--       From                    : in     String := GNAT.Source_Info.Source_Location
--    ) return Boolean;

      overriding
      function Verify_Step (
         Options  : in     Verification_Options_Type;
         Step     : in     Initialization_Step_Type;
         From     : in     String := GNAT.Source_Info.Source_Location;
         Who      : in     String := GNAT.Source_Info.Enclosing_Entity
      ) return Boolean;

      function Was_Initialized (
         Options                 : in     Verification_Options_Type
      ) return Boolean;

   private

      type Steps_Array  is array (Initialization_Step_Type) of Boolean;

      type Verification_Options_Type is abstract
            limited new Abstract_Runtime_Options_Type with record
         Trace_Options  : Boolean := True; -- False; for testing
         Steps          : Steps_Array := (others => False);
      end record;

   end Verification_Package;

   type Verification_Nested_Options_Type is abstract limited new
         Verification_Package.Verification_Options_Type with null record;

   type Verification_Nested_Options_Access
         is access all Verification_Nested_Options_Type;
   type Verification_Nested_Options_Class_Access
         is access all Verification_Nested_Options_Type'class;
   type Verification_Nested_Options_Constant_Class_Access
         is access constant Verification_Nested_Options_Type'class;

   function Get_Ada_Lib_Modifiable_Nested_Options (
      From                       : in  String := Options_Here
   ) return Verification_Nested_Options_Class_Access
   with Pre    => Have_Ada_Lib_Verification_Options;

   function Get_Ada_Lib_Read_Only_Nested_Options (
      From                       : in  String := Options_Here
   ) return Verification_Nested_Options_Constant_Class_Access
   with pre => Have_Ada_Lib_Verification_Options;

   type Verification_Program_Options_Type is abstract limited new
         Verification_Package.Verification_Options_Type with private;

   type Verification_Program_Options_Access
         is access all Verification_Program_Options_Type;
   type Verification_Program_Options_Class_Access
         is access all Verification_Program_Options_Type'class;
   type Verification_Program_Options_Constant_Class_Access
         is access constant Verification_Program_Options_Type'class;

   procedure Display_Help (
     Options   : in     Verification_Program_Options_Type;
     Message   : in     String := "";   -- leave blank no error help
     Halt      : in     Boolean := True);

   function Get_Ada_Lib_Modifiable_Program_Options (
      From                       : in  String := Options_Here
   ) return Verification_Program_Options_Class_Access
   with Pre    => Have_Ada_Lib_Verification_Options;

   function Get_Ada_Lib_Read_Only_Program_Options (
      From                       : in  String := Options_Here
   ) return Verification_Program_Options_Constant_Class_Access
   with pre => Have_Ada_Lib_Verification_Options;

   function Have_Ada_Lib_Verification_Options
   return Boolean;

   function Have_Ada_Lib_Nested_Verification_Options
   return Boolean;

   overriding
   function Initialize (
     Options                     : in out Verification_Program_Options_Type;
     From                        : in     String := Ada_Lib.Trace.Here
   ) return Boolean
   with Pre    => not Options.Verify_Step (Initialized),
        Post   => Options.Verify_Step (Initialized);

-- overriding
-- function Process (     -- processes whole command line calling Process_Option for each option
--   Options                     : in out Verification_Program_Options_Type;
--   Include_Options             : in     Boolean;
--   Include_Non_Options         : in     Boolean;
--   Option_Prefix               : in     Character := '-';
--   Modifiers                   : in     String := ""
-- ) return Boolean;

-- overriding
-- function Process_Option (  -- process one option
--    Options                    : in out Verification_Program_Options_Type;
--    Iterator                   : in out Command_Line_Iterator_Interface'class;
--    Option                     : in     Flag_Option_Type'class
-- ) return Boolean
-- with pre => Options.Verify_Step (Initialized);

-- overriding
-- procedure Program_Help (
--    Options                    : in      Verification_Program_Options_Type;
--    Help_Mode                  : in      Help_Mode_Type);

   procedure Set_Ada_Lib_Program_Options (
      Options        : in     Verification_Program_Options_Class_Access;
      Nested_Options : in     Verification_Nested_Options_Class_Access
   ) with Pre  => Options /= Null and then
                  not Have_Ada_Lib_Verification_Options,
          Post => Have_Ada_Lib_Verification_Options;

private

   type Verification_Program_Options_Type is abstract limited new
         Verification_Package.Verification_Options_Type with record
      Verification_Nested_Options
         : Verification_Nested_Options_Class_Access := Null;
   end record;

end Ada_Lib.Options.Verification;

