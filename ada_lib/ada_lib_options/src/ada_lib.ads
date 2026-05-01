with Ada.Calendar;
--with Ada.Exceptions;
--with GNAT.Source_Info;
--with System;

package Ada_Lib is

   Trace_Failure                 : exception;

   function Current_Task
   return String;

   Bits_Per_Byte        : constant := 8;
   Exception_Occured    : Boolean := False;
   No_Time              : constant Ada.Calendar.Time :=
                           Ada.Calendar.Time_Of (
                              Year => Ada.Calendar.Year_Number'last,
                              Month => Ada.Calendar.Month_Number'last,
                              Day => Ada.Calendar.Day_Number'last,
                              Seconds => Ada.Calendar.Day_Duration'last);
-- program built to do unit testing
-- --------------------------------------------------------------
--                    |        Build_Mode
--                    |  "execute"  | "help_test" |
--           -----------------------+----------------------------
--                    |   False     |   False     |  Help_Test
--             "TRUE" |-------------+----------------------------
--                    |   True      |   False     |  Unit_Testing
-- Unit_Test -----------------------+----------
--                    |   False     |   True      |  Help_Test
--            "FALSE" |-------------+----------------------------
--                    |   False     |   False     |  Unit_Testing
-- --------------------------------------------------------------

end Ada_Lib;
