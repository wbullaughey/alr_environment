-- with Ada.Containers.Vectors;
-- with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Template.Generic_Parameter;

pragma Elaborate (Ada_Lib.Template.Generic_Parameter);

package Ada_Lib.Template.Parameters is

   type Parameter_Array          is array (Positive range <>) of Named_Parameter_Class_Access;

   function Expand (
      Parameters           : in   Parameter_Array;
      Index             : in   Parameter_Index_Type;
      Done              : in   Boolean_Access
   ) return String;

   function Load (
      Path                       : in     String
   ) return Parameter_Array;

   function Integer_Image (
      Target                     : in     Integer
   ) return String;

   package Integer_Package is new Ada_Lib.Template.Generic_Parameter.Parameter_Package (
      Target_Type       => Integer,
      Image             => Integer_Image,
      Null_Target       => 0);

   subtype Integer_Parameter_Type is Integer_Package.Generic_Parameter_Type;

   function Boolean_Image (
      Target                     : in     Boolean
   ) return String;

   package Boolean_Package is new Ada_Lib.Template.Generic_Parameter.Parameter_Package (
      Target_Type       => Boolean,
      Image             => Boolean_Image,
      Null_Target       => False);

   subtype Boolean_Parameter_Type is Boolean_Package.Generic_Parameter_Type;

-- type Integer_Parameter_Type   is new Named_Parameter_Type with record
--    Value                      : Integer;
-- end record;
--
-- overriding
-- function Value (
--    Parameter                  : in   Integer_Parameter_Type;
--    Index                      : in   Parameter_Index_Type;
--    Done                       : in   Integer_Access
-- ) return String;



   type Integer_Array            is array (Positive range <>) of Integer;

   type Integer_Array_Parameter_Type (
      Array_Length               : Natural
   )                             is new Named_Parameter_Type with record
      Value                      : Integer_Array (1 .. Array_Length);
   end record;
   type Integer_Array_Parameter_Access
                                 is access Integer_Array_Parameter_Type;
-- function Create (
--    Name                       : in   String;
--    Dimension                  : in   Natural;
--    Default_Value              : in   Integer := 0
-- ) return Integer_Array_Parameter_Access;

   procedure Set (
      Parameter                  : in out Integer_Array_Parameter_Type;
      Index                      : in   Positive;
      Value                      : in   Integer);

   overriding
   function Value (
      Parameter                  : in   Integer_Array_Parameter_Type;
      Index                      : in   Parameter_Index_Type;
      Done                       : in   Boolean_Access
   ) return String;

   type String_Parameter_Type is new Named_Parameter_Type with record
      Value                      : Unlimited_String_Type;
   end record;
   type String_Parameter_Access  is access String_Parameter_Type;

-- function Create (
--    Name                       : in   String;
--    Value                      : in   String
-- ) return String_Parameter_Access;

   procedure Set (
      Parameter                  : in out String_Parameter_Type;
      Index                      : in   Positive;
      Value                      : in   String);

   overriding
   function Value (
      Parameter                  : in   String_Parameter_Type;
      Index                      : in   Parameter_Index_Type;
      Done                       : in   Boolean_Access
   ) return String;

-- function Value (
--    Parameter            : in   Bounded_String_Parameter_Type;
--    Index             : in   Parameter_Index_Type;
--    Done              : in   Boolean_Access
-- ) return String;

-- package String_Vector_Package is new Ada.Containers.Vectors (
--    Index_Type        => Natural,
--    Element_Type      => Unlimited_String_Type,
--    "="               => Ada_Lib.Strings.Unlimited."=");
--
-- package String_Parameter_Package
--                               is new Ada_Lib.Template.Generic_Parameter.Parameter_Package (String_Vector_Package.Vector);
     type String_Array           is array (Positive range <>) of
                                    Unlimited_String_Type;

     type String_Array_Parameter_Type (
        Array_Length             : Positive
     )                           is new Named_Parameter_Type with record
        Value                    : String_Array (1 .. Array_Length);
     end record;
   type String_Array_Parameter_Access
                                 is access String_Array_Parameter_Type;

-- function Create (
--    Name              : in   String;
--    Dimension            : in   Natural;
--    Default_Value        : in   String := ""
-- ) return String_Array_Parameter_Access;

   procedure Set (
      Parameter            : in out String_Array_Parameter_Type;
      Index             : in   Positive;
      Value             : in   String);

   overriding
   function Value (
      Parameter            : in   String_Array_Parameter_Type;
      Index             : in   Parameter_Index_Type;
      Done              : in   Boolean_Access
   ) return String;

   type Construct_Type        is tagged null record;

   subtype Construct_Class    is Construct_Type'class;

   type Construct_Class_Access   is access all Construct_Class;

     function Expand (
        Construct            : in   Construct_Type;
        Parameters           : in   Parameter_Array;
        Index             : in   Parameter_Index_Type;
        Done              : in   Boolean_Access
     ) return String;

   type List_Type;
   type List_Access              is access all List_Type;
   type List_Type                is new Construct_Type with record
      Cell                       : Construct_Class_Access;
      Next                       : List_Access;
   end record;

   overriding
   function Expand (
      List                       : in   List_Type;
      Parameters                 : in   Parameter_Array;
      Index                      : in   Parameter_Index_Type;
      Done                       : in   Boolean_Access
   ) return String;

   function Expand (
      List                       : in   List_Type;
      Parameters                 : in   Parameter_Array
   ) return String;

   type Expression_Type          is new Construct_Type with null record;
-- subtype Expression_Class      is Expression_Type'class;
   type Expression_Class_Access  is access all Expression_Type'class;

   function Evaluate (
      Expression           : in   Expression_Type;
      Parameters           : in   Parameter_Array;
      Index             : in   Parameter_Index_Type;
      Done              : in   Boolean_Access
   ) return Boolean;

   function Evaluate (
      Expression           : in   Expression_Type;
      Parameters           : in   Parameter_Array;
      Index             : in   Parameter_Index_Type;
      Done              : in   Boolean_Access
   ) return Integer;

   overriding
  function Expand (
     Expression               : in   Expression_Type;
     Parameters               : in   Parameter_Array;
     Index                    : in   Parameter_Index_Type;
     Done                     : in   Boolean_Access
  ) return String;

  type If_Else_Type           is new Construct_Type with record
     Condition                : Expression_Class_Access;
     True_Part                : List_Access;
     False_Part               : Construct_Class_Access;
  end record;

  type If_Else_Access        is access all If_Else_Type;

   overriding
  function Expand (
     If_Else                  : in   If_Else_Type;
     Parameters               : in   Parameter_Array;
     Index                    : in   Parameter_Index_Type;
     Done                     : in   Boolean_Access
  ) return String;

  type Not_Operator_Type     is new Construct_Type with record
     Expression           : Construct_Class_Access;
  end record;

   overriding
   function Expand (
      Not_Operator               : in   Not_Operator_Type;
      Parameters                 : in   Parameter_Array;
      Index                      : in   Parameter_Index_Type;
      Done                       : in   Boolean_Access
   ) return String;

     type Table_Type             is new Construct_Type with record
        List                     : List_Access;
     end record;

     type Table_Access           is access Table_Type;

      overriding
      function Expand (
         Table                      : in   Table_Type;
         Parameters                 : in   Parameter_Array;
         Index                      : in   Parameter_Index_Type;
         Done                       : in   Boolean_Access
      ) return String;

     type Evaluate_Type         is new Construct_Type with record
        Expression               : Expression_Class_Access;
     end record;

   type Evaluate_Access       is access all Evaluate_Type;

   overriding
   function Expand (
      Expression           : in   Evaluate_Type;
      Parameters           : in   Parameter_Array;
      Index             : in   Parameter_Index_Type;
      Done              : in   Boolean_Access
   ) return String;

     type Binary_Operator_Type  is new Expression_Type with record
        Operator          : Binary_Opcodes_Type;
        Right             : Expression_Class_Access;
        Left              : Expression_Class_Access;
     end record;

   overriding
   function Evaluate (
      Operator                   : in   Binary_Operator_Type;
      Parameters                 : in   Parameter_Array;
      Index                      : in   Parameter_Index_Type;
      Done                       : in   Boolean_Access
   ) return Boolean;

   overriding
   function Evaluate (
      Operator                   : in   Binary_Operator_Type;
      Parameters                 : in   Parameter_Array;
      Index                      : in   Parameter_Index_Type;
      Done                       : in   Boolean_Access
   ) return Integer;

   overriding
   function Expand (
      Binary_Operator            : in   Binary_Operator_Type;
      Parameters                 : in   Parameter_Array;
      Index                      : in   Parameter_Index_Type;
      Done                       : in   Boolean_Access
   ) return String;

   type Text_Type                is new Expression_Type with record
      Contents                   : Unlimited_String_Type;
   end record;

   overriding
   function Evaluate (
      Text                       : in   Text_Type;
      Parameters                 : in   Parameter_Array;
      Index                      : in   Parameter_Index_Type;
      Done                       : in   Boolean_Access
   ) return Boolean;

   overriding
   function Evaluate (
      Text                       : in   Text_Type;
      Parameters                 : in   Parameter_Array;
      Index                      : in   Parameter_Index_Type;
      Done                       : in   Boolean_Access
   ) return Integer;

   overriding
   function Expand (
      Text                       : in   Text_Type;
      Parameters                 : in   Parameter_Array;
      Index                      : in   Parameter_Index_Type;
      Done                       : in   Boolean_Access
   ) return String;

   function Value (
      Text                       : in     Text_Type
   ) return String;

   type Unary_Operator_Type      is new Expression_Type with record
      Operator                   : Unary_Opcodes_Type;
      Expression                 : Expression_Class_Access;
   end record;

   overriding
   function Evaluate (
      Operator          : in   Unary_Operator_Type;
      Parameters           : in   Parameter_Array;
      Index             : in   Parameter_Index_Type;
      Done              : in   Boolean_Access
   ) return Boolean;

   overriding
   function Evaluate (
      Operator          : in   Unary_Operator_Type;
      Parameters           : in   Parameter_Array;
      Index             : in   Parameter_Index_Type;
      Done              : in   Boolean_Access
   ) return Integer;

   overriding
   function Expand (
      Unary_Operator       : in   Unary_Operator_Type;
      Parameters           : in   Parameter_Array;
      Index             : in   Parameter_Index_Type;
      Done              : in   Boolean_Access
   ) return String;

   type Variable_Type is new Expression_Type with record
      Name                     : Unlimited_String_Type;
   end record;

   overriding
   function Evaluate (
      Variable          : in   Variable_Type;
      Parameters           : in   Parameter_Array;
      Index             : in   Parameter_Index_Type;
      Done              : in   Boolean_Access
   ) return Boolean;

   overriding
   function Evaluate (
      Variable          : in   Variable_Type;
      Parameters           : in   Parameter_Array;
      Index             : in   Parameter_Index_Type;
      Done              : in   Boolean_Access
   ) return Integer;

   overriding
   function Expand (
      Variable                   : in   Variable_Type;
      Parameters                 : in   Parameter_Array;
      Index                      : in   Parameter_Index_Type;
      Done                       : in   Boolean_Access
   ) return String;

   type Boolean_Array         is array (Positive range <>) of Boolean;

   type Boolean_Array_Parameter_Type (
      Array_Length               : Natural
   )                             is new Named_Parameter_Type with record
      Value                      : Boolean_Array (1 .. Array_Length);
   end record;
   type Boolean_Array_Parameter_Access
                                 is access Boolean_Array_Parameter_Type;

-- function Create (
--    Name                       : in   String;
--    Dimension                  : in   Natural;
--    Default_Value              : in   Boolean := False
-- ) return Boolean_Array_Parameter_Access;

   procedure Set (
      Parameter                  : in out Boolean_Array_Parameter_Type;
      Index                      : in   Positive;
      Value                      : in   Boolean);

   overriding
   function Value (
      Parameter                  : in   Boolean_Array_Parameter_Type;
      Index                      : in   Parameter_Index_Type;
      Done                       : in   Boolean_Access
   ) return String;

   type Vector_Parameter_Type (
      Vector_Length              : Positive
   )                             is new Named_Parameter_Type with record
      Contents                   : Parameter_Array (1 .. Vector_Length);
   end record;
   type Vector_Parameter_Access  is access Vector_Parameter_Type;

-- function Create (
--    Name                       : in   String;
--    Contents                   : in   Parameter_Array
-- ) return Vector_Parameter_Access;

   procedure Set (
      Parameter                  : in out Vector_Parameter_Type;
      Index                      : in   Positive;
      Pointer                    : in   Named_Parameter_Class_Access);

   overriding
   function Value (
      Parameter                  : in   Vector_Parameter_Type;
      Index                      : in   Parameter_Index_Type;
      Done                       : in   Boolean_Access
   ) return String;

--    List                       : List_Access := Null;
-- end record;

-- type Construct_Type        is tagged null record;
--
--   type Template_Type is tagged record
--      List                       : List_Access := Null;
--   end record;

-- function Expand (
--    Construct            : in   Construct_Type;
--    Parameters           : in   Parameter_Array;
--    Index             : in   Parameter_Index_Type;
--    Done              : in   Boolean_Access
-- ) return String;
--
-- type Evaluate_Type         is new Construct_Type with record
--    Expression           : Expression_Class_Access;
-- end record;
--
-- type If_Else_Type       is new Construct_Type with record
--    Condition            : Expression_Class_Access;
--    True_Part            : List_Access;
--    False_Part           : Construct_Class_Access;
-- end record;
--
-- type Expression_Type    is new Construct_Type with null record;
--
-- type Binary_Operator_Type  is new Expression_Type with record
--    Operator          : Binary_Opcodes_Type;
--    Right             : Expression_Class_Access;
--    Left              : Expression_Class_Access;
-- end record;
--
-- type List_Type          is new Construct_Type with record
--    Cell              : Construct_Class_Access;
--    Next              : List_Access;
-- end record;
--
-- type Not_Operator_Type     is new Construct_Type with record
--    Expression           : Construct_Class_Access;
-- end record;
--
-- type Unary_Operator_Type   is new Expression_Type with record
--    Operator          : Unary_Opcodes_Type;
--    Expression           : Expression_Class_Access;
-- end record;
--
-- function Adjusted_Index (
--    Index             : in   Parameter_Index_Type
-- ) return Positive;
--
   No_Parameters           : Parameter_Array (1 .. 0);

end Ada_Lib.Template.Parameters;
