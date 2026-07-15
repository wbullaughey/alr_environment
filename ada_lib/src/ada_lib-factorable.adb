-- package that provides a dispersion type that guarenties values are
-- multiples of 10

with Ada_Lib.Strings;

package body Ada_Lib.Factorable is

   function Round (
      Value             : in   Integer
   ) return Factorable_Type;

   ---------------------------------------------------------------------------
   overriding
   function "+" (
      Left, Right          : in   Factorable_Type
   ) return Factorable_Type is
   ---------------------------------------------------------------------------

   begin
      return Factorable_Type (Integer (Left) + Integer (Right));
   end "+";

   ---------------------------------------------------------------------------
   function "+" (
      Left              : in   Factorable_Type;
      Right             : in   Integer
   ) return Factorable_Type is
   ---------------------------------------------------------------------------

   begin
      return Round (Integer (Left) + Right);
   end "+";

   ---------------------------------------------------------------------------
   function "+" (
      Left              : in   Integer;
      Right             : in   Factorable_Type
   ) return Factorable_Type is
   ---------------------------------------------------------------------------

   begin
      return Round (Left + Integer (Right));
   end "+";

   ---------------------------------------------------------------------------
   overriding
   function "-" (
      Left, Right          : in   Factorable_Type
   ) return Factorable_Type is
   ---------------------------------------------------------------------------

   begin
      return Factorable_Type (Integer (Left) - Integer (Right));
   end "-";

   ---------------------------------------------------------------------------
   function "-" (
      Left              : in   Factorable_Type;
      Right             : in   Integer
   ) return Factorable_Type is
   ---------------------------------------------------------------------------

   begin
      return Round (Integer (Left) - Right);
   end "-";

   ---------------------------------------------------------------------------
   function "-" (
      Left              : in   Integer;
      Right             : in   Factorable_Type
   ) return Factorable_Type is
   ---------------------------------------------------------------------------

   begin
      return Round (Left - Integer (Right));
   end "-";

   ---------------------------------------------------------------------------
   overriding
   function "-" (
      Value             : in   Factorable_Type
   ) return Factorable_Type is
   ---------------------------------------------------------------------------

   begin
      return Factorable_Type (-Integer (Value));
   end "-";

   ---------------------------------------------------------------------------
   overriding
   function "*" (
      Left, Right          : in   Factorable_Type
   ) return Factorable_Type is
   ---------------------------------------------------------------------------

   begin
      return Factorable_Type (Integer (Left) * Integer (Right));
   end "*";

   ---------------------------------------------------------------------------
   function "*" (
      Left              : in   Factorable_Type;
      Right             : in   Integer
   ) return Factorable_Type is
   ---------------------------------------------------------------------------

   begin
      return Round (Integer (Left) * Right);
   end "*";

   ---------------------------------------------------------------------------
   function "*" (
      Left              : in   Integer;
      Right             : in   Factorable_Type
   ) return Factorable_Type is
   ---------------------------------------------------------------------------

   begin
      return Round (Left * Integer (Right));
   end "*";

   ---------------------------------------------------------------------------
   overriding
   function "/" (
      Left, Right          : in   Factorable_Type
   ) return Factorable_Type is
   ---------------------------------------------------------------------------

   begin
      return Factorable_Type (Integer (Left) / Integer (Right));
   end "/";

   ---------------------------------------------------------------------------
   function "/" (
      Left              : in   Factorable_Type;
      Right             : in   Integer
   ) return Factorable_Type is
   ---------------------------------------------------------------------------

   begin
      return Round (Integer (Left) / Right);
   end "/";

   ---------------------------------------------------------------------------
   function "/" (
      Left              : in   Integer;
      Right             : in   Factorable_Type
   ) return Factorable_Type is
   ---------------------------------------------------------------------------

   begin
      return Round (Left / Integer (Right));
   end "/";

   ---------------------------------------------------------------------------
   overriding
   function "=" (
      Left, Right          : in   Factorable_Type
   ) return Boolean is
   ---------------------------------------------------------------------------

   begin
      return Integer (Left) = Integer (Right);
   end "=";

   ---------------------------------------------------------------------------
   function "=" (
      Left              : in   Factorable_Type;
      Right             : in   Integer
   ) return Boolean is
   ---------------------------------------------------------------------------

   begin
      return Integer (Left) = Right;
   end "=";

   ---------------------------------------------------------------------------
   function "=" (
      Left              : in   Integer;
      Right             : in   Factorable_Type
   ) return Boolean is
   ---------------------------------------------------------------------------

   begin
      return Left = Integer (Right);
   end "=";

   ---------------------------------------------------------------------------
   overriding
   function "<" (
      Left, Right          : in   Factorable_Type
   ) return Boolean is
   ---------------------------------------------------------------------------

   begin
      return Integer (Left) < Integer (Right);
   end "<";

   ---------------------------------------------------------------------------
   function "<" (
      Left              : in   Factorable_Type;
      Right             : in   Integer
   ) return Boolean is
   ---------------------------------------------------------------------------

   begin
      return Integer (Left) < Right;
   end "<";

   ---------------------------------------------------------------------------
   function "<" (
      Left              : in   Integer;
      Right             : in   Factorable_Type
   ) return Boolean is
   ---------------------------------------------------------------------------

   begin
      return Left < Integer (Right);
   end "<";

   ---------------------------------------------------------------------------
   overriding
   function ">" (
      Left, Right          : in   Factorable_Type
   ) return Boolean is
   ---------------------------------------------------------------------------

   begin
      return Integer (Left) > Integer (Right);
   end ">";

   ---------------------------------------------------------------------------
   function ">" (
      Left              : in   Factorable_Type;
      Right             : in   Integer
   ) return Boolean is
   ---------------------------------------------------------------------------

   begin
      return Integer (Left) > Right;
   end ">";

   ---------------------------------------------------------------------------
   function ">" (
      Left              : in   Integer;
      Right             : in   Factorable_Type
   ) return Boolean is
   ---------------------------------------------------------------------------

   begin
      return Left > Integer (Right);
   end ">";

   ---------------------------------------------------------------------------
   overriding
   function "<=" (
      Left, Right          : in   Factorable_Type
   ) return Boolean is
   ---------------------------------------------------------------------------

   begin
      return Integer (Left) <= Integer (Right);
   end "<=";

   ---------------------------------------------------------------------------
   function "<=" (
      Left              : in   Factorable_Type;
      Right             : in   Integer
   ) return Boolean is
   ---------------------------------------------------------------------------

   begin
      return Integer (Left) <= Right;
   end "<=";

   ---------------------------------------------------------------------------
   function "<=" (
      Left              : in   Integer;
      Right             : in   Factorable_Type
   ) return Boolean is
   ---------------------------------------------------------------------------

   begin
      return Left <= Integer (Right);
   end "<=";

   ---------------------------------------------------------------------------
   overriding
   function ">=" (
      Left, Right          : in   Factorable_Type
   ) return Boolean is
   ---------------------------------------------------------------------------

   begin
      return Integer (Left) >= Integer (Right);
   end ">=";

   ---------------------------------------------------------------------------
   function ">=" (
      Left              : in   Factorable_Type;
      Right             : in   Integer
   ) return Boolean is
   ---------------------------------------------------------------------------

   begin
      return Integer (Left) >= Right;
   end ">=";

   ---------------------------------------------------------------------------
   function ">=" (
      Left              : in   Integer;
      Right             : in   Factorable_Type
   ) return Boolean is
   ---------------------------------------------------------------------------

   begin
      return Left >= Integer (Right);
   end ">=";

   ---------------------------------------------------------------------------
   function From (
      Value             : in   Factorable_Type
   ) return Integer is
   ---------------------------------------------------------------------------

   begin
      return Integer (Value);
   end From;

   ---------------------------------------------------------------------------
   function Image (
      Value             : in   Factorable_Type
   ) return String is
   ---------------------------------------------------------------------------

   begin
      return Ada_Lib.Strings.Trim (Value'img);
   end Image;

   ---------------------------------------------------------------------------
   function To (
      Value             : in   Integer
   ) return Factorable_Type is
   ---------------------------------------------------------------------------

   begin
      return Round (Value);
   end To;

   ---------------------------------------------------------------------------
   function To (
      Value             : in   String
   ) return Factorable_Type is
   ---------------------------------------------------------------------------

   begin
      return Round (Integer'value (Value));
   end To;

   ---------------------------------------------------------------------------
   function Round (
      Value             : in   Integer
   ) return Factorable_Type is
   ---------------------------------------------------------------------------

   begin
      if Value > Integer'(0) then
         return Factorable_Type (
            ((Value + Factor / Integer'(2)) / Factor) * Factor);
      else
         return Factorable_Type (
            ((Value - Factor / Integer'(2)) / Factor) * Factor);
      end if;
   end Round;

end Ada_Lib.Factorable;