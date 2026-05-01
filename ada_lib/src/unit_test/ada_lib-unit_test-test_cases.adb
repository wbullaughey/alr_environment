with Ada.Environment_Variables;
with Ada.Text_IO; use Ada.Text_IO;
with Ada_Lib.Options.Program;
with Ada_Lib.Options.AUnit_Lib;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Trace;

package body Ada_Lib.Unit_Test.Test_Cases is

   use type Ada_Lib.Options.Mode_Type;

   Debug    : Boolean renames Options.Unit_Test.Ada_Lib_Unit_Test_Test_Cases.Debug;

   ----------------------------------------------------------------------------
   procedure Add_Optional_Routine (
      Test                 : in out Test_Case_Type;
      Routine              : in     AUnit.Test_Cases.Test_Routine;
      Suite_Name           : in     String;
      Routine_Name         : in     String;
      Needs_Camera         : in     Boolean) is
   ----------------------------------------------------------------------------

   begin
--log_here ("needs camera " & Needs_Camera'img);
      if Needs_Camera and then not Ada_Lib.Options.Program.Has_Camera then
         Put_Line ("skipping " & Suite_Name & " routine " & Routine_Name);
      else
         Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
            Routine, AUnit.Format (Routine_Name)));
      end if;
   end Add_Optional_Routine;

   ----------------------------------------------------------------------------
   overriding
   procedure Add_Routine (
      Test                    : in out Test_Case_Type;
      Val                     : AUnit.Test_Cases.Routine_Spec) is
   ----------------------------------------------------------------------------

      Options  : constant Ada_Lib.Options.Verification.
                     Verification_Program_Options_Constant_Class_Access :=
                  Ada_Lib.Options.Verification.
                     Get_Ada_Lib_Read_Only_Program_Options;
   begin
      Log_In (Debug, Quote ("routine", Val.Routine_Name.all));
--       " mode " & Options.Mode'img);

      Tag_History (Debug, "options", Options.all'tag);
      declare
         Program_Options
            : Ada_Lib.Options.AUnit_Lib.Aunit_Program_Options_Type renames
               Ada_Lib.Options.AUnit_Lib.Aunit_Program_Options_Type (
                  Options.all);
         Nested_Options
            : Ada_Lib.Options.Unit_Test.Ada_Lib_Unit_Test_Nested_Options_Type'class renames
                  Ada_Lib.Options.Unit_Test.Ada_Lib_Unit_Test_Nested_Options_Type'class (
                        Program_Options.Nested_Unit_Test_Options);
      begin
         if Nested_Options.Mode = Ada_Lib.Options.Run_Tests then
            AUnit.Test_Cases.Test_Case (Test).Add_Routine (Val);
         end if;

         Routine (Test_Case_Type'class (Test).Name.all, Val.Routine_Name.all);
         Log_Out (Debug);
      end;
   end Add_Routine;

   ----------------------------------------------------------------------------
   overriding
   procedure Set_Up (
      Test     : in out Test_Case_Type) is
   ----------------------------------------------------------------------------

   Options  : Ada_Lib.Options.Unit_Test.
                  Ada_Lib_Unit_Test_Nested_Options_Type renames
               Ada_Lib.Options.AUnit_Lib.
                     Aunit_Program_Options_Constant_Class_Access (
                  Ada_Lib.Options.Verification.
                     Get_Ada_Lib_Read_Only_Program_Options).Nested_Unit_Test_Options;
   begin
      Log_In (Debug or Trace_Set_Up_Tear_Down, "Random_Seed_Mode " &
         Options.Random_Seed_Mode'img);

      for Index in 1 .. Options.Number_Random_Generators loop
         Log_Here (Debug, "reset random gemerator mode " &
            Options.Random_Seed_Mode'img &
            " seed" & Index' img & ":" &
            Options.Random_Seeds (Index)'img);

         Random_Number_Generator.Reset (Test.Random_Generators (Index),
            Options.Random_Seeds (Index));

      end loop;

--    Ada_Lib.Unit_Testing := True;
      Root_Test.Test_Type (Test).Set_Up;
      Log_Out (Debug or Trace_Set_Up_Tear_Down);
   end Set_Up;

   ----------------------------------------------------------------------------
   procedure Set_Up_Exception (
      Test                       : in out Test_Case_Type;
      Fault                      : in     Ada.Exceptions.Exception_Occurrence;
      Here                       : in     String := Ada_Lib.Trace.Here;
      Who                        : in     String := Ada_Lib.Trace.Who) is
   ----------------------------------------------------------------------------

   begin
--    Put_Line ("------ exception trace --------");
      Put ("Exception in Set_Up " & Ada.Exceptions.Exception_Name (Fault) &
         ": " & Ada.Exceptions.Exception_Message (Fault) &
         "' called from " & Who & " at " & Here);
      New_Line;
--    Put_Line ("-------------------------------------------------");
      Flush;
      Test.Set_Up_Failed;
   end Set_Up_Exception;

   ----------------------------------------------------------------------------
   procedure Set_Up_Message_Exception (
      Test                       : in out Test_Case_Type;
      Fault                      : in     Ada.Exceptions.Exception_Occurrence;
      Message                    : in     String;
      Here                       : in     String := Ada_Lib.Trace.Here;
      Who                        : in     String := Ada_Lib.Trace.Who) is
   ----------------------------------------------------------------------------

   begin
      Put ("Exception in Set_Up " & Ada.Exceptions.Exception_Name (Fault) &
         ": " & Ada.Exceptions.Exception_Message (Fault) &
         Quote (" message", Message) &
         "' called from " & Who & " at " & Here);
      New_Line;
      Flush;
      Test.Set_Up_Failed;
   end Set_Up_Message_Exception;

   ----------------------------------------------------------------------------
   procedure Set_Up_Failure (
      Test                       : in     Test_Case_Type;
      Condition                  : in     Boolean;
      Here                       : in     String := Ada_Lib.Trace.Here;
      Who                        : in     String := Ada_Lib.Trace.Who;
      Message                    : in     String := "") is
   pragma Unreferenced (Test);
   ----------------------------------------------------------------------------

   begin
      if not Condition then
         Put ("Failure in Set_Up called from " & Who & " at " & Here);
         if Message'length > 0 then
            Put (" " & Message);
         end if;
         New_Line;
         raise Failed with "Failure in Set_Up " & Message &
            " called from " & Who & " at " & Here;
--       Ada_Lib.OS.Immediate_Halt (-1);
      end if;
   end Set_Up_Failure;

--   ----------------------------------------------------------------------------
--   procedure Tear_Down (
--      Test                       : in out Test_Case_Type) is
--   ----------------------------------------------------------------------------
--
--   begin
--      Log ( Debug, Here, Who & " enter");
--
----    if Ada_Lib.Database.Unit_Test.Is_DBDaemon_Running then
----       raise Ada_Lib.Unit_Test.Test_Cases.Failed with "dbdaemon not closed at " & Here & " " & Who;
----    end if;
--
--      AUnit.Test_Cases.Test_Case (Test).Tear_Down;
--      Log ( Debug, Here, Who & " exit");
--   end Tear_Down;
--
     ----------------------------------------------------------------------------
     procedure Tear_Down_Exception (
        Test                       : in out Test_Case_Type;
        Fault                      : Ada.Exceptions.Exception_Occurrence;
      Here                       : in     String := Ada_Lib.Trace.Here;
      Who                        : in     String := Ada_Lib.Trace.Who;
        Message                    : in     String := "") is
     ----------------------------------------------------------------------------

     begin
        Put ("Exception in Tear_Down " & Ada.Exceptions.Exception_Name (Fault) &
           ": " & Ada.Exceptions.Exception_Message (Fault) &
           " called from " & Who & " at " & Here);
        if Message'length > 0 then
           Put (" " & Message);
        end if;
        New_Line;
--      Ada_Lib.OS.Immediate_Halt (-1);
        Test.Tear_Down_Failed;
     end Tear_Down_Exception;

     ----------------------------------------------------------------------------
     procedure Tear_Down_Failure (
        Test                       : in out Test_Case_Type;
        Condition                  : in     Boolean;
        Here                       : in     String := Ada_Lib.Trace.Here;
        Who                        : in     String := Ada_Lib.Trace.Who;
        Message                    : in     String := "") is
     ----------------------------------------------------------------------------

     begin
        if not Condition then
           Put ("Failure in Tear_Down called from " & Who & " at " & Here);
           if Message'length > 0 then
              Put (" " & Message);
           end if;
           New_Line;
--         Ada_Lib.OS.Immediate_Halt (-1);
           Test.Tear_Down_Failed;
        end if;
     end Tear_Down_Failure;

--   ----------------------------------------------------------------------------
--   function Was_There_An_Async_Failure
--   return Boolean is
--   ----------------------------------------------------------------------------
--
--   begin
--      if Length (Current_Fixture.Async_Failure_Message) > 0 then
--         Put_Line (To_String (Current_Fixture.Async_Failure_Message) & " called from " &
--            To_String (Current_Fixture.Failure_From));
--         return True;
--      else
--         return False;
--      end if;
--   end Was_There_An_Async_Failure;

   package body Root_Test is

      ----------------------------------------------------------------------------
      function Did_Set_Up_Fail (
         Test                    : in     Test_Type
      ) return Boolean is
      ----------------------------------------------------------------------------

      begin
         return Test.Set_Up_Failed;
      end Did_Set_Up_Fail;

--    ----------------------------------------------------------------------------
--    overriding
--    procedure Register_Tests (
--       Test                    : in out Test_Type) is
--    ----------------------------------------------------------------------------
--
--    begin
--       Log_In (Debug);
--       AUnit.Test_Cases.Test_Case'class (Test).Register_Tests;
--       Log_Out (Debug);
--    end Register_Tests;

      ----------------------------------------------------------------------------
      overriding
      procedure Set_Up (
         Test                    : in out Test_Type) is
      ----------------------------------------------------------------------------

      begin
         Log_In (Debug or Trace_Set_Up_Tear_Down);
--       Ada_Lib.Unit_Testing := True;
         Test.Set_Up_Succeeded := True;
         Test.Torn_Down := False;
         Log_Out (Debug or Trace_Set_Up_Tear_Down);
      end Set_Up;

      ----------------------------------------------------------------------------
      procedure Set_Up_Failed (
         Test                       : in out Test_Type;
         Here                       : in     String := Ada_Lib.Trace.Here) is
      ----------------------------------------------------------------------------

      begin
         Test.Set_Up_Failed := True;
         Log_Here;
      end Set_Up_Failed;

      ----------------------------------------------------------------------------
      overriding
      procedure Tear_Down (
         Test                       : in out Test_Type) is
      ----------------------------------------------------------------------------

      begin
         Log_In (Debug or Trace_Set_Up_Tear_Down);
         Test.Set_Up_Succeeded := False;
         Test.Torn_Down := True;
         Log_Out (Debug or Trace_Set_Up_Tear_Down);
      end Tear_Down;

      ----------------------------------------------------------------------------
      procedure Tear_Down_Failed (
         Test                       : in out Test_Type;
         Here                       : in     String := Ada_Lib.Trace.Here) is
      ----------------------------------------------------------------------------

      begin
         Test.Tear_Down_Failed := True;
         Log_Here;
      end Tear_Down_Failed;

      ----------------------------------------------------------------------------
      function Verify_Set_Up (
         Test                       : in     Test_Type;
         Expect_True                : in     Boolean := True;
         Here                       : in     String := Ada_Lib.Trace.Here
      )  return Boolean is
      ----------------------------------------------------------------------------

      Result   : constant Boolean := Test.Set_Up_Succeeded and then
                                       not Test.Set_Up_Failed;

      begin
         return Log_Here (Result,
            Debug or else Trace_Pre_Post_Conditions,
            "Set_Up_Succeeded " & Test.Set_Up_Succeeded'img &
            " Set_Up_Failed " & Test.Set_Up_Failed'img &
            " called from " & Here);
      end Verify_Set_Up;

      ----------------------------------------------------------------------------
      function Verify_Tear_Down (
         Test                       : in     Test_Type;
         Expect_True                : in     Boolean := True;
         Here                       : in     String := Ada_Lib.Trace.Here
      ) return Boolean is
      ----------------------------------------------------------------------------

      Result   : constant Boolean := Test.Torn_Down and then
                                       not Test.Tear_Down_Failed;
      begin
         return Log_Here (Result,
            Debug or else Trace_Pre_Post_Conditions,
            "Torn_Down " & Test.Torn_Down'img &
            " Tear_Down_Failed " & Test.Tear_Down_Failed'img &
            " called from " & Here);

      end Verify_Tear_Down;

   end Root_Test;

begin
   if Trace_Tests then
      Debug := Trace_Tests;
   end if;
--Debug := True;
   Log_Here (Debug or Trace_Options or Elaborate, "unit testing " &
      Ada_Lib.Options.Ada_Lib_Environment.Unit_Testing'img &
      " Ada_Lib.Options.Ada_Lib_Environment.Help_Test " &
      Ada_Lib.Options.Ada_Lib_Environment.Help_Test'img &
      "Environment_Variables help test " & Ada.Environment_Variables.Value (
         "BUILD_MODE", "execute") &
      "Environment_Variables unit test " & Ada.Environment_Variables.Value (
         "UNIT_TEST", "FALSE"));

end Ada_Lib.Unit_Test.Test_Cases;
