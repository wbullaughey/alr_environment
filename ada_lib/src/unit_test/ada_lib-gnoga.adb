with Ada_Lib.Options.Unit_Test;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with Gnoga.Gui.Base;

package body Ada_Lib.GNOGA is

   use type Standard.Gnoga.Gui.Window.Pointer_To_Window_Class;

   Debug       : Boolean renames Ada_Lib.Options.Unit_Test.
                  Ada_Lib_GNOGA_Unit_Test.GNOGA_Debug;
   Main_Window : Standard.Gnoga.Gui.Window.Pointer_To_Window_Class := Null;

   ---------------------------------------------------------------
   procedure Clear_Main_Window is
   ---------------------------------------------------------------

   begin
      Main_Window := Null;
   end Clear_Main_Window;

   ---------------------------------------------------------------
   function Get_Main_Window
   return Standard.Gnoga.Gui.Window.Pointer_To_Window_Class is
   ---------------------------------------------------------------

   begin
      return Main_Window;
   end Get_Main_Window;

   ---------------------------------------------------------------
   function Get_Window_Connection_Data
   return Connection_Data_Class_Access is
   ---------------------------------------------------------------

      Result   : constant Standard.Gnoga.Types.
                  Pointer_to_Connection_Data_Class :=
                     Standard.Gnoga.Gui.Base.Connection_Data (
                        Standard.Gnoga.Gui.Base.Base_Type (Main_Window.all));
   begin
      return Connection_Data_Class_Access (Result);
   end Get_Window_Connection_Data;

   ---------------------------------------------------------------
   function Has_Main_Window
   return Boolean is
   ---------------------------------------------------------------

      Result   : constant Boolean := Main_Window /= Null;

   begin
      return Log_Here (Result, Debug or else Trace_Pre_Post_Conditions or else
         (Trace_Pre_Post_False and not Result));
   end Has_Main_Window;

   ---------------------------------------------------------------
   procedure Set_Connection_Data_Main_Window (
      Connection_Data         : in out Connection_Data_Type;
      Main_Window             : in     Standard.Gnoga.Gui.Window.
                                          Pointer_To_Window_Class) is
   ---------------------------------------------------------------

   begin
      Log_Here (Debug);
      Connection_Data.Main_Window := Main_Window;
   end Set_Connection_Data_Main_Window;

   ---------------------------------------------------------------
   procedure Set_Main_Window (
      Window    : in     Standard.Gnoga.Gui.Window.Pointer_To_Window_Class) is
   ---------------------------------------------------------------

   begin
      Main_Window := Window;
   end Set_Main_Window;

end Ada_Lib.GNOGA;
