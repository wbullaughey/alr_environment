with Ada_Lib.Template.Parameters;

package Ada_Lib.Template.Token is

   type Token_Type               is abstract tagged null record;

   subtype Token_Class           is Token_Type'class;

   type Token_Class_Access       is access all Token_Class;

   function Create (
      Token                      : in   Token_Type
   ) return Ada_Lib.Template.Parameters.Construct_Class_Access is abstract;

   function Create (
      Token             : in   Token_Type
   ) return Ada_Lib.Template.Parameters.Expression_Class_Access is abstract;

   function Image (
      Token             : in   Token_Type
   ) return String is abstract;

   function Length (
      Token             : in   Token_Type
   ) return Natural is abstract;

   function Simple (
      Token             : in   Token_Type
   ) return Boolean;

   type Source_Token_Type is abstract new Token_Type with null record;

-- function Length (
--    Token             : in   Source_Token_Type
-- ) return Natural is abstract;

   -- create unary expression
   function Create (
      Token             : in   Source_Token_Type;
      Expression           : in   Ada_Lib.Template.Parameters.Expression_Class_Access
   ) return Ada_Lib.Template.Parameters.Expression_Class_Access;

   -- create binary expression
   function Create (
      Lefthand_Term        : in   Ada_Lib.Template.Parameters.Expression_Class_Access;
      Opcode_Token         : in   Source_Token_Type;
      Righthand_Term       : in   Ada_Lib.Template.Parameters.Expression_Class_Access
   ) return Ada_Lib.Template.Parameters.Expression_Class_Access;

   type Null_Token_Type    is new Token_Type with null record;

   overriding
   function Length (
      Token                      : in   Null_Token_Type
   ) return Natural;

   overriding
   function Create (
      Token             : in   Null_Token_Type
   ) return Ada_Lib.Template.Parameters.Construct_Class_Access;

   overriding
   function Create (
      Token             : in   Null_Token_Type
   ) return Ada_Lib.Template.Parameters.Expression_Class_Access;

   overriding
   function Image (
      Token             : in   Null_Token_Type
   ) return String;

   function Null_Token
   return Token_Class;

   type End_Of_File_Token_Type   is new Token_Type with
                           null record;

   function End_Of_File_Token
   return Token_Class;

   overriding
   function Create (
      Token                      : in   End_Of_File_Token_Type
   ) return Ada_Lib.Template.Parameters.Construct_Class_Access;

   overriding
   function Create (
      Token                      : in   End_Of_File_Token_Type
   ) return Ada_Lib.Template.Parameters.Expression_Class_Access;

   overriding
   function Image (
      Token                      : in   End_Of_File_Token_Type
   ) return String;

   overriding
   function Length (
      Token                      : in   End_Of_File_Token_Type
   ) return Natural;

   type String_Token_Type        is new Source_Token_Type with record
      Contents                   : Unlimited_String_Type;
   end record;

   overriding
   function Create (
      Token                      : in   String_Token_Type
   ) return Ada_Lib.Template.Parameters.Construct_Class_Access;

   overriding
   function Create (
      String                     : in   String_Token_Type
   ) return Ada_Lib.Template.Parameters.Expression_Class_Access;

   overriding
   function Image (
      Token                      : in   String_Token_Type
   ) return String;

   overriding
   function Length (
      Token                      : in   String_Token_Type
   ) return Natural;

   overriding
   function Simple (
      String               : in   String_Token_Type
   ) return Boolean;

   function String_Token (
      Source               : in   String
   ) return Token_Class;

   type Operator_Token_Type      is new Source_Token_Type with record
      Operator                   : Terminal_Type;
   end record;

   overriding
   function Create (
      Token                      : in   Operator_Token_Type
   ) return Ada_Lib.Template.Parameters.Construct_Class_Access;

   overriding
   function Create (
      Token                      : in   Operator_Token_Type
   ) return Ada_Lib.Template.Parameters.Expression_Class_Access;

   overriding
   function Image (
      Operator                   : in   Operator_Token_Type
   ) return String;

   overriding
   function Length (
      Token                      : in   Operator_Token_Type
   ) return Natural;

   function Operator (
      Operator                   : in   Operator_Token_Type
   ) return Terminal_Type;

   function Operator_Token (
      Source_Length        : in   Natural;
      Opcode               : Terminal_Type
   ) return Operator_Token_Type;

   type Terminal_Token_Type      is new Source_Token_Type with record
      Terminal                   : Terminal_Type;
   end record;

   overriding
   function Create (
      Token                      : in   Terminal_Token_Type
   ) return Ada_Lib.Template.Parameters.Construct_Class_Access;

   overriding
   function Create (
      Token                      : in   Terminal_Token_Type
   ) return Ada_Lib.Template.Parameters.Expression_Class_Access;

   overriding
   function Image (
      Terminal                   : in   Terminal_Token_Type
   ) return String;

   overriding
   function Length (
      Token                      : in   Terminal_Token_Type
   ) return Natural;

   function Terminal (
      Terminal                   : in   Terminal_Token_Type
   ) return Terminal_Type;

   function Terminal_Token (
      Terminal          : Terminal_Type
   ) return Token_Class;

   type Variable_Token_Type      is new String_Token_Type with null record;

   overriding
   function Create (
      Token                      : in   Variable_Token_Type
   ) return Ada_Lib.Template.Parameters.Construct_Class_Access;

   overriding
   function Create (
      Variable                   : in   Variable_Token_Type
   ) return Ada_Lib.Template.Parameters.Expression_Class_Access;

   overriding
   function Image (
      Variable                   : in   Variable_Token_Type
   ) return String;

   function Variable_Token (
      Name              : in   String
   ) return Token_Class;

end Ada_Lib.Template.Token;
