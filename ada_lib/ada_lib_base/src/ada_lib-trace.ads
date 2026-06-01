--  Package that provides basic tracing facilities.

with Ada.Tags;
--with Ada.Calendar;
with Ada.Exceptions;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada_Lib.Strings;
with Ada_Lib.Trace_Options_Package;
with GNAT.Source_Info;
with System;

package Ada_Lib.Trace is

   Recursive_Failure             : exception;
   Bad_Lock_State                : exception;
   Deadlock                      : exception;

   Lowest_Level                  : constant := 0;
   Undefined_Level               : constant := -1;

   type Dump_Width_Type          is (Width_8, Width_16, Width_32, Width_64);

   type Priority_Type            is range 0 .. 5;
   subtype Level_Type            is Integer range Undefined_Level .. Integer'last;
   type Task_Data_Type           is record
      Buffer                     : Ada.Strings.Unbounded.Unbounded_String;
      Last_level                 : Level_Type := Lowest_Level;
      Priority                   : Level_Type := Lowest_Level;
      Locked                     : Boolean := False;
      Task_Name                  : Ada.Strings.Unbounded.Unbounded_String;
   end record;

   Absolute                      : Boolean  renames
         Ada_Lib.Trace_Options_Package.Absolute;
   Ada_Lib_Lib_Verbose           : Boolean  renames
         Ada_Lib.Trace_Options_Package.Ada_Lib_Lib_Verbose;
   Ada_Lib_Trace_Trace           : Boolean  renames
         Ada_Lib.Trace_Options_Package.Ada_Lib_Trace_Trace;
   Debug_All                     : Boolean  renames
         Ada_Lib.Trace_Options_Package.Debug_All;
   Debug_Trace                   : Boolean  renames
         Ada_Lib.Trace_Options_Package.Debug_Trace;
   Detail                        : Boolean  renames
         Ada_Lib.Trace_Options_Package.Detail;
   Do_Trace_Checks               : Boolean  renames
         Ada_Lib.Trace_Options_Package.Do_Trace_Checks;
   Elaborate                     : Boolean  renames
         Ada_Lib.Trace_Options_Package.Elaborate;
   Include_Hundreds              : Boolean  renames
         Ada_Lib.Trace_Options_Package.Include_Hundreds;
   Include_Program               : Boolean  renames
         Ada_Lib.Trace_Options_Package.Include_Program;
   Indent_Trace                  : Boolean  renames
         Ada_Lib.Trace_Options_Package.Indent_Trace;
   Inhibit_Trace                 : Boolean  renames
         Ada_Lib.Trace_Options_Package.Inhibit_Trace;
   Pause_Flag                    : Boolean  renames
         Ada_Lib.Trace_Options_Package.Pause_Flag;
   Test_Condition                : Boolean  renames
         Ada_Lib.Trace_Options_Package.Test_Condition;
   Trace_Conversions             : Boolean  renames
         Ada_Lib.Trace_Options_Package.Trace_Conversions;
   Trace_Exceptions              : Boolean  renames
         Ada_Lib.Trace_Options_Package.Trace_Exceptions;
   Trace_Levels                  : Boolean  renames
         Ada_Lib.Trace_Options_Package.Trace_Levels;
   Trace_Options                 : Boolean  renames
         Ada_Lib.Trace_Options_Package.Trace_Options;
   Trace_Pre_Post_Conditions     : Boolean  renames
         Ada_Lib.Trace_Options_Package.Trace_Pre_Post_Conditions;
   Trace_Pre_Post_False          : Boolean  renames
         Ada_Lib.Trace_Options_Package.Trace_Pre_Post_False;
   Trace_Set_Up_Tear_Down        : Boolean  renames
         Ada_Lib.Trace_Options_Package.Trace_Set_Up_Tear_Down;
   Trace_Tag_History                 : Boolean  renames
         Ada_Lib.Trace_Options_Package.Trace_Exceptions;
   Trace_Tests                   : Boolean  renames
         Ada_Lib.Trace_Options_Package.Trace_Tests;
   Trace_Value                   : Integer := 0;
   Off                           : constant Priority_Type := Priority_Type'first;
   Low                           : constant Priority_Type := Off + 1;
   High                          : constant Priority_Type := Priority_Type'last;
   Medium                        : constant Priority_Type := (Low + High) / 2;

   function Ask_Pause (
      Manual                     : in     Boolean;
      Prompt                     : in     String
   ) return Boolean;

   procedure Dump (
      Address                 : in     System.Address;
      Length                  : in     Natural;          -- in bytes
      Width                   : in     Positive;         -- line to print
      Dump_Width              : in     Dump_Width_Type;  -- format
      Description             : in     String;
      From                    : in     String);

   function Exception_Info (
      Fault       : in   Ada.Exceptions.Exception_Occurrence;
      Message     : in     String := "";
      Whom        : in     String := GNAT.Source_Info.Enclosing_Entity;
      Where       : in     String := GNAT.Source_Info.Source_Location
   ) return String;

   function Format (
      Seconds              : in   Integer;
      Show_Days            : in   Boolean := False
   ) return String;

   function Here
   return String renames GNAT.Source_Info.Source_Location;

   function Who
   return String renames GNAT.Source_Info.Enclosing_Entity;

   function Line return Positive renames GNAT.Source_Info.Line;

   procedure Log (
      Enable      : in     Boolean := True;
      Where       : in     String := GNAT.Source_Info.Source_Location;
      Message     : in     String := "");

   -- use before raising an exception when not in an exception handler
   -- and in a routine that has a log_in
   procedure Log_Exception (
      Enable      : in     Boolean := True;
      Message     : in     String := "";
      Where       : in     String := GNAT.Source_Info.Source_Location;
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity);

   -- use before raising an exception when in an exception handler
   -- and in a routine that has a log_in
   procedure Log_Exception (
      Enable      : in     Boolean := True;
      Fault       : in     Ada.Exceptions.Exception_Occurrence;
      Message     : in     String := "";
      Where       : in     String := GNAT.Source_Info.Source_Location;
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity);

   procedure Log_Here (
      Enable      : in     Boolean;
      Message     : in     String := "";
      Where       : in     String := GNAT.Source_Info.Source_Location;
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity);

   procedure Log_Here (
      Message     : in     String := "";
      Where       : in     String := GNAT.Source_Info.Source_Location;
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity);

   function Log_Here (
      Result      : in     Boolean;
      Enable      : in     Boolean := True;
      Message     : in     String := "";
      Where       : in     String := GNAT.Source_Info.Source_Location;
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity
   ) return Boolean;

   procedure Log_Here_Non_Locking (
      Message     : in     String := "";
      Enable      : in     Boolean := True;
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity;
      From        : in     String := GNAT.Source_Info.Source_Location);

   procedure Log_In (
      Enable      : in     Boolean := True;
      Message     : in     String := "";
      Where       : in     String := GNAT.Source_Info.Source_Location;
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity);

   procedure Log_In_Checked (
      Recursed : in out Boolean;
      Enable   : in     Boolean := True;
      Message  : in     String := "";
      Where    : in     String := GNAT.Source_Info.Source_Location;
      Who      : in     String := GNAT.Source_Info.Enclosing_Entity);

   procedure Log_Out (
      Enable      : in     Boolean := True;
      Message     : in     String := "";
      Where       : in     String := GNAT.Source_Info.Source_Location;
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity);

   function Log_Out (
      Result      : in     Boolean;
      Enable      : in     Boolean := True;
      Message     : in     String := "";
      Where       : in     String := GNAT.Source_Info.Source_Location;
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity
   ) return Boolean;

   procedure Log_Out_Checked (
      Recursed : in out Boolean;
      Enable   : in     Boolean;
      Message  : in     String := "";
      Where    : in     String := GNAT.Source_Info.Source_Location;
      Who      : in     String := GNAT.Source_Info.Enclosing_Entity);

   function Log_Out_Checked (
      Recursed : in out Boolean;
      Result   : in     Boolean;
      Enable   : in     Boolean;
      Message  : in     String := "";
      Where    : in     String := GNAT.Source_Info.Source_Location;
      Who      : in     String := GNAT.Source_Info.Enclosing_Entity
   ) return Boolean;

   -- aborts after printing message
   procedure Not_Implemented (
      Why         : in     String := "";
      Here        : in     String := GNAT.Source_Info.Source_Location;
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity);

   procedure Override_Level (
      Level       : in     Level_Type);

   function Pad (
      Source      : in   String
   ) return String;

   procedure Pause (
      Prompt      : in     String := "";
      From        : in     String := Here;
      Trace       : in    Boolean := False);

   procedure Pause (
      Condition   : in     Boolean;
      Prompt      : in     String := "";
      From        : in     String := Here;
      Trace       : in    Boolean := False);

   procedure Pause_On_Flag (
      Prompt      : in     String;
      From        : in     String := Here;
      Trace       : in     Boolean := False);

   procedure Set_Check_Address (
      Address              : in     System.Address);

-- procedure Set_Options_Completed;

   procedure T (
      Enable      : in     Boolean := True;
      What        : in     String := "";
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity;
      Where       : in     String :=  GNAT.Source_Info.Source_Location);

   procedure Tag_History (
      Variable    : in     String;
      Tag_Value   : in     Ada.Tags.Tag;
      From        : in     String := GNAT.Source_Info.
                                             Source_Location);

   procedure Tag_History (
      Enable      : in     Boolean;
      Variable    : in     String;
      Tag_Value   : in     Ada.Tags.Tag;
      From        : in     String := GNAT.Source_Info.
                                             Source_Location);
   function Tag_Name (
      Variable    : in     String;
      Tag_Value   : in     Ada.Tags.Tag
   ) return String;

   procedure Trace_Exception (
      Debug       : in   Boolean;
      Fault       : in   Ada.Exceptions.Exception_Occurrence;
      Where       : in   String := GNAT.Source_Info.Source_Location;
      Who         : in   String := GNAT.Source_Info.Enclosing_Entity);

   procedure Trace_Exception (
      Fault       : in   Ada.Exceptions.Exception_Occurrence;
      Where       : in   String := GNAT.Source_Info.Source_Location;
      Who         : in   String := GNAT.Source_Info.Enclosing_Entity);

   procedure Trace_Message_Exception (
      Debug       : in   Boolean;
      Fault       : in   Ada.Exceptions.Exception_Occurrence;
      Message     : in   String;
      Where       : in   String := GNAT.Source_Info.Source_Location;
      Who         : in   String := GNAT.Source_Info.Enclosing_Entity);

   procedure Trace_Message_Exception (
      Fault       : in   Ada.Exceptions.Exception_Occurrence;
      Message     : in   String;
      Where       : in   String := GNAT.Source_Info.Source_Location;
      Who         : in   String := GNAT.Source_Info.Enclosing_Entity);

   function Trace_Return (
      Debug       : in     Boolean;
      Value       : in     Boolean;
      Message     : in     String := "";
      Where       : in     String := GNAT.Source_Info.Source_Location;
      Who         : in     String := GNAT.Source_Info.Enclosing_Entity
   ) return Boolean;

   function File
   return String renames GNAT.Source_Info.File;

   subtype String_Constant_Access
                                 is Ada_Lib.Strings.String_Constant_Access;

   type Traces_Type        is (
      Containers,
      None,
      Finalization
   );

   generic

      type Object_Type is tagged private;

   package Tag_Package is

      type Object_Class_Access   is access constant Object_Type'class;

      procedure Generic_Tag_History (
         Enable      : in     Boolean;
         Object      : in     Object_Class_Access;
         From        : in     String := GNAT.Source_Info.
                                                Source_Location);
   end Tag_Package;

   function Test (
      Which                : in   String;
      Priority             : in   Priority_Type := Priority_Type'first;
      From                 : in   String := Here
   ) return Boolean;
-- ) return Boolean renames Specification_Package.Test;

   procedure Set (
      Which             : in   String;
      Priority             : in   Priority_Type := Priority_Type'first);
-- ) renames Specification_Package.Set;

   procedure Set (
      Options              : in   String);
-- ) renames Specification_Package.Set;

private

   type File_Type                is abstract tagged limited null record;

   procedure Flush (
      File        : in     File_Type) is abstract;

   procedure Output (
      File        : in out File_Type;
      Data        : in     String) is abstract;

   type File_Access              is access File_Type;
   type File_Class_Access        is access all File_Type'class;

   type Default_File_Type        is new File_Type with record
      File        : Ada.Text_IO.File_Type;
   end record;

   overriding
   procedure Flush (
      File        : in     Default_File_Type);

   overriding
   procedure Output (
      File        : in out Default_File_Type;
      Data        : in     String);

   procedure Replace_Output_File (
      New_File    : in     File_Class_Access;
      Previous_File              :    out File_Class_Access);

end Ada_Lib.Trace;
