with Ada_Lib.Strings.Unlimited;-- use Ada_Lib.Strings.Unlimited;
with GNAT.OS_Lib;

package Ada_Lib.Database.Connection is

-- use type Ada_Lib.Strings.Unlimited.String_Type;

   type Abstract_Database_Type is abstract new Database_Type with private;

   type Abstract_Database_Class_Access
                                 is access all Abstract_Database_Type'class;
   function Is_Active (
      Remote                     : in     Abstract_Database_Type
   ) return Boolean;

   procedure Initialize (
      Database                    : in out Abstract_Database_Type;
      Host                       : in     String;
      Port                       : in     Port_Type;
      User                       : in     String;
      DBDaemon_Path              : in     Ada_Lib.Strings.Unlimited.String_Type) is abstract;

   type Local_Database_Type is new Abstract_Database_Type with private;

   overriding
   procedure Initialize (
      Local                      : in out Local_Database_Type;
      Host                       : in     String;
      Port                       : in     Port_Type;
      User                       : in     String;
      DBDaemon_Path              : in     Ada_Lib.Strings.Unlimited.String_Type)
   with pre => Host = "" and then User = "";

   overriding
   procedure Finalize (
      Remote                     : in out Local_Database_Type);

-- procedure Initialize (
--    Remote                     : in out Local_Database_Type);

   type Remote_Database_Type is new Abstract_Database_Type with private;

   overriding
   procedure Initialize (
      Remote                     : in out Remote_Database_Type;
      Host                       : in     String;
      Port                       : in     Port_Type;
      User                       : in     String;
      DBDaemon_Path              : in     Ada_Lib.Strings.Unlimited.String_Type)
   with pre => Host /= "" and then User /= "" and then DBDaemon_Path.Length /= 0;

   overriding
   procedure Finalize (
      Remote                     : in out Remote_Database_Type);

-- procedure Initialize (
--    Remote                     : in out Remote_Database_Type);

   Debug                         : aliased Boolean := False;

private

   type Abstract_Database_Type is abstract new Database_Type with record
      DBDaemon_Path              : Ada_Lib.Strings.Unlimited.String_Type;
      Port                       : Any_Port_Type := Invalid_Port;
      Running                    : Boolean := False;
   end record;

   type Local_Database_Type is new Abstract_Database_Type with record
      Process_ID                 : aliased GNAT.OS_Lib.Process_Id := GNAT.OS_Lib.Invalid_Pid;
      Start                      : Boolean := False;
   end record;

   type Remote_Database_Type is new Abstract_Database_Type with record
      Host                       : Ada_Lib.Strings.Unlimited.String_Type;
      User                       : Ada_Lib.Strings.Unlimited.String_Type;
   end record;

end Ada_Lib.Database.Connection;
