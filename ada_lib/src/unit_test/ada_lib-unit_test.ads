with Ada.Exceptions;
with Ada_Lib.Options;
with Ada_Lib.Trace; use Ada_Lib.Trace;
--with AUnit.Test_Cases;

package Ada_Lib.Unit_Test is

   Failed                        : exception;

-- -- derive all aunit tests from this type
-- type AUnit_Testfs_Type   is abstract new AUnit.Test_Cases.Test_Case with private;

-- overriding
-- procedure Set_Up (
--    Test                       : in out AUnit_Tests_Type
-- ) with Pre => not Test.Verify_Set_Up,
--        Post => Test.Verify_Set_Up;
--
-- overriding
-- procedure Tear_Down (
--    Test                       : in out AUnit_Tests_Type
-- ) with Pre => not Test.Verify_Tear_Down,
--        Post => Test.Verify_Tear_Down;
--
-- function Verify_Set_Up (
--    Test                       : in     AUnit_Tests_Type
-- )  return Boolean;
--
-- function Verify_Tear_Down (
--    Test                       : in     AUnit_Tests_Type
-- )  return Boolean;

   type Suite_Action_Access      is access procedure (
      Suite                      : in     String;
      First                      : in out Boolean;
      Mode                       : in     Ada_Lib.Options.Mode_Type);

   type Routine_Action_Access    is access procedure (
      Suite                      : in     String;
      Routine                    : in     String;
      Mode                       : in     Ada_Lib.Options.Mode_Type);

   function Did_Fail return Boolean;

   procedure Exception_Assert (
      Fault                      : Ada.Exceptions.Exception_Occurrence;
      Here                       : in     String := Ada_Lib.Trace.Here;
      Who                        : in     String := Ada_Lib.Trace.Who);

   function Has_Test (
      Suite_Name                 : in     String;
      Routine_Name               : in     String
   ) return Boolean;

   procedure Iterate_Suites (
      Suite_Action               : in     Suite_Action_Access;
      Routine_Action             : in     Routine_Action_Access;
      Mode                       : in     Ada_Lib.Options.Mode_Type);

   procedure Routine (
      Suite_Name                 : in     String;
      Routine_Name               : in     String);

-- procedure Run_Tests;

   procedure Set_Failed (
      From                       : in     String := Ada_Lib.Trace.Here);

     procedure Suite (
        Name                       : in     String);

     function Test_Name (
        Suite_Name                 : in     String;
        Routine_Name               : in     String
     ) return String;

--private
--
--   -- derive all aunit tests from this type
--   type AUnit_Tests_Type   is abstract new AUnit.Test_Cases.Test_Case with record
--      Set_Up_Completed     : Boolean := False;
--      Tear_Down_Completed  : Boolean := False;
--   end record;

end Ada_Lib.Unit_Test;
