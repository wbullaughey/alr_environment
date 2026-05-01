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

-- use type Ada_Lib.Options.Base_Flag_Option_Type;
   use type Ada_Lib.Options.Flags.Flag_Option_Type;

   subtype Line_Type             is String;

   type Element_Type (
      Parameter_Length           : Natural;
      Description_Length         : Positive;
      Component_Length           : Natural;
      Source_Line_Length         : Positive) is record
      Option                     : Ada_Lib.Options.Flags.Flag_Option_Type;
      Parameter                  : Line_Type (1 .. Parameter_Length);
      Description                : Line_Type (1 .. Description_Length);
      Component                  : Line_Type (1 .. Component_Length);
      Source_Line                : Line_Type (1 .. Source_Line_Length);
   end record;

   function Equal (
      Left, Right                : in     Element_Type
   ) return Boolean;

   function Less_Than (
      Left, Right                : in     Element_Type
   ) return Boolean;

   function Option_Image (
      Element                    : in     Element_Type
   ) return String;

   package Line_Package is new Ada.Containers.Indefinite_Ordered_Sets (
      Element_Type   => Element_Type,
      "<"   => Less_Than,
      "="   => Equal);

   Debug                         : Boolean renames
                                    Ada_Lib.Options.Ada_Lib_Help.Debug;
   Lines                         : Line_Package.Set;
   Maximum_Description_Length    : Natural := 0;
   Maximum_Parameter_Length      : Natural := 0;

   procedure Find_Duplicate (
      Option                     : in     Ada_Lib.Options.Flags.Flag_Option_Type;
      Parameter                  : in     String;
      Description                : in     String;
      Component                  : in     String;
      From                       : in     String);

   ----------------------------------------------------------------------------
   procedure Add_Option (
      Option                     : in     Ada_Lib.Options.Flags.Flag_Option_Type;
      Parameter                  : in     String;
      Description                : in     String;
      Component                  : in     String := "";
      Source_Line                : in     String := Ada_Lib.Trace.Here) is
   ----------------------------------------------------------------------------

   begin
      Log_In (Debug, Option.Image &
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
            Component         => Line_Type (Component),
            Component_Length  => Component'length,
            Description       => Line_Type (Description),
            Description_Length=> Description'length,
            Option            => Option,
            Parameter         => Line_Type (Parameter),
            Parameter_Length  => Parameter'length,
            Source_Line       => Line_Type (Source_Line),
         Source_Line_Length=> Source_Line'length));
      Log_Out (Debug);

   exception

      when Fault: Constraint_Error =>
         Trace_Message_Exception (Debug, Fault, Option.Image);
         declare
            -------------------------------------------------------
            procedure Process (
               Cursor            : in     Line_Package.Cursor) is
            -------------------------------------------------------

               Message           : constant String :=
                                    Option.Image &
                                    (if Description'length > 0 then
                                          Quote (" parameter ", Description)
                                       else
                                          "") &
                                    Quote (" already defined for ", Component) &
                                    Quote (" at ", Line_Package.Element (Cursor).Source_Line) &
                                    Quote (" set from", Source_Line);
            begin
               Log_Here (Debug or Trace_Options, Quote ("Description", Description) &
                  Quote ("Component", Component) &
                  Quote ("Message", Message));
               if Option = Line_Package.Element (Cursor).Option then
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
               Quote (" parameter", Parameter) &
               Quote (" description", Description) &
               Quote (" component", Component) &
               " from " & Source_Line);
--          Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.No_Error);
         end;

      when Fault: others =>
         Put_Line (Option.Image & Quote (" Description ", Description) &
            Quote (" for ", Component) & " already defined");
         Trace_Message_Exception (Debug, Fault, Option.Image);
         raise;

   end Add_Option;

   ----------------------------------------------------------------------------
   procedure Create_Option (
      Option                     : in     Character;
      Parameter                  : in     String;
      Description                : in     String;
      Component                  : in     String;
      Modifier                   : in     Character;
      Source_Line                : in     String := Ada_Lib.Trace.Here) is
   ----------------------------------------------------------------------------

      Flag                       : Ada_Lib.Options.Flags.Flag_Option_Type;

   begin
      Log_In (Debug, Quote ("parameter", Parameter) &
         Quote ("description", Description) & Quote ("component", Component) &
         Quote ("modifier", Modifier) & " from " & Source_Line);
      Ada_Lib.Options.Flags.Create_Option (Flag, Option, Modifier);
      Add_Option (Flag, Parameter, Description, Component, Source_Line);
      Log_Out (Debug);
   end Create_Option;

   ----------------------------------------------------------------------------
   procedure Display (
      Output_Line                : not null access procedure (
      Line                       : in     String))is
   ----------------------------------------------------------------------------

      -------------------------------------------------------------------------
      procedure Output (
         Cursor                  : in    Line_Package.Cursor) is
      -------------------------------------------------------------------------

         Element                 : Element_Type renames Line_Package.Element (
                                    Cursor);
         Line                    : Ada_Lib.Strings.Unlimited.String_Type;
         Start_Description       : constant Natural := 7 +
                                    Maximum_Parameter_Length;
         Start_Component         : constant Natural := Start_Description +
                                    Maximum_Description_Length + 3;

      begin
         Log_In (Debug, Quote ("option", Element.Option.Option) &
            (case Element.Option.Kind is
               when Ada_Lib.Options.Nil_Option   => "",
               when Ada_Lib.Options.Plain =>
                  Quote (" option", Element.Option.Option),
               when Ada_Lib.Options.Modified     =>
                  Quote (" modifier", Element.Option.Modifier) &
                  Quote (" option", Element.Option.Option)) &
            Quote (" parameter", Element.Parameter) &
            Quote (" description", Element.Description));
         Line.Append ("-");
         Line.Append (Option_Image (Element));
         Line.Append (" ");

         if Element.Parameter'length > 0 then
            Line.Append ("<" & String (Element.Parameter) & ">");
         end if;

         while Line.Length < Start_Description loop
            Line.Append (" ");
         end loop;

         Line.Append (": ");
         Line.Append (String (Element.Description));

         if Element.Component'Length > 0 then
            while Line.Length < Start_Component loop
               Line.Append (" ");
            end loop;

            Line.Append ("(" & String (Element.Component) & ")");
         end if;

         Log_Here (Debug, Ada_Lib.Strings.Unlimited.Quote ("line", Line));
         Output_Line (Line.Coerce);
         Log_Out (Debug);
      end Output;
      -------------------------------------------------------------------------

   begin
      Log_In (Debug);
      Put_Line (Command_Name & " command line options:");
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
      Option         : in     Ada_Lib.Options.Flags.Flag_Option_Type;
      Parameter      : in     String;
      Description    : in     String;
      Component      : in     String;
      From           : in     String) is
   ----------------------------------------------------------------------------

      -------------------------------------------------------------------------
      procedure Check (
         Cursor                  : in    Line_Package.Cursor) is
      -------------------------------------------------------------------------

         Element                 : Element_Type renames Line_Package.Element (
                                    Cursor);

      begin
         Log_Here (Debug, Option_Image (Element));
         if Element.Option = Option then
            Put_Line ("duplicate options for help. Previous " &
               Option_Image (Element) &
               Quote (" parameter", Parameter) &
               Quote (" description", Description) &
               Quote (" component", Component) &
               Quote (" from", From));
            raise Failed with "duplicate options for help. Previous " &
               Option_Image (Element);
         end if;
      end Check;
      -------------------------------------------------------------------------

   begin
      Line_Package.Iterate (Lines, Check'access);
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
      Element                    : in     Element_Type
   ) return String is
   ----------------------------------------------------------------------------

   begin
      return Element.Option.Image (False) &
         Quote (" parameter", Element.Parameter) &
         Quote (" component", Element.Component) &
         Quote (" description", Element.Description);
   end Option_Image;

   ----------------------------------------------------------------------------
   procedure Reset is
   ----------------------------------------------------------------------------

   begin
      Log_Here (Debug);
      Lines.Clear;
   end Reset;

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
