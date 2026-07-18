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
with Sockets;

package Ada_Lib_Sockets is

	Connection_Closed			: exception;

	subtype Port_Type			is Positive;
	subtype Socket_Type			is Sockets.Socket_FD;

	procedure Accept_Socket (
		Server					: in	 Socket_Type;
		Client					:	 out Socket_Type
	) renames Sockets.Accept_Socket;

	procedure Bind (
		Handle					: in	 Socket_Type;
		Port					: in	 Port_Type);

	function Get_Line (
		Socket					: in	 Socket_Type'class;
		Max_Length				: in	 Positive := 2048
	) return String renames Sockets.Get_Line;

	procedure Listen (
		Handle					: in	 Socket_Type;
    	Length					: in	 Positive := 5)
	renames Sockets.Listen;

	procedure Put_Line (
		Socket					: in	 Socket_Type'class;
		Line					: in	 String
	) renames Sockets.Put_Line;

	procedure Shutdown (
		Handle					: in out Socket_Type;
    	How 					: in	 Sockets.Shutdown_Type := 
    										Sockets.Both)
	renames Sockets.Shutdown;

	procedure Socket (
		Handle					:	 out Sockets.Socket_FD;
    	Family					: in	 Sockets.Socket_Domain := Sockets.PF_INET;
    	Mode					: in	 Sockets.Socket_Type := Sockets.SOCK_STREAM)
	renames Sockets.Socket;

	procedure Make;

end Ada_Lib_Sockets;
