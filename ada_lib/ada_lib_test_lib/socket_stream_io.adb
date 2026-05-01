-- package provides socket server to off load and on load 
-- meta data via stream over socket

with Ada.Text_IO; use  Ada.Text_IO;
with Ada_Lib.Socket_Stream_IO;
with GNAT.Sockets;
with Interrupt_Handler;
with Trace;

package body Socket_Stream_IO is

	Traceing					: constant Boolean := True;

	task Server_Task;
		
	Accept_Socket				: GNAT.Sockets.Socket_Type;
	Socket_Created				: Boolean := False;

	---------------------------------------------------------------------------
	procedure Control_C_Callback is

	begin
		Socket_Stream_IO.Stop;
	end Control_C_Callback;
	---------------------------------------------------------------------------

	---------------------------------------------------------------------------
	procedure Initialize is
	---------------------------------------------------------------------------

	begin
		Interrupt_Handler.Enable_Control_C_Abort (Control_C_Callback'access);
	end Initialize;

	---------------------------------------------------------------------------
	procedure Process_Requst (
		Connect_Socket			: in	 GNAT.Sockets.Socket_Type) is
	---------------------------------------------------------------------------

		Selector				: GNAT.Sockets.Selector_Type;
		Socket_Set				: GNAT.Sockets.Socket_Set_Type;
		Stream					: aliased Ada_Lib.Socket_Stream_IO.Stream_Type;
		 
	begin
		Ada_Lib.Socket_Stream_IO.Create (Stream, Connect_Socket, 5.0, 1.0);
		Trace.Log (Traceing, Trace.Here, "stream created");				

		begin
			loop
				declare
					Request			: String (1 .. 3);

				begin
					String'Read (Stream'access, Request);
					Put_Line ("got request '" & Request & "'");

					if Request = "end" then
						exit;
					elsif Request = "t 1" then
						null;	-- everything ok
					elsif Request (1 .. 2) = "t2" then
						Put_Line ("should not get this request");
					elsif Request = "t 3" then
						delay 10.0;	-- let write fail
						exit;
					end if;
				end;
			end loop;

		exception

			when Fault: Ada_Lib.Socket_Stream_IO.Timeout =>
				Trace.Trace_Exception (Fault, Trace.Here,
					"Timeout on socket IO");

			when Fault: others =>
				Trace.Trace_Exception (Fault, Trace.Here,
					"process request failed");
			
		end;

		Ada_Lib.Socket_Stream_IO.Close (Stream);

	end Process_Requst;

	---------------------------------------------------------------------------
	procedure Socket_Server is
	---------------------------------------------------------------------------

	begin
		begin
			GNAT.Sockets.Create_Socket (Accept_Socket);
			Socket_Created := True;
			Trace.Log (Traceing, Trace.Here, "socket created");				
				
		exception
			when Fault: GNAT.Sockets.Socket_Error =>
				Trace.Trace_Exception (Fault, Trace.Here,
					"Could not create Socket_Stream_IO socket");
			return;
		end;

		begin
			GNAT.Sockets.Bind_Socket (Accept_Socket, GNAT.Sockets.Sock_Addr_Type'(
				Addr	=> GNAT.Sockets.Any_Inet_Addr,
				Family	=> GNAT.Sockets.Family_Inet,
				Port	=> Accept_Port
			));
			Trace.Log (Traceing, Trace.Here, "socket bound");				

		exception
			when Fault: GNAT.Sockets.Socket_Error =>
				Trace.Trace_Exception (Fault, Trace.Here,
					"Could not bind Socket_Stream_IO socket");
			return;
		end;

		begin
			GNAT.Sockets.Listen_Socket (Accept_Socket, 1);	-- only accept one connectin at a time
			Trace.Log (Traceing, Trace.Here, "socket listening");				

		exception
			when Fault: GNAT.Sockets.Socket_Error =>
				Trace.Trace_Exception (Fault, Trace.Here,
					"Could not listen on Socket_Stream_IO socket");
			return;
		end;

		loop
			declare
				Connect_Socket	: GNAT.Sockets.Socket_Type;
				Connected		: Boolean := False;

			begin
				declare
					Connect_Address	: GNAT.Sockets.Sock_Addr_Type;
				begin
					GNAT.Sockets.Accept_Socket (Accept_Socket, Connect_Socket, Connect_Address);
					Trace.Log (Traceing, Trace.Here, "socket accepted");				
					Connected := True;

				exception
					when Fault: GNAT.Sockets.Socket_Error =>
						Trace.Trace_Exception (Fault, Trace.Here,
							"Connect to Socket_Stream_IO failed");
				end;

				if Connected then
					Process_Requst (Connect_Socket);
        			GNAT.Sockets.Close_Socket (Connect_Socket);
					Trace.Log (Traceing, Trace.Here, "connect socket closed");				
				end if;
			end;
		end loop;
	end;

	---------------------------------------------------------------------------
	procedure Stop is
	---------------------------------------------------------------------------

	begin
		Trace.Log (Traceing, Trace.Here, "stop socket_stream_io");				
		
		Abort Server_Task;

		if Socket_Created then
			Socket_Created := False;
			GNAT.Sockets.Close_Socket (Accept_Socket);
			Trace.Log (Traceing, Trace.Here, "socket closed");				
		end if;
	end Stop;

	---------------------------------------------------------------------------
	task body Server_Task is

	begin
		Socket_Server;
					
	exception

		when Fault: others =>
			Trace.Trace_Exception (Fault, Trace.Here,
				"unexpected exception in Socket_Stream_IO socket");
			
	end Server_Task;

end Socket_Stream_IO;