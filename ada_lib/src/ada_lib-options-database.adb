with Ada.Exceptions;
--with Ada_Lib.Command_Line_Iterator;
with Ada_Lib.Help;
with Ada_Lib.Options.Create;
--with Ada_Lib.Options.Nested;
with Ada_Lib.Options.Runstring;
with Ada_Lib.Trace; use Ada_Lib.Trace;

--pragma Elaborate_All (Ada_Lib.Command_Line_Iterator);

package body Ada_Lib.Options.Database is

   Remote_Daemon_Option          : constant Character := 'Q';
   Options_With_Parameters       : aliased constant
                                    Flag_List_Type :=
                                       Create.Create_Multiple (
                                          "LpRu", Unmodified_flag) &
                                       Create.Create_One (
                                          Remote_Daemon_Option, Help.Modifier);
   Options_Without_Parameters    : aliased constant
                                    Flag_List_Type :=
                                       Create.Create_One (
                                          'l', Unmodified_flag);

   Debug                         : Boolean renames Ada_Lib_Database.Trace_All;

   -------------------------------------------------------------------------
   procedure Cant_Be_Local (
      Options                    : in     Database_Options_Type) is
   -------------------------------------------------------------------------

   begin
      if    (  Options.Has_Local_DBDaemon or else
               Options.Local_DBDaemon_Path.Length > 0) and then
            not Ada_Lib.Options.Ada_Lib_Environment.Help_Test then
         raise Multiple_Hosts with "from " & Here;
      end if;
   end Cant_Be_Local;

   -------------------------------------------------------------------------
   procedure Cant_Be_Remote (
      Options                    : in     Database_Options_Type) is
   -------------------------------------------------------------------------

   begin
      if    (  Options.Remote_Host.Length > 0 or else
               Options.Remote_User.Length > 0 or else
               Options.Remote_DBDaemon_Path.Length > 0) and then
            not Ada_Lib.Options.Ada_Lib_Environment.Help_Test then
         raise No_Host with "Application does not suport a remote host, " &
            "remote user or a remote dbdaemon path from " & Here;
      end if;
   end Cant_Be_Remote;

   ---------------------------------------------------------------
   function Get_Host (
      Options                    : in     Database_Options_Type
   ) return String is
   ---------------------------------------------------------------

   begin
      if Options.No_DBDaemon then
         raise No_Host;
      end if;

      if Options.Remote_Host.Length > 0 then
         if Options.Has_Local_DBDaemon then
            raise Multiple_Hosts;
         end if;

         return Options.Remote_Host.Coerce;
      else
         return Ada_Lib.Database.Local_Host_Name;
      end if;
   end Get_Host;

   ----------------------------------------------------------------------------
   function Has_Database (
      Options                    : in     Database_Options_Type) return Boolean is
   ----------------------------------------------------------------------------

   begin
      return Options.Has_Local_DBDaemon or else
             Options.Remote_DBDaemon_Path.Length > 0;
   end Has_Database;

   ----------------------------------------------------------------------------
   function Has_Remote_Host (Options : in    Database_Options_Type) return Boolean is
   ----------------------------------------------------------------------------

      Result                     : constant Boolean := Options.Remote_Host.Length > 0;

   begin
      Log (Debug, Here, Who & " result " & Result'img);
      return Result;
   end Has_Remote_Host;

   ----------------------------------------------------------------------------
   overriding
   function Initialize (
     Options                     : in out Database_Options_Type;
     From                        : in     String := Standard.Ada_Lib.Trace.Here
   ) return Boolean is
-- pragma Unreferenced (Options);
   ----------------------------------------------------------------------------

   begin
      Log_In (Debug or Trace_Options);
      Ada_Lib.Options.Runstring.Options.Register (Ada_Lib.Options.Runstring.With_Parameters,
         Options_With_Parameters);
      Ada_Lib.Options.Runstring.Options.Register (Ada_Lib.Options.Runstring.Without_Parameters,
         Options_Without_Parameters);
      return Log_Out (Nested.Nested_Options_Type (Options).Initialize,
         Debug or Trace_Options);
   end Initialize;

   ----------------------------------------------------------------
   overriding
   function Process_Option (
      Options                    : in out Database_Options_Type;
      Iterator                   : in out Command_Line_Iterator_Interface'class;
      Option                     : in     Base_Flag_Option_Type'class
   ) return Boolean is
   ----------------------------------------------------------------

--    use Ada_Lib.Options;

   begin
      Log_In (Trace_Options or Debug, Option.Image);
      if Ada_Lib.Options.Has_Option (Option, Options_With_Parameters,
            Options_Without_Parameters) then
         case Option.Kind is

         when Plain =>
            case Option.Option is

            when 'l' =>
               Options.Cant_Be_Remote;
               Options.Has_Local_DBDaemon := True;
               Options.No_DBDaemon := False;

            when 'L' =>
               Options.Cant_Be_Remote;
               declare
                  Parameter   : constant String := Iterator.Get_Parameter;

               begin
                  Options.Local_DBDaemon_Path.Set (Parameter);
                  Log_Here (Trace_Options or Debug, "local dbdaemon path '" &
                     Parameter & "'");
               end;

            when 'p' =>
               Options.Port := Ada_Lib.Database.Port_Type (
                  Iterator.Get_Integer);

            when 'r' =>
               Options.Cant_Be_Local;

               declare
                  Parameter   : constant String := Iterator.Get_Parameter;

               begin
                  Options.Remote_Host.Set (Parameter);
                  Options.No_DBDaemon := False;
                  Log_Here (Trace_Options or Debug, "Remote host '" &
                     Parameter & "'");
               end;

            when 'R' =>
               Options.Cant_Be_Local;

               declare
                  Parameter   : constant String := Iterator.Get_Parameter;

               begin
                  Options.Remote_DBDaemon_Path.Set (Parameter);
                  Log_Here (Trace_Options or Debug, "Remote dbdaemon path '" &
                     Parameter & "'");
               end;

            when 'u' =>
               Options.Cant_Be_Local;
               declare
                  Parameter   : constant String := Iterator.Get_Parameter;

               begin
                  Options.Remote_User.Set (Parameter);
                  Log_Here (Trace_Options or Debug, "Remote user '" &
                     Parameter & "'");
               end;

            when Others =>
               Log_Exception (Debug or Trace_Options);
               raise Failed with "Has_Option incorrectly passed " & Option.Image;

            end case;

         when Modified | Nil_Option =>
            Log_Exception (Debug or Trace_Options);
            raise Failed with "Has_Option incorrectly passed " & Option.Image;

         end case;
         return Log_Out (True, Trace_Options or Debug, Option.Image & " handled");
      else
         return Log_Out (False, Trace_Options or Debug, "not handled" &
            Option.Image);
      end if;

   exception
      when Fault: Multiple_Hosts =>
         Trace_Exception (Debug or Trace_Options, Fault, Here);
         Options.Bad_Option (Option, "Multiple hosts raised " &
            Ada.Exceptions.Exception_Message (Fault));  -- aborts
         return False;

      when Fault: No_Host =>
         Trace_Exception (Debug or Trace_Options, Fault, Here);
         Options.Bad_Option (Option,
            Ada.Exceptions.Exception_Message (Fault));  -- aborts
         return False;

      when Fault: others =>
         Trace_Exception (Fault);
         Options.Bad_Option (Option, Ada.Exceptions.Exception_Name (Fault) &
            " " & Ada.Exceptions.Exception_Message (Fault));
            -- aborts
         return False;

   end Process_Option;

   ---------------------------------------------------------------
   overriding
   procedure Program_Help (      -- common for all programs that use GNOGA_Options
     Options                    : in      Database_Options_Type;  -- only used for dispatch - root of derivation tree
     Help_Mode                  : in     Ada_Lib.Options.Help_Mode_Type) is
   pragma Unreferenced (Options);
   ---------------------------------------------------------------

      Component                  : constant String := "Ada_Lib.Options.Database";

   begin
      Log_In (Debug or Trace_Options, "help mode " & Help_Mode'img);
      case Help_Mode is

      when Ada_Lib.Options.Program_Mode =>
         Ada_Lib.Help.Create_Option ('l', "", "local dbdaemon.", Component, Ada_Lib.Help.Unmodified_Flag);
         Ada_Lib.Help.Create_Option ('L', "path", "local dbdaemon path.", Component, Ada_Lib.Help.Unmodified_Flag);
         Ada_Lib.Help.Create_Option ('p', "port number", "remote DBDaemon port number", Component, Ada_Lib.Help.Unmodified_Flag);
--       Ada_Lib.Help.Create_Option ('P', "browser port", Component, Ada_Lib.Help.Unmodified_Flag);
         Ada_Lib.Help.Create_Option (Remote_Daemon_Option, "dbdaemon", "remote dbdaemon.",
            Component, Ada_Lib.Help.Modifier);
         Ada_Lib.Help.Create_Option ('R', "path", "remote dbdaemon path.", Component, Ada_Lib.Help.Unmodified_Flag);
         Ada_Lib.Help.Create_Option ('u', "user", "remote user.", Component, Ada_Lib.Help.Unmodified_Flag);

      when Ada_Lib.Options.Trace_Mode =>
         Null;

      end case;
      Log_Out (Debug or Trace_Options);
   end Program_Help;

-- ---------------------------------------------------------------
-- overriding
-- function Set_Options (
--    Options                    : in out Database_Options_Type
-- ) return Boolean is
-- pragma Unreferenced (Options);
-- ---------------------------------------------------------------
--
-- begin
--    Log_Here (Debug or Trace_Options);
--    return False;            -- root of derivation tree
-- end Set_Options;

   ----------------------------------------------------------------
   overriding
   procedure Trace_Parse (
      Options           : in out Database_Options_Type;
      Iterator          : in out Command_Line_Iterator_Interface'class) is
   pragma Unreferenced (Options, Iterator);
   ----------------------------------------------------------------

   begin
      Not_Implemented;
   end Trace_Parse;

   ----------------------------------------------------------------
   function Which_Host (
      Options                    : in     Database_Options_Type
   ) return Ada_Lib.Database.Which_Host_Type is
   ----------------------------------------------------------------

   begin
      if Options.No_DBDaemon then
         Log (Debug or Trace_Options, Here, Who & " no host");
         return Ada_Lib.Database.No_Host;
      elsif Options.Has_Local_DBDaemon then
         if    Options.Remote_Host.Length > 0 or else
               Options.Remote_DBDaemon_Path.Length > 0 then
            raise Failed with
               "local dbdaemon selected but remote host or dbdaemon path specified";
         end if;
         Log (Debug or Trace_Options, Here, Who & " local host");
         return Ada_Lib.Database.Local;
      else
         if    Options.Remote_Host.Length = 0 or else
               Options.Remote_DBDaemon_Path.Length = 0 or else
               Options.Remote_User.Length = 0 then
            raise Failed with
               "no local dbdaemon specified and remote host " &
               "not specified or remote dbdaemon path specified";
         end if;
         Log (Debug or Trace_Options, Here, Who & " remote host");
         return Ada_Lib.Database.Remote;
      end if;

   end Which_Host;

begin
--debug := True;
--Trace_Options := True;
   Log_Here (Debug or Trace_Options or Elaborate);
end Ada_Lib.Options.Database;

