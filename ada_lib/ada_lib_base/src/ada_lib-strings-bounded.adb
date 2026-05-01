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

-----------------------------------------------------------------------
-- Package implementing a string type with fixed maximum length set
-----------------------------------------------------------------------

with Ada.Exceptions;
with Ada.Strings.Hash;
with Ada.Text_IO; use Ada.Text_IO;  -- Ada_Lib_LIB_Debug

package body Ada_Lib.Strings.Bounded is

   procedure Check_Append (
      Original          : in   Bounded_Type;
      Append               : in   String);

   procedure Verify (
      Bounded              : in   Bounded_Type);

   Maximum_Bound           : constant := 1_000_000_000;  --arbitrary
   Trace                : constant Boolean := False;

   -------------------------------------------------------------------
   function Bounded (
      Contents          : in   String;
      Limit             : in   Natural := 0
   ) return Bounded_Type is
   -------------------------------------------------------------------

      Bound             : constant Natural := (if Limit = 0 then Contents'length else Limit);
      Filler               : constant String (
                           1 .. Limit - Contents'length) := (
         others => ' ');

   begin
      if Bound > Maximum_Bound then
         Ada.Exceptions.Raise_Exception (Maximum_Bound_Exceeded'identity,
            "Requested bound" & Limit'img & " maximum" &
            Maximum_Bound'img);
      end if;

      return (
         Bound       => Bound,
         Length      => Contents'length,
         Contents => Contents & Filler);
   end Bounded;

   -------------------------------------------------------------------
    function Hash (
      Bounded              : in   Bounded_Type
    ) return Ada.Containers.Hash_Type is
   -------------------------------------------------------------------

    begin
        return Ada.Strings.Hash (To_String (Bounded));
    end Hash;

   -------------------------------------------------------------------
   function Length (
      Bounded              : in   Bounded_Type
   ) return Natural is
   -------------------------------------------------------------------

   begin
      if Trace then
         Put_Line ("bounded length" & Bounded.Length'img);
      end if;

      Verify (Bounded);
      return Bounded.Length;
   end Length;

   -------------------------------------------------------------------
   function "&" (
      Original          : in   Bounded_Type;
      Appended          : in   String
   ) return Bounded_Type is
   -------------------------------------------------------------------

      Result               : Bounded_Type := Original;

   begin
      Append (Result, Appended);
      return Result;
   end "&";

   -------------------------------------------------------------------
   function "&" (
      Original          : in   Bounded_Type;
      Appended          : in   Bounded_Type
   ) return Bounded_Type is
   -------------------------------------------------------------------

   begin
      return Original & To_String (Appended);
   end "&";

   -------------------------------------------------------------------
   function "&" (
      Original          : in   String;
      Appended          : in   Bounded_Type
   ) return Bounded_Type is
   -------------------------------------------------------------------

   begin
      return Bounded (Original) & Appended;
   end "&";

   -------------------------------------------------------------------
   -- raises the Too_Long Maximum_Bound_Exceeded and Corrupt exceptions
   function "&" (
      Original          : in   Bounded_Type;
      Appended          : in   Character
   ) return Bounded_Type is
   -------------------------------------------------------------------

   begin
      return Original & String'(1 => Appended);
   end "&";

   -------------------------------------------------------------------
   overriding
   function "=" (
      Bounded_1            : in   Bounded_Type;
      Bounded_2            : in   Bounded_Type
   ) return Boolean is
   -------------------------------------------------------------------

   begin
      return Bounded_1.Length = Bounded_2.Length and then
         Bounded_1.Contents (Bounded_1.Contents'first .. Bounded_1.Length) =
         Bounded_2.Contents (Bounded_2.Contents'first .. Bounded_2.Length);

   end "=";

   -------------------------------------------------------------------
   procedure Append (
      Original          : in out Bounded_Type;
      Append               : in   String;
      Truncate          : in   Boolean := False;
      Truncated_Suffix     : in   String := "")
   -------------------------------------------------------------------
   is
      From_New_Part        : Natural := Append'Length;
      Start_New_Part       : Positive;
      Truncated            : Boolean := False;

   begin
      if Trace then
         Put_Line ("bounded append '" & Append & "' to '" &
            Original.Contents (
               Original.Contents'first .. Original.Length) & "'");
      end if;

      Verify (Original);

      -- Start appending at the end of whatever's in there now
      Start_New_Part := Original.Contents'First + Original.Length;

      if Truncate then
         if Original.Length + Append'Length > Original.Bound then
            From_New_Part := Original.Bound - Original.Length;

            Truncated := True;
         end if;
      else
         Check_Append (Original, Append);
      end if;

      if From_New_Part > 0 then
      Original.Contents (Start_New_Part ..
            Start_New_Part + From_New_Part - 1) :=
               Append (Append'first .. Append'first + From_New_Part - 1);
      end if;

      -- Update Length
      if Truncated then
         Original.Length := Original.Bound;

         if Truncated_Suffix'Length > 0 then
            if Truncated_Suffix'Length > Original.Bound then
               Ada.Exceptions.Raise_Exception (Too_Long'identity,
                  "Truncated_Suffix '" & Truncated_Suffix &
                  " is longer then the bound on original value " &
                  Original.Contents);
            else
               Original.Contents (Original.Contents'last -
                  Truncated_Suffix'Length + 1 ..
                     Original.Contents'last) := Truncated_Suffix;
            end if;
         end if;
      else
      Original.Length := Original.Length + Append'Length;
      end if;

   end Append;

   -------------------------------------------------------------------
   procedure Check_Append (
      Original          : in   Bounded_Type;
      Append               : in   String) is
   -------------------------------------------------------------------

   begin
      -- Make sure that appending this won't overflow the buffer
      if Original.Length + Append'Length > Original.Bound then
         Ada.Exceptions.Raise_Exception (Too_Long'identity,
            "appending '" & Append & "' (" & Append'Length'img &") to '" &
            Original.Contents (Original.Contents'first .. Original.Length) & "' (" &
            Original.Length'img & ")");
      end if;
   end Check_Append;

   -------------------------------------------------------------------
   procedure Set (
      Bounded              : in out Bounded_Type;
      Source               : in   String) is
   -------------------------------------------------------------------

   begin
      if Trace then
         Put_Line ("set bounded to '" & Source & "'");
      end if;

      Verify (Bounded);

      if Source'Length > Bounded.Bound then
         Ada.Exceptions.Raise_Exception (Too_Long'identity,
            "set bound string longer then bound. Value: '" &
            Source & "' bound:" & Bounded.Bound'img);
      end if;

      Bounded.Length := Source'Length;
      Bounded.Contents (Bounded.Contents'first .. Source'Length) :=
         Source;
   end Set;

   -------------------------------------------------------------------
   procedure Set (
      Bounded              : in out Bounded_Type;
      Source               : in   Bounded_Type) is
   -------------------------------------------------------------------

   begin
      if Trace then
         Put_Line ("set bounded to '" & To_String (Source) & "'");
      end if;

      Verify (Bounded);

      if Source.Length > Bounded.Bound then
         Ada.Exceptions.Raise_Exception (Too_Long'identity,
            "set bound string longer then bound. Value: '" &
            To_String (Source) & "' bound:" & Bounded.Bound'img);
      end if;

      Bounded.Length := Source.Length;
      Bounded.Contents (Bounded.Contents'first .. Source.Length) :=
         Source.Contents (Source.Contents'first .. Source.Length);
   end Set;

   -------------------------------------------------------------------
   function To_String (
      Source               : in   Bounded_Type
   ) return String is
   -------------------------------------------------------------------

   begin
      if Trace then
         Put_Line ("bounded to string '" &
            Source.Contents (Source.Contents'first .. Source.Length) & "'");
      end if;

      Verify (Source);

      return Source.Contents (Source.Contents'first ..
         Source.Length);

   end To_String;

   -------------------------------------------------------------------
   procedure Truncate (
      Bounded              : in out Bounded_Type;
      Length               : in   Natural) is
   -------------------------------------------------------------------

   begin
      if Length <= Bounded.Length then
         Bounded.Length := Length;
      else
         raise Truncate_Too_Long;
      end if;
   end Truncate;

   -------------------------------------------------------------------
   procedure Verify (
      Bounded              : in   Bounded_Type) is
   -------------------------------------------------------------------

   begin
      if Bounded.Bound > Maximum_Bound then
         Ada.Exceptions.Raise_Exception (Maximum_Bound_Exceeded'identity,
            "Bad bounded string. Bound" &  Bounded.Bound'img &
            " maximum" & Maximum_Bound'img);
      end if;

      if Bounded.Length > Bounded.Bound then
         Ada.Exceptions.Raise_Exception (Corrupt'identity,
            "bad string. Length" & Bounded.Length'img &
               " bound" & Bounded.Bound'img);
      end if;
   end Verify;

   -------------------------------------------------------------------
   function Verify (
      Bounded              : in   Bounded_Type;
      Limit             : in   Natural
   ) return Boolean is
   -------------------------------------------------------------------

   begin
      return Bounded.Bound <= Limit and then Bounded.Length <= Bounded.Bound;
   end Verify;

end Ada_Lib.Strings.Bounded;
