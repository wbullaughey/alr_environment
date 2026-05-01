with Ada_Lib.OS.Run;
with Ada_Lib.Trace; use Ada_Lib.Trace;

-- pragma Elaborate (Ada_Lib.OS);

package body Ada_Lib.CURL is

   procedure Run (
      Source                     : in     string
   ) is

   begin
      Log_In (Debug);

      declare
         Result                  : constant String :=
                                    Ada_Lib.OS.Run.Spawn (
                                       Program     => "/bin/bash",
                                       Parameters => Source);
      begin
         Log_Out (Debug, Result);
      end;
   end Run;

end Ada_Lib.CURL;