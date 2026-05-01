-- with Ada.Exceptions;
with Ada.Streams;
with Ada.Strings.Fixed;
with Ada_Lib.Trace; use Ada_Lib.Trace;

package body Ada_Lib.Telnet is

-- Telnet_Port             : constant := 23;
   Trace                : Boolean := False;

   -------------------------------------------------------------------
   procedure Close (
      Telnet               : in out Telnet_Type) is
   -------------------------------------------------------------------

   begin
      Log_In (Trace);
--      Telnet.Socket.Close;
----    Socket_Stream_IO.Close (Telnet.Stream);
----    GNAT.Sockets.Close_Socket (Telnet.Socket);
      Log_Out (Trace);
   end Close;

   -------------------------------------------------------------------
   procedure Open (
      Telnet               :   out Telnet_Type;
      Host              : in   String) is
   pragma Unreferenced (Telnet, Host);
   -------------------------------------------------------------------

   begin
      Log_In (Trace);
--      Telnet.Socket.Initialize;
----    GNAT.Sockets.Create_Socket (Telnet.Socket,
----       Family   => GNAT.Sockets.Family_Inet,
----       Mode  => GNAT.Sockets.Socket_Stream);
--
----    GNAT.Sockets.Bind_Socket (Telnet.Socket,
----       Address  => GNAT.Sockets.No_Sock_Addr);
--
--      Telnet.Socket.Connect
--      begin
--         declare
--            Host_Entry        : constant GNAT.Sockets.Host_Entry_Type :=
--                              GNAT.Sockets.Get_Host_By_Name (Host);
--            Address           : constant GNAT.Sockets.Inet_Addr_Type :=
--                              GNAT.Sockets.Addresses (Host_Entry);
--         begin
--            GNAT.Sockets.Connect_Socket (Telnet.Socket,
--               (case Address.Family is
--                  when GNAT.Sockets.Family_Inet =>
--                     GNAT.Sockets.Sock_Addr_Type'(
--                        Addr  => Address,
--                        Family   => GNAT.Sockets.Family_Inet,
--                        Port  => Telnet_Port),
--
--                  when GNAT.Sockets.Family_Inet6 =>
--                     GNAT.Sockets.Sock_Addr_Type'(
--                        Addr  => Address,
--                        Family   => GNAT.Sockets.Family_Inet6,
--                        Port  => Telnet_Port)
--
----                when GNAT.Sockets.Family_Unix =>
----                   GNAT.Sockets.Sock_Addr_Type'(
----                      Name  => "",
----                      Family   => GNAT.Sockets.Family_Unix)
--
----                when GNAT.Sockets.Family_UNSPEC =>
----                   GNAT.Sockets.Sock_Addr_Type'(
----                      Addr  => Address,
----                      Family   => GNAT.Sockets.Family_UNSPEC,
----                      Port  => Telnet_Port)
--                ));
--            Socket_Stream_IO.Create (Telnet.Stream,
--               Telnet.Socket);
--
--         end;
--
--      exception
--         when Fault: GNAT.Sockets.Socket_Error |
--                  GNAT.Sockets.Host_Error =>
--            Ada.Exceptions.Raise_Exception (Failed'Identity,
--               "Could not open socket to switch " & Host &
--               " Error: " & Ada.Exceptions.Exception_Message (Fault));
--      end;
      Log_Out (Trace);
   end Open;

   -------------------------------------------------------------------
   -- return what ever is in the input buffer
   function Receive (
      Telnet               : access Telnet_Type;
      Wait_Time            : in   Duration := 0.0
   ) return String is
   -------------------------------------------------------------------

      Item           : Ada.Streams.Stream_Element_Array (1 .. 4096);
      Last           : Ada.Streams.Stream_Element_Offset := 0;

   begin
      Log_In (Trace);
      if Wait_Time > 0.0 then
         delay Wait_Time;
      end if;
      Telnet.Socket.Read (
         Buffer      => Item,
         Last        => Last);

      declare
         Line     : String (1 .. Natural (Last));
            for Line'Address use Item'address;

      begin
         Log_Out (Trace);
         return Line;
      end;
   end Receive;

   -------------------------------------------------------------------
   procedure Send (
      Telnet               : in out Telnet_Type;
      Line              : in   String) is
   -------------------------------------------------------------------

      Item                 : Ada.Streams.Stream_Element_Array (1 .. Line'length);
      for Item'Address use Line'Address;

   begin
      Log_In (Trace);
--    if Trace then
--       Log_Here ("send '" & Line & "'");
--    end if;
--
--    Socket_Stream_IO.Write (Telnet.Stream, Item);
      Log_Out (Trace);
   end Send;

   -------------------------------------------------------------------
   procedure Set_Trace (
      State             : in   Boolean) is
   -------------------------------------------------------------------

   begin
      Trace := State;
   end Set_Trace;

   -------------------------------------------------------------------
   procedure Wait_For (
      Telnet               : in out Telnet_Type;
      Pattern              : in   String;
      At_End               : in   Boolean := False;
      At_Start          : in   Boolean := False) is
   -------------------------------------------------------------------

   begin
      if Trace then
         Log_Here ("wait for '" & Pattern & "'");
      end if;

      loop
         declare
            Line     : constant String := Telnet.Receive (0.5);
            Start_Match : constant Natural :=
                        Ada.Strings.Fixed.Index (Line, Pattern);
         begin
            if Trace then
               Log_Here ("'" & Line & "'");
            end if;

            if Start_Match > 0 then
               declare
                  Ok    : Boolean := True;

               begin
                  if At_End then
                     if Start_Match + Pattern'Length - 1 /= Line'length then
                        Ok := False;
                     end if;
                  end if;

                  if At_Start then
                     if Start_Match /= Line'first then
                        Ok := False;
                     end if;
                  end if;

                  if Ok then
                     if Trace then
                        Log_Here ("got '" & Pattern & "'");
                     end if;

                     return;
                  end if;
               end;
            end if;
         end;
      end loop;
   end Wait_For;

end Ada_Lib.Telnet;

