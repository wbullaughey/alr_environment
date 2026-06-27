--$Header$

-----------------------------------------------------------------------------
--  Copyright (c) 2003 - 2004  All rights reserved
--
--  This file is a product of Communication Automation & Control, Inc. (CAC)
--  and is provided for unrestricted use WITH CAC PRODUCTS ONLY provided
--  this legend is included on all media and as a part of the software
--  program in whole or part.
--
--  Users may copy or modify this file without charge, but are not authorized
--  to license or distribute it to anyone else except as part of a product or
--  program developed by the user incorporating CAC products.
--
--  THIS FILE IS PROVIDED AS IS WITH NO WARRANTIES OF ANY KIND INCLUDING THE
--  WARRANTIES OF DESIGN, MERCHANTIBILITY AND FITNESS FOR A PARTICULAR
--  PURPOSE, OR ARISING FROM A COURSE OF DEALING, USAGE OR TRADE PRACTICE.
--
--  In no event will CAC be liable for any lost revenue or profits, or other
--  special, indirect and consequential damages, which may arise from the use
--  of this software.
--
--  Communication Automation & Control, Inc.
--  1180 McDermott Drive, West Chester, PA (USA) 19380
--  (877) 284-4804 (Toll Free)
--  (610) 692-9526 (Outside the US)
-----------------------------------------------------------------------------

with Ada.Characters.Latin_1;
with Ada.Strings.Fixed;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with Ada.Text_IO; use Ada.Text_IO;
with Hex_IO;

package body Ask is

   protected type Lock_Type      is

      entry Lock;
      procedure Unlock;

   private

      Locked                  : Boolean := False;

   end Lock_Type;

   function Is_Input_Queue_Empty
   return Boolean;

   function Line_Input
   return String;

   Input_Lock                 : Lock_Type;
   Input_Queue                : Ada_Lib.Strings.Unlimited.String_Type;
   Output_File                : Ada.Text_IO.File_Access := Ada.Text_IO.Standard_Output;

   -------------------------------------------------------------------
   function Ask_Character (
      Question             : in   String
   ) return Character is
   -------------------------------------------------------------------

      Result                  : Character;

   begin
      T (Ada_Lib_Trace_Trace, "in");
      Put (Question & ": ");
      if Is_Input_Queue_Empty then
         Get_Immediate (Result);
      else
         New_Line;
         Result := Input_Queue.Element (1);
         Input_Queue.Delete (1, 1);
      end if;
      New_Line;
      T (Ada_Lib_Trace_Trace, "out" & Quote (" result", Result));
      return Result;
   end Ask_Character;

   -------------------------------------------------------------------
   function Ask_String (
      Question             : in   String
   ) return String is
   -------------------------------------------------------------------

   begin
      Log_In (Ada_Lib_Trace_Trace);
      Put (Output_File.all, Question & ": ");

      declare
         Line                    : constant String := Ada_Lib.Strings.Trim (Line_Input);

      begin
         Log (Ada_Lib_Trace_Trace, Here, Who & Quote (" line", Line));
         return Line;
      end;
   end Ask_String;

   -------------------------------------------------------------------
   procedure Ask_Time (
      Question             : in   String;
      Value                : in out Duration) is
   -------------------------------------------------------------------

      Time                 : Float;

   begin
      Log_In (Ada_Lib_Trace_Trace);
      Time := Float (Value);
      Ask_Float (Question, Time, 0, 2, 0);
      Value := Duration (Time);
      Log (Ada_Lib_Trace_Trace, Here, Who & " value " & Value'img);
   end Ask_Time;

   -------------------------------------------------------------------
   procedure Floating_Point (
      Question             : in   String;
      Value                : in out Value_Type;
      Fore                 : in   Natural := Default_Fore;
      Aft                     : in   Natural := Default_Aft;
      Exp                     : in   Natural := Default_Exp) is
   -------------------------------------------------------------------

      package IO is new Float_IO (Value_Type);

   begin
      Log_In (Ada_Lib_Trace_Trace);
      loop
         begin
            Put (Output_File.all, Question & "(");
            IO.Put (Output_File.all, Value, Fore, Aft, Exp);
            Put (Output_File.all, "): ");

            declare
               Line                    : constant String := Line_Input;

            begin
               Value := Value_Type'value (
                  Ada.Strings.Fixed.Trim (Line,
                     Ada.Strings.Both));
               Log (Ada_Lib_Trace_Trace, Here, Who & " value " & Value'img);
               return;

            exception

               when others =>
                  Put (Output_File.all, "invalid response: '" &
                     Line & "'" & " min ");
                  IO.Put (Output_File.all, Value_Type'first, Fore, Aft, Exp);
                  Put (Output_File.all, " max ");
                  IO.Put (Output_File.all, Value_Type'last, Fore, Aft, Exp);
                  New_Line (Output_File.all);
            end;

         end;
      end loop;
   end Floating_Point;

   procedure Floating is new Floating_Point (Float);
   -------------------------------------------------------------------
   procedure Ask_Float (
      Question             : in   String;
      Value                : in out Float;
      Fore                 : in   Natural := 0;
      Aft                     : in   Natural := 0;
      Exp                     : in   Natural := 0) is
   -------------------------------------------------------------------

   begin
      Log_In (Ada_Lib_Trace_Trace);
      Floating (Question, Value, Fore, Aft, Exp);
      Log_Out (Ada_Lib_Trace_Trace);
   end Ask_Float;

   -------------------------------------------------------------------
   procedure Integer_Decimal (
      Question          : in   String;
      Value             : in out Value_Type) is
   -------------------------------------------------------------------

   begin
      Log_In (Ada_Lib_Trace_Trace);
      loop
         begin
            Put (Output_File.all, Question & "(" & Value_Type'image (Value) & "): ");
            declare
               Line                    : constant String := Line_Input;

            begin
               Value := Value_Type'value (
                  Ada.Strings.Fixed.Trim (Line,
                     Ada.Strings.Both));
               Log (Ada_Lib_Trace_Trace, Here, Who & " value " & Value'img);
               return;

            exception

               when others =>
                  Put_Line (Output_File.all, "invalid response: '" &
                     Line & "'" &
                     " min " & Value_Type'image (Value_Type'first) &
                     " max " & Value_Type'image (Value_Type'last));
            end;

         end;
      end loop;
   end Integer_Decimal;

   procedure Decimal is new Integer_Decimal (Integer);

   -------------------------------------------------------------------
   procedure Ask_Integer (
      Question             : in   String;
      Value                : in out Integer) is
   -------------------------------------------------------------------

   begin
      Log_In (Ada_Lib_Trace_Trace);
      Decimal (Question, Value);
      Log_Out (Ada_Lib_Trace_Trace);
   end Ask_Integer;

   -------------------------------------------------------------------
   procedure Integer_Hex (
      Question          : in   String;
      Value             : in out Value_Type) is
   -------------------------------------------------------------------

      function Hex         is new Hex_IO.Integer_Hex (Value_Type);

   begin
      Log_In (Ada_Lib_Trace_Trace);
      loop
         begin
            Put (Output_File.all, Question & "(" & Hex (Value) & "): ");
            declare
               Line                    : constant String := Line_Input;

            begin
               Value := Value_Type'value (
                  "16#" & Ada.Strings.Fixed.Trim (Line,
                     Ada.Strings.Both) & "#");

               Log (Ada_Lib_Trace_Trace, Here, Who & " value " & Value'img);
               return;

            exception

               when others =>
                  Put_Line (Output_File.all, "invalid response: '" &
                     Line & "'" &
                     " min " & Value_Type'image (Value_Type'first) &
                     " max " & Value_Type'image (Value_Type'last));
            end;

         end;
      end loop;
   end Integer_Hex;

   -------------------------------------------------------------------
   function Is_Input_Queue_Empty
   return Boolean is
   -------------------------------------------------------------------

   begin
      return Input_Queue.Length = 0;
   end Is_Input_Queue_Empty;

   -------------------------------------------------------------------
   function Line_Input
   return String is
   -------------------------------------------------------------------

      Last              : Natural;
      Line              : String (1 .. 10000);

   begin
      Last := Input_Queue.Length;
      Log_In (Ada_Lib_Trace_Trace, Here, Who & (if Last > 0 then
            Quote (" input queue", Input_Queue.Coerce (1 .. Last))
         else
            " input queue empty"));

      if Is_Input_Queue_Empty then
         Set_Col (Standard_Input.all, 1);
         Get_Line (Line, Last);
         if Last = 0 then
            return "";
         end if;
      else
         Line (1 .. Last) := Input_Queue.Coerce;
         Put_Line (Line (1 .. Last));
         Input_Queue.Delete (1, Last);
      end if;

      Log (Ada_Lib_Trace_Trace, Here, Who & Quote (" line", Line (1 .. Last)));
      return Line (1 .. Last);
   end Line_Input;

   -------------------------------------------------------------------
   procedure Modular_Hex (
      Question          : in   String;
      Value             : in out Value_Type) is
   -------------------------------------------------------------------

      function Hex         is new Hex_IO.Modular_Hex (Value_Type);

   begin
      loop
         begin
            Put (Output_File.all, Question & "(" & Hex (Value) & "): ");
            declare
               Line                    : constant String := Line_Input;

            begin
               Value := Value_Type'value (
                  "16#" & Ada.Strings.Fixed.Trim (Line,
                     Ada.Strings.Both) & "#");
               return;

            exception

               when others =>
                  Put_Line (Output_File.all, "invalid response: '" &
                     Line & "'" &
                     " min " & Value_Type'image (Value_Type'first) &
                     " max " & Value_Type'image (Value_Type'last));
            end;

         end;
      end loop;
   end Modular_Hex;

   -------------------------------------------------------------------
   procedure Lock_Input is
   -------------------------------------------------------------------

   begin
      Input_Lock.Lock;
   end Lock_Input;

   -------------------------------------------------------------------
   procedure Push (
      Value                : in     Character) is
   -------------------------------------------------------------------

   begin
      Log (Ada_Lib_Trace_Trace, Here, Who & Quote (" value", Value));
      Input_Queue.Insert (1, String'(1 => Value));
   end Push;

   -------------------------------------------------------------------
   procedure Push (
      Value                : in     String) is
   -------------------------------------------------------------------

   begin
      Log (Ada_Lib_Trace_Trace, Here, Who & Quote (" value", Value));
      Input_Queue.Insert (1, Value & " ");
   end Push;

   -------------------------------------------------------------------
   procedure Push_Line (
      Value                : in     String) is
   -------------------------------------------------------------------

   begin
      Log (Ada_Lib_Trace_Trace, Here, Who & Quote (" value", Value));
      Push (Ada.Characters.Latin_1.LF);
      Push (Value);
   end Push_Line;

   -------------------------------------------------------------------
   procedure Set_Output_File (
      File                 : in   Ada.Text_IO.File_Access) is
   -------------------------------------------------------------------

   begin
      Output_File := File;
   end Set_Output_File;

   -- raises:
   --       an asserting failure
   -------------------------------------------------------------------
   procedure Unlock_Input is
   -------------------------------------------------------------------

   begin
      Input_Lock.Unlock;
   end Unlock_Input;

   -------------------------------------------------------------------
   function Yes_No (
      Question             : in   String
   ) return Boolean is
   -------------------------------------------------------------------

      Answer                  : Character;

   begin
      loop
         Put (Output_File.all, Question & " (y/n): ");
         Get_Immediate (Answer);

         Put (Output_File.all, Answer);
         New_Line (Output_File.all);

         case Answer is

            when 'y' | 'Y' =>
               return True;

            when 'n' | 'N' =>
               return False;

            when others =>
               Put_Line (Output_File.all, "huh?");

         end case;
      end loop;
   end Yes_No;

   -------------------------------------------------------------------
   function Yes_No (
      Question             : in   String;
      Was                     : in   Boolean
   ) return Boolean is
   -------------------------------------------------------------------

      Answer                  : Character;
      Previous             : String (1 .. 3);

   begin
      if Was then
         Previous := "Y:n";
      else
         Previous := "y:N";
      end if;

      loop
         Put (Output_File.all, Question & " (" & Previous & "): ");
         Get_Immediate (Answer);
         New_Line (Output_File.all);

         case Answer is

            when 'y' | 'Y' =>
               return True;

            when 'n' | 'N' =>
               return False;

            when Ada.Characters.Latin_1.LF |
                Ada.Characters.Latin_1.CR =>
               return Was;

            when others =>
               Put_Line (Output_File.all, "huh?");

         end case;
      end loop;
   end Yes_No;

   protected body Lock_Type      is

      entry Lock when not Locked is

      begin
         Locked := True;
      end Lock;

      -- raises:
      --       an asserting failure
      procedure Unlock is

      begin
         pragma Assert (Locked);
         Locked := False;
      end Unlock;

   end Lock_Type;

begin
-- Ada_Lib_Trace_Trace := True;
   Log_Here (Ada_Lib_Trace_Trace or Elaborate);
end Ask;
