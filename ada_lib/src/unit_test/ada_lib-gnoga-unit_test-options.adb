--with Ada.Unchecked_Deallocation;
with Ada.Text_IO;use Ada.Text_IO;
--with GNOGA_Ada_Lib.Base;
--with Ada_Lib.GNOGA.Unit_Test.Events;
with Ada_Lib.Help;
--with Ada_Lib.Options.Create;
with Ada_Lib.Options.Runstring;
with Ada_Lib.Options.Unit_Test;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Trace; use Ada_Lib.Trace;
--with Gnoga.Application.Multi_Connect;

--pragma Elaborate_All (Ada_Lib.Command_Line_Iterator);

package body Ada_Lib.GNOGA.Unit_Test.Options is

   Trace_Option            : constant Character := 'g';
   Options_With_Parameters : aliased constant
                              Ada_Lib.Options.Flag_List_Type :=
                                 Ada_Lib.Options.Initialize (Trace_Option,
                                    Ada_Lib.Options.Unmodified_flag);

   -------------------------------------------------------------------
   overriding
   function Initialize (
     Options                     : in out GNOGA_Unit_Test_Options_Type;
     From                        : in     String := Standard.Ada_Lib.Trace.Here
   ) return Boolean is
   -------------------------------------------------------------------

   begin
      Log_In (Debug_Options or Trace_Options, Tag_Name ("options",
         GNOGA_Unit_Test_Options_Type'class (Options)'tag) & " from " & From);
--    GNOGA_Options := Options'unchecked_access;
      Ada_Lib.Options.Runstring.Options.Register (Ada_Lib.Options.Runstring.
         With_Parameters, Options_With_Parameters);
      return Log_Out (Ada_Lib.Options.Nested.Nested_Options_Type (
         Options).Initialize, Debug_Options or Trace_Options);
   end Initialize;

   ---------------------------------------------------------------
   overriding
   function Process_Option (
      Options                    : in out GNOGA_Unit_Test_Options_Type;
      Iterator                   : in out Ada_Lib.Options.Command_Line_Iterator_Interface'class;
      Option                     : in     Ada_Lib.Options.Flag_Option_Type'class
   ) return Boolean is
   ---------------------------------------------------------------

      use Ada_Lib.Options;

   begin
      Log_In (Trace_Options or Debug_Options, Option.Image);
      if Ada_Lib.Options.Has_Option (Option,
            Options_With_Parameters, Ada_Lib.Options.Null_Flag_List) then
         if Option.Modified then
            return False;
         else     -- not Modified
            case Option.Option is

               when 'g' =>   -- options for GNOGA
                  Options.Trace_Parse (Iterator);

               when Others =>
                  raise Failed with "Has_Option incorrectly passed " & Option.Image;

            end case;
         end if;
      else
         return Log_Out (Ada_Lib.Options.Nested.Nested_Options_Type (
            Options).Process_Option (Iterator, Option),
            Trace_Options or Debug_Options);
      end if;
      return Log_Out (True, Debug_Options or Trace_Options);
   end Process_Option;

   ----------------------------------------------------------------------------
   overriding
   procedure Program_Help (
      Options                    : in      GNOGA_Unit_Test_Options_Type;
      Help_Mode                  : in      Ada_Lib.Options.Help_Mode_Type) is
   ----------------------------------------------------------------------------

      Component                  : constant String := "Ada_Lib.GNOGA";

   begin
      Log_In (Debug_Options or Trace_Options, "mode " & Help_Mode'img);
      case Help_Mode is

      when Ada_Lib.Options.Program_Mode =>
         Standard.Ada_Lib.Help.Create_Option ('g', True, "trace options",
            "GNOGA Unit Test traces", Component, Ada_Lib.Help.Unmodified_Flag);

      when Ada_Lib.Options.Trace_Mode =>
         Ada_Lib.Help.Set_Has_Trace ('g', Ada_Lib.Help.Unmodified_Flag);
         Put_Line ("Ada_Lib GNOGA unit tests trace options (-" &
            Trace_Option & ")");
         Put_Line ("      a               all");
         Put_Line ("      b               Ada_Lib.GNOGA.Unit_Test.Base_Debug");
         Put_Line ("      d               Ada_Lib.GNOGA.Unit_Test.Debug");
         Put_Line ("      e               Ada_Lib.GNOGA.Unit_Test.Event_Debug");
         Put_Line ("      g               Ada_Lib.GNOGA.GNOGA_Debug");
         Put_Line ("      u               GNOGA unit Test (main window)");
--       Put_Line ("      o               Ada_Lib.GNOGA.Unit_Test.Options.Debug_Options");
         New_Line;

      end case;
      Ada_Lib.Options.Nested.Nested_Options_Type (Options).Program_Help (
         Help_Mode);
      Log_Out (Debug_Options  or Trace_Options);
   end Program_Help;

   ----------------------------------------------------------------------------
   overriding
   procedure Trace_Parse (
      Options                    : in out GNOGA_Unit_Test_Options_Type;
      Iterator                   : in out Ada_Lib.Options.Command_Line_Iterator_Interface'class) is
   ----------------------------------------------------------------------------

      Parameter                  : constant String := Iterator.Get_Parameter;

   begin
      Log_In (Debug_Options or Trace_Options);
      for Index in Parameter'range  loop
         declare
            Trace    : constant Character := Parameter (Index);

         begin
            Log (Debug_Options or Trace_Options, Here, Who &
               Quote (" Parameter", Parameter) & Quote (" Trace", Trace));
            case Trace is

               when 'a' =>
                  Ada_Lib.Options.Unit_Test.Ada_Lib_GNOGA_Unit_Test.
                     Base_Debug := True;
                  Ada_Lib.Options.Unit_Test.Ada_Lib_GNOGA_Unit_Test.
                     Event_Debug := True;

               when 'b' =>
                  Ada_Lib.Options.Unit_Test.Ada_Lib_GNOGA_Unit_Test.
                     Base_Debug := True;

               when 'd' =>
                  Ada_Lib.Options.Unit_Test.Ada_Lib_GNOGA_Unit_Test.
                     Test_Debug := True;

               when 'e' =>
                  Ada_Lib.Options.Unit_Test.Ada_Lib_GNOGA_Unit_Test.
                     Event_Debug := True;

               when 'g' =>
                  Ada_Lib.Options.Unit_Test.Ada_Lib_GNOGA_Unit_Test.
                     GNOGA_Debug := True;

               when others =>
                  Options.Bad_Option (Trace);

            end case;


         end;
      end loop;
      Log_Out (Debug_Options or Trace_Options);
   end Trace_Parse;

begin
--Trace_Tests := True;
--   if Trace_Tests then
--      Debug := Trace_Tests;
--   end if;
----Debug := True;
--Debug_Options := True;
--Trace_Options := True;
   Log_Here (Trace_Options or Elaborate);
end Ada_Lib.GNOGA.Unit_Test.Options;
