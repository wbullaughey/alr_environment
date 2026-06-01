with Ada.Text_IO;use Ada.Text_IO;
with AUnit.Options;
with AUnit.Test_Results;
with AUnit.Test_Suites;
with Ada_Lib.Command_Line_Iterator.Tests;
with Ada_Lib.Configuration.Tests;
with Ada_Lib.Curl.Tests;
with Ada_Lib.Database.Get_Put_Tests;
with Ada_Lib.Database.Server.Tests;
with Ada_Lib.Database.Subscribe.Tests;
with Ada_Lib.Database.Subscription.Tests;
with Ada_Lib.Directory.Test;
with Ada_Lib.Event.Unit_Test;
--with Ada_Lib.GNOGA.Unit_Test.Base;   caused circular reference
with Ada_Lib.GNOGA.Unit_Test.Events;
with Ada_Lib.GNOGA.Unit_Test.Window_Events;
with Ada_Lib.Help.Tests;
--with Ada_Lib.ICON.Unit_Test;
with Ada_Lib.Lock.Tests;
with Ada_Lib.Mail.Tests;
with Ada_Lib.Options.Unit_Test;
with Ada_Lib.OS.Tests;
with Ada_Lib.Parser.Tests;
with Ada_Lib.Socket_IO.Client.Unit_Test;
with Ada_Lib.Socket_IO.Stream_IO.Unit_Test;
with Ada_Lib.Strings.Maps.Unit_Tests;
with Ada_Lib.Template.Tests;
with Ada_Lib.Test.Ask_Tests;
with Ada_Lib.Text.Textbelt.Tests;
with Ada_Lib.Timer.Tests;
with Ada_Lib.Trace.Tests; use Ada_Lib.Trace;
with Ada_Lib.Unit_Test.Reporter;
--with Ada_Lib.GNOGA.Unit_Test.Window_Events; could not find gnoga.ads

pragma Elaborate_All (Ada_Lib.Lock);
pragma Elaborate (Ada_Lib.Parser);

----------------------------------------------------------------------------
procedure Ada_Lib.Test.Run_Suite (
   Options                       : in     Ada_Lib.Options.AUnit_Lib.
                                             Aunit_Program_Options_Type'class) is
----------------------------------------------------------------------------

   use type Ada_Lib.Options.Mode_Type;

   Debug       : Boolean renames
                  Ada_Lib.Options.Unit_Test.Ada_Lib_Aunit.Debug;
   List_Suites : constant Boolean := Options.Nested_Unit_Test_Options.Mode =
                  Ada_Lib.Options.List_Suites;
begin
   Log_In (Debug, "list suites " & List_Suites'img);

   declare
      AUnit_Options           : AUnit.Options.AUnit_Options;
      Have_Host               : Boolean := False;
      Non_DBDaemon_Test_Suite : constant Ada_Lib.Options.AUnit_Lib.
                                 Non_DBDamon_Test_Access :=
                                    Ada_Lib.Options.AUnit_Lib.New_Suite;
      Outcome                 : AUnit.Status;
      Reporter                : Ada_Lib.Unit_Test.Reporter.Reporter_Type;
      Results                 : AUnit.Test_Results.Result;
      Test_Suite              : constant AUnit.Test_Suites.Access_Test_Suite :=
                                 (if List_Suites then
                                    new AUnit.Test_Suites.Test_Suite
                                 else
                                    AUnit.Test_Suites.New_Suite);

   begin
      AUnit_Options.Filter := Options.Nested_Unit_Test_Options.Filter'
                                 unchecked_access;

      Non_DBDaemon_Test_Suite.Add_Test (
         Ada_Lib.Curl.Tests.Suite);
      Non_DBDaemon_Test_Suite.Add_Test (
         Ada_Lib.Directory.Test.Suite);
      Non_DBDaemon_Test_Suite.Add_Test (
         Ada_Lib.Timer.Tests.Suite);
--    Non_DBDaemon_Test_Suite.Add_Test (
--       Ada_Lib.JSON.Tests.Suite);
      Non_DBDaemon_Test_Suite.Add_Test (
         Ada_Lib.Trace.Tests.Suite);
      Non_DBDaemon_Test_Suite.Add_Test (
         Ada_Lib.Lock.Tests.Suite);
      Non_DBDaemon_Test_Suite.Add_Test (
         Ada_Lib.Event.Unit_Test.Suite);
      Non_DBDaemon_Test_Suite.Add_Test (
         Ada_Lib.GNOGA.Unit_Test.Events.Suite);
      Non_DBDaemon_Test_Suite.Add_Test (
         Ada_Lib.GNOGA.Unit_Test.Window_Events.Suite);
      Non_DBDaemon_Test_Suite.Add_Test (
         Ada_Lib.Socket_IO.Client.Unit_Test.Suite);
      Non_DBDaemon_Test_Suite.Add_Test (
         Ada_Lib.Socket_IO.Stream_IO.Unit_Test.Suite);
      Non_DBDaemon_Test_Suite.Add_Test (
         Ada_Lib.Configuration.Tests.Suite);
      Non_DBDaemon_Test_Suite.Add_Test (
         Ada_Lib.Strings.Maps.Unit_Tests.Suite);
      Non_DBDaemon_Test_Suite.Add_Test (
         Ada_Lib.Test.Ask_Tests.Suite);
      Non_DBDaemon_Test_Suite.Add_Test (
         Ada_Lib.Parser.Tests.Suite);
      Non_DBDaemon_Test_Suite.Add_Test (
         Ada_Lib.Help.Tests.Suite);
--       Non_DBDaemon_Test_Suite.Add_Test (
--          Ada_Lib.GNATCOLLL.Tests.Suite);
--    Non_DBDaemon_Test_Suite.Add_Test (
--       Ada_Lib.GNOGA.Unit_Test.Base.Suite);
      Non_DBDaemon_Test_Suite.Add_Test (
         Ada_Lib.Command_Line_Iterator.Tests.Suite);
      Non_DBDaemon_Test_Suite.Add_Test (
         Ada_Lib.Database.Get_Put_Tests.No_Database_Suite );
      Non_DBDaemon_Test_Suite.Add_Test (
         Ada_Lib.Mail.Tests.Suite);
      Non_DBDaemon_Test_Suite.Add_Test (
         Ada_Lib.Text.Textbelt.Tests.Suite);
      Non_DBDaemon_Test_Suite.Add_Test (
         Ada_Lib.OS.Tests.Suite);
      Non_DBDaemon_Test_Suite.Add_Test (
         Ada_Lib.Template.Tests.Suite);
--    Non_DBDaemon_Test_Suite.Add_Test (
--       Ada_Lib.ICON.Unit_Test.Suite);
      Test_Suite.Add_Test (Non_DBDaemon_Test_Suite);

      for Host_Kind in Ada_Lib.Database.Valid_Hosts_Type loop
         Log (Debug, Here, Who & " Host_Kind " & Host_Kind'img);

         if (case Host_Kind is

               when Ada_Lib.Database.Local =>
                  Options.Database_Options.Has_Local_DBDaemon or else
                  Options.Nested_Unit_Test_Options.Mode = Ada_Lib.Options.List_Suites,

               when Ada_Lib.Database.Remote =>
                  Options.Database_Options.Has_Remote_Host

            ) then
            declare
               DBDaemon_Test_Suite
                              : constant Ada_Lib.Options.AUnit_Lib.
                                 DBDamon_Test_Access :=
                                    Ada_Lib.Options.AUnit_Lib.New_Suite;
               Subscribe_Test_Suite
                              : constant AUnit.Test_Suites.Access_Test_Suite :=
                                 Ada_Lib.Database.Subscribe.Tests.
                                    Subscribe_Suite (Host_Kind);
               Subscription_Test_Suite
                              : constant AUnit.Test_Suites.Access_Test_Suite :=
                                 Ada_Lib.Database.Subscription.Tests.
                                    Subscription_Suite (Host_Kind);

            begin
               Log (Debug, Here, Who & " add tests for " & Host_Kind'img);

               DBDaemon_Test_Suite.Add_Test (
                  Ada_Lib.Database.Get_Put_Tests.Database_Suite (Host_Kind));

               DBDaemon_Test_Suite.Add_Test (
                  Ada_Lib.Database.Server.Tests.Server_Suite (Host_Kind));

               Test_Suite.Add_Test (Subscription_Test_Suite);
               Test_Suite.Add_Test (Subscribe_Test_Suite);
               Test_Suite.Add_Test (DBDaemon_Test_Suite);
               Have_Host := True;
            end;
         end if;
      end loop;

      if not Have_Host then
         Log_Here (Debug, "no host found");
      end if;
      Test_Suite.Run (AUnit_Options, Results, Outcome);

      Log_Here (Debug, "Mode " & Options.Nested_Unit_Test_Options.Mode'img);
      case Options.Nested_Unit_Test_Options.Mode is

         when Ada_Lib.Options.Driver_Suites |
              Ada_Lib.Options.List_Suites |
              Ada_Lib.Options.Print_Suites =>
            Ada_Lib.Unit_Test.Iterate_Suites (
               Ada_Lib.Options.Unit_Test.Suite_Action'access,
               Ada_Lib.Options.Unit_Test.Routine_Action'access,
               Options.Nested_Unit_Test_Options.Mode);

         when Ada_Lib.Options.Run_Tests =>
            Log_Here (Debug);
            Put_Line ("report Ada_Lib test results");
            Reporter.Report (Results, AUnit_Options);

      end case;
   end;
   Log_Out (Debug);

end Ada_Lib.Test.Run_Suite;

