--with Ada.Numerics.Discrete_Random;
--with Ada_Lib.Options.Unit_Test;
with Ada_Lib.Trace;
with Ada_Lib.Unit_Test.Test_Cases;
with AUnit.Test_Cases;
with AUnit.Test_Suites;

package Ada_Lib.Socket_IO.Stream_IO.Unit_Test is

   Fault                         : exception;

   type Answer_Type              is (Bad_Ack, Bad_DAta, Success, Timeout_Answer,
                                    Unexpected, Wrong_Length);

   type Socket_Test_Type         is new Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type
                                    with private;
   type Socket_Test_Access is access all Socket_Test_Type;

   overriding
   function Name (
      Test                       : Socket_Test_Type
   ) return Standard.AUnit.Message_String;

   overriding
   procedure Register_Tests (
      Test                       : in out Socket_Test_Type);

   procedure Server_Failure (
      Test                       : in out AUnit.Test_Cases.Test_Case'class);

   procedure Set_Answer (
      Test                       : in out Socket_Test_Type;
      Answer                     : in     Answer_Type;
      From                       : in     String := Ada_Lib.Trace.Here);

   overriding
   procedure Set_Up (
      Test                       : in out Socket_Test_Type
   ) with Pre => not Test.Verify_Set_Up,
          Post => Test.Verify_Set_Up;

   function Suite return Standard.AUnit.Test_Suites.Access_Test_Suite;

   overriding
   procedure Tear_Down (
      Test     : in out Socket_Test_Type
   ) with post => Test.Verify_Tear_Down;

   Debug                         : Boolean := False;
   Suite_Name                    : constant String := "Socket_Stream";

private

   Test_Buffer_Length            : constant := 5000;

   subtype Data_Buffer_Type      is Ada_Lib.Socket_IO.Buffer_Type (1 ..
                                    Test_Buffer_Length);
   type Data_Access              is access all Buffer_Type;

   Default_Port                  : constant := 12345;

   type Read_Write_Mode_Type        is (
      Matching_Record_Length,    -- client and server use same record lengths
      No_Data,
      Polling_Read,              -- server has short read timeout and polls
      Unmatched_Record_Length,   -- server fixed length reads, client delays and reads available
      Read_Timeout);              -- client sends short write, server times out
--    Write_Timeout,             -- server reads slower then client writes
--    Connect_Timeout);          -- server doesn't to accept

   type Sockets_Type             is array (1 .. 10) of Socket_Class_Access;

   type Socket_Test_Type is new Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type with record
      Answer                     : Answer_Type := Success;
      Client_Completed           : Boolean := False;
      Client_Delay_Write_Time    : Duration := 0.0;
      Client_Delayed             : Boolean := False;
      Client_Failed              : Boolean := False;
      Client_Read_Timeout_Time   : Duration := No_Timeout;
      Client_Started             : Boolean := False;
      Client_Timed_Out           : Boolean := False;
      Client_Write_Timeout_Time  : Duration := No_Timeout;
--    Do_Acknowledgement         : Boolean := False;
      Read_Write_Mode            : Read_Write_Mode_Type := Matching_Record_Length;
      Received_Data              : Data_Buffer_Type;
      Repetition                 : Positive;
      Send_Data                  : Data_Buffer_Type;
      Server_Completed           : Boolean := False;
      Server_Failed              : Boolean := False;
      Select_Timeout_Expected    : Boolean := False;
      Server_Port                : Ada_Lib.Socket_IO.Port_Type := Default_Port;
      Server_Read_Timeout_Time   : Duration := No_Timeout;
      Server_Started             : Boolean := False;
      Server_Timedout            : Boolean := False;
      Server_Wait_Time           : Duration := 0.0;
      Server_Write_Buffer        : Boolean := False; -- true write buffer else ack
      Server_Write_Response      : Boolean := True; -- false for testing read timeout by client
      Server_Write_Timeout_Time  : Duration := No_Timeout;
      Sockets                    : Sockets_Type := (others => Null);
      Socket_Count               : Natural := 0;
   end record;

end Ada_Lib.Socket_IO.Stream_IO.Unit_Test;

