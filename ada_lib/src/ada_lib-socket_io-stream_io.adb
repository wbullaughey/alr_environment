-- package that provides stream IO for sockets with a timeout
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Unchecked_Deallocation;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Time;
with Ada_Lib.Timer;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with Ada_Lib.Trace_Tasks; use Ada_Lib.Trace_Tasks;
with Interfaces;

package body Ada_Lib.Socket_IO.Stream_IO is

   use type Ada_Lib.Strings.String_Constant_Access;
-- use type Data_Type;
   use type Index_Type;
   use type GNAT.Sockets.Error_Type;
   use type GNAT.Sockets.Socket_Type;
   use type Ada_Lib.Time.Time_Type;

   procedure Free is new Ada.Unchecked_Deallocation (
      Name     => GNAT.Sockets.Stream_Access,
      Object   => Ada.Streams.Root_Stream_Type'Class);

   procedure Free is new Ada.Unchecked_Deallocation (
      Object   => Input_Task,
      name  => Input_Task_Access);

   procedure Free is new Ada.Unchecked_Deallocation (
      Object   => Output_Task,
      name  => Output_Task_Access);

   procedure Trace_Read (
      Line                 : in   Buffer_Type;
      Last                 : in   Index_Type);

-- Close_Flag              : constant Data_Type := Data_Type (Character'Pos (
--                            Character'last));

   ---------------------------------------------------------------------------
   overriding
   procedure Close (
      Socket                     : in out Stream_Socket_Type) is
   ---------------------------------------------------------------------------

   begin
      Log_In (Trace, Socket.Image &
         " stream " & Ada_Lib.Strings.Image (Socket.Stream'address) &
         " output buffer empty " &
            Socket.Stream.Output_Buffer.Empty (False)'img);

      if not Socket.Is_Open then
         Log_Out (Trace);
         return;
      end if;
      while not Socket.Stream.Output_Buffer.Empty (False) loop
         delay 0.1;
      end loop;
      Socket.Stream.Input_Buffer.Set_Event (Closed); -- signal input task to close
      Log_Here (Trace);
      Socket.Stream.Output_Buffer.Set_Event (Closed); -- signal output task to close
      Socket.Stream.Socket_Closed := True;
      delay 0.2;     -- let tasks complete

      Log_Here (Tracing, "wait for write task to exit socket " &
         Socket.Image & " writer stopped " & Socket.Stream.Writer_Stopped'img);
      while not Socket.Stream.Writer_Stopped loop
         delay 0.1;
      end loop;

      if Socket.GNAT_Socket_Open then
         Log_Here (Trace);
         GNAT.Sockets.Close_Socket (Socket.GNAT_Socket);
         Socket.GNAT_Socket_Open := False;
      end if;

      Socket_Type (Socket).Close;   -- to terminate receive
      Socket.Stream.Close;

      Log_Here (Tracing, "wait for reader task to exit socket " &
         Socket.Image &
         " Reader_Stopped " & Socket.Stream.Reader_Stopped'img);
      while not Socket.Stream.Reader_Stopped loop
         delay 0.1;
      end loop;
      Log_Here (Tracing);
      Log_Out (Trace, Socket.Image);

   exception
      when Fault: others =>
--       Trace_Exception (Trace, Fault);
         Log_Exception (Trace, Fault);
         raise;

   end Close;

   ---------------------------------------------------------------------------
   procedure Close (
      Stream               : in out Stream_Type) is
   ---------------------------------------------------------------------------

   begin
      Log_In (Tracing, Stream.Image &
         " reader stopped " & Stream.Reader_Stopped'img &
         " writer stopped " & Stream.Writer_Stopped'img &
         " address stream " & Ada_Lib.Strings.Image (Stream'address));

      Stream.Input_Buffer.Set_Event (Closed);
      Stream.Output_Buffer.Set_Event (Closed);
      if Stream.Socket /= Null and then
            Stream.Socket.Is_Open then
         Log_Here (Tracing);
         Socket_Type (Stream.Socket.all).Close;
      end if;
      Log_Here (Tracing, "reader stopped " &Stream.Reader_Stopped'img &
         " writer stopped " &Stream.Writer_Stopped'img);
      declare
         Timeout           : constant Ada_Lib.Time.Time_Type :=
                              Ada_Lib.Time.Now + 0.5;
      begin
         while not (Stream.Reader_Stopped and then
                    Stream.Writer_Stopped) loop
            if Ada_Lib.Time.Now > Timeout then
               declare
                  Message  : constant String :=
                              "reader stopped " &Stream.Reader_Stopped'img &
                              " writer stopped " &Stream.Writer_Stopped'img;
               begin
                  Log_Exception (Debug, Message);
                  raise Task_Running with Message & " " & Here;
               end;
            end if;
            delay 0.1;
         end loop;
      end;
      Log_Here (Debug);
      Free (Stream.Reader);
      Free (Stream.Writer);
      Log_Out (Tracing);
   end Close;

   ---------------------------------------------------------------------------
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
         Socket                  : in     Socket_Class_Access) := Null) is
   pragma Unreferenced (Socket, Server_Name, Port, Connection_Timeout, Expected_Read_Callback);
   ---------------------------------------------------------------------------

   begin
      Not_Implemented;
   end Connect;

   ---------------------------------------------------------------------------
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
         Socket                  : in     Socket_Class_Access) := Null) is
   ---------------------------------------------------------------------------

   begin
      Not_Implemented;
   end Connect;

   ---------------------------------------------------------------------------
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
         Socket                  : in     Socket_Class_Access) := Null) is
   ---------------------------------------------------------------------------

   begin
      Not_Implemented;
   end Connect;

   ---------------------------------------------------------------------------
   procedure Create (
      Stream                     : in out Stream_Type;
      Socket                     : in out Stream_Socket_Type'class;
      Default_Read_Timeout       : in   Duration := No_Timeout;
      Default_Write_Timeout      : in   Duration := No_Timeout;
      Priority                   : in   Ada_Lib.OS.Priority_Type :=
                                          Ada_Lib.OS.Default_Priority) is
   ---------------------------------------------------------------------------

      Reader_Task_Description    : constant String_Constant_Access := new String'(
                                       (if Socket.Description = Null then
                                             "undescribed socket"
                                          else
                                             Socket.Description.all & " reader task"));
      Writer_Task_Description    : constant String_Constant_Access := new String'(
                                       (if Socket.Description = Null then
                                             "undescribed socket"
                                          else
                                             Socket.Description.all & " write task"));
   begin
      Log_In (Tracing, Socket.Image &
         Quote (" reader description", Reader_Task_Description) &
         Quote (" writer description", Writer_Task_Description) &
         " Default_Read_Timeout " &
         Format_Timeout (Default_Read_Timeout) &
         " Default_Write_Timeout " &
         Format_Timeout (Default_Write_Timeout) & " " & Socket.Image);
      Stream.Socket := Socket_Type (Socket)'unchecked_access;
      Stream.GNAT_Stream :=  GNAT.Sockets.Stream (Socket.GNAT_Socket);
      Stream.Default_Read_Timeout := Default_Read_Timeout;
      Stream.Default_Write_Timeout := Default_Write_Timeout;
      Stream.Input_Buffer.Reset; -- put back to ok for Reopen
      Stream.Output_Buffer.Reset; -- put back to ok for Reopen
      Stream.Reader := new Input_Task (Reader_Task_Description);
      Stream.Reader.Open (Stream'unchecked_access, Priority);
      Stream.Socket_Closed := False;
      delay 0.1;  -- lett read initialize before write starts for debugging
      Stream.Writer := new Output_Task (Writer_Task_Description);
      Stream.Writer.Open (Stream'unchecked_access, Priority);
      Log_Out (Tracing, "was created " & Stream.Was_Created'img);
   end Create;

   ---------------------------------------------------------------------------
   overriding
   procedure Create_Stream (
      Socket                     : in out Stream_Socket_Type;
      Default_Read_Timeout       : in     Duration := No_Timeout;
      Default_Write_Timeout      : in     Duration := No_Timeout) is
   ---------------------------------------------------------------------------

   begin
      Log_In (Tracing, Socket.Image & -- Quote (" Description", Description) &
         " socket " & Socket.Image & " no description expected ");
--       "addresses socket " & Image (Socket'address) &
--       " stream " & Ada_Lib.Strings.Image (Socket.Stream'address));

--    if Socket.Description = Null then
--       Socket.Set_Description (Description);
--    elsif Description'length > 0 and then
--          Socket.Description.all /= Description then
--       Log_Exception (Trace, "missmatch description");
--       raise Different_Description with Quote ("Missmatch description. Socket",
--          Socket.Image) & Quote ("create description", Description);
--    end if;

      Socket.Stream.GNAT_Stream := GNAT.Sockets.Stream (Socket.GNAT_Socket);
      Socket.Stream.Create (
         Socket                  => Socket,
         Default_Read_Timeout    => Default_Read_Timeout,
         Default_Write_Timeout   => Default_Write_Timeout);
      Log_Out (Tracing, "socket " & Socket.Image);
   end Create_Stream;

   ---------------------------------------------------------------------------
   procedure Dump (
      Description          : in     String;
      Data                 : in     Buffer_Type;
      From                 : in     String := Here) is
   ---------------------------------------------------------------------------

      Length               : constant Natural := Data'length;

   begin
      if Length = 0 then
         Put_Line ("dump for " & Description & " for 0 bytes called from " & From);
      else
         Ada_Lib.Trace.Dump (Data'address, Length, 32,
            Ada_Lib.Trace.Width_8, Description & " length" & Length'img, From);
      end if;
   end Dump;

   ---------------------------------------------------------------------------
   procedure Dump_Input_Buffer (
      Socket                     : in out Stream_Socket_Type;
      From                       : in     String := Ada_Lib.Trace.Here) is
   ---------------------------------------------------------------------------

   begin
      Put_Line ("called from " & From);
      Socket.Stream.Input_Buffer.Dump;
   end Dump_Input_Buffer;

   ---------------------------------------------------------------------------
   overriding
   procedure Finalize (
      Socket                     : in out Stream_Socket_Type) is
   ---------------------------------------------------------------------------

   begin
      Log_In (Trace, Socket.Image & " open " & Socket.Is_Open'img & " address " &
         Ada_Lib.Strings.Image (Socket'address));
      if Socket.Is_Open then
         Log_Here (Trace);
         Socket.Close;
      end if;
      Socket_Type (Socket).Finalize;
      Free (Socket.Stream.GNAT_Stream);
      Log_Out (Trace);
   end Finalize;

-- -----------------------------------------------------------------------
-- procedure Get (
--    Buffer                     : in out Protected_Buffer_Type;
--    Data                       :    out Buffer_Type;
--    Event                      :    out Event_Type) is
-- -----------------------------------------------------------------------
--
--    Left                       : Index_Type := Data'length;
--    Start                      : Index_Type := 1;
--
-- begin
--    Log_In (Tracing, "length" & Left'img);
--    if Tracing then
--       Buffer.Trace_State;
--    end if;
--    while Left > 0 loop
--       declare
--          Last                 : Index_Type;
--
--       begin
--          Buffer.Get (Data (Start .. Data'last), Event, Last);
--             -- will block when buffer empty
--          Left := Data'last - Last;
--          Start := Last + 1;
--       end;
--    end loop;
--    Log_Out (Tracing);
-- end Get;

   ---------------------------------------------------------------------------
   function Image (
      Stream                     : in   Stream_Type
   ) return String is
   ---------------------------------------------------------------------------

   begin
      return "socket " & (if Stream.Socket = Null then
            "null"
         else
            Stream.Socket.Image);
   end Image;

   ---------------------------------------------------------------------------
   function In_Buffer (
      Stream               : in   Stream_Type
   ) return Index_Type is
   ---------------------------------------------------------------------------

   begin
      return Stream.Input_Buffer.In_Buffer;
   end In_Buffer;

   ---------------------------------------------------------------------------
   overriding
   function In_Buffer (
      Socket                     : in   Stream_Socket_Type
   ) return Index_Type is
   ---------------------------------------------------------------------------

   begin
      return Socket.Stream.In_Buffer;
   end In_Buffer;

   ---------------------------------------------------------------------------
   overriding
   procedure Initialize (
      Socket                     : in out Stream_Socket_Type) is
   ---------------------------------------------------------------------------

   begin
      Log_In (Trace);
      Socket_Type (Socket).Initialize;
      Log_Out (Trace, Socket.Image);

   exception
      when Fault: others =>
         Trace_Exception (Fault, Here);
         Log_Exception (Trace, Fault);
         raise;

   end Initialize;

   -----------------------------------------------------------------------
   procedure Put (
      Buffer            : in out Protected_Buffer_Type;
      Data              : in     Buffer_Type) is
   -----------------------------------------------------------------------

      Event             : Event_Type := Ok;
      Left              : Index_Type := Data'length;
      Start             : Index_Type := Data'first;

   begin
      Log_In (Tracing, "start" & Start'img & " length" & Left'img);
      if Tracing then
         Buffer.Trace_State;
      end if;
      while Left > 0 and then Event = Ok loop
         declare
            Length               : constant Index_Type :=
                                    (if Left > Buffer_Length then
                                       Buffer_Length
                                    else
                                       Left);
         begin
            Buffer.Prime_Output (Length);
            Buffer.Put (Data (Start .. Start + Length - 1), Event);
            if Event /= Ok then
               Log_Here (Tracing, "event " & Event'img);
               exit;
            end if;
            Left := Left - Length;
            Start := Start + Length;
         end ;
      end loop;
      Log_Out (Tracing);
   end Put;

   ---------------------------------------------------------------------------
   -- if Timeout_Length > 0 then timeout exception raised if do not get
   -- the full Buffer
   procedure Read (
      Stream                    : in out Stream_Type;
      Buffer                     :    out Buffer_Type;
      Last                       :    out Index_Type; -- in Buffer
      Timeout_Length             : in     Duration) is
   ---------------------------------------------------------------------------

      Throw_Exception   : constant Boolean := Timeout_Length > 0.0 and then
                                              Timeout_Length /= No_Timeout;

   begin
      Ada_Lib.Trace.Log_In (Trace,
         Buffer'first'img & " .." &
         Buffer'last'img &
         " socket " & Stream.Image &
         " state " & Stream.Input_Buffer.Get_State'img &
         " Timeout_Length " & Format_Timeout (Timeout_Length) &
         " Throw_Exception " & Throw_Exception'img &
         " throw " & Throw_Exception'img &
         " in buffer" & Stream.Input_Buffer.In_Buffer'img);

      Last := 0;
      Stream.Input_Buffer.Set_Event (OK);

      declare
         Event                   : Event_Type;
         Failure                 : Boolean := False;
         Start_Get               : Index_Type := Buffer'first;

      begin
         Log_Here (Trace);

         while not Failure loop
            declare
               type Timeout_Event_Type
                                 is new Ada_Lib.Timer.Event_Type
                                    with null record;
               overriding
               procedure Callback (
                  Event          : in out Timeout_Event_Type);

               Buffer_Empty      : constant Boolean := Stream.Input_Buffer.Empty (
                                    Throw_Exception);
               Timeout_Event     : aliased Timeout_Event_Type;

               --------------------------------------------------------------
               overriding
               procedure Callback (
                  Event             : in out Timeout_Event_Type) is
               pragma Unreferenced (Event);
               --------------------------------------------------------------

               begin
                  Log_Here (Trace);
                  Failure := True;
                  Stream.Input_Buffer.Set_Event (Timed_Out);   -- triger buffer
               end Callback;
               --------------------------------------------------------------

            begin
               Log_Here (Trace, "Buffer_Empty " & Buffer_Empty'img &
                  " Timeout_Length " & Timeout_Length'img &
                  " Start_Get" & Start_Get'img &
                  " buffer last" & Buffer'Last'img);

               if    Buffer_Empty and then
                     Timeout_Length = 0.0 then  -- return data current in buffer
                  Log_Here (Trace);
                  exit;
               end if;

               if Throw_Exception then
                  Timeout_Event.Start (Timeout_Length,
                  "stream " & Stream.Image & " read timeout",
                     False, False);
               end if;

               Stream.Input_Buffer.Get (Buffer (Start_Get .. Buffer'last),
                  Event, Last);

               Log_Here (Trace, "Last" & Last'img &
                  " event " & Event'img);

               if Event /= Timed_Out then
                  if not Timeout_Event.Cancel then
                     Log_Here (Trace, "cancel timeout event failed");
                  end if;
               end if;

               case Event is

                  when OK =>
                     if Last = Buffer'last then  -- buffer full
                        Log_Here (Trace);
                        exit;
                     end if;

                     -- wait for more data
                     Start_Get := Last + 1;

                  when Closed =>
                     if Last > 0 then
                        exit;
                     end if;

                     Log_Exception (Trace, "Peer_Closed");
                     raise Peer_Closed;

                  when Failed =>
                     Log_Exception (Trace, "failed");
                     raise IO_Failed;

                  when Timed_Out =>
                     if Throw_Exception then
                        declare
                           Message  : constant String := "timeout after " &
                                       Timeout_Length'img & " from " & Here;
                        begin
                           Log_Exception (Trace, Message);
                           raise Timeout with Message;
                        end;
                     else
                        Stream.Close;
                        Log_Here (Trace);
                        exit;
                     end if;

               end case;

               Log_Here (Trace);
            end;
         end loop;
      end;

      if Last = 0  then
         Log_Here (Trace, "zero length read");
      else
         if Test_Condition and Trace then
            Dump ("read completed", Buffer (Buffer'first .. Last));
         end if;
      end if;

      Log_Out (Trace, "socket " & Stream.Image & " last" & Last'img &
         " in buffer" & Stream.Input_Buffer.In_Buffer'img);

   exception
      when Fault: Timeout =>
         Log_Exception (Trace, Fault, "read timed out");
         raise;

      when Fault: others =>
--       Trace_Message_Exception (Trace, Fault, "read failed");
         Log_Exception (Trace, Fault, "read failed");
         raise;
   end Read;

   ---------------------------------------------------------------------------
   -- reads Buffer amout of data from Socket
   -- throws timeout if timeout reached and Item array not filled
   -- waits forever if Timeout_Length = No_Timeout
   overriding
   procedure Read(
      Socket               : in out Stream_Socket_Type;
      Buffer               :    out Buffer_Type;
      Timeout_Length       : in     Duration := No_Timeout) is
   ---------------------------------------------------------------------------

      Last                 : Index_Type;
      Start                : Index_Type := Buffer'first;
      Timeout_Time         : constant Ada.Calendar.Time :=
                              Ada.Calendar.Clock +
                                 (if Timeout_Length = No_Timeout then
                                    Socket.Stream.Default_Read_Timeout
                                 else
                                    Timeout_Length);
   begin
      Log_In (Tracing, " length" & Buffer'length'img &
         " first" & Buffer'first'img &
         " last" & Buffer'last'img &
         " timeout " & Timeout_Length'img);
      loop
         declare
            Time_Left      : constant Duration := Timeout_Time -
                              Ada.Calendar.Clock;
         begin
            Log_Here (Tracing, "Time_Left " & Time_Left'img);

            if Time_Left <= 0.0 then
               declare
                  Message     : constant String :=
                                 "timeout befor buffer filled at " & Here;
               begin
                  Log_Exception (Tracing, Message);
                  raise Timeout with Message;
               end;
            end if;
            Log_Here (Tracing, " start" & Start'img);
            Read (Socket.Stream, Buffer (Start .. Buffer'last), Last,
               Timeout_Length    => Time_Left);
            Log_Here (Tracing, "last" & Last'img);
         end;

         if Last = Buffer'last then -- got whole buffer
            exit;
         end if;

         Start := Last + 1;
      end loop;

      if Test_Condition and Trace then
         Dump ("read", Buffer);
      end if;

      Log_Out (Tracing, "last" & Last'img);
   end Read;

   ---------------------------------------------------------------------------
   -- returns current contents of socket buffer
   overriding
   procedure Read (
      Socket                     : in out Stream_Socket_Type;
      Buffer                     :    out Buffer_Type;
      Last                       :    out Index_Type) is
   ---------------------------------------------------------------------------

   begin
      Log_In (Tracing, Socket.Stream.Image & " length" & BUFFER'length'img);

      Read (Socket.Stream, Buffer, Last,
         Timeout_Length    => 0.0);    -- no timeout,don't wait for data

      if Last = 0  then
         Log_Here (Trace, "zero length read");
      else
         if Test_Condition and Trace then
            Dump ("read", Buffer (Buffer'first .. Last));
         end if;
      end if;

      Log_Out (Tracing, "last" & Last'img);
   end Read;

   ---------------------------------------------------------------------------
   -- returns current contents of socket buffer
   overriding
   procedure Read(
      Stream               : in out Stream_Type;
      Item                 : out Buffer_Type;
      Last                 : out Index_Type) is -- index in Item
   ---------------------------------------------------------------------------

   begin
      Log_In (Tracing, Stream.Image & " length" & Item'length'img);
      Read (Stream, Item, Last, 0.0);

   if Test_Condition and Trace then
            Trace_Read (Item, Last);
         end if;
      Log_Out (Tracing, "last" & Last'img);
   end Read;

   ---------------------------------------------------------------------------
   function Reader_Stopped (
      Socket                     : in   Stream_Socket_Type
   ) return Boolean is
   ---------------------------------------------------------------------------

   begin
      Log_Here (Tracing, Socket.Image & " reader stopped " & Socket.Stream.Reader_Stopped'img);

      return Socket.Stream.Reader_Stopped;
   end Reader_Stopped;

   ---------------------------------------------------------------------------
   function Socket_ID (
      Socket                     : in   Stream_Socket_Type
   ) return String is
   ---------------------------------------------------------------------------

   begin
      return GNAT.Sockets.Image (Socket.GNAT_Socket);
   end Socket_ID;

   ---------------------------------------------------------------------------
   procedure Trace_Read (
      Line                 : in   Buffer_Type;
      Last                 : in   Index_Type) is
   ---------------------------------------------------------------------------

   begin
      if Last < Line'first then
         Log_Here ("read null line");
      else
         Dump ("read", Line (Line'first .. Last));
      end if;
   end Trace_Read;

   ---------------------------------------------------------------------------
   function Was_Created (
      Stream               : in     Stream_Type
   ) return Boolean is
   ---------------------------------------------------------------------------

   begin
      return Stream.Socket /= Null;
   end Was_Created;

   ---------------------------------------------------------------------------
   overriding
   procedure Write (
      Socket                     : in out Stream_Socket_Type;
      Buffer                     : in     Buffer_Type) is
   ---------------------------------------------------------------------------

   begin
--    Log_In (Tracing, Socket.Image);
      Socket.Stream.Write (Buffer);
--    Log_Out (Tracing);
   end Write;

   ---------------------------------------------------------------------------
   overriding
   procedure Write(
      Stream               : in out Stream_Type;
      Item                 : in   Buffer_Type) is
   ---------------------------------------------------------------------------

   begin
--    Log_In (Tracing, Stream.Image);
      Write (Stream, Item, Stream.Default_Write_Timeout);
--    Log_Out (Tracing);
   end Write;

   ---------------------------------------------------------------------------
   procedure Write (
      Stream               : in out Stream_Type;
      Item                 : in   Buffer_Type;
      Timeout_Length       : in   Duration) is
   pragma Unreferenced (Timeout_Length);
   ---------------------------------------------------------------------------

--    This_Timeout         : Duration := Stream.Default_Write_Timeout;

   begin
      Log_In (Trace, Stream.Image & " " &
         " length" & Item'length'img &
         Index_Type'image (Item'first) & " .." &
         Index_Type'image (Item'last) & " timeout");
--          Format_Timeout (Timeout_Length));
--       " output buffer " & Image (Stream.Output_Buffer'address));
      if Test_Condition and Trace then
         Dump ("write", Item);
      end if;

--    if Timeout_Length /= No_Timeout then
--       This_Timeout := Timeout_Length;
--    end if;

      Put (Stream.Output_Buffer, Item); -- will block until room
      Log_out (Trace);

   exception
      when Fault: others =>
         Log_Exception (Trace, FAult);
         raise;

   end Write;

   ---------------------------------------------------------------------------
   function Writer_Stopped (
      Socket                     : in   Stream_Socket_Type
   ) return Boolean is
   ---------------------------------------------------------------------------

   begin
      Log_Here (Tracing, Socket.Image & " writer stopped " & Socket.Stream.Writer_Stopped'img);

      return Socket.Stream.Writer_Stopped;
   end Writer_Stopped;
   ---------------------------------------------------------------------------

   protected body Protected_Buffer_Type is

      function Image return String;

      function Prefix
      return String;

      -----------------------------------------------------------------------
      procedure Dump is
      -----------------------------------------------------------------------

      begin
         Put_Line (Prefix);
         Dump ("input buffer", Buffer);
      end Dump;

      -----------------------------------------------------------------------
      function Empty (
         Throw_Expression        : in     Boolean
      ) return Boolean is
      -----------------------------------------------------------------------

      begin
         Log_In (Tracing, Prefix);

         case State is

            when Ok =>
               Log_Out (Tracing, Kind'img &
                  (if Buffer_Count = 0 then " " else " not ") & "empty");
               return Buffer_Count = 0;

            when Closed | Failed =>
               Log_Out (Tracing, Kind'img &
                  (if Buffer_Count = 0 then " " else " not ") & "empty");
               return Buffer_Count = 0;

            when Timed_Out =>
               if Throw_Expression then
                  Log_Exception (Tracing, Kind'img);
                  raise IO_Failed with "buffer state " & State'img & " not ok at " & Here;
               else
                  Log_Out (Tracing, Kind'img & " empty");
                  return True;
               end if;

         end case;
      end Empty;

      -----------------------------------------------------------------------
      function Free
      return Index_Type is
      -----------------------------------------------------------------------

         Result      : constant Index_Type := Buffer_Length - Buffer_Count;

      begin
         Log_Here (Tracing, Kind'img & " Result" & Result'img &
            " state " & State'img);

         if State /= Ok then
            Log_Exception (Trace);
            raise IO_Failed with "buffer state " & State'img & " not ok at " & Here;
         end if;
         return Result;
      end Free;

      -----------------------------------------------------------------------
      -- return everything in buffer up to size of data
      entry Get (
         Data                    :    out Buffer_Type;
         Event                   :    out Event_Type;
         Last                    :    out Index_Type
      ) when Buffer_Count > 0 or else State /= Ok is
      -----------------------------------------------------------------------

      begin
         Log_In (Tracing, Prefix &
            " primmed" & Primed_Input'img &
            " Buffer_Count" & Buffer_Count'img &
            " tail" & Tail'img & " data first" & Data'first'img &
            " data'last" & Data'last'img);

         Log_Here (Test_Condition and Trace, Image);
         case State is

         when Closed =>
            Log_Exception (Trace, Prefix & " socket closed");
            raise Aborted with "Get called with closed socket at " & Here;

         when OK =>
            null;

         when Timed_Out =>
            Event := Timed_Out;
            Log_Out (Tracing, Prefix & " timed out");
            return;

         when Failed =>
            Log_Exception (Trace, Prefix);
            raise Aborted with "unexpected state " & State'img & " in get";

         end case;

         Event := State;
         Last := 0;

         for Index in Data'range loop
            Data (Index) := Buffer (Tail);
            Last := Index;

            if Tail = Buffer'last then
               Tail := Buffer'first;
            else
               Tail := Tail + 1;
            end if;

            Buffer_Count := Buffer_Count - 1;

            if Buffer_Count = 0 then   -- buffer empty
--             Head := Buffer'first;   -- reset pointers
--             Tail := Buffer'first;
               Log_Here (Debug, "last" & Last'img);
               exit;
            end if;
         end loop;

         if Tracing then
            Dump ("got", Data (Data'first .. Last));
         end if;

         Log_Out (Tracing, Prefix & " Event " & Event'img & " Last" & Last'img &
            " tail" & Tail'img &
            " Buffer_Count" & Buffer_Count'img);
--          " data " & Image (Data'address) &
--          " buffer " & Image (Buffer'address));
      end Get;

      -----------------------------------------------------------------------
      function Get_State return Event_Type is
      -----------------------------------------------------------------------

      begin
         return State;
      end Get_State;

      -----------------------------------------------------------------------
      function Image return String is
      -----------------------------------------------------------------------

      begin
         return Description.all & " " &
            " kind " & Kind'img & " " &
            " buffer count" & Buffer_Count'img &
            " head" & Head'img &
            " tail" & Tail'img &
            " state " & State'img &
            " primed input" & Primed_Input'img &
            " output" & Primed_Output'img;
      end Image;

      -----------------------------------------------------------------------
      function In_Buffer
      return Index_Type is
      -----------------------------------------------------------------------

      begin
         Log_Here (Tracing, Prefix & " Buffer_Count" & Buffer_Count'img &
            " state " & State'img);

         if State /= Ok then
            Log_Exception (Trace, Prefix);
            raise IO_Failed with "buffer state " & State'img & " not ok at " & Here;
         end if;
         return Buffer_Count;
      end In_Buffer;

      -----------------------------------------------------------------------
      function Prefix
      return String is
      -----------------------------------------------------------------------

      begin
         return Description.all & " " & Kind'img & " " & State'img &
            " count" & Buffer_Count'img;
      end Prefix;

      -----------------------------------------------------------------------
      procedure Prime_Output (
         Length                  : in     Index_Type) is
      -----------------------------------------------------------------------

      begin
         Primed_Output := Length;
      end Prime_Output;

      -----------------------------------------------------------------------
      entry Put (
         Data                    : in     Buffer_Type;
         Event                   :    out Event_Type
      ) when Buffer_Length - Buffer_Count >= Primed_Output or else State /= Ok is
      -- block when not room in buffer or bad state
      -----------------------------------------------------------------------

      begin
         Log_In (Tracing, Prefix & " primed" & Primed_Output'img &
            " head" & Head'img & " data'first" & Data'first'img &
            " data'last" & Data'last'img &
            " buffer count" & Buffer_Count'img & " state " & State'img);
         if Primed_Output = 0 then
            raise IO_Failed with "not primed for put";
         end if;

         Event := State;
         case State is

             when Ok =>
               null;

            when Timed_Out =>
               Log_Here (Tracing, Kind'img & " timed out");
               State := Ok;      -- more data now availabl
   --          Timeout_Time := Ada_Lib.Time.Ada_Lib.Time.No_Time;
   --          return;

            when Closed =>
               Log_Out (Tracing, Kind'img & " closed");
               return;

            when Failed =>
               Log_Exception (Tracing, Prefix & " failed");
               raise IO_Failed with "buffer state " & State'img & " not ok at " & Here;
         end case;

         if Buffer_Length - Buffer_Count < Primed_Output then
            raise IO_Failed with "not room in buffer for primmed output";
         end if;

         for Index in Data'range loop
            Buffer (Head) := Data (Index);

            if Head = Buffer'last then
               Head := Buffer'first;   -- loop around
            else
               Head := Head + 1;
            end if;

            Buffer_Count := Buffer_Count + 1;

            if Buffer_Count > Buffer'length then
               raise IO_Failed with "buffer overflow";
            end if;
         end loop;

         if Tracing then
            Dump ("put all data ", Data);
            Dump ("Buffer", Buffer);
         end if;

         Log_Here (Test_Condition and Trace, Image);

         Log_Out (Tracing, Prefix & " Buffer_Count" & Buffer_Count'img &
            " Head" & Head'img & " event " & Event'img);
      end Put;

      -----------------------------------------------------------------------
      procedure Reset is
      -----------------------------------------------------------------------

      begin
         State := OK;
      end Reset;

      -----------------------------------------------------------------------
      procedure Set_Event (
         Event          : in     Event_Type;
         From           : in     String := Here) is
      -----------------------------------------------------------------------

         type Change_Action_Type is (Allow, Ignore, No_Change, Raise_Exception);


         Valid_Transitions    : constant array (
                                 Event_Type'range,                   -- current
                                 Event_Type'range) of Change_Action_Type := (   -- new
                                    Closed      => (
                                       Closed      => No_Change,
                                       Failed      => Allow,
                                       OK          => Raise_Exception,
                                       Timed_Out   => Raise_Exception
                                    ),
                                    Failed      => (
                                       Closed      => Ignore,
                                       Failed      => No_Change,
                                       OK          => Raise_Exception,
                                       Timed_Out   => Raise_Exception
                                    ),
                                    OK          => (
                                       Closed      => Allow,
                                       Failed      => Allow,
                                       OK          => No_Change,
                                       Timed_Out   => Allow
                                    ),
                                    Timed_Out   => (
                                       Closed      => Allow,
                                       Failed      => Allow,
                                       OK          => Allow,
                                       Timed_Out   => No_Change
                                    )
                                 );
         Transition  : constant Change_Action_Type :=
                        Valid_Transitions (State, Event);

      begin
         Log_In (Tracing, Prefix & " event " & Event'img &
            " transition " & Transition'img &
            " from " & From);

         case Transition is

            when Allow =>
               State := Event;

            when Ignore | No_Change =>
               null;

            when Raise_Exception =>
               Log_Exception (Trace);
               raise Aborted with "invalid state transition from " & State'img &
                  " to " & Event'img;
         end case;

         Log_Out (Tracing, Prefix);
      end Set_Event;

      -----------------------------------------------------------------------
      function Timed_Out
      return Boolean is
      -----------------------------------------------------------------------

      begin
         Log_In (Trace, Prefix);
         return State = Timed_Out;
--
--       declare
--          Now                     : constant Ada_Lib.Time.Time_Type := Ada_Lib.Time.Now;
--          Result                  : constant Boolean :=
--                                     (if Timeout_Time = Ada_Lib.Time.Ada_Lib.Time.No_Time then
--                                           False
--                                        else
--                                           Now > Timeout_Time);
--       begin
--          Log_Out (Trace, "now " & From_Start (Now) &
--             " result " & Result'img);
--
--          return Result;
--       end;
--
--    exception
--       when Fault: others =>
--          Trace_Exception (Trace, Fault);
--          Log_Exception (Trace);
--          raise;
--
      end Timed_Out;

      -----------------------------------------------------------------------
      procedure Trace_State is
      -----------------------------------------------------------------------

      begin
         Log_Here (Prefix & " Buffer_Count" & Buffer_Count'img &
            " head" & Head'img & " tail" & Tail'img &
            " Primed_Output" & Primed_Output'img);
      end Trace_State;

   end Protected_Buffer_Type;

--   -----------------------------------------------------------------------
--   package body Timer_Event_Package is
--
--      ---------------------------------------------------------------------------
--      function Allocate_Event (
--         Buffer                     : in     Protected_Buffer_Access;
--         Wait                       : in     Duration;
--         Description                : in String := ""
--      ) return Timer_Event_Access is
--      ---------------------------------------------------------------------------
--
--         Local_Description          : aliased String := Description; -- pointer only
--                                       -- temperarily used
--
--      begin
--         return new Timer_Event_Type (
--            Buffer      => Buffer,
--            Description => (if Description'length = 0 then
--                              Null
--                           else
--                              Local_Description'unchecked_access),
--            Offset      => Ada_Lib.Timer.Wait (Wait));
--      end Allocate_Event;
--
--      ---------------------------------------------------------------------------
--      overriding
--      procedure Callback (
--         Event             : in out Timer_Event_Type) is
--      ---------------------------------------------------------------------------
--
--      begin
--         Log_In (Trace, "Timed_Out");
--   --    if not Event.Cancel then
--   --       raise IO_Failed with "could not cancel event";
--   --    end if;
--         Event.Buffer.Set_Event (Timed_Out);
--         Log_Out (Trace);
--
--      exception
--         when Fault: others =>
--            Trace_Exception (Trace, Fault);
--            raise;
--
--      end Callback;
--
----    ---------------------------------------------------------------------------
----    overriding
----    function Create_Event (
----       Offset                  : in     Ada_Lib.Timer.Duration;
----       Dynamic                 : in     Boolean;
----       Repeating               : in     Boolean;
----       Description             : in     String
----    ) return Timer_Event_Type is
----    ---------------------------------------------------------------------------
----
----       Local_Dexcription       : aliased String := Description;
----
----    begin
----       return Result: Timer_Event_Type (
----          Description => Local_Dexcription'unchecked_access,
----          Buffer      => Null,
----          Offset      => Offset
----       ) do
----          null;
----       end Return;
----    end Create_Event;
----
--   end Timer_Event_Package;

   -----------------------------------------------------------------------
   task body Input_Task is
   ---------------------------------------------------------------

      Stream_Pointer             : Stream_Access;

   begin
      Log_In (Trace, Quote ("description", Description));
      Ada_Lib.Trace_Tasks.Start ("input task", Here);
      accept Open (
         Stream                  : in   Stream_Access;
         Priority                : in   Ada_Lib.OS.Priority_Type;
         From                    : in   String := Ada_Lib.Trace.Here) do

         Stream_Pointer := Stream;
         Stream_Pointer.Reader_Task_Id := Ada.Task_Identification.Current_Task;
         Ada_Lib.OS.Set_Priority (Priority);
         Stream_Pointer.Reader_Stopped := False;
         Log_Here (Trace, "from " & From &
            " socket " & Stream.Socket.Image);

      end Open;

      loop
         Log_Here (Tracing, "socket " & Stream_Pointer.Socket.Image &
            " closed " & Stream_Pointer.Socket_Closed'img);
--          " addresses socket " & Image (Stream_Pointer.Socket.all'address) &
--          " stream " & Image (Stream_Pointer.all'address));

         if Stream_Pointer.Socket_Closed then      -- socket closed
            Stream_Pointer.Input_Buffer.Set_Event (Closed);
            exit;
         end if;

         declare
            Poll_Byte         : Buffer_Type (1 .. 1);
--          Event             : Event_Type;
            Last_Read         : Index_Type;

         begin
            GNAT.Sockets.Receive_Socket (Stream_Pointer.Socket.GNAT_Socket,
               Poll_Byte, Last_Read, GNAT.Sockets.Wait_For_A_Full_Reception);
               -- block on one byte read if no data in socet
            Log_Here (Trace, "Last_Read" & Last_Read'img &
               " poll byte " & Hex_IO.Hex (
                  Interfaces.Unsigned_8 (Poll_Byte (1))) &
               " closed " & Stream_Pointer.Socket_Closed'img);

            if Last_Read = 0 then   -- socket was closed
               Log_Here (Trace, "GNAT socket closed");
               exit;
            end if;

            if Stream_Pointer.Socket_Closed then      -- socket closed
               Stream_Pointer.Input_Buffer.Set_Event (Closed);
               Log_Here (Trace, "loop exit ");
               exit;
            end if;

            if Stream_Pointer.Socket_Closed then      -- socket closed
               Stream_Pointer.Input_Buffer.Set_Event (Closed);
               Log_Here (Trace, "closing socket");
               exit;
            end if;

            declare
               Last_Read         : Index_Type;
               Size_Request      : GNAT.Sockets.Request_Type := (
                                    Name  => GNAT.Sockets.N_Bytes_To_Read,
                                    Size  => 0);
            begin
               -- find out how many more bytes are available to read
               GNAT.Sockets.Control_Socket (Stream_Pointer.Socket.GNAT_Socket,
                  Size_Request);

               if Size_Request.Size = 0 then    -- no moredata available
                  Log_Here (Tracing, "only 1 byte in input");
                     -- put will block until room for whole buffer is available
                  Put (Stream_Pointer.Input_Buffer, Poll_Byte);
               else                             --  read it
                  Log_Here (Tracing, "request size" & Size_Request.Size'img);
                  -- read exact number of bytes available limited by size of buffer
                  declare
                     Expected_Length   : constant Index_Type :=
                                          Index_Type (Size_Request.Size + 1);
                     Data              : Buffer_Type (1 .. Expected_Length);

                  begin
                     Data (1) := Poll_Byte (1);
                     GNAT.Sockets.Receive_Socket (
                        Stream_Pointer.Socket.GNAT_Socket,
                        Data (2 .. Expected_Length),
                        Last_Read);
                     Log_Here (Tracing, "Last_Read" & Last_Read'img );

                     if Last_Read /= Index_Type (Size_Request.Size + 1) then
                        Log_Exception (Trace, "short read");
                        raise IO_Failed with "short read at " & Here &
                           " read" & Last_Read'img &
                           " expected" & Expected_Length'img;
                     end if;

                        -- put will block until room for whole buffer is available
                     if Tracing or Trace_IO then
                        Dump ("GNAT socket received",
                           Data (Data'first .. Expected_Length));
                     end if;
                     Put (Stream_Pointer.Input_Buffer, Data);
                  end;
               end if;

            exception
               when Fault: GNAT.Sockets.Socket_Error =>
                  Trace_Exception (Fault);
                  if GNAT.Sockets.Resolve_Exception (Fault) /=
                        GNAT.Sockets.Resource_Temporarily_Unavailable then
                     Stream_Pointer.Input_Buffer.Set_Event (Failed);
                  else
                     delay 0.05;
                  end if;
            end;

         exception
            when Fault: GNAT.Sockets.Socket_Error =>
               declare
                  Socket_Closed  : constant Boolean :=
                                    Stream_Pointer.Input_Buffer.Get_State = Closed;
               begin
                  Trace_Message_Exception (Trace and not Socket_Closed, Fault,
--                Trace_Message_Exception (true or Trace, Fault,
                     (if Socket_Closed then
                        ""
                     else
                        "not ") &
                     "expected exception Socket closed " & Stream_Pointer.Image);
                  if not Socket_Closed then
                     Stream_Pointer.Input_Buffer.Set_Event (Closed);
                  end if;
                  exit;
               end;
         end;

      end loop;
      Log_Here (Trace, "loop exit " & Quote ("description", Description));
      Stream_Pointer.Reader_Stopped := True;

      Ada_Lib.Trace_Tasks.Stop;
      Log_Out (Trace);

   exception
      when Fault: others =>
         Trace_Message_Exception (Fault, Stream_Pointer.Socket.Image);
         Stream_Pointer.Reader_Stopped := True;
         Stream_Pointer.Input_Buffer.Set_Event (Failed);
         Stream_Pointer.Output_Buffer.Set_Event (Failed);
         Ada_Lib.Trace_Tasks.Stop;
         Log_Out (Trace);

   end Input_Task;

   ---------------------------------------------------------------
   task body Output_Task is
   ---------------------------------------------------------------

      Stream_Pointer             : Stream_Access;

   begin
      Log_In (Trace, Quote ("description", Description));

      accept Open (
         Stream                  : in   Stream_Access;
         Priority                : in   Ada_Lib.OS.Priority_Type;
         From                    : in   String := Ada_Lib.Trace.Here) do

         Ada_Lib.Trace_Tasks.Start ("output task " & Stream.Socket.Image, Here);
         Stream_Pointer := Stream;
         Stream_Pointer.Writer_Task_Id := Ada.Task_Identification.Current_Task;
         Ada_Lib.OS.Set_Priority (Priority);
         Stream_Pointer.Writer_Stopped := False;
         Log_Here (Tracing, "from " & From &
            " socket " & Stream.Socket.Image);
--          " socket " & Image (Stream_Pointer.Socket'address));

      end Open;

      loop  -- loop getting buffers to write
         declare
            State    : constant Event_Type :=
                        Stream_Pointer.Output_Buffer.Get_State;
         begin
            Log_Here (Trace,
               Quote ("descritpion", Stream_Pointer.Socket.Description) & " " &
               " state " & State'img & " " &
               Stream_Pointer.Socket.Image);
            case State is

               when Closed =>
                  Log_Here (Tracing, "output buffer closed");
                  exit;

               when Failed =>
                  Log_Here (Tracing, "output buffer failed");
                  exit;

               when Ok =>
                  Log_Here (Tracing, "got state OK");

               when Timed_Out =>
                  Log_Here (Tracing, "output buffer timed out");
                  exit;

            end case;
         end;

         declare
            Data     : Stream_Buffer_Type;
            Event    : Event_Type;
            Last     : Index_Type;

         begin
            Log_Here (Tracing, Stream_Pointer.Image);

            begin
               Stream_Pointer.Output_Buffer.Get (Data, Event, Last);

            exception
               when Fault: Aborted =>     -- socket got closed
                  if Stream_Pointer.Socket_Closed then
                     Log_Here (Trace, "closed " &
                        Stream_Pointer.Socket_Closed'img);
                  else
                     Trace_Exception (Tracing, Fault);
                  end if;
                  exit;

               when Fault: others =>
                  Trace_Exception (Trace, Fault, Here);
                  raise;

            end;

            Log_Here (Tracing, "event " & Event'img & " last" & Last'img &
               " closed " & Stream_Pointer.Socket_Closed'img);

            if Last = 0 and then Stream_Pointer.Socket_Closed then
               exit;
            end if;

            case Event is

--             when Buffer_Limit =>
--                raise Aborted with "buffer limit after get";

               when OK | Closed =>  -- write even if closed but last > 0
                  Log_Here (Tracing, Stream_Pointer.Image);
                  declare
                     Start_Send  : Index_Type := Data'first;
                     Send_Last   : Index_Type;

                  begin
                     loop  -- until whole buffer sent
                        begin
pragma Assert (Stream_Pointer /= Null, "stream pointer null");
pragma Assert (Stream_Pointer.socket /= Null, "socket null");
pragma Assert (Stream_Pointer.socket.Is_Open, "socket not open");
pragma Assert (Stream_Pointer.socket.GNAT_Socket /= GNAT.Sockets.No_Socket,
   "no socket");
                           Log_Here (Trace, Stream_Pointer.Socket.Image);
                           if not Stream_Pointer.Socket.GNAT_Socket_Open then
                              raise IO_Failed with "GNAT Socket closed " & Stream_Pointer.Socket.Image;
                           end if;

                           if Tracing or Trace_IO then
                              Dump ("GNAT socket send", Data (Start_Send .. Last));
                           end if;

                           GNAT.Sockets.Send_Socket (
                              Stream_Pointer.Socket.GNAT_Socket,
                              Data (Start_Send .. Last), Send_Last);

                           Log_Here (Trace, "Start_Send" & Start_Send'img &
                              " Send_Last " & Send_Last'img &
                              " last " & Last'img & " on socket " &
                                 Stream_Pointer.Socket.Image);

                           if Send_Last = Last then
                              exit;
                           end if;

                           Start_Send := Send_Last + 1;

                        exception
                           when Fault: GNAT.Sockets.Socket_Error =>
                              Trace_Message_Exception (Trace, Fault, "stream " &
                                 Ada_Lib.Strings.Image (Stream_Pointer.all'address));

                              if GNAT.Sockets.Resolve_Exception (Fault) /=
                                    GNAT.Sockets.Resource_Temporarily_Unavailable then
                                 Stream_Pointer.Output_Buffer.Set_Event (Failed);
                                 exit;
                              else
                                 delay 0.05;
                              end if;
                        end;
                     end loop;
                     Log_Here (Tracing);
                  end;

--             when Closed =>
--                Log_Here (Trace);
--                exit;

               when Failed | Timed_Out =>
                  null;

            end case;
         end;
      end loop;
      Log_Here (Trace, "socket " & Ada_Lib.Strings.Image (
         Stream_Pointer.Socket'address));

      if    Stream_Pointer.Socket /= Null and then
            Stream_Pointer.Socket.Is_Open then
         Log_Here (Trace);
--       Stream_Pointer.Close;
         Stream_Pointer.Input_Buffer.Set_Event (Closed);
      end if;
      Stream_Pointer.Writer_Stopped := True;

      Ada_Lib.Trace_Tasks.Stop;
      Log_Out (Trace);

   exception
      when Fault: others =>
         Trace_Exception (Fault, Here);
         Stream_Pointer.Writer_Stopped := True;
         Ada_Lib.Trace_Tasks.Stop;
         Log_Out (Trace);

   end Output_Task;

begin
--Trace := True;
--Tracing := True;
   Log_Here (Elaborate or Tracing);
end Ada_Lib.Socket_IO.Stream_IO;
