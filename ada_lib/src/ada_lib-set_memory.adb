with System.Storage_Elements;

procedure Ada_Lib.Set_Memory (
	Address						: in	 System.Address;
	Bits						: in	 Natural;
	Value						: in	 Natural) is

	Buffer						: System.Storage_Elements.Storage_Array (1 .. 
									System.Storage_Elements.Storage_Offset (
										(Bits + System.Storage_Unit - 1) /
										System.Storage_Unit));
	for Buffer'address use Address;

begin
	for Index in Buffer'range loop
		Buffer (Index) := System.Storage_Elements.Storage_Element (Value);
	end loop;
end Ada_Lib.Set_Memory;
	