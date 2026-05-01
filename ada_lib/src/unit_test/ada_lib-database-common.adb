with Ada.Exceptions;
with Ada.Text_IO;use Ada.Text_IO;
--with Ada_Lib.Test;
with AUnit.Assertions; use AUnit.Assertions;
with Ada_Lib.Database.Wild;
with Ada_Lib.Options;
with Ada_Lib.Strings;
with Ada_Lib.Trace; use Ada_Lib.Trace;

package body Ada_Lib.Database.Common is

   Debug    : Boolean renames Options.Ada_Lib_Database.Trace;

   ---------------------------------------------------------------
   procedure Wild_Get ( -- needs new dbdaemon
      Database                   : in out Ada_Lib.Database.Database_Type'class) is
   ---------------------------------------------------------------

      subtype Test_Parameter_Type is Integer range 0 .. 3;
      subtype Test_Index_Type is Test_Parameter_Type range 1 .. 3;
      subtype String_Type is String (1 .. 3);
      type Test_Fixture_Type is record
         Name                       : String_Type;
         Value                      : String_Type;
      end record;
      type Tests_Type is array (Test_Index_Type) of Test_Fixture_Type;

      Failed_Count                  : Natural := 0;
      Tests                         : Tests_Type;

      ------------------------------------------------------------
      procedure Check_Values (
         First                   : in     Test_Index_Type;
         Last                    : in     Test_Index_Type;
         Response                : in     Ada_Lib.Database.Wild.Response_Type;
         Description             : in     String) is
      ------------------------------------------------------------

         Response_Index          : Natural := 1;

      begin
         for Index in First .. Last loop
            declare
               Message           : constant String := "wrong name for " & Description &
                                    "wrong name at" & Index'img & " got '" & Response.Name (Response_Index) &
                                    "' expected " & Tests (Index).Name;
            begin
               if not Assert (Tests (Index).Name = Response.Name (Response_Index), Message) then
                  Put_Line (Message);
               end if;
            end;

            declare
               Message           : constant String := "wrong value for " & Description &
                                    "wrong value at" & Index'img & " got '" & Response.Value (Response_Index) &
                                    "' expected " & Tests (Index).Value;
            begin
               if not Assert (Tests (Index).Value = Response.Value (Response_Index), Message) then
                  Put_Line (Message);
               end if;
            end;

            Response_Index := Response_Index + 1;
         end loop;
      end Check_Values;

      ------------------------------------------------------------
      procedure Do_Test (
         Pattern              : in     String;
         Expected_Count       : in     Natural;
         Assert_Message       : in     String;
         Check_First          : in     Test_Parameter_Type;
         Check_Last           : in     Test_Parameter_Type) is
      ------------------------------------------------------------

         Response                : Ada_Lib.Database.Wild.Response_Type;

      begin
         Log (Debug, Here, Who & " pattern '" & Pattern & "' expected count" & Expected_Count'img);
         Response := Ada_Lib.Database.Wild.Wild_Get (Database, Pattern);
         if not Assert (Response.Count = Expected_Count, Assert_Message & " expected" & Expected_Count'img &
               " got" & Response.Count'img) then
            Put_Line (Pattern & " expected" & Expected_Count'img & " got" & Response.Count'img);
         end if;

         if Check_First > 0 then
            Check_Values (Check_First, Check_Last, Response, Pattern);
         end if;

      exception
         when Fault: Ada_Lib.Database.Wild.Not_Found =>
            Put_Line ("wild get failed with " & Ada.Exceptions.Exception_Message (Fault) &
               " assertion message " & Assert_Message & " for pattern '" & Pattern &
               "' expected" & Expected_Count'img & " first" & Check_First'img & " last" & Check_Last'img);
            Failed_Count := Failed_Count + 1;

      end Do_Test;
      ------------------------------------------------------------

   begin
      Log (Debug, Here, Who);
      Assert (Database.Is_Open, "data base not open");

      for Unique_Counter in Test_Index_Type'range loop
         Tests (Unique_Counter).Name := "a" & Ada_Lib.Strings.Trim (Unique_Counter'img) & "b";
         Tests (Unique_Counter).Value := "x" & Ada_Lib.Strings.Trim (Unique_Counter'img) & "y";

         Database.Post (Tests (Unique_Counter).Name, Ada_Lib.Database.No_Vector_Index, "",
            Tests (Unique_Counter).Value);
      end loop;

      Do_Test ("/abc", 0, "Null not empty", 0, 0);
      Do_Test ("/a.b", 3, "wrong count for /a.b",1, 3);
      Do_Test ("/2+", 1, "wrong count for /2+", 2, 2);
      Do_Test ("/.+", 3, "wrong count for /.+", 1, 3);
      Assert (Failed_Count = 0, Failed_Count'img & " wild get tests failed");
   end Wild_Get;



end Ada_Lib.Database.Common;
