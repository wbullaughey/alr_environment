with Ada.Exceptions;
with Ada_Lib.Options;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with Ada.Streams.Stream_IO; -- use Ada.Streams; use Ada.Streams.Stream_IO;

procedure Ada_Lib.Directory.File_Copy (
   Source      : in     String;
   Destination : in     String;
   Overwrite   : in     Boolean := False) is

   Buffer      : Ada.Streams.Stream_Element_Array (1 .. 10000);
   Count       : Ada.Streams.Stream_Element_Offset;
   Debug       : Boolean renames Options.Ada_Lib_Directory.Debug;
   Input       : Ada.Streams.Stream_IO.File_Type;
   Output      : Ada.Streams.Stream_IO.File_Type;

begin
   Log_In (Debug);

   begin
      Ada.Streams.Stream_IO.Open (Input, Ada.Streams.Stream_IO.In_File, Source);

   exception
      when Fault: others =>
         Trace_Exception (Debug, Fault);
         raise Bad_Path with Quote ("Could not open source file", Source) &
            " with IO error " & Ada.Exceptions.Exception_Message (Fault);

   end;

   begin
      if not Overwrite and then
            Exists (Destination) then
         raise Failed with Quote ("Overwriting destination", Destination);
      end if;

      Ada.Streams.Stream_IO.Create (Output, Ada.Streams.Stream_IO.Out_File, Destination);

   exception
      when Fault: others =>
         Trace_Exception (Debug, Fault);
         raise Bad_Path with Quote ("Could not create destination file",
            Destination) & " with IO error " &
            Ada.Exceptions.Exception_Message (Fault);

   end;

   while not Ada.Streams.Stream_IO.End_Of_File (Input) loop
      begin
         Ada.Streams.Stream_IO.Read (Input, Buffer, Count);
      exception
         when Fault: others =>
            Trace_Exception (Debug, Fault);
            raise IO_Failed with Quote ("Could not read from source file",
               Source) & " with IO error " &
               Ada.Exceptions.Exception_Message (Fault);
      end;

      begin
         Ada.Streams.Stream_IO.Write (Output, Buffer (Buffer'first .. Count));
      exception
         when Fault: others =>
            Trace_Exception (Debug, Fault);
            raise IO_Failed with Quote ("Could not write to destination file",
               Destination) & " with IO error " &
               Ada.Exceptions.Exception_Message (Fault);
      end;
   end loop;

   begin
      Ada.Streams.Stream_IO.Close (Input);
      exception
         when Fault: others =>
            Trace_Exception (Debug, Fault);
            raise IO_Failed with Quote ("Could not close source file",
               Source) & " with IO error " &
               Ada.Exceptions.Exception_Message (Fault);
      end;
   begin
      Ada.Streams.Stream_IO.Close (Output);
      exception
         when Fault: others =>
            Trace_Exception (Debug, Fault);
            raise IO_Failed with Quote ("Could not close destination file",
               Destination) & " with IO error " &
               Ada.Exceptions.Exception_Message (Fault);
      end;
   Log_Out (Debug);
end Ada_Lib.Directory.File_Copy;

