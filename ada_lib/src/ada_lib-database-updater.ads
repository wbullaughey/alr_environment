with Ada.Tags;
with Ada_Lib.Strings.Unlimited;-- use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace;

package Ada_Lib.Database.Updater is

   Failed                        : exception;

   type Update_Kind_Type is (
      External,
      Ignore,
      Internal,
      Refresh,
      Restore);

   type Update_Mode_Type is (Always, Unique, Never);

   function Calculate_Update_Mode (
      Subscribe                  : in     Boolean;
      On_Change                  : in     Boolean
   ) return Update_Mode_Type;

   function Updater_ID (
      Name                    : in     String;
      Index                   : in     Ada_Lib.Database.Optional_Vector_Index_Type;
      DBDaemon_Tag            : in     String;
      Ada_Tag                 : in     Ada.Tags.Tag
   ) return String;

   type Abstract_Address_Type is abstract tagged null record;

   procedure Dump (
      Address                    : in     Abstract_Address_Type;
      Title                      : in     String := "";
      From                       : in     String := Ada_Lib.Trace.Here) is abstract;

   function Image (
      Address                    : in     Abstract_Address_Type
   ) return String is abstract;

   type Abstract_Address_Unit_Type is abstract tagged private;

   function Image (
      Address                    : in     Abstract_Address_Unit_Type
   ) return String is abstract;

    type Null_Address_Type is new Abstract_Address_Type with null record;

   overriding
   procedure Dump (
      Address                    : in     Null_Address_Type;
      Title                      : in     String := "";
      From                       : in     String := Ada_Lib.Trace.Here);

    overriding
    function Image (
      Address                    : in     Null_Address_Type
    ) return String;

   type Updater_Interface is limited Interface;
   type Updater_Interface_Access is access Updater_Interface;
   type Updater_Interface_Class_Access is access all Updater_Interface'class;
   type Updater_Interface_Constant_Class_Access is access constant Updater_Interface'class;

   procedure Dump (
      Updater               : in     Updater_Interface;
      Title                      : in     String := "";
      From                       : in     String := Ada_Lib.Trace.Here) is abstract;

   function "=" (
      Left, Right                : in     Updater_Interface
   ) return Boolean is abstract;

   function Equal (
      Left, Right                : in     Updater_Interface_Class_Access
   ) return Boolean;

   function Image (
      Updater                    : in     Updater_Interface
   ) return String is abstract;

   function Index (
      Base_Updater               : in     Updater_Interface
   ) return Optional_Vector_Index_Type is abstract;

   function Name (
      Updater                    : in     Updater_Interface
   ) return String is abstract;

   function Name_Value (
      Updater                    : in     Updater_Interface
   ) return Name_Value_Type'class is abstract;

   procedure Set_Mode (
      Updater                    : in out Updater_Interface;
      Mode                       : in     Update_Mode_Type) is abstract;

   procedure Store (
      Updater                    : in     Updater_Interface;
      File                       : in out Ada.Text_IO.File_Type) is abstract;

   function DBDaemon_Tag (
      Updater                    : in     Updater_Interface
   ) return String is abstract;

   procedure Update (
      Updater                    : in out Updater_Interface;
      Address                    : in     Abstract_Address_Type'class;
      Tag                        : in     String;
      Value                      : in     String;
      Update_Kind                : in     Update_Kind_Type;
      From                       : in     String := Ada_Lib.Trace.Here) is abstract;

   function Update_Count (
      Updater                    : in     Updater_Interface
   ) return Natural is abstract;

   function Update_Mode (
      Updater                    : in     Updater_Interface
   ) return Update_Mode_Type is abstract;

   function Updater_ID (
      Updater                    : in     Updater_Interface
   ) return String is abstract;

   function Value (
      Updater                    : in     Updater_Interface
   ) return String is abstract;

   package Base_Updater_Package is
      type Base_Updater_Type is tagged limited  private;

      function "=" (
         Left, Right                : in     Base_Updater_Type
      ) return Boolean;

      function DBDaemon_Tag (
         Base_Updater               : in     Base_Updater_Type
      ) return String;

      procedure Dump (
         Updater                    : in     Base_Updater_Type;
         Title                      : in     String := "";
         From                       : in     String := Ada_Lib.Trace.Here);

      function Image (
         Updater                    : in     Base_Updater_Type
      ) return String;

      function Index (
         Base_Updater               : in     Base_Updater_Type
      ) return Optional_Vector_Index_Type;

      procedure Initialize (
         Updater                    : in out Base_Updater_Type;
         Index                      : in     Ada_Lib.Database.Optional_Vector_Index_Type;
         Name                       : in     String;
         DBDaemon_Tag               : in     String;
         Ada_Tag                    : in     Ada.Tags.Tag;
         Update_Mode                : in     Update_Mode_Type);

      procedure Load (
         Updater                    : in out Base_Updater_Type;
         File                       : in out Ada.Text_IO.File_Type;
         Got_Subscription           :    out Boolean);

      function Name (
         Base_Updater               : in     Base_Updater_Type
      ) return String;

      procedure Set_Mode (
         Updater                    : in out Base_Updater_Type;
         Mode                       : in     Update_Mode_Type);

      procedure Store (
         Updater                    : in     Base_Updater_Type;
         File                       : in out Ada.Text_IO.File_Type);

      function Update_Count (
         Updater                    : in     Base_Updater_Type
      ) return Natural;

      function Update_Mode (
         Base_Updater               : in     Base_Updater_Type
      ) return Update_Mode_Type;

      function Updater_ID (
         Updater                    : in     Base_Updater_Type
      ) return String;

   private

      type Base_Updater_Type is tagged limited record
         ID                         : Ada_Lib.Strings.Unlimited.String_Type;   -- lookup key in server
         Name_Index_Tag             : Name_Index_Tag_Type;
         Update_Mode                : Update_Mode_Type;
      end record;

   end Base_Updater_Package;

   type Abstract_Updater_Type is abstract new Base_Updater_Package.Base_Updater_Type and
      Updater_Interface with null record;
   type Abstract_Updater_Access is access Abstract_Updater_Type;
   type Abstract_Updater_Class_Access is access all Abstract_Updater_Type'class;
   type Abstract_Updater_Constant_Class_Access is access constant Abstract_Updater_Type'class;

   overriding
   procedure Dump (
      Updater                    : in     Abstract_Updater_Type;
      Title                      : in     String := "";
      From                       : in     String := Ada_Lib.Trace.Here);

-- function "=" (
--    Left                       : in     Abstract_Updater_Type;
--    Right                      : in     Abstract_Updater_Type
-- ) return Boolean;

-- function Image (
--    Updater                    : in     Abstract_Updater_Type
-- ) return String;

-- procedure Load (
--    Table                      :    out Abstract_Updater_Type;
--    Path                       : in     String) is abstract;

   overriding
   procedure Load (
      Updater                    : in out Abstract_Updater_Type;
      File                       : in out Ada.Text_IO.File_Type;
      Got_Subscription           :    out Boolean);

   overriding
   function Value (
      Updater                    : in     Abstract_Updater_Type
   ) return String;

   overriding
   function Name_Value (
      Updater                    : in     Abstract_Updater_Type
   ) return Name_Value_Type'class;

   overriding
   procedure Update (
      Updater                    : in out Abstract_Updater_Type;
      Address                    : in     Abstract_Address_Type'class;
      Tag                        : in     String;
      Value                      : in     String;
      Update_Kind                : in     Update_Kind_Type;
      From                       : in     String := Ada_Lib.Trace.Here) is abstract;

    Null_Address                 : constant Null_Address_Type := (null record);

private

   type Abstract_Address_Unit_Type is abstract tagged null record;


end Ada_Lib.Database.Updater;
