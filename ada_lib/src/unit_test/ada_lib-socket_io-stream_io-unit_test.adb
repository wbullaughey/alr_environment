with Ada.Exceptions;
--with Ada.Real_Time;
with Ada.Text_IO;use Ada.Text_IO;
--with Ada_Lib.Options.Flags;
with AUnit.Assertions; use AUnit.Assertions;
--with Ada_Lib.Options.AUnit_Lib;
with Ada_Lib.Options.Program;
with Ada_Lib.Options.Unit_Test;
--with Ada_Lib.Options.Verification;
with Ada_Lib.OS;
with Ada_Lib.Socket_IO.Client;
with Ada_Lib.Socket_IO.Server;
--with Ada_Lib.Socket_IO.Stream_IO;
with Ada_Lib.Strings;
--with Ada_Lib.Time;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with Ada_Lib.Trace_Tasks;
--with Ada_Lib.Unit_Test.Test_Cases;
with GNAT.Source_Info;
with Hex_IO;
--with Runtime_Options;
with SYSTEM.ASSERTIONS;

-- pragma Elaborate (Ada_Lib.OS);

package body Ada_Lib.Socket_IO.Stream_IO.Unit_Test is

   use type Ada.Streams.Stream_Element_Array;
   use type Ada.Streams.Stream_Element_Offset;
   use type Ada_Lib.Options.Unit_Test.Random_Generator_Number_Type;
   use type Port_Type;

   type Length_Or_Answer_Type       is mod 2 ** 32;

   task type Client_Task_Type (
      Description                : Ada_Lib.Strings.String_Constant_Access) is

      entry Start (
         Test                    : in     Socket_Test_Access);

   end Client_Task_Type;

   type Client_Task_Access       is access Client_Task_Type;

-- type Length_Buffer_Type    is new Buffer_Type (1 .. 4);

   task type Server_Task_Type (
      Description                : Ada_Lib.Strings.String_Constant_Access) is

      entry Start (
         Test                    : in     Socket_Test_Access);

   end Server_Task_Type;

   type Server_Task_Access       is access Server_Task_Type;


   procedure Socket_Open_Close (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Socket_Send_Receive_Fixed_Record (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Socket_Send_Receive_Poll (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Socket_Send_Receive_Variable_Record (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Socket_Acknowledge_Send_Receive (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Send_Receive_Missmatch_Read_Length (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Socket_Timeout_Send_Receive (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   Data_Generator_Index          : constant := 2;
   Default_Client_Read_Timeout_Time
                                 : constant Duration := 1.0;
   Default_Server_Read_Timeout_Time
                                 : constant Duration := 1.0;
   Delay_Generator_Index         : constant := 3;
   Delay_Time                    : constant Duration := 0.5;   -- time to delay second part of write to test timeout
-- Limit_Length                  : constant := 128;
   Notify_Frequency              : constant := 10;
   Offset_Generator_Index        : constant := 1;
   Required_Random_Number_Generators
                                 : constant := Delay_Generator_Index;
   Server_Name                   : constant String := "localhost";

   ---------------------------------------------------------------
   overriding
   function Name (Test : Socket_Test_Type) return AUnit.Message_String is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

   begin
      return AUnit.Format (Suite_Name);
   end Name;

   ---------------------------------------------------------------
   procedure Record_Socket (
      Test                       : in out Socket_Test_Type;
      Socket                     : in out Socket_Type'class) is
   ---------------------------------------------------------------

   begin
      Test.Socket_Count := Test.Socket_Count + 1;
      Test.Sockets (Test.Socket_Count) := Socket'unchecked_access;
      Log_Here (Debug, "record socket " & Socket.Image &
         " count" & Test.Socket_Count'img);
   end Record_Socket;

   ---------------------------------------------------------------
   overriding
   procedure Register_Tests (Test : in out Socket_Test_Type) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug);

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Socket_Open_Close'access,
         Routine_Name   => AUnit.Format ("Socket_Open_Close")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Socket_Send_Receive_Fixed_Record'access,
         Routine_Name   => AUnit.Format ("Socket_Send_Receive_Fixed_Record")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Socket_Send_Receive_Poll'access,
         Routine_Name   => AUnit.Format ("Socket_Send_Receive_Poll")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Socket_Send_Receive_Variable_Record'access,
         Routine_Name   => AUnit.Format ("Socket_Send_Receive_Variable_Record")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Socket_Acknowledge_Send_Receive'access,
         Routine_Name   => AUnit.Format ("Socket_Acknowledge_Send_Receive")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Send_Receive_Missmatch_Read_Length'access,
         Routine_Name   => AUnit.Format ("Send_Receive_Missmatch_Read_Length")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Socket_Timeout_Send_Receive'access,
         Routine_Name   => AUnit.Format ("Socket_Timeout_Send_Receive")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
         Routine        => Server_Failure'access,
         Routine_Name   => AUnit.Format ("Server_Failure")));

      Log_Out (Debug);
   end Register_Tests;

   ---------------------------------------------------------------
   overriding
   procedure Set_Up (
      Test                       : in out Socket_Test_Type) is
   ---------------------------------------------------------------

      Nested_Options
         : Options.Unit_Test.Ada_Lib_Unit_Test_Nested_Options_Type
            renames Options.Unit_Test.Ada_Lib_Unit_Test_Nested_Options_Type (
               Options.Unit_Test.
                  Get_Modifiable_Ada_Lib_Unit_Test_Nested_Options.all);
   begin
      Log_In (Debug or Trace_Set_Up_Tear_Down);
      if Nested_Options.Number_Random_Generators = 0 then
         Nested_Options.Number_Random_Generators :=
            Required_Random_Number_Generators;
      elsif Nested_Options.Number_Random_Generators /=
            Required_Random_Number_Generators then
         raise Fault with "wrong number random number generators" &
            Nested_Options.Number_Random_Generators'img &
            " required" & Required_Random_Number_Generators'img;
      end if;
      Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type (Test).Set_Up;
      Test.Answer := Success;
      Test.Client_Completed := False;
      Test.Client_Delayed             := False;
      Test.Client_Failed              := False;
      Test.Client_Read_Timeout_Time   := Default_Client_Read_Timeout_Time;
      Test.Client_Started             := False;
      Test.Client_Write_Timeout_Time  := No_Timeout;
--    Test.Do_Acknowledgement         := False;
--    Test.Missmatch_Read_Length      := False;
      Test.Server_Completed := False;
      Test.Server_Failed    := False;
      Test.Server_Port                := Default_Port;
      Test.Server_Read_Timeout_Time   := Default_Server_Read_Timeout_Time;
                                          -- time out incase client fails
      Test.Server_Started             := False;
      Test.Server_Timedout            := False;
      Test.Server_Write_Timeout_Time  := No_Timeout;
      Test.Socket_Count := 0;

      Log_Out (Debug or Trace_Set_Up_Tear_Down);

   exception

      when Fault: others =>
         Trace_Exception (Fault);
         Log_Exception (Trace, Fault);
         raise;

   end Set_Up;

   --------------------------------------------------------------
   procedure Send_Receive (
      Test                       : in out Socket_Test_Type;
      From                       : in     String := GNAT.Source_Info.Source_Location) is
   ---------------------------------------------------------------

      Client         : Client_Task_Access := Null;
      Client_Description
                     : constant Ada_Lib.Strings.String_Constant_Access :=
                        new String'("client send receive");

--    Options        : Ada_Lib.Options.AUnit_Lib.Aunit_Program_Options_Type'class renames
--                      Ada_Lib.Options.AUnit_Lib.
--                         Aunit_Program_Options_Constant_Class_Access (
--                            Ada_Lib.Options.Verification.Get_Ada_Lib_Read_Only_Nested_Options).all;
      Send_Started   : Boolean := True;
      Server         : Server_Task_Access := Null;
      Server_Description
                     : constant Ada_Lib.Strings.String_Constant_Access :=
                        new String'("server send receive");
      Server_Read_Timeout_Time
                     : Duration renames
                        Test.Server_Read_Timeout_Time;
   begin
      Log_In (Debug, "mode " & Test.Read_Write_Mode'img);

      case Test.Read_Write_Mode is

         when Read_Timeout =>
            Test.Client_Delay_Write_Time := 0.2;
            Test.Server_Read_Timeout_Time := 0.1;  -- want server to timeout

         when Unmatched_Record_Length =>
            declare
               Generator      : Ada_Lib.Unit_Test.Test_Cases.
                                 Random_Number_Generator.Generator renames
                                    Test.Random_Generators (
                                       Delay_Generator_Index);
               Random         : constant Integer := Ada_Lib.Unit_Test.
                                 Test_Cases.Random_Number_Generator.Random (
                                    Generator);
               Module         : constant Integer := Random mod 500;
               Fraction       : constant Float := Float (Module) / 1000.0 + 0.01;
                                   -- /= 0
            begin
               Test.Server_Wait_Time := Duration (Fraction);
               Test.Client_Read_Timeout_Time :=
                  Test.Server_Wait_Time * 10.0 + 1.0;
               Log_Here (Debug, "Client_Read_Timeout_Time " &
                  Test.Client_Read_Timeout_Time'img);
               -- give time for server to wait 10 times plus extra
            end;

         when others =>
            Log_Here (Debug);

      end case;

      Log_Here (Debug,
         " Client Read Timeout " & Test.Client_Read_Timeout_Time'img &
         " Client Write Timeout " & Test.Client_Write_Timeout_Time'img &
         " Client_Delay_Write_Time " & Test.Client_Delay_Write_Time'img &
         " Server Read Timeout " & Test.Server_Read_Timeout_Time'img &
         " Server_Wait_Time " & Test.Server_Wait_Time'img &
         " Server Write Timeout " & Test.Server_Write_Timeout_Time'img &
         " called from " & From);

      Client := new Client_Task_Type (Client_Description);
      delay 0.1;  -- client get initialized before starting server
      Server := new Server_Task_Type (Server_Description);
      if Test.Client_Failed then
         Log_Here (Debug, "client failed");
         Send_Started := False;
      end if;

      if Test.Server_Failed then
         Log_Here (Debug, "Server failed");
         Send_Started := False;
      end if;

      if Test.Server_Timedout then
         Log_Here (Debug, "Server timeout");
         Send_Started := False;
      end if;

      if not Send_Started then
         Assert (False, "server or client not started");
      end if;

      -- initialize data buffer
      declare
         Generator      : Ada_Lib.Unit_Test.Test_Cases.Random_Number_Generator.
                           Generator renames
                              Test.Random_Generators (Data_Generator_Index);
      begin
         for Index in Test.Send_Data'range loop
            declare
               Random   : constant Integer := Ada_Lib.Unit_Test.Test_Cases.
                           Random_Number_Generator.Random (Generator);
            begin
               Test.Send_Data (Index) := Data_Type (
                  Random mod Integer (Data_Type'last));
            end;
         end loop;
      end;

      if Debug and then Test.Read_Write_Mode /= No_Data then
         Dump (Test.Send_Data'address, Test.Send_Data'length,32,Width_8,"send data", Here);
      end if;
      Log_Here (Debug, "start server task");
      Server.Start (    -- reads from client and then writes to client
         Test              => Test'unchecked_access);
      delay 0.1;  -- let server start
      if not Test.Server_Started then
         Log_Exception (Debug);
         Assert (False, "server did not start");
      end if;

      Log_Here (Debug, "start client task");
      Client.Start (    -- writes to server and reads from server
         Test              => Test'unchecked_access);

      delay 0.1;  -- let client start
      if not Test.Client_Started then
         Assert (False, "client did not start");
      end if;

      Log_Here (Debug, "wait for tasks to complete");

      loop
         if    Test.Client_Completed and then
               Test.Server_Completed then
            Log_Here (Debug, "tasks completed");
            exit;
         end if;
         delay 0.2;
      end loop;

      declare
         Why      : constant String :=
            (if Test.Server_Timedout then " server timedout" else "") &
            (if Test.Server_Failed then " server failed" else "") &
            (if Test.Client_Failed then " client failed" else "") &
            (if Test.Client_Timed_Out then " client timed out" else "");
         Message  : constant String := " answer " & Test.Answer'img &
                     (if Why'length > 0 then
                        " and " & Why
                     else
                        "");
      begin
         Log_Here (Debug, Message);
         if Debug then
            Dump (Test.Received_Data'address,
               Test.Received_Data'length, 32, Width_8, "send data", Here);
         end if;
         Assert (Test.Answer = Success, Message);
      end;

      if Test.Send_Data = Test.Received_Data then
         Log_Here (Debug);
      elsif Test.Client_Timed_Out and then
            not Test.Server_Write_Response then
         Log_Here (Debug);
      elsif Server_Read_Timeout_Time = 0.0 then
         Log_Here (Debug, "data missmach");
         Hex_IO.Dump_8 (Test.Send_Data'address, Test.Send_Data'size, 32, "sent data");
         Hex_IO.Dump_8 (Test.Received_Data'address, Test.Received_Data'size, 32, "received data");
         Test.Set_Answer (Bad_Data);
      else
         Log_Here (Debug, "don't expect read buffer");
      end if;
      Log_Out (Debug);

   exception

      when Fault: others =>
         Log_Exception (Debug, Fault);
         raise;

   end Send_Receive;

   --------------------------------------------------------------
   procedure Server_Failure (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

      Answer                     : Buffer_Type (1 ..
                                    Buffer_Bytes (Length_Or_Answer_Type'size));
      Ack                        : Length_Or_Answer_Type;
      for Ack'address use Answer'address;
      Local_Test                 : Socket_Test_Type renames Socket_Test_Type (Test);
      Send_Buffer                : constant Data_Buffer_Type := (
                                    others => 123);
      Write_Length               : constant Index_Type := Send_Buffer'length;
      Length_Buffer              : Buffer_Type (1 .. 4);
      for Length_Buffer'address use Write_Length'address;

      OK_Repetition              : constant := 1;    -- Repetition 1 ok
      No_Server_Repetition       : constant := 2;    -- server not started so
                                                   -- connect should fail
      Wrong_Port                 : constant := 3;  -- should fail

   begin
      Log_In (Debug);
      Local_Test.Read_Write_Mode := No_Data;
      Local_Test.Client_Completed := True;   -- client not used

      for Repetition in OK_Repetition .. Wrong_Port loop
         declare
            Port                 : constant Port_Type :=
                                    Default_Port +
                                    Port_Type (Repetition);
         begin
            Put_Line ("doing Repetition" & Repetition'img &
               " port" &
               " will fail on Repetition" & No_Server_Repetition'img);
            Local_Test.Repetition := Repetition;
            Local_Test.Server_Completed := False;
            Local_Test.Select_Timeout_Expected := Repetition /= OK_Repetition;
            Local_Test.Server_Port := (if Repetition = Wrong_Port then
                  Default_Port
               else
                  Port);
            Local_Test.Server_Started := False;
            declare
               Client_Description   : aliased constant String :=
                                       "client repetition" & Repetition'img;
               Server               : Server_Task_Access := Null;
               Client_Socket        : constant Ada_Lib.Socket_IO.Client.
                                      Client_Socket_Access := new Ada_Lib.
                                         Socket_IO.Client.Client_Socket_Type (
                                            Client_Description'unchecked_access);
               Server_Description   : aliased constant String :=
                                       "client repetition" & Repetition'img;
            begin
--             Socket.Set_Description ("client socket repetition" & Repetition'img);
               if Repetition /= No_Server_Repetition then
                  Server := new Server_Task_Type (Server_Description'unchecked_access);
                  delay 0.1;  -- let server get initialized
                  Server.Start (Local_Test'unchecked_access);
                  delay 0.1;  -- let server get initialized

                  Log_Here (Debug, "started" & Repetition'img);
                  Assert (Local_Test.Server_Started, "server did not start");
                  delay 0.1;  -- let server socket get bound
               end if;

               Log_Here (Debug, "connect to server Repetition" &
                  Repetition'img & " port" & Port'img);

               begin
                  Client_Socket.Connect (Server_Name, Port, Reuse => True);

               exception
                  when Fault: others =>
                     Trace_Message_Exception (Debug, Fault,
                        (if Repetition = OK_Repetition then
                           "unexpected "
                        else
                           "expected ") &
                     "exception");
                     case Repetition is

                        when No_Server_Repetition =>
                           null;

                        when OK_Repetition =>
                           Assert (False, "unexpected failed exception");

                        when Wrong_Port =>
                           while not Local_Test.Server_Completed loop
                              delay 0.2;
                           end loop;

                     end case;

                     Client_Socket.Close;
                     goto Loop_Repeat;
               end;

               if Repetition = No_Server_Repetition then
                  Assert (False, "exception for connect failure did not happen");
               end if;

               Log_Here (Debug, "connected to server. write length" &
                  Write_Length'img);
               Client_Socket.Write (Length_Buffer);
               Log_Here (Debug, "write buffer" &
                  Natural'(Send_Buffer'size/8)'img);
               Client_Socket.Write (Send_Buffer);
               while not Local_Test.Server_Completed loop
                  delay 0.2;
               end loop;

               -- read is done by server task
               Log_Here (Debug, "close socket for repetition" & Repetition'img);
               Client_Socket.Close;

               Log_Here (Debug,  "Repetition" & Repetition'img &
                  " answer " & Local_Test.Answer'img &
                  " server task completed" &
                  (if Local_Test.Server_Timedout then " server timedout" else "") &
                  (if Local_Test.Server_Failed then " server failed" else ""));

               Assert (Local_Test.Answer = Success,
                  "Repetition " & Repetition'img &
                  " Local_Test.Answer " & Local_Test.Answer'img);
               Log_Here (Debug);

            exception

               when Fault: AUNIT.ASSERTIONS.ASSERTION_ERROR =>
                  Trace_Message_Exception (Debug, Fault, "unexpected assertion");

               when Fault: others =>
                  Trace_Exception (Debug, Fault, Here);
                  Assert (False, "unexpected exception " &
                     Ada.Exceptions.Exception_Name (Fault) & " " &
                     Ada.Exceptions.Exception_Message (Fault));

            end;
            Log_Here (Debug, "Repetition" & Repetition'img);
         end;
<< Loop_Repeat >>
      end loop;
      Log_Out (Debug);
   end Server_Failure;

   --------------------------------------------------------------
   procedure Socket_Open_Close (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

      Local_Test                 : Socket_Test_Type renames Socket_Test_Type (Test);

   begin
      Log_In (Debug);
      Local_Test.Read_Write_Mode := No_Data;
      Send_Receive (Local_Test);
      Log_Out (Debug);

   exception

      when Fault: others =>
         Trace_Exception (Fault);

   end Socket_Open_Close;

   ------------------------------------------------------------
   procedure Socket_Send_Receive_Fixed_Record (
      Test                      : in out AUnit.Test_Cases.Test_Case'class) is
-- pragma Unreferenced (Test);
   ---------------------------------------------------------------

      Local_Test                 : Socket_Test_Type renames Socket_Test_Type (Test);

   begin
      Log_In (Debug);
      Local_Test.Read_Write_Mode := Matching_Record_Length;
      Send_Receive (Local_Test);
      Log_Out (Debug);

   end Socket_Send_Receive_Fixed_Record;

   --------------------------------------------------------------
   procedure Socket_Send_Receive_Poll (
      Test                      : in out AUnit.Test_Cases.Test_Case'class) is
-- pragma Unreferenced (Test);
   ---------------------------------------------------------------

      Local_Test                 : Socket_Test_Type renames Socket_Test_Type (Test);

   begin
      Log_In (Debug);
      Local_Test.Read_Write_Mode := Polling_Read;
      Send_Receive (Local_Test);
      Log_Out (Debug);
   end Socket_Send_Receive_Poll;

   --------------------------------------------------------------
   procedure Socket_Send_Receive_Variable_Record (
      Test                      : in out AUnit.Test_Cases.Test_Case'class) is
-- pragma Unreferenced (Test);
   ---------------------------------------------------------------

      Local_Test     : Socket_Test_Type renames Socket_Test_Type (Test);

   begin
      Log_In (Debug);
      -- wait for client to write data
      Local_Test.Read_Write_Mode := Unmatched_Record_Length;
      Local_Test.Server_Write_Buffer := True; -- write buffer back to client
      Send_Receive (Local_Test);
      Log_Out (Debug);
   end Socket_Send_Receive_Variable_Record;

--------------------------------------
   --
   procedure Send_Receive_Missmatch_Read_Length (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------
   -- total read and write lengths are equal
   -- individual read and writes differ

      Local_Test                 : Socket_Test_Type renames Socket_Test_Type (Test);

   begin
      Log_In (Debug);
      Put_Line ("long test ~45 seconds");

      Local_Test.Read_Write_Mode := Unmatched_Record_Length;
      Send_Receive (Local_Test);
      Assert (Local_Test.Answer = Success,
         "Answers failed " & Local_Test.Answer'img);
      Log_Out (Debug);
   end Send_Receive_Missmatch_Read_Length;

   --------------------------------------------------------------
   -- expect timeout in server read
   procedure Socket_Timeout_Send_Receive (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

      Local_Test                 : Socket_Test_Type renames Socket_Test_Type (Test);

   begin
      Log_In (Debug);
      Put_Line ("long test ~45 seconds");
      Local_Test.Server_Write_Response := False;   -- force timeout
      Local_Test.Read_Write_Mode := Read_Timeout;
      Send_Receive (Local_Test);
      Assert (Local_Test.Answer = Success,
         "Answer failed " & Local_Test.Answer'img);
      Log_Out (Debug);
   end Socket_Timeout_Send_Receive;

   --------------------------------------------------------------
   procedure Socket_Acknowledge_Send_Receive (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

      Local_Test                 : Socket_Test_Type renames Socket_Test_Type (Test);

   begin
      Log_In (Debug);
      Put_Line ("long test ~45 seconds");

      Local_Test.Read_Write_Mode := Unmatched_Record_Length;
      Send_Receive (Local_Test);
      Assert (Local_Test.Answer = Success,
         "Answers failed " & Local_Test.Answer'img);
      Log_Out (Debug);

   exception

      when Fault: others =>
         Log_Exception (Debug, Fault);
         raise;

   end Socket_Acknowledge_Send_Receive;

   ---------------------------------------------------------------
   function Suite return AUnit.Test_Suites.Access_Test_Suite is
   ---------------------------------------------------------------

      Test_Suite                 : constant AUnit.Test_Suites.Access_Test_Suite :=
                                    new AUnit.Test_Suites.Test_Suite;
      Tests                      : constant Socket_Test_Access := new Socket_Test_Type;

   begin
      Ada_Lib.Unit_Test.Suite (Suite_Name);  -- used for listing suites
      Test_Suite.Add_Test (Tests);
      return Test_Suite;
   end Suite;

   ---------------------------------------------------------------
   overriding
   procedure Tear_Down (Test : in out Socket_Test_Type) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug or Trace_Set_Up_Tear_Down, "sockets" & Test.Socket_Count'img);

      for Index in 1 .. Test.Socket_Count loop
         Log_Here (Debug, "close " & Test.Sockets (Index).Image &
            " index" & Index'img);

         begin
            Test.Sockets (Index).Close;

         exception
            when Fault: others =>  -- unexpected, server may have failed
               Trace_Message_Exception (Fault, "socket " &
                  Test.Sockets (Index).Image, Here);
         end;
      end loop;
      Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type (Test).Tear_Down;
      Log_Out (Debug or Trace_Set_Up_Tear_Down);
   end Tear_Down;

   ---------------------------------------------------------------
   procedure Set_Answer (
      Test                       : in out Socket_Test_Type;
      Answer                     : in     Answer_Type;
      From                       : in     String := Ada_Lib.Trace.Here) is
   ---------------------------------------------------------------

   begin
      if Test.Answer = Success then
         Test.Answer := Answer;
         Log_Here (Debug, "set answer " & Answer'img & " from " & From);
      else
         Log_Here (Debug, "answer alread set " & Test.Answer'img &
            " new answer " & Answer'img & " from " & From);
      end if;
   end Set_Answer;

   ---------------------------------------------------------------
   task body Client_Task_Type is
   ---------------------------------------------------------------

      Count                      : Natural := 0;
      Local_Test                 : Socket_Test_Access := Null;

      ------------------------------------------------------------
      function Check_Answer (
         Client_Socket  : in     Ada_Lib.Socket_IO.Client.Client_Socket_Access;
         Data_Length    : in     Index_Type;
         Start          : in     Index_Type;
         Stop           : in     Index_Type
      ) return Boolean is
      ------------------------------------------------------------

         Answer   : Buffer_Type (1 ..
                     Buffer_Bytes (Length_Or_Answer_Type'size));
         Ack      : Length_Or_Answer_Type;
         for Ack'address use Answer'address;
         Sum               : Length_Or_Answer_Type := 0;

      begin
         Log_Here (Debug, "data length" & Data_Length'img &
            " start" & Start'img & " stop" & Stop'img);
         if Data_Length /= Stop - Start + 1 then
            raise Fault with "bad length" & Data_Length'img &
               " start" & Start'img & " stop" & Stop'img;
         end if;

         begin
            Client_Socket.Read (Answer,
               Timeout_Length => Local_Test.Client_Read_Timeout_Time);

         exception
            when Fault: Timeout =>  -- unexpected, server may have failed
               Trace_Exception (Debug, Fault, Here);
               Local_Test.Client_Timed_Out := True;
               Local_Test.Set_Answer (Timeout_Answer);
               return False;
         end;
         -- calculate what answer should be
         for Index in Start .. Stop loop
            Sum := Sum +
               Length_Or_Answer_Type (Local_Test.Send_Data (Index));
         end loop;

         Log_Here (Debug, "count" & Count'img &
            " sum" & Sum'img & " ack" & Ack'img);

         if Sum = Ack then
            return True;
         else
            Local_Test.Set_Answer (Bad_Ack);
            Log_here (Debug, "bad ack");
            return False;
         end if;

      end Check_Answer;
      ------------------------------------------------------------

   begin
    Log_In (Debug, "client " & Description.all);
    Ada_Lib.Trace_Tasks.Start ("client " & Description.all);

    accept Start (
       Test                    : in     Socket_Test_Access) do

       Log_Here (Debug, "started Answer " &
          Test.Answer'img & Test.Client_Read_Timeout_Time'img);
       Local_Test := Test;
    end Start;
    Local_Test.Client_Started := True;
    Local_Test.Client_Failed := False;

      declare
         Data_Left   : Index_Type := (case Local_Test.Read_Write_Mode is

                        when No_Data | Read_Timeout => 0,

                        when Polling_Read => Buffer_Length,

                        when others => Data_Buffer_Type'length);
         Nested_Program_Options
               : constant Options.Program.
                     Nested_Program_Options_Constant_Class_Access :=
                  Options.Program.Get_Read_Only_Nested_Program_Options;
         Nested_Unit_Test_Options
               : constant Options.Unit_Test.
                     Ada_Lib_Unit_Test_Nested_Options_Constant_Class_Access :=
                  Options.Unit_Test.Get_Readonly_Ada_Lib_Unit_Test_Nested_Options;
         Description : aliased constant String := "client";
         Client_Socket
                     : Ada_Lib.Socket_IO.Client.Client_Socket_Access :=
                        new Ada_Lib.Socket_IO.Client.Client_Socket_Type (
                           Description'unchecked_access);
         Start_Offset: Index_Type :=
                        Local_Test.Send_Data'first;
         Written     : Index_Type := 0;

      begin
         Log_Here (Debug,
            "client socket " & Client_Socket.Image &
            " Read_Write_Mode " & Local_Test.Read_Write_Mode'img &
            " data left" & Data_Left'img &
            " delay time " & Delay_Time'img &
            " socket " & Ada_Lib.Strings.Image (Client_Socket'address) &
            " entered offset seed " &
               Nested_Unit_Test_Options.Random_Seeds (Offset_Generator_Index)'img &
            " entered data seed " &
               Nested_Unit_Test_Options.Random_Seeds (Data_Generator_Index)'img &
            " Test " & Ada_Lib.Strings.Image (Local_Test.all'address));

         Client_Socket.Connect (
            Connection_Timeout=> 1.0,
            Port              => Local_Test.Server_Port,
            Server_Name       => Server_Name,
            Reuse             => True);

         Record_Socket (Local_Test.all, Client_Socket.all);
         Log_Here (Debug, "connected");

         if Data_Left > 0 then
            if Local_Test.Client_Delay_Write_Time > 0.0 then
               Log_Here (Debug, "start delay " &
                  Local_Test.Client_Delay_Write_Time'img);
               delay Local_Test.Client_Delay_Write_Time;
            end if;

            while Data_Left > 0 and then not (
                  Local_Test.Server_Failed or else Local_Test.Server_Timedout) loop
               Log_Here (Debug, " left" & Data_Left'img);

               declare
                  Write_Length      : Index_Type;
                                    -- make sure never zero
               begin
                  case Local_Test.Read_Write_Mode is

                  when Matching_Record_Length =>
                     -- send buffer length
                     declare
                        Random_Length     : constant Index_Type := Index_Type (
                                             Ada_Lib.Unit_Test.Test_Cases.
                                                Random_Number_Generator.Random (
                                                   Local_Test.Random_Generators (
                                                      Data_Generator_Index)));
                        Mod_Length        : constant Index_Type :=
                                             Random_Length mod (Test_Buffer_Length / 2);
                        Length_Request_Buffer
                                       : Length_Or_Answer_Type :=
                                        Length_Or_Answer_Type(Data_Left);
                        Write_Buffer   : Buffer_Type (1 ..
                                          Buffer_Bytes (Length_Request_Buffer'size));
                        for Write_Buffer'address use Length_Request_Buffer'address;

                     begin
                        Write_Length:= Mod_Length + 1;
                        if Write_Length > Data_Left then
                           Write_Length := Data_Left;
                        end if;
                        Length_Request_Buffer := Length_Or_Answer_Type (Write_Length);

                        Log_Here (Debug, "Length_Request_Buffer" &
                              Length_Request_Buffer'img &
                              " Random_Length" & Random_Length'img &
                              " mod length" & Mod_Length'img &
                              " write length" & Write_Length'img);

                        Client_Socket.Write (Write_Buffer);     -- send request length
                     end;

                  when Polling_Read =>
                     Write_Length:= Buffer_Length;
                     Log_Here (Debug, "write length" & Write_Length'img &
                        " to client socket " & Client_Socket.Image);

--                when Read_Timeout =>
--                   raise False with "should not happen " & Here;

                  when Unmatched_Record_Length =>
                     Write_Length:= Test_Buffer_Length;
                     Log_Here (Debug, "write length" & Write_Length'img &
                        " to client socket " & Client_Socket.Image);

                  when others =>
                     raise Fault with "unexpected Local_Test.Read_Write_Mode " &
                           Local_Test.Read_Write_Mode'img & " at " & Here;

                  end case;

                  -- write data
                  Client_Socket.Write (Local_Test.Send_Data (
                      Start_Offset .. Start_Offset + Write_Length - 1));
                  Written := Written + Write_Length;

                  if Local_Test.Read_Write_Mode = Matching_Record_Length then
                     if not Check_Answer (Client_Socket, Write_Length,
                           Start_Offset, Start_Offset + Write_Length - 1) then
                        exit;
                     end if;

                     if Nested_Program_Options.Verbose and then
                           Count mod Notify_Frequency = 0 then
                        Put_Line (Count'img & " records received");
                     end if;
                  end if;

                  Start_Offset := Start_Offset + Write_Length;
                  Data_Left := Data_Left - Write_Length;

                  Count := Count + 1;
                  if Count mod 10 = 0 and then Nested_Program_Options.Verbose then
                     Put_LIne (Count'img & " records written");
                  end if;

                  Log_Here (Debug, "left" & Data_Left'img &
                     " start " & Start_Offset'img & " length" & Write_Length'img &
                     " written" & Written'img);
               end;
            end loop;

            if Local_Test.Read_Write_Mode = Unmatched_Record_Length then
               if not Check_Answer (Client_Socket, Test_Buffer_Length,
                     Local_Test.Send_Data'first, Local_Test.Send_Data'last) then
                  Log_Here (Debug);
               end if;
            end if;
         end if;

         Log_Here (Debug);
         if Client_Socket.Is_Open then
            Client_Socket.Close;
         end if;

         Local_Test.Client_Completed := True;

      exception
         when Fault: others =>
            Trace_Exception (Fault, Here);
            Local_Test.Client_Failed := True;
            Put_Line ("Client task failed with " &
               Ada.Exceptions.Exception_Message (Fault));
      end;

      Ada_Lib.Trace_Tasks.Stop;
      Log_Out (Debug);

   exception

      when SYSTEM.ASSERTIONS.ASSERT_FAILURE =>
         Put_Line ("pragma assert failed");
         Log_Out (Debug);
         Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.Assertion_Exit);

      when Fault: others =>
         Trace_Exception (Fault, Here);
         if Local_Test = Null then
            Put_Line ("exception in " & Who & " befor Local_Test initialized");
            Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.Assertion_Exit);
         else
            Local_Test.Client_Failed := True;
         end if;
         Log_Out (Debug);

   end Client_Task_Type;

   ---------------------------------------------------------------
   task body Server_Task_Type is
   ---------------------------------------------------------------

      Accept_Timeout             : constant := 0.5;
      Local_Test                 : Socket_Test_Access := Null;

      ------------------------------------------------------------
      procedure Close_Sockets (
         Accepted_Socket         : in      Ada_Lib.Socket_IO.Server.
                                    Accepted_Socket_Access;
         Server_Socket           : in      Ada_Lib.Socket_IO.Server.
                                    Server_Socket_Access) is
      ------------------------------------------------------------

      begin
         Log_in (Debug, "close sockets for " & Description.all);

         if Accepted_Socket.Is_Open then
            Accepted_Socket.Close;
         end if;

         if Server_Socket.Is_Open then
            Server_Socket.Close;
         end if;
         Log_Out (Debug, "sockets closed");
      end Close_Sockets;
      ------------------------------------------------------------

   begin
      Log_In (Debug, "server " & Description.all);
      Ada_Lib.Trace_Tasks.Start ("server " & Description.all);

      accept Start (
         Test                    : in     Socket_Test_Access) do

         Log_Here (Debug, "started Answer " & Test.Answer'img);
         Local_Test := Test;
      end Start;
      Local_Test.Server_Started := True;
      Local_Test.Server_Failed := False;

      declare
         Accepted_Desscription   : aliased constant String := "accepted";
         Accepted_Socket         : constant Ada_Lib.Socket_IO.Server.
                                    Accepted_Socket_Access := new Ada_Lib.
                                       Socket_IO.Server.Accepted_Socket_Type (
                                          Accepted_Desscription'unchecked_access);
         Server_Desscription     : aliased constant String := "server";
         Server_Socket           : constant Ada_Lib.Socket_IO.Server.
                                    Server_Socket_Access := new Ada_Lib.
                                       Socket_IO.Server.Server_Socket_Type (
                                          Server_Desscription'unchecked_access,
                                          Local_Test.Server_Port);

      -----------------------------------------------------------------
      procedure Send_Ack (
         Data                    : in     Buffer_Type) is
      -----------------------------------------------------------------

         Sum            : Length_Or_Answer_Type;
         Answer         : Buffer_Type (1 .. Sum'size / Data_Type'size);
         for Answer'address use Sum'address;

      begin
         Log_Here (Debug, "Answer size" & Answer'size'img &
            " sum" & Sum'size'img);
         pragma Assert (Answer'size = Sum'size);
         Sum := 0;
         for Byte of Data loop
            Sum := Sum + Length_Or_Answer_Type (Byte);
         end loop;
         Log_Here (Debug, "Sum" & Sum'img );

         Accepted_Socket.Write (
            Buffer            => Answer);
      end Send_Ack;

      -----------------------------------------------------------------
      procedure Received_Fixed_Record is
      -----------------------------------------------------------------

         Count                   : Natural := 0;
         Data_Left               : Index_Type := Data_Buffer_Type'length;
         Start_Offset            : Index_Type :=
                                    Local_Test.Received_Data'first;

      begin
         Log_In (Debug,  "Description " & Description.all &
            " timeout " & Local_Test.Server_Read_Timeout_Time'img);

         while Data_Left > 0 and then  -- loop until all data received
               not Local_Test.Client_Failed and then
               not Local_Test.Server_Failed loop
            -- keep reading until all data received
            declare
               Request_Length : Length_Or_Answer_Type;

            begin
               declare
                  Read_Buffer    : Buffer_Type (1 ..
                                    Buffer_Bytes (Request_Length'size));
                  for Read_Buffer'address use Request_Length'address;

               begin
                  Accepted_Socket.Read (Read_Buffer,     -- read the request length
                     Local_Test.Server_Read_Timeout_Time);

                  Log_Here (Debug,  "Description " & Description.all &
                     " read length" & Request_Length'img);
               end;

               -- read the data
               declare
                  End_Offset        : constant Index_Type := Start_Offset +
                                       Index_Type (Request_Length) - 1;
               begin
                  Log_Here (Debug, "count" & Count'img &
                     " Request_Length" & Request_Length'img &
                     " start " & Start_Offset'img &
                     " End_Offset" & End_Offset'img);

                  Accepted_Socket.Read (  -- read the data
                     Buffer            => Local_Test.Received_Data (
                                             Start_Offset .. End_Offset),
                     Timeout_Length    => Local_Test.
                                             Server_Read_Timeout_Time);
                  Data_Left := Data_Left - Index_Type (Request_Length);
                  Log_Here (Debug, "left" & Data_Left'img &
                     " Start_Offset" & Start_Offset'img &
                     " End_Offset" & End_Offset'img);

                  Send_Ack (Local_Test.Received_Data (
                     Start_Offset .. End_Offset));
               end;

               Count := Count + 1;
               Start_Offset := Start_Offset + Index_Type (Request_Length);
               Log_Here (Debug, "left" & Data_Left'img &
                  " Request_Length" & Request_Length'img);

            exception
               when Fault: Timeout =>
                  Trace_Message_Exception (Debug, Fault,
                     "client delayed " & Local_Test.Client_Delayed'img);
                  Local_Test.Set_Answer (Timeout_Answer);
                  Local_Test.Server_Timedout := True;
                  exit;                   -- expected
            end;
         end loop;   -- while Data_Left > 0 and then
                     --       not Local_Test.Client_Failed and then
                     --       not Local_Test.Server_Failed loop

         Log_Out (Debug);
      end Received_Fixed_Record;

      -----------------------------------------------------------------
      procedure Received_Variable_Record is
      -----------------------------------------------------------------

         Count                : Natural := 0;
         Data_Left            : Index_Type := Data_Buffer_Type'length;
         Start_Offset         : Index_Type :=
                                 Local_Test.Received_Data'first;
      begin
         Log_In (Debug);
         while Data_Left > 0 loop
            -- keep reading until all data Last
            declare
               Last           : Index_Type;
               Received       : Index_Type;

            begin
               Log_Here (Debug, "start " & Start_Offset'img &
                  " Server_Wait_Time" & Local_Test.Server_Wait_Time'img);

               if Local_Test.Server_Wait_Time > 0.0 then
                  delay Local_Test.Server_Wait_Time;
               end if;

               if    Local_Test.Client_Failed or else
                     Local_Test.Server_Failed then
                  Log_Here (Debug, "Client_Failed " & Local_Test.Client_Failed'img &
                     " Server_Failed " & Local_Test.Server_Failed'img);
                  exit;
               end if;

               if not Accepted_Socket.Open then
                  Log_Here (Debug, "Accepted_Socket closed ");
                  exit;
               end if;

               Accepted_Socket.Read (
                  Buffer   => Local_Test.Received_Data (Start_Offset ..
                                 Local_Test.Received_Data'last),
                  Last     => Last);

               if Last > 0 then
                  Received := Last - Start_Offset + 1;
                  Data_Left := Data_Left - Received;
                  Log_Here (Debug, "Start_Offset" & Start_Offset'img &
                     " Received" & Received'img &
                     " last" & Last'img & " left" & Data_Left'img);
                  Count := Count + 1;
                  Start_Offset := Start_Offset + Received;
               end if;
            end;
         end loop;   -- while Data_Left > 0 and then
                     --       not Local_Test.Client_Failed and then
                     --       not Local_Test.Server_Failed loop

         Send_Ack (Local_Test.Received_Data);

         Log_Out (Debug);
      end Received_Variable_Record;

      -----------------------------------------------------------------
      procedure Timeout_Read is
      -----------------------------------------------------------------

      begin
         Log_In (Debug);
         begin
            Accepted_Socket.Read (Local_Test.Received_Data,
               -- read the full buffer
               Local_Test.Server_Read_Timeout_Time);
            Local_Test.Set_Answer (Unexpected);
            Local_Test.Server_Failed := True;
            Log_Here (Debug, "read unexpectedly succeeded.");

         exception
            when Fault: Timeout =>
               Trace_Message_Exception (Debug, Fault, "expected timeout exception");
               Local_Test.Set_Answer (Success);
         end;
         Log_Out (Debug);

      end Timeout_Read;
      -----------------------------------------------------------------

      Have_Socket          : Boolean := False;

   begin
         Log_Here (Debug, "server " & Description.all &
            " unaccepted socket " & Accepted_Socket.Image & " no description expected " &
            " server socket " & Server_Socket.Image & " no description expected " &
--          " accepted socket " & Image (Accepted_Socket'address) &
--          " server socket " & Image (Server_Socket'address) &
--          " do ack " & Local_Test.Do_Acknowledgement'img &
            " Read_Write_Mode " & Local_Test.Read_Write_Mode'img &
            " timeout duration " & Local_Test.Server_Read_Timeout_Time'img &
            " Test " & Ada_Lib.Strings.Image (Local_Test.all'address));

         begin
            Server_Socket.Accept_Socket (
               Accepted_Socket      => Accepted_Socket.all,
               Accept_Timeout       => Accept_Timeout);
            Have_Socket := True;

         exception
            when Fault: Select_Timeout =>
               Trace_Message_Exception (Debug, Fault,
                  (if Local_Test.Select_Timeout_Expected then
                     ""
                  else
                     "not ") &
                  "expected exception for server " & Description.all);

               Server_Socket.Close;
               if Local_Test.Select_Timeout_Expected then  -- expected timeout
                  Log_Here (Debug);
               else
                  Local_Test.Set_Answer (Timeout_Answer);
                  Put_Line ("Server task failed with " &
                     Ada.Exceptions.Exception_Message (Fault));
               end if;
         end;

         Log_Here (Debug, "server " & Description.all);

         Record_Socket (Local_Test.all, Server_Socket.all);
         Record_Socket (Local_Test.all, Accepted_Socket.all);
         Log_Here (Debug, "server socket " & Server_Socket.Image &
            " accepted socket " & Accepted_Socket.Image &
            " have socket " & Have_Socket'img &
            " mode " & Local_Test.Read_Write_Mode'img);

         if Have_Socket then
            case Local_Test.Read_Write_Mode is

               when Matching_Record_Length => -- read buffer length
                  Received_Fixed_Record;

               when  Read_Timeout =>
                  Timeout_Read;              -- do a whole buffer read and expect timeout

               when Unmatched_Record_Length =>  -- try to read whole buffer
                  Received_Variable_Record;

               when  others =>
                  Log_Here (Debug, "Read_Write_Mode " &
                     Local_Test.Read_Write_Mode'img);
            end case;

            Log_Here (Debug, "server " & Description.all &
               " wait for client to complete Client_Completed " &
               Local_Test.Client_Completed'img &
               " Test " & Ada_Lib.Strings.Image (Local_Test.all'address));
         end if;

         Close_Sockets (Accepted_Socket, Server_Socket);

      exception
         when Fault: Timeout =>
               Trace_Message_Exception (Fault, "server " & Description.all &
                  "timeout not expected");
               Put_Line ("Server task failed with unexpected timeout " &
                  Ada.Exceptions.Exception_Message (Fault));
               Local_Test.Server_Failed := True;
               Local_Test.Set_Answer (Timeout_Answer);
            Close_Sockets (Accepted_Socket, Server_Socket);

         when Fault: others =>
            Trace_Message_Exception (Debug, Fault, "server " & Description.all);
            Local_Test.Server_Failed := True;
            Local_Test.Set_Answer (Unexpected);
            Put_Line ("Server task failed with " &
               Ada.Exceptions.Exception_Message (Fault));
            Close_Sockets (Accepted_Socket, Server_Socket);
      end;

      Log_Here (Debug, "server " & Description.all);
      Local_Test.Server_Completed := True;
      Ada_Lib.Trace_Tasks.Stop;
      Log_Out (Debug, "server " & Description.all);

   exception
      when SYSTEM.ASSERTIONS.ASSERT_FAILURE =>
         Put_Line ("pragma assert failed");
         Log_Out (Debug);
         Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.Assertion_Exit);

      when Fault: others =>
         Local_Test.Server_Failed := True;
         Trace_Exception (Fault, Here);
         Log_Out (Debug);

   end Server_Task_Type;
   ---------------------------------------------------------------

begin
if Trace_Tests then
      Debug := Trace_Tests;
   end if;
--Debug := True;
   Log_Here (Trace_Options or Elaborate);
end Ada_Lib.Socket_IO.Stream_IO.Unit_Test;

