with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
--with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;

package body Ada_Lib.Strings.Maps is

   package body Mapper is

--    use type Ada_Lib.Strings.Unlimited.String_Type;

      ----------------------------------------------------------------
      function Map_Name (
         Name     : in     String
      ) return Kind_Type is
      ----------------------------------------------------------------

      begin
         for Index in Names'range loop
            if Name = Names (Index).Coerce then
               return Kinds (Index);
            end if;
         end loop;

         raise Failed with Quote ("name", Name) & " not found";
      end Map_Name;

      ----------------------------------------------------------------
      function Map_Name (
         Name     : in     Ada_Lib.Strings.Unlimited.String_Type
      ) return Kind_Type is
      ----------------------------------------------------------------

      begin
         return Map_Name (Name.Coerce);
      end Map_Name;

      ----------------------------------------------------------------
      function Map_Kind (
         Kind     : in     Kind_Type
      ) return String is
      ----------------------------------------------------------------

      begin
         return Map_Kind (Kind).Coerce;
      end Map_Kind;

      ----------------------------------------------------------------
      function Map_Kind (
         Kind     : in     Kind_Type
      ) return Ada_Lib.Strings.Unlimited.String_Type is
      ----------------------------------------------------------------

      begin
         for Index in Kinds'range loop
            if Kind = Kinds (Index) then
               return Names (Index);
            end if;
         end loop;

         raise Failed with "kind " & Kind'img & " not found";
      end Map_Kind;

   end Mapper;

end Ada_Lib.Strings.Maps;
