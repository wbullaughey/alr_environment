-- with Ada.Containers.Vectors;

package Ada_Lib.Template.Generic_Parameter is

   generic

      type Target_Type is (<>);

      with function Image (
         Target                     : in     Target_Type
      ) return String;

      Null_Target                   : Target_Type;

   package Parameter_Package is

      type Generic_Parameter_Type   is new Ada_Lib.Template.Named_Parameter_Type with record
         Target                     : Target_Type := Null_Target;
      end record;
      type Generic_Parameter_Access is access Generic_Parameter_Type;

      function Create (
         Name                       : in   String;
         Target                     : in   Target_Type
      ) return Generic_Parameter_Type;

      procedure Set (
         Parameter                  : in out Generic_Parameter_Type;
         Value                      : in   Target_Type);

      overriding
      function Value (
         Parameter                  : in   Generic_Parameter_Type;
         Index                      : in   Ada_Lib.Template.Parameter_Index_Type;
         Done                       : in   Boolean_Access
      ) return String;

   end Parameter_Package;

end Ada_Lib.Template.Generic_Parameter;
