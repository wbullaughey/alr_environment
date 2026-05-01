with Ada.Exceptions;
with Ada.Text_IO;use Ada.Text_IO;
with Ada_Lib.Database.Common;
with AUnit.Assertions; use AUnit.Assertions;
with Ada_Lib.DAtabase.Subscribe;
with Ada_Lib.Database.Subscription.Tests;
with Ada_Lib.Database.Event;
--with Ada_Lib.Options.Flags;
with Ada_Lib.Options.AUnit_Lib;
with Ada_Lib.Options.Unit_Test;
with Ada_Lib.Options.Verification;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with Ada_Lib.Unit_Test.Test_Cases;

pragma Elaborate_All (Ada_Lib.Database);

package body Ada_Lib.Database.Server.Tests is

   use type Ada_Lib.Options.Mode_Type;
   use type Ada_Lib.Strings.String_Constant_Access;
-- use type Ada_Lib.Strings.Unlimited.String_Type;
   use type Ada_Lib.Database.Updater.Update_Mode_Type;

-- type Generic_Event_Type is new Ada_Lib.Database.Event.Event_Intervace with null record;

-- type Test_Suite_Type is new Ada_Lib.Test.Tests.Test_Suite_Type with null record;

-- type Local_Open_Close_Server_Test_Type is new Server_Open_Close_Test_Type with null record;
   type Local_Server_Test_Type is new Server_Test_Type with null record;
--
-- type Remote_Open_Close_Server_Test_Type is new Server_Open_Close_Test_Type with null record;
   type Remote_Server_Test_Type is new Server_Test_Type with null record;
--
   type Content_Type is new Ada_Lib.Database.Event.Event_Content_Type with record
      Update_Count            : Natural := 0;
   end record;

-- type Content_Access        is access all Content_Type;

   overriding
   procedure Signaled (
      Signal_Content          : in out Content_Type);

   function Construct (
      Source                     : in     String;
      Append                     : in     Ada_Lib.Strings.Unlimited.String_Type
   ) return String renames Ada_Lib.Strings.Unlimited.Construct;

-- procedure Signal (
--    Event                      : in     Generic_Event_Type);

   procedure Test_Subscription (
      Test                       : in     Server_Test_Type;
      Name_Value                 : in     Ada_Lib.Database.Name_Value_Type;
      Update_Mode                : in     Ada_Lib.Database.Updater.Update_Mode_Type;
      Subscription               : in out Ada_Lib.Database.Subscription.Tests.Subscription_Type;
      Expected_Count             : in out Natural;
      First_Subscription         : in     Boolean);

   Name_1                        : constant String := "name_1";
   Name_2                        : constant String := "name_2";
-- Name_3                        : constant String := "name_3";
   Value_1                       : constant String := "value_1";
   Value_2                       : constant String := "value_2";
-- Value_3                       : constant String := "value_3";
   Name_Value_1                  : constant Ada_Lib.Database.Name_Value_Type :=
                                    Ada_Lib.Database.Create (
                                       Name_1, Ada_Lib.Database.No_Vector_Index, "", Value_1);
   Name_Value_2                  : constant Ada_Lib.Database.Name_Value_Type :=
                                    Ada_Lib.Database.Create (
                                       Name_2, Ada_Lib.Database.No_Vector_Index, "", Value_1);
   Read_Timeout                  : constant Duration := 1.0;
   Subscribe_Timeout             : constant Duration := 0.25;
   Test_Timeout                  : constant Duration := 0.5;
   Trace                         : Boolean renames
                                    Options.Unit_Test.Ada_Lib_Database_Unit_Test.Server_Tests_Trace;
   Update_Time                   : constant Duration := 0.25;
   Write_Timeout                 : constant Duration := 0.25;

   ---------------------------------------------------------------
   procedure Delete (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

--    This_Test                  : Server_Test_Type renames Server_Test_Type (Test);
--    Options                    : constant GNOGA_Options.Database.AUnit.Aunit_Program_Options_Constant_Class_Access :=
--                                     Runtime_Options.Get_Options;
      Server                     : constant Ada_Lib.Database.Server.Server_Access := Server_State.Get_Server;
      Subscription               : aliased Ada_Lib.Database.Subscription.Tests.Subscription_Type;

   begin
      Log (Debug, Here, Who & " enter");
      Assert (Server.Is_Open, "data base not open");
      Subscription.Initialize (
         Ada_Tag           => Ada_Lib.Database.Subscription.Tests.
                                 Subscription_Type'class (Subscription)'tag,
         DBDaemon_Tag      => "",
--       Dynamic           => False,
         Index             => Ada_Lib.Database.No_Vector_Index,
         Name              => Name_1,
--       Value             => Value_1,
--       Update_Count      => 0,
         Update_Mode       => Ada_Lib.Database.Updater.Never);

      Server.Add_Subscription (Subscription'unchecked_access);
      Server.Post (Name_Value_1, Write_Timeout);

      delay 0.2;     -- let update complete

--    declare
--       Signal                  : constant Content_Access := Content_Access (Event.Ptr);
--
--    begin
--       Assert (Signal.Was_Signaled, "subscription not updated");
--       Assert (Signal.Update_Count = 1, "wrong update count. expected 1 got" & Signal.Update_Count'img);

         Assert (Server.Delete_Subscription (Name_1, Ada_Lib.Database.No_Vector_Index, "",
            Ada_Lib.Database.Subscription.Tests.Subscription_Type'class (Subscription)'tag),
            "Delete_Subscription failed");
         Assert (not Server.Has_Subscription (Name_1, Ada_Lib.Database.No_Vector_Index, "",
            Ada_Lib.Database.Updater.Abstract_Updater_Type'tag), "not all subscriptions deleted");

         Server.Post (Name_Value_1, Write_Timeout);

         delay 0.2;     -- let subscribe complete

   --    Log (Debug, Here, Who & " Was_Signaled " & Event.Was_Signaled'img &  " Event " &
   --       Image (Event.all'address));
--       Assert (Signal.Update_Count = 1, "wrong update count. expected 1 got" & Signal.Update_Count'img);
--    end;

      Log (Debug, Here, Who & " exit");

   end Delete;

   ---------------------------------------------------------------
   procedure Delete_All (          -- change update mode
      Test                    : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

--    This_Test               : Server_Test_Type renames Server_Test_Type (Test);
--    Options                    : constant GNOGA_Options.Database.AUnit.Aunit_Program_Options_Constant_Class_Access :=
--                                     Runtime_Options.Get_Options;
      Server                     : constant Ada_Lib.Database.Server.Server_Access := Server_State.Get_Server;

   begin
      Log (Debug, Here, Who & " enter");
      Assert (Server.Is_Open, "data base not open");

      Server.Post (Name_Value_1, Write_Timeout);
      Server.Post (Name_Value_2, Write_Timeout);

      for Unsubscribed_Only in Boolean'range loop
         declare
            Response          : constant Ada_Lib.Database.Name_Value_Type'class :=
                                 Server.Read (Name_2,
                                    Ada_Lib.Database.No_Vector_Index, "", Read_Timeout);
            pragma Unreferenced (Response);
            Subscription               : aliased Ada_Lib.Database.Subscription.Tests.Subscription_Type;
--          Subscription               : aliased Ada_Lib.Database.Updater.Abstract_Updater_Type :=
--                                        Ada_Lib.Database.Updater.Abstract_Updater_Type'(Ada_Lib.Database.Subscription.Create (
--                Name              => Name_1,
--                Index             => Ada_Lib.Database.No_Vector_Index,
--                Tag               => "",
--                Value             => Value_1,
--                Update_Mode       => Ada_Lib.Database.Updater.Never));

         begin
            Log (Debug, Here, Who);
            Subscription.Initialize (
               Ada_Tag           => Ada_Lib.Database.Subscription.Tests.Subscription_Type'class (Subscription)'tag,
               DBDaemon_Tag      => "",
--             Dynamic           => False,
               Index             => Ada_Lib.Database.No_Vector_Index,
               Name              => Name_1,
--             Value             => Value_1,
--             Update_Count      => 0,
               Update_Mode       => Ada_Lib.Database.Updater.Never);
            Server.Add_Subscription (Subscription'unchecked_access);
            delay 0.2;     -- make sure last update completes before unsubscribing
            Server.Delete_All_Subscriptions (Unsubscribed_Only);
            Assert (Server.Has_Subscription (Name_1, Ada_Lib.Database.No_Vector_Index, "",
               Ada_Lib.Database.Updater.Abstract_Updater_Type'tag) = Unsubscribed_Only,
               "did not have subscription for subscribed name when deleting Unsubscribed_Only");
            Assert (not Server.Has_Subscription (Name_2, Ada_Lib.Database.No_Vector_Index, "",
               Ada_Lib.Database.Updater.Abstract_Updater_Type'tag),
               "had a subscription for read name");
         end;
      end loop;
      Log (Debug, Here, Who & " exit");

   exception
      when Fault: AUnit.Assertions.Assertion_Error =>
         Trace_Message_Exception (Debug, Fault, "exception in Delete_All test");
         raise;

      when Fault: others =>
         Trace_Message_Exception (Fault, " exception in Delete_All test");
         Assert (False, "exception in Delete_All test");
   end Delete_All;

   ---------------------------------------------------------------
   procedure Duplicate_Subscription (
      Test                    : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

--    This_Test                  : Server_Test_Type renames Server_Test_Type (Test);
--    Options                    : constant GNOGA_Options.Database.AUnit.Aunit_Program_Options_Constant_Class_Access :=
--                                     Runtime_Options.Get_Options;
      Server                     : constant Ada_Lib.Database.Server.Server_Access := Server_State.Get_Server;
      Subscription               : aliased Ada_Lib.Database.Subscription.Tests.Subscription_Type;
--    Subscription               : aliased Ada_Lib.Database.Updater.Abstract_Updater_Type :=
--                                  Ada_Lib.Database.Updater.Abstract_Updater_Type'(Ada_Lib.Database.Subscription.Create (
--          Name              => Name_1,
--          Index             => Ada_Lib.Database.No_Vector_Index,
--          Tag               => "",
--          Value             => Value_1,
--          Update_Mode       => Ada_Lib.Database.Updater.Never));

   begin
      Log (Debug, Here, Who & " enter");
      Assert (Server.Is_Open, "data base not open");
      Subscription.Initialize (
         Ada_Tag           => Ada_Lib.Database.Subscription.Tests.Subscription_Type'class (Subscription)'tag,
         DBDaemon_Tag      => "",
--       Dynamic           => False,
         Index             => Ada_Lib.Database.No_Vector_Index,
         Name              => Name_1,
--       Value             => Value_1,
--       Update_Count      => 0,
         Update_Mode       => Ada_Lib.Database.Updater.Never);

      Server.Add_Subscription (Subscription'unchecked_access);
      Assert (Server.Has_Subscription (Name_1, Ada_Lib.Database.No_Vector_Index, "",
         Ada_Lib.Database.Updater.Abstract_Updater_Type'tag),
         "subscribe failed");

      begin
         Server.Add_Subscription (Subscription'unchecked_access);
         Assert (False , "subscribe did not fail");

      exception
         when Fault: others =>
            Trace_Message_Exception (Debug, Fault, "expected exception");

      end;
      Log (Debug, Here, Who & " exit");

   exception
      when Fault: Ada_Lib.Database.Failed =>
         Trace_Message_Exception (Fault, "dupicate subscription");
         Log (Debug, Here, Who & " exit");

   end Duplicate_Subscription;

   ---------------------------------------------------------------
   procedure Flush_Input (
      Test                          : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

--    This_Test                  : Server_Test_Type renames Server_Test_Type (Test);
--    Options                    : constant GNOGA_Options.Database.AUnit.Aunit_Program_Options_Constant_Class_Access :=
--                                     Runtime_Options.Get_Options;
      Server                     : constant Ada_Lib.Database.Server.Server_Access := Server_State.Get_Server;

   begin
      Log (Debug, Here, Who & " enter");
      Assert (Server.Is_Open, "data base not open");
      Server.Post (Name_Value_1, Write_Timeout);
      Server.Post (Name_1, Write_Timeout);
      Put_Line ("delay for " & Write_Timeout'img);
      delay Write_Timeout;
      Server.Flush_Input;

      Put_Line ("wait for " & Test_Timeout'img);
      declare
         Residual                : constant String := Server.all.Get (Test_Timeout);

      begin
         Log_Here (Debug, Quote (Residual, Residual));
         Assert (Residual'length = 0, "input flushed");
      end;
      Log (Debug, Here, Who & " exit");

   exception
      when Fault: Ada_Lib.Database.Timed_Out =>
         Trace_Message_Exception (Debug, Fault, Here, Who & "partial input received");
         Assert (False,  "partial input received");

      when Fault: others =>
         Trace_Message_Exception (Fault, Who, Here);
         raise;

   end Flush_Input;

   ---------------------------------------------------------------
   procedure Iterate_Subscriptions (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

      type Cursor_Type is new Ada_Lib.DAtabase.Subscribe.Subscription_Cursor_Type with record
         Counter                 : Natural := 0;
      end record;

      overriding
      function Process (
         Cursor                  : in out Cursor_Type
      ) return Boolean;

      Local_Name                 : constant String := "abc";
      Local_Value                : constant String := "123";
      Local_Name_Value           : constant Ada_Lib.Database.Name_Value_Type :=
                                    Ada_Lib.Database.Create (Local_Name,
                                       Ada_Lib.Database.No_Vector_Index, "", Local_Value);
      Update_Mode                : constant Ada_Lib.Database.Updater.Update_Mode_Type := Ada_Lib.Database.Updater.Unique;
--    This_Test                  : Server_Test_Type renames Server_Test_Type (Test);
--    Options                    : constant GNOGA_Options.Database.AUnit.Aunit_Program_Options_Constant_Class_Access :=
--                                     Runtime_Options.Get_Options;
      Server                     : constant Ada_Lib.Database.Server.Server_Access := Server_State.Get_Server;
      Subscription               : aliased Ada_Lib.Database.Subscription.Tests.Subscription_Type;
--    Subscription               : aliased Ada_Lib.Database.Updater.Abstract_Updater_Type :=
--                                  Ada_Lib.Database.Updater.Abstract_Updater_Type'(Ada_Lib.Database.Subscription.Create (
--          Name              => Name_1,
--          Index             => Ada_Lib.Database.No_Vector_Index,
--          Tag               => "",
--          Value             => Value_1,
--          Update_Mode       => Ada_Lib.Database.Updater.Never));

      ---------------------------------------------------------------
      overriding
      function Process (
         Cursor                  : in out Cursor_Type
      ) return Boolean is
      ---------------------------------------------------------------

      begin
         Log_In (Debug, Quote (" enter name",
            Cursor.Updater.Name));

         Assert (Cursor.Updater.Name = Local_Name_Value.Name.Coerce,
            Quote ("wrong name value got ", Cursor.Updater.Name) &
            Quote ("expected ", Local_Name_Value.Name));
         Assert (Cursor.Update_Mode = Update_Mode, "wrong on change");
         Cursor.Counter := Cursor.Counter + 1;
         return True;

      exception

         when Fault: AUNIT.ASSERTIONS.ASSERTION_ERROR =>
            Trace_Message_Exception (Fault, Who & " aunit assertion");
            return false;

      end Process;

      Cursor                     : Cursor_Type;

   begin
      Log (Debug, Here, Who & " enter");
      Subscription.Initialize (
         Ada_Tag           => Ada_Lib.Database.Subscription.Tests.Subscription_Type'class (Subscription)'tag,
         DBDaemon_Tag      => "",
--       Dynamic           => False,
         Index             => Ada_Lib.Database.No_Vector_Index,
         Name              => Name_1,
--       Value             => Value_1,
--       Update_Count      => 0,
         Update_Mode       => Ada_Lib.Database.Updater.Never);

      Server.Add_Subscription (Subscription'unchecked_access);
      Server.Iterate (Cursor);
      Assert (Cursor.Counter = Server.Number_Subscriptions, "wrong count");

   end Iterate_Subscriptions;

-- ---------------------------------------------------------------
-- function Name (Test : Server_Open_Close_Test_Type) return AUnit.Message_String is
-- ---------------------------------------------------------------
--
-- begin
--    return AUnit.Format (Suite_Name);
-- end Name;

   ---------------------------------------------------------------
   overriding
   function Name (Test : Server_Test_Type) return AUnit.Message_String is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

   begin
      return AUnit.Format (Suite_Name);
   end Name;

   ---------------------------------------------------------------
   procedure Name_Value_Get (
      Test                          : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

--    This_Test                  : Server_Test_Type renames Server_Test_Type (Test);
--    Options                    : constant GNOGA_Options.Database.AUnit.Aunit_Program_Options_Constant_Class_Access :=
--                                     Runtime_Options.Get_Options;
      Server                     : constant Ada_Lib.Database.Server.Server_Access := Server_State.Get_Server;

   begin
      Log (Debug, Here, Who);
      Assert (Server.Is_Open, "data base not open");
      Server.Post (Name_2, Ada_Lib.Database.No_Vector_Index, "", Value_2, Write_Timeout);

      declare
         Response                : constant Ada_Lib.Database.Name_Value_Class_Type :=
                                    Server.all.Read (Name_2,
                                       Ada_Lib.Database.No_Vector_Index, "", Read_Timeout);

      begin
         Log (Debug, Here, Who & " response" & Response.To_String);
         Assert (Response.Name = Name_2,
            Construct ("did not get expected name '" & Name_2 & "' got '", Response.Name & "'"));
         Assert (Response.Value = Value_2,
            Construct ("did not get expected value '" & Value_2 & "' got '", Response.Value & "'"));
      end;
      declare
         Response                : constant Ada_Lib.Database.Name_Value_Class_Type :=
                                    Server.all.Read (Name_2,
                                       Ada_Lib.Database.No_Vector_Index, "", Read_Timeout);

      begin
         Log_Here (Debug, Quote ("response", Response.To_String));
         Assert (Response.Name = Name_2,
            Construct ("did not get expected name '" & Name_2 & "' got '", Response.Name & "'"));
         Assert (Response.Value = Value_2,
            Construct ("did not get expected value '" & Value_2 & "' got '", Response.Value & "'"));
      end;

      Server.Post (Name_Value_2, Write_Timeout);
      delay 0.2;

      declare
         Response                : constant Ada_Lib.Database.Name_Value_Class_Type :=
                                    Server.all.Read (Name_2,
                                       Ada_Lib.Database.No_Vector_Index, "", Read_Timeout);

      begin
         Log_Here (Debug, Quote ("response", Response.To_String));
         Assert (Response = Ada_Lib.Database.Name_Value_Class_Type (Name_Value_2),
            "did not get expected response: " & Name_Value_2.To_String & " got: " & Response.To_String);
      end;

   end Name_Value_Get;

-- ---------------------------------------------------------------
-- procedure Name_Value_Get_With_Token (
--    Test                          : in out AUnit.Test_Cases.Test_Case'class) is
-- ---------------------------------------------------------------
--
--    This_Test                  : Server_Test_Type renames Server_Test_Type (Test);
--
-- begin
--    Log (Debug, Here, Who);
--    Assert (Server.Is_Open, "data base not open");
--    Server.Post (Name_Value_1, Test_Timeout);
--
--    declare
--       Response                : constant Ada_Lib.Database.Name_Value_Class_Type :=
--                                  Server.all.Get (Name_1, Test_Timeout, True);
--
--    begin
--       Log_Here (Debug, Here, Who, "response", Response, Quote (response), Response)).To_String);
--       Assert (Response.Name = Name_1, "got expected name");
--       Assert (Response.Value = Value, "got expected value");
--    end;
-- end Name_Value_Get_With_Token;

   ---------------------------------------------------------------
   procedure Parse_Name_Value (
      Test                    : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

--    use Ada_Lib.Strings;
--    use Ada_Lib.Strings.Unlimited;

      type Case_Type is record
         Index                   : Optional_Vector_Index_Type;
         Name                    : Ada_Lib.Strings.String_Constant_Access;
         Name_Value              : Name_Value_Access;
         Line                    : Ada_Lib.Strings.String_Constant_Access;
         Tag                     : Ada_Lib.Strings.String_Constant_Access;
         Value                   : Ada_Lib.Strings.String_Constant_Access;
      end record;

      -----------------------------------------------------------
      procedure Initialize (
         Test                    : in out Case_Type) is
      -----------------------------------------------------------

      begin
         Test.Name_Value := new Name_Value_Type'(Create (Test.Name.all, Test.Index,
            (if Test.Value = Null then "" else Test.Value.all),
            (if Test.Tag = Null then "" else Test.Tag.all)));

         Test.Line := new String'(
            (if Test.Tag = Null then "" else Test.Tag.all & "!") &
            Test.Name.all & "=" &
            (if Test.Value = Null then "" else "=" & Test.Value.all));
      end Initialize;
      -----------------------------------------------------------

      Tests                      : array (Positive range <>) of Case_Type := (
                                    1 => (
                                       Index => No_Vector_Index,
                                       Name => new String'("abc"),
                                       Name_Value => Null,
                                       Line => Null,
                                       Tag => Null,
                                       Value => new String'("xyz")
                                    )
                                 );

   begin
      for Test of Tests loop
         Log_Here (Trace, Quote ("Line", Test.Line.all));

         Initialize (Test);
         declare
            Name_Value           : constant Name_Value_Type := Parse (Test.Line.all);

         begin
            if Trace then
               Test.Name_Value.Dump;
            end if;

            Assert (Name_Value = Test.Name_Value.all, "name value not equal");
         end;
      end loop;
   end Parse_Name_Value;

   ---------------------------------------------------------------
   procedure Post_Get (
      Test                          : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

--    This_Test                     : Server_Test_Type renames Server_Test_Type (Test);
--    Options                    : constant GNOGA_Options.Database.AUnit.Aunit_Program_Options_Constant_Class_Access :=
--                                     Runtime_Options.Get_Options;
      Server                     : constant Ada_Lib.Database.Server.Server_Access := Server_State.Get_Server;


   begin
      Log (Debug, Here, Who);
      Assert (Server.Is_Open, "data base not open");
      Server.Post (Name_2, Ada_Lib.Database.No_Vector_Index, "", Value_2, Write_Timeout);
      delay 0.2;
      declare
         Response                : constant Ada_Lib.Database.Name_Value_Type'class :=
                                    Server.Read (Name_2,
                                       Ada_Lib.Database.No_Vector_Index, "", Read_Timeout);

      begin
         Log_Here (Debug, Quote ("name '", Response.Name) &
            Quote ("value", Response.Value));
         Assert (Response.Name = Name_2, "got wrong name expected '" & Name_2 &
            Construct ("' got '", Response.Name & "'"));
         Assert (Response.Value = Value_2, Construct ("got wrong value expected '" & Value_2 &
            "' got '", Response.Value & "'"));
      end;
   end Post_Get;

-- ---------------------------------------------------------------
-- procedure Post_Get_With_Token (
--    Test                          : in out AUnit.Test_Cases.Test_Case'class) is
-- ---------------------------------------------------------------
--
--    Data                        : constant String := Name_Value_1;
--    This_Test                  : Server_Test_Type renames Server_Test_Type (Test);
--
-- begin
--    Log (Debug, Here, Who);
--    Assert (Server.Is_Open, "data base not open");
--    Server.Post (Data, Test_Timeout);
--
--    declare
--       Response                : constant Ada_Lib.Database.Name_Value_Class_Type := Server.all.Get (Name_1, Test_Timeout,
--                                  Use_Token => True);
--
--    begin
--       Log (Debug, Here, Who);
--       Assert (Response.Name = Name_1, "got wrong name '" & Response.Name & "' expected '" & Name_1 & "'");
--       Assert (Response.Value = Value, "got wrong value '" & Response.Value & "' expected '" & Value & "'");
--    end;
-- end Post_Get_With_Token;
--
----------------------------------------------------
--   procedure Register_Tests (Test : in out Server_Open_Close_Test_Type) is
--   ---------------------------------------------------------------
--
--   begin
--      Log (Debug, Here, Who & " enter Which_Host " & Test.Which_Host'img);
--
--      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
--         Routine        => Start_Stop'access,
--         Routine_Name   => AUnit.Format ("Start_Stop")));
--   end Register_Tests;

   --------------------------------------------------
   overriding
   procedure Register_Tests (Test : in out Server_Test_Type) is
   ---------------------------------------------------------------

   use Ada_Lib.Options.Unit_Test;

      Options        : Ada_Lib.Options.AUnit_Lib.Aunit_Program_Options_Type'class
                        renames Ada_Lib.Options.AUnit_Lib.
                           Aunit_Program_Options_Constant_Class_Access (
                              Ada_Lib.Options.Verification.
                                 Get_Ada_Lib_Read_Only_Program_Options).all;
      Listing_Suites : constant Boolean :=
                        Options.Nested_Unit_Test_Options.Mode /=
                           Ada_Lib.Options.Run_Tests;
      Star_Names     : constant String := (if Listing_Suites then "*" else "");

   begin
      Log_In (Debug, "enter Which_Host " & Test.Which_Host'img);

      if Listing_Suites or else
            Options.Nested_Unit_Test_Options.Suite_Set (Ada_Lib.Options.Unit_Test.Database_Server) then
         Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
           Routine        => Parse_Name_Value'access,
           Routine_Name   => AUnit.Format ("Parse_Name_Value" & Star_Names)));

         Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
           Routine        => Start_Stop'access,
           Routine_Name   => AUnit.Format ("Start_Stop" & Star_Names)));

         Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
            Routine        => Flush_Input'access,
            Routine_Name   => AUnit.Format ("Flush_Input" & Star_Names)));

         Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
            Routine        => Post_Get'access,
            Routine_Name   => AUnit.Format ("Post_Get" & Star_Names)));

   --    Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
   --       Routine        => Post_Get_With_Token'access,
   --       Routine_Name   => AUnit.Format ("Post_Get_With_Token" & Star_Names)));
   --
         Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
            Routine        => Name_Value_Get'access,
            Routine_Name   => AUnit.Format ("Name_Value_Get" & Star_Names)));

   --    Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
   --       Routine        => Name_Value_Get_With_Token'access,
   --       Routine_Name   => AUnit.Format ("Name_Value_Get_With_Token" & Star_Names)));
   --
         Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
            Routine        => Subscribe'access,
            Routine_Name   => AUnit.Format ("Subscribe" & Star_Names)));

         Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
            Routine        => Delete'access,
            Routine_Name   => AUnit.Format ("Delete" & Star_Names)));

         Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
            Routine        => Delete_All'access,
            Routine_Name   => AUnit.Format ("Delete_All" & Star_Names)));

         Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
            Routine        => Iterate_Subscriptions'access,
            Routine_Name   => AUnit.Format ("Iterate_Subscriptions" & Star_Names)));

         Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
            Routine        => Subscribe_Unsubscribe'access,
            Routine_Name   => AUnit.Format ("Subscribe_Unsubscribe" & Star_Names)));

         Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
            Routine        => Resubscribe'access,
            Routine_Name   => AUnit.Format ("Resubscribe" & Star_Names)));

         Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
            Routine        => Duplicate_Subscription'access,
            Routine_Name   => AUnit.Format ("Duplicate_Subscription" & Star_Names)));

   --    Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
   --       Routine        => Subscription_State'access,
   --       Routine_Name   => AUnit.Format ("Subscription_State" & Star_Names)));

         Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
            Routine        => Read'access,
            Routine_Name   => AUnit.Format ("Read" & Star_Names)));

         Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
            Routine        => Timeout_Get'access,
            Routine_Name   => AUnit.Format ("Timeout_Get" & Star_Names)));

   --    Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
   --       Routine        => Set_Subscription_Mode'access,
   --       Routine_Name   => AUnit.Format ("Set_Subscription_Mode" & Star_Names)));

         Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
            Routine        => Wild_Get'access,
            Routine_Name   => AUnit.Format ("Wild_Get" & Star_Names)));
      end if;

      Log_Out (Debug);
   end Register_Tests;

   ---------------------------------------------------------------
   procedure Read (
      Test                    : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

--    This_Test                  : Server_Test_Type renames Server_Test_Type (Test);
--    Options                    : constant GNOGA_Options.Database.AUnit.Aunit_Program_Options_Constant_Class_Access :=
--                                     Runtime_Options.Get_Options;
      Server                     : constant Ada_Lib.Database.Server.Server_Access := Server_State.Get_Server;
      Updated_Name_Value         : constant Ada_Lib.Database.Name_Value_Type := Name_Value_1;

   begin
      Log (Debug, Here, Who & " enter");

      Assert (Server.Is_Open, "data base not open");
      Server.Post (Name_Value_1, Write_Timeout);
      delay Update_Time;

      declare
         Answer                  : constant Ada_Lib.Database.Name_Value_Type'class :=
                                    Server.Read (
                                       Name        => Name_1,
                                       Index       => Ada_Lib.Database.No_Vector_Index,
                                       Tag         => "");
      begin
         Assert (Name_Value_1 = Ada_Lib.Database.Name_Value_Type (Answer), "1st Read returned wrong value. Got " &
            Answer.Image & " expected " & Name_Value_1.Image);
      end;

      Server.Post (Updated_Name_Value, Write_Timeout);
      delay 0.2;     -- let update complete
      declare
         Answer                  : constant Ada_Lib.Database.Name_Value_Type'class :=
                                    Server.Read (
                                       Name        => Name_1,
                                       Index       => Ada_Lib.Database.No_Vector_Index,
                                       Tag         => "");
      begin
         Assert (Name_Value_1 = Ada_Lib.Database.Name_Value_Type (Answer), "2nd Read returned wrong value. Got " &
            Answer.Image & " expected " & Name_Value_1.Image);
      end;

      Log (Debug, Here, Who & " exit");

   exception
      when Fault: AUnit.Assertions.Assertion_Error =>
         Trace_Message_Exception (Debug, Fault, "exception in Read test");
         raise;

      when Fault: others =>
         Trace_Message_Exception (Fault, Who & " exception in Read test");
         Assert (False, "exception " & Ada.Exceptions.Exception_Name (Fault) &
            " in Read test. Message: " & Ada.Exceptions.Exception_Message (Fault));
   end Read;

   ---------------------------------------------------------------
   procedure Resubscribe (          -- change update mode
      Test                    : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

   -- test case
   -- subscribe and unsubscribe 3 times
   -- 1st always
   -- 2nd on change
   -- 3rd always
   -- send data each time and verify update counts.

      type Subscription_Types    is (Update_Mode_Unsubscribed, Any_Kept, Any_Unsubscribed);

      Expected_Count            : Natural := 0;
      First_Subscription         : Boolean := True;
      Local_Name_Value           : constant Ada_Lib.Database.Name_Value_Type := Ada_Lib.Database.Create (
                                    "variable", Ada_Lib.Database.No_Vector_Index, "", "event 1");
      Subscription               : Ada_Lib.Database.Subscription.Tests.Subscription_Type;
      Unsubscribe_Resubscribe : constant array (Subscription_Types) of Ada_Lib.Database.Updater.Update_Mode_Type := (
                                 Update_Mode_Unsubscribed   => Ada_Lib.Database.Updater.Unique,
                                 Any_Kept                   => Ada_Lib.Database.Updater.Always,
                                 Any_Unsubscribed           => Ada_Lib.Database.Updater.Unique);
      This_Test               : Server_Test_Type renames Server_Test_Type (Test);
--    Options                    : constant GNOGA_Options.Database.AUnit.Aunit_Program_Options_Constant_Class_Access :=
--                                     Runtime_Options.Get_Options;
      Server                     : constant Ada_Lib.Database.Server.Server_Access := Server_State.Get_Server;

   begin
      Log (Debug, Here, Who & " enter");
      Assert (Server.Is_Open, "data base not open");

      for Update_Mode of Unsubscribe_Resubscribe loop
         Test_Subscription (This_Test, Local_Name_Value, Update_Mode, Subscription,
            Expected_Count, First_Subscription);
         First_Subscription := False;
         delay 0.2;     -- make sure last update completes before resubscribing
      end loop;
      Log (Debug, Here, Who & " exit");

   exception
      when Fault: AUnit.Assertions.Assertion_Error =>
         Trace_Message_Exception (Debug, Fault, "exception in Resibscribe test");
         raise;

      when Fault: others =>
         Trace_Message_Exception (Fault, Who & " exception in Resibscribe test");
         Assert (False, "exception in Resibscribe test");
   end Resubscribe;

   ---------------------------------------------------------------
   function Server_Suite (
      Which_Host                 : in    Ada_Lib.Database.Which_Host_Type
   ) return AUnit.Test_Suites.Access_Test_Suite is
   ---------------------------------------------------------------

--    Test_Suite                 : constant AUnit.Test_Suites.Access_Test_Suite :=
--                                  new Test_Suite_Type;
      Test_Suite                 : constant AUnit.Test_Suites.Access_Test_Suite :=
                                    new AUnit.Test_Suites.Test_Suite;
--    Open_Close_Test            : constant Ada_Lib.Unit_Test.Test_Cases.Test_Case_Class_Access :=
--                                  Ada_Lib.Unit_Test.Test_Cases.Test_Case_Class_Access'(case Which_Host is
--
--                                     when Ada_Lib.Database.Local =>
--                                        new Local_Open_Close_Server_Test_Type,
--
--                                     when Ada_Lib.Database.Remote =>
--                                        new Remote_Open_Close_Server_Test_Type,
--
--                                     when Ada_Lib.Database.No_Host |
--                                          Ada_Lib.Database.Unset =>
--                                        Null
--                                  );
      Tests                      : constant Ada_Lib.Unit_Test.Test_Cases.Test_Case_Class_Access :=
                                    Ada_Lib.Unit_Test.Test_Cases.Test_Case_Class_Access'(case Which_Host is

                                       when Ada_Lib.Database.Local =>
                                          new Local_Server_Test_Type,

                                       when Ada_Lib.Database.Remote =>
                                          new Remote_Server_Test_Type,

                                       when Ada_Lib.Database.No_Host |
                                            Ada_Lib.Database.Unset =>
                                          Null
                                    );

   begin
      Log (Debug, Here, Who & " Which_Host " & Which_Host'img);
      Ada_Lib.Unit_Test.Suite (Suite_Name);  -- used for listing suites
--    Test_Suite.Add_Test (Open_Close_Test);
      Test_Suite.Add_Test (Tests);
      return Test_Suite;
   end Server_Suite;

-- ---------------------------------------------------------------
-- -- allocates Server
-- procedure Set_Up (
--    Test                          : in out Server_Open_Close_Test_Type) is
-- ---------------------------------------------------------------
--
--    Options                    : constant Run_Options.Options_Access := This_Test.Options;
--
-- begin
--    Log (Debug, Here, Who & " enter which host " & Test.Which_Host'img);
--    Ada_Lib.Database.Unit_Test.Test_Case_Type (Test).Set_Up;
--    Test.Started := Options.Server.Create_Server (Options.Host, Options.Port);
--    Log (Debug, Here, Who & " exit");
--
-- exception
--    when Fault: others =>
--       Trace_Message_Exception (Fault, Who, Here);
--       Test.Set_Up_Exception (Fault, Here, Who, "could not open database");
--       Log (Debug, Here, Who & " kill");
-- end Set_Up;

   ---------------------------------------------------------------
   -- allocates Server
   -- calls Server.Open
   overriding
   procedure Set_Up (
      Test                          : in out Server_Test_Type) is
   ---------------------------------------------------------------

--    Options           : Ada_Lib.Options.AUnit_Lib.Aunit_Program_Options_Type'class
--                         renames Ada_Lib.Options.AUnit_Lib.
--                            Aunit_Program_Options_Constant_Class_Access (
--                               Ada_Lib.Options.Verification.Get_Ada_Lib_Read_Only_Nested_Options).all;
--    Subscription_Table         : constant Ada_Lib.DAtabase.Subscribe.
--                                  Table_Class_Access := new Ada_Lib.Database.
--                                     Subscription.Tests.Subscription_Table_Type;
   begin
not_implemented;
--    Log (Debug or Trace_Set_Up_Tear_Down, Here, Who & " enter which host " & Test.Which_Host'img);
--    Ada_Lib.Database.Unit_Test.Test_Case_Type (Test).Set_Up;
--    Test.Started := Server_State.Create_Server (
--       Subscription_Table,
--       Options.Database_Options.Get_Host,
--       Options.Database_Options.Port);
--    Log (Debug or Trace_Set_Up_Tear_Down, Here, Who & " exit");
--
-- exception
--    when Fault: others =>
--       Trace_Message_Exception (Fault, Who, Here);
--       Test.Set_Up_Message_Exception (Fault, Here, Who, "could not open database");
--       Log (Debug, Here, Who & " kill");
   end Set_Up;

   ---------------------------------------------------------------------------------
   overriding
   procedure Signaled (
      Signal_Content          : in out Content_Type) is
   ---------------------------------------------------------------------------------

   begin
      Signal_Content.Update_Count := Signal_Content.Update_Count + 1;
      Log (Debug, Here, Who & " count after update" & Signal_Content.Update_Count'img);
   end Signaled;

   ---------------------------------------------------------------
   procedure Start_Stop (
      Test                    : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

      This_Test                  : Server_Test_Type renames Server_Test_Type (Test);
--    Options                    : constant Runtime_Options.Options_Constant_Class_Access :=
--                                     Runtime_Options.Get_Options;
      Server                     : constant Ada_Lib.Database.Server.Server_Access := Server_State.Get_Server;

   begin
      Log (Debug, Here, Who & " enter");
      Assert (This_Test.Started, "server not started");
--    declare
--       Options                 : constant Runtime_Options.Options_Class_Access := This_Test.Options;
--       Server                  : constant Ada_Lib.Database.Server.Server_Access :=
--                                  Server.Get_Server;
--    begin
         Assert (Server.Is_Started, "server not ready");
         Server.Close;
--    end;
      Log (Debug, Here, Who & " exit");

   exception
      when Fault: others =>
         Trace_Message_Exception (Fault, Who, Here);
         Assert (False, "could not open server");
   end Start_Stop;

   ---------------------------------------------------------------
   procedure Subscribe (
      Test                    : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

      Event                      : Ada_Lib.Database.Event.Event_Type;
      Expected_Count            : Natural := 0;
      Subscription               : Ada_Lib.Database.Subscription.Tests.Subscription_Type;
      This_Test                  : Server_Test_Type renames Server_Test_Type (Test);
--    Options                    : constant Runtime_Options.Options_Constant_Class_Access :=
--                                     Runtime_Options.Get_Options;
      Server                     : constant Ada_Lib.Database.Server.Server_Access := Server_State.Get_Server;
      Update_Mode                : constant Ada_Lib.Database.Updater.Update_Mode_Type := Ada_Lib.Database.Updater.Always;

   begin
      Log (Debug, Here, Who & " enter");

      Assert (Server.Is_Open, "data base not open");
      Event.Set (new Content_Type);
--    declare
--       Signal                  : constant Content_Access := Content_Access (Event.Ptr);
--
--    begin
      Test_Subscription (This_Test, Name_Value_1, Update_Mode, Subscription,
         Expected_Count, True);
--    end;
      Log (Debug, Here, Who & " exit");

   exception
      when Fault: AUnit.Assertions.Assertion_Error =>
         Trace_Message_Exception (Debug, Fault, "exception in Subscribe test");
         raise;

      when Fault: others =>
         Trace_Message_Exception (Fault, Who & " exception in Subscribe test");
         Assert (False, "exception " & Ada.Exceptions.Exception_Name (Fault) &
            " in Subscribe test. Message: " & Ada.Exceptions.Exception_Message (Fault));
   end Subscribe;

   ---------------------------------------------------------------
   procedure Subscribe_Unsubscribe (
      Test                    : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

   -- test case
   -- subscribe and unsubscribe 3 times
   -- 1st always
   -- 2nd on change
   -- 3rd always
   -- send data each time and verify update counts.

      type Subscription_Types    is (Update_Mode_Unsubscribed, Any_Kept, Any_Unsubscribed);

      Expected_Count            : Natural := 0;
      Local_Name_Value           : constant Ada_Lib.Database.Name_Value_Type := Ada_Lib.Database.Create (
                                    "variable", Ada_Lib.Database.No_Vector_Index, "", "event 1");
      Subscription               : Ada_Lib.Database.Subscription.Tests.Subscription_Type;
      Unsubscribe_Resubscribe : constant array (Subscription_Types) of Ada_Lib.Database.Updater.Update_Mode_Type := (
                                 Update_Mode_Unsubscribed   => Ada_Lib.Database.Updater.Unique,
                                 Any_Kept                   => Ada_Lib.Database.Updater.Always,
                                 Any_Unsubscribed           => Ada_Lib.Database.Updater.Unique);
      This_Test               : Server_Test_Type renames Server_Test_Type (Test);
--    Options                    : constant Runtime_Options.Options_Constant_Class_Access :=
--                                     Runtime_Options.Get_Options;
      Server                     : constant Ada_Lib.Database.Server.Server_Access := Server_State.Get_Server;

   begin
      Log (Debug, Here, Who & " enter");
      Assert (Server.Is_Open, "data base not open");

      for Update_Mode of Unsubscribe_Resubscribe loop
         declare
            Event                   : Ada_Lib.Database.Event.Event_Type;

         begin
            Event.Set (new Content_Type);

--          declare
--             Signal                  : constant Content_Access := Content_Access (Event.Ptr);
--
--          begin
               Test_Subscription (This_Test, Local_Name_Value, Update_Mode, Subscription, Expected_Count, True);
               delay 0.2;     -- make sure last update completes before unsubscribing
               Assert (Server.Unsubscribe (True, Local_Name_Value.Name.Coerce,
                  Ada_Lib.Database.No_Vector_Index, "", Ada_Lib.Database.Updater.Abstract_Updater_Type'tag), "Unsubscribe failed");
--          end;
         end;
      end loop;
      Log (Debug, Here, Who & " exit");

   exception
      when Fault: AUnit.Assertions.Assertion_Error =>
         Trace_Message_Exception (Debug, Fault, "exception in Subscribe_Unsubscribe test");
         raise;

      when Fault: others =>
         Trace_Message_Exception (Fault, Who & " exception in Subscribe_Unsubscribe test");
         Assert (False, "exception in Subscribe_Unsubscribe test");
   end Subscribe_Unsubscribe;

-- test removed. read does not crete a subscription
-- ---------------------------------------------------------------
-- procedure Subscription_State (
--    Test                       : in out AUnit.Test_Cases.Test_Case'class) is
-- ---------------------------------------------------------------
--
--    -- subscribe to one name
--    -- read a second name
--    -- verify both exits
--    -- verify mode of both
--    Event                      : Ada_Lib.Database.Event.Event_Type;
--    This_Test                  : Server_Test_Type renames Server_Test_Type (Test);
--    Update_Mode                : constant Ada_Lib.Database.Updater.Update_Mode_Type := Ada_Lib.Database.Updater.Always;
--
-- begin
--    Log (Debug, Here, Who & " enter");
--
--    Server.Post (Name_Value_1, Write_Timeout);
--    Server.Post (Name_Value_2, Write_Timeout);
--
--    Assert (Server.Is_Open, "data base not open");
--    Event.Set (new Content_Type);
--    Assert (Server.Subscribe (Event, Name_1, Update_Mode), "Subscribe failed");
--
--    declare
--       Response_2              : constant Ada_Lib.Database.Name_Value_Type'class :=
--                                  Server.Read (Name_2,
--                                     Ada_Lib.Database.No_Vector_Index, Read_Timeout);
--       Response_3              : constant Ada_Lib.Database.Name_Value_Type'class :=
--                                  Server.Read (Name_3,
--                                     Ada_Lib.Database.No_Vector_Index, Read_Timeout);
--
--    begin
--       Assert (Server.Has_Subscription (Name_1), "did not have subscription for subscribed name " & Name_1);
--       Assert (not Server.Has_Subscription (Name_2), "had a subscription for read " & Name_2 & " did not save value");
--       Assert (Server.Has_Subscription (Name_3), "did not have subscription for read " & Name_3);
--       Assert (Server.Get_Subscription_Update_Mode (Name_1) = Update_Mode,
--          "Get_Subscription_Update_Mode returned wrong value for " & Name_1);
--       Assert (Server.Get_Subscription_Update_Mode (Name_3) = Ada_Lib.Database.Updater.Never,
--          "Get_Subscription_Update_Mode returned wrong value for " & Name_3);
--    end;
-- end Subscription_State;
--
   ---------------------------------------------------------------
   overriding
   procedure Tear_Down (
      Test                          : in out Server_Test_Type) is
   ---------------------------------------------------------------

--    Options                    : constant Runtime_Options.Options_Constant_Class_Access :=
--                                     Runtime_Options.Get_Options;
      Server                     : constant Ada_Lib.Database.Server.Server_Access := Server_State.Get_Server;

   begin
      Log (Debug or Trace_Set_Up_Tear_Down, Here, Who & " enter");

      Ada_Lib.Database.Unit_Test.Test_Case_Type (Test).Tear_Down;
      Log (Debug or Trace_Set_Up_Tear_Down, Here, Who & " delete value");
      Test.Get_Database.Delete (Name_1, Ada_Lib.Database.No_Vector_Index);

      if Server /= Null then
         Log (Debug, Here, Who & " close server");
         Server.Close;
         Log (Debug, Here, Who & " free server");
         Server_State.Free_Server;
      end if;

      Pause (Pause_Flag and Debug, "Pause before Tear Down cleanup", Here, Debug);
      Log (Debug or Trace_Set_Up_Tear_Down, Here, Who & " exit");
   end Tear_Down;

-- ---------------------------------------------------------------
-- procedure Tear_Down (
--    Test                          : in out Server_Open_Close_Test_Type) is
-- ---------------------------------------------------------------
--
-- begin
--    Log (Debug, Here, Who & " enter");
--
--    Ada_Lib.Database.Unit_Test.Test_Case_Type (Test).Tear_Down;
--    if Server /= Null then
--       Log (Debug, Here, Who & " free server");
--       Server.Free_Server;
--    end if;
--
--    Pause (This_Test.Options.Pause, "Pause before Tear Down cleanup", Here, Debug);
--    Log (Debug, Here, Who & " exit");
-- end Tear_Down;

   ---------------------------------------------------------------
   procedure Test_Subscription (
      Test                       : in     Server_Test_Type;
      Name_Value                 : in     Ada_Lib.Database.Name_Value_Type;
      Update_Mode                : in     Ada_Lib.Database.Updater.Update_Mode_Type;
      Subscription               : in out Ada_Lib.Database.Subscription.Tests.Subscription_Type;
      Expected_Count            : in out Natural;
      First_Subscription         : in     Boolean) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

      Name                       : constant String := Name_Value.Name.Coerce;
--    Options                    : constant Runtime_Options.Options_Constant_Class_Access :=
--                                     Runtime_Options.Get_Options;
      Server                     : constant Ada_Lib.Database.Server.Server_Access := Server_State.Get_Server;
--    Value                      : constant String := Name_Value.Value.Coerce;

   begin
      case First_Subscription is

      when True =>
      Server.Add_Subscription (Subscription'unchecked_access);

      when False =>
         Server.Set_Subscription_Mode (Name, Ada_Lib.Database.No_Vector_Index, "",
            Ada_Lib.Database.Subscription.Tests.Subscription_Type'class (Subscription)'tag, Update_Mode);

      end case;
      Server.Post (Name_Value, Write_Timeout);

      if    Update_Mode = Ada_Lib.Database.Updater.Always or else
            not First_Subscription then           -- don't increment when 1st post is same as original value
         Expected_Count := Expected_Count + 1;
      end if;

      delay 0.2;     -- let update complete

      declare
         Number_Repititions      : constant := 3;
         Number_Unique_Updates   : constant := 10;
         Value                   : Natural  := 0;

      begin
         for Unique_Counter in 1 .. Number_Unique_Updates loop
            Value := Value + 1;
            for Repitition_Counter in 1 .. Number_Repititions loop
               Server.Post (Ada_Lib.Database.Name_Value_Type'(Ada_Lib.Database.Create (
                     Name  => Name_Value.Name.Coerce,
                     Index => Ada_Lib.Database.No_Vector_Index,
                     Tag   => "",
                     Value => Value'img)),
                  Write_Timeout);
            end loop;
         end loop;

         Log (Debug, Here, Who);
         delay Subscribe_Timeout;     -- wait for all updates to come in

         Expected_Count := Expected_Count + Number_Unique_Updates *
            (if Update_Mode = Ada_Lib.Database.Updater.Unique then 1 else Number_Repititions );

         Log (Debug, Here, Who & " on change " & Update_Mode'img &
            " name value " & Subscription.Name_Value.Image &
            " Expected_Count" & Expected_Count'img &
            " Number_Unique_Updates" & Number_Unique_Updates'img &
            " subscription count" & Subscription.Update_Count'img &
            " address " & Ada_Lib.Strings.Image (Subscription'address));
         Assert (Subscription.Update_Count = Expected_Count, "wrong update count. got" &
            Subscription.Update_Count'img & " expected" & Expected_Count'img &
            " subscription address " & Ada_Lib.Strings.Image (Subscription'address));
      end;
   end Test_Subscription;

   ---------------------------------------------------------------
   procedure Timeout_Get (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

--    This_Test                  : Server_Test_Type renames Server_Test_Type (Test);
--    Options                    : constant Runtime_Options.Options_Constant_Class_Access :=
--                                     Runtime_Options.Get_Options;
      Server                     : constant Ada_Lib.Database.Server.Server_Access := Server_State.Get_Server;

   begin
      Log (Debug, Here, Who);
      Assert (Server.Is_Open, "data base not open");

      declare
         Response                : constant String := Server.all.Get (Test_Timeout);

      begin
         if not Assert (Response'length = 0, "null response expected") then
            Log_Here ("unexpected response '" & Response & "'");
         end if;
      end;
   end Timeout_Get;

-- ---------------------------------------------------------------
-- procedure Update (
--    Event                  : in out Subscription_Tests_Updated_Value_Type) is
-- ---------------------------------------------------------------
--
-- begin
--    Event.Was_Signaled := True;
--    Event.Update_Count := Event.Update_Count + 1;
--    Log (Debug, Here, Who &  " Event " & Image (Event'address) & " label " & Event.Label.Coerce &
--       " value '" & Event.Name_Value.To_String & "' count" & Event.Update_Count'img);
-- end Update;
--
-- ---------------------------------------------------------------
-- procedure Update (
--    Event                  : in out Update_Test_Updated_Value_Type) is
-- ---------------------------------------------------------------
--
-- begin
--    null;    -- no used for this test;
-- end Update;
--
-- ---------------------------------------------------------------
-- not currently supported
-- procedure Set_Subscription_Mode (
--    Test                       : in out AUnit.Test_Cases.Test_Case'class) is
-- ---------------------------------------------------------------
--
--    type Cursor_Type is new Ada_Lib.DAtabase.Subscribe.Subscription_Cursor_Type with record
--       Updated                 : Boolean := False;
--    end record;
--
--    overriding
--    function Process (
--       Cursor                  : in out Cursor_Type
--    ) return Boolean;
--
--    Local_Name_Value           : constant Ada_Lib.Database.Name_Value_Type := Ada_Lib.Database.Create ("abc", "123");
--    Update_Mode                : constant Ada_Lib.Database.Updater.Update_Mode_Type := Ada_Lib.Database.Updater.Unique;
--    This_Test                  : Server_Test_Type renames Server_Test_Type (Test);
--    Update_Value               : constant := 1;
--
--    ---------------------------------------------------------------
--    function Process (
--       Cursor                  : in out Cursor_Type
--    ) return Boolean is
--    ---------------------------------------------------------------
--
--    begin
--       Log (Debug, Here, Construct (Who & " enter name '",
--          Cursor.Name_Value.Name & "'"));
--
--       Assert (Cursor.Name_Value.Name = Local_Name_Value.Name,
--          Construct ("wrong name value got ", Cursor.Name_Value.Name &
--          "expected " & Local_Name_Value.Name));
--       Assert (Cursor.Update_Mode = Update_Mode, "wrong on change");
--       Update_Test_Updated_Value_Access (Cursor.Subscription).Value := Update_Value;
--       Cursor.Updated := True;
--       return True;
--
--    exception
--
--       when Fault: AUNIT.ASSERTIONS.ASSERTION_ERROR =>
--          Trace_Message_Exception (Fault, Who & " aunit assertion");
--          return false;
--
--    end Process;
--
--    Cursor                     : Cursor_Type;
--    Subscription               : constant access Update_Test_Updated_Value_Type :=
--                                  Allocate_Update_Test_Updated (Name, Value_1, Ada_Lib.Database.Updater.Always);
--    Subscribe_Handle           : constant Ada_Lib.Database.Subscriptions.Handle.Subscribed_Object_Type :=
--                                  Ada_Lib.Database.Subscriptions.Handle.Create (
--                                     Local_Name_Value.Name.Coerce,
--                                     Ada_Lib.Database.Subscriptions.Event.Subscription_Entity_Class_Access (
--                                        Subscription));
--    Updated                    : Boolean;
--
-- begin
--    Log (Debug, Here, Who & " enter");
--
--    Assert (Server.Subscribe (Subscribe_Handle, Local_Name_Value.Name.Coerce, Update_Mode), "subscribe failed");
--
--    Updated := Server.Update (Cursor, Local_Name_Value.Name.Coerce, Subscription.Id);
--    Assert (Updated, "update failed");
--    Assert (Cursor.Updated, "subscription did not get updated");
--    Assert (Subscription.Value = Update_Value, "value did not get updated");
--
-- end Set_Subscription_Mode;

   ---------------------------------------------------------------
   procedure Wild_Get (    -- needs new dbdaemon
      Test                          : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

      This_Test                  : Server_Test_Type renames Server_Test_Type (Test);

   begin
      Ada_Lib.Database.Common.Wild_Get (This_Test.Get_Database.all);

   exception
      when Fault: Ada_Lib.Database.Common.Failed =>
         raise Failed with Ada.Exceptions.Exception_Message (Fault);
   end Wild_Get;

begin
   if Trace_Tests then
      Debug := Trace_Tests;
   end if;
--Trace_Options := True;
   Log_Here (Debug or Elaborate or Trace_Options);

end Ada_Lib.Database.Server.Tests;

