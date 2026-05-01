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


with Ada.Calendar;
with Ada.Unchecked_Conversion;
with Ada_Lib.Strings;

package body Unique_Number is

   function Coerce is new Ada.Unchecked_Conversion (
      Source   => Ada.Calendar.Time,
      Target   => Number_Type);

   Last_Value              : Number_Type := 0;

   -------------------------------------------------------------------
   function Get
   return Number_Type is
   -------------------------------------------------------------------

      Result               : Number_Type;

   begin
      Result := Coerce (Ada.Calendar.Clock);

      if Result = Last_Value then
         Result := Result + 1;
      end if;

      Last_Value := Result;

      return Result;
   end Get;

   -------------------------------------------------------------------
   function To_String (
      Number               : in   Number_Type
   ) return String is
   -------------------------------------------------------------------

   begin
      return Ada_Lib.Strings.Trim (Number'img);
   end To_String;

end Unique_Number;