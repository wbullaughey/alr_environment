with Ada_Lib.Options.Flags;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Trace; use Ada_Lib.Trace;

package body Ada_Lib.Options.Create is

   Debug                : Boolean renames Ada_Lib_Options.Debug;

   ----------------------------------------------------------------------------
   function Create_One (-- create a single option
      Option                     : in     Character;
      Modifier                   : in     Character;
      From                       : in     String := Ada_Lib.Trace.Here
   ) return Flag_List_Type is
   ----------------------------------------------------------------------------

      Flag                       : constant Flags.Flag_Option_Access :=
                                    Flags.Allocate_Option (Option, Modifier, From);
      Options                    : Base_Options_Array (1 .. 1);
      Result                     : Flag_List_Type;

   begin
      Options (1) := Base_Flag_Option_Class_Access (Flag);
      Result.Create_Options (Options, From);
      return Result;
   end Create_One;

-- ----------------------------------------------------------------------------
-- function Create_Option (
--    Option                     : in     Character;
--    Modifier                   : in     Character;
--    From                       : in     String := Ada_Lib.Trace.Here
-- ) return Base_Flag_Option_Class_Access is
-- ----------------------------------------------------------------------------
--
--    Result                     : constant Base_Flag_Option_Class_Access :=
--                                  new Flag_Option_Type;
-- begin
--    Result.Create_Option (Option, Modifier, From);
--    return Result;
-- end Create_Option;

   ----------------------------------------------------------------------------
   function Create_Multiple (   -- create multiple option
      Source                     : in     String;
      Modifier                   : in     Character;
      From                       : in     String := Ada_Lib.Trace.Here
   ) return Flag_List_Type is
   ----------------------------------------------------------------------------

      Count                      : Natural := 0;
      Options                    : Base_Options_Array (1 .. Source'length);
      Result                     : Flag_List_Type;

   begin
      Log_In (Debug or Trace_Options, Quote ("source", Source) & (if Modifier = Unmodified_flag then
            " no modifier"
         else
            Quote (" modifier", Modifier)) &
         " from " & From);
      for Option of Source loop
         declare
            Flag                 : constant Flags.Flag_Option_Access :=
                                    Flags.Allocate_Option (Option, Modifier, From);
         begin
            Count := Count + 1;
            Options (Count) := Base_Flag_Option_Class_Access (Flag);
         end;
      end loop;

      Result.Create_Options (Options);
      Log_Out (Debug or Trace_Options, "count" & Count'img);
      return Result;
   end Create_Multiple;

-- ----------------------------------------------------------------------------
-- function Create_Options (
--    Source                     : in     String;
--    Modifier                   : in     Character;
--    From                       : in     String := Ada_Lib.Trace.Here
-- ) return Ada_Lib.Options.Options_Access is
-- ----------------------------------------------------------------------------
--
--    Options                    : constant Flag_Option_Type :=
--                                  Create_Options (Source, Modifier, From);
--    Result                     : constant Ada_Lib.Options.Options_Access :=
--                                  new Options_Type (1 .. Options'last);
-- begin
--    Result.all := Options;
--    return Result;
-- end Create_Options;


begin
--Debug := True;
--Trace_Options := True;
--Elaborate := True;
   Log_Here (Debug or Trace_Options or Elaborate);
end Ada_Lib.Options.Create;

