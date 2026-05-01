with Ada_Lib.Options.Flags;
with Ada_Lib.Trace;

package Ada_Lib.Help is

   Failed                        : exception;

   procedure Add_Option (
      Option                     : in     Ada_Lib.Options.Flags.Flag_Option_Type;
      Parameter                  : in     String;
      Description                : in     String;
      Component                  : in     String := "";
      Source_Line                : in     String := Ada_Lib.Trace.Here
   ) with Pre => Description'length > 0;

   procedure Create_Option (
      Option                     : in     Character;
      Parameter                  : in     String;
      Description                : in     String;
      Component                  : in     String;
      Modifier                   : in     Character;
      Source_Line                : in     String := Ada_Lib.Trace.Here
   ) with Pre => Description'length > 0;

   procedure Display (
      Output_Line                : not null access procedure (
         Line                       : in     String));

   procedure Reset;

   Modifier          : constant Character := '@';
   Modifiers         : constant String    := "@";
   Trace_Modifier    : constant Character := '#';
   Trace_Modifiers   : constant String    := "#";
   Unmodified_Flag   : Character renames Ada_Lib.Options.Unmodified_Flag;
   Unit_Test_Modifier: constant Character := '$';

end  Ada_Lib.Help;

