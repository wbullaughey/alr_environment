with Interfaces.C.Strings;
with System;

package Ada_Lib.SNMP is

	Error						: exception;
	Failed						: exception;

	Default_Option				: constant := 0;

	type Option_Type			is range Default_Option .. Natural'Last;
	type Session_Type			is tagged private;

	type Session_Access			is access Session_Type;

--	type Values_Array			is array (Positive range <>) of access String;

	type Value_Kind_Type		is (Integer_Kind);

	type Version_Type			is (Version_1, Version_2c, Version_3);

	procedure Close (
		Session					: in out Session_Type);

	procedure Diagnose_Error (
		Where					: in	 String;
		Session					: in	 Session_Type);

	function Get (
		Session					: in	 Session_Type;
		Name					: in	 String
	) return String;

	procedure Open (
		Session					:	 out Session_Type;
		Host					: in	 String;
		Version					: in	 Version_Type;
		Timeout					: in	 Option_Type := Default_Option;
		Retries					: in	 Option_Type := Default_Option);

	procedure Set (
		Session					: in	 Session_Type;
		Name					: in	 String;
		Value_Kind				: in	 Value_Kind_Type;
		Value					: in	 String);

private
	type Pointer_Type			is new System.Address;
	type Structure_Type			is new System.Address;
	 
	Null_Pointer				: constant Pointer_Type :=
									Pointer_Type (System.Null_Address);
	Null_Structure				: constant Structure_Type :=
									Structure_Type (System.Null_Address);

	type Session_Type			is tagged record
		Pointer					: Pointer_Type := Null_Pointer;
		Structure				: Structure_Type := Null_Structure;
		Arguments				: Interfaces.C.Strings.chars_ptr_array (0 .. 10);
		Argument_Count			: Interfaces.C.size_t := 0;
	end record;
	
end Ada_Lib.SNMP;
