--with Ada.Assertions;
with Ada.Characters.Handling;
with Ada.Strings.Unbounded;
--with Ada.Tags;
with Ada.Text_IO; use  Ada.Text_IO;
with Ada_Lib.Trace_Options_Package;

package body Ada_Lib.Options is

   Parameter_Parsing_Failed
                        : Boolean := False;

   Debug                : Boolean renames Ada_Lib_Options.Debug;
-- Debug_All            : Boolean renames Ada_Lib_Options.Debug_All;
-- Debug_Options        : Boolean renames Ada_Lib_Options.Debug_Options;
   Trace_Options        : Boolean renames Trace_Options_Package.Trace_Options;
-- Use_Options_Prefix   : Boolean renames Ada_Lib_Options.Use_Options_Prefix;

   ----------------------------------------------------------------------------
   function "&" (
      Left, Right                : in        Flag_List_Type
   ) return Flag_List_Type is
   ----------------------------------------------------------------------------

      Result                     : Flag_List_Type;

   begin
      Result.Options := new Options_Array (1 ..
         Left.Options.all'length + Right.Options.all'length);

      Result.Options.all (1 .. Left.Options.all'length) := Left.Options.all;
      Result.Options.all (Left.Options.all'length + 1 ..
         Left.Options.all'length + Right.Options.all'length) := Right.Options.all;
      return Result;
   end "&";

   ----------------------------------------------------------------------------
   function Has_Option (
      Option                     : in     Flag_Option_Type;
      Options_With_Parameters    : in     Flag_List_Type'class;
      Options_Without_Parameters : in     Flag_List_Type'class;
      Who                        : in     String := Options_Who;
      From                       : in     String := Options_Here
   ) return Boolean is
   ----------------------------------------------------------------------------

      Log_It                     : constant Boolean := Debug or Trace_Options;
      Result                     : Boolean := False;

      ----------------------------------------------------------------------------
      procedure Verify (
         List_Option    : in     Flag_Option_Type) is

         Test           : constant Boolean := List_Option = Option;

      begin
         Option_Log (Log_It, "has " & List_Option.Image & " " & Test'img);

         if Test then
            Result := True;
         end if;
      end Verify;
      ----------------------------------------------------------------------------

   begin
      Option_Log (Log_It, Option.Image &
         " Options_With_Parameters " &
         Options_With_Parameters.Length'img & " " &
         Options_With_Parameters.Image &
         " Options_Without_Parameters " &
         Options_Without_Parameters.Length'img & " " &
         Options_Without_Parameters.Image,
         Who, From);

      Options_With_Parameters.Iterate (Verify'access);
      Options_WithOut_Parameters.Iterate (Verify'access);

      return Option_Log (Result, Log_It, "", Who, From);
   end Has_Option;

   ----------------------------------------------------------------------------
   function Has_Options (
      Flags                   : in        Flag_List_Type
   ) return Boolean is
   ----------------------------------------------------------------------------

   begin
      return Flags.Options /= Null;
   end Has_Options;

   ----------------------------------------------------------------------------
   function Image (
      Option                     : in     Flag_Option_Type;
      Quote                      : in     Boolean := True;
      Kind                       : in     Boolean := True
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
            "option '" &Text & "'"
         else
            Text) &
         (if Kind then
            " " & Option.Kind'img
         else "");
   end Image;

   ----------------------------------------------------------------------------
   function Image (
      Flags                   : in        Flag_List_Type
   ) return String is
   ----------------------------------------------------------------------------

      use Ada.Strings.Unbounded;

      Result   : Unbounded_String;

      -------------------------------------------------------------------------
      procedure Callback (
         Option                  : in     Flag_Option_Type) is
      -------------------------------------------------------------------------

      begin
         case Option.Kind is

            when Plain =>
               Result := Result & Option.Option & ',';

            when Modified =>
               Result := Result & Option.Modifier & Option.Option & ',';

            when Nil_Option =>
               Null;
         end case;
      end Callback;
      -------------------------------------------------------------------------

   begin
      Flags.Iterate (Callback'access);
      return To_String (Result);
   end Image;

   ----------------------------------------------------------------------------
   function Initialize (
     Option       : in     Character;
     Modifier     : in     Character;
     Who          : in     String := Options_Who;
     From         : in     String := Options_Here
   ) return Flag_Option_Type is
   pragma Unreferenced (Who, From);
   ----------------------------------------------------------------------------

      Result      : Flag_Option_Type;

   begin
      Result.Kind := (if Modifier = Unmodified_flag then
                           Plain
                        else
                           Modified);
      Result.Modifier := Modifier;
      Result.Option   := Option;
--    Option_Log (Debug or Trace_Options, Result.Image (True), Who, From);
      return Result;
   end Initialize;

   ----------------------------------------------------------------------------
   procedure Initialize (
      Flags       :    out Flag_List_Type;
      Option      : in     Character;
      Modifier    : in     Character;
      Who               : in     String := Options_Who;
      From        : in     String := Options_Here) is
   ----------------------------------------------------------------------------

   begin
      Option_Log (Debug or Trace_Options, "called from " & Who & " " & From);
      Flags.Initialize (String'(
         1 => Option), Modifier, From);
   end Initialize;

   ----------------------------------------------------------------------------
   function Initialize (
     Options      : in     Character;
     Modifier     : in     Character;
     Who          : in     String := Options_Who;
     From         : in     String := Options_Here
   ) return Flag_List_Type is
   ----------------------------------------------------------------------------

      Result      : Flag_List_Type;

   begin
      Result.Initialize (Options, Modifier, Who, From);
      return Result;
   end Initialize;

   ----------------------------------------------------------------------------
   procedure Initialize (
      Flags       :    out Flag_List_Type;
      Options     : in     String;
      Modifier    : in     Character;
      Who         : in     String := Options_Who;
      From        : in     String := Options_Here) is
   ----------------------------------------------------------------------------

      Index    : Natural := 0;
      Log_It   : constant Boolean := Debug or Trace_Options;

   begin
      Option_Log (Log_It, "options '" & Options &
         "' modifier " & Modifier & "called from " & Who & " " & From);
      Flags.Options := new Options_Array (1 .. Options'last);
      for Option of Options loop
         Index := Index + 1;
         declare
            Flag_Option    : Flag_Option_Type renames Flags.Options (Index);

         begin
            Flag_Option.Kind := (if Modifier = Not_Flag_Option then
                              Plain
                           else
                              Modified);
            Flag_Option.Modifier := Modifier;
            Flag_Option.Option := Option;
         end;
      end loop;
      Option_Log (Log_It, "flags '" & Flags.Image, Who, From);
   end Initialize;

   ----------------------------------------------------------------------------
   function Initialize (
     Options      : in     String;
     Modifier     : in     Character;
     Who          : in     String := Options_Who;
     From         : in     String := Options_Here
   ) return Flag_List_Type is
   ----------------------------------------------------------------------------

      Result      : Flag_List_Type;

   begin
      Result.Initialize (Options, Modifier, Who, From);
      return Result;
   end Initialize;

   ----------------------------------------------------------------------------
   procedure Iterate (
      Flags                      : in     Flag_List_Type;
      Callback                   : access procedure (
         Option                  : in     Flag_Option_Type)) is
   ----------------------------------------------------------------------------

   begin
      for Option of Flags.Options.all loop
         Callback (Option);
      end loop;
   end Iterate;

   ----------------------------------------------------------------------------
   function Length (
      Flags                      : in     Flag_List_Type
   ) return Natural is
   ----------------------------------------------------------------------------

   begin
      return Flags.Options.all'length;
   end Length;

   ----------------------------------------------------------------------------
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

   -------------------------------------------------------------------
   function Option (
      Flags                      : in     Flag_List_Type;
      Index                      : in     Natural
   ) return Character is
   -------------------------------------------------------------------

   begin
      return Flags.Options.all (Index).Option;
   end Option;

   ----------------------------------------------------------------------------
   function Modified (
      Option                     : in     Flag_Option_Type
   ) return Boolean is
   ----------------------------------------------------------------------------

   begin
      return Option.Kind = Modified;
   end Modified;

   ----------------------------------------------------------------------------
   function Modifier (
      Option                     : in     Flag_Option_Type
   ) return Character is
   ----------------------------------------------------------------------------

   begin
      return Option.Modifier;
   end Modifier;

   -------------------------------------------------------------------
   function Modifier (
      Flags                      : in     Flag_List_Type;
      Index                      : in     Natural
   ) return Character is
   -------------------------------------------------------------------

   begin
      return Flags.Options.all (Index).Modifier;
   end Modifier;

   -------------------------------------------------------------------
   procedure Option_Log (
      Enable                     : in     Boolean := True;
      Message           : in     String := "";
      Who               : in     String := Options_Who;
      Where             : in     String := Options_Here) is
   -------------------------------------------------------------------

   begin
--Put_Line ("here " & Options_Here & " enable " & Enable'img & " who " & Who & " message '" & Message & "' from " & Where);
      if Enable then
         Put_Line (Who & " message '" & Message & "' from " & Where);
      end if;
   end Option_Log;

   -------------------------------------------------------------------
   function Option_Log (
      Result            : in     Boolean;
      Enable            : in     Boolean := True;
      Message           : in     String := "";
      Who               : in     String := Options_Who;
      Where             : in     String := Options_Here
   ) return Boolean is
   -------------------------------------------------------------------

   begin
      if Enable or else Ada_Lib.Trace_Options_Package.Trace_Pre_Post_False then
         Put_Line (Who & " result " & Result'img &
            " message '" & Message & "' from " & Where);
      end if;

      return Result;
   end Option_Log;

   -------------------------------------------------------------------
   -- raises assert
   procedure Options_Not_Implemented (
      Why                        : in     String := "";
      Who               : in     String := Options_Who;
      Here              : in     String := Options_Here) is
   -------------------------------------------------------------------

   begin
      pragma Assert (False, "not implemented at " & Here &
         " by " & Who & " for " & Why);
   end Options_Not_Implemented;

   ----------------------------------------------------------------------------
   procedure Parsing_Failed is
   ----------------------------------------------------------------------------

   begin
--    Option_Log (Debug or Trace_Options);
      Parameter_Parsing_Failed := True;
   end Parsing_Failed;

   ----------------------------------------------------------------------------
   function Parsing_Failed return Boolean is
   ----------------------------------------------------------------------------

   begin
--    Option_Log (Debug or Trace_Options, "Parameter_Parsing_Failed " & Parameter_Parsing_Failed'img);
      return Parameter_Parsing_Failed;
   end Parsing_Failed;

begin
   declare
      use Trace;

   begin
      Include_Hundreds := False;
      Include_Task     := False;
      Include_Time     := False;
      Inhibit_Trace    := True;
   end;
   declare
      use Ada_Lib.Trace_Options_Package;

   begin
--Debug := True;
Trace.Include_Task := True;
Trace.Include_Time := True;
      Option_Log (Debug_Trace or Elaborate or Trace_Options or Debug);
   end;
end Ada_Lib.Options;

