-- with Ada.Exceptions;
--with Ada.Text_IO; use Ada.Text_IO;
with AUnit.Assertions; use AUnit.Assertions;
--with Ada_Lib.Options.Flags;
--with Ada_Lib.Options.Unit_Test;
--with Ada_Lib.Options.Verification;
with Ada_Lib.Unit_Test;
with Ada_Lib.Trace; use Ada_Lib.Trace;
--with GNATCOLL.Templates;

package body Ada_Lib.GNATCOLL.Tests is

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
      Test                       : in out Template_Test_Type) is
   ---------------------------------------------------------------

   begin
      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Expand_Template'access,
         Routine_Name   => AUnit.Format ("Expand_Template")));

   end Register_Tests;

   ---------------------------------------------------------------
   procedure Expand_Template(
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

--    Source                     : constant String :=
--                                  "before variable %{abc}after variable %{xyz}";
--    Parameters                 : constant Standard.GNATCOLL.Templates.Substitution_Array := (
--                                  (
--                                     Name  => new String'("abc"),
--                                     Value => new String'("abc_value")
--                                  ), (
--                                     Name  => new String'("xyz"),
--                                     Value => new String'("xyz_value")
--                                  )
--                               );
--    Expected                   : constant String :=
--                                  "before variable abc_valueafter variable xyz_value";
   begin
      Log_In (Debug);
not_implemented;
--    declare
--       Options     : Ada_Lib.Options.Unit_Test.
--                      Ada_Lib_Unit_Test_Program_Options_Type'class renames
--                         Ada_Lib.Options.Unit_Test.
--                            Ada_Lib_Unit_Test_Options_Constant_Class_Access (
--                               Ada_Lib.Options.Verification.Get_Ada_Lib_Read_Only_Nested_Options).all;
--       Expansion               : constant String := Standard.GNATCOLL.Templates.Substitute (
--                                  Str         => Source,
--                                  Substrings  => Parameters);
--    begin
--       if Options.Nested_Program_Options.Verbose then
--          Put_Line (Source & " => " & Expansion);
--       end if;
--       Assert (Expansion = Expected, "template replacement failed");
--    end;
      Log_Out (Debug);

   exception
      when Fault: others =>
         Trace_Message_Exception (Fault, "error in library");
         Assert (False, "library failed");

   end Expand_Template;

-- ---------------------------------------------------------------
-- procedure Set_Up (
--    Test                       : in out Template_Test_Type) is
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
      Template_Tests             : constant Template_Test_Access := new Template_Test_Type;

   begin
      Ada_Lib.Unit_Test.Suite (Suite_Name);  -- used for listing suites
      Test_Suite.Add_Test (Template_Tests);
      return Test_Suite;
   end Suite;

-- ---------------------------------------------------------------
-- overriding
-- procedure Tear_Down (
--    Test                       : in out Template_Test_Type) is
-- ---------------------------------------------------------------
--
-- begin
--    Log_In (Debug);
--    Test.Credential.Close;
--    Test_Type (Test).Tear_Down;
--    Log_Out (Debug);
-- end Tear_Down;

begin
   if Trace_Tests then
      Debug := Trace_Tests;
   end if;
--Debug := True;
   Log_Here (Elaborate or Trace_Options);
end Ada_Lib.GNATCOLL.Tests;
