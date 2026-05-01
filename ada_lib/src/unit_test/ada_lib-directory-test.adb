with Ada.Exceptions;
with Ada_Lib.Directory.Compare_Files;
with Ada_Lib.Directory.File_Compare;
with Ada_Lib.Directory.File_Copy;
--with Ada_Lib.OS.Environment;
with Ada.Text_IO;use Ada.Text_IO;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with Ada_Lib.Unit_Test.Test_Cases;
with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases;

package body Ada_Lib.Directory.Test is

   type Test_Type                is new Ada_Lib.Unit_Test.
                                    Test_Cases.Test_Case_Type with null record;

   type Test_Access is access Test_Type;

   overriding
   function Name (
      Test                       : in     Test_Type) return AUnit.Message_String;

   overriding
   procedure Register_Tests (
      Test                       : in out Test_Type);

   procedure Test_File_Compare (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Test_File_Copy (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   Compare_Path_1                : constant String := "file_compare_1";
   Compare_Path_2                : constant String := "file_compare_2";
   Different_Path                : constant String := "file_compare_difference";
   Copy_Source_Path              : constant String := "file_copy_source";
   Destination_Path              : constant String := "file_copy_destination";

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
      Log_In (Debug);

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Test_File_Compare'access,
         Routine_Name   => AUnit.Format ("Test_File_Compare")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Test_File_Copy'access,
         Routine_Name   => AUnit.Format ("Test_File_Copy")));

      Log_Out (Debug);
   end Register_Tests;

-- ---------------------------------------------------------------
-- procedure Set_Up (Test : in out Test_Type) is
-- ---------------------------------------------------------------
--
--    Seperator               : character;
--
-- begin
--Log (Here, Who);
--    Log (Debug, Here, Who);
-- end Set_Up;

   ---------------------------------------------------------------
   function Suite return AUnit.Test_Suites.Access_Test_Suite is
   ---------------------------------------------------------------

      Test_Suite                 : constant AUnit.Test_Suites.Access_Test_Suite :=
                                    new AUnit.Test_Suites.Test_Suite;
      Test                       : constant Test_Access := new Test_Type;

   begin
      Log_In (Debug);
      Ada_Lib.Unit_Test.Suite (Suite_Name);
      Test_Suite.Add_Test (Test);
      Log_Out (Debug);
      return Test_Suite;
   end Suite;

-- ---------------------------------------------------------------
-- procedure Tear_Down (Test : in out Test_Type) is
-- ---------------------------------------------------------------
--
-- begin
--    Log (Debug, Here, Who);
--    Test.Camera.Close;
--    Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type (Test).Tear_Down;
-- end Tear_Down;

   ---------------------------------------------------------------
   procedure Test_File_Compare (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

   begin
      Log_In (Debug);
      Put_Line ("test file compare");
      Ada_Lib.Directory.File_Compare (Full_Name (Compare_Path_1),
         Full_Name (Compare_Path_2));
      Assert (Ada_Lib.Directory.Compare_Files (Full_Name (Compare_Path_1),
         Full_Name (Compare_Path_2)), Compare_Path_1 & " and " & Compare_Path_2 &
         " files should have compared");
      begin
         Ada_Lib.Directory.File_Compare (Full_Name (Compare_Path_1),
            Full_Name (Different_Path));
         Assert (not Ada_Lib.Directory.Compare_Files (Full_Name (Compare_Path_1),
            Full_Name (Different_Path)), Compare_Path_1 & " and " & Different_Path &
            " files should not have compared");
         Log_Here (Debug, "different files compared");

      exception
         when Fault: Failed =>
            declare
               Expected          : constant String := "Files differ at offset";
               Message           : constant String :=
                                    Ada.Exceptions.Exception_Message (Fault);

            begin
               Trace_Exception (Debug, Fault);
               Log_Here (Debug, "different files did not compare");
               Assert (Message'length > Expected'length and then
                  Message (1 .. Expected'length) = Expected,
                  Quote ("Exception message", Message) &
                  Quote (" was not same as expected", Expected));
               Log_Out (Debug, "tests succeed");
               return;     -- both tests ok
            end;
      end;

      Assert (False, "Compare of different files did not fail");

   exception
      when Fault: others =>
         Trace_Exception (Debug, Fault);
         Assert (False, Ada.Exceptions.Exception_Message (Fault));

   end Test_File_Compare;

   ---------------------------------------------------------------
   procedure Test_File_Copy(
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

   begin
      Log_In (Debug);
      Put_Line ("test file copy");
      Ada_Lib.Directory.File_Copy (Copy_Source_Path,
         Destination_Path, True);
      Log_Out (Debug, "files copied");
      Ada_Lib.Directory.File_Compare (Copy_Source_Path, Destination_Path);
      Log_Out (Debug);

   exception
      when Fault: others =>
         Trace_Exception (Debug, Fault);
         Assert (False, Ada.Exceptions.Exception_Message (Fault));

   end Test_File_Copy;

begin
   Log_Here (Elaborate);
--Debug := True;
--Trace_Options := True;

end Ada_Lib.Directory.Test;
