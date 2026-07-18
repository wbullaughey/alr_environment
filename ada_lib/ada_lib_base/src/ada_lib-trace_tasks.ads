with Ada.Finalization;
with Ada.Task_Identification;
with Ada_Lib.Trace; -- use Ada_Lib.Trace;  prevent ambiguous expression

package Ada_Lib.Trace_Tasks is

   Trace_Failure                 : exception;

   generic
   package Gateway is   -- debug tool to detect reentrency to task

      type Gateway_Type is new Ada.Finalization.Limited_Controlled with null record;

      procedure Enter ( -- mark entry
         Gateway                 : in     Gateway_Type;
         Caller_Name             : in     String := Ada_Lib.Trace.Who;
         Caller_Line             : in     Positive := Ada_Lib.Trace.Line);

      function Enter ( -- mark entry
         Caller_Name             : in     String := Ada_Lib.Trace.Who;
         Caller_Line             : in     Positive := Ada_Lib.Trace.Line
      ) return Gateway_Type;

   private

      overriding
      procedure Finalize ( -- clear entry marker
         Gateway                 : in out Gateway_Type);

--    type Active_Type is new  Ada.Finalization.Limited_Controlled with record
--       Caller_Name                : Ada_Lib.Strings.Unlimited.String_Type;
--       Caller_Line                : Positive;
--    end record;
--
--    Active_Entry                  : Active_Type;
   end Gateway;

   function All_Stopped return Boolean ;

   procedure Report;

   procedure Start (
      Description                : in     String := Ada_Lib.Trace.Who;
      From                       : in     String := Ada_Lib.Trace.Here);

   procedure Stop (
      From                       : in     String := Ada_Lib.Trace.Here);

   procedure Stop (
      Task_ID                    : in     Ada.Task_Identification.Task_ID);

   Debug                         : aliased Boolean := False;

private

end Ada_Lib.Trace_Tasks;

