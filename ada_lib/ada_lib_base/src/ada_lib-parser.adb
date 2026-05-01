with Ada.Exceptions;
with Ada.Strings.Fixed;
with Ada_Lib.Options;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Strings;

--pragma Elaborate (Ada_Lib.Trace);

package body Ada_Lib.Parser is

-- use type Buffer_Type;

   procedure Dump (
      Iterator    : in     Iterator_Type;
      Line        : in     String := Here;
      What        : in     String := Who);

   Debug          : Boolean renames Options.Ada_Lib_Parser.Debug;
   Null_String    : Buffer_Type renames Buffer_Package.Null_String;

   -----------------------------------------------------------------------
   function At_End (
      Iterator             : in   Iterator_Type
   ) return Boolean is
   -----------------------------------------------------------------------

   begin
      Dump (Iterator);
      return Iterator.Current > Iterator.Length and then
             Iterator.Current_Value = Null_String and then
             Iterator.Current_Seperators = Null_String;
   end At_End;

   -----------------------------------------------------------------------
   procedure Dump (
      Iterator                   : in     Iterator_Type;
      Line                       : in     String := Here;
      What                       : in     String := Who) is
   -----------------------------------------------------------------------

   begin
      Log_Here (Debug, Line, What & " state " & Iterator.State'img &
         " Current" & Iterator.Current'img & " length" &
         Iterator.Length'img & " Last_Start" & Iterator.Last_Start'img &
         " Current_Value '" & Iterator.Current_Value.Coerce &
         "' Current_Seperators '" & Iterator.Current_Seperators.Coerce &
         "' buffer '" & Iterator.Buffer.Coerce & "'");
   end Dump;

   -----------------------------------------------------------------------
   function Get_Number (
      Iterator                   : in out Iterator_Type;
      Do_Next                    : in     Boolean := False
   ) return Integer is
   -----------------------------------------------------------------------

      Value                      : constant String :=
                                    Iterator.Get_Value (Do_Next, False);
      Result                     : constant Integer := Integer'value (Value);
   begin
      Log_Here (Debug, Quote ("value", Value) & ": " & Result'img);
      return Result;
   end Get_Number;

   -----------------------------------------------------------------------
   function Get_Original (     -- returns original unparsed value
      Iterator             : in   Iterator_Type
   ) return String is
   -----------------------------------------------------------------------

   begin
      return Iterator.Buffer.Coerce;
   end Get_Original;

   -----------------------------------------------------------------------
   function Get_Parsed (     -- returns start of buffer to current
      Iterator             : in   Iterator_Type
   ) return String is
   -----------------------------------------------------------------------

   begin
      return Buffer_Package.Slice (Iterator.Buffer, 1, Iterator.Current - 1);
   end Get_Parsed;

   -----------------------------------------------------------------------
   function Get_Remainder (
      Iterator             : in   Iterator_Type
   ) return String is
   -----------------------------------------------------------------------

   begin
      Dump (Iterator);
      if Iterator.Current <= Iterator.Length then
         return Buffer_Package.Slice (Iterator.Buffer, Iterator.Current, Iterator.Length);
      else
         return "";
      end if;
   end Get_Remainder;

   -----------------------------------------------------------------------
   function Get_Seperator (
      Iterator             : in   Iterator_Type
   ) return Character is
   -----------------------------------------------------------------------

   begin
      Log_In (Debug);
      if Iterator.Current_Seperators.Length = 0 then
         Log_Out (Debug);
         return No_Seperator;
      else
         declare
            Result               : constant Character :=
                                    Buffer_Package.Element (Iterator.Current_Seperators, 1);

         begin
            Log_Out (Debug, "seperator '" & Result & "'");
            return Result;
         end;
      end if;
   end Get_Seperator;

   -----------------------------------------------------------------------
   function Get_Seperators (
      Iterator             : in   Iterator_Type
   ) return String is
   -----------------------------------------------------------------------

   begin
      Log_In (Debug);
      if Iterator.Current_Seperators.Length = 0 then
         Log_Out (Debug);
         return "";
      else
         declare
            Result               : constant String :=
                                    Iterator.Current_Seperators.Coerce;

         begin
            Log_Out (Debug, Quote ("seperators", Result));
            return Result;
         end;
      end if;
   end Get_Seperators;

   -----------------------------------------------------------------------
   function Get_Value (
      Iterator                   : in out Iterator_Type;
      Do_Next                    : in     Boolean := False;
      Allow_Null                 : in     Boolean := False
   ) return String is
   -----------------------------------------------------------------------

   begin
      Log_In (Debug, "do next " & Do_Next'img & " Allow null " & Allow_Null'img);
      Dump (Iterator);

      if At_End (Iterator) then
         if Allow_Null then
            return "";
         end if;
         Log_Exception (Debug);
         raise Underflow with Ada_Lib.Strings.Unlimited.Quote (
            "iterator buffer", Iterator.Buffer);
      end if;

      declare
         Result                  : constant String := (if Iterator.Trim and then
                                          not Iterator.Quoted then
                                       Ada_Lib.Strings.Trim (Iterator.Current_Value.Coerce)
                                    else
                                       Iterator.Current_Value.Coerce);
      begin
         if Do_Next then
            Iterator.Next;
         end if;

         Log_Out (Debug, Quote ("result", Result) & " quoted " & Iterator.Quoted'img &
            " Do_Next " & Do_Next'img);
         return Result;
      end;
   end Get_Value;

   -----------------------------------------------------------------------
   function Initialize (
      Value                      : in     String;
      Seperators                 : in     String := " ";
      Ignore_Multiple_Seperators : in     Boolean := True;
      Comment_Seperator          : in     Character := No_Seperator;
      Trim_Spaces                : in     Boolean := True;
      Quotes                     : in     String := ""
   ) return Iterator_Type is
   -----------------------------------------------------------------------

      -------------------------------------------------------------------
      function Trimmed
      return String is
      -------------------------------------------------------------------

            End_Value               : Integer := Value'last;

      begin
            while End_Value >= Value'first and then
                  (  Value (End_Value) = Ada.Characters.Latin_1.CR or else
                     Value (End_Value) = Ada.Characters.Latin_1.LF) loop
               End_Value := End_Value - 1;
            end loop;
            if End_Value < Value'first then
               return "";
            elsif Trim_Spaces then
                return Ada_Lib.Strings.Trim (Value (Value'first .. End_Value));
         else
                return Value (Value'first .. End_Value);
         end if;
      end Trimmed;
      -------------------------------------------------------------------

      Iterator                : Iterator_Type;
      Trimmed_Value           : constant String := Trimmed;
      End_Value               : Natural := Trimmed_Value'last;

   begin
      Log_In (Debug, Quote ("Value", Value) & Quote (" Seperators", Seperators) &
         Quote (" Quotes", Quotes));
      if Comment_Seperator = No_Seperator then
         End_Value := Trimmed_Value'last;
      else
         declare
            Start_Comment     : constant Natural :=
                              Ada.Strings.Fixed.Index (Trimmed_Value,
                                 String'(1 => Comment_Seperator));

         begin
            if Start_Comment > 0 then
               End_Value := Start_Comment - 1;
            end if;
         end;
      end if;

      Iterator.Buffer := Ada_Lib.Strings.Unlimited.Coerce (Trimmed_Value (Trimmed_Value'first .. End_Value));
      Iterator.Current := 1;
      Iterator.Current_Seperators := Null_String;
      Iterator.Current_Value := Null_String;
      Iterator.Ignore_Multiple_Seperators := Ignore_Multiple_Seperators;
      Iterator.Last_Start := 1;
      Iterator.Length := Iterator.Buffer.Length;
      Iterator.Quoted := False;
      Iterator.Quotes := Ada.Strings.Maps.To_Set (Quotes);
      Iterator.Seperators := Ada.Strings.Maps.To_Set (Seperators);
      Iterator.State := Normal;
      Iterator.Trim := Trim_Spaces;

      Dump (Iterator);
      Iterator.Next;
      Log_Out (Debug);
      return Iterator;
   end Initialize;

   -----------------------------------------------------------------------
   procedure Initialize (
      Iterator                   :    out Iterator_Type;
      Value                      : in     String;
      Seperators                 : in     String := " ";
      Ignore_Multiple_Seperators : in     Boolean := True;
      Comment_Seperator          : in     Character := No_Seperator;
      Trim_Spaces                : in     Boolean := True;
      Quotes                     : in     String := "") is
   -----------------------------------------------------------------------

   begin
      Log_In (Debug,
         "value '" & Value &
         "' seperators '" & Seperators &
         "' quotes '" & Quotes &
         " Ignore_Multiple_Seperators " & Ignore_Multiple_Seperators'img &
         " Trim_Spaces " & Trim_Spaces'img);

      Iterator := Initialize (Value, Seperators, Ignore_Multiple_Seperators,
         Comment_Seperator, Trim_Spaces, Quotes);
      Log_Out (Debug);
   end Initialize;

   -----------------------------------------------------------------------
   function Is_Quoted (       -- returns true if last Get_Value was a quoted string
      Iterator             : in   Iterator_Type
   ) return Boolean is
   -----------------------------------------------------------------------

   begin
      Log_Here (Debug, "quoted " & Iterator.Quoted'img);
      return Iterator.Quoted;
   end Is_Quoted;

   -----------------------------------------------------------------------
   procedure Next (
      Iterator             : in out Iterator_Type) is
   -----------------------------------------------------------------------

--    Done                 : constant Boolean := Iterator.Current > Iterator.Length and
--                                                 Iterator.Current_Value = Null_String and
--                                                 Iterator.Current_Seperators = Null_String;

   begin
      Log_In (Debug);
      Dump (Iterator);

      Iterator.Current_Seperators := Null_String;
      Iterator.Current_Value := Null_String;
      Iterator.Quoted := False;
      Iterator.Last_Start := Iterator.Current;

      if Iterator.Current > Iterator.Length then
         Log_Out (Debug);
         return;
      end if;

      Dump (Iterator);

      for Index in Iterator.Current .. Iterator.Length loop
         declare
            Next        : constant Character := Buffer_Package.Element (Iterator.Buffer, Index);

         begin
            Log_Here (Debug, Quote ("Next", Next) & " Index" & Index'img &
               " state " & Iterator.State'img);
            Dump (Iterator);
            Iterator.Current := Index + 1;

            case Iterator.State is

               when Normal =>
                  if Ada.Strings.Maps.Is_In (Next, Iterator.Quotes) then -- start quote
                     Iterator.State := Quote;
                     if Iterator.Current_Value.Length > 0 then  -- have a value to return
                        return;
                     elsif Iterator.Current_Seperators.Length > 0 then  -- have a seperator to return
                        Log_Out (Debug);
                        return;
                     end if;
                     Log_Here (Debug, "in quote");
                  else
                     Log_Here (Debug, "not quoted" & Quote (" next", Next));

                     if Ada.Strings.Maps.Is_In (Next, Iterator.Seperators) then
                        Buffer_Package.Append (Iterator.Current_Seperators, Next);
                        if Iterator.Ignore_Multiple_Seperators then
                           Iterator.State := Seperator;  -- collect more
                        else
                           Log_Out (Debug);
                           return;
                        end if;
                     elsif Iterator.Trim and then Next = ' ' then
                        Log_Here (Debug, "skip space");
                     else
                        Buffer_Package.Append (Iterator.Current_Value, Next);
                     end if;
                  end if;

               when Quote =>
                  if Ada.Strings.Maps.Is_In (Next, Iterator.Quotes) then   -- end quote
                     Iterator.Quoted := True;
                     Log_Here (Debug, "quoted '" & Iterator.Current_Value.Coerce & "'");

                     Iterator.State := Normal;
                  else
                     Buffer_Package.Append (Iterator.Current_Value, Next);
                  end if;

               when Seperator =>
                  if Ada.Strings.Maps.Is_In (Next, Iterator.Seperators) then
                     Buffer_Package.Append (Iterator.Current_Seperators, Next);
                  else
                     Iterator.State := Normal;
                     Iterator.Current := Iterator.Current - 1; -- put it back
                     Log_Out (Debug);
                     return;
                  end if;
            end case;
         end;
      end loop;

      Iterator.State := Seperator;     -- treat end of buffer as a seperator

      case Iterator.State is

         when Normal | Seperator =>
            if    Iterator.Current_Value = Null_String and then
                  Iterator.Current_Seperators = Null_String then
               Log_Exception (Debug);
               raise Underflow;
--          else
--             Iterator.Current_Value := Null_String;
--             Iterator.Current_Seperators := Null_String;
            end if;

         when Quote =>
            Log_Exception (Debug);
            raise Underflow with "missing closing quote";

      end case;
      Log_Out (Debug);
   end Next;

   -----------------------------------------------------------------------
   package body Name_Value is

      procedure Delete (
         Source         : in out Buffer_Type;
         From           : in   Positive;
         Through        : in   Natural);

      function Index (
         Source            : in String;
         Pattern           : in String;
         Going             : in Ada.Strings.Direction := Ada.Strings.Forward;
         Mapping           : in Ada.Strings.Maps.Character_Mapping
                           := Ada.Strings.Maps.Identity
      ) return Natural renames Ada.Strings.Fixed.Index;

      function Index (
         Source            : in   String;
         Set               : in   Ada.Strings.Maps.Character_Set;
         Test              : in   Ada.Strings.Membership := Ada.Strings.Inside;
         Going             : in   Ada.Strings.Direction  := Ada.Strings.Forward
      ) return Natural renames Ada.Strings.Fixed.Index;

--    function Length (
--       Source            : in   Buffer_Type
--    ) return Natural renames Buffer_Package.Length;
--
--    procedure Trim (
--       Source            : in out Buffer_Type;
--       Side           : in   Ada.Strings.Trim_End
--    ) renames Buffer_Package.Trim;

      function Trim_Spaces (
         Source            : in   String
      ) return String;

      Buffer               : Buffer_Type;
      Comment_Seperators      : constant String := (1 => Comment_Seperator);
      Current_Seperator    : Character := No_Seperator;
      Name_Seperators_Map     : constant Ada.Strings.Maps.Character_Set :=
                           Ada.Strings.Maps.To_Set (Value_Seperators & Key_Seperator);
      Table             : array (Key_Type) of Ada_Lib.Strings.String_Constant_Access;
      Table_Initialized    : Boolean := False;
      Value_Seperators_Map : constant Ada.Strings.Maps.Character_Set :=
                           Ada.Strings.Maps.To_Set (Value_Seperators);

      -----------------------------------------------------------------------
      function At_End
      return Boolean is
      -----------------------------------------------------------------------

      begin
         return Buffer.Length = 0;
      end At_End;

      -----------------------------------------------------------------------
      procedure Delete (
         Source         : in out Buffer_Type;
         From           : in   Positive;
         Through        : in   Natural) is
      -----------------------------------------------------------------------

      begin
         Buffer_Package.Delete (Source, From, Through);

         if Ignore_Spaces then
            Buffer.Trim (Ada.Strings.Both);
         end if;
      end Delete;

      -----------------------------------------------------------------------
      function Is_Key
      return Boolean is
      -----------------------------------------------------------------------

      begin
         if Current_Seperator = No_Seperator or else
               Ada.Strings.Maps.Is_In (Current_Seperator, Value_Seperators_Map) then
            return True;
         else
            return False;
         end if;
      end Is_Key;

      -----------------------------------------------------------------------
      function Get_Key
      return Key_Type is
      -----------------------------------------------------------------------

         -------------------------------------------------------------------
         function Find (
            Name           : in   String
         ) return Key_Type is
         -------------------------------------------------------------------

            Trimmed           : constant String := Trim_Spaces (Name);

         begin
            for Key in Table'range loop
               if Trimmed = Table (Key).all then
                  return Key;
               end if;
            end loop;

            Ada.Exceptions.Raise_Exception (Failed'identity,
               "Invalid Key word '" & Name & "'");
         end Find;
         -------------------------------------------------------------------

         Buffer_Left       : constant String := Buffer.Coerce;
         Seperator         : constant Natural := Index (
                           Buffer_Left, Name_Seperators_Map);

      begin
         if not Is_Key then
            Ada.Exceptions.Raise_Exception (Failed'identity,
               "Unexpected value");
         end if;

         if Buffer_Left'length = 0 then
            Ada.Exceptions.Raise_Exception (Failed'identity,
               "Missing key");
         end if;

         if Seperator > 0 then
            Current_Seperator := Buffer_Left (Seperator);

            Delete (Buffer, 1, Seperator);

            return Find (Buffer_Left (Buffer_Left'first .. Seperator - 1));
         else
            Current_Seperator := No_Seperator;

            Delete (Buffer, 1, Buffer_Left'length);

            return Find (Buffer_Left);
         end if;
      end Get_Key;

      -----------------------------------------------------------------------
      function Get_Value
      return String is
      -----------------------------------------------------------------------

      begin
         return Get_Value_Required (False);
      end Get_Value;


      -----------------------------------------------------------------------
      function Get_Value_Required (
         Value_Required       : in Boolean
      ) return String is
      -----------------------------------------------------------------------

         Buffer_Left       : constant String := Buffer.Coerce;

      begin

         if Is_Key then
            if Value_Required then
               Ada.Exceptions.Raise_Exception (Failed'identity,
                     "Missing value");
            else
               return "";
            end if;
         end if;


         if Value_Seperators'length > 0 then
            declare
               Value_End   : constant Natural := Index (
                           Buffer_Left, Value_Seperators_Map);

            begin
               if Value_End > 0 then
                  declare
                     Value : constant String := Trim_Spaces (Buffer_Left (Buffer_Left'first .. Value_End - 1));

                  begin
                     if Value_Required and then Value'length <= 0 then
                        Ada.Exceptions.Raise_Exception (Failed'identity,
                           "Missing value");
                     else
                  Current_Seperator := Buffer_Left (Value_End);

                  Delete (Buffer, 1, Value_End);

                        return Value;
               end if;
            end;
         end if;
            end;
         end if;

         -- no value seperator specified or no value seperator found, return whole buffer
         Current_Seperator := No_Seperator;
         Delete (Buffer, 1, Buffer_Left'length);
         return Trim_Spaces (Buffer_Left);
      end Get_Value_Required;

      -----------------------------------------------------------------------
      procedure Initialize (
         Value          : in   String) is
      -----------------------------------------------------------------------

         Comment           : Natural;

      begin
         Current_Seperator := No_Seperator;

         Buffer.Set (Value);

         if Ignore_Spaces then
            Buffer.Trim (Ada.Strings.Both);
         end if;

         if Comment_Seperator /= No_Seperator then
            Comment := Ada.Strings.Fixed.Index (Value, Comment_Seperators);

            if Comment > 0 then
               Delete (Buffer, Comment, Value'last);
            end if;
         end if;

         if not Table_Initialized then
            Table_Initialized := True;

            declare
               Comma    : Natural;
               Key         : Key_Type := Key_Type'first;
               Start    : Positive := Keys'first;
               Stop     : Positive;

            begin
               loop
                  Comma := Index (Keys (Start .. Keys'last), ",");

                  if Comma = 0 then
                     Stop := Keys'last;
                  else
                     Stop := Comma - 1;
                  end if;

                  Table (Key) := new String'(Keys (Start .. Stop));

                  if Comma = 0 then
                     exit;
                  end if;

                  Start := Comma + 1;

                  if Key = Key_Type'last then
                     Ada.Exceptions.Raise_Exception (Failed'identity,
                        "Too many words in Parser Keys '" & Keys & "'");
                  end if;

                  Key := Key_Type'succ (Key);
               end loop;

               if Key /= Key_Type'last then
                  Ada.Exceptions.Raise_Exception (Failed'identity,
                     "Too few words in Parser Keys '" & Keys & "'");
               end if;
            end;
         end if;
      end Initialize;

      -----------------------------------------------------------------------
      function Key_Name (
         Key               : in     Key_Type
      ) return String is
      -----------------------------------------------------------------------

      begin
         return Table (Key).all;
      end Key_Name;

      -----------------------------------------------------------------------
      function Remainder
      return String is
      -----------------------------------------------------------------------

      begin
         return Buffer.Coerce;
      end Remainder;

      -----------------------------------------------------------------------
      function Seperator
      return Character is
      -----------------------------------------------------------------------

      begin
         return Current_Seperator;
      end Seperator;

      -----------------------------------------------------------------------
      function Trim_Spaces (
         Source            : in   String
      ) return String is
      -----------------------------------------------------------------------

      begin
         if Ignore_Spaces then
            return Ada.Strings.Fixed.Trim (Source, Ada.Strings.Both);
         else
            return Source;
         end if;
      end Trim_Spaces;

   end Name_Value;

begin
--Debug := True;
--Elaborate := True;
   Log_Here (Elaborate or Trace_Options);
end Ada_Lib.Parser;

