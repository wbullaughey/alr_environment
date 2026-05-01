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


package body Ada_Lib.Pid_File is

   -- TODO: We need to come up with a way of porting this to win32

   -----------------
   -- File_Exists --
   -----------------

   ---------------
   -- Lock_File --
   ---------------

   procedure Lock_File
     (File_Name		: in String)
   is
   begin
		null;
		pragma Assert (False);
   end Lock_File;


   ---------------
   -- Lock_File --
   ---------------

   procedure Lock_File
     (File_Name		: in     String;
      Already_Locked	:    out Boolean)
   is
   begin
		null;
		pragma Assert (False);
   end Lock_File;

end Ada_Lib.Pid_File;
