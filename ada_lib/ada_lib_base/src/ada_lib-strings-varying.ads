--
--  $Id$
--
--  This is an implementation of strings with varying lengths.
--  The implementation is based off the one given in "Ada as a
--  second language", 11.8.1.

package Ada_Lib.Strings.Varying is

   Index_Error          : exception;
   Length_Error         : exception;

   type Varying_String_Type (Maximum_Length : Natural) is
      limited private;

   Null_Varying_String  : constant Varying_String_Type;

   function To_Varying_String (S : String) return Varying_String_Type;
   --  Convert the given string into a varying string.  The maximum
   --  bound for the string will be set to S'Length.

   function To_String (V : Varying_String_Type) return String;
   --  Convert a varying string into a String.

   function Length (V : Varying_String_Type) return Natural;
   --  Return the current length of a varying string.

   function "&"
     (Left, Right : Varying_String_Type) return Varying_String_Type;
   --  Concatenate Left and Right and return the result.

   function "=" (Left, Right : Varying_String_Type) return Boolean;
   --  Return True if the contents of Left and Right are equal.

   function Slice
     (Full_String       : in Varying_String_Type;
      Lower_Bound       : in Positive;
      Upper_Bound       : in Natural)
     return Varying_String_Type;
   --  Return Full_String (Lower_Bound .. Upper_Bound)
   --  Raises Index_Error

   procedure Get_Line (Item : out Varying_String_Type);
   --  Read a line into a varying string.

   procedure Put (Item : in Varying_String_Type);
   --  Display the varying string to stdout

   procedure Copy
     (From              : in Varying_String_Type;
      To                : out Varying_String_Type);
   --  Copy From -> To.  The bounds of these strings need not
   --  be the same.  If the length of From > length of To, then
   --  we truncate from the right.

   procedure Copy
     (From              : in String;
      To                : out Varying_String_Type);
   --  Copy From -> To. See Copy above.  Note that this can
   --  be used to zero a string by doing Copy ("", V).


   procedure Set
     (Destination       : out Varying_String_Type;
      Source            : in String);
   --  Copy with the arguments reversed.

   procedure Append
     (Source            : in out Varying_String_Type;
      New_Item          : in String);
   --  Append a given string to the end of Source
   --  Raises Length_Error

   procedure Append
     (Source            : in out Varying_String_Type;
      New_Item          : in Varying_String_Type);
   --  Append a given string to the end of Source
   --  Raises Length_Error

   procedure Append
     (Source            : in out Varying_String_Type;
      New_Item          : in Character);
   --  Append a given character to the end of Source
   --  Raises Length_Error

   procedure Append
     (Source      : in out Varying_String_Type;
      Item     : in Integer);
   --  Append given integer to the end of Source
   --  Raises Length_Error
   --  Will not put leading space

   procedure Append
     (Source      : in out Varying_String_Type;
      Item     : in Float;
      Aft      : in Natural := 2;
      Exp      : in Natural := 0);
   --  Append given floating point value to end of Source
   --  Raises Length_Error

private

   type Varying_String_Type (Maximum_Length : Natural) is record
      Current_Length    : Natural := 0;
      Contents          : String (1 .. Maximum_Length);
   end record;

   Null_Varying_String  : constant Varying_String_Type :=
     (Maximum_Length => 0, Current_Length => 0, Contents => "");

end Ada_Lib.Strings.Varying;
