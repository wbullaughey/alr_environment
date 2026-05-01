--with Ada.Assertions;
with Ada.Characters.Handling;
--with Ada.Exceptions;
with Ada.Tags;
--with Ada.Text_IO;use Ada.Text_IO;
--with Ada_Lib.Command_Line_Iterator;
--with Ada_Lib.Help;
--with Ada_Lib.OS;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
--with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace; use Ada_Lib.Trace;

package body Ada_Lib.Options.Flags is

   use type Ada.Tags.Tag;

   Debug       : Boolean renames Ada_Lib_Options_Flags.Debug;

   ----------------------------------------------------------------------------
   function Allocate_Option (    -- create a single options
      Option                     : in     Character;
      Modifier                   : in     Character;
      From                       : in     String := Ada_Lib.Trace.Here
   ) return Flag_Option_Access is
   ----------------------------------------------------------------------------

      Flag_Option                : constant Flag_Option_Access :=
                                    new Flag_Option_Type;

   begin
      Log_Here (Debug or Trace_Options, Quote ("option", Option) & (if Modifier = Unmodified_flag then
            " no modifier"
         else
            Quote (" modifier", Modifier) &
         " from " & From));

      Flag_Option.Create_Option (Option, Modifier, From);
      return Flag_Option;
   end Allocate_Option;

   ----------------------------------------------------------------------------
   function Allocate_Option (
      Option                     : in     Character;
      Modifier                   : in     Character;
      From                       : in     String := Here
   ) return Flag_Option_Type is
   ----------------------------------------------------------------------------

      Result                     : Flag_Option_Type;

   begin
      Result.Create_Option (Option, Modifier, From);
      return Result;
   end Allocate_Option;

   ----------------------------------------------------------------------------
   overriding
   function Has_Option (
      Option                     : in     Flag_Option_Type;
      Options_With_Parameters    : in     Flag_List_Type'class;
      Options_Without_Parameters : in     Flag_List_Type'class;
      From                          : in     String := Options_Here
   ) return Boolean is
   ----------------------------------------------------------------------------

      Result                     : Boolean := False;

      ----------------------------------------------------------------------------
      procedure Verify (
         List_Option    : in     Base_Flag_Option_Type'class) is

         Test           : constant Boolean := List_Option =
                           Base_Flag_Option_Type'class (Option);
      begin
         Log_Here (Debug, "has " & List_Option.Image & " " & Test'img);

         if Test then
            Result := True;
         end if;
      end Verify;
      ----------------------------------------------------------------------------

   begin
      Log_In (Debug or Trace_Options, Option.Image &
         " Options_With_Parameters " &
         Options_With_Parameters.Length'img & " " &
         Options_With_Parameters.Image &
         " Options_Without_Parameters " &
         Options_Without_Parameters.Length'img & " " &
         Options_Without_Parameters.Image &
         " called from " & From);

      Options_With_Parameters.Iterate (Verify'access);
      Options_WithOut_Parameters.Iterate (Verify'access);

      return Log_Out (Result, Debug or Trace_Options);
   end Has_Option;

-- ----------------------------------------------------------------------------
-- function Have_Options return Boolean is
-- ----------------------------------------------------------------------------
--
-- begin
--    return Modifiable_Options /= Null;
-- end Have_Options;

   ----------------------------------------------------------------------------
   overriding
   function Image (
      Option                     : in     Flag_Option_Type;
      Quote                      : in     Boolean := True
   ) return String is
   ----------------------------------------------------------------------------

      Text                       : constant String := (case Option.Kind is
                                    when Modified => String'(
                                       Option.Modifier, Option.Option),
                                    when Plain    => String'(
                                       1 => Option.Option),
--                                     2 => '#'), -- added for debug listing
                                    when Nil_Option   => (
                                       if Quote then "" else "Null"));
   begin
      return (if Quote then
            Ada_Lib.String_Quote.Quote ("option", Text)
         else
            Text);
   end Image;

   ----------------------------------------------------------------------------
   overriding
   function Less (
      Left, Right                : in     Flag_Option_Type
   ) return Boolean is
   ----------------------------------------------------------------------------

      use Ada.Characters.Handling;

      Left_Letter                : constant Character :=
                                    To_Upper (Left.Option);
      Right_Letter               : constant Character :=
                                    To_Upper (Right.Option);
      Left_Upper                 : constant Boolean :=
                                    Is_Upper (Left.Option);
      Right_Upper                : constant Boolean :=
                                    Is_Upper (Right.Option);

   begin
      return (if Left.Kind = Right.Kind then
            (if Left_Letter = Right_Letter then
               (if Left_Upper = Right_Upper then
                  True
               else
                  Right_Upper)
            else
               Left_Letter < Right_Letter)
         else
            Left.Kind < Right.Kind);
   end Less;

-- ----------------------------------------------------------------------------
-- function Modifiable_Options_Address
-- return String is
-- ----------------------------------------------------------------------------
--
-- begin
--    return "Modifiable_Options address is " &
--       (if Modifiable_Options = Null then
--          "null "
--       else
--          Image (Modifiable_Options.all'address));
--
-- end Modifiable_Options_Address;

   ----------------------------------------------------------------------------
   overriding
   function Modified (
      Option                     : in     Flag_Option_Type
   ) return Boolean is
   ----------------------------------------------------------------------------

   begin
      return Option.Kind = Modified;
   end Modified;

   ----------------------------------------------------------------------------
   overriding
   function Modifier (
      Option                     : in     Flag_Option_Type
   ) return Character is
   ----------------------------------------------------------------------------

   begin
      return Option.Modifier;
   end Modifier;

begin
--Debug := True;
--Trace_Options := True;
--Elaborate := True;
   Log_Here (Debug or Trace_Options or Elaborate);
end Ada_Lib.Options.Flags;

