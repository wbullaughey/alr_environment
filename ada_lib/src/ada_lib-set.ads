generic

   type Index_Type            is ( <> );

package Ada_Lib.Set is

   type Unconstrained_Type       is array (Index_Type range <>) of Boolean;
   pragma Pack (Unconstrained_Type);

   subtype Set_Type        is Unconstrained_Type (Index_Type);
   type Set_Constant_Access   is access constant Set_Type;
   type Vector_Type        is array (Positive range <>) of Index_Type;

   Full_Set             : aliased constant Set_Type := (others => True);
   Null_Set             : aliased constant Set_Type := (others => False);

   function Count (
      Set                  : in   Unconstrained_Type
   ) return Natural;

   overriding
   function "=" (
      Left              : in   Unconstrained_Type;
      Right             : in   Unconstrained_Type
   ) return Boolean;

   overriding
   function "and" (
      Left              : in   Unconstrained_Type;
      Right             : in   Unconstrained_Type
   ) return Unconstrained_Type;

   overriding
   function "or" (
      Left              : in   Unconstrained_Type;
      Right             : in   Unconstrained_Type
   ) return Unconstrained_Type;

   overriding
   function "not" (
      Set                  : in   Unconstrained_Type
   ) return Unconstrained_Type;

   function Image (
      Set                  : in   Unconstrained_Type
   ) return String;

   function Image (
      Vector               : in   Vector_Type
   ) return String;

   function Is_In (
      Set                  : in   Unconstrained_Type;
      Item              : in   Index_Type
   ) return Boolean;

   -- test if Set_2 is a subset of Set_1
   function Is_In (
      Set_1             : in   Unconstrained_Type;
      Set_2             : in   Unconstrained_Type
   ) return Boolean;

   function Singleton (
      Item              : in   Index_Type
   ) return Set_Type;

   function To_Set (
      Vector               : in   Vector_Type
   ) return Set_Type;

   function To_Vector (
      Set                  : in   Unconstrained_Type
   ) return Vector_Type;

end Ada_Lib.Set;

