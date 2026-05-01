with Gnoga.Gui.Element.Common;
with Gnoga.Gui.Element.Form;
with Gnoga.Gui.View;
with Gnoga.Gui.Window;
with Gnoga.Types;
--with GNOGA_Ada_Lib;

package Ada_Lib.GNOGA is

   -- use for all types that create a GNOGA object
   type GNOGA_Interface    is limited interface;

   type Connection_Data_Type is new Standard.Gnoga.Types.Connection_Data_Type with
                                    record
         Main_Window : Standard.Gnoga.Gui.Window.Pointer_To_Window_Class := Null;
      end record;

   type Connection_Data_Access is access all Connection_Data_Type;
   type Connection_Data_Class_Access is access all Connection_Data_Type'class;

   procedure Set_Connection_Data_Main_Window (
      Connection_Data         : in out Connection_Data_Type;
      Main_Window             : in     Standard.Gnoga.Gui.Window.
                                          Pointer_To_Window_Class);

   type Form_Connection_Type is new Connection_Data_Type with  record
      Button                     : Standard.Gnoga.Gui.Element.Common.Button_Type;
      Display_Window             : Standard.Gnoga.Gui.View.View_Type;
      Form                       : Standard.Gnoga.Gui.Element.Form.Form_Type;
   end record;

   type Form_Connection_Access        is access all Form_Connection_Type;
   type Form_Connection_Class_Access  is access all Form_Connection_Type'class;

   procedure Clear_Main_Window;

   function Get_Main_Window
   return Standard.Gnoga.Gui.Window.Pointer_To_Window_Class
   with Pre => Has_Main_Window;

   function Get_Window_Connection_Data
   return Connection_Data_Class_Access
   with Pre => Has_Main_Window;

   function Has_Main_Window
   return Boolean;

   procedure Set_Main_Window (
      Window    : in     Standard.Gnoga.Gui.Window.
                           Pointer_To_Window_Class
   ) with Pre => not Has_Main_Window;

end Ada_Lib.GNOGA;
