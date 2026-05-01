with Ada_Lib.Database;
--with Ada_Lib.Options.Flags;
with Ada_Lib.Options.Nested;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace;

package Ada_Lib.Options.Database is

   Multiple_Hosts                : exception;
   No_Host                       : exception;

   type Database_Options_Type    is Limited new Ada_Lib.Options.Nested.
                                    Nested_Options_Type with record
      No_DBDaemon                : Boolean := True;
      Remote_Host                : Ada_Lib.Strings.Unlimited.String_Type;   -- host for tests which connect to a remote host
      Port                       : Ada_Lib.Database.Port_Type :=
                                    Ada_Lib.Database.Default_Port;
      Remote_User                : Ada_Lib.Strings.Unlimited.String_Type;
      Remote_DBDaemon_Path       : Ada_Lib.Strings.Unlimited.String_Type;   -- dbdaemon executable program path on remote host or null
      Has_Local_DBDaemon         : Boolean := False;
      Local_DBDaemon_Path        : Ada_Lib.Strings.Unlimited.String_Type;   -- dbdaemon executable program path on local machine or null
   end record;

   type Database_Options_Access is access all Database_Options_Type;
   type Database_Options_Class_Access
                                 is access all Database_Options_Type'class;

   function Has_Database(
      Options                    : in     Database_Options_Type) return Boolean;
-- function Has_Local_Host (
--    Options                    : in     Database_Options_Type) return Boolean;
   function Has_Remote_Host (
      Options                    : in     Database_Options_Type) return Boolean;

   overriding
   function Initialize (
     Options                     : in out Database_Options_Type;
     From                        : in     String := Standard.Ada_Lib.Trace.Here
   ) return Boolean
   with pre    => not Options.Verify_Step (Initialized),
        Post   => Options.Verify_Step (Initialized);

-- overriding
-- procedure Process (     -- process command line options
--   Options                    : in out Database_Options_Type;
--   Iterator                   : in out Ada_Lib.Command_Line_Iterator.
--                                  Abstract_Package.Abstract_Iterator_Type'class);
-- overriding
-- function Set_Options (
--    Options                    : in out Database_Options_Type) return Boolean;

   function Get_Host (
      Options                    : in     Database_Options_Type
   ) return String;

   overriding
   function Process_Option (
      Options                    : in out Database_Options_Type;
      Iterator                   : in out Command_Line_Iterator_Interface'class;
      Option                     : in     Base_Flag_Option_Type'class
   ) return Boolean
   with pre => Options.Verify_Step (Initialized);

   overriding
   procedure Trace_Parse (
      Options              : in out Database_Options_Type;
      Iterator             : in out Command_Line_Iterator_Interface'class);

   function Which_Host (
      Options                    : in     Database_Options_Type
   ) return Ada_Lib.Database.Which_Host_Type;

private

   overriding
   procedure Program_Help (      -- common for all programs that use GNOGA_Options
     Options                    : in      Database_Options_Type;  -- only used for dispatch
     Help_Mode                  : in     Ada_Lib.Options.Help_Mode_Type);

end Ada_Lib.Options.Database;
