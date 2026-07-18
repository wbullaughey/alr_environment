with Ada.Text_IO; use Ada.Text_IO;
with Ada_Lib.Options;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Time;
with Ada_Lib.Trace;
with Ada.Unchecked_Conversion;

package body Hex_IO is

-- Debug : Boolean renames Ada_Lib.Options.Ada_Lib_Options.Hex_Debug;

   package Unsigned_8_IO is new Ada.Text_IO.Modular_IO (
      Interfaces.Unsigned_8);

   package Unsigned_16_IO is new Ada.Text_IO.Modular_IO (
      Interfaces.Unsigned_16);

   package Unsigned_32_IO is new Ada.Text_IO.Modular_IO (
      Interfaces.Unsigned_32);

   package Unsigned_64_IO is new Ada.Text_IO.Modular_IO (
      Interfaces.Unsigned_64);

   function Coerce            is new Ada.Unchecked_Conversion (
      Source => Interfaces.Unsigned_32,
      Target => Integer);

   function Coerce            is new Ada.Unchecked_Conversion (
      Source => Interfaces.Integer_8,
      Target => Interfaces.Unsigned_8);

   function Coerce            is new Ada.Unchecked_Conversion (
      Source => Interfaces.Integer_16,
      Target => Interfaces.Unsigned_16);

   function Coerce            is new Ada.Unchecked_Conversion (
      Source => Interfaces.Integer_32,
      Target => Interfaces.Unsigned_32);

   function Coerce            is new Ada.Unchecked_Conversion (
      Source => Interfaces.Integer_64,
      Target => Interfaces.Unsigned_64);

   function Coerce            is new Ada.Unchecked_Conversion (
      Source => Interfaces.Unsigned_8,
      Target => Interfaces.Integer_8);

   function Coerce            is new Ada.Unchecked_Conversion (
      Source => Interfaces.Unsigned_16,
      Target => Interfaces.Integer_16);

   function Coerce            is new Ada.Unchecked_Conversion (
      Source => Interfaces.Unsigned_32,
      Target => Interfaces.Integer_32);

   function Coerce            is new Ada.Unchecked_Conversion (
      Source => Interfaces.Unsigned_64,
      Target => Interfaces.Integer_64);

   generic
      Width                      : in Positive;
      type Data_Type             is mod <>;
   procedure Dump (
      Source                     : in     System.Address;
      Size                       : in     Positive;
      Line_Limit                 : in     Positive;
      Message                    : in     String := "");

   Include_Hundreds  : Boolean renames Ada_Lib.Options.Trace.Include_Hundreds;
   Include_Task      : Boolean renames Ada_Lib.Options.Trace.Include_Task;
   Include_Time      : Boolean renames Ada_Lib.Options.Trace.Include_Time;

   -------------------------------------------------------------------
   procedure Dump (
      Source                     : in     System.Address;
      Size                       : in     Positive;     -- size in bits
      Line_Limit                 : in     Positive;
      Message                    : in     String := "") is
   -------------------------------------------------------------------
      type Buffer_Type     is array (Natural range <>) of Data_Type;
      pragma Pack (Buffer_Type);

      Values               : constant Positive := (Size - 1) / Data_Type'size + 1;
                              -- in bytes
      Buffer               : Buffer_Type (1 .. Values);
      Last_Line            : Buffer_Type (1 .. Values) := (
                                             others => Data_Type'first);
      This_Line            : Buffer_Type (1 .. Values);

      for Buffer'address use Source;
      Skipping             : Natural := 0;
      Do_Skipping          : Boolean := False;
      First_Line           : Boolean := True;
      First_Skip           : Boolean := True;

   begin
      if Message'length > 0 then
         if Include_Task then
            Put (Standard.Ada_Lib.Current_Task & ": ");
         end if;

         if Include_Time then
            Put ("[" & Ada_Lib.Time.From_Start (Ada_Lib.Time.Now,
               Include_Hundreds) & "] ");
         end if;

        Put_Line (Message & " source " & Ada_Lib.Strings.Image (Source'address));
      end if;

      for Index in Buffer'range loop
         declare
            Line_Index     : constant Positive :=
                              (Index - 1) mod Line_Limit + 1;
         begin
            if Line_Index = 1 then   -- new line
               if First_Skip or else not Do_Skipping then
                  if Include_Task then
                     Put (Ada_Lib.Current_Task & ": ");
                  end if;
                  Put (Hex ((Index - 1) * (Width / 2), 4) & ": ");   -- address
               end if;
               if First_Skip and then Do_Skipping then
                  Put_Line ("*");
                  First_Skip := False;
               end if;
            end if;

            This_Line (Line_Index) := Buffer (Index);

            if Do_Skipping then
               Skipping := Skipping + 1;
            else     -- print the value
               Put (Hex (Interfaces.Unsigned_64 (Buffer (Index)), Width) & " ");
            end if;

            if    Line_Index = Line_Limit or else  -- last of line
                  Index = Buffer'last then         -- end of buffer
               if Last_Line = This_Line then
                  Do_Skipping := True;
               else
                  if Do_Skipping then
                     Put (Skipping'img);
                     Do_Skipping := False;
                     First_Skip := True;
                     Skipping := 0;
                  end if;
                  Last_Line := This_Line;
               end if;

               if not Do_Skipping or else First_Skip then
                  if First_Line then
                     Put (": " & Message);
                     First_Line := False;
                  end if;
                  New_Line;
               end if;
            end if;

         exception
            when Fault: others =>
               Ada_Lib.Trace.Trace_Message_Exception (Fault, "index" & Index'img &
                  " line index" & Line_Index'img &
                  " Line_Limit" & Line_Limit'img);
               raise;
         end;
      end loop;

      Flush;
   end Dump;

   -------------------------------------------------------------------
   procedure Dump8 is new Dump (
      Width       => 2,
      Data_Type   => Interfaces.Unsigned_8);
   -------------------------------------------------------------------

   -------------------------------------------------------------------
   procedure Dump_8 (
      Source                     : in     System.Address;
      Size                       : in     Positive;
      Width                      : in     Positive := 16;
      Message                    : in     String := "") is
   -------------------------------------------------------------------

   begin
      Dump8 (Source, Size, Width, Message);
   end Dump_8;

   -------------------------------------------------------------------
   procedure Dump16 is new Dump (
      Width       => 4,
      Data_Type   => Interfaces.Unsigned_16);
   -------------------------------------------------------------------

   -------------------------------------------------------------------
   procedure Dump_16 (
      Source                     : in   System.Address;
      Size                       : in   Positive;
      Width                      : in   Positive := 8;
      Message                    : in     String := "") is
   -------------------------------------------------------------------

   begin
      Dump16 (Source, Size, Width, Message);
   end Dump_16;

   -------------------------------------------------------------------
   procedure Dump32 is new Dump (
      Width       => 8,
      Data_Type   => Interfaces.Unsigned_32);
   -------------------------------------------------------------------

   -------------------------------------------------------------------
   procedure Dump_32 (
      Source                     : in   System.Address;
      Size                       : in   Positive;
      Width                      : in   Positive := 4;
      Message                    : in   String := "") is
   -------------------------------------------------------------------

   begin
      Dump32 (Source, Size, Width, Message);
   end Dump_32;

   -------------------------------------------------------------------
   procedure Dump64 is new Dump (
      Width       => 16,
      Data_Type   => Interfaces.Unsigned_64);
   -------------------------------------------------------------------

   -------------------------------------------------------------------
   procedure Dump_64 (
      Source                     : in   System.Address;
      Size                       : in   Positive := 64;
      Width                      : in   Positive := 64;
      Message                    : in     String := "") is
   -------------------------------------------------------------------

   begin
      Dump64 (Source, Size, Width, Message);
   end Dump_64;

   -------------------------------------------------------------------
   function Hex (
      Source               : in   String
   ) return Integer is
   -------------------------------------------------------------------

      Last              : Natural;
      Result               : Interfaces.Unsigned_32;

   begin
      Unsigned_32_IO.Get ("16#" & Source & "#", Result, Last);

-- put_line ("get hex '" & Source
      return Coerce (Result);
   end Hex;

   -------------------------------------------------------------------
   function Hex (
      Source               : in   String
   ) return Interfaces.Integer_8 is
   -------------------------------------------------------------------

      Last              : Natural;
      Result               : Interfaces.Unsigned_8;

   begin
      Unsigned_8_IO.Get ("16#" & Source & "#", Result, Last);

      return Coerce (Result);
   end Hex;

   -------------------------------------------------------------------
   function Hex (
      Source               : in   String
   ) return Interfaces.Integer_16 is
   -------------------------------------------------------------------

      Last              : Natural;
      Result               : Interfaces.Unsigned_16;

   begin
      Unsigned_16_IO.Get ("16#" & Source & "#", Result, Last);

      return Coerce (Result);
   end Hex;

   -------------------------------------------------------------------
   function Hex (
      Source               : in   String
   ) return Interfaces.Integer_32 is
   -------------------------------------------------------------------

      Last              : Natural;
      Result               : Interfaces.Unsigned_32;

   begin
      Unsigned_32_IO.Get ("16#" & Source & "#", Result, Last);

      return Coerce (Result);
   end Hex;

   -------------------------------------------------------------------
   function Hex (
      Source               : in   String
   ) return Interfaces.Integer_64 is
   -------------------------------------------------------------------

      Last              : Natural;
      Result               : Interfaces.Unsigned_64;

   begin
      Unsigned_64_IO.Get ("16#" & Source & "#", Result, Last);

      return Coerce (Result);
   end Hex;

   -------------------------------------------------------------------
   function Hex (
      Source               : in   String
   ) return Interfaces.Unsigned_8 is
   -------------------------------------------------------------------

      Last              : Natural;
      Result               : Interfaces.Unsigned_32;

   begin
      Unsigned_32_IO.Get ("16#" & Source & "#", Result, Last);
      return Interfaces.Unsigned_8 (Result);
   end Hex;

   -------------------------------------------------------------------
   function Hex (
      Source               : in   String
   ) return Interfaces.Unsigned_16 is
   -------------------------------------------------------------------

      Last              : Natural;
      Result               : Interfaces.Unsigned_32;

   begin
      Unsigned_32_IO.Get ("16#" & Source & "#", Result, Last);
      return Interfaces.Unsigned_16 (Result);
   end Hex;

   -------------------------------------------------------------------
   function Hex (
      Source               : in   String
   ) return Interfaces.Unsigned_32 is
   -------------------------------------------------------------------

      Last              : Natural;
      Result               : Interfaces.Unsigned_32;

   begin
      Unsigned_32_IO.Get ("16#" & Source & "#", Result, Last);
      return Result;
   end Hex;

   -------------------------------------------------------------------
   function Hex (
      Source               : in   String
   ) return Interfaces.Unsigned_64 is
   -------------------------------------------------------------------

      Last              : Natural;
      Result               : Interfaces.Unsigned_64;

   begin
      Unsigned_64_IO.Get ("16#" & Source & "#", Result, Last);
      return Result;
   end Hex;

   -------------------------------------------------------------------
   function Hex (
      Address              : in   System.Address
   ) return String is
   -------------------------------------------------------------------

   begin
      return Hex (Interfaces.Unsigned_64 (
         System.Storage_Elements.To_Integer (Address)), 8);
   end Hex;

   -------------------------------------------------------------------
   function Hex (
      Address              : in   System.Storage_Elements.Storage_Offset
   ) return String is
   -------------------------------------------------------------------

   begin
      return Hex (Interfaces.Unsigned_32 (Address), 8);
   end Hex;

   -------------------------------------------------------------------
   function Hex (
      Value             : in   character
   ) return String is
   -------------------------------------------------------------------

   begin
      return Hex (Interfaces.Unsigned_8 (Character'Pos (Value)), 8);
   end Hex;

   -------------------------------------------------------------------
   function Hex (
      Value             : in   Integer;
      Width             : in   Positive := 8
   ) return String is
   -------------------------------------------------------------------

      Extended          : constant Interfaces.Integer_64 :=
                           Interfaces.Integer_64 (Value);

   begin
      return Hex (Coerce (Extended), Width);
   end Hex;

   -------------------------------------------------------------------
   function Hex (
      Value             : in   Interfaces.C.Unsigned
   ) return String is
   -------------------------------------------------------------------

   begin
      return Hex (Interfaces.Unsigned_64 (Value), 8);
   end Hex;

   -------------------------------------------------------------------
   function Hex (
      Value             : in   Interfaces.Unsigned_8;
      Width             : in   Positive := 2
   ) return String is
   -------------------------------------------------------------------

   begin
      return Hex (Interfaces.Unsigned_64 (Value), Width);
   end Hex;

   -------------------------------------------------------------------
   function Hex (
      Value             : in   Interfaces.Unsigned_16;
      Width             : in   Positive := 4
   ) return String is
   -------------------------------------------------------------------

   begin
      return Hex (Interfaces.Unsigned_64 (Value), Width);
   end Hex;

   -------------------------------------------------------------------
   function Hex (
      Value             : in   Interfaces.Unsigned_32;
      Width             : in   Positive := 8
   ) return String is
   -------------------------------------------------------------------

   begin
      return Hex (Interfaces.Unsigned_64 (Value), Width);
   end Hex;

   -- raises Width_Error
   -------------------------------------------------------------------
   function Hex (
      Value             : in   Interfaces.Unsigned_64;
      Width             : in   Positive := 16
   ) return String is
   -------------------------------------------------------------------

      Found_Start          : Boolean := False;
      Result               : String (1 .. 20);
      Start             : Positive := Result'length - Width;

   begin
      if Width > 16 then
         raise Width_Error;
      end if;

      Unsigned_64_IO.Put (Result, Value, Base => 16);
-- put_line ("raw '" & Result & "'");

      for Index in reverse 4 .. Result'length - 2 loop
         case Result (Index) is

            when '#' | ' ' =>
               Result (Index) := '0';
               Found_Start := True;

            when others =>
               if Found_Start then
                  Result (Index) := '0';
               end if;

         end case;
      end loop;

      for Index in 4 ..  Result'length - 1 - Width loop
         if Result (Index) /= '0' then
            Start := Index;
            exit;
         end if;
      end loop;

      return Result (Start .. Result'last - 1);
   end Hex;

   -------------------------------------------------------------------
   function Hex (
      Value             : in   Interfaces.Integer_8;
      Width             : in   Positive := 2
   ) return String is
   -------------------------------------------------------------------

   begin
      return Hex (Coerce (Value), Width);
   end Hex;

   -------------------------------------------------------------------
   function Hex (
      Value             : in   Interfaces.Integer_16;
      Width             : in   Positive := 4
   ) return String is
   -------------------------------------------------------------------

   begin
      return Hex (Coerce (Value), Width);
   end Hex;

   -------------------------------------------------------------------
   function Hex (
      Value             : in   Interfaces.Integer_32;
      Width             : in   Positive := 8
   ) return String is
   -------------------------------------------------------------------

   begin
      return Hex (Coerce (Value), Width);
   end Hex;

   -------------------------------------------------------------------
   function Hex (
      Value             : in   Interfaces.Integer_64;
      Width             : in   Positive := 16
   ) return String is
   -------------------------------------------------------------------

   begin
      return Hex (Coerce (Value), Width);
   end Hex;

   -------------------------------------------------------------------
   function Hex (
      Value             : in   Interfaces.C.Unsigned_Char
   ) return String is
   -------------------------------------------------------------------

   begin
      return Hex (Interfaces.Unsigned_64 (Value), 2);
   end Hex;

   -------------------------------------------------------------------
   function Integer_Hex (
      Value             : in   Data_Type;
      Width             : in   Positive := Data_Type'size / 4
   ) return String is
   -------------------------------------------------------------------

   begin
      return Hex (Interfaces.Unsigned_64 (Value), Width);
   end Integer_Hex;

   -------------------------------------------------------------------
   function Modular_Hex (
      Value             : in   Data_Type;
      Width             : in   Positive := Data_Type'size / 4
   ) return String is
   -------------------------------------------------------------------

   begin
      return Hex (Interfaces.Unsigned_64 (Value), Width);
   end Modular_Hex;

   -------------------------------------------------------------------
   function Modular_Hex_Address (
      Address           : in   System.Address;
      Width             : in   Positive   -- in bytes
   ) return String is
   -------------------------------------------------------------------

      Buffer            : array (1 .. Width) of Interfaces.Unsigned_8;
      for Buffer'address use Address;
      Result            : Ada_Lib.Strings.Unlimited.String_Type;

   begin
      for Index in Buffer'range loop
         Result := Result & Hex (Buffer (Index));
      end loop;

      return Result.Coerce;
   end Modular_Hex_Address;

end Hex_IO;
