with Ada_Lib.Time;

package Ada_Lib.Strings.Float is

   function Format (
      Value             : in   Standard.Float;
      Width             : in   Natural := 0;
      Aft                  : in   Natural := 1;
      Exponent          : in   Natural := 0
   ) return String;

   function Format (
      Value             : in   Ada_Lib.Time.Duration_Type;
      Width             : in   Natural := 0;
      Aft                  : in   Natural := 1;
      Exponent          : in   Natural := 0
   ) return String;

   generic
      type Value_Type         is digits <>;

   function Generic_Format (
      Value             : in   Value_Type;
      Width             : in   Natural := 0;
      Aft                  : in   Natural := 1;
      Exponent          : in   Natural := 0
   ) return String;

end Ada_Lib.Strings.Float;
