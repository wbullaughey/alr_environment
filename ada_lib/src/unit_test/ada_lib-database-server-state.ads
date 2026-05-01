with Ada_Lib.Strings.Unlimited;-- use Ada_Lib.Strings.Unlimited;
-- with Ada_Lib.Database.Subscription;

package Ada_Lib.Database.Server.State is

   Failed                        : exception;

   type Server_Type is tagged Limited private;
   type Server_Class_Access is access all Server_Type'class;
   type Server_Constant_Class_Access is access constant Server_Type'class;


-- procedure Alert (
--    Server                     : in     Server_Type;
--    Message                    : in     String);

-- procedure Clear_Host (
--    Server                     : in out Server_Type);

   -- allocates Ada_Lib.Database.Server object and opens it
   function Create_Server (
      Server                     : in out Server_Type;
      Subscription_Table         : in     Ada_Lib.Database.Subscribe.Table_Class_Access;
      Host                       : in     String;
      Port                       : in     Ada_Lib.Database.Port_Type;
      Idle_Timeout               : in     Duration := 0.0   -- 0.0 will not timeout
   ) return Boolean
   with Pre => Server.Is_Server_Stopped;

   -- closes Ada_Lib.Database.Server and frees it
   procedure Delete_Server (
      Server                     : in out Server_Type)
   with Pre => Server.Is_Server_Open;

   procedure Do_Callback (
      Server                     : in out Server_Type;
      Parameter                   : in out Ada_Lib.Database.Server.Callback_Parameter_Type'class);

   procedure Free_Server (
      Server                     : in out Server_Type);

   function Get_Host_Name (
      Server                     : in     Server_Type
   ) return String
   with Pre => Server.Is_Host_Known;

   function Get_Port (
      Server                     : in     Server_Type
   ) return Ada_Lib.Database.Port_Type
   with Pre => Server.Is_Host_Known;

   function Get_Server (
      Server                     : in     Server_Type
   ) return Ada_Lib.Database.Server.Server_Access
   with pre => Server.Is_Server_Allocated;

   function Get_Subscription (
      Server                     : in     Server_Type;
      Name                       : in     String;
      Index                      : in     Ada_Lib.Database.Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag
   ) return Ada_Lib.Database.Updater.Updater_Interface_Class_Access
   with pre => Server.Is_Server_Open;

   function Has_Subscription (
      Server                     : in     Server_Type;
      Name                       : in     String;
      Index                      : in     Ada_Lib.Database.Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag
   ) return Boolean
   with pre => Server.Is_Server_Open;

   function Is_Server_Allocated (
      Server                     : in     Server_Type
   ) return Boolean;

   function Is_Server_Open (
      Server                     : in     Server_Type
   ) return Boolean;

   function Is_Server_Started (
      Server                     : in     Server_Type
   ) return Boolean;

   function Is_Server_Stopped (
      Server                     : in     Server_Type
   ) return Boolean;

   function Is_Host_Known (
      Server                     : in     Server_Type
   ) return Boolean;

   -- read a value
   function Read (
      Server                     : in     Server_Type;
      Name                       : in     String;
      Index                      : in     Ada_Lib.Database.Optional_Vector_Index_Type;
      Tag                        : in     String;
      Timeout                    : in     Duration := Ada_Lib.Database.Default_Post_Timeout
   ) return Ada_Lib.Database.Name_Value_Type'class
   with pre => Server.Is_Server_Open;

-- function Server (
--    Server                     : in     Server_Type
-- ) return Ada_Lib.Database.Server.Server_Class_Access;

-- procedure Set_Host (
--    Server                     : in out Server_Type;
--    Host                       : in     String)
--
-- procedure Set_Port (
--    Server                     : in out Server_Type;
--    Port                       : in     Ada_Lib.Database.Port_Type)

-- procedure Set_Server (     use create_server instead
--    Server                     : in out Server_Type;
--    Database                   : in     Ada_Lib.Database.Server.Server_Access);

   procedure Set_Timeout_Mode (
      Server                     : in out Server_Type;
      Mode                       : in      Ada_Lib.Database.Server.Timeout_Mode_Type;
      Timeout                    : in      Duration := 0.0);

   procedure Write (
      Server                     : in     Server_Type;
      Name                       : in     String;
      Index                      : in     Ada_Lib.Database.Optional_Vector_Index_Type;
      Tag                        : in     String;
      Value                      : in     String;
      Timeout                    : in     Duration := Ada_Lib.Database.Default_Post_Timeout)
   with pre => Server.Is_Server_Open and then
               Name'length > 0;

   Debug                            : aliased Boolean := False;

private

   type Server_Type is tagged Limited record
      Host_Name                     : Ada_Lib.Strings.Unlimited.String_Type :=
                                       Ada_Lib.Strings.Unlimited.Coerce ("localhost");
      Host_Port                     : Any_Port_Type := Invalid_Port;
      Server                        : Ada_Lib.Database.Server.Server_Access := Null;
   end record;

end Ada_Lib.Database.Server.State;
