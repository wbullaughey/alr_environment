with Ada.Containers.Indefinite_Vectors;
with Ada.Text_IO;use Ada.Text_IO;
with Ada_Lib.Options.Unit_Test;
--with Ada_Lib.OS.Run;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
--with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
--with Ada_Lib.Trace; use Ada_Lib.Trace;
with AUnit.Assertions;

package body Ada_Lib.Unit_Test is

-- use type Ada.Containers.Count_Type;

   type String_Access            is access constant String;

   Test_Failed                   : Boolean := False;

   package Routines_Package      is new Ada.Containers.Indefinite_Vectors (
      Index_Type        => Positive,
      Element_Type      => String,
      "="               => "=");

   type Suite_Type               is record
      Routines                   : Routines_Package.Vector;
      Suite                      : String_Access;
   end record;

   package Suites_Package        is new Ada.Containers.Indefinite_Vectors (
      Index_Type        => Positive,
      Element_Type      => Suite_Type,
      "="               => "=");

   subtype Suites_Type           is Suites_Package.Vector;
-- type Suites_Access            is access Suites_Type;

   Debug    : Boolean renames Options.Unit_Test.Ada_Lib_Unit_Test.Debug;
   Suites   : Suites_Type;

   ----------------------------------------------------------------------------
   function Did_Fail return Boolean is
   ----------------------------------------------------------------------------

   begin
      Log_Here (Debug, " Failed " & Test_Failed'img);
      return Test_Failed;
   end Did_Fail;

   ----------------------------------------------------------------------------
   procedure Exception_Assert (
     Fault                      : Ada.Exceptions.Exception_Occurrence;
     Here                       : in     String := Ada_Lib.Trace.Here;
     Who                        : in     String := Ada_Lib.Trace.Who) is
   ----------------------------------------------------------------------------

     use Ada.Exceptions;

   begin
     Trace_Message_Exception (Fault, "method " & Who, Here);
     Set_Failed;
     AUnit.Assertions.Assert (False, Exception_Name (Fault) & " " &
         Exception_Message (Fault) &
         " called from " & Here & " by " & Who);
   end Exception_Assert;

   ----------------------------------------------------------------------------
   function Has_Test (
      Suite_Name                 : in     String;
      Routine_Name               : in     String
   ) return Boolean is
   ----------------------------------------------------------------------------

      Found                      : Boolean := False;

      ----------------------------------------------------------------------------
      procedure Find_Suite (
         Cursor                  : in     Suites_Package.Cursor) is
      ----------------------------------------------------------------------------

         Suite_Reference         : Suites_Package.Reference_Type renames
                                    Suites_Package.Reference (Suites, Cursor);
         Routines                : Routines_Package.Vector renames
                                    Suite_Reference.Routines;

      begin
         Log_In (Debug, Quote ("Reference.Suite", Suite_Reference.Suite.all) &
            Quote (" Suite_Name", Suite_Name) &
            Quote (" Routine_Name", Routine_Name));
         if Suite_Reference.Suite.all = Suite_Name then
            Log_Here (Debug);

            declare
               ----------------------------------------------------------------------------
               procedure Find_Routine (
                  Cursor                  : in     Routines_Package.Cursor) is
               ----------------------------------------------------------------------------

                  Routine_Reference       : Routines_Package.Reference_Type renames
                                             Routines_Package.Reference (
                                                Suite_Reference.Routines, Cursor);
--                Routines                : Routines_Package.Vector renames
--                                           Suite_Reference.Routines;

               begin
                  Log_In (Debug, Quote ("Reference.Suite", Routine_Reference) &
                     Quote (" Routine_Name", Routine_Name));
                  if Routine_Reference = Routine_Name then
                     Log_Here (Debug);
                     Found := True;
                  end if;
                  Log_Out (Debug);
               end Find_Routine;
               ----------------------------------------------------------------------------

            begin
               if Routine_Name'length > 0 then
                  Routines_Package.Iterate (Routines, Find_Routine'access);
               else
                  Found := True;
               end if;
            end;
         end if;
         Log_Out (Debug, "Found " & Found'img);
      end Find_Suite;
      ----------------------------------------------------------------------------

   begin
      Log_In (Debug, Quote ("Suite_Name", Suite_Name) &
         Quote (" Routine_Name", Routine_Name));

      Suites_Package.Iterate (Suites, Find_Suite'access);

      if not Found then
         Log_Exception (Debug, "suite/routine not scheduled");
         raise Failed with Quote ("suite", Suite_Name) &
            (if Routine_Name'length > 0 then
                  Quote (" routine", Routine_Name)
               else
                  "") &
               " not scheduled";
      end if;

      return Log_Out (Found, Debug);
   end Has_Test;


   -----------------------------------------------------------
   procedure Iterate_Suites (
      Suite_Action               : in     Suite_Action_Access;
      Routine_Action             : in     Routine_Action_Access;
      Mode                       : in     Ada_Lib.Options.Mode_Type) is
   -----------------------------------------------------------

      -----------------------------------------------------------
      function Less (
         Left, Right             : in     Suite_Type
      ) return Boolean is
      -----------------------------------------------------------

      begin
         return Left.Suite.all < Right.Suite.all;
      end Less;
      -----------------------------------------------------------

      package Sort_Suite_Package is new Suites_Package.Generic_Sorting (
         "<"   => Less);

      package Sort_Routine_Package is new Routines_Package.Generic_Sorting (
         "<"   => "<");

      First                      : Boolean := True;

   begin
      Log_In (Debug);

      Sort_Suite_Package.Sort (Suites);
      for Suite of Suites loop
         if not Suite.Routines.Is_Empty then
            Suite_Action (Suite.Suite.all, First, Mode);
            First := False;

            Sort_Routine_Package.Sort (Suite.Routines);

            for Routine of Suite.Routines loop
               Routine_Action (Suite.Suite.all, Routine, Mode);
            end loop;
         end if;
      end loop;

      New_Line;
      Put_Line ("Routines with a * are disabled by default");
      Log_Out (Debug);

exception

   when Fault: others =>
      Trace_Exception (True, Fault, Here);
      raise;

   end Iterate_Suites;

   ----------------------------------------------------------------------------
   procedure Routine (
      Suite_Name                 : in     String;
      Routine_Name               : in     String) is
   ----------------------------------------------------------------------------

      Found                      : Boolean := False;

      ----------------------------------------------------------------------------
      procedure Update (
         Cursor                  : in     Suites_Package.Cursor) is
      ----------------------------------------------------------------------------

         Reference               : Suites_Package.Reference_Type renames
                                    Suites_Package.Reference (Suites, Cursor);
         Routines                : Routines_Package.Vector renames Reference.Routines;

      begin
         Log_In (Debug, Quote ("Reference.Suite", Reference.Suite.all) &
            Quote (" Suite_Name", Suite_Name) &
            Quote (" Routine_Name", Routine_Name));
         if Reference.Suite.all = Suite_Name then
            Log_Here (Debug);
            Found := True;
            Routines_Package.Append (Routines, Routine_Name);
         end if;
         Log_Out (Debug);
      end Update;
      ----------------------------------------------------------------------------

   begin
      Log_In (Debug, Quote ("Suite_Name", Suite_Name) &
         Quote (" Routine_Name", Routine_Name));

      Suites_Package.Iterate (Suites, Update'access);

      if not Found then
         Log_Exception (Debug);
         raise Failed with "suite " & Suite_Name & " not created. " &
            "Add call to Ada_Lib.Unit_Test.Suite when creating the Suite";
      end if;

      Log_Out (Debug);
   end Routine;

-- ---------------------------------------------------------------
-- procedure Run_Tests is
-- ---------------------------------------------------------------
--
--    Test_Application           : constant String :=
--                                  "../unit_test/bin/canera_aunit";
-- begin
--    Log_In (Debug);
--    Ada_Lib.Unit_Testing := True;
--    for Suite of Suites loop
--       Put_Line ("  " & Suite.Suite.all);
--       declare
--          Parameters        : Ada_Lib.Strings.Unlimited.String_Type;
--
--       begin
--          Parameters.Construct ("-s " & Suite.Suite.all);
--          if Suite.Routines.Length > 0 then
--             for Routine of Suite.Routines loop
--                Put_Line ("    " & Routine);
--                Parameters.Append (" -R " & Routine);
--                Log_Here (Debug, Quote ("parameters", Parameters));
--                Put_Line (Ada_Lib.OS.Run.Spawn (
--                      Test_Application, Parameters.Coerce));
--             end loop;
--          else
--             Log_Here (Debug, Quote ("parameters", Parameters));
--             Put_Line (Ada_Lib.OS.Run.Spawn (
--                   Test_Application, Parameters.Coerce));
--          end if;
--       end;
--    end loop;
--    Log_Out (Debug);
-- end Run_Tests;

   ----------------------------------------------------------------------------
   procedure Set_Failed (
      From                       : in     String := Ada_Lib.Trace.Here) is
   ----------------------------------------------------------------------------

   begin
      Log_Here (Debug,  " called from " & From);
      Test_Failed := True;
   end Set_Failed;

-- ----------------------------------------------------------------------------
-- overriding
-- procedure Set_Up (
--    Test                       : in out AUnit_Tests_Type) is
-- ----------------------------------------------------------------------------
--
-- begin
--    Log_Here (Debug or Trace_Set_Up_Tear_Down);
--    Test.Set_Up_Completed := True;
--    Test.Tear_Down_Completed := False;
-- end Set_Up;

   -----------------------------------------------------------
   procedure Suite (
      Name                       : in     String) is
   -----------------------------------------------------------

   begin
      Log_In (Debug, Quote ("Suite_Name", Name));
      Suites_Package.Append (Suites, Suite_Type'(
         Routines  => Routines_Package.Empty_Vector,
         Suite    => new String'(Name)));
      Log_Out (Debug);
   end Suite;

-- ----------------------------------------------------------------------------
-- overriding
-- procedure Tear_Down (
--    Test                       : in out AUnit_Tests_Type) is
-- ----------------------------------------------------------------------------
--
-- begin
--    Log_In (Debug or Trace_Set_Up_Tear_Down);
--    Test.Tear_Down_Completed := True;
--    Test.Set_Up_Completed := False;
--    Log_Out (Debug or Trace_Set_Up_Tear_Down);
-- end Tear_Down;

   ----------------------------------------------------------------------------
   function Test_Name (
      Suite_Name                 : in     String;
      Routine_Name               : in     String
   ) return String is
   ----------------------------------------------------------------------------

      Result                     : constant String := Suite_Name & ":" & Routine_Name;

   begin
      Log_Here (Debug, " Suite '" & Suite_Name & "' Routine '" & Routine_Name &
         "' filter '" & Result & "'");
      return Result;
   end Test_Name;

-- ----------------------------------------------------------------------------
-- function Verify_Set_Up (
--    Test                       : in     AUnit_Tests_Type
-- )  return Boolean is
-- ----------------------------------------------------------------------------
--
-- begin
--    return Log_Here (Test.Set_Up_Completed, Debug);
-- end Verify_Set_Up;
--
-- ----------------------------------------------------------------------------
-- function Verify_Tear_Down (
--    Test                       : in     AUnit_Tests_Type
-- )  return Boolean is
-- ----------------------------------------------------------------------------
--
-- begin
--    return Log_Here (Test.Tear_Down_Completed, Debug);
-- end Verify_Tear_Down;

begin
--Debug := True;
--Trace_Options := True;
   Log_Here (Trace_Options or Elaborate);
end Ada_Lib.Unit_Test;
