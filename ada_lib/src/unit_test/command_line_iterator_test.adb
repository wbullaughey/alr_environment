with Ada.Command_Line;
with Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;
with Command_Line_Iterator; use Command_Line_Iterator;
with Command_Line_Iterator_Test_Helper; use Command_Line_Iterator_Test_Helper;

procedure Command_Line_Iterator_Test is

	use type Ada.Command_Line.Exit_Status;

	Iterator					: Iterator_Type := Initialize (True, True, "");

begin
	Put_Line ("test command line iterator package");
	
	while not At_End (Iterator) loop
		if Is_Option (Iterator) then
			declare
				Option			: constant Character :=	Get_Option (Iterator);

			begin
				Put_Line ("option " & Option);
			end;
		else
			Put_Line ("parameter '" & Get_Parameter (Iterator));
		end if;

		Advance (Iterator);
	end loop;
	 
	Ada.Command_Line.Set_Exit_Status (0);

exception
	when Fault: others =>
		Put_Line (Ada.Exceptions.Exception_Name (Fault));
		Put_Line (Ada.Exceptions.Exception_Message (Fault));

		begin
			Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Exit_Status (
				Exception_Number (
					Ada.Exceptions.Exception_Identity (Fault))));

		exception
			when others =>
				Ada.Command_Line.Set_Exit_Status (-1);
		end;
end Command_Line_Iterator_Test;