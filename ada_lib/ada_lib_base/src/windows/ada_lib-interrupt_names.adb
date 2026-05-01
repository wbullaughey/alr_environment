with Ada.Interrupts.Names;

package body Ada_Lib.Interrupt_Names is

	pragma Unreserve_All_Interrupts;

	protected Handlers is
		procedure SIGABRT_Handler;
		pragma Interrupt_Handler (SIGABRT_Handler);
		procedure SIGTERM_Handler;
		pragma Interrupt_Handler (SIGTERM_Handler);
		procedure SIGFPE_Handler;
		pragma Interrupt_Handler (SIGFPE_Handler);
		procedure SIGILL_Handler;
		pragma Interrupt_Handler (SIGILL_Handler);
		procedure SIGINT_Handler;
		pragma Interrupt_Handler (SIGINT_Handler);
	end Handlers;

	type Table_Entry_Type		is record
		Interrupt				: Ada.Interrupts.Interrupt_ID;
		Handler					: Ada.Interrupts.Parameterless_Handler;
	end record;

	Handler_Callback			: Callback_Access := NULL;

	Table				: constant array (Interrupt_Type) of Table_Entry_Type := (
		SIGABRT		=> ( Ada.Interrupts.Names.SIGABRT,Handlers.SIGABRT_Handler'access ),
		SIGTERM		=> ( Ada.Interrupts.Names.SIGTERM,Handlers.SIGTERM_Handler'access ),
		SIGFPE		=> ( Ada.Interrupts.Names.SIGFPE, Handlers.SIGFPE_Handler'access ),
		SIGILL		=> ( Ada.Interrupts.Names.SIGILL, Handlers.SIGILL_Handler'access ),
		SIGINT		=> ( Ada.Interrupts.Names.SIGINT, Handlers.SIGINT_Handler'access )
	);

	-------------------------------------------------------------------
	function Handler (
		Interrupt				: in	 Interrupt_Type
	) return Ada.Interrupts.Parameterless_Handler is
	-------------------------------------------------------------------

	begin
		return Table (Interrupt).Handler;
	end Handler;

	-------------------------------------------------------------------
	function Map (
		Interrupt				: in	 Interrupt_Type
	) return Ada.Interrupts.Interrupt_ID is
	-------------------------------------------------------------------

	begin
		return Table (Interrupt).Interrupt;
	end Map;

	-------------------------------------------------------------------
	procedure Set_Callback (
		Callback				: in	 Callback_Access) is
	-------------------------------------------------------------------

	begin
		Handler_Callback := Callback;
	end Set_Callback;

	-------------------------------------------------------------------

	protected body Handlers is

		procedure SIGABRT_Handler  is

		begin
			Handler_Callback (SIGABRT);
		end SIGABRT_Handler;

		procedure SIGTERM_Handler  is

		begin
			Handler_Callback (SIGTERM);
		end SIGTERM_Handler;

		procedure SIGFPE_Handler  is

		begin
			Handler_Callback (SIGFPE);
		end SIGFPE_Handler;

		procedure SIGILL_Handler  is

		begin
			Handler_Callback (SIGILL);
		end SIGILL_Handler;

		procedure SIGINT_Handler  is

		begin
			Handler_Callback (SIGINT);
		end SIGINT_Handler;

	end Handlers;


end Ada_Lib.Interrupt_Names;
