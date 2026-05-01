with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;

package body Ada_Lib.Template.Token is

   ----------------------------------------------------------------------
   overriding
   function Create (
      Token             : in   End_Of_File_Token_Type
   ) return Ada_Lib.Template.Parameters.Construct_Class_Access is
   ----------------------------------------------------------------------

   begin
      pragma Assert (False);
      pragma Unreferenced (Token);
      return Null;
   end Create;

   ----------------------------------------------------------------------
   overriding
   function Create (
      Token             : in   End_Of_File_Token_Type
   ) return Ada_Lib.Template.Parameters.Expression_Class_Access is
   ----------------------------------------------------------------------

   begin
      pragma Assert (False);
      pragma Unreferenced (Token);
      return Null;
   end Create;

   ----------------------------------------------------------------------
   overriding
   function Create (
      Token             : in   Null_Token_Type
   ) return Ada_Lib.Template.Parameters.Construct_Class_Access is
   ----------------------------------------------------------------------

   begin
      pragma Assert (False);
      pragma Unreferenced (Token);
      return Null;
   end Create;

   ----------------------------------------------------------------------
   overriding
   function Create (
      Token             : in   Null_Token_Type
   ) return Ada_Lib.Template.Parameters.Expression_Class_Access is
   ----------------------------------------------------------------------

   begin
      pragma Assert (False);
      pragma Unreferenced (Token);
      return Null;
   end Create;

   ----------------------------------------------------------------------
   overriding
   function Create (
      Token             : in   Operator_Token_Type
   ) return Ada_Lib.Template.Parameters.Construct_Class_Access is
   ----------------------------------------------------------------------

   begin
      pragma Assert (False);
      pragma Unreferenced (Token);
      return Null;
   end Create;

   ----------------------------------------------------------------------
   overriding
   function Create (
      Token             : in   Operator_Token_Type
   ) return Ada_Lib.Template.Parameters.Expression_Class_Access is
   ----------------------------------------------------------------------

   begin
      pragma Assert (False);
      pragma Unreferenced (Token);
      return Null;
   end Create;

   ----------------------------------------------------------------------
   overriding
   function Create (
      Token             : in   String_Token_Type
   ) return Ada_Lib.Template.Parameters.Construct_Class_Access is
   ----------------------------------------------------------------------

   begin
      return Ada_Lib.Template.Parameters.Construct_Class_Access'(
         new Ada_Lib.Template.Parameters.Text_Type'(
            Contents => Token.Contents));
   end Create;

   ----------------------------------------------------------------------
   overriding
   function Create (
      String               : in   String_Token_Type
   ) return Ada_Lib.Template.Parameters.Expression_Class_Access is
   ----------------------------------------------------------------------

   begin
      return new Ada_Lib.Template.Parameters.Text_Type'(
         Contents => String.Contents);
   end Create;

   ----------------------------------------------------------------------
   overriding
   function Create (
      Token             : in   Terminal_Token_Type
   ) return Ada_Lib.Template.Parameters.Construct_Class_Access is
   ----------------------------------------------------------------------

   begin
      pragma Assert (False);
      pragma Unreferenced (Token);
      return Null;
   end Create;

   ----------------------------------------------------------------------
   overriding
   function Create (
      Token             : in   Terminal_Token_Type
   ) return Ada_Lib.Template.Parameters.Expression_Class_Access is
   ----------------------------------------------------------------------

   begin
      pragma Assert (False);
      pragma Unreferenced (Token);
      return Null;
   end Create;

   ----------------------------------------------------------------------
   overriding
   function Create (
      Token             : in   Variable_Token_Type
   ) return Ada_Lib.Template.Parameters.Construct_Class_Access is
   ----------------------------------------------------------------------

   begin
      return new Ada_Lib.Template.Parameters.Variable_Type'(
         Name  => Token.Contents);
   end Create;

   ----------------------------------------------------------------------
   overriding
   function Create (
      Variable          : in   Variable_Token_Type
   ) return Ada_Lib.Template.Parameters.Expression_Class_Access is
   ----------------------------------------------------------------------

   begin
      return new Ada_Lib.Template.Parameters.Variable_Type'(
         Name  => Variable.Contents);
   end Create;

   ----------------------------------------------------------------------
   -- create unary expression
   function Create (
      Token             : in   Source_Token_Type;
      Expression           : in   Ada_Lib.Template.Parameters.Expression_Class_Access
   ) return Ada_Lib.Template.Parameters.Expression_Class_Access is
   ----------------------------------------------------------------------

   begin
      return new Ada_Lib.Template.Parameters.Unary_Operator_Type'(
         Operator => Operator (Operator_Token_Type (
                     Token_Class (Token))),
         Expression  => Expression);
   end Create;

   ----------------------------------------------------------------------
   -- create binary expression
   function Create (
      Lefthand_Term        : in   Ada_Lib.Template.Parameters.Expression_Class_Access;
      Opcode_Token         : in   Source_Token_Type;
      Righthand_Term       : in   Ada_Lib.Template.Parameters.Expression_Class_Access
   ) return Ada_Lib.Template.Parameters.Expression_Class_Access is
   ----------------------------------------------------------------------

   begin
      return new Ada_Lib.Template.Parameters.Binary_Operator_Type'(
         Operator => Operator (Operator_Token_Type (
                     Token_Class (Opcode_Token))),
         Left     => Lefthand_Term,
         Right    => Righthand_Term);
   end Create;

   ----------------------------------------------------------------------
   function End_Of_File_Token
   return Token_Class is
   ----------------------------------------------------------------------

      Result               : End_Of_File_Token_Type;

   begin
      return Result;
   end End_Of_File_Token;

   ----------------------------------------------------------------------
   overriding
   function Image (
      Token             : in   End_Of_File_Token_Type
   ) return String is
   ----------------------------------------------------------------------

   begin
      pragma Unreferenced (Token);
      return "end of file token";
   end Image;

   ----------------------------------------------------------------------
   overriding
   function Image (
      Token             : in   Null_Token_Type
   ) return String is
   ----------------------------------------------------------------------

   begin
      pragma Unreferenced (Token);
      return "null token";
   end Image;

   ----------------------------------------------------------------------
   overriding
   function Image (
      Operator          : in   Operator_Token_Type
   ) return String is
   ----------------------------------------------------------------------

   begin
      return "operator '" & Operator.Operator'img;
   end Image;

   ----------------------------------------------------------------------
   overriding
   function Image (
      Token             : in   String_Token_Type
   ) return String is
   ----------------------------------------------------------------------

   begin
      return "string '" & Token.Contents.Coerce & "'";
   end Image;

   ----------------------------------------------------------------------
   overriding
   function Image (
      Terminal          : in   Terminal_Token_Type
   ) return String is
   ----------------------------------------------------------------------

   begin
      return "terminal " & Terminal.Terminal'img;
   end Image;

   ----------------------------------------------------------------------
   overriding
   function Image (
      Variable          : in   Variable_Token_Type
   ) return String is
   ----------------------------------------------------------------------

   begin
      return "variable '" & Variable.Contents.Coerce & "'";
   end Image;

   ----------------------------------------------------------------------
   overriding
   function Length (
      Token                      : in   End_Of_File_Token_Type
   ) return Natural is
   pragma Unreferenced (Token);
   ----------------------------------------------------------------------

   begin
      return 0;
   end Length;

   ----------------------------------------------------------------------
   overriding
   function Length (
      Token                      : in   Null_Token_Type
   ) return Natural is
   pragma Unreferenced (Token);
   ----------------------------------------------------------------------

   begin
      return 0;
   end Length;

   ----------------------------------------------------------------------
   overriding
   function Length (
      Token                      : in   Operator_Token_Type
   ) return Natural is
   ----------------------------------------------------------------------

      Result                     : constant String := Token.Operator'img;

   begin
      return Result'length;
   end Length;

   ----------------------------------------------------------------------
   overriding
   function Length (
      Token                      : in   String_Token_Type
   ) return Natural is
   ----------------------------------------------------------------------

   begin
      return Token.Contents.Length;
   end Length;

   ----------------------------------------------------------------------
   overriding
   function Length (
      Token                      : in   Terminal_Token_Type
   ) return Natural is
   ----------------------------------------------------------------------

      Result                     : constant String := Token.Terminal'img;

   begin
      return Result'length;
   end Length;

   ----------------------------------------------------------------------
   function Null_Token
   return Token_Class is
   ----------------------------------------------------------------------

      Result               : Null_Token_Type;

   begin
      return Result;
   end Null_Token;

   ----------------------------------------------------------------------
   function Operator (
      Operator          : in   Operator_Token_Type
   ) return Terminal_Type is
   ----------------------------------------------------------------------

   begin
      return Operator.Operator;
   end Operator;

   ----------------------------------------------------------------------
   function Operator_Token (
      Source_Length        : in   Natural;
      Opcode               : in   Terminal_Type
   ) return Operator_Token_Type is
   ----------------------------------------------------------------------

   begin
      return (
         Operator       => Opcode);
   end Operator_Token;

   ----------------------------------------------------------------------
   function Simple (
      Token             : in   Token_Type
   ) return Boolean is
   ----------------------------------------------------------------------

   begin
      pragma Unreferenced (Token);
      return False;
   end Simple;

   ----------------------------------------------------------------------
   overriding
   function Simple (
      String               : in   String_Token_Type
   ) return Boolean is
   ----------------------------------------------------------------------

   begin
      pragma Unreferenced (String);
      return True;
   end Simple;

   ----------------------------------------------------------------------
   function String_Token (
      Source               : in   String
   ) return Token_Class is
   ----------------------------------------------------------------------

   begin
      return String_Token_Type'(
         Contents => Ada_Lib.Strings.Unlimited.Coerce (Source));
   end String_Token;

   ----------------------------------------------------------------------
   function Terminal (
      Terminal          : Terminal_Token_Type
   ) return Terminal_Type is
   ----------------------------------------------------------------------

   begin
      return Terminal.Terminal;
   end Terminal;

   ----------------------------------------------------------------------
   function Terminal_Token (
      Terminal          : Terminal_Type
   ) return Token_Class is
   ----------------------------------------------------------------------

   begin
      return Terminal_Token_Type'(
         Terminal    => Terminal);
   end Terminal_Token;

   ----------------------------------------------------------------------
   function Variable_Token (
      Name              : in   String
   ) return Token_Class is
   ----------------------------------------------------------------------

   begin
      return Variable_Token_Type'(
         Contents=> Ada_Lib.Strings.Unlimited.Coerce (Name));
   end Variable_Token;

end Ada_Lib.Template.Token;
