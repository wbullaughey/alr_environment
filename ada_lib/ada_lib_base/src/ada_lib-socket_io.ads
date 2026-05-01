with Ada.Finalization;
with Ada.Streams;
with Ada_Lib.Options;
with ADA_LIB.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace;
with GNAT.Sockets;
with Hex_IO;
-- with Interfaces;

package Ada_Lib.Socket_IO is

   Failed                        : exception;
   Select_Timeout                : exception;

   subtype Data_Type             is Ada.Streams.Stream_Element;
   subtype Buffer_Type           is Ada.Streams.Stream_Element_Array;
   subtype Host_Entry_Type       is GNAT.Sockets.Host_Entry_Type;
   subtype Index_Type            is Ada.Streams.Stream_Element_Offset;
   subtype IP_Address_Type       is GNAT.Sockets.Inet_Addr_V4_Type;
   subtype IP_Address_Segment_Type
                                 is GNAT.Sockets.Inet_Addr_Comp_Type;
   subtype Option_Type           is GNAT.Sockets.Option_Name;
   subtype Port_Type             is GNAT.Sockets.Port_Type;
   subtype Timeout_Type          is GNAT.Sockets.Timeval_Duration;

   type Address_Kind_Type        is (IP, Not_Set, URL);

   type Address_Type (
      Address_Kind               : Address_Kind_Type) is tagged record
      case Address_Kind is

         when IP =>
            IP_Address           : IP_Address_Type;

         when Not_Set =>
            null;

         when URL =>
            URL_Address          : ADA_LIB.Strings.Unlimited.String_Type;

      end case;

   end record;

   type Address_Access           is access Address_Type;
   type Address_Constant_Access  is access constant Address_Type;

   function Image (
      Address                    : in     Address_Type
   ) return String;

   type Buffer_Access   is access all Ada.Streams.Stream_Element_Array;

   No_Address     : constant Address_Type;
   No_Timeout     : constant Duration := Duration'last;
   Reuse_Address  : Option_Type renames GNAT.Sockets.Reuse_Address;
   Trace          : Boolean renames Options.Ada_Lib_Socket_IO.Trace;
   Trace_IO       : Boolean renames Options.Ada_Lib_Socket_IO.Trace_IO;
   Tracing        : Boolean renames Options.Ada_Lib_Socket_IO.Tracing;

   type Socket_Interface  is limited Interface;

   function Buffer_Bytes (
      Bits                       : in     Natural
   ) return Index_Type;

   procedure Close (
      Socket                     : in out Socket_Interface) is abstract;

-- procedure Set_Description (
--    Socket                     : in out Socket_Interface;
--    Description                : in     String) is abstract;

   function Hex is new Hex_IO.Modular_Hex (Data_Type);

   function Image (
      Socket                     : in     Socket_Interface
   ) return String is abstract;

   function Is_Open (
      Socket                     : in     Socket_Interface
   ) return Boolean is abstract;

   type Socket_Type (
      Description       : Ada_Lib.Strings.String_Constant_Access
                           ) is abstract new Ada.Finalization.Limited_Controlled and
                              Socket_Interface with record
      GNAT_Socket       : aliased GNAT.Sockets.Socket_Type :=
                           GNAT.Sockets.No_Socket;
      GNAT_Socket_Open  : Boolean := False;
      Initialized       : Boolean := False;
      Open              : Boolean := False;
   end record;

   type Socket_Access            is access Socket_Type;
   type Socket_Class_Access      is access all Socket_Type'class;

   procedure Bind (
      Socket               : in out Socket_Type;
      Port                 : in     Port_Type;
      Reuse                : in     Boolean := False);

   overriding
   procedure Close (
      Socket                     : in out Socket_Type);

-- overriding
-- procedure Set_Description (
--    Socket                     : in out Socket_Type;
--    Description                : in     String);

   function Get_Description (
      Socket                     : in     Socket_Type
   ) return String;

   function GNAT_Socket (
      Socket                     : in out Socket_Type
   ) return GNAT.Sockets.Socket_Type;

   overriding
   function Image (
      Socket                     : in     Socket_Type
   ) return String;

   overriding
   function Is_Open (
      Socket                     : in     Socket_Type
   ) return Boolean;

   function Is_Initialized (
      Socket                     : in     Socket_Type
   ) return Boolean;

   type Client_Socket_Interface  is limited Interface;

   procedure Connect (
      Socket                     : in out Client_Socket_Interface;
      Server_Name                : in     String;
      Port                       : in     Port_Type;
      Connection_Timeout         : in     Timeout_Type := 1.0;
      Default_Read_Timeout       : in     Timeout_Type := 1.0;
      Default_Write_Timeout      : in     Timeout_Type := 1.0;
      Reuse                      : in     Boolean := False;
      Expected_Read_Callback     : access procedure (
         Socket                  : in     Socket_Class_Access) := Null
   ) is abstract;

   procedure Connect (
      Socket                     : in out Client_Socket_Interface;
      IP_Address                 : in     IP_Address_Type;
      Port                       : in     Port_Type;
      Connection_Timeout         : in     Timeout_Type := 1.0;
      Default_Read_Timeout       : in     Timeout_Type := 1.0;
      Default_Write_Timeout      : in     Timeout_Type := 1.0;
      Reuse                      : in     Boolean := False;
      Expected_Read_Callback     : access procedure (
         Socket                  : in     Socket_Class_Access) := Null
   ) is abstract;

   procedure Connect (
      Socket                     : in out Client_Socket_Interface;
      Address                    : in     Address_Type'class;
      Port                       : in     Port_Type;
      Connection_Timeout         : in     Timeout_Type := 1.0;
      Default_Read_Timeout       : in     Timeout_Type := 1.0;
      Default_Write_Timeout      : in     Timeout_Type := 1.0;
      Reuse                      : in     Boolean := False;
      Expected_Read_Callback     : access procedure (
         Socket                  : in     Socket_Class_Access) := Null
   ) is abstract;

   type Socket_Stream_Interface  is limited Interface;

   procedure Create_Stream (
      Socket                     : in out Socket_Stream_Interface;
      Default_Read_Timeout       : in     Duration := No_Timeout;
      Default_Write_Timeout      : in     Duration := No_Timeout) is abstract;

   function In_Buffer (
      Socket                     : in   Socket_Stream_Interface
   ) return Index_Type is abstract;

   -- reads Buffer amout of data from Socket
   -- throws timeout if timeout reached and Item array not filled
   -- waits forever if Timeout_Length = No_Timeout
   procedure Read (
      Socket                     : in out Socket_Stream_Interface;
      Buffer                     :    out Buffer_Type;
      Timeout_Length             : in     Duration := No_Timeout) is abstract;

   -- returns current contents of socket buffer
   procedure Read (
      Socket                     : in out Socket_Stream_Interface;
      Buffer                     :    out Buffer_Type;
      Last                       :    out Index_Type) is abstract;

   procedure Write (
      Socket                     : in out Socket_Stream_Interface;
      Buffer                     : in     Buffer_Type) is abstract;

   function Format_Timeout (
      Timeout                    : in     Duration
   ) return String;

   function Get_Host_By_Name (
      Name                       : in     String
   ) return Ada_Lib.Socket_IO.Host_Entry_Type;

   function Image (
      IP_Address                 : in     IP_Address_Type
   ) return String;

   procedure Set_Open (
      Socket                     : in out Socket_Type;
      From                      : in     String := Ada_Lib.Trace.Here);

   procedure Set_Socket (
      Socket                     : in out Socket_Type;
      GNAT_Socket                : in     GNAT.Sockets.Socket_Type);

private

   overriding
   procedure Finalize (
     Socket                   : in out Socket_Type);

   overriding
   procedure Initialize (
     Socket                   : in out Socket_Type);

   No_Address     : constant Address_Type := (
                              Address_Kind   => Not_Set);

end Ada_Lib.Socket_IO;
