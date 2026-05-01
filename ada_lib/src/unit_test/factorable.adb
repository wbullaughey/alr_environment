with Ada.Text_IO; use Ada.Text_IO;
with Ada_Lib.Factorable;

procedure Factorable is

	package Number is new Ada_Lib.Factorable (
		Factor	=> 10,
		Min		=> -1000,
		Max		=> 1000);

	subtype Number_Type is Number.Factorable_Type;

	use type Number_Type;

	x	: Number_Type := Number.To (55);
	
begin
	Put_Line ("x = " &  Number.Image (X));

	X := X + 6;

	Put_Line ("x + 6 = " &  Number.Image (X));
		 
	X := X * 3;

	Put_Line ("x * 3 = " &  Number.Image (X));
		 
	X := X / 10;

	Put_Line ("x / 10 = " &  Number.Image (X));
		 
end Factorable;