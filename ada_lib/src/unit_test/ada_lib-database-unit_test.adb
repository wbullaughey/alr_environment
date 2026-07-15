with Ada.Exceptions;
--with Ada.Text_IO;use Ada.Text_IO;
with AUnit.Assertions; use AUnit.Assertions;
with Ada_Lib.Database.Connection;
with Ada_Lib.Options.AUnit_Lib;
--with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Trace; use Ada_Lib.Trace;
--with Ada_Lib.Unit_Test.Test_Cases;

package body Ada_Lib.Database.Unit_Test is

-- use type Ada_Lib.Strings.Unlimited.String_Type;

   ---------------------------------------------------------------
   procedure Check_Database_Value (
      Test                       : in out Test_Case_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      Tag                        : in     String;
      Value                      : in     String) is
   ---------------------------------------------------------------

      Name_Value                 : constant Name_Value_Class_Type := Test.Get (Name, Index, Tag);

   begin
      Assert (Name_Value.Value = Value,
         "wrong value in database for '" & Name &
         "' expected '" & Value & "' got '" & Name_Value.Value.Coerce & "'");
   end Check_Database_Value;

--   ----------------------------------------------------------------
--   function Database_Options return Ada_Lib.Database.Remote_Instance.Options_Type'class is
--   ----------------------------------------------------------------
--
--   begin
-- log_here (tag_name (Ada_Lib.Options.Get_Options.all'tag));
--      return Options_Type'class (Ada_Lib.Options.Get_Options.all).Database_Options;
--   end Database_Options;

   ----------------------------------------------------------------
   function Get (
      Test                       : in     Test_Case_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      Tag                        : in     String
   ) return String is
   ----------------------------------------------------------------

      Value                      : constant String := Test.Database.all.Get (Name, Index, Tag);

   begin
      Log_Here (Debug, " name '" & Name & "' value '" & Value & "'");
      return Value;
   end Get;

   ----------------------------------------------------------------
   function Get (
      Test                       : in     Test_Case_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      Tag                        : in     String
   ) return Name_Value_Class_Type is
   ----------------------------------------------------------------

      Result                    : constant Name_Value_Class_Type := Test.Database.all.Get (Name, Index, Tag);

   begin
      Log_Here (Debug, Ada_Lib.Strings.Unlimited.Quote ("name", Result.Name) &
         Ada_Lib.Strings.Unlimited.Quote ("value", Result.Value));
      return Result;
   end Get;

   ----------------------------------------------------------------
   function Get_Database  (
      Test                       : in     Test_Case_Type
   ) return Database_Class_Access is
   ----------------------------------------------------------------

   begin
      Log_Here (Debug);
      return Test.Database;
   end Get_Database;

-- ----------------------------------------------------------------
-- function Get_Options (
--    Test                       : in     Test_Case_Type
-- ) return Ada_Lib.Options.Program_Options_Constant_Class_Access is
-- ----------------------------------------------------------------
--
-- begin
--    return Ada_Lib.Options.Program_Options_Constant_Class_Access (Test.Options);
-- end Get_Options;

   ----------------------------------------------------------------
   function Has_Database (
      Test                       : in     Test_Case_Type
   ) return Boolean is
   ----------------------------------------------------------------

      Result   : constant Boolean := Test.Database /= Null;

   begin
      return Log_Here (Result, Trace_Pre_Post (Result, Debug or Trace_Pre_Post_Conditions),
         "no database set");
   end Has_Database;

   ----------------------------------------------------------------
   function Host_Name (
      Test                    : in     Test_Case_Type
   ) return String is
   ----------------------------------------------------------------

--    Options           : Ada_Lib.Options.AUnit_Lib.Aunit_Program_Options_Type'class
--                         renames Ada_Lib.Options.AUnit_Lib.
--                            Aunit_Program_Options_Constant_Class_Access (
--                               Ada_Lib.Options.Verification.Get_Ada_Lib_Read_Only_Nested_Options).all;
   begin
not_implemented;
return "";
--    return (case Test.Which_Host is
--       when Local => Local_Host_Name,
--       when Remote => Options.Database_Options.Remote_Host.Coerce,
--       when No_Host | Unset => ""
--    );
   end Host_Name;

   ----------------------------------------------------------------
   function Host_Port (
      Test                       : in     Test_Case_Type
   ) return Ada_Lib.Database.Port_Type is
   ----------------------------------------------------------------

--    Options           : Ada_Lib.Options.AUnit_Lib.Aunit_Program_Options_Type'class
--                         renames Ada_Lib.Options.AUnit_Lib.
--                            Aunit_Program_Options_Constant_Class_Access (
--                               Ada_Lib.Options.Verification.Get_Ada_Lib_Read_Only_Nested_Options).all;
   begin
not_implemented;
return Ada_Lib.Database.Port_Type'last;
--    return Options.Database_Options.Port;
   end Host_Port;

-- ----------------------------------------------------------------
-- function Manual (
--    Options                    : in     Options_Type
-- ) return Boolean is
-- ----------------------------------------------------------------
--
-- begin
--    return Options.Unit_Test_Options.Manual;
-- end Manual;
--
-- ----------------------------------------------------------------
-- function Pause (
--    Options                    : in     Options_Type
-- ) return Boolean is
-- ----------------------------------------------------------------
--
-- begin
--    return Options.Unit_Test_Options.Pause;
-- end Pause;

   ----------------------------------------------------------------
   procedure Post (
      Test                       : in     Test_Case_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      Tag                        : in     String;
      Value                      : in     String) is
   ----------------------------------------------------------------

   begin
      Log_Here (Debug, " name '" & Name & "' value '" & Value & "'");
      Test.Database.Post (Name, Index, Tag, Value);
   end Post;

   ----------------------------------------------------------------
   -- selects which database and initializes Database in the test
   -- if not No_Host verifies its open
   overriding
   procedure Set_Up (
      Test                       : in out Test_Case_Type) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug or Trace_Set_Up_Tear_Down, "which host " & Test.Which_Host'img);

      Test.Set_Up_Failure (Test.Database /= Null, Here, Who,
         "Test.Database is null");

      case Test.Which_Host is

         when Local =>
            Test.Database :=
               new Ada_Lib.Database.Connection.Local_Database_Type;
--          Test.Database.Initialize  (Host, Port, User, DBDaemon_Path);
            Test.Set_Up_Failure (Test.Database.Is_Open, Here, Who,
               "Local database not open");

         when Remote =>
            Test.Database :=
               new Ada_Lib.Database.Connection.Remote_Database_Type;
            Test.Set_Up_Failure (Test.Database.Is_Open, Here, Who,
               "remote database not open");

         when No_Host =>
            Null;

         when Unset =>
            Test.Set_Up_Failure (False, Here, Who, "which database not set");
      end case;

      if Test.Which_Host /= No_Host then
         Log (Debug, Here, Who & " test database set");
         Test.Set_Up_Failure (Test.Database.Is_Open, Here, Who,
            "database not open");
      end if;

      Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type (Test).Set_Up;
      Log_Out (Debug or Trace_Set_Up_Tear_Down);

   exception
      when Fault: others =>
         Trace_Message_Exception (Fault, Who, Here);
         Test.Set_Up_Message_Exception (Fault, Here, Who, "exception " &
            Ada.Exceptions.Exception_Message (Fault));
         Log_Out (Debug or Trace_Set_Up_Tear_Down);

   end Set_Up;

   ---------------------------------------------------------------
   overriding
   procedure Tear_Down (
      Test                       : in out Test_Case_Type) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug or Trace_Set_Up_Tear_Down, "close database");
      if Test.Which_Host /= No_Host and then Test.Has_Database then
         Test.Database.Delete_All;
      end if;
      Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type (Test).Tear_Down;

      Log_Out (Debug or Trace_Set_Up_Tear_Down);
   end Tear_Down;

   ----------------------------------------------------------------------------
   overriding
   function Test (
      Suite                      : in     Test_Suite_Type
   ) return Boolean is       -- return true if test can be run
   ----------------------------------------------------------------------------

--    Options           : Ada_Lib.Options.AUnit_Lib.Aunit_Program_Options_Type'class
--                         renames Ada_Lib.Options.AUnit_Lib.
--                            Aunit_Program_Options_Constant_Class_Access (
--                               Ada_Lib.Options.Verification.Get_Ada_Lib_Read_Only_Nested_Options).all;
   begin
not_implemented;
--    Log_In (Debug, "Has_Local_DBDaemon " & Options.Database_Options.Has_Local_DBDaemon'img &
--       (if Options.Database_Options.Remote_Host.Length = 0 then " no Remote_Host" else " Remote_Host dbdaemon.all "));
--
--    if Options.Database_Options.Has_Local_DBDaemon or else Options.Database_Options.Remote_Host.Length > 0 then
--       Put_Line ("start Database Test Suite");
--       return True;
--    end if;
--
--    Put_Line ("skip Database.Get_Put_Suite");
--    Log_Out (Debug);
      return False;
   end Test;

-- ----------------------------------------------------------------------------
-- function Unit_Test_Options (
--    Options                    : in     Options_Type
-- ) return GNOGA_Options.Database.AUnit.Options_Constant_Class_Access is
-- ----------------------------------------------------------------------------
--
-- begin
--    return Options.Unit_Test_Options'unchecked_access;
-- end Unit_Test_Options;

   ----------------------------------------------------------------------------
   function Which_Host (
      Test                       : in     Test_Case_Type
   ) return Which_Host_Type is
   ----------------------------------------------------------------------------

      Options  : Ada_Lib.Options.AUnit_Lib.Aunit_Program_Options_Type'class
                  renames Ada_Lib.Options.AUnit_Lib.
                     Aunit_Program_Options_Constant_Class_Access (
                        Ada_Lib.Options.Verification.
                           Get_Ada_Lib_Read_Only_Program_Options).all;
   begin
      return Options.Database_Options.Which_Host;
   end Which_Host;

   ----------------------------------------------------------------------------
begin
   if Trace_Tests then
      Debug := Trace_Tests;
   end if;
--Debug := True;
   Log_Here (Elaborate);
end Ada_Lib.Database.Unit_Test;



