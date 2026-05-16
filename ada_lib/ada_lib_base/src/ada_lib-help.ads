with Ada_Lib.Options;
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

   procedure Display (
      Output_Line                : not null access procedure (
         Line                       : in     String));

   procedure Reset;

   procedure Set_Has_Trace (
      Option                     : in     Character;
      Modifier                   : in     Character);

   Modifier          : constant Character := '@';
   Modifiers         : constant String    := "@";
   Trace_Modifier    : constant Character := '#';
   Trace_Modifiers   : constant String    := "#";
   Unmodified_Flag   : Character renames Ada_Lib.Options.Unmodified_Flag;
   Unit_Test_Modifier: constant Character := '$';

end  Ada_Lib.Help;

