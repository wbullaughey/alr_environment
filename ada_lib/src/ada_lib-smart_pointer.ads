with Ada.Finalization;
with Ada_Lib.Strings;

package Ada_Lib.Smart_Pointer is

   Already_Initialized        : exception;
   Null_Object             : exception;

   type Contents_Type         is abstract new Ada.Finalization.Limited_Controlled with private;

   type Contents_Access    is access all Contents_Type'class;

   -- generic package use to create a specific pointer type to
   -- a base type derived from Contents_Type
   -- the pointer type can point to any type derived from that
   -- base type
   generic

      type Base_Type (<>)     is abstract new Contents_Type with private;

      type Base_Access     is access Base_Type'class;

   package Pointer is

      type Pointer_Type    is new Ada.Finalization.Controlled with private;

      type Pointer_Access     is access Pointer_Type'class;

   -- procedure Delete (
   --    Object            : in out Pointer_Type);

      -- set a pointer to not reference the object it was pointing to
      procedure Dereference (
         Object            : in out Pointer_Type);

      function Reference (
         Object            : in   Pointer_Type
      ) return Base_Access;

      procedure Initialize (
         Object            : in out Pointer_Type;
         Content           : in   Base_Access;
         From_Where        : in   String);

      function Is_Allocated (
         Object            : in   Pointer_Type
      ) return Boolean;

      Null_Pointer         : constant Pointer_Type;

   private

      overriding
      procedure Adjust (
         Object            : in out Pointer_Type);

      function Base_From_Where (
         Contents       : in   Base_Access
      ) return String;
      pragma Inline (Base_From_Where);

      function Base_Image (
         Contents       : in   Base_Access
      ) return String;
      pragma Inline (Base_Image);

      overriding
      procedure Finalize (
         Object            : in out Pointer_Type);

      procedure Free (
         Object            : in out Pointer_Access);

      overriding
      procedure Initialize (
         Object            : in out Pointer_Type);

      type Pointer_Type    is new Ada.Finalization.Controlled with record
         Contents       : Base_Access := Null;
      end record;

      Dummy_Pointer        : Pointer_Type;

      Null_Pointer         : constant Pointer_Type := Dummy_Pointer;

   end Pointer;

private

   type Contents_Type         is abstract new Ada.Finalization.Limited_Controlled with record
      Reference_Count         : Natural := 0;
      Where_Allocated         : Ada_Lib.Strings.String_Access := Null;
   end record;

   function Count (
      Contents          : in   Contents_Type'class
   ) return Natural;

   procedure Decrement (
      Contents          : access Contents_Type'class);

   procedure Increment (
      Contents          : access Contents_Type'class);

   procedure Initialize (
      Contents          : access Contents_Type'class);

   procedure Set_Count (
      Contents          : in out Contents_Type'class;
      Count             : in   Natural);

   Tracking             : Boolean := False;
   Trace_Smart_Pointer        : Boolean := False;
   Trace_Verbose           : Boolean := False;
end Ada_Lib.Smart_Pointer;
