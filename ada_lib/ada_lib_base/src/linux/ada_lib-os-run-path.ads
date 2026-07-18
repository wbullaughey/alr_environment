with Ada_Lib.OS;

package Ada_Lib.Test.Ada_Lib.Run_Remote_Path is

-- Home_Path                     : constant String := "/Users/";
      User                       : constant String := Ada_Lib.OS.Get_Environment ("USER");
      Local_Home_Directory       : constant String := "/Users/" & User;
      Log_File                   : constant String := Local_Home_Directory & "/tmp/run_remote.txt";
      Remote_Home_Directory      : constant String := "/home/" & User;

end Ada_Lib.Test.Ada_Lib.Run_Remote_Path;
