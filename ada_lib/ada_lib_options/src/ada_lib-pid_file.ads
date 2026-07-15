package Ada_Lib.Pid_File is

   Process_Already_Running : exception;

   procedure Lock_File (File_Name : in String);
   -- See if File_Name exists: if it does and it contains
   -- the process id of a running process then throw
   -- Process_Already_Running

   procedure Lock_File
     (File_Name         : in     String;
   Already_Locked    :    out Boolean);
   -- Check if File_Name exists: if it does and it contains
   -- the process id of a running process then set Already_Locked
   -- to False.  Otherwise create/overwrite File_Name with the
   -- process id of the current process.

end Ada_Lib.Pid_File;
