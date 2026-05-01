with Ada.Calendar;
with GNAT.Source_Info;

package Ada_Lib.Time is

   subtype Duration_Type         is Duration;
   subtype Time_Type             is Ada.Calendar.Time;

   function From_Start
   return Duration;

   function From_Start (
      Time                 : in   Ada.Calendar.Time
   ) return Duration;

   function From_Start (
      Time                 : in   Ada.Calendar.Time;
      Hundreds            : in   Boolean := False;
      Show_Days            : in   Boolean := False;
      From                 : in     String := GNAT.Source_Info.Source_Location
   ) return String;

   function From_Start (
      Hundreds            : in   Boolean := False;
      Show_Days            : in   Boolean := False
   ) return String;

   function Get_Start_Time
   return Ada.Calendar.Time;

   function Image (
      Time                       : in   Ada.Calendar.Time;
      Hundreths                  : in   Boolean := False
   ) return String;

   function Image (
      Time                       : in   Duration;
      Hundreths                  : in   Boolean := False;
      Show_Days                  : in   Boolean := False
   ) return String;

   Bad_Time                      : exception;
                        -- raise by Parse_Date_Time and
                        -- Parse_Duration if bad source format
   function Parse_Date_Time (
      Source                     : in   String
   ) return Ada.Calendar.Time;

   function Parse_Duration (
      Source                     : in   String
   ) return Duration;

   function To_Duration (
      Seconds                    : in   Float;
      Minutes                    : in   Natural := 0;
      Hours                      : in   Natural := 0
   ) return Duration;

   function Now
   return Ada.Calendar.Time         renames Ada.Calendar.Clock;


   No_Time                       : constant Ada.Calendar.Time :=
                                    Ada.Calendar.Time_Of (
                                       Year => Ada.Calendar.Year_Number'last,
                                       Month => Ada.Calendar.Month_Number'last,
                                       Day => Ada.Calendar.Day_Number'last,
                                       Seconds => Ada.Calendar.Day_Duration'last);

   Never                         : constant Ada.Calendar.Time :=
                                    Ada.Calendar.Time_Of (
                                       Year => Ada.Calendar.Year_Number'last,
                                       Month => Ada.Calendar.Month_Number'First,
                                       Day => Ada.Calendar.Day_Number'First,
                                       Seconds => Ada.Calendar.Day_Duration'First);
   No_Duration                   : constant Duration := Duration'last;

end Ada_Lib.Time;
