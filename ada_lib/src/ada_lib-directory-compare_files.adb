with Ada_Lib.Directory.File_Compare;
with Ada_Lib.Options;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Trace; use Ada_Lib.Trace;

function Ada_Lib.Directory.Compare_Files (
   Path_1, Path_2                : in     String
) return Boolean is

   Debug : Boolean renames Options.Ada_Lib_Directory.Debug;

begin
   Log_In (Debug, Quote ("compare path 1", Path_1) & Quote (" path 2", Path_2));
   Ada_Lib.Directory.File_Compare (Path_1, Path_2);
   return Log_Out (True, Debug);

exception
   when Fault: Failed =>
      Trace_Exception (Debug, Fault);
      return Log_Out (False, Debug);


end Ada_Lib.Directory.Compare_Files;

