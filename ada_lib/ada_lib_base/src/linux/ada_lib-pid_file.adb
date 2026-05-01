--$Header$

-----------------------------------------------------------------------------
--  Copyright (c) 2003 - 2004  All rights reserved
-- 
--  This file is a product of Communication Automation & Control, Inc. (CAC)
--  and is provided for unrestricted use WITH CAC PRODUCTS ONLY provided
--  this legend is included on all media and as a part of the software
--  program in whole or part.
-- 
--  Users may copy or modify this file without charge, but are not authorized
--  to license or distribute it to anyone else except as part of a product or
--  program developed by the user incorporating CAC products.
-- 
--  THIS FILE IS PROVIDED AS IS WITH NO WARRANTIES OF ANY KIND INCLUDING THE
--  WARRANTIES OF DESIGN, MERCHANTIBILITY AND FITNESS FOR A PARTICULAR
--  PURPOSE, OR ARISING FROM A COURSE OF DEALING, USAGE OR TRADE PRACTICE.
-- 
--  In no event will CAC be liable for any lost revenue or profits, or other
--  special, indirect and consequential damages, which may arise from the use
--  of this software.
-- 
--  Communication Automation & Control, Inc.
--  1180 McDermott Drive, West Chester, PA (USA) 19380
--  (877) 284-4804 (Toll Free)
--  (610) 692-9526 (Outside the US)
-----------------------------------------------------------------------------


with Ada.Text_IO;
with Ada.Integer_Text_IO;
with Interfaces;
with Interfaces.C;
with Gnat.OS_Lib;

package body Ada_Lib.Pid_File is

   -- TODO: We need to come up with a way of porting this to win32

   -- Note: The following may not work on UNIX systems.  POSIX 
   -- has getpid() return pid_t, which is implementation defined.a
   
   type Pid_Type is new Interfaces.Unsigned_32;

   function Get_Pid return Pid_Type;
   pragma Import (C, Get_Pid, "getpid");

   function Kill 
     (Pid		: in Pid_Type;
      Sig		: in Interfaces.C.int) 
     return Interfaces.C.int;
   pragma Import (C, Kill, "kill");

   -----------------
   -- File_Exists --
   -----------------

   function File_Exists (File_Name : in String) return Boolean
   is
   begin
      return Gnat.OS_Lib.Is_Regular_File (File_name);
   end File_Exists;

   --------------------
   -- Process_Exists --
   --------------------

   function Process_Exists (Pid	: in Pid_Type) return Boolean
   is 
      use type Interfaces.C.int;
      Error		: Interfaces.C.int;
   begin
      Error := Kill (Pid, 0);
      if Error = 0 then
	 -- No error, process exists
	 return True;
      else
	 -- Error, process doesn't exist
	 return False;
      end if;
   end Process_Exists;

   -----------------------
   -- Get_Pid_From_File --
   -----------------------

   function Get_Pid_From_File (File_Name : in String) return Pid_Type
   is
      use Ada.Text_IO;
      use Ada.Integer_Text_IO;
      File		: File_Type;
      Integer_Pid	: Integer;
   begin
      Open (File, In_File, File_Name);
      Get (File, Integer_Pid);
      Close (File);
      return Pid_Type (Integer_Pid);
   end Get_Pid_From_File;


   -----------------------
   -- Write_Pid_To_File --
   -----------------------

   procedure Write_Pid_To_File 
     (File_Name		: in String;
      Pid		: in Pid_Type) 
   is
      use Ada.Text_IO;
      File		: File_Type;
   begin
      Create (File, Out_File, File_Name);
      Put_Line (File, Pid'Img);
      Close (File);
   end Write_Pid_To_File;


   ---------------
   -- Lock_File --
   ---------------

   procedure Lock_File 
     (File_Name		: in String)
   is
      Locked		: Boolean;
   begin
      Lock_File (File_Name, Locked);
      if Locked then
	 raise Process_Already_Running;
      end if;
   end Lock_File;


   ---------------
   -- Lock_File --
   ---------------

   procedure Lock_File 
     (File_Name		: in     String;
      Already_Locked	:    out Boolean)
   is 
      use Ada.Text_IO;
      File_Path		: constant String := "/tmp/" & File_Name;
      Current_Pid	: constant Pid_Type := Get_Pid;
      Other_Pid		: Pid_Type;
   begin
      -- Check if File_Name exists: if it does and it contains
      -- the process id of a running process then set Already_Locked
      -- to False.  Otherwise create/overwrite File_Name with the
      -- process id of the current process.

      if File_Exists (File_Path) then
	 Other_Pid := Get_Pid_From_File (File_Path);
	 if Process_Exists (Other_Pid) then
	    Already_Locked := True;
	 else
	    Write_Pid_To_File (File_Path, Current_Pid);
	    Already_Locked := False;
	 end if;
      else
	 -- File doesn't exist, write out current PID
	 Write_Pid_To_File (File_Path, Current_Pid);
	 Already_Locked := False;
      end if;

   exception

      when others =>
	 Put_Line ("Ada_Lib.Pid_File.Lock_File: Propagating unexpected exception");
	 raise;

   end Lock_File;

end Ada_Lib.Pid_File;
