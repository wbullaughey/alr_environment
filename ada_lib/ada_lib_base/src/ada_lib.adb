with Ada.Task_Identification;
with Ada_Lib.Trace; use Ada_Lib.Trace;

package body Ada_Lib is

-- use type Ada.Calendar.Time;

   --------------------------------------------------------------------
   -- return task identification for calling task
   function Current_Task
   return String is
   --------------------------------------------------------------------

   begin
      return Ada.Task_Identification.Image (Ada.Task_Identification.Current_Task);
   end Current_Task;

begin
--Elaborate := True;
-- Trace_Options := True;
   Log_Here (Elaborate or Trace_Options);
end Ada_Lib;
