-- package that provides a dispersion type that guarenties values are
-- multiples of 10
generic
   Factor                  : in  Positive;
   Min                     : in  Integer;
   Max                     : in  Integer;
package Ada_Lib.Factorable is

   type Factorable_Type    is private;

   Maximum                 : constant Factorable_Type;
   Minimum                 : constant Factorable_Type;

   function "+" (
      Left, Right          : in   Factorable_Type
   ) return Factorable_Type;

   function "+" (
      Left              : in   Factorable_Type;
      Right             : in   Integer
   ) return Factorable_Type;

   function "+" (
      Left              : in   Integer;
      Right             : in   Factorable_Type
   ) return Factorable_Type;

   function "-" (
      Left, Right          : in   Factorable_Type
   ) return Factorable_Type;

   function "-" (
      Left              : in   Factorable_Type;
      Right             : in   Integer
   ) return Factorable_Type;

   function "-" (
      Left              : in   Integer;
      Right             : in   Factorable_Type
   ) return Factorable_Type;

   function "-" (
      Value             : in   Factorable_Type
   ) return Factorable_Type;

   function "/" (
      Left, Right          : in   Factorable_Type
   ) return Factorable_Type;

   function "/" (
      Left              : in   Factorable_Type;
      Right             : in   Integer
   ) return Factorable_Type;

   function "/" (
      Left              : in   Integer;
      Right             : in   Factorable_Type
   ) return Factorable_Type;

   function "*" (
      Left, Right          : in   Factorable_Type
   ) return Factorable_Type;

   function "*" (
      Left              : in   Factorable_Type;
      Right             : in   Integer
   ) return Factorable_Type;

   function "*" (
      Left              : in   Integer;
      Right             : in   Factorable_Type
   ) return Factorable_Type;

   overriding
   function "=" (
      Left, Right          : in   Factorable_Type
   ) return Boolean;

   function "=" (
      Left              : in   Factorable_Type;
      Right             : in   Integer
   ) return Boolean;

   function "=" (
      Left              : in   Integer;
      Right             : in   Factorable_Type
   ) return Boolean;

   function ">" (
      Left, Right          : in   Factorable_Type
   ) return Boolean;

   function ">" (
      Left              : in   Factorable_Type;
      Right             : in   Integer
   ) return Boolean;

   function ">" (
      Left              : in   Integer;
      Right             : in   Factorable_Type
   ) return Boolean;

   function "<" (
      Left, Right          : in   Factorable_Type
   ) return Boolean;

   function "<" (
      Left              : in   Factorable_Type;
      Right             : in   Integer
   ) return Boolean;

   function "<" (
      Left              : in   Integer;
      Right             : in   Factorable_Type
   ) return Boolean;

   function ">=" (
      Left, Right          : in   Factorable_Type
   ) return Boolean;

   function ">=" (
      Left              : in   Factorable_Type;
      Right             : in   Integer
   ) return Boolean;

   function ">=" (
      Left              : in   Integer;
      Right             : in   Factorable_Type
   ) return Boolean;

   function "<=" (
      Left, Right          : in   Factorable_Type
   ) return Boolean;

   function "<=" (
      Left              : in   Factorable_Type;
      Right             : in   Integer
   ) return Boolean;

   function "<=" (
      Left              : in   Integer;
      Right             : in   Factorable_Type
   ) return Boolean;

   function From (
      Value             : in   Factorable_Type
   ) return Integer;

   function Image (
      Value             : in   Factorable_Type
   ) return String;

   function To (
      Value             : in   Integer
   ) return Factorable_Type;

   function To (
      Value             : in   String
   ) return Factorable_Type;

private

   type Factorable_Type    is new Integer range Min .. Max;

   Maximum                 : constant Factorable_Type :=
                           Factorable_Type (Max);
   Minimum                 : constant Factorable_Type :=
                           Factorable_Type (Min);

end Ada_Lib.Factorable;