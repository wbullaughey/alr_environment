--with AUnit.Test_Cases;
with AUnit.Test_Suites;

package Ada_Lib.Lock.Tests is

   Suite_Name                    : constant String := "Lock";

   function Suite return AUnit.Test_Suites.Access_Test_Suite;

end Ada_Lib.Lock.Tests;