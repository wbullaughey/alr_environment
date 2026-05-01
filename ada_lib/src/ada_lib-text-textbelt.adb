-- with Ada.Characters.Latin_1;
with Ada.Text_IO;
-- with Ada_Lib.Directory;
with Ada_Lib.OS;
with Ada_Lib.OS.Run;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Strings;
with Ada_Lib.Trace; use Ada_Lib.Trace;

-- pragma Elaborate (Ada_Lib.OS);

package body Ada_Lib.Text.Textbelt is

   use type Ada_Lib.OS.OS_Exit_Code_Type;

   Key                           : constant String :=
                                    "f425d0d5b9762c8802dd02f523dad124e5fe2643ZjLZndTNtFJTyBpfgINYdoHlE";

   ----------------------------------------------------------------------------
   procedure Parse (
      Line                       : in     String;
      Success                    : in out Boolean;
      Quota                      : in out Natural) is
   ----------------------------------------------------------------------------

      Quota_Index                : constant Natural :=
                                    Ada_Lib.Strings.Index (Line, """quotaRemaining""");
      Success_Index              : constant Natural :=
                                    Ada_Lib.Strings.Index (Line, """success"":");
      True_Index                 : constant Natural :=
                                    Ada_Lib.Strings.Index (Line, "true");
   begin
      Log_In (Debug, Quote ("line", Line) & " quota index" & Quota_Index'img &
                                    " success index" & Success_Index'img &
                                    " true index" & True_Index'img &
                                    " quota index" & Quota_Index'img);

      if Success_Index > 0 and then True_Index > 0 then
         Success := True;
      end if;

      if Quota_Index > 0 then
         declare
            End_Quota_Index      : Natural :=
                                    Ada_Lib.Strings.Index (Line (Quota_Index .. Line'last), "}");
         begin
            Log_Here (Debug, " End_Quota_Index " & End_Quota_Index'img);

            if End_Quota_Index = 0 then
               End_Quota_Index := Line'last - 1;
            end if;

            declare
               Value                : constant String :=
                                       Line (Quota_Index + 17 .. End_Quota_Index - 1);
            begin
               Log_Here (Debug, Quote ("quota", Value));
               if Value'length > 0 then
                  Quota := Natural'value (Value);
               end if;
            end;
         end;
      end if;

      Log_Out (Debug, "success " & Success'img);

   exception
      when Fault: CONSTRAINT_ERROR =>
         Trace_Message_Exception (Fault, Quote ("could not parse ", Line));
         raise Failed with Quote ("parse of line", Line) & " failed";

   end Parse;

   ----------------------------------------------------------------------------
   procedure Send (
      Phone_Number               : in     String;
      Contents                   : in     String;
      Verbose                    : in     Boolean := False) is
   ----------------------------------------------------------------------------

      Parameter                  : constant String := (if Verbose then
                                          "-v "
                                       else
                                          "") &
                                    "https://textbelt.com/text " &
                                    "--data-urlencode phone='" & Phone_Number &
                                    "' --data-urlencode message='" & Contents &
                                    "' -d key=" & Key;
      Response_File              : Ada_Lib.OS.File_Descriptor;
      Response_File_Name         : Ada_Lib.OS.Temporary_File_Name;

   begin
      Log_In (Debug, Quote ("parameter", Parameter));

      Ada_Lib.OS.Create_Scratch_File (Response_File, Response_File_Name);
      Log_Here (Debug, Quote ("response file name", Response_File_Name));
      Ada_Lib.OS.Close_File (Response_File);

      declare
         Result                  : constant Ada_Lib.OS.OS_Exit_Code_Type :=
                                    Ada_Lib.OS.Run.Spawn ("/usr/bin/CURL", Parameter,
                                       Response_File_Name);
         Success                 : Boolean := False;
         Quota                   : Natural := 0;

      begin
         Log_Here (Debug, "result " & Result'img);
         declare
            Response_File     : Ada.Text_IO.File_Type;

         begin
            if Debug then
               Ada.Text_IO.Put_Line (Quote ("response file", Response_File_Name));
            end if;

            Ada.Text_IO.Open (Response_File, Ada.Text_IO.In_File,
               Response_File_Name);

            while not Ada.Text_IO.End_Of_File (Response_File) loop
               declare
                  Response       : constant String :=
                                    Ada.Text_IO.Get_Line (Response_File);

               begin
                  if Debug then
                     Ada.Text_IO.Put_Line (Response);
                  end if;

                  Parse (Response, Success, Quota);
               end;
            end loop;

            if not Debug then
               Ada.Text_IO.Delete (Response_File);
            end if;

            if Success then
               if Verbose then
                  Ada.Text_IO.Put_Line ("Remaining text quota" & Quota'img);
               end if;
            else
               raise Failed with "send failed. quota" & Quota'img;
            end if;
         end;

         if Result /= Ada_Lib.OS.No_Error then
            Log_Here (Debug, "result " & Result'img);
--          raise Failed with "send text message failed with error code " &
--             Result'img;
         end if;
      end;

   exception
      when Fault: others =>
         Trace_Message_Exception (Fault, Who, Here);
         raise;

   end Send;

end Ada_Lib.Text.Textbelt;
