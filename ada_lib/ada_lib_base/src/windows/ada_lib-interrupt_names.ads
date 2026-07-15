with Ada.Interrupts;

package Ada_Lib.Interrupt_Names is

	type Interrupt_Type is (
		SIGABRT,        --  used by abort,
		SIGTERM,  		-- break (Ctrl-Break)
		SIGFPE,         --  floating point exception
		SIGILL,         --  illegal instruction (not reset)
		SIGINT         --  interrupt (rubout)
	);

	type Callback_Access		is access procedure (
		Interrupt				: in	 Interrupt_Type);

	function Handler (
		Interrupt				: in	 Interrupt_Type
	) return Ada.Interrupts.Parameterless_Handler;

	function Map (
		Interrupt				: in	 Interrupt_Type
	) return Ada.Interrupts.Interrupt_ID;

	procedure Set_Callback (
		Callback				: in	 Callback_Access);

end Ada_Lib.Interrupt_Names;
