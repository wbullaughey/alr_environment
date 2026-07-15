with Ada.Exceptions;
with Ada.Strings.Fixed;
with Ada_Lib.Trace;use Ada_Lib.Trace;
with Strings;

package body Ada_Lib.SNMP is

--	pragma Linker_Options("-L/home/wayne/vendor/net-snmp/snmplib/.libs");
	pragma Linker_Options("-L/usr/local/lib");
	pragma Linker_Options ("-lnetsnmp");

	Retry						: exception;

	use type Interfaces.C.int;
	use type Interfaces.C.size_t;
	use type Interfaces.C.unsigned;
	use type System.Address;

	MAX_OID_LEN					: constant := 128;

	type Code_Type				is new Interfaces.Unsigned_32;

	ASN_BIT_STR	    			: constant Code_Type := 16#03#;
--	ASN_BOOLEAN	    			: constant Code_Type := 16#01#;
	ASN_CONSTRUCTOR 			: constant Code_Type := 16#20#;
	ASN_CONTEXT	    			: constant Code_Type := 16#80#;
	ASN_INTEGER	    			: constant Code_Type := 16#02#;
--	ASN_NULL	    			: constant Code_Type := 16#05#;
	ASN_OBJECT_ID				: constant Code_Type := 16#06#;
	ASN_OCTET_STR				: constant Code_Type := 16#04#;
	ASN_PRIMITIVE	    		: constant Code_Type := 16#00#;
--	ASN_SEQUENCE				: constant Code_Type := 16#10#;
--	ASN_SET		    			: constant Code_Type := 16#11#;
	SNMP_MSG_GET				: constant Code_Type := 
									ASN_CONTEXT or 
									ASN_CONSTRUCTOR or 16#0#;
--  SNMP_MSG_GETNEXT			: constant Code_Type :=
--  								ASN_CONTEXT or
--  								ASN_CONSTRUCTOR or 16#1#;
--  SNMP_MSG_RESPONSE			: constant Code_Type :=
--  								ASN_CONTEXT or
--  								ASN_CONSTRUCTOR or 16#2#;
	SNMP_MSG_SET				: constant Code_Type :=
									ASN_CONTEXT or
									ASN_CONSTRUCTOR or 16#3#;

	SNMP_NOSUCHOBJECT    		: constant Code_Type := ASN_CONTEXT or ASN_PRIMITIVE or 16#0#; -- 80=128 
	SNMP_NOSUCHINSTANCE  		: constant Code_Type := ASN_CONTEXT or ASN_PRIMITIVE or 16#1#; -- 81=129 
	SNMP_ENDOFMIBVIEW    		: constant Code_Type := ASN_CONTEXT or ASN_PRIMITIVE or 16#2#; -- 82=130 
	  
--	type Variable_Kind_Type		is new Interfaces.C.Unsigned_Char;

	type Unsigned_Char_Array	is array (Interfaces.C.size_t range <>) of
									Interfaces.C.unsigned_char;  

	type OID_Type				is new Interfaces.Unsigned_32;
	type OID_Array				is array (Interfaces.C.size_t range <>) of OID_Type;
	type PDU_Kind_Type			is new Interfaces.Unsigned_32;

--  type Counter64_Type 		is record
--      high					: Interfaces.C.Unsigned_Long;
--      low						: Interfaces.C.Unsigned_Long;
--  end record;

	type Netsnmp_Vardata_Type (
		Kind					: Code_Type := 0) is record 

		case Kind is

			when ASN_INTEGER =>
				Integer_Value	: Interfaces.C.long;

			when ASN_OCTET_STR =>
				String_Value	: Interfaces.C.unsigned_char;

			when ASN_OBJECT_ID =>
				objid			: OID_Type;

			when ASN_BIT_STR =>
				bitstring		: Interfaces.C.unsigned_char;

--  		counter64				: Counter64_Type;
--  		floatVal				: Integer.C.float;
--  		doubleVal				: Integer.C.double;
			when others =>
				Other_Value		: Integer;
		end case;
   --
   -- t_union *unionVal; 
   --
	end record;
	pragma Unchecked_Union (Netsnmp_Vardata_Type);

	type Variable_List_Type;

	type Variable_List_Access	is access all Variable_List_Type;

	type Variable_List_Type		is record
		--  NULL for last variable */
		next_variable			: Variable_List_Access;    
		--  Object identifier of variable */
		name					: access OID_Type;   
		--  number of subid's in name */
		name_length				: Interfaces.C.size_t;    
		--  ASN type of variable */
		variable_type			: Interfaces.C.unsigned_char;   
		--  value of variable */
		val						: Netsnmp_Vardata_Type;
		--  the length of the value to be copied into buf */
		val_len					: Interfaces.C.size_t;
		--  buffer to hold the OID */
		name_loc 				: OID_Array (0 .. MAX_OID_LEN - 1);  
		--  90 percentile < 40. */
		buf						: Unsigned_Char_Array (0 .. 39);
		--  (Opaque) hook for additional data */
		data					: System.Address;
		--  callback to free above */
		dataFreeHook			: System.Address;    
		index					: Interfaces.C.int;
	end record;

	type PDU_Type				is record
--
-- Protocol-version independent fields
--
-- snmp version */
		version					: Interfaces.C.long;
		-- Type of this PDU */	
		command					: Interfaces.C.int;
		-- Request id - note: not incremented on retries */
		reqid					: Interfaces.C.long;  
		-- Message id for V3 messages note: incremented for each retry */
		msgid					: Interfaces.C.long;
		-- Unique ID for incoming transactions */
		transid					: Interfaces.C.long;
		-- Session id for AgentX messages */
		sessid					: Interfaces.C.long;
		-- Error status (non_repeaters in GetBulk) */
		errstat					: Interfaces.C.long;
		-- Error index (max_repetitions in GetBulk) */
		errindex				: Interfaces.C.long;       
		-- Uptime */
		time					: Interfaces.C.unsigned_long;   
		flags					: Interfaces.C.unsigned_long;
		
		securityModel			: Interfaces.C.int;
		-- noAuthNoPriv, authNoPriv, authPriv */
		securityLevel			: Interfaces.C.int;  
		msgParseModel			: Interfaces.C.int;
		
		--
		-- Transport-specific opaque data.  This replaces the IP-centric address
		-- field.  
		--
		
		transport_data			: System.Address;
		transport_data_length	: Interfaces.C.int;
		
		--
		-- The actual transport domain.  This SHOULD NOT BE FREE()D.  
		--
		
		tDomain					: access constant OID_Type;
		tDomainLen				: Interfaces.C.size_t;
		
		variables				: Variable_List_Access;
		
		--
		-- SNMPv1 & SNMPv2c fields
		--
		-- community for outgoing requests. */
		community				: access Interfaces.C.unsigned_char;
		-- length of community name. */
		community_len			: Interfaces.C.size_t;  
		
		--
		-- Trap information
		--
		-- System OID */
		enterprise				: access OID_Type;     
		enterprise_length		: Interfaces.C.size_t;
		-- trap type */
		trap_type				: Interfaces.C.long;
		-- specific type */
		specific_type			: Interfaces.C.long;
		-- This is ONLY used for v1 TRAPs  */
		agent_addr				: Unsigned_Char_Array (0 .. 3);  
		
		--
		--  SNMPv3 fields
		--
		-- context snmpEngineID */
		contextEngineID			: access Interfaces.C.unsigned_char;
		-- Length of contextEngineID */
		contextEngineIDLen	   : Interfaces.C.size_t;     
		-- authoritative contextName */
		contextName				: access Interfaces.C.char;
		-- Length of contextName */
		contextNameLen			: Interfaces.C.size_t;
		-- authoritative snmpEngineID for security */
		securityEngineID		: access Interfaces.C.unsigned_char;
		-- Length of securityEngineID */
		securityEngineIDLen	 	: Interfaces.C.size_t;    
		-- on behalf of this principal */
		securityName			: access Interfaces.C.char;
		-- Length of securityName. */
		securityNameLen			: Interfaces.C.size_t;        
		
		--
		-- AgentX fields
		--      (also uses SNMPv1 community field)
		--
		priority				: Interfaces.C.int;
		range_subid				: Interfaces.C.int;
		
		securityStateRef		: System.Address;
	end record;

	type PDU_Access				is access all PDU_Type;

	subtype Status_Type			is Interfaces.C.Int;

		procedure snmp_add_null_var (
			pdu					: in	 PDU_Access;
			oid					: in	 OID_Array;
			Count				: in	 Interfaces.C.size_t);
		pragma Import (C, snmp_add_null_var);

		procedure snmp_add_var (
			pdu					: in	 PDU_Access;
			oid					: in	 OID_Array;
			Count				: in	 Interfaces.C.size_t;
			Value_Type			: in	 Interfaces.C.char;
			Value				: in	 Interfaces.C.Strings.chars_ptr);
		pragma Import (C, snmp_add_var);

		procedure snmp_free_pdu (
			Response			: in	 PDU_Access);
		pragma Import (C, snmp_free_pdu);

		function snmp_parse_oid (
			Source				: in	 Interfaces.C.Strings.chars_ptr;
			Destination 		: in	 OID_Array;
			Space_Left			: access Interfaces.C.size_t
		) return access OID_Type;
		pragma Import (C, snmp_parse_oid);

		function snmp_pdu_create (
			PUD_Kind			: in	 PDU_Kind_Type
		) return PDU_Access;
		pragma Import (C, snmp_pdu_create);

		function snmp_synch_response (
			Pointer				: in	 Pointer_Type;
			PDU 				: in	 PDU_Access;
			Response			: access PDU_Access
		) return Status_Type;
		pragma Import (C, snmp_synch_response);

	Status_Success  			: constant Status_Type := 0;
	Status_Error  				: constant Status_Type := 1;
	Status_Timeout 				: constant Status_Type := 2;
	Trace						: constant Boolean := False;

	Value_Kind_Table			: constant array (Value_Kind_Type) of Interfaces.C.char := (
		Integer_Kind	=> Interfaces.C.To_C ('i')
	);
	Version_Table				: constant Array (Version_Type) of 
									access constant String := (
		Version_1	=> new String'("1"),
		Version_2c	=> new String'("2c"),
		Version_3	=> new String'("3")
	);

	--------------------------------------------------------------------
	procedure Close (
		Session					: in out Session_Type) is
	--------------------------------------------------------------------

		procedure free_snmp (
			Session				: in	 Structure_Type);
		pragma Import (C, free_snmp);

	begin
-- log (Here, Who);
		for Index in Session.Arguments'First .. Session.Argument_Count loop
			Interfaces.C.Strings.Free (Session.Arguments (Index));
		end loop;

		if Session.Structure /= Null_Structure then
			free_snmp (Session.Structure);
			Session.Structure := Null_Structure;
		end if;
-- log (Here, Who);
	end Close;

	--------------------------------------------------------------------
	procedure Diagnose_Error (
		Where					: in	 String;
		Session					: in	 Session_Type) is
	--------------------------------------------------------------------
	
		procedure snmp_sess_perror (
			Who					: in	 Interfaces.C.Strings.chars_ptr;
			Session				: in	 Structure_Type);
		pragma Import (C, snmp_sess_perror);

		Message					: Interfaces.C.Strings.chars_ptr :=
									Interfaces.C.Strings.New_String (Where);

	begin
		snmp_sess_perror (Message, Session.Structure);
		Interfaces.C.Strings.Free (Message);
	end Diagnose_Error;

	--------------------------------------------------------------------
	function Get (
		Session					: in	 Session_Type;
		Name					: in	 String
	) return String is
	--------------------------------------------------------------------
	
		----------------------------------------------------------------
		function Return_Value (
			PDU					: in	 PDU_Access
		) return String is
		----------------------------------------------------------------

			function snprint_variable(
				buffer			: in	 Interfaces.C.char_array;
				buffer_length	: in	 Interfaces.C.size_t;
                objid			: access OID_Type; 
				objidlen		: in	 Interfaces.C.size_t;
                variable		: in	 Variable_List_Access
			) return Interfaces.C.Int;
			pragma Import (C, snprint_variable);

			Buffer				: aliased Interfaces.C.char_array := (
									1 .. 1000 => Interfaces.C.nul);
			Length				: Interfaces.C.int;
			Variables			: constant Variable_List_Access := PDU.variables;

		begin
-- log (here, who & " variable type " & Variables.variable_Type'img);

			Length := snprint_variable (Buffer, Buffer'Length, 
				Variables.Name, Variables.name_length, Variables);

			if Length >= 0 then
				declare
					Result		: constant String := Interfaces.C.Strings.Value (
						Interfaces.C.Strings.To_Chars_Ptr (Buffer'unchecked_access, False), 
						Interfaces.C.size_t (Length));
					Equal		: constant Natural := Ada.Strings.Fixed.Index (Result, "=");

				begin
					if Equal > 0 then
						declare
							Colon		: constant Natural := Ada.Strings.Fixed.Index (
											Result (Equal + 1 .. Result'last), ":");
						begin
							if Colon > 1 then
								return Strings.Trim (Result (Colon + 1 .. Result'last));
							else
								return Result;
							end if;
						end;
					else
						return Result;
					end if;
				end;
			else
  				Ada.Exceptions.Raise_Exception (Error'Identity,
					"snprint_variable failed");
			end if;

--  		case Code_Type (Variables.variable_type) is
--
--  			when SNMP_NOSUCHOBJECT =>
--  				Ada.Exceptions.Raise_Exception (Error'Identity,
--                      "No Such Object available on this agent at this OID");
--
--  			when SNMP_NOSUCHINSTANCE =>
--  				Ada.Exceptions.Raise_Exception (Error'Identity,
--  					"No Such Instance currently exists at this OID");
--
--  			when SNMP_ENDOFMIBVIEW =>
--  				Ada.Exceptions.Raise_Exception (Error'Identity,
--  					"No more variables left in this MIB View (It is past the end of the MIB tree)");
--
--  			when ASN_INTEGER =>
--  				return Strings.Trim (Variables.val.Integer_Value'img);
--
--  			when others =>
--  				Ada.Exceptions.Raise_Exception (Error'Identity,
--  					"Unimplemented value type" & Variables.variable_Type'img);
--  		end case;
--
--  		return "";
		end Return_Value;
		----------------------------------------------------------------

		oid						: OID_Array (0 .. MAX_OID_LEN - 1);
		Count					: aliased Interfaces.C.size_t := oid'length;
		pdu						: constant PDU_Access := 
									snmp_pdu_create (PDU_Kind_Type (SNMP_MSG_GET));
		Response				: aliased PDU_Access := Null;
		C_Name					: Interfaces.C.Strings.chars_ptr :=
									Interfaces.C.Strings.New_String (Name);
	begin
		if snmp_parse_oid (C_Name, oid, Count'unchecked_access) = Null then
			Interfaces.C.Strings.Free (C_Name);
			Ada.Exceptions.Raise_Exception (Error'Identity,
				"OID parse error for " & Name);
		end if;

		snmp_add_null_var (pdu, oid, Count);

-- Log (Here, Who & count'img);
-- for Index in oid'First .. count - 1  loop
--    log (here, oid (index)'img);
-- end loop;

		loop								-- retry
-- log (here, who);
			declare
				Status			: constant Interfaces.C.Int := 
									snmp_synch_response (Session.Pointer, 
									pdu, response'unchecked_access);
			begin
-- log (here, who & status'img);
				case Status is

					when Status_Success =>
						if Trace then
							Log (Here, Who);
						end if;

						exit;

					when Status_Error =>
						Ada.Exceptions.Raise_Exception (Error'Identity,
							"snmpget failed");

					when Status_Timeout =>
						Ada.Exceptions.Raise_Exception (Failed'Identity,
							"timeout");

					when others =>
						Ada.Exceptions.Raise_Exception (Failed'Identity,
							"Unexpected status returned from snmp_synch_response" &
							Status'img);
				end case;

			exception
				when Retry =>
					Null;
			end;
exit;
		end loop;

		Interfaces.C.Strings.Free (C_Name);

		if Response /= Null then
			declare
				Result			: constant String :=
									Return_Value (Response);
			begin
				snmp_free_pdu (Response);
				return Result;
			end;
		else
			return "";
		end if;
	end Get;

	--------------------------------------------------------------------
	procedure Open (
		Session					:	 out Session_Type;
		Host					: in	 String;
		Version					: in	 Version_Type;
		Timeout					: in	 Option_Type := Default_Option;
		Retries					: in	 Option_Type := Default_Option) is
	--------------------------------------------------------------------

		function allocate_snmp return Structure_Type;
		pragma Import (C, allocate_snmp);

		function snmp_check_sizes (
			netsnmp_vardata_type: in	 Interfaces.C.unsigned;
			variable_list_type	: in	 Interfaces.C.unsigned;
			pdu_type			: in	 Interfaces.C.unsigned
		) return Interfaces.C.int;
		pragma Import (C, snmp_check_sizes);

		function snmp_parse_args (
			argc				: in	 Interfaces.C.int;
			argv				: in	 Interfaces.C.Strings.chars_ptr_array;
			session				: in	 Structure_Type;
			localOpts			: in	 Interfaces.C.Strings.chars_ptr;
			callback			: in	 System.Address
		) return Interfaces.C.Int;
		pragma Import (C, snmp_parse_args);

		function snmp_open (
			Structure			: in	 Structure_Type
		) return Pointer_Type;
		pragma Import (C, snmp_open);

--  	procedure snmp_sess_init(
--  		session				: in	 Session_Access);
--  	pragma Import (C, snmp_sess_init);
--
--  	procedure set_options (
--  		session				: in	 Session_Access;
--  		version				: in	 Version_Type;
--  		timeout				: in	 Option_Type;
--  		retries				: in	 Option_Type);
--  	pragma Import (C, set_options);

	begin
		if snmp_check_sizes (Netsnmp_Vardata_Type'Size / 8,
				Variable_List_Type'Size/ 8,
				Pdu_Type'Size/ 8) = 0 then
			Ada.Exceptions.Raise_Exception (Failed'Identity, "c struct size error");
		end if;

		Session.Structure := allocate_snmp;
--  	snmp_sess_init (Session.Structure);
--  	set_options (Session.Structure, Version, Timeout, Retries);

		Session.Arguments (0) := Interfaces.C.Strings.New_String ("Ada_Lib.SNMP");
		Session.Arguments (1) := Interfaces.C.Strings.New_String ("-v");
		Session.Arguments (2) := Interfaces.C.Strings.New_String (Version_Table (Version).all);
		Session.Arguments (3) := Interfaces.C.Strings.New_String ("-c");
		Session.Arguments (4) := Interfaces.C.Strings.New_String ("public");
		Session.Argument_Count := 5;

		if Timeout > 0 then
			Session.Arguments (Session.Argument_Count) := Interfaces.C.Strings.New_String ("-t");
			Session.Argument_Count := Session.Argument_Count + 1;
			Session.Arguments (Session.Argument_Count) := Interfaces.C.Strings.New_String (Timeout'img);
			Session.Argument_Count := Session.Argument_Count + 1;
		end if;
		
		if Retries > 0 then
			Session.Arguments (Session.Argument_Count) := Interfaces.C.Strings.New_String ("-r");
			Session.Argument_Count := Session.Argument_Count + 1;
			Session.Arguments (Session.Argument_Count) := Interfaces.C.Strings.New_String (Retries'img);
			Session.Argument_Count := Session.Argument_Count + 1;
		end if;

		Session.Arguments (Session.Argument_Count) := Interfaces.C.Strings.New_String (Host);
		Session.Argument_Count := Session.Argument_Count + 1;
-- log (Here, Who);
		declare
			Result			: constant Interfaces.C.Int :=
								snmp_parse_args (
									Interfaces.C.int (Session.Argument_Count), Session.Arguments, Session.Structure,
									Interfaces.C.Strings.Null_Ptr, System.Null_Address);
		begin
			case Result is
				when 0 =>			-- normal return
					null;
	
				when -1 | -3 =>		-- error parsing arguments
					Ada.Exceptions.Raise_Exception (Failed'Identity,
						"Invalid arguments passed to snmp_parse_args");
	
				when others =>
					if Result < 0 then
						Ada.Exceptions.Raise_Exception (Failed'Identity,
							"Unexpected result from snmp_parse_args:" & Result'img);
					end if;
					
			end case;
		end;
-- log (Here, Who);

--		Cleanup;

--		winsock_startup;	-- only need for windows

		Session.Pointer := snmp_open (Session.Structure);
-- log (Here, Who);

		if Session.Pointer = Null_Pointer then
			Ada.Exceptions.Raise_Exception (Error'Identity);
		end if;
-- log (Here, Who);
	end Open;

--  --------------------------------------------------------------------
--  procedure Parse_Arguments
--  --------------------------------------------------------------------
--
--  	function snmp_parse_args (
--  		argc				: in	 Interfaces.C.int;
--  		argv				: in	 Interfaces.C.char_array;
--  		session				: in	 Session_Access;
--  		local_opts			: access Interfaces.C.char;
--  		callback			: in	 System.Address);
--
--  	pramga import (C, snmp_parse_args);
--
--  begin
--  end Parse_Arguments;

	--------------------------------------------------------------------
	procedure Set (
		Session					: in	 Session_Type;
		Name					: in	 String;
		Value_Kind				: in	 Value_Kind_Type;
		Value					: in	 String) is
	--------------------------------------------------------------------
	
		oid						: OID_Array (0 .. MAX_OID_LEN - 1);
		Count					: aliased Interfaces.C.size_t := oid'length;
		pdu						: constant PDU_Access := 
									snmp_pdu_create (PDU_Kind_Type (SNMP_MSG_SET));
		Response				: aliased PDU_Access := Null;
		C_Name					: Interfaces.C.Strings.chars_ptr :=
									Interfaces.C.Strings.New_String (Name);
		C_Value					: Interfaces.C.Strings.chars_ptr :=
									Interfaces.C.Strings.New_String (Value);
	begin
		if snmp_parse_oid (C_Name, oid, Count'unchecked_access) = Null then
			Interfaces.C.Strings.Free (C_Name);
			Ada.Exceptions.Raise_Exception (Error'Identity,
				"OID parse error for " & Name);
		end if;

-- Log (Here, Who & count'img);
		snmp_add_var (pdu, oid, Count, Value_Kind_Table (Value_Kind), C_Value);
-- Log (Here, Who & count'img);
-- for Index in oid'First .. count - 1  loop
--    log (here, oid (index)'img);
-- end loop;

		declare
			Status			: constant Interfaces.C.Int := 
								snmp_synch_response (Session.Pointer, 
								pdu, response'unchecked_access);
		begin
-- log (here, who & status'img);
			case Status is

				when Status_Success =>
					if Trace then
						Log (Here, Who);
					end if;

				when Status_Error =>
					Ada.Exceptions.Raise_Exception (Error'Identity,
						"snmpset failed");

				when Status_Timeout =>
					Ada.Exceptions.Raise_Exception (Failed'Identity,
						"timeout");

				when others =>
					Ada.Exceptions.Raise_Exception (Failed'Identity,
						"Unexpected status returned from snmp_synch_response" &
						Status'img);
			end case;

		exception
			when Retry =>
				Null;
		end;

		Interfaces.C.Strings.Free (C_Name);
		Interfaces.C.Strings.Free (C_Value);

		if Response /= Null then
			snmp_free_pdu (Response);
		end if;
	end Set;

end Ada_Lib.SNMP;

