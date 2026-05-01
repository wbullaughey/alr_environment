with Ada.Exceptions;
with Ada.Strings.Fixed;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with Ada_Lib.Strings;

package body Ada_Lib.Parser is

   use type Ada.Strings.Maps.Character_Set;
   use type Buffer_Type;

   function Coerce (
      Source            : in   Buffer_Type
   ) return String renames Buffer_Package.To_String;

   function Coerce (
      Source            : in   String
   ) return Buffer_Type renames Buffer_Package.To_Unbounded_String;

   procedure Set_Mark (
      Iterator             : in out Iterator_Type);

   -----------------------------------------------------------------------
   function At_End (
      Iterator             : in   Iterator_Type
   ) return Boolean is
   -----------------------------------------------------------------------

   begin
      return Buffer_Package.Length (Iterator.Buffer) = 0;
   end At_End;

   -----------------------------------------------------------------------
   function Get_Seperator (
      Iterator             : in   Iterator_Type
   ) return Character is
   -----------------------------------------------------------------------

   begin
      if    Iterator.In_Quote or
            Iterator.Start_Seperator > Buffer_Package.Length (Iterator.Buffer) then
         return No_File_Seperator;
      else
         return Buffer_Package.Element (Iterator.Buffer,
            Iterator.Start_Seperator);
      end if;
   end Get_Seperator;

   -----------------------------------------------------------------------
   function Get_Seperators (
      Iterator             : in   Iterator_Type
   ) return String is
   -----------------------------------------------------------------------

   begin
      if    Iterator.In_Quote or
            Iterator.Start_Seperator > Buffer_Package.Length (Iterator.Buffer) then
         return "";
      else
         return Buffer_Package.Slice (Iterator.Buffer,
            Iterator.Start_Seperator, Iterator.Start_Seperator);
      end if;
   end Get_Seperators;

   -----------------------------------------------------------------------
   function Get_Value (
      Iterator             : in out Iterator_Type;
        Do_Next                     : in     Boolean := False
   ) return String is
   -----------------------------------------------------------------------

      -------------------------------------------------------------------
        function Finish_Up (
            Value                   : in     String
        ) return String is
      -------------------------------------------------------------------

        begin
            if Do_Next then
                Iterator.Next;
            end if;

            return Value;
        end Finish_Up;

      -------------------------------------------------------------------
      function Get return String is
      -------------------------------------------------------------------

      begin
         if Ada_Lib_LIB_Debug then
            Log_Here ("In_Quote " & Iterator.In_Quote'img &
               " Start_seperator" & Iterator.Start_Seperator'img & " buffer '" & Iterator.Buffer & "'");
         end if;

         if Iterator.In_Quote then
            declare
               Quote             : constant String (1 .. 1) := String'(
                                    1 => Buffer_Package.Element (Iterator.Buffer, 1));
            begin
               Buffer_Package.Delete (Iterator.Buffer, 1, 1);
               Iterator.Stop_Seperator := Buffer_Package.Index (Iterator.Buffer, Quote);
               return Coerce (Buffer_Package.Head (Iterator.Buffer, Iterator.Stop_Seperator - 1));
            end;
         else
            if Iterator.Start_Seperator > Buffer_Package.Length (Iterator.Buffer) then
               -- return whole buffer
               return Coerce (Iterator.Buffer);
            else
               -- return buffer up to end mark
               return Coerce (Buffer_Package.Head (Iterator.Buffer, Iterator.Start_Seperator - 1));
            end if;
         end if;
      end Get;
      -------------------------------------------------------------------

   begin
      if At_End (Iterator) then
         raise Underflow;
      end if;
      if Iterator.Trim then
         return Finish_Up (Ada_Lib.strings.Trim (Get));
      else
         return Finish_Up (Get);
      end if;
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
                  (  Value (End_Value) = Ada.Characters.Latin_1.CR or
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

      Iterator             : Iterator_Type;
      Trimmed_Value           : constant String := Trimmed;
      End_Value               : Natural := Trimmed_Value'last;

   begin
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

      Iterator.Buffer := Coerce (Trimmed_Value (Trimmed_Value'first .. End_Value));
      Iterator.Ignore_Multiple_Seperators := Ignore_Multiple_Seperators;
      Iterator.In_Quote := False;
      Iterator.Quotes := Ada.Strings.Maps.To_Set (Quotes);
      Iterator.Seperators := Ada.Strings.Maps.To_Set (Seperators);
      Iterator.Trim := Trim_Spaces;

      Set_Mark (Iterator);
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
      Log (Ada_Lib_LIB_Debug, Here, Who &
         " value '" & Value &
         "' seperators '" & Seperators &
         "' quotes '" & Quotes &
         " Ignore_Multiple_Seperators " & Ignore_Multiple_Seperators'img &
         " Trim_Spaces " & Trim_Spaces'img);

      Iterator := Initialize (Value, Seperators, Ignore_Multiple_Seperators,
         Comment_Seperator, Trim_Spaces, Quotes);
   end Initialize;

   -----------------------------------------------------------------------
   procedure Next (
      Iterator             : in out Iterator_Type) is
   -----------------------------------------------------------------------

   begin
      if At_End (Iterator) then
         raise Underflow with Here & Who;
      else
         declare
            Length            : constant Natural :=
                              Buffer_Package.Length (Iterator.Buffer);

         begin
            if Ada_Lib_LIB_Debug then
               Log_Here ("lenth" & Length'img & " stop_seperator" &
                  Iterator.Stop_Seperator'img & " buffer '" & Iterator.Buffer & "'");
            end if;

            if Iterator.In_Quote then
               -- delete quoted string
               Buffer_Package.Delete (Iterator.Buffer, 1, Iterator.Stop_Seperator);
               declare
                  Next           : constant Character := Buffer_Package.Element (Iterator.Buffer, 1);

               begin
                  if Ada.Strings.Maps.Is_In (Next, Iterator.Seperators) then
                  end if;
               end;
            else
               if Iterator.Stop_Seperator >= Length then
                  -- delete whole buffer by setting it to empty value
                  Iterator.Buffer := Coerce ("");
               else
                  -- delete up through seperator
                  Buffer_Package.Delete (Iterator.Buffer, 1, Iterator.Stop_Seperator);
               end if;
            end if;

            Set_Mark (Iterator);
         end;
      end if;
   end Next;

   -----------------------------------------------------------------------
   function Remainder (
      Iterator             : in   Iterator_Type
   ) return String is
   -----------------------------------------------------------------------

   begin
      Log (Ada_Lib_LIB_Debug, Here, Who & " buffer '" & Iterator.Buffer & "'");
      return Coerce (Iterator.Buffer);
   end Remainder;

   -----------------------------------------------------------------------
   procedure Set_Mark (
      Iterator             : in out Iterator_Type) is
   -----------------------------------------------------------------------

      Length                  : constant Natural := Buffer_Package.Length (Iterator.Buffer);

   begin
      if Ada_Lib_LIB_Debug then
         Log_Here ("lenth" & Length'img & " In_Quote " & Iterator.In_Quote'img &
            " buffer '" & Iterator.Buffer & "'");
      end if;

      if Length > 0 then
         if    (not Iterator.In_Quote and
               Iterator.Quotes /= Ada.Strings.Maps.Null_Set) and then
               Ada.Strings.Maps.Is_In (Buffer_Package.Element (Iterator.Buffer, 1),
                     Iterator.Quotes) then
            Iterator.In_Quote := True;
            Log (Ada_Lib_LIB_Debug, Here, Who & " in quote");
            return;
         end if;
         -- find first seperator
         Iterator.Start_Seperator := Buffer_Package.Index (Iterator.Buffer,
            Iterator.Seperators);

         if Ada_Lib_LIB_Debug then
            Log_Here ("Start_Seperator" & Iterator.Start_Seperator'img);
         end if;

         if Iterator.Start_Seperator = 0 then
            -- no seperator, set end to last character plus 1
            Iterator.Start_Seperator := Length + 1;
            Iterator.Stop_Seperator := Iterator.Start_Seperator;
         else
            Iterator.Stop_Seperator := Iterator.Start_Seperator;

            if Iterator.Ignore_Multiple_Seperators then
               declare
                  First_Seperator   : constant Character :=
                                 Buffer_Package.Element (Iterator.Buffer,
                                    Iterator.Start_Seperator);

               begin
                  while Iterator.Stop_Seperator < Length loop
                     declare
                        Next  : constant Character :=
                                 Buffer_Package.Element (Iterator.Buffer,
                                    Iterator.Stop_Seperator + 1);

                     begin
                        if Next /= First_Seperator or
                              not Ada.Strings.Maps.Is_In (Next,
                                 Iterator.Seperators) then
                           exit;
                        end if;
                     end;

                     Iterator.Stop_Seperator := Iterator.Stop_Seperator + 1;
                  end loop;
               end;
            end if;

         end if;
      else
         Iterator.Start_Seperator := 1;
      end if;

      if Ada_Lib_LIB_Debug then
         Log_Here ("Start_Seperator" & Iterator.Start_Seperator'img &
             " Stop_Seperator" & Iterator.Stop_Seperator'img);
      end if;

   end Set_Mark;

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

      function Length (
         Source            : in   Buffer_Type
      ) return Natural renames Buffer_Package.Length;

      procedure Trim (
         Source            : in out Buffer_Type;
         Side           : in   Ada.Strings.Trim_End
      ) renames Buffer_Package.Trim;

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
         return Length (Buffer) = 0;
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
            Trim (Buffer, Ada.Strings.Both);
         end if;
      end Delete;

      -----------------------------------------------------------------------
      function Is_Key
      return Boolean is
      -----------------------------------------------------------------------

      begin
         if Current_Seperator = No_Seperator  or
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

         Buffer_Left       : constant String := Coerce (Buffer);
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

         Buffer_Left       : constant String := Coerce (Buffer);

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
                     if Value_Required and Value'length <= 0 then
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

         Buffer := Ada_Lib.Strings.Unlimited.To_Unbounded_String (Value);

         if Ignore_Spaces then
            Trim (Buffer, Ada.Strings.Both);
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
         return Coerce (Buffer);
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
Ada_Lib_LIB_Debug := True'
   Log_Here (Ada_Lib_LIB_Debug or Elaborate);
end Ada_Lib.Parser;

