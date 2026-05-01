with Ada.Characters.Latin_1;
with Ada.Integer_Text_IO;
with Ada.IO_Exceptions;
with Ada.Text_IO; use Ada.Text_IO;
with Ada_Lib.OS;

-- pragma Elaborate (Ada_Lib.OS);

package body Ada_Lib.Path_Test is

   Bad_Path_File           :exception;

   type Instance_Type;

   type Instance_Access    is access Instance_Type;


   type Instance_Type (
      Entity_Length           : Natural;
      Location_Length         : Natural) is record
      Activated_Count         : Natural;
      Caller_Entity           : String (1 .. Entity_Length);
      Caller_Source_Location  : String (1 .. Location_Length);
      Caller_Instance         : Natural;
      Counter                 : Natural;
      Event_ID                : Positive;
      Kind                    : Kind_Type;
      Next_Instance           : Instance_Access;
      Reached_Criteria        : Boolean;
   end record;

   type Entity_Type (
      Entity_Length        : Natural;
      Location_Length         : Natural) is record
      Callie_Entity        : String (1 .. Entity_Length);
      Callie_Source_Location  : String (1 .. Location_Length);
      Callie_Instance         : Natural;
      ID                : Positive;
      Instances            : Instance_Access;
   end record;

   use type Ada_Lib.Strings.String_Constant_Access;

   type Entity_Access         is access Entity_Type;

   procedure Put (
      ID                : in   Positive;
      Caller_Reference     : in   Reference_Type;
      Callie_Reference     : in   Reference_Type;
      Kind              : in   Kind_Type;
      Load_State           : in   Boolean;
      Counter              : in out Natural;
      Event_ID          : in out Positive;
      Activated_Count         : in out Natural;
      Fire              :   out Boolean);

   Only_ID                 : Integer := -1;
   Criteria             : array (Kind_Type) of Natural := (others => 0);
   Entities             : array (1 .. Maximum_Entities) of Entity_Access := (others => null);
   Event_Count             : Natural := 0;
   First_Idle_Call            : Boolean := True;
   Idle_Check_Delay        : Ada_Lib.Time.Duration_Type := 0.0;
-- Idle_With_No_New_Faults_Exit_Code
--                      : constant := 0;
-- Idle_With_New_Faults_Exit_Code
--                      : constant := 99;
   Last_Session_Count         : Natural := 0;
   Idle_Check_Time            : Ada_Lib.Time.Time_Type;
   Null_Reference          : constant Reference_Type := (
      Entity_Length        => 0,
      Source_Location_Length  => 0,
      Entity               => "",
      Source_Location         => "",
      Instance          => 0);

   Session_Count           : Natural := 0;

   ---------------------------------------------------------------------------
   procedure Idle_Test is
   ---------------------------------------------------------------------------

      use type Ada_Lib.Time.Time_Type;

   begin
      if not Stub and then Idle_Check_Delay > 0.0 then
         if First_Idle_Call then
            Idle_Check_Time := Ada_Lib.Time.Now;
            Last_Session_Count := Session_Count;
            First_Idle_Call := False;
         else
            if Ada_Lib.Time.Now > Idle_Check_Time + Idle_Check_Delay then
               if Session_Count = Last_Session_Count then
                  if Session_Count = 0 then
                     Put_Line ("Idle for " & Ada_Lib.Time.Image (Idle_Check_Delay) &
                        " seconds. No new events. Terminate with completed code");
                     -- no new errors, terminate normally, don't need to save
                     Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.No_Error);
                  else
                     -- idle now but new errors recorded, save and exit
                     Idle_Exit_Save;
                     Put_Line ("Idle for " & Ada_Lib.Time.Image (Idle_Check_Delay) &
                        " seconds. " &
                        Integer'image (Session_Count - Last_Session_Count) &
                        " new events. Terminate with restart code");

                     Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.Application_Error);
                  end if;
               end if;

               Idle_Check_Time := Idle_Check_Time + Idle_Check_Delay;
            end if;
         end if;
      end if;
   end Idle_Test;

   ---------------------------------------------------------------------------
   function Image (
      Reference            : in   Reference_Type
   ) return String is
   ---------------------------------------------------------------------------

   begin
      return
         Reference.Entity &
         "=>" & Reference.Source_Location &
         " #" & Reference.Instance'img;
   end Image;

   ---------------------------------------------------------------------------
   procedure Load (
      File_Name            : in   String) is
   ---------------------------------------------------------------------------

   begin
      if not Stub then
         declare
            File        : Ada.Text_IO.File_Type;

            ---------------------------------------------------------------
            function Read_Strings
            return Reference_Type is
            ---------------------------------------------------------------

               type Line_Index   is (Entity, File_Name);

               type Line_Type is record
                  Line     : String (1 .. 256);
                  Last     : Natural;
               end record;

               Lines       : array (Line_Index) of Line_Type;

            begin
               for Line in Lines'range loop
                  Ada.Text_IO.Get_Line (File, Lines (Line).Line, Lines (Line).Last);

                  if Lines (Line).Last = 0 then
                     Ada.Exceptions.Raise_Exception (Bad_Path_File'identity, "incomplete path test file");
                  end if;
               end loop;

               return (
                  Entity         => Lines (Entity).Line (
                                 1 .. Lines (Entity).Last),
                  Entity_Length  => Lines (Entity).Last,
                  Source_Location      => Lines (File_Name).Line (
                                 1 .. Lines (File_Name).Last),
                  Source_Location_Length=> Lines (File_Name).Last,
                  Instance    => 0);
            end Read_Strings;
            ---------------------------------------------------------------

         begin
            Ada.Text_IO.Open (File, Ada.Text_IO.In_File, File_Name);

            Ada.Integer_Text_IO.Get (File, Event_Count);
            Ada.Text_IO.Skip_Line (File);

            while not Ada.Text_IO.End_Of_File (File) loop
               declare
                  Activated_Count      : Natural;
                  Below_Criteria    : Boolean;
                  Callie_Reference  : Reference_Type :=
                                    Read_Strings;
                  Caller_Reference  : Reference_Type :=
                                    Read_Strings;

                  Counter           : Natural;
                  Event_ID       : Positive;
                  ID             : Positive;
                  Kind           : Kind_Type;
                  Line           : String (1 .. 256);
                  Last           : Natural;

               begin
                  Ada.Text_IO.Get_Line (File, Line, Last);
                  if Last > 0 then
                     Kind := Kind_Type'value (Line (1 .. Last));

                     declare
                        Field       : Positive := 1;

                     begin
                        Ada.Integer_Text_IO.Get (File, ID);
                        Field := Field + 1;
                        Ada.Integer_Text_IO.Get (File, Callie_Reference.Instance);
                        Field := Field + 1;
                        Ada.Integer_Text_IO.Get (File, Caller_Reference.Instance);
                        Field := Field + 1;
                        Ada.Integer_Text_IO.Get (File, Counter);
                        Field := Field + 1;
                        Ada.Integer_Text_IO.Get (File, Event_ID);
                        Field := Field + 1;
                        Ada.Integer_Text_IO.Get (File, Activated_Count);
                        Ada.Text_IO.Skip_Line (File);

                     exception
                        when Ada.IO_Exceptions.Data_Error =>
                           Ada.Exceptions.Raise_Exception (Bad_Path_File'identity,
                              "Parse error on field" & Field'img &
                              " loading path test data file " & File_Name);

                     end;

                     if ID /= Only_ID then
                        Put (ID, Caller_Reference, Callie_Reference, Kind,
                           True, Counter, Event_ID, Activated_Count, Below_Criteria);
                     end if;
                  else
                     Ada.Exceptions.Raise_Exception (Bad_Path_File'identity,
                        "Missing kind in path test load file");
                  end if;
               end;
            end loop;

            Ada.Text_IO.Close (File);

         exception
            when Ada.Text_IO.Name_Error =>
               raise No_File;

            when Fault: Bad_Path_File =>
               Put_Line (Ada.Exceptions.Exception_Message (Fault));
               Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.Exception_Exit);

            when Fault: others =>
               Put_Line (Ada.Exceptions.Exception_Name (Fault) & " in " &
                  GNAT.Source_Info.Source_Location);
               Put_Line (Ada.Exceptions.Exception_Message (Fault));
               Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.Exception_Exit);

         end;
      end if;

   end Load;

   ---------------------------------------------------------------------------
   procedure Not_Idle is
   ---------------------------------------------------------------------------

   begin
      First_Idle_Call := True;
   end Not_Idle;

   ---------------------------------------------------------------------------
   procedure Put (
      ID                : in   Positive;
      Caller_Reference     : in   Reference_Type;
      Callie_Reference     : in   Reference_Type;
      Kind              : in   Kind_Type;
      Load_State           : in   Boolean;
      Counter              : in out Natural;
      Event_ID          : in out Positive;
      Activated_Count         : in out Natural;
      Fire              :   out Boolean) is
   ---------------------------------------------------------------------------

   begin
      if not Stub then
         for Index in Entities'range loop
            if Entities (Index) = Null then
               -- got to the end of existing references, it must be new

               if not Load_State then
                  -- call to add reference
                  Counter := 1;  -- first reference
               end if;

               Fire := Counter <= Criteria (Kind);

               if Fire then

                  if not Load_State then
                     Activated_Count := 1;
                     Event_Count := Event_Count + 1;
                     Event_ID := Event_Count;
                  end if;
               else
                  if not Load_State then
                     Activated_Count := 0;
                  end if;
               end if;

               Entities (Index) := new Entity_Type'(
                  Callie_Entity        => Callie_Reference.Entity,
                  Callie_Source_Location  => Callie_Reference.Source_Location,
                  Callie_Instance         => Callie_Reference.Instance,
                  Entity_Length        => Callie_Reference.Entity'length,
                  ID                => ID,
                  Location_Length         => Callie_Reference.Source_Location'length,
                  Instances            => new Instance_Type'(
                     Activated_Count
                              => Activated_Count,
                     Caller_Entity
                              => Caller_Reference.Entity,
                     Caller_Instance
                              => Caller_Reference.Instance,
                     Caller_Source_Location
                              => Caller_Reference.Source_Location,
                     Counter     => Counter,
                     Entity_Length  => Caller_Reference.Entity'length,
                     Event_ID => Event_ID,
                     Kind     => Kind,
                     Location_Length   => Caller_Reference.Source_Location'length,
                     Next_Instance  => null,
                     Reached_Criteria
                              => not Fire));

               return;
            else
               declare
                  Entity      : Entity_Type renames Entities (Index).all;

               begin
                  if Entity.Callie_Source_Location = Callie_Reference.Source_Location and then
                        Entity.Callie_Instance = Callie_Reference.Instance and then
                        Entity.ID = ID then
                     declare
                        Instance : Instance_Access := Entity.Instances;

                        ------------------------------------------------
                        procedure Set_Fire is
                        ------------------------------------------------

                        begin
                           Fire := Counter <= Criteria (Kind);

                           if Fire then
                              if Load_State then
                                 Instance.Activated_Count := Activated_Count;
                              else
                                 Instance.Activated_Count := Instance.Activated_Count + 1;
                                 Event_Count := Event_Count + 1;
                                 Event_ID := Event_Count;
                              end if;
                           else
                              if Load_State then
                                 Instance.Activated_Count := Activated_Count;
                              end if;

                              Instance.Reached_Criteria := True;
                           end if;
                        end Set_Fire;
                        ------------------------------------------------

                     begin
                        while Instance /= null loop
                           if (Instance.Caller_Instance = Caller_Reference.Instance and then
                                 Instance.Kind = Kind and then
                                 Instance.Caller_Source_Location'length =
                                    Caller_Reference.Source_Location'length) and then
                                 Instance.Caller_Source_Location =
                                    Caller_Reference.Source_Location then
                              Instance.Counter := Instance.Counter + 1;

                              Counter := Instance.Counter;
                              Event_ID := Instance.Event_ID;
                                 -- repeated event, use the same id

                              Set_Fire;
                              return;
                           end if;

                           Instance := Instance.Next_Instance;
                        end loop;

                        if not Load_State then
                           -- call to add reference
                           Counter := 1;  -- first reference
                        end if;

                        Instance := new Instance_Type'(
                           Activated_Count
                                    => 0,
                           Caller_Entity
                                    => Caller_Reference.Entity,
                           Caller_Instance
                                    => Caller_Reference.Instance,
                           Caller_Source_Location
                                    => Caller_Reference.Source_Location,
                           Counter     => Counter,
                           Entity_Length  => Caller_Reference.Entity'length,
                           Event_ID => Event_ID,
                           Kind     => Kind,
                           Location_Length   => Caller_Reference.Source_Location'length,
                           Next_Instance  => Entity.Instances,
                           Reached_Criteria
                                    => False);

                           Entity.Instances := Instance;
                           Set_Fire;
                           Instance.Event_ID := Event_ID;
                           return;
                     end;
                  end if;
               end;
            end if;
         end loop;

         Put_Line ("too many enities");
         Ada_Lib.OS.Immediate_Halt (Ada_Lib.OS.Application_Error);
      end if;
   end Put;

   ---------------------------------------------------------------------------
   function Reference (
      Entity               : in   String;
      Source_Location            : in   String;
      Instance          : in   Natural := 0
   ) return Reference_Type is
   ---------------------------------------------------------------------------

   begin
      if Stub then
         return Null_Reference;
      else
         return (
            Entity_Length        => Entity'length,
            Source_Location_Length  => Source_Location'length,
            Entity               => Entity,
            Source_Location         => Source_Location,
            Instance          => Instance);
      end if;
   end Reference;

   ---------------------------------------------------------------------------
   procedure Report is
   ---------------------------------------------------------------------------

   begin
      if not Stub then
         for Index in Entities'range loop
            if Entities (Index) = Null then
               -- all reported
               return;
            end if;

            declare
               Entity      : Entity_Type renames Entities (Index).all;
               Instance : Instance_Access := Entity.Instances;

            begin
               Put_Line ("Routine " & Entity.Callie_Entity &
                  " ->" & Entity.Callie_Source_Location &
                  " #" & Entity.Callie_Instance'img &
                  " ID" & Entity.ID'img & " called from:");

               while Instance /= Null loop              --
                  if Instance.Counter = 0 then          --
                     -- all reported                    --
                     exit;
                  end if;

                  Put ("   " & Instance.Caller_Entity &
                     "->" & Instance.Caller_Source_Location &
                     " #" & Instance.Caller_Instance'img &
                     " " & Instance.Kind'img &
                     " called" & Instance.Counter'img &
                     " activated" & Instance.Activated_Count'img &
                     " event" & Instance.Event_ID'img);

                  if Instance.Reached_Criteria then
                     Put (" reached criteria");
                  end if;

                  New_Line;
                  Instance := Instance.Next_Instance;
               end loop;

            end;
         end loop;
      end if;
   end Report;

   ---------------------------------------------------------------------------
   procedure Save (
      File_Name            : in   String) is
   ---------------------------------------------------------------------------

   begin
      if not Stub then
         declare
            File        : Ada.Text_IO.File_Type;

         begin
            Ada.Text_IO.Create (File, Ada.Text_IO.Out_File, File_Name);

            Put_Line (File, Event_Count'img);

            for Index in Entities'range loop
               if Entities (Index) = Null then
                  -- end of valid Entities
                  exit;
               end if;

               declare
                  Entity      : Entity_Type renames Entities (Index).all;
                  Instance : Instance_Access := Entity.Instances;

               begin
                  while Instance /= Null loop
                     Put_Line (File, Entity.Callie_Entity);
                     Put_Line (File, Entity.Callie_Source_Location);
                     Put_Line (File, Instance.Caller_Entity);
                     Put_Line (File, Instance.Caller_Source_Location);
                     Put_Line (File, Instance.Kind'img);
                     Put (File, Entity.ID'img);
                     Put (File, Entity.Callie_Instance'img);
                     Put (File, Instance.Caller_Instance'img);
                     Put (File, Instance.Counter'img);
                     Put (File, Instance.Event_ID'img);
                     Put (File, Instance.Activated_Count'img);
                     New_Line (File);

                     Instance := Instance.Next_Instance;
                  end loop;
               end;
            end loop;

            Ada.Text_IO.Close (File);
         end;
      end if;
   end Save;

   ---------------------------------------------------------------------------
   procedure Set_Criteria (
      Kind              : in   Kind_Type;
      Count             : in   Natural) is
   ---------------------------------------------------------------------------

   begin
      if not Stub then
         Criteria (Kind) := Count;
      end if;
   end Set_Criteria;

   ---------------------------------------------------------------------------
   procedure Set_Idle_Time (
      Value             : in   Ada_Lib.Time.Duration_Type) is
   ---------------------------------------------------------------------------

   begin
      Idle_Check_Delay := Value;
   end Set_Idle_Time;

   ---------------------------------------------------------------------------
   procedure Set_Only_ID (
      ID                : in   Integer) is
   ---------------------------------------------------------------------------

   begin
      Only_ID := ID;
   end Set_Only_ID;

   ---------------------------------------------------------------------------
   procedure Test (
      ID                : in   Positive;
      Caller_Reference     : in   Reference_Type;
      Callie_Reference     : in   Reference_Type;
      Kind              : in   Kind_Type;
      Fire              :   out Boolean;
      Counter              :   out Natural;
      Event_ID          :   out Positive) is
   ---------------------------------------------------------------------------

      Activated_Count         : Natural := 0;

   begin
      Event_ID := Positive'last; -- dummy value should never be used
                           -- set by Put

      if Stub or else
         -- Stub true for release version, no path test
            (  Criteria (Kind) = 0 or else
                  -- this Kind is not enabled
               (  Only_ID > 0 and then
                  -- Only ID option set
                  ID /= Only_ID)) then
                  -- not this ID
         Fire := False;
         return;
      else
         Counter := 0;  -- force it to get assigned
         Put (ID, Caller_Reference, Callie_Reference, Kind, False, Counter, Event_ID,
            Activated_Count, Fire);

         if Fire then
            Session_Count := Session_Count + 1;
         end if;
      end if;
   end Test;

   ---------------------------------------------------------------------------
   procedure Test_Exception (
      ID                : in   Positive;
      Caller_Reference     : in   Reference_Type;
      Callie_Reference     : in   Reference_Type;
      Kind              : in   Kind_Type;
      Exception_To_Throw      : in   Ada.Exceptions.Exception_Id;
      Extra_Message        : in   String := "") is
   ---------------------------------------------------------------------------

      Fire              : Boolean;
      Counter              : Natural;
      Event_ID          : Positive;

   begin
      Test (ID, Caller_Reference, Callie_Reference, Kind, Fire, Counter, Event_ID);

      if Fire then
         Ada.Exceptions.Raise_Exception (Exception_To_Throw,
            "Path Test generated exception" & Event_ID'img &
            " instance counter" & Counter'img &
            Ada.Characters.Latin_1.LF &
            "for " & Kind'img &
            " from " & Image (Callie_Reference) &
            " ID" & ID'img &
            Ada.Characters.Latin_1.LF &
            "called from " & Image (Caller_Reference) &
            " " & Extra_Message);
      end if;
   end Test_Exception;

   ---------------------------------------------------------------------------
   procedure Test_Exceptions (
      ID                : in   Positive;
      Caller_Reference     : in   Reference_Type;
      Callie_Reference     : in   Reference_Type;
      Kind              : in   Kind_Type;
      Exceptions_To_Throw     : in   Exception_Array;
      Extra_Messages       : in   Messages_Array := (
                           1 => Null)) is
   ---------------------------------------------------------------------------

   begin
      for Index in Exceptions_To_Throw'range loop
         declare
            Message        : Ada_Lib.Strings.String_Constant_Access;
            Null_Message   : aliased constant String := "";

         begin
            if Index <= Extra_Messages'last then
               Message := Extra_Messages (Index);

               if Message = Null then
                  Message := Null_Message'unchecked_access;
               end if;
            else
               Message := Null_Message'unchecked_access;
            end if;

            Test_Exception (ID, Caller_Reference, Callie_Reference,
               Kind, Exceptions_To_Throw (Index), Message.all);
         end;
      end loop;

   end Test_Exceptions;

end Ada_Lib.Path_Test;
