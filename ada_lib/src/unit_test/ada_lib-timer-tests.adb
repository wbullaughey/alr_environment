with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Simple_Test_Cases;
with AUnit.Test_Cases;

package body Ada_Lib.Timer.Tests is

   use type Ada_Lib.Strings.String_Access;
   use type Ada_Lib.Time.Time_Type;

   procedure Single_Event (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Wait_For_Event (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   Criteria                      : constant Duration := 0.2;
                                    -- limit of actual event from expected

   ---------------------------------------------------------------------------
   function Allocate_Event (
      Offset                     : in     Duration;
      Description                : in     String := ""
   ) return Test_Timer_Class_Access is
   ---------------------------------------------------------------------------

      Result                     : constant Test_Timer_Class_Access :=
                                     new Test_Timer_Type;
   begin
      Log_Here (Debug, Quote ("description", Description) &
         " offset " & Offset'img);
      Result.Start (
            Description    => Description,
            Dynamic        => True,
            Wait           => Offset);
      return Result;
   end Allocate_Event;

 ---------------------------------------------------------------
   overriding
   procedure Callback (
      Event             : in out Test_Timer_Type) is
 ---------------------------------------------------------------

   begin
      Event.Occurred := True;
      Event.Occured_At := Ada_Lib.Time.Now;
      Log_Here (Debug, Quote ("description", Event.Description) &
         " occured at " & Ada_Lib.Time.From_Start (Event.Occured_At, True));
   end Callback;

   ---------------------------------------------------------------
   procedure Cancel_Event (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

   -- test with 3 events
   -- 1st event is longest
   -- 2nd event is shortest
   -- 3rd event is middle event and is canceled after 2nd event has occured
   -- 2 passes selectin which is dynamic
   -- 1st pass 2nd is dynamic
   -- 2nd pass 3rd is dynamic

      Number_Events              : constant := 3;
      Cancel_Event_Index         : constant Natural := 3;   -- event to cancel
      Expect_Active              : constant Array (1 .. Number_Events) of Boolean := (
                                    True,       -- last event should not be canceled,
                                    False,      -- event should occure before cancel,
                                    False);     -- event canceled
      Event_Times                : constant Array (1 .. Number_Events) of Duration := (
                                       1.5, 0.5, 1.0);

      ---------------------------------------------------------------
      function Failure_Message (
         Index                   : in     Natural;
         Offset                  : in     Duration;
         Event                   : Test_Timer_Type
      ) return String is
      ---------------------------------------------------------------

   begin
         return
            "event" & Index'img &
            " Occurred at wrong time. Offset " & Offset'img  &
            " expected active " & Expect_Active (Index)'img &
            " cancel event " & Boolean'(Index =
               Cancel_Event_Index)'img &
            Quote (" description ", Event.Description.all);
      end Failure_Message;
      ---------------------------------------------------------------

   begin
      Log_In (Debug);
      declare
         Event_1                 : aliased Test_Timer_Type;
      begin
         Log_Here (Debug, "event 1 created canceled " & Event_1.Cancel'img);
      end;
      Log_Here (Debug, "event 1 finalized");

      declare
         Event_2                 : aliased Test_Timer_Type;
      begin
         Log_Here (Debug, "event 2 created canceled " & Event_2.Cancel'img);
      end;
      Log_Here (Debug, "event 2 finalized");

      declare
         Event_3                 : aliased Test_Timer_Type;
      begin
         Log_Here (Debug, "event 3 created canceled " & Event_3.Cancel'img);
      end;
      Log_Here (Debug, "event 3 finalized");

      for Dynamic_Index in 2 .. 3 loop -- select which event is dynamic
         Log_Here (Debug, "dynamic" & Dynamic_Index'img);
         declare
            Event_1                    : aliased Test_Timer_Type;
            Event_2                    : aliased Test_Timer_Type;
            Event_3                    : aliased Test_Timer_Type;

         begin
            Log_Here (Debug, "Dynamic_Index" & Dynamic_Index'img);
            declare
               Active_Events        : Event_Pointers_Type (1 .. Number_Events);

            begin
               for Index in Active_Events'range loop   -- create events
                  declare
                     Event             : Test_Timer_Class_Access renames
                                          Active_Events (Index);
                  begin
                     Log_Here (Debug, "index" & Index'img);
                     Event := (case Index is

                        when 1 =>
                           Event_1'unchecked_access,
                        when 2 =>
                           Event_2'unchecked_access,
                        when 3 =>
                           Event_3'unchecked_access);

                     if Index = Dynamic_Index then
                        Log_Here (Debug, "cancel unused event. result " &
                           Event.Cancel'img);  -- cancel the static one
                        Event := Allocate_Event (
                                 Description    => "dynamic event",
                                 Offset         => Event_Times (Dynamic_Index));
                     else
                        Event.Start (
                              Description    => "static" & Index'img,
                              Dynamic        => False,
                              Wait           => Event_Times (Index));
                     end if;
                     Log_Here (Debug, "index" & Index'img &
                        " state " & Event.State'img &
                        " wait " & Event.Wait'img &
                        " start " & Ada_Lib.Time.From_Start (Event.Start_Time) &
                        Quote (" description", Event.Description));

                  end;
               end loop;

               declare
                  All_Occured       : Boolean := False;
                  Cancel_Event      : Test_Timer_Type'class renames
                                       Active_Events (Cancel_Event_Index).all;
                  Event_Canceled          : Boolean := False;
                  Failed_Time       : constant Ada_Lib.Time.Time_Type :=
                                       Ada_Lib.Time.Now + 1.75;   -- after last event
               begin
                  delay 0.75; -- after 1st event and before end of cancel event;
                  Log_Here (Debug, "cancel Index" & Cancel_Event_Index'img);
                  Event_Canceled := Cancel_Event.Cancel; -- cancel middle event
                  Log_Here (Debug, " canceled " & Event_Canceled'img);

                  Assert (Event_Canceled, "with dynamic event" & Dynamic_Index'img &
                     " event" & Cancel_Event_Index'img & " not canceled");

                  for Index in Active_Events'range loop
                     Log_Here (Debug, "index" & Index'img &
                        " dynamic" & Dynamic_Index'img);
                     if    Index /= Dynamic_Index and then
                           -- cancled dynamic was freed
                           Index /= Cancel_Event_Index then
                        declare
                           Event          : Test_Timer_Type'class renames
                                             Active_Events (Index).all;
                           Active         : constant Boolean := Event.Active;
                           Expected       : constant Boolean := Expect_Active (Index);

                        begin
                           Log_Here (Debug, "index" & Index'img &
                              Quote ( " description", Event.Description) &
                              " event active " & Active'img &
                              " expected " & Expected'img);
                           Assert (Active = Expected,
                              Quote ("description", Event.Description) &
                              " index" & Index'img & " expected to be " &
                              (if Expected then
                                 "active but was not."
                              else
                                 "in active but was active."));
                        end;
                     end if;
                  end loop;

                  Log_Here (Debug);
                  loop     -- wait for all events to occure
                     All_Occured := True;
                     for Index in 1 .. Number_Events loop
                        declare
                           Event    : Test_Timer_Type'class renames
                                       Active_Events (Index).all;
                           Fault    : constant Ada_Lib.Strings.String_Access :=
                                       Event.Get_Exception;
                        begin
                           Log_Here (Debug, "index" & Index'img &
                              " state " & Event.State'img &
                              " dynamic" & Dynamic_Index'img);
                           if Fault /= Null then
                              Assert (False, "exception " &
                                 Fault.all & " in timer task");

                           end if;

                           case Event.State is

                              when Canceled =>
                                 Assert (Index = Cancel_Event_Index,
                                    "wrong event" & Index'img &
                                    Quote ( " description", Event.Description) &
                                    " cancled");

                              when Waiting =>
                                 Log_Here (Debug, Index'img &
                                    Quote ( " description", Event.Description) &
                                    " still waiting");
                                 if Ada_Lib.Time.Now > Failed_Time then
                                    Assert (False, "not all events completed");
                                 end if;
                                 All_Occured := False;

                              when Uninitialized | Completed | Finalized =>
                                 Log_Here (Debug, Index'img & " not waiting");

                           end case;
                        end;
                     end loop;

                     if All_Occured then
                        Log_Here (Debug, "all Occurred");
                        exit;
                     end if;

                     delay 0.1;
                  end loop;
                                             -- all events completed or canceled
                  Log_Here (Debug);
                  for Index in 1 .. Number_Events loop
--                   if    Index = Dynamic_Index then
                        declare
                           Event       : Test_Timer_Type'class renames
                                          Active_Events (Index).all;
                           Expected    : constant Ada_Lib.Time.Time_Type :=
                                       Event.Start_Time + Event_Times (Index);
                           Offset      : constant Duration := (if Event.Occurred then
                                             abs (Expected - Event.Occured_At)
                                          else
                                             0.0);
                        begin
                           Log_Here (Debug, "index" & Index'img &
                           " start time " & Ada_Lib.Time.From_Start (Event.Start_Time, True) &
                              " expected " & Ada_Lib.Time.From_Start (Expected, True) &
                              (if Event.Occurred then
                                    " occured at " & Ada_Lib.Time.From_Start (Event.Occured_At, True) &
                                    " offset " & Offset'img
                                 else
                                    " not occured") &
                              " event time " & Event_Times (Index)'img);

                        Assert (Offset < Criteria, Failure_Message (
                           Index, Offset, Test_Timer_Type (Event)));
                        end;
--                   end if;
                  end loop;
                  Log_Here (Debug);

               exception
                  when Fault: AUNIT.ASSERTIONS.ASSERTION_ERROR =>
                     Trace_Message_Exception (Fault, "assert Occurred");
                     return;
               end;

            exception
               when Fault: others =>
                  Trace_Message_Exception (Fault, "error in library");
                  Assert (False, "library failed");

            end;
         end;
      end loop;
      Log_Out (Debug);

   exception

      when Fault: others =>
         Trace_Message_Exception (Fault, "error in library");
         Assert (False, "library failed");

   end Cancel_Event;

   ---------------------------------------------------------------
   procedure Finalize_Event (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------


   begin
      Log_In (Debug);

      declare
         Static_Event            : aliased Test_Timer_Type;

      begin
         Static_Event.Start (
            Description    => "static",
            Dynamic        => False,
            Wait           => 0.2);
         Log_Here (Debug, "state " & Static_Event.State'img);
      end;
      Log_Out (Debug);

   exception

      when Fault: others =>
         Trace_Message_Exception (Fault, "error in library");
         Assert (False, "library failed");

   end Finalize_Event;

   ---------------------------------------------------------------
   procedure Multiple_Events (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

      Dynamic_Index              : constant := 2;
      Number_Events              : constant := 3;

      Event_Times                : constant Array (1 .. Number_Events) of
                                    Duration := (1.5, 0.5, 1.0);
      Event_1                    : aliased Test_Timer_Type;
      Event_3                    : aliased Test_Timer_Type;

   begin

      Log_In (Debug);
      Event_1.Start (
         Description    => "static 1",
         Dynamic        => False,
         Wait           => Event_Times (1));
      Event_3.Start (
         Description    => "static 3",
         Dynamic        => False,
         Wait           => Event_Times (3));
      declare
         Events                  : Event_Pointers_Type (1 .. Number_Events);

      begin
         for Index in 1 .. Number_Events loop
            declare
               Event             : Test_Timer_Class_Access renames Events (Index);

            begin
               case Index is

                  when 1 =>
                     Event := Event_1'unchecked_access;

                  when Dynamic_Index =>
                     Event := Allocate_Event (
                        Description    => "dynamic",
                        Offset         => Event_Times (Dynamic_Index));

                  when 3 =>
                     Event := Event_3'unchecked_access;

               end case;
            end;
         end loop;

         declare
            All_Occured          : Boolean := False;
--          Start_Time           : constant Ada_Lib.Time.Time_Type := Ada_Lib.Time.Now;

         begin
            Log_Here (Debug);
            loop
               All_Occured := True;
               for Event of Events loop
                  if not Event.Occurred then
                     All_Occured := False;
                  end if;
               end loop;

               if All_Occured then
                  Log_Here (Debug, "all Occurred");
                  exit;
               end if;

               delay 0.1;
            end loop;
            Log_Here (Debug);

            for Index in 1 .. Number_Events loop
               declare
                  Event          : Test_Timer_Type'class renames Events (Index).all;
                  Expected       : constant Ada_Lib.Time.Time_Type :=
                                    Event.Start_Time + Event_Times (Index);
                  Offset         : constant Duration :=
                                    abs (Expected - Event.Occured_At);
               begin
                  Log_Here (Debug, "test"& Index'img &
                     " expected " & Ada_Lib.Time.From_Start (Expected, True) &
                     " occured at " & Ada_Lib.Time.From_Start (Event.Occured_At, True) &
                     " start time " & Ada_Lib.Time.From_Start (Event.Start_Time, True) &
                     " event time " & Event_Times (Index)'img &
                     " offset " & Offset'img);

                  Assert (Offset < Criteria,
                     "event" & Index'img & " Occurred at wrong time. Offset " &
                        Offset'img);

               end;
            end loop;
            Log_Here (Debug);

         exception
            when Fault: AUNIT.ASSERTIONS.ASSERTION_ERROR =>
               Trace_Message_Exception (Fault, "assert Occurred");
               return;
         end;

      exception
         when Fault: others =>
            Trace_Message_Exception (Fault, "error in library");
            Assert (False, "library failed");

      end;
      Log_Out (Debug);

   exception

      when Fault: others =>
         Trace_Message_Exception (Fault, "error in library");
         Assert (False, "library failed");

   end Multiple_Events;

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
         Routine        => Finalize_Event'access,
         Routine_Name   => AUnit.Format ("Finalize_Event")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Cancel_Event'access,
         Routine_Name   => AUnit.Format ("Cancel_Event")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Single_Event'access,
         Routine_Name   => AUnit.Format ("Single_Event")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Multiple_Events'access,
         Routine_Name   => AUnit.Format ("Multiple_Events")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Wait_For_Event'access,
         Routine_Name   => AUnit.Format ("Wait_For_Event")));

      Log_Out (Debug);
   end Register_Tests;

   ---------------------------------------------------------------
   procedure Single_Event (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

      Wait_Time                  : constant Duration := 0.5;
      Static_Event               : aliased Test_Timer_Type;

   begin
      Log_In (Debug);
      Static_Event.Test_Ada_2022 := @ + 1;
      Static_Event.Start (
         Description    => "static",
         Dynamic        => False,
         Wait           => Wait_Time);

      for Dynamic in Boolean'range loop
         declare
            Event                   : constant Test_Timer_Class_Access := (if Dynamic then
                                          Allocate_EVent (
                                             Description    => "dynamic",
                                             Offset         => Wait_Time)
                                       else
                                          Static_Event'unchecked_access);
         begin
            Log_Here (Debug, "dynamic " & Dynamic'img);
            while not Event.Occurred loop
               delay 0.1;
            end loop;

            declare
               Elapsed_Time      : constant Duration := Ada_Lib.Time.Now -
                                    Event.Occured_At;
            begin
               Log_Here (Debug, "elapse time " & Elapsed_Time'img);
               Assert (Abs (Elapsed_Time) < Criteria, "elapse time " &
                  Elapsed_Time'img & " too long");

            exception
               when Fault: AUNIT.ASSERTIONS.ASSERTION_ERROR =>
                  Trace_Message_Exception (Fault, "assert Occurred");
                  return;
            end;

            if Dynamic then
               Event.Free;
            end if;

         exception
            when Fault: others =>
               Trace_Message_Exception (Fault, "error in library");
               Assert (False, "library failed");

         end;
      end loop;
      Log_Out (Debug);

   exception

      when Fault: others =>
         Trace_Message_Exception (Fault, "error in library");
         Assert (False, "library failed");

   end Single_Event;

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

   ---------------------------------------------------------------
   procedure Wait_For_Event (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

   begin
      Log_In (Debug);
      declare
         Wait_Canceled              : Boolean := False;
         Wait_Event                 : Test_Timer_Type;

         procedure Timed_Out;

         package Timeout is new Timeout_Package (Timed_Out);

         Timeout_Event              : Timeout.Timeout_Timer_Type;

         ---------------------------------------------------------------
         procedure Timed_Out is
         ---------------------------------------------------------------

         begin
            Log_Here (Debug);
            Wait_Canceled := True;
            Assert (Wait_Event.Cancel, "could not cancel wait event");
         end Timed_Out;
         ---------------------------------------------------------------

      begin
         Timeout_Event.Start (
            Description    => "timeout event",
            Dynamic        => False,
            Wait           => 0.5);
         Wait_Event.Start (
            Description    => "wait event",
            Dynamic        => False,
            Wait           => 0.2);

   --    Wait_Event.Wait_For_Event;
         Log_Here (Debug);
         Assert (Timeout_Event.Cancel, "could not cancel timeout event");
         Assert (not Wait_Canceled, "wait event got canceled");
      end;
      Log_Out (Debug);

   exception

      when Fault: others =>
         Trace_Message_Exception (Fault, "error in library");
         Assert (False, "library failed");

   end Wait_For_Event;

   ---------------------------------------------------------------
   package body Timeout_Package is

      ---------------------------------------------------------------
      overriding
      procedure Callback (
         Event             : in out Timeout_Timer_Type) is
      pragma Unreferenced (Event);
      ---------------------------------------------------------------

      begin
         Timed_Out;
      end Callback;

   end Timeout_Package;
   ---------------------------------------------------------------

begin
--Debug := True;
   Log_Here (Elaborate or Trace_Options);
end Ada_Lib.Timer.Tests;