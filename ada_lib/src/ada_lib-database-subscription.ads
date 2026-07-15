with Ada.Text_IO;
with Ada_Lib.Database.Updater;
with Ada_Lib.Strings.Unlimited;-- use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace;

package Ada_Lib.Database.Subscription is

   Failed                        : exception;

   type Direction_Type is (Send, Receive, Dont_Record);

   type Subscription_Type is tagged limited private;
   type Subscription_Access is access all Subscription_Type;
   type Subscription_Class_Access is access all Subscription_Type'class;
   type Subscription_Constant_Access is access constant Subscription_Type;
   type Subscription_Constant_Class_Access is access constant Subscription_Type'class;
   type Subscription_Update_Result_Type is (Updated, No_Change, Update_Failed);

   type Update_Kind_Type is (
      External,
      Ignore,
      Internal,
      Refresh,
      Restore);

   Direction_Table               : constant array (Update_Kind_Type) of Direction_Type := (
      External             => Receive,
      Internal             => Send,
      Restore              => Dont_Record,
      Refresh              => Dont_Record,
      Ignore               => Dont_Record
   );

   Seperator                     : constant Character := '~';

   function "=" (
      Left, Right                : in     Subscription_Type
   ) return Boolean;

   function Check_Name (
      Subscription               : in     Subscription_Type;
      Name                       : in     String
   ) return Boolean;

   function Create (
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      Tag                        : in     String;
      Value                      : in     String;
      Update_Mode                : in     Ada_Lib.Database.Updater.Update_Mode_Type;
      Update_Count               : in     Natural := 0
   ) return Subscription_Type;

   procedure Dump (
      Subscription               : in     Subscription_Type);

   function Equal (
      Left, Right                : in     Subscription_Class_Access
   ) return Boolean;

   procedure Free (
      Subscription               : in out Subscription_Class_Access);

   function Image (
      Subscription               : in     Subscription_Type
   ) return String;

   procedure Increment_Count (
      Subscription               : in out Subscription_Type);

   function Index (
      Subscription               : in     Subscription_Type
   ) return Optional_Vector_Index_Type;

   procedure Initialize (
      Subscription               : in out Subscription_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      Tag                        : in     String;
      Value                      : in     String;
      Update_Mode                : in     Ada_Lib.Database.Updater.Update_Mode_Type);

   function Is_Dyanmic (
      Subscription               : in     Subscription_Type
   ) return Boolean;

   function Last_Value (
      Subscription               : in     Subscription_Type
   ) return Ada_Lib.Strings.Unlimited.String_Type;

   procedure Load (
      Subscription               :    out Subscription_Type;
      File                       : in out Ada.Text_IO.File_Type;
      Got_Subscription           :    out Boolean);

   function Name_Value (
      Subscription               : in     Subscription_Type
   ) return Name_Value_Type;

   procedure Set_Dynamic (
      Subscription               : in out Subscription_Type);

   procedure Set_Mode (
      Subscription               : in out Subscription_Type;
      Mode                       : in     Ada_Lib.Database.Updater.Update_Mode_Type);

   procedure Store (
      Subscription               : in     Subscription_Type;
      File                       : in out Ada.Text_IO.File_Type);

   function Update_Count (
      Subscription               : in     Subscription_Type
   ) return Natural;

   function Update_Mode (
      Subscription               : in     Subscription_Type
   ) return Ada_Lib.Database.Updater.Update_Mode_Type;

   procedure Update_Value (
      Subscription               : in out Subscription_Type;
      Tag                        : in     String;
      Value                      : in     String;
      Update_Kind                : in     Update_Kind_Type;
      From                       : in     String := Ada_Lib.Trace.Here);

private
   type Subscription_Type is tagged limited record
      Dynamic                    : Boolean := False;  -- when true delete when deleted
      Name_Value                 : Name_Value_Type;
      Update_Count               : Natural := 0;
      Update_Mode                : Ada_Lib.Database.Updater.Update_Mode_Type;
   end record;

end Ada_Lib.Database.Subscription;

