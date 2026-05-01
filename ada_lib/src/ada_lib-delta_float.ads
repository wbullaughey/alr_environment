generic

    type Float_Type is digits <>;
    Epsilon : in float;

package Ada_Lib.Delta_Float is

    function Changed
      (Old_Value            : in     Float_Type;
       Current_Value        : in     Float_Type)
      return Boolean;
    --  Compare Old_Value to Current_Value.  If
    --  abs (Old_Value - Current_Value) > Epsilon then
    --  return True, otherwise return False.

    function To_String (Value : in Float_Type) return String;
    --  Return a String representation of the given float.  The
    --  returned image will have no exponent (Exp => 0) and
    --  enough decimal digits to reprsent Epsilon.

end Ada_Lib.Delta_Float;
