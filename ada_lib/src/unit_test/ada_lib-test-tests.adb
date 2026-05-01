-- to be used by non-database tests
package body Ada_Lib.Test.Tests is


   ---------------------------------------------------------------
-- overriding
   function Test (
      Suite                      : in     Test_Suite_Type
   ) return Boolean is       -- return true if test can be run
   ---------------------------------------------------------------

   begin
      return True;
   end Test;

end Ada_Lib.Test.Tests;
