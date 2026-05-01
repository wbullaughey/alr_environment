with Ada.Strings.Unbounded;

package Ada_Lib.String_Quote is

   function Quote (
      Value                : in   Character
   ) return String;

   function Quote (
      Value                : in   String
   ) return String;

   function Quote (
      Value                : in   Ada.Strings.Unbounded.Unbounded_String
   ) return String;

   function Quote (
      Variable             : in   String;
      Value                : in   Character
   ) return String;

   function Quote (
      Variable             : in   String;
      Value                : in   String
   ) return String;

   function Quote (
      Variable             : in   String;
      Value                : access constant String
   ) return String;

   function Quote (
      Variable             : in   String;
      Value                : in   Ada.Strings.Unbounded.Unbounded_String
   ) return String;

end Ada_Lib.String_Quote;
