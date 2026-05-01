-- with Ada.Containers.Vectors;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
-- with Ada_Lib.Trace; use Ada_Lib.Trace;
-- with Ada_Lib.Template;

package body Ada_Lib.Template.Generic_Parameter is

-- use type Unlimited_String_Type;

   package body Parameter_Package is

      --------------------------------------------------------------------------
      function Create (
         Name                       : in   String;
         Target                     : in   Target_Type
      ) return Generic_Parameter_Type is
      --------------------------------------------------------------------------

      begin
         return Generic_Parameter_Type'(
            Name     => Ada_Lib.Strings.Unlimited.Coerce (Name),
            Target   => Target);
      end Create;

      --------------------------------------------------------------------------
      procedure Set (
         Parameter               : in out Generic_Parameter_Type;
         Value                   : in   Target_Type) is
      --------------------------------------------------------------------------

      begin
         Parameter.Target := Value;
      end Set;

      --------------------------------------------------------------------------
      overriding
      function Value (
         Parameter                  : in   Generic_Parameter_Type;
         Index                      : in   Ada_Lib.Template.Parameter_Index_Type;
         Done                       : in   Boolean_Access
      ) return String is
      --------------------------------------------------------------------------

      begin
         return Image (Parameter.Target);
      end Value;

   end Parameter_Package;

end Ada_Lib.Template.Generic_Parameter;
