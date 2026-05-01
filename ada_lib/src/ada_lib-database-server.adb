with Ada.Text_IO;use Ada.Text_IO;
with Ada.Unchecked_Deallocation;
with Ada_Lib.Options;
with Ada_Lib.OS;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Time;
with Ada_Lib.Trace; use Ada_Lib.Trace;

-- pragma Elaborate (Ada_Lib.OS);

package body Ada_Lib.Database.Server is

   use type Ada.Task_Identification.Task_Id;
   use type Ada_Lib.Time.Time_Type;

   protected Poll_Timeout is

      function Get_Abort_Time return Ada_Lib.Time.Time_Type;

      function Get_Mode return Timeout_Mode_Type;

      function Get_Subscribe_Timeout return Duration;

      procedure Set_Mode (
         Mode                    : in     Timeout_Mode_Type;
         Timeout                 : in      Duration);

--    procedure Set_Timeout (
--       Timeout                 : in      Duration);

      procedure Update_Abort_Timoout;

   private
      Abort_Time                 : Ada_Lib.Time.Time_Type;
      Subscribe_Timeout          : Duration := 0.0;
      Timeout_Mode               : Timeout_Mode_Type := Disabled;

   end Poll_Timeout;

   procedure Free_Server is new Ada.Unchecked_Deallocation (
      Name     => Server_Access,
      Object   => Server_Type);

   procedure Tasking_Error_Occured (
      From                       : in     String := Here);
   pragma No_Return (Tasking_Error_Occured);

-- Read_Timeout            :constant Duration := 1.0;
-- Server_Task_ID          :Ada.Task_Identification.Task_ID := Ada.Task_Identification.Null_Task_Id;
   Server_Tasking_Error    :Boolean := False;
-- Subscribe_Timeout       :Duration := 0.0;
   Task_Exit_Timeout       :constant Duration := 0.5;
   Task_Shutdown_Timeout   :constant Duration := 0.5;
-- Timeout_Mode            :Timeout_Mode_Type := Disabled;
   Trace                   : Boolean renames
                              Options.Ada_Lib_Database.Server_Trace;
   Trace_All               : Boolean renames
                              Options.Ada_Lib_Database.Server_Trace;
   Update_Wait_Time        :constant Duration := 0.25;
   Write_Timeout           :constant Duration := 0.25;

   ---------------------------------------------------------------------------------
   procedure Add_Subscription (
      Server                     : in out Server_Type;
      Updater                    : in     Ada_Lib.Database.Updater.Updater_Interface_Class_Access) is
   ---------------------------------------------------------------------------------

      Task_Gateway               : Gateway.Gateway_Type := Gateway.Enter;
      pragma Unreferenced (Task_Gateway); -- declared for sideeffect

   begin
      Log_In (Trace);
      Server.Subscriber.Add_Subscription (Updater);
--    Server.Subscriber.Send_Subscription_Mode (Updater.all); -- removed 8/30/22
      Log_Out (Trace);
   end Add_Subscription;

   ---------------------------------------------------------------------------------
   function Allocate_Server (
      Subscription_Table         : in     Ada_Lib.Database.Subscribe.Table_Class_Access;
      Host_Name                  : in     String;
      Port                       : in     Port_Type;
      Idle_Timeout               : in     Duration := 0.0
   ) return Server_Access is
   ---------------------------------------------------------------------------------

      Server                     : Server_Access;

   begin
      Log_In (Trace, " host " & Host_Name & " port" & Port'img &
         " Idle_Timeout " & Idle_Timeout'img);

      Server := new Server_Type;
      Server.Subscriber.Get_Task_Id (Server.Subscriber_Task_ID);
      declare
         Result                  : Boolean;
         Task_Gateway            : Gateway.Gateway_Type := Gateway.Enter;
         pragma Unreferenced (Task_Gateway); -- declared for sideeffect

      begin
         Log_Here (Trace, " host " & Host_Name & " Idle_Timeout " & Idle_Timeout'img);
--          " task id" & Server.Subscriber_Task_ID'img);

         Server.Subscriber.Open (Subscription_Table, Host_Name, Port, Idle_Timeout, Result);
         if not Result then
            Log_Exception (Trace);
            raise Failed with "could not open database";
         end if;
         declare
            Timeout           : constant Ada_Lib.Time.Time_Type := Ada_Lib.Time.Now + 0.5;

         begin
            while Ada_Lib.Time.Now < Timeout loop
               if Server.Is_Started then
                  Log_Here (Trace_All, " database opened");

                  if    Server.Read_Database.Open (Host_Name, Port) and then
                        Server.Write_Database.Open (Host_Name, Port) then
                     Log_Out (Trace);
                     return Server;
                  else
                     Log_Exception (Trace);
                     raise FAiled with "coud not open read and write databases";
                  end if;
               else
                  delay 0.1;
               end if;
            end loop;

            Log_Exception (Trace_All);
            raise Failed with "server did not become callable";
         end;
      end;
   end Allocate_Server;

   ---------------------------------------------------------------------------------
   procedure Close (
      Server                     : in out Server_Type) is
   ---------------------------------------------------------------------------------

      Timeout                    : constant Ada_Lib.Time.Time_Type := Ada_Lib.Time.Now + Task_Shutdown_Timeout;

   begin
      Log_In (Trace,
         " read database open " & Server.Read_Database.Is_Open'img &
         " write database open " & Server.Write_Database.Is_Open'img);

      if Server.Read_Database.Is_Open then
         Server.Read_Database.Close;
      end if;

      if Server.Write_Database.Is_Open then
         Server.Write_Database.Close;
      end if;

      Log_Here (Trace, " wait for termination task id " &
         Ada.Task_Identification.Image (Server.Subscriber_Task_Id));

      if Server.Subscriber_Task_Id = Ada.Task_Identification.Null_Task_Id or else
            Ada.Task_Identification.Is_Terminated (Server.Subscriber_Task_Id) then
         Log_Out (Trace);
         return;
      end if;

      declare
         Task_Gateway            : Gateway.Gateway_Type := Gateway.Enter;
         pragma Unreferenced (Task_Gateway); -- declared for sideeffect

      begin
         Server.Subscriber.Close;
         while Ada_Lib.Time.Now < Timeout loop
--          if    Server.Subscriber_Task_Id = Ada.Task_Identification.Null_Task_Id or else
--                Ada.Task_Identification.Is_Terminated (Server.Subscriber_Task_Id) then
--             Server.Subscriber_Task_Id := Ada.Task_Identification.Null_Task_Id;
            if Server.Is_Stopped then
               Log_Out (Trace_All);
               return;
            end if;
            delay 0.1;
         end loop;
      end;

      Log_Exception (Trace_All, " timeout ");
      raise Failed with "timeout waiting for Subscriber task to terminate";

   exception
      when Tasking_Error =>
         Tasking_Error_Occured;
--       raise Failed with "close server failed";

   end Close;

   ---------------------------------------------------------------------------------
   procedure Delete_All_DBDaemon_Values (
      Server                     : in out Server_Type) is
   ---------------------------------------------------------------------------------

   begin
      Server.Subscriber.Delete_All_DBDaemon_Values;
   end Delete_All_DBDaemon_Values;

   ---------------------------------------------------------------------------------
   procedure Delete_All_Subscriptions (
      Server                     : in out Server_Type;
      Unsubscribed_Only          : in     Boolean := False;
      Timeout                    : in     Duration := Default_Post_Timeout) is
   ---------------------------------------------------------------------------------

      Task_Gateway               : Gateway.Gateway_Type := Gateway.Enter;
      pragma Unreferenced (Task_Gateway); -- declared for sideeffect

   begin
      Log_In (Trace, "Unsubscribed_Only " & Unsubscribed_Only'img);
      Server.Subscriber.Delete_All (Unsubscribed_Only); --, Timeout);
      Log_Out (Trace);

   exception
      when Tasking_Error =>
         Tasking_Error_Occured;

   end Delete_All_Subscriptions;

   ---------------------------------------------------------------------------------
   function Delete_Subscription (
      Server                     : in out Server_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag;
      Timeout                    : in     Duration := Default_Post_Timeout
   ) return Boolean is
   ---------------------------------------------------------------------------------

      Result                     : Boolean;
      Task_Gateway               : Gateway.Gateway_Type := Gateway.Enter;
      pragma Unreferenced (Task_Gateway); -- declared for sideeffect


   begin
      Log_In (Trace);
      Server.Subscriber.Delete (Name, Index, DBDaemon_Tag, Ada_Tag, Result);
      Log_Out (Trace);
      return Result;

   exception
      when Tasking_Error =>
         Tasking_Error_Occured;
         return False;

   end Delete_Subscription;

   ---------------------------------------------------------------------------------
   function Delete_Subscription (
      Server                     : in out Server_Type;
      Updater               : in     Ada_Lib.Database.Updater.Updater_Interface_Class_Access
   ) return Boolean is
   ---------------------------------------------------------------------------------

      Result                     : Boolean;
      Task_Gateway               : Gateway.Gateway_Type := Gateway.Enter;
      pragma Unreferenced (Task_Gateway); -- declared for sideeffect


   begin
      Log_In (Trace, "Updater address " & Ada_Lib.Strings.image (Updater.all'address));
      Server.Subscriber.Delete (Updater, Result);
      Log_Out (Trace, "result " & Result'img);
      return Result;

   exception
      when Tasking_Error =>
         Tasking_Error_Occured;
         return False;

   end Delete_Subscription;

   ---------------------------------------------------------------------------------
   procedure Call_Callback (
      Server                    : in     Server_Type;
      Parameter                 : in out Callback_Parameter_Type'class) is
   ---------------------------------------------------------------------------------

      Task_Gateway               : Gateway.Gateway_Type := Gateway.Enter;
      pragma Unreferenced (Task_Gateway); -- declared for sideeffect

   begin
      Log_In (Trace);
      Server.Subscriber.Call_Callback (Parameter);
      Log_Out (Trace);
   end Call_Callback;

   ---------------------------------------------------------------------------------
   procedure Dump (
      Server                     : in     Server_Type) is
   ---------------------------------------------------------------------------------

   begin
      Server.Subscriber.Dump;
   end Dump;

   ---------------------------------------------------------------------------------
   procedure Flush_Input (
      Server                     : in out Server_Type) is
   ---------------------------------------------------------------------------------

   begin
      Server.Read_Database.Flush_Input;

   exception
      when Tasking_Error =>
         Tasking_Error_Occured;

   end Flush_Input;

   ---------------------------------------------------------------------------------
   procedure Free (
      Server                     : in out Server_Access) is
   ---------------------------------------------------------------------------------

      Timeout                    : constant Ada_Lib.Time.Time_Type := Ada_Lib.Time.Now + Task_Exit_Timeout;

   begin
      Log_In (Trace);
      while Ada_Lib.Time.Now < Timeout loop
         if Server_Tasking_Error or else Server.Is_Stopped then
            if Server_Tasking_Error then
               delay 0.1;     -- make sure task had time to terminate
            end if;
            Log_Out (Trace_All, " Server_Tasking_Error " & Server_Tasking_Error'img);
            Free_Server (Server);
            return;
         else
            delay 0.1;
         end if;
      end loop;
      Log_Exception (Trace);
      raise Failed with "timeout waiting for server task terminate";
   end Free;

   ---------------------------------------------------------------------------------
   function Get (
      Server                     : in out Server_Type;
      Timeout                    : in     Duration := Default_Get_Timeout
   ) return String is
   ---------------------------------------------------------------------------------

   begin
      return Server.Read_Database.Get (Timeout);

   exception
      when Tasking_Error =>
         Tasking_Error_Occured;
         return "";

   end Get;

   ---------------------------------------------------------------------------------
   function Get (
      Server                     : in out Server_Type;
      Timeout                    : in     Duration := Default_Get_Timeout
   ) return Name_Value_Class_Type is
   ---------------------------------------------------------------------------------

   begin
      return Server.Read_Database.Get (Timeout);

   exception
      when Tasking_Error =>
         Tasking_Error_Occured;
         return Null_Name_Value;

   end Get;

   ---------------------------------------------------------------------------------
   function Get_Subscriber (
      Server                     : in out Server_Type
   ) return access Subscriber_Task is
   ---------------------------------------------------------------------------------

   begin
      return Server.Subscriber'unchecked_access;
   end Get_Subscriber;

   ---------------------------------------------------------------------------------
   function Get_Subscription (
      Server                     : in out Server_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag
   ) return Ada_Lib.Database.Updater.Updater_Interface_Class_Access is
   ---------------------------------------------------------------------------------

      Result                     : Ada_Lib.Database.Updater.Updater_Interface_Class_Access;
      Task_Gateway               : Gateway.Gateway_Type := Gateway.Enter;
      pragma Unreferenced (Task_Gateway); -- declared for sideeffect


   begin
      Log_In (Trace, " enter name '" & Name & "' index " & Index'img &
         Tag_Name (" Ada_Tag", Ada_Tag));
      Server.Subscriber.Get_Subscription (Name, Index, DBDaemon_Tag, Ada_Tag, Result);
      Log_Out (Trace, " exit with subscription for " & Result.Name);
      return Result;
   end Get_Subscription;

   ---------------------------------------------------------------------------------
   function Get_Subscription_Update_Mode (
      Server                     : in     Server_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag
   ) return Ada_Lib.Database.Updater.Update_Mode_Type is
   ---------------------------------------------------------------------------------

      Result                     : Boolean;
      Task_Gateway               : Gateway.Gateway_Type := Gateway.Enter;
      pragma Unreferenced (Task_Gateway); -- declared for sideeffect

      Update_Mode                : Ada_Lib.Database.Updater.Update_Mode_Type;

   begin
      Log_In (Trace);
      Server.Subscriber.Get_Subscription_Update_Mode (
         Name        => Name,
         Index       => Index,
         DBDaemon_Tag=> DBDaemon_Tag,
         Ada_Tag     => Ada_Tag,
         Update_Mode => Update_Mode,
         Result      => Result);
      Log_Here (Trace, " exit result " & Result'img & " update mode " & Update_Mode'img);

      if not Result then
         Log_Exception (Trace);
         raise Failed with "subscription not found";
      end if;
      Log_Out (Trace);
      return Update_Mode;

   exception
      when Tasking_Error =>
         Tasking_Error_Occured;

   end Get_Subscription_Update_Mode;

-- --------------------------------------------------------------------------------- removed 8/30/22
-- function Get_Updater_Task (
--    Server                     : in out Server_Type
-- ) return Ada_Lib.Database.Subscribe.Updater_Task_Access is
-- ---------------------------------------------------------------------------------
--
-- begin
--    return Server.Updater'unchecked_access;
-- end Get_Updater_Task;

   ---------------------------------------------------------------------------------
   function Has_Subscription (
      Server                     : in     Server_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag
   ) return Boolean is
   ---------------------------------------------------------------------------------

      Result                     : Boolean;
      Task_Gateway               : Gateway.Gateway_Type := Gateway.Enter;
      pragma Unreferenced (Task_Gateway); -- declared for sideeffect


   begin
      Log_In (Trace);
      Server.Subscriber.Has_Subscription (Name, Index, DBDaemon_Tag, Ada_Tag, Result);
      Log_Out (Trace, "Reslt " & Result'img);
      return Result;

   exception
      when Tasking_Error =>
         Tasking_Error_Occured;
         return False;

   end Has_Subscription;

   ---------------------------------------------------------------------------------
   function Is_Open (
      Server                     : in     Server_Type
   ) return Boolean is
   ---------------------------------------------------------------------------------

   begin
      return Log_Here (
         Server.Is_Started and then Server.Read_Database.Is_Open and then
            Server.Write_Database.Is_Open,
         Trace_All or Trace_Pre_Post_Conditions,
            "Is_Started " & Server.Is_Started'img &
            " Read_Database.Is_Open " & Server.Read_Database.Is_Open'img &
            " Write_Database.Is_Open " & Server.Write_Database.Is_Open'img);
   end Is_Open;

   ---------------------------------------------------------------------------------
   function Is_Started (
      Server                     : in     Server_Type
   ) return Boolean is
   ---------------------------------------------------------------------------------

   begin
      Log_In (Trace_All);

      if Server.Subscriber_Task_ID = Ada.Task_Identification.Null_Task_Id then
         Log_Out (Trace_All, "false");
         return False;
      else
         declare
            Result               : constant Boolean :=
                                    Ada.Task_Identification.Is_Callable (Server.Subscriber_Task_ID);

         begin
            Log_Out (Trace_All, "task callable " & Result'img);
            return Result;
         end;
      end if;
   end Is_Started;

   ---------------------------------------------------------------------------------
   function Is_Stopped (
      Server                     : in     Server_Type
   ) return Boolean is
   ---------------------------------------------------------------------------------

      Timeout                    : constant Ada_Lib.Time.Time_Type := Ada_Lib.Time.Now + 2.0;

   begin
      Log_In (Trace);
      loop
         declare
            Task_ID_Null         : constant Boolean :=
                                    Server.Subscriber_Task_Id = Ada.Task_Identification.Null_Task_Id;
            Task_Terminated      : constant Boolean := Task_ID_Null or else
                                       Ada.Task_Identification.Is_Terminated (Server.Subscriber_Task_Id);
            Result               : constant Boolean :=
                                    not (Server.Read_Database.Is_Open or else
                                       Server.Write_Database.Is_Open)
                                    and then
                                       Task_Terminated;

         begin
            Log_Here (Trace_All, " Task Is_Terminated " & Task_Terminated'img &
               " task id null " & Task_ID_Null'img &
               " read database " & Server.Read_Database.Is_Open'img &
               " write database " & Server.Write_Database.Is_Open'img &
               " result " & Result'img);
            if Result then
               Log_Out (Trace);
               return True;
            end if;

            exit when Ada_Lib.Time.Now > Timeout;

            delay 0.1;
         end;
      end Loop;

      Log_Out (Trace);
      return False;
   end Is_Stopped;

   ---------------------------------------------------------------------------------
   procedure Iterate (
      Server                     : in out Server_Type;
      Cursor                     : in out Ada_Lib.Database.Subscribe.Subscription_Cursor_Type'Class) is
   ---------------------------------------------------------------------------------

      Task_Gateway               : Gateway.Gateway_Type := Gateway.Enter;
      pragma Unreferenced (Task_Gateway); -- declared for sideeffect

   begin
      Log_In (Trace);
      Server.Subscriber.Iterate (Cursor);
      Log_Out (Trace);

   exception
      when Tasking_Error =>
         Tasking_Error_Occured;

   end Iterate;

   ---------------------------------------------------------------------------------
   procedure Load_Subscriptions (
      Server                     : in out Server_Type;
      Path                       : in     String) is
   ---------------------------------------------------------------------------------

   begin
      Log_In (Trace, Quote (" path", Path));
      Server.Subscriber.Load_Subscriptions (Path);
      Log_Out (Trace);
   end Load_Subscriptions;

   ---------------------------------------------------------------------------------
   function Number_Subscriptions (
      Server                     : in     Server_Type
   ) return Natural is
   ---------------------------------------------------------------------------------

      Result                     : Natural;
      Task_Gateway               : Gateway.Gateway_Type := Gateway.Enter;
      pragma Unreferenced (Task_Gateway); -- declared for sideeffect


   begin
      Server.Subscriber.Number_Subscriptions (Result);
      return Result;
   end Number_Subscriptions;

   ---------------------------------------------------------------------------------
    -- post a string value
   procedure Post (
      Server                     : in out Server_Type;
      Name                    : in     String;
      Index                   : in     Optional_Vector_Index_Type;
      Tag                     : in     String;
      Value                   : in     String;
      Timeout                 : in     Duration := Default_Post_Timeout) is
   ---------------------------------------------------------------------------------

   begin
      Server.Write_Database.Post (Name, Index, Tag, Value, Timeout);

   exception
      when Tasking_Error =>
         Tasking_Error_Occured;

   end Post;

   ---------------------------------------------------------------------------------
    -- post a string value
   procedure Post (
      Server                     : in out Server_Type;
      Line                       : in     String;
      Timeout                    : in     Duration := Default_Post_Timeout) is
   ---------------------------------------------------------------------------------

   begin
      Server.Write_Database.Post (Line, Timeout);

   exception
      when Tasking_Error =>
         Tasking_Error_Occured;

   end Post;

   ---------------------------------------------------------------------------------
    -- post a string value
   procedure Post (
      Server                     : in out Server_Type;
      Name_Value                 : in     Name_Value_Type'class;
      Timeout                    : in     Duration := Default_Post_Timeout) is
   ---------------------------------------------------------------------------------

   begin
      Server.Write_Database.Post (Name_Value, Timeout);

   exception
      when Tasking_Error =>
         Tasking_Error_Occured;

   end Post;

   ---------------------------------------------------------------------------------
   -- read a value
   function Read (
      Server                     : in out Server_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      Tag                        : in     String;
      Timeout                    : in     Duration := Default_Get_Timeout
   ) return Name_Value_Type'class is
   ---------------------------------------------------------------------------------

   begin
      Log_In (Trace, " enter name " & Quote (Name));
      Server.Read_Database.Post (Name, Index, Tag, "", Default_Post_Timeout);
      delay Update_Wait_Time;

      declare
         Result                  : constant Name_Value_Type'class :=
                                    Server.Read_Database.Get (Timeout);
      begin
         Log_Out (Trace, " exit result " & Result.Image);
         return Result;
      end;
   end Read;

   ---------------------------------------------------------------------------------
   procedure Tasking_Error_Occured (
      From                       : in     String := Here) is
   ---------------------------------------------------------------------------------

   begin
      if Server_Tasking_Error then
         raise Subscriber_Time_Out with "no subscripe input for " & Ada_Lib.Strings.Image (Poll_Timeout.Get_Subscribe_Timeout) &
            " caught at " & From;
      else
         raise Tasking_Error with "server task raised exception caught at " & From;
      end if;
   end Tasking_Error_Occured;

   ---------------------------------------------------------------------------------
   -- adds or updates name/value to table and sends to dbdaemon
   -- if already subscribed then don't immediately update table but wait for subscription
   -- if new then set the mode to never
   procedure Set (
      Server                     : in out Server_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag;
      Value                      : in     String) is
   ---------------------------------------------------------------------------------

      Task_Gateway               : Gateway.Gateway_Type := Gateway.Enter;
      pragma Unreferenced (Task_Gateway); -- declared for sideeffect

   begin
      Log_In (Trace);
      Server.Subscriber.Set (Name, Index, DBDaemon_Tag, Ada_Tag, Value);
      Log_Out (Trace);
   end Set;

   ---------------------------------------------------------------------------------
   procedure Set_Socket_Poll_Delay (
      Seconds                    : in     Duration) is
   ---------------------------------------------------------------------------------

   begin
      Socket_Poll_Delay := Seconds;
   end Set_Socket_Poll_Delay;

   ---------------------------------------------------------------------------------
   procedure Send_Subscription_Mode (
      Server                     : in out Server_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Update_Mode                : in     Ada_Lib.Database.Updater.Update_Mode_Type) is
   ---------------------------------------------------------------------------------

      Task_Gateway               : Gateway.Gateway_Type := Gateway.Enter;
      pragma Unreferenced (Task_Gateway); -- declared for sideeffect


   begin
      Log_In (Trace);
      Server.Subscriber.Send_Subscription_Mode (Name, Index, DBDaemon_Tag, Update_Mode);
      Log_Out (Trace);
   end Send_Subscription_Mode;

   ---------------------------------------------------------------------------------
   procedure Set_Subscription_Mode (
      Server                     : in out Server_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag;
      Update_Mode                : in     Ada_Lib.Database.Updater.Update_Mode_Type;
      Timeout                    : in     Duration := Default_Post_Timeout) is
   ---------------------------------------------------------------------------------

      Result                     : Boolean;
      Task_Gateway               : Gateway.Gateway_Type := Gateway.Enter;
      pragma Unreferenced (Task_Gateway); -- declared for sideeffect


   begin
      Log_In (Trace);
      Server.Subscriber.Set_Subscription_Mode (Name, Index, DBDaemon_Tag, Ada_Tag, Update_Mode, Result);
      if not Result then
         Log_Exception (Trace);
         raise Failed with "Could not set subscription mode for" & Quote (Name) & Index'img;
      end if;
      Log_Out (Trace);
   end Set_Subscription_Mode;

-- ---------------------------------------------------------------------------------
-- procedure Set_Subscription_Mode (
--    Server                     : in out Server_Type;
--    Name_Value                 : in     Name_Value_Type;
--    Index                      : in     Optional_Vector_Index_Type;
--    Update_Mode                : in     Ada_Lib.Database.Updater.Update_Mode_Type;
--    Timeout                    : in     Duration := Default_Post_Timeout) is
-- ---------------------------------------------------------------------------------
--
--    Result                     : Boolean;
--
-- begin
--    Log_In (Trace);
--    Server.Subscriber.Set_Subscription_Mode (Name_Value, Index, Update_Mode, Timeout, Result);
--    if not Result then
--          raise Failed with "Could not update subscription for" & Quote (Name_Value.Value);
--    end if;
--    Log_In (Trace, " exit result " & Result'img);
--
-- exception
--    when Tasking_Error =>
--       Tasking_Error_Occured;
--
-- end Set_Subscription_Mode;

   ---------------------------------------------------------------------------------
   procedure Set_Timeout_Mode (
      Server                     : in out Server_Type;
      Mode                       : in      Timeout_Mode_Type;
      Timeout                    : in      Duration := 0.0) is
   ---------------------------------------------------------------------------------

--    Task_Gateway               : Gateway.Gateway_Type := Gateway.Enter;
--    pragma Unreferenced (Task_Gateway); -- declared for sideeffect

   begin
      Poll_Timeout.Set_Mode (Mode, Timeout);
   end Set_Timeout_Mode;

   ---------------------------------------------------------------------------------
   procedure Store_Subscriptions (
      Server                     : in out Server_Type;
      Path                       : in     String) is
   ---------------------------------------------------------------------------------

   begin
      Log_In (Trace, Quote ("Path", Path));
      Server.Subscriber.Store_Subscriptions (Path);
      Log_Out (Trace);
   end Store_Subscriptions;

   ---------------------------------------------------------------------------------
   function Table_Referece (
      Server                     : in out Server_Type
   ) return Ada_Lib.DAtabase.Subscribe.Table_Class_Access is
   ---------------------------------------------------------------------------------

      Result                     : Ada_Lib.DAtabase.Subscribe.Table_Class_Access;
      Task_Gateway               : Gateway.Gateway_Type := Gateway.Enter;
      pragma Unreferenced (Task_Gateway); -- declared for sideeffect


   begin
      Server.Subscriber.Table_Referece (Result);
      return Result;

   exception
      when Tasking_Error =>
         Tasking_Error_Occured;

   end Table_Referece;

   ---------------------------------------------------------------------------------
   function Unsubscribe (
      Server                     : in out Server_Type;
      Remove                     : in     Boolean;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag;
      Timeout                    : in     Duration := Default_Post_Timeout
   ) return Boolean is
   ---------------------------------------------------------------------------------

      Result                     : Boolean;
      Task_Gateway               : Gateway.Gateway_Type := Gateway.Enter;
      pragma Unreferenced (Task_Gateway); -- declared for sideeffect


   begin
      Log_In (Trace);
      Server.Subscriber.Unsubscribe (Remove, Name, Index, DBDaemon_Tag, Ada_Tag, Timeout, Result);
      Log_Out (Trace);
      return Result;

   exception
      when Tasking_Error =>
         Tasking_Error_Occured;

   end Unsubscribe;

   ---------------------------------------------------------------------------------
   protected body Poll_Timeout is

      ------------------------------------------------------------------------------
      function Get_Abort_Time return Ada_Lib.Time.Time_Type is
      ------------------------------------------------------------------------------

      begin
         return Abort_Time;
      end Get_Abort_Time;

      ------------------------------------------------------------------------------
      function Get_Mode return Timeout_Mode_Type is
      ------------------------------------------------------------------------------

      begin
         return Timeout_Mode;
      end Get_Mode;

      ------------------------------------------------------------------------------
      function Get_Subscribe_Timeout return Duration is
      ------------------------------------------------------------------------------

      begin
         return Subscribe_Timeout;
      end Get_Subscribe_Timeout;

      ------------------------------------------------------------------------------
      procedure Set_Mode (
         Mode                    : in     Timeout_Mode_Type;
         Timeout                 : in      Duration) is
      ------------------------------------------------------------------------------

      begin
         Log_In (Trace_All, " current mode " & Timeout_Mode'img &
            " new mode " & Mode'img & " current timeout " & Ada_Lib.Strings.Image (Subscribe_Timeout) &
            " new timeout " & Ada_Lib.Strings.Image (Timeout));
         case Mode is                  -- new mode

            when Active =>
               case Timeout_Mode is    -- current mode

                  when Active =>
                     if Timeout /= 0.0 then   -- use new timeout
                        Subscribe_Timeout := Timeout;
                     end if;
                     Abort_Time := Ada_Lib.Time.Now + Subscribe_Timeout;

                  when Disabled =>
                     Subscribe_Timeout := Timeout;
                     Abort_Time := Ada_Lib.Time.Now + Subscribe_Timeout;
                     Timeout_Mode := Active;

                  when Suspended =>
                     if Timeout /= 0.0 then
                        Subscribe_Timeout := Timeout;
                     end if;

                     Abort_Time := Ada_Lib.Time.Now + Subscribe_Timeout;
                     Timeout_Mode := Active;

               end case;

            when Disabled =>
               case Timeout_Mode is

                  when Disabled =>
                     null;            -- change

                  when Active |
                       Suspended =>
                     Timeout_Mode := Disabled;

               end case;

            when Suspended =>
               case Timeout_Mode is

                  when Disabled =>
                     Log_Exception (Trace_All);
                     raise Failed with "timeout mode can't be set to Suspended when its Disabled";

                  when Active =>
                     Timeout_Mode := Suspended;

                  when Suspended =>
                     null;         -- no change

               end case;

         end case;

         Log_Out (Trace_All);
      end Set_Mode;

--    ------------------------------------------------------------------------------
--    procedure Set_Timeout (
--       Timeout                 : in      Duration) is
--    ------------------------------------------------------------------------------
--
--    begin
--       Subscribe_Timeout := Timeout;
--    end Set_Timeout;

      ------------------------------------------------------------------------------
      procedure Update_Abort_Timoout is
      ------------------------------------------------------------------------------

      begin
         Abort_Time := Ada_Lib.Time.Now + Subscribe_Timeout;
      end Update_Abort_Timoout;

end Poll_Timeout;

   ---------------------------------------------------------------------------------
   task body Subscriber_Task is

--    procedure Send_Mode (
--       Name                    : in     String;
--       Index                   : in     Optional_Vector_Index_Type;
--       DBDaemon_Tag            : in     String;
--       Update_Mode             : in     Ada_Lib.Database.Updater.Update_Mode_Type);

--    Abort_Time                 : Ada_Lib.Time.Time_Type;
      Database                   : Database_Type;
      Running                    : Boolean := False;
      Table                      : Ada_Lib.DAtabase.Subscribe.Table_Class_Access := Null;

--      ---------------------------------------------------------------------------------
--      procedure Delete_By_Name (
--         Name           : in     String;
--         Index          : in     Optional_Vector_Index_Type;
--         DBDaemon_Tag   : in     String;
--         Ada_Tag        : in     Ada.Tags.Tag;
--         Result         :    out Boolean) is
--      ---------------------------------------------------------------------------------
--
--      begin
--         Log_In (Trace_All);
----                      Database.Delete (Name, Index, Timeout);   -- decided not to delete from database 1/9/22
--         Result := Table.Delete (Name, Index, DBDaemon_Tag, Ada_Tag);
--         Send_Mode (Name, Index, DBDaemon_Tag, Ada_Lib.Database.Updater.Never);
--         Log_Out (Trace_All);
--      end Delete_By_Name;
--
--      ----------      ---------------------------------------------------------------------------------
--      procedure Delete_By_Updater (
--         Updater                 : in     Ada_Lib.Database.Subscribe.Updater_Interface_Class_Access;
--         Result                  :    out Boolean) is
--      ---------------------------------------------------------------------------------
--
--      begin
--         Log_In (Trace_All);
--         Result := Table.Delete (Updater);
--         Send_Mode (Updater.Name, Updater.Index, Updater.DBDaemon_Tag, Ada_Lib.Database.Updater.Never);
--         Log_Out (Trace_All);
--      end Delete_By_Updater;

------------------------------------------------------------------
      procedure Reset_Timeout is
      -----------------------------------------------------------------------------

      begin
         Log_In (Trace_All);
         if Poll_Timeout.Get_Mode = Active then
            Poll_Timeout.Update_Abort_Timoout;
         end if;
         Log_Out (Trace_All, "Timeout_Mode " & Poll_Timeout.Get_Mode'img & " Abort_Time " & Ada_Lib.Strings.Image (Poll_Timeout.Get_Abort_Time, True));
      end Reset_Timeout;

      ---------------------------------------------------------------------------------
      procedure Send_Mode (
         Name                    : in     String;
         Index                   : in     Optional_Vector_Index_Type;
         DBDaemon_Tag            : in     String;
         Update_Mode             : in     Ada_Lib.Database.Updater.Update_Mode_Type) is
      ---------------------------------------------------------------------------------

      begin
         Log_In (Trace_All, "enter name '" & Name & "' mode " & Update_Mode'img);

            Database.Post (Name, Index, DBDaemon_Tag, (case Update_Mode is
               when Ada_Lib.Database.Updater.Never => "--unsubscribe",
               when Ada_Lib.Database.Updater.Always => "--subscribe",
               when Ada_Lib.Database.Updater.Unique => "--subscribeoc"));
         Log_Out (Trace_All);

      exception
         when Fault: Failed =>
            Trace_Exception (Fault);
            raise;

      end Send_Mode;
      ---------------------------------------------------------------------------------

   begin
      Log_In (Trace_All);
      Ada_Lib.Trace_Tasks.Start ("subscriber task", Here);
      accept Get_Task_Id (
         Task_Id                    :     out Ada.Task_Identification.Task_Id) do

         Task_Id := Ada.Task_Identification.Current_Task;
         Log_Out (Trace_All);
         return;
      end Get_Task_Id;

      select

         accept Open (
           Subscription_Table       : in     Ada_Lib.Database.Subscribe.Table_Class_Access;
           Host                     : in     String;
           Port                     : in     Port_Type;
           Idle_Timeout             : in     Duration;
           Result                   :    out Boolean) do

            Log_In (Trace_All, Host & " idle timeout " & Ada_Lib.Strings.Image (Idle_Timeout) &
               " Timeout Mode " & Poll_Timeout.Get_Mode'img);

            Table := Subscription_Table;
            if Idle_Timeout > 0.0 then
               Poll_Timeout.Set_Mode (Active, Idle_Timeout);
               Poll_Timeout.Update_Abort_Timoout;
--             Timeout_Mode := Active;
            end if;

--            if Server_Object.Subscriber_Task_ID /= Ada.Task_Identification.Null_Task_Id then
--               Put_Line ("second server task started");
--               Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.No_Error);
--            end if;
--
-- log_here;
--            Server_Object.Subscriber_Task_ID := Ada.Task_Identification.Current_Task;
--            Server_Object_Pointer := Server_Object;
            Result := Database.Open (Host, Port);
         end Open;

         Running := True;
         Server_Tasking_Error := False;

         declare
            Got_Request          : Boolean := False;
            Got_Socket_Response  : Boolean := False;
            No_New_Count         : Natural := 0;

         begin
            while Running loop
               Exception_Recovery: begin
                  Log_Here (Trace_All, " wait for close, subscribe or socket input");
                  Got_Request := True;
                  Got_Socket_Response := True;
                  select
                     ---------------------------------------------------------------------------------
                     accept Add_Subscription (
                        Updater  : in     Ada_Lib.Database.Updater.Updater_Interface_Class_Access) do
                     ---------------------------------------------------------------------------------

                        Table.Add_Subscription (Updater);
                     end Add_Subscription;
                  or
                     ---------------------------------------------------------------------------------
                     accept Call_Callback (
                        Parameter      : in out Callback_Parameter_Type'class) do
                     ---------------------------------------------------------------------------------

                        Log_In (Trace_All);
                        Parameter.Subscriber := Table;
                        Parameter.Do_Callback;
                        Log_Out (Trace_All);
                     end Call_Callback;
                  or
                     ---------------------------------------------------------------------------------
                     accept Close do
                     ---------------------------------------------------------------------------------
                        Log_In (Trace_All, "close ");
                        Database.Close;
                        Log_Here (Trace_All, " subscribe link closed ");
                        Running := False;
                        Reset_Timeout;
                        Log_Out (Trace_All);
                     end Close;
                  or
                     ---------------------------------------------------------------------------------
                     accept Delete (
                        Name           : in     String;
                        Index          : in     Optional_Vector_Index_Type;
                        DBDaemon_Tag   : in     String;
                        Ada_Tag        : in     Ada.Tags.Tag;
                        Result         :    out Boolean) do
                     pragma Unreferenced (Ada_Tag, DBDaemon_Tag, Index, Name, Result);
                     ---------------------------------------------------------------------------------

                        Log_In (Trace_All);
--                        Delete_By_Name (Name, Index, DBDaemon_Tag,Ada_Tag, Result); -- deleted 8/30/22
----                      Database.Delete (Name, Index, Timeout);   -- decided not to delete from database 1/9/22
--                        Result := Table.Delete (Name, Index, DBDaemon_Tag, Ada_Tag);
--                        Send_Mode (Name, Index, DBDaemon_Tag, Ada_Lib.Database.Updater.Never);
                        Reset_Timeout;
                        Log_Out (Trace_All);
                     end Delete;
                  or
                     ---------------------------------------------------------------------------------
                     accept Delete (
                        Updater        : in     Ada_Lib.Database.Updater.Updater_Interface_Class_Access;
                        Result         :    out Boolean) do
                     pragma Unreferenced (Result);
                     ---------------------------------------------------------------------------------

                        Log_In (Trace_All, "Updater address " & Ada_Lib.Strings.image (Updater.all'address));
--                      Database.Delete (Name, Index, Timeout);   -- decided not to delete from database 1/9/22
--                      Delete_By_Updater (Updater, Result); -- deleted
                        Reset_Timeout;
                        Log_Out (Trace_All);
                     end Delete;
                  or
                     ---------------------------------------------------------------------------------
                     accept Delete_All (
                        Unsubscribed_Only : in     Boolean) do
--                      Timeout           : in     Duration) do
                     ---------------------------------------------------------------------------------

                        Log_In (Trace);

--                      if not Unsubscribed_Only then    -- don't want to do this anymore  1/9/22
--                         Database.Delete_All (Timeout);   -- delete from dbdaemon
--                      end if;
                        Table.Delete_All (Unsubscribed_Only);
                        Reset_Timeout;
                        Log_Out (Trace_All);
                     end Delete_All;
                  or
                     accept Delete_All_DBDaemon_Values do
                        Database.Delete_All;
                     end Delete_All_DBDaemon_Values;

                  or
      --             ---------------------------------------------------------------------------------
      --             accept Delete_Row (
      --                Name           : in     String;
      --                Result         :    out Boolean) do
      --             ---------------------------------------------------------------------------------
      --
      --                Table.Delete_Row (Name, Result);
   --                   Reset_Timeout;
      --             end Delete_Row;
      --          or
                     accept Dump do
                        Table.Dump;
                     end Dump;
                  or
                     accept Get_Subscription (
                        Name           : in     String;
                        Index          : in     Optional_Vector_Index_Type;
                        DBDaemon_Tag   : in     String;
                        Ada_Tag        : in     Ada.Tags.Tag;
--                      Action         : in     Ada_Lib.Database.Subscribe.Action_Type; -- removed 8/30/22
                        Updater        :    out Ada_Lib.Database.Updater.Updater_Interface_Class_Access) do

                        Log_In (Trace_All, " enter name '" & Name & "' index " & Index'img);
                        Updater := Table.Get_Subscription (Name, Index, DBDaemon_Tag, Ada_Tag); -- , Action); removed 8/20/22
                        Log_Out (Trace_All);
                     end Get_Subscription;
                  or
                     ---------------------------------------------------------------------------------
                     accept Get_Subscription_Update_Mode (
                        Name                       : in     String;
                        Index                      : in     Optional_Vector_Index_Type;
                        DBDaemon_Tag   : in     String;
                        Ada_Tag        : in     Ada.Tags.Tag;
                        Update_Mode                :    out Ada_Lib.Database.Updater.Update_Mode_Type;
                        Result                     :    out Boolean) do
                     ---------------------------------------------------------------------------------

                        Log_In (Trace_All);
                        Table.Get_Subscription_Update_Mode (Name, Index, DBDaemon_Tag, Ada_Tag,
                           Update_Mode, Result);
                        Poll_Timeout.Update_Abort_Timoout;
                        Log_Out (Trace_All);

                     end Get_Subscription_Update_Mode;
                  or
                     ---------------------------------------------------------------------------------
                     accept Has_Subscription (
                        Name                    : in     String;
                        Index                   : in     Optional_Vector_Index_Type;
                        DBDaemon_Tag            : in     String;
                        Ada_Tag                 : in     Ada.Tags.Tag;
                        Result                  :    out Boolean) do
                     ---------------------------------------------------------------------------------

                        Result := Table.Has_Subscription (Name, Index, DBDaemon_Tag, Ada_Tag);
                        Log_In (Trace_All, "name" & Quote (Name) & Index'img & " result " & Result'img);
                        Reset_Timeout;
                        Log_Out (Trace_All);
                     end Has_Subscription;
                  or
                     ---------------------------------------------------------------------------------
                     accept Iterate (
                        Cursor         : in out Ada_Lib.Database.Subscribe.Subscription_Cursor_Type'Class) do
                     ---------------------------------------------------------------------------------
                        Log_In (Trace_All);
--                      Cursor.Number_Subscriptions := Natural (Table.Length);
                        Table.Iterate (Cursor);
                        Reset_Timeout;
                        Log_Out (Trace_All);
                     end Iterate;
                  or
                     ---------------------------------------------------------------------------------
                     accept Load_Subscriptions (
                        Path                    : in     String) do
                     ---------------------------------------------------------------------------------

                        Log_In (Trace);
                        Table.Load (Path);
                        Log_Out (Trace);
                     end Load_Subscriptions;
                  or
                     ---------------------------------------------------------------------------------
                     accept Number_Subscriptions (
                        Result                  :    out Natural) do
                     ---------------------------------------------------------------------------------

                        Result := Table.Number_Subscriptions;
                     end Number_Subscriptions;
                  or
                     ---------------------------------------------------------------------------------
                     -- updates name/value to table and sends to dbdaemon
                     -- if already subscribed then don't immediately update table but wait for Updater
                     -- if new then set the mode to never
                     accept Set (
                        Name                       : in     String;
                        Index                      : in     Optional_Vector_Index_Type;
                        DBDaemon_Tag               : in     String;
                        Ada_Tag                    : in     Ada.Tags.Tag;
                        Value                      : in     String) do
                     ---------------------------------------------------------------------------------

                        if Table.Set (Name, Index, DBDaemon_Tag, Ada_Tag, Value) then      -- new name in table
                           Database.Post (Name, Index, DBDaemon_Tag, Value, Write_Timeout);
                        end if;
                     end Set;
                  or
                     ---------------------------------------------------------------------------------
                     accept Send_Subscription_Mode (
                        Name                    : in     String;
                        Index                   : in     Optional_Vector_Index_Type;
                        DBDaemon_Tag            : in     String;
                        Update_Mode             : in     Ada_Lib.Database.Updater.Update_Mode_Type) do
                     ---------------------------------------------------------------------------------

                        Log_In (Trace_All);
                        Send_Mode (Name, Index, DBDaemon_Tag, Update_Mode);
                        Reset_Timeout;
                        Log_Out (Trace_All);

                     exception
                        when Fault: Failed =>
                           Trace_Message_Exception (Fault, Who & " exception in Send_Subscription_Mode");
                           Log_Out (Trace_All, " failure exit");

                     end Send_Subscription_Mode;
                  or
                     ---------------------------------------------------------------------------------
                     accept Set_Subscription_Mode (
                        Name                    : in     String;
                        Index                   : in     Optional_Vector_Index_Type;
                        DBDaemon_Tag            : in     String;
                        Ada_Tag                 : in     Ada.Tags.Tag;
                        Update_Mode             : in     Ada_Lib.Database.Updater.Update_Mode_Type;
                        Result                  :    out Boolean) do
                     ---------------------------------------------------------------------------------

                        Log_In (Trace_All, "enter name '" & Name & "' mode " & Update_Mode'img);
                        case Table.Set_Subscription_Mode (Name, Index, DBDaemon_Tag, Ada_Tag, Update_Mode) is

                           when Ada_Lib.Database.No_Change =>
                              Result := True;

                           when Ada_Lib.Database.Update_Failed =>
                              Result := False;

                           when Ada_Lib.Database.Updated =>
                              Result := True;

                        end case;
                        Send_Mode (Name, Index, DBDaemon_Tag, Update_Mode);
                        Reset_Timeout;
                        Log_Out (Trace_All);

                     exception
                        when Fault: Failed =>
                           Trace_Message_Exception (Fault, Who & " exception in Set_Subscription_Mode");
                           Result := False;
                           Log_Out (Trace_All, " failure exit");

                     end Set_Subscription_Mode;
                  or
--                   accept Set_Timeout_Mode (
--                      Mode        : in      Timeout_Mode_Type;
--                      Timeout     : in      Duration) do
--                   ---------------------------------------------------------------------------------
--
--                      Log (Trace_All, Here, Who & " current mode " & Timeout_Mode'img &
--                         " new mode " & Mode'img & " current timeout " & Ada_Lib.Strings.Image (Poll_Timeout.Get_Subscribe_Timeout) &
--                         " new timeout " & Ada_Lib.Strings.Image (Timeout));
--                      case Mode is                  -- new mode
--
--                         when Active =>
--                            case Timeout_Mode is    -- current mode
--
--                               when Active =>
--                                  if Timeout /= 0.0 then   -- use new timeout
--                                     Subscribe_Timeout := Timeout;
--                                  end if;
--                                  Abort_Time := Ada_Lib.Time.Now + Subscribe_Timeout;
--
--                               when Disabled =>
--                                  Subscribe_Timeout := Timeout;
--                                  Abort_Time := Ada_Lib.Time.Now + Subscribe_Timeout;
--                                  Timeout_Mode := Active;
--
--                               when Suspended =>
--                                  if Timeout /= 0.0 then
--                                     Subscribe_Timeout := Timeout;
--                                  end if;
--
--                                  Abort_Time := Ada_Lib.Time.Now + Subscribe_Timeout;
--                                  Timeout_Mode := Active;
--
--                            end case;
--
--                         when Disabled =>
--                            case Timeout_Mode is
--
--                               when Disabled =>
--                                  null;            -- change
--
--                               when Active |
--                                    Suspended =>
--                                  Timeout_Mode := Disabled;
--
--                            end case;
--
--                         when Suspended =>
--                            case Timeout_Mode is
--
--                               when Disabled =>
--                                  raise Failed with "timeout mode can't be set to Suspended when its Disabled";
--
--                               when Active =>
--                                  Timeout_Mode := Suspended;
--
--                               when Suspended =>
--                                  null;         -- no change
--
--                            end case;
--
--                      end case;
--                   end Set_Timeout_Mode;
--                or
                     ---------------------------------------------------------------------------------
                     accept Store_Subscriptions (
                        Path                    : in     String) do
                     ---------------------------------------------------------------------------------

                        Log_In (Trace, Quote ("Path", Path));
                        Table.Store (Path);
                        Log_Out (Trace);
                     end Store_Subscriptions;
                  or
                     ---------------------------------------------------------------------------------
                     accept Unsubscribe (
                        Remove         : in     Boolean;
                        Name           : in     String;
                        Index          : in     Optional_Vector_Index_Type;
                        DBDaemon_Tag   : in     String;
                        Ada_Tag        : in     Ada.Tags.Tag;
                        Timeout        : in     Duration;
                        Result         :    out Boolean) do
                     pragma Unreferenced (Timeout);
                     ---------------------------------------------------------------------------------

                        Log_In (Trace_All, "unsubscribe");
                        Result := Table.Unsubscribe (Remove, Name, Index, DBDaemon_Tag, Ada_Tag);

                        if Result then
                           Send_Mode (Name, Index, DBDaemon_Tag, Ada_Lib.Database.Updater.Never);
                        end if;
                        Poll_Timeout.Update_Abort_Timoout;
                        Log_Out (Trace_All);
                     end Unsubscribe;
                  or
                     ---------------------------------------------------------------------------------
                     accept Table_Referece (
                        Result         :    out Ada_Lib.DAtabase.Subscribe.Table_Class_Access) do
                     ---------------------------------------------------------------------------------

                        Result := Table;
                        Poll_Timeout.Update_Abort_Timoout;
                     end Table_Referece;
                  else
                     Got_Request := False;
                     ---------------------------------------------------------------------------------
                     Log_In (Trace_All, "get input ");
                     begin
                        declare
                           Name_Value        : constant Name_Value_Type'class := Database.Get;    -- don't throw exception when no input

                        begin
                           if Name_Value.Name.Length > 0 then     -- got valid input from DBDaemon
                              declare
                                 Task_Gateway   : Gateway.Gateway_Type := Gateway.Enter;
                                 pragma Unreferenced (Task_Gateway);

                              begin
                                 Log_Here (Trace, " got name_value name: '" & Name_Value.Name.Coerce &
                                    "' tag '" & Name_Value.Tag.Coerce &
                                    "' value '" & Name_Value.Value.Coerce & "'");
                                 Table.Notify (Name_Value);
                                 Poll_Timeout.Update_Abort_Timoout;
                              end;
                           else
                              Log_Here (Trace_All, " no input timeout " &
                                 " timeout mode " & Poll_Timeout.Get_Mode'img & " " &
                                 Ada_Lib.Time.Image (Poll_Timeout.Get_Subscribe_Timeout, Hundreths => True) &
                                 " now " & Ada_Lib.Time.Image (Ada_Lib.Time.Now, Hundreths => True) &
                                 " abort time " & Ada_Lib.Time.Image (Poll_Timeout.Get_Abort_Time, Hundreths => True));

                              if Poll_Timeout.Get_Mode = Active and then Ada_Lib.Time.Now > Poll_Timeout.Get_Abort_Time then
                                 Put_Line ("no subscribed input for " &
                                    Ada_Lib.Time.Image (Poll_Timeout.Get_Subscribe_Timeout) & "seconds. Quiting");
         --                      Server_Tasking_Error := True;
                                 exit;
                              end if;

                              Got_Socket_Response := False;
                              delay Socket_Poll_Delay;
                           end if;
                        end;

                     exception
                        when Fault: others =>
                           Trace_Message_Exception (Fault, Who & " exception doing socket Get");
                           exit;    -- exit task select loop
                     end;
                     Log_Out (Trace_All);
                  end select;

               exception
                  when Fault: Ada_Lib.Database.Subscribe.Duplicate => -- expected
                     Trace_Message_Exception (Trace_All, Fault, Who &
                        " expected exception in Subscriber task accept loop");

                  when Fault: others =>
                     Trace_Message_Exception (Fault, Who &
                        " unexpected exception in Subscriber task accept loop");

                     if Got_Request or Got_Socket_Response then
                        No_New_Count := 0;
                     else
                        No_New_Count := No_New_Count + 1;
                        if No_New_Count > 5 then
                           Put_Line ("repeated exceptions with no new requests No_New_Count" &
                              No_New_Count'img);
                           Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.Exception_Exit);
                        end if;
                     end if;

               end Exception_Recovery;
            end loop;
            Log_Out (Trace);
         end;
      or

         accept Close do
         ---------------------------------------------------------------------------------
            Log_Here (Trace_All);
         end Close;

      end select;

      Log_Out (Trace_All);
--    Server_Object_Pointer.Subscriber_Task_ID := Ada.Task_Identification.Null_Task_Id;
      Ada_Lib.Trace_Tasks.Stop;

   exception
      when Fault: others =>
         Trace_Message_Exception (Fault, Who & " exception in Subscriber task");
         Ada_Lib.Trace_Tasks.Stop;
         Log_Out (Trace_All);

   end Subscriber_Task;

begin
-- Trace := True;
-- Trace_All := True;
   Log_Here (Elaborate or Trace_All);
end Ada_Lib.Database.Server;
