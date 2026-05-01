with Ada.Text_IO;use Ada.Text_IO;
with Ada_Lib.Database.Updater;
with Ada_Lib.Options.Unit_Test;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
--with Ada_Lib.Test; --.Tests;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Trace; use Ada_Lib.Trace;
--with Ada_Lib.Unit_Test.Test_Cases;
with AUnit.Assertions; use AUnit.Assertions;
--with AUnit.Test_Suites;

pragma Elaborate_All (Ada_Lib.Database.Updater);

package body Ada_Lib.Database.Subscription.Tests is

-- type Test_Suite_Type is new Ada_Lib.Test.Tests.Test_Suite_Type with null record;

   type Local_Test_Type is new Test_Type with null record;
   type Remote_Test_Type is new Test_Type with null record;

   Complex_Subscription : aliased Subscription_Type;
   Debug                : Boolean renames Options.Unit_Test.
                           Ada_Lib_Database_Unit_Test.Subscribe_Debug;
   Load_Subdirectory    : constant String := "tests/data/load_subscriptions/";
   Store_Subdirectory   : constant String := "tests/data/store_subscriptions/";
   Simple_Subscription  : aliased Subscription_Type;

-- ---------------------------------------------------------------
-- function "="" (
--    Left, Right                : in     Subscription_Type
-- ) return Boolean is
-- ---------------------------------------------------------------
--
-- begin
--    return Ada_Lib.Database.Updater.Abstract_Updater_Type (Left).Equal (
--       Ada_Lib.Database.Updater.Abstract_Updater_Type (Right));
-- end Equal;

   ---------------------------------------------------------------
   overriding
   procedure Load (
      Table                      : in out Subscription_Table_Type;
      Path                       : in     String) is
   ---------------------------------------------------------------

   begin
not_implemented;
   end Load;

--   ---------------------------------------------------------------
--   procedure Load (
--      Subscription               :    out Subscription_Type;
--      File                       : in out Ada.Text_IO.File_Type;
--      Got_Subscription           :    out Boolean) is
--   ---------------------------------------------------------------
--
--   begin
--      Log_In (Debug);
--      Ada_Lib.Database.Updater.Abstract_Updater_Type'class (Subscription).Load (File,
----       Dynamic           => False,
--         Got_Subscription  => Got_Subscription);
--      Log_Out (Debug);
--   end Load;
--
   ---------------------------------------------------------------
   procedure Load_Subscription (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

      Loaded_Subscription        : Subscription_Type;
      File                       : Ada.Text_IO.File_Type;
      Got_Subscription           : Boolean := False;

   begin
      Log (Debug, Here, Who & " enter" & Quote (" load file", "test_subscription"));
      Ada.Text_IO.Open (File, Ada.Text_IO.In_File, Load_Subdirectory & "test_subscription");
      Loaded_Subscription.Load (File, Got_Subscription);
      Ada.Text_IO.Close (File);
      Assert (Got_Subscription, "could not load subscription");
      if Loaded_Subscription /= Simple_Subscription then
         Loaded_Subscription.Dump ("loaded");
         Simple_Subscription.Dump ("simple");
         Assert (False, "loaded subscription does not match");
      end if;
      Log (Debug, Here, Who & " exit");
   end Load_Subscription;

   ---------------------------------------------------------------
   overriding
   function Name (Test : Test_Type) return AUnit.Message_String is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

   begin
      return AUnit.Format (Suite_Name);
   end Name;

   ---------------------------------------------------------------
   overriding
   function Name_Value (
      Subscription               : in     Subscription_Type
   ) return Name_Value_Type'class is
   ---------------------------------------------------------------

--    Result                     : Name_Value_Type;
   begin
      return Name_Value_Type'(
         Ada_Lib.Database.Name_Index_Tag_Type'(
            Index          => Subscription.Index,
            Name           => Ada_Lib.Strings.Unlimited.Coerce (Subscription.Name),
            Tag            => Ada_Lib.Strings.Unlimited.Coerce (Subscription.DBDaemon_Tag)
         ) with
            Value       => Ada_Lib.Strings.Unlimited.Null_String);
   end Name_Value;

   --------------------------------------------------
   overriding
   procedure Register_Tests (Test : in out Test_Type) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug);

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
        Routine        => Load_Subscription'access,
        Routine_Name   => AUnit.Format ("Load_Subscription")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
        Routine        => Store_Subscription'access,
        Routine_Name   => AUnit.Format ("Store_Subscription")));

      Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
        Routine        => Store_Load_Subscription'access,
        Routine_Name   => AUnit.Format ("Store_Load_Subscription")));

      Log_Out (Debug);
   end Register_Tests;

   ---------------------------------------------------------------
   procedure Store_Load_Subscription (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

      Counter                    : Natural := 0;
      Subscriptions              : constant array (1 .. 2) of
                                    Ada_Lib.Database.Updater.Abstract_Updater_Constant_Class_Access := (
                                       Simple_Subscription'access,
                                       Complex_Subscription'access
                                 );
   begin
      for Subscription of Subscriptions loop
         Counter := Counter + 1;

         declare
            File_Name            : constant String := Store_Subdirectory & "subscription" &
                                    Ada_Lib.Strings.Trim (Counter'img);

         begin
            declare
               File              : Ada.Text_IO.File_Type;

            begin
               Log_Here (Debug, "counter" & Counter'img & Quote (" store file", File_Name));
               Ada.Text_IO.Create (File, Ada.Text_IO.Out_File, File_Name);
               Subscription.Store (File);
               Ada.Text_IO.Close (File);
            end;

            declare
               File              : Ada.Text_IO.File_Type;
               Got_Subscription  : Boolean := False;
               Loaded_Subscription
                                 : Subscription_Type;

            begin
               Log (Debug, Here, Who & Quote (" load file", File_Name));
               Ada.Text_IO.Open (File, Ada.Text_IO.In_File, File_Name);
               Loaded_Subscription.Load (File, Got_Subscription);
               Ada.Text_IO.Close (File);
               Assert (Got_Subscription, "could not load subscription");
               Assert (Loaded_Subscription = Subscription_Type (Subscription.all),
                  "loaded subscription does not match." &
                  " Loaded " & Loaded_Subscription.Image & " Original " & Subscription.Image);
            end;
         end;
      end loop;

      Log (Debug, Here, Who & " exit");
   end Store_Load_Subscription;

   ---------------------------------------------------------------
   procedure Store_Subscription (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

      File                       : Ada.Text_IO.File_Type;

   begin
      Log (Debug, Here, Who & " enter");
      Ada.Text_IO.Create (File, Ada.Text_IO.Out_File, Store_Subdirectory & "stored_subscription");
      Simple_Subscription.Store (File);
      Ada.Text_IO.Close (File);
      Log (Debug, Here, Who & " exit");
   end Store_Subscription;

   ---------------------------------------------------------------
   function Subscription_Suite (
      Which_Host                 : in    Ada_Lib.Database.Which_Host_Type
   ) return AUnit.Test_Suites.Access_Test_Suite is
   ---------------------------------------------------------------

--    Test_Suite                 : constant AUnit.Test_Suites.Access_Test_Suite :=
--                                  new Test_Suite_Type;
      Test_Suite                 : constant AUnit.Test_Suites.Access_Test_Suite :=
                                    new AUnit.Test_Suites.Test_Suite;
      Tests                      : constant Ada_Lib.Unit_Test.Test_Cases.Test_Case_Class_Access :=
                                    Ada_Lib.Unit_Test.Test_Cases.Test_Case_Class_Access'(case Which_Host is

                                       when Ada_Lib.Database.Local =>
                                          new Local_Test_Type,

                                       when Ada_Lib.Database.Remote =>
                                          new Remote_Test_Type,

                                       when Ada_Lib.Database.No_Host |
                                            Ada_Lib.Database.Unset =>
                                          Null
                                    );

   begin
      Log (Debug, Here, Who & " Which_Host " & Which_Host'img);
      Ada_Lib.Unit_Test.Suite (Suite_Name);
      Test_Suite.Add_Test (Tests);
      return Test_Suite;
   end Subscription_Suite;

  ---------------------------------------------------------------------------------
  overriding
  procedure Update (
     Subscription               : in out Subscription_Type;
     Address                    : in     Ada_Lib.Database.Updater.Abstract_Address_Type'class;
     Tag                        : in     String;
     Value                      : in     String;
     Update_Kind                : in     Ada_Lib.Database.Updater.Update_Kind_Type;
     From                       : in     String := Ada_Lib.Trace.Here) is
  ---------------------------------------------------------------------------------

  begin
     Log_In (Debug_Subscribe, Subscription.Image);
--      Subscription.Set_Value (Value);

--      case Update_Kind is
--
--         when Ada_Lib.Database.Updater.Internal =>
--            null;
--
--         when others =>
--            Subscription.Update_Count := Subscription.Update_Count + 1;
--
--      end case;
     Log (Debug_Subscribe, Here, Who & Subscription.Image &
        " update count" & Subscription.Update_Count'img & " update kind " & Update_Kind'img &
        Tag_Name (" subscription", Subscription_Type'class (Subscription)'tag) &
        " subscription address " & Ada_Lib.Strings.Image (Subscription'address) & " from " & From);
  end Update;

begin
   Complex_Subscription.Initialize (
      Ada_Tag           => Subscription_Type'class (Complex_Subscription)'tag,
      DBDaemon_Tag      => "tag",
--    Dynamic     => False,
      Index       => 5,
      Name        => "Complex",
--    Update_Count=> 0,
      Update_Mode => Ada_Lib.Database.Updater.Unique);
--    Value       => "");

   Simple_Subscription.Initialize (
      Ada_Tag           => Subscription_Type'class (Simple_Subscription)'tag,
      DBDaemon_Tag      => "",
--    Dynamic     => False,
      Index       => -1,
      Name        => "abc",
--    Update_Count=> 0,
      Update_Mode => Ada_Lib.Database.Updater.Always);
--    Value       => "");

end Ada_Lib.Database.Subscription.Tests;

