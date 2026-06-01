--with Ada.Assertions;
with Ada.Exceptions;
with Ada.Text_IO;use Ada.Text_IO;
with Ada_Lib.Command_Line_Iterator;
with Ada_Lib.Help;
with Ada_Lib.Options.AUnit_Lib;
--with Ada_Lib.Options.Create;
with Ada_Lib.Options.Runstring;
with Ada_Lib.Options.Unit_Test;
with Ada_Lib.OS;
--with Ada_Lib.Specifications;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Trace; use Ada_Lib.Trace;

package body Ada_Lib.Options.Program is

   procedure Set_All;

   Debug                         : Boolean renames Ada_Lib.Options.
                                    Ada_Lib_Options_Program.Debug;
   Include_Task                  : Boolean renames
                                    Ada_Lib.Options.Trace.Include_Task;
   Include_Time                  : Boolean renames
                                    Ada_Lib.Options.Trace.Include_Time;
   Initialize_Recursed           : Boolean := False;
   Test_Condition_Flag           : constant Character := 'c';
   Options_With_Parameters       : aliased constant
                                    Flag_List_Type :=
                                       Initialize (
                                          'a', Unmodified_flag);
   Options_Without_Parameters    : aliased constant
                                    Flag_List_Type :=
                                       Initialize (
                                          "hPv#", Unmodified_flag) &
                                       Initialize (
                                          "ipTx" & Test_Condition_Flag,
                                          Ada_Lib.Help.Modifier);

   ----------------------------------------------------------------------------
   overriding
   procedure Display_Help (   -- common for all programs that use GNOGA_Options
                              -- prints full help
     Options   : in     Program_Options_Type;     -- only used for dispatch
     Message   : in     String := "";  -- leave blank no error help
     Halt      : in     Boolean := True) is
   ----------------------------------------------------------------------------

      -------------------------------------------------------------------------
      procedure Print_Help (
         Line                    : in     String) is
      -------------------------------------------------------------------------

      begin
         Put ("    ");
         Put_Line (Line);
      end Print_Help;
      -------------------------------------------------------------------------

      Log   : constant Boolean := Debug or Trace_Options;

   begin
      Log_In (Log, Quote ("message", Message) &
         " halt " & Halt'img &
         Tag_Name (" options", Abstract_Runtime_Options_Type'class (
            Options)'tag));
--    if Options.In_Help then
--       Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.No_Error);
--    end if;

      if Message'length > 0 then
         Put_Line (Message);
      end if;
--log_here;
--      Verification.Get_Ada_Lib_Read_Only_Nested_Options.
--         Program_Help (Program_Mode);

--    Options.Nested_Program_Options.Program_Help (Program_Mode);
      Ada_Lib.Options.Verification.Verification_Program_Options_Type'class (
         Options).Program_Help (Program_Mode);
      Ada_Lib.Help.Display (Print_Help'access);
      New_Line;
      Ada_Lib.Options.Verification.Verification_Program_Options_Type'class (
         Options).Program_Help (Trace_Mode);

      if Halt then
         Log_Out (Log);
         Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.No_Error);
      else
         Log_Out (Log);
      end if;
   end Display_Help;

   ----------------------------------------------------------------------------
   overriding
   procedure Display_Help (            -- common for all programs that use GNOGA_Options
                              -- prints full help
     Options                     : in     Nested_Program_Options_Type;     -- only used for dispatch
     Message                     : in     String := "";  -- leave blank no error help
     Halt                        : in     Boolean := True) is
   ----------------------------------------------------------------------------

      -------------------------------------------------------------------------
      procedure Print_Help (
         Line                    : in     String) is
      -------------------------------------------------------------------------

      begin
         Put ("    ");
         Put_Line (Line);
      end Print_Help;
      -------------------------------------------------------------------------

   begin
      Log_In (Debug or Trace_Options, Quote ("message", Message) &
         " halt " & Halt'img &
         Tag_Name (" options", Abstract_Runtime_Options_Type'class (
            Options)'tag) &
         " in help " & Options.In_Help'img);
      if Options.In_Help then
         Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.No_Error);
      end if;

      if Message'length > 0 then
         Put_Line (Message);
      end if;
      Verification.Get_Ada_Lib_Read_Only_Program_Options.
         Program_Help (Program_Mode);

      Ada_Lib.Help.Display (Print_Help'access);
      New_Line;

      Options.GNOGA_Ada_Lib_Option.Program_Help (Program_Mode);


      if Halt then
         Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.No_Error);
      end if;
   end Display_Help;

   ----------------------------------------------------------------------------
   function Get_Modifiable_Program_Options (
      From                       : in  String := Options_Here
   ) return Program_Options_Class_Access is
   ----------------------------------------------------------------------------

   begin
      Log_Here (Trace_Conversions, "from " & From);
      return Program_Options_Class_Access (
         Verification.Get_Ada_Lib_Modifiable_Program_Options (From));
   end Get_Modifiable_Program_Options;

   ----------------------------------------------------------------------------
   function Get_Modifiable_Nested_Program_Options (
      From                       : in     String := Options_Here
   ) return Nested_Program_Options_Class_Access is
   ----------------------------------------------------------------------------

   begin
      Log_Here (Trace_Conversions, "from " & From);
      return Nested_Program_Options_Class_Access (
         Verification.Get_Ada_Lib_Modifiable_Nested_Options);
   end Get_Modifiable_Nested_Program_Options;

   ----------------------------------------------------------------------------
   function Get_Read_Only_Nested_Program_Options (
      Options  : in     Program_Options_Type
   ) return Nested_Program_Options_Constant_Class_Access is
   ----------------------------------------------------------------------------

   begin
      Log_Here (Trace_Conversions);
      return Nested_Program_Options_Constant_Class_Access (
         Verification.Get_Ada_Lib_Read_Only_Nested_Options);
   end Get_Read_Only_Nested_Program_Options;

 ----------------------------------------------------------------------------
 function Get_Read_Only_GNOGA_Ada_Lib_Option (
    From                       : in     String := Options_Here
 ) return Gnoga_Ada_Lib.GNOGA_Ada_Lib_Options_Constant_Class_Access is
 ----------------------------------------------------------------------------

 begin
    Log_Here (Trace_Conversions, "from " & From);
    return Get_Read_Only_Nested_Program_Options.
       GNOGA_Ada_Lib_Option'unchecked_access;
 end Get_Read_Only_GNOGA_Ada_Lib_Option;

   ----------------------------------------------------------------------------
   function Get_Read_Only_Nested_Program_Options (
      From                       : in     String := Options_Here
   ) return Nested_Program_Options_Constant_Class_Access is
   ----------------------------------------------------------------------------

   begin
      Log_Here (Trace_Conversions, "from " & From);
      return Nested_Program_Options_Constant_Class_Access (
         Verification.Get_Ada_Lib_Read_Only_Nested_Options);
   end Get_Read_Only_Nested_Program_Options;

 ----------------------------------------------------------------------------
 function Get_Read_Only_Program_Options (
    From                       : in  String := Options_Here
 ) return Program_Options_Constant_Class_Access is
 ----------------------------------------------------------------------------

 begin
    Log_Here (Trace_Conversions, "from " & From);
    return Program_Options_Constant_Class_Access (
       Verification.Get_Ada_Lib_Read_Only_Program_Options (From));
 end Get_Read_Only_Program_Options;

   -------------------------------------------------------------------------
   function Has_Camera
   return Boolean is
   -------------------------------------------------------------------------

      Trace_Log   : constant Boolean := Debug or Trace_Pre_Post_Conditions;

   begin
      Log_In (Trace_Log);
      declare
         Options  : constant Verification.
                     Verification_Program_Options_Constant_Class_Access :=
                        Verification.Get_Ada_Lib_Read_Only_Program_Options;
      begin
         Tag_History (Trace_Log, "options", Options.all'tag);

         declare
            Nested_Options
               : Unit_Test.Ada_Lib_Unit_Test_Nested_Options_Type renames
                  AUnit_Lib.Aunit_Program_Options_Constant_Class_Access (
                     Options).Nested_Unit_Test_Options;
         begin
            return Log_Out (Nested_Options.Have_Camera,
               Trace_Log);
         end;
      end;

   exception
      when Fault: others =>
         Trace_Exception (Trace_Log, Fault);
         raise;

   end Has_Camera;

   ----------------------------------------------------------------------------
   function Have_Nested_Program_Options (
      Options  : in     Program_Options_Type
   ) return Boolean is
   ----------------------------------------------------------------------------

      Result   : constant Boolean :=
                  Verification.Have_Ada_Lib_Nested_Verification_Options;
      Log_It   : constant Boolean := Debug or else
                                     Trace_Pre_Post_Conditions or else
                                     (Trace_Pre_Post_False and not Result);

   begin
      return Log_Here (Result, Log_It,
         (if result then
            ""
         else
            "Nested_Program_Options is null"));
   end Have_Nested_Program_Options;

   ----------------------------------------------------------------------------
   overriding
   function Image (
     Options                     : in     Nested_Program_Options_Type
   ) return String is
   ----------------------------------------------------------------------------

   begin
not_implemented;
return "";
   end Image;

   ----------------------------------------------------------------------------
   overriding
   function Image (
     Options                     : in     Program_Options_Type
   ) return String is
   ----------------------------------------------------------------------------

   begin
not_implemented;
return "";
   end Image;

   ----------------------------------------------------------------------------
   overriding
   function Initialize (
     Options                     : in out Nested_Program_Options_Type;
     From                        : in     String := Ada_Lib.Trace.Here
   ) return Boolean is
   ----------------------------------------------------------------------------

--    Message        : constant String := " from " & From &
--       " options with parameters " &
--       Image (Options_With_Parameters) &
--       " with out " &
--       Image (Options_Without_Parameters);
      Log_It   : constant Boolean := Debug or Trace_Options;

   begin
     Log_In_Checked (Initialize_Recursed, Log_It,
         Tag_Name ("options",
            Nested_Program_Options_Type'class (Options)'tag));

     Tag_History (Log_It, "Options",
       Nested_Program_Options_Type'class (Options)'tag);

      Runstring.Options.Register (
         Runstring.With_Parameters,
         Options_With_Parameters);
      Runstring.Options.Register (
         Runstring.Without_Parameters,
         Options_Without_Parameters);

      return Log_Out_Checked (Initialize_Recursed,
         Options.GNOGA_Ada_Lib_Option.Initialize and then
         Verification.Verification_Nested_Options_Type (
            Options).Initialize,
         Log_It);
   end Initialize;

   ----------------------------------------------------------------------------
   overriding
   function Initialize (
     Options                     : in out Program_Options_Type;
     From                        : in     String := Ada_Lib.Trace.Here
   ) return Boolean is
   ----------------------------------------------------------------------------

   begin
      return Log_Here (
         Verification.Verification_Program_Options_Type (Options).Initialize,
         Debug or Trace_Options,
         Tag_Name ("options",
            Program_Options_Type'class (Options)'tag));
   end Initialize;

   ----------------------------------------------------------------------------
   function Is_Program_Processed (
     Options                     : in out Program_Options_Type
   ) return Boolean is
   ----------------------------------------------------------------------------

   begin
      return Options.Program_Processed;
   end Is_Program_Processed;

   ----------------------------------------------------------------------------
   function Process (
      Options                    : in out Program_Options_Type;
      Iterator                   : in out Command_Line_Iterator_Interface'class
   ) return Boolean is
   ----------------------------------------------------------------------------

      Log_It   : constant Boolean := Debug or Trace_Options;

   begin
      Log_In (Log_It);
--       Tag_Name (Nested_Program_Options_Type'class (Options)'tag));

      while not Iterator.At_End loop
         begin
            if Iterator.Is_Option then
               declare
                  Option         : constant Flag_Option_Type'class :=
                                    Iterator.Get_Option;
                  Message        : constant String := Option.Image & " not defined";

               begin
                  Log_Here (Log_It, Option.Image);
                  if Program_Options_Type'class (Options).Process_Option (
                        Iterator, Option) then
                     Log_Here (Log_It, Message);
                  else
                     Options.Bad_Option (Option, Message);     -- aborts program
                     return Log_Out (False, Log_It, "processed");
                  end if;
               end;
            else
               declare
                  Argument          : constant String :=
                                       Iterator.Get_Argument;
               begin
                  Log_Out (Log_It);
                  Options.Bad_Option ("unexpected '" & Argument & "' on run string" &
                     " from " & Here);
                     -- raises exception
               end;
            end if;

--       exception
--
--          when Fault: others =>
--             Trace_Exception (Log_It, Fault);
--             if not Options.Nested_Program_Options.Help_Test then
--                raise;
--             end if;
--
         end;
         if not Iterator.At_End then
            Iterator.Advance;
         end if;
      end loop;

      return Log_Out (True, Log_It, "processed");

   exception

      when Fault: others =>
         if Log_It then
            Tag_History ("options", Program_Options_Type'class (Options)'tag);
            Trace_Exception (Fault);
         end if;
         raise;

   end Process;

   ----------------------------------------------------------------------------
-- overriding
   function Process (     -- processes whole command line calling Process_Option for each option
     Options                     : in out Nested_Program_Options_Type;
     Include_Options             : in     Boolean;
     Include_Non_Options         : in     Boolean;
     Option_Prefix               : in     Character := '-';
     Modifiers                   : in     String := ""
   ) return Boolean is
   ----------------------------------------------------------------------------

   begin
      Log_In (Debug or Trace_Options, "Include_Options " & Include_Options'img &
         " Include_Non_Options " & Include_Non_Options'img &
         Ada_Lib.String_Quote.Quote (" modifiers", Modifiers) &
         " " & Tag_Name ("options",
            Nested_Program_Options_Type'class (Options)'tag));
not_implemented;
return false;
--    declare
--       Iterator                : Ada_Lib.Command_Line_Iterator.Run_String.
--                                  Runstring_Iterator_Type;
--
--    begin
--       Log_Here (Debug or Trace_Options);
--       Iterator.Initialize (Include_Options, Include_Non_Options,
--          Option_Prefix, Modifiers);
--       Options.Nested_Program_Options.Process (Iterator);
--
--    exception
--       when Fault: others =>
--          Trace_Exception (Debug or Trace_Options, Fault);
--          Verification.Get_Ada_Lib_Read_Only_Nested_Options.Display_Help (
--             Ada.Exceptions.Exception_Message (Fault));
--    end;
--
--    Options.Nested_Processed := True;
--    return Log_Out (True, Debug or Trace_Options);

   exception
      when Fault: Ada_Lib.Options.Failed =>
         Trace_Exception (Debug or Trace_Options, Fault);
         Options.Display_Help (Ada.Exceptions.Exception_Message (Fault), True);
         raise;

      when Fault: others =>
         Trace_Exception (Debug or Trace_Options, Fault);
         raise;

   end Process;

   ----------------------------------------------------------------------------
   function Process (     -- processes whole command line calling Process_Option for each option
     Options                     : in out Program_Options_Type;
     Include_Options             : in     Boolean;
     Include_Non_Options         : in     Boolean;
     Option_Prefix               : in     Character := '-';
     Modifiers                   : in     String := ""
   ) return Boolean is
   ----------------------------------------------------------------------------

   begin
      Log_In (Debug or Trace_Options, "Include_Options " & Include_Options'img &
         " Include_Non_Options " & Include_Non_Options'img &
         Ada_Lib.String_Quote.Quote (" modifiers", Modifiers) &
         Tag_Name ("Options", Program_Options_Type'class (Options)'tag));

      declare
         Iterator                : Ada_Lib.Command_Line_Iterator.Run_String.
                                    Runstring_Iterator_Type;

      begin
         Log_Here (Debug or Trace_Options);
         Iterator.Initialize (Include_Options, Include_Non_Options,
            Option_Prefix, Modifiers);
--       if not Options.Process (Iterator) then
--          return Log_Out (False,Debug or Trace_Options);
--       end if;
         -- dispatch on class value
         if not Program_Options_Type'class (Options).Process (Iterator) then
            return Log_Out (False,Debug or Trace_Options);
         end if;

      exception
         when Fault: others =>
            Trace_Exception (Debug or Trace_Options, Fault);
            raise;
--          Verification.Get_Ada_Lib_Read_Only_Program_Options.Display_Help (
--             Ada.Exceptions.Exception_Message (Fault));
      end;

      Options.Program_Processed := True;
      return Log_Out (Verification.Verification_Program_Options_Type (
            Options).Process (Include_Options, Include_Non_Options,
            Option_Prefix, Modifiers),
         Debug or Trace_Options);

   exception
      when Fault: Ada_Lib.Options.Failed =>
         Trace_Exception (Debug or Trace_Options, Fault);
         Options.Display_Help (Ada.Exceptions.Exception_Message (Fault), True);
         raise;

      when Fault: others =>
         Trace_Exception (Debug or Trace_Options, Fault);
         raise;

   end Process;

   ----------------------------------------------------------------------------
   overriding
   function Process_Option (
      Options                    : in out Nested_Program_Options_Type;
      Iterator                   : in out Command_Line_Iterator_Interface'class;
      Option                     : in     Flag_Option_Type'class
   ) return Boolean is
   ----------------------------------------------------------------------------

      Log_It   : constant Boolean := Trace_Options or Debug;

   begin
      Log_In (Log_It, "option '" & Option.Image &
         " kind " & Option.Kind'img &
         " Help_Test " & Options.Help_Test'img);

      if Option.Has_Option (Options_With_Parameters,
            Options_Without_Parameters) then
         if Option.Kind = Ada_Lib.Options.Plain then
            case Option.Option is

               when 'a' =>
                  Options.Trace_Parse (Iterator);

               when 'h' =>
                  if not Options.Help_Test then
                     declare
                        Program_Options
                           : constant Verification.
                              Verification_Program_Options_Constant_Class_Access :=
                                 Verification.Get_Ada_Lib_Read_Only_Program_Options;
                     begin
                        Tag_history (Log_It,
                           "Program_Options", Program_Options.all'tag);
                        Program_Options.Display_Help ("", False);
                        Ada_Lib.Help.Check_Traces;
                        Log_Out (Log_It);

                        Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.No_Error);
                     end;
                  end if;

               when 'P' =>
                  Ada_Lib.Trace.Pause_Flag := True;

--             when 's' =>
--                Options.Camera_State_Path.Construct (Iterator.Get_Parameter);

               when 'v' =>
                  Options.Verbose := True; -- Set_Verbose (True);

               when '#' =>
                  Do_Trace_Checks := False;

               when Others =>
                  Log_Exception (Debug or Trace_Options);
                  raise Failed with "Has_Option incorrectly passed " &
                     Option.Image;

            end case;
         else
            case Option.Option is

               when Test_Condition_Flag =>      -- c
                  Test_Condition := True;

               when 'i' =>
                  Indent_Trace := True;

               when 'p' =>
                  Include_Program := True;

               when 't' =>
                  Include_Task := True;

               when 'x' =>
                  Include_Time := False;

               when others =>
                  return Log_Out (False, Debug or Trace_Options,
                     " option not handled" & Option.Image);

            end case;
         end if;
      else
         return Log_Out (
            Options.GNOGA_Ada_Lib_Option.Process_Option (
               Iterator, Option),
            Debug or Trace_Options,
            Quote (" option not handled", Option.Image));
      end if;
      return Log_Out (True, Debug or Trace_Options,
         " option" & Option.Image & " handled");
   end Process_Option;

--   ----------------------------------------------------------------------------
--   overriding
--   function Process_Option (
--      Options                    : in out Program_Options_Type;
--      Iterator                   : in out Command_Line_Iterator_Interface'class;
--      Option                     : in     Flag_Option_Type
--   ) return Boolean is
--   ----------------------------------------------------------------------------
--
--   begin
--log_here;
--      return Log_Here (
--         Verification.Verification_Program_Options_Type (
--            Options).Process_Option (Iterator, Option),
--               Debug or Trace_Options);
--   end Process_Option;

   ----------------------------------------------------------------------------
   overriding
   procedure Program_Help (
      Options                    : in     Nested_Program_Options_Type;  -- only used for dispatch
      Help_Mode                  : in     Ada_Lib.Options.Help_Mode_Type) is
   ----------------------------------------------------------------------------

      Component                  : constant String := "Ada_Lib";

   begin
      Log_In (Debug or Trace_Options, "mode " & Help_Mode'img);
      case Help_Mode is

      when Ada_Lib.Options.Program_Mode =>
         Ada_Lib.Help.Create_Option ('a', True, "trace options",
            "Ada_Lib library trace options", Component,
            Ada_Lib.Help.Unmodified_Flag);
         Ada_Lib.Help.Create_Option ('h', False, "", "this message",
            Component, Ada_Lib.Help.Unmodified_Flag);
         Ada_Lib.Help.Create_Option ('P', False, "", "set pause flag",
            Component, Ada_Lib.Help.Unmodified_Flag);
--       Ada_Lib.Help.Create_Option ('s', False, "", "camera state path",
--          Component, Ada_Lib.Help.Unmodified_Flag);
         Ada_Lib.Help.Create_Option ('v', False, "", "verbose", Component,
            Ada_Lib.Help.Unmodified_Flag);
         Ada_Lib.Help.Create_Option (Test_Condition_Flag, False, "",
            "trace test condition", Component, Ada_Lib.Help.Modifier);
         Ada_Lib.Help.Create_Option ('i', False, "", "indent trace",
            Component, Ada_Lib.Help.Modifier);
         Ada_Lib.Help.Create_Option ('p', False, "",
            "include program in trace", Component, Ada_Lib.Help.Modifier);
         Ada_Lib.Help.Create_Option ('T', False, "", "include task in trace",
            Component, Ada_Lib.Help.Modifier);
         Ada_Lib.Help.Create_Option ('x', False, "", "exclude time in trace",
            Component,Ada_Lib.Help.Modifier);
         Ada_Lib.Help.Create_Option ('#', False, "", "exclude trace checks",
            Component, Ada_Lib.Help.Unmodified_Flag);
         Ada_Lib.Help.Create_Option ('?', False, "", "this message",
            Component, Ada_Lib.Help.Unmodified_Flag);

      when Ada_Lib.Options.Trace_Mode =>
         Ada_Lib.Help.Set_Has_Trace ('a', Ada_Lib.Help.Unmodified_Flag);
         Put_Line ("CAC ada_lib trace library options (-a)");
         Put_Line ("      a               all");
         Put_Line ("      b               database subscribe");
         Put_Line ("      c               Ada_Lib.Command_Line Trace");
         Put_Line ("      C               Ada_Lib.Configuration Trace");
         Put_Line ("      e               Event");
--       Put_Line ("      g               GNOGA.Debug");
--       Put_Line ("      G               GNOGA_Options.Debug");
         Put_Line ("      h               Help");
         Put_Line ("      i               interrupt");
         Put_Line ("      I               Ada_Lib.interface");
         Put_Line ("      l               lock");
         Put_Line ("      m               timer");
         Put_Line ("      M               mail");
         Put_Line ("      o               os");
         Put_Line ("      O               Ada_Lib.Options");
         Put_Line ("      p               parser");
         Put_Line ("      P               database post");
         Put_Line ("      r               run remote, database connect");
         Put_Line ("      R               Ada_Lib.Options.Runstring.Debug");
         Put_Line ("      s               socket trace");
         Put_Line ("      S               socket Stream tracing");
         Put_Line ("      t               Ada_Lib.Trace");
         Put_Line ("      T               Ada_Lib.Trace_Tasks");
         Put_Line ("      v               Ada_Lib.Options.Verification.Debug");
--       Put_Line ("      x               Ada_Lib.Trace.Detail");
--       Put_Line ("      @               Ada_Lib.Strings");
         Put_Line ("      " & Ada_Lib.Help.Trace_Modifier &
                           "c              Template Compile");
         Put_Line ("      " & Ada_Lib.Help.Trace_Modifier &
                           "d              Template Detail");
         Put_Line ("      " & Ada_Lib.Help.Trace_Modifier &
                           "D              Ada_Lib.Directory trace");
         Put_Line ("      " & Ada_Lib.Help.Trace_Modifier &
                           "e              Template Evaluate");
         Put_Line ("      " & Ada_Lib.Help.Trace_Modifier &
                           "E              Template Expand");
         Put_Line ("      " & Ada_Lib.Help.Trace_Modifier &
                           "l              Template Load");
         Put_Line ("      " & Ada_Lib.Help.Trace_Modifier &
                           "o              Trace_Options");
         Put_Line ("      " & Ada_Lib.Help.Trace_Modifier &
                           "p              Trace Pre and Post Condtion functions");
         Put_Line ("      " & Ada_Lib.Help.Trace_Modifier &
                           "P              Trace Pre and Post Condtion false");
         Put_Line ("      " & Ada_Lib.Help.Trace_Modifier &
                           "s              Strings");
         Put_Line ("      " & Ada_Lib.Help.Trace_Modifier &
                           "S              Socket_IO IO");
         Put_Line ("      " & Ada_Lib.Help.Trace_Modifier &
                           "t              Ada_Lib.Text");

      end case;
      Options.GNOGA_Ada_Lib_Option.Program_Help (Help_Mode);
      Log_Out (Debug or Trace_Options);
   end Program_Help;

-- ----------------------------------------------------------------------------
-- overriding
-- procedure Program_Help (
--    Options                    : in     Program_Options_Type;  -- only used for dispatch
--    Help_Mode                  : in     Ada_Lib.Options.Help_Mode_Type) is
-- ----------------------------------------------------------------------------
--
-- begin
--    Log_In (Debug);
--    Options.Nested_Program_Options.Program_Help (Help_Mode);
--    Log_Out (Debug);
-- end Program_Help;

   ----------------------------------------------------------------------------
   procedure Set_All is
   ----------------------------------------------------------------------------

   begin
      Ada_Lib.Command_Line_Iterator.Debug := True;
      Ada_Lib_Configuration.Trace := True;
      Ada_Lib_Interrupt.Debug := True;
      Ada_Lib_Database.Connection_Debug := True;
      Ada_Lib_Database.Trace := True;
      Ada_Lib_Database.Trace_All := True;
      Ada_Lib_Event.Debug := True;
      Ada_Lib_Help.Debug := True;
      Ada_Lib_Lock.Debug := True;
      Ada_Lib_EMail.Debug := True;
      Ada_Lib_Mail.Debug := True;
--    GNOGA_Options.Debug := True;
      Ada_Lib_Options_Runstring.Debug := True;
      Ada_Lib_Options.Debug := True;
      Ada_Lib_OS.Trace := True;
      Ada_Lib_OS.Run_Debug := True;
      Ada_Lib_Parser.Debug := True;
      Ada_Lib_Socket_IO.Trace := True;
      Ada_Lib_Socket_IO.Trace_IO := True;
      Ada_Lib_Socket_IO.Tracing := True;
      Ada_Lib_Strings.Debug := True;
      Ada_Lib_Timer.Debug := True;
      Ada_Lib_Trace_Tasks.Debug := True;
      Ada_Lib.Trace.Trace_Pre_Post_Conditions := True;
      Debug := True;
   end Set_All;

-- ----------------------------------------------------------------------------
-- procedure Set_Nested_Program_Options (
--    Options                 : in out Program_Options_Type;
--    Nested_Program_Options  : Nested_Program_Options_Class_Access) is
-- ----------------------------------------------------------------------------
--
-- begin
--    Options.Nested_Program_Options := Nested_Program_Options;
-- end Set_Nested_Program_Options;

   ----------------------------------------------------------------------------
   procedure Trace_Parse (
      Options              : in out Nested_Program_Options_Type;
      Iterator             : in out Command_Line_Iterator_Interface'class) is
   ----------------------------------------------------------------------------

      Extended                   : Boolean := False;
      Parameter                  : constant String := Iterator.Get_Parameter;

   begin
      Log_In (Debug or Ada_Lib_Trace_Trace or Trace_Options,
         Quote ("parameter", Parameter));

      for Trace of Parameter loop
         Log_Here (Debug or Ada_Lib_Trace_Trace or Trace_Options, " Extended " &
            Extended'img & Quote (" trace", Trace));

         case Extended is

            when False =>
               case Trace is

                  when 'a' =>
                     Set_All;

                  when 'b' =>
                     Ada_Lib_Database.Debug_Subscribe := True;

                  when 'c' =>
                     Ada_Lib_Command_Line_Iterator.Debug := True;

                  when 'C' =>
                     Ada_Lib_Configuration.Trace := True;

                  when 'e' =>
                     Ada_Lib_Event.Debug := True;

--                when 'g' =>
--                   GNOGA_Options.Debug := True;

--                when 'G' =>
--                   GNOGA_Options.Debug := True;

                  when 'h' =>
                     Ada_Lib_Help.Debug := True;

                  when 'i' =>
                     Ada_Lib_Interrupt.Debug := True;

                  when 'I' =>
                     Ada_Lib_Options.Debug := True;

                  when 'l' =>
                     Ada_Lib_Lock.Debug := True;

                  when 'm' =>
                     Ada_Lib_Timer.Debug := True;

                  when 'M' =>
                     Ada_Lib_EMail.Debug := True;
                     Ada_Lib_Mail.Debug := True;

                  when 'o' =>
                     Ada_Lib_OS.Trace := True;

                  when 'O' =>
                     Debug := True;

                  when 'p' =>
                     Ada_Lib_Parser.Debug := True;

                  when 'r' =>
                     Ada_Lib_OS.Run_Debug := True;
                     Ada_Lib_Database.Connection_Debug := True;

                  when 'R' =>
                     Ada_Lib_Options_Runstring.Debug := True;

                  when 's' =>
                     Ada_Lib_Socket_IO.Trace := True;

                  when 'S' =>
                     Ada_Lib_Socket_IO.Tracing := True;

                  when 't' =>
                     Ada_Lib_Trace_Trace := True;

                  when 'T' =>
                     Ada_Lib_Trace_Tasks.Debug := True;

                  when 'v' =>
                     Ada_Lib_Options_Verification.Debug := True;

                  when Ada_Lib.Help.Trace_Modifier =>
                     Extended := True;

                  when others =>
                     Options.Bad_Option (Quote ("unexpected Ada_Lib trace option",
                        Trace));

               end case;

            when True =>

               case Trace is

                  when 'c' =>
                     Ada_Lib_Template.Trace_Compile := True;

                  when 'd' =>
                     Ada_Lib.Trace.Detail := True;

                  when 'D' =>
                     Ada_Lib_Directory.Debug := True;

                  when 'e' =>
                     Ada_Lib_Template.Trace_Evaluate := True;

                  when 'E' =>
                     Ada_Lib_Template.Trace_Expand := True;

                  when 'l' =>
                     Ada_Lib_Template.Trace_Load := True;

                  when 'o' =>
                     Trace_Options := True;

                  when 'p' =>
                     Ada_Lib.Trace.Trace_Pre_Post_Conditions := True;

                  when 'P' =>
                     Ada_Lib.Trace.Trace_Pre_Post_False := True;

                  when 's' =>
                     Ada_Lib_Strings.Debug := True;

                  when 'S' =>
                     Ada_Lib_Socket_IO.Trace_IO := True;

                  when 't' =>
                     Ada_Lib_Text.Debug := True;

                  when others =>
                     Options.Bad_Option (Quote ("unexpected Ada_Lib trace option",
                        Trace));    -- aborts program

               end case;
               Extended := False;

         end case;
      end loop;
      Log_Out (Debug or Ada_Lib_Trace_Trace or Trace_Options);
   end Trace_Parse;

--   ----------------------------------------------------------------------------
--   procedure Program_Help (
--      Trace_Parse                : in     Program_Options_Type;  -- only used for dispatch
--      Iterator                   : in out Command_Line_Iterator_Interface'class) is
--   ----------------------------------------------------------------------------
--
--   begin
--not_implemented;
--   end Program_Help;

   ----------------------------------------------------------------------------
   overriding
   procedure Trace_Parse (
      Options              : in out Program_Options_Type;
      Iterator             : in out Command_Line_Iterator_Interface'class) is
   ----------------------------------------------------------------------------

   begin
not_implemented;
   end Trace_Parse;

-- ---------------------------------------------------------------
-- overriding
-- function Verify_Initialized (
--    Options     : in     Nested_Program_Options_Type;
--    From        : in     String := GNAT.Source_Info.Source_Location
-- ) return Boolean is
-- ---------------------------------------------------------------
--
--    Verify_Initialized
--                : constant Boolean := Verification.
--                   Verification_Nested_Options_Type (
--                      Options).Verify_Initialized;
--    Trace_Log   : constant Boolean := Debug or Trace_Options or (
--                   (not Verify_Initialized) and Trace_Pre_Post_Conditions);
-- begin
--    Log_In (Trace_Log,
--       "for Nested_Program_Options_Type Verify_Initialized " &
--       Verify_Initialized'img &
--       " Processed " & Options.Nested_Processed'img);
--    Tag_History (Trace_Log,"Verification_Nested_Options_Type",
--       Verification.Verification_Nested_Options_Type'class (Options)'tag);
--    if Verify_Initialized then
--       if Options.Nested_Processed then
--          declare
--             Message  : constant String :=
--                         "Options.Nested_Processed before inialization called from " & From;
--          begin
--             Log_Here (Message);
--             Put_Line (Message);
--          end;
--       else
--          return Log_Out (True, Trace_Log);
--       end if;
--    end if;
--
--    return Log_Out (False, True, "options not verified");
-- end Verify_Initialized;
--
-- ---------------------------------------------------------------
-- function Verify_Postprocess (
--    Options        : in     Nested_Program_Options_Type;
--    From           : in     String := GNAT.Source_Info.Source_Location
-- ) return Boolean is
-- ---------------------------------------------------------------
--
-- begin
--    Log_In (Debug or Trace_Options, Tag_Name ("options",
--       Nested_Program_Options_Type'class (Options)'tag) &
--       " called from " & From);
--    if Options.Nested_Processed then
--          return Log_Out (True, Debug or Trace_Options);
--    else
--       Put_Line ("not Options.Nested_Processed called from " & From);
--    end if;
--    Put_Line (Who & " " & Here);
--    return Log_Out (False, Debug or Trace_Options);
--
-- exception
--    when Fault: others =>
--       Trace_Exception (Fault);
--       return False;
--
-- end Verify_Postprocess;
--
-- ---------------------------------------------------------------
-- function Verify_Postprocess (
--    Options                    : in     Program_Options_Type;
--    From                       : in     String := GNAT.Source_Info.Source_Location
-- ) return Boolean is
-- ---------------------------------------------------------------
--
-- begin
--    if Options.Program_Processed then
--          return Log_Out (True, Debug or Trace_Options);
--    else
--       Put_Line ("Process not called");
--    end if;
--    Put_Line (Who & " " & Here);
--    return Log_Out (False, Debug or Trace_Options);
--
-- end Verify_Postprocess;
--
-- ---------------------------------------------------------------
-- overriding
-- function Verify_Preinitialize (
--    Options                    : in     Nested_Program_Options_Type;
--    From                       : in     String := GNAT.Source_Info.Source_Location
-- ) return Boolean is
-- ---------------------------------------------------------------
--
-- begin
--    Log_In (Debug or Trace_Options, "called from " & From);
--    if Verification.Verification_Nested_Options_Type (
--          Options).Verify_Preinitialize then
--       if Options.Nested_Processed then
--          Put_Line ("Options.Nested_Processed");
--       else
--          return Log_Out (True, Debug or Trace_Options);
--       end if;
--    else
--       Put_Line ("Ada_Lib_Options not initialized at " & Here &
--          " called from " & From);
--    end if;
--    return Log_Out (False, Debug);
--
-- exception
--    when Fault: others =>
--       Trace_Exception (Fault);
--       return False;
--
-- end Verify_Preinitialize;
--
-- ---------------------------------------------------------------
-- function Verify_Preprocess (
--    Options                    : in     Nested_Program_Options_Type;
--    From                       : in     String := GNAT.Source_Info.Source_Location
-- ) return Boolean is
-- ---------------------------------------------------------------
--
-- begin
--    Log_In (Debug or Trace_Options,  "called from " & From);
--    if Options.Verify_Step (Initialized) then
--       if Options.Nested_Processed then
--          Put_Line ("Options.Nested_Processed already called " & " called from " & From);
--       else
--          return Log_Out (True, Debug or Trace_Options);
--       end if;
--    else
--       Put_Line ("Ada_Lib_Options not initialized at " & Here & " called from " & From);
--    end if;
--    return Log_Out (False, Debug or Trace_Options);
-- end Verify_Preprocess;
--
-- ---------------------------------------------------------------
-- function Verify_Preprocess (
--    Options                    : in     Program_Options_Type;
--    From                       : in     String := GNAT.Source_Info.Source_Location
-- ) return Boolean is
-- ---------------------------------------------------------------
--
-- begin
--    Log_In (Debug or Trace_Options,  "called from " & From);
--    if Options.Verify_Step (Initialized) then
--       if Options.Program_Processed then
--          Put_Line ("Options.Program_Processed already called " &
--          " called from " & From);
--       else
--          return Log_Out (True, Debug or Trace_Options);
--       end if;
--    else
--       Put_Line ("Ada_Lib_Options not initialized at " & Here & " called from " & From);
--    end if;
--    return Log_Out (False, Debug or Trace_Options);
-- end Verify_Preprocess;

--   ---------------------------------------------------------------
--   overriding
--   function Verify_Step (
--      Options  : in     Program_Options_Type;
--      Step     : in     Initialization_Step_Type;
--      From     : in     String := GNAT.Source_Info.Source_Location
--   ) return Boolean is
--   ---------------------------------------------------------------
--
--      Log_It   : constant Boolean := Debug or Trace_Options;
--
--   begin
--      Log_In (Log_It,  "step " & Step'img & " called from " & From);
--      if not Options.Steps (Step) then
--         Put_Line (Step'img &" not set " & " called from " & From);
--         return False;
--      end if;
--
--      if Step > Initialization_Step_Type'first then
--         declare
--            Prefious_Step  : constant Initialization_Step_Type := Step - 1;
--
--         begin
--            if not Options.Steps (Prefious_Step) then
--               Put_Line (Prefious_Step'img & " not set " &
--                  " called from " & From);
--               return False;
--            end if;
--         end;
--      end if;
--
--      if Step < Initialization_Step_Type'last then
--         for Next_Step in Step + 1 .. Initialization_Step_Type'last loop
--            if Options.Steps (Next_Step then
--               Put_Line ("later step " Next_Step'img & "  set " &
--                  " called from " & From);
--               return False;
--            end if;
--         end loop;
--      end if;
--
--      return Log_Out (True, Log_It);
--   end Verify_Step;
--
--   ---------------------------------------------------------------
--   overriding
--   function Verify_Step (
--      Options  : in     Nested_Program_Options_Type;
--      Step     : in     Initialization_Step_Type;
--      From     : in     String := GNAT.Source_Info.Source_Location
--   ) return Boolean is
--   ---------------------------------------------------------------
--
--   begin
--not_implemented;
--return false;
--   end Verify_Step;
   ---------------------------------------------------------------

begin
--debug := true;
--Trace_Conversions := True;
--Elaborate := True;
--Trace_Pre_Post_Conditions := True;
--Trace_Options := True;
   Log_Here (Debug or Elaborate);
end Ada_Lib.Options.Program;
