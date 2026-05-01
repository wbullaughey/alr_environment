with Ada_Lib.Options.Verification;
-- with GNOGA_Options.Database.AUnit;
with AUnit.Test_Suites.Optional;
with Ada_Lib.Unit_Test.Test_Cases;

package Ada_Lib.Database.Unit_Test is

   Failed                        : exception;

-- subtype String_Access         is Ada_Lib.Database.Remote_Instance.String_Access;

   -- options that specify what kind of DBDaemon is configured
-- type Options_Type             is abstract new Ada_Lib.Options.Database.Database_Options_Type with private;
-- type Options_Access           is access all Options_Type;
-- type Options_Class_Access     is access all Options_Type'class;

   type Test_Suite_Type is new AUnit.Test_Suites.Optional.Test_Suite_Type with private;

   -- this test setup spawns a dbdaemon application and terminates it in the tear down
   type Test_Case_Type is abstract new Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type
      with private;

   type Access_Test_Case is access all Test_Case_Type'Class;

-- function Database_Options return Ada_Lib.Database.Remote_Instance.Options_Type'class

   function Get (
      Test                       : in     Test_Case_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      Tag                        : in     String
   ) return String
   with Pre => Has_Database (Test);

   function Get (
      Test                       : in     Test_Case_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      Tag                        : in     String
   ) return Name_Value_Class_Type
   with Pre => Has_Database (Test);

   function Get_Database  (
      Test                       : in     Test_Case_Type
   ) return Database_Class_Access
   with Pre => Has_Database (Test);

-- function Get_Options (
--    Test                       : in     Test_Case_Type
-- ) return GNOGA_Options.Database.AUnit.Aunit_Program_Options_Constant_Class_Access

-- function Has_Database (
--    Options                    : in     Options_Type
-- ) return Boolean;

   function Has_Database (
      Test                       : in     Test_Case_Type
   ) return Boolean;

   function Host_Name (
      Test                       : in     Test_Case_Type
   ) return String;

   function Host_Port (
      Test                       : in     Test_Case_Type
   ) return Ada_Lib.Database.Port_Type;

-- function Manual (
--    Options                    : in     Options_Type
-- ) return Boolean;

   function Options_Set return Boolean renames
      Ada_Lib.Options.Verification.Have_Ada_Lib_Verification_Options;

-- function Pause (
--    Options                    : in     Options_Type
-- ) return Boolean;

   procedure Post (
      Test                       : in     Test_Case_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      Tag                        : in     String;
      Value                      : in     String)
   with Pre => Has_Database (Test);

   -- selects which database and initializes Database in the test
   -- if not No_Host verifies its open
   overriding
   procedure Set_Up (
      Test                       : in out Test_Case_Type)
   with Pre => not Test.Verify_Set_Up,
        Post => Test.Verify_Set_Up;

   procedure Check_Database_Value (
      Test                       : in out Test_Case_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      Tag                        : in     String;
      Value                      : in     String)
   with Pre => Has_Database (Test);

   overriding
   procedure Tear_Down (
      Test                       : in out Test_Case_Type)
   with post => Verify_Tear_Down (Test);

   overriding
   function Test (
      Suite                      : in     Test_Suite_Type
   ) return Boolean;       -- return true if test can be run

-- function Unit_Test_Options (
--    Options                    : in     Options_Type
-- ) return GNOGA_Options.Database.AUnit.Options_Constant_Class_Access;

   function Which_Host (
      Test                       : in     Test_Case_Type
   ) return Which_Host_Type
   with pre => Options_Set;

   Debug                         : aliased Boolean := False;

private
-- type Options_Type             is abstract new Ada_Lib.Options.Database.Database_Options_Type with record
--    Unit_Test_Options          : aliased GNOGA_Options.Database.AUnit.Options_Type;
-- end record;

   type Test_Suite_Type is new AUnit.Test_Suites.Optional.Test_Suite_Type with record
      Database                : Database_Class_Access := Null;
--    Options                 : Ada_Lib.Options.
--                               Unit_Test_Options_Constant_Class_Access := Null;
   end record;

   -- this test setup spawns a dbdaemon application and terminates it in the tear down
   type Test_Case_Type is abstract new Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type with record
      Database                : Database_Class_Access := Null;
--    Options                 : GNOGA_Options.Database.AUnit.Aunit_Program_Options_Constant_Class_Access := Null;
   end record;

end Ada_Lib.Database.Unit_Test;
