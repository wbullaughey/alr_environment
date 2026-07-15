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

with Ada.Float_Text_IO;
with Ada.Text_IO;

package body Ada_Lib.Strings.Float is

   function Format (
      Value             : in   Standard.Float;
      Width             : in   Natural := 0;
      Aft                  : in   Natural := 1;
      Exponent          : in   Natural := 0
   ) return String is

      Result_Width         : Positive;

   begin
      if Width = 0 then
         Result_Width := 50;
      else
         Result_Width := Width;
      end if;

      declare
         Stop           : Natural;
         Result            : String (1 .. Result_Width);

      begin
         Ada.Float_Text_IO.Put (Result, Value, Aft, Exponent);

         if Aft = 0 then            -- trim off digits after decimal point
            Stop := Ada.Strings.Fixed.Index (Result, ".");
            if Stop = 0 then
               Stop := Result'last;
            end if;
         else
            Stop := Result'last;
         end if;

         if Width = 0 then
            return Ada_Lib.Strings.Trim (Result (Result'first .. Stop));
         else
            return Result (Result'first .. Stop);
         end if;
      end;
   end Format;

   function Format (
      Value             : in   Ada_Lib.Time.Duration_Type;
      Width             : in   Natural := 0;
      Aft                  : in   Natural := 1;
      Exponent          : in   Natural := 0
   ) return String is
   begin
      return Format (Standard.Float (Value), Width, Aft, Exponent);
   end Format;
   function Generic_Format (
      Value             : in   Value_Type;
      Width             : in   Natural := 0;
      Aft                  : in   Natural := 1;
      Exponent          : in   Natural := 0
   ) return String is

      package Float_IO is new Ada.Text_IO.Float_IO (Value_Type);

      Result_Width         : Positive;

   begin
      if Width = 0 then
         Result_Width := 50;
      else
         Result_Width := Width;
      end if;

      declare
         Stop           : Natural;
         Result            : String (1 .. Result_Width);

      begin
         Float_IO.Put (Result, Value, Aft, Exponent);

         if Aft = 0 then            -- trim off digits after decimal point
            Stop := Ada.Strings.Fixed.Index (Result, ".");
            if Stop = 0 then
               Stop := Result'last;
            end if;
         else
            Stop := Result'last;
         end if;

         if Width = 0 then
            return Ada_Lib.Strings.Trim (Result (Result'first .. Stop));
         else
            return Result (Result'first .. Stop);
         end if;
      end;
   end Generic_Format;

end Ada_Lib.Strings.Float;

