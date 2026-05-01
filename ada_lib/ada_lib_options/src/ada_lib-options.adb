--with Ada.Assertions;
with Ada.Strings.Unbounded;
--with Ada.Tags;
with Ada.Text_IO; use  Ada.Text_IO;
--with Ada_Lib.Trace_Options_Package;
with Ada_Lib.Trace_Options_Package;

package body Ada_Lib.Options is

   function Who
   return String renames GNAT.Source_Info.Enclosing_Entity;

   Parameter_Parsing_Failed
                        : Boolean := False;

   Debug                : Boolean renames Ada_Lib_Options.Debug;
-- Debug_All            : Boolean renames Ada_Lib_Options.Debug_All;
-- Debug_Options        : Boolean renames Ada_Lib_Options.Debug_Options;
-- Use_Options_Prefix   : Boolean renames Ada_Lib_Options.Use_Options_Prefix;

   ----------------------------------------------------------------------------
   function "&" (
      Left, Right                : in        Flag_List_Type
   ) return Flag_List_Type is
   ----------------------------------------------------------------------------

      Result                     : Flag_List_Type;

   begin
      Result.Options := new Base_Options_Array (1 ..
         Left.Options.all'length + Right.Options.all'length);

      Result.Options.all (1 .. Left.Options.all'length) := Left.Options.all;
      Result.Options.all (Left.Options.all'length + 1 ..
         Left.Options.all'length + Right.Options.all'length) := Right.Options.all;
      return Result;
   end "&";

   ----------------------------------------------------------------------------
   procedure Create_Option (
      Flag                       :    out Base_Flag_Option_Type;
      Option                     : in     Character;
      Modifier                   : in     Character;
      From                       : in     String := Options_Here) is
   ----------------------------------------------------------------------------

   begin
      Flag.Kind := (if Modifier = Unmodified_flag then
                           Plain
                        else
                           Modified);
      Flag.Modifier := Modifier;
      Flag.Option   := Option;
   end Create_Option;

   ----------------------------------------------------------------------------
   procedure Create_Options (
      Flag                    :    out Flag_List_Type;
      Options                 : in     Base_Options_Array;
      From                    : in     String := Options_Here) is
   ----------------------------------------------------------------------------

      Index                   : Natural := 0;

   begin
      Flag.Options := new Base_Options_Array (1 .. Options'last);
      for Option of Options loop
         Index := Index + 1;
         Flag.Options (Index) := Option;
      end loop;
   end Create_Options;

   ----------------------------------------------------------------------------
   function Has_Options (
      Flag                    : in        Flag_List_Type
   ) return Boolean is
   ----------------------------------------------------------------------------

   begin
      return Flag.Options /= Null;
   end Has_Options;

   ----------------------------------------------------------------------------
   function Image (
      Flag                    : in        Flag_List_Type
   ) return String is
   ----------------------------------------------------------------------------

      use Ada.Strings.Unbounded;

      Result   : Unbounded_String;

      -------------------------------------------------------------------------
      procedure Callback (
         Option                  : in     Base_Flag_Option_Type'class) is
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
      Flag.Iterate (Callback'access);
      return To_String (Result);
   end Image;

   ----------------------------------------------------------------------------
   procedure Iterate (
      Flags                      : in     Flag_List_Type;
      Callback                   : access procedure (
         Option                  : in     Base_Flag_Option_Type'class)) is
   ----------------------------------------------------------------------------

   begin
      for Option of Flags.Options.all loop
         Callback (Option.all);
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

   -------------------------------------------------------------------
   function Option (
      Flags                      : in     Flag_List_Type;
      Index                      : in     Natural
   ) return Character is
   -------------------------------------------------------------------

   begin
      return Flags.Options.all (Index).Option;
   end Option;

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
      Where             : in     String := GNAT.Source_Info.Source_Location) is
   -------------------------------------------------------------------

   begin
      if Enable then
         Put_Line ("message '" & Message & "' from " & Where);
      end if;
   end Option_Log;

   -------------------------------------------------------------------
   function Option_Log (
      Result            : in     Boolean;
      Enable            : in     Boolean := True;
      Message           : in     String := "";
      Where             : in     String := GNAT.Source_Info.Source_Location
   ) return Boolean is
   -------------------------------------------------------------------

   begin
      if Enable or else Ada_Lib.Trace_Options_Package.Trace_Pre_Post_False then
         Put_Line ("result " & Result'img &
            " message '" & Message & "' from " & Where);
      end if;

      return Result;
   end Option_Log;

   -------------------------------------------------------------------
   -- raises assert
   procedure Options_Not_Implemented (
      Why                        : in     String := "";
      Here                       : in     String := GNAT.Source_Info.Source_Location;
      Who                        : in     String := GNAT.Source_Info.Enclosing_Entity) is
   -------------------------------------------------------------------

   begin
      pragma Assert (False, "not implemented at " & Here &
         " by " & Who & " for " & Why);
   end Options_Not_Implemented;

   ----------------------------------------------------------------------------
   procedure Parsing_Failed is
   ----------------------------------------------------------------------------

   begin
--    Log_Here (Debug or Trace_Options);
      Parameter_Parsing_Failed := True;
   end Parsing_Failed;

   ----------------------------------------------------------------------------
   function Parsing_Failed return Boolean is
   ----------------------------------------------------------------------------

   begin
--    Log_Here (Debug or Trace_Options, "Parameter_Parsing_Failed " & Parameter_Parsing_Failed'img);
      return Parameter_Parsing_Failed;
   end Parsing_Failed;

begin
--Debug := True;
   Trace.Include_Task := True;

end Ada_Lib.Options;

