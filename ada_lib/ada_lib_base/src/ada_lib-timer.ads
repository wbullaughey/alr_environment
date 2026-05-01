with Ada.Calendar;
--with Ada_Lib.Event;
with Ada.Finalization;
with Ada_Lib.Strings;
--with GNAT.Source_Info;
with Ada_Lib.Trace; use Ada_Lib.Trace;

package Ada_Lib.Timer is

   Failed                  : exception;   -- invalid request
   Overflow             : exception;   -- too many events

   Null_Time               : constant Ada.Calendar.Time :=
                           Ada.Calendar.Time_Of (
                              Year  => Ada.Calendar.Year_Number'last,
                              Month => Ada.Calendar.Month_Number'last,
                              Day      => Ada.Calendar.Day_Number'last,
                              Seconds  => 0.0);

   type Duration_Access    is access all Duration;

   type State_Type         is (Canceled, Completed, Finalized, Waiting,
                              Uninitialized);

   type Event_Type         is abstract new Ada.Finalization.Limited_Controlled
                                 with private;

   type Event_Access          is access all Event_Type;
   type Event_Class_Access    is access all Event_Type'class;

   function Active (
      Event             : in   Event_Type
   ) return Boolean;

   -- called when event occurs
   -- called from seperate task
   procedure Callback (
      Event             : in out Event_Type
   ) is abstract;

   -- cancel a scheduled event
   function Cancel (
      Event             : in out Event_Type;
      From              : in     String := Here
   ) return Boolean;

   -- cancel a scheduled event
   procedure Cancel (
      Event             : in out Event_Type;
      From              : in     String := Here);

   function Get_Exception (
      Event             : in     Event_Type
   ) return Ada_Lib.Strings.String_Access;

   function Description (
      Event             : in     Event_Type
   ) return String;

   overriding
   procedure Finalize (
      Event             : in out Event_Type);

   procedure Free (
      Event             : in out Event_Type);

   overriding
   procedure Initialize (
      Event             : in out Event_Type);

-- procedure Initialize (
--    Event                      : in out Event_Type;
--    Wait                       : in     Duration;
--    Description                : in     String := "";
--    Dynamic                    : in     Boolean := False;
--    Repeating                  : in     Boolean := False
-- ) with Pre => Wait > 0.0 and then
--               not Initialized (Event);

   function Initialized (
      Event                : in     Event_Type
   ) return Boolean;

   procedure Set_Description (
      Event                      : in out Event_Type;
      Description                : in     String);

   procedure Start (
      Event                      : in out Event_Type;
      Wait                       : in     Duration;
      Description                : in     String := "";
      Dynamic                    : in     Boolean;
      Repeating                  : in     Boolean := False
   ) with Pre => Wait > 0.0 and then
                 not Initialized (Event);

   function Start_Time (
      Event                : in     Event_Type
   ) return Ada.Calendar.Time
   with Pre => Initialized (Event);

   function State (
      Event                : in     Event_Type
   ) return State_Type
   with Pre => Initialized (Event);

   procedure Set_Trace (
      State             : in   Boolean);

   function Wait_Time (
      Event                : in     Event_Type
   ) return Duration;

   No_Timeout                    : constant Duration := Duration'last;
-- Trace                         : Boolean := False;

private

   task type Timer_Task_Type (
      Event                      : Event_Class_Access) is

      entry Cancel;

      entry Start ;

   end Timer_Task_Type;

   type Timer_Task_Access  is access Timer_Task_Type;

   Uninitialized_Event_Description
                           : aliased String := "uninitialized event";
   type Event_Type         is abstract new Ada.Finalization.Limited_Controlled
                                 with record
      Description          : Ada_Lib.Strings.String_Access_All :=
                              Uninitialized_Event_Description'unchecked_access;
      Dynamic              : Boolean := False;
      Exception_Message    : Ada_Lib.Strings.String_Access := Null;
      Exception_Name       : Ada_Lib.Strings.String_Access := Null;
      Initialized          : Boolean := False;
      Repeating            : Boolean := False;
--    Started              : Boolean := False;
      State                : State_Type := Uninitialized;
      Start_Time           : Ada.Calendar.Time := Null_Time;
      Timer_Task           : Timer_Task_Access := Null;
      Wait                 : Duration := 0.25;  -- uninitialized timeout
   end record;

end Ada_Lib.Timer;
