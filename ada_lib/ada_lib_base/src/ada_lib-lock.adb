--with Ada.Real_Time;
--with Ada.Text_IO; use  Ada.Text_IO;
with Ada_Lib.Options;
with Ada_Lib.Strings; use Ada_Lib.Strings;
with Ada_Lib.Trace; use Ada_Lib.Trace;

package body Ada_Lib.Lock is

   Debug    : Boolean renames Options.Ada_Lib_Lock.Debug;

   -------------------------------------------------------------------
   overriding
   function Is_Locked (                -- used value on Lock
      Lock                    : in     Lock_Type;
      From                    : in     String := GNAT.Source_Info.Source_Location
   ) return Boolean is
   -------------------------------------------------------------------

   begin
      return Log_Here (Lock.Protected_Lock.Is_Locked, Debug,
         "lock address " & Image (Lock'address) & " called from " & From);
   end Is_Locked;

   -------------------------------------------------------------------
   overriding
   function Lock (
      Lock           : in out Lock_Type;
      Timeout        : in     Duration := Min_Lock_Time;
      From           : in     String := GNAT.Source_Info.Source_Location
   ) return Boolean is
   -------------------------------------------------------------------

      Result         : Boolean;

   begin
      Log_In (Debug, "locked " & Lock.Protected_Lock.Is_Locked'img &
         " timeout " & Timeout'img &
         " lock address " & Image (Lock'address) & " from " & From);

      if Timeout = Min_Lock_Time then
         Lock.Protected_Lock.Try_Lock (Result);
         return Log_Out (Result, Debug);
      end if;

      declare
         Deadline       : constant Ada.Real_Time.Time := Ada.Real_Time.Clock +
                           Ada.Real_Time.To_Time_Span(Timeout);
      begin
         select
            delay until Deadline;
            Result := False;
         then abort
            Lock.Protected_Lock.Lock;
            Result := True;
         end select;

         return Log_Out (Result, Debug, (if Result then
               "got lock"
            else
               "lock timed out after " & Timeout'img & " seconds"));
      end;
   end Lock;

   -------------------------------------------------------------------
   -- raises exception if object already locked
   overriding
   procedure Lock (
      Lock                 : in out Lock_Type;
      From                 : in     String := GNAT.Source_Info.Source_Location) is
   -------------------------------------------------------------------

   begin
      Log_In (Debug, "lock address " & Image (Lock'address) & " from " & From);
      if not Lock.Lock then
         raise Already_Locked with "from " & From;
      end if;
      Log_Out (Debug);
   end Lock;

-- -------------------------------------------------------------------
-- overriding
-- function Try_Lock (
--    Lock                     : in out Lock_Type;
--    From                       : in     String := GNAT.Source_Info.Source_Location
-- ) return Boolean is
-- -------------------------------------------------------------------
--
--    Got_Lock                   : Boolean;
--
-- begin
--    Log_In (Debug, "from " & From);
--    Lock.Protected_Lock.Try_Lock (Got_Lock);
--    return Log_Out (Got_Lock, Debug);
-- end Try_Lock;

-------------------------------------
   overriding
   procedure Unlock (
      Lock               : in out Lock_Type;
      From                 : in     String := GNAT.Source_Info.Source_Location) is
   -------------------------------------------------------------------

   begin
      Log_Here (Debug, "lock address " & Image (Lock'address) & "from " & From);
      Lock.Protected_Lock.Unlock;
   end Unlock;

   -------------------------------------------------------------------
   protected body Protected_Lock_Type is

      -------------------------------------------------------------------
      entry Lock when not Locked is
      -------------------------------------------------------------------

      begin
         Locked := True;
         Log_Here (Debug, "Lock set");
      end Lock;

      -------------------------------------------------------------------
      procedure Try_Lock (
         Got_Lock       :   out Boolean) is
      -------------------------------------------------------------------

      begin
         if Locked then
            Got_Lock := False;
         else
            Locked := True;
            Got_Lock := True;
         end if;
      end Try_Lock;

      -------------------------------------------------------------------
      procedure Unlock is
      -------------------------------------------------------------------

      begin
         Locked := False;
         Log_Here (Debug, "Lock cleared");
      end Unlock;

      -------------------------------------------------------------------
      function Is_Locked return Boolean is
      -------------------------------------------------------------------
      begin
         return Log_Here (Locked, Debug);
      end Is_Locked;

   end Protected_Lock_Type;

end Ada_Lib.Lock;
