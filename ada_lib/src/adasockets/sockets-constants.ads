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


--  This package has been generated automatically on:
--  Linux wayne-dpt4 2.4.18-3smp #1 SMP Thu Apr 18 07:27:31 EDT 2002
--  i686 unknown
--  Generation date: Sun Jan 19 14:22:18 EST 2003
--  Any change you make here is likely to be lost !
package Sockets.Constants is
-- TCP_NODELAY : constant := 1;
AF_INET : constant := 2;
-- AF_UNIX : constant := 1;
Sock_Stream          : constant := 2;
Sock_Dgram           : constant := 1;
EINTR : constant := 4;
-- EAGAIN : constant := 11;
-- EWOULDBLOCK : constant := 11;
-- EINPROGRESS : constant := 150;
-- EALREADY : constant := 149;
-- EISCONN : constant := 133;
ECONNREFUSED : constant := 146;
-- FNDELAY : constant := 16#0080#;
-- FASYNC : constant := 16#1000#;
-- F_GETFL : constant := 3;
-- F_SETFL : constant := 4;
-- F_SETOWN : constant := 24;
SO_RCVBUF : constant := 16#1002#;
SO_REUSEADDR : constant := 16#0004#;
SO_LINGER : constant := 16#0080#;
So_Reuseport         : constant := -1;
SOL_SOCKET : constant := 16#ffff#;
-- SIGTERM : constant := 15;
-- SIGKILL : constant := 9;
-- O_RDONLY : constant := 16#0000#;
-- O_WRONLY : constant := 16#0001#;
-- O_RDWR : constant := 16#0002#;
HOST_NOT_FOUND : constant := 1;
TRY_AGAIN : constant := 2;
NO_RECOVERY : constant := 3;
NO_DATA : constant := 4;
NO_ADDRESS : constant := 4;
-- POLLIN : constant := 16#001#;
-- POLLPRI : constant := 16#002#;
-- POLLOUT : constant := 16#004#;
-- POLLERR : constant := 16#008#;
-- POLLHUP : constant := 16#010#;
-- POLLNVAL : constant := 16#020#;
--   I_Setsig             : constant := -1;
-- S_RDNORM : constant := 16#0040#;
-- S_WRNORM : constant := 16#0004#;
Ipproto_Ip           : constant := 0;
IP_ADD_MEMBERSHIP : constant := 35;
IP_MULTICAST_LOOP : constant := 34;
IP_MULTICAST_TTL : constant := 33;
IP_DROP_MEMBERSHIP : constant := 36;
-- O_NONBLOCK : constant := 16#0080#;
--   Msg_Peek             : constant := -1;
FIONBIO : constant := 16#667e#;
-- FIONREAD : constant := 16#467f#;
SO_SNDBUF : constant := 16#1001#;
-- AF_INET6 : constant := 10;
--   Ai_Addrconfig        : constant := -1;
--   Ai_All               : constant := -1;
-- AI_CANONNAME : constant := 16#0002#;
--   Ai_Default           : constant := -1;
--   Ai_Mask              : constant := -1;
-- AI_NUMERICHOST : constant := 16#0004#;
-- AI_PASSIVE : constant := 16#0001#;
--   Ai_V4mapped          : constant := -1;
--   Ai_V4mapped_Cfg      : constant := -1;
-- NI_DGRAM : constant := 16;
-- NI_MAXHOST : constant := 1025;
-- NI_MAXSERV : constant := 32;
-- NI_NAMEREQD : constant := 8;
-- NI_NOFQDN : constant := 4;
-- NI_NUMERICHOST : constant := 1;
-- NI_NUMERICSERV : constant := 2;
--   Ni_Withscopeid       : constant := -1;
--   Ipproto_Ipv6         : constant := -1;
-- IPV6_UNICAST_HOPS : constant := 16;
-- IPV6_MULTICAST_IF : constant := 17;
-- IPV6_MULTICAST_HOPS : constant := 18;
-- IPV6_MULTICAST_LOOP : constant := 19;
-- IPV6_JOIN_GROUP : constant := 20;
-- IPV6_LEAVE_GROUP : constant := 21;

MSG_NOSIGNAL : constant := 16#4000#;
end Sockets.Constants;
