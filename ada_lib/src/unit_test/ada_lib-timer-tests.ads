with Ada_Lib.Time;
with Ada_Lib.Unit_Test.Test_Cases;
--with AUnit.Test_Cases;
with AUnit.Test_Suites;

package Ada_Lib.Timer.Tests is

Suite_Name                    : constant String := "Timer";

   type Test_Type                is new Ada_Lib.Unit_Test.Test_Cases.
                                    Test_Case_Type with null record;

   overriding
   function Name (
      Test                       : in     Test_Type) return AUnit.Message_String;

   overriding
   procedure Register_Tests (
      Test                       : in out Test_Type);

-- overriding
-- procedure Set_Up (Test : in out Test_Type)
-- with post => Test.Verify_Set_Up;

   function Suite return AUnit.Test_Suites.Access_Test_Suite;

-- overriding
-- procedure Tear_Down (Test : in out Test_Type)
-- with post => Verify_Set_Up (Test);

   Debug                         : Boolean := False;

private

   generic
      with procedure Timed_Out;

   package Timeout_Package is

      type Timeout_Timer_Type    is new Event_Type with null record;

      overriding
      procedure Callback (
         Event             : in out Timeout_Timer_Type);

   end Timeout_Package;

   type Test_Timer_Type          is new Event_Type with record
      Occurred                   : Boolean := False;
      Occured_At                 : Ada_Lib.Time.Time_Type :=
                                    Ada_Lib.Time.No_Time;
      Start_At                   : Ada_Lib.Time.Time_Type :=
                                    Ada_Lib.Time.No_Time;
      Test_Ada_2022              : Integer := 0;
   end record;

   type Test_Timer_Access        is access all Test_Timer_Type;
   type Test_Timer_Class_Access  is access all Test_Timer_Type'class;

   function Allocate_Event (
      Offset                     : in     Duration;
      Description                : in     String := ""
   ) return Test_Timer_Class_Access;

   type Event_Pointers_Type      is array (Positive range <>) of
                                    Test_Timer_Class_Access;

   overriding
   procedure Callback (
      Event             : in out Test_Timer_Type);

end Ada_Lib.Timer.Tests;
