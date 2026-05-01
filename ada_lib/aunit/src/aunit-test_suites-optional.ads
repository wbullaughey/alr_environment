with Ada_Lib.Options.Verification;

package AUnit.Test_Suites.Optional is

-- use type Ada_Lib.Options.Program_Options_Constant_Class_Access;

   type Test_Suite_Type is abstract new AUnit.Test_Suites.Test_Suite with null record;
   type Access_Test_Suite is access all Test_Suite_Type'Class;

   --  Optionally Run all tests collected into this suite
   overriding
   procedure Run (Suite   : access Test_Suite_Type;
                  Options :        AUnit_Options;
                  R       : in out Result'Class;
                  Outcome :    out Status
   ) with Pre => Ada_Lib.Options.Verification.Have_Ada_Lib_Verification_Options;

   -- test is have the right DBDaemon (local or remote) open
   function Test (
      Suite                      : in     Test_Suite_Type
   ) return Boolean is abstract;       -- return true if test can be run

end AUnit.Test_Suites.Optional;

