--with Ada.Exceptions;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
--with Ada.Text_IO; use  Ada.Text_IO;
with Ada_Lib.Trace; use Ada_Lib.Trace;

with Ada_Lib.Database;

package body Ada_Lib.Event is

   -------------------------------------------------------------------
   function Event_Occured (
      Object                     : in     Event_Type
   ) return Boolean is
   -------------------------------------------------------------------

      Result                     : constant Boolean :=
                                    Object.Event_Object.Did_Occure;
   begin
      Log_Here (Debug, Quote ("event", Object.Description) &
         " occured " & Result'img);
      return Result;
   end Event_Occured;

   -------------------------------------------------------------------
   procedure Reset_Event (
      Object                     : in out Event_Type) is
   -------------------------------------------------------------------

   begin
      Object.Event_Object.Reset;
   end Reset_Event;

   -------------------------------------------------------------------
   procedure Set_Event (
      Object                     : in out Event_Type;
      From                       : in     String := GNAT.Source_Info.Source_Location) is
   -------------------------------------------------------------------

      Is_Locked                  : constant Boolean := Object.Event_Object.Did_Occure;

   begin
      Log_In (Debug, Quote ("event", Object.Description) &
         " from " & From & " locked " & Is_Locked'img );

      Object.Event_Object.Set_Occured (From);
      Log_Out (Debug);
   end Set_Event;

   -------------------------------------------------------------------
   procedure Wait_For_Event (
      Object                     : in out Event_Type;
      From                       : in     String := GNAT.Source_Info.Source_Location) is
   -------------------------------------------------------------------

   begin
      Log_In (Debug, Quote ("event ", Object.Description));
      Object.Event_Object.Wait_For_Event (From);
      Log_Out (Debug);
   end Wait_For_Event;

   protected body Protected_Event is
   -------------------------------------------------------------------

      ---------------------------------------------------------------
      function Did_Occure return Boolean is
      ---------------------------------------------------------------

      begin
         Log_Here (Debug, Quote ("event", Description) &
            " occured " & Occured'img);
         return Occured;
      end Did_Occure;

      ---------------------------------------------------------------
      procedure Reset is
      ---------------------------------------------------------------

      begin
         Occured := False;
      end Reset;

      ---------------------------------------------------------------
      procedure Set_Occured (
         From                    : in     String) is
      ---------------------------------------------------------------

      begin
         Log_Here (Debug, Quote ("description ", Description) &
            " occured " & Occured'img);
         if Occured then
            raise Failed with Quote ("event ", Description) &
               " allready occured from " & From;
         end if;
         Occured := True;
      end Set_Occured;

      ---------------------------------------------------------------
      entry Wait_For_Event (
         From                    : in     String
      ) when Occured is
      ---------------------------------------------------------------

      begin
         Log_Here (Debug, Quote ("event", Description) &
            " from " & From);
      end Wait_For_Event;

   end Protected_Event;

begin
--debug := true;
-- Ada_Lib.Trace.Elaborate := True;
   Log_Here (Elaborate or Trace_Options);
--log_here("size Database_Type " & Ada_Lib.Database.Database_Type'size'img);
end Ada_Lib.Event;
