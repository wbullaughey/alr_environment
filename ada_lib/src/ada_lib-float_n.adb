-- package to provide a floating point type that fits in specified bits

with Ada.Exceptions;
with Ada_Lib.Trace;use Ada_Lib.Trace;

package body Ada_Lib.Float_N is
   -------------------------------------------------------------------
   function "+" (
      Left, Right          : in   Float_N_Type
   ) return Float_N_Type is
   -------------------------------------------------------------------

   begin
      return Convert (Convert (Left) + Convert (Right));
   end "+";

   -------------------------------------------------------------------
   function "-" (
      Left, Right          : in   Float_N_Type
   ) return Float_N_Type is
   -------------------------------------------------------------------

   begin
      return Convert (Convert (Left) - Convert (Right));
   end "-";

   -------------------------------------------------------------------
   function "*" (
      Left, Right          : in   Float_N_Type
   ) return Float_N_Type is
   -------------------------------------------------------------------

   begin
      return Convert (Convert (Left) * Convert (Right));
   end "*";

   -------------------------------------------------------------------
   function "/" (
      Left, Right          : in   Float_N_Type
   ) return Float_N_Type is
   -------------------------------------------------------------------

   begin
      return Convert (Convert (Left) / Convert (Right));
   end "/";

   -------------------------------------------------------------------
   function Convert (
      Source               : in   Float_N_Type
   ) return Float is
   -------------------------------------------------------------------

      Result               : constant Float :=
                           Float (Source.Mantisa) *
                           Math."**" (
                              Float (Mantisa_Base),
                              (-1.0 * Float (Source.Exponent + Mantisa_Bits)));

   begin
      return Result;
   end Convert;

   -------------------------------------------------------------------
   function Convert (
      Source               : in   Float
   ) return Float_N_Type is
   -------------------------------------------------------------------

   begin
      -- Cannot take the log of 0.0 or negative floats
      if Source <= 0.0 then
         return (
            Exponent => 0,
            Mantisa     => 0);

      else
         declare
            Log                  : constant Float :=
                                 Math.Log (Source, Base => Float (Mantisa_Base));
            Exponent          : constant Float :=
                                 Float'Floor (Log);
            Mantisa              : constant Float :=
                                 Math."**" (Float (Mantisa_Base), (Log - Exponent));
            Ada_Lib_Exponent         : Integer :=
                                 Integer ((-1.0 * Exponent) - 1.0);
            Ada_Lib_Mantisa          : Natural :=
                                 Natural (
                                    Float'Rounding (
                                       Mantisa * (Float (Mantisa_Base) ** (Mantisa_Bits - 1))));

         begin
            -- Rounding up may exceed the range of mantisa base type
            if Ada_Lib_Mantisa > Mantisa_Type'last then
               Ada_Lib_Exponent := Ada_Lib_Exponent - 1;
               Ada_Lib_Mantisa := Natural (Float'Rounding (Float (Ada_Lib_Mantisa) / Float (Mantisa_Base)));
            end if;

            -- If source is too big, return maximum value
            if Ada_Lib_Exponent < Exponent_Type'first then
               Ada_Lib_Exponent := Exponent_Type'first;
               Ada_Lib_Mantisa := Mantisa_Type'last;
            -- If source is too small, return minimum value
            elsif Ada_Lib_Exponent > Exponent_Type'last then
               Ada_Lib_Exponent := Exponent_Type'first;
               Ada_Lib_Mantisa := Mantisa_Type'first;
            end if;

            return (
               Exponent => Ada_Lib_Exponent,
               Mantisa     => Ada_Lib_Mantisa);
         end;
      end if;
   end Convert;

   -------------------------------------------------------------------
   function Image (
      Source               : in   Float_N_Type
   ) return String is
   -------------------------------------------------------------------

   begin
      return Convert (Source)'img;
   exception
      when Fault: others =>
         Log_Here (Ada.Exceptions.Exception_Name (Fault));
         Log_Here (Ada.Exceptions.Exception_Message (Fault));
         Log_Here (" source=" & Source.Mantisa'img & " E" & Source.Exponent'img);
         return "*******";
   end Image;
end Ada_Lib.Float_N;
