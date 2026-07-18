with Ada.Text_IO; use Ada.Text_IO;
with Ada.Unchecked_Deallocation;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with Hex_IO;

package body Ada_Lib.Smart_Object is

   procedure Free_Contents is new Ada.Unchecked_Deallocation (
      Object   => Contents_Type'class,
      Name  => Contents_Access);

      function Image (
         Contents       : in   Contents_Access
      ) return String;

   Trace                : constant Boolean := False;

   ---------------------------------------------------------------------------
   function Count (
      Contents          : in   Contents_Type
   ) return Natural is
   ---------------------------------------------------------------------------

   begin
      return Contents.Reference_Count;
   end Count;

   ---------------------------------------------------------------------------
   procedure Decrement (
      Contents          : in out Contents_Access) is
   ---------------------------------------------------------------------------

   begin
      Contents.Reference_Count :=   Contents.Reference_Count - 1;

      if Trace then
         Put_Line ("count after decrement" & Contents.Reference_Count'img &
            " of " & Image (Contents));
      end if;

      if Count (Contents.all) = 0 then
         if Trace then
            Put_Line ("free contents");
         end if;

         Free_Contents (Contents);
      end if;
   end Decrement;

   ---------------------------------------------------------------------------
   function Image (
      Contents          : in   Contents_Access
   ) return String is
   ---------------------------------------------------------------------------

   begin
      if Contents = Null then
         return "null contents";
      else
         return Hex_IO.Hex (Contents.all'address);
      end if;
   end Image;

   ---------------------------------------------------------------------------
   procedure Increment (
      Contents          : in   Contents_Access) is
   ---------------------------------------------------------------------------

   begin
      Contents.Reference_Count :=   Contents.Reference_Count + 1;

      if Trace then
         Put_Line ("count after increment" & Contents.Reference_Count'img &
            " of " & Image (Contents));
      end if;
   end Increment;

   ---------------------------------------------------------------------------
   procedure Set_Count (
      Contents          : in out Contents_Type;
      Count             : in   Natural) is
   ---------------------------------------------------------------------------

   begin
      Contents.Reference_Count := Count;
   end Set_Count;

   ---------------------------------------------------------------------------
   package body Pointer is

      procedure Free_Pointer is new Ada.Unchecked_Deallocation (
         Object   => Pointer_Type'class,
         Name  => Pointer_Access);

      ---------------------------------------------------------------------------
      overriding
      procedure Adjust (
         Object            : in out Pointer_Type) is
      ---------------------------------------------------------------------------

      begin
         if Object.Contents /= Null then
            if Trace then
               Put_Line ("adjust " & Image (Contents_Access (Object.Contents)));
            end if;

            Increment (Contents_Access (Object.Contents));
         else
            if Trace then
               Put_Line ("adjust null object");
            end if;
         end if;
      end Adjust;

      ---------------------------------------------------------------------------
      procedure Allocate (
         Object            : in out Pointer_Type'class;
         Content           : in   Base_Access) is
      ---------------------------------------------------------------------------

      begin
         if Object.Contents = Null then
            Object.Contents := Content;
            Set_Count (Contents_Access (Object.Contents).all, 1);

            if Trace then
               Put_Line ("allocate object " & Image (Contents_Access (Object.Contents)) & " count 1");
            end if;

         else
            raise Already_Allocated;
         end if;
      end Allocate;

      ---------------------------------------------------------------------------
      procedure Delete (
         Object            : in out Pointer_Type) is
      ---------------------------------------------------------------------------

      begin
         if Trace then
            Put_Line ("delete " & Image (Contents_Access (Object.Contents)));
         end if;

         if Object.Contents /= Null then
            Set_Count (Contents_Access (Object.Contents).all, 0);

            Free_Contents (Contents_Access (Object.Contents));
         end if;
      end Delete;

      ---------------------------------------------------------------------------
      -- set a pointer to not reference the object it was pointing to
      procedure Dereference (
         Object            : in out Pointer_Type) is
      ---------------------------------------------------------------------------

      begin
         if Trace then
            Put_Line ("dereference " & Image (Contents_Access (Object.Contents)));
         end if;

         if Object.Contents /= Null then
            Decrement (Contents_Access (Object.Contents));
            Object.Contents := Null;
         end if;
      end Dereference;

      ---------------------------------------------------------------------------
      overriding
      procedure Finalize (
         Object            : in out Pointer_Type) is
      ---------------------------------------------------------------------------

      begin
         Log (Trace, Here, Who & " finalize " & Image (Contents_Access (Object.Contents)));
         -- Contents will be null if object nerver allocated
         if Object.Contents /= Null then
            Decrement (Contents_Access (Object.Contents));
         end if;
         Log (Trace, Here, Who & " exit");
      end Finalize;

      ---------------------------------------------------------------------------
      procedure Free (
         Object            : in out Pointer_Access) is
      ---------------------------------------------------------------------------

      begin
         Free_Pointer (Object);
      end Free;

      ---------------------------------------------------------------------------
      function Get (
         Object            : in   Pointer_Type'class
      ) return Base_Access is
      ---------------------------------------------------------------------------

      begin
         if Trace then
            Put_Line ("get " & Image (Contents_Access (Object.Contents)));
         end if;

         if Object.Contents = Null then
            raise Null_Object;
         end if;

         return Object.Contents;
      end Get;

      ---------------------------------------------------------------------------
      overriding
      procedure Initialize (
         Object            : in out Pointer_Type) is
      ---------------------------------------------------------------------------

      begin
         if Trace then
            Put_Line ("initialize smart pointer null");
         end if;

         Object.Contents := Null;
      end Initialize;

      ---------------------------------------------------------------------------
      function Is_Allocated (
         Object            : in   Pointer_Type'class
      ) return Boolean is
      ---------------------------------------------------------------------------

      begin
         return Object.Contents /= Null;
      end Is_Allocated;

   end Pointer;

end Ada_Lib.Smart_Object;
