with Ada_Lib.OS.Run;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
--with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Time;
with Ada_Lib.Trace; use Ada_Lib.Trace;

-- pragma Elaborate (Ada_Lib.OS);

package body Ada_Lib.Database.Connection is

   use type Ada_Lib.Time.Time_Type;
   use type GNAT.OS_Lib.Process_Id;

   ---------------------------------------------------------------
   overriding
   procedure Finalize (
      Remote                     : in out Local_Database_Type) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug, "enter local database start " & Remote.Start'img &
         " kill process id: " & GNAT.OS_Lib.Pid_To_Integer (Remote.Process_ID)'img);
      if Remote.Start then
         if Remote.Process_ID /= GNAT.OS_Lib.Invalid_Pid  then
            Ada_Lib.OS.Run.Kill_All ("dbdaemon");
         end if;
      end if;
      Log_Out (Debug) ;
   end Finalize;

   ---------------------------------------------------------------
   overriding
   procedure Finalize (
      Remote                     : in out Remote_Database_Type) is
   ---------------------------------------------------------------

      Parameters                 : constant String := "-9 dbdaemon";

   begin
      Log_In (Debug);
      if    Remote.Host.Length > 0 and then
            Remote.User.Length > 0 then
         if not Ada_Lib.OS.Run.Non_Blocking_Spawn (Remote.Host.Coerce, "killall",
               Remote.User.Coerce, Parameters) then
            raise Failed with "could not spawn killall";
         end if;
      end if;
      Log_Out (Debug) ;
   end Finalize;

   ---------------------------------------------------------------
   overriding
   procedure Initialize (
      Local                      : in out Local_Database_Type;
      Host                       : in     String;
      Port                       : in     Port_Type;
      User                       : in     String;
      DBDaemon_Path              : in     Ada_Lib.Strings.Unlimited.String_Type) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug, "port" & Port'img & Quote (" DBDaemon_Path", DBDaemon_Path));
      Local.Start := DBDaemon_Path.Length > 0;
      Local.Port := Port;
      Local.DBDaemon_Path := DBDaemon_Path;

      if Local.Start then
         declare
           Parameters                 : constant String := "--port" & Local.Port'img;

         begin
            Log_Here (Debug, Quote (" Local Database Path:", Local.DBDaemon_Path.Coerce) &
               Quote (" Parameters ", Parameters) &
               Quote (" local host name", Local_Host_Name) & " port" & Local.Port'img);

            if not Ada_Lib.OS.Run.Non_Blocking_Spawn (Local.DBDaemon_Path.Coerce, Parameters,
                  Local.Process_ID'access) then
               Log_Exception (Debug);
               raise Failed with "could not spawn '" & Local.DBDaemon_Path.Coerce;
            end if;

            delay 0.2;     -- let it have time to create the socket
            Log_Here (Debug, "process id: " & GNAT.OS_Lib.Pid_To_Integer (Local.Process_ID)'img);
         end;
      end if;

      declare
        Timeout                 : constant Ada_Lib.Time.Time_Type := Ada_Lib.Time.Now + 2.0;

      begin
         while Ada_Lib.Time.Now < Timeout loop
            declare
               Connection          : Ada_Lib.Database.Database_Type;

            begin
               if    Local.Open (Local_Host_Name, Local.Port) and then
                     Connection.Open (Local_Host_Name, Local.Port) then  -- don't try Database until know it will work
                 Local.Running := True;
                 Log_Out (Debug, "local database " & Ada_Lib.Strings.Image (Local'address) & " opened");
                 return;
               else
                  Log_Exception (Debug);
                 raise Failed with "could not open '" & Local_Host_Name & "' for port" & Local.Port'img;
               end if;

            exception
               when Fault: Ada_Lib.Database.Failed =>
                  Trace_Exception (Debug,Fault);
                  delay 0.1;
            end;
         end loop;

         Log_Exception (Debug);
         raise Failed with "timeout waiting to connect to dbdaemon";
      end;
   end Initialize;

--   ---------------------------------------------------------------
--   procedure Initialize (
--      Database                   : in out Remote_Database_Type;
--      Host                       : Ada_Lib.Strings.Unlimited.String_Type;
--      Port                       : Port_Type;
--      User                       : Ada_Lib.Strings.Unlimited.String_Type;
--      DBDaemon_Path              : Ada_Lib.Strings.Unlimited.String_Type) is
--   ---------------------------------------------------------------
--
--   begin
--      Log_In (Debug);
----    Database.DBDaemon_Path := DBDaemon_Path;
----    Database.Host := Host;
----    Database.Port := Port;
----    Database.User := User;
--      Log_Out (Debug);
--   end Initialize;

-- ---------------------------------------------------------------
-- procedure Initialize (
--    Remote                     : in out Local_Database_Type) is
-- ---------------------------------------------------------------
--
-- begin
--    log (here, who);
--   declare
--      Parameters                 : constant String := "--port" & Remote.Port'img;
--
--   begin
-- Log_Here ("port " & Remote.Port'img);
--      if not Remote.Start then
--         Log (Debug, Here, Who & " No local database");
--         return;        -- not configured
--      end if;
--
--      Log (Debug, Here, Who & Quote (" Local Database Path:", Remote.DBDaemon_Path.Coerce) &
--         Quote (" Parameters ", Parameters) &
--         Quote (" local host name", Local_Host_Name) & " port" & Remote.Port'img);
--
--      if not Ada_Lib.OS.Run.Non_Blocking_Spawn (Remote.DBDaemon_Path.Coerce, Parameters, Remote.Process_ID'access) then
--         raise Failed with "could not spawn '" & Remote.DBDaemon_Path.Coerce;
--      end if;
--
--      Log (Debug, Here, Who & " process id: " & GNAT.OS_Lib.Pid_To_Integer (Remote.Process_ID)'img);
--      declare
--         Timeout                 : constant Ada_Lib.Time.Time_Type := Ada_Lib.Time.Now + 2.0;
--
--      begin
--         while Ada_Lib.Time.Now < Timeout loop
--            declare
--               Database          : Ada_Lib.Database.Database_Type;
--
--            begin
--               if    Database.Open (Local_Host_Name, Remote.Port) and
--                     Remote.Open (Local_Host_Name, Remote.Port) then  -- don't try Remote until know it will work
--                  Remote.Running := True;
--                  Log (Debug, Here, Who & " local database " & Ada_Lib.Strings.Image (Remote'address) & " opened");
--                  return;
--               else
--                  raise Failed with "could not open '" & Local_Host_Name & "' for port" & Remote.Port'img;
--               end if;
--
--            exception
--               when Ada_Lib.Database.Failed =>
--                  delay 0.1;
--            end;
--         end loop;
--
--         raise Failed with "timeout waiting to connect to dbdaemon";
--      end;
-- end;
--
-- exception
--    when Fault: others =>
--       Trace_Message_Exception (Fault, "could not open local database");
--       Ada_Lib.OS.Immediate_Halt(-1);
--
-- end Initialize;

 ---------------------------------------------------------------
 overriding
 procedure Initialize (
      Remote                     : in out Remote_Database_Type;
      Host                       : in     String;
      Port                       : in     Port_Type;
      User                       : in     String;
      DBDaemon_Path              : in     Ada_Lib.Strings.Unlimited.String_Type) is
 ---------------------------------------------------------------

      Parameters                 : constant String := "--port" & Port'img;
      Process_ID                 : aliased GNAT.OS_Lib.Process_Id;

   begin
    Log (Debug, Here, Who & Quote ("Remote Database Path:", DBDaemon_Path));

    if    Host'Length = 0 or else
          DBDaemon_Path.Length = 0 then
       Log (Debug, Here, Who & " No remote database");
       return;      -- not configured
    end if;

    if User'Length = 0 then
       raise Failed with "no user specified for remote host";
    end if;

    if DBDaemon_Path.Length = 0 then
       raise Failed with "no path for dbdaemon for remote host";
    end if;

    declare

     begin
       if not Ada_Lib.OS.Run.Non_Blocking_Spawn (Host, DBDaemon_Path.Coerce, User,
             Parameters, Process_ID'access) then
          raise Failed with "could not spawn '" & Host & "' for user " & User;
       end if;

       declare
          Timeout                 : constant Ada_Lib.Time.Time_Type := Ada_Lib.Time.Now + 2.0;

       begin
          while Ada_Lib.Time.Now < Timeout loop
             declare
                Database          : Ada_Lib.Database.Database_Type;

             begin
                if    Database.Open (Host, Port) and then
                      Remote.Open (Host, Port) then
                   Remote.Running := True;
                   return;
                else
                   raise Failed with "could not open '" & Host & "' port" & Port'img;
                end if;

             exception
                when Fault: Ada_Lib.Database.Failed =>
                   if Debug then
                      Trace_Message_Exception (Fault, " open failed in retry loop");
                   end if;
                   delay 0.1;
             end;
          end loop;
          raise Failed with "timeout waiting to connect to dbdaemon";
       end;
    end;

 exception
    when Fault: others =>
       Trace_Message_Exception (Fault, "could not open remote database");
       Log (Debug, Here, Who & "kill remote");
       Ada_Lib.OS.Run.Kill_Remote (Process_ID, True);
--     Ada_Lib.OS.Immediate_Halt(-1);

 end Initialize;

   ---------------------------------------------------------------
   function Is_Active (
      Remote                     : in     Abstract_Database_Type
   ) return Boolean is
   ---------------------------------------------------------------

   begin
-- Log_Here ("isactive");
      return Remote.Running;
   end Is_Active;

begin
   Log_Here (Elaborate);
--Debug := True;
end Ada_Lib.Database.Connection;
