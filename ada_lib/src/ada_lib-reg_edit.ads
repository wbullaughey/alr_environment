with GNAT.Regpat;

-- utility to apply a regular expression to a string resulting in a transformation
package Ada_Lib.Reg_Edit is

   Error                      : exception;

   subtype Flags_Type         is GNAT.Regpat.Regexp_Flags;
   subtype Match_Location     is GNAT.Regpat.Match_Location;
   subtype Program_Size       is GNAT.Regpat.Program_Size;

   Case_Insensitive           : Flags_Type renames GNAT.Regpat.Case_Insensitive;
   Ada_Lib_LIB_Debug                      : aliased Boolean := False;
   Multiple_Lines             : Flags_Type renames GNAT.Regpat.Multiple_Lines;
   No_Flags                   : Flags_Type renames GNAT.Regpat.No_Flags;
   No_Match                   : Match_Location renames GNAT.Regpat.No_Match;
   Single_Line                : Flags_Type renames GNAT.Regpat.Single_Line;

   type Match_Class (
      Expression_Length       : Positive;
      Size                    : Program_Size) is tagged private;

   type Match_Access          is access Match_Class;
   type Match_Class_Access    is access Match_Class'class;

   procedure Dump (
      Match                   : in     Match_Class;
      Add_New_Line            : in     Boolean := True);

   function Get_Expression (
      Object                  : in     Match_Class
   ) return String;

   procedure Free (
      Match                   : in out Match_Class_Access);

   function Initialize (
      Expression              : in     String;
      Flags                   : in     Flags_Type := No_Flags
   ) return Match_Class
   with
      Pre => Expression'length > 0;

   function Initialize (
      Expression              : in     String;
      Flags                   : in     Flags_Type := No_Flags
   ) return Match_Class_Access
   with
      Pre => Expression'length > 0;

   function Match (
      Object                  : in     Match_Class;
      Data                    : in     String
   ) return Boolean;

   function Replace (
      Object                  : in     Match_Class;
      Data                    : in     String;
      Recipe                  : in     String
   ) return String;

   type Replace_Class (
      Expression_Length       : Positive;
      Recipe_Length           : Positive;
      Size                    : Program_Size) is new Match_Class with private;

   type Replace_Access          is access Replace_Class;
   type Replace_Class_Access     is access Replace_Class'class;

   overriding
   procedure Dump (
      Replace                 : in     Replace_Class;
      Add_New_Line            : in     Boolean := True);

   procedure Free (
      Replace                 : in out Replace_Class_Access);

   function Get_Recipe (
      Object                  : in     Replace_Class
   ) return String;

   overriding
   function Initialize (               -- throws error exception (initialization with no Recipe
      Expression              : in     String;
      Flags                   : in     Flags_Type := No_Flags
   ) return Replace_Class
   with
      Pre => Expression'length > 0;

   function Initialize (
      Expression              : in     String;
      Recipe                  : in     String;
      Flags                   : in     Flags_Type := No_Flags
   ) return Replace_Class
   with
      Pre => Expression'length > 0;

   function Initialize (
      Expression              : in     String;
      Recipe                  : in     String;
      Flags                   : in     Flags_Type := No_Flags
   ) return Replace_Class_Access
   with
      Pre => Expression'length > 0;

   function Replace (
      Object                  : in     Replace_Class;
      Data                    : in     String
   ) return String;

private

   subtype Matcher_Type       is GNAT.Regpat.Pattern_Matcher;
   type Matcher_Access        is access GNAT.Regpat.Pattern_Matcher;

   type Match_Class (
      Expression_Length       : Positive;
      Size                    : Program_Size) is tagged record
      Expression              : String (1 .. Expression_Length);
      Matcher                 : Matcher_Type (Size);
   end record;

   type Replace_Class (
      Expression_Length       : Positive;
      Recipe_Length           : Positive;
      Size                    : Program_Size) is new Match_Class (
         Expression_Length, Size) with record
      Recipe                  : String (1 .. Recipe_Length);
   end record;

end Ada_Lib.Reg_Edit;

