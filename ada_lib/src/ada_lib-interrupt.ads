with Ada.Interrupts;

package Ada_Lib.Interrupt is
   pragma Unreserve_All_Interrupts;


   Failed                  : exception;
   Reserved_Interrupt      : exception;
   No_Handler              : exception;

   subtype Interrupt_Type is Ada.Interrupts.Interrupt_ID;

   type Interrupt_Callback_Type
                           is access procedure;

   Debug                         : aliased Boolean := False;

   protected type Handler_Type (
      Interrupt            : Interrupt_Type;
      Callback             : Interrupt_Callback_Type) is

      function Occured return Boolean;

   private

      procedure Handler
      with Attach_Handler => Interrupt;

      Got_It               : Boolean := False;

   end Handler_Type;
end Ada_Lib.Interrupt;
