with Ada_Lib.Smart_Pointer;

pragma Elaborate_All (Ada_Lib.Smart_Pointer);

package Ada_Lib.Smart_Object_Helper is

   type Object_Type     is new Ada_Lib.Smart_Pointer.Contents_Type with private;

private

   type Object_Type     is new Ada_Lib.Smart_Pointer.Contents_Type with record
      Value          : Integer;
   end record;

end Ada_Lib.Smart_Object_Helper;