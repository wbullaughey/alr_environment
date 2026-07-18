with Ada.Exceptions;

separate (OS)

	-------------------------------------------------------------------
	procedure Set_Priority (
		Priority				: in	 Priority_Type) is
	-------------------------------------------------------------------

	PRIO_PROCESS				: constant := 0;
--	PRIO_PGRP					: constant := 1;
--	PRIO_USER					: constant := 2;

	Nice_Table					: constant array (Priority_Type) of 
									Interfaces.C.Int := (
		Active_IO			=> -15,
		Background			=> 10,
		Default_Priority	=> 0,		-- web callback
		Low_Rate_Poller		=> 5,
		Scheduler			=> 1,
		User_Waiting		=> 0);

	function setpriority (
		Which					: in	 Interfaces.C.Int;
		Who						: in	 Interfaces.C.Int;
		Amount					: in	 Interfaces.C.Int
	) return Interfaces.C.Int;

	pragma Import (C, setpriority);

	begin
		if setpriority (PRIO_PROCESS, 0, Nice_Table (Priority)) /= 0 then
			Ada.Exceptions.Raise_Exception (
				Failed'identity, "OS nice failed with error code " &
				GNAT.OS_Lib.Errno'img);
		end if;
	end Set_Priority;
