
with Ada.Command_Line;
--with Ada.Exceptions;
with Ada.Strings.Fixed;
--with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada.Text_IO; use Ada.Text_IO;
--with Ada_Lib.OS;
with Ada_Lib.Options.Runstring;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with GNAT.OS_Lib;

--pragma Elaborate_All (Ada_Lib.OS);

package body Ada_Lib.Command_Line_Iterator is

-- use type Ada.Strings.Maps.Character_Set;
-- use type Ada_Lib.Strings.String_Access;
   use type Ada_Lib.Strings.String_Constant_Access;
-- use type Ada_Lib.Strings.Unlimited.String_Type;
   use type Ada_Lib.Options.Flag_Option_Kind_Type;

   package Modular_IO         is new Ada.Text_IO.Modular_IO (Interfaces.Unsigned_64);

   package body Abstract_Package is

      -- raises No_Argument, Invalid_Option
      -------------------------------------------------------------------
      overriding
      procedure Advance (
         Iterator          : in out Abstract_Iterator_Type) is
      -------------------------------------------------------------------

         ----------------------------------------------------------------
         function Next_Argument
         return Boolean is
         ----------------------------------------------------------------

         begin
            Log_In (Debug, "Argument_Index" & Iterator.Argument_Index'img);
            Iterator.Argument_Index := Iterator.Argument_Index + 1;
            if Iterator.Argument_Index >
                  Abstract_Iterator_Type'class (Iterator).Number_Arguments then
               return Log_Out (False, Debug);
            else
               Iterator.Argument.Set (Iterator.Internal_Get_Argument);
               Iterator.Character_Index := 0;
               return Log_Out (True, Debug, "Argument_Index" &
                  Iterator.Argument_Index'img);
            end if;
         end Next_Argument;

         ----------------------------------------------------------------
         function Next_Character (
            Get_Next_Argument        : in     Boolean
         ) return Boolean is
         ----------------------------------------------------------------

         begin
            Log_In (Debug, "Character_Index" & Iterator.Character_Index'img &
               " next_option " & Get_Next_Argument'img);
            if    Iterator.Character_Index = 0 or else
                  Iterator.Character_Index >= Iterator.Argument.Length then
               if Get_Next_Argument then
                  if not Next_Argument then
                     return Log_Out (False, Debug);
                  end if;
               else
                  return Log_Out (False, Debug);
               end if;
            end if;

            Iterator.Character_Index := Iterator.Character_Index + 1;

            Iterator.Current := (
               if Iterator.Character_Index > Iterator.Argument.Length then
                  Ada.Characters.Latin_1.Nul
               else
                  Iterator.Argument.Element (Iterator.Character_Index));

            return Log_Out (True, Debug, Quote ("current", Iterator.Current) &
               " Character_Index" & Iterator.Character_Index'img);
         end Next_Character;

         ----------------------------------------------------------------
         procedure Start_Option is
         ----------------------------------------------------------------

         begin
            Log_In (Debug);
            -- check if option has a modfier
            if Ada.Strings.Maps.Is_In (Iterator.Current,
                 Iterator.Modifiers) then   -- have modifier
               Log_Here (Debug, "have modifier");
               if Iterator.Character_Index >=
                     Iterator.Argument.Length then
                  Log_Exception (Debug);
                  raise Invalid_Option with
                     Quote ("No letter following modifier", Iterator.Current);
                           end if;

               Iterator.Option.Modifier := Iterator.Current;
               Iterator.Option.Kind :=
                  Ada_Lib.Options.Modified;
               if not Next_Character (False) then    -- get option character
                  raise Failed with "next_character should never fail";
               end if;
            else
               Iterator.Option.Kind :=
                  Ada_Lib.Options.Plain;
            end if;

            Iterator.Option.Option := Iterator.Current;
            Log_Here (Debug, Iterator.Option.Image (True));

            -- make sure option is registerd
            if Ada_Lib.Options.Runstring.Options.Is_Registered (
                 Iterator.Option) then
               Log_Here (Debug, "registered " &
                  Iterator.Option.Image (True));
               -- check if it has a parameter
               if Ada_Lib.Options.Runstring.Options.Has_Parameter (
                    Iterator.Option) then
                  Log_Here (Debug, "need parameter");
                                 -- option needs parameter
                  Iterator.State := Option_With_Parameter;
                  Iterator.Has_Parameter := True;
                  if not Next_Character (False) then -- next true then inline parameter
                     -- paramete is next Argument
                     Iterator.Character_Index := 0;   -- force end of argument
                     if not Next_Character (True) then
                        Log_Exception (Debug);
                        raise No_Argument with "Missing parameter for '" &
                           Iterator.Option.Image (False);
                     end if;
                  end if;
                  Iterator.Parameter_Index := Iterator.Character_Index;
                  Iterator.Character_Index := 0; -- mark end of argument
               else   -- no parameter is next argument
                  Iterator.State := Option;
                  Iterator.Has_Parameter := False;
               end if;

               Abstract_Iterator_Type'class (Iterator).Dump_Iterator (
                  "Start_Option out");
               Log_Out (Debug, "state " & Iterator.State'img);
            else
               Log_Exception (Debug);
               raise Not_Option with "'" & Iterator.Option.Image &
                  "' is not a registered option";
            end if;
         end Start_Option;

         ----------------------------------------------------------------
         procedure Iterate is
         ----------------------------------------------------------------

         begin
            Log_In (Debug, "State " & Iterator.State'img &
               Quote (" letter ", Iterator.Current));

            loop     -- until get state ready to process
               case Iterator.State is
                  when Argument =>     -- finished start next parameter
                     Iterator.State := Initial; -- end of this parameter
                     Iterator.Has_Parameter := False;
                     Iterator.Character_Index := 0;

                  when Initial  =>    -- start new parameter
                     if not Next_Character (True) then   -- get next parameter
                        Iterator.State := At_End;
                        Log_Out (Debug);
                        return;
                     end if;

                     if Iterator.Current = Iterator.Option_Prefix then
                                -- found an option
                        if Iterator.Argument.Length < 2 then
                           Log_Exception (Debug);
                           raise Invalid_Option with
                              Quote ("No option letter following",
                                 Iterator.Option_Prefix);
                        end if;

                        Log_Here (Debug, "start options");
                        if Next_Character (True) then
                           Start_Option;
                           Log_Out (Debug, "have option state " &
                              Iterator.State'img);
                           return;
                        else
                           Log_Exception (Debug);
                           raise Failed with "next_character should not fail";
                        end if;
                     else
                        Iterator.State := Argument;
                        Iterator.Has_Parameter := False;
                        Log_Out (Debug, "have argument");
                        return;
                     end if;

                  when Option =>
                     if Next_Character (False) then   -- get next option character
                        Start_Option;
                        Log_Out (Debug,"have option");
                        return;
                     else
                        Iterator.State := Initial; -- end of this parameter
                        Iterator.Has_Parameter := False;
                     end if;


                  when At_End =>
                     Log_Out (Debug, "at end");
                     return;

                  when Option_With_Parameter =>
                     Iterator.Character_Index := 0;
                        -- idicate at end of current argument
                     Iterator.State := Initial; -- end of this parameter
                     Iterator.Has_Parameter := False;

                  when Quoted =>
                     Log_Exception (Debug);
                     raise Failed with "quoted on start";

--                when others =>
--                   Log_Exception (Debug);
--                   raise Failed with "unexpected state " &
--                      Iterator.State'img;

               end case;

               Log_Here (Debug, "state " & Iterator.State'img);

            end loop;
         end Iterate;
         ----------------------------------------------------------------

      begin
         Log_In (Debug);
         Iterator.Option := Ada_Lib.Options.Flags.Null_Flag_Option;
         Abstract_Iterator_Type'class (Iterator).Dump_Iterator ("Advance in");
         Iterate;
         Iterator.Dump_Iterator ("Advance out");
         Log_Out (Debug);
      end Advance;

      -------------------------------------------------------------------
      overriding
      function At_End (
         Iterator          : in   Abstract_Iterator_Type
      ) return Boolean is
      -------------------------------------------------------------------

         Result                  : constant Boolean := Iterator.State = At_End;

      begin
         Log_Here (Debug, "end " & Result'img & " state " & Iterator.State'img);
         return Result;
      end At_End;

      -------------------------------------------------------------------
      overriding
      procedure Dump_Iterator (
         Iterator                : in     Abstract_Iterator_Type;
         What                    : in     String;
         Where                   : in     String := Ada_Lib.Trace.Here) is
      -------------------------------------------------------------------

         Class_Iterator          : Abstract_Iterator_Type'class
                                    renames Abstract_Iterator_Type'class (
                                       Iterator);
      begin
         if Debug and then not Inhibit_Trace then
            Debug := False;
            Ada_Lib.Options.Ada_Lib_Options_Runstring.Debug := False;
            Put_Line ("Iterator for " & What & " from " & Where);
            Put_Line ("  State                   " & Iterator.State'img);
            Put_Line (Quote ("  Argument                ",
               (if Iterator.State = At_End then
                     "end of iterator"
                  else
                     Class_Iterator.Get_Argument)));
            Put_Line ("  Argument_Index         " & Iterator.Argument_Index'img);
            Put_Line ("  At_End                  " & Iterator.At_End'img);
            Put_Line ("  Character_Index        " & Iterator.Character_Index'img);
            Put_Line ("  Has_Parameter           " & Iterator.Has_Parameter'img);
            Put_Line ("  Include_Non_Options     " & Iterator.
               Include_Non_Options'img);
            Put_Line ("  Modifiers               " &
               Ada.Strings.Maps.To_Sequence (Iterator.Modifiers));
            Put_Line ("  Include_Options     " & Iterator.Include_Options'img);
            Put_Line ("  Number_Arguments    " & Class_Iterator.Number_Arguments'img);
            Put_Line ("  Option              " & Iterator.Option.Image (False));
            Put_Line ("  Options_Prefix      " & Iterator.Option_Prefix);
            Put_Line ("  Parameter_Index     " & Iterator.Parameter_Index'img);
            Debug := True;
            Ada_Lib.Options.Ada_Lib_Options_Runstring.Debug := True;
         end if;
      end Dump_Iterator;

      -------------------------------------------------------------------
      overriding
      function Get_Argument (
         Iterator          : in     Abstract_Iterator_Type
      ) return String is
      -------------------------------------------------------------------

      begin
         return Iterator.Internal_Get_Argument;
      end Get_Argument;

      -- raise Invalid_Number
      -------------------------------------------------------------------
      overriding
      function Get_Float (
         Iterator          : in out Abstract_Iterator_Type
      ) return Float is
      -------------------------------------------------------------------

         Parameter            : constant String := Get_Parameter (Iterator);

      begin
         Log_Here (Debug, "result " & Parameter);
         return Float'Value (Parameter);

      exception
         when CONSTRAINT_ERROR =>
            Log_Exception (Debug);
            raise Invalid_Number with
               "Invalid numeric parameter '" & Parameter & "' for '" &
               Iterator.Option.Image & "' option.";

      end Get_Float;

      -- raise Invalid_Number
      -------------------------------------------------------------------
      overriding
      function Get_Integer (
         Iterator          : in out Abstract_Iterator_Type
      ) return Integer is
      -------------------------------------------------------------------

         Parameter            : constant String := Get_Parameter (Iterator);

      begin
         Log_Here (Debug, "result " & Parameter);
         return Integer'Value (Parameter);

      exception
         when CONSTRAINT_ERROR =>
            Log_Exception (Debug);
            raise Invalid_Number with
               "Invalid numeric parameter '" & Parameter & "' for '" &
               Iterator.Option.Image & "' option.";

      end Get_Integer;

      -- raise Invalid_Number
      -------------------------------------------------------------------
      overriding
      function Get_Unsigned (
         Iterator          : in out Abstract_Iterator_Type;
         Base              : in   Positive := 16
      ) return Interfaces.Unsigned_64 is
      -------------------------------------------------------------------

         Last              : Positive;
         Parameter            : constant String :=
                              Positive'Image (Base) &
                              "#" &
                              Get_Parameter (Iterator) &
                              "#";
         Value             : Interfaces.Unsigned_64;


      begin
         Log_In (Debug, "result " & Parameter);
         Modular_IO.Get (Parameter, Value, Last);
         Log_Out (Debug, "value" & Value'img);
         return Value;

      exception
         when CONSTRAINT_ERROR =>
            Log_Exception (Debug);
            raise Invalid_Number with
               "Invalid numeric parameter '" & Parameter & "' for '" &
               Iterator.Option.Image & "' option.";

      end Get_Unsigned;

      -------------------------------------------------------------------
      overriding
      function Get_Option (
         Iterator          : in   Abstract_Iterator_Type
      ) return Options.Base_Flag_Option_Type'class is
      -------------------------------------------------------------------

      begin
         Log_In (Debug);
         Abstract_Iterator_Type'class (Iterator).Dump_Iterator ("Get_Option");
         Log_Out (Debug, "result " & Iterator.Option.Image);
         return Iterator.Option;
      end Get_Option;

      -- raises No_Parameter, Not_Option
      -------------------------------------------------------------------
      overriding
      function Get_Parameter (
         Iterator          : in out Abstract_Iterator_Type
      ) return String is
      -------------------------------------------------------------------

      begin
         Log_In (Debug);
         Abstract_Iterator_Type'class (Iterator).Dump_Iterator ("Get_Parameter");

         if Iterator.At_End then
            Log_Exception (Debug);
            raise No_Parameter with
               "Get_Parameter called for option (" & Iterator.Option.Image &
                  " at end of command line found. Exception raised at " & Here;
         end if;

         if not Iterator.Has_Parameter then
            raise No_Parameter with
               "Get_Parameter called for option '" &
               Iterator.Option.Image & "' with no parameters";
         end if;

         declare
            Result               : constant String :=
                                    Iterator.Argument.Slice (Iterator.Parameter_Index,
                                       Iterator.Argument.Length);
         begin
            Log_Out (Debug, "result " & Result);
            return Result;
         end;
      end Get_Parameter;

      -------------------------------------------------------------------
      function Get_Signed (
         Iterator          : in out Abstract_Iterator_Type
      ) return Value_Type is
      -------------------------------------------------------------------

         Parameter            : constant String := Get_Parameter (Iterator);

      begin
         Log_Here (Debug, "result " & Parameter);
         return Value_Type'Value (Parameter);

      exception
         when CONSTRAINT_ERROR =>
            Log_Exception (Debug);
            raise Invalid_Number with
               "Invalid signed parameter '" & Parameter & "' for '" &
               Iterator.Option.Image & "' option.";

      end Get_Signed;

      -------------------------------------------------------------------
      function Get_State (
         Iterator          : in   Abstract_Iterator_Type
      ) return Iterator_State_Type is
      -------------------------------------------------------------------

      begin
         return Iterator.State;
      end Get_State;

      -- raises No_Argument, Not_Option
      -------------------------------------------------------------------
      function Has_Parameter (
         Iterator          : in   Abstract_Iterator_Type
      ) return Boolean is
      -------------------------------------------------------------------

      begin
         return Iterator.Unchecked_Has_Parameter;
      end Has_Parameter;

      -------------------------------------------------------------------
      -- raises No_Selection, Invalid_Option
      procedure Initialize (
         Iterator                : in out Abstract_Iterator_Type;
         Number_Arguments        : in     Natural;
         Include_Options         : in     Boolean;
         Include_Non_Options     : in     Boolean;
         Option_Prefix           : in     Character := '-';
         Modifiers               : in     String := "";
         Skip                    : in     Natural := 0) is
      -------------------------------------------------------------------

      begin
         Log_In (Debug, "Number_Arguments" & Number_Arguments'img &
            " Include_Options " & Include_Options'img &
            " Include_Non_Options " & Include_Non_Options'img &
            Ada_Lib.String_Quote.Quote (" Option_Prefix", Option_Prefix) &
            Ada_Lib.String_Quote.Quote (" Modifiers", Modifiers) &
            "' Skip '" & Skip'img);

         if not (Include_Options or
                Include_Non_Options) then
            Log_Exception (Debug);
            raise No_Selection;
         end if;

         Iterator.Argument_Count          := Number_Arguments;
         Iterator.Argument_Index          := Skip;
         Iterator.Character_Index         := 0;
         Iterator.Has_Parameter           := False;
         Iterator.Include_Options         := Include_Options;
         Iterator.Include_Non_Options     := Include_Non_Options;
         Iterator.Modifiers               := Ada.Strings.Maps.To_Set (Modifiers);
         Iterator.Option                  := Ada_Lib.Options.Flags.Null_Flag_Option;
         Iterator.Option_Prefix           := Option_Prefix;
         Iterator.Parameter_Index         := 1;
         Iterator.State                   := Initial;
         Iterator.Dump_Iterator("initialize");

         Log_Out (Debug);

      exception
         when Fault: others =>
            Trace_Exception (Fault);
            Put_Line ("aborting");
            GNAT.OS_Lib.OS_Exit (-1);
--          Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.Exception_Exit);

      end Initialize;

      -------------------------------------------------------------------
      function Internal_Get_Argument (
         Iterator          : in     Abstract_Iterator_Type
      ) return String is
      -------------------------------------------------------------------

      begin
         Log_In (Debug, "Argument_Index" & Iterator.Argument_Index'img);
         Abstract_Iterator_Type'class (Iterator).Dump_Iterator ("Get_Argument");

         if Iterator.State = At_End then
            Log_Exception (Debug);
            raise No_Argument;
         end if;

         declare
            Result               : constant String := (
                                    if Iterator.Argument_Index = 0 then
                                       ""
                                    else
                                       Abstract_Iterator_Type'class (
                                          Iterator).Get_Argument (
                                             Iterator.Argument_Index));
         begin
            Log_Out (Debug, Quote ("result", Result));
            return Result;
         end;
      end Internal_Get_Argument;

      -- raises No_Argument
      -------------------------------------------------------------------
      overriding
      function Is_Option (
         Iterator          : in   Abstract_Iterator_Type
      ) return Boolean is
      -------------------------------------------------------------------

      begin
         Log_In (Debug);
         Iterator.Dump_Iterator ("Is_Option");
         if Iterator.At_End then
            Log_Exception (Debug);
            raise No_Argument;
         end if;

         return Log_Out (Option_States (Iterator.State),
            Debug, "state " & Iterator.State'img);
      end Is_Option;

      -------------------------------------------------------------------
      function Number_Arguments (
         Iterator          : in   Abstract_Iterator_Type
      ) return Natural is
      -------------------------------------------------------------------

      begin
--       Log_Here (Debug, "number arguments" & Iterator.Argument_Count'img);
         return Iterator.Argument_Count;
      end Number_Arguments;

      -------------------------------------------------------------------
      function Unchecked_Has_Parameter (
         Iterator          : in   Abstract_Iterator_Type
      ) return Boolean is
      -------------------------------------------------------------------

      begin
         Log_In (Debug);
         if Iterator.At_End then
            Log_Exception (Debug);
            raise No_Argument;
         end if;

         Log_Out (Debug, "result " & Iterator.Has_Parameter'img);
         return Iterator.Has_Parameter;
      end Unchecked_Has_Parameter;

   end Abstract_Package;

   package body Run_String is

      -------------------------------------------------------------------
      overriding
      function Get_Argument (
         Iterator                : in     Runstring_Iterator_Type;
         Index                   : in     Positive
      ) return String is
      pragma Unreferenced (Iterator);
      -------------------------------------------------------------------

      begin
         Log_Here (Debug, Quote ("result ", Ada.Command_Line.Argument (Index)) &
            " index" & Index'img);
               return Ada.Command_Line.Argument (Index);
      end Get_Argument;

      -- raises No_Selection, Invalid_Option
      -------------------------------------------------------------------
      procedure Initialize (
         Iterator                   :    out Runstring_Iterator_Type;
         Include_Options            : in     Boolean;
         Include_Non_Options        : in     Boolean;
         Option_Prefix              : in     Character := '-';
         Modifiers                  : in     String := "";
         Skip                       : in     Natural := 0) is
      -------------------------------------------------------------------

         Argument_Count          : constant Natural :=
                                    Ada.Command_Line.Argument_Count;

      begin
         Log_In (Debug, "argument count" & Argument_Count'img);

         Iterator.Initialize (Argument_Count, Include_Options,
            Include_Non_Options, Option_Prefix, Modifiers, Skip);

         Advance (Iterator);
         Iterator.Dump_Iterator ("Initialize");
         Log_Out (Debug);
      end Initialize;

      -------------------------------------------------------------------
      overriding
      function Number_Arguments (
         Iterator                : in   Runstring_Iterator_Type
      ) return Natural is
      -------------------------------------------------------------------

      begin
         Log_Here (Debug, "Number_Arguments" &
            Ada.Command_Line.Argument_Count'img);
         return Ada.Command_Line.Argument_Count;
      end Number_Arguments;

   end Run_String;

   package body Internal is

      -------------------------------------------------------------------
      overriding
      procedure Dump_Iterator (
         Iterator                : in     Iterator_Type;
         What                    : in     String;
         Where                   : in     String := Ada_Lib.Trace.Here) is
      -------------------------------------------------------------------

      begin
         if Debug and then not Inhibit_Trace then
            Abstract_Package.Abstract_Iterator_Type (Iterator).Dump_Iterator (
               Where);
            Put_Line ("  What                    '" & What & "'");
            Put_Line ("  Source                  '" & Iterator.Source.all & "'");
            Put_Line ("  Start                  " & Iterator.Start'img);
         end if;
      end Dump_Iterator;

      -------------------------------------------------------------------
      overriding
      function Get_Argument (
         Iterator                : in     Iterator_Type;
         Index                   : in     Positive
      ) return String is
      -------------------------------------------------------------------

         Argument_Count          : constant Natural :=
                                    Iterator_Type'class (
                                       Iterator).Number_Arguments;
      begin
         Log_In (Debug);
         if Index > Argument_Count then
            Log_Exception (Debug);
            raise No_Argument with "Invalid argument:" & Index'img &
               " max:" & Argument_Count'img;
         end if;
         Iterator.Dump_Iterator ("Get_Argument " & Here);
         declare
            Argument             : Argument_Type renames Iterator.Arguments (Index);
            Result               : constant String :=
                                    Iterator.Source (Argument.Start .. Argument.Stop);
         begin
            Log_Out (Debug, Quote ("result", Result));
            return Result;
         end;
      end Get_Argument;

      -- raises No_Selection, Invalid_Option
      -------------------------------------------------------------------
      procedure Initialize (
         Iterator                :    out Iterator_Type;
         Source                  : in     String;
         Include_Options         : in     Boolean;
         Include_Non_Options     : in     Boolean;
         Argument_Seperator      : in     Character := ' ';
         Option_Prefix           : in     Character := '-';
         Modifiers               : in     String := "";
         Skip                    : in     Natural := 0;
         Quote                   : in     Character := Ada.Characters.Latin_1.Nul) is
      -------------------------------------------------------------------

      begin
         Log_In (Debug, "source '" & Source & "'" &
            " include options " & Include_Options'img &
            " include non_options " & Include_Non_options'img &
            " argument seperator '" & Argument_Seperator & "'" &
            " Option_Prefix '" & Option_Prefix & "'" &
            Ada_Lib.String_Quote.Quote (" Quote", Quote) &
            " skip" & Skip'img);

         Iterator.Argument_Seperator := Argument_Seperator;
--       Iterator.Quote := Quote;
         Iterator.Seperator_Set := Ada.Strings.Maps.To_Set (Argument_Seperator);
         Iterator.Source := new String'(Source);
         Iterator.Start := Iterator.Source'first;

         -- count argumetns
         declare
            Number_Arguments     : Natural := 0;
            Start_Token          : Positive := Source'first;

         begin
            loop
               declare
                  End_Token      : Natural;

               begin
                  Ada.Strings.Fixed.Find_Token (Source, Iterator.Seperator_Set,
                     Start_Token, Ada.Strings.Outside, Start_Token, End_Token);

                  declare
                     Letter      : constant Character :=
                                    Source (Start_Token);
                  begin
                     Log_Here (Debug, "Start_Token" & Start_Token'img & " end" &
                        End_Token'img & Ada_Lib.String_Quote.Quote (" Letter", Letter));

                     if End_Token > 0 then
                        if Number_Arguments > Max_Arguments then
                           Log_Exception (Debug);
                           raise Too_Many_Arguments with "Too many arguments:" &
                              Number_Arguments'img & " max:" & Max_Arguments'img;
                        end if;

                        if Letter = Quote then  -- find end of quote
                           declare
                              End_Quote
                                 :constant Natural := Ada.Strings.Fixed.Index (
                                    Source, String'(1 => Quote), Start_Token + 1);
                           begin
                              if End_Quote = 0 then
                                 raise Invalid_Quote with
                                    Ada_Lib.String_Quote.Quote ("In source", Source) &
                                    " quote start at" & Start_Token'img;
                              end if;

                              Number_Arguments := Number_Arguments + 1;

                              Iterator.Arguments (Number_Arguments) :=
                                 Argument_Type'(
                                 Start    => Start_Token + 1,
                                 Stop     => End_Quote - 1);

                              Start_Token := End_Quote + 1;
                              Log_Here (Debug, "after quote Start_Token");
                           end;
                        else
                           Number_Arguments := Number_Arguments + 1;

                           Iterator.Arguments (Number_Arguments) := Argument_Type'(
                              Start    => Start_Token,
                              Stop     => End_Token);

                           Start_Token := End_Token + 1;
                        end if;

                        if Start_Token > Source'last then
                           exit;
                        end if;
                     else
                        exit;
                     end if;
                  end;
               end;
            end loop;

            Iterator.Initialize (Number_Arguments, Include_Options,
               Include_Non_Options, Option_Prefix, Modifiers, Skip);
         end;

         Advance (Iterator);
         Iterator.Dump_Iterator ("initialize");
         Log_Out (Debug);
      end Initialize;

   end Internal;

   ---------------------------------------------------------------
   procedure Make is
   ---------------------------------------------------------------

   begin
      null;
   end Make;

begin
   Debug := Debug or Ada_Lib.Options.Ada_Lib_Options.Debug_All;
--Debug := True;
--Trace_Options := True;
--Elaborate := True;
   Log_Here (Debug or Elaborate);
end Ada_Lib.Command_Line_Iterator;
