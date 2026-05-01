with Ada_Lib.OS;

package body Ada_Lib.OS_Strings is

   ---------------------------------------------------------------
   function Scratch_File_Path return String is
   ---------------------------------------------------------------

   begin
      return "/home/" & Ada_Lib.OS.Get_Environment (User_Environment_Variable) & "/tmp";
   end Scratch_File_Path;

end Ada_Lib.OS_Strings;
