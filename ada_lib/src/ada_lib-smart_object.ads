with Ada.Finalization;

package Ada_Lib.Smart_Object is

   Already_Allocated       : exception;
   Null_Object             : exception;

   type Contents_Type         is abstract tagged limited private;

   type Contents_Access    is access all Contents_Type'class;

   -- generic package use to create a specific pointer type to
   -- a base type derived from Contents_Type
   -- the pointer type can point to any type derived from that
   -- base type
   generic

      type Base_Type (<>)     is abstract new Contents_Type with private;

   package Pointer is

      type Base_Access     is access all Base_Type'class;

      type Pointer_Type    is new Ada.Finalization.Controlled with private;

      procedure Allocate (
         Object            : in out Pointer_Type'class;
         Content           : in   Base_Access);

      procedure Delete (
         Object            : in out Pointer_Type);

      -- set a pointer to not reference the object it was pointing to
      procedure Dereference (
         Object            : in out Pointer_Type);

      overriding
      procedure Finalize (
         Object            : in out Pointer_Type);

      function Get (
         Object            : in   Pointer_Type'class
      ) return Base_Access;

      function Is_Allocated (
         Object            : in   Pointer_Type'class
      ) return Boolean;

      Null_Pointer         : constant Pointer_Type;

   private

      type Pointer_Access     is access Pointer_Type'class;

      overriding
      procedure Adjust (
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

   type Contents_Type         is abstract tagged limited record
      Reference_Count         : Natural := 0;
   end record;

   function Count (
      Contents          : in   Contents_Type
   ) return Natural;

   procedure Decrement (
      Contents          : in out Contents_Access);

   procedure Increment (
      Contents          : in   Contents_Access);

   procedure Set_Count (
      Contents          : in out Contents_Type;
      Count             : in   Natural);

end Ada_Lib.Smart_Object;
