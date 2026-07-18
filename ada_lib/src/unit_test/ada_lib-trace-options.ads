with Ada_Lib.Help;
with Ada_Lib.Options.Nested;

package Ada_Lib.Trace.Options is

   type Ada_Lib_Trace_Options_Type
                        is new Ada_Lib.Options.Nested.Nested_Options_Type
                           with null record;

   type Ada_Lib_Trace_Options_Access
                        is access all Ada_Lib_Trace_Options_Type;
   type Ada_Lib_Trace_Options_Class_Access
                        is access all Ada_Lib_Trace_Options_Type'class;
   type Ada_Lib_Trace_Options_Constant_Class_Access
                        is access constant Ada_Lib_Trace_Options_Type'class;

   overriding
   procedure Display_Help (            -- common for all programs that use GNOGA_Options
                              -- prints full help, aborts program
     Options                     : in     Ada_Lib_Trace_Options_Type;  -- only used for dispatch
     Parameters                  : in     Ada_Lib.Options.Argument_Array;
     Message                     : in     String := "";   -- leave blank no error help
     Halt                        : in     Boolean := True);

   overriding
   function Process_Option (
      Options  : in out Ada_Lib_Trace_Options_Type;
      Iterator : in out Ada_Lib.Options.Command_Line_Iterator_Interface'class;
      Option   : in     Ada_Lib.Options.Flag_Option_Type'class
   ) return Boolean;

   overriding
   procedure Program_Help (
      Options                    : in      Ada_Lib_Trace_Options_Type;  -- only used for dispatch
      Help_Mode                  : in      Ada_Lib.Options.Help_Mode_Type);

end Ada_Lib.Trace.Options;
