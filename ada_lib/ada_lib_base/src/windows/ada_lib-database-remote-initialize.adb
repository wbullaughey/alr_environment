with Ada_Lib.Time;

separate (Ada_Lib.Database.Connection)

   ---------------------------------------------------------------
    procedure Initialize (
      Remote                     : in out Remote_Database_Type) is
   ---------------------------------------------------------------

      use type Ada_Lib.Time.Time_Type;

      Parameters                 : constant String := "--nodaemon --port" & Remote.Port'img;

    begin
      Log (Debug, Here, Who & Quote (" host", Remote.Host);
      if Remote.Host = Null then    -- not configured
         return;
      end if;

      if not Ada_Lib.OS.Run.Non_Blocking_Spawn (Remote.Host.all, Program, Remote.User.all,
            Parameters, Remote.Process_ID'access) then
         raise Failed with "could not spawn '" & Remote.Host.all & "' for user " & Remote.User.all;
      end if;

      declare
         Timeout                 : constant Ada_Lib.Time.Time_Type := Ada_Lib.Time.Now + 2.0;

      begin
         while Ada_Lib.Time.Now < Timeout loop
            declare
               Database          : Ada_Lib.Database.Database_Type;

            begin
               Database.Open (Remote.Host.all, Remote.Port);
               Remote.Running := True;
               return;

            exception
               when Ada_Lib.Database.Failed =>
                  delay 0.1;
            end;
         end loop;

         Log (Here, "timeout waiting to connect to dbdaemon");
         Remote.Running := False;
      end;
   end Initialize;


