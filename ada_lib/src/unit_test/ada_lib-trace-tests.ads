with Ada.Containers.Doubly_Linked_Lists;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Unit_Test.Test_Cases;
--with AUnit.Test_Cases;
with AUnit.Test_Suites;

package Ada_Lib.Trace.Tests is

Suite_Name                    : constant String := "Trace";

   type Test_Type                is new Ada_Lib.Unit_Test.Test_Cases.
                                    Test_Case_Type with private;

   overriding
   function Name (
      Test                       : in     Test_Type) return AUnit.Message_String;

   overriding
   procedure Register_Tests (
      Test                       : in out Test_Type);

   overriding
   procedure Set_Up (Test : in out Test_Type)
   with post => Test.Verify_Set_Up;

   function Suite return AUnit.Test_Suites.Access_Test_Suite;

   overriding
   procedure Tear_Down (Test : in out Test_Type)
   with post => Verify_Tear_Down (Test);

private

-- use type Ada_Lib.Strings.Unlimited.String_Type;

   package Output_Package is new Ada.Containers.Doubly_Linked_Lists (
      Element_Type   => Ada_Lib.Strings.Unlimited.String_Type);

   type Test_File_Type           is new File_Type with record
      List                       : Output_Package.List;
   end record;

   type Test_File_Access         is access all Test_File_Type;
   type Test_File_Class_Access   is access Test_File_Type'class;

   overriding
   procedure Flush (
      File                       : in     Test_File_Type);

   overriding
   procedure Output (
      File                       : in out Test_File_Type;
      Data                       : in     String);

   type Test_Type                is new Ada_Lib.Unit_Test.Test_Cases.
                                    Test_Case_Type with record
      Output                     : aliased Test_File_Type;
      Saved_Output_File          : File_Class_Access := Null;
   end record;

end Ada_Lib.Trace.Tests;