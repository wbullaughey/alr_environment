--with Ada.Characters.Latin_1;
with Ada.Containers.Indefinite_Ordered_Sets;
-- with Ada.Exceptions;
--with Ada.Iterator_Interfaces;
--with Ada.Strings.Maps.Constants;
with Ada.Text_IO;use Ada.Text_IO;
--with Ada_Lib.Options.Flags;
with Ada_Lib.OS;
--with Ada_Lib.Options.Runstring;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with Command_Name;
-- with Debug_Options;

-- pragma Elaborate (Ada_Lib.OS);

package body Ada_Lib.Help is

-- use type Ada_Lib.Options.Flag_Option_Type;
   use type Ada_Lib.Options.Flag_Option_Type;

   subtype Line_Type             is String;

   type Element_Contents_Type (
      Parameter_Length           : Natural;
      Description_Length         : Positive;
      Component_Length           : Natural;
      Source_Line_Length         : Positive) is record
      Component                  : Line_Type (1 .. Component_Length);
      Description                : Line_Type (1 .. Description_Length);
      Has_Trace                  : Boolean;
      Options                    : Line_Type (1 .. Parameter_Length);
      Source_Line                : Line_Type (1 .. Source_Line_Length);
      Trace_Option_Set           : Boolean;
   end record;

   type Element_Contents_Access  is access Element_Contents_Type;

   type Element_Type is record
      Contents                   : Element_Contents_Access := Null;
      Option                     : Ada_Lib.Options.Flag_Option_Type;
   end record;

   function Equal (
      Left, Right                : in     Element_Type
   ) return Boolean;

   function Less_Than (
      Left, Right                : in     Element_Type
   ) return Boolean;

   function Option_Image (
      Element                    : in     Element_Type;
      Label                      : in     Boolean
   ) return String;

   package Line_Package is new Ada.Containers.Indefinite_Ordered_Sets (
      Element_Type   => Element_Type,
      "<"   => Less_Than,
      "="   => Equal);

   procedure Add_Option (
      Option                     : in     Ada_Lib.Options.Flag_Option_Type;
      Trace_Option               : in     Boolean; -- needs to be true if
                                                   -- option is for a trace
      Parameter                  : in     String;
      Description                : in     String;
      Component                  : in     String := "";
      Source_Line                : in     String := Ada_Lib.Trace.Here
   ) with Pre => Description'length > 0;

   Debug                         : Boolean renames
                                    Ada_Lib.Options.Ada_Lib_Help.Debug;
   Lines                         : Line_Package.Set;
   Maximum_Description_Length    : Natural := 0;
   Maximum_Parameter_Length      : Natural := 0;

   procedure Find_Duplicate (
      Option                     : in     Ada_Lib.Options.Flag_Option_Type;
      options                  : in     String;
      Description                : in     String;
      Component                  : in     String;
      From                       : in     String);

   ----------------------------------------------------------------------------
   procedure Add_Option (
      Option                     : in     Ada_Lib.Options.Flag_Option_Type;
      Trace_Option               : in     Boolean;
      Parameter                  : in     String;
      Description                : in     String;
      Component                  : in     String := "";
      Source_Line                : in     String := Ada_Lib.Trace.Here) is
   ----------------------------------------------------------------------------

      Log_It         : constant Boolean := Debug or else Trace_Options;

   begin
      Log_In (Log_It, Option.Image &
         " trace option " & Trace_Option'img &
         Quote (" Parameter", Parameter) &
         Quote (" Description", Description) &
         Quote (" Component", Component) & " from " & Source_Line);

      Find_Duplicate (Option, Parameter, Description, Component, Source_Line);

      if Description'length > Maximum_Description_Length then
         Maximum_Description_Length := Description'length;
      end if;

      if Parameter'length > Maximum_Parameter_Length then
         Maximum_Parameter_Length := Parameter'length;
      end if;

      Line_Package.Insert (Lines, Element_Type'(
         Contents    => new Element_Contents_Type'(
            Component         => Line_Type (Component),
            Component_Length  => Component'length,
            Description       => Line_Type (Description),
            Description_Length=> Description'length,
            Has_Trace         => Trace_Option,
            Options           => Line_Type (Parameter),
            Parameter_Length  => Parameter'length,
            Source_Line       => Line_Type (Source_Line),
            Source_Line_Length=> Source_Line'length,
            Trace_Option_Set  => False),
         Option            => Option));
      Log_Out (Log_It);

   exception

      when Fault: Constraint_Error =>
         Trace_Message_Exception (Log_It, Fault, Option.Image);
         declare
            -------------------------------------------------------
            procedure Process (
               Cursor            : in     Line_Package.Cursor) is
            -------------------------------------------------------

               Element  : Element_Type renames Line_Package.Element (Cursor);
               Contents : constant Element_Contents_Access := Element.Contents;
               Message  : constant String :=
                           Option.Image &
                           (if Description'length > 0 then
                                 Quote (" Parameter ", Description)
                              else
                                 "") &
                           Quote (" already defined for ", Component) &
                           Quote (" at ", Contents.Source_Line) &
                           Quote (" set from", Source_Line);
            begin
               Log_Here (Log_It, Quote ("Description", Description) &
                  Quote ("Component", Component) &
                  Quote ("Message", Message));
               if Option = Element.Option then
                  Put_Line (Message);
                  Put_Line ("****** Halting *******");
                  Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.No_Error);
               end if;
            end Process;
            -------------------------------------------------------

         begin
            Line_Package.Iterate (
               Container   => Lines,
               Process     => Process'access);

            Put_Line ("previous definition not found for" &
               Option.Image &
               Quote (" Parameter", Parameter) &
               Quote (" description", Description) &
               Quote (" component", Component) &
               " from " & Source_Line);
--          Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.No_Error);
         end;

      when Fault: others =>
         Put_Line (Option.Image & Quote (" Description ", Description) &
            Quote (" for ", Component) & " already defined");
         Trace_Message_Exception (Log_It, Fault, Option.Image);
         raise;

   end Add_Option;

   ----------------------------------------------------------------------------
   procedure Check_Traces is
   ----------------------------------------------------------------------------

      Log_It         : constant Boolean := Debug or else Trace_Options;

      -------------------------------------------------------------------------
      procedure Check (
         Cursor                  : in    Line_Package.Cursor) is
      -------------------------------------------------------------------------

         Element     : Element_Type renames Line_Package.Element (Cursor);
         Contents    : Element_Contents_Type renames Element.Contents.all;

      begin
         Log_Here (Log_It,
            " has trace " & Contents.Has_Trace'img &
            " Trace_Option_Set " & Contents.Trace_Option_Set'img &
            " kind " & Element.Option.Kind'img & " " &
            (case Element.Option.Kind is
               when Ada_Lib.Options.Nil_Option   => "",
               when Ada_Lib.Options.Plain =>
                  Quote (" option", Element.Option.Option),
               when Ada_Lib.Options.Modified     =>
                  Quote (" modifier", Element.Option.Modifier) &
                  Quote (" option", Element.Option.Option)) &
            Quote (" options", Contents.options) &
            Quote (" description", Contents.Description));

         if Contents.Has_Trace /= Contents.Trace_Option_Set then
            raise Failed with "missing trace option for " &
               Option_Image (Element, True) & " at " & Here;
         end if;
      end Check;
      -------------------------------------------------------------------------


   begin
      Log_In (Log_It);
      if Do_Trace_Checks then
         Line_Package.Iterate (Lines, Check'access);
      end if;
      Log_Out (Log_It);
   end Check_Traces;

   ----------------------------------------------------------------------------
   procedure Create_Option (
      Option                     : in     Character;
      Trace_Option               : in     Boolean;
      Parameter                  : in     String;
      Description                : in     String;
      Component                  : in     String;
      Modifier                   : in     Character;
      Source_Line                : in     String := Ada_Lib.Trace.Here) is
   ----------------------------------------------------------------------------

      Flags          : constant Ada_Lib.Options.Flag_Option_Type :=
                        Options.Initialize (Option, Modifier);
      Log_It         : constant Boolean := Debug or else Trace_Options;

   begin
      Log_In (Log_It, Quote ("option", option) &
         " trace option " & Trace_Option'img &
         Quote (" parameter", Parameter) &
         Quote (" description", Description) &
         Quote (" component", Component) &
         Quote ( "modifier", Modifier) & " from " & Source_Line);

      Add_Option (Flags, Trace_Option, Parameter, Description, Component,
         Source_Line);
      Log_Out (Log_It);
   end Create_Option;

   ----------------------------------------------------------------------------
   procedure Display (
      Parameters                 : in     Ada_Lib.Options.Argument_Array;
      Output_Line                : not null access procedure (
      Line                       : in     String))is
   ----------------------------------------------------------------------------

      -------------------------------------------------------------------------
      procedure Output (
         Cursor                  : in    Line_Package.Cursor) is
      -------------------------------------------------------------------------

         Element     : Element_Type renames Line_Package.Element (Cursor);
         Contents    : Element_Contents_Type renames Element.Contents.all;
         Line        : Ada_Lib.Strings.Unlimited.String_Type;
         Start_Description
                     : constant Natural := 7 + Maximum_Parameter_Length;
         Start_Component
                     : constant Natural := Start_Description +
                        Maximum_Description_Length + 3;
      begin
         Log_In (Debug, -- Quote ("option", Element.Option.Option) &
            " has trace " & Contents.Has_Trace'img &
            " Trace_Option_Set " & Contents.Trace_Option_Set'img &
            " kind " & Element.Option.Kind'img & " " &
            (case Element.Option.Kind is
               when Ada_Lib.Options.Nil_Option   => "",
               when Ada_Lib.Options.Plain =>
                  Quote (" option", Element.Option.Option),
               when Ada_Lib.Options.Modified     =>
                  Quote (" modifier", Element.Option.Modifier) &
                  Quote (" option", Element.Option.Option)) &
            Quote (" options", Contents.options) &
            Quote (" description", Contents.Description));

--       if Contents.Has_Trace /= Contents.Trace_Option_Set then
--          raise Failed with "missing trace option for " &
--             Element.Option.Image & " at " & Here;
--       end if;
         Line.Append ("-");
         Line.Append (Option_Image (Element, False));
         Line.Append (" ");

         if Contents.options'length > 0 then
            Line.Append ("<" & String (Contents.options) & ">");
         end if;

         while Line.Length < Start_Description loop
            Line.Append (" ");
         end loop;

         Line.Append (": ");
         Line.Append (String (Contents.Description));

         if Contents.Component'Length > 0 then
            while Line.Length < Start_Component loop
               Line.Append (" ");
            end loop;

            Line.Append ("(" & String (Contents.Component) & ")");
         end if;

         Log_Here (Debug, Ada_Lib.Strings.Unlimited.Quote ("line", Line));
         Output_Line (Line.Coerce);
         Log_Out (Debug);
      end Output;
      -------------------------------------------------------------------------

      First_Parameter   : Boolean := True;

   begin
      Log_In (Debug, "parameters length" & Parameters'length'img);
      Put (Command_Name & " ");
      if Parameters'length >= 1 then
         for Parameter of Parameters loop
            if First_Parameter then
               First_Parameter := False;
            else
               Put (", ");
            end if;
            Log_Here (Debug, Quote ("parameter", Parameter.Coerce));
            Put (Parameter.Coerce & " ");
         end loop;
      end if;
      Put_Line ("<command line options>:");
      Line_Package.Iterate (Lines, Output'access);
      Log_Out (Debug);
   end Display;

   ----------------------------------------------------------------------------
   function Equal (
      Left, Right                : in     Element_Type
   ) return Boolean is
   ----------------------------------------------------------------------------

   begin
      return Left = Right;
   end Equal;

   ----------------------------------------------------------------------------
   procedure Find_Duplicate (
      Option         : in     Ada_Lib.Options.Flag_Option_Type;
      options        : in     String;
      Description    : in     String;
      Component      : in     String;
      From           : in     String) is
   ----------------------------------------------------------------------------

      Log_It         : constant Boolean := Debug or else Trace_Options;

      -------------------------------------------------------------------------
      procedure Check (
         Cursor                  : in    Line_Package.Cursor) is
      -------------------------------------------------------------------------

         Element                 : Element_Type renames Line_Package.Element (
                                    Cursor);

      begin
         Log_Here (Log_It, Option_Image (Element, True));
         if Element.Option = Option then
            Log_Here (Log_It, "option " & Option'img);
            declare
               Message  : constant String :=
                  "duplicate options for help. Existing " &
                  Option_Image (Element, True) &
                  Quote (" options", options) &
                  Quote (" description", Description) &
                  Quote (" component", Component) &
                  Quote (" from", From);

            begin
               Put_Line (Message);

               raise Failed with Message;
            end;
         end if;
      end Check;
      -------------------------------------------------------------------------

   begin
      Log_In (Log_It, "option " & Option'img);
      Line_Package.Iterate (Lines, Check'access);
      Log_Out (Log_It);
   end Find_Duplicate;

   ----------------------------------------------------------------------------
   function Less_Than (
      Left, Right                : in     Element_Type
   ) return Boolean is
   ----------------------------------------------------------------------------

   begin
      return Left.Option.Less (Right.Option);
   end Less_Than;

   ----------------------------------------------------------------------------
   function Option_Image (
      Element                    : in     Element_Type;
      Label                      : in     Boolean
   ) return String is
   ----------------------------------------------------------------------------

      Contents    : Element_Contents_Type renames Element.Contents.all;

   begin
      return Element.Option.Image (Label, False) & (
         if Label then
            Quote (" component", Contents.Component) &
            Quote (" description", Contents.Description) &
            Quote (" options", Contents.options)
         else
            "");
   end Option_Image;

   ----------------------------------------------------------------------------
   procedure Reset is
   ----------------------------------------------------------------------------

   begin
      Log_Here (Debug);
      Lines.Clear;
   end Reset;

   ----------------------------------------------------------------------------
   procedure Set_Has_Trace (
      Option                     : in     Character;
      Modifier                   : in     Character) is
   ----------------------------------------------------------------------------

      -------------------------------------------------------------------------
      procedure Set (
         Cursor                  : in     Line_Package.Cursor) is
      -------------------------------------------------------------------------

         Element     : Element_Type renames Line_Package.Element (Cursor);
         Contents    : Element_Contents_Type renames Element.Contents.all;

      begin
         if Element.Option = Ada_Lib.Options.Initialize (Option, Modifier) then
            Log_Here (Debug, Option_Image (Element, True) & " set");
            Contents.Trace_Option_Set := True;
         end if;
      end Set;
      -------------------------------------------------------------------------

   begin
      Log_In (Debug, Quote ("option", Option) & Quote (" modifier", Modifier));
      Line_Package.Iterate (Lines, Set'access);
      Log_Out (Debug);
   end Set_Has_Trace;
   ----------------------------------------------------------------------------
begin
     Debug := Debug or Ada_Lib.Options.Ada_Lib_Options.Debug_All;
--Debug := True;
--Trace_Options := True;
   Log_Here (Debug or Trace_Options or Elaborate);
-- Ada_Lib.Options.Runstring.Options.Register (
--    Ada_Lib.Options.Runstring.With_Parameters,
--    Ada_Lib.Options.Create_Options (
--       Ada_Lib.Options.Options_Prefix));
end  Ada_Lib.Help;
