--with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Trace; use Ada_Lib.Trace;

package body Ada_Lib.Database.Server.State is


-- ---------------------------------------------------------------
-- procedure Alert (
--    Server                     : in     Server_Type;
--    Message                    : in     String) is
-- ---------------------------------------------------------------
--
-- begin
--    Server.GUI.Alert (Message);
-- end Alert;

-- ---------------------------------------------------------------
-- procedure Clear_Host (
--    Server                     : in out Server_Type) is
-- ---------------------------------------------------------------
--
-- begin
--    Server.Host_Name := Ada_Lib.Strings.Unlimited.Coerce ("");
--    Server.Host_Port := GNAT.Sockets.No_Port;
-- end Clear_Host;

-- ---------------------------------------------------------------
-- procedure Clear_All_Windows (
--    Server                     : in out Server_Type) is
-- ---------------------------------------------------------------
--
-- begin
--    Server.Windows.Clear_All;
-- end Clear_All_Windows;
--
-- ---------------------------------------------------------------
-- procedure Clear_Window (
--    Name                       : in     String) is
-- ---------------------------------------------------------------
--
-- begin
--    if Has_Window (Name) then
--       if Debug    then
--          Log_Here ("" & Quote (Name) &
--             " address " & Image (Get_Window (Name).all'address));
--       end if;
--       Server.Windows.Delete_Window (Name);
--    else
--       Log (Debug, Here, Who & " " & Quote (Name) & " not registered");
--    end if;
-- end Clear_Window;
--
-- ---------------------------------------------------------------
-- procedure Create_Top is
-- ---------------------------------------------------------------
--
-- begin
--    Log_In (Debug);
--    Server.GUI := new Widgets.Top.Top_Type;
--    Log (Debug, Here, Who & " exit");
-- end Create_Top;
--
-- ---------------------------------------------------------------
-- procedure Create_Main_Window (
--    Start_Client               : in     Boolean;
--    Verbose                    : in     Boolean) is
-- ---------------------------------------------------------------
--
-- begin
--    Log (Debug, Here, Who & " enter Main_Window_Created " & Server.Main_Window_Created'img &
--       " Start_Client " & Start_Client'img);
--    if not Server.Main_Window_Created then
--       DB_View.Main_Window.Create (
--          DB_View.Controller.Initial_Connect_Handler'access, Start_Client, Verbose);
--      Server.Main_Window_Created := True;
--    end if;
--    Log (Debug, Here, Who & " exit");
-- end Create_Main_Window;
--
   ---------------------------------------------------------------
   function Create_Server (
      Server                     : in out Server_Type;
      Subscription_Table         : in     Ada_Lib.Database.Subscribe.Table_Class_Access;
      Host                       : in     String;
      Port                       : in     Ada_Lib.Database.Port_Type;
      Idle_Timeout               : in     Duration := 0.0
   ) return Boolean is
   ---------------------------------------------------------------

   begin
      Log_In (Debug);
      if Server.Server /= Null then
         raise Failed with "server already allocated";
      end if;

      Server.Server := Ada_Lib.Database.Server.Allocate_Server (Subscription_Table, Host, Port, Idle_Timeout);
      Server.Host_Name.Set (Host);
      Server.Host_Port := Port;

--    declare
--       Timeout                 : constant Ada_Lib.Time.Time_Type := Ada_Lib.Time.Now + 0.5;
--
--    begin
--       while Ada_Lib.Time.Now < Timeout loop
--          if Server.Is_Server_Started then
--             declare
--                Result         : constant Boolean :=
--                                  Server.Server.Open (Server.Host_Name.Coerce, Server.Host_Port, Idle_Timeout);
--
--             begin
--                Log (Debug, Here, Who & " exit result " & Result'img);
--                return Result;
--             end;
--          end if;
--       end loop;
--
--       raise Failed with "timeout waiting for server to start";
--    end;
      return True;
   end Create_Server;

   ---------------------------------------------------------------
   procedure Delete_Server (
      Server                     : in out Server_Type) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug);
--    Server.Data_Table.Subscriber_Stop;
--    Free (Server.Data_Table);
--    Server.Created := False;

--    if Server.Host.Is_Connected then
--       Server.Host.Get_DB_Daemon.Close;
--    end if;

--    if Server.GUI /= Null then
--       Delete_GUI;
--    end if;

--    if Server.Host /=Null then
--       Free (Server.Host);
--    end if;
--
--    Destroy_Main_Window;

--    Widgets.Drop_Down.Stop;

--    if Server.Focus_Manager /= Null then
--       Server.Focus_Manager.Quit;
--       Widgets.Drop_Down.Free_Task (Widgets.Drop_Down.Focus_Manager_Access (Server.Focus_Manager));
--    end if;
--
      Server.Server.Close;
      Ada_Lib.Database.Server.Free (Server.Server);

      Log (Debug, Here, Who & " exit");

   exception
      when Fault: others =>
          Trace_Message_Exception (Fault, Who, Here);

   end Delete_Server;

--   ---------------------------------------------------------------
--   procedure Delete_GUI is
--   ---------------------------------------------------------------
--
--   begin
--      Log_In (Debug);
--      Free (Server.GUI);
----    Server.Stopped := True;
--      Log (Debug, Here, Who & " exit");
--
--   exception
--      when Fault: others =>
--          Trace_Message_Exception (Fault, Who, Here);
--
--   end Delete_GUI;
--
--   ---------------------------------------------------------------
--   procedure Delete_Window (
--      Name                       : in     String) is
--   ---------------------------------------------------------------
--
--   begin
--      Server.Windows.Delete_Window (Name);
--   end Delete_Window;
--
--   ---------------------------------------------------------------
--   procedure Destroy_Main_Window is
--   ---------------------------------------------------------------
--
--   begin
--      if Server.Main_Window_Created then
--         DB_View.Main_Window.Destroy;
--         Server.Main_Window_Created := False;
--      end if;
--   end Destroy_Main_Window;

   ---------------------------------------------------------------
   procedure Do_Callback (
      Server                     : in out Server_Type;
      Parameter                   : in out Ada_Lib.Database.Server.Callback_Parameter_Type'class) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug);
      Server.Server.Call_Callback (Parameter);
      Log (Debug, Here, Who & " exit");
   end Do_Callback;

-- ---------------------------------------------------------------
-- function Do_Reload return Boolean is
-- ---------------------------------------------------------------
--
-- begin
--    return Server.Reload;
-- end Do_Reload;

-- ---------------------------------------------------------------
-- function Focus_Manager
-- return access Widgets.Drop_Down.Focus_Manager_Task is
-- ---------------------------------------------------------------
--
-- begin
--    return Server.Focus_Manager;
-- end Focus_Manager;

   ---------------------------------------------------------------
   procedure Free_Server (
      Server                     : in out Server_Type) is
   ---------------------------------------------------------------

   begin
      Ada_Lib.Database.Server.Free (Server.Server);
   end Free_Server;

   ---------------------------------------------------------------
   function Get_Host_Name (
      Server                     : in     Server_Type
   ) return String is
   ---------------------------------------------------------------

   begin
      return Ada_Lib.Strings.Unlimited.Coerce (Server.Host_Name);
   end Get_Host_Name;

   ---------------------------------------------------------------
   function Get_Port (
      Server                     : in     Server_Type
   ) return Ada_Lib.Database.Port_Type is
   ---------------------------------------------------------------

   begin
      return Server.Host_Port;
   end Get_Port;

-- ---------------------------------------------------------------
-- function Get_Top return access Widgets.Top.Top_Type'class is
-- ---------------------------------------------------------------
--
-- begin
--    return Server.GUI;
-- end Get_Top;
--
-- --------------------------------------------------------------------------------
-- function Get_Main_Window return Gnoga.Gui.Window.Pointer_To_Window_Class is
-- --------------------------------------------------------------------------------
--
-- begin
--    return Server.GUI.Top_Window;
-- end Get_Main_Window;

   --------------------------------------------------------------------------------
   function Get_Server (
      Server                     : in     Server_Type
   ) return Ada_Lib.Database.Server.Server_Access is
   ---------------------------------------------------------------

   begin
      Log_In (Debug, "name '" & Ada_Lib.Strings.Unlimited.Coerce (Server.Host_Name) &
         "' created " & Server.Is_Server_Open'img);
      return Server.Server;
   end Get_Server;

   ----------------------------------------------
   function Get_Subscription (
      Server                     : in     Server_Type;
      Name                       : in     String;
      Index                      : in     Ada_Lib.Database.Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag
   ) return Ada_Lib.Database.Updater.Updater_Interface_Class_Access is
   ----------------------------------------------

   begin
      return Server.Server.Get_Subscription (Name, Index, DBDaemon_Tag, Ada_Tag);
   end Get_Subscription;

-- ----------------------------------------------
-- function Get_Window (
--    Server                     : in     Server_Type;
--    Name                       : in     String
-- ) return Gnoga.Gui.Base.Pointer_To_Base_Class is
-- ----------------------------------------------
--
-- begin
--    if not Has_Window (Name) then
--       raise Failed with " window " & Quote (Name) & " does not exist";
--    end if;
--
--    declare
--       Result                  : constant Gnoga.Gui.Base.Pointer_To_Base_Class :=
--                                  Server.Windows.Get_Window (Name);
--    begin
--       if Result = Null then
--          raise Failed with "Get_Window returned Null address for " & Quote (Name);
--       end if;
--
--       Log (Debug, Here, Who & " name " & Quote (Name) & " address " & Image (Result.all'address));
--       return Result;
--    end;
-- end Get_Window;

--   ----------------------------------------------
--   function Has_Row (
--      Name                       : in     String
--   ) return Boolean is
--   ----------------------------------------------
--
--      type Parameter_Type is new Ada_Lib.Database.Server.Callback_Parameter_Type with null record;
--      Result                     : Boolean;
--
--      procedure Do_Callback (
--         Parameter                 : in out Parameter_Type) is
--
--      begin
--         Result := Parameter.Subscriber.Has_Row (Name);
--      end Do_Callback;
--
--      Parameter                   : Parameter_Type;
--
--   begin
--      Ada_Lib.Database.Server.Call_Callback (Server.Server.all, Parameter);
----    return Server.Server.all.Do_Callback (Parameter);
--      return Result;
--   end Has_Row;

   ----------------------------------------------
   function Has_Subscription (
      Server                     : in     Server_Type;
      Name                       : in     String;
      Index                      : in     Ada_Lib.Database.Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag
   ) return Boolean is
   ----------------------------------------------

   begin
      return Server.Server.Has_Subscription (Name, Index, DBDaemon_Tag, Ada_Tag);
   end Has_Subscription;

-- ----------------------------------------------
-- function Has_Window (
--    Server                     : in     Server_Type;
--    Name                       : in     String
-- ) return Boolean is
-- ----------------------------------------------
--
-- begin
--    return Server.Windows.Has_Window (Name);
-- end Has_Window;

-- ---------------------------------------------------------------
-- function Have_Focus_Manager
-- return Boolean is
-- ---------------------------------------------------------------
--
-- begin
--
--    if Server.Focus_Manager = Null then
--       Server.Focus_Manager := new Widgets.Drop_Down.Focus_Manager_Task;
--    end if;
--
--    return True;
-- end Have_Focus_Manager;

-- ----------------------------------------------
-- function IS_GUI_Created return Boolean is
-- ---------------------------------------------------------------
--
-- begin
--    return Server.GUI /= Null;
-- end IS_GUI_Created;

-- ---------------------------------------------------------------
-- function Is_GUI_Stopped return Boolean is
-- ---------------------------------------------------------------
--
-- begin
--    return Server.Stopped;
-- end Is_GUI_Stopped;
--

   ---------------------------------------------------------------
   function Is_Server_Allocated (
      Server                     : in     Server_Type
   ) return Boolean is
   ---------------------------------------------------------------

      Result : constant Boolean := Server.Server /= Null;

   begin
      return Log_Here (Result, Debug or Trace_Pre_Post_Conditions or not Result,
         "server not allocated");
   end Is_Server_Allocated;

   ---------------------------------------------------------------
   function Is_Server_Open (
      Server                     : in     Server_Type
   ) return Boolean is
   ---------------------------------------------------------------

      Result   : constant Boolean := Server.Server /= Null and then
                                       Server.Server.Is_Open;
   begin
      if Debug then
         if Server.Server = Null then
            Log_Here ("server not allocated");
         elsif not Server.Server.Is_Open then
            Log_Here ("server not opened");
         end if;
      end if;
      return Log_Here (Result,
         Debug or Trace_Pre_Post_Conditions or not Result,
         "Server " & (if Server.Server = Null then
            "null"
         else
            "set") &
         "server" & (if Server.Server.Is_Open then
            ""
         else
            " not") & " open");
   end Is_Server_Open;

   ---------------------------------------------------------------
   function Is_Server_Started (
      Server                     : in     Server_Type
   ) return Boolean is
   ---------------------------------------------------------------

   begin
      Log_In (Debug);
      return Server.Server.Is_Started;
   end Is_Server_Started;

   ---------------------------------------------------------------
   function Is_Server_Stopped (
      Server                     : in     Server_Type
   ) return Boolean is
   ---------------------------------------------------------------

      Result   : constant Boolean := Server.Server = Null or else
                                       Server.Server.Is_Stopped;
   begin
      return Log_Here (Result,
         Debug or Trace_Pre_Post_Conditions or not Result,
         "server " & (if Server.Server = Null then
            "null"
         else
            "set") &
         " Is_Stopped " & Server.Server.Is_Stopped'img);
   end Is_Server_Stopped;


-- ---------------------------------------------------------------
-- function Is_GUI_Initialized return Boolean is
-- ---------------------------------------------------------------
--
-- begin
--    return Server.GUI /= Null and then
--           Server.GUI.Is_Initialized;
-- end Is_GUI_Initialized;

-- ---------------------------------------------------------------
-- function Is_Top_Open return Boolean is
-- ---------------------------------------------------------------
--
-- begin
--    return Server.GUI /= Null and then
--           Server.GUI.Is_Open;
-- end Is_Top_Open;

   ---------------------------------------------------------------
   function Is_Host_Known (
      Server                     : in     Server_Type
   ) return Boolean is
   ---------------------------------------------------------------

      Result   : constant Boolean := Ada_Lib.Strings.Unlimited.length (
                                       Server.Host_Name) > 0;
   begin
      return Log_Here (Result,
         Debug or Trace_Pre_Post_Conditions or not Result,
         Ada_Lib.Strings.Unlimited.Quote ("Host Name", Server.Host_Name));
   end Is_Host_Known;

--   ---------------------------------------------------------------
--   procedure Populate_GUI is
--   ---------------------------------------------------------------
--
--   begin
-- null;
-- pragma assert (false, "Populate GUI not implemented " & here) ;
--   end Populate_GUI;

   ---------------------------------------------------------------
   -- read a value
   function Read (
      Server                     : in     Server_Type;
      Name                       : in     String;
      Index                      : in     Ada_Lib.Database.Optional_Vector_Index_Type;
      Tag                        : in     String;
      Timeout                    : in     Duration := Ada_Lib.Database.Default_Post_Timeout
   ) return Ada_Lib.Database.Name_Value_Type'class is
   ---------------------------------------------------------------

   begin
      return Server.Server.Read (Name, Index, Tag, Timeout);
   end read;

-- ---------------------------------------------------------------
-- procedure Register_Window (
--    Name                       : in     String;
--    Window                     : in     Gnoga.Gui.Base.Pointer_To_Base_Class) is
-- ---------------------------------------------------------------
--
-- begin
--    Log (DB_View.Debug, Here, Who & " register " & Quote (Name) &
--       " address " & Image (Window.all'address));
--    Server.Windows.Register_Window (Name, Window);
-- end Register_Window;

-- ---------------------------------------------------------------
-- function Server (
--    Server                     : in     Server_Type
-- ) return Ada_Lib.Database.Server.Server_Class_Access is
-- ---------------------------------------------------------------
--
-- begin
--    return Server.Server;
-- end Server;

-- ---------------------------------------------------------------
-- procedure Set_Host (
--    Server                     : in out Server_Type;
--    Host                       : in     String) is
-- ---------------------------------------------------------------
--
-- begin
--    Server.Host_Name := Ada_Lib.Strings.Unlimited.Coerce (Host);
-- end Set_Host;
--
-- ---------------------------------------------------------------
-- procedure Set_Port (
--    Server                     : in out Server_Type;
--    Port               : in     Ada_Lib.Database.Port_Type) is
-- ---------------------------------------------------------------
--
-- begin
--    Server.Host_Port := Port;
-- end Set_Port;

-- ---------------------------------------------------------------
-- procedure Set_GUI (
--    GUI                           : in     Widgets.Top.Top_Class_Access) is
-- ---------------------------------------------------------------
--
-- begin
--    Server.GUI := GUI;
-- end Set_GUI;
--
-- ---------------------------------------------------------------
-- procedure Set_Server (
--    Server                     : in out Server_Type;
--    Database                   : in     Ada_Lib.Database.Server.Server_Access) is
-- ---------------------------------------------------------------
--
-- begin
--    Server.Server := Database;
-- end Set_Server;

   ---------------------------------------------------------------
   procedure Set_Timeout_Mode (
      Server                     : in out Server_Type;
      Mode                       : in      Ada_Lib.Database.Server.Timeout_Mode_Type;
      Timeout                    : in      Duration := 0.0) is
   ---------------------------------------------------------------

   begin
      Server.Server.Set_Timeout_Mode (Mode, Timeout);
   end Set_Timeout_Mode;

-- ---------------------------------------------------------------
-- procedure Set_Table (
--    Table                      : not null access Data.Table.Table_Type'class) is
-- ---------------------------------------------------------------
--
-- begin
--    Server.Get_Data_Table : Table;
-- end Set_Table;

-- ---------------------------------------------------------------
-- procedure Set_Subscription_Mode (
--    Server                     : in out Server_Type;
--    Name                       : in     String;
--    Value                      : in     String;
--    Index                      : in     Ada_Lib.Database.Optional_Vector_Index_Type :=
--                                           Ada_Lib.Database.Whole_Value_Index) is
-- ---------------------------------------------------------------
--
-- begin
--    Server.Get_Subscription (Name, Index).Set (Ada_Lib.Database.Create (Name, Value));
-- end Set_Subscription_Mode;

-- ---------------------------------------------------------------
-- procedure Wait_For_Window (
--    Name                       : in      String) is
-- ---------------------------------------------------------------
--
--    Timeout_Duration           : constant Duration := 10.0;
--    Timeout_Time               : constant Ada_Lib.Time.Time_Type := Ada_Lib.Time.Now + Timeout_Duration;
--
-- begin
--    Log (Debug, Here, Who & " wait for " & Quote (Name) & " timeout " & From_Start (Timeout_Time, True));
--    while Ada_Lib.Time.Now < Timeout_Time loop
--       delay 0.1;      -- always wait at least this much to let window complete initialization
--       if Has_Window (Name) then
--          Log (Debug, Here, Who & " window pointer set");
--          return;
--       end if;
--    end loop;
--
--    Log (Debug, Here, Who & " timeout waiting for main window");
--    raise Failed with "Timeout after " & Timeout_Duration'img & " waiting for " & Name & " to be set";
-- end Wait_For_Window;

   ---------------------------------------------------------------
   procedure Write (
      Server                     : in     Server_Type;
      Name                       : in      String;
      Index                      : in     Ada_Lib.Database.Optional_Vector_Index_Type;
      Tag                        : in     String;
      Value                      : in      String;
      Timeout                    : in     Duration := Ada_Lib.Database.Default_Post_Timeout) is
   ---------------------------------------------------------------

   begin
      Server.Server.Post (Name, Index, Tag, Value, Timeout);
   end Write;

-- ---------------------------------------------------------------
-- protected body Protect_Windows_Type is
--
--    ---------------------------------------------------------------
--    procedure Clear_All is
--    ---------------------------------------------------------------
--
--    begin
--       Log_In (Debug);
--       for Cursor in Windows.Iterate loop
--          Put_Line (Registry_Package.Key (Cursor));
--       end loop;
--       Windows.Clear;
--       Log (Debug, Here, Who & " exit");
--    end Clear_All;
--
--    ---------------------------------------------------------------
--    procedure Delete_Window (
--       Name                       : in     String) is
--    ---------------------------------------------------------------
--
--    begin
--       Windows.Delete (Name);
--    end Delete_Window;
--
--    ---------------------------------------------------------------
--    function Get_Window (
--       Name                       : in     String
--    ) return Gnoga.Gui.Base.Pointer_To_Base_Class is
--    ---------------------------------------------------------------
--
--    begin
--       return Windows.Element (Name);
--    end Get_Window;
--
--    ---------------------------------------------------------------
--    function Has_Window (
--       Name                       : in     String
--    ) return Boolean is
--    ---------------------------------------------------------------
--
--    begin
--       return Windows.Contains (Name);
--    end Has_Window;
--
--    ---------------------------------------------------------------
--    procedure Register_Window (
--       Name                       : in     String;
--       Window                     : in     Gnoga.Gui.Base.Pointer_To_Base_Class) is
--    ---------------------------------------------------------------
--
--    begin
--       Log (Debug, Here, Who & " enter Name " & Quote (Name));
--       Windows.Insert (Name, Window);
--
--    exception
--       when Fault: Constraint_Error =>
--          Trace_Message_Exception (Fault, "could not add " & Quote (Name));
--          raise Failed with "could not add " & Quote (Name);
--
--    end Register_Window;
--
-- end Protect_Windows_Type;

end Ada_Lib.Database.Server.State;

