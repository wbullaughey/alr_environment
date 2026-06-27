--with Ada_Lib.Options.Flags;
with Ada_Lib.Options.Program;
with Ada_Lib.Options.Verification;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace;
with AUnit.Test_Filters.Ada_Lib;
--with GNOGA_Options;

-- provides options for all unit testing
package Ada_Lib.Options.Unit_Test is

   Failed                        : exception;

   Maximum_Random_Generators     : constant := 5;
   type Random_Generator_Number_Type
                                 is new Natural range 0 ..
                                    Maximum_Random_Generators;
   subtype Random_Generator_Index_Type
                                 is Random_Generator_Number_Type range 1 ..
                                    Maximum_Random_Generators;
   type Random_Seed_Mode_Type   is (Default_Seed, Random_Seed,
                                    Seed_Not_Set, Specified_Seed);

   type Random_Seeds_Type        is array (Random_Generator_Index_Type) of
                                    Integer;

   type Suites_Type              is (Database_Server, Textbelt);

   type Suite_Set_Type           is array (Suites_Type) of Boolean;

   Default_Random_Seed           : constant := 0;

   -- base type for all unit test programs which -- include ada_lib
   type Ada_Lib_Unit_Test_Nested_Options_Type (
      Multi_Test        : Boolean -- perform multiple tests in one
                                      -- execution of test program
                           ) is new Program.
                              Nested_Program_Options_Type with record
      Debug             : Boolean := False;  -- debug unit test application
      Debug_Options     : Boolean := False;  -- debug unit test options
      Exit_On_Done      : Boolean := False;  -- exit test application after
                                             -- all unit tests complete
      Filter            : aliased Standard.AUnit.Test_Filters.Ada_lib.
                           Ada_Lib_Filter;
      Have_Camera       : Boolean := True;
      Mode              : Mode_Type := Run_Tests;  -- run unit tests
      Manual            : Boolean := False;  -- GUI interactions must be
                                             -- performed manually
      Number_Random_Generators
                        : Random_Generator_Number_Type := 0;
      Random_Seeds      : Random_Seeds_Type := (others => Default_Random_Seed);
      Random_Seed_Count : Random_Generator_Number_Type := 0;
      Random_Seed_Mode  : Random_Seed_Mode_Type := Seed_Not_Set;
      Report_Random     : Boolean := False;
      Routine           : Ada_Lib.Strings.Unlimited.String_Type;
      Short_Test        : Boolean := False;
      Suite_Name        : Ada_Lib.Strings.Unlimited.String_Type;
      Suite_Set         : Suite_Set_Type := (others => False);
   end record;

   type Ada_Lib_Unit_Test_Nested_Options_Access
            is access all Ada_Lib_Unit_Test_Nested_Options_Type;
   type Ada_Lib_Unit_Test_Nested_Options_Class_Access
            is access all Ada_Lib_Unit_Test_Nested_Options_Type'class;
   type Ada_Lib_Unit_Test_Nested_Options_Constant_Class_Access
            is access constant Ada_Lib_Unit_Test_Nested_Options_Type'class;

   -- call this for unit tests that cannot run multiple tests at one time
   procedure Check_Test_Suite_And_Routine (
      Options                    : in     Ada_Lib_Unit_Test_Nested_Options_Type);

   function Get_Modifiable_Ada_Lib_Unit_Test_Nested_Options (
      From                       : in  String := Options_Here
   ) return Ada_Lib_Unit_Test_Nested_Options_Class_Access
   with pre => Verification.Have_Ada_Lib_Verification_Options;

   function Get_Readonly_Ada_Lib_Unit_Test_Nested_Options (
      From                       : in  String := Options_Here
   ) return Ada_Lib_Unit_Test_Nested_Options_Constant_Class_Access
   with pre => Verification.Have_Ada_Lib_Verification_Options;

   overriding
   function Image (
     Options                     : in     Ada_Lib_Unit_Test_Nested_Options_Type
   ) return String;

   overriding
   function Initialize (
     Options                     : in out Ada_Lib_Unit_Test_Nested_Options_Type;
     From                        : in     String := Standard.Ada_Lib.Trace.Here
   ) return Boolean
   with pre    => not Options.Verify_Step (Initialized),
        Post   => Options.Verify_Step (Initialized);

   overriding
   procedure Post_Process (      -- final initialization
     Options                    : in out Ada_Lib_Unit_Test_Nested_Options_Type);

   overriding
   function Process_Option (  -- process one option
     Options                     : in out Ada_Lib_Unit_Test_Nested_Options_Type;
     Iterator                    : in out Ada_Lib.Options.Command_Line_Iterator_Interface'class;
      Option                     : in     Ada_Lib.Options.Flag_Option_Type'class
   ) return Boolean
   with pre => Options.Verify_Step (Initialized);

   overriding
   procedure Update_Filter (
      Options                    : in out Ada_Lib_Unit_Test_Nested_Options_Type);

-- function Have_Unit_Test_Options
-- return Boolean;

   procedure Routine_Action (
      Suite                      : in     String;
      Routine                    : in     String;
      Mode                       : in     Mode_Type);

-- procedure Set_Ada_Lib_Unit_Test_Options (
--    Options     : in     Ada_Lib_Unit_Test_Nested_Options_Class_Access
-- ) with Pre => Options /= Null and then
--               not Verification.Have_Ada_Lib_Verification_Options;

   procedure Suite_Action (
      Suite                      : in     String;
      First                      : in out Boolean;
      Mode                       : in     Mode_Type);

   package Ada_Lib_Ask_Tests is
      Debug                         : Boolean := False;
   end Ada_Lib_Ask_Tests;

   package Ada_Lib_Aunit is
      Debug                      : Boolean := False;
      Tester_Debug               : Boolean := False;  -- maine test program
   end Ada_Lib_Aunit;

   package Ada_Lib_Database_Unit_Test is
      Debug                         : Boolean := False;
      Get_Put_Debug                 : Boolean := False;
      Server_Tests_Trace            : Boolean := False;
      Subscribe_Debug               : Boolean := False;
   end Ada_Lib_Database_Unit_Test;

   package Ada_Lib_Event_Unit_Test is
      Debug                         : Boolean := False;
   end Ada_Lib_Event_Unit_Test;

   package Ada_Lib_GNOGA_Unit_Test is
      Base_Debug                    : Boolean := False;
      Event_Debug                   : Boolean := False;
      GNOGA_Debug                   : Boolean := False;
      Test_Debug                    : Boolean := False;
   end Ada_Lib_GNOGA_Unit_Test;

   package Ada_Lib_Help_Unit_Test is
      Debug                         : Boolean := False;
   end Ada_Lib_Help_Unit_Test;

   package Ada_Lib_ICON_Unit_Test is
      Debug                         : Boolean := False;
   end Ada_Lib_ICON_Unit_Test;

   package Ada_Lib_Lock_Unit_Test is
      Debug                         : Boolean := False;
   end Ada_Lib_Lock_Unit_Test;

   package Ada_Lib_Options_Unit_Test is
      Client_Debug                  : Boolean := False;
      Debug                         : Boolean := False;
   end Ada_Lib_Options_Unit_Test;

   package Ada_Lib_Options_Trace_Tests is
      Debug_Detail                  : Boolean := False;
      Debug_Test                    : Boolean := False;
      Debug_All_Tests               : Boolean := False;
   end Ada_Lib_Options_Trace_Tests;

   package Ada_Lib_Strings is
      Debug_Maps                    : Boolean := False;
   end Ada_Lib_Strings;

   package Ada_Lib_Test_States is
      Debug                         : Boolean := False;
   end Ada_Lib_Test_States;

   package Ada_Lib_Textbelt_Unit_Test is
      Debug                         : Boolean := False;
   end Ada_Lib_Textbelt_Unit_Test;

   package Ada_Lib_Unit_Test is
      Debug                         : Boolean := False;
      Fixtures_Debug                : Boolean := False;
      Parser_Debug                  : Boolean := False;
      Reporter_Debug                : Boolean := False;
      Tests_Debug                   : Boolean := False;
   end Ada_Lib_Unit_Test;

   package Ada_Lib_Unit_Test_Test_Cases is
      Debug                         : Boolean := False;
   end Ada_Lib_Unit_Test_Test_Cases;

   package AUnit_Ada_Lib is
      AUnit_Debug                   : Boolean := False;
   end AUnit_Ada_Lib;


private

   overriding
   procedure Program_Help (
      Options                    : in     Ada_Lib_Unit_Test_Nested_Options_Type;  -- only used for dispatch
      Help_Mode                  : in     Ada_Lib.Options.Help_Mode_Type);

   overriding
   procedure Trace_Parse (
      Options              : in out Ada_Lib_Unit_Test_Nested_Options_Type;
      Iterator             : in out Ada_Lib.Options.
                                       Command_Line_Iterator_Interface'class);

end Ada_Lib.Options.Unit_Test;
