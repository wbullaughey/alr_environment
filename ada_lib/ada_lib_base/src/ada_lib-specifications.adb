with Ada.Text_IO; use  Ada.Text_IO;
with Ada_Lib.Options;

package body Ada_Lib.Specifications is

   Debug : Boolean renames Ada_Lib.Options.Ada_Lib_Options.Specifications_Debug;

   -------------------------------------------------------------------
   function Get_Option (
      Specification              : in     Specification_Type
   ) return Character is
   -------------------------------------------------------------------

   begin
      return Specification.Option;
   end Get_Option;

   -------------------------------------------------------------------
   function Get_Prompt (
      Specification              : in     Specification_Type
   ) return Ada_Lib.Strings.String_Constant_Access is
   -------------------------------------------------------------------

   begin
      return Specification.Prompt;
   end Get_Prompt;

   package body Selection_Package is

      -------------------------------------------------------------------
      function Get_Level (
         Specification           : in     Specification_Level_Type
      ) return Priority_Type is
      -------------------------------------------------------------------

      begin
         return Specification.Priority;
      end Get_Level;

   end Selection_Package;

   package body Specification_Package is

--    Settings                   : array (Selection_Type) of Priority_Type := (
--                                  others => Priority_Type'first);

      -------------------------------------------------------------------
      procedure Help is
      -------------------------------------------------------------------

      begin
         put_line ("Not_Implemented");
--       for Trace in Selection_Type'succ (Selection_Type'first) .. Selection_Type'last loop
--          declare
--             Specification  : Specification_Type renames Specifications (Trace);
--
--          begin
--             pragma Assert (Specifications(Trace).Get_Prompt /= Null);
--             Put_Line ("   " & Specification.Get_Option & "     : " &
--                Specification.Get_Prompt.all);
--          end;
--       end loop;
      end Help;

      --------------------------------------------------------------------
      function Test (
         Which             : in   String;
         Priority             : in   Priority_Type := Priority_Type'first
      ) return Boolean is
      pragma Unreferenced (Which, Priority);
      --------------------------------------------------------------------

      begin
         put_line ("Not_Implemented");
         return false;
--       return Settings (Which) >= Priority;
      end Test;

      --------------------------------------------------------------------
      procedure Set (
         Which             : in   String;
         Priority             : in   Priority_Type := Priority_Type'first) is
      pragma Unreferenced (Which, Priority);
      --------------------------------------------------------------------

      begin
         put_line ("Not_Implemented");
--       Settings (Which) := Priority;
      end Set;

      --------------------------------------------------------------------
      procedure Set (
         Options                 : in   String) is
      pragma Unreferenced (Options);
      --------------------------------------------------------------------

--       Index                   : Positive := Options'first;

      begin
put_line ("Not_Implemented");
--       Not_Implemented;
--       while Index <= Options'last loop
--          declare
--             Priority             : Priority_Type;
--             Option            : constant Character := Options (Index);
--
--          begin
--             if Index = Options'last then
--                Ada.Exceptions.Raise_Exception (Invalid'identity,
--                   "Missing trace Priority for option '" & Option & "'");
--             end if;
--
--             Log (Debug, Here, Who & Quote (Options (Index + 1)));
--
--             case Options (Index + 1) is
--
--                when 'n' =>
--                   Priority := Off;
--
--                when 'l' =>
--                   Priority := Priority_Type'first;
--
--                when 'm' =>
--                   Priority := Medium;
--
--                when 'h' =>
--                   Priority := High;
--
--                when others =>
--                   Ada.Exceptions.Raise_Exception (Invalid'identity,
--                      "Invalid trace Priority '" & Options (Index + 1) &
--                      " for option '" & Option & "' for Settings");
--             end case;
--
--             for Which in Specifications'range loop
--                if Specifications (Which).Option = Option then
--                   Set (Which, Priority);
--                   return;
--                end if;
--             end loop;
--
--             Ada.Exceptions.Raise_Exception (Invalid'identity,
--                "Invalid option '" & Option & "' for Settings");
--          end;
--
--          Index := Index + 2;
--       end loop;
      end Set;

   end Specification_Package;


end Ada_Lib.Specifications;
