with Ada.Exceptions;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with AUnit.Test_Fixtures;

package Ada_Lib.Unit_Test.Fixtures is

   Failed                        : exception;

   type Base_Test_Fixtures_Type is abstract new AUnit.Test_Fixtures.Test_Fixture with record
      Async_Failure_Message      : Ada_Lib.Strings.Unlimited.String_Type;
      Failure_From               : Ada_Lib.Strings.Unlimited.String_Type;
   end record;

   type Base_Test_Fixtures_Access
                                 is access Base_Test_Fixtures_Type'class;

   function Verify_Set_Up (
      Test                       : in     Base_Test_Fixtures_Type
   ) return Boolean is abstract;

   function Verify_Tear_Down (
      Test                       : in     Base_Test_Fixtures_Type
   ) return Boolean is abstract;


   procedure Exception_Assert (
      Fault                      : Ada.Exceptions.Exception_Occurrence;
      Here                       : in     String;
      Who                        : in     String);

   function Get_Async_Message
   return String;

-- function Get_Which_Host (
--    Test                       : in   Base_Test_Fixtures_Type
--  ) return Which_Host_Type is abstract;

-- procedure Init_Test (
--    Test                       : in out Base_Test_Fixtures_Type);

   procedure Set_Async_Failure_Message (
      Fault                      : in     Ada.Exceptions.Exception_Occurrence;
      From                       : in     String);

   procedure Set_Async_Failure_Message (
      Message                    : in     String;
      From                       : in     String);

   procedure Set_Async_Failure_Message (
      Message                    : in     Ada_Lib.Strings.Unlimited.String_Type;
      From                       : in     String);

   overriding
   procedure Set_Up (
      Test                       : in out Base_Test_Fixtures_Type
   ) with Pre => not Base_Test_Fixtures_Type'class (Test).Verify_Set_Up,
          Post => Base_Test_Fixtures_Type'class (Test).Verify_Set_Up;

   procedure Set_Up_Exception (
      Test                       : in out Base_Test_Fixtures_Type;
      Fault                      : Ada.Exceptions.Exception_Occurrence;
      Here                       : in     String;
      Who                        : in     String;
      Message                    : in     String := "");

   procedure Set_Up_Failure (
      Test                       : in     Base_Test_Fixtures_Type;
      Condition                  : in     Boolean;
      Here                       : in     String;
      Who                        : in     String;
      Message                    : in     String := "");

   overriding
   procedure Tear_Down (
      Test                       : in out Base_Test_Fixtures_Type);

   procedure Tear_Down_Exception (
      Test                       : in out Base_Test_Fixtures_Type;
      Fault                      : in     Ada.Exceptions.Exception_Occurrence;
      Here                       : in     String;
      Who                        : in     String;
      Message                    : in     String := "");

   procedure Tear_Down_Failure (
      Test                       : in     Base_Test_Fixtures_Type;
      Condition                  : in     Boolean;
      Here                       : in     String;
      Who                        : in     String;
      Message                    : in     String := "");

   function Was_There_An_Async_Failure
   return Boolean;

end Ada_Lib.Unit_Test.Fixtures;
