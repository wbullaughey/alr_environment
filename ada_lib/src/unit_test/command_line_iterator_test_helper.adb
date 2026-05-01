with Command_Line_Iterator;use Command_Line_Iterator;

package body Command_Line_Iterator_Test_Helper is

	use type Ada.Exceptions.Exception_Id;

	Exception_Table				: constant array (Positive range <>) of 
									Ada.Exceptions.Exception_Id := (
		Invalid_Option'identity,
		Invalid_Number'identity,
		No_Argument'identity,
		No_Parameter'identity,
		No_Selection'identity,
		Not_Argument'identity,
		Not_Option'identity);

	function Exception_ID (
		Index					: in	 Positive
	) return Ada.Exceptions.Exception_Id is

	begin
		return Exception_Table (Index);
	end Exception_ID;

	function Exception_Number (
		ID						: in	 Ada.Exceptions.Exception_Id
	) return Positive is

	begin
		for Index in Exception_Table'range loop
			if ID = Exception_Table (Index) then
				return Index;
			end if;
		end loop;

		raise Not_Found;
	end Exception_Number;

end Command_Line_Iterator_Test_Helper;