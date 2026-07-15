   with Ada.Exceptions;
-- with Ada.Streams;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Strings;
--with Ada_Lib.Time;
with Ada_Lib.Trace;use Ada_Lib.Trace;
with GNAT.Sockets;
-- with Hex_IO;

package body Ada_Lib.Socket_IO.Client is

   use type Ada_Lib.Strings.String_Constant_Access;
-- use type Ada_Lib.Strings.String_Access_All;
-- use type Ada_Lib.Time.Time_Type;
-- use type Index_Type;
   use type GNAT.Sockets.Selector_Status;
-- use type GNAT.Sockets.Stream_Access;

   ---------------------------------------------------------------------------
   procedure Check_Read (
      Socket                     : in     Client_Socket_Type;
      Buffer                     : in     Buffer_Type) is
   ---------------------------------------------------------------------------

   begin
      Log_In (Trace, (if Socket.Read_Check = Null then "no " else "") &
         "read check");

      if Socket.Read_Check /= Null then
         declare
            Read_Check           : Read_Check_Type renames Socket.Read_Check.all;

         begin
            Log_Here (Trace, "buffer length" & Buffer'last'img &
               "Expected_Read_Length" & Read_Check.Expected_Read_Length'img);

            if Read_Check.Expected_Read_Length = 0 then     -- no write yet
               Log_Here (Trace, "lock " & Read_Check.Lock.Is_Locked'img);
               Read_Check.Lock.Lock;
               Read_Check.Lock.Unlock;
               if Read_Check.Expected_Read_Length = 0 then
                  raise Failed with "Expected_Read_Length not set";
               end if;
            end if;

            if Read_Check.Expected_Read_Length /= Buffer'last then
               raise Failed with "read length (" & Buffer'last'img &
                  ") not equal expected length (" &
                  Read_Check.Expected_Read_Length'img & ")";
            end if;


--          Read_Check.Pending_Read_Length := Buffer'last;
--
--          if Buffer'last > Read_Check.Expected_Read_Length then
--             raise Failed with "read length (" & Buffer'last'img &
--                ") exceeds expected length (" &
--                Read_Check.Expected_Read_Length'img & ")";
--          end if;
         end;
      end if;
      Log_Out (Trace);
   end Check_Read;

   ---------------------------------------------------------------------------
   overriding
   procedure Connect (
      Socket                     : in out Client_Socket_Type;
      Server_Name                : in     String;
      Port                       : in     Port_Type;
      Connection_Timeout         : in     Timeout_Type := 1.0;
      Default_Read_Timeout       : in     Timeout_Type := 1.0;
      Default_Write_Timeout      : in     Timeout_Type := 1.0;
      Reuse                      : in     Boolean := False;
      Expected_Read_Callback     : access procedure (
         Socket                  : in     Socket_Class_Access) := Null) is
   ---------------------------------------------------------------------------

      ------------------------------------------------------------------------
      procedure Failure_Close (
         Fault                   : in     Ada.Exceptions.Exception_Occurrence;
         Where                   : in     String) is
      ------------------------------------------------------------------------

      begin
         Log_Exception (Trace, Fault, "", Where);
         Socket.Open := False;
         Socket.GNAT_Socket_Open := False;
         GNAT.Sockets.Close_Socket (Socket.GNAT_Socket);
         Socket.Exception_Message.Construct (
            Ada.Exceptions.Exception_Message (Fault));
      end Failure_Close;
      ------------------------------------------------------------------------

      Host_Name                  : constant String := Server_Name & ":" &
                                       Ada_Lib.Strings.Trim (Port'img);
   begin
      Log_In (Trace, "preconnect socket " & Socket.Image &
         " open " & Socket.Open'img &
         Quote (" Server_Name", Server_Name) &
         " port" & Port'img &
         " timeout " & Connection_Timeout'img &
         Quote ( " Host_Name", Host_Name) &
         " reuse " & Reuse'img);

      declare
         Host_Entry                 : constant GNAT.Sockets.Host_Entry_Type :=
                                       GNAT.Sockets.Get_Host_By_Name (Server_Name);
      begin
         Log_Here (Tracing, "name found");
         declare
            Host_Address               : constant GNAT.Sockets.Inet_Addr_Type :=
                                          GNAT.Sockets.Addresses (Host_Entry);
            Host_Socket_Address        : constant GNAT.Sockets.Sock_Addr_Type := (
                                          Family   => GNAT.Sockets.Family_Inet,
                                          Addr     => Host_Address,
                                          Port     => Port);
            Status                     : GNAT.Sockets.Selector_Status;

         begin
            Log_Here (Tracing, "original handle " &
               GNAT.Sockets.Image (Socket.GNAT_Socket));
            GNAT.Sockets.Connect_Socket (Socket.GNAT_Socket, Host_Socket_Address,
                Connection_Timeout, Null, Status);

            Log_Here (Tracing, "connected socket " & Socket.Image &
               " connected status  " & Status'img);
            if Status /= GNAT.Sockets.Completed then
               raise Failed with "could not connect " & Host_Name;
            end if;
            Socket.Create_Stream (
               Default_Read_Timeout    => Default_Read_Timeout,
               Default_Write_Timeout   => Default_Write_Timeout);
            Socket.Set_Open;

            Log (Tracing, Here, Who & " Status " & Status'img & " exit");
         end;
      end;

      if Expected_Read_Callback /= Null then
         Log_Here (Tracing);
         Expected_Read_Callback (Socket'unchecked_access);
      end if;

      if Reuse then
         declare
            Socket_Option        : GNAT.Sockets.Option_Type (Reuse_Address);

         begin
            Socket_Option.Enabled := True;
            GNAT.Sockets.Set_Socket_Option (Socket.GNAT_Socket,
               Level       => GNAT.Sockets.Socket_Level,
               Option      => Socket_Option);
         end;
      end if;

      Log_Out (Trace, "open " & Socket.Open'img & Socket.Image);

   exception
      when Fault: GNAT.SOCKETS.SOCKET_ERROR =>
         declare
            Message     : constant String := Socket.Description.all;

         begin
            Trace_Message_Exception (Trace, Fault, Message);

            Log_Exception (Trace, Fault);
            Ada.Exceptions.Raise_Exception (
               Ada.Exceptions.Exception_Identity (Fault), Message);
         end;

      when Fault: GNAT.SOCKETS.HOST_ERROR =>
         Failure_Close (Fault, Here);
         raise Failed with "Could not open host " & Host_Name &
            Socket.Description.all & " at " & Here;

      when Fault: others =>
         Failure_Close (Fault, Here);
         Ada.Exceptions.Raise_Exception (
            Ada.Exceptions.Exception_Identity (Fault),
            "Could not open host " & Host_Name & " " &
            Socket.Description.all & " at " & Here);


   end Connect;

   ---------------------------------------------------------------------------
   overriding
   procedure Connect (
      Socket                     : in out Client_Socket_Type;
      IP_Address                 : in     IP_Address_Type;
      Port                       : in     Port_Type;
      Connection_Timeout         : in     Timeout_Type := 1.0;
      Default_Read_Timeout       : in     Timeout_Type := 1.0;
      Default_Write_Timeout      : in     Timeout_Type := 1.0;
      Reuse                      : in     Boolean := False;
      Expected_Read_Callback     : access procedure (
         Socket                  : in     Socket_Class_Access) := Null) is
   ---------------------------------------------------------------------------

      Address                    : constant String :=
                                    Ada_Lib.Socket_IO.Image (IP_Address) & " Port" & Port'img;
   begin
      Socket.Initialize;
--    Socket.Set_Description (Description);
      Log_In (Trace, "connected socket " & Socket.Image &
         " for Address " & Ada_Lib.Socket_IO.Image (IP_Address));

      declare
         Ineternet_Address       : constant GNAT.Sockets.Inet_Addr_Type := (
                                    Family   => GNAT.Sockets.Family_Inet,
                                    Sin_V4   => IP_Address);
         Host_Socket_Address     : constant GNAT.Sockets.Sock_Addr_Type := (
                                    Family   => GNAT.Sockets.Family_Inet,
                                    Addr     => Ineternet_Address,
                                    Port     => Port);
         Status                  : GNAT.Sockets.Selector_Status;

      begin
         Log_Here (Trace);

         if Reuse then
            declare
               Socket_Option        : GNAT.Sockets.Option_Type (Reuse_Address);

            begin
               Socket_Option.Enabled := TRue;
               Log_Here (Trace, "set reuse");
               GNAT.Sockets.Set_Socket_Option (Socket.GNAT_Socket,
                  Level       => GNAT.Sockets.Socket_Level,
                  Option      => Socket_Option);
            end;
         end if;

         GNAT.Sockets.Connect_Socket (Socket.GNAT_Socket, Host_Socket_Address,
             Connection_Timeout, Null, Status);
         Log_Here (Trace, "Status " & Status'img);

         case Status is

            when GNAT.Sockets.Completed =>
               Socket.Create_Stream (
                  Default_Read_Timeout    => Default_Read_Timeout,
                  Default_Write_Timeout   => Default_Write_Timeout);
               Socket.Set_Open;

            when GNAT.Sockets.Expired =>
               raise Failed with "timeout connection to " & Address;

            when GNAT.Sockets.Aborted =>
               raise Failed with "connection to " & Address & "rejected";

         end case;

         if Expected_Read_Callback /= Null then
            Log_Here (Trace);
            Socket.Read_Check := new Read_Check_Type;
            Expected_Read_Callback (Socket'unchecked_access);
         end if;

      exception
         when Fault: others =>
               Trace_Exception (Trace, Fault);
               raise Failed with Ada.Exceptions.Exception_Message (Fault);
      end;

      Log_Here (Trace);
      Socket.Set_Open;

      Log_Out (Trace);

   exception
      when Fault: others =>
            Trace_Exception (Trace, Fault);
            raise Failed with Ada.Exceptions.Exception_Message (Fault);

   end Connect;

   ---------------------------------------------------------------------------
   overriding
   procedure Connect (
      Socket                     : in out Client_Socket_Type;
      Address                    : in     Address_Type'class;
      Port                       : in     Port_Type;
      Connection_Timeout         : in     Timeout_Type := 1.0;
      Default_Read_Timeout       : in     Timeout_Type := 1.0;
      Default_Write_Timeout      : in     Timeout_Type := 1.0;
      Reuse                      : in     Boolean := False;
      Expected_Read_Callback     : access procedure (
         Socket                  : in     Socket_Class_Access) := Null) is
   ---------------------------------------------------------------------------

   begin
      Socket.Initialize;
--    Socket.Set_Description (Description);
      Log_In (Trace, "connected socket " & Socket.Image &
         " for Address " & Address.Image);

      case Address.Address_Kind is

         when IP =>
            Socket.Connect (Address.IP_Address, Port, Connection_Timeout,
               Default_Read_Timeout, Default_Write_Timeout, Reuse,
               Expected_Read_Callback);

         when Not_Set =>
            Log_Exception (Trace);
            raise Failed with "address not set raised at " & Here;

         when URL =>
            Socket.Connect (Address.URL_Address.Coerce, Port, Connection_Timeout,
               Default_Read_Timeout, Default_Write_Timeout, Reuse,
               Expected_Read_Callback);

      end case;
      Log_Out (Trace);

   exception
      when Fault: others =>
            Log_Exception (Trace, Fault);
            raise Failed with Ada.Exceptions.Exception_Message (Fault);

   end Connect;

-- ---------------------------------------------------------------------------
-- procedure Create_Stream (
--    Socket                     : in out Client_Socket_Type) is
-- ---------------------------------------------------------------------------
--
-- begin
--    Log_In (Trace, Tag_Name (" socket", Client_Socket_Type'class (Socket)'tag));
--    Socket.Stream.GNAT_Stream := GNAT.Sockets.Stream (Socket.GNAT_Socket);
--    Socket.Stream.Create (Socket);
--    Log_Out (Trace);
-- end Create_Stream;

   ---------------------------------------------------------------------------
   overriding
   procedure Finalize (
      Socket                     : in out Client_Socket_Type) is
   ---------------------------------------------------------------------------

   begin
      Log_In (Trace, Socket.Image);
      Ada_Lib.Socket_IO.Stream_IO.Stream_Socket_Type (Socket).Finalize;
      Log_Out (Trace);
   end Finalize;

   ---------------------------------------------------------------------------
   function Has_Read_Check (
      Socket                     : in     Client_Socket_Type
   ) return Boolean is
   ---------------------------------------------------------------------------

   begin
      return Socket.Read_Check /= Null;
   end Has_Read_Check;

-- ---------------------------------------------------------------------------
-- function In_Buffer (
--    Socket                     : in   Client_Socket_Type
-- ) return Natural is
-- pragma Unreferenced (Socket);
-- ---------------------------------------------------------------------------
--
-- begin
--    Not_Implemented;
--    return 0;
-- end In_Buffer;

   ---------------------------------------------------------------------------
   overriding
   procedure Initialize (
      Socket                     : in out Client_Socket_Type) is
   ---------------------------------------------------------------------------

   begin
      Log_In (Trace, "socket address " & Ada_Lib.Strings.Image (Socket'address));
      Ada_Lib.Socket_IO.Stream_IO.Stream_Socket_Type (Socket).Initialize;
      Log_Out (Trace, " exit");
   end Initialize;

-- ---------------------------------------------------------------------------
-- function Is_Connected (
--    Socket                     : in     Client_Socket_Type
-- ) return Boolean is
-- ---------------------------------------------------------------------------
--
-- begin
--    Log_In (Trace, "open " & Socket.Open'img &
--       " connected " & Socket.Connected'img);
--    return Socket.Open and then Socket.Connected;
-- end Is_Connected;

-- ---------------------------------------------------------------------------
-- overriding
-- function Is_Open (
--    Socket                     : in     Client_Socket_Type
-- ) return Boolean is
-- ---------------------------------------------------------------------------
--
-- begin
--    return Ada_Lib.Socket_IO.Root_Socket.Socket_Type (Socket).Is_Open and
--       Socket.Connected
-- end Is_Open;

-- ---------------------------------------------------------------------------
-- procedure Read (
--    Socket                     : in out Client_Socket_Type;
--    Buffer                     :    out Buffer_Type;
--    Timeout_Length             : in     Duration := No_Timeout) is
-- ---------------------------------------------------------------------------
--
-- begin
--    Log_In (Trace, "socket " & Ada_Lib.Strings.Image (Socket'address) & " " &
--       Socket.Is_Connected'img & " Timeout_Length " & Timeout_Length'img);
--    pragma Warnings (Off, "*may be referenced before it has a value");
--    Socket.Check_Read (Buffer);   -- only used for 'left attribute
--    pragma Warnings (On, "*may be referenced before it has a value");
--    Ada_Lib.Socket_IO.Root_Socket.Socket_Type (Socket).Read (Buffer, Timeout_Length);
--    Log_Out (Trace);
-- end Read;

-- ---------------------------------------------------------------------------
-- procedure Set_Open (
--    Socket                     : in out Client_Socket_Type) is
-- ---------------------------------------------------------------------------
--
-- begin
--    Log_In (Trace);
--    Socket.Connected := True;
-- end Set_Open;

   ---------------------------------------------------------------------------
   procedure Set_Expected_Read_Length (
      Socket                     : in out Client_Socket_Type;
      Length                     : in     Index_Type) is
   ---------------------------------------------------------------------------

   begin
      Log_In (Trace, "length" & Length'img);
      Socket.Read_Check.Expected_Read_Length := Length;
      Socket.Read_Check.Lock.Lock;
      Log_Out (Trace);
   end Set_Expected_Read_Length;

   ---------------------------------------------------------------------------
   procedure Unlock (
      Socket                     : in out Client_Socket_Type) is
   ---------------------------------------------------------------------------

   begin
      if Socket.Read_Check /= Null then
         Socket.Read_Check.Lock.Unlock;
      end if;
   end Unlock;

-- ---------------------------------------------------------------------------
-- function Was_Created (
--    Socket                     : in     Client_Socket_Type
-- ) return Boolean is
-- ---------------------------------------------------------------------------
--
-- begin
--    return Socket;
-- end Was_Created;

-- ---------------------------------------------------------------------------
-- procedure Write (
--    Socket                     : in out Client_Socket_Type;
--    Buffer                     : in     Buffer_Type) is
-- ---------------------------------------------------------------------------
--
-- begin
--    Ada_Lib.Socket_IO.Root_Socket.Socket_Type (Socket).Write (Buffer);
-- end Write;

begin
--Trace := True;
   Log_Here (Trace);

end Ada_Lib.Socket_IO.Client;


