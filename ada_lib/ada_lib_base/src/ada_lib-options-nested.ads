with Ada_Lib.Help;
with Ada_Lib.Options.Verification;

package Ada_Lib.Options.Nested is

   -- type used for options nested in other options
   type Nested_Options_Type   is limited new Verification.
                                 Verification_Nested_Options_Type with null record;
--    Library_Options         : Ada_Lib.Options.Library.Library_Options_Type;
-- end record;

   type Nested_Options_Access is access all Nested_Options_Type;
   type Nested_Options_Class_Access is access all Nested_Options_Type'class;
   type Nested_Options_Constant_Class_Access is access constant Nested_Options_Type'class;

   overriding
   procedure Display_Help (            -- common for all programs that use GNOGA_Options
                              -- prints full help, aborts program
     Options                     : in     Nested_Options_Type;  -- only used for dispatch
     Parameters                  : in     Ada_Lib.Options.Argument_Array;
     Message                     : in     String := "";   -- leave blank no error help
     Halt                        : in     Boolean := True);

   function Get_Nested_Options (
      From                       : in  String := Options_Here
   ) return Nested_Options_Constant_Class_Access;

   overriding
   function Image (
     Options                     : in     Nested_Options_Type
   ) return String;

   overriding
   procedure Program_Help (
      Options                    : in      Nested_Options_Type;  -- only used for dispatch
      Help_Mode                  : in      Ada_Lib.Options.Help_Mode_Type);

   overriding
   function Process_Option (
      Options                    : in out Nested_Options_Type;
      Iterator                   : in out Command_Line_Iterator_Interface'class;
      Option                     : in     Flag_Option_Type'class
   ) return Boolean;

-- procedure Set_Ada_Lib_Nested_Options (
--    Options                    : in     Nested_Options_Class_Access
-- ) with Pre => Options /= Null and then
--               not Have_Ada_Lib_Verification_Options (False);

end Ada_Lib.Options.Nested;

