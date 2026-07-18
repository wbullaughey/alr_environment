with Ada.Exceptions;
with Ada.Task_Identification;
with Ada.Text_IO; use  Ada.Text_IO;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with GNAT.OS_Lib;

package body Ada_Lib is

-- use type Ada.Calendar.Time;
   use type Ada.Task_Identification.Task_Id;

   --------------------------------------------------------------------
   -- return task identification for calling task
   function Current_Task
   return String is
   --------------------------------------------------------------------

      Task_Pointer   : constant Ada.Task_Identification.Task_Id :=
                        Ada.Task_Identification.Current_Task;

   begin
      return (
         if Task_Pointer = Ada.Task_Identification.Null_Task_Id then
            "no current task"
         else
            Ada.Task_Identification.Image (Task_Pointer)
      );
   end Current_Task;

begin
--Elaborate := True;
-- Trace_Options := True;
   Log_Here (Elaborate or Trace_Options);
   Is_Elaborated := True;

exception

   when Fault: others =>
      Put_Line ("----------- exception --------------");
      Put_Line ("Exception name:" &
         Ada.Exceptions.Exception_Name (Fault));
      Put_Line ("Exception message:" &
         Ada.Exceptions.Exception_Message (Fault));
      Put_Line ("------------------------------------");
      GNAT.OS_Lib.OS_Exit (0);
end Ada_Lib;
