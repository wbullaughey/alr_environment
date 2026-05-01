with Ada_Lib.Unit_Test;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Simple_Test_Cases;

package body Ada_Lib.Curl.Tests is

   ---------------------------------------------------------------
   procedure Expand_Template (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

--    Local_Test                 : Test_Type renames Test_Type (Test);

   begin
      Log_Here (Debug);

   exception
      when Fault: others =>
         Trace_Message_Exception (Fault, "error in library");
         Assert (False, "library failed");

   end Expand_Template;

 ---------------------------------------------------------------
   overriding
   function Name (
      Test                       : in     Test_Type) return AUnit.Message_String is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

   begin
      return AUnit.Format (Suite_Name);
   end Name;

   ---------------------------------------------------------------
   overriding
   procedure Register_Tests (
      Test                       : in out Test_Type) is
   ---------------------------------------------------------------

   begin
      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Expand_Template'access,
         Routine_Name   => AUnit.Format ("Expand_Template")));

   end Register_Tests;

-- ---------------------------------------------------------------
-- procedure Set_Up (
--    Test                       : in out Test_Type) is
-- ---------------------------------------------------------------
--
-- begin
--    Log_In (Debug);
--    Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type (Test).Set_Up;
--    Test.Credential.Initialize (Account, Password);
--    Log_Out (Debug);
--
-- exception
--    when Fault: others =>
--       Trace_Exception (Debug, Fault);
--       Assert (False, "exception message " & Ada.Exceptions.Exception_Message (Fault));
--
-- end Set_Up;

   ---------------------------------------------------------------
   function Suite return AUnit.Test_Suites.Access_Test_Suite is
   ---------------------------------------------------------------

      Test_Suite                 : constant AUnit.Test_Suites.Access_Test_Suite :=
                                    new AUnit.Test_Suites.Test_Suite;
      Tests                      : constant Test_Access := new Test_Type;

   begin
      Ada_Lib.Unit_Test.Suite (Suite_Name);  -- used for listing suites
      Test_Suite.Add_Test (AUnit.Simple_Test_Cases.Test_Case_Access (Tests));
      return Test_Suite;
   end Suite;

-- ---------------------------------------------------------------
-- overriding
-- procedure Tear_Down (
--    Test                       : in out Test_Type) is
-- ---------------------------------------------------------------
--
-- begin
--    Log_In (Debug);
--    Test.Credential.Close;
--    Test_Type (Test).Tear_Down;
--    Log_Out (Debug);
-- end Tear_Down;

begin
--Debug := True;
   Log_Here (Elaborate or Trace_Options);
end Ada_Lib.Curl.Tests;