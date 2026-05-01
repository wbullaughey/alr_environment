with Ada.Unchecked_Deallocation;
with GNAT.Regpat;

package Ada_Lib.Strings.Reg_Edit is

   Error                      : exception;

   subtype Flags_Type         is GNAT.Regpat.Regexp_Flags;
   subtype Matcher_Type       is GNAT.Regpat.Pattern_Matcher;
   type Matcher_Access        is access GNAT.Regpat.Pattern_Matcher;
   subtype Match_Location     is GNAT.Regpat.Match_Location;

   Case_Insensitive           : Flags_Type renames GNAT.Regpat.Case_Insensitive;
   Ada_Lib_LIB_Debug                      : aliased Boolean := False;
   Multiple_Lines             : Flags_Type renames GNAT.Regpat.Multiple_Lines;
   No_Flags                   : Flags_Type renames GNAT.Regpat.No_Flags;
   No_Match                   : Match_Location renames GNAT.Regpat.No_Match;
   Single_Line                : Flags_Type renames GNAT.Regpat.Single_Line;

   function Compile (
      Expression              : in     String;
      Flags                   : in     Flags_Type := No_Flags
   ) return Matcher_Type renames GNAT.Regpat.Compile;

   function Compile (
      Expression              : in     String;
      Flags                   : in     Flags_Type := No_Flags
   ) return Matcher_Access;

   procedure Free is new Ada.Unchecked_Deallocation (
      Matcher_Type, Matcher_Access);

   function Match (
      Matcher                 : in     Matcher_Type;
      Data                    : in     String;
      Start                   : in     Integer  := -1;
      Last                    : Positive := Positive'Last
   ) return Boolean renames GNAT.Regpat.Match;

   function Replace (
      Matcher                 : in     Matcher_Type;
      Source                  : in     String;
      Target                  : in     String
   ) return String;

end Ada_Lib.Strings.Reg_Edit;
