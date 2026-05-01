with Ada.Assertions;
with Ada.Tags;
with Ada.Text_IO;use Ada.Text_IO;
--with Ada_Lib.Options.Program;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with Ada_Lib.Trace_Options_Package;
--with System;

package body Ada_Lib.Options.Verification is

   Debug       : Boolean renames Ada_Lib_Options_Verification.Debug;
-- Modifiable_Nested_Options
--             : Verification_Nested_Options_Class_Access := Null;
   Modifialbe_Verification_Options
               : Verification_Program_Options_Class_Access := Null;
   Recursed    : Boolean := False;

   ----------------------------------------------------------------
   procedure Display_Help (
     Options   : in     Verification_Program_Options_Type;
     Message   : in     String := "";   -- leave blank no error help
     Halt      : in     Boolean := True) is
   ----------------------------------------------------------------

   begin
not_implemented;
   end Display_Help;

   ----------------------------------------------------------------
   function Get_Ada_Lib_Modifiable_Nested_Options (
      From                       : in  String := Options_Here
   ) return Verification_Nested_Options_Class_Access is
   ----------------------------------------------------------------

   begin
      Option_Log (Trace_Conversions, Who & " called from " & From);
      Ada.Assertions.Assert (Modifialbe_Verification_Options /= Null,
         "Modifialbe_Verification_Options not set");
      Ada.Assertions.Assert (
         Modifialbe_Verification_Options.Verification_Nested_Options /= Null,
         "Modifialbe_Verification_Options.Verification_Nested_Options not set");
      return Modifialbe_Verification_Options.Verification_Nested_Options;

   end Get_Ada_Lib_Modifiable_Nested_Options;

   ----------------------------------------------------------------
   function Get_Ada_Lib_Modifiable_Program_Options (
      From                       : in  String := Options_Here
   ) return Verification_Program_Options_Class_Access is
   ----------------------------------------------------------------

   begin
      Option_Log (Trace_Conversions, Who & " called from " & From);
      Ada.Assertions.Assert (Modifialbe_Verification_Options /= Null,
         "Modifialbe_Verification_Options not set");
      return Modifialbe_Verification_Options;

   end Get_Ada_Lib_Modifiable_Program_Options;

   ----------------------------------------------------------------------------
   function Get_Ada_Lib_Read_Only_Nested_Options (
      From                       : in  String := Options_Here
   ) return Verification_Nested_Options_Constant_Class_Access is
   ----------------------------------------------------------------------------

   begin
      Option_Log (Trace_Conversions, Who & " called from " & From);
      Ada.Assertions.Assert (Modifialbe_Verification_Options /= Null,
         "Modifialbe_Verification_Options not set");

      Ada.Assertions.Assert (
         Modifialbe_Verification_Options.Verification_Nested_Options /= Null,
         "Modifialbe_Verification_Options.Verification_Nested_Options not set");
      return Verification_Nested_Options_Constant_Class_Access (
         Modifialbe_Verification_Options.Verification_Nested_Options);
   end Get_Ada_Lib_Read_Only_Nested_Options;

   ----------------------------------------------------------------------------
   function Get_Ada_Lib_Read_Only_Program_Options (
      From                       : in  String := Options_Here
   ) return Verification_Program_Options_Constant_Class_Access is
   ----------------------------------------------------------------------------

   begin
      Option_Log (Trace_Conversions, "Modifialbe_Verification_Options tag " &
         Ada.Tags.Expanded_Name (Modifialbe_Verification_Options.all'tag) &
         " " & Who & " called from " & From);
      Ada.Assertions.Assert (Modifialbe_Verification_Options /= Null,
         "Modifialbe_Verification_Options not set");
      Tag_History (Debug, "Modifialbe_Verification_Options",
         Modifialbe_Verification_Options.all'tag);
      return Verification_Program_Options_Constant_Class_Access (
         Modifialbe_Verification_Options);
   end Get_Ada_Lib_Read_Only_Program_Options;

   ----------------------------------------------------------------------------
   function Have_Ada_Lib_Nested_Verification_Options
   return Boolean is
   ----------------------------------------------------------------------------

      Result   : constant Boolean := Modifialbe_Verification_Options.
                  Verification_Nested_Options /= Null;

   begin
      return Option_Log (Result,
         Ada_Lib.Trace_Options_Package.Trace_Pre_Post_Conditions or
            (Ada_Lib.Trace_Options_Package.Trace_Pre_Post_False and not Result));
   end Have_Ada_Lib_Nested_Verification_Options;

   ----------------------------------------------------------------------------
   function Have_Ada_Lib_Verification_Options
   return Boolean is
   ----------------------------------------------------------------------------

      Result   : constant Boolean := Modifialbe_Verification_Options /= Null;

   begin
      return Option_Log (Result,
         Ada_Lib.Trace_Options_Package.Trace_Pre_Post_Conditions or
            (Ada_Lib.Trace_Options_Package.Trace_Pre_Post_False and not Result));
   end Have_Ada_Lib_Verification_Options;

   ----------------------------------------------------------------
   overriding
   function Initialize (
     Options                     : in out Verification_Program_Options_Type;
     From                        : in     String := Ada_Lib.Trace.Here
   ) return Boolean is
   ----------------------------------------------------------------

   begin
      Option_Log (Debug, "called from " & From);
      return Verification_Package.Verification_Options_Type (Options).Initialize;

   end Initialize;

   ----------------------------------------------------------------
   overriding
   function Process_Option (  -- process one option
      Options                    : in out Verification_Program_Options_Type;
      Iterator                   : in out Command_Line_Iterator_Interface'class;
      Option                     : in     Base_Flag_Option_Type'class
   ) return Boolean is
   ----------------------------------------------------------------

   begin
      Option_Log (Debug or else Trace_Options);
      return Options.Verification_Nested_Options.Process_Option (
         Iterator, Option);
   end Process_Option;

   ----------------------------------------------------------------
   overriding
   procedure Program_Help (
      Options                    : in      Verification_Program_Options_Type;
      Help_Mode                  : in      Help_Mode_Type) is
   ----------------------------------------------------------------

   begin
      Option_Log (Debug);
      Options.Verification_Nested_Options.Program_Help (Help_Mode);
   end Program_Help;

   ----------------------------------------------------------------
   procedure Set_Ada_Lib_Program_Options (
      Options        : in     Verification_Program_Options_Class_Access;
      Nested_Options : in     Verification_Nested_Options_Class_Access) is
   ----------------------------------------------------------------

   begin
      Option_Log (Debug,
         Tag_Name ("options", Options.all'tag) &
         Tag_Name ("nested options", Nested_Options.all'tag) &
         " called from " & Who);
      Modifialbe_Verification_Options := Options;
      Modifialbe_Verification_Options.Verification_Nested_Options :=
         Nested_Options;
   end Set_Ada_Lib_Program_Options;

   package body Verification_Package is
      ----------------------------------------------------------------------------
      overriding
      procedure Bad_Option (              -- aborts program
         Options                    : in     Verification_Options_Type;
         What                       : in     Character;
         Message                    : in     String := "";
         Where                      : in     String := Ada_Lib.Trace.Here) is
      ----------------------------------------------------------------------------

      begin
         Log_Here (Debug or Trace_Options, "what " & What & " where " & Where);
         Parsing_Failed;
         raise Failed with
            (if Message'length > 0 then
               Quote (Message) & " "
            else "") &
            Quote ("Processing option ", What) & (if Debug or Trace_Options then
               " From " & Where
            else
               "");
      end Bad_Option;

      ----------------------------------------------------------------------------
      overriding
      procedure Bad_Option (              -- aborts program
         Options                    : in     Verification_Options_Type;
         What                       : in     String;
         Message                    : in     String := "";
         Where                      : in     String := Ada_Lib.Trace.Here) is
      ----------------------------------------------------------------------------

      begin
         Log_Here (Debug or Trace_Options, "what " & What & " where " & Where);
         Parsing_Failed;
         raise Failed with
            (if Message'length > 0 then
               Quote (Message) & " "
            else "") &
            Quote ("Processing option ", What) &
            (if Debug or Trace_Options then
               " From " & Where
            else
               "");
      end Bad_Option;

      ----------------------------------------------------------------------------
      overriding
      procedure Bad_Option (        -- raises Failed exception
         Options                    : in     Verification_Options_Type;
         Option                     : in     Base_Flag_Option_Type'class;
         Message                    : in     String := "";
         Where                      : in     String := Ada_Lib.Trace.Here) is
      ----------------------------------------------------------------------------

      begin
         Log_Here (Debug or Trace_Options, Quote ("message", Message) &
            " what " & Option.Image &
            " where " & Where);
         Parsing_Failed;
         raise Failed with (
            (if Message'length > 0 then
               Quote (Message) & " "
            else "") &
            "Processing " & Option.Image) &
            (if Debug or Trace_Options then
               " From " & Where
            else
               "");
      end Bad_Option;

      ----------------------------------------------------------------------------
      overriding
      procedure Bad_Trace_Option (              -- aborts program
         Options           : in     Verification_Options_Type;
         Trace_Option      : in     Character;
         What              : in     Character;
         Modifier          : in     Character := Ada.Characters.Latin_1.Nul;
         Message           : in     String := "";
         Where             : in     String := Ada_Lib.Trace.Here) is
      ----------------------------------------------------------------------------

      begin
         Log_Here (Debug or Trace_Options,
            Quote ("trace option", Trace_Option) &
            Quote (" what ", What) &
            Quote (" modifier ", Modifier) &
            " where " & Where);
         Parsing_Failed;
         raise Failed with
            (if Message'length > 0 then
               Quote (Message) & " "
            else "") &
            (if Modifier /= Ada.Characters.Latin_1.Nul then
               " modifier " & Modifier
            else
               "") &
            Quote (" Trace option", What) &
            Quote (" not defined for", Trace_Option) &
            (if Debug or Trace_Options then
               " From " & Where
            else
               "");
      end Bad_Trace_Option;

      ----------------------------------------------------------------
      procedure Display_Help (
        Options   : in     Verification_Options_Type;  -- only used for dispatch
        Message   : in     String := "";   -- leave blank no error help
        Halt      : in     Boolean := True) is
      ----------------------------------------------------------------

      begin
   not_implemented;
      end Display_Help;

      ---------------------------------------------------------------
      overriding
      function Initialize (
         Options                 : in out Verification_Options_Type;
         From                    : in     String := Ada_Lib.Trace.Here
      ) return Boolean is
      ---------------------------------------------------------------

      begin
         Log_In_Checked (Recursed, Debug or Trace_Options,
            "from " & From & " options address " &
            Ada_Lib.Strings.Image (Options'address));
         Tag_History (Debug or Trace_Options, "Options",
            Verification_Options_Type'class (Options)'tag);
         Options.Steps (Initialized) := True;
         return Log_Out_Checked (Recursed, True, Debug or Trace_Options);
      end Initialize;

      ----------------------------------------------------------------------------
      overriding
      procedure Post_Process (      -- final post process
        Options                    : in out Verification_Options_Type) is
      ----------------------------------------------------------------------------

      begin
         Options.Steps (Post_Processed) := True;
      end Post_Process;

      ----------------------------------------------------------------------------
      overriding
      function Post_Process_Completed (      -- final post process
        Options                    : in out Verification_Options_Type
      ) return Boolean is
      ----------------------------------------------------------------------------

      begin
         return Options.Steps (Post_Processed);
      end Post_Process_Completed;

      ----------------------------------------------------------------------------
      overriding
      procedure Trace_Parse (
         Options              : in out Verification_Options_Type;
         Iterator             : in out Command_Line_Iterator_Interface'class) is
      ----------------------------------------------------------------------------

   --    Extended                   : Boolean := False;
         Parameter                  : constant String := Iterator.Get_Parameter;

      begin
         Log_In (Debug or Ada_Lib_Trace_Trace or Trace_Options,
            Quote ("parameter", Parameter));
         for Index in Parameter'range  loop
            declare
               Trace    : constant Character := Parameter (Index);

            begin
               Log_Here (Trace_Options or Debug, Quote ("trace", Trace));
               case Trace is

   --               when 'a' =>
   ----                Ada_Lib_GNOGA.Base_Debug := True;
   --                  Ada_Lib_GNOGA.Debug := True;
   --
   ----             when 'b' =>
   ----                Ada_Lib_GNOGA.Base_Debug := True;
   --
   --               when 'd' =>
   --                  Ada_Lib_GNOGA.Debug := True;

                  when others =>
                     Options.Bad_Option (Trace, "trace options");

               end case;

            end;
         end loop;
         Log_Out (Debug or Ada_Lib_Trace_Trace or Trace_Options);
      end Trace_Parse;

      ----------------------------------------------------------------------------
      overriding
      procedure Update_Filter (
         Options                    : in out Verification_Options_Type) is
      ----------------------------------------------------------------------------

      begin
         Log_Here (Tag_Name ("options",
            Verification_Options_Type'class (Options)'tag));
         Not_Implemented;
      end Update_Filter;

      ---------------------------------------------------------------
      overriding
      function Process_Argument (  -- process one argument
        Options                     : in out Verification_Options_Type;
        Iterator                    : in out Command_Line_Iterator_Interface'
                                                class;
        Argument                    : in     String
      ) return Boolean is
      pragma Unreferenced (Options, Iterator, Argument);
      ---------------------------------------------------------------

      begin
         Log_Here (Debug or Trace_Options, "no argument");
         return False;
      end Process_Argument;

--      ---------------------------------------------------------------
--      overriding
--      function Verify_Initialized (
--         Options                    : in     Verification_Options_Type;
--         From                       : in     String := GNAT.Source_Info.Source_Location
--      ) return Boolean is
--      ---------------------------------------------------------------
--
--         ---------------------------------------------------------------
--         procedure Failed (
--            Text                    : in     String) is
--         ---------------------------------------------------------------
--
--            Message  : constant String := Text &  " called from " & From;
--
--         begin
--            Log_Here (Message);
--            Put_Line (Message);
--         end Failed;
--         ---------------------------------------------------------------
--
--      begin
--         Log_In (Debug or Trace_Options or Trace_Pre_Post_Conditions,
--            "Initialized " & Options.Initialized'img & " from " & From &
--            " options address " &
--            Ada_Lib.Strings.Image (Options'address) &
--            Tag_Name (" options",
--               Verification_Options_Type'class (Options)'tag));
--
--         if not Have_Ada_Lib_Verification_Options then
--            Failed ("Get_Modifiable_Program_Options not initialized at " & Here);
--         else
--            if Options.Initialized then
--               return Log_Out (True, Debug or Trace_Options or
--                  Trace_Pre_Post_Conditions);
--            else
--               Failed ("Options.Initialized not initialized at " & Here);
--            end if;
--         end if;
--
--         Tag_History (Debug or Trace_Options, "Options",
--            Verification_Options_Type'class (Options)'tag);
--         return Log_Out (False, True, "Verify_Initialized failed from " & From);
--      end Verify_Initialized;
--
--      ---------------------------------------------------------------
--      overriding
--      function Verify_Preinitialize (
--         Options                    : in     Verification_Options_Type;
--         From                       : in     String := GNAT.Source_Info.Source_Location
--      ) return Boolean is
--      ---------------------------------------------------------------
--
--      begin
--         Log_In (Debug or Trace_Options,
--            "Initialized " & Options.Initialized'img &
--            " options address " &
--            Ada_Lib.Strings.Image (Options'address) &
--            " Get_Ada_Lib_Read_Only_Nested_Options ");
----          Ada_Lib.Strings.Image (
----             Get_Ada_Lib_Read_Only_Nested_Options.all'address));
--         Tag_History (Debug or Trace_Options, "options",
--            Verification_Options_Type'class (Options)'tag);
--
--         if Modifialbe_Verification_Options = Null then
--            Put_Line ("Modifialbe_Verification_Options is null " & Here);
--         else
--            if Options.Initialized then
--               Put_Line ("Options.Initialized should be false");
--            else
--               return Log_Out (True, Debug or Trace_Options);
--            end if;
--         end if;
--         Put_Line (Who & " failed at " & Here);
--         return Log_Out (False, Debug or Trace_Options,
--            Tag_Name ("options",
--               Verification_Options_Type'class (Options)'tag));
--
--      exception
--         when Fault: others =>
--            Trace_Exception (Fault);
--            return False;
--
--      end Verify_Preinitialize;

      ----------------------------------------------------------------------------
      overriding
      function Verify_Step (
         Options  : in     Verification_Options_Type;
         Step     : in     Initialization_Step_Type;
         From     : in     String := GNAT.Source_Info.Source_Location
      ) return Boolean is
      ----------------------------------------------------------------------------

         Log_It   : constant Boolean := Debug or Trace_Options or
                     Trace_Pre_Post_Conditions;
         Labels   : constant array (Initialization_Step_Type) of
                     Strings.String_Access := (
                        Initialized       => new String'("initialize"),
                        Processed         => new String'("options"),
                        Post_Processed    => new String'("post process"));

         -------------------------------------------------------------------------
         function Steps
         return String is
         -------------------------------------------------------------------------

            Result   : Ada_Lib.Strings.Unlimited.String_Type;

         begin
            Result.Append ("not completed ");
            for Step in Options.Steps'range loop
               if not Options.Steps (Step) then
                  Result.Append (Labels (Step).all & ", ");
               end if;
            end loop;
            Result.Append (" completed ");
            for Step in Options.Steps'range loop
               if Options.Steps (Step) then
                  Result.Append (Labels (Step).all & ", ");
               end if;
            end loop;
            return Result.Coerce;
         end Steps;

         ---------------------------------------------------------------
         procedure Failed (
            Text                    : in     String) is
         ---------------------------------------------------------------

            Message  : constant String := Text &  " called from " & From;

         begin
            Log_Here (Message);
            Put_Line (Message);
         end Failed;
         ---------------------------------------------------------------

      begin
         Log_In (Log_It,  "step " & Step'img & " " &
            Steps & " called from " & From);
         Tag_History (Log_It, "options",
            Verification_Options_Type'class (Options)'tag);

         if not Have_Ada_Lib_Verification_Options then
            Failed ("Get_Modifiable_Program_Options not initialized at " & Here);
            return Log_Out (False, Log_It);
         else
            if not Options.Steps (Step) then
               Put_Line (Step'img &" not set " & " called from " & From);
               return Log_Out (False, Log_It);
            end if;

            if Step > Initialization_Step_Type'first then
               declare
                  Previous_Step  : constant Initialization_Step_Type :=
                                    Initialization_Step_Type'pred (Step);

               begin
                  if not Options.Steps (Previous_Step) then
                     Put_Line (Previous_Step'img & " not set " &
                        " called from " & From);
                     return Log_Out (False, Log_It);
                  end if;
               end;
            end if;

            if Step < Initialization_Step_Type'last then
               for Next_Step in Initialization_Step_Type'succ (Step) ..
                     Initialization_Step_Type'last loop
                  if Options.Steps (Next_Step) then
                     Put_Line ("later step " & Next_Step'img & "  set " &
                        " called from " & From);
                     return Log_Out (False, Log_It);
                  end if;
               end loop;
            end if;

            return Log_Out (True, Log_It);
         end if;
      end Verify_Step;

      ----------------------------------------------------------------------------
      function Was_Initialized (
         Options                 : in     Verification_Options_Type
      ) return Boolean is
      ----------------------------------------------------------------------------

      begin
         Tag_History (Debug or Trace_Options, "options",
            Verification_Options_Type'class (Options)'tag);
         return Log_Here (Options.Steps (Initialized),
            Debug or else
            Trace_Options or else
            Trace_Pre_Post_Conditions or else
            not Options.Steps (Initialized));
      end Was_Initialized;

   end Verification_Package;

begin
Debug := True;
   Log_Here (Debug or Elaborate);
end Ada_Lib.Options.Verification;

