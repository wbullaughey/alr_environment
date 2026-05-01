with Ada.Tags;
with Ada.Task_Identification;
with Ada_Lib.DAtabase.Subscribe;
with Ada_Lib.Database.Updater;
-- with Ada_Lib.Database.Subscription;
with Ada_Lib.Trace_Tasks;
-- with Widgets.DB_Table;

pragma Elaborate (Ada_Lib.Trace_Tasks);

package Ada_Lib.Database.Server is

   Subscriber_Time_Out           : exception;

   use type Ada_Lib.Database.Updater.Updater_Interface_Class_Access;

   type Callback_Parameter_Type is abstract tagged record
      Subscriber                : Ada_Lib.Database.Subscribe.Table_Class_Access;
   end record;

   procedure Do_Callback (
      Parameter                 : in out Callback_Parameter_Type) is abstract;

   type Server_Type is tagged limited private;
   type Server_Access is access all Server_Type;
   type Server_Class_Access is access all Server_Type'class;
   type Subscriber_Task;

   procedure Add_Subscription (
      Server                     : in out Server_Type;
      Updater                    : in     Ada_Lib.Database.Updater.Updater_Interface_Class_Access)
   with pre => Is_Open (Server);

   function Allocate_Server (
      Subscription_Table         : in     Ada_Lib.Database.Subscribe.Table_Class_Access;
      Host_Name                  : in     String;
      Port                       : in     Port_Type;
      Idle_Timeout               : in     Duration := 0.0
   ) return Server_Access;

   procedure Call_Callback (
      Server                    : in     Server_Type;
      Parameter                 : in out Callback_Parameter_Type'class);

   type Timeout_Mode_Type is (Active, Disabled, Suspended);

   procedure Close (
      Server                     : in out Server_Type);

   procedure Delete_All_DBDaemon_Values (
      Server                     : in out Server_Type);

   procedure Delete_All_Subscriptions (
      Server                     : in out Server_Type;
      Unsubscribed_Only          : in     Boolean := False;
      Timeout                    : in     Duration := Default_Post_Timeout)
   with pre => Is_Open (Server);

-- procedure Delete_Row (
--    Server                     : in out Server_Type;
--    Name                       : in     String);

   function Delete_Subscription (
      Server                     : in out Server_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag;
      Timeout                    : in     Duration := Default_Post_Timeout
   ) return Boolean
   with pre => Is_Open (Server);

   function Delete_Subscription (
      Server                     : in out Server_Type;
      Updater                    : in     Ada_Lib.Database.Updater.Updater_Interface_Class_Access
   ) return Boolean
   with pre => Is_Open (Server);

   procedure Dump (
      Server                     : in     Server_Type)
   with pre => Server.Is_Open;

   procedure Flush_Input (
      Server                     : in out Server_Type)
   with pre => Is_Open (Server);

   procedure Free (
      Server                     : in out Server_Access);

   function Get (
      Server                     : in out Server_Type;
      Timeout                    : in     Duration := Default_Get_Timeout
   ) return String
   with pre => Is_Open (Server);

   function Get (
      Server                     : in out Server_Type;
      Timeout                    : in     Duration := Default_Get_Timeout
   ) return Name_Value_Class_Type
   with pre => Is_Open (Server);

   function Get_Subscriber (
      Server                     : in out Server_Type
   ) return access Subscriber_Task;

-- function Get_Number_Subscriptions (
--    Server                     : in     Server_Type
-- ) return Natural;

   function Get_Subscription (
      Server                     : in out Server_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag
   ) return Ada_Lib.Database.Updater.Updater_Interface_Class_Access
   with post => Get_Subscription'Result /= Null;

   function Get_Subscription_Update_Mode (
      Server                     : in     Server_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag
   ) return Ada_Lib.Database.Updater.Update_Mode_Type;

   function Has_Subscription (
      Server                     : in     Server_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag
   ) return Boolean;

   function Is_Open (
      Server                     : in     Server_Type
   ) return Boolean;

   function Is_Started(
      Server                     : in     Server_Type
   ) return Boolean;

   function Is_Stopped (
      Server                     : in     Server_Type
   ) return Boolean;

   procedure Iterate (
      Server                     : in out Server_Type;
      Cursor                     : in out Ada_Lib.Database.Subscribe.Subscription_Cursor_Type'Class);

   procedure Load_Subscriptions (
      Server                     : in out Server_Type;
      Path                       : in     String);

   function Number_Subscriptions (
      Server                     : in     Server_Type
   ) return Natural
   with pre => Is_Open (Server);

-- function Open (
--    Server                     : in out Server_Type;
--    Host_Name                  : in     String;
--    Port                       : in     Port_Type;
--    Idle_Timeout               : in     Duration := 0.0
--  ) return Boolean

-- procedure Kill (
--    Server                     : in out Server_Type);
--
    procedure Post (
        Server                   : in out Server_Type;
        Line                    : in     String;
        Timeout                 : in     Duration := Default_Post_Timeout)
    with pre => Is_Open (Server);

    -- post a string value
    procedure Post (
        Server                   : in out Server_Type;
        Name                     : in     String;
        Index                    : in     Optional_Vector_Index_Type;
        Tag                      : in     String;
        Value                    : in     String;
        Timeout                  : in     Duration := Default_Post_Timeout)
    with pre => Is_Open (Server);

    procedure Post (
        Server                   : in out Server_Type;
        Name_Value               : in     Name_Value_Type'class;
        Timeout                  : in     Duration := Default_Post_Timeout)
    with pre => Is_Open (Server);

   -- read a value
   function Read (
      Server                     : in out Server_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      Tag                        : in     String;
      Timeout                    : in     Duration := Default_Get_Timeout
   ) return Name_Value_Type'class
   with pre => Is_Open (Server) and then
               Name'length > 0;

   -- adds or updates name/value to table and sends to dbdaemon
   -- if already subscribed then don't immediately update table but wait for subscription
   -- if new then set the mode to never
   procedure Set (
      Server                     : in out Server_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag;
      Value                      : in     String);

   procedure Set_Socket_Poll_Delay (
      Seconds                    : in     Duration);

   procedure Send_Subscription_Mode (
      Server                     : in out Server_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Update_Mode                : in     Ada_Lib.Database.Updater.Update_Mode_Type);

   -- subscription must already exist
   procedure Set_Subscription_Mode (
      Server                     : in out Server_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag;
      Update_Mode                : in     Ada_Lib.Database.Updater.Update_Mode_Type;
      Timeout                    : in     Duration := Default_Post_Timeout);

   procedure Set_Timeout_Mode (
      Server                     : in out Server_Type;
      Mode                       : in      Timeout_Mode_Type;
      Timeout                    : in      Duration := 0.0);

   procedure Store_Subscriptions (
      Server                     : in out Server_Type;
      Path                       : in     String);

-- -- with base Subscription_Type
-- function Subscribe (
--    Server                     : in out Server_Type;
--    Name                       : in     String;
--    Index                      : in     Optional_Vector_Index_Type;
--    Tag                        : in     String;
--    Value                      : in     String;
--    Update_Mode                : in     Ada_Lib.Database.Updater.Update_Mode_Type := Always;
--    Timeout                    : in     Duration := Default_Post_Timeout
-- ) return Boolean

-- -- with derived Subscription_Type
-- function Subscribe_With (
--    Server                     : in out Server_Type;
--    Subscription               : in     Ada_Lib.Database.Updater.Updater_Interface_Class_Access;
--    Name                       : in     String;
--    Index                      : in     Optional_Vector_Index_Type;
--    Tag                        : in     String;
--    Value                      : in     String;
--    Update_Mode                : in     Ada_Lib.Database.Updater.Update_Mode_Type := Always;
--    Timeout                    : in     Duration := Default_Post_Timeout
-- ) return Boolean

   function Table_Referece (
      Server                     : in out Server_Type
   ) return Ada_Lib.DAtabase.Subscribe.Table_Class_Access;

   function Unsubscribe (
      Server                     : in out Server_Type;
      Remove                     : in     Boolean;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag;
      Timeout                    : in     Duration := Default_Post_Timeout
   ) return Boolean
   with pre => Is_Open (Server);

-- function Update (
--    Server                     : in out Server_Type;
--    Cursor                     : in out Ada_Lib.DAtabase.Subscribe.Subscription_Cursor_Type'Class;
--    Name                       : in     String;
--    Index                      : in     Optional_Vector_Index_Type
-- ) return Boolean

   task type Subscriber_Task is

      entry Add_Subscription (
         Updater                 : in     Ada_Lib.Database.Updater.Updater_Interface_Class_Access);

      entry Call_Callback (
         Parameter               : in out Callback_Parameter_Type'class);

      entry Close;

      entry Delete (
         Updater                 : in     Ada_Lib.Database.Updater.Updater_Interface_Class_Access;
         Result                  :    out Boolean);

      entry Delete (
         Name                    : in     String;
         Index                   : in     Optional_Vector_Index_Type;
         DBDaemon_Tag            : in     String;
         Ada_Tag                 : in     Ada.Tags.Tag;
         Result                  :    out Boolean);

      entry Delete_All (
         Unsubscribed_Only       : in     Boolean);
--       Timeout                 : in     Duration);

      entry Delete_All_DBDaemon_Values;

      entry Dump;

      entry Get_Subscription (
         Name                    : in     String;
         Index                   : in     Optional_Vector_Index_Type;
         DBDaemon_Tag            : in     String;
         Ada_Tag                 : in     Ada.Tags.Tag;
         Updater                 :    out Ada_Lib.Database.Updater.Updater_Interface_Class_Access);

      entry Get_Subscription_Update_Mode (
         Name                    : in     String;
         Index                   : in     Optional_Vector_Index_Type;
         DBDaemon_Tag            : in     String;
         Ada_Tag                 : in     Ada.Tags.Tag;
         Update_Mode             :    out Ada_Lib.Database.Updater.Update_Mode_Type;
         Result                  :    out Boolean);

      entry Get_Task_Id (
         Task_Id                    :     out Ada.Task_Identification.Task_Id);

      entry Has_Subscription (
         Name                    : in     String;
         Index                   : in     Optional_Vector_Index_Type;
         DBDaemon_Tag            : in     String;
         Ada_Tag                 : in     Ada.Tags.Tag;
         Result                  :   out Boolean);

      entry Iterate (
         Cursor                  : in out Ada_Lib.Database.Subscribe.Subscription_Cursor_Type'Class);

      entry Load_Subscriptions (
         Path                    : in     String);

      entry Number_Subscriptions (
         Result                  :    out Natural);

      entry Open (
         Subscription_Table      : in     Ada_Lib.Database.Subscribe.Table_Class_Access;
         Host                    : in     String;
         Port                    : in     Port_Type;
         Idle_Timeout            : in     Duration;
--       Server_Object           : in     Server_Access;
         Result                  :    out Boolean);

      -- updates name/value to table and sends to dbdaemon
      -- if already subscribed then don't immediately update table but wait for subscription
      -- if new then set the mode to never
      entry Set (
         Name                    : in     String;
         Index                   : in     Optional_Vector_Index_Type;
         DBDaemon_Tag            : in     String;
         Ada_Tag                 : in     Ada.Tags.Tag;
         Value                   : in     String);

      entry Send_Subscription_Mode (
         Name                    : in     String;
         Index                   : in     Optional_Vector_Index_Type;
         DBDaemon_Tag            : in     String;
         Update_Mode             : in     Ada_Lib.Database.Updater.Update_Mode_Type);

      entry Set_Subscription_Mode (
         Name                    : in     String;
         Index                   : in     Optional_Vector_Index_Type;
         DBDaemon_Tag            : in     String;
         Ada_Tag                 : in     Ada.Tags.Tag;
         Update_Mode             : in     Ada_Lib.Database.Updater.Update_Mode_Type;
         Result                  :    out Boolean);

--    entry Set_Timeout_Mode (
--       Mode                    : in      Timeout_Mode_Type;
--       Timeout                 : in      Duration);
--
      entry Store_Subscriptions (
         Path                    : in     String);

--    entry Subscribe (
--       Subscription            : in     Ada_Lib.Database.Updater.Updater_Interface_Class_Access;
--       Name                    : in     String;
--       Index                   : in     Optional_Vector_Index_Type;
--       Tag                     : in     String;
--       Value                   : in     String;
--       Update_Mode             : in     Ada_Lib.Database.Updater.Update_Mode_Type;
--       Timeout                 : in     Duration;
--       Result                  :    out Boolean);

      entry Table_Referece (
         Result                  :    out Ada_Lib.DAtabase.Subscribe.Table_Class_Access);

      entry Unsubscribe (
         Remove                  : in     Boolean;
         Name                    : in     String;
         Index                   : in     Optional_Vector_Index_Type;
         DBDaemon_Tag            : in     String;
         Ada_Tag                 : in     Ada.Tags.Tag;
         Timeout                 : in     Duration;
         Result                  :    out Boolean);

--    entry Update (
--       Name                    : in     String;
--       Index                   : in     Optional_Vector_Index_Type;
--       Cursor                  : in out Ada_Lib.DAtabase.Subscribe.Subscription_Cursor_Type'Class;
--       Result                  :    out Boolean);

   end Subscriber_Task;

private
   package Gateway is new Ada_Lib.Trace_Tasks.Gateway; -- debug tool to detect reentrency to task

   type Server_Type is tagged limited record
      Read_Database              : Ada_Lib.Database.Database_Type;
      Subscriber                 : aliased Subscriber_Task;
      Subscriber_Task_ID         : Ada.Task_Identification.Task_Id := Ada.Task_Identification.Null_Task_Id;
      Write_Database             : Ada_Lib.Database.Database_Type;
   end record;

   Socket_Poll_Delay             : Duration := 0.1;

end Ada_Lib.Database.Server;
