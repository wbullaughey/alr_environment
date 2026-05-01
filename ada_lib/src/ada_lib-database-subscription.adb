with Ada.Text_IO;use Ada.Text_IO;
with Ada.Unchecked_Deallocation;
--with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
--with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace; use Ada_Lib.Trace;

package body Ada_Lib.Database.Subscription is

   use type Ada_Lib.Database.Updater.Update_Mode_Type;
-- use type Ada_Lib.Strings.Unlimited.String_Type;

   procedure Free_It is new Ada.Unchecked_Deallocation (
      Name     => Subscription_Access,
      Object   => Subscription_Type);

   ---------------------------------------------------------------------------------
   function "=" (
      Left, Right                : in     Subscription_Type
   ) return Boolean is
   ---------------------------------------------------------------------------------

   begin
      Log_Here (Debug_Subscribe, " index left " & Left.Index'img & " right " & Right.Index'img &
         " name value left " & Left.Name_Value.Image & " right " & Right.Name_Value.Image &
         " update mode left " & Left.Update_Mode'img & " right " & Right.Update_Mode'img);

      return Left.Name_Value = Right.Name_Value and then
             Left.Update_Count = Right.Update_Count and then
             Left.Update_Mode = Right.Update_Mode;
   end "=";

   ---------------------------------------------------------------------------------
   function Check_Name (
      Subscription               : in     Subscription_Type;
      Name                       : in     String
   ) return Boolean is
   ---------------------------------------------------------------------------------

   begin
      return Subscription.Name_Value.Name = Name;
   end Check_Name;

   ---------------------------------------------------------------
   function Create (
      Name                       : in     String;
      Index                      : in     Ada_Lib.Database.Optional_Vector_Index_Type;
      Tag                        : in     String;
      Value                      : in     String;
      Update_Mode                : in     Ada_Lib.Database.Updater.Update_Mode_Type;
      Update_Count               : in     Natural := 0
   ) return Subscription_Type is
   ---------------------------------------------------------------

   begin
      return Subscription_Type'(False, Name_Value_Type'(
         Ada_Lib.Strings.Unlimited.Coerce (Name), Index,
         Ada_Lib.Strings.Unlimited.Coerce (Tag),
         Ada_Lib.Strings.Unlimited.Coerce (Value)), Update_Count, Update_Mode);
   end Create;

   ---------------------------------------------------------------------------------
   procedure Dump (
      Subscription               : in     Subscription_Type) is
   ---------------------------------------------------------------------------------

   begin
      Log_Here (Debug_Subscribe, " enter");
      Put_Line (Subscription.Name_Value.Image & " update mode " & Subscription.Update_Mode'img &
         " count" & Subscription.Update_Count'img);
   end Dump;

   ---------------------------------------------------------------------------------
   function Equal (
      Left, Right                : in     Subscription_Class_Access
   ) return Boolean is
   ---------------------------------------------------------------------------------

   begin
      return Left = Right or else Left.all = Right.all;
   end Equal;

   procedure Free (
      Subscription               : in out Subscription_Class_Access) is
   ---------------------------------------------------------------------------------

   begin
      Free_It (Subscription_Access (Subscription));
   end Free;

   ---------------------------------------------------------------
   function Image (
      Subscription               : in     Subscription_Type
   ) return String is
   ---------------------------------------------------------------

   begin
      return " subscription: dynamic:" & Subscription.Dynamic'img & " name/value " &
         Subscription.Name_Value.Image & " update count" & Subscription.Update_Count'img &
         " update mode " & Subscription.Update_Mode'img;
   end Image;

   ---------------------------------------------------------------------------------
   procedure Increment_Count (
      Subscription               : in out Subscription_Type) is
   ---------------------------------------------------------------------------------

   begin
      Subscription.Update_Count := Subscription.Update_Count + 1;
      Log_Here (Debug_Subscribe, Subscription.Update_Count'img);
   end Increment_Count;

   ---------------------------------------------------------------------------------
   function Index (
      Subscription               : in     Subscription_Type
   ) return Optional_Vector_Index_Type is
   ---------------------------------------------------------------------------------

   begin
      return Subscription.Name_Value.Index;
   end Index;

   ---------------------------------------------------------------------------------
   procedure Initialize (
      Subscription               : in out Subscription_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      Tag                        : in     String;
      Value                      : in     String;
      Update_Mode                : in     Ada_Lib.Database.Updater.Update_Mode_Type) is
   ---------------------------------------------------------------------------------

   begin
      Subscription.Name_Value := Create (Name, Index, Tag, Value);
      Subscription.Update_Mode := Update_Mode;
      Log_Here (Debug_Subscribe, " name value " & Subscription.Name_Value.Image &
         " Update_Mode " & Update_Mode'img & " address " & Ada_Lib.Strings.Image (Subscription'address) &
         Tag_Name (" subscription", Subscription_Type'class (Subscription)'tag));
   end Initialize;

   ---------------------------------------------------------------------------------
   function Is_Dyanmic (
      Subscription               : in     Subscription_Type
   ) return Boolean is
   ---------------------------------------------------------------------------------

   begin
      return Subscription.Dynamic;
   end Is_Dyanmic;

   ---------------------------------------------------------------------------------
   function Last_Value (
      Subscription               : in     Subscription_Type
   ) return Ada_Lib.Strings.Unlimited.String_Type is
   ---------------------------------------------------------------------------------

   begin
      return Subscription.Name_Value.Value;
   end Last_Value;

   ---------------------------------------------------------------------------------
   procedure Load (
      Subscription               :    out Subscription_Type;
      File                       : in out Ada.Text_IO.File_Type;
      Got_Subscription           :    out Boolean) is
   ---------------------------------------------------------------------------------

      ------------------------------------------------------------------------------
      function Get_Field (
         Allow_Null              : in     Boolean
      ) return String is
      ------------------------------------------------------------------------------

         Buffer                  : Ada_Lib.Strings.Unlimited.String_Type;
         Next                    : Character;
         End_Of_Line             : Boolean;

      begin
         Log_In (Debug_Subscribe);
         loop
            Look_Ahead (File, Next, End_Of_Line);
            if End_Of_Line then
               if not End_Of_File (File) then
                  Skip_Line (File);
               end if;
               exit;
            end if;

            if Next = Seperator then
               declare
                  Skip           : String (1 .. 1);

               begin
                  Get (File, Skip);
               end;

               exit;
            end if;

            Get (File, Next);
            Buffer.Append (Next);
         end loop;

         Log_Here (Debug_Subscribe, Quote (" result", Buffer));

         if Buffer.Length = 0 and then not Allow_Null then
            Log_Exception (Debug_Subscribe);
            raise Failed;
         end if;
         Log_Out (Debug_Subscribe);
         return Buffer.Coerce;
      end Get_Field;
      ------------------------------------------------------------------------------

   begin
      Log_In (Debug_Subscribe);
      declare
         Name                    : constant String := Get_Field (True);

      begin
         if Name'length = 0 then
            Got_Subscription := False;
            Log_Out (Debug_Subscribe, "end of file");
            return;
         end if;
         Subscription.Name_Value.Name := Ada_Lib.Strings.Unlimited.Coerce (Name);
      end;

      Subscription.Name_Value.Index := Optional_Vector_Index_Type'Value (Get_Field (False));
      Subscription.Name_Value.Tag := Ada_Lib.Strings.Unlimited.Coerce (Get_Field (True));
      Subscription.Name_Value.Value := Ada_Lib.Strings.Unlimited.Coerce (Get_Field (True));
      Subscription.Update_Mode := Ada_Lib.Database.Updater.Update_Mode_Type'Value (Get_Field (True));
      Got_Subscription := True;
      Log_Out (Debug_Subscribe, Subscription.Image);

   exception
      when Fault: Failed =>
         Trace_Message_Exception (Debug_Subscribe, Fault, "null subscription field");
         raise;

   end Load;

   ---------------------------------------------------------------------------------
   function Name_Value (
      Subscription               : in     Subscription_Type
   ) return Name_Value_Type is
   ---------------------------------------------------------------------------------

   begin
      return Subscription.Name_Value;
   end Name_Value;

   ---------------------------------------------------------------------------------
   procedure Set_Dynamic (
      Subscription               : in out Subscription_Type) is
   ---------------------------------------------------------------------------------

   begin
      Subscription.Dynamic := True;
   end Set_Dynamic;

   ---------------------------------------------------------------------------------
   function Update_Mode (
      Subscription               : in     Subscription_Type
   ) return Ada_Lib.Database.Updater.Update_Mode_Type is
   ---------------------------------------------------------------------------------

   begin
      return Subscription.Update_Mode;
   end Update_Mode;

   ---------------------------------------------------------------------------------
   procedure Set_Mode (
      Subscription               : in out Subscription_Type;
      Mode                       : in     Ada_Lib.Database.Updater.Update_Mode_Type) is
   ---------------------------------------------------------------------------------

   begin
      Subscription.Update_Mode := Mode;
   end Set_Mode;

   ---------------------------------------------------------------------------------
   procedure Store (
      Subscription               : in     Subscription_Type;
      File                       : in out Ada.Text_IO.File_Type) is
   ---------------------------------------------------------------------------------

   begin
      Log_In (Debug_Subscribe, Subscription.Name_Value.Image);
      Subscription.Name_Value.Store (File);
      Put_Line (File, Seperator & Subscription.Update_Mode'img);
      Log_Out (Debug_Subscribe);
   end Store;

   ---------------------------------------------------------------------------------
   function Update_Count (
      Subscription               : in     Subscription_Type
   ) return Natural is
   ---------------------------------------------------------------------------------

   begin
      return Subscription.Update_Count;
   end Update_Count;

   ---------------------------------------------------------------------------------
   procedure Update_Value (
      Subscription               : in out Subscription_Type;
      Tag                        : in     String;
      Value                      : in     String;
      Update_Kind                : in     Update_Kind_Type;
      From                       : in     String := Ada_Lib.Trace.Here) is
   ---------------------------------------------------------------------------------

   begin
      Log_In (Debug_Subscribe, Subscription.Name_Value.Image &
         Tag_Name (" subscription ",
            Subscription_Type'class (Subscription)'tag));
      Subscription.Name_Value.Value := Ada_Lib.Strings.Unlimited.Coerce (Value);

      case Update_Kind is

         when Internal =>
            null;

         when others =>
            Subscription.Update_Count := Subscription.Update_Count + 1;

      end case;
      Log_Out (Debug_Subscribe, " name value " &
         Subscription.Name_Value.Image &
         " update count" & Subscription.Update_Count'img & " update kind " &
         Update_Kind'img & Tag_Name (" subscription",
            Subscription_Type'class (Subscription)'tag) &
         " subscription address " & Ada_Lib.Strings.Image (Subscription'address) & " from " & From);
   end Update_Value;

begin
   Log_Here (Elaborate);
end Ada_Lib.Database.Subscription;
