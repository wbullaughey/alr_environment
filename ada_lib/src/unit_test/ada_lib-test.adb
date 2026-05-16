with Ada_Lib.Options.Unit_Test;
with Ada_Lib.Trace; use Ada_Lib.Trace;

package body Ada_Lib.Test is

   Debug       : Boolean renames Options.Unit_Test.Ada_Lib_Aunit.Debug;

   ----------------------------------------------------------------------------
   function Near (
      Actual                     : in     Value_Type;
      Expected                   : in     Value_Type;
      Tolerance                  : in     Value_Type
   ) return Boolean is
   ----------------------------------------------------------------------------

   begin
      return abs (Actual - Expected) < Tolerance;
   end Near;

   ----------------------------------------------------------------------------
   procedure Raise_Assert_Failed (
      Message                    : in     String;
      Called_From                : in     String := Ada_Lib.Trace.Who;
      Raised_From                : in     String := Ada_Lib.Trace.Here) is
   ----------------------------------------------------------------------------

   begin
      raise Ada_Lib.Test.Assert_Failed with Message &
         " called from " & Called_From & " raised at " & Raised_From;
   end Raise_Assert_Failed;

-- ----------------------------------------------------------------------------
-- procedure Set_All_Traces is
-- ----------------------------------------------------------------------------
--
-- begin
--    Ada_Lib.Test.Debug := True;
--    Ada_Lib.Unit_Test.Debug := True;
-- end Set_All_Traces;

begin
Debug := True;
--Trace_Options := True;
   Log_Here (Debug or Trace_Options or Elaborate);
end Ada_Lib.Test;
