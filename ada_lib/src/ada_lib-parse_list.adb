with Ada.Exceptions;

package body Ada_Lib.Parse_List is

	type Seperator_Type			is (
		Comma, Dash, None);
	
	---------------------------------------------------------------------------	
	function Get_Token (
		Source					: in	 String;
		Seperator				: access Seperator_Type;
		Start					: access Positive
	) return String is
	---------------------------------------------------------------------------	
	
		Have_Number				: Boolean := False;
		In_Number				: Boolean := False;
		Result					: String (1 .. Source'last);
		Result_Index			: Natural := 0;
		
	begin
		for Source_Index in Source'range loop
			declare
				Byte			: constant Character := Source (Source_Index);
				
			begin		
				case Byte is
				
					when '-' =>
						if Source_Index = Source'last then
							Ada.Exceptions.Raise_Exception (Invalid'identity);
						end if;
							
						if Have_Number or In_Number then
							Seperator.all := Dash;
							Start.all := Source_Index + 1;
							return Result (1 .. Result_Index);
						end if;	
						
						Ada.Exceptions.Raise_Exception (Invalid'identity);
						
					when ' ' =>
						if In_Number then
							In_Number := False;
							Have_Number := True;
						end if;	
					
					when ',' =>
						if Source_Index = Source'last then
							Ada.Exceptions.Raise_Exception (Invalid'identity);
						end if;	
							
						if Have_Number or In_Number then
							Seperator.all := Comma;
							Start.all := Source_Index + 1;
							return Result (1 .. Result_Index);
						end if;	
						
						Ada.Exceptions.Raise_Exception (Invalid'identity);
					
					when '0' .. '9' =>
						if Have_Number then
							Seperator.all := Comma;
							Start.all := Source_Index + 1;
							return Result (1 .. Result_Index);
						end if;	

						In_Number := True;
							
						Result_Index := Result_Index + 1;
						Result (Result_Index) := Byte;
													
					when others =>
						Ada.Exceptions.Raise_Exception (Invalid'identity);
						
				end case;
			end;		
		end loop;
		
		Seperator.all := None;
		Start.all := Source'last + 1;
		return Result (1 .. Result_Index);
	end Get_Token;
	
	---------------------------------------------------------------------------	
	procedure To_Set (
		List						: in	 String;
		Result						:	 out Set_Package.Set_Type) is
	---------------------------------------------------------------------------	
	
		In_Range					: Boolean := False;
		Start						: aliased Positive := List'first;
		Start_Range					: Set_Package.Index_Type := Set_Package.Index_Type'last;
	
	begin
		Result := Set_Package.Null_Set;
	
		while Start <= List'last loop
			declare
				Seperator			: aliased Seperator_Type;
				Token				: constant String := Get_Token (
										List (Start .. List'last), 
										Seperator'unchecked_access, Start'unchecked_access);
			begin
				if Token'length = 0 then
					Ada.Exceptions.Raise_Exception (Invalid'identity);
				end if;
			
				declare
					Value			: constant Set_Package.Index_Type :=
										Set_Package.Index_Type'value (Token);
				begin					
	--Log_Here ("seperator " &	Seperator'img & " value '" & Value'img & "'");
			
					case Seperator is
			
						when Comma | None =>
							if In_Range then
								for Index in Start_Range .. Value loop
									Result (Index) := True;
								end loop;
						
								In_Range := False;
							else
								Result (Value) := True;
							end if;
							
							if Seperator = None then
								return;				
							end if;
							
						when Dash =>
							if In_Range then
								Ada.Exceptions.Raise_Exception (Invalid'identity);
							end if;
					
							In_Range := True;
							Start_Range := Value;
					
					end case;	
				end;
			end;
		end loop;
	
	exception
		when Fault: Constraint_Error =>
			Ada.Exceptions.Raise_Exception (Invalid'identity,
				Ada.Exceptions.Exception_Message (Fault));
		
	end To_Set;
			
	---------------------------------------------------------------------------	
	procedure To_Vector (
		List					: in	 String;
		Result					:	 out Set_Package.Vector_Type;
		Length					:	 out Natural) is
	---------------------------------------------------------------------------	
	
		In_Range					: Boolean := False;
		Result_Index				: Natural := Result'first - 1; 
		Start						: aliased Positive := List'first;
		Start_Range					: Set_Package.Index_Type := Set_Package.Index_Type'last;
	
	begin
		Length := 0;
		
		while Start <= List'last loop
			declare
				Seperator			: aliased Seperator_Type;
				Token				: constant String := Get_Token (
										List (Start .. List'last), 
										Seperator'unchecked_access, Start'unchecked_access);
			begin
				if Token'length = 0 then
					Ada.Exceptions.Raise_Exception (Invalid'identity);
				end if;
			
				declare
					Value			: constant Set_Package.Index_Type :=
										Set_Package.Index_Type'value (Token);
				begin					
	--Log_Here ("seperator " &	Seperator'img & " value '" & Value'img & "'");
			
					case Seperator is
			
						when Comma | None =>
							if In_Range then
								for Index in Start_Range .. Value loop
									Result_Index := Result_Index + 1;
									Result (Result_Index) := Index;
									Length := Length + 1;
								end loop;
						
								In_Range := False;
							else
								Result_Index := Result_Index + 1;
								
								if Result_Index > Result'last then
									raise Overflow;
								end if;
									
								Result (Result_Index) := Value;
								Length := Length + 1;
							end if;
							
							if Seperator = None then
								return;				
							end if;
							
						when Dash =>
							if In_Range then
								Ada.Exceptions.Raise_Exception (Invalid'identity);
							end if;
					
							In_Range := True;
							Start_Range := Value;
					
					end case;	
				end;
			end;
		end loop;
	
	exception
		when Fault: Constraint_Error =>
			Ada.Exceptions.Raise_Exception (Invalid'identity,
				Ada.Exceptions.Exception_Message (Fault));
		
	end To_Vector;
	
	package body To_List is

		---------------------------------------------------------------------------	
		procedure Parse (
			Source					: in	 String;
			List					:	 out List_Type;
			Length					:	 out Natural) is
		---------------------------------------------------------------------------	
	
			In_Range					: Boolean := False;
			Result_Index				: Natural := List'first - 1; 
			Start						: aliased Positive := Source'first;
			Start_Range					: Value_Type := Value_Type'last;
	
		begin
			Length := 0;
		
			while Start <= Source'last loop
				declare
					Seperator			: aliased Seperator_Type;
					Token				: constant String := Get_Token (
											Source (Start .. Source'last), 
											Seperator'unchecked_access, Start'unchecked_access);
				begin
					if Token'length = 0 then
						Ada.Exceptions.Raise_Exception (Invalid'identity);
					end if;
			
					declare
						Value			: constant Value_Type :=
											Value_Type'value (Token);
					begin					
		--Log_Here ("seperator " &	Seperator'img & " value '" & Value'img & "'");
			
						case Seperator is
			
							when Comma | None =>
								if In_Range then
									for Index in Start_Range .. Value loop
										Result_Index := Result_Index + 1;
										List (Result_Index) := Index;
										Length := Length + 1;
									end loop;
						
									In_Range := False;
								else
									Result_Index := Result_Index + 1;
								
									if Result_Index > List'last then
										raise Overflow;
									end if;
									
									List (Result_Index) := Value;
									Length := Length + 1;
								end if;
							
								if Seperator = None then
									return;				
								end if;
							
							when Dash =>
								if In_Range then
									Ada.Exceptions.Raise_Exception (Invalid'identity);
								end if;
					
								In_Range := True;
								Start_Range := Value;
					
						end case;	
					end;
				end;
			end loop;
	
		exception
			when Fault: Constraint_Error =>
				Ada.Exceptions.Raise_Exception (Invalid'identity,
					Ada.Exceptions.Exception_Message (Fault));
		
		end Parse;
	end To_List;	

end Ada_Lib.Parse_List;