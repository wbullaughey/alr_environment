with Ada_Lib.Set;

package Ada_Lib.Parse_List is

	Invalid						: Exception;
	Overflow					: Exception;
	
	generic
	
		with package Set_Package
								is new Ada_Lib.Set (<>);

	procedure To_Set (
		List					: in	 String;
		Result					:	 out Set_Package.Set_Type);

	generic
	
		with package Set_Package
								is new Ada_Lib.Set (<>);

	procedure To_Vector (
		List					: in	 String;
		Result					:	 out Set_Package.Vector_Type;
		Length					:	 out Natural);

	generic

		type Value_Type			is ( <> );
		
	package To_List is

		type List_Type			is array (Positive range <> ) of Value_Type;

		procedure Parse (
			Source				: in	 String;
			List				:	 out List_Type;
			Length				:	 out Natural);

	end To_List;

end Ada_Lib.Parse_List;		