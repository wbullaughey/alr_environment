--
--  $Id$
--

with Ada.Text_Io;
with Ada.Float_Text_Io;
with Ada.Integer_Text_Io;
with Ada.Strings.Fixed;

package body Ada_Lib.Strings.Varying is

   -----------------------
   -- To_Varying_String --
   -----------------------

   function To_Varying_String (S : String) return Varying_String_Type
   is
   begin
      --  Note: we set Maximum_Length and Current_Length to S'Length
      return Varying_String_Type'
        (Maximum_Length | Current_Length        => S'Length,
         Contents                               => S);
   end To_Varying_String;

   ---------------
   -- To_String --
   ---------------

   function To_String (V : Varying_String_Type) return String
   is
   begin
      return V.Contents (1 .. V.Current_Length);
   end To_String;

   ------------
   -- Length --
   ------------

   function Length (V : Varying_String_Type) return Natural
   is
   begin
      return V.Current_Length;
   end Length;

   -------
   -- & --
   -------

   function "&"
     (Left, Right : Varying_String_Type) return Varying_String_Type
   is
      Left_Length       : Natural renames Left.Current_Length;
      Right_Length      : Natural renames Right.Current_Length;
      Result_Length     : constant Natural := Left_Length + Right_Length;
      Result            : Varying_String_Type (Result_Length);
   begin
      Result.Contents (1 .. Left_Length) :=
        Left.Contents (1 .. Left_Length);

      Result.Contents (Left_Length + 1 .. Result_Length) :=
        Right.Contents (1 .. Right_Length);

      Result.Current_Length := Result_Length;
      return Result;
   end "&";

   -------
   -- = --
   -------

   overriding
   function "=" (Left, Right : Varying_String_Type) return Boolean
   is
   begin
      return
        Left.Contents (1 .. Left.Current_Length) =
        Right.Contents (1 .. Right.Current_Length);
   end "=";

   -----------
   -- Slice --
   -----------

   function Slice
     (Full_String       : in Varying_String_Type;
      Lower_Bound       : in Positive;
      Upper_Bound       : in Natural)
     return Varying_String_Type
   is
      Result_Length     : Positive;
   begin
      if Upper_Bound < Lower_Bound then
         return Varying_String_Type'
           (Maximum_Length              => 0,
            Current_length              => 0,
            Contents                    => "");
      elsif Lower_Bound not in Full_String.Contents'Range or else
        Upper_Bound not in Full_String.Contents'Range then
         raise Index_Error;
      else
         Result_Length := Upper_Bound - Lower_Bound + 1;
         return Varying_String_Type'
           (Maximum_Length | Current_Length     => Result_Length,
            Contents                            =>
              Full_String.Contents (Lower_Bound .. Upper_Bound));
         -- Result "slides" into positions 1 .. Result_Length
      end if;
   end Slice;

   --------------
   -- Get_Line --
   --------------

   procedure Get_Line (Item : out Varying_String_Type)
   is
   begin
      Ada.Text_IO.Get_Line
        (Item.Contents, Item.Current_Length);
   end Get_Line;


   ---------
   -- Put --
   ---------

   procedure Put (Item : in Varying_String_Type)
   is
   begin
      Ada.Text_IO.Put
        (Item.Contents (1 .. Item.Current_Length));
   end Put;

   ----------
   -- Copy --
   ----------

   procedure Copy
     (From              : in Varying_String_Type;
      To                : out Varying_String_Type)
   is
   begin
      if From.Current_Length > To.Maximum_Length then
         -- Trucate excess characters
         To.Contents :=
           From.Contents (1 .. To.Maximum_Length);
         To.Current_Length := To.Maximum_Length;
      else
         To.Contents (1 .. From.Current_Length) :=
           From.Contents (1 .. From.Current_Length);
         To.Current_Length := From.Current_Length;
      end if;
   end Copy;

   ---------
   -- Set --
   ---------

   procedure Set
     (Destination       : out Varying_String_Type;
      Source            : in String)
   is
   begin
      Copy (Source, Destination);
   end Set;


   ----------
   -- Copy --
   ----------

   procedure Copy
     (From              : in String;
      To                : out Varying_String_Type)
   is
   begin
       if From'Length > To.Maximum_Length then
      -- Trucate excess characters
      To.Contents :=
        From (From'First .. From'First + To.Maximum_Length - 1);
      To.Current_Length := To.Maximum_Length;
       else
      To.Contents (1 .. From'Length) := From;
      To.Current_Length := From'Length;
       end if;
   end Copy;

   ------------
   -- Append --
   ------------

   procedure Append
     (Source            : in out Varying_String_Type;
      New_Item          : in String)
   is
       Source_Length     : constant Natural := Source.Current_Length;
   begin
       if (Source_Length + New_Item'Length) > Source.Maximum_Length then
           -- No room to append
           raise Length_Error;
       elsif New_Item'Length = 0 then
           -- Empty append, nothing to do
           null;
       else
           pragma Assert (Source.Maximum_Length > 0);
           Source.Contents
             (Source_Length + 1 .. Source_Length + New_Item'Length) :=
             New_Item;
           Source.Current_Length := Source.Current_Length + New_Item'Length;
       end if;
   end Append;


   ------------
   -- Append --
   ------------

   procedure Append
     (Source            : in out Varying_String_Type;
      New_Item          : in Varying_String_Type)
   is
   begin
      Append (Source, New_Item.Contents (1 .. New_Item.Current_Length));
   end Append;


   ------------
   -- Append --
   ------------

   procedure Append
     (Source            : in out Varying_String_Type;
      New_Item          : in Character)
   is
   begin
       if Source.Current_Length < Source.Maximum_Length then
      Source.Contents (Source.Current_Length + 1) := New_Item;
           Source.Current_Length := Source.Current_Length + 1;
       else
           raise Length_Error;
       end if;
   end Append;


   ------------
   -- Append --
   ------------

   procedure Append
     (Source      : in out Varying_String_Type;
      Item     : in Integer)
   is
       Buffer     : String (1 .. 15);
   begin
       Ada.Integer_Text_Io.Put (Buffer, Item);
       Append (Source,
          Ada.Strings.Fixed.Trim (Buffer, Ada.Strings.Both));
   end Append;


   ------------
   -- Append --
   ------------

   procedure Append
     (Source      : in out Varying_String_Type;
      Item     : in Float;
      Aft      : in Natural := 2;
      Exp      : in Natural := 0)
   is
       Buffer           : String (1 .. 15);
   begin
       Ada.Float_Text_Io.Put (Buffer, Item, Aft => Aft, Exp => Exp);
       Append (Source,
          Ada.Strings.Fixed.Trim (Buffer, Ada.Strings.Both));
   end Append;


end Ada_Lib.Strings.Varying;
