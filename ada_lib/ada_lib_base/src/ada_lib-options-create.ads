with Ada_Lib.Trace; -- use Ada_Lib.Trace;

package Ada_Lib.Options.Create is

   function Create_One (       -- create a single option
     Option                     : in     Character;
     Modifier                   : in     Character;
     From                       : in     String := Ada_Lib.Trace.Here
   ) return Flag_List_Type;

   function Create_Multiple (     -- create multiple options from a string
     Source                     : in     String;
     Modifier                   : in     Character;
     From                       : in     String := Ada_Lib.Trace.Here
   ) return Flag_List_Type;

end Ada_Lib.Options.Create;
