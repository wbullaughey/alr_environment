with Ada_Lib.Lock;
with Ada_Lib.Socket_IO.Stream_IO;
with Ada_Lib.Strings.Unlimited;-- use Ada_Lib.Strings.Unlimited;

pragma Elaborate_All (Ada_Lib.Lock);

package Ada_Lib.Socket_IO.Client is

   use type Index_Type;

   type Client_Socket_Type  (
      Description                : Ada_Lib.Strings.String_Constant_Access
                                    ) is new Ada_Lib.Socket_IO.Stream_IO.
                                       Stream_Socket_Type and
                                    Socket_Interface with private;
   type Client_Socket_Access     is access Client_Socket_Type;

   type Client_Socket_Class_Access
                                 is access all Client_Socket_Type'class;

   procedure Check_Read (
      Socket                     : in     Client_Socket_Type;
      Buffer                     : in     Buffer_Type);

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
         Socket                  : in     Socket_Class_Access) := Null
   ) with Pre => Socket.Is_Initialized;

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
         Socket                  : in     Socket_Class_Access) := Null
   ) with Pre => Socket.Is_Initialized;

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
         Socket                  : in     Socket_Class_Access) := Null
   ) with Pre => Socket.Is_Initialized;

   function Has_Read_Check (
      Socket                     : in     Client_Socket_Type
   ) return Boolean;

-- function Is_Connected (
--    Socket                     : in     Client_Socket_Type
-- ) return Boolean;

-- function Is_Open (
--    Socket                     : in     Client_Socket_Type
-- ) return Boolean;

-- procedure Read (
--    Socket                     : in out Client_Socket_Type;
--    Buffer                     :    out Buffer_Type;
--    Timeout_Length             : in     Duration := No_Timeout
-- ) with pre => Socket.Is_Connected and
--               Buffer'length > 0;

-- procedure Set_Open (
--    Socket                     : in out Client_Socket_Type);

   procedure Set_Expected_Read_Length (
      Socket                     : in out Client_Socket_Type;
      Length                     : in     Index_Type
   ) with pre => Has_Read_Check (Socket);

   procedure Unlock (
      Socket                     : in out Client_Socket_Type);

-- procedure Write (
--    Socket                     : in out Client_Socket_Type;
--    Buffer                     : in     Buffer_Type
-- ) with pre => Socket.Is_Connected;

private

-- type Client_Socket_Type       is new Socket_Type with record
--    Socket                     : Client_Socket_Class_Access := Null;
-- end record;
--
-- type Client_Socket_Type       is new Ada_Lib.Socket_IO.Accepted_Socket_Type
--                                  with private;
-- type Client_Socket_Class_Access
--                               is access all Client_Socket_Type'class;

   type Read_Check_Type          is record
      Expected_Read_Length       : Index_Type;
      Lock                       : Ada_Lib.Lock.Lock_Type (
                                    new String'("expected read length"));
--    Pending_Read_Length        : Index_Type;
   end record;

   type Read_Check_Access        is access Read_Check_Type;

   type Client_Socket_Type (
      Description                : Ada_Lib.Strings.String_Constant_Access
                                    ) is new Ada_Lib.Socket_IO.Stream_IO.
                                       Stream_Socket_Type (Description) and
                                    Socket_Interface with record
--    Connected                  : Boolean := False;
      Exception_Message          : Ada_Lib.Strings.Unlimited.String_Type;
      Read_Check                 : Read_Check_Access := Null;
   end record;

   overriding
   procedure Finalize (
      Socket                     : in out Client_Socket_Type);

-- function In_Buffer (
--    Socket                     : in   Client_Socket_Type
-- ) return Natural;

   overriding
   procedure Initialize (
      Socket                     : in out Client_Socket_Type);

end Ada_Lib.Socket_IO.Client;
