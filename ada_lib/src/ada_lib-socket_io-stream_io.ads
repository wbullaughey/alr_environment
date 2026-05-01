-- package that provides stream IO for sockets with a timeout

with Ada.Calendar;
with Ada.Streams;
with Ada.Task_Identification;
with Ada_Lib.OS;
--with Ada_Lib.Timer;
with Ada_Lib.Trace;
with GNAT.Sockets;

-- pragma Elaborate (Ada_Lib.OS);

package Ada_Lib.Socket_IO.Stream_IO is

   Aborted                       : exception;
   Different_Description         : exception;
   IO_Failed                     : exception;
   Peer_Closed                   : exception;
   Task_Running                  : exception;
   Timeout                       : exception;

   type Buffer_Kind_Type            is (Input, Output);

   type Event_Type                  is (Closed,  Failed, OK, Timed_Out);   -- Buffer_Limit

   Buffer_Length                    : constant := 1024;
   subtype Buffer_Index_Type        is Index_Type range 1 .. Buffer_Length;
   subtype Stream_Buffer_Type       is Buffer_Type (Buffer_Index_Type);
   No_Timeout                       : constant Duration := Duration'last;

   protected type Protected_Buffer_Type (
      Kind                       : Buffer_Kind_Type;
      Description                : Ada_Lib.Strings.String_Constant_Access) is

      procedure Dump;

      function Empty(
         Throw_Expression        : in     Boolean
      ) return Boolean;

      function Free
      return Index_Type;

      -- return everything in buffer
      entry Get (
         Data                    :    out Buffer_Type;
         Event                   :    out Event_Type;
         Last                    :    out Index_Type);

      function Get_State return Event_Type;

      function In_Buffer
      return Index_Type;

      -- set length next Put wants to put in buffer
      procedure Prime_Output (
         Length                  : in     Index_Type);

      entry Put (
         Data                    : in     Buffer_Type;
         Event                   :    out Event_Type);

      procedure Reset;

      procedure Set_Event (
         Event                   : in     Event_Type;
         From                    : in     String := Ada_Lib.Trace.Here);

      function Timed_Out return Boolean;

      procedure Trace_State;

   private
      Buffer                     : Stream_Buffer_Type;
      Buffer_Count               : Index_Type := 0;
      Head                       : Buffer_Index_Type := Buffer_Index_Type'first;
      Primed_Input               : Index_Type := 0;
      Primed_Output              : Index_Type := 0;
      State                      : Event_Type := Ok;
      Tail                       : Buffer_Index_Type := Buffer_Index_Type'first;
--    Timeout_Time               : Ada_Lib.Time.Time_Type := Ada_Lib.Time.Ada_Lib.Time.No_Time;

   end Protected_Buffer_Type;

   procedure Put (
      Buffer                     : in out Protected_Buffer_Type;
      Data                       : in     Buffer_Type);


   type Stream_Socket_Type (
      Description                : Ada_Lib.Strings.String_Constant_Access
                                    ) is new Socket_Type and
                                    Client_Socket_Interface and
                                    Socket_Interface and
                                    Socket_Stream_Interface with private;

   type Stream_Socket_Access     is access all Stream_Socket_Type;

   procedure Dump_Input_Buffer (
      Socket                     : in out Stream_Socket_Type;
      From                       : in     String := Ada_Lib.Trace.Here);

   overriding
   procedure Close (
      Socket                     : in out Stream_Socket_Type);

   overriding
   procedure Connect (
      Socket                     : in out Stream_Socket_Type;
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
      Socket                     : in out Stream_Socket_Type;
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
      Socket                     : in out Stream_Socket_Type;
      Address                    : in     Address_Type'class;
      Port                       : in     Port_Type;
      Connection_Timeout         : in     Timeout_Type := 1.0;
      Default_Read_Timeout       : in     Timeout_Type := 1.0;
      Default_Write_Timeout      : in     Timeout_Type := 1.0;
      Reuse                      : in     Boolean := False;
      Expected_Read_Callback     : access procedure (
         Socket                  : in     Socket_Class_Access) := Null
   ) with Pre => Socket.Is_Initialized;

   overriding
   procedure Create_Stream (
      Socket                     : in out Stream_Socket_Type;
      Default_Read_Timeout       : in     Duration := No_Timeout;
      Default_Write_Timeout      : in     Duration := No_Timeout);

   overriding
   function In_Buffer (
      Socket                     : in   Stream_Socket_Type
   ) return Index_Type;

   -- reads Buffer amout of data from Socket
   -- throws timeout if timeout reached and Item array not filled
   -- waits forever if Timeout_Length = No_Timeout
   overriding
   procedure Read (
      Socket                     : in out Stream_Socket_Type;
      Buffer                     :    out Buffer_Type;
      Timeout_Length             : in     Duration := No_Timeout
   ) with pre => Socket.Is_Open and then
                 Buffer'length > 0 and then
                 Timeout_Length >= 0.0;

   -- returns current contents of socket buffer
   overriding
   procedure Read (
      Socket                     : in out Stream_Socket_Type;
      Buffer                     :    out Buffer_Type;
      Last                       :    out Index_Type
   ) with pre => Socket.Is_Open and then
                 Buffer'length > 0;

   function Reader_Stopped (
      Socket                     : in   Stream_Socket_Type
   ) return Boolean;

   function Socket_ID (
      Socket                     : in   Stream_Socket_Type
   ) return String;

   -- throws timeout if timeout reached and last Item array not written
   overriding
   procedure Write (
      Socket                     : in out Stream_Socket_Type;
      Buffer                     : in     Buffer_Type
   ) with pre => Socket.Is_Open and then
                 Buffer'length > 0;

   function Writer_Stopped (
      Socket                     : in     Stream_Socket_Type
   ) return Boolean;

   procedure Dump (
      Description                : in     String;
      Data                       : in     Buffer_Type;
      From                       : in     String := Ada_Lib.Trace.Here);

   type Task_State_Type          is (Idle, Running, Started, Stopped);
   type Task_State_Access        is access all Task_State_Type;

private
   Never                         : constant Ada.Calendar.Time :=
                                    Ada.Calendar.Time_Of (
                                       Year => Ada.Calendar.Year_Number'last,
                                       Month => Ada.Calendar.Month_Number'First,
                                       Day => Ada.Calendar.Day_Number'First,
                                       Seconds => Ada.Calendar.Day_Duration'First);

   type Stream_Type;
   type Stream_Access            is access all Stream_Type;

   task type Input_Task (
      Description                : Ada_Lib.Strings.String_Constant_Access) is

      pragma Priority (2);

      entry Open (
         Stream                  : in   Stream_Access;
         Priority                : in   Ada_Lib.OS.Priority_Type;
         From                    : in   String := Ada_Lib.Trace.Here);

   end Input_Task;

   type Input_Task_Access       is access Input_Task;

   task type Output_Task (
      Description                : Ada_Lib.Strings.String_Constant_Access) is

      pragma Priority (1);

      entry Open (
         Stream                  : in   Stream_Access;
         Priority                : in   Ada_Lib.OS.Priority_Type;
         From                    : in   String := Ada_Lib.Trace.Here);

   end Output_Task;

   type Output_Task_Access       is access Output_Task;

   type Stream_Type (
      Description                : Ada_Lib.Strings.String_Constant_Access
         ) is new Ada.Streams.Root_Stream_Type with record
      Default_Read_Timeout       : Duration;
      Default_Write_Timeout      : Duration;
      GNAT_Stream                : GNAT.Sockets.Stream_Access;
      Input_Buffer               : aliased Protected_Buffer_Type (
                                    Input, Description);
      Output_Buffer              : aliased Protected_Buffer_Type (
                                    Output, Description);
      Reader                     : Input_Task_Access := Null;
--    Reader_State               : aliased Task_State_Type := Idle;
      Reader_Task_Id             : Ada.Task_Identification.Task_Id;
      Reader_Stopped             : Boolean := True;
      Socket                     : Socket_Class_Access := Null;
      Socket_Closed              : Boolean := False;
      Writer                     : Output_Task_Access := Null;
--    Writer_State               : aliased Task_State_Type := Idle;
      Writer_Task_Id             : Ada.Task_Identification.Task_Id;
      Writer_Stopped             : Boolean := True;
   end record;

   procedure Close (
      Stream                     : in out Stream_Type);

   procedure Create (
      Stream                     : in out Stream_Type;
      Socket                     : in out Stream_Socket_Type'class;
      Default_Read_Timeout       : in     Duration := No_Timeout;
      Default_Write_Timeout      : in     Duration := No_Timeout;
      Priority                   : in     Ada_Lib.OS.Priority_Type :=
                                             Ada_Lib.OS.Default_Priority);

   function Image (
      Stream                     : in   Stream_Type
   ) return String;

   function In_Buffer (
      Stream                     : in   Stream_Type
   ) return Index_Type;

   procedure Read (
      Stream                     : in out Stream_Type;
      Buffer                     :    out Buffer_Type;
      Last                       :    out Index_Type;    -- index in Item
      Timeout_Length             : in     Duration
   ) with pre => Stream.Was_Created and then
                 Buffer'length > 0;

   -- returns current contents of socket buffer
   overriding
   procedure Read (
      Stream                     : in out Stream_Type;
      Item                       :    out Buffer_Type;
      Last                       :    out Index_Type        -- index in Item
   ) with pre => Stream.Was_Created and then
                 Item'length > 0;

   function Was_Created (
      Stream                     : in     Stream_Type
   ) return Boolean;

   overriding
   procedure Write (
      Stream                     : in out Stream_Type;
      Item                       : in Buffer_Type
   ) with pre => Stream.Was_Created and then
                 Item'length > 0;

   procedure Write (
      Stream                     : in out Stream_Type;
      Item                       : in     Buffer_Type;
      Timeout_Length             : in     Duration
   ) with pre => Item'length > 0 and then
                 Timeout_Length > 0.0;

   type Stream_Socket_Type (
      Description                : Ada_Lib.Strings.String_Constant_Access
                                    ) is new Socket_Type (Description) and
                                       Client_Socket_Interface and
                                       Socket_Interface and
                                       Socket_Stream_Interface with record
      Stream                     : Stream_Type (Description);
   end record;

   overriding
   procedure Finalize (
      Socket                     : in out Stream_Socket_Type);

   overriding
   procedure Initialize (
      Socket                     : in out Stream_Socket_Type);

end Ada_Lib.Socket_IO.Stream_IO;
