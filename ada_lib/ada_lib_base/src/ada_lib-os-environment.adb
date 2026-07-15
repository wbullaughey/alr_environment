with Ada.Command_Line.Environment;

package body Ada_Lib.OS.Environment is

   ---------------------------------------------------------------
   function Get (
      Name                    : in     String
   ) return String is
   ---------------------------------------------------------------

      Compare                 : constant String := Name & '=';

   begin
      for index in Positive range 1 .. Ada.Command_Line.Environment.Environment_Count loop
         declare
            Value             : constant String :=
                                 Ada.Command_Line.Environment.Environment_Value (Index);

         begin
            if    Value'length >= Compare'length and then
                  Value (1 .. Compare'length) = Compare then
               return Value (Compare'length + 1 .. Value'last);
            end if;
         end;
      end loop;

      return "";
   end Get;
   ---------------------------------------------------------------

end Ada_Lib.OS.Environment;

