with Ada.Characters.Latin_1;
--with Ada_Lib.Options;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
--with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with Hex_IO;

package body Ada_Lib.Options.Runstring is

-- use type Ada_Lib.Strings.Unlimited.String_Type;

   function Find_Registration (
      Registrations           : in     Registrations_Type;
      Option                  : in     Flag_Option_Type
   ) return Constant_Reference_Type;

   Debug       : Boolean renames Ada_Lib_Options_Runstring.Debug;
   Debug_All   : Boolean renames Ada_Lib_Options.Debug_All;
   LF                   : Character renames Ada.Characters.Latin_1.LF;

   -------------------------------------------------------------------
   overriding
   function "=" (
      Left, Right             : in     Element_Type
   ) return Boolean is
   -------------------------------------------------------------------

   begin
      return Left.Option = Right.Option and then
             Left.Kind = Right.Kind;
   end "=";

   -------------------------------------------------------------------
   function Image (
      Element                 : in     Element_Type
   ) return String is
   -------------------------------------------------------------------

   begin
      return Element.Option.Image & (case Element.Kind is

         when With_Parameters =>
            " with parameter",

         when Without_Parameters =>
            "");
   end Image;

   -------------------------------------------------------------------
   function Image (
      Registrations        : in     Registrations_Type
   ) return String is
   -------------------------------------------------------------------

      Result   : Ada_Lib.Strings.Unlimited.String_Type;

      ----------------------------------------------------------------
      procedure List (
         Position      :     in Registrations_Package.Cursor) is
      ----------------------------------------------------------------

      begin
         Result := Result & "   " &
            Registrations_Package.Element (Position).Image & LF;
      end List;
      ----------------------------------------------------------------

   begin
      Registrations_Package.Iterate (
         Registrations_Package.List (Registrations), List'access);
      return Result.Coerce;
   end Image;

   -------------------------------------------------------------------
   function Find_Registration (
      Registrations              : in     Registrations_Type;
      Option                     : in     Flag_Option_Type
   ) return Constant_Reference_Type is
   -------------------------------------------------------------------

      use Registrations_Package;

      Cursor          : Registrations_Package.Cursor := First (Registrations);

   begin
      Log_In (Debug, Option.Image & " registrations" & Registrations.Length'img);
      while Has_Element (Cursor) loop
         declare
            Element  : constant Constant_Reference_Type :=
                        Constant_Reference (Registrations, Cursor);
         begin
            Log_Here (Debug, Element.Option.Image);
            if Element.Option.all = Option then
               Log_Out (Debug, "found " & Element.Option.Image);
               return Element;
            end if;
         end;

         Next (Cursor);
      end Loop;

      Log_Out (Debug);
      raise Failed with Quote ("options", Option.Option) & " not defined";
   end Find_Registration;

   protected body Registration_Type is

      -------------------------------------------------------------------
      function All_Options (
         Quote                   : in     Boolean := True
      ) return String is
      -------------------------------------------------------------------

         Result                  : Ada_Lib.Strings.Unlimited.String_Type;

      begin
         Log_In (Debug, "registrations" & Registrations.Length'img);
         for Registration of Registrations loop
            Result := Result &
               Registration.Option.Image (Quote, Kind => False) &
               (if Quote then
                  " "
               else
                  "");
         end Loop;
--       Result := Result & " ";
         Log_Out (Debug, Result.Coerce);
         return Result.Coerce;
      end All_Options;

      -------------------------------------------------------------------
      function All_Registered (
         Quote                   : in     Boolean := True
      ) return String is
      -------------------------------------------------------------------

         Result                  : Ada_Lib.Strings.Unlimited.String_Type;

      begin
         Log_In (Debug, "registrations" & Registrations.Length'img);
         for Registration of Registrations loop
            Result := Result & Registration.Option.Image (Quote ) & ": " &
               Registration.From & " ";
         end Loop;
         Log_Out (Debug, Result.Coerce);
         return Result.Coerce;
      end All_Registered;

      -------------------------------------------------------------------
      function Has_Parameter (
         Option                  : in     Flag_Option_Type
      ) return Boolean is
      -------------------------------------------------------------------

      begin
         if Is_Registered (Option) then
            declare
               Parameter          : constant Constant_Reference_Type :=
                                    Find_Registration (Registrations, Option);
            begin
               return Parameter.Kind = With_Parameters;
            end;
         end if;

         return False;
      end Has_Parameter;

      -------------------------------------------------------------------
      function Is_Registered (
         Option                  : in     Flag_Option_Type
      ) return Boolean is
      -------------------------------------------------------------------

      use Registrations_Package;

         Cursor          : Registrations_Package.Cursor := First (Registrations);

      begin
         Log_In (Debug or Trace_Options, Option.Image &
            " registrations" & Registrations.Length'img);
         while Has_Element (Cursor) loop
            declare
               Element  : constant Constant_Reference_Type :=
                           Constant_Reference (Registrations, Cursor);
            begin
               if Element.Option.all = Option then
                  return Log_Out (True, Debug or Trace_Options, Element.Option.Image);
               end if;
            end;
            Next (Cursor);
         end Loop;
         return Log_Out (False, Debug or Trace_Options);
      end Is_Registered;

      -------------------------------------------------------------------
      procedure Register (
         Kind                    : in     Kind_Type;
         Options                 : in     Flag_List_Type'class;
         From                    : in     String:= Ada_Lib.Trace.Here) is
      -------------------------------------------------------------------

         ------------------------------------------------------------
         procedure Check_Duplicates (
            Option      :     Flag_Option_Type) is
         ------------------------------------------------------------

         begin
            Log_In (Debug or Trace_Options,
               "registrations" & Registrations.Length'img);
            if Is_Registered (Option) then
               Log_Exception (Debug or Trace_Options);
               raise Duplicate_Options with Option.Image &
                  " a parameter defined at " &
                  Registration (Option) &
                  " called from " & From;
            end if;
            Log_Out (Debug or Trace_Options, "unique option " & Option.Image);
         end Check_Duplicates;

         ------------------------------------------------------------
         procedure Register_Option (
            Option      :     Flag_Option_Type) is
         ------------------------------------------------------------

            Element           : Element_Type;

         begin
            Log_Here (Debug or Trace_Options, Option.Image & " kind " & Kind'img);
            Element.From.Construct (From);
            Element.Kind := Kind;
            Element.Option := new Flag_Option_Type'(Option);
            Registrations.Append (Element);
         end Register_Option;

      begin
         Log_In (Debug or Trace_Options,
            "options " & Options.Image &
            " Kind " & Kind'img &
            " registrations" & Registrations.Length'img &
            " address " & Hex_IO.Hex (Registrations'address) &
            " called from " & From);

         Options.Iterate (Check_Duplicates'access);
         Options.Iterate (Register_Option'access);

         Log_Out (Debug or Trace_Options,
            "registrations" & Registrations.Length'img &
            " registrations " & LF & "options: " & LF & Registrations.Image);
      end Register;

      -------------------------------------------------------------------
      function Registration (
         Option                  : in     Flag_Option_Type
      ) return String is
      -------------------------------------------------------------------

         Result : constant String := Find_Registration (
                     Registrations, Option).From.Coerce;
      begin
         Log_Here (Debug, Quote ("result", Result));
         return Result;

      exception
         when Fault: others =>
            Trace_Exception (Debug, Fault, Option.Image &
               " not defined");
            raise;

      end Registration;

      -------------------------------------------------------------------
      procedure Reset is         -- clears sets if need different iterator sets
      -------------------------------------------------------------------

      begin
         Log_In (Debug, "length" & Registrations.Length'img);
         Registrations.Clear;
         Log_Out (Debug, "length" & Registrations.Length'img);
      end Reset;

   end Registration_Type;

begin
     Debug := Debug or Debug_All;
--Debug := True;
--Trace_Options := True;
--Elaborate := True;
   Log_Here (Debug or Elaborate or Trace_Options);
end Ada_Lib.Options.Runstring;
