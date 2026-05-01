with  Ada_Lib.OS;

package Ada_Lib.Test.Ada_Lib.Run_Remote_Path is

   Host                          : constant String := Ada_Lib.OS.Get_Environment ("COMPUTERNAME");
   Local_Home_Directory          : constant String := "\\" & Host & "\admin$";
   Log_File                      : constant String := Local_Home_Directory & "\Temp\run_remote.txt";
   User                          : constant String := Ada_Lib.OS.Get_Environment ("USERNAME");
   Remote_Home_Directory         : constant String := "/home/" & User;

end Ada_Lib.Test.Ada_Lib.Run_Remote_Path;
