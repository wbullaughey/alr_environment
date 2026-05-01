with AUnit.Assertions;
with Ada.Text_IO; use Ada.Text_IO;
with Ada_Lib.Options.Unit_Test;
with Ada_Lib.OS;
with Ada_Lib.Trace; use Ada_Lib.Trace;

-- pragma Elaborate (Ada_Lib.OS);

package body Ada_Lib.Unit_Test.Fixtures is

-- use Ada_Lib.Strings.Unlimited;

   Current_Fixture   : access Base_Test_Fixtures_Type'class := Null;
   Debug             : Boolean renames Options.Unit_Test.Ada_Lib_Unit_Test.
                        Fixtures_Debug;

   ----------------------------------------------------------------------------
   procedure Exception_Assert (
      Fault                      : Ada.Exceptions.Exception_Occurrence;
      Here                       : in     String;
      Who                        : in     String) is
   ----------------------------------------------------------------------------

      use Ada.Exceptions;

   begin
      AUnit.Assertions.Assert (False, Exception_Name (Fault) & Exception_Message (Fault) &
         " called from " & Here & " by " & Who);
   end Exception_Assert;

   ----------------------------------------------------------------------------
   function Get_Async_Message
   return String is
   ----------------------------------------------------------------------------

   begin
      return Current_Fixture.Async_Failure_Message.Coerce & " called from " &
         Current_Fixture.Failure_From.Coerce;
   end Get_Async_Message;

-- ----------------------------------------------------------------------------
-- function Get_Which_Host (
--    Test                       : in   Base_Test_Fixtures_Type
--  ) return Which_Host_Type is
-- ----------------------------------------------------------------------------
--
-- begin
--     return Unset;
-- end Get_Which_Host;

-- ----------------------------------------------------------------------------
-- overriding
-- procedure Init_Test (
--    Test                       : in out Base_Test_Fixtures_Type) is
-- ----------------------------------------------------------------------------
--
-- begin
--    if Ada_Lib.Trace.Ada_Lib_Lib_Verbose then
--       Put_Line ("------------------------------------------------------------------");
--    end if;
--    AUnit.Test_Cases.Test_Case (Test).Init_Test;
-- end Init_Test;
--
   ----------------------------------------------------------------------------
   procedure Set_Async_Failure_Message (
      Fault                      : in     Ada.Exceptions.Exception_Occurrence;
      From                       : in     String) is
   ----------------------------------------------------------------------------

   begin
      Current_Fixture.Async_Failure_Message := Ada_Lib.Strings.Unlimited.Coerce (
         Ada.Exceptions.Exception_Name (Fault) & Ada.Exceptions.Exception_Message (Fault) &
         " set from " & From);
   end Set_Async_Failure_Message;

   ----------------------------------------------------------------------------
   procedure Set_Async_Failure_Message (
      Message                    : in     String;
      From                       : in     String) is
   ----------------------------------------------------------------------------

   begin
      Current_Fixture.Async_Failure_Message.Set (Message);
      Current_Fixture.Failure_From.Set (From);
   end Set_Async_Failure_Message;

   ----------------------------------------------------------------------------
   procedure Set_Async_Failure_Message (
      Message                    : in     Ada_Lib.Strings.Unlimited.String_Type;
      From                       : in     String) is
   ----------------------------------------------------------------------------

   begin
      Current_Fixture.Async_Failure_Message := Message;
      Current_Fixture.Failure_From.Set (From);
   end Set_Async_Failure_Message;

   ----------------------------------------------------------------------------
   overriding
   procedure Set_Up (
      Test                       : in out Base_Test_Fixtures_Type) is
   ----------------------------------------------------------------------------

   begin
      Log ( Debug or Trace_Set_Up_Tear_Down, Here, Who & " enter");

      Current_Fixture := Test'unchecked_access;
      AUnit.Test_Fixtures.Test_Fixture (Test).Set_Up;
      if Ada_Lib.Trace.Ada_Lib_Lib_Verbose then
         Put_Line ("------------------------------------------------------------------");
      end if;
      Log ( Debug or Trace_Set_Up_Tear_Down, Here, Who & " exit");
-- Log ( Here, Who & " exit");

    exception
        when Fault: others =>
            Test.Set_Up_Exception (Fault, Here, Who);
   end Set_Up;

   ----------------------------------------------------------------------------
   procedure Set_Up_Exception (
      Test                       : in out Base_Test_Fixtures_Type;
      Fault                      : in     Ada.Exceptions.Exception_Occurrence;
      Here                       : in     String;
      Who                        : in     String;
      Message                    : in     String := "") is
   pragma Unreferenced (Test);
   ----------------------------------------------------------------------------

   begin
      Put ("Exception in Set_Up " & Ada.Exceptions.Exception_Name (Fault) &
         ": " & Ada.Exceptions.Exception_Message (Fault) &
--       " for test case '" & AUnit.Assertions.Current_Test.Name &
         "' called from " & Who & " at " & Here);
      if Message'length > 0 then
         Put (" " & Message);
      end if;
      New_Line;
      Flush;
--    Pause ("Set_Up_Exception exit",  Here);
      Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.Unit_Test_Set_Up_Exception);
   end Set_Up_Exception;

   ----------------------------------------------------------------------------
   procedure Set_Up_Failure (
      Test                       : in     Base_Test_Fixtures_Type;
      Condition                  : in     Boolean;
      Here                       : in     String;
      Who                        : in     String;
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
         raise Failed with "Failure in Set_Up called from " & Who & " at " & Here;
--       Ada_Lib.OS.Immediate_Halt (-1);
      end if;
   end Set_Up_Failure;

   ----------------------------------------------------------------------------
   overriding
   procedure Tear_Down (
      Test                       : in out Base_Test_Fixtures_Type) is
   ----------------------------------------------------------------------------

   begin
      Log ( Debug or Trace_Set_Up_Tear_Down, Here, Who & " enter");

--    if Ada_Lib.Database.Unit_Test.Is_DBDaemon_Running then
--       raise Ada_Lib.Unit_Test.Fixtures.Failed with "dbdaemon not closed at " & Here & " " & Who;
--    end if;

      AUnit.Test_Fixtures.Test_Fixture (Test).Tear_Down;
      Log ( Debug or Trace_Set_Up_Tear_Down, Here, Who & " exit");
   end Tear_Down;

   ----------------------------------------------------------------------------
   procedure Tear_Down_Exception (
      Test                       : in out Base_Test_Fixtures_Type;
      Fault                      : in     Ada.Exceptions.Exception_Occurrence;
      Here                       : in     String;
      Who                        : in     String;
      Message                    : in     String := "") is
   pragma Unreferenced (Test);
   ----------------------------------------------------------------------------

   begin
      Put ("Exception in Tear_Down " & Ada.Exceptions.Exception_Name (Fault) &
         ": " & Ada.Exceptions.Exception_Message (Fault) &
         " called from " & Who & " at " & Here);
      if Message'length > 0 then
         Put (" " & Message);
      end if;
      New_Line;
      Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.Unit_Test_Tear_Down_Exception);
   end Tear_Down_Exception;

   ----------------------------------------------------------------------------
   procedure Tear_Down_Failure (
      Test                       : in     Base_Test_Fixtures_Type;
      Condition                  : in     Boolean;
      Here                       : in     String;
      Who                        : in     String;
      Message                    : in     String := "") is
   pragma Unreferenced (Test);
   ----------------------------------------------------------------------------

   begin
      if not Condition then
         Put ("Failure in Tear_Down called from " & Who & " at " & Here);
         if Message'length > 0 then
            Put (" " & Message);
         end if;
         New_Line;
         Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.Unit_Test_Tear_Down_Exception);
      end if;
   end Tear_Down_Failure;

   ----------------------------------------------------------------------------
   function Was_There_An_Async_Failure
   return Boolean is
   ----------------------------------------------------------------------------

   begin
      if Current_Fixture.Async_Failure_Message.Length > 0 then
         Put_Line (Current_Fixture.Async_Failure_Message.Coerce & " called from " &
            Current_Fixture.Failure_From.Coerce);
         return True;
      else
         return False;
      end if;
   end Was_There_An_Async_Failure;

begin
   if Trace_Tests then
      Debug := Trace_Tests;
   end if;
--Debug := Trace_Tests;

end Ada_Lib.Unit_Test.Fixtures;
