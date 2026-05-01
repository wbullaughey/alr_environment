with Ada.Strings.Maps;
with Ada.Strings.Unbounded;

package Ada_Lib.Strings.Unlimited is

   type String_Type is tagged private;

   subtype Direction is Ada.Strings.Direction;

   Forward                       : constant Direction := Ada.Strings.Forward;
   Backward                      : constant Direction := Ada.Strings.Backward;

   subtype Membership is Ada.Strings.Membership;

   Inside                        : constant Membership := Ada.Strings.Inside;
   Outside                       : constant Membership := Ada.Strings.Outside;

   subtype Trim_End   is Ada.Strings.Trim_End;

   Left                          : constant Trim_End := Ada.Strings.Left;
   Right                         : constant Trim_End := Ada.Strings.Right;
   Both                          : constant Trim_End := Ada.Strings.Both;
   Null_String                   : constant String_Type;

   overriding
   function "="  (
      Left, Right                : in     String_Type
   ) return Boolean;

   function "="  (
      Left                       : in     String_Type;
      Right                      : in     String
   ) return Boolean;

   function "&"  (
      Left, Right                : in     String_Type
   ) return String_Type;

   function "&"  (
      Left                       : in     String_Type;
      Right                      : in     String
   ) return String_Type;

   function "&"  (
      Left                       : in     String_Type;
      Right                      : in     Character
   ) return String_Type;

   procedure Append (
      Source                     : in out String_Type;
      New_Item                   : in     String_Type);

   procedure Append (
      Source                     : in out String_Type;
      New_Item                   : in String);

   procedure Append (
      Source                     : in out String_Type;
      New_Item                   : in Character);

   function Coerce (
      Source                     : in     String
   ) return String_Type;

   function Coerce (
      Source                     : in     String_Type
   ) return String;

   procedure Construct (
      Target                     :    out String_Type;
      Source                     : in     String);

   function Construct (
      Source                     : in     String;
      Append                     : in     String_Type
   ) return String;

   function Delete (
      Source                     : in     String_Type;
      From                       : in     Positive;
      Through                    : in     Natural
   ) return String_Type;

   procedure Delete (
      Source                     : in out String_Type;
      From                       : in     Positive;
      Through                    : in     Natural);

   function Element (
      Source                     : in     String_Type;
      Index                      : in     Positive
   ) return Character;

   procedure Find_Token (
      Source                     : in     String_Type;
      Set                        : in     Ada.Strings.Maps.Character_Set;
      Test                       : in     Membership;
      First                      :    out Positive;
      Last                       :    out Natural);

   function Index (
      Source                     : in     String_Type;
      Pattern                    : in     String;
      From                       : in     Positive;
      Going                      : in     Direction := Forward;
      Mapping                    : in     Ada.Strings.Maps.Character_Mapping :=
                                             Ada.Strings.Maps.Identity
   ) return Natural;

   function Index (
      Source                     : in     String_Type;
      Pattern                    : in     String;
      Going                      : in     Direction := Forward;
      Mapping                    : in     Ada.Strings.Maps.Character_Mapping :=
                                             Ada.Strings.Maps.Identity
   ) return Natural;

   function Insert (
      Source                     : in     String_Type;
      Before                     : in Positive;
      New_Item                   : in String
   ) return String_Type;

   procedure Insert (
      Source                     : in out String_Type;
      Before                     : in Positive;
      New_Item                   : in String);

   function Length (
      Source                     : in     String_Type
   ) return Natural;

   function Quote (
      Variable             : in   String;
      Value                : in   String_Type
   ) return String;

   function Quote (
      Source                     : in     String_Type;
      Substiture_For_Non_Alpha   : in     Boolean := False;
      Quote                      : in     Character := '"'
   ) return String_Type;

   function Quote (
      Label                      : in     String;
      Source                     : in     String_Type;
      Substiture_For_Non_Alpha   : in     Boolean := False;
      Quote                      : in     Character := '"'
   ) return String_Type;

   procedure Set (
      Target                     :    out String_Type;
      Source                     : in     String);

   function Slice (
      Source                     : in     String_Type;
      Low                        : in     Positive;
      High                       : in     Natural
   ) return String;

   function Tail (
      Source                     : in     String_Type;
      Count                      : in     Natural;
      Pad                        : in     Character := ' '
   ) return String;

   function Tail (
      Source                     : in     String_Type;
      Count                      : in     Natural;
      Pad                        : in     Character := ' '
   ) return String_Type;

   function Translate (
      Source                     : in     String_Type;
      Mapping                    : in     Ada.Strings.Maps.Character_Mapping
   ) return String;

   procedure Translate (
      Source                     : in out String_Type;
      Mapping                    : in     Ada.Strings.Maps.Character_Mapping);

   function Translate (
      Source                     : in     String_Type;
      Mapping                    : in     Ada.Strings.Maps.Character_Mapping_Function
   ) return String;

   procedure Translate (
      Source                     : in out String_Type;
      Mapping                    : in     Ada.Strings.Maps.Character_Mapping_Function);

   function Trim (
      Source                     : in     String_Type;
      Side                       : in Trim_End
   ) return String_Type;

   procedure Trim (
      Source                     : in out String_Type;
      Side                       : in     Trim_End);

private

   type String_Type is tagged record
      Contents                   : Ada.Strings.Unbounded.Unbounded_String;
   end record;

   Null_String                   : constant String_Type :=
                                    String_Type'(Contents =>
                                       Ada.Strings.Unbounded.Null_Unbounded_String);

end Ada_Lib.Strings.Unlimited;
