with AUnit.Test_Suites; -- .Optional;
--with Ada_Lib.Database.Unit_Test;
with Ada_Lib.Unit_Test.Test_Cases;


-- to be used by non-database tests
package Ada_Lib.Test.Tests is

   type Test_Case_Type is abstract new Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type with null record;

   type Test_Suite_Type is new AUnit.Test_Suites.Test_Suite with null record;

-- overriding
   function Test (
      Suite                      : in     Test_Suite_Type
   ) return Boolean;       -- return true if test can be run

end Ada_Lib.Test.Tests;
