package body Ada_Lib.Strings.Bounded.Stream is

   -------------------------------------------------------------------
   overriding
   function Bounded (
      Contents          : in   String;
      Limit             : in   Natural := 0
   ) return Streamable_Type is
   -------------------------------------------------------------------

      Bounded              : constant Bounded_Type :=
                           Ada_Lib.Strings.Bounded.Bounded (Contents, Limit);

   begin
      return Streamable_Type'(Bounded with Bound => Bounded.Bound);
   end Bounded;

   -------------------------------------------------------------------
   procedure Read (
      Stream               : access Ada.Streams.Root_Stream_Type'class;
      String               :   out Streamable_Type) is
   -------------------------------------------------------------------

   begin
      Natural'Read (Stream, String.Length);
      Standard.String'Read (Stream, String.Contents (1 .. String.Length));
   end Read;

   -------------------------------------------------------------------
   procedure Write (
      Stream               : access Ada.Streams.Root_Stream_Type'class;
      String               : in   Streamable_Type) is
   -------------------------------------------------------------------

   begin
      Natural'Write (Stream, String.Length);
      Standard.String'Write (Stream, String.Contents (1 .. String.Length));
   end Write;

   -------------------------------------------------------------------
   overriding
   function "&" (
      Original          : in   Streamable_Type;
      Appended          : in   String
   ) return Streamable_Type is
   -------------------------------------------------------------------

      Bounded              : constant Bounded_Type :=
                           Ada_Lib.Strings.Bounded."&" (Bounded_Type (Original), Appended);

   begin
      return Streamable_Type'(Bounded with Bound => Bounded.Bound);
   end "&";

   -------------------------------------------------------------------
   overriding
   function "&" (
      Original          : in   Streamable_Type;
      Appended          : in   Character
   ) return Streamable_Type is
   -------------------------------------------------------------------

      Bounded              : constant Bounded_Type :=
                           Ada_Lib.Strings.Bounded."&" (Bounded_Type (Original), Appended);

   begin
      return Streamable_Type'(Bounded with Bound => Bounded.Bound);
   end "&";

   -------------------------------------------------------------------
   overriding
   function "&" (
      Original          : in   String;
      Appended          : in   Streamable_Type
   ) return Streamable_Type is
   -------------------------------------------------------------------

      Bounded              : constant Bounded_Type :=
                           Ada_Lib.Strings.Bounded."&" (Original, Bounded_Type (Appended));

   begin
      return Streamable_Type'(Bounded with Bound => Bounded.Bound);
    end "&";

   -------------------------------------------------------------------
   overriding
   function "&" (
      Original          : in   Streamable_Type;
      Appended          : in   Streamable_Type
   ) return Streamable_Type is
   -------------------------------------------------------------------

      Bounded              : constant Bounded_Type :=
                           Ada_Lib.Strings.Bounded."&" (Bounded_Type (Original),
                                        Bounded_Type (Appended));

   begin
      return Streamable_Type'(Bounded with Bound => Bounded.Bound);
    end "&";

end Ada_Lib.Strings.Bounded.Stream;
