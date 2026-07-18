with Ada.Containers.Indefinite_Hashed_Maps;
with Ada.Strings.Hash;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;

package Ada_Lib.Configuration is

   Failed                     : exception;

   type Configuration_Type       is tagged private;

   procedure Close (
      Configuration              : in out Configuration_Type
   ) with Pre => Configuration.Is_Open;

   function Get_Integer (
      Configuration              : in     Configuration_Type;
      Name                       : in     String
   ) return Integer
   with Pre => Configuration.Is_Open;

   function Get_String (
      Configuration              : in     Configuration_Type;
      Name                       : in     String
   ) return String
   with Pre => Configuration.Is_Open;

   function Has (
      Configuration              : in     Configuration_Type;
      Name                       : in     String
   ) return Boolean
   with Pre => Configuration.Is_Open;

   function Has_Path (
      Configuration              : in     Configuration_Type
   ) return Boolean;

   function Has_Value (
      Configuration              : in     Configuration_Type;
      Name                       : in     String
   ) return Boolean
   with Pre => Configuration.Is_Open;

   function Is_Empty (
      Configuration              : in     Configuration_Type
   ) return Boolean;

   function Is_Open (
      Configuration              : in     Configuration_Type
   ) return Boolean;

   procedure Load (
      Configuration              : in out Configuration_Type;
      Path                       : in     String;
      Create                     : in     Boolean
   ) with Pre => Path'length > 0 and then
                 Configuration.Is_Empty;

   procedure Set (
      Configuration              : in out Configuration_Type;
      Name                       : in     String;
      Value                      : in     String;
      Update                     : in     Boolean := True
   ) with Pre  => Configuration.Has_Path;

   procedure Set (
      Configuration              : in out Configuration_Type;
      Name                       : in     String;
      Value                      : in     Integer;
      Update                     : in     Boolean := True);

   procedure Store (
      Configuration              :    out Configuration_Type;
      Path                       : in     String);

   procedure Unload (
      Configuration              : in out Configuration_Type
   ) with Post    => Configuration.Is_Empty;

private

   package Table_Package is new Ada.Containers.Indefinite_Hashed_Maps (
         Key_Type       => String,
         Element_Type   => String,
         Hash           => Ada.Strings.Hash,
         Equivalent_Keys=> "=",
         "="            => "=");

   type Configuration_Type       is tagged record
      Opened                     : Boolean := False;
      Path                       : Ada_Lib.Strings.Unlimited.String_Type;
      Table                      : Table_Package.Map;
   end record;

end Ada_Lib.Configuration;

