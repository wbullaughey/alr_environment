with Ada.Text_IO;
with Ada_Lib.Directory;
with Ada_Lib.OS.Run;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
-- with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace; use Ada_Lib.Trace;

-- pragma Elaborate (Ada_Lib.OS);

package body Ada_Lib.OS.Base64 is

   function Run (
      Parameter                  : in     String;
      Source                     : in     String
   ) return String;

   -------------------------------------------------------------------
   function Decode (
      Encoded                     : in     String
   ) return String is
   -------------------------------------------------------------------

   begin
      Log_In (Trace, Quote ("Encoded", Encoded));
      return Run ("-D -i", Encoded);
   end Decode;

   -------------------------------------------------------------------
   function Encode (
      Source                     : in     String
   ) return String is
   -------------------------------------------------------------------

   begin
      Log_In (Trace, Quote ("Source", Source));
      return Run ("-i", Source);
   end Encode;

   -------------------------------------------------------------------
   function Run (
      Parameter                  : in     String;
      Source                     : in     String
   ) return String is
   -------------------------------------------------------------------

      Source_File               : Ada_Lib.OS.File_Descriptor;
      Temporary_File_Name        : Ada_Lib.OS.Temporary_File_Name;

   begin
      Log_In (Trace, "Parameter " & Parameter & Quote (" Source", Source));

      Ada_Lib.OS.Create_Scratch_File (Source_File, Temporary_File_Name);
      Log_Here (Trace, Quote ("Temporary_File_Name", Temporary_File_Name));

      declare
         Source_File            : Ada.Text_IO.File_Type;
         Source_File_Name       : String renames Temporary_File_Name (
                                    Temporary_File_Name'first ..
                                       Temporary_File_Name'last - 1);

      begin
         Ada.Text_IO.Open (Source_File, Ada.Text_IO.Out_File,
            Source_File_Name);
         Ada.Text_IO.Put_Line (Source_File, Source);
         Ada.Text_IO.Close (Source_File);
         Log_Here (Trace, Quote ("source file name", Source_File_Name));

         declare
            Result               : constant String :=
                                    Ada_Lib.OS.Run.Spawn ("/usr/bin/base64",
                                       Parameter & " " & Source_File_Name,
                                       Zero_Ok  => True);
         begin
            if not Trace then
               Ada_Lib.Directory.Delete (Source_File_Name);
            end if;

            Log_Out (Trace, Quote ("Result", Result));
            return Result;
         end;
      end;
   end Run;

-- -------------------------------------------------------------------
-- procedure Callback (
--    Context                    : in out Ada_Lib.Strings.Unlimited.String_Type;
--    Line                       : in     String) is
-- -------------------------------------------------------------------
--
-- begin
--    Log_In (Trace, Quote ("Line", Line));
--    Context.Construct (Line);
--    Log_Out (Trace);
-- end Callback;

end Ada_Lib.OS.Base64;
