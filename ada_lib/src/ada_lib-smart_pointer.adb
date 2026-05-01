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
with Ada.Unchecked_Deallocation;
with Hex_IO;
with Ada_Lib.Trace; use Ada_Lib.Trace;


package body Ada_Lib.Smart_Pointer is

   use type Ada_Lib.Strings.String_Access;

   procedure Free_From_Allocated (
      Contents          : in   Contents_Access);

   function From_Where (
      Contents       : in   Contents_Access
   ) return String;

   function Image (
      Contents          : in   Contents_Access
   ) return String;

   procedure Set_Where_Allocated (
      Contents          : in   Contents_Access;
      From_Where           : in   String);

   package body Pointer is

      procedure Free_Contents is new Ada.Unchecked_Deallocation (
         Object   => Base_Type'class,
         Name  => Base_Access);

      procedure Free_Pointer is new Ada.Unchecked_Deallocation (
         Object   => Pointer_Type'class,
         Name  => Pointer_Access);

      ---------------------------------------------------------------------------
      overriding
      procedure Adjust (
         Object               : in out Pointer_Type) is
      ---------------------------------------------------------------------------

      begin
         if Object.Contents /= Null then
            if Trace_Smart_Pointer then
               Log_Here ("adjust " & Base_Image (Object.Contents) &
                  Base_From_Where (Object.Contents));
            end if;

            Increment (Object.Contents);
         else
            if Trace_Smart_Pointer then
               Log_Here ("adjust null object");
            end if;
         end if;
      end Adjust;

      ---------------------------------------------------------------------------
      function Base_From_Where (
         Contents       : in   Base_Access
      ) return String is
      ---------------------------------------------------------------------------

      begin
         pragma Assert (Contents /= Null);
         return From_Where (Contents_Access (Contents));
      end Base_From_Where;

      ---------------------------------------------------------------------------
      function Base_Image (
         Contents       : in   Base_Access
      ) return String is
      ---------------------------------------------------------------------------

      begin
         return Image (Contents_Access (Contents));
      end Base_Image;

   -- ---------------------------------------------------------------------------
   -- procedure Delete (
   --    Object               : in out Pointer_Type) is
   -- ---------------------------------------------------------------------------
   --
   -- begin
   --    if Trace_Smart_Pointer then
   --       Log_Here ("delete " & Image (Object.Contents));
   --    end if;
   --
   --    Object.Contents.Reference_Count := 0;
   --    Free_Contents (Object.Contents);
   -- end Delete;

      ---------------------------------------------------------------------------
      procedure Check_For_Delete (
         Contents          : in out Base_Access) is
      ---------------------------------------------------------------------------

      begin
         if Count (Contents_Type (Contents.all)) = 0 then
            if Trace_Smart_Pointer then
               Log_Here ("free Base " & Image (Contents_Access (Contents)) &
                  Base_From_Where (Contents));
            end if;

            Free_From_Allocated (Contents_Access (Contents));

            Free_Contents (Contents);
         end if;
      end Check_For_Delete;

      ---------------------------------------------------------------------------
      -- set a pointer to not reference the object it was pointing to
      procedure Dereference (
         Object               : in out Pointer_Type) is
      ---------------------------------------------------------------------------

      begin
         if Object.Contents /= Null then
            if Trace_Smart_Pointer then
               Log_Here ("dereference " & Base_Image (Object.Contents) &
                  Base_From_Where (Object.Contents));
            end if;

            Decrement (Object.Contents);
            Check_For_Delete (Object.Contents);
            Object.Contents := Null;
         else
            if Trace_Smart_Pointer then
               Log_Here ("dereference null pointer");
            end if;
         end if;
      end Dereference;

      ---------------------------------------------------------------------------
      overriding
      procedure Finalize (
         Object               : in out Pointer_Type) is
      ---------------------------------------------------------------------------

      begin
         -- Contents will be null if object nerver allocated
         if Object.Contents /= Null then
            if Trace_Smart_Pointer then
               Log_Here ("finalize " & Base_Image (Object.Contents) &
                  Base_From_Where (Object.Contents));
            end if;
            Decrement (Object.Contents);
            Check_For_Delete (Object.Contents);
         else
            if Trace_Smart_Pointer then
               Log_Here ("finalize null pointer");
            end if;
         end if;
      end Finalize;

      ---------------------------------------------------------------------------
      procedure Free (
         Object               : in out Pointer_Access) is
      ---------------------------------------------------------------------------

      begin
         Free_Pointer (Object);
      end Free;

--      ---------------------------------------------------------------------------
--      function Get (
--          Object                  : in     Pointer_Type
--      ) return Base_Access is
--      ---------------------------------------------------------------------------
--
--      begin
--          if Object.Contents = Null then
--              if Trace_Smart_Pointer then
--                  Log_Here ("get null pointer");
--              end if;
--
--              raise Null_Object;
--          end if;
--
--          if Trace_Smart_Pointer and Trace_Verbose then
--              Log_Here ("get " & Base_Image (Object.Contents) &
--                  Base_From_Where (Object.Contents));
--          end if;
--
--          return Object.Contents;
--      end Get;

      ---------------------------------------------------------------------------
      overriding
      procedure Initialize (
         Object               : in out Pointer_Type) is
      ---------------------------------------------------------------------------

      begin
         if Trace_Smart_Pointer then
            Log_Here ("initialize smart pointer null");
         end if;

         Object.Contents := Null;
      end Initialize;

      ---------------------------------------------------------------------------
      procedure Initialize (
         Object               : in out Pointer_Type;
         Content              : in   Base_Access;
         From_Where           : in   String) is
      ---------------------------------------------------------------------------

      begin
         if Object.Contents = Null then
            if Tracking then
               Set_Where_Allocated (Contents_Access (Content), From_Where);
            end if;

            Object.Contents := Content;
            Initialize (Object.Contents);

            if Trace_Smart_Pointer then
               Log_Here ("Initialize object " & " from " & From_Where & " " &
                  Base_Image (Object.Contents) & " count 1");
            end if;

         else
            raise Already_Initialized;
         end if;
      end Initialize;

      ---------------------------------------------------------------------------
      function Is_Allocated (
         Object               : in   Pointer_Type
      ) return Boolean is
      ---------------------------------------------------------------------------

      begin
         return Object.Contents /= Null;
      end Is_Allocated;

      ---------------------------------------------------------------------------
      function Reference (
         Object               : in   Pointer_Type
      ) return Base_Access is
      ---------------------------------------------------------------------------

      begin
         if Object.Contents = Null then
            if Trace_Smart_Pointer then
               Log_Here ("get null pointer");
            end if;

            raise Null_Object;
         end if;

         if Trace_Smart_Pointer and Trace_Verbose then
            Log_Here ("get " & Base_Image (Object.Contents) &
               Base_From_Where (Object.Contents));
         end if;

         return Object.Contents;
      end Reference;

   end Pointer;

   ---------------------------------------------------------------------------
   function Count (
      Contents          : in   Contents_Type'class
   ) return Natural is
   ---------------------------------------------------------------------------

   begin
      return Contents.Reference_Count;
   end Count;

   ---------------------------------------------------------------------------
   procedure Decrement (
      Contents          : access Contents_Type'class) is
   ---------------------------------------------------------------------------

   begin
      Contents.Reference_Count :=   Contents.Reference_Count - 1;

      if Trace_Smart_Pointer then
         Log_Here ("count after decrement " & Contents.Reference_Count'img &
            " of " & Image (Contents_Access (Contents)) &
            From_Where (Contents_Access (Contents)));
      end if;
   end Decrement;

   ---------------------------------------------------------------------------
   procedure Free_From_Allocated (
      Contents          : in   Contents_Access) is
   ---------------------------------------------------------------------------

   begin
      if Contents.Where_Allocated /= Null then
         Ada_Lib.Strings.Free (Contents.Where_Allocated);
      end if;
   end Free_From_Allocated;

   ---------------------------------------------------------------------------
   function From_Where (
      Contents       : in   Contents_Access
   ) return String is
   ---------------------------------------------------------------------------

   begin
      pragma Assert (Contents /= Null);

      if Contents.Where_Allocated = Null then
         return "";
      else
         return " allocated at " & Contents.Where_Allocated.all;
      end if;
   end From_Where;

   ---------------------------------------------------------------------------
   function Image (
      Contents       : in   Contents_Access
   ) return String is
   ---------------------------------------------------------------------------

   begin
      if Contents = Null then
         return "NULL";
      else
         return Hex_IO.Hex (Contents.all'address);
      end if;
   end Image;

   ---------------------------------------------------------------------------
   procedure Increment (
      Contents          : access Contents_Type'class) is
   ---------------------------------------------------------------------------

   begin
      Contents.Reference_Count :=   Contents.Reference_Count + 1;

      if Trace_Smart_Pointer then
         Log_Here ("count after increment" & Contents.Reference_Count'img &
            " of " & Image (Contents_Access (Contents)) &
            From_Where (Contents_Access (Contents)));
      end if;
   end Increment;

   ---------------------------------------------------------------------------
   procedure Initialize (
      Contents          : access Contents_Type'class) is
   ---------------------------------------------------------------------------

   begin
      Contents.Reference_Count := 1;
   end Initialize;

   ---------------------------------------------------------------------------
   procedure Set_Count (
      Contents          : in out Contents_Type'class;
      Count             : in   Natural) is
   ---------------------------------------------------------------------------

   begin
      Contents.Reference_Count := Count;
   end Set_Count;

   ---------------------------------------------------------------------------
   procedure Set_Where_Allocated (
      Contents          : in   Contents_Access;
      From_Where           : in   String) is
   ---------------------------------------------------------------------------

   begin
      Contents.Where_Allocated := new String'(From_Where);
   end Set_Where_Allocated;

begin
   Tracking := True;
end Ada_Lib.Smart_Pointer;
