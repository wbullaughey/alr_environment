with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with AUnit.Ada_Lib;
with AUnit.Simple_Test_Cases;

package body AUnit.Test_Filters.Ada_lib is

   Debug                         : Boolean renames AUnit.Ada_Lib.Debug;

   -----------------------------------------------------------
   overriding
   function Is_Active (
      Filter                     : in     Ada_Lib_Filter;
      Test      : AUnit.Tests.Test'Class) return Boolean is
   -----------------------------------------------------------

      Test_Name            : constant String := AUnit.Simple_Test_Cases.Name (
                              AUnit.Simple_Test_Cases.Test_Case'Class (Test)).all;
   begin
      Log_In (Debug);
      if Filter.Name /= Null then
         declare
            Result         : constant Boolean := Test_Name = Filter.Name.all;

        begin
            Log_Here (Debug, " Test_Name " & Quote (Test_Name) &
               " filter " & Quote (Filter.Name.all) &
               " result " & Result'img);

            if Result then
               return Log_Out (True, Debug);
            end if;
         end;
      end if;

      return Log_Out (Name_Filter (Filter).Is_Active (Test), Debug);
   end Is_Active;

end AUnit.Test_Filters.Ada_lib;

