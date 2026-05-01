with Ada.Characters.Latin_1;
with Ada_Lib.Substiture_For_Non_Alpha;

package body Ada_Lib.String_Quote is

   -------------------------------------------------------------------
   function Quote (
      Value                : in   Character
   ) return String is
   -------------------------------------------------------------------

   begin
      return (if Value = Ada.Characters.Latin_1.Nul then
            "NUL"
         else
            String'(1 => Ada_Lib.Substiture_For_Non_Alpha.Mapper (Value)));
   end Quote;

   -------------------------------------------------------------------
   function Quote (
      Value                : in   String
   ) return String is
   -------------------------------------------------------------------

   begin
      return "'" & Ada_Lib.Substiture_For_Non_Alpha.Substitute (Value) & "'";
   end Quote;

   -------------------------------------------------------------------
   function Quote (
      Value                : in   Ada.Strings.Unbounded.Unbounded_String
   ) return String is
   -------------------------------------------------------------------

   begin
      return Quote (Ada.Strings.Unbounded.To_String (Value));
   end Quote;

   -------------------------------------------------------------------
   function Quote (
      Variable             : in   String;
      Value                : in   Character
   ) return String is
   -------------------------------------------------------------------

   begin
      return Variable & ": " & Quote (Value);
   end Quote;

   -------------------------------------------------------------------
   function Quote (
      Variable             : in   String;
      Value                : in   String
   ) return String is
   -------------------------------------------------------------------

   begin
      return Variable & ": " & Quote (Value);
   end Quote;

   -------------------------------------------------------------------
   function Quote (
      Variable             : in   String;
      Value                : access constant String
   ) return String is
   -------------------------------------------------------------------

   begin
      return Quote (Variable, (if Value = Null then
            "null pointer"
         else
            Value.all));
   end Quote;

   -------------------------------------------------------------------
   function Quote (
      Variable             : in   String;
      Value                : in   Ada.Strings.Unbounded.Unbounded_String
   ) return String is
   -------------------------------------------------------------------

   begin
      return Quote (Variable, Ada.Strings.Unbounded.To_String (Value));
   end Quote;


end Ada_Lib.String_Quote;
