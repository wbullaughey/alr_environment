with Ada_Lib.Unit_Test.Test_Cases;
--with Gnoga.Gui.Window;
--with GNOGA_Ada_Lib;
with Gnoga.Application.Multi_Connect;
--with Gnoga.Gui.Element.Common;
--with Gnoga.Gui.Element.Form;
--with Gnoga.Gui.View;

package Ada_Lib.GNOGA.Unit_Test is

   Failed                        : exception;

   type GNOGA_Tests_Interface    is limited interface;

   type GNOGA_Tests_Type (
      Initialize_GNOGA
                  : Boolean;
      Test_Driver : Boolean) is abstract limited new
                     Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type with
                        null record;

   type GNOGA_Tests_Access       is access GNOGA_Tests_Type;
   type GNOGA_Tests_Class_Access is access GNOGA_Tests_Type'class;

   procedure Set_Up_With_Handler (
      Test           : in out GNOGA_Tests_Type;
      Test_Handler   : in     Standard.Gnoga.Application.Multi_Connect.
                                 Application_Connect_Event;
      Wait_For_Message_Loop_Exit
                     : in     Boolean
   ) with Post => Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type'class (
                     Test).Verify_Set_Up;

   overriding
   procedure Tear_Down (
      Test : in out GNOGA_Tests_Type
   ) with post => Test.Verify_Tear_Down;

end Ada_Lib.GNOGA.Unit_Test;
