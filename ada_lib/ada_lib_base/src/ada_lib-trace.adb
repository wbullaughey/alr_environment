with Ada.Characters.Latin_1;
with Ada.Command_Line;
with Ada.Task_Identification;
with Ada.Text_IO; use  Ada.Text_IO;
with Ada_Lib.Options;
with Ada_Lib.OS;
--with Ada_Lib.Substiture_For_Non_Alpha;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Time;
with Ask;
with Hex_IO;
with Interfaces;
--with System.Address_Image;

--pragma Elaborate_All (Ada_Lib.Time);

package body Ada_Lib.Trace is

-- use type Ada.Calendar.Time;
   use type Ada.Task_Identification.Task_Id;
   use type System.Address;

   Maximum_Tasks  : constant := 100;

   type Context_Type             is (Decrement, Report_Exception, Increment,
                                       Raise_Exception, Same);


   type Task_Count_Type          is range 0 .. Maximum_Tasks;
   subtype Task_Index_Type       is Task_Count_Type range 1 .. Maximum_Tasks;

   type Task_Type is record
      Buffer      : Ada.Strings.Unbounded.Unbounded_String;
      Level       : Level_Type := Level_Type'first;
      Task_ID     : Ada.Task_Identification.Task_ID;
   end record;

   type Tasks_Type               is array (Task_Index_Type) of Task_Type;

   package Locked_Package is

      procedure Dump (
         Address  : in     System.Address;
         Length   : in     Natural;
         Width    : in     Positive;
         Dump_Width              : in     Dump_Width_Type;
         Description             : in     String;
         From     : in     String);

      procedure Override_Level (
         Level    : in     Level_Type);

      procedure Pause (
         Prompt   : in     String;
         From     : in     String;
         Trace    : in     Boolean );

      procedure Put (
         Enable   : in     Boolean := True;
         Context  : in     Context_Type;
         Message  : in     String;
         Where    : in     String;
         Who      : in     String);

      procedure Replace_Output_File (
         New_File    : in     File_Class_Access;
         Previous_File              :    out File_Class_Access);

      procedure Trace_Message_Exception (
         Fault       : in     Ada.Exceptions.Exception_Occurrence;
         Message     : in     String;
         From        : in     String;
         Who         : in     String);

      protected type Protected_Type is

         procedure Dump (
            Address              : in     System.Address;
            Length: in     Natural;
            Width : in     Positive;
            Dump_Width           : in     Dump_Width_Type;
            Description          : in     String;
            From  : in     String);

         procedure Override_Level (
            Level    : in     Level_Type);

         procedure Put (
            Enable: in     Boolean;
            Context              : in     Context_Type;
            Text  : in     String;
            Where : in     String;
            Who   : in     String);

         procedure Pause (
            Prompt: in     String;
            From  : in     String;
            Trace : in     Boolean);

         procedure Trace_Message_Exception (
            Fault    : in     Ada.Exceptions.Exception_Occurrence;
            Message  : in     String;
            From     : in     String;
            Who      : in     String);

      private
         Tasks    : Tasks_Type;

      end Protected_Type;

   end Locked_Package;

   Check_Address        : System.Address := System.Null_Address;
   Include_Task         : Boolean renames Ada_Lib.Options.Trace.Include_Task;
   Include_Time         : Boolean renames
                           Ada_Lib.Options.Trace.Include_Time;
   Indent_Amount        : constant := 2; -- spaces per level
   LF    : Character renames Ada.Characters.Latin_1.LF;
   Next_Free_Task       : Task_Index_Type := Task_Index_Type'first;
-- Trace_Preoptions_Complete
--       : constant Boolean := False;
   Trace_Tags           : constant Boolean := True;

   procedure Format_Output (    -- only call from within locked object
      Output_File             : in     File_Class_Access;
      Text     : in     String;
      Where    : in     String;
      Who      : in     String;
      Task_Data: in out Task_Type;
      Indent   : in     Boolean);

-- function Get_Start_Time
-- return Ada.Calendar.Time;

   procedure Put (
      Enable      : in     Boolean;
      Context     : in     Context_Type;
      Text        : in     String;
      Where       : in     String;
      Who         : in     String);

   ---------------------------------------------------------------
   function Ask_Pause (
      Manual      : in     Boolean;
      Prompt      : in     String
   ) return Boolean is
   ---------------------------------------------------------------

   begin
      if Manual then
         loop
            declare
               Response          : constant Character :=
                                    Ask.Ask_Character (Prompt & "[y/n]");
            begin
               case Response is

                  when 'n' | 'N' =>
                     return False;

                  when 'y' | 'Y' =>
                     return True;

                  when others =>
                     Put_Line (Quote ("unexpected response", Response));

               end case;
            end;
         end loop;
      else
         return True;
      end if;
   end Ask_Pause;

   --------------------------------------------------------------------
   procedure Dump (
      Address  : in     System.Address;
      Length   : in     Natural;
      Width    : in     Positive;
      Dump_Width              : in     Dump_Width_Type;
      Description             : in     String;
      From     : in     String) is
   --------------------------------------------------------------------

   begin
      Locked_Package.Dump (Address, Length, Width, Dump_Width, Description, From);
   end Dump;

   -------------------------------------------------------------------
   function Exception_Info (
      Fault       : in   Ada.Exceptions.Exception_Occurrence;
      Message     : in     String := "";
      Whom        : in     String := GNAT.Source_Info.Enclosing_Entity;
      Where       : in     String := GNAT.Source_Info.Source_Location
   ) return String is
   -------------------------------------------------------------------

   begin
      return Message &
         (if Message'length > 0 then " " else "") &
         Ada.Exceptions.Exception_Name (Fault) & " " &
         Ada.Exceptions.Exception_Message (Fault) &
         " from " & Whom & ":" & Where;
   end Exception_Info;

   --------------------------------------------------------------------
   overriding
   procedure Flush (
      File        : in     Default_File_Type) is
   --------------------------------------------------------------------

   begin
      Flush (File.File);
   end Flush;

   -------------------------------------------------------------------
   function Format (
      Seconds              : in   Integer;
      Show_Days            : in   Boolean := False
   ) return String is
   -------------------------------------------------------------------

   begin
      if Show_Days and then Seconds >= 86400 then
         return
            Pad (Integer'image (Seconds / 86400)) & ":" &
            Pad (Integer'image ((Seconds / 3600) mod 24)) & ":" &
            Pad (Integer'image ((Seconds / 60) mod 60)) & ":" &
            Pad (Integer'image (Seconds mod 60));
      else
         return
            Pad (Integer'image (Seconds / 3600)) & ":" &
            Pad (Integer'image ((Seconds / 60) mod 60)) & ":" &
            Pad (Integer'image (Seconds mod 60));
      end if;
   end Format;

   --------------------------------------------------------------------
   procedure Format_Output (
      Output_File : in     File_Class_Access;
      Text        : in     String;
      Where       : in     String;
      Who         : in     String;
      Task_Data   : in out Task_Type;
      Indent      : in     Boolean) is
   --------------------------------------------------------------------

   begin
      T (Debug_Trace, "indent " & Indent'img &
         " level" & Task_Data.Level'img & Quote (" text", Text));

      if Include_Program then
         Ada.Strings.Unbounded.Append (Task_Data.Buffer,
            Ada.Command_Line.Command_Name & "=> ");
      end if;

      if Include_Task then
         declare
            Current_Task_ID      : constant Ada.Task_Identification.Task_ID :=
                                    Ada.Task_Identification.Current_Task;

         begin
            Ada.Strings.Unbounded.Append (Task_Data.Buffer,
               Ada.Task_Identification.Image (Current_Task_ID) & ": ");
         end;
      end if;

      if Include_Time then
         Ada.Strings.Unbounded.Append (Task_Data.Buffer,
            "[" & Ada_Lib.Time.From_Start (Ada_Lib.Time.Now,
               Include_Hundreds) & "] ");
      end if;

      Ada.Strings.Unbounded.Append (Task_Data.Buffer,
         Where & " " & Who & " (" &
         Ada_Lib.Strings.Trim (Task_Data.Level'img) & ") " & Text);

      T(Debug_Trace, "length" &
         Ada.Strings.Unbounded.Length (Task_Data.Buffer)'img);
      if Ada.Strings.Unbounded.Length (Task_Data.Buffer) > 0 then
         declare
            Has_LF   : constant Boolean :=
                        Ada.Strings.Unbounded.To_String (Task_Data.Buffer)(1) = LF;
         begin
            T (Debug_Trace, "has lf " & Has_LF'img);
            if not Has_LF then
               Ada.Strings.Unbounded.Append (Task_Data.Buffer, LF);
            end if;

            if Indent and then Indent_Trace and then Task_Data.Level > 0 then
               declare
                  Padding           : constant String (1 .. Positive (
                                       Task_Data.Level * Indent_Amount)) := (
                                          others => ' ');
               begin
--ada.Text_io.put_line (here & Quote (" buffer", Task_Data.Buffer));
                  Ada.Strings.Unbounded.Insert (Task_Data.Buffer, 1, Padding);
--ada.Text_io.put_line (here & Quote (" buffer", Task_Data.Buffer) & Quote (" padding", padding));

               exception
                  when Fault: others =>
                     Trace_Message_Exception (Fault,
                        Quote ("text", Text), Where & " " & Who);
                     Ada_Lib.OS.Immediate_Halt (
                        Ada_Lib.OS.Exception_Exit);

               end;
            end if;

            T (Debug_Trace, Quote ("buffer", Task_Data.Buffer));
--ada.Text_io.put_line (here & " indent " & Indent'img & " Indent_Trace " & Indent_Trace'img & " level " & Task_Data.Level'img & Quote (" buffer", Task_Data.Buffer));
            Output_File.Output (Ada.Strings.Unbounded.To_String (Task_Data.Buffer));
            Output_File.Flush;
            Ada.Strings.Unbounded.Set_Unbounded_String (Task_Data.Buffer, "");

         exception
            when Fault: others =>
               Trace_Message_Exception (Fault, Quote ("text", Text),
                  Where & " " & Who);
               Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.Exception_Exit);

         end;
      end if;

      if Check_Address /= System.Null_Address then
         declare
            Value : Interfaces.Unsigned_64;
            for Value'address use Check_Address;

         begin
            Output_File.Output ("**** " & Hex_IO.Hex (Value) &
               " Address " & Ada_Lib.Strings.Image (Check_Address) & " *****");
         exception
            when Fault: others =>
               Trace_Message_Exception (Fault, Quote ("text", Text),
                  Where & " " & Who);
               Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.Exception_Exit);

         end;
      end if;

   exception

      when Fault: others =>
         Trace_Message_Exception (Fault, Quote ("text", Text) &
            " buffer length" & Ada.Strings.Unbounded.Length (Task_Data.Buffer)'img,
            Where & " " & Who);
         Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.Exception_Exit);

   end Format_Output;

   -------------------------------------------------------------------
   procedure Log (
      Enable      : in     Boolean := True;
      Where       : in     String := GNAT.Source_Info.Source_Location;
      Message     : in     String := "") is
   -------------------------------------------------------------------

   begin
      Put (Enable or else Trace_Exceptions,
         Same, Message, Where, "");
   end Log;

   -------------------------------------------------------------------
   procedure Log_Exception (
      Enable      : in     Boolean := True;
      Message     : in     String := "";
      Where       : in     String := GNAT.Source_Info.Source_Location;
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity) is
   -------------------------------------------------------------------

   begin
      Put (
         Enable      => Enable,
         Context     => Raise_Exception,
         Text        => Message & LF,
         Where       => Where,
         Who         => Who);
   end Log_Exception;

   -------------------------------------------------------------------
   procedure Log_Exception (
      Enable      : in     Boolean := True;
      Fault       : in     Ada.Exceptions.Exception_Occurrence;
      Message     : in     String := "";
      Where       : in     String := GNAT.Source_Info.Source_Location;
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity) is
   -------------------------------------------------------------------

   begin
      Put (
         Enable      => Enable,
         Context     => Report_Exception,
         Text        => LF & "exception: " &
                           Ada.Exceptions.Exception_Name (Fault) & LF &
                        "exception message: " &
                           Ada.Exceptions.Exception_Message (Fault) & LF &
                        (if Message'length > 0 then
                              Quote ("log message", Message) & LF
                           else
                              "") &
                        "caught at " & Where & LF,
         Where       => Where,
         Who         => Who);
--put_Line (here & " enable " & Enable'img & " '" & Where & "'");
   end Log_Exception;

   -------------------------------------------------------------------
   procedure Log_Here (
      Enable      : in     Boolean;
      Message     : in     String := "";
      Where       : in     String := GNAT.Source_Info.Source_Location;
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity) is
   -------------------------------------------------------------------

   begin
      Put (
         Enable      => Enable,
         Context     => Same,
         Text        => Message, -- & LF,
         Where       => Where,
         Who         => Who);
--ada.Text_io.put_line (here);
   end Log_Here;

   -------------------------------------------------------------------
   procedure Log_Here (
      Message     : in     String := "";
      Where       : in     String := GNAT.Source_Info.Source_Location;
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity) is
   -------------------------------------------------------------------

   begin
      Log_Here (True, Message, Where, Who);
   end Log_Here;

   -------------------------------------------------------------------
   function Log_Here (
      Result      : in     Boolean;
      Enable      : in     Boolean := True;
      Message     : in     String := "";
      Where       : in     String := GNAT.Source_Info.Source_Location;
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity
   ) return Boolean is
   -------------------------------------------------------------------

   begin
      Log_Here (Enable or else (Trace_Pre_Post_False and not Result),
         "result " & Result'img & " " & Message, Where, Who);
      return Result;
   end Log_Here;

   -------------------------------------------------------------------
   procedure Log_In (
      Enable      : in     Boolean := True;
      Message     : in     String := "";
      Where       : in     String := GNAT.Source_Info.Source_Location;
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity) is
   -------------------------------------------------------------------

   begin
      Put (
         Enable      => Enable,
         Context     => Increment,
         Text        => "in " & Message, -- & LF,
         Where       => Where,
         Who         => Who);
   end Log_In;

   -------------------------------------------------------------------
   procedure Log_In_Checked (
      Recursed    : in out Boolean;
      Enable      : in     Boolean := True;
      Message     : in     String := "";
      Where       : in     String := GNAT.Source_Info.Source_Location;
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity) is
   -------------------------------------------------------------------

   begin
--put_Line (here & " recursed " & recursed'img & " enable " & enable'img);
      Log_In (Enable or else Trace_Pre_Post_False, Message, Where, Who);

      if Recursed then
         Put_Line ("recursive call from " & Where & " by " & Who &
            Quote (" message", Message));
         Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.Recursion_Exit);
      else
         Recursed := True;
      end if;
   end Log_In_Checked;

   -------------------------------------------------------------------
   procedure Log_Out (
      Enable      : in     Boolean := True;
      Message     : in     String := "";
      Where       : in     String := GNAT.Source_Info.Source_Location;
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity) is
   -------------------------------------------------------------------

   begin
      Locked_Package.Put (
         Enable      => Enable,
         Context     => Decrement,
         Message     => "out " & Message, -- & LF,
         Where       => Where,
         Who         => Who);
   end Log_Out;

   -------------------------------------------------------------------
   function Log_Out (
      Result      : in     Boolean;
      Enable      : in     Boolean := True;
      Message     : in     String := "";
      Where       : in     String := GNAT.Source_Info.Source_Location;
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity
   ) return Boolean is
   -------------------------------------------------------------------

   begin
      Log_Out (Enable or else Trace_Pre_Post_Conditions or else
         (Trace_Pre_Post_False and not Result),
         "result " & Result'img & " " & Message, Where, Who);
      return Result;
   end Log_Out;

   -------------------------------------------------------------------
   procedure Log_Out_Checked (
      Recursed    : in out Boolean;
      Enable      : in     Boolean := True;
      Message     : in     String := "";
      Where       : in     String := GNAT.Source_Info.Source_Location;
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity) is
   -------------------------------------------------------------------

   begin
      if Recursed then
         Recursed := False;
         Log_Out (Enable or else Trace_Pre_Post_False, Message, Where, Who);
      else
         raise Recursive_Failure with "not logged in from " & Where & " by " & Who;
      end if;
   end Log_Out_Checked;

   -------------------------------------------------------------------
   function Log_Out_Checked (
      Recursed    : in out Boolean;
      Result      : in     Boolean;
      Enable      : in     Boolean := True;
      Message     : in     String := "";
      Where       : in     String := GNAT.Source_Info.Source_Location;
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity
   ) return Boolean is
   -------------------------------------------------------------------

   begin
      if Recursed then
         Recursed := False;
         Log_Out (Enable or else Trace_Pre_Post_False,
            "recursed " & Recursed'img &
            " result " & Result'img & " " & Message, Where, Who);
         return Result;
      else
         raise Recursive_Failure with "not logged in from " & Where & " by " & Who;
      end if;
   end Log_Out_Checked;

   -------------------------------------------------------------------
   -- aborts after printing message
   procedure Not_Implemented (
      Why         : in     String := "";
      Here        : in     String := GNAT.Source_Info.Source_Location;
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity) is
   -------------------------------------------------------------------

   begin
      Put (
         Enable      => True,
         Context     => Same,
         Text        => Why & " not implemented" & LF,
         Where       => Here,
         Who         => Who);
      Pause_On_Flag ("not implemented called from " & Here);
      Ada_Lib.OS.Immediate_Halt(Ada_Lib.OS.Not_Implemented_Exit);
   end Not_Implemented;

   --------------------------------------------------------------------
   overriding
   procedure Output (
      File        : in out Default_File_Type;
      Data        : in     String) is
   --------------------------------------------------------------------

   begin
--ada.Text_io.put_line (here);
      Put (File.File, Data);
--ada.Text_io.put_line (here);
   end Output;

   -------------------------------------------------------------------
   procedure Override_Level (
      Level       : in     Level_Type) is
   -------------------------------------------------------------------

   begin
      Locked_Package.Override_Level (Level);
   end Override_Level;

   -------------------------------------------------------------------
   function Pad (
      Source            : in   String
   ) return String is
   -------------------------------------------------------------------

      Trimmed           : constant String := Ada_Lib.Strings.Trim (Source);

   begin
      case Trimmed'length is

         when 0 =>
            return "00";

         when 1 =>
            return "0" & Trimmed;

         when others =>
            return Trimmed;

      end case;
   end Pad;

   -------------------------------------------------------------------
   procedure Pause (
      Prompt      : in     String := "";
      From        : in     String := Here;
      Trace       : in     Boolean := False) is
   -------------------------------------------------------------------

   begin
      Pause (True, Prompt, From, Trace);
   end Pause;

   -------------------------------------------------------------------
   procedure Pause (
      Condition   : in     Boolean;
      Prompt      : in     String := "";
      From        : in     String := Here;
      Trace       : in    Boolean := False) is
   -------------------------------------------------------------------

   begin
      if Condition then
         Locked_Package.Pause (Prompt, From, Trace);
      end if;
   end Pause;

   -------------------------------------------------------------------
   procedure Pause_On_Flag (
      Prompt      : in     String;
      From        : in     String := Here;
      Trace       : in    Boolean := False) is
   -------------------------------------------------------------------

   begin
      if Pause_Flag then
         Pause (Prompt, From, Trace);
      end if;
   end Pause_On_Flag;

   --------------------------------------------------------------------
   procedure Put (
      Enable      : in     Boolean;
      Context     : in     Context_Type;
      Text        : in     String;
      Where       : in     String;
      Who         : in     String) is
   --------------------------------------------------------------------

   begin
--ada.Text_io.put_line (here);
      T (Debug_Trace, "enable " & Enable'img &
         Quote (" text", Text) & Quote (" where", Where) &
         Quote (" who", Who));
--ada.Text_io.put_line (here);
      Locked_Package.Put (Enable, Context, Text, Where, Who);
--ada.Text_io.put_line (here);
   end Put;

   ---------------------------------------------------------------
   procedure Replace_Output_File (
      New_File    : in     File_Class_Access;
      Previous_File              :    out File_Class_Access) is
   ---------------------------------------------------------------

   begin
      Locked_Package.Replace_Output_File (New_File, Previous_File);
   end Replace_Output_File;

   --------------------------------------------------------------------
   procedure Set_Check_Address (
      Address              : in     System.Address) is
   --------------------------------------------------------------------

   begin
      Check_Address := Address;

      declare
         Value : Interfaces.Unsigned_64;
         for Value'address use Check_Address;

      begin
         Put_Line ("**** setting " &
            " Address " & Ada_Lib.Strings.Image (Check_Address) &
            " initial value " & Hex_IO.Hex (Value) & " *****");
      end;
   end Set_Check_Address;

-- -------------------------------------------------------------------
-- procedure Set_Options_Completed is
-- -------------------------------------------------------------------
--
-- begin
--    Options_Completed := True;
-- end Set_Options_Completed;

   --------------------------------------------------------------------
   procedure T (
      Enable      : in     Boolean := True;
      What        : in     String := "";
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity;
      Where       : in     String :=  GNAT.Source_Info.Source_Location) is
   --------------------------------------------------------------------

   begin
--ada.Text_io.put_line (here & " enable " & enable'img);
      if Enable then
         Put_Line ("------> " & Where & " " & Who & " " & Current_Task &
            (if What'length = 0 then "" else " " & What) &
            " <-------");
      end if;
   end T;

   --------------------------------------------------------------------
   procedure Tag_History (
      Variable    : in     String;
      Tag_Value   : in     Ada.Tags.Tag;
      From        : in     String := GNAT.Source_Info.
                                             Source_Location) is
   --------------------------------------------------------------------

      use type Ada.Tags.Tag;

      This_Tag    : Ada.Tags.Tag := Tag_Value;

   begin
      if Trace_Tags then
         Put_Line ("Tag history for " & Variable & ": " &
            Ada.Tags.Expanded_Name (Tag_Value) &
            " from " & From);
         loop
            declare
               Parent: constant Ada.Tags.Tag :=
                                       Ada.Tags.Parent_Tag (This_Tag);
            begin
               if Parent = Ada.Tags.No_Tag then
                  Put_Line ("root " & Ada.Tags.Expanded_Name (This_Tag));
                  exit;
               else
                  Put_Line ("Parent " & Ada.Tags.Expanded_Name (Parent));
                  This_Tag := Parent;
               end if;
            end;
         end loop;
      end if;
   end Tag_History;

   --------------------------------------------------------------------
   procedure Tag_History (
      Enable      : in     Boolean;
      Variable    : in     String;
      Tag_Value   : in     Ada.Tags.Tag;
      From        : in     String := GNAT.Source_Info.
                                             Source_Location) is
   --------------------------------------------------------------------

   begin
      if Enable then
         Tag_History (Variable, Tag_Value, From);
      end if;
   end Tag_History;

   --------------------------------------------------------------------
   function Tag_Name (
      Variable    : in     String;
      Tag_Value   : in     Ada.Tags.Tag
   ) return String is
   --------------------------------------------------------------------

   begin
      return Variable & " tag " & Ada.Tags.Expanded_Name (Tag_Value);
   end Tag_Name;

   --------------------------------------------------------------------
   procedure Trace_Exception (
      Debug       : in   Boolean;
      Fault       : in   Ada.Exceptions.Exception_Occurrence;
      Where       : in   String := GNAT.Source_Info.Source_Location;
      Who         : in   String := GNAT.Source_Info.Enclosing_Entity) is
   --------------------------------------------------------------------

   begin
      Trace_Message_Exception (Debug or Trace_Exceptions,
         Fault, "", Where, Who);
   end Trace_Exception;

   --------------------------------------------------------------------
   procedure Trace_Exception (
      Fault       : in   Ada.Exceptions.Exception_Occurrence;
      Where       : in   String := GNAT.Source_Info.Source_Location;
      Who         : in   String := GNAT.Source_Info.Enclosing_Entity) is
   --------------------------------------------------------------------

   begin
      Trace_Message_Exception (True, Fault, "", Where, Who);
   end Trace_Exception;

   --------------------------------------------------------------------
   procedure Trace_Message_Exception (
      Debug       : in   Boolean;
      Fault       : in   Ada.Exceptions.Exception_Occurrence;
      Message     : in   String;
      Where       : in   String := GNAT.Source_Info.Source_Location;
      Who         : in   String := GNAT.Source_Info.Enclosing_Entity) is
   --------------------------------------------------------------------

   begin
      Ada_Lib.Exception_Occured := True;

      if Debug or Trace_Exceptions then
         Locked_Package.Trace_Message_Exception (Fault, Message, Where, Who);
      end if;
   end Trace_Message_Exception;

   --------------------------------------------------------------------
   procedure Trace_Message_Exception (
      Fault       : in   Ada.Exceptions.Exception_Occurrence;
      Message     : in   String;
      Where       : in   String := GNAT.Source_Info.Source_Location;
      Who         : in   String := GNAT.Source_Info.Enclosing_Entity) is
   --------------------------------------------------------------------

   begin
      Trace_Message_Exception (True, Fault, Message, Where, Who);
   end Trace_Message_Exception;

   -------------------------------------------------------------------
   package body Locked_Package is

      Output_File : File_Class_Access :=
                                    new Default_File_Type'(
                                       File  => Ada.Text_IO.Standard_Output);
      State       : Protected_Type;

      ---------------------------------------------------------------
      procedure Dump (
         Address  : in     System.Address;
         Length   : in     Natural;
         Width    : in     Positive;
         Dump_Width              : in     Dump_Width_Type;
         Description             : in     String;
         From     : in     String) is
      ---------------------------------------------------------------


      begin
         State.Dump (Address, Length, Width, Dump_Width,
            Description, From);
      end Dump;

      -------------------------------------------------------------------
      procedure Override_Level (
         Level       : in     Level_Type) is
      -------------------------------------------------------------------

      begin
         State.Override_Level (Level);
      end Override_Level;

      ---------------------------------------------------------------
      procedure Pause (
         Prompt      : in     String;
         From        : in     String;
         Trace       : in     Boolean) is
      ---------------------------------------------------------------

      begin
         State.Pause (Prompt, From, Trace);
      end Pause;

      ---------------------------------------------------------------
      procedure Put (
         Enable   : in     Boolean := True;
         Context  : in     Context_Type;
         Message  : in     String;
         Where    : in     String;
         Who      : in     String) is
      ---------------------------------------------------------------

      begin
--ada.Text_io.put_line (here);
         State.Put (Enable, Context, Message, Where, Who);
--ada.Text_io.put_line (here);
      end Put;

      ---------------------------------------------------------------
      procedure Replace_Output_File (
         New_File    : in     File_Class_Access;
         Previous_File              :    out File_Class_Access) is
      ---------------------------------------------------------------

      begin
--ada.Text_io.put_line (here & " new file " & Image (New_File.all'address));
         Previous_File := Output_File;
         Output_File := New_File;
--ada.Text_io.put_line (here & " Previous_File " & Image (Previous_File.all'address));
      end Replace_Output_File;

      ------------------------------------------------------------------
      procedure Trace_Message_Exception (
         Fault    : in     Ada.Exceptions.Exception_Occurrence;
         Message  : in     String;
         From     : in     String;
         Who      : in     String) is
      -------------------------------------------------------------------

      begin
         Ada_Lib.Exception_Occured := True;
         State.Trace_Message_Exception (Fault, Message, From, Who);
      end Trace_Message_Exception;

      ---------------------------------------------------------------
      protected body Protected_Type is

         ---------------------------------------------------------------
         procedure Dump (
            Address  : in     System.Address;
            Length   : in     Natural;          -- in bytes
            Width    : in     Positive;         -- line to print
            Dump_Width              : in     Dump_Width_Type;  -- format
            Description             : in     String;
            From     : in     String) is
         ---------------------------------------------------------------

            Routine  : constant array (Dump_Width_Type) of
                                          access procedure (
                                          Source  : in     System.Address;
                                          Size    : in     Positive;        -- size in bits
                                          Width   : in     Positive;
                                          Message : in     String) := (
                  Hex_IO.Dump_8'access,
                  Hex_IO.Dump_16'access,
                  Hex_IO.Dump_32'access,
                  Hex_IO.Dump_64'access);

         begin
--T(true, "in");
            if Length = 0 then
               Put_Line ("dump for " & Description &
                  " for 0 bytes called from " & From);
            else
               Routine (Dump_Width) (Address, Length * 8, Width,
                  "dump for " & Description & " called from " & From);
            end if;
--T(true, "out");
         end Dump;

         ---------------------------------------------------------------
         procedure Find_Task (
            Result:    out Task_Index_Type) is
         ---------------------------------------------------------------

            Current_Task_ID            : constant Ada.Task_Identification.Task_ID :=
                                          Ada.Task_Identification.Current_Task;
            Free_Task_Index            : Task_Count_Type := 0;

         begin
            for Index in Tasks'first .. Next_Free_Task - 1 loop
               declare
                  Item  : Task_Type renames Tasks (Index);

               begin
                  if Item.Task_ID = Current_Task_ID then
                     T(Debug_Trace, "task" & Index'img);
                     Result := Index;
                     return;
                  elsif Free_Task_Index = 0 and then
                        Ada.Task_Identification.Is_Terminated (
                           Item.Task_ID) then
                     Free_Task_Index := Index;
                     T (Debug_Trace, "free index " & Free_Task_Index'img);
                  end if;
               end;
            end loop;

            if Free_Task_Index /= 0 then
               Result := Free_Task_Index;
               T(Debug_Trace, "use free task index" & Result'img);
            else
               declare
                  Task_Index  : constant Task_Index_Type := Next_Free_Task;

               begin
                  Next_Free_Task := Next_Free_Task + 1;
                  Result := Task_Index;
                  T(Debug_Trace, "new task index" & Result'img);
               end;
            end if;

            Tasks (Result).Task_ID := Current_Task_ID;
         end Find_Task;

         -------------------------------------------------------------------
         procedure Override_Level (
            Level       : in     Level_Type) is
         -------------------------------------------------------------------

            Task_Index              : Task_Index_Type;

         begin
            Find_Task (Task_Index);

            declare
               Task_Entry           : Task_Type renames
                                       Tasks (Task_Index);

            begin
               Task_Entry.Level := Level;
            end;
         end Override_Level;

         ------------------------------------------------------------------
         procedure Trace_Message_Exception (
            Fault       : in     Ada.Exceptions.Exception_Occurrence;
            Message     : in     String;
            From        : in     String;
            Who         : in     String) is
         -------------------------------------------------------------------

            Task_Index              : Task_Index_Type;

         begin
            Ada_Lib.Exception_Occured := True;
            Find_Task (Task_Index);

            declare
               Task_Entry           : Task_Type renames
                                       Tasks (Task_Index);

            begin
               Output_File.Output ("----------- exception --------------"& LF);
               Output_File.Output ("Exception name:" &
                  Ada.Exceptions.Exception_Name (Fault)& LF);
               Output_File.Output ("Exception message:" &
                  Ada.Exceptions.Exception_Message (Fault)& LF);
               if Message'length > 0 then
                  Output_File.Output ("handler message:" & Quote (Message) & LF);
               end if;
               Format_Output (Output_File, "caught at " & From &
                  " who " & Who, "", "",
                  Task_Entry, True);
               Output_File.Output ("------------------------------------"& LF);
            end;

         exception

            when Fault: others =>
               Output_File.Output  (Ada.Exceptions.Exception_Name (Fault) &
                  "Exception message:" & Ada.Exceptions.Exception_Message (Fault));
               Ada_Lib.OS.Immediate_Halt(Ada_Lib.OS.Exception_Exit);
         end Trace_Message_Exception;

         ------------------------------------------------------------
         procedure Pause (
            Prompt   : in     String;
            From     : in     String;
            Trace    : in     Boolean) is
         pragma Unreferenced (Trace);
         ------------------------------------------------------------

            Task_Index              : Task_Index_Type;

         begin
            Find_Task (Task_Index);

            declare
               Task_Entry           : Task_Type renames
                                       Tasks (Task_Index);
            begin
               Format_Output (Output_File, Prompt & " pause called from " &
                  From, Here, Who, Task_Entry, False);

               declare
                  Answer: constant Character :=
                                          Ask.Ask_Character (Prompt);
                  pragma Unreferenced (Answer);
               begin
                  New_Line;
               end;
            end;
         end Pause;

         ------------------------------------------------------------
         procedure Put (
            Enable   : in     Boolean;
            Context  : in     Context_Type;
            Text     : in     String;
            Where    : in     String;
            Who      : in     String) is
         ------------------------------------------------------------

            Task_Index              : Task_Index_Type;

         begin
--ada.Text_io.put_line (here & " enable " & Enable'img & " Trace_Preoptions_Complete " & Trace_Preoptions_Complete'img & " Options_Completed " & Options_Completed'img) ;
            Find_Task (Task_Index);
--ada.Text_io.put_line (here);

            declare
               Task_Entry           : Task_Type renames
                                       Tasks (Task_Index);
            begin
--ada.Text_io.put_line (here);
               T (Debug_Trace, "in enable " & Enable'img &
--                " Options_Completed " & Options_Completed'img &
                  " context " & Context'img &
                  " level" & Task_Entry.Level'img & Quote (" text", Text) &
                  " where " & Where & " who " & Who);
--ada.Text_io.put_line (here & " emab;e " & enable'img & " Options_Completed " & Options_Completed'img);
               if    Enable then
--                   (Trace_Preoptions_Complete and not Options_Completed) then
                  case Context is

                     when Report_Exception =>
                        Ada_Lib.Exception_Occured := True;
                        Output_File.Output (
                           "-------------------- exception ----------------" & LF);

                     when Increment =>
                        Task_Entry.Level := Task_Entry.Level + 1;
--ada.Text_io.put_line (here & " level " & Task_Entry.Level'img);

                     when others =>
                        null;

                  end case;

--ada.Text_io.put_line (here & " emab;e " & enable'img);
                  Format_Output (Output_File, Text, Where, Who, Task_Entry, True);
--ada.Text_io.put_line (here & " emab;e " & enable'img);
                  case Context is

                     when Decrement =>
                        null;

                     when Report_Exception =>
                        Output_File.Output (
                           "-----------------------------------------------" & LF);

                     when others =>
                        return;

                  end case;

                  if Task_Entry.Level = 0 then
                     Output_File.Output ("missing log in from " &
                        Where & ":" & Who & LF);
                  else
                     Task_Entry.Level := Task_Entry.Level - 1;
--ada.Text_io.put_line (here & " level " & Task_Entry.Level'img);
                  end if;
               end if;
--ada.Text_io.put_line (here);
               T (Debug_Trace, "out enable " & Enable'img & " context " & Context'img &
                  " level" & Task_Entry.Level'img & Quote (" text", Text));
--ada.Text_io.put_line (here);
            end;
--ada.Text_io.put_line (here);
         end Put;

      end Protected_Type;

   end Locked_Package;

   ---------------------------------------------------------------
   package body Tag_Package is

      ---------------------------------------------------------------
      procedure Generic_Tag_History (
         Enable      : in     Boolean;
         Object      : in     Object_Class_Access;
         From        : in     String := GNAT.Source_Info.
                                                Source_Location) is
      ---------------------------------------------------------------

      begin
         Tag_History (Enable, "object", Object.all'tag, From);
      end Generic_Tag_History;

   end Tag_Package;
   ---------------------------------------------------------------

   begin
--Debug_Trace := True;
--Elaborate := True;
Trace_Options := True;
--Trace_Pre_Post_False := True;
--Trace_Set_Up_Tear_Down := True;
--Trace_Tests := True;
   Include_Hundreds := True;
-- Include_Program := True;
-- Include_Task := True;
-- Include_Time := True;
   Indent_Trace := True;
   Log_Here (Debug_Trace or Elaborate or Trace_Options or Trace_Tests,
      "start time " & Time.Image (Time.Get_Start_Time) &
      " debug trace " & Debug_Trace'img &
      " elaborate " & Elaborate'img &
      " trace options " & Trace_Options'img &
      " trace tests " & Trace_Tests'img);
--put_line ("clock" & Ada.Calendar.Clock'img);
--Put_Line("Formatted: " &
--    Ada.Calendar.Formatting.Image(Start_Time));
end Ada_Lib.Trace;
