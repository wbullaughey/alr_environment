with Ada.Text_IO;use Ada.Text_IO;
with Ada_Lib.Help;
with Ada_Lib.Options.Create;
--with Ada_Lib.Options.Nested;
with Ada_Lib.Options.Runstring;
with Ada_Lib.Strings;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Trace; use Ada_Lib.Trace;

package body Ada_Lib.Options.Template is

-- use type  Ada_Lib.Strings.Unlimited.String_Type;

   Debug       : Boolean renames Ada_Lib.Options.Ada_Lib_Options_Template.Debug;
   Trace_Option                  : constant Character := 'T';
                                 -- only used for Help_Test
   Trace_Help_Options_With_Parameters
                           : aliased constant
                              Flag_List_Type :=
                                 Create.Create_One (
                                 Trace_Option, Unmodified_flag);
   Options_Without_Parameters    : aliased constant
                                    Flag_List_Type :=
                                          Ada_Lib.Options.Null_Flag_List;

   ----------------------------------------------------------------------------
   overriding
   function Initialize (
     Options                     : in out Template_Options_Type;
     From                        : in     String := Standard.Ada_Lib.Trace.Here
   ) return Boolean is
   ----------------------------------------------------------------------------

   begin
      Log_In (Debug);
      Template_Options_Constant := Options'unchecked_access;
      if Ada_Lib.Options.Ada_Lib_Environment.Help_Test then
         Ada_Lib.Options.Runstring.Options.Register (
            Ada_Lib.Options.Runstring.With_Parameters,
            Trace_Help_Options_With_Parameters);
      end if;
--    Ada_Lib.Options.Runstring.Options.Register (
--       Ada_Lib.Options.Runstring.Without_Parameters,
--       Options_Without_Parameters);
      return Log_Out (Nested.Nested_Options_Type (Options).Initialize,
         Debug or Trace_Options);
   end Initialize;

   ----------------------------------------------------------------------------
   overriding
   function Process_Option (
      Options           : in out Template_Options_Type;
      Iterator          : in out Ada_Lib.Options.
                                    Command_Line_Iterator_Interface'class;
      Option            : in     Ada_Lib.Options.Base_Flag_Option_Type'class
   ) return Boolean is
   ----------------------------------------------------------------------------

--    use Standard.Ada_Lib.Options;

   begin
      Log_In (Trace_Options or Debug, Option.Image &
      " help_test " & Ada_Lib.Options.Ada_Lib_Environment.Help_Test'img &
         " Options address " & Ada_Lib.Strings.Image (Options'address));

      if Ada_Lib.Options.Ada_Lib_Environment.Help_Test then
         declare
            Has_On_Options : constant Boolean :=
                              Has_Option (Option,
                                 Trace_Help_Options_With_Parameters,
                                 Options_Without_Parameters);
         begin
            Log_Here (Trace_Options or Debug,
               "Has_On_Options " & Has_On_Options'img);

            if Has_On_Options then
               case Option.Option is

                  when 'T' => -- template trace options
                     Options.Trace_Parse (Iterator);

                  when Others =>
                     Log_Exception (Trace_Options or Debug, " other option" &
                        Option.Image);
                     raise Failed with "Has_Option incorrectly passed " & Option.Image;

               end case;
            else
               return Log_Out (Ada_Lib.Options.Nested.Nested_Options_Type (
                  Options).Process_Option (Iterator, Option),
                  Trace_Options or Debug, Option.Image & " processed");
            end if;
         end;
      else  -- no options when not doing help_test
         return Log_Out(False, Trace_Options or Debug,
            "other option" & Option.Image);
      end if;

      Log_Out (Trace_Options or Debug, " option" & Option.Image & " handled");
      return True;

   end Process_Option;

   ----------------------------------------------------------------------------
   overriding
   procedure Program_Help (
      Options                    : in     Template_Options_Type;  -- root of derivation truee
      Help_Mode                  : in     Ada_Lib.Options.Help_Mode_Type) is
   ----------------------------------------------------------------------------

--    use Standard.Ada_Lib.Options;

      Component                  : constant String := "Ada_Lib.Template.Tests";

   begin
      Log_In (Debug, "mode " & Help_Mode'img);
      case Help_Mode is

         when Ada_Lib.Options.Program_Mode =>
            if Ada_Lib.Options.Ada_Lib_Environment.Help_Test then
               New_Line;
               Ada_Lib.Help.Create_Option (Trace_Option, "options", -- t
                  "enables trace template unit tests", Component, Ada_Lib.Help.Unmodified_Flag);
            end if;

         when Ada_Lib.Options.Trace_Mode =>
            Put_Line (Component & " (-" & Trace_Option & ")");
            Put_Line ("      a               all");
            Put_Line ("      c               compile");
            Put_Line ("      e               evaluate");
            Put_Line ("      E               expand");
            Put_Line ("      l               load");
            Put_Line ("      o               optons");
            Put_Line ("      t               template test");
            New_Line;

      end case;
      Log_Out (Debug);
   end Program_Help;

--   ----------------------------------------------------------------------------
--   overriding
--   function Set_Options (
--      Options                    : in out Template_Options_Type
--   ) return Boolean is
--   ----------------------------------------------------------------------------
--
--   begin
--      Log_Here (Debug or Trace_Options);
--      return False;     -- terminal derivation
----    return Options_Type (Options).Set_Options;
--   end Set_Options;

   ----------------------------------------------------------------------------
   overriding
   procedure Trace_Parse (
      Options        : in out Template_Options_Type;
      Iterator       : in out Command_Line_Iterator_Interface'class) is
   ----------------------------------------------------------------------------

      Parameter                  : constant String := Iterator.Get_Parameter;

   begin
      Log (Trace_Options or Debug, Here, Who & Quote (" Parameter", Parameter));
      for Index in Parameter'range  loop
         declare
            Trace    : constant Character := Parameter (Index);

         begin
            Log_Here (Trace_Options or Debug, Quote ("trace", Trace));
            case Trace is

               when 'a' =>
                  Debug := True;
                  Options.Compile := True;
                  Options.Evaluate := True;
                  Options.Expand := True;
                  Options.Load := True;
                  Options.Test := True;

               when 'c' =>
                  Options.Compile := True;

               when 'e' =>
                  Options.Evaluate := True;

               when 'E' =>
                  Options.Expand := True;

               when 'l' =>
                  Debug := True;

               when 'o' =>
                  Debug := True;

               when 't' =>
                  Options.Test := True;

               when others =>
                  Options.Bad_Option (Trace, "trace options");

            end case;


         end;
      end loop;
   end Trace_Parse;

-- ----------------------------------------------------------------------------
-- overriding
-- procedure Update_Filter (
--    Options                    : in out Template_Options_Type) is
-- ----------------------------------------------------------------------------
--
-- begin
--    Log_In (Debug or Ada_Lib.Unit_Test.Debug, "options " &
--       Image (Options'address) & " filter " &
--       Image (Options.Filter'address) &
--       Quote (" Suite", Options.Suite_Name) &
--       Quote (" routine", Options.Routine));
--    if Options.Suite_Name.Length > 0 then
--       if Options.Routine.Length > 0 then
--          Log_Here (Debug, Quote ("suite", Options.Suite_Name) & Quote (" routine", Options.Routine));
--          Options.Filter.Set_Name (Options.Suite_Name.Coerce & " : " & Options.Routine.Coerce);
--       else
--          Log_Here (Debug, Quote ("suite", Options.Suite_Name) & " no routine");
--          Options.Filter.Set_Name (Options.Suite_Name.Coerce);
--       end if;
--    end if;
--    Log_Out (Debug);
-- end Update_Filter;

begin
-- Elaborate := True;
-- Debug := Debug or Debug_Options.Debug_Al;
--Trace_Options := True;
--debug := True;
   Log_Here (Elaborate or Debug);
end Ada_Lib.Options.Template;
