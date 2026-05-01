-- with Ada.Containers.Vectors;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
-- with Ada_Lib.Template.Generic_Parameter;

package Ada_Lib.Template is

   Bad_Parameter                 : exception;
   Failed                        : exception;
   Index_Error                   : exception;
   Missmatched_Parameter         : exception;
   No_Parameter                  : exception;
   Not_Found                     : exception;
   Syntax_Error                  : exception;

   type Boolean_Access        is access all Boolean;

-- type Terminal_Type         is (
--    Add_Token,
--    And_Token,
--    Else_Token,
--    Elsif_Token,
--    End_If_Token,
--    End_Table_Token,
--    Equal_Token,
--    Evaluate_Token,
--    Greater_Token,
--    Greater_Equal_Token,
--    If_Token,
--    Less_Token,
--    Less_Equal_Token,
--    Not_Token,
--    Not_Equal_Token,
--    Or_Token,
--    Subtract_Token,
--    Table_Token
-- );

   -- subtypes are dependent on following ordering
   type Terminal_Type        is (
      -- unary opcodes
      Not_Token,
      -- binary opcodes
      -- integer binary opcodes
      Add_Token,
      Subtract_Token,
      Greater_Token,
      Greater_Equal_Token,
      Less_Token,
      Less_Equal_Token,
      -- boolean binary opcodes
      And_Token,
      Or_Token,
      -- any operand binary opcodes
      Equal_Token,
      Not_Equal_Token,
      Else_Token,
      Elsif_Token,
      End_If_Token,
      End_Table_Token,
      Evaluate_Token,
      If_Token,
      Table_Token);

   subtype Operator_Type   is Terminal_Type range
                                    Not_Token .. Not_Equal_Token;

   subtype Unary_Opcodes_Type is Terminal_Type range Not_Token .. Not_Token;
   subtype Binary_Opcodes_Type   is Terminal_Type range Add_Token ..
                           Not_Equal_Token;
   subtype Boolean_Binary_Opcodes_Type
                        is Terminal_Type range And_Token .. Or_Token;
   subtype Integer_Binary_Opcodes_Type
                        is Terminal_Type range Add_Token ..
                           Less_Equal_Token;
   subtype String_Binary_Opcodes_Type
                        is Terminal_Type range Equal_Token ..
                           Not_Equal_Token;

   type Parameter_Index_Type     is array (Positive range <>) of Positive;

   subtype Unlimited_String_Type is Ada_Lib.Strings.Unlimited.String_Type;

   function Adjusted_Index (
      Index                      : in   Parameter_Index_Type
   ) return Positive;

   function Dumpstring (Arg : String) return String;

   function Is_Numeric (
     Source               : in   String
   ) return Boolean;

   function Numeric_Value (
     Source               : in   String
   ) return Integer;

   type Parameter_Interface           is interface;

-- function Create (
--    Name                       : in   String;
--    Value                      : in   String
-- ) return Parameter_Interface is abstract;
--
--
   function Name (
      Parameter                  : in     Parameter_Interface
   ) return String is abstract;

-- procedure Set (
--    Parameter                  : in out Parameter_Interface;
--    Index                      : in   Positive;
--    Value                      : in   String) is abstract;

   function Value (
      Parameter                  : in   Parameter_Interface;
      Index                      : in   Parameter_Index_Type;
      Done                       : in   Boolean_Access
   ) return String is abstract;

   subtype Parameter_Interface_Class
                                 is Parameter_Interface'class;

   type Parameter_Interface_Class_Access   is access all Parameter_Interface_Class;

   type Named_Parameter_Type     is abstract new Parameter_Interface with record
      Name                       : Unlimited_String_Type;
   end record;
   type Named_Parameter_Class_Access
                                 is access all Named_Parameter_Type'class;

   procedure Initialize (
      Parameter                  : in out Named_Parameter_Type;
      Name                       : in     String);

   overriding
   function Name (
      Parameter                  : in     Named_Parameter_Type
   ) return String;

   No_Parameter_Index         : Parameter_Index_Type(1 .. 0);
--   Null_Index              : constant Parameter_Index_Type (1 .. 0) :=
--                           (others => 1);

-- type Evaluate_Type         is new Construct_Type with private;
--

-- type If_Else_Type       is new Construct_Type with private;
--
-- type If_Else_Access        is access all If_Else_Type;

-- function Expand (
--    Parameters           : in   Parameter_Array;
--    If_Else              : in   If_Else_Type;
--    Index             : in   Parameter_Index_Type;
--    Done              : in   Boolean_Access
-- ) return String;

-- type Not_Operator_Type     is new Construct_Type with private;

-- type Table_Type            is new Construct_Type with private;



--   package Boolean_Package          is new Ada_Lib.Template.Generic_Parameter.Parameter_Package (Boolean);
--   subtype Boolean_Parameter_Type   is Boolean_Package.Generic_Parameter_Type;
--
--   procedure Set (
--      Parameter                  : in out Boolean_Parameter_Type;
--      Value                      : in   Boolean);
--
--   function Value (
--      Parameter                  : in   Boolean_Parameter_Type;
--      Index                      : in   Parameter_Index_Type;
--      Done                       : in   Boolean_Access
--   ) return String;
--
--   type Boolean_Array_Parameter_Type (
--      Array_Length               : Natural
--   )                             is new Parameter_Type with private;
--
--   function Create (
--      Name                       : in   String;
--      Dimension                  : in   Natural;
--      Default_Value              : in   Boolean := False
--   ) return Boolean_Array_Parameter_Type;
--
--   procedure Set (
--      Parameter            : in out Boolean_Array_Parameter_Type;
--      Index             : in   Positive;
--      Value             : in   Boolean);
--
--   function Value (
--      Parameter            : in   Boolean_Array_Parameter_Type;
--      Index             : in   Parameter_Index_Type;
--      Done              : in   Boolean_Access
--   ) return String;
--
--   package Integer_Package          is new Ada_Lib.Template.Generic_Parameter.Parameter_Package (Integer);
--   subtype Integer_Parameter_Type   is Integer_Package.Generic_Parameter_Type;
--
--   function Create (
--      Name              : in   String;
--      Value             : in   Integer
--   ) return Integer_Parameter_Type;
--
--   procedure Set (
--      Parameter            : in out Integer_Parameter_Type;
--      Value             : in   Integer);
--
--   function Value (
--      Parameter            : in   Integer_Parameter_Type;
--      Index             : in   Parameter_Index_Type;
--      Done              : in   Boolean_Access
--   ) return String;
--
--   package Integer_Vector_Package is new Ada.Containers.Vectors (
--      Index_Type        => Natural,
--      Element_Type      => Integer,
--      "="               => "=");
--
--   package Integer_Parameter_Package
--                                 is new Ada_Lib.Template.Generic_Parameter.Parameter_Package (Integer_Vector_Package.Vector);
--   subtype Integer_Array_Parameter_Type
--                                 is Integer_Parameter_Package.Generic_Parameter_Type;
--
--   function Create (
--      Name              : in   String;
--      Dimension            : in   Natural;
--      Default_Value        : in   Integer := 0
--   ) return Integer_Array_Parameter_Type;
--
--   procedure Set (
--      Parameter            : in out Integer_Array_Parameter_Type;
--      Index             : in   Positive;
--      Value             : in   Integer);
--
--   function Value (
--      Parameter            : in   Integer_Array_Parameter_Type;
--      Index             : in   Parameter_Index_Type;
--      Done              : in   Boolean_Access
--   ) return String;
--
--   package String_Package          is new Ada_Lib.Template.Generic_Parameter.Parameter_Package (Unlimited_String_Type);
--   subtype String_Parameter_Type   is String_Package.Generic_Parameter_Type;
--
--   function Create (
--      Name              : in   String;
--      Value             : in   String
--   ) return String_Parameter_Type;
--
--   function Value (
--      Parameter            : in   String_Parameter_Type;
--      Index             : in   Parameter_Index_Type;
--      Done              : in   Boolean_Access
--   ) return String;
--
--   type Parameter_Array    is array (Positive range <>) of Parameter_Interface_Class_Access;
--
---- function Value (
----    Parameter            : in   Bounded_String_Parameter_Type;
----    Index             : in   Parameter_Index_Type;
----    Done              : in   Boolean_Access
---- ) return String;
--
--   package String_Vector_Package is new Ada.Containers.Vectors (
--      Index_Type        => Natural,
--      Element_Type      => Unlimited_String_Type,
--      "="               => Ada_Lib.Strings.Unlimited."=");
--
--   package String_Parameter_Package
--                                 is new Ada_Lib.Template.Generic_Parameter.Parameter_Package (String_Vector_Package.Vector);
--   subtype String_Array_Parameter_Type
--                                 is String_Parameter_Package.Generic_Parameter_Type;
--
--   function Create (
--      Name              : in   String;
--      Dimension            : in   Natural;
--      Default_Value        : in   String := ""
--   ) return String_Array_Parameter_Type;
--
--   procedure Set (
--      Parameter            : in out String_Array_Parameter_Type;
--      Index             : in   Positive;
--      Value             : in   String);
--
--   function Value (
--      Parameter            : in   String_Array_Parameter_Type;
--      Index             : in   Parameter_Index_Type;
--      Done              : in   Boolean_Access
--   ) return String;
--
----private
----   subtype String_Type        is Ada_Lib.Strings.Bounded.Bounded_Type (
----                           Maximum_Value_Length);
----
----   type Bounded_String_Array  is array (Positive range <>) of
----                           String_Type;
----
----   type String_Array_Parameter_Type (
----      Name_Length          : Positive;
----      Array_Length         : Natural
----   )                    is new Parameter_Type (Name_Length) with record
----      Value             : Bounded_String_Array (1 .. Array_Length);
----   end record;
--
--   type Vector_Parameter_Type (
--      Vector_Length        : Positive
--   )                    is new Parameter_Interface with private;
--
--   function Create (
--      Name              : in   String;
--      Contents          : in   Parameter_Array
--   ) return Vector_Parameter_Type;
--
--   function Value (
--      Parameter            : in   Vector_Parameter_Type;
--      Index             : in   Parameter_Index_Type;
--      Done              : in   Boolean_Access
--   ) return String;
--
--   type Construct_Type        is tagged private;
--
--   subtype Construct_Class    is Construct_Type'class;
--
--   type Ada_Lib.Template.Parameters.Construct_Class_Access   is access all Construct_Class;
--
--   type Expression_Type    is new Construct_Type with private;
--
--   function Evaluate (
--      Expression           : in   Expression_Type;
--      Parameters           : in   Parameter_Array;
--      Index             : in   Parameter_Index_Type;
--      Done              : in   Boolean_Access
--   ) return Boolean;
--
--   function Evaluate (
--      Expression           : in   Expression_Type;
--      Parameters           : in   Parameter_Array;
--      Index             : in   Parameter_Index_Type;
--      Done              : in   Boolean_Access
--   ) return Integer;
--
--   subtype Expression_Class   is Expression_Type'class;
--
--   type Expression_Class_Access
--                        is access all Expression_Class;
--
--   type Logic_Binary_Operator_Type  is new Expression_Type with private;
--
--   function Evaluate (
--      Parameters           : in   Parameter_Array;
--      Operator          : in   Binary_Operator_Type;
--      Index             : in   Parameter_Index_Type;
--      Done              : in   Boolean_Access
--   ) return Boolean;
--
--   function Evaluate (
--      Parameters           : in   Parameter_Array;
--      Operator          : in   Binary_Operator_Type;
--      Index             : in   Parameter_Index_Type;
--      Done              : in   Boolean_Access
--   ) return Integer;
--
--   function Expand (
--      Parameters           : in   Parameter_Array;
--      Binary_Operator         : in   Binary_Operator_Type;
--      Index             : in   Parameter_Index_Type;
--      Done              : in   Boolean_Access
--   ) return String;
--
--   type Evaluate_Type         is new Construct_Type with private;
--
--   type Evaluate_Access       is access all Evaluate_Type;
--
--   type If_Else_Type       is new Construct_Type with private;
--
--   type If_Else_Access        is access all If_Else_Type;
--
--
--   type List_Type          is new Construct_Type with private;
--
--   type List_Access        is access all List_Type;
--
--   function Expand (
--      Parameters           : in   Parameter_Array;
--      List              : in   List_Type
--   ) return String;
--
--   function Expand (
--      Parameters           : in   Parameter_Array;
--      List              : in   List_Type;
--      Index             : in   Parameter_Index_Type;
--      Done              : in   Boolean_Access
--   ) return String;
--
--   type Not_Operator_Type     is new Construct_Type with private;
--
--   function Expand (
--      Parameters           : in   Parameter_Array;
--      Not_Operator         : in   Not_Operator_Type;
--      Index             : in   Parameter_Index_Type;
--      Done              : in   Boolean_Access
--   ) return String;
--
--   type Table_Type            is new Construct_Type with private;
--
--   function Expand (
--      Parameters           : in   Parameter_Array;
--      Table             : in   Table_Type;
--      Index             : in   Parameter_Index_Type;
--      Done              : in   Boolean_Access
--   ) return String;
--
--   type Text_Type (
--      Length               : Positive
--   )                    is new Expression_Type with private;
--
--   function Evaluate (
--      Parameters           : in   Parameter_Array;
--      Text              : in   Text_Type;
--      Index             : in   Parameter_Index_Type;
--      Done              : in   Boolean_Access
--   ) return Boolean;
--
--   function Evaluate (
--      Parameters           : in   Parameter_Array;
--      Text              : in   Text_Type;
--      Index             : in   Parameter_Index_Type;
--      Done              : in   Boolean_Access
--   ) return Integer;
--
--   function Expand (
--      Parameters           : in   Parameter_Array;
--      Text              : in   Text_Type;
--      Index             : in   Parameter_Index_Type;
--      Done              : in   Boolean_Access
--   ) return String;
--
--   type Unary_Operator_Type   is new Expression_Type with private;
--
--   function Evaluate (
--      Parameters           : in   Parameter_Array;
--      Operator          : in   Unary_Operator_Type;
--      Index             : in   Parameter_Index_Type;
--      Done              : in   Boolean_Access
--   ) return Boolean;
--
--   function Evaluate (
--      Parameters           : in   Parameter_Array;
--      Operator          : in   Unary_Operator_Type;
--      Index             : in   Parameter_Index_Type;
--      Done              : in   Boolean_Access
--   ) return Integer;
--
--   function Expand (
--      Parameters           : in   Parameter_Array;
--      Unary_Operator       : in   Unary_Operator_Type;
--      Index             : in   Parameter_Index_Type;
--      Done              : in   Boolean_Access
--   ) return String;
--
--   type Variable_Type (
--      Length               : Positive
--   )                    is new Expression_Type with private;
--
--   function Evaluate (
--      Parameters           : in   Parameter_Array;
--      Variable          : in   Variable_Type;
--      Index             : in   Parameter_Index_Type;
--      Done              : in   Boolean_Access
--   ) return Boolean;
--
--   function Evaluate (
--      Parameters           : in   Parameter_Array;
--      Variable          : in   Variable_Type;
--      Index             : in   Parameter_Index_Type;
--      Done              : in   Boolean_Access
--   ) return Integer;
--
--   function Expand (
--      Parameters           : in   Parameter_Array;
--      Variable          : in   Variable_Type;
--      Index             : in   Parameter_Index_Type;
--      Done              : in   Boolean_Access
--   ) return String;
--
     Trace_Compile           : Boolean := False;
     Trace_Evaluate          : Boolean := False;
     Trace_Expand            : Boolean := False;
     Trace_Load              : Boolean := False;
     Trace_Test              : Boolean := False;
--   No_Parameters           : Parameter_Array (1 .. 0);
--   No_Parameter_Index         : Parameter_Index_Type(1 .. 0);
--
--   type Template_Type            is tagged private;
--
--   procedure Compile (
--      Template                   : in out Template_Type;
--      Source_File                : in     String);
--
--   -- preload templates
--   procedure Load (
--      Template                   : in out Template_Type;
--      Path                       : in   String);
--
-- private
---- type Parameter_Type           is new Unlimited_String_Type
----                                  with null record;
----    Name              : String (1 .. Name_Length);
---- end record;
--
---- type Boolean_Parameter_Type   is new Parameter_Type with record
----    Value             : Boolean;
---- end record;
--
--   type Boolean_Array         is array (Positive range <>) of Boolean;
--
--   type Boolean_Array_Parameter_Type (
--      Array_Length         : Natural
--   )                    is new Parameter_Type with record
--      Name              : Unlimited_String_Type;
--      Value             : Boolean_Array (1 .. Array_Length);
--   end record;
--
----
---- type Integer_Array_Parameter_Type (
----    Array_Length         : Natural
---- )                    is new Parameter_Type with record
----    Value             : Integer_Array (1 .. Array_Length);
---- end record;
--
---- type String_Parameter_Type (
----    Value_Length         : Natural
---- )                    is new Parameter_Type with record
----    Value             : String (1 .. Value_Length);
---- end record;
--
---- type Bounded_String_Parameter_Type (
----    Name_Length                : Positive;
----    Maximum_Value_Length       : Positive
---- )                             is new Parameter_Type (Name_Length) with record
----    Value                      : Unlimited_String_Type (Maximum_Value_Length);
---- end record;
--

end Ada_Lib.Template;
