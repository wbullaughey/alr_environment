with Ada.Exceptions;
with Ada_Lib.Parser;
with Ada_Lib.Strings;

--pragma Elaborate (Ada_Lib.Parser);

package body Ada_Lib.Time is

   use type Ada.Calendar.Time;

   Start_Time           : constant Ada.Calendar.Time :=
                           Ada.Calendar.Clock;

   --------------------------------------------------------------------
   function Get_Start_Time
   return Ada.Calendar.Time is
   --------------------------------------------------------------------

   begin
      return Start_Time;
   end Get_Start_Time;

   --------------------------------------------------------------------
   function From_Start
   return Duration is
   --------------------------------------------------------------------

   begin
      return From_Start (Ada.Calendar.Clock);
   end From_Start;

   --------------------------------------------------------------------
   function From_Start (
      Time                 : in   Ada.Calendar.Time
   ) return Duration is
   --------------------------------------------------------------------

   begin
      return Time - Start_Time;
   end From_Start;

   --------------------------------------------------------------------
   function From_Start (
      Hundreds             : in   Boolean := False;
      Show_Days            : in   Boolean := False
   ) return String is
   --------------------------------------------------------------------

   begin
      return From_Start (Ada.Calendar.Clock, Hundreds, Show_Days);
   end From_Start;

   --------------------------------------------------------------------
   function From_Start (
      Time                 : in   Ada.Calendar.Time;
      Hundreds            : in   Boolean := False;
      Show_Days            : in   Boolean := False;
      From                 : in     String := GNAT.Source_Info.Source_Location
   ) return String is
   pragma Unreferenced (From);
   --------------------------------------------------------------------

--offset : constant duration := Time - Start_Time;
   begin
      if Time = Ada_Lib.Time.No_Time then
         return "no time";
      else
--put_line ("time " & time'img & " start time " & Start_Time'img & " from start " & offset'img);
         return Image ((
            if Start_Time = Ada_Lib.Time.No_Time then
               0.0
            else
               Time - Start_Time),
            Hundreds, Show_Days);
      end if;
   end From_Start;

-- --------------------------------------------------------------------
-- function Get_Start_Time
-- return Ada.Calendar.Time is
-- --------------------------------------------------------------------
--
-- begin
--    return Start_Time;
-- end Get_Start_Time;

   -------------------------------------------------------------------
   function Image (
      Time              : in   Duration;
      Hundreths            : in   Boolean := False;
      Show_Days            : in   Boolean := False
   ) return String is
   -------------------------------------------------------------------

   begin
      if Time = No_Duration then
         return "no duration";
      end if;

      if Hundreths then
         return Ada_Lib.Strings.Format (Integer (Float'Floor (Float (Time))), Show_Days => Show_Days) & "." &
            Strings.Pad_Time (Integer'image (Integer (Time * 100) mod 100));
      else
         return Ada_Lib.Strings.Format (Integer (Time), Show_Days => Show_Days);
      end if;
   exception
      when Ada.Calendar.Time_Error =>
         return "INVALID";
   end Image;

   -------------------------------------------------------------------
   function Image (
      Time              : in   Ada.Calendar.Time;
      Hundreths            : in   Boolean := False
   ) return String is
   -------------------------------------------------------------------

      Year              : Ada.Calendar.Year_Number;
      Month             : Ada.Calendar.Month_Number;
      Day                  : Ada.Calendar.Day_Number;
      Seconds              : Ada.Calendar.Day_Duration;

   begin
      if Time = Ada_Lib.Time.No_Time then
         return "no time";
      end if;

      Ada.Calendar.Split (Time, Year, Month, Day, Seconds);

      if Hundreths then
         return
           Ada_Lib.Strings.Trim (Year'img) & "/" &
            Strings.Pad_Time (Month'img) & "/" &
            Strings.Pad_Time (Day'img) & " " &
            Ada_Lib.Strings.Format (Integer (Seconds)) & "." &
            Strings.Pad_Time (Integer'Image (Integer (Seconds * 100) mod 100));
      else
         return
           Ada_Lib.Strings.Trim (Year'img) & "/" &
            Strings.Pad_Time (Month'img) & "/" &
            Strings.Pad_Time (Day'img) & " " &
            Ada_Lib.Strings.Format (Integer (Seconds));
      end if;
   exception
      when Ada.Calendar.Time_Error =>
         return "INVALID";
   end Image;

   -------------------------------------------------------------------
   function Parse_Date_Time (
      Source               : in   String
   ) return Ada.Calendar.Time is
   -------------------------------------------------------------------

      procedure Raise_Bad_Time (
         Field          : in   String);

      pragma No_Return (Raise_Bad_Time);

      ---------------------------------------------------------------
      procedure Raise_Bad_Time (
         Field          : in   String) is
      ---------------------------------------------------------------

      begin
         Ada.Exceptions.Raise_Exception (Bad_Time'identity,
            "Invalid " & Field & " in Ada_Lib.Time.Parse_Date_Time source parameter '" &
               Source & "'");
      end Raise_Bad_Time;

      ---------------------------------------------------------------
      function Parse_Time (
         Value          : in   String)
      return Duration is
      ---------------------------------------------------------------
         subtype Hour_Type    is Integer range 0 .. 23;
         subtype Minute_Type     is Integer range 0 .. 59;
         subtype Second_Type     is Integer range 0 .. 59;

         Hour              : Hour_Type;
         Iterator          : Ada_Lib.Parser.Iterator_Type :=
                              Ada_Lib.Parser.Initialize (
                                 Value                =>Ada_Lib.Strings.Trim (Value),
                                 Seperators              => ":",
                                 Ignore_Multiple_Seperators => False);
         Minute               : Minute_Type;
         Second               : Second_Type;

      begin
         Hour := Hour_Type'value (Ada_Lib.Parser.Get_Value (Iterator));
         Ada_Lib.Parser.Next (Iterator);

         Minute := Minute_Type'value (Ada_Lib.Parser.Get_Value (Iterator));
         Ada_Lib.Parser.Next (Iterator);

         Second := Second_Type'value (Ada_Lib.Parser.Get_Value (Iterator));
         Ada_Lib.Parser.Next (Iterator);

         if not Ada_Lib.Parser.At_End (Iterator) then
            Raise_Bad_Time ("time");
         end if;

         return Duration (((Hour * 60) + Minute) * 60 + Second);

      exception
         when  Constraint_Error |
               Ada_Lib.Parser.Underflow =>
            Raise_Bad_Time ("time");

      end Parse_Time;
      ---------------------------------------------------------------

      Day                  : Ada.Calendar.Day_Number;
      Iterator          : Ada_Lib.Parser.Iterator_Type :=
                           Ada_Lib.Parser.Initialize (
                              Value                =>Ada_Lib.Strings.Trim (Source),
                              Seperators              => " ",
                              Ignore_Multiple_Seperators => False);
      Month             : Ada.Calendar.Month_Number;
      Now                  : constant Ada.Calendar.Time := Time.Now;
      Time              : Duration;
      Year              : Ada.Calendar.Year_Number;

   begin
      declare
         Field       : constant String := Ada_Lib.Parser.Get_Value (Iterator);

      begin
         Ada_Lib.Parser.Next (Iterator);

         -- Field is a date
         if not Ada_Lib.Parser.At_End (Iterator) then
            declare
               Date_Iterator        : Ada_Lib.Parser.Iterator_Type :=
                                    Ada_Lib.Parser.Initialize (
                                       Value                =>Ada_Lib.Strings.Trim (Field),
                                       Seperators              => "/",
                                       Ignore_Multiple_Seperators => False);

            begin
               declare
                  Year_Value        : constant Natural :=
                                    Natural'value (
                                       Ada_Lib.Parser.Get_Value (Date_Iterator));

               begin
                  if Year_Value < 100 then
                     Year := Year_Value + 2000;
                  else
                     Year := Year_Value;
                  end if;
               end;

               Ada_Lib.Parser.Next (Date_Iterator);

               Month := Ada.Calendar.Month_Number'value (Ada_Lib.Parser.Get_Value (Date_Iterator));
               Ada_Lib.Parser.Next (Date_Iterator);

               Day := Ada.Calendar.Day_Number'value (Ada_Lib.Parser.Get_Value (Date_Iterator));
               Ada_Lib.Parser.Next (Date_Iterator);

               if not Ada_Lib.Parser.At_End (Date_Iterator) then
                  Raise_Bad_Time ("date");
               end if;
            end;

            Time := Parse_Time (Ada_Lib.Parser.Get_Value (Iterator));

         else
            Year := Ada.Calendar.Year (Now);
            Month := Ada.Calendar.Month (Now);
            Day := Ada.Calendar.Day (Now);

            Time := Parse_Time (Field);
         end if;
      end;

      return Ada.Calendar.Time_Of (Year, Month, Day, Time);

   exception
         when  Constraint_Error |
               Ada_Lib.Parser.Underflow =>
         Raise_Bad_Time ("date");

   end Parse_Date_Time;

   -------------------------------------------------------------------
   function Parse_Duration (
      Source               : in   String
   ) return Duration is
   -------------------------------------------------------------------

      ---------------------------------------------------------------
      procedure Raise_Bad_Time is
      ---------------------------------------------------------------

      begin
         Ada.Exceptions.Raise_Exception (Bad_Time'identity,
            "Invalid parameter for Ada_Lib.Time.Parse_Duration source parameter '" &
            Source & "'");
      end Raise_Bad_Time;
      ---------------------------------------------------------------

      Iterator          : Ada_Lib.Parser.Iterator_Type :=
                           Ada_Lib.Parser.Initialize (
                              Value                => Ada_Lib.Strings.Trim (Source),
                              Seperators              => ":",
                              Ignore_Multiple_Seperators => False);
      Time_Fields          : array (1 .. 4) of Natural;
      Time_Fields_Count    : Natural := 0;

   begin
      while not Ada_Lib.Parser.At_End (Iterator) loop
         Time_Fields_Count := Time_Fields_Count + 1;

         if Time_Fields_Count > 4 then
            Raise_Bad_Time;
         end if;

         Time_Fields (Time_Fields_Count) := Natural'value (Ada_Lib.Parser.Get_Value (Iterator));

         Ada_Lib.Parser.Next (Iterator);
      end loop;


      declare
         type Seconds_Type is range 0 .. 16#7FFF_FFFF_FFFF_FFFF#;

         Result            : Seconds_Type := 0;

      begin

         for Index in 1 .. Time_Fields_Count loop
            if Time_Fields_Count - Index < 2 then
               Result := Result * 60 + Seconds_Type (Time_Fields (Index));
            else
               Result := Result * 24 + Seconds_Type (Time_Fields (Index));
            end if;
         end loop;

         return Duration (Result);
      end;

   exception
      when Constraint_Error =>
         Raise_Bad_Time;
         return 0.0;

   end Parse_Duration;

   -------------------------------------------------------------------
   function To_Duration (
      Seconds              : in   Float;
      Minutes              : in   Natural := 0;
      Hours             : in   Natural := 0
   ) return Duration is
   -------------------------------------------------------------------

   begin
      return Duration ((Hours * 60 + Minutes) * 60) + Duration (Seconds);
   end To_Duration;

end Ada_Lib.Time;
