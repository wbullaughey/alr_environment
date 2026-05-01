
package body Ada_Lib.Database.Remote_Control is

   ---------------------------------------------------------------
   function Is_Active return Boolean is
   ---------------------------------------------------------------

   begin
      return Remote.Is_Active;
   end Is_Active;

end Ada_Lib.Database.Remote_Control;
