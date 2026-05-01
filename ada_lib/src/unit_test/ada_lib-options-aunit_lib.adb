with Ada.Text_IO;use Ada.Text_IO;
with Ada_Lib.Configuration.Tests;
with Ada_Lib.Database.Server.Tests;
with Ada_Lib.Directory.Test;
with Ada_Lib.Help;
with Ada_Lib.Mail.Tests;
with Ada_Lib.Options.Create;
with Ada_Lib.Options.Runstring;
with Ada_Lib.Options.Verification;
with Ada_Lib.OS;
with Ada_Lib.Socket_IO.Stream_IO.Unit_Test;
with Ada_Lib.Strings;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Template;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with Ada_Lib.Unit_Test;

-- tests for the Ada_Lib unit tests
package body Ada_Lib.Options.AUnit_Lib is

-- use type Ada_Lib.Options.Flag_List_Type;

   Debug          : Boolean renames AUnit.Debug;
   Trace_Option                  : constant Character := 't';
   Options_With_Parameters       : aliased constant
                                    Flag_List_Type :=
                                       Create.Create_One (
                                          Trace_Option, Unmodified_flag);
   Options_Without_Parameters    : aliased constant
                                    Flag_List_Type :=
                                       Create.Create_One (
                                          't', Ada_Lib.Help.Modifier) &
                                       Create.Create_Multiple (
                                          "dT", Ada_Lib.Help.Unmodified_Flag);
   Trace_Modifier             : character renames Ada_Lib.Help.Trace_Modifier;

   ----------------------------------------------------------------------------
   overriding
   procedure Display_Help (
               -- prints full help
     Options   : in     Aunit_Program_Options_Type;     -- only used for dispatch
     Message   : in     String := "";  -- leave blank no error help
     Halt      : in     Boolean := True) is
   ----------------------------------------------------------------------------

      Log_It   : constant Boolean := Debug or Trace_Options;

   begin
      Log_In (Log_It, Ada_Lib.String_Quote.Quote ("message", Message) &
         " Options_Selection " &  Options.Options_Selection'img &
         " halt " & Halt'img);
      Tag_History (Log_It, "options", Aunit_Program_Options_Type'class (options)'tag);

      for Help_Mode in Help_Mode_Type'range loop
         Log_Here (Log_It, "Help_Mode " & Help_Mode'img &
            " Options_Selection " & Options.Options_Selection'img);
         Options.Program_Help (Help_Mode);
log_here;
--         Options.Get_Read_Only_Nested_Program_Options.Program_Help (Help_Mode);
--log_here;
--         Options.Nested_Unit_Test_Options.Program_Help (Help_Mode);
--         Options.GNOGA_Unit_Test_Options.Program_Help (Help_Mode);
--
--         case Options.Options_Selection is
--
--            when Unit_Test_With_Template_Only =>
--               Options.Template_Only.Program_Help (Help_Mode);
--
--            when Unit_Test_With_Database_And_Template =>
--               Options.Database_Options.Program_Help (Help_Mode);
--               Options.Template.Program_Help (Help_Mode);
--
--            when Unit_Test_With_No_Database_Or_Template =>
--               null;
--
--            when Unit_Test_With_Database_Only =>
--               Options.Database_Options.Program_Help (Help_Mode);
--
--         end case;

         if Help_Mode = Program_Mode then -- output the help
            Log_Here (Log_It);
            Program.Program_Options_Type (Options).Display_Help ("", False);
         end if;

      end loop;

      Log_Out (Log_It, "halt " & Halt'img);
      if Halt then
         Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.No_Error);
      end if;
   end Display_Help;

   -------------------------------------------------------------------------
   function Get_Modifiable_AUnit_Options (
      From                       : in  String := Ada_Lib.Trace.Here
   ) return Aunit_Program_Options_Class_Access is
   -------------------------------------------------------------------------

   begin
      Log_Here (Trace_Conversions, "from " & From);
      return Aunit_Program_Options_Class_Access (
         Verification.Get_Ada_Lib_Modifiable_Program_Options (From));
   end Get_Modifiable_AUnit_Options;

   -------------------------------------------------------------------------
   function Get_Read_Only_AUnit_Options (
      From                       : in  String := Ada_Lib.Trace.Here
   ) return Aunit_Program_Options_Constant_Class_Access is
   -------------------------------------------------------------------------

   begin
      Log_Here (Trace_Conversions, "from " & From);
      return Aunit_Program_Options_Constant_Class_Access (
         Verification.Get_Ada_Lib_Read_Only_Program_Options (From));
   end Get_Read_Only_AUnit_Options;

   -------------------------------------------------------------------------
   function Get_Read_Only_Nested_Unit_Test_Options (
      From                       : in  String := Ada_Lib.Trace.Here
   ) return Unit_Test.Ada_Lib_Unit_Test_Nested_Options_Constant_Class_Access is
   -------------------------------------------------------------------------

   begin
      Log_Here (Trace_Conversions, "from " & From);
      return Get_Read_Only_AUnit_Options.Nested_Unit_Test_Options'unchecked_access;
   end Get_Read_Only_Nested_Unit_Test_Options;

   -------------------------------------------------------------------------
   function Has_Database return Boolean is
   -------------------------------------------------------------------------

--    Options  : AUnit_Lib.Aunit_Program_Options_Type'class
--                renames AUnit_Lib.
--                   Aunit_Program_Options_Constant_Class_Access (
--                      Verification.Get_Ada_Lib_Read_Only_Nested_Options).all;
--    Options_Selection
--             : AUnit_Lib.Options_Selection_Type renames
--                Options.Options_Selection;
--    Result   : constant Boolean := (case Options_Selection is
--
--          when Unit_Test_With_Template_Only =>
--             False,
--
--          when Unit_Test_With_Database_And_Template =>
--             Options.Database_Options.Has_Database,
--
--          when Unit_Test_With_No_Database_Or_Template =>
--             False,
--
--          when Unit_Test_With_Database_Only =>
--             Options.Database_Only.Has_Database);
   begin
not_implemented;
return false;
--    return Log_Here (Result,
--       Debug or Trace_Options or Trace_Pre_Post_Conditions or not Result,
--       "Options_Selection " & Options.Options_Selection'img);
   end Has_Database;

   ----------------------------------------------------------------------------
   function Image (
     Options                     : in     Aunit_Program_Options_Type
   ) return String is
   ----------------------------------------------------------------------------

   begin
not_implemented;
return "";
   end Image;

   ----------------------------------------------------------------------------
   overriding
   function Initialize (
     Options                     : in out Aunit_Program_Options_Type;
     From                        : in     String := Standard.Ada_Lib.Trace.Here
   ) return Boolean is
   ----------------------------------------------------------------------------

   begin
      Log_In (Debug or Trace_Options,
         "Options_Selection " & Options.Options_Selection'img);

      Runstring.Options.Register (
         Runstring.With_Parameters, Options_With_Parameters);
      Runstring.Options.Register (
         Runstring.Without_Parameters, Options_Without_Parameters);

      return Log_Out (
         (case Options.Options_Selection is

            when Unit_Test_With_Template_Only =>
               Options.Template_Only.Initialize,

            when Unit_Test_With_No_Database_Or_Template =>
               True,

            when Unit_Test_With_Database_And_Template =>
               Options.Database_Options.Initialize and then
               Options.Template.Initialize,

            when Unit_Test_With_Database_Only =>
               Options.Database_Only.Initialize

         ) and then
         Options.GNOGA_Unit_Test_Options.Initialize and then
         Options.Nested_Unit_Test_Options.Initialize and then
         Program.Program_Options_Type (Options).Initialize,
         Debug or Trace_Options,
            "Options_Selection " & Options.Options_Selection'img);

   exception
      when Fault: others =>
         Trace_Exception (Fault);
         raise;

   end Initialize;

   ----------------------------------------------------------------------------
   function New_Suite return DBDamon_Test_Access is
   ----------------------------------------------------------------------------

   begin
      Log_Here (Debug);
      return new DBDamon_Test_Suite;
   end New_Suite;

   ----------------------------------------------------------------------------
   function New_Suite return Non_DBDamon_Test_Access is
   ----------------------------------------------------------------------------


   begin
      Log_Here (Debug);
      return new Non_DBDamon_Test_Suite;
   end New_Suite;

   ----------------------------------------------------------------------------
   overriding
   function Process (
      Options                    : in out Aunit_Program_Options_Type;
      Iterator                   : in out Command_Line_Iterator_Interface'class
   ) return Boolean is
   ----------------------------------------------------------------------------

   begin
      Log_In (Debug or Trace_Options);
--       Tag_Name (Nested_Program_Options_Type'class (Options)'tag));

      while not Iterator.At_End loop
         begin
            if Iterator.Is_Option then
               declare
                  Option         : constant Base_Flag_Option_Type'class :=
                                    Iterator.Get_Option;
                  Message        : constant String := Option.Image & " not defined";

               begin
                  Log_Here (Debug or Trace_Options, Option.Image &
                     " Options_Selection " & Options.Options_Selection'img);
                  if    Options.GNOGA_Unit_Test_Options.Process_Option (
                           Iterator, Option) or else
                        Options.Nested_Unit_Test_Options.Process_Option (
                           Iterator, Option) or else
--                      Options.Nested_Program_Options.Process_Option (
--                         Iterator, Option) or else
                        (case Options.Options_Selection is

                           when Unit_Test_With_Template_Only =>
                              Options.Template_Only.Process_Option (
                                 Iterator, Option),

                           when Unit_Test_With_Database_And_Template =>
                              Options.Database_Options.Process_Option (
                                 Iterator, Option) and then
                              (if Ada_Lib.Options.Ada_Lib_Environment.Help_Test then
                                 Options.Template.Process_Option (
                                    Iterator, Option)
                              else
                                 True),

                           when Unit_Test_With_No_Database_Or_Template =>
                              True,

                           when Unit_Test_With_Database_Only =>
                              Options.Database_Only.Process_Option (
                                 Iterator, Option)
                        ) then
                     Log_Here (Debug or Trace_Options, Option.Image, "processed");
                  else
                     Log_Here (Debug or Trace_Options, Message);
                     Options.Bad_Option (Option, Message);     -- aborts program
                     return Log_Out (False, Debug or Trace_Options);
                  end if;
               end;
            else
               declare
                  Argument          : constant String :=
                                       Iterator.Get_Argument;
               begin
--                if not Options.Nested_Program_Options.Process_Argument (
--                      Iterator, Argument) then
                     Log_Out (Debug or Trace_Options);
                     Options.Bad_Option ("unexpected '" & Argument & "' on run string" &
                        " from " & Here);
                        -- raises exception
--                end if;
               end;
            end if;

--       exception
--
--          when Fault: others =>
--             Trace_Exception (Debug or Trace_Options, Fault);
--             if not Options.Nested_Program_Options.Help_Test then
--                raise;
--             end if;

         end;
         if not Iterator.At_End then
            Iterator.Advance;
         end if;
      end loop;

      return Log_Out (True, Debug or Trace_Options, "processed");

   exception

      when Fault: others =>
         Trace_Exception (Debug or Trace_Options, Fault);
         raise;

   end Process;

   ----------------------------------------------------------------------------
   overriding
   function Process_Option (
      Options                    : in out Aunit_Program_Options_Type;
      Iterator                   : in out Command_Line_Iterator_Interface'class;
      Option                     : in     Base_Flag_Option_Type'class
   ) return Boolean is
   ----------------------------------------------------------------------------

      Has_It                     : constant Boolean :=
                                    Has_Option (Option,
                                       Options_With_Parameters,
                                       Options_Without_Parameters);
   begin
      Log_In (Trace_Options or Debug, Option.Image &
         " has options " & Has_It'img &
         " option selection " & Options.Options_Selection'img &
         " Options address " & Ada_Lib.Strings.Image (Options'address));

      if Has_It then
         if Option.Modified then
            return Log_Out (False, Trace_Options or Debug);
         end if;

         case Option.Option is

            when 'A' => -- ada_lib trace options
                Options.Trace_Parse (Iterator);

            when Trace_Option =>    -- t
               Options.Trace_Parse (Iterator);

            when Others =>
               Log_Exception (Trace_Options or Debug, " other option" & Option.Image);
               raise Failed with "Has_Option incorrectly passed " & Option.Image;
         end case;

         return Log_Out (True, Trace_Options or Debug);

      else
         return Log_Out (
            (case Options.Options_Selection is

               when Unit_Test_With_Template_Only =>
                  Options.Template_Only.Process_Option (Iterator, Option),

               when Unit_Test_With_No_Database_Or_Template =>
                  False,

               when Unit_Test_With_Database_And_Template =>
                  Options.Database_Options.Process_Option (
                     Iterator, Option) or else
                  Options.Template.Process_Option (Iterator, Option),

               when Unit_Test_With_Database_Only =>
                  Options.Database_Only.Process_Option (Iterator, Option)

            ) or else
            Options.Ada_Lib_Trace_Options.Process_Option (
               Iterator, Option) or else
            Options.GNOGA_Unit_Test_Options.Process_Option (
               Iterator, Option) or else
            Options.Nested_Unit_Test_Options.Process_Option (Iterator, Option) or else
            Program.Program_Options_Type (Options).Process_Option (
               Iterator, Option),
            Trace_Options or Debug, Option.Image & " processed");
      end if;
   end Process_Option;

   ----------------------------------------------------------------------------
   overriding
   procedure Program_Help (
      Options                    : in      Aunit_Program_Options_Type;  -- only used for dispatch
      Help_Mode                  : in      Help_Mode_Type) is
   ----------------------------------------------------------------------------

      Component                  : constant String := "Ada_Lib Unit Test";

   begin
      Log_In (Debug or Trace_Options, "mode " & Help_Mode'img);
      case Help_Mode is

      when Program_Mode =>
         Ada_Lib.Help.Create_Option (Trace_Option, "trace options",
            "ada_lib trace options", Component, Ada_Lib.Help.Unmodified_Flag);

      when Trace_Mode =>
         Put_Line (Ada_Lib.Trace.Who & " trace options (-" &
            Trace_Option & ")");
         Put_Line ("      a               all");
         Put_Line ("      A               AUnit debug");
         Put_Line ("      c               configuration");
         Put_Line ("      C               command line iterator");
         Put_Line ("      d               directory compare and copy");
         Put_Line ("      h               help test");
         Put_Line ("      i               Socket_IO.Client trace");
         Put_Line ("      l               Lock Test");
         Put_Line ("      m               Mail Test");
         Put_Line ("      o               Ada_Lib.Options.AUnit_Lib options");
--       Put_Line ("      r               suites");
         Put_Line ("      R               Tester_Debug");
         Put_Line ("      s               Socket Stream Test");
         Put_Line ("      S               Database server Test");
         Put_Line ("      t               Template Test");
         Put_Line ("      T               Timer Test");
         Put_Line ("      " & Trace_Modifier &
                          "c              Camera Commands Unit Test");
         Put_Line ("      " & Trace_Modifier &
                          "d              Debug Test");
         Put_Line ("      " & Trace_Modifier &
                          "T              Debug Tests");
         Put_Line ("      " & Trace_Modifier &
                          "t              Debug Test routines");
         New_Line;

      end case;
      case Options.Options_Selection is

         when Unit_Test_With_Template_Only =>
            Options.Template_Only.Program_Help (Help_Mode);

         when Unit_Test_With_No_Database_Or_Template =>
            null;

         when Unit_Test_With_Database_And_Template =>
            Options.Database_Options.Program_Help (Help_Mode);
            Options.Template.Program_Help (Help_Mode);

         when Unit_Test_With_Database_Only =>
            Options.Database_Only.Program_Help (Help_Mode);

      end case;
      Options.GNOGA_Unit_Test_Options.Program_Help (Help_Mode);
      Options.Nested_Unit_Test_Options.Program_Help (Help_Mode);
log_here;
      Program.Program_Options_Type (Options).Program_Help (Help_Mode);

      Log_Out (Debug or Trace_Options);
   end Program_Help;

   ----------------------------------------------------------------------------
   procedure Register_Tests (
      Options                    : in     Aunit_Program_Options_Type;
      Suite_Name                 : in     String;
      Test                       : in out Ada_Lib.Unit_Test.Test_Cases.
                                             Test_Case_Type'class) is
   ----------------------------------------------------------------------------

   begin
      Log_In (Debug);
      Ada_Lib.Unit_Test.Suite (Suite_Name);  -- used for listing suites
      Test.Register_Tests;
      Log_Out (Debug);
   end Register_Tests;

-- ----------------------------------------------------------------------------
-- procedure Set_Options is
-- ----------------------------------------------------------------------------
--
-- begin
--    Log_Here (Debug, Tag_Name (Aunit_Program_Options_Type'class (Protected_Options)'tag));
--
--    Ada_Lib.Options.Set_Ada_Lib_Options (
--       Protected_Options'access);
-- end Set_Options;

   ----------------------------------------------------------------------------
   overriding
   procedure Trace_Parse (
      Options     : in out Aunit_Program_Options_Type;
      Iterator    : in out Command_Line_Iterator_Interface'class) is
   ----------------------------------------------------------------------------

      Trace_Tests_Debug       : Boolean renames
                                 Unit_Test.Ada_Lib_Options_Trace_Tests.Debug_Unit_Test;
      Trace_Tests_Debug_Test  : Boolean renames
                                 Unit_Test.Ada_Lib_Options_Trace_Tests.Debug_Test;
      Trace_Tests_Debug_Tests : Boolean renames
                                 Unit_Test.Ada_Lib_Options_Trace_Tests.Debug_Tests;
      Extended                : Boolean := False;
      Parameter               : constant String := Iterator.Get_Parameter;

   begin
      Log (Trace_Options or Debug, Here, Who & Quote (" Parameter", Parameter));
      for Index in Parameter'range  loop
         declare
            Trace    : constant Character := Parameter (Index);

         begin
            Log_Here (Trace_Options or Debug, Quote ("trace", Trace) &
               " extended " & Extended'img);
            case Extended is

               when False =>
                  case Trace is

                     when 'a' =>
                        Ada_Lib_Command_Line_Iterator.Tests_Debug := True;
                        Ada_Lib.Configuration.Tests.Debug := True;
                        Ada_Lib.Database.Server.Tests.Debug := True;
                        AUnit.Debug := True;
                        Ada_Lib.Mail.Tests.Debug := True;
                        Ada_Lib.Socket_IO.Stream_IO.Unit_Test.Debug := True;
                        Ada_Lib.Template.Trace_Compile := True;
                        Ada_Lib.Template.Trace_Evaluate := True;
                        Ada_Lib.Template.Trace_Expand := True;
                        Ada_Lib.Template.Trace_Load := True;
                        Ada_Lib.Template.Trace_Test := True;
                        Trace_Tests_Debug := True;
                        Trace_Tests_Debug_Test := True;
                        Trace_Tests_Debug_Tests := True;
                        Debug := True;
                        Unit_Test.Ada_Lib_AUnit.Tester_Debug := True;
                        Unit_Test.Ada_Lib_Help_Unit_Test.Debug := True;
                        Unit_Test.Ada_Lib_Lock_Unit_Test.Debug := True;
                        Unit_Test.Ada_Lib_Options_Unit_Test.Client_Debug := True;

                     when 'A' =>
                        AUnit.Debug := True;

                     when 'c' =>
                        Ada_Lib.Configuration.Tests.Debug := True;

                     when 'C' =>
                        Ada_Lib_Command_Line_Iterator.Tests_Debug := True;

                     when 'd' =>
                        Ada_Lib.Directory.Test.Debug := True;

                     when 'h' =>
                        Unit_Test.Ada_Lib_Help_Unit_Test.Debug := True;

                     when 'i' =>
                        Unit_Test.Ada_Lib_Options_Unit_Test.Client_Debug := True;

                     when 'l' =>
                        Unit_Test.Ada_Lib_Lock_Unit_Test.Debug := True;

                     when 'm' =>
                        Ada_Lib.Mail.Tests.Debug := True;

                     when 'o' =>
                        Debug := True;

--                   when 'r' =>
--                      Debug := True;

                     when 'R' =>
                        Unit_Test.Ada_Lib_AUnit.Tester_Debug := True;

                     when 's' =>
                        Ada_Lib.Socket_IO.Stream_IO.Unit_Test.Debug := True;

                     when 'S' =>
                        Ada_Lib.Database.Server.Tests.Debug := True;

                     when 't' =>
                        Ada_Lib.Template.Trace_Test := True;

                     when 'T' =>
                        Trace_Tests_Debug := True;

      --             when 'u' =>
      --                Ada_Lib.Unit_Test.Debug := True;

                     when Trace_Modifier =>
                        Extended := True;

                     when others =>
                        Options.Bad_Trace_Option (Trace_Option, Trace);

                  end case;

               when True =>
                  case Trace is

                     when 'd' =>
                        Trace_Tests_Debug_Test := True;

                     when 't' =>
                        Trace_Tests_Debug := True;

                     when 'T' =>
                        Trace_Tests_Debug_Tests := True;

                     when others =>
                        Options.Bad_Trace_Option (Trace_Option, Trace,
                           Ada_Lib.Help.Trace_Modifier);

                  end case;
                  Extended := False;

            end case;
         end;
      end loop;
--    GNOGA_Iterator.Trace_Parse (Iterator);
   end Trace_Parse;

begin
-- AUnit_Lib_Options := Protected_Options'access;
-- Elaborate := True;
   Debug := Debug or Debug_All;
--Trace_Options := True;
--debug := True;
--Protected_Options.Tester_Debug := True;
   Log_Here (Elaborate or Trace_Options or Debug);

exception
   when Fault: others =>
      Trace_Exception (Fault);
-- Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.No_Error);
end Ada_Lib.Options.AUnit_Lib;

