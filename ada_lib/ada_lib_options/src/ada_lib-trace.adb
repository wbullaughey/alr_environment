with Ada.Characters.Latin_1;
with Ada.Command_Line;
with Ada.Task_Identification;
with Ada.Text_IO; use  Ada.Text_IO;
--with Ada_Lib.Maps.Element;
with Ada_Lib.Options;
with Ada_Lib.OS;
--with Ada_Lib.Specifications;
--with Ada_Lib.Strings;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
--with Ada_Lib.Maps.Table;
with Ada_Lib.Time;
with Ask;
with Hex_IO;
with Interfaces;

package body Ada_Lib.Trace is

   use type Ada.Task_Identification.Task_Id;
   use type System.Address;

   Maximum_Tasks           : constant := 100;
   Undefined_Task_Index    : constant := -1;
   type Context_Type       is (Decrement, Report_Exception, Increment,
                              Raise_Exception, Same);


   type Task_Index_Type    is new Integer range
                              Undefined_Task_Index .. Maximum_Tasks;
   subtype Task_Count_Type is Task_Index_Type range 0 .. Maximum_Tasks;

   type Task_Type    is record
      Buffer         : Ada.Strings.Unbounded.Unbounded_String;
      Level          : Level_Type := Lowest_Level;
      Task_ID        : Ada.Task_Identification.Task_ID;
   end record;

   type Task_Access  is access all Task_Type;

   type Tasks_Type   is array (Task_Index_Type) of aliased Task_Type;

   protected type Protected_State_Type is

      procedure Dump (
         Address              : in     System.Address;
         Length: in     Natural;
         Width : in     Positive;
         Dump_Width           : in     Dump_Width_Type;
         Description          : in     String;
         From  : in     String);

      procedure Find_Task (
         Result:    out Task_Index_Type);

      procedure Get_Task (
         Task_Index           : in     Task_Index_Type;
         Task_Pointer         :    out Task_Access);

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
      Tasks    : aliased Tasks_Type;

   end Protected_State_Type;

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


   end Locked_Package;

   Check_Address        : System.Address := System.Null_Address;
   Global_Context_Level : Natural := 0;
   Include_Task         : Boolean renames Ada_Lib.Options.Trace.Include_Task;
   Include_Time         : Boolean renames
                           Ada_Lib.Options.Trace.Include_Time;
   Indent_Amount        : constant := 2; -- spaces per level
   LF    : Character renames Ada.Characters.Latin_1.LF;
   Output_File          : File_Class_Access :=
                           new Default_File_Type'(
                              File  => Ada.Text_IO.Standard_Output);
   Next_Free_Task       : Task_Index_Type := Task_Index_Type'first;
   Protected_State      : Protected_State_Type;
   State_Lock_Count     : Natural := 0;
-- Trace_Preoptions_Complete
--       : constant Boolean := False;
-- Trace_Tags           : constant Boolean := True;

   procedure Format_Output (    -- only call from within locked object
      Output_File             : in     File_Class_Access;
      Text     : in     String;
      Where    : in     String;
      Who      : in     String;
      Task_Data: in out Task_Type;
      Indent   : in     Boolean);

   procedure Put (
      Enable      : in     Boolean;
      Context     : in     Context_Type;
      Text        : in     String;
      Where       : in     String;
      Who         : in     String);

   procedure Unlocked_Put (
      Enable   : in     Boolean;
      Context  : in     Context_Type;
      Text     : in     String;
      Where    : in     String;
      Who      : in     String);

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
      Log_Here_Non_Locking("in indent " & Indent'img &
         " level" & Task_Data.Level'img & Quote (" text", Text), Debug_Trace);

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

      Log_Here_Non_Locking("length" &
         Ada.Strings.Unbounded.Length (Task_Data.Buffer)'img, Debug_Trace);
      if Ada.Strings.Unbounded.Length (Task_Data.Buffer) > 0 then
         declare
            Has_LF   : constant Boolean :=
                        Ada.Strings.Unbounded.To_String (Task_Data.Buffer)(1) = LF;
         begin
            Log_Here_Non_Locking("has lf " & Has_LF'img, Debug_Trace);
            if not Has_LF then
               Ada.Strings.Unbounded.Append (Task_Data.Buffer, LF);
            end if;

            if Indent and then Indent_Trace and then Task_Data.Level > 0 then
               declare
                  Padding           : constant String (1 .. Positive (
                                       Task_Data.Level * Indent_Amount)) := (
                                          others => ' ');
               begin
                  Ada.Strings.Unbounded.Insert (Task_Data.Buffer, 1, Padding);

               exception
                  when Fault: others =>
                     Trace_Message_Exception (Fault,
                        Quote ("text", Text), Where & " " & Who);
                     Ada_Lib.OS.Immediate_Halt (
                        Ada_Lib.OS.Exception_Exit);

               end;
            end if;

            Log_Here_Non_Locking(Quote ("buffer", Task_Data.Buffer), Debug_Trace);
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
      Log_Here_Non_Locking("out", Debug_Trace);

   exception

      when Fault: others =>
         Trace_Message_Exception (Fault, Quote ("text", Text) &
            " buffer length" & Ada.Strings.Unbounded.Length (Task_Data.Buffer)'img,
            Where & " " & Who);
         Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.Exception_Exit);

   end Format_Output;

   -------------------------------------------------------------------
   function Get_Level (
      From     : in     String :=  GNAT.Source_Info.Source_Location
   ) return Level_Type is
   -------------------------------------------------------------------

   begin
      Log_Here_Non_Locking("return from " & From & " Global_Context_Level " & Global_Context_Level'img, Debug_Trace);
      return Global_Context_Level;
   end Get_Level;

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
      Log_Here (Enable, "result " & Result'img & " " & Message, Where, Who);
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
      Log_Here_Non_Locking ("enable " & enable'img & " message " & message,
         Debug_Trace);
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
      Log_In (Enable, Message, Where, Who);

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
      Put (
         Enable      => Enable,
         Context     => Decrement,
         Text        => "out " & Message, -- & LF,
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
      Log_Out (Enable,
         "result " & Result'img & " " & Message, Where, Who);
      return Result;
   end Log_Out;

   -------------------------------------------------------------------
   procedure Log_Out_Checked (
      Recursed    : in out Boolean;
      Enable      : in     Boolean;
      Message     : in     String := "";
      Where       : in     String := GNAT.Source_Info.Source_Location;
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity) is
   -------------------------------------------------------------------

   begin
      if Recursed then
         Recursed := False;
         Log_Out (Enable, Message, Where, Who);
      else
         raise Recursive_Failure with "not logged in from " & Where & " by " & Who;
      end if;
   end Log_Out_Checked;

   -------------------------------------------------------------------
   function Log_Out_Checked (
      Recursed    : in out Boolean;
      Result      : in     Boolean;
      Enable      : in     Boolean;
      Message     : in     String := "";
      Where       : in     String := GNAT.Source_Info.Source_Location;
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity
   ) return Boolean is
   -------------------------------------------------------------------

   begin
      if Recursed then
         Recursed := False;
         Log_Out (Enable,
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
--Log_Here_Non_Locking (here);
      Put (
         Enable      => True,
         Context     => Same,
         Text        => Why & " not implemented from " & Here & LF,
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
--Log_Here_Non_Locking("in");
      Put (File.File, Data);
--Log_Here_Non_Locking("out");
   end Output;

   -------------------------------------------------------------------
   procedure Override_Level (
      Level       : in     Level_Type) is
   -------------------------------------------------------------------

   begin
--Log_Here_Non_Locking;
      Locked_Package.Override_Level (Level);
   end Override_Level;

   -------------------------------------------------------------------
   procedure Log_Here_Non_Locking(
      Message     : in     String := "";
      Enable      : in     Boolean := True;
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity;
      From        : in     String :=  GNAT.Source_Info.Source_Location) is
   -------------------------------------------------------------------

   begin
--Put_Line ("here " & here & " from " & from & " enable " & Enable'img);
      if enable then
         Put_Line ("non blocking " &
            Ada.Task_Identification.Image (
               Ada.Task_Identification.Current_Task) & ": " &
            From & " from package " & Who & (
               if Message'length > 0 then
                  " message " & Message
               else
                  ""));
      end if;
   end Log_Here_Non_Locking;

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
      Log_Here_Non_Locking("in enable " & Enable'img &
         Quote (" text", Text) & Quote (" where", Where) &
         Quote (" who", Who) &
         " lock count " & State_Lock_Count'img,
         Debug_Trace);

      if Enable then
         if State_Lock_Count > 0 then
            Unlocked_Put (Enable, Context, Text, Where, Who);
         else
            Locked_Package.Put (Enable, Context, Text, Where, Who);
         end if;
      end if;
      Log_Here_Non_Locking("out", Debug_Trace);
   end Put;

   ---------------------------------------------------------------
   procedure Replace_Output_File (
      New_File    : in     File_Class_Access;
      Previous_File              :    out File_Class_Access) is
   ---------------------------------------------------------------

   begin
--Log_Here_Non_Locking;
      Locked_Package.Replace_Output_File (New_File, Previous_File);
--Log_Here_Non_Locking;
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

   --------------------------------------------------------------------
   procedure T (
      Enable      : in     Boolean := True;
      What        : in     String := "";
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity;
      Where       : in     String :=  GNAT.Source_Info.Source_Location) is
   --------------------------------------------------------------------

   begin
--Log_Here_Non_Locking("in enable " & enable'img & " what " & What & " who " & Who  & " where " & Where);
      if Enable then
         Put_Line ("------> (" & Get_Level'img & ")" & Where & " " &
            Who & " " & (
               if Ada_Lib.Is_Elaborated then
                  Current_Task
               else
                  "current task not elaborated") &
            (if What'length = 0 then "" else " " & What) &
            " <-------");
      end if;
--Log_Here_Non_Locking("out");
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
   end Tag_History;

   --------------------------------------------------------------------
   procedure Tag_History (
      Enable      : in     Boolean;
      Variable    : in     String;
      Tag_Value   : in     Ada.Tags.Tag;
      From        : in     String := GNAT.Source_Info.Source_Location) is
   --------------------------------------------------------------------

   begin
      if Enable and then Trace_Tag_History then
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
   function Trace_Return (
      Debug       : in     Boolean;
      Value       : in     Boolean;
      Message     : in     String := "";
      Where       : in     String := GNAT.Source_Info.Source_Location;
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity
   ) return Boolean is
   -------------------------------------------------------------------

   begin
      Put (
         Enable      => Debug,
         Context     => Same,
         Text        => "Trace_Return " & Value'img & " message " &Message,
         Where       => Where,
         Who         => Who);
      return Value;
   end Trace_Return;

   -------------------------------------------------------------------
   package body Locked_Package is

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
         Protected_State.Dump (Address, Length, Width, Dump_Width,
            Description, From);
      end Dump;

      -------------------------------------------------------------------
      procedure Override_Level (
         Level       : in     Level_Type) is
      -------------------------------------------------------------------

      begin
         Protected_State.Override_Level (Level);
      end Override_Level;

      ---------------------------------------------------------------
      procedure Pause (
         Prompt      : in     String;
         From        : in     String;
         Trace       : in     Boolean) is
      ---------------------------------------------------------------

      begin
         Protected_State.Pause (Prompt, From, Trace);
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
         Log_Here_Non_Locking("enable " & Enable'img &
            " lock count " & State_Lock_Count'img &
            " message " & Message, Debug_Trace);
         if Enable then
            if State_Lock_Count > 0 then
               Put_Line (Message);
            else
               Protected_State.Put (Enable, Context, Message, Where, Who);
            end if;
         end if;
         Log_Here_Non_Locking("out", Debug_Trace);
      end Put;

      ---------------------------------------------------------------
      procedure Replace_Output_File (
         New_File       : in     File_Class_Access;
         Previous_File  :    out File_Class_Access) is
      ---------------------------------------------------------------

      begin
--Log_Here_Non_Locking (here & " new file " & Ada_Lib.Strings.Image (New_File.all'address));
         Previous_File := Output_File;
         Output_File := New_File;
--Log_Here_Non_Locking (here & " Previous_File " & Ada_Lib.Strings.Image (Previous_File.all'address));
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
         Protected_State.Trace_Message_Exception (Fault, Message, From, Who);
      end Trace_Message_Exception;

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
   protected body Protected_State_Type is

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
         Log_Here_Non_Locking("in", Debug_Trace);
         State_Lock_Count := State_Lock_Count + 1;
--            Lock_State.Lock;
         if Length = 0 then
            Put_Line ("dump for " & Description &
               " for 0 bytes called from " & From);
         else
            Routine (Dump_Width) (Address, Length * 8, Width,
               "dump for " & Description & " called from " & From);
         end if;
--            Lock_State.Unlock;
         State_Lock_Count := State_Lock_Count - 1;
         Log_Here_Non_Locking("out", Debug_Trace);
      end Dump;

      ---------------------------------------------------------------
      procedure Find_Task (
         Result:    out Task_Index_Type) is
      ---------------------------------------------------------------

         Current_Task_ID            : constant Ada.Task_Identification.Task_ID :=
                                       Ada.Task_Identification.Current_Task;
         Free_Task_Index            : Task_Count_Type := 0;

      begin
         Log_Here_Non_Locking("in current task id " &
            Current_Task_ID'img, Debug_Trace);
         State_Lock_Count := State_Lock_Count + 1;
--            Lock_State.Lock;
--Log_Here_Non_Locking;
         for Index in Tasks'first .. Next_Free_Task - 1 loop
            declare
               Item  : Task_Type renames Tasks (Index);

            begin
               if Item.Task_ID = Current_Task_ID then
                  Result := Index;
--                     Lock_State.Unlock;
                  State_Lock_Count := State_Lock_Count - 1;
                  Log_Here_Non_Locking("out task index result " &
                     Result'img, Debug_Trace);
                  return;
               elsif Free_Task_Index = 0 and then
                     Ada.Task_Identification.Is_Terminated (
                        Item.Task_ID) then
                  Free_Task_Index := Index;
                  Log_Here_Non_Locking("free index " & Free_Task_Index'img, Debug_Trace);
               end if;
            end;
         end loop;

         if Free_Task_Index /= 0 then
            Result := Free_Task_Index;
            Log_Here_Non_Locking("use free task index" & Result'img, Debug_Trace);
         else
            declare
               Task_Index  : constant Task_Index_Type := Next_Free_Task;

            begin
               Next_Free_Task := Next_Free_Task + 1;
               Result := Task_Index;
               Log_Here_Non_Locking("new task index" & Result'img, Debug_Trace);
            end;
         end if;

         Tasks (Result).Task_ID := Current_Task_ID;
--Log_Here_Non_Locking;
--            Lock_State.Unlock;
         State_Lock_Count := State_Lock_Count - 1;
         Log_Here_Non_Locking("out result " & Result'img, Debug_Trace);
      end Find_Task;

      -------------------------------------------------------------------
      procedure Get_Task (
         Task_Index           : in     Task_Index_Type;
         Task_Pointer         :    out Task_Access) is
      -------------------------------------------------------------------

      begin
         Task_Pointer := Tasks (Task_Index)'unchecked_access;
      end Get_Task;

      -------------------------------------------------------------------
      procedure Override_Level (
         Level       : in     Level_Type) is
      -------------------------------------------------------------------

         Task_Index              : Task_Index_Type;

      begin
         Log_Here_Non_Locking("in", Debug_Trace);
         State_Lock_Count := State_Lock_Count + 1;
--            Lock_State.Lock;
--          T(Debug_Trace, "in level " & Level'img);
         Find_Task (Task_Index);

         declare
            Task_Entry           : Task_Type renames
                                    Tasks (Task_Index);

         begin
            Task_Entry.Level := Level;
         end;
--            Lock_State.Unlock;
         State_Lock_Count := State_Lock_Count - 1;
         Log_Here_Non_Locking("out", Debug_Trace);
--          T(Debug_Trace, "Out");
      end Override_Level;

      ------------------------------------------------------------
      procedure Pause (
         Prompt   : in     String;
         From     : in     String;
         Trace    : in     Boolean) is
      pragma Unreferenced (Trace);
      ------------------------------------------------------------

         Task_Index              : Task_Index_Type;

      begin
         Log_Here_Non_Locking("in", Debug_Trace);
--            Lock_State.Lock;
         State_Lock_Count := State_Lock_Count + 1;
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
--            Lock_State.Unlock;
         State_Lock_Count := State_Lock_Count - 1;
         Log_Here_Non_Locking("out", Debug_Trace);
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
         Log_Here_Non_Locking("in", Debug_Trace);
         State_Lock_Count := State_Lock_Count + 1;
--            Lock_State.Lock;
--Log_Here_Non_Locking;
         Find_Task (Task_Index);
--Log_Here_Non_Locking;
         declare
            Task_Entry           : Task_Type renames
                                    Tasks (Task_Index);
         begin
--               T (Debug_Trace, "in enable " & Enable'img &
----                " Options_Completed " & Options_Completed'img &
--                  " context " & Context'img &
--                  " level" & Task_Entry.Level'img & Quote (" text", Text) &
--                  " where " & Where & " who " & Who);
            if    Enable then
--                   (Trace_Preoptions_Complete and not Options_Completed) then
               case Context is

                  when Report_Exception =>
                     Ada_Lib.Exception_Occured := True;
--Log_Here_Non_Locking;
                     Output_File.Output (
                        "-------------------- exception ----------------" & LF);

                  when Increment =>
                     Task_Entry.Level := Task_Entry.Level + 1;
                     Global_Context_Level := Task_Entry.Level;

                  when others =>
                     null;
--Log_Here_Non_Locking;

               end case;

--Log_Here_Non_Locking;
               Format_Output (Output_File, Text, Where, Who, Task_Entry, True);
--Log_Here_Non_Locking;
               case Context is

                  when Decrement =>
                     Global_Context_Level := Task_Entry.Level;
--Log_Here_Non_Locking;

                  when Report_Exception =>
                     Output_File.Output (
                        "-----------------------------------------------" & LF);

                  when others =>
--                      T (Debug_Trace, "out enable " & Enable'img &
--                         " context " & Context'img &
--                         " level" & Task_Entry.Level'img & Quote (" text", Text));
--                        Lock_State.Unlock;
                     State_Lock_Count := State_Lock_Count + 1;
                     return;

               end case;

--Log_Here_Non_Locking;
               if Task_Entry.Level = 0 then
                  Output_File.Output ("missing log in from " &
                     Where & ":" & Who & LF);
               else
                  Task_Entry.Level := Task_Entry.Level - 1;
               end if;
            end if;
--             T (Debug_Trace, "out enable " & Enable'img & " context " & Context'img &
--                " level" & Task_Entry.Level'img & Quote (" text", Text));
         end;
--            Lock_State.Unlock;
         State_Lock_Count := State_Lock_Count - 1;
         Log_Here_Non_Locking("out", Debug_Trace);
      end Put;

      ------------------------------------------------------------------
      procedure Trace_Message_Exception (
         Fault       : in     Ada.Exceptions.Exception_Occurrence;
         Message     : in     String;
         From        : in     String;
         Who         : in     String) is
      -------------------------------------------------------------------

         Task_Index              : Task_Index_Type;

      begin
         State_Lock_Count := State_Lock_Count + 1;
--Log_Here_Non_Locking("in");
--            Lock_State.Lock;
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
         State_Lock_Count := State_Lock_Count - 1;
--            Lock_State.Unlock;
--Log_Here_Non_Locking("out");

      exception

         when Fault: others =>
            Output_File.Output  (Ada.Exceptions.Exception_Name (Fault) &
               "Exception message:" & Ada.Exceptions.Exception_Message (Fault));
            State_Lock_Count := State_Lock_Count - 1;
            Ada_Lib.OS.Immediate_Halt(Ada_Lib.OS.Exception_Exit);
      end Trace_Message_Exception;

   end Protected_State_Type;

   ---------------------------------------------------------------
   function Test (
      Which                : in   String;
      Priority             : in   Priority_Type := Priority_Type'first;
      From                 : in   String := Here
   ) return Boolean is
   ---------------------------------------------------------------

      Result   : constant Boolean := Integer (Priority_Type'pos (Priority)) = Trace_Value;

   begin
      Log_Here_Non_Locking ("from " & From & " which " & Which &
         " priority " & Priority'img &
         " result " & (
            if Result then
               "true"
            else
               "false"),
         Debug_Trace);
      return Result;
   end Test;

   ---------------------------------------------------------------
   procedure Set (
      Which                : in   String;
      Priority             : in   Priority_Type := Priority_Type'first) is
   pragma Unreferenced (Which, Priority);
   ---------------------------------------------------------------

   begin
not_implemented;
   end Set;

   ---------------------------------------------------------------
   procedure Set (
      Options              : in   String) is
   pragma Unreferenced (Options);
   ---------------------------------------------------------------

   begin
not_implemented;
   end Set;

   ------------------------------------------------------------
   function Trace_Pre_Post (
      Debug       : in     Boolean
   ) return Boolean is
   ------------------------------------------------------------

   begin
      return Debug or else
             Trace_Pre_Post_Conditions or else
             Trace_Pre_Post_False;
   end Trace_Pre_Post;

   ------------------------------------------------------------
   procedure Unlocked_Put (
      Enable   : in     Boolean;
      Context  : in     Context_Type;
      Text     : in     String;
      Where    : in     String;
      Who      : in     String) is
   ------------------------------------------------------------

      Task_Index              : Task_Index_Type;

   begin
      Log_Here_Non_Locking("in enable " & Enable'img &
         " context " & Context'img &
         " text '" & Text &
         " ' where " & Where &
         " who " & Who, Debug_Trace);
      if Enable then
         State_Lock_Count := State_Lock_Count + 1;
         Protected_State.Find_Task (Task_Index);
         declare
            Task_Entry           : Task_Access := Null;

         begin
            Protected_State.Get_Task (Task_Index, Task_Entry);
            case Context is

               when Report_Exception =>
                  Ada_Lib.Exception_Occured := True;
                  Output_File.Output (
                     "-------------------- exception ----------------" & LF);

               when Increment =>
                  Task_Entry.Level := Task_Entry.Level + 1;
                  Global_Context_Level := Task_Entry.Level;

               when others =>
                  null;

            end case;

            Format_Output (Output_File, Text, Where, Who, Task_Entry.all, True);
            case Context is

               when Decrement =>
                  Global_Context_Level := Task_Entry.Level;

               when Report_Exception =>
                  Output_File.Output (
                     "-----------------------------------------------" & LF);

               when others =>
                  State_Lock_Count := State_Lock_Count + 1;
                  return;

            end case;

            if Task_Entry.Level = 0 then
               Output_File.Output ("missing log in from " &
                  Where & ":" & Who & LF);
            else
               Task_Entry.Level := Task_Entry.Level - 1;
            end if;
         end;
         State_Lock_Count := State_Lock_Count - 1;
      end if;
      Log_Here_Non_Locking("out", Debug_Trace);
   end Unlocked_Put;

   begin
--Log_Here_Non_Locking (here);
--Debug_All := True;
--Debug_Trace := True;
-- := True;
--Elaborate := True;
--Trace_Conversions := True;
--Trace_Options := True;
--Trace_Pre_Post_False := True;
--Trace_Set_Up_Tear_Down := True;
--Trace_Tests := True;
-- Include_Hundreds := True;
-- Include_Program := True;
-- Include_Task := True;
-- Include_Time := True;
-- Indent_Trace := True;
--Log_Here_Non_Locking("elaborate Debug_Trace " & Debug_Trace'img & " Elaborate " & Elaborate'img & " Trace_Tests " & Trace_Tests'img);
   Log_Here_Non_Locking("elaborate " &
      " Debug_Trace " & Debug_Trace'img &
      " Elaborate " & Elaborate'img &
      " Trace_Tests " & Trace_Tests'img,
      Debug_Trace or Elaborate or Trace_Tests);
--    "start time " & Time.Image (Time.Get_Start_Time) &
--    " debug trace " & Debug_Trace'img &
--    " elaborate " & Elaborate'img &
--    " trace options " & Trace_Options'img &
--    " trace tests " & Trace_Tests'img);
--put_line ("clock" & Ada.Calendar.Clock'img);
--Put_Line("Formatted: " &
--    Ada.Calendar.Formatting.Image(Start_Time));
--Log_Here_Non_Locking;
end Ada_Lib.Trace;
