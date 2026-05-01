with Ada_Lib.OS;
with Ada_Lib.Socket_IO.Stream_IO;

-- pragma Elaborate (Ada_Lib.OS);

package Ada_Lib.Socket_IO.Server is

   type Accepted_Socket_Type (
      Description                : Ada_Lib.Strings.String_Constant_Access
                                    ) is new Ada_Lib.Socket_IO.Stream_IO.
                                       Stream_Socket_Type and
                                    Socket_Interface  with private;

   type Accepted_Socket_Access   is access Accepted_Socket_Type;

-- procedure Create_Stream (
--    Socket                     : in out Accepted_Socket_Type);

   overriding
   function In_Buffer (
      Socket                     : in     Accepted_Socket_Type
   ) return Index_Type;

-- function Is_Connected (
--    Socket                     : in     Accepted_Socket_Type
-- ) return Boolean;

   overriding
   function Is_Open (
      Socket                     : in     Accepted_Socket_Type
   ) return Boolean;

   procedure Set_Closed (
      Socket                     : in out Accepted_Socket_Type);

-- procedure Set_Open (
--    Socket                     : in out Accepted_Socket_Type);

   type Server_Socket_Type (
      Description    : Ada_Lib.Strings.String_Constant_Access;
      Port           : GNAT.Sockets.Port_Type
                        ) is new Socket_Type (
                           Description) and
                        Socket_Interface with null record;

   type Server_Socket_Access     is access Server_Socket_Type;

   procedure Accept_Socket (
      Server_Socket              : in out Server_Socket_Type;
      Accepted_Socket            :    out Accepted_Socket_Type'class;
      Accept_Timeout             : in     Duration := No_Timeout;
      Default_Read_Timeout       : in     Duration := No_Timeout;
      Default_Write_Timeout      : in     Duration := No_Timeout;
      Priority                   : in     Ada_Lib.OS.Priority_Type :=
                                             Ada_Lib.OS.Default_Priority
   ) with Pre => Server_Socket.Is_Open;

-- procedure Bind_Socket (
--    Socket                     : in out Server_Socket_Type;
--    Host_Entry                 : in     Host_Entry_Type;
--    Port                       : in     Port_Type);

-- procedure Finalize (
--    Socket                     : in out Server_Socket_Type);

-- overriding
-- procedure Connect (
--    Socket                     : in out Server_Socket_Type;
--    Server_Name                : in     String;
--    Port                       : in     Port_Type;
--    Connection_Timeout         : in     Timeout_Type := 1.0;
--    Expected_Read_Callback     : access procedure (
--       Socket                  : in     Root_Socket.Socket_Class_Access) := Null);

   overriding
   procedure Initialize (           -- does Bind
      Socket                     : in out Server_Socket_Type
   ) with Pre => not Socket.Is_Open;

-- overriding
-- function Is_Open (
--    Socket                     : in     Server_Socket_Type
-- ) return Boolean;

-- procedure Set_Option (
--    Socket                     : in out Server_Socket_Type;
--    Option                     : in     Option_Type);
--
private

   procedure Create_Stream (
      Socket                     : in out Server_Socket_Type);

   type Accepted_Socket_Type (
      Description                : Ada_Lib.Strings.String_Constant_Access
                                    ) is new Ada_Lib.Socket_IO.Stream_IO.
                                    Stream_Socket_Type (Description) and
                                    Socket_Interface with record
      Accepted                   : Boolean := False;
      Server_Closed              : Boolean := False;
   end record;

-- overriding
-- procedure Initialize (           -- creates stream
--    Socket                     : in out Accepted_Socket_Type
-- ) with Pre => not Socket.Is_Open;

-- procedure Set_Option (
--    Socket                     : in out Accepted_Socket_Type;
--    Option                     : in     Option_Type);
--
end Ada_Lib.Socket_IO.Server;
