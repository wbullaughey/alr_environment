with Ada.Interrupts;

package Ada_Lib.Interrupt_Names is

	type Interrupt_Type is (
		SIGHUP,			--  hangup
		SIGINT,         --  interrupt (rubout)
		SIGQUIT,        --  quit (ASCD FS)
		SIGILL,         --  illegal instruction (not reset)
		SIGTRAP,        --  trace trap (not reset)
		SIGIOT,         --  IOT instruction
		SIGABRT,        --  used by abort,
		SIGFPE,         --  floating point exception
		SIGKILL,        --  kill (cannot be caught or ignored)
		SIGBUS,         --  bus error
		SIGSEGV,        --  segmentation violation
		SIGPIPE,        --  write on a pipe with
						--  no one to read it
		SIGALRM,        --  alarm clock
		SIGTERM,        --  software termination signal from kill
		SIGUSR1,        --  user defined signal 1
		SIGUSR2,        --  user defined signal 2
		SIGCLD,         --  child status change
		SIGCHLD,        --  4.3BSD's/POSIX name for SIGCLD
		SIGWINCH,       --  window size change
		SIGURG,         --  urgent condition on IO channel
		SIGPOLL,        --  pollable event occurred
		SIGIO,          --  input/output possible,
						--  SIGPOLL alias (Solaris)
		SIGSTOP,        --  stop (cannot be caught or ignored)
		SIGTSTP,        --  user stop requested from tty
		SIGCONT,        --  stopped process has been continued
		SIGTTIN,        --  background tty read attempted
		SIGTTOU,        --  background tty write attempted
		SIGVTALRM,      --  virtual timer expired
		SIGPROF,        --  profiling timer expired
		SIGXCPU,        --  CPU time limit exceeded
		SIGXFSZ,        --  filesize limit exceeded
		SIGUNUSED,      --  unused signal
		SIGSTKFLT,      --  stack fault on coprocessor
		SIGLOST,        --  Linux alias for SIGIO
		SIGPWR          --  Power failure
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
