with Ada.Exceptions;
with Ada.Text_IO;use Ada.Text_IO;
with Ada_Lib.Options.Unit_Test;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with Ada_Lib.Unit_Test.Test_Cases;
with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases;

package body Ada_Lib.Strings.Maps.Unit_Tests is

-- use type Ada_Lib.Strings.Unlimited.String_Type;

   type Test_Type    is new Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type with
                        null record;
   type Test_Access  is access Test_Type;

   procedure Map_Failure (
      Test           : in out AUnit.Test_Cases.Test_Case'class);

   procedure Map_Success (
      Test           : in out AUnit.Test_Cases.Test_Case'class);

   overriding
   function Name (
      Test           : Test_Type) return AUnit.Message_String;

   overriding
   procedure Register_Tests (
      Test           : in out Test_Type);

   Debug             : Boolean renames Ada_Lib.Options.Unit_Test.
                        Ada_Lib_Strings.Debug_Maps;
   Suite_Name        : constant String := "Maps";

   type Kind_Type    is (one, two, three, no_kind);

   type Kinds_Type   is array (Positive range <>) of Kind_Type;

   type Names_Type   is array (Positive range <>) of
                           Ada_Lib.Strings.Unlimited.String_Type;

   Kinds             : constant Kinds_Type := (One, Two, Three);
   Names             : constant Names_Type := (
                        Ada_Lib.Strings.Unlimited.Coerce ("one"),
                        Ada_Lib.Strings.Unlimited.Coerce ("two"),
                        Ada_Lib.Strings.Unlimited.Coerce ("three"));

   package Mapper is new Ada_Lib.Strings.Maps.Mapper (
      Kind_Type      => Kind_Type,
      Kinds          => Kinds,
      Kinds_Type     => Kinds_Type,
      Names          => Names,
      Names_Type     => Names_Type);

   ----------------------------------------------------------------------------
   procedure Map_Failure (
      Test           : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ----------------------------------------------------------------------------

      Bad_Name       : constant String := "xyz";

   begin
      Log_In (Debug);
      begin
         declare
            Result      : constant Kind_Type := Mapper.Map_Name (Bad_Name);
            pragma Unreferenced (Result);

         begin
            Assert (False, Bad_Name & " did not raise an exception");
         end;

      exception
         when Failed =>
            Null;
      end;
      begin
         declare
            Result      : constant String := Mapper.Map_Kind (No_Kind);
            pragma Unreferenced (Result);

         begin
            Assert (False, No_Kind'img & " did not raise an exception");
         end;

      exception
         when Failed =>
            Null;
      end;
      Log_Out (Debug);

   exception
      when Fault: Failed =>
         Unit_Test.Exception_Assert (Fault);

   end Map_Failure;

   ----------------------------------------------------------------------------
   procedure Map_Success (
      Test           : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ----------------------------------------------------------------------------

   begin
      Log_In (Debug);
      for Index in Names'range loop
         begin
            Assert (Mapper.Map_Name (Names (Index)) = Kinds (Index),
               "name " & Names (Index).Coerce &
               " does not map to " & Kinds (Index)'img);
            Assert (Mapper.Map_Name (Names (Index).Coerce) = Kinds (Index),
               "name " & Names (Index).Coerce &
               " does not map to " & Kinds (Index)'img);
         exception
            when Fault: Failed =>
               Put_Line ("name " & Names (Index).Coerce & "not found in map");
               Put_Line ("exception type " &
                  Ada.Exceptions.Exception_Name (Fault) & " " &
                  Ada.Exceptions.Exception_Message (Fault));
         end;
         begin
            Assert (Mapper.Map_Kind (Kinds (Index)) = Names (Index),
               "Kind " & Kinds (Index)'img &
               " does not map to " & Names (Index).Coerce);
            Assert (Mapper.Map_Kind (Kinds (Index)) = Names (Index),
               "Kind " & Kinds (Index)'img &
               " does not map to " & Names (Index).Coerce);
         exception
            when Fault: Failed =>
               Put_Line ("ind " & Kinds (Index)'img & "not found in map");
               Put_Line ("exception type " &
                  Ada.Exceptions.Exception_Name (Fault) & " " &
                  Ada.Exceptions.Exception_Message (Fault));
         end;
      end loop;
      Log_Out (Debug);
   end Map_Success;

   ----------------------------------------------------------------------------
   overriding
   function Name (Test : Test_Type) return AUnit.Message_String is
   ----------------------------------------------------------------------------

   begin
      return AUnit.Format (Suite_Name);
   end Name;

   ----------------------------------------------------------------------------
   overriding
   procedure Register_Tests (
      Test : in out Test_Type) is
   ----------------------------------------------------------------------------

   begin
      Log_In (Debug);

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Map_Failure'access,
         Routine_Name   => AUnit.Format ("Map_Failure")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Map_Success'access,
         Routine_Name   => AUnit.Format ("Map_Success")));

      Log_Out (Debug);
   end Register_Tests;

   ----------------------------------------------------------------------------
   function Suite return AUnit.Test_Suites.Access_Test_Suite is
   ----------------------------------------------------------------------------

      Test_Suite                 : constant AUnit.Test_Suites.Access_Test_Suite :=
                                    new AUnit.Test_Suites.Test_Suite;
      Tests                      : constant Test_Access := new Test_Type;

   begin
      Ada_Lib.Unit_Test.Suite (Suite_Name);  -- used for listing suites
      Test_Suite.Add_Test (Tests);
      return Test_Suite;
   end Suite;

end Ada_Lib.Strings.Maps.Unit_Tests;

