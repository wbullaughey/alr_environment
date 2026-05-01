generic
	
	type Datum_Type is private;
	type Range_Type is range <>;
	
	-- This must return a string with Item formated for display
	with function Image
		 (Item					: in     Datum_Type)
			 return String;

	-- This must return a string with Item formated for JSON
	with function JSON
		 (Item					: in     Datum_Type)
			 return String;

	-- This must return True iff Item1 > Item2
	with function Greater
		 (Item1			: in     Datum_Type;
		  Item2			: in     Datum_Type)
			 return Boolean;
	
	-- This must return True iff Item1 = Item2
	with function Equal
		 (Item1			: in     Datum_Type;
		  Item2			: in     Datum_Type)
			 return Boolean;
	
package Ada_Lib.GenList is
	Out_Of_Bounds				: exception;

	type List_Type is private;
	
	procedure Add
		(List					: in  out List_Type;
		 Item					: in      Datum_Type);

	procedure Add
		(List					: in  out List_Type;
		 Item_List				: in      List_Type);

	function Contains
		(List					: in	  List_Type;
		 Item					: in      Datum_Type)
		return boolean;

	function Get
		(List					: in      List_Type;
		 Index					: in      Range_Type)
		 return Datum_Type;

	function Format
		(List					: in      List_Type)
		return String;

	function Index_Of
		(List					: in      List_Type;
		 Item					: in      Datum_Type)
		return Range_Type;

	function JSON
		(List					: in      List_Type)
		return String;

	function Last_Index
		(List					: in      List_Type)
		return Range_Type;

	function Length
		(List					: in      List_Type)
		return Natural;

	procedure Remove
		(List					: in  out List_Type;
		 Index					: in      Range_Type);

	procedure Reset
		(List					: in  out List_Type);

	function Sort
		(List					: in      List_Type)
		return List_Type;

	
private
	type Element_Array_Type is array (Range_Type) of Datum_Type;
	
	type List_Type is record
		Length					: Natural := 0;
		Elements				: Element_Array_Type;
	end record;

end Ada_Lib.GenList;
