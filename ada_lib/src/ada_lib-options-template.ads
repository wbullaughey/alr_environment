--with AUnit.Test_Filters;
with Ada_Lib.Options.Nested;
--with Ada_Lib.Options.Flags;
--with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace;
--with Ada_Lib.Unit_Test.Tests;

-- options for unit test of Ada_Lib
package Ada_Lib.Options.Template is

   Failure                       : exception;

   type Template_Options_Type    is limited new Ada_Lib.Options.Nested.
                                    Nested_Options_Type
                                    with record
      Debug                      : Boolean := False;
      Compile                    : Boolean := False;
      Evaluate                   : Boolean := False;
      Expand                     : Boolean := False;
      Load                       : Boolean := False;
      Test                       : Boolean := False;
   end record;

   type Template_Options_Constant_Class_Access is access constant Template_Options_Type'class;

   overriding
   function Initialize (
     Options                     : in out Template_Options_Type;
     From                        : in     String := Standard.Ada_Lib.Trace.Here
   ) return Boolean
   with pre    => not Options.Verify_Step (Initialized),
        Post   => Options.Verify_Step (Initialized);

   overriding
   function Process_Option (
      Options           : in out Template_Options_Type;
      Iterator          : in out Ada_Lib.Options.
                                    Command_Line_Iterator_Interface'class;
      Option            : in     Base_Flag_Option_Type'class
   ) return Boolean
   with pre => Options.Verify_Step (Initialized);

   overriding
   procedure Trace_Parse (
      Options     : in out Template_Options_Type;
      Iterator    : in out Ada_Lib.Options.
                              Command_Line_Iterator_Interface'class);

   Template_Options_Constant     : Template_Options_Constant_Class_Access := Null;

private

   overriding
   procedure Program_Help (
      Options                    : in     Template_Options_Type;  -- only used for dispatch
      Help_Mode                  : in     Help_Mode_Type);

end Ada_Lib.Options.Template;
