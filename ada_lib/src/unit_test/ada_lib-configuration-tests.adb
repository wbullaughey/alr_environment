with Ada.Text_IO; use Ada.Text_IO;
with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with GNAT.OS_Lib;

package body Ada_Lib.Configuration.Tests is

   procedure Test_Configuration (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Update_New_Configuration (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Update_Same_Configuration (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   Root_Path                     : constant String := "tests/data/";
   Default_Configuration_Path    : constant String := Root_Path &
                                                      "configuration.cfg";
   New_Configuration_Path        : constant String := "new_configuration.cfg";
   New_Name                      : constant String := "new_configuration_name";
   New_Value                     : constant String := "new_configuration_value";
   Missing_Configuration_Path    : constant String := Root_Path &
                                                      "missing_configuration.cfg";
   Previous_Name                 : constant String := "previous_name";
   Update_New_Path               : constant String := Root_Path &
                                                      "test-update_new_path.cfg";
   Update_Name                   : constant String := "update_name";
   Update_Same_Path              : constant String := Root_Path &
                                                      "test-update_same_path.cfg";

   ---------------------------------------------------------------
   overriding
   function Name (Test : Test_Type) return AUnit.Message_String is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

   begin
      return AUnit.Format (Suite_Name);
   end Name;

   ---------------------------------------------------------------
   procedure Missing_Configuration (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

      Local_Test                 : Test_Type renames Test_Type (Test);

   begin
      Log_In (Debug);
      begin
         Local_Test.Configuration.Load (Missing_Configuration_Path, False);
         Assert (False, "Open " & Missing_Configuration_Path & " should have raised an exception");

      exception
         when Fault: Failed =>
            Trace_Exception (Debug, Fault);
      end;

      Log_Out (Debug);

   exception
      when Fault: others =>
         Trace_Exception (Fault);
         Ada_Lib.Unit_Test.Set_Failed;

   end Missing_Configuration;

   ---------------------------------------------------------------
   procedure New_Configuration (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

      Local_Test                 : Test_Type renames Test_Type (Test);

   begin
      Log_In (Debug);
      Local_Test.Configuration.Load (New_Configuration_Path, True);

      Assert (GNAT.OS_Lib.Is_Regular_File (New_Configuration_Path), "new configuration not created");
      Local_Test.Configuration.Set (New_Name, New_Value, True);
      Local_Test.Configuration.Close;
      Local_Test.Configuration.Load (New_Configuration_Path, False);
      Assert (Local_Test.Configuration.Get_String (New_Name) = New_Value, "value not updated");
      Log_Out (Debug);

   exception
      when Fault: others =>
         Trace_Exception (Fault);
         Ada_Lib.Unit_Test.Set_Failed;

   end New_Configuration;

   ---------------------------------------------------------------
   overriding
   procedure Register_Tests (Test : in out Test_Type) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug);

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Missing_Configuration'access,
         Routine_Name   => AUnit.Format ("Missing_Configuration")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => New_Configuration'access,
         Routine_Name   => AUnit.Format ("New_Configuration")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Test_Configuration'access,
         Routine_Name   => AUnit.Format ("Test_Configuration")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Update_New_Configuration'access,
         Routine_Name   => AUnit.Format ("Update_New_Configuration")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Update_Same_Configuration'access,
         Routine_Name   => AUnit.Format ("Update_Same_Configuration")));

      Log_Out (Debug);
   end Register_Tests;

   ---------------------------------------------------------------
   overriding
   procedure Set_Up (
      Test                       : in out Test_Type) is
   ---------------------------------------------------------------

      use GNAT.OS_Lib;

      ------------------------------------------------------------
      procedure Delete_File (
         Name                    : in     String) is
      ------------------------------------------------------------

      begin
         Log_In (Debug, Quote ("Name", Name));
         if    Is_Regular_File (Name) then
            declare
               Success              : Boolean;

            begin
               Delete_File  (Name, Success);
               if Success and Debug then
                  Put_Line (Name & " was deleted");
               end if;
            end;
         elsif Is_Directory (Name) then
            raise Failed with Name & " was a directory and could not be deleted";
         end if;
      end Delete_File;
      ------------------------------------------------------------

   begin
      Log_In (Debug or Trace_Set_Up_Tear_Down);
      Delete_File (New_Configuration_Path);
      Delete_File (Missing_Configuration_Path);
      Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type (Test).Set_Up;
      Log_Out (Debug or Trace_Set_Up_Tear_Down);
   end Set_Up;

   ---------------------------------------------------------------
   function Suite return AUnit.Test_Suites.Access_Test_Suite is
   ---------------------------------------------------------------

      Test_Suite                 : constant AUnit.Test_Suites.Access_Test_Suite :=
                                    new AUnit.Test_Suites.Test_Suite;
      Tests                      : constant Test_Access := new Test_Type;

   begin
      Ada_Lib.Unit_Test.Suite (Suite_Name);
      Test_Suite.Add_Test (Tests);
      return Test_Suite;
   end Suite;

   ---------------------------------------------------------------
   overriding
   procedure Tear_Down (
      Test                       : in out Test_Type) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug or Trace_Set_Up_Tear_Down);
      if Test.Configuration.Is_Open then
         Log_Here (Debug);
         Test.Configuration.Close;
      end if;
      Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type (Test).Tear_Down;
      Log_Out (Debug or Trace_Set_Up_Tear_Down);
   end Tear_Down;

   ---------------------------------------------------------------
   procedure Test_Configuration (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

      Local_Test                 : Test_Type renames Test_Type (Test);

   begin
      Log_In (Debug);
      Local_Test.Configuration.Load (Default_Configuration_Path, False);
      Local_Test.Configuration.Close;
      Log_Out (Debug);

   exception
      when Fault: others =>
         Trace_Exception (Fault);
         Ada_Lib.Unit_Test.Set_Failed;

   end Test_Configuration;

   ---------------------------------------------------------------
   procedure Update_New_Configuration (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

      Local_Test                 : Test_Type renames Test_Type (Test);

   begin
      Log_In (Debug);
      Local_Test.Configuration.Load (Default_Configuration_Path, False);
      Local_Test.Configuration.Set ("new entry", "New Value", False);
      Local_Test.Configuration.Store (Update_New_Path);
      Local_Test.Configuration.Close;
      Log_Out (Debug);

   exception
      when Fault: others =>
         Ada_Lib.Unit_Test.Exception_Assert (Fault);

   end Update_New_Configuration;

   ---------------------------------------------------------------
   procedure Update_Same_Configuration (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

      Local_Test                 : Test_Type renames Test_Type (Test);

   begin
      Log_In (Debug);
      Local_Test.Configuration.Load (Update_Same_Path, False);

      declare
         Update_Value            : constant Integer := Local_Test.Configuration.
                                    Get_Integer (Update_Name);
         Next_Value              : constant Integer := Update_Value + 1;

      begin
         Local_Test.Configuration.Set (Previous_Name, Update_Value, True);
         Local_Test.Configuration.Set (Update_Name, Next_Value, True);
         Local_Test.Configuration.Close;
         Local_Test.Configuration.Load (Update_Same_Path, False);
         declare
            Previous_Value          : constant Integer := Local_Test.Configuration.
                                       Get_Integer (Previous_Name);
            Update_Value            : constant Integer := Local_Test.Configuration.
                                       Get_Integer (Update_Name);
            Expected_Value          : constant Integer := Previous_Value + 1;

         begin
            Assert (Update_Value = Expected_Value,
               "update value is wrong. expected" & Expected_Value'img &
               " got" & Previous_Value'img);
            Local_Test.Configuration.Close;
         end;
      end;
      Log_Out (Debug);

   exception
      when Fault: others =>
         Ada_Lib.Unit_Test.Exception_Assert (Fault);

   end Update_Same_Configuration;

begin
   if Trace_Tests then
      Debug := Trace_Tests;
   end if;

end Ada_Lib.Configuration.Tests;

