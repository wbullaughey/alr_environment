with Ada.Containers.Indefinite_Hashed_Maps;
with Ada.Containers;
with Ada.Strings.Hash;
with Ada.Tags;
-- with Ada_Lib.Database.Subscription;
with Ada_Lib.Database.Updater;
-- with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
-- with Ada_Lib.Trace;

package Ada_Lib.Database.Subscribe is

   Duplicate                  : exception;
   Failed                     : exception;

-- package Subscription_Package is
--    type Reference_Type is new Ada.Finalization.Controlled with private;
--
--    function Create_Reference (
--       Subscription            : in     Ada_Lib.Database.Updater.Updater_Interface_Class_Access
--    ) return Reference_Type;
--
--    function Equal (
--       Left, Right             : in     Reference_Type
--    ) return Boolean;
--
--    function Get_Subscription (
--       Subscription            : in     Reference_Type
--    ) return Ada_Lib.Database.Updater.Updater_Interface_Class_Access;
--
-- private
--    type Reference_Type is new Ada.Finalization.Controlled with record
--       Subscription            : Ada_Lib.Database.Updater.Updater_Interface_Class_Access;
--    end record;
-- end Subscription_Package;

-- package Subscription_Vector_Package is new Ada.Containers.Vectors (
--    Optional_Vector_Index_Type,
--    Ada_Lib.Database.Updater.Updater_Interface_Class_Access,
--    Ada_Lib.Database.Subscription.Equal);
--
-- subtype Vector_Cursor_Type is Subscription_Vector_Package.Cursor;
--
-- type Vector_Type is new Subscription_Vector_Package.Vector with null record;
--
-- function Compare_Vectors (
--    Left, Right                : Vector_Type
-- ) return Boolean;

-- function Get_Subscription (
--    Cursor                     : in     Vector_Cursor_Type
-- ) return Ada_Lib.Database.Updater.Updater_Interface_Class_Accessy;

-- Empty_Vector                  : constant Vector_Type;

-- function Hash (
--    Key                        : in     Ada_Lib.Database.Updater.Key_Type
-- ) return Ada.Containers.Hash_Type;
--
-- function Image (
--    Key                        : in     Ada_Lib.Database.Updater.Key_Type
-- ) return String;

-- function Key (
--    Subscription               : in     Ada_Lib.Database.Subscription.Abstract_Subscription_Type'class
-- ) return Key_Type;

   package Hash_Table_Package is new Ada.Containers.Indefinite_Hashed_Maps (
      String,
      Ada_Lib.Database.Updater.Updater_Interface_Class_Access,
      Ada.Strings.Hash,
      "=",
      Ada_Lib.Database.Updater.Equal);

   subtype Element_Reference_Type is Hash_Table_Package.Reference_Type;
   subtype Table_Cursor_Type is Hash_Table_Package.Cursor;

   type Table_Type is abstract tagged limited private;

   type Table_Access is access all Table_Type'class;
   type Table_Class_Access is access all Table_Type'class;

   type Subscription_Cursor_Type is abstract tagged record
--    Number_Subscriptions       : Natural;
      Updater                    : Ada_Lib.Database.Updater.Updater_Interface_Class_Access;
   end record;

   procedure Add_Subscription (
      Table                      : in out Table_Type;
      Updater                    : in     Ada_Lib.Database.Updater.Updater_Interface_Class_Access);
--    Timeout                    : in     Duration := Default_Post_Timeout);

   function Delete (
      Table                      : in out Table_Type;
      Updater                    : in     Ada_Lib.Database.Updater.Updater_Interface_Class_Access
   ) return Boolean;

   -- delete all subscriptions for named item, returns numbe subscrpitions deleted
   function Delete (
      Table                      : in out Table_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag
   ) return Boolean;

   procedure Delete_All (
      Table                      : in out Table_Type;
      Unsubscribed_Only          : in     Boolean := False);

-- procedure Delete_Row (
--    Table                      : in out Table_Type;
--    Name                       : in     String);

   procedure Dump (
      Table                      : in     Table_Type;
      Title                      : in     String := "";
      From                       : in     String := Ada_Lib.Trace.Here);

   function Get_Number_Subscriptions (
      Table                      : in out Table_Type
   ) return Natural;

   function Get_Subscription (
      Table                      : in out Table_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag
   ) return Ada_Lib.Database.Updater.Updater_Interface_Class_Access;

   procedure Get_Subscription_Update_Mode (
      Table                   : in out Table_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag;
      Update_Mode                :    out Ada_Lib.Database.Updater.Update_Mode_Type;
      Result                     :    out Boolean);

   function Has_Row (
      Table                      : in out Table_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type
   ) return Boolean;

   function Has_Subscription (
      Table                      : in out Table_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag
   ) return Boolean;

   function Has_Subscription_Element (
      Position                   : in     Table_Cursor_Type
   ) return Boolean renames Hash_Table_Package.Has_Element;

-- procedure Insert (   use Add_Subscription instead
--    Table                      : in out Table_Type;
--    Subscription               : in     Ada_Lib.Database.Updater.Updater_Interface_Class_Access);

-- function Is_Valid (
--    Cursor                     : in     Subscription_Cursor_Type
-- ) return Boolean;

   procedure Iterate (
      Table                      : in out Table_Type;
      Cursor                     : in out Subscription_Cursor_Type'Class);

-- function Last_Value (
--    Cursor                     : in     Subscription_Cursor_Type
-- ) return Ada_Lib.Strings.Unlimited.String_Type;--
                                              --
   procedure Load (
      Table                      : in out Table_Type;
      Path                       : in     String) is abstract;

-- function Name_Value (                      --
--    Cursor                     : in     Subscription_Cursor_Type
-- ) return Name_Value_Type;

   -- send value to subscriptions
   procedure Notify (
      Table                   : in out Table_Type;
      Name_Value              : in     Name_Value_Type'class);

   function Number_Subscriptions (
      Table                   : in     Table_Type
   ) return Natural;

   function Process (
      Cursor                     : in out Subscription_Cursor_Type
   ) return Boolean is abstract;    -- return true to continue iterating

   -- updates name/value to table
   -- returns false if name does not exist
   function Set (
      Table                      : in out Table_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag;
      Value                      : in     String
   ) return boolean;

   -- returns true if any subscriptions are not Never
   function Set_Subscription_Mode (
      Table                   : in out Table_Type;
      Name                    : in     String;
      Index                   : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag;
      Update_Mode             : in    Ada_Lib.Database.Updater.Update_Mode_Type
   ) return Ada_Lib.Database.Updater_Result_Type
   with pre => Name'length > 0;

   procedure Store (
      Table                      : in     Table_Type;
      Path                       : in     String);

-- -- add a subscription returns false if one already exists
-- function Subscribe (
--    Table                      : in out Table_Type;
--    Subscription               : in     Ada_Lib.Database.Updater.Updater_Interface_Class_Access;
--    Name                       : in     String;
--    Index                      : in     Optional_Vector_Index_Type;
--    Tag                        : in     String;
--    Value                      : in     String;
--    Update_Mode                : in    Ada_Lib.Database.Updater.Update_Mode_Type
-- ) return Boolean;

   function Subscription (
      Cursor                     : in out Subscription_Cursor_Type
   ) return Ada_Lib.Database.Updater.Updater_Interface_Class_Access;

   function Subscription_Protected (   -- only call from routine called from task
      Cursor                     : in out Subscription_Cursor_Type
   ) return Ada_Lib.Database.Updater.Updater_Interface_Class_Access;

   -- remove a subscription
   function Unsubscribe (
      Table                      : in out Table_Type;
      Remove                     : in     Boolean;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag
   ) return Boolean;

-- function Update (
--    Table                      : in out Table_Type;
--    Name                       : in     String;
--    Index                      : in     Optional_Vector_Index_Type;
--    Cursor                     : in out Subscription_Cursor_Type'Class
-- ) return Boolean;

   function Update_Mode (
      Cursor                     : in     Subscription_Cursor_Type
   ) return Ada_Lib.Database.Updater.Update_Mode_Type;

-- procedure Update_All (
--    Table                      : in out Table_Type;
--    Cursor                     : in out Subscription_Cursor_Type'Class);


-- -- add a subscription returns false if one already exists
-- -- returns true if new subscription added
-- function Set_Subscription_Mode (
--    Table                      : in out Table_Type;
--    Name_Value                 : in     Name_Value_Type;
--    Index                      : in     Optional_Vector_Index_Type;
--    Update_Mode                : in     Ada_Lib.Database.Updater.Update_Mode_Type;
--    Timeout                    : in     Duration := Default_Post_Timeout
-- ) return Boolean;

private
   type Table_Type is abstract tagged limited record
      Map                        : Hash_Table_Package.Map;
   end record;

-- Empty_Vector : constant Vector_Type :=
--    Vector_Type'(Subscription_Vector_Package.Vector with null record);

end Ada_Lib.DAtabase.Subscribe;
