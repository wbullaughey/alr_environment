with Ada_Lib.Smart_Pointer;
with  Ada_Lib.Smart_Object_Helper;

package Ada_Lib.Smart_Integer is

-- package Object is
--    type Object_Type     is new Ada_Lib.Smart_Pointer.Contents_Type with private;
--
-- private
--    type Object_Type     is new Ada_Lib.Smart_Pointer.Contents_Type with record
--       Value          : Integer;
--    end record;
--
-- end object;

   type Object_Access   is access all Ada_Lib.Smart_Object_Helper.Object_Type'class;

   package Pointer is new Ada_Lib.Smart_Pointer.Pointer (
      Base_Type      => Ada_Lib.Smart_Object_Helper.Object_Type,
      Base_Access    => Object_Access);


end Ada_Lib.Smart_Integer;


