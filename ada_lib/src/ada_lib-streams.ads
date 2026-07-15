--
-- This package provides utility functions that operate on streams.

with Ada.Streams;

package Ada_Lib.Streams is

    function To_Stream (Arg : in String)
      return Ada.Streams.Stream_Element_Array;

end Ada_Lib.Streams;
