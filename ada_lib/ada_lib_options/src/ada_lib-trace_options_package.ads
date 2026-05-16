--  Package that provides basic tracing facilities.

package Ada_Lib.Trace_Options_Package is

   Absolute                      : constant Boolean := False;
   Ada_Lib_Lib_Verbose           : Boolean := False;
   Ada_Lib_Trace_Trace           : aliased Boolean := False;
   Debug_All                     : Boolean := False;
   Debug_Trace                   : Boolean := False;
   Detail                        : Boolean := False;
   Do_Trace_Checks               : Boolean := True;
   Elaborate                     : Boolean := False;
   Include_Hundreds              : Boolean := False;
   Include_Program               : Boolean := False;
   Indent_Trace                  : Boolean := False;
   Inhibit_Trace                 : Boolean := False;
   Pause_Flag                    : Boolean := False;
   Test_Condition                : Boolean := False;
   Trace_Conversions             : Boolean := False;
   Trace_Exceptions              : Boolean := False;
   Trace_Tag_History             : Boolean := False;
   Trace_Levels                  : Boolean := False;
   Trace_Options                 : Boolean := False;
   Trace_Pre_Post_Conditions     : Boolean := False;
   Trace_Pre_Post_False          : Boolean := False;
   Trace_Set_Up_Tear_Down        : Boolean := False;
   Trace_Tests                   : Boolean := False;

end Ada_Lib.Trace_Options_Package;
