with Ada_Lib.Trace; use Ada_Lib.Trace;

package body Ada_Lib.Options.Nested is

-- Debug                : Boolean renames Ada_Lib_Options.Debug;
-- Debug_All            : Boolean renames Ada_Lib_Options.Debug_All;
-- Debug_Options        : Boolean renames Ada_Lib_Options.Debug_Options;
-- Modifiable_Nested_Options     : Nested_Options_Class_Access := Null;
-- Use_Options_Prefix   : Boolean renames Ada_Lib_Options.Use_Options_Prefix;

   ----------------------------------------------------------------------------
   overriding
   procedure Display_Help (            -- common for all programs that use GNOGA_Options
                              -- prints full help, aborts program
     Options                     : in     Nested_Options_Type;  -- only used for dispatch
     Message                     : in     String := "";   -- leave blank no error help
     Halt                        : in     Boolean := True) is
   ----------------------------------------------------------------------------

   begin
      raise Failed with "should not be called";
   end Display_Help;

-- ----------------------------------------------------------------
-- function Get_Ada_Lib_Modifiable_Nested_Options (
--    From                       : in  String := Ada_Lib.Trace.Here
-- ) return Nested_Options_Class_Access is
-- ----------------------------------------------------------------
--
-- begin
--    Log_Here (Debug or Trace_Options, "from " & From);
--    if Debug or Trace_Options then
--       Tag_History (Modifiable_Nested_Options.all'tag, From);
--    end if;
--    return Modifiable_Nested_Options;
--
-- exception
--    when Fault: others =>
--       Trace_Exception (Fault);
--       raise;
--
-- end Get_Ada_Lib_Modifiable_Nested_Options;
--
-- ----------------------------------------------------------------------------
-- function Get_Ada_Lib_Read_Only_Nested_Options (
--    From                       : in  String := Ada_Lib.Trace.Here
-- ) return Nested_Options_Constant_Class_Access is
-- ----------------------------------------------------------------------------
--
-- begin
--    Log_Here (Debug or Trace_Options,
--       "modifiable options " & Tag_Name (Modifiable_Nested_Options.all'tag) &
--       " from " & From);
--
--    if Debug then
--       Tag_History (Modifiable_Nested_Options.all'tag);
--    end if;
--
--    return Nested_Options_Constant_Class_Access (
--       Modifiable_Nested_Options);
-- end Get_Ada_Lib_Read_Only_Nested_Options;
--
   ----------------------------------------------------------------------------
   function Get_Nested_Options (
      From                       : in  String := Options_Here
   ) return Nested_Options_Constant_Class_Access is
   ----------------------------------------------------------------------------

   begin
      Log_Here (Trace_Conversions, "from " & From);
not_implemented;
return null;
   end Get_Nested_Options;

   ----------------------------------------------------------------------------
   overriding
   function Image (
     Options                     : in     Nested_Options_Type
   ) return String is
   ----------------------------------------------------------------------------

   begin
not_implemented;
return "";
   end Image;

   ----------------------------------------------------------------------------
   overriding
   function Process_Option (
      Options                    : in out Nested_Options_Type;
      Iterator                   : in out Command_Line_Iterator_Interface'class;
      Option                     : in     Base_Flag_Option_Type'class
   ) return Boolean is
   pragma Unreferenced (Iterator);
   ----------------------------------------------------------------------------

   begin
      return False;  -- no options for parent
   end Process_Option;

   ----------------------------------------------------------------------------
   overriding
   procedure Program_Help (
      Options                    : in      Nested_Options_Type;  -- only used for dispatch
      Help_Mode                  : in      Ada_Lib.Options.Help_Mode_Type) is
   ----------------------------------------------------------------------------

   begin
      null; -- no more help
   end Program_Help;

-- ----------------------------------------------------------------
-- procedure Set_Ada_Lib_Nested_Options (
--    Options                    : in     Nested_Options_Class_Access) is
-- ----------------------------------------------------------------
--
-- begin
--    Log_In (Debug or Trace_Options, Tag_Name (Options.all'tag));
--    Tag_History (Debug or Trace_Options, Options.all'tag);
--    Modifiable_Nested_Options := Options;
--    Log_Out (Debug or Trace_Options); --, Modifiable_Options_Address);
--
-- end Set_Ada_Lib_Nested_Options;

end Ada_Lib.Options.Nested;

