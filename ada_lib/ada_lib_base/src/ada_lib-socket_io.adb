--with Ada.Text_IO; use Ada.Text_IO;
-- with Ada.Streams;
-- with Ada.Unchecked_Deallocation;
-- with Socket_Stream_IO;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Strings; use Ada_Lib.Strings;
with Ada_Lib.Trace;use Ada_Lib.Trace;
-- with Hex_IO;

package body Ada_Lib.Socket_IO is

-- use type Ada_Lib.Strings.String_Constant_Access;
-- use type Ada_Lib.Strings.String_Access_All;
   use type GNAT.Sockets.Socket_Type;

   ---------------------------------------------------------------------------
   procedure Bind (
      Socket               : in out Socket_Type;
      Port                 : in     Port_Type;
      Reuse                : in     Boolean := False) is
   ---------------------------------------------------------------------------

      Server_Address             : constant GNAT.Sockets.Sock_Addr_Type := (
                                    Family   => GNAT.Sockets.Family_Inet,
                                    Addr     => GNAT.Sockets.Any_Inet_Addr,
                                    Port     => Port);

   begin
      Log_In (Trace, "socket " & Socket.Image &
         " port" & Port'img & " reuse " & Reuse'img);
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

      GNAT.Sockets.Bind_Socket (Socket.GNAT_Socket, Server_Address);

      Log_Out (Trace);
   end Bind;

   ---------------------------------------------------------------------------
   function Buffer_Bytes (
      Bits                       : in     Natural
   ) return Index_Type is
   ---------------------------------------------------------------------------

   begin
      return Index_Type ((Bits - 1) / Bits_Per_Byte + 1);
   end Buffer_Bytes;

   ---------------------------------------------------------------------------
   overriding
   procedure Close (
      Socket                     : in out Socket_Type) is
   ---------------------------------------------------------------------------

   begin
      Log_In (Trace, "socket " & Socket.Image &
         " Open " & Socket.Is_Open'img &
         Tag_Name ("socket", Socket_Type'class (Socket)'tag) &
         " addresses socket " & Image (Socket'address));

      if not Socket.Is_Open then
         Log_Out (Trace);
         return;
      end if;

      if Socket.GNAT_Socket_Open then
         GNAT.Sockets.Close_Socket (Socket.GNAT_Socket);
         Socket.GNAT_Socket_Open := False;
      end if;
      Socket.Open := False;
      Log_Out (Trace);
   end Close;

   ---------------------------------------------------------------------------
   overriding
     procedure Finalize (
        Socket                     : in out Socket_Type) is
     ---------------------------------------------------------------------------

     begin
        Log_In (Trace, Socket.Image & "open " &
            " socket address " & Image (Socket'address));

         if Socket.Open then
            if Socket.GNAT_Socket_Open then
               GNAT.Sockets.Close_Socket (Socket.GNAT_Socket);
               Socket.GNAT_Socket_Open := False;
            end if;
            Socket.Open := False;
         end if;
         Log_Out (Trace);
     end Finalize;

   ---------------------------------------------------------------------------
   function Format_Timeout (
      Timeout                    : in     Duration
   ) return String is
   ---------------------------------------------------------------------------

   begin
      return (if Timeout = No_Timeout then
            "no timeout"
         else
            Timeout'img);
   end Format_Timeout;

   ---------------------------------------------------------------------------
   function Get_Description (
      Socket                     : in     Socket_Type
   ) return String is
   ---------------------------------------------------------------------------

   begin
      return (if Socket.Description = Null then
            "no description"
         else
            Socket.Description.all);
   end Get_Description;

   ---------------------------------------------------------------------------
   function Get_Host_By_Name (
      Name                       : in     String
   ) return Ada_Lib.Socket_IO.Host_Entry_Type is
   ---------------------------------------------------------------------------

   begin
      return GNAT.Sockets.Get_Host_By_Name (Name);
   end Get_Host_By_Name;

   ---------------------------------------------------------------------------
   function GNAT_Socket (
      Socket                     : in out Socket_Type
   ) return GNAT.Sockets.Socket_Type is
   ---------------------------------------------------------------------------

   begin
      return Socket.GNAT_Socket;
   end GNAT_Socket;

   ----------------------------------------------------------------
   function Image (
      Address                    : in     Address_Type
   ) return String is
   ----------------------------------------------------------------

      Result                     : Ada_Lib.Strings.Unlimited.String_Type;

   begin
      case Address.Address_Kind is

         when IP =>
            Result.Construct ("IP:");
            declare
               First          : Boolean := True;

            begin
               for Segment of Address.IP_Address loop
                  if First then
                     First := False;
                  else
                     Result.Append (".");
                  end if;
                  Result.Append (Ada_Lib.Strings.Trim (Segment'img));
               end loop;
            end;

         when Not_Set =>
            raise Failed with "address not set raised at " & Here;

         when URL =>
            Result.Construct (Quote ("URL", Address.URL_ADDRESS.Coerce));

      end case;
      return Result.Coerce;
   end Image;

   ---------------------------------------------------------------------------
   overriding
   function Image (
      Socket                     : in     Socket_Type
   ) return String is
   ---------------------------------------------------------------------------

   begin
      return "handle" & (if Socket.GNAT_Socket = GNAT.Sockets.No_Socket then
            " no socket"
         else
            GNAT.Sockets.Image (Socket.GNAT_Socket)) &
         Quote (" description", Socket.Description) &
         " socket open " & Socket.Open'img & " GNAT socket " & Socket.GNAT_Socket_Open'img &
         " address " & Image (Socket'address);
   end Image;

   ---------------------------------------------------------------------------
   function Image (
      IP_Address                 : in     IP_Address_Type
   ) return String is
   ---------------------------------------------------------------------------

--    use Ada_Lib.Strings;

   begin
      return Trim (IP_Address (1)'img) & "." &
             Trim (IP_Address (2)'img) & "." &
             Trim (IP_Address (3)'img) & "." &
             Trim (IP_Address (4)'img);
   end Image;

   ---------------------------------------------------------------------------
   overriding
   procedure Initialize (
      Socket                     : in out Socket_Type) is
   ---------------------------------------------------------------------------

   begin
        Log_In (Tracing, "socket " & Socket.Image);
        GNAT.Sockets.Create_Socket (Socket.GNAT_Socket, GNAT.Sockets.Family_Inet,
           GNAT.Sockets.Socket_Stream);
        Socket.Initialized := True;
        Log_Out (Tracing, "initialized socket " & Socket.Image);

   exception
      when Fault: others =>
        declare
           Message              : constant String := "Create_Socket failed";

        begin
           Trace_Message_Exception (Fault, Message);
           raise Failed with Message;
        end;
   end Initialize;

   ---------------------------------------------------------------------------
   function Is_Initialized (
      Socket                     : in     Socket_Type
   ) return Boolean is
   ---------------------------------------------------------------------------

   begin
     Log_Here (Tracing, "initialized " & Socket.Initialized'img &
        " address " & Image (Socket'address));

     return Socket.Initialized;
   end Is_Initialized;

   ---------------------------------------------------------------------------
   overriding
   function Is_Open (
     Socket                     : in     Socket_Type
   ) return Boolean is
   ---------------------------------------------------------------------------

   begin
     return Log_Here (Socket.Open, Tracing,
         "open " & Socket.Open'img &
        " address " & Image (Socket'address));
   end Is_Open;

-- ---------------------------------------------------------------------------
-- overriding
-- procedure Set_Description (
--    Socket                     : in out Socket_Type;
--    Description                : in     String) is
-- ---------------------------------------------------------------------------
--
-- begin
--    if Socket.Description /= Null then
--       Put_Line (Quote ("rename socket from", Socket.Description.all) &
--          Quote (" to", Description));
--       Ada_Lib.Strings.Free_All (Socket.Description);
--    end if;
--    Socket.Description := (if Description'length = 0 then
--          Null
--       else
--          new String'(Description));
-- end Set_Description;

   ---------------------------------------------------------------------------
   procedure Set_Open (
      Socket                     : in out Socket_Type;
      From                      : in     String := Ada_Lib.Trace.Here) is
   ---------------------------------------------------------------------------

   begin
      Socket.Open := True;
      Socket.GNAT_Socket_Open := True;
   end Set_Open;

   ---------------------------------------------------------------------------
   procedure Set_Socket (
      Socket                     : in out Socket_Type;
      GNAT_Socket                : in     GNAT.Sockets.Socket_Type) is
   ---------------------------------------------------------------------------

   begin
      Socket.GNAT_Socket := GNAT_Socket;
   end Set_Socket;

--   package body Root_Socket is
--
----    use type GNAT.Sockets.Stream_Access;
--
--      ---------------------------------------------------------------------------
--      procedure Close (
--         Socket                     : in out Socket_Type) is
--      ---------------------------------------------------------------------------
--
--      begin
--         Log (Trace, Here, Who & " enter");
--         GNAT.Sockets.Close_Socket (Socket.GNAT_Socket);
--         Socket.Open := False;
--         Socket.GNAT_Socket := GNAT.Sockets.No_Socket;
--         Log_Out (Trace);
--      end Close;
--
--      ---------------------------------------------------------------------------
--      function GNAT_Socket (
--         Socket                     : in out Socket_Type
--      ) return access GNAT.Sockets.Socket_Type is
--      ---------------------------------------------------------------------------
--
--      begin
--         return Socket.GNAT_Socket'unchecked_access;
--      end GNAT_Socket;
--
--      ---------------------------------------------------------------------------
--      procedure Read (
--         Socket                     : in out Socket_Type;
--         Buffer                     :    out Buffer_Type;
--         Timeout_Length             : in     Duration := No_Timeout) is
--      pragma Unreferenced (Socket, Buffer, Timeout_Length);
--      ---------------------------------------------------------------------------
--
----       Last                       : Index_Type;
--
--      begin
--         Not_Implemented;
----       Log_In (Trace, "first" & Buffer'first'img & " last" & Buffer'last'img);
----       Buffer := (others => 0);
----       Ada.Streams.Read (Socket.Stream.all, Buffer, Last);
----
----       if Trace then
----          Log_Here ("Last" & Last'img);
----          Hex_IO.Dump_8 (Buffer'address,
----             Integer (Buffer'last) * 8, 32, "socket read");
----       end if;
----
----       if Last /= Buffer'last then
----          raise Failed with "short socket read. Got" & Last'img &
----             " Expected" & Buffer'last'img;
----       end if;
----
----       Log_Out (Trace, "last" & Last'img);
--      end Read;
--
--      ---------------------------------------------------------------------------
--      procedure Write (
--         Socket                     : in out Socket_Type;
--         Buffer                     : in     Buffer_Type) is
--      pragma Unreferenced (Socket, Buffer);
--      ---------------------------------------------------------------------------
--
--      begin
--         Not_Implemented;
----       Log_In (Trace, "length " & Buffer'length'img);
----
----       if Trace then
----          Hex_IO.Dump_8 (Buffer'address, Buffer'size, 32, "socket write");
----       end if;
----
----       Ada.Streams.Write (Socket.Stream.all, Buffer);
----       Log_Out (Trace);
--      end Write;
--
--   end Root_Socket;


end Ada_Lib.Socket_IO;
