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

with Ada.Exceptions;
with Ada.Text_IO;
with Ada.Strings.Fixed;
with Ada.Numerics.Generic_Elementary_Functions;
with Ada_Lib.Trace; use Ada_Lib.Trace;

package body Ada_Lib.Delta_Float is

    package IO is
        new Ada.Text_IO.Float_IO (Num => Float_Type);

    package Math is
        new Ada.Numerics.Generic_Elementary_Functions (Float_Type =>
                                                         Float);

    --  NOTE: After is calculated in the package body.

    After                   : Ada.Text_IO.Field := 0;

    -------------
    -- Changed --
    -------------

    function Changed
      (Old_Value            : in     Float_Type;
       Current_Value        : in     Float_Type)
      return Boolean
    is
    begin
        if Float (Old_Value - Current_Value) > Epsilon or else
          Float (Current_Value - Old_Value) > Epsilon then
            return True;
        else
            return False;
        end if;
    end Changed;

    ---------------
    -- To_String --
    ---------------

    function To_String (Value : in Float_Type) return String
    is
        Buffer                  : String (1 .. 25);
        Index_Of_Decimal        : Natural;
    begin
        -- First, write to the local buffer with a large number
        -- of decimal digits.
        Io.Put (Buffer,
                Value,
                Aft => After,
                Exp => 0);

        -- Next locate the decimal point in the buffer and depending
        -- on our value of After, return so many digits

        if After < 1 then
        Index_Of_Decimal := Ada.Strings.Fixed.Index (Buffer, ".");

            return Ada.Strings.Fixed.Trim
              (Buffer (1 .. Index_Of_Decimal - 1),
               Side => Ada.Strings.Left);
        else
            return Ada.Strings.Fixed.Trim
              (Buffer,
               Side => Ada.Strings.Left);
        end if;

        -- return Ada.Strings.Fixed.Trim (Buffer, Side => Ada.Strings.Both);
   exception
      when Fault: others =>
         Log_Here (Ada.Exceptions.Exception_Name (Fault));
         Log_Here (Ada.Exceptions.Exception_Message (Fault));
         Log_Here ("value=" & Value'img & " after:" & After'img);
         return "*******";
    end To_String;

begin   -- Delta_Float

    --  'After' is the nuumber of digits to display after the decimal.
    --  This is calculated to give enough accuracy to display Epsilon.

    if Epsilon >= 1.0 then
        --  For any Epsilon >= 1.0, we shouldn't display anything
        --  after the decimal point.
        After := 0;
    elsif Epsilon < 0.0 then
        --  Special case.  Negative epsilon.  This will never
        --  hold true, I don't know what to do in this case.  Perhaps
        --  raise an exception?
        pragma Assert (Epsilon >= 0.0);
        After := 0;
    elsif Epsilon = 0.0 then
        --  Special case.  Epsilon = 0 will always hold true.
        --  So, we'll write out a large number of digits.
        After := 5;
    else
        --  The only case left is when Epsilon is in (0.0, 1.0).
        --  We'll set After to one less then the number of digits
        --  required to represent Epsilon;
        pragma Assert (Epsilon > 0.0 and then Epsilon < 1.0);
        declare
            Temp : Float;
        begin
            Temp := Float'Floor (Math.Log (Epsilon, Base => 10.0));
            After := Ada.Text_Io.Field (abs (Temp) - 1.0);
        end;
    end if;

end Ada_Lib.Delta_Float;
