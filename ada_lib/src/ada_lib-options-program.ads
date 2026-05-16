--with Ada_Lib.Options.Library;
with Ada_Lib.Options.Verification;
with Ada_Lib.Trace;
--with GNAT.Source_Info;
with Gnoga_Ada_Lib;

-- options for both main program and test case
package Ada_Lib.Options.Program is

   type Nested_Program_Options_Type
         is limited new Verification.Verification_Nested_Options_Type with record
      GNOGA_Ada_Lib_Option
                        : aliased Gnoga_Ada_Lib.GNOGA_Ada_Lib_Options_Type;
      Help_Test         : Boolean := False;  -- used to test help options
      In_Help           : Boolean := False;
      Nested_Processed  : Boolean := False;
      Test_Driver       : Boolean := False;
      Verbose           : Boolean := False;
   end record;

   type Nested_Program_Options_Access  is access all Nested_Program_Options_Type;
   type Nested_Program_Options_Class_Access
                                 is access all Nested_Program_Options_Type'class;
   type Nested_Program_Options_Constant_Class_Access
                                 is access constant Nested_Program_Options_Type'class;

   overriding
   procedure Display_Help (            -- common for all programs that use GNOGA_Options
                              -- prints full help, aborts program
     Options                     : in     Nested_Program_Options_Type;  -- only used for dispatch
     Message                     : in     String := "";   -- leave blank no error help
     Halt                        : in     Boolean := True);

   function Get_Read_Only_GNOGA_Ada_Lib_Option (
      From                       : in     String := Options_Here
   ) return Gnoga_Ada_Lib.GNOGA_Ada_Lib_Options_Constant_Class_Access
   with pre => Verification.Have_Ada_Lib_Verification_Options;

   overriding
   function Image (
     Options                     : in     Nested_Program_Options_Type
   ) return String;

   overriding
   function Initialize (
     Options                     : in out Nested_Program_Options_Type;
     From                        : in     String := Standard.Ada_Lib.Trace.Here
   ) return Boolean
   with pre    => not Options.Verify_Step (Initialized),
        post   => Options.Verify_Step (Initialized);

   function Process (     -- processes whole command line calling Process_Option for each option
     Options                     : in out Nested_Program_Options_Type;
     Include_Options             : in     Boolean;
     Include_Non_Options         : in     Boolean;
     Option_Prefix               : in     Character := '-';
     Modifiers                   : in     String := ""
   ) return Boolean;

   overriding
   function Process_Option (  -- process one option
      Options                    : in out Nested_Program_Options_Type;
      Iterator                   : in out Command_Line_Iterator_Interface'class;
      Option                     : in     Flag_Option_Type'class
   ) return Boolean
   with pre => Options.Verify_Step (Initialized);
-- with Pre => not Verification.Have_Ada_Lib_Verification_Options;

   overriding
   procedure Program_Help (      -- common for all programs that use GNOGA_Options
      Options                    : in      Nested_Program_Options_Type;  -- only used for dispatch
      Help_Mode                  : in      Help_Mode_Type);

   overriding
   procedure Trace_Parse (
      Options                    : in out Nested_Program_Options_Type;
      Iterator                   : in out Command_Line_Iterator_Interface'class);

-- overriding
-- function Verify_Step (
--    Options  : in     Nested_Program_Options_Type;
--    Step     : in     Initialization_Step_Type;
--    From     : in     String := GNAT.Source_Info.Source_Location
-- ) return Boolean;

-- overriding
-- function Verify_Initialized (
--    Options                    : in     Nested_Program_Options_Type;
--    From                       : in     String := GNAT.Source_Info.Source_Location
-- ) return Boolean;
--
-- overriding
-- function Verify_Preinitialize (
--    Options                    : in     Nested_Program_Options_Type;
--    From                       : in     String := GNAT.Source_Info.Source_Location
-- ) return Boolean;
--
-- function Verify_Postprocess (
--    Options                    : in     Nested_Program_Options_Type;
--    From                       : in     String := GNAT.Source_Info.Source_Location
-- ) return Boolean;
--
-- function Verify_Preprocess (
--    Options                    : in     Nested_Program_Options_Type;
--    From                       : in     String := GNAT.Source_Info.Source_Location
-- ) return Boolean;

   type Program_Options_Type
         is abstract limited new
            Verification.Verification_Program_Options_Type with private;

   type Program_Options_Access  is access all Program_Options_Type;
   type Program_Options_Class_Access
                                 is access all Program_Options_Type'class;
   type Program_Options_Constant_Class_Access
                                 is access constant Program_Options_Type'class;

-- function Verify_Postprocess (
--    Options                    : in     Program_Options_Type;
--    From                       : in     String := GNAT.Source_Info.Source_Location
-- ) return Boolean;
--
-- function Verify_Preprocess (
--    Options                    : in     Program_Options_Type;
--    From                       : in     String := GNAT.Source_Info.Source_Location
-- ) return Boolean;

-- overriding
-- function Verify_Step (
--    Options  : in     Program_Options_Type;
--    Step     : in     Initialization_Step_Type;
--    From     : in     String := GNAT.Source_Info.Source_Location
-- ) return Boolean;

   overriding
   procedure Display_Help (   -- common for all programs that use GNOGA_Options
                              -- prints full help, aborts program
     Options   : in     Program_Options_Type;  -- only used for dispatch
     Message   : in     String := "";   -- leave blank no error help
     Halt      : in     Boolean := True);

   function Get_Modifiable_Program_Options (
      From                       : in  String := Options_Here
   ) return Program_Options_Class_Access
   with pre => Verification.Have_Ada_Lib_Verification_Options;

   function Get_Modifiable_Nested_Program_Options (
      From                       : in     String := Options_Here
   ) return Nested_Program_Options_Class_Access
   with Pre => Verification.Have_Ada_Lib_Verification_Options;

   function Get_Read_Only_Nested_Program_Options (
      Options  : in     Program_Options_Type
   ) return Nested_Program_Options_Constant_Class_Access
   with Pre    => Verification.Have_Ada_Lib_Nested_Verification_Options;

   function Get_Read_Only_Program_Options (
      From                       : in  String := Options_Here
   ) return Program_Options_Constant_Class_Access
   with pre => Verification.Have_Ada_Lib_Verification_Options;

   function Get_Read_Only_Nested_Program_Options (
      From                       : in     String := Options_Here
   ) return Nested_Program_Options_Constant_Class_Access
   with Pre => Verification.Have_Ada_Lib_Verification_Options;

   function Have_Nested_Program_Options (
      Options  : in     Program_Options_Type
   ) return Boolean;

   overriding
   function Image (
     Options                     : in     Program_Options_Type
   ) return String;

   overriding
   function Initialize (
     Options                     : in out Program_Options_Type;
     From                        : in     String := Standard.Ada_Lib.Trace.Here
   ) return Boolean
   with pre    => Verification.Have_Ada_Lib_Verification_Options and then
                  Verification.Have_Ada_Lib_Nested_Verification_Options and then
                  not Options.Verify_Step (Initialized),
        post   => Options.Verify_Step (Initialized);

   function Is_Program_Processed (
     Options                     : in out Program_Options_Type
   ) return Boolean;

   -- needs to be overrident by type used to allocate options object
   function Process (
     Options                     : in out Program_Options_Type;
     Include_Options             : in     Boolean;
     Include_Non_Options         : in     Boolean;
     Option_Prefix               : in     Character := '-';
     Modifiers                   : in     String := ""
   ) return Boolean
   with Pre    => not Options.Verify_Step (Processed),
        Post   => Options.Verify_Step (Processed);

   function Process (     -- process command line options
     Options                  : in out Program_Options_Type;
     Iterator                 : in out Command_Line_Iterator_Interface'class
   ) return Boolean;

--   overriding
--   function Process_Option (  -- process one option
--      Options                    : in out Program_Options_Type;
--      Iterator                   : in out Command_Line_Iterator_Interface'class;
--      Option                     : in     Flag_Option_Type
--   ) return Boolean
--   with pre => Options.Verify_Step (Initialized);
---- with Pre => not Verification.Have_Ada_Lib_Verification_Options;

-- overriding
-- procedure Program_Help (      -- common for all programs that use GNOGA_Options
--    Options                    : in      Program_Options_Type;  -- only used for dispatch
--    Help_Mode                  : in      Help_Mode_Type
-- ) with Pre => Verification.Have_Ada_Lib_Nested_Verification_Options;

-- procedure Set_Nested_Program_Options (
--    Options                 : in out Program_Options_Type;
--    Nested_Program_Options  : Nested_Program_Options_Class_Access
-- ) with Pre     => Nested_Program_Options /= Null and then
--                   not Verification.Have_Ada_Lib_Nested_Verification_Options,
--        Post    => Verification.Have_Ada_Lib_Nested_Verification_Options;

-- overriding
   procedure Trace_Parse (
      Options                    : in out Program_Options_Type;
      Iterator                   : in out Command_Line_Iterator_Interface'class);

   function Has_Camera
   return Boolean
   with Pre    => Verification.Have_Ada_Lib_Verification_Options;

private

   type Program_Options_Type
         is abstract limited new Verification.Verification_Program_Options_Type with record
      Program_Processed : Boolean := False;
   end record;

end Ada_Lib.Options.Program;
