with Ada.Exceptions;
with Ada_Lib.Options;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with Ada.Streams.Stream_IO; -- use Ada.Streams; use Ada.Streams.Stream_IO;

procedure Ada_Lib.Directory.File_Compare (
   Path_1, Path_2                : in     String) is

   use type Ada.Streams.Stream_Element_Array;
   use type Ada.Streams.Stream_Element_Offset;
   use type Ada.Streams.Stream_Element;

   package IO is

      procedure Open (
         Description             : in     String;
         Path                    : in     String;
         File                    : in out Ada.Streams.Stream_IO.File_Type);

      procedure Read (
         Description             : in     String;
         File                    : in     Ada.Streams.Stream_IO.File_Type;
         Buffer                  :    out Ada.Streams.Stream_Element_Array;
         Count                   :    out Ada.Streams.Stream_Element_Offset);

   end IO;

   Debug : Boolean renames Options.Ada_Lib_Directory.Debug;

   package body IO is

      ---------------------------------------------------------------
      procedure Open (
         Description             : in     String;
         Path                    : in     String;
         File                    : in out Ada.Streams.Stream_IO.File_Type) is
      ---------------------------------------------------------------

      begin
         Ada.Streams.Stream_IO.Open (File, Ada.Streams.Stream_IO.In_File, Path);

      exception
         when Fault: others =>
            Trace_Exception (Debug, Fault);
            raise Bad_Path with Quote ("Could not open " & Description, Path) &
               " with IO error " & Ada.Exceptions.Exception_Message (Fault);

      end Open;

      ---------------------------------------------------------------
      procedure Read (
         Description             : in     String;
         File                    : in     Ada.Streams.Stream_IO.File_Type;
         Buffer                  :    out Ada.Streams.Stream_Element_Array;
         Count                   :    out Ada.Streams.Stream_Element_Offset) is
      ---------------------------------------------------------------

      begin
         Ada.Streams.Stream_IO.Read (File, Buffer, Count);
      exception
         when Fault: others =>
            Trace_Exception (Debug, Fault);
            raise IO_Failed with "Could not read from" & Description &
               " with IO error " &
               Ada.Exceptions.Exception_Message (Fault);
      end Read;

   end IO;

   Buffer_1                      : Ada.Streams.Stream_Element_Array (1 .. 10000);
   Buffer_2                      : Ada.Streams.Stream_Element_Array (1 .. 10000);
   Count_1                       : Ada.Streams.Stream_Element_Offset;
   Count_2                       : Ada.Streams.Stream_Element_Offset;
   File_1                        : Ada.Streams.Stream_IO.File_Type;
   File_2                        : Ada.Streams.Stream_IO.File_Type;

begin
   Log_In (Debug, Quote ("compare path 1", Path_1) & Quote (" path 2", Path_2));

   IO.Open ("file 1", Path_1, File_1);
   IO.Open ("file 2", Path_2, File_2);

   Loop
      IO.Read ("file 1", File_1, Buffer_1, Count_1);
      IO.Read ("file 2", File_2, Buffer_2, Count_2);

      Log_Here (Debug, "count 1" & Count_1'img & " count 2" & Count_2'img);
      if Count_1 /= Count_2 then
         raise Failed with "Files are different length. " &
            "File 1 length" & Count_1'img & ". " &
            "File 2 length" & Count_2'img & ".";
      end if;

      if Count_1 = 0 then
         exit;
      end if;

      if Buffer_1 /= Buffer_2 then
         for Index in Buffer_1'first .. Count_1  loop
            if Buffer_1 (Index) /= Buffer_2 (Index) then
               raise Failed with "Files differ at offset" & Index'img;
            end if;
         end loop;
      end if;
   end loop;

   Ada.Streams.Stream_IO.Close (File_1);
   Ada.Streams.Stream_IO.Close (File_2);
   Log_Out (Debug);

exception
   when Fault: others =>
      Trace_Exception (Debug, Fault);
      raise;


end Ada_Lib.Directory.File_Compare;

