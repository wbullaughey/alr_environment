with Ada_Lib.Trace; use Ada_Lib.Trace; -- use Ada_Lib.Trace_Tasks;

package body Ada_Lib.Interrupt is

-- pragma Unreserve_All_Interrupts;
-- pragma Interrupt_State (Ada.Interrupts.Names.SIGINT, User);
--
-- task type Handler_Task_Type is
--
--    entry Signal (
--       Interrupt         : in   Ada_Lib.Interrupt_Names.Interrupt_Type);
--
--    entry Stop;
--
-- end;
--
-- type Handler_Task_Access   is access Handler_Task_Type;


-- procedure Free is new Ada.Unchecked_Deallocation (
--    Object         => Handler_Task_Type,
--    Name        => Handler_Task_Access);

-- function OS_Kill (
--    Process_ID                 : in     Integer;
--    Signal                     : in     Integer
-- ) return Integer

--   procedure Signal_Task (
--      Interrupt            : in   Interrupt_Type);
--
--   Handlers             : array (Ada_Lib.Interrupt_Names.Interrupt_Type) of
--                           Handler_Access := (others => Null);
--   Handler_ID           : Ada.Task_Identification.Task_Id;
--   Handler_Task            : Handler_Task_Access := Null;
--
--   -------------------------------------------------------------------
--   procedure Attach_Handler (
--      Interrupt            : in   Interrupt_Type;
--      Handler              : in   Handler_Access) is
--   -------------------------------------------------------------------
--
--      ID                : constant Ada.Interrupts.Interrupt_ID :=
--                           Ada_Lib.Interrupt_Names.Map (Interrupt);
--   begin
--      Log (Debug, Here, Who);
--      if Ada.Interrupts.Is_Reserved (ID) then
--         Ada.Exceptions.Raise_Exception (Reserved_Interrupt'Identity, Interrupt'img);
--      end if;
--
--      Handlers (Interrupt) := Handler;
--
--      Ada.Interrupts.Attach_Handler (
--         Ada_Lib.Interrupt_Names.Handler(Interrupt), ID);
--
--      if Handler_Task = Null then
--         Handler_Task :=new Handler_Task_Type;
--         Ada_Lib.Interrupt_Names.Set_Callback (Signal_Task'access);
--      end if;
--   end Attach_Handler;
--
--   -------------------------------------------------------------------
--   procedure Cleanup is
--   -------------------------------------------------------------------
--
--      Timeout              : constant Ada.Calendar.Time := Ada.Calendar.Clock + 0.5;
--
--   begin
--      Log (Debug, Here, Who);
--      if Handler_Task /= Null then
--         Handler_Task.Stop;
--         while not Ada.Task_Identification.Is_Terminated (Handler_Id) loop
--            if Ada.Calendar.Clock > Timeout then
--               Log (Debug, Here, Who);
--               raise Failed with "Interrupt Handler task failed to terminate";
--            end if;
--         end loop;
--         Free (Handler_Task);
--      end if;
--   end Cleanup;
--
--   -------------------------------------------------------------------
--   procedure Kill (
--      Interrupt            : in   Interrupt_Type) is
--   -------------------------------------------------------------------
--
----    Result               : Integer;
--
--   begin
-- Null;
----    Result := OS_Kill (0, Interrupt_Type'POS (Interrupt));
--   end Kill;
--
--   -------------------------------------------------------------------
--   procedure Signal (
--      Interrupt            : in   Interrupt_Type;
--      Handler              : in out Handler_Type) is
--   -------------------------------------------------------------------
--
--   begin
--      null;
--   end Signal;
--
--   -------------------------------------------------------------------
--   procedure Signal_Task (
--      Interrupt            : in   Interrupt_Type) is
--   -------------------------------------------------------------------
--
--   begin
--      pragma Assert (Handler_Task /= Null);
--      Handler_Task.Signal (Interrupt);
--   end Signal_Task;
--
--   -------------------------------------------------------------------
--   procedure Signal_Handler (
--      Interrupt            : in   Interrupt_Type) is
--   -------------------------------------------------------------------
--
--   begin
--      pragma assert (Handler_Task /= Null);
--      pragma assert (Handlers (Interrupt) /= Null);
--
--      Signal (Interrupt, Handlers (Interrupt).all);
--   end Signal_Handler;

   -------------------------------------------------------------------
   protected body Handler_Type is

--    ----------------------------------------------------------------
--    procedure Attach (
--       Interrupt_Number  : in     Ada.Interrupts.Interrupt_ID) is
--    ----------------------------------------------------------------
--
--    begin
--       Ada.Interrupts.Attach_Handler (Handler'access, Interrupt_Number);
--    end Attach;

      ----------------------------------------------------------------
      procedure Handler is
      ----------------------------------------------------------------

      begin
         Log (Debug, Here, Who);
         Got_It := True;

         if Callback /= Null then
            Callback.all;
         end if;
      end Handler;

      ----------------------------------------------------------------
      function Occured return Boolean is
      ----------------------------------------------------------------

      begin
         return Got_It;
      end Occured;

   end Handler_Type;

-- -------------------------------------------------------------------
-- task body Handler_Task_Type is
--
--    Local_Interrupt         : Ada_Lib.Interrupt_Names.Interrupt_Type;
--
-- begin
--    Handler_ID := Ada.Task_Identification.Current_Task;
--    Tasks.Start ("handler task type", Here);
--    loop
--       select
--          accept Signal (
--             Interrupt         : in   Ada_Lib.Interrupt_Names.Interrupt_Type) do
--
--             Local_Interrupt := Interrupt;
--          end Signal;
--
--          Signal_Handler (Local_Interrupt);
--       or
--          accept Stop;
--          Log (Debug, Here, Who);
--          Tasks.Stop;
--          exit;
--       end select;
--    end loop;
--    Log (Debug, Here, Who);
-- end;

end Ada_Lib.Interrupt;
