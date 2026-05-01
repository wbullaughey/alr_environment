with Ada.Directories;
with Ada.Exceptions;
with Ada.IO_Exceptions;
with Ada.Strings.Fixed;
with Ada.Text_IO;
with Ada_Lib.Directory;
with Ada_Lib.Options;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
--with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Strings;
with Ada_Lib.Trace; use Ada_Lib.Trace;

package body Ada_Lib.Configuration is

   use type Ada.Directories.File_Kind;


   Trace             : Boolean renames Options.Ada_Lib_Configuration.Trace;

   ---------------------------------------------------------------
   procedure Close (
      Configuration              : in out Configuration_Type) is
   ---------------------------------------------------------------

   begin
      Log_Here (Trace, "configuration " & Ada_Lib.Strings.Image (Configuration'address));
      Table_Package.Clear (Configuration.Table);
      Configuration.Opened := False;
   end Close;

   ---------------------------------------------------------------
   function Get_Integer (
      Configuration              : in     Configuration_Type;
      Name                       : in     String
   ) return Integer is
   ---------------------------------------------------------------

   begin
      return Integer'value (Configuration.Get_String (Name));
   end Get_Integer;

   ---------------------------------------------------------------
   function Get_String (
      Configuration              : in     Configuration_Type;
      Name                    : in     String
   ) return String is
   ---------------------------------------------------------------

   begin
      Log_In (Trace, "name " & Name);

      if Table_Package.Contains (Configuration.Table, Name) then
         declare
            Result               : constant String :=
                                    Table_Package.Element (Configuration.Table,
                                       Name);
         begin
            Log_Out (Trace, Quote ("value", Result));

            return Result;
         end;
      else
         Log_Exception (Trace, Quote (" no name", Name));
         raise Failed with Quote ("Name", Name) & Quote (" not found for ",
            Configuration.Path);
      end if;

   exception
      when Fault: others =>
         Trace_Exception (Trace, Fault);
         raise;
   end Get_String;

   ---------------------------------------------------------------
   function Has (
      Configuration              : in     Configuration_Type;
      Name                       : in     String
   ) return Boolean is
   ---------------------------------------------------------------

      Result                     : constant Boolean :=
                                    Table_Package.Contains (Configuration.Table, Name);
   begin
      Log_Here (Trace, "name " & Name & " result " & Result'img);
      return Result;
   end Has;

   ---------------------------------------------------------------
   function Has_Path (
      Configuration              : in     Configuration_Type
   ) return Boolean is
   ---------------------------------------------------------------

   begin
      return Configuration.Path.Length > 0;
   end Has_Path;

   ---------------------------------------------------------------
   function Has_Value (
      Configuration              : in     Configuration_Type;
      Name                       : in     String
   ) return Boolean is
   ---------------------------------------------------------------

      Value                      : constant String := (if Has (Configuration, Name) then
                                       Get_String (Configuration, Name)
                                    else
                                       "");
      Result                     : constant Boolean := Value'length > 0;

   begin
      Log_Here (Trace, "name " & Name & Quote (" value", Value) &
         " result " & Result'img);
      return Result;
   end Has_Value;

   ---------------------------------------------------------------
   function Is_Open (
      Configuration              : in     Configuration_Type
   ) return Boolean is
   ---------------------------------------------------------------

   begin
      return Log_Here (Configuration.Opened, Trace or Trace_Pre_Post_Conditions,
         "opened " & Configuration.Opened'img &
         " configuration " & Ada_Lib.Strings.Image (Configuration'address));
   end Is_Open;

   ---------------------------------------------------------------
   procedure Load (
      Configuration              :    out Configuration_Type;
      Path                    : in     String;
      Create                  : in     Boolean) is
   ---------------------------------------------------------------

      File                    : Ada.Text_IO.File_Type;
      Full_Path               : Ada_Lib.Strings.Unlimited.String_Type;
      Line_Number             : Positive := 1;

   begin
      Full_Path := Ada_Lib.Strings.Unlimited.Coerce (
         Ada_Lib.Directory.Full_Name (Path));

      Log_In (Trace, Quote (" path ", Path) & Quote (" full path", Full_Path) &
         " create " & Create'img & " configuration " &
         Ada_Lib.Strings.Image (Configuration'address));

      if Ada.Directories.Exists (Full_Path.Coerce)  then
         Log_Here (Trace);
         if Ada.Directories.Kind (Full_Path.Coerce) /= Ada.Directories.Ordinary_File then
            Log_Here (Trace);
            Ada.Exceptions.Raise_Exception (Ada.IO_Exceptions.Use_Error'Identity);
         end if;

         Ada.Text_IO.Open (File, Ada.Text_IO.In_File, Full_Path.Coerce);
         Configuration.Path.Construct (Path);

         while not Ada.Text_IO.End_Of_File (File) loop
            declare
               Last           : Natural;
               Line           : String (1 .. 4096);
               Equal          : Natural;
               Pound          : Natural;

            begin
               Ada.Text_IO.Get_Line (File, Line, Last);
               if Last = Line'last then
                  Log_Exception (Trace, "value too long");
                  Ada.Exceptions.Raise_Exception (Constraint_Error'Identity,
                     "value too long");
               end if;

               if Last > 0 then  -- not blank line

                  Pound := Ada.Strings.Fixed.Index (Line (1 .. Last), "#");
                  if Pound = 0 then -- not a comment

                     Equal := Ada.Strings.Fixed.Index (Line (1 .. Last), "=");

                     if Equal = 0 then
                        Log_Exception (Trace, "missing equal sign line" & Line_Number'img &
                           " in " & Path);
                        Ada.Exceptions.Raise_Exception (Constraint_Error'Identity,
                           "missing equal sign line" & Line_Number'img &
                           " in " & Path);
                     end if;

                     declare
                        Name           : constant String := Line (1 .. Equal - 1);
                        Value          : constant String := Line (Equal + 1 .. Last);

                     begin
                        Log (Trace, Here, Who & " equal" & Equal'img &
                           Quote (" name", Name) &
                           Quote (" value", Value));

                        if Table_Package.Contains (Configuration.Table, Name) then
                           Log_Exception (Trace, " is already loaded");
                           raise Failed with Quote (Name) & " is already loaded";
                        end if;

                        Table_Package.Insert (Configuration.Table, Name, Value);

                     exception

                        when Constraint_Error =>
                           Log_Exception (Trace);
                           raise Failed with "could not add " &
                              Quote ("name", Name) &
                              Quote (" Value", Value) &
                              " to configuration";
                     end;
                  end if;
               end if;
            end;

            Line_Number := Line_Number + 1;
         end loop;
         Ada.Text_IO.Close (File);
         Configuration.Opened := True;

      elsif Create then
         Log (Trace, Here, Who & " create new options " & Full_Path.Coerce);
         Ada.Text_IO.Create (File, Ada.Text_IO.Out_File, Full_Path.Coerce);
         Ada.Text_IO.Close (File);
         Configuration.Path.Construct (Path);
         Configuration.Opened := True;
      else
         Log_Exception (Trace);
         Ada.Exceptions.Raise_Exception (Ada.IO_Exceptions.Name_Error'Identity);
      end if;

      Log_Out (Trace);

   exception

      when Ada.IO_Exceptions.Name_Error =>
         raise Failed with Quote ("Full_Path", Full_Path) & " does not exist";

      when Fault : others =>
         Trace_Message_Exception (Fault, "Full_Path '" & Full_Path.Coerce & "' create " & Create'img);
         Ada.Text_IO.Close (File);
         raise;
   end Load;

   ---------------------------------------------------------------
   procedure Set (
      Configuration              : in out Configuration_Type;
      Name                    : in     String;
      Value                   : in     String;
      Update                  : in     Boolean := True) is
   ---------------------------------------------------------------

   begin
      Log_In (Trace, "name " & Name & " value '" & Value &
         "' update " & Update'img);
      if Table_Package.Contains (Configuration.Table, Name) then
         Table_Package.Replace (Configuration.Table, Name, Value);
      else
         Table_Package.Insert (Configuration.Table, Name, Value);
      end if;

      if Update then
         declare
            Cursor   : Table_Package.Cursor :=
                        Table_Package.First (Configuration.Table);
            File     : Ada.Text_IO.File_Type;

         begin
            Ada.Text_IO.Open (File, Ada.Text_IO.Out_File, Configuration.Path.Coerce);
            while Table_Package.Has_Element (Cursor) loop
               Ada.Text_IO.Put_Line (File, Table_Package.Key (Cursor) & "=" &
                  Table_Package.Element (Cursor));
               Cursor := Table_Package.Next (Cursor);
            end loop;

            Ada.Text_IO.Close (File);
         end;
      end if;
      Log_Out (Trace);

   exception
      when Fault: others =>
         Trace_Exception (Trace, Fault);
         raise;
   end Set;

   ---------------------------------------------------------------
   procedure Set (
      Configuration              : in out Configuration_Type;
      Name                    : in     String;
      Value                   : in     Integer;
      Update                  : in     Boolean := True) is
   ---------------------------------------------------------------

   begin
      Log_In (Trace, "name " & Name & " value" & Value'img &
         " update " & Update'img);
      Configuration.Set (Name, Ada_Lib.Strings.Trim (Value'img), Update);
      Log_Out (Trace);

   exception
      when Fault: others =>
         Trace_Exception (Trace, Fault);
         raise;
   end Set;

   ---------------------------------------------------------------
   procedure Store (
      Configuration              :    out Configuration_Type;
      Path                       : in     String) is
   pragma Unreferenced (Configuration);
   ---------------------------------------------------------------

      File                       : Ada.Text_IO.File_Type;
      Full_Path                  : Ada_Lib.Strings.Unlimited.String_Type;

      ------------------------------------------------------------
      procedure Write_Entry (
         Cursor                  : in  Table_Package.Cursor) is
      ------------------------------------------------------------

         Element                 : constant String := Table_Package.Element (Cursor);
         Key                     : constant String := Table_Package.Key (Cursor);

      begin
         Log_Here (Trace, Quote ("Key", Key) & Quote (" value", Element));
         Ada.Text_IO.Put_Line (File, Key & "=" & Element);
      end Write_Entry;
      ------------------------------------------------------------

   begin
      Full_Path := Ada_Lib.Strings.Unlimited.Coerce (
         Ada_Lib.Directory.Full_Name (Path));

      Log_In (Trace, Quote ("path", Path) & Quote (" full path", Full_Path));

      declare
         Containing_Directory    : constant String :=
                                    Ada.Directories.Containing_Directory (
                                       Full_Path.Coerce);
         Table                   : Table_Package.Map renames
                                    Configuration.Table;
      begin
         Log_Here (Trace, Quote (" containing directory", Containing_Directory));

         if Ada.Directories.Exists (Containing_Directory)  then
            Ada.Text_IO.Create (File, Ada.Text_IO.Out_File, Full_Path.Coerce);
            Table_Package.Iterate (Table, Write_Entry'Access);
            Ada.Text_IO.Close (File);
         else
            Log_Exception (Trace);
            raise Failed with Containing_Directory &
               " does not exit. Create it and try again.";
         end if;
      end;
      Log_Out (Trace);

   exception
      when Fault: others =>
         Trace_Exception (Trace, Fault);
         raise;
   end Store;

begin
--Trace := True;
   Log_Here (Trace or Elaborate);
end Ada_Lib.Configuration;

