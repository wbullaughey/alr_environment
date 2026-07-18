package AUnit.Test_Filters.Ada_lib is

   type Ada_Lib_Filter is new Name_Filter with null record;
   type Ada_Lib_Filter_Access is access constant Ada_Lib_Filter'Class;

   overriding
   function Is_Active (
      Filter                     : in     Ada_Lib_Filter;
      Test      : AUnit.Tests.Test'Class) return Boolean ;

end AUnit.Test_Filters.Ada_lib;


