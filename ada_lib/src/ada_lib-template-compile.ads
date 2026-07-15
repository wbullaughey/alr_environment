with Ada_Lib.Template.Parameters;

package Ada_Lib.Template.Compile is

   Syntax_Error                  : exception;

   type Template_Type            is tagged private;

   function Compile (
      Template                   : in out Template_Type;
      File_Contents              : in     String;
      Parameters                 : in     Ada_Lib.Template.Parameters.Parameter_Array :=
                                             Ada_Lib.Template.Parameters.No_Parameters
   ) return String;

   -- preload templates
   function Load (
      Path                       : in   String
   ) return String;

private

   type Template_Type is tagged record
      List                       : Ada_Lib.Template.Parameters.List_Access := Null;
   end record;

end Ada_Lib.Template.Compile;
