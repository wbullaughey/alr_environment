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

with Ada.Command_Line;
with Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

package body Command_Line_Iterator is

   package Modular_IO         is new Ada.Text_IO.Modular_IO (Interfaces.Unsigned_64);

   procedure Dump_Iterator (
      Where             : in   String;
      Iterator          : in   Iterator_Type);

   Debug                : constant Boolean := False;

   -- raises No_Argument, Invalid_Option
   -------------------------------------------------------------------
   procedure Advance (
      Iterator          : in out Iterator_Type) is
   -------------------------------------------------------------------

   begin
      Dump_Iterator ("Advance in", Iterator);

      if Iterator.At_End then
         Ada.Exceptions.Raise_Exception (No_Argument'identity,
            "Advance called after end in command line iterator");
      end if;

      loop                 -- need to find first of right type
         declare
            Argument    : constant String := Ada.Command_Line.Argument (
                           Iterator.Argument_Index);
            New_Argument   : Boolean := False;

         begin
            if Iterator.Character_Index = 0 then
                                    -- first time through loop for this
                                    -- argument
               Iterator.Character_Index := 1;
            else
               if Iterator.In_Options then
                  if Iterator.Has_Parameter then
                     Iterator.Argument_Index :=
                        Iterator.Argument_Index + 1;

                     New_Argument := True;

                  else
                     Iterator.Character_Index := Iterator.Character_Index + 1;

                     if Iterator.Character_Index > Argument'Length then

                        Iterator.Argument_Index := Iterator.Argument_Index + 1;
                        New_Argument := True;

                     end if;
                  end if;
               else
                  Iterator.Argument_Index := Iterator.Argument_Index + 1;
                  New_Argument := True;
               end if;
            end if;

            if New_Argument then          -- Argument_Index advanced -
                                       -- get next argument string
               if Iterator.Argument_Index >
                     Ada.Command_Line.Argument_Count then
                  Iterator.At_End := True;
                  exit;
               end if;

               Iterator.Character_Index := 0;
               Iterator.In_Options := False;
            else
               if Iterator.Character_Index = 1 then
                  if Argument (1) = Iterator.Option_Prefix then
                              -- found an option
                     if Argument'Length < 2 then
                        Ada.Exceptions.Raise_Exception (Invalid_Option'identity,
                              "No option letter following a '-'");
                     end if;

                     Iterator.Character_Index := Iterator.Character_Index + 1;
                        Iterator.In_Options := True;
                     Iterator.In_Options := True;
                  end if;
               end if;

               if    Iterator.In_Options then

                  Iterator.Option := Argument (Iterator.Character_Index);

                  if Ada.Strings.Maps.Is_In (Iterator.Option,
                        Iterator.Options_With_Parameters) then
                                    -- option needs parameter
                     if Iterator.Character_Index = Argument'Last then
                                    -- parameter is next argument
                        if Iterator.Argument_Index + 1 >
                              Ada.Command_Line.Argument_Count then
                           Ada.Exceptions.Raise_Exception (No_Argument'identity,
                              "Missing parameter for '" &
                                 Iterator.Option & "' option.");
                        end if;

                        Iterator.Argument_Index := Iterator.Argument_Index + 1;
                        Iterator.Parameter_Index := 1;
                     else
                        Iterator.Parameter_Index := Iterator.Character_Index + 1;
                     end if;

                     Iterator.Has_Parameter := True;
                  else
                     Iterator.Has_Parameter := False;
                  end if;
               end if;

               if Iterator.In_Options then
                  if Iterator.Include_Options then
                     exit;
                  end if;
               else
                  if Iterator.Include_Non_Options then
                     exit;
                  end if;
               end if;
            end if;
         end;
      end loop;

      Dump_Iterator ("Advance out", Iterator);
   end Advance;

   -- raises Not_Option, No_Parameter, No_Argument
   -------------------------------------------------------------------
   procedure Advance_Parameter (
      Iterator          : in out Iterator_Type) is
   -------------------------------------------------------------------

   begin
      Dump_Iterator ("Advance_Parameter in", Iterator);

      if not Iterator.In_Options then
         Ada.Exceptions.Raise_Exception (Not_Option'identity,
            "Advance_Parameter called when no option found");
      end if;

      if not Iterator.Has_Parameter then
         Ada.Exceptions.Raise_Exception (No_Parameter'identity,
            "Advance_Parameter called for option with no parameters");
      end if;

      if Iterator.At_End then
         Ada.Exceptions.Raise_Exception (No_Argument'identity,
            "Advance_Parameter called after end in command line iterator" &
            Ada.Characters.Latin_1.LF &
            "or no more run string parameters");
      end if;

      Iterator.Argument_Index := Iterator.Argument_Index + 1;

      if Iterator.Argument_Index <= Ada.Command_Line.Argument_Count then

         declare
            Argument       : constant String := Ada.Command_Line.Argument (
                              Iterator.Argument_Index);

         begin
            Iterator.Has_Parameter := Argument (Argument'first) /= Iterator.Option_Prefix;

            if not Iterator.Has_Parameter then
               Iterator.In_Options := False;
            end if;

            Iterator.Parameter_Index := 1;
         end;
      else
         Iterator.Has_Parameter := False;
         Iterator.In_Options := False;
         Iterator.At_End := True;
      end if;

      Dump_Iterator ("Advance_Parameter out", Iterator);
   end Advance_Parameter;

   -------------------------------------------------------------------
   function At_End (
      Iterator          : in   Iterator_Type
   ) return Boolean is
   -------------------------------------------------------------------

   begin
      return Iterator.At_End;
   end At_End;

   -------------------------------------------------------------------
   procedure Dump_Iterator (
      Where             : in   String;
      Iterator          : in   Iterator_Type) is
   -------------------------------------------------------------------

   begin
      if Debug then
         Put_Line ("Iterator at               " & Where);
         Put_Line ("  Argument_Index          " & Iterator.Argument_Index'img);
         Put_Line ("  At_End                  " & Iterator.At_End'img);
         Put_Line ("  Character_Index         " & Iterator.Character_Index'img);
         Put_Line ("  Has_Parameter           " & Iterator.Has_Parameter'img);
         Put_Line ("  In_Options              " & Iterator.In_Options'img);
         Put_Line ("  Include_Non_Options     " & Iterator.Include_Non_Options'img);
         Put_Line ("  Include_Options         " & Iterator.Include_Options'img);
         Put_Line ("  Option                  " & Iterator.Option);
         Put_Line ("  Options_Prefix          " & Iterator.Option_Prefix);
         Put_Line ("  Options_With_Parameters " & Ada.Strings.Maps.To_Sequence (
                                          Iterator.Options_With_Parameters));
         Put_Line ("  Parameter_Index         " & Iterator.Parameter_Index'img);
      end if;
   end Dump_Iterator;

   -------------------------------------------------------------------
   function Get_Argument (
      Iterator          : in   Iterator_Type
   ) return String is
   -------------------------------------------------------------------

   begin
      Dump_Iterator ("Get_Argument", Iterator);

      if Iterator.At_End then
         raise No_Argument;
      end if;

      if Iterator.In_Options then
         raise Not_Argument;
      end if;


      return Ada.Command_Line.Argument (
         Iterator.Argument_Index);
   end Get_Argument;

   -- raise Invalid_Number
   -------------------------------------------------------------------
   function Get_Number (
      Iterator          : in   Iterator_Type
   ) return Float is
   -------------------------------------------------------------------

      Parameter            : constant String := Get_Parameter (Iterator);

   begin
      return Float'Value (Parameter);

   exception
      when CONSTRAINT_ERROR =>
         Ada.Exceptions.Raise_Exception (Invalid_Number'identity,
            "Invalid numeric parameter '" & Parameter & "' for '" &
            Iterator.Option & "' option.");

   end Get_Number;

   -- raise Invalid_Number
   -------------------------------------------------------------------
   function Get_Number (
      Iterator          : in   Iterator_Type
   ) return Integer is
   -------------------------------------------------------------------

      Parameter            : constant String := Get_Parameter (Iterator);

   begin
      return Integer'Value (Parameter);

   exception
      when CONSTRAINT_ERROR =>
         Ada.Exceptions.Raise_Exception (Invalid_Number'identity,
            "Invalid numeric parameter '" & Parameter & "' for '" &
            Iterator.Option & "' option.");

   end Get_Number;

   -- raise Invalid_Number
   -------------------------------------------------------------------
   function Get_Number (
      Iterator          : in   Iterator_Type;
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
      Modular_IO.Get (Parameter, Value, Last);
      return Value;

   exception
      when CONSTRAINT_ERROR =>
         Ada.Exceptions.Raise_Exception (Invalid_Number'identity,
            "Invalid numeric parameter '" & Parameter & "' for '" &
            Iterator.Option & "' option.");

   end Get_Number;

   -------------------------------------------------------------------
   function Get_Option (
      Iterator          : in   Iterator_Type
   ) return Character is
   -------------------------------------------------------------------

   begin
      Dump_Iterator ("Get_Option", Iterator);

      if not Iterator.In_Options then
         raise Not_Option;
      end if;

      if Debug then
         Put_Line ("return option " & Iterator.Option);
      end if;

      return Iterator.Option;
   end Get_Option;

   -- raises No_Parameter, Not_Option
   -------------------------------------------------------------------
   function Get_Parameter (
      Iterator          : in   Iterator_Type
   ) return String is
   -------------------------------------------------------------------

   begin
      Dump_Iterator ("Get_Parameter", Iterator);

      if Iterator.At_End then
         Ada.Exceptions.Raise_Exception (No_Parameter'identity,
            "Get_Parameter after end of command line found.");
      end if;

      if not Iterator.In_Options then
         Ada.Exceptions.Raise_Exception (Not_Option'identity,
            "Get_Parameter called when no option found");
      end if;

      if not Iterator.Has_Parameter then
         Ada.Exceptions.Raise_Exception (No_Parameter'identity,
            "Get_Parameter called for option '" &
            Iterator.Option & "' with no parameters");
      end if;

      declare
         Word           : constant String := Ada.Command_Line.Argument (
                           Iterator.Argument_Index);
      begin
         return Word (Iterator.Parameter_Index .. Word'Last);
      end;

   end Get_Parameter;

   -------------------------------------------------------------------
   function Get_Signed (
      Iterator          : in   Iterator_Type
   ) return Value_Type is
   -------------------------------------------------------------------

      Parameter            : constant String := Get_Parameter (Iterator);

   begin
      return Value_Type'Value (Parameter);

   exception
      when CONSTRAINT_ERROR =>
         Ada.Exceptions.Raise_Exception (Invalid_Number'identity,
            "Invalid signed parameter '" & Parameter & "' for '" &
            Iterator.Option & "' option.");

   end Get_Signed;

   -- raises No_Selection, Invalid_Option
   -------------------------------------------------------------------
   function Initialize (
      Include_Options         : in   Boolean;
      Include_Non_Options     : in   Boolean;
      Options_With_Parameters : in   String  := "";
      Option_Prefix        : in Character := '-';
      Skip              : in   Natural := 0
   ) return Iterator_Type is
   -------------------------------------------------------------------

      Iterator          : Iterator_Type := (
         Argument_Index    => 1 + Skip,
         At_End            => False,
         Character_Index      => 0,
         Has_Parameter     => False,
         In_Options        => False,
         Include_Options      => Include_Options,
         Include_Non_Options  => Include_Non_Options,
         Option            => ' ',
         Option_Prefix     => Option_Prefix,
         Options_With_Parameters
                        => Ada.Strings.Maps.To_Set (
                           Options_With_Parameters),
         Parameter_Index      => 1);

   begin
      Dump_Iterator ("Initialzie", Iterator);

      if not (Iterator.Include_Options or else
             Iterator.Include_Non_Options) then
         raise No_Selection;
      end if;

      if Iterator.Argument_Index > Ada.Command_Line.Argument_Count then
         Iterator.At_End := True;
      else
         Advance (Iterator);
      end if;

      return Iterator;
   end Initialize;

   -- raises No_Argument
   -------------------------------------------------------------------
   function Is_Option (
      Iterator          : in   Iterator_Type
   ) return Boolean is
   -------------------------------------------------------------------

   begin
      if Iterator.At_End then
         raise No_Argument;
      end if;

      return Iterator.In_Options;
   end Is_Option;

   -- raises No_Argument, Not_Option
   -------------------------------------------------------------------
   function Has_Parameter (
      Iterator          : in   Iterator_Type
   ) return Boolean is
   -------------------------------------------------------------------

   begin
      if Iterator.At_End then
         raise No_Argument;
      end if;

      if not Iterator.In_Options then
         raise Not_Option;
      end if;

      return Iterator.Has_Parameter;
   end Has_Parameter;

   procedure Make is

   begin
      null;
   end Make;

end Command_Line_Iterator;
