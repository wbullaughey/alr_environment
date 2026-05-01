with Ada_Lib.Trace;use Ada_Lib.Trace;

package body Ada_Lib.Socket_IO.Server is

-- use type GNAT.Sockets.Stream_Access;

   ---------------------------------------------------------------------------
   procedure Accept_Socket (
      Server_Socket              : in out Server_Socket_Type;
      Accepted_Socket            :    out Accepted_Socket_Type'class;
      Accept_Timeout             : in     Duration := No_Timeout;
      Default_Read_Timeout       : in     Duration := No_Timeout;
      Default_Write_Timeout      : in     Duration := No_Timeout;
      Priority                   : in     Ada_Lib.OS.Priority_Type :=
                                             Ada_Lib.OS.Default_Priority) is
   ---------------------------------------------------------------------------

      Client_Address             : GNAT.Sockets.Sock_Addr_Type;
      Status                     : GNAT.Sockets.Selector_Status;

   begin
--    Server_Socket.Set_Description (Server_Description);
--    Accepted_Socket.Set_Description (Accepted_Description);
--
      Log_In (Trace,
         "server socket " & Server_Socket.Image &
         " accepted socket " & Accepted_Socket.Image &
         " Default_Read_Timeout " & Format_Timeout (Default_Read_Timeout) &
         " Default_Write_Timeout " & Format_Timeout (Default_Write_Timeout));
      GNAT.Sockets.Accept_Socket (Server_Socket.GNAT_Socket,
         Accepted_Socket.GNAT_Socket, Client_Address, Accept_Timeout,
         Selector    => Null,
         Status      => Status);

      case Status is

         when GNAT.Sockets.Completed =>
            begin
               Accepted_Socket.Create_Stream;
--                Description    => Accepted_Description);
               Accepted_Socket.Set_Open;
               Log_Out (Trace, "accepted socket " & Accepted_Socket.Image);
               return;

            exception
               when Fault: others =>
                  declare
                     Message              : constant String := "Accept_Socket failed";

                  begin
                     Trace_Message_Exception (Fault, Message);
                     Log_Exception (Trace, Fault, "select failed");
                     raise Failed with Message;
                  end;
            end;

         when GNAT.Sockets.Expired =>
            Log_Exception (Trace, "select expired");
            Accepted_Socket.Open := False;
            raise Select_Timeout with "select timed out" &
               " for server " & Server_Socket.Description.all &
               " at " & Here;

         when GNAT.Sockets.Aborted =>
            Log_Exception (Trace, "select failed");
            Accepted_Socket.Open := False;
            raise Failed with "select failed";

      end case;
   end Accept_Socket;

-- ---------------------------------------------------------------------------
-- procedure Bind_Socket (
--    Socket                     : in out Server_Socket_Type;
--    Host_Entry                 : in     Host_Entry_Type;
--    Port                       : in     Port_Type) is
-- ---------------------------------------------------------------------------
--
--    Address                    : constant GNAT.Sockets.Sock_Addr_Type :=
--                                  GNAT.Sockets.Sock_Addr_Type'(
--                                  Family      => GNAT.Sockets.Family_Inet,
--                                  Addr        => (     -- Inet_Addr_Type (Family)
--                                     Family   => GNAT.Sockets.Family_Inet,
--                                     Sin_V4   => GNAT.Sockets.Addresses (Host_Entry).Sin_V4),
--                                  Port        => Port);
--
-- begin
--    GNAT.Sockets.Bind_Socket (Socket, Address);
-- end Bind_Socket;

-- ---------------------------------------------------------------------------
-- procedure Finalize (
--    Socket                     : in out Server_Socket_Type) is
-- ---------------------------------------------------------------------------
--
-- begin
--    GNAT.Sockets.Close_Socket (Socket);
-- end Finalize;

-- ---------------------------------------------------------------------------
-- procedure Connect (
--    Socket                     : in out Server_Socket_Type;
--    Server_Name                : in     String;
--    Port                       : in     Port_Type;
--    Connection_Timeout         : in     Timeout_Type := 1.0;
--    Expected_Read_Callback     : access procedure (
--       Socket                  : in     Socket_Class_Access) := Null) is
-- pragma Unreferenced (Socket, Server_Name, Port, Connection_Timeout, Expected_Read_Callback);
-- ---------------------------------------------------------------------------
--
-- begin
--    Not_Implemented;
-- end Connect;
--
   ---------------------------------------------------------------------------
   procedure Create_Stream (
      Socket                     : in out Server_Socket_Type) is
   ---------------------------------------------------------------------------

   begin
      Log_In (Trace);
      Not_Implemented;
      Log_Out (Trace);
   end Create_Stream;

   ---------------------------------------------------------------------------
   overriding
   function In_Buffer (
      Socket                     : in   Accepted_Socket_Type
   ) return Index_Type is
   pragma Unreferenced (Socket);
   ---------------------------------------------------------------------------

   begin
      Not_Implemented;
      return 0;
   end In_Buffer;

   ---------------------------------------------------------------------------
   overriding
   procedure Initialize (
      Socket                     : in out Server_Socket_Type) is
   ---------------------------------------------------------------------------

      Bind_Failed                : aliased constant String := "Bind Failed";
      Initialize_Failed          : aliased constant String := "Initialize Failed";
      Listen_Failed              : aliased constant String := "Listen Failed";
      Step                       : access constant String := Null;

   begin
      Log_In (Trace, "socket " & Socket.Image &
         " port" & Socket.Port'img);
      Step := Initialize_Failed'access;
      Socket_Type (Socket).Initialize;
      Log_Here (Trace);
      Step := Bind_Failed'access;
      Socket.Bind (Socket.Port, Reuse => True);
      Step := Listen_Failed'access;
      Log_Here (Trace, "listen for socket");
      GNAT.Sockets.Listen_Socket (Socket.GNAT_Socket);
      Socket.Set_Open;
      Log_Out (Trace, "socket " & Socket.Image);

   exception
      when Fault: others =>
         declare
            Message              : constant String :=  Step.all &
                                    " server socket " & Socket.Image;
         begin
            Trace_Message_Exception (Fault, Message);
            Log_Exception (Trace, Fault);
            raise Failed with Message;
         end;
   end Initialize;

-- ---------------------------------------------------------------------------
-- overriding
-- procedure Initialize (
--    Socket                     : in out Accepted_Socket_Type) is
-- ---------------------------------------------------------------------------
--
-- begin
--    Log_In (Trace, "socket " & Socket.Image);
--    Ada_Lib.Socket_IO.Stream_IO.Stream_Socket_Type (Socket).Initialize;
--    Log_Out (Trace);
-- end Initialize;

-- ---------------------------------------------------------------------------
-- function Is_Connected (
--    Socket                     : in     Accepted_Socket_Type
-- ) return Boolean is
-- ---------------------------------------------------------------------------
--
-- begin
--    Log_Here (Trace, "Accepted " & Socket.Accepted'img);
--    return Socket.Accepted;
-- end Is_Connected;

   ---------------------------------------------------------------------------
   overriding
   function Is_Open (
      Socket                     : in     Accepted_Socket_Type
   ) return Boolean is
   ---------------------------------------------------------------------------

      Result                     : constant Boolean :=
                                    Ada_Lib.Socket_IO.Stream_IO.Stream_Socket_Type (Socket).Is_Open;
   begin
      return Log_Here (Result,
         Trace or Trace_Pre_Post_Conditions, "socket not open");
   end Is_Open;

-- ---------------------------------------------------------------------------
-- procedure Read (
--    Socket                     : in out Accepted_Socket_Type;
--    Buffer                     :    out Buffer_Type;
--    Timeout_Length             : in     Duration := No_Timeout) is
-- ---------------------------------------------------------------------------
--
-- begin
--    Socket.Read (Buffer, Timeout_Length);
-- end Read;

   ---------------------------------------------------------------------------
   procedure Set_Closed (
      Socket                     : in out Accepted_Socket_Type) is
   ---------------------------------------------------------------------------

   begin
      Socket.Server_Closed := True;
   end Set_Closed;

-- ---------------------------------------------------------------------------
-- procedure Set_Open (
--    Socket                     : in out Accepted_Socket_Type) is
-- ---------------------------------------------------------------------------
--
-- begin
--    Socket.Accepted := True;
-- end Set_Open;

-- ---------------------------------------------------------------------------
-- procedure Set_Option (
--    Socket                     : in out Server_Socket_Type;
--    Option                     : in     Option_Type) is
-- ---------------------------------------------------------------------------
--
--    Socket_Option              : GNAT.Sockets.Option_Type (Option);
--
-- begin
--    Log_In (Trace, "option " & Option'img);
--    Socket_Option.Enabled := TRue;
--
--    GNAT.Sockets.Set_Socket_Option (Socket,
--       Level       => GNAT.Sockets.Socket_Level,
--       Option      => Socket_Option);
--    Log_Out (Trace);
-- end Set_Option;

-- ---------------------------------------------------------------------------
-- procedure Set_Option (
--    Socket                     : in out Accepted_Socket_Type;
--    Option                     : in     Option_Type) is
-- ---------------------------------------------------------------------------
--
--    Socket_Option              : GNAT.Sockets.Option_Type (Option);
--
-- begin
--    Log_In (Trace, "option " & Option'img);
--          Socket_Option.Enabled := TRue;
--
--    GNAT.Sockets.Set_Socket_Option (Socket,
--       Level       => GNAT.Sockets.Socket_Level,
--       Option      => Socket_Option);
--    Log_Out (Trace);
-- end Set_Option;


--   ---------------------------------------------------------------------------
--   procedure Write (
--      Socket                     : in out Accepted_Socket_Type;
--      Buffer                     : in     Buffer_Type) is
--   ---------------------------------------------------------------------------
--
--   begin
--      Socket.Write (Buffer);
-- end Write;

begin
-- Trace := True;
   Log_Here (Trace);
end Ada_Lib.Socket_IO.Server;
