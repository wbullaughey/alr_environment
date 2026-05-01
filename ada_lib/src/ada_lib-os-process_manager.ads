-- use with multi-tasking applications that need to spawn processes
-- NOTE in package System.OS_Lib
   --  Spawning processes in tasking programs using the above Spawn and
   --  Non_Blocking_Spawn subprograms is not recommended, because there are
   --  subtle interactions between creating a process and signals/locks that
   --  can cause trouble. These issues are not specific to Ada; they depend
   --  primarily on the operating system.

with Ada.Finalization;
with GNAT.Sockets;

package Ada_Lib.OS.Process_Manager is

   Failed                        : exception;

   type Initializer_Type is new Ada.Finalization.Limited_Controlled with private;

   overriding
   procedure Finalize (
      Object                     : in out Initializer_Type);

   overriding
   procedure Initialize (
      Object                     : in out Initializer_Type);

   function Was_Initialized (
      Object                     : in     Initializer_Type
   ) return Boolean;

   Default_Server_Port           : GNAT.Sockets.Port_Type := 12345;

private
   type Initializer_Type is new Ada.Finalization.Limited_Controlled with record
      Initialized                : Boolean := False;
      Process_Id                 : GNAT.OS_Lib.Process_Id;
   end record;

end Ada_Lib.OS.Process_Manager;
