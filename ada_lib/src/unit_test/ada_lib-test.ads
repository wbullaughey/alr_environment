--with Ada.Exceptions;
with Ada_Lib.Trace;

package Ada_Lib.Test is

   Assert_Failed                 : exception;
   Failed                        : exception;

-- procedure Exception_Handler (
--    Fault                      : in   Ada.Exceptions.Exception_Occurrence;
--    Where                      : in   String := Ada_Lib.Trace.Here;
--    Who                        : in   String := Ada_Lib.Trace.Who;
--    Message                    : in   String := "");

   procedure Raise_Assert_Failed (
      Message                    : in     String;
      Called_From                : in     String := Ada_Lib.Trace.Who;
      Raised_From                : in     String := Ada_Lib.Trace.Here);

-- procedure Help (
--    Option                     : in     Character);
--
   generic
      type Value_Type            is digits <>;

   function Near (
      Actual                     : in     Value_Type;
      Expected                   : in     Value_Type;
      Tolerance                  : in     Value_Type
   ) return Boolean;

-- procedure Parse (
--    Options                    : in out Standard_Options.Extra_Options_Type'class;
--    Parameter                  : in     String);
--
-- procedure Set_All_Traces;

end Ada_Lib.Test;
