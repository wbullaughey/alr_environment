with Ada.Text_IO; use Ada.Text_IO;

package body Ada_Lib.Tags is

   use type Ada.Tags.Tag;

   ---------------------------------------------------------------
   procedure Interface_Ancestors (
      Tag                        : in     Ada.Tags.Tag) is
   ---------------------------------------------------------------

      Tags                       : constant Ada.Tags.Tag_Array := Ada.Tags.Interface_Ancestor_Tags (Tag);

   begin
      Put ("interface ancestors: ");
      for Index in Tags'range loop
         Put (Ada.Tags.Expanded_Name (Tags (Index)));

         if Index < Tags'last then
            Put (" : ");
         end if;
      end loop;
      New_Line;
   end Interface_Ancestors;

   ---------------------------------------------------------------
   procedure Derivation (              -- print darivation of Tag
      Tag                        : in     Ada.Tags.Tag) is
   ---------------------------------------------------------------

      Iterater                   : Ada.Tags.Tag := Tag;

   begin
      loop
         Put (Ada.Tags.Expanded_Name (Iterater));

         Iterater := Ada.Tags.Parent_Tag (Iterater);
         if Iterater = Ada.Tags.No_Tag then
            New_LIne;
            return;
         else
            Put (" : ");
         end if;
      end loop;
   end Derivation;

end Ada_Lib.Tags;
