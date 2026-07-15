-- root package for testing Ada_Lib.Database package
with Ada_Lib.Options.Unit_Test;

package Database is

   Debug : Boolean renames Ada_Lib.Options.Unit_Test.
            Ada_Lib_Database_Unit_Test.Debug;

end Database;
