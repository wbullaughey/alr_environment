with Ada_Lib.Database.Connection;
--with Ada_Lib.Help;
with Ada_Lib.Options.Database;
with Ada_Lib.GNOGA.Unit_Test.Options;
with Ada_Lib.Options.Program;
with Ada_Lib.Options.Template;
with Ada_Lib.Options.Unit_Test;
--with Ada_Lib.Options.Verification;
with Ada_Lib.Trace.Options;
with Ada_Lib.Unit_Test.Test_Cases;
with AUnit.Test_Suites;
--with Gnoga_Ada_Lib;

-- options for unit tests of Ada_Lib
package Ada_Lib.Options.AUnit_Lib is

   type DBDamon_Test_Suite       is new Standard.AUnit.Test_Suites.Test_Suite
                                    with null record;

   type DBDamon_Test_Access      is access DBDamon_Test_Suite;

   function New_Suite return DBDamon_Test_Access;

   type Non_DBDamon_Test_Suite   is new Standard.AUnit.Test_Suites.Test_Suite with null record;

   type Non_DBDamon_Test_Access  is access Non_DBDamon_Test_Suite;

   function Has_Database return Boolean;

   function New_Suite return Non_DBDamon_Test_Access;

   -- type used in application for unit testing;


   type Options_Selection_Type   is (
      Unit_Test_With_Template_Only,
      Unit_Test_With_Database_And_Template,
      Unit_Test_With_No_Database_Or_Template,
      Unit_Test_With_Database_Only);

   type Aunit_Program_Options_Type (
      Multi_Test           : Boolean; -- perform multiple tests in one
                                            -- execution of test program
      Options_Selection    : Options_Selection_Type
                              ) is new Program.Program_Options_Type with record
      Ada_Lib_Trace_Options:Ada_Lib.Trace.Options.Ada_Lib_Trace_Options_Type;
      Database             : Ada_Lib.Database.Connection.
                              Abstract_Database_Class_Access := Null;
      GNOGA_Unit_Test_Options
                           : Ada_Lib.GNOGA.Unit_Test.Options.
                              GNOGA_Unit_Test_Options_Type;
      Nested_Unit_Test_Options
                           : aliased Unit_Test.
                              Ada_Lib_Unit_Test_Nested_Options_Type (
                                 Multi_Test => True);
      case Options_Selection is

         when Unit_Test_With_Template_Only =>
            Template_Only  : Ada_Lib.Options.Template.Template_Options_Type;

         when Unit_Test_With_Database_And_Template =>
            Database_Options
                           : Ada_Lib.Options.Database.Database_Options_Type;
            Template       : Ada_Lib.Options.Template.Template_Options_Type;

         when Unit_Test_With_No_Database_Or_Template =>
            null;

         when Unit_Test_With_Database_Only =>
            Database_Only  : Ada_Lib.Options.Database.Database_Options_Type;

      end case;
   end record;

   type Aunit_Program_Options_Class_Access
                                 is access all Aunit_Program_Options_Type'class;
   type Aunit_Program_Options_Constant_Class_Access
                                 is access constant Aunit_Program_Options_Type'class;

   Failure                       : exception;

   overriding
   procedure Display_Help (
                              -- prints full help, aborts program
     Options   : in     Aunit_Program_Options_Type;  -- only used for dispatch
     Parameters: in     Ada_Lib.Options.Argument_Array;
     Message   : in     String := "";   -- leave blank no error help
     Halt      : in     Boolean := True);

   function Get_Modifiable_AUnit_Options (
      From                       : in  String := Ada_Lib.Trace.Here
   ) return Aunit_Program_Options_Class_Access;
-- with pre => Ada_Lib.Options.Have_Options;

   function Get_Read_Only_AUnit_Options (
      From                       : in  String := Ada_Lib.Trace.Here
   ) return Aunit_Program_Options_Constant_Class_Access;
-- with pre => Ada_Lib.Options.Have_Options;

   function Get_Read_Only_Nested_Unit_Test_Options (
      From                       : in  String := Ada_Lib.Trace.Here
   ) return Unit_Test.Ada_Lib_Unit_Test_Nested_Options_Constant_Class_Access;

-- function Image (
--   Options                     : in     Aunit_Program_Options_Type
-- ) return String;

   overriding
   function Initialize (
     Options                     : in out Aunit_Program_Options_Type;
     From                        : in     String := Standard.Ada_Lib.Trace.Here
   ) return Boolean
   with pre    => not Options.Verify_Step (Initialized),
        Post   => Options.Verify_Step (Initialized);

   overriding
   function Process (     -- process command line options
     Options                  : in out Aunit_Program_Options_Type;
     Iterator                 : in out Command_Line_Iterator_Interface'class
   ) return Boolean;

private

   overriding
   procedure Program_Help (
      Options                    : in     Aunit_Program_Options_Type;  -- only used for dispatch
      Help_Mode                  : in     Help_Mode_Type);

   overriding
   function Process_Option (
      Options                    : in out Aunit_Program_Options_Type;
      Iterator                   : in out Ada_Lib.Options.Command_Line_Iterator_Interface'class;
      Option                     : in     Flag_Option_Type'class
   ) return Boolean
   with pre => Options.Verify_Step (Initialized);

   procedure Register_Tests (
      Options                    : in     Aunit_Program_Options_Type;
      Suite_Name                 : in     String;
      Test                       : in out Ada_Lib.Unit_Test.Test_Cases.
                                             Test_Case_Type'class);
   overriding
   procedure Trace_Parse (
      Options     : in out Aunit_Program_Options_Type;
      Iterator    : in out Ada_Lib.Options.
                              Command_Line_Iterator_Interface'class);

end Ada_Lib.Options.AUnit_Lib;
