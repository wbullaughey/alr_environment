with Interfaces.C;

procedure Ada_Lib.Zero_Fill (
	Address						: in	 System.Address;
	Bits						: in	 Natural) is

   procedure memset (
      Address              : in   System.Address;
      Value             : in   Interfaces.C.int;
      Bytes             : in   Interfaces.C.size_t);

   pragma Import (C, memset);


begin
	memset (Address, 0, Interfaces.C.size_t ((Bits - 1) / System.Storage_Unit + 1));
end Ada_Lib.Zero_Fill;