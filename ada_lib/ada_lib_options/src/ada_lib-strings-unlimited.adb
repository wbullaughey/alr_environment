--with GNAT.Source_Info;
--with Ada.Text_IO; use  Ada.Text_IO;

package body Ada_Lib.Strings.Unlimited is

   use Ada.Strings.Unbounded;

   ---------------------------------------------------------------
   function "&"  (
      Left, Right                : in     String_Type
   ) return String_Type is
   ---------------------------------------------------------------

   begin
      return String_Type'(Contents => Left.Contents & Right.Contents);
   end "&";

   ---------------------------------------------------------------
   function "&"  (
      Left                       : in     String_Type;
      Right                      : in     String
   ) return String_Type is
   ---------------------------------------------------------------

   begin
      return String_Type'(Contents => Left.Contents & Right);
   end "&";

   ---------------------------------------------------------------
   function "&"  (
      Left                       : in     String_Type;
      Right                      : in     Character
   ) return String_Type is
   ---------------------------------------------------------------

   begin
      return String_Type'(Contents => Left.Contents & Right);
   end "&";

   ---------------------------------------------------------------
   overriding
   function "="  (
      Left, Right                : in     String_Type
   ) return Boolean is
   ---------------------------------------------------------------

   begin
      return Left.Contents = Right.Contents;
   end "=";

   ---------------------------------------------------------------
   function "="  (
      Left                       : in     String_Type;
      Right                      : in     String
   ) return Boolean is
   ---------------------------------------------------------------

   begin
      return To_String (Left.Contents) = Right;
   end "=";

   ---------------------------------------------------------------
   procedure Append (
      Source                     : in out String_Type;
      New_Item                   : in     String_Type) is
   ---------------------------------------------------------------

   begin
      Append (Source.Contents, New_Item.Contents);
   end Append;

   ---------------------------------------------------------------
   procedure Append (
      Source                     : in out String_Type;
      New_Item                   : in String) is
   ---------------------------------------------------------------

   begin
      Append (Source.Contents, New_Item);
   end Append;

   procedure Append (
      Source                     : in out String_Type;
      New_Item                   : in Character) is
   ---------------------------------------------------------------

   begin
      Append (Source.Contents, New_Item);
   end Append;

   ---------------------------------------------------------------
   function Coerce (
      Source                     : in     String
   ) return String_Type is
   ---------------------------------------------------------------

   begin
      return String_Type'(Contents => To_Unbounded_String (Source));
   end Coerce;

   ---------------------------------------------------------------
   function Coerce (
      Source                     : in     String_Type
   ) return String is
   ---------------------------------------------------------------

   begin
      return To_String (Source.Contents);
   end Coerce;

   ---------------------------------------------------------------
   procedure Construct (
      Target                     :    out String_Type;
      Source                     : in     String) is
   ---------------------------------------------------------------

   begin
      Target.Contents := To_Unbounded_String (Source);
   end Construct;

   ---------------------------------------------------------------
   function Construct (
      Source                     : in     String;
      Append                     : in     String_Type
   ) return String is
   ---------------------------------------------------------------

   begin
      return Coerce (Coerce (Source) & Append);
   end Construct;

   ---------------------------------------------------------------
   function Delete (
      Source                     : in     String_Type;
      From                       : in     Positive;
      Through                    : in     Natural
   ) return String_Type is
   ---------------------------------------------------------------

   begin
      return String_Type'(Contents => Delete (Source.Contents, From, Through));
   end Delete;

   ---------------------------------------------------------------
   procedure Delete (
      Source                     : in out String_Type;
      From                       : in     Positive;
      Through                    : in     Natural) is
   ---------------------------------------------------------------

   begin
      Delete (Source.Contents, From, Through);
   end Delete;

   ---------------------------------------------------------------
   function Element (
      Source                     : in     String_Type;
      Index                      : in     Positive
   ) return Character is
   ---------------------------------------------------------------

   begin
      return Element (Source.Contents, Index);
   end Element;

   ---------------------------------------------------------------
   procedure Find_Token (
      Source                     : in     String_Type;
      Set                        : in     Ada.Strings.Maps.Character_Set;
      Test                       : in     Membership;
      First                      :    out Positive;
      Last                       :    out Natural) is
   ---------------------------------------------------------------

   begin
      Ada.Strings.Unbounded.Find_Token (Source.Contents, Set, Test, First, Last);
   end Find_Token;

   ---------------------------------------------------------------
   function Index (
      Source                     : in     String_Type;
      Pattern                    : in     String;
      From                       : in     Positive;
      Going                      : in     Direction := Forward;
      Mapping                    : in     Ada.Strings.Maps.Character_Mapping :=
                                             Ada.Strings.Maps.Identity
   ) return Natural is
   ---------------------------------------------------------------

   begin
      return Ada.Strings.Unbounded.Index (Source.Contents, Pattern, From,
         Going, Mapping);
   end Index;

   ---------------------------------------------------------------
   function Index (
      Source                     : in     String_Type;
      Pattern                    : in     String;
      Going                      : in     Direction := Forward;
      Mapping                    : in     Ada.Strings.Maps.Character_Mapping :=
                                             Ada.Strings.Maps.Identity
   ) return Natural is
   ---------------------------------------------------------------

   begin
      return Ada.Strings.Unbounded.Index (Source.Contents, Pattern, Going, Mapping);
   end Index;

   ---------------------------------------------------------------
   function Insert (
      Source                     : in     String_Type;
      Before                     : in Positive;
      New_Item                   : in String
   ) return String_Type is
   ---------------------------------------------------------------

   begin
      return String_Type'(Contents => Insert (Source.Contents, Before, New_Item));
   end Insert;

   ---------------------------------------------------------------
   procedure Insert (
      Source                     : in out String_Type;
      Before                     : in Positive;
      New_Item                   : in String) is
   ---------------------------------------------------------------

   begin
      Ada.Strings.Unbounded.Insert (Source.Contents, Before, New_Item);
   end Insert;

   ---------------------------------------------------------------
   function Length (
      Source                     : in     String_Type
   ) return Natural is
   ---------------------------------------------------------------

   begin
      return Length (Source.Contents);
   end Length;

   ---------------------------------------------------------------
   function Quote (
      Variable             : in   String;
      Value                : in   String_Type
   ) return String is
   ---------------------------------------------------------------

   begin
      return Variable & " '" & Coerce (Value) & "'";
   end Quote;

   ---------------------------------------------------------------
   function Quote (
      Source                     : in     String_Type;
      Substiture_For_Non_Alpha   : in     Boolean := False;
      Quote                      : in     Character := '"'
   ) return String_Type is
   ---------------------------------------------------------------

   begin
      return Coerce ("'") & Source & "'";
   end Quote;

   ---------------------------------------------------------------
   function Quote (
      Label                      : in     String;
      Source                     : in     String_Type;
      Substiture_For_Non_Alpha   : in     Boolean := False;
      Quote                      : in     Character := '"'
   ) return String_Type is
   ---------------------------------------------------------------

   begin
      return Coerce (Label) & " '" & Source & "'";
   end Quote;

   ---------------------------------------------------------------
   procedure Set (
      Target                     :    out String_Type;
      Source                     : in     String) is
   ---------------------------------------------------------------

   begin
      Set_Unbounded_String (Target.Contents, Source);
   end Set;

   ---------------------------------------------------------------
   function Slice (
      Source                     : in     String_Type;
      Low                        : in     Positive;
      High                       : in     Natural
   ) return String is
   ---------------------------------------------------------------

   begin
      return Slice (Source.Contents, Low, High);
   end Slice;

   ---------------------------------------------------------------
   function Tail (
      Source                     : in     String_Type;
      Count                      : in     Natural;
      Pad                        : in     Character := ' '
   ) return String is
   ---------------------------------------------------------------

   begin
      return To_String (Tail (Source.Contents, Count, Pad));
   end Tail;

   ---------------------------------------------------------------
   function Tail (
      Source                     : in     String_Type;
      Count                      : in     Natural;
      Pad                        : in     Character := ' '
   ) return String_Type is
   ---------------------------------------------------------------

   begin
      return String_Type'(Contents => Ada.Strings.Unbounded.Tail (Source.Contents, Count, Pad));
   end Tail;

   ---------------------------------------------------------------
   function Translate (
      Source                     : in     String_Type;
      Mapping                    : in     Ada.Strings.Maps.Character_Mapping
   ) return String is
   ---------------------------------------------------------------

   begin
      return Ada.Strings.Fixed.Translate (Source.Coerce, Mapping);
   end Translate;

   ---------------------------------------------------------------
   procedure Translate (
      Source                     : in out String_Type;
      Mapping                    : in     Ada.Strings.Maps.Character_Mapping) is
   ---------------------------------------------------------------

      Translated                 : String := Source.Coerce;

   begin
      Ada.Strings.Fixed.Translate (Translated, Mapping);
      Set (Source, Translated);
   end Translate;

   ---------------------------------------------------------------
   function Translate (
      Source                     : in     String_Type;
      Mapping                    : in     Ada.Strings.Maps.Character_Mapping_Function
   ) return String is
   ---------------------------------------------------------------

   begin
      return Ada.Strings.Fixed.Translate (Source.Coerce, Mapping);
   end Translate;

   ---------------------------------------------------------------
   procedure Translate (
      Source                     : in out String_Type;
      Mapping                    : in     Ada.Strings.Maps.Character_Mapping_Function) is
   ---------------------------------------------------------------

      Translated                 : String := Source.Coerce;

   begin
      Ada.Strings.Fixed.Translate (Translated, Mapping);
      Set (Source, Translated);
   end Translate;

   ---------------------------------------------------------------
   function Trim (
      Source                     : in     String_Type;
      Side                       : in Trim_End
   ) return String_Type is
   ---------------------------------------------------------------

   begin
      return String_Type'(Contents => Ada.Strings.Unbounded.Trim (Source.Contents, Side));
   end Trim;

   ---------------------------------------------------------------
   procedure Trim (
      Source                     : in out String_Type;
      Side                       : in     Trim_End) is
   ---------------------------------------------------------------

   begin
      Ada.Strings.Unbounded.Trim (Source.Contents, Side);
   end Trim;

end Ada_Lib.Strings.Unlimited;
