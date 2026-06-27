with Ada.Text_IO;use Ada.Text_IO;
with Ada_Lib.Help;
--with Ada_Lib.Options.Create;

package body Ada_Lib.Trace.Options is

   Failed                        : exception;

   Debug                         : constant Boolean := False; -- fix this
-- Options_With_Parameters    : aliased constant
--                                  Ada_Lib.Options.Flag_List_Type :=
--                                     Ada_Lib.Options.Initialize (
--                                        'u', Ada_Lib.Help.Modifier);
   Options_Without_Parameters    : aliased constant
                                    Ada_Lib.Options.Flag_List_Type :=
                                       Ada_Lib.Options.Initialize (
                                          'u', Ada_Lib.Help.Modifier);
   Trace_Option                  : constant Character := 'U';

   --------------------------------------------------------------------
   overriding
   procedure Display_Help (            -- common for all programs that use GNOGA_Options
                              -- prints full help, aborts program
     Options                     : in     Ada_Lib_Trace_Options_Type;  -- only used for dispatch
     Parameters                  : in     Ada_Lib.Options.Argument_Array;
     Message                     : in     String := "";   -- leave blank no error help
     Halt                        : in     Boolean := True) is
   pragma Unreferenced (Parameters, Options, Message, Halt);
   --------------------------------------------------------------------

   begin
not_implemented;
   end Display_Help;

   --------------------------------------------------------------------
   overriding
   function Process_Option (
      Options  : in out Ada_Lib_Trace_Options_Type;
      Iterator : in out Ada_Lib.Options.Command_Line_Iterator_Interface'class;
      Option   :in         Ada_Lib.Options.Flag_Option_Type'class
   ) return Boolean is
   --------------------------------------------------------------------

      Has_It                     : constant Boolean :=
                                    Ada_Lib.Options.Has_Option (Option,
                                       Ada_Lib.Options.Null_Flag_List,
                                       Options_Without_Parameters);
   begin
      Log_In (Trace_Options or Debug, Option.Image &
         " has options " & Has_It'img &
         " Options address " & Ada_Lib.Strings.Image (Options'address));

      if Has_It then
         if Option.Modified then
            return Log_Out (False, Trace_Options or Debug);
         end if;

         case Option.Option is

            when Others =>
               Log_Exception (Trace_Options or Debug, " other option" & Option.Image);
               raise Failed with "Has_Option incorrectly passed " & Option.Image;
         end case;

--       return Log_Out (True, Trace_Options or Debug);

      else
         return Log_Out (
            Ada_Lib.Options.Nested.Nested_Options_Type (Options).Process_Option (
               Iterator, Option),
            Trace_Options or Debug, Option.Image & " processed");
      end if;
   end Process_Option;

   --------------------------------------------------------------------
   overriding
   procedure Program_Help (
      Options                    : in      Ada_Lib_Trace_Options_Type;  -- only used for dispatch
      Help_Mode                  : in      Ada_Lib.Options.Help_Mode_Type) is
   --------------------------------------------------------------------

      Component                  : constant String := "Ada_Lib Unit Test";

   begin
      Log_In (Debug or Trace_Options, "mode " & Help_Mode'img);
      case Help_Mode is

      when Ada_Lib.Options.Program_Mode =>
         Ada_Lib.Help.Create_Option (
            Option         => Trace_Option,
            Trace_Option   => True,
            Parameter      => "trace options",
            Description    => "ada_lib unit test trace options",
            Component      => Component,
            Modifier       => Ada_Lib.Help.Modifier);

      when Ada_Lib.Options.Trace_Mode =>
         Ada_Lib.Help.Set_Has_Trace (Trace_Option, Ada_Lib.Help.Modifier);
         Put_Line (Ada_Lib.Trace.Who & " trace options (-" &
            Trace_Option & ")");
         Put_Line ("      a               all");
         Put_Line ("      u               ?");
         New_Line;

      end case;
      Log_Out (Debug or Trace_Options);
   end Program_Help;

end Ada_Lib.Trace.Options;
