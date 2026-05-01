--with Ada_Lib.Options.Unit_Test;
--with Ada_Lib.Test.Suites;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with AUnit.Ada_Lib;

package body AUnit.Test_Suites.Optional is

   Debug                         : Boolean renames AUnit.Ada_Lib.Debug;

   ----------------------------------------------------------------------------
   overriding
   procedure Run (Suite   : access Test_Suite_Type;
                  Options :        AUnit_Options;
                  R       : in out Result'Class;
                  Outcome :    out Status) is
   --  Optionally Run all tests collected into this suite
   ----------------------------------------------------------------------------

   begin
      Log_In (Debug, "include " & Access_Test_Suite (Suite).Test'img);
--       " list suites " & Unit_Test_Options.List_Suites'img);

      if Access_Test_Suite (Suite).Test then
--          not Unit_Test_Options.List_Suites then
         AUnit.Test_Suites.Run (AUnit.Test_Suites.Test_Suite (Suite.all)'access, Options, R, Outcome);
      end if;

      Log_Out (Debug);
   end Run;

end AUnit.Test_Suites.Optional;

