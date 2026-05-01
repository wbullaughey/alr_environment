with Ada.Calendar;
with Ada.Containers.Indefinite_Hashed_Maps;
with Ada.Strings.Hash;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Unchecked_Deallocation;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with System.Storage_Elements;

package body Ada_Lib.Trace_Tasks is

   use type Ada.Calendar.Time;
   use type System.Address;
   use type System.Storage_Elements.Storage_Offset;

   type Element_Type (
         ID_Length               : Positive;
         Description_Length      : Positive;
         From_Length             : Positive) is record
      Description                : String (1 .. Description_Length);
      From                       : String (1 .. From_Length);
      Gateway_Name               : Ada_Lib.Strings.Unlimited.String_Type;
      Gateway_Line_Number        : Positive;
      Main_Task                  : Boolean;  -- not expected to terminate
      Task_ID                    : String (1 .. ID_Length);
   end record;

   type Element_Access           is access Element_Type;

   procedure Free is new Ada.Unchecked_Deallocation (
        Object          => Element_Type,
        Name            => Element_Access);

   package Map_Package is new Ada.Containers.Indefinite_Hashed_Maps (
      Key_Type       => String,
      Element_Type   => Element_Access,
      Hash           => Ada.Strings.Hash,
      Equivalent_Keys=> "=");

   protected Map is
      function All_Stopped return Boolean ;

      procedure Gateway_Enter (
         Caller_Name                : in     String;
         Caller_Line_Number         : in     Positive);

      procedure Gateway_Exit;

--    function Gateway_Open
--    return Boolean;

      procedure Report;

      procedure Start (
         Description                : in     String;
         From                       : in     String);

      procedure Stop (
         Task_ID                    : in     Ada.Task_Identification.Task_ID);

   private
      Map                        : Map_Package.Map;

   end Map;

   ---------------------------------------------------------------
   function All_Stopped return Boolean is
   ---------------------------------------------------------------

   begin
      return Map.All_Stopped;
   end All_Stopped;

   ---------------------------------------------------------------
   procedure Report is
   ---------------------------------------------------------------

   begin
      Log_In (Debug);
      declare
         Timeout                 : constant Ada.Calendar.Time := Ada.Calendar.Clock + 5.0;

      begin
         while Ada.Calendar.Clock < Timeout loop   -- wait for tasks to stop
            if All_Stopped then
               exit;
            end if;
            delay 0.1;
         end loop;
         Log_Here (Debug, "all stopped " & All_Stopped'img);
         Map.Report;
      end;
      Log_Out (Debug);
   end Report;

   ---------------------------------------------------------------
   procedure Start (
      Description                : in     String := Ada_Lib.Trace.Who;
      From                       : in     String := Ada_Lib.Trace.Here) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug, "enter for '" & Description & "' from " & From);
      Map.Start (Description, From);
      Log_Out (Debug);
   end Start;

   ---------------------------------------------------------------
   procedure Stop (
      From                       : in     String := Ada_Lib.Trace.Here) is
   ---------------------------------------------------------------

   begin
      Log_In (Debug, "stoppped from " & From);
      Stop (Ada.Task_Identification.Current_Task);
      Log_Out (Debug);
   end Stop;

   ---------------------------------------------------------------
   package body Gateway is

      ------------------------------------------------------------
      procedure Enter (
         Gateway                 : in     Gateway_Type;
         Caller_Name             : in     String := Ada_Lib.Trace.Who;
         Caller_Line             : in     Positive := Line) is
      ------------------------------------------------------------

      begin
         Log_In (Debug, "entered " & Caller_Name & " from" & Caller_Line'img);
         Map.Gateway_Enter (Caller_Name, Caller_Line);
         Log_Out (Debug);
      end Enter;

      ------------------------------------------------------------
      function Enter (
         Caller_Name             : in     String := Ada_Lib.Trace.Who;
         Caller_Line             : in     Positive := Line
      ) return Gateway_Type is
      ------------------------------------------------------------

      begin
         Map.Gateway_Enter (Caller_Name, Caller_Line);

         return Gateway_Type'(Ada.Finalization.Limited_Controlled with null record);
      end Enter;

      ------------------------------------------------------------
      overriding
      procedure Finalize (
         Gateway                 : in out Gateway_Type) is
      ------------------------------------------------------------

      begin
         Map.Gateway_Exit;
      end Finalize;

   end Gateway;

   ---------------------------------------------------------------
   procedure Stop (
      Task_ID                    : in     Ada.Task_Identification.Task_ID) is
   ---------------------------------------------------------------

   begin
      Map.Stop (Task_Id);
   end Stop;

   ---------------------------------------------------------------
   protected body Map is


      ---------------------------------------------------------------
      function All_Stopped return Boolean is
      ---------------------------------------------------------------

      begin
         declare
            Result      : constant Boolean := Map.Is_Empty;

         begin
            return Result;
         end;

      exception
         when Fault: others =>
            Trace_Message_Exception (Fault, "all stopped");
            raise;
      end All_Stopped;

      ---------------------------------------------------------------
      procedure Gateway_Enter (
         Caller_Name                : in     String;
         Caller_Line_Number         : in     Positive) is
      ---------------------------------------------------------------

         ID                         : constant String := Ada.Task_Identification.Image (
                                       Ada.Task_Identification.Current_Task);
         Cursor                     : constant Map_Package.Cursor := Map.Find (Id);

      begin
         Log_In (Debug, "entered " & Caller_Name & " from" & Caller_Line_Number'img);

         if Map_Package.Has_Element (Cursor) then
            declare
               Reference            :  constant Map_Package.Reference_Type :=
                                       Map.Reference (Cursor);

            begin
               if Reference.Gateway_Name.Length /= 0 then
                  Log_Exception (Debug);
                  raise Trace_Failure with "Server already entered with " &
                     Reference.Gateway_Name.Coerce & " line" & Reference.Gateway_Line_Number'img;
               end if;

               Reference.Gateway_Name.Set (Caller_Name);
               Reference.Gateway_Line_Number := Caller_Line_Number;
            end;
         else
            Log_Exception (Debug);
            raise Trace_Failure with Quote ("task id ", Id) & " does not exist for gateway enter " &
               Caller_Name & " line number" & Caller_Line_Number'img;
         end if;
         Log_Out (Debug);
      end Gateway_Enter;

      ---------------------------------------------------------------
      procedure Gateway_Exit is
      ---------------------------------------------------------------

         ID                         : constant String := Ada.Task_Identification.Image (
                                       Ada.Task_Identification.Current_Task);
         Reference                  :  constant Map_Package.Reference_Type := Map.Reference (Map.Find (Id));

      begin
         Log_In (Debug, "clear gateway for " & Reference.Gateway_Name.Coerce);
         Reference.Gateway_Name := Ada_Lib.Strings.Unlimited.Null_String;
         Log_Out (Debug);
      end Gateway_Exit;

--    ---------------------------------------------------------------
--    function Gateway_Open
--    return Boolean is
--    ---------------------------------------------------------------
--
--       ID                         : constant String := Ada.Task_Identification.Image (
--                                     Ada.Task_Identification.Current_Task);
--
--    begin
--       return Map.Constant_Reference (Map.Find (Id)).Gateway_Name.Length = 0;
--    end Gateway_Open;

      ---------------------------------------------------------------
      procedure Report is
      ---------------------------------------------------------------

         First_Task                 : Boolean := True;

         ------------------------------------------------------------
         procedure Process (
            Cursor                  : in     Map_Package.Cursor) is
         ------------------------------------------------------------

            Element     : constant Element_Access :=
                           Map_Package.Element (Cursor);
            Description : constant String :=
                           Quote ("description", Element.Description) &
                           " from " & Element.From &
                           " task id " & Element.Task_Id;
         begin
            Log_Here (Debug, "first " & First_Task'img);
            if First_Task then
               Put_Line ("tasks left running:");
               First_Task := False;
            end if;
            Log_Here (Debug, Description);
            Put_Line (Description);
         end Process;
         ------------------------------------------------------------

      begin
         Log_In (Debug);
         Map.Iterate (Process'access);
         Log_Out (Debug);

      exception
         when Fault: others =>
            Trace_Message_Exception (Fault, "reporting tasks left running");
            Log_Exception (Debug);
            raise;
      end Report;

      ---------------------------------------------------------------
      procedure Start (
         Description                : in     String;
         From                       : in     String) is
      ---------------------------------------------------------------

         ID                         : constant String := Ada.Task_Identification.Image (
                                       Ada.Task_Identification.Current_Task);
      begin
         Log_In (Debug, Quote ("Description", Description) &
            " ID " & ID & "from " & From);

         declare
            Element                    : constant Element_Access :=
                                          new Element_Type (ID'length, Description'length, From'length);

         begin
            Element.Description := Description;
            Element.From := From;
            Element.Task_Id := Id;
            Map.Insert (Id, Element);
         end;
         Log_Out (Debug);

      exception
         when Fault: others =>
            Trace_Message_Exception (Fault, Id & " '" & Description & "' '" & From & "'");
            Log_Exception (Debug);
            raise;

      end Start;

      ---------------------------------------------------------------
      procedure Stop (
         Task_ID                    : in     Ada.Task_Identification.Task_ID) is
      ---------------------------------------------------------------

         ID                         : constant String := Ada.Task_Identification.Image (Task_Id);

      begin
         Log_In (Debug, Quote ("task id", Id));
         if Map.Contains (Id) then
            declare
               Cursor               : Map_Package.Cursor := Map.Find (Id);
               Element              : Element_Access := Map_Package.Element (Cursor);
            begin
               Log_Here (Debug, Quote ("Description", Element.Description) &
                  " from " & Element.From);
               Map.Delete (Cursor);
               Free (Element);
            end;
         else
            Put_Line (Quote ("task ", Id) & " not in task list");
         end if;
         Log_Out (Debug);

      exception
         when Fault: others =>
            Trace_Message_Exception (Fault, Id);
            Log_Exception (Debug);
      end Stop;

   end Map;

end Ada_Lib.Trace_Tasks;


