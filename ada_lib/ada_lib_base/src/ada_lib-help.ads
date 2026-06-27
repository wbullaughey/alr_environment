with Ada_Lib.Options;
with Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace;

package Ada_Lib.Help is

   Failed                        : exception;

   procedure Create_Option (
      Option                     : in     Character;
      Trace_Option               : in     Boolean; -- needs to be true if
                                                   -- option is for a trace
      Parameter                  : in     String;
      Description                : in     String;
      Component                  : in     String;
      Modifier                   : in     Character;
      Source_Line                : in     String := Ada_Lib.Trace.Here
   ) with Pre => Description'length > 0;

   procedure Check_Traces;

-- type Parameter_Array   is array (Positive range <>) of
--                         Ada_Lib.Strings.Unlimited.String_Type;
--
-- type Parameter_Array_Access
--                      is access Parameter_Array;
--
   procedure Display (
      Parameters        : in     Ada_Lib.Options.Argument_Array;
      Output_Line       : not null access procedure (
         Line              : in     String));

   procedure Reset;

   procedure Set_Has_Trace (
      Option                     : in     Character;
      Modifier                   : in     Character);

   Modifier          : constant Character := '@';
   Modifiers         : constant String    := "@";
   Null_Parameters   : constant Options.Argument_Array (1 .. 0) := (others =>
                        Strings.Unlimited.Null_String);
   Trace_Modifier    : constant Character := '#';
   Trace_Modifiers   : constant String    := "#";
-- Unmodified_Flag   : Character renames Ada_Lib.Options.Unmodified_Flag;
   Unit_Test_Modifier: constant Character := '$';

end  Ada_Lib.Help;

