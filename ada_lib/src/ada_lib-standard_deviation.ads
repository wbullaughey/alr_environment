generic

	type Data_Type				is digits <>;

package Ada_Lib.Standard_Deviation is

	Failed						: exception;
	No_Data						: exception;

	type Calculate_Type			is private;

	procedure Add_Value (
		Calculate				: in out Calculate_Type;
		Value					: in	 Data_Type);

	function Count (
		Calculate				: in	 Calculate_Type
	) return Natural;

	function Mean (
		Calculate				: in	 Calculate_Type
	) return Data_Type;

	function Result (
		Calculate				: in	 Calculate_Type
	) return Data_Type;

private

	type Calculate_Type			is record
		Count       			: Natural := 0;
		Sum    					: Long_Float := 0.0;
		Squares 				: Long_Float := 0.0;
	end record;

end Ada_Lib.Standard_Deviation;
