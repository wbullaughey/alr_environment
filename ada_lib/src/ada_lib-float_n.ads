-- package to provide a floating point type that fits in specified bits

with Ada.Numerics.Generic_Elementary_Functions;

generic
	Exponent_Bits				: Positive;
	Mantisa_Bits				: Positive;

package Ada_Lib.Float_N is
	type Float_N_Type			is private;

	function "+" (
		Left, Right				: in	 Float_N_Type
	) return Float_N_Type;

	function "-" (
		Left, Right				: in	 Float_N_Type
	) return Float_N_Type;

	function "*" (
		Left, Right				: in	 Float_N_Type
	) return Float_N_Type;

	function "/" (
		Left, Right				: in	 Float_N_Type
	) return Float_N_Type;

	function Convert (
		Source					: in	 Float_N_Type
	) return Float;

	function Convert (
		Source					: in	 Float
	) return Float_N_Type;

	function Image (
		Source					: in	 Float_N_Type
	) return String;

	Zero						: constant Float_N_Type;

private
    package Math is
        new Ada.Numerics.Generic_Elementary_Functions (Float_Type => 
                                                         Float);
	Mantisa_Base				: constant := 2;

	subtype Exponent_Type		is Natural range 0 .. Mantisa_Base ** Exponent_Bits - 1;
	subtype Mantisa_Type		is Natural range 0 .. Mantisa_Base ** Mantisa_Bits - 1;

	type Float_N_Type			is record
		Exponent				: Exponent_Type;
		Mantisa					: Mantisa_Type;
	end record;

	pragma Pack (Float_N_Type);

	Zero						: constant Float_N_Type := (
		Exponent=> 0,
		Mantisa	=> 0);

end Ada_Lib.Float_N;