with Ada.Exceptions;

package Command_Line_Iterator_Test_Helper is

	Not_Found					: exception;

	function Exception_ID (
		Index					: in	 Positive
	) return Ada.Exceptions.Exception_Id;

	function Exception_Number (
		ID						: in	 Ada.Exceptions.Exception_Id
	) return Positive;

end Command_Line_Iterator_Test_Helper;