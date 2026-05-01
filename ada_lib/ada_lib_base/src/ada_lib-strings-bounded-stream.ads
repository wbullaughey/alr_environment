with Ada.Streams;

package Ada_Lib.Strings.Bounded.Stream is

   type Streamable_Type (
      Bound             : Natural) is new Bounded_Type (Bound) with null record;

   overriding
   function Bounded (
      Contents          : in   String;
      Limit             : in   Natural := 0  -- 0 defaults to exact length
   ) return Streamable_Type;

   procedure Read (
      Stream               : access Ada.Streams.Root_Stream_Type'class;
      String               :   out Streamable_Type);

   for Streamable_Type'Read use Read;

   procedure Write (
      Stream               : access Ada.Streams.Root_Stream_Type'class;
      String               : in   Streamable_Type);

   for Streamable_Type'Write use Write;

   overriding
   function "&" (
      Original          : in   Streamable_Type;
      Appended          : in   String
   ) return Streamable_Type;

   -- raises the Too_Long Maximum_Bound_Exceeded and Corrupt exceptions
   overriding
   function "&" (
      Original          : in   Streamable_Type;
      Appended          : in   Character
   ) return Streamable_Type;

   overriding
   function "&" (
      Original          : in   String;
      Appended          : in   Streamable_Type
   ) return Streamable_Type;

   overriding
   function "&" (
      Original          : in   Streamable_Type;
      Appended          : in   Streamable_Type
   ) return Streamable_Type;

end Ada_Lib.Strings.Bounded.Stream;
