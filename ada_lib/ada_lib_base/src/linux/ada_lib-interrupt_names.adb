with Ada.Interrupts.Names;

package body Ada_Lib.Interrupt_Names is

	pragma Unreserve_All_Interrupts;

	protected Handlers is
		procedure SIGHUP_Handler;
		pragma Interrupt_Handler (SIGHUP_Handler);
		procedure SIGINT_Handler;
		pragma Interrupt_Handler (SIGINT_Handler);
		procedure SIGQUIT_Handler;
		pragma Interrupt_Handler (SIGQUIT_Handler);
		procedure SIGILL_Handler;
		pragma Interrupt_Handler (SIGILL_Handler);
		procedure SIGTRAP_Handler;
		pragma Interrupt_Handler (SIGTRAP_Handler);
		procedure SIGIOT_Handler;
		pragma Interrupt_Handler (SIGIOT_Handler);
		procedure SIGABRT_Handler;
		pragma Interrupt_Handler (SIGABRT_Handler);
		procedure SIGFPE_Handler;
		pragma Interrupt_Handler (SIGFPE_Handler);
		procedure SIGKILL_Handler;
		pragma Interrupt_Handler (SIGKILL_Handler);
		procedure SIGBUS_Handler;
		pragma Interrupt_Handler (SIGBUS_Handler);
		procedure SIGSEGV_Handler;
		pragma Interrupt_Handler (SIGSEGV_Handler);
		procedure SIGPIPE_Handler;
		pragma Interrupt_Handler (SIGPIPE_Handler);
		procedure SIGALRM_Handler;
		pragma Interrupt_Handler (SIGALRM_Handler);
		procedure SIGTERM_Handler;
		pragma Interrupt_Handler (SIGTERM_Handler);
		procedure SIGUSR1_Handler;
		pragma Interrupt_Handler (SIGUSR1_Handler);
		procedure SIGUSR2_Handler;
		pragma Interrupt_Handler (SIGUSR2_Handler);
		procedure SIGCLD_Handler;
		pragma Interrupt_Handler (SIGCLD_Handler);
		procedure SIGCHLD_Handler;
		pragma Interrupt_Handler (SIGCHLD_Handler);
		procedure SIGWINCH_Handler;
		pragma Interrupt_Handler (SIGWINCH_Handler);
		procedure SIGURG_Handler;
		pragma Interrupt_Handler (SIGURG_Handler);
		procedure SIGPOLL_Handler;
		pragma Interrupt_Handler (SIGPOLL_Handler);
		procedure SIGIO_Handler;
		pragma Interrupt_Handler (SIGIO_Handler);
		procedure SIGSTOP_Handler;
		pragma Interrupt_Handler (SIGSTOP_Handler);
		procedure SIGTSTP_Handler;
		pragma Interrupt_Handler (SIGTSTP_Handler);
		procedure SIGCONT_Handler;
		pragma Interrupt_Handler (SIGCONT_Handler);
		procedure SIGTTIN_Handler;
		pragma Interrupt_Handler (SIGTTIN_Handler);
		procedure SIGTTOU_Handler;
		pragma Interrupt_Handler (SIGTTOU_Handler);
		procedure SIGVTALRM_Handler;
		pragma Interrupt_Handler (SIGVTALRM_Handler);
		procedure SIGPROF_Handler;
		pragma Interrupt_Handler (SIGPROF_Handler);
		procedure SIGXCPU_Handler;
		pragma Interrupt_Handler (SIGXCPU_Handler);
		procedure SIGXFSZ_Handler;
		pragma Interrupt_Handler (SIGXFSZ_Handler);
		procedure SIGUNUSED_Handler;
		pragma Interrupt_Handler (SIGUNUSED_Handler);
		procedure SIGSTKFLT_Handler;
		pragma Interrupt_Handler (SIGSTKFLT_Handler);
		procedure SIGLOST_Handler;
		pragma Interrupt_Handler (SIGLOST_Handler);
		procedure SIGPWR_Handler;
		pragma Interrupt_Handler (SIGPWR_Handler);
	end Handlers;

	type Table_Entry_Type		is record
		Interrupt				: Ada.Interrupts.Interrupt_ID;
		Handler					: Ada.Interrupts.Parameterless_Handler;
	end record;

	Handler_Callback			: Callback_Access := NULL;

	Table				: constant array (Interrupt_Type) of Table_Entry_Type := (
		SIGHUP		=> ( Ada.Interrupts.Names.SIGHUP, Handlers.SIGHUP_Handler'access ),     --  hangup
		SIGINT		=> ( Ada.Interrupts.Names.SIGINT, Handlers.SIGINT_Handler'access ),     --  interrupt (rubout)
		SIGQUIT		=> ( Ada.Interrupts.Names.SIGQUIT, Handlers.SIGQUIT_Handler'access ),    --  quit (ASCD FS)
		SIGILL		=> ( Ada.Interrupts.Names.SIGILL, Handlers.SIGILL_Handler'access ),     --  illegal instruction (not reset)
		SIGTRAP		=> ( Ada.Interrupts.Names.SIGTRAP, Handlers.SIGTRAP_Handler'access ),    --  trace trap (not reset)
		SIGIOT		=> ( Ada.Interrupts.Names.SIGIOT, Handlers.SIGIOT_Handler'access ),    	--  IOT instruction
		SIGABRT		=> ( Ada.Interrupts.Names.SIGABRT,Handlers.SIGABRT_Handler'access ),	--  used by abort, Handlers.SIGABRT,	--  used by abort_Handler'access ),
		SIGFPE		=> ( Ada.Interrupts.Names.SIGFPE, Handlers.SIGFPE_Handler'access ),     --  floating point exception
		SIGKILL		=> ( Ada.Interrupts.Names.SIGKILL, Handlers.SIGKILL_Handler'access ),    --  kill (cannot be caught or ignored)
		SIGBUS		=> ( Ada.Interrupts.Names.SIGBUS, Handlers.SIGBUS_Handler'access ),     --  bus error
		SIGSEGV		=> ( Ada.Interrupts.Names.SIGSEGV, Handlers.SIGSEGV_Handler'access ),    --  segmentation violation
		SIGPIPE 	=> ( Ada.Interrupts.Names.SIGPIPE, Handlers.SIGPIPE_Handler'access ),	--  write on a pipe with
														--  no one to read it
		SIGALRM		=> ( Ada.Interrupts.Names.SIGALRM, Handlers.SIGALRM_Handler'access ),    --  alarm clock
		SIGTERM		=> ( Ada.Interrupts.Names.SIGTERM, Handlers.SIGTERM_Handler'access ),    --  software termination signal from kill
		SIGUSR1		=> ( Ada.Interrupts.Names.SIGUSR1, Handlers.SIGUSR1_Handler'access ),    --  user defined signal 1
		SIGUSR2		=> ( Ada.Interrupts.Names.SIGUSR2, Handlers.SIGUSR2_Handler'access ),    --  user defined signal 2
		SIGCLD		=> ( Ada.Interrupts.Names.SIGCLD, Handlers.SIGCLD_Handler'access ),     --  child status change
		SIGCHLD		=> ( Ada.Interrupts.Names.SIGCHLD, Handlers.SIGCHLD_Handler'access ),    --  4.3BSD's/POSIX name for SIGCLD
		SIGWINCH	=> ( Ada.Interrupts.Names.SIGWINCH, Handlers.SIGWINCH_Handler'access ),   --  window size change
		SIGURG		=> ( Ada.Interrupts.Names.SIGURG, Handlers.SIGURG_Handler'access ),     --  urgent condition on IO channel
		SIGPOLL		=> ( Ada.Interrupts.Names.SIGPOLL, Handlers.SIGPOLL_Handler'access ),    --  pollable event occurred
		SIGIO 		=> ( Ada.Interrupts.Names.SIGIO, Handlers.SIGIO_Handler'access ), 	--  input/output possible, Handlers.SIGIO,  	--  input/output possible_Handler'access ),
														--  SIGPOLL alias (Solaris)
		SIGSTOP		=> ( Ada.Interrupts.Names.SIGSTOP, Handlers.SIGSTOP_Handler'access ),    --  stop (cannot be caught or ignored)
		SIGTSTP		=> ( Ada.Interrupts.Names.SIGTSTP, Handlers.SIGTSTP_Handler'access ),    --  user stop requested from tty
		SIGCONT		=> ( Ada.Interrupts.Names.SIGCONT, Handlers.SIGCONT_Handler'access ),    --  stopped process has been continued
		SIGTTIN		=> ( Ada.Interrupts.Names.SIGTTIN, Handlers.SIGTTIN_Handler'access ),    --  background tty read attempted
		SIGTTOU		=> ( Ada.Interrupts.Names.SIGTTOU, Handlers.SIGTTOU_Handler'access ),    --  background tty write attempted
		SIGVTALRM	=> ( Ada.Interrupts.Names.SIGVTALRM, Handlers.SIGVTALRM_Handler'access ),  --  virtual timer expired
		SIGPROF		=> ( Ada.Interrupts.Names.SIGPROF, Handlers.SIGPROF_Handler'access ),    --  profiling timer expired
		SIGXCPU		=> ( Ada.Interrupts.Names.SIGXCPU, Handlers.SIGXCPU_Handler'access ),    --  CPU time limit exceeded
		SIGXFSZ		=> ( Ada.Interrupts.Names.SIGXFSZ, Handlers.SIGXFSZ_Handler'access ),    --  filesize limit exceeded
		SIGUNUSED	=> ( Ada.Interrupts.Names.SIGUNUSED, Handlers.SIGUNUSED_Handler'access ),  --  unused signal
		SIGSTKFLT	=> ( Ada.Interrupts.Names.SIGSTKFLT, Handlers.SIGSTKFLT_Handler'access ),  --  stack fault on coprocessor
		SIGLOST		=> ( Ada.Interrupts.Names.SIGLOST, Handlers.SIGLOST_Handler'access ),    --  Linux alias for SIGIO
		SIGPWR		=> ( Ada.Interrupts.Names.SIGPWR, Handlers.SIGPWR_Handler'access )      --  Power failure
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
		procedure SIGHUP_Handler  is

		begin
			Handler_Callback (SIGHUP);
		end SIGHUP_Handler;

		procedure SIGINT_Handler  is

		begin
			Handler_Callback (SIGINT);
		end SIGINT_Handler;

		procedure SIGQUIT_Handler  is

		begin
			Handler_Callback (SIGQUIT);
		end SIGQUIT_Handler;

		procedure SIGILL_Handler  is

		begin
			Handler_Callback (SIGILL);
		end SIGILL_Handler;

		procedure SIGTRAP_Handler  is

		begin
			Handler_Callback (SIGTRAP);
		end SIGTRAP_Handler;

		procedure SIGIOT_Handler  is

		begin
			Handler_Callback (SIGIOT);
		end SIGIOT_Handler;

		procedure SIGABRT_Handler  is

		begin
			Handler_Callback (SIGABRT);
		end SIGABRT_Handler;

		procedure SIGFPE_Handler  is

		begin
			Handler_Callback (SIGFPE);
		end SIGFPE_Handler;

		procedure SIGKILL_Handler  is

		begin
			Handler_Callback (SIGKILL);
		end SIGKILL_Handler;

		procedure SIGBUS_Handler  is

		begin
			Handler_Callback (SIGBUS);
		end SIGBUS_Handler;

		procedure SIGSEGV_Handler  is

		begin
			Handler_Callback (SIGSEGV);
		end SIGSEGV_Handler;

		procedure SIGPIPE_Handler  is

		begin
			Handler_Callback (SIGPIPE);
		end SIGPIPE_Handler;

		procedure SIGALRM_Handler  is

		begin
			Handler_Callback (SIGALRM);
		end SIGALRM_Handler;

		procedure SIGTERM_Handler  is

		begin
			Handler_Callback (SIGTERM);
		end SIGTERM_Handler;

		procedure SIGUSR1_Handler  is

		begin
			Handler_Callback (SIGUSR1);
		end SIGUSR1_Handler;

		procedure SIGUSR2_Handler  is

		begin
			Handler_Callback (SIGUSR2);
		end SIGUSR2_Handler;

		procedure SIGCLD_Handler  is

		begin
			Handler_Callback (SIGCLD);
		end SIGCLD_Handler;

		procedure SIGCHLD_Handler  is

		begin
			Handler_Callback (SIGCHLD);
		end SIGCHLD_Handler;

		procedure SIGWINCH_Handler  is

		begin
			Handler_Callback (SIGWINCH);
		end SIGWINCH_Handler;

		procedure SIGURG_Handler  is

		begin
			Handler_Callback (SIGURG);
		end SIGURG_Handler;

		procedure SIGPOLL_Handler  is

		begin
			Handler_Callback (SIGPOLL);
		end SIGPOLL_Handler;

		procedure SIGIO_Handler  is

		begin
			Handler_Callback (SIGIO);
		end SIGIO_Handler;

		procedure SIGSTOP_Handler  is

		begin
			Handler_Callback (SIGSTOP);
		end SIGSTOP_Handler;

		procedure SIGTSTP_Handler  is

		begin
			Handler_Callback (SIGTSTP);
		end SIGTSTP_Handler;

		procedure SIGCONT_Handler  is

		begin
			Handler_Callback (SIGCONT);
		end SIGCONT_Handler;

		procedure SIGTTIN_Handler  is

		begin
			Handler_Callback (SIGTTIN);
		end SIGTTIN_Handler;

		procedure SIGTTOU_Handler  is

		begin
			Handler_Callback (SIGTTOU);
		end SIGTTOU_Handler;

		procedure SIGVTALRM_Handler  is

		begin
			Handler_Callback (SIGVTALRM);
		end SIGVTALRM_Handler;

		procedure SIGPROF_Handler  is

		begin
			Handler_Callback (SIGPROF);
		end SIGPROF_Handler;

		procedure SIGXCPU_Handler  is

		begin
			Handler_Callback (SIGXCPU);
		end SIGXCPU_Handler;

		procedure SIGXFSZ_Handler  is

		begin
			Handler_Callback (SIGXFSZ);
		end SIGXFSZ_Handler;

		procedure SIGUNUSED_Handler  is

		begin
			Handler_Callback (SIGUNUSED);
		end SIGUNUSED_Handler;

		procedure SIGSTKFLT_Handler  is

		begin
			Handler_Callback (SIGSTKFLT);
		end SIGSTKFLT_Handler;

		procedure SIGLOST_Handler  is

		begin
			Handler_Callback (SIGLOST);
		end SIGLOST_Handler;

		procedure SIGPWR_Handler  is

		begin
			Handler_Callback (SIGPWR);
		end SIGPWR_Handler;

	end Handlers;


end Ada_Lib.Interrupt_Names;
