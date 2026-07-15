with AUnit.Test_Suites;

package Ada_Lib.Directory.Test is

   Debug                         : Boolean := False;

   function Suite return AUnit.Test_Suites.Access_Test_Suite;

   Suite_Name                    : constant String := "Directory";

end Ada_Lib.Directory.Test;
