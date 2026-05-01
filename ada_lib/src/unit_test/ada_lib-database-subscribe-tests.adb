--with Ada_Lib.Test.Tests;
with AUnit.Assertions; use AUnit.Assertions;
-- with Ada_Lib.Database.Server.State;
with Ada_Lib.Database.Subscription.Tests;
--with Ada_Lib.Database.Unit_Test;
with ADa_Lib.Options.Unit_Test;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Trace; use Ada_Lib.Trace;
--with Ada_Lib.Unit_Test.Test_Cases;
--with Ada_Lib.Test; -- .Tests;

package body Ada_Lib.Database.Subscribe.Tests is


-- type Generic_Event_Type is new Ada_Lib.Database.Event.Event_Intervace with null record;

-- type Test_Suite_Type is new Ada_Lib.Test.Tests.Test_Suite_Type with null record;

-- type Local_Open_Close_Test_Type is new Server_Open_Close_Test_Type with null record;
   type Local_Test_Type is new Test_Type with null record;
--
-- type Remote_Open_Close_Test_Type is new Server_Open_Close_Test_Type with null record;
   type Remote_Test_Type is new Test_Type with null record;
--
-- type Content_Type is new Ada_Lib.Database.Event.Event_Content_Type with record
--    Update_Count            : Natural := 0;
-- end record;

-- type Content_Access        is access all Content_Type;

-- type Ada_Lib.Database.Subscription.Abstract_Subscription_Type is new Ada_Lib.Database.Subscription.Abstract_Subscription_Type with null record;

   Debug                         : Boolean renames Options.Unit_Test.
                                    Ada_Lib_Database_Unit_Test.Subscribe_Debug;
   Index_1                       : constant := 5;
   Index_2                       : constant := -1;
   Load_Subdirectory             : constant String := "tests/data/load_subscriptions/";
   Store_Subdirectory            : constant String := "tests/data/store_subscriptions/";
   Load_Name_1                   : constant String := "load_name_1";
   Load_Name_2                   : constant String := "load_name_2";
   Store_Name_1                  : constant String := "store_name_1";
   Store_Name_2                  : constant String := "store_name_2";
   Tag_1                         : constant String := "tag_1";
   Tag_2                         : constant String := "";
-- Value_1                       : constant String := "value_1";
-- Value_2                       : constant String := "value_2";

   ---------------------------------------------------------------
   overriding
   procedure Load (
      Table                      : in out Test_Table_Type;
      Path                       : in     String) is
   ---------------------------------------------------------------

   begin
Not_Implemented;
   end Load;

   ---------------------------------------------------------------
   procedure Load_Subscription (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

      ------------------------------------------------------------
      procedure Load (
         Path                    : in     String;
         Name                    : in     String;
         Index                   : in     Optional_Vector_Index_Type;
         Tag                     : in     String;
         Update_Mode             : in    Ada_Lib.Database.Updater.Update_Mode_Type) is
      pragma Unreferenced (Update_Mode);
      ------------------------------------------------------------

         Subscription            : constant Ada_Lib.Database.Updater.Abstract_Updater_Class_Access :=
                                    new Ada_Lib.Database.Subscription.Tests.Subscription_Type;
         File                    : Ada.Text_IO.File_Type;
         Got_Subscription        : Boolean := False;

      begin
         Log_In (Debug, Quote ("Path", Path));
         Ada.Text_IO.Open (File, Ada.Text_IO.In_File, Path);
         Subscription.Load (File,
--          Dynamic           => True,
            Got_Subscription  => Got_Subscription);
         Ada.Text_IO.Close (File);
         Assert (Got_Subscription, "could not load subscription");

         Assert (Subscription.Name_Value.Name.Coerce = Name, "wrong name loaded. got '" &
            Subscription.Name_Value.Name.Coerce & "' expected '" & Name);

         Assert (Subscription.Name_Value.Index = Index, "wrong index loaded. got " &
            Subscription.Name_Value.Index'img & " expected '" & Index'img);

         Assert (Subscription.Name_Value.Tag.Coerce = Tag, "wrong tag loaded. got '" &
            Subscription.Name_Value.Tag.Coerce & "' expected '" & Tag);

         Assert (Subscription.Name_Value.Value.Coerce = "", "wrong value loaded. got '" &
            Subscription.Name_Value.Value.Coerce & "' expected ''");
         Log_Out (Debug);
      end Load;
      ------------------------------------------------------------

   begin
      Log_In (Debug);
      Load (Load_Subdirectory & "test_subscription_1", Load_Name_1, Index_1, Tag_1, Ada_Lib.Database.Updater.Always);
      Load (Load_Subdirectory & "test_subscription_2", Load_Name_2, Index_2, Tag_2, Ada_Lib.Database.Updater.Unique);
      Log_Out (Debug);

   exception
      when Fault: others =>
         Trace_Exception (Fault);

   end Load_Subscription;

   ---------------------------------------------------------------
   overriding
   function Name (Test : Test_Type) return AUnit.Message_String is
   pragma Unreferenced (Test);
   ---------------------------------------------------------------

   begin
      return AUnit.Format (Suite_Name);
   end Name;

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

--    Test.Add_Routine (AUnit.Test_Cases.Routine_Spec'(
--      Routine        => Store_Load_Subscription'access,
--      Routine_Name   => AUnit.Format ("Store_Load_Subscription")));

      Log_Out (Debug);
   end Register_Tests;

   ---------------------------------------------------------------
   overriding
   procedure Set_Up (
      Test                       : in out Test_Type) is
   ---------------------------------------------------------------

      Subscription_1             : constant Ada_Lib.Database.Updater.Abstract_Updater_Class_Access :=
                                    new Ada_Lib.Database.Subscription.Tests.Subscription_Type;
      Subscription_2             : constant Ada_Lib.Database.Updater.Abstract_Updater_Class_Access :=
                                    new Ada_Lib.Database.Subscription.Tests.Subscription_Type;

   begin
      Log_In (Debug or Trace_Set_Up_Tear_Down);
      Subscription_1.Initialize (
         Ada_Tag           => Subscription_1.all'tag,
         DBDaemon_Tag      => Tag_1,
--       Dynamic        => True,
         Index          => Index_1,
         Name           =>Store_Name_1,
--       Update_Count   => 0,
         Update_Mode    => Ada_Lib.Database.Updater.Always);
--       Value          =>Value_1);

      Subscription_2.Initialize (
         Ada_Tag           => Subscription_2.all'tag,
         DBDaemon_Tag      => Tag_2,
--       Dynamic        => True,
         Index          => Index_2,
         Name           =>Store_Name_2,
--       Update_Count   => 0,
         Update_Mode    => Ada_Lib.Database.Updater.Always);
--       Value          =>Value_2);

      Test.Table.Add_Subscription (Ada_Lib.Database.Updater.Updater_Interface_Class_Access (Subscription_1));
      Test.Table.Add_Subscription (Ada_Lib.Database.Updater.Updater_Interface_Class_Access (Subscription_2));
      Test.Subscribed := True;
      Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type (Test).Set_Up;
      Log_Out (Debug or Trace_Set_Up_Tear_Down);
   end Set_Up;

-- ---------------------------------------------------------------
-- procedure Store_Load_Subscription (
--    Test                       : in out AUnit.Test_Cases.Test_Case'class) is
-- ---------------------------------------------------------------
--
--    Counter                    : Natural := 0;
--    Subscriptions              : constant array (1 .. 2) of Ada_Lib.Database.Subscription.Subscription_Constant_Access := (
--                                  Simple_Subscription'access,
--                                  Complex_Subscription'access
--                               );
-- begin
--    for Subscription of Subscriptions loop
--       Counter := Counter + 1;
--
--       declare
--          File_Name            : constant String := Subdirectory & "subscription" &
--                                  Ada_Lib.Strings.Trim (Counter'img);
--
--       begin
--          declare
--             File              : Ada.Text_IO.File_Type;
--
--          begin
--             Log (Debug, Here, Who & Quote (" store file", File_Name));
--             Ada.Text_IO.Create (File, Ada.Text_IO.Out_File, File_Name);
--             Subscription.Store (File);
--             Ada.Text_IO.Close (File);
--          end;
--
--          declare
--             File              : Ada.Text_IO.File_Type;
--             Loaded_Subscription
--                               : Ada_Lib.Database.Subscription.Abstract_Subscription_Type;
--
--          begin
--             Log (Debug, Here, Who & Quote (" load file", File_Name));
--             Ada.Text_IO.Open (File, Ada.Text_IO.In_File, File_Name);
--             Loaded_Subscription.Load (File);
--             Ada.Text_IO.Close (File);
--             Assert (Loaded_Subscription = Subscription.all, "loaded subscription does not match");
--          end;
--       end;
--    end loop;
--
--    Log (Debug, Here, Who & " exit");
-- end Store_Load_Subscription;

   ---------------------------------------------------------------
   procedure Store_Subscription (
      Test                       : in out AUnit.Test_Cases.Test_Case'class) is
   ---------------------------------------------------------------

      Local_Test                 : Test_Type renames Test_Type (Test);
      Path                       : constant String := Store_Subdirectory & "test_subscribe";

   begin
      Log (Debug, Here, Who & " store " & Quote (" quote", Path));
      Assert (Local_Test.Subscribed, " Set_Up failed");
      Local_Test.Table.Store (Path);
      Log (Debug, Here, Who & " exit");
   end Store_Subscription;

   ---------------------------------------------------------------
   function Subscribe_Suite (
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
      Ada_Lib.Unit_Test.Suite (Suite_Name);  -- used for listing suites
      Test_Suite.Add_Test (Tests);
      return Test_Suite;
   end Subscribe_Suite;

   ---------------------------------------------------------------
   overriding
   procedure Tear_Down (
      Test                       : in out Test_Type) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug or Trace_Set_Up_Tear_Down);
      Test.Table.Delete_All;
      Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type (Test).Tear_Down;
      Log_Out (Debug or Trace_Set_Up_Tear_Down);
   end Tear_Down;

begin
   if Trace_Tests then
      Debug := Trace_Tests;
   end if;

end Ada_Lib.Database.Subscribe.Tests;

