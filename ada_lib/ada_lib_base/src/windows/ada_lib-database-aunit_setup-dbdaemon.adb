with Ada.Text_IO;use Ada.Text_IO;
with Ada_Lib.OS.Environment;
with Ada_Lib.Time;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with GNAT.OS_Lib;

package body Ada_Lib.Database.AUnit_Setup.DBDaemon is

   Log_File                      : constant String := "c:\temp\aunit_run_remote_output.txt";
   use type Ada_Lib.Time.Time_Type;
   use type GNAT.OS_Lib.Process_Id;

   PLink_Path         : constant String := "plink.exe";
-- PLink_Path         : constant String := "c:\Program Files\PuTTY\plink.exe";
   Timeout                       : constant Duration := 10.0;   -- time to wait to make sure plink starts dbdaemon
   User_Name                     : constant String := Ada_Lib.OS.Environment.Get ("USERNAME");

   ---------------------------------------------------------------------------
   procedure Kill (
      DBDaemon_Host              : in     String;
      DBDaemon_ID                : in out GNAT.OS_Lib.Process_Id) is
   ---------------------------------------------------------------------------

      Argument_List              : constant GNAT.OS_Lib.Argument_List_Access :=
                                    GNAT.OS_Lib.Argument_String_To_List (
                                       User_Name & "@" & DBDaemon_Host & " killall -9 dbdaemon");
      Success                    : Boolean := True;

   begin
      if DBDaemon_ID /= GNAT.OS_Lib.Invalid_Pid then
         GNAT.OS_Lib.Spawn (PLink_Path, Argument_List.all, Success);

         if not Success then
            raise Ada_Lib.Unit_Test.Setup.Failed with "could not kill dbdaemon";
         end if;

         DBDaemon_ID := GNAT.OS_Lib.Invalid_Pid;
      end if;
   end Kill;

   ---------------------------------------------------------------------------
   function Start (
      DBDaemon_Host              : in     String;
      DBDaemon_Path              : in     String;
      DBDaemon_Port              : in     Positive
   ) return GNAT.OS_Lib.Process_Id is
   ---------------------------------------------------------------------------

      Argument_List              : constant GNAT.OS_Lib.Argument_List_Access :=
                                    GNAT.OS_Lib.Argument_String_To_List (
                                       User_Name & "@" & DBDaemon_Host & " " & DBDaemon_Path &
                                       " --port" & DBDaemon_Port'img);
      DBDaemon_ID                : GNAT.OS_Lib.Process_Id := GNAT.OS_Lib.Invalid_Pid;
      Timeout_Time               : constant Ada_Lib.Time.Time_Type := Ada_Lib.Time.Now + Timeout;

   begin
      if Trace then
         Log (Here, Who & " enter DBDaemon_Path '" & DBDaemon_Path & "' user '" & User_Name &
            "' Argument_List '");

         for index in Argument_List.all'range loop
            Ada.Text_IO.Put (Argument_List.all (Index).all);
            Put (',');
         end loop;
         Ada.Text_IO.New_Line;
      end if;

      DBDaemon_ID := GNAT.OS_Lib.Non_Blocking_Spawn (PLink_Path, Argument_List.all, Log_File, True);
      -- process id of process running plink

      if DBDaemon_ID = GNAT.OS_Lib.Invalid_Pid then
         raise Ada_Lib.Unit_Test.Setup.Failed with "could not run plink to start dbdaemon";
      end if;

      while Ada_Lib.Time.Now < Timeout_Time loop
         declare
            Pid                  : GNAT.OS_Lib.Process_Id;
            Success              : Boolean;

         begin
            GNAT.OS_Lib.Non_Blocking_Wait_Process (PID, Success);

            Log (Trace, Here, Who & " PID" & GNAT.OS_Lib.Pid_To_Integer (PID)'img);

            if PID /= GNAT.OS_Lib.Invalid_Pid then -- plink quit without starting dbdaemon
               raise Ada_Lib.Unit_Test.Setup.Failed with
                  "plink failed start dbdaemon. Success = " & Success'img;
            end if;

            delay 0.3;
         end;
      end loop;

      Log (Trace, Here, Who & " dbdaemon started");
      return DBDaemon_ID;
   end Start;

end Ada_Lib.Database.AUnit_Setup.DBDaemon;

