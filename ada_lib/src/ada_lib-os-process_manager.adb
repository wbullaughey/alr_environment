-- use with multi-tasking applications that need to spawn processes
-- NOTE in package GNAT.OS_Lib
   --  Spawning processes in tasking programs using the above Spawn and
   --  Non_Blocking_Spawn subprograms is not recommended, because there are
   --  subtle interactions between creating a process and signals/locks that
   --  can cause trouble. These issues are not specific to Ada; they depend
   --  primarily on the operating system.

with Ada_Lib.Trace;use Ada_Lib.Trace;
with GNAT.OS_Lib;

package body Ada_Lib.OS.Process_Manager is

   use type GNAT.OS_Lib.Process_Id;

   Server_Path                   : constant String := "c:\build\bin\Ada_Lib_os_process_manager_server.exe";

   ---------------------------------------------------------------------------
   overriding
   procedure Finalize (
      Object                     : in out Initializer_Type) is
   ---------------------------------------------------------------------------

   begin
      Log (Trace, Here, Who);
      GNAT.OS_Lib.Kill_Process_Tree (Object.Process_ID,  Hard_Kill => True);
   end Finalize;

   ---------------------------------------------------------------------------
   overriding
   procedure Initialize (
      Object                     : in out Initializer_Type) is
   ---------------------------------------------------------------------------

      Argument_List              : constant GNAT.OS_Lib.Argument_List_Access :=
                                    GNAT.OS_Lib.Argument_String_To_List ("-t");
--    Descriptor                 : GNAT.OS_Lib.Process_Descriptor;

   begin
-- Trace := True;
      Log (Trace, Here, Who);
      Object.Process_ID := GNAT.OS_Lib.Non_Blocking_Spawn (Server_Path, Argument_List.all);

      if Object.Process_ID = GNAT.OS_Lib.Invalid_Pid then
         declare
            Error_Number         : constant Integer := GNAT.OS_Lib.Errno;
            Error_Message        : constant String := GNAT.OS_Lib.Errno_Message (Error_Number);

         begin
            Log (Trace,  Here, Who & "Errno" & Error_Number'img & " message '" &
               Error_Message);
            Log (Trace,  Here, Who & " could not start '" & Server_Path & "'");
         end;
      else
         Object.Initialized := True;
         Log (Trace, Here, Who);
      end if;
   end Initialize;

   ---------------------------------------------------------------------------
   function Was_Initialized (
      Object                     : in     Initializer_Type
   ) return Boolean is
   ---------------------------------------------------------------------------

   begin
      return Object.Initialized;
   end Was_Initialized;

end Ada_Lib.OS.Process_Manager;
