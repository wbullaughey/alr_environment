with Ada.Exceptions;
with Ada_Lib.Time;
with Ada_Lib.Timer;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases;

package body Ada_Lib.Event.Unit_Test is

   procedure Wait_For_Event(
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   ---------------------------------------------------------------
   overriding
   function Name (Test : Test_Type) return AUnit.Message_String is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

   begin
      return AUnit.Format (Suite_Name);
   end Name;

   ---------------------------------------------------------------
   overriding
   procedure Register_Tests (Test : in out Test_Type) is
   ---------------------------------------------------------------

   begin
      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Wait_For_Event'access,
         Routine_Name   => AUnit.Format ("Wait_For_Event")));

   end Register_Tests;

   ---------------------------------------------------------------
   function Suite return AUnit.Test_Suites.Access_Test_Suite is
   ---------------------------------------------------------------

      Test_Suite                 : constant AUnit.Test_Suites.Access_Test_Suite :=
                                    new AUnit.Test_Suites.Test_Suite;
      Tests                      : constant Test_Access := new Test_Type;

   begin
      Ada_Lib.Unit_Test.Suite (Suite_Name);  -- used for listing suites
      Test_Suite.Add_Test (Tests);
      return Test_Suite;
   end Suite;

   ---------------------------------------------------------------
   procedure Wait_For_Event(
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
      pragma Unreferenced (Test);
   ---------------------------------------------------------------

      type Check_Event_Type      is new Ada_Lib.Timer.Event_Type with
                                    null record;
      overriding
      procedure Callback (
         Event             : in out Check_Event_Type);

      type Delay_Event_Type      is new Ada_Lib.Timer.Event_Type with
                                    null record;
      overriding
      procedure Callback (
         Event             : in out Delay_Event_Type);

      Check_Time                 : constant Duration := 0.6;
      Delay_Time                 : constant Duration := 0.4;
      Test_Event                 : Event_Type (new String'("event description"));
      Wait_For_All               : constant Duration := 1.0;

      ------------------------------------------------------------
      overriding
      procedure Callback (
         Event             : in out Check_Event_Type) is
--    pragma Unreferenced (Event);
      ------------------------------------------------------------

      begin
         Log_In (Debug, Event.Description &
            " wait " & Event.Wait_Time'img &
            " started at " & Ada_Lib.Time.From_Start (Event.Start_Time, Hundreds => True));

         if not Test_Event.Event_Occured then
            Log_Out (Debug);
            Assert (False, "Wait_For_Event " &
               Event.Description & " did not occure");
         end if;
         Log_Out (Debug);
      end Callback;

      ------------------------------------------------------------
      overriding
      procedure Callback (
         Event             : in out Delay_Event_Type) is
      ------------------------------------------------------------

      begin
         Log_In (Debug, Event.Description &
            " wait " & Event.Wait_Time'img &
            " started at " & Ada_Lib.Time.From_Start (Event.Start_Time, Hundreds => True));

         Test_Event.Set_Event;
         Log_Out (Debug);
      end Callback;

   begin
      Log_In (Debug);
      declare
         Check_Timer             : aliased Check_Event_Type;
         Delay_Timer             : aliased Delay_Event_Type;

      begin
         Log_Here (Debug);
         Check_Timer.Start (
            Description    => "check",
            Dynamic        => False,
            Wait           => Check_Time);
         Delay_Timer.Start (
            Description    => "Delay",
            Dynamic        => False,
            Wait           => Delay_Time);
         Test_Event.Wait_For_Event;
         Log_Here (Debug);
         Assert (Test_Event.Event_Occured, "event occured not set");
         Log_Here (Debug);
         delay Wait_For_All;
      end;
      Log_Out (Debug);
   exception

      when Fault: AUNIT.ASSERTIONS.ASSERTION_ERROR =>
         Trace_Message_Exception (Fault, Who, Here);
         raise;

      when Fault: others =>
         Trace_Message_Exception (Fault, Who, Here);
         Assert (False, "exception " & Ada.Exceptions.Exception_Name (Fault) &
         " " & Ada.Exceptions.Exception_Message (Fault));
   end Wait_For_Event;

end Ada_Lib.Event.Unit_Test;

