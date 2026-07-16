-- utility package for interfaceing with data base deamon

-- with Ada.Characters.Latin_1;
with Ada.Exceptions;
with Ada.Integer_Text_IO;
with Ada.Streams;
-- with Ada.Strings.Fixed;
with Ada.Text_IO; use Ada.Text_IO;
with Ada_Lib.Auto_Lock;
with Ada_Lib.Database.Connection;
with Ada_Lib.Options;
with Ada_Lib.Parser;
with Ada_Lib.OS.Run;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
--with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with Ada_Lib.Strings;

   pragma Elaborate (Ada_Lib.Parser);

package body Ada_Lib.Database is

--  use type Ada_Lib.Strings.Unlimited.String_Type;
    use type GNAT.Sockets.Stream_Access;

   function Log_Label (
      Database                      : in     Database_Type'class
   ) return String;

   Trace             : Boolean renames Options.Ada_Lib_Database.Trace;
   Trace_All         : Boolean renames Options.Ada_Lib_Database.Trace_All;
   Trace_Get_Post    : Boolean renames Options.Ada_Lib_Database.Trace_Get_Post;
   Null_Socket_Set   : GNAT.Sockets.Socket_Set_Type;

    -------------------------------------------------------------------
    overriding
    function "=" (
       Left, Right            : Name_Value_Type
    ) return Boolean is
    -------------------------------------------------------------------

    begin
       return Left.Name = Right.Name and then
              Left.Value = Right.Value and then
              Left.Tag = Right.Tag;
    end "=";

    -------------------------------------------------------------------
    function Allocate (
       Name                   : in     String;
       Index                  : in     Optional_Vector_Index_Type;
       Value                  : in     String;
       Tag                    : in     String := ""
    ) return Name_Value_Access is
    -------------------------------------------------------------------

    begin
       return new Name_Value_Type'(Create (
         Index          => Index,
         Name           => Name,
         Tag            => Tag,
         Value          => Value));
    end Allocate;

    -------------------------------------------------------------------
    function Allocate (
       Name_Value             : in     Name_Value_Type
    ) return Name_Value_Access is
    -------------------------------------------------------------------

    begin
       return new Name_Value_Type'(Name_Value);
--     return Allocate (Name_Value.Name, Name_Value.Value, Name_Value.Tag);
    end Allocate;


   ---------------------------------------------------------------------------
   procedure Close (
      Database                : in out Database_Type) is
   ---------------------------------------------------------------------------

   begin
      Log (Trace, Here, Who &
         " socket created " & Database.Socket_Created'img &
         " socket opened " & Database.Socket_Opened'img &
         " selector created " & Database.Selector_Created'img &
         " database address " & Ada_Lib.Strings.Image (Database'address) & Log_Label (Database));
      if Database.Socket_Created then
         Log (Trace_All, Here, Who & " socket address " & Ada_Lib.Strings.Image (Database.Socket'address));
      end if;

      if Database.Socket_Opened then
         Database.Socket_Opened := False;
         Log (Trace_All, Here, Who);
         GNAT.Sockets.Shutdown_Socket (Database.Socket);
      end if;

      if Database.Selector_Created then
         Database.Selector_Created := False;
         Log (Trace_All, Here, Who);
         GNAT.Sockets.Abort_Selector (Database.Selector);
         Log (Trace_All, Here, Who);
         GNAT.Sockets.Close_Selector (Database.Selector);
      end if;

      if Database.Socket_Created then
         Database.Socket_Created := False;
         Log (Trace_All, Here, Who);
         GNAT.Sockets.Close_Socket (Database.Socket);
      end if;
      Log (Trace, Here, Who);

   exception
      when Fault: GNAT.SOCKETS.SOCKET_ERROR =>
         if Trace then
            Trace_Message_Exception (Fault, Who &
               " database address " & Ada_Lib.Strings.Image (Database'address) &
               " socket address " & Ada_Lib.Strings.Image (Database.Socket'address) & Log_Label (Database));
         end if;

      when Fault: others =>
         Trace_Message_Exception (Fault, Who &
            " database address " & Ada_Lib.Strings.Image (Database'address) &
            " socket address " & Ada_Lib.Strings.Image (Database.Socket'address) & Log_Label (Database));
         raise;

   end Close;

--  -------------------------------------------------------------------
--  function Create (
--      Update_Mode              : in    Ada_Lib.Database.Updater.Update_Mode_Type;
--      Index                    : in     Optional_Vector_Index_Type
--  ) return Subscription_Attribute_Type is
--  -------------------------------------------------------------------
--
--    Result                     : Subscription_Attribute_Type :=
--                                  Subscription_Attribute_Type'(
--                                     Abstract_Subscription_Attribute.Attribute_Type with
--                                     Update_Mode             => Update_Mode);
--  begin
--     Result.Initialize (Index);
--     return Result;
--
--  end Create;
--
--  -------------------------------------------------------------------
--  function Create (
--      Name                     : in     String;
--      Update_Mode              : in    Ada_Lib.Database.Updater.Update_Mode_Type;
--      Index                    : in     Optional_Vector_Index_Type
--  ) return Named_Subscription_Attribute_Type is
--  -------------------------------------------------------------------
--
--    Subscription_Attribute    : constant Subscription_Attribute_Type :=
--                                  Create (Update_Mode, Index);
--
--  begin
--     return Named_Subscription_Attribute_Type'(
--        Subscription_Attribute with
--          Length                  => Name'length,
--          Name                    => Name);
--  end Create;
--
--  -------------------------------------------------------------------
--  function Create (
--      Update_Mode              : in    Ada_Lib.Database.Updater.Update_Mode_Type;
--      Index                    : in     Optional_Vector_Index_Type
--  ) return Named_Subscription_Attribute_Type is
--  -------------------------------------------------------------------
--
--    Subscription_Attribute    : constant Subscription_Attribute_Type :=
--                                  Create (Update_Mode, Index);
--
--  begin
--     raise Failed with "Named_Subscription_Attribute must have a name";
--
--     return Named_Subscription_Attribute_Type'(
--        Subscription_Attribute with
--          Length                  => 0,
--          Name                    => "");
--  end Create;

    -------------------------------------------------------------------
    function Create (
       Name                   : in     String;
       Index                  : in     Optional_Vector_Index_Type;
       Tag                    : in     String;
       Value                  : in     String
    ) return Name_Value_Type is
    -------------------------------------------------------------------

    begin
       Log_Here (Trace_All, Quote ("Name", Name) & " Index " & Index'img &
         Quote (" Tag", Tag) & Quote (" Value", Value));

       return Name_Value_Type'(
         Index          => Index,
         Name           => Ada_Lib.Strings.Unlimited.Coerce (Name),
         Tag            => Ada_Lib.Strings.Unlimited.Coerce (Tag),
         Value          => Ada_Lib.Strings.Unlimited.Coerce (Value));
    end Create;

    -------------------------------------------------------------------
    function DeEscape (
        Source                  : in     String
    ) return String is
    -------------------------------------------------------------------

        Result                  : String (1 .. Source'length);
        Result_Index            : Positive := Result'first;
        Source_Index            : Positive := Source'first;

    begin
        while Source_Index <= Source'last loop
            if Source (Source_Index) = '&' then -- escaped
                declare
                    Hex         : String (1 .. 6);
                    Length      : Positive;

                begin   -- create a standard Ada hex string representation
                    Hex (1 .. 2) := "16";       -- starts with base
                    Hex (3 .. 4) := Source (Source_Index + 1 .. Source_Index + 2);
                                                -- take # from source and 1st hex digit
                    if Source (Source_Index + 3) /= ';' then    -- 2 digit hex
                        Hex (5) := Source (Source_Index + 3);
                        Length := 6;
                        Source_Index := Source_Index + 5;
                    else
                        Length := 5;
                        Source_Index := Source_Index + 4;
                    end if;

                    Hex (Length) := '#';    -- add terminating #
                    Result (Result_Index) := Character'val (Integer'value (Hex (Hex'first .. Length)));
                end;
            else
                Result (Result_Index) := Source (Source_Index);
                Source_Index := Source_Index + 1;
            end if;
            Result_Index := Result_Index + 1;
        end loop;

        return Result (Result'first .. Result_Index - 1);
    end DeEscape;

    ---------------------------------------------------------------------------
    procedure Delete (  -- delete value from dbdaemon
        Database                : in out Database_Type;
        Name                    : in     String;
        Index                   : in     Optional_Vector_Index_Type;
        Timeout                 : in     Duration := Default_Post_Timeout) is
    ---------------------------------------------------------------------------

    begin
       Log_In (Trace);
       Database.Post (Name & "=--delete", Timeout);
       Log_Out (Trace);
    end Delete;

    ---------------------------------------------------------------------------
    procedure Delete_All ( -- delete all values from dbdaemon
        Database                : in out Database_Type;
        Timeout                 : in     Duration := Default_Post_Timeout) is
    ---------------------------------------------------------------------------

    begin
       Log_Here (Trace);
       Database.Post ("*=--delete", Timeout);
       Log_Out (Trace);
    end Delete_All;

    -------------------------------------------------------------------
    procedure Dump (
      Name_Value                 : in     Name_Value_Type;
      Title                      : in     String := "";
      From                       : in     String := Ada_Lib.Trace.Here) is
    -------------------------------------------------------------------

    begin
       Log_In (Trace and Detail, Name_Value.Image & " from " & From);
       Put_Line (Name_Value.To_String);
       Log_Out (Trace);
    end Dump;


    -------------------------------------------------------------------
   function Equal (
      Left, Right                : in     Name_Index_Tag_Type
   ) return Boolean is
    -------------------------------------------------------------------

   begin
      return Left.Name = Right.Name and then
             Left.Index = Right.Index and then
             Left.Tag = Right.Tag;
   end Equal;

--  -------------------------------------------------------------------
--  procedure Erase_All (
--      Database                : in out Database_Type) is
--  -------------------------------------------------------------------
--
--  begin
--     Database.Post ("/=--delete");
--  end Erase_All;

    -------------------------------------------------------------------
    function Escape (
        Source                  : in     String
    ) return String is
    -------------------------------------------------------------------

        Buffer                  : String_Type;


    begin
        if Trace then
            Log_Here ("'" & Source & "'");
        end if;

        for Index in Source'range loop
            declare
                -------------------------------------------------------
                procedure Escape (
                    Value       : in     Natural) is
                -------------------------------------------------------

                    Hex         : String (1 .. 8);
                    Started     : Boolean := False;
                begin
                    Ada.Integer_Text_IO.Put (Hex, Value, Base => 16);
                    Append (Buffer, '&');
                    for Index in Hex'range loop
                        if Hex (Index) = '#' then
                            if Started then             -- at trailing #
                                Append (Buffer, ';');
                                exit;
                            else                        -- at leading #
                                Started := True;
                            end if;
                        end if;

                        if Started then
                            Append (Buffer, Hex (Index));
                        end if;
                    end loop;
                end Escape;
                -------------------------------------------------------

                Letter          : Character renames Source (Index);
                Value           : constant Natural := Character'pos (Letter);

            begin
                case Letter is

                    when Ada.Characters.Latin_1.Space .. Ada.Characters.Latin_1.Percent_Sign |
                         Ada.Characters.Latin_1.Apostrophe .. Ada.Characters.Latin_1.Tilde =>
                        Append (Buffer, Letter);

                    when Ada.Characters.Latin_1.LF |
                         Ada.Characters.Latin_1.Ampersand =>
                        Escape (Value);

                    when others =>
                        Escape (Value);
                end case;
            end;
        end loop;

        return Buffer.Coerce;
    end Escape;

   -------------------------------------------------------------------
   overriding
   procedure Finalize (
      Database                   : in out Database_Type) is
   -------------------------------------------------------------------

   begin
      Log (Trace, Here, Who & " " & Ada_Lib.Strings.Image (Database'address) &
         " socket opened " & Database.Socket_Opened'img &
         " selector created " & Database.Selector_Created'img &
         " initialized " & Database.Initialized'img & Log_Label (Database));

      if Database.Initialized and then Database.Is_Open then
         Database.Close;
      end if;
      Log (Trace_All, Here, Who & " exit");

   exception
      when Fault: others =>
         Trace_Message_Exception (Fault, "database socket close failed" & Log_Label (Database));
         raise;

   end Finalize;

    -------------------------------------------------------------------
    procedure Flush_Input (
        Database                : in out Database_Type) is
    -------------------------------------------------------------------

        Residual                : constant String := Database.Get (0.0);

    begin
        Log (Trace_All, Here, Who & " flushed '" & Residual & "'");
    end Flush_Input;

    -------------------------------------------------------------------
    function Get (
        Database                : in out Database_Type;
        Timeout                 : in     Duration := Default_Get_Timeout
    ) return String is
    -------------------------------------------------------------------

      -------------------------------------------------------------------
      function Do_It return String is
      -------------------------------------------------------------------

         Input                   : Ada.Streams.Stream_Element_Array (1 .. 1000);
         String_Input            : String (1 .. 1000);
         for String_Input'address use Input'address ;
         Index                   : Positive := String_Input'first;

      begin
         Log_In (Trace);
         loop
             declare
                  Status  : GNAT.Sockets.Selector_Status;
                  Test_Set : GNAT.Sockets.Socket_Set_Type;

             begin
                 GNAT.Sockets.Set (Test_Set, Database.Socket);
                 GNAT.Sockets.Check_Selector (Database.Selector,
                     Test_Set, Null_Socket_Set, Status, Timeout);
                 Log (Trace_All, Here, Who & " status " & Status'img);
                 case Status is

                     when GNAT.Sockets.Completed =>
                         if   GNAT.Sockets.Is_Empty (Test_Set) or else
                              not GNAT.Sockets.Is_Set (Test_Set, Database.Socket) then
                            exit;      -- no data ready
                         end if;

                         Character'Read (Database.Stream, String_Input (Index));
                         Log (Trace_All, Here, Who & " '" & String_Input (Index) & "'");

                         if String_Input (Index) = Ada.Characters.Latin_1.LF then
                            exit;
                         end if;

                         Index := Index + 1;

                     when GNAT.Sockets.Expired =>
                        Log (Trace_All, Here, Who & " timeout" & Timeout'img & " Socket_Opened " &
                           Database.Socket_Opened'img & " index" & Index'img);

                        if Timeout > 0.0 and then Database.Socket_Opened then
                           if Index = 1 then       -- no input, return null line
                              exit;
                           end if;

                           raise Timed_Out with "timeout waiting for socket read. timrout " &
                              Timeout'img;
                        else
                           exit;
                        end if;

                     when GNAT.Sockets.Aborted =>
                         raise Failed with "writing to socket failed";

                 end case;
             end;
         end loop;

         Log_Out ((Trace_Get_Post and then Index > 1) or else Trace_all, " String_Input '" &
               String_Input (String_Input'first .. Index - 1) & "' Index" & Index'img & Log_Label (Database));

         return String_Input (String_Input'first .. Index - 1);
      end Do_It;
      -------------------------------------------------------------------

   begin
      if Trace_All then
       Log_Here ("timeout" & Timeout'img & " stream " & Ada_Lib.Strings.Image (Database.Stream.all'address) & Log_Label (Database));
      end if;

      if Database.Use_Locks then
         declare
            pragma Warnings (Off, "variable ""Lock"" is not referenced");
            Lock                    : Ada_Lib.Auto_Lock.Unconditional_Type (Database.Read_Lock'unchecked_access);
            pragma Warnings (On, "variable ""Lock"" is not referenced");

         begin
            return Do_It;
         end;
      else
         return Do_It;
      end if;

   exception
      when Fault: others =>
         if Database.Socket_Opened then
            if Trace then
               Trace_Message_Exception (Fault, "database socket get failed" & Log_Label (Database));
            end if;
         end if;
         raise;

   end Get;

    -------------------------------------------------------------------
    function Get (
        Database                : in out Database_Type;
        Name                    : in     String;
        Index                   : in     Optional_Vector_Index_Type;
        Tag                     : in     String;
        Timeout                 : in     Duration := Default_Get_Timeout;
        Use_Token               : in     Boolean := False
    ) return String is
    -------------------------------------------------------------------

      -------------------------------------------------------------------
      function Do_It return String is
      -------------------------------------------------------------------

      begin
         Database.Unlocked_Post (
--             (if Use_Token then Database.Tag (Database.Tag'first ..
--             Database.Tag'first + Database.Tag_Length - 1) else "") &
               Indexed_Tagged_Name (Name, Index, Tag), Timeout);
         declare
            Result               : constant String := Database.Get (Timeout);

         begin
            Log_Here (Trace_All, Quote ("Result", Result));
            return Result;
         end;
      end Do_It;
      -------------------------------------------------------------------

    begin
      Log (Trace_All, Here, Who & " Name '" & Name & "' time out " & Timeout'img &
         " use token " & Use_Token'img & " use locks " & Database.Use_Locks'img);

      if Database.Use_Locks then
         declare
            pragma Warnings (Off, "variable ""Lock"" is not referenced");
            Lock                       : Ada_Lib.Auto_Lock.Unconditional_Type (Database.Write_Lock'unchecked_access);
            pragma Warnings (On, "variable ""Lock"" is not referenced");

         begin
            return Do_It;
         end;
      else
         return Do_It;
      end if;

    exception
      when Fault: others =>
--       Database.Write_Lock.Unlock;
         Trace_Message_Exception (Fault, "getting '" & Name & "' socket address " &
            Ada_Lib.Strings.Image (Database.Socket'address) & " database " & Ada_Lib.Strings.Image (Database'address) & Log_Label (Database));
         raise;

    end Get;

    -------------------------------------------------------------------
    function Get (
        Database                : in out Database_Type;
        Name                    : in     String;
        Index                   : in     Optional_Vector_Index_Type;
        Tag                     : in     String;
        Timeout                 : in     Duration := Default_Get_Timeout;
        Use_Token               : in     Boolean := False
   ) return Name_Value_Class_Type is
   pragma Precondition (Is_Open (Database));
    -------------------------------------------------------------------


    begin
      Log (Trace_All, Here, Who & Quote (" Name", Name) & " Index" & Index'img & " time out " & Timeout'img &
         " use token " & Use_Token'img & Log_Label (Database) & Database.Get_Tag);

       return Parse (Database.Get (Name, Index, Tag, Timeout, Use_Token));
    end Get;

   ---------------------------------------------------------------
   function Get (
        Database                : in out Database_Type;
        Timeout                 : in     Duration := Default_Get_Timeout
   ) return Name_Value_Class_Type is
   pragma Precondition (Is_Open (Database));
   ---------------------------------------------------------------

      Line                       : constant String := Get (Database, Timeout);

   begin
      Log_In (Trace_All, Quote ("Line", Line));

      if Line'length > 0 then
         return Parse (Line);
      else
         Log_Out (Trace_All);
         return Null_Name_Value;
      end if;
   end Get;

   ------------------------------------------------------------------------------
   function Get_Subscription_Field (
      File                       : in out Ada.Text_IO.File_Type;
      Allow_Null                 : in     Boolean;
      From                       : in     String := Here
   ) return String is
   ------------------------------------------------------------------------------

      Buffer                  : Ada_Lib.Strings.Unlimited.String_Type;
      Next                    : Character;
      End_Of_Line             : Boolean;

   begin
      Log_In (Trace, "from " & From);
      loop
         Look_Ahead (File, Next, End_Of_Line);
         if End_Of_Line then
            if not End_Of_File (File) then
               Skip_Line (File);
            end if;
            exit;
         end if;

         if Next = File_Seperator then
            declare
               Skip           : String (1 .. 1);

            begin
               Get (File, Skip);
            end;

            exit;
         end if;

         Get (File, Next);
         Buffer.Append (Next);
      end loop;

      Log (Trace, Here, Who & Quote (" result", Buffer));

      if Buffer.Length = 0 and then not Allow_Null then
         Log_Exception (Trace);
         raise Failed;
      end if;

      Log_Out (Trace, Quote ("result", Buffer));
      return Buffer.Coerce;
   end Get_Subscription_Field;

   -------------------------------------------------------------------
    function Get_Tag (
        Database                : in   Database_Type
   ) return String is
   -------------------------------------------------------------------

    begin
       return Database.Tag (Database.Tag'first .. Database.Tag_Length - Database.Tag'first);
   end Get_Tag;

   -------------------------------------------------------------------
   function Image (
      Name_Index_Tag             : in     Name_Index_Tag_Type
   ) return String is
   -------------------------------------------------------------------

   begin
      return Quote (Name_Index_Tag.Name.Coerce) &
         (if Name_Index_Tag.Index /= No_Vector_Index then
            "[" & Ada_Lib.Strings.Trim (Name_Index_Tag.Index'img) & "]"
         else
            ""
         ) &
         (if Name_Index_Tag.Tag.Length > 0 then " [" & Name_Index_Tag.Tag.Coerce & "]" else "");
   end Image;

   -------------------------------------------------------------------
   overriding
   function Image (
      Name_Value                 : in     Name_Value_Type
   ) return String is
   -------------------------------------------------------------------

   begin
      return Quote (Name_Value.Name.Coerce) &
         (if Name_Value.Index /= No_Vector_Index then
            "[" & Ada_Lib.Strings.Trim (Name_Value.Index'img) & "]"
         else
            ""
         ) &
         ": " & Quote (Name_Value.Value.Coerce) &
         (if Name_Value.Tag.Length > 0 then " [" & Name_Value.Tag.Coerce & "]" else "");
   end Image;

-- -------------------------------------------------------------------
-- function Image (
--    Tag                        : in     String;
--    Tag_Length                 : in     Natural
-- ) return String is
-- -------------------------------------------------------------------
--
-- begin
--    return " Tag '" & Tag (Tag'first .. Tag'first + Tag_Length - 1) & "'";
-- end Image;

    -------------------------------------------------------------------
   overriding
   procedure Initialize (
      Database                   : in out Database_Type) is
    -------------------------------------------------------------------

   begin
      -- Trace may not be initialized by run string parameters yet
      Database.Initialized := True;
   end Initialize;

   ---------------------------------------------------------------
   function Indexed_Tagged_Name (
        Name                    : in     String;
        Index                   : in     Optional_Vector_Index_Type;
        Tag                     : in     String
   ) return String is
   ---------------------------------------------------------------

   begin
      return Name & (if Index = No_Vector_Index then "" else "." & Ada_Lib.Strings.Trim (Index'img)) &
         (if Tag'Length = 0 then "" else "." & Tag);
   end Indexed_Tagged_Name;

--  ---------------------------------------------------------------------------
-- procedure Initialize (
--    Attributes              :    out Subscription_Attribute_Type;
--    Update_Mode             : in    Ada_Lib.Database.Updater.Update_Mode_Type;
--    Index                   : in     Optional_Vector_Index_Type) is
--  ---------------------------------------------------------------------------
--
-- begin
--    Abstract_Subscription_Attribute.Attribute_Type (Attributes).Initialize (Index);
--    Attributes.Update_Mode := Update_Mode;
-- end Initialize;
--
--  ---------------------------------------------------------------------------
-- procedure Initialize (
--    Attributes              :    out Named_Subscription_Attribute_Type;
--    Name                    : in     String;
--    Update_Mode             : in    Ada_Lib.Database.Updater.Update_Mode_Type;
--    Index                   : in     Optional_Vector_Index_Type) is
--  ---------------------------------------------------------------------------
--
-- begin
--    Subscription_Attribute_Type (Attributes).Initialize (Update_Mode, Index);
--    Attributes.Name := Name;
-- end Initialize;

   ---------------------------------------------------------------------------------
   procedure Initialize (
      Name_Index_Tag             :    out Name_Index_Tag_Type;
      Index                      : in     Ada_Lib.Database.Optional_Vector_Index_Type;
      Name                       : in     String;
      Tag                        : in     String) is
   ---------------------------------------------------------------------------------

   begin
      Name_Index_Tag.Index   := Index;
      Name_Index_Tag.Name    := Ada_Lib.Strings.Unlimited.Coerce (Name);
      Name_Index_Tag.Tag     := Ada_Lib.Strings.Unlimited.Coerce (Tag);
   end Initialize;

   ---------------------------------------------------------------------------------
   procedure Initialize (
      Name_Value                 :    out Name_Value_Type;
      Index                      : in     Ada_Lib.Database.Optional_Vector_Index_Type;
      Name                       : in     String;
      Tag                        : in     String;
      Value                      : in     String) is
   ---------------------------------------------------------------------------------

   begin
      Name_Value.Initialize (Index, Name, Tag);
      Name_Value.Value := Ada_Lib.Strings.Unlimited.Coerce (Value);
   end Initialize;

    ---------------------------------------------------------------------------
    function Is_Open (
        Database                : in     Database_Type
    ) return Boolean is
    ---------------------------------------------------------------------------

      Result   : constant Boolean := Database.Socket_Opened and then Database.Selector_Created;
    begin
      return Log_Here (Result,
         Trace_All,
          Ada_Lib.Strings.Image (Database'address) &
         " socket opened " & Database.Socket_Opened'img &
         " selector created " & Database.Selector_Created'img &
         " initialized " & Database.Initialized'img & Log_Label (Database));
    end Is_Open;

    ---------------------------------------------------------------------------
   function Log_Label (
      Database                  : in     Database_Type'class
   ) return String is
    ---------------------------------------------------------------------------

   begin
      return (if Database.Label.Length = 0 then
            ""
         else
            " using " & Database.Label.To_String);
   end Log_Label;

    ---------------------------------------------------------------------------
   function Name_Value (                      --
      Updater                    : in     Name_Index_Tag_Type'class
   ) return Name_Value_Type is
    ---------------------------------------------------------------------------

   begin
      return Name_Value_Type'(
         Name        => Updater.Name,
         Index       => Updater.Index,
         Tag         => Updater.Tag,
         Value       => Ada_Lib.Strings.Unlimited.Null_String);
   end Name_Value;

    ---------------------------------------------------------------------------
    function Open (
        Database                :    out Database_Type;
        Host                    : in     String := "";
                                -- use default for connecting to local host
        Port                    : in     Port_Type := Default_Port;
        Reopen                  : in     Boolean := False;
        Connection_Timeout      : in     Duration := Default_Connect_Timeout;
        Use_Locks               : in     Boolean := False;
        Label                   : in     String := ""
    ) return Boolean is
    ---------------------------------------------------------------------------

        Inet_Addr               : GNAT.Sockets.Inet_Addr_Type :=    GNAT.Sockets.Any_Inet_Addr;

    begin
        Log_In (Trace);
        Database.Label.Set (Label);
        Log (Trace, Here, Who & " Host '" & Host & "' port" & Port'img & " reopen " & Reopen'img &
         " database address " & Ada_Lib.Strings.Image (Database'address) &
         " socket address " & Ada_Lib.Strings.Image (Database.Socket'address) &
         " timeout " & Connection_Timeout'img &
         " use locks " & Use_Locks'img &
         Log_Label (Database));

        if Host'length > 0 then
            begin
                Inet_Addr := GNAT.Sockets.Addresses (GNAT.Sockets.Get_Host_By_Name (Host));

            exception
                when GNAT.Sockets.Host_Error =>
                    if Trace then
                        Put_Line ("Could not find host '" & Host & "'");
                    end if;

                    return False;
--                  Ada.Exceptions.Raise_Exception (Failed'identity,
--                      "Could not find host '" & Host & "' error=" &
--                      Ada.Exceptions.Exception_Message (Fault));

            end;
        end if;
        begin
            Database.Use_Locks := Use_Locks;
            if not Database.Socket_Created then
               GNAT.Sockets.Create_Socket (Database.Socket);
               Database.Socket_Created := True;
               Log (Trace_All, Here, Who & " socket created");
            end if;

            if not Database.Selector_Created then
               GNAT.Sockets.Create_Selector (Database.Selector);
               Database.Selector_Created := True;
               Log (Trace_All, Here, Who & " selector created");
            end if;

        exception
            when GNAT.Sockets.Socket_Error =>
                if Trace then
                    Put_Line ("could not create socket");
                end if;

                Ada.Exceptions.Raise_Exception (Failed'identity,
                    "could not create socket");

        end;

        if Reopen then
            begin
                GNAT.Sockets.Set_Socket_Option (Database.Socket,
                    GNAT.Sockets.Socket_Level, (
                        Name    => GNAT.Sockets.Reuse_Address,
                        Enabled => True));

            exception
                when GNAT.Sockets.Socket_Error =>
                    if Trace then
                        Put_Line ("could not set socket option for dbdeamon");
                    end if;

                    Ada.Exceptions.Raise_Exception (Failed'identity,
                        "could not set socket option for dbdeamon");

            end;
        end if;

        declare
            Address             : constant GNAT.Sockets.Sock_Addr_Type := (
                Addr    => Inet_Addr,
                Family  => GNAT.Sockets.Family_Inet,
                Port    => Port);
            Status              : GNAT.Sockets.Selector_Status;

        begin
            GNAT.Sockets.Connect_Socket (Database.Socket, Address,
                Connection_Timeout, Null, Status);
            Log_Here (Trace_All, "Status" & Status'img & " timeout " &
               Connection_Timeout'img);

            case Status is

                when GNAT.Sockets.Completed =>
                    Database.Stream := GNAT.Sockets.Stream (Database.Socket);
                    Database.Socket_Opened := True;

                when GNAT.Sockets.Expired =>
                    if Trace then
                        Put_Line ("timeout connecting socket for host " & Host &
                            " port" & Port'img);
                    end if;

                    Ada.Exceptions.Raise_Exception (Failed'identity,
                        "timeout connecting socket for host " & Host &
                        " port" & Port'img);

                when GNAT.Sockets.Aborted =>
                   Log (Trace, Here, Who & " connect socket aborted for host " & Host &
                      " port" & Port'img);

                    Ada.Exceptions.Raise_Exception (Failed'identity,
                        "could not connect socket for host " & Host &
                        " port" & Port'img);
            end case;

        exception
            when Fault: GNAT.Sockets.Socket_Error |
                 GNAT.Sockets.Host_Error =>
                    Trace_Message_Exception (Trace, Fault, " could not connect socket for host " & Host &
                        " port" & Port'img);

                Ada.Exceptions.Raise_Exception (Failed'identity,
                    "could not connect socket for host " & Host &
                    " port" & Port'img);
        end;

        Log (Trace_All, Here, "Socket_Opened database address:" & Ada_Lib.Strings.Image (Database'address));
        declare      -- get a unique number to use as a tag
            ID                : constant Name_Value_Class_Type :=
                                 Database.Get ("uniqueid", No_Vector_Index, "", 0.5);

         begin
            Log_Here (Trace_All, Quote ("ID", ID.Value.Coerce));
            Database.Tag_Length := ID.Value.Length + 1;
            Database.Tag (Database.Tag'first .. Database.Tag'first  + Database.Tag_Length - 1) :=
               ID.Value.Coerce & "!";
            Log_Here (Trace_All, Database.Get_Tag);
         end;

         Log_Out (Trace and not Trace_All);
         return True;
    end Open;

   ---------------------------------------------------------------
   function Parse (
        Line                     : in     String
   ) return Name_Value_Type is
   ---------------------------------------------------------------

      Index                      : Ada_Lib.Strings.Unlimited.String_Type;
      Name                       : Ada_Lib.Strings.Unlimited.String_Type;
      Iterator                   : Ada_Lib.Parser.Iterator_Type := Ada_Lib.Parser.Initialize (
                                    Value                      => LIne,
                                    Seperators                 => "=!.",
                                    Ignore_Multiple_Seperators => False,
                                    Comment_Seperator          => No_File_Seperator,
                                    Trim_Spaces                => False,
                                    Quotes                     => "");
      Tag                        : Ada_Lib.Strings.Unlimited.String_Type;

   begin
      Log_In (Trace_All, Quote ("Line", Line));

      if Iterator.At_End then
         Log_Out (Trace_All);
         return Null_Name_Value;
      end if;

      while not Iterator.At_End loop
         declare
            Seperator               : constant Character := Iterator.Get_Seperator;

         begin
            Log_Here (Trace, Quote ("Seperator", Seperator));
            case Seperator is

               when '!' =>
                  declare
                     Value       : constant String := Iterator.Get_Value;

                  begin
                     Log_Here (Trace, Quote ("Value", Value));
                     if Value'length = 0 then
                        Log_Exception (Trace);
                        raise Invalid with "Missing tag before !";
                     end if;

                     if Tag.Length > 0 then
                        Tag := Tag & '!';
                     end if;

                     Tag := Tag & Value;
                     Log_Here (Trace, Quote ("Tag", Tag));
                  end;

               when '.' =>    -- end of name, start of index
                  Name.Set (Iterator.Get_Value);
                  Iterator.Next;

                  if Iterator.At_End then    -- no value
                     Log_Exception (Trace);
                     raise Invalid with "Missing index value";
                  end if;
                  Index.Set (Iterator.Get_Value);

                  declare
                     Seperator   : constant Character := Iterator.Get_Seperator;

                  begin
                     Log_Here (Trace, Quote ("Seperator", Seperator));
                     case Seperator is

                        when No_File_Seperator =>
                           exit;

                        when '=' =>
                           exit;

                        when others =>
                           Log_Exception (Trace_All);
                           raise Invalid with "Missing value after index. " & Quote (" Line", Line) & " at " & Here;

                     end case;
                  end;

               when '=' | No_File_Seperator =>    -- end of name, start of value
                  Name.Set (Iterator.Get_Value);
                  exit;

               when others =>
                  Log_Exception (Trace_All);
                  raise Invalid with Quote ("Unexpected seperator", Seperator);

            end case;
         end;

         Iterator.Next;
      end loop;

      if Name.Length = 0 then
         Log_Exception (Trace_All);
         raise Invalid with "No name. " & Quote (" Line", Line) & " at " & Here;
      end if;

      -- remainder is the value;

      declare
         Remainder               : constant String := Iterator.Get_Remainder;
         Seperator               : constant Character := Iterator.Get_Seperator;

      begin
         Log_Here (Trace, Quote ("Name", Name) & Quote (" Index", Index) &
            Quote (" Remainder", Remainder) & Quote (" Seperator", Seperator));

         if Remainder'length = 0 and then Seperator /= No_File_Seperator then
            Log_Exception (Trace);
            raise Invalid with Quote ("Unexpected serpator", Seperator);
         end if;

         declare
            Index_Value             : constant Optional_Vector_Index_Type := (if Index.Length = 0 then
                                          No_Vector_Index
                                       else
                                          Optional_Vector_Index_Type'Value (Index.Coerce));
            Result                  : constant Name_Value_Type := Create (
                                       Name.Coerce, Index_Value, Tag.Coerce, Remainder);
         begin
            Log_Out (Trace, Result.Image);
            return Result;
         end;
      end;

   exception
      when Fault: Invalid =>
         Trace_Exception (Trace, Fault);
         raise;

      when Fault: others =>
         Trace_Exception (Fault);
         raise;

   end Parse;

    -------------------------------------------------------------------
    procedure Post (
        Database                : in out Database_Type;
        Line                    : in     String;
        Timeout                 : in     Duration := Default_Post_Timeout) is
    -------------------------------------------------------------------

    begin
      Log_In (Trace, "Use_Locks" & Database.Use_Locks'img & Quote ("Line", Line));
      if Database.Use_Locks then
         declare
            pragma Warnings (Off, "variable ""Lock"" is not referenced");
            Lock                       : aliased Ada_Lib.Auto_Lock.Unconditional_Type (Database.Write_Lock'unchecked_access);
            pragma Warnings (On, "variable ""Lock"" is not referenced");

         begin
            Unlocked_Post (Database, Line, Timeout);
         end;
      else
         Unlocked_Post (Database, Line, Timeout);
      end if;

      Log_Out (Trace);

   exception
      when Fault: others =>
         Trace_Message_Exception (Fault, "posting '" & Line & "'" & Log_Label (Database));

   end Post;

    -------------------------------------------------------------------
    procedure Post (
        Database                : in out Database_Type;
        Name_Value              : in     Name_Value_Type'class;
        Timeout                 : in     Duration := Default_Post_Timeout) is
    -------------------------------------------------------------------

    begin
       Post (Database, Name_Value.Name.Coerce, Name_Value.Index, Name_Value.Tag.Coerce,
         Name_Value.Value.Coerce, Timeout);
    end Post;

    -------------------------------------------------------------------
    -- post a string value
    procedure Post (
        Database                : in out Database_Type;
        Name                    : in     String;
        Index                   : in     Optional_Vector_Index_Type;
        Tag                     : in     String;
        Value                   : in     String;
        Timeout                 : in     Duration := Default_Post_Timeout) is
    -------------------------------------------------------------------

        ---------------------------------------------------------------

    begin
        Log_In (Trace_All, Name & " = '" & Value & "'" & " index" & Index'img & Log_Label (Database) &
            (if Database.Stream = Null then " not open" else " stream " & Ada_Lib.Strings.Image (Database.Stream.all'address)));

        if Database.Stream = Null then
            Ada.Exceptions.Raise_Exception (Failed'identity,
                "database connection not open");
        end if;

        Post (Database, Indexed_Tagged_Name (Name, Index, Tag) & (if Value'Length = 0 then "" else "=" & Value), Timeout);
        Log_Out (Trace_All);
    end Post;

    -------------------------------------------------------------------
    -- post a boolean value
    procedure Post (
        Database                : in out Database_Type;
        Name                    : in     String;
        Index                   : in     Optional_Vector_Index_Type;
        Tag                     : in     String;
        Value                   : in     Boolean;
        Timeout                 : in     Duration := Default_Post_Timeout) is
    -------------------------------------------------------------------

    begin
        Post (Database, Name, Index, Tag, Value'img, Timeout);
    end Post;

    -------------------------------------------------------------------
    -- post a integer value
    procedure Post (
        Database                : in out Database_Type;
        Name                    : in     String;
        Index                   : in     Optional_Vector_Index_Type;
        Tag                     : in     String;
        Value                   : in     Integer;
        Timeout                 : in     Duration := Default_Post_Timeout) is
    -------------------------------------------------------------------

    begin
        Post (Database, Name, Index, Tag, Ada_Lib.Strings.Trim (Value'img), Timeout);
    end Post;

    -------------------------------------------------------------------
    procedure Post_Discrete (
        Database                : in out Database_Type;
        Name                    : in     String;
        Index                   : in     Optional_Vector_Index_Type;
        Tag                     : in     String;
        Value                   : in     Value_Type;
        Timeout                 : in     Duration := Default_Post_Timeout) is
    -------------------------------------------------------------------

    begin
        Post (Database, Name, Index, Tag, Ada_Lib.Strings.Trim (Value'img), Timeout);
    end Post_Discrete;

    ---------------------------------------------------------------------------
    procedure Set_Notify_Mode (
        Database                : in out Database_Type;
        Notify_Mode             : in     Notify_Mode_Type) is
    ---------------------------------------------------------------------------

        Table                   : constant array (Notify_Mode_Type) of Natural := (
            Normal_Mode => 0,
            ID_Mode     => 1);

    begin
        Post (Database, "notifymode", No_Vector_Index, "", Table (Notify_Mode));
    end Set_Notify_Mode;

--  ---------------------------------------------------------------------------
--  procedure Set_Trace (
--      Value                   : in     Boolean;
--      Both                    : in     Boolean := False) is
--  ---------------------------------------------------------------------------
--
--  begin
--      Trace := Value;
--
--      if Both then
--         Trace_All := Value;
--         Ada_Lib.Database.Connection.Debug := True;
--      end if;
--      Log (Trace, Here, Who & " " & Trace'img & " both " & Both'img);
--  end Set_Trace;

    -------------------------------------------------------------------
    procedure Store (
        Name_Index_Tag           : in     Name_Index_Tag_Type;
        File                     : in out Ada.Text_IO.File_Type) is
    -------------------------------------------------------------------

    begin
       Log_In (Trace, Name_Index_Tag.Image);
       Put (File, Name_Index_Tag.Name.Coerce & File_Seperator & Ada_Lib.Strings.Trim (Name_Index_Tag.Index'img) &
         File_Seperator & Name_Index_Tag.Tag.Coerce);
      Log_Out (Trace);
    end Store;

    -------------------------------------------------------------------
   overriding
    procedure Store (
        Name_Value               : in     Name_Value_Type;
        File                     : in out Ada.Text_IO.File_Type) is
    -------------------------------------------------------------------

    begin
       Log_In (Trace, Name_Value.Image);
       Name_Index_Tag_Type (Name_Value).Store (File);
       Put (File, File_Seperator & Name_Value.Value.Coerce);
       Log_Out (Trace);
    end Store;

    -------------------------------------------------------------------
    function To_String (
       Name_Value                : in     Name_Value_Type
    ) return String is
    -------------------------------------------------------------------

    begin
       return Quote ("Name", Name_Value.Name) & "Index" & Name_Value.Index'img &
         Quote (" Tag", Name_Value.Tag) & Quote (" Value", Name_Value.Value);
    end To_String;

     ---------------------------------------------------------------
     procedure Trace_Clear is
     ---------------------------------------------------------------

     begin
         Trace := False;
         Trace_All := False;
         Ada_Lib.Database.Connection.Debug := False;
         Ada_Lib.OS.Run.Debug := False;
     end Trace_Clear;

     ---------------------------------------------------------------
     procedure Unlocked_Post (
         Database                   : in out Database_Type;
         Line                       : in     String;
         Timeout                    : in     Duration) is
     ---------------------------------------------------------------

     begin
        if Trace_Get_Post then
            Log_Here (  --" stream " & Ada_Lib.Strings.Image (Database.Stream.all'address) &
               -- " socket " & Ada_Lib.Strings.Image (Database.Socket'address) & Database.Get_Tag &
               " line '" & Line & "' " & Log_Label (Database));
               -- " timeout " & Timeout'img);
        end if;

         if Timeout = Wait_For_Ever then
             Log (Trace_All, Here, Who);
             String'Write (Database.Stream, Line & Ada.Characters.Latin_1.LF);
         else
             for Index in Line'first .. Line'last + 1 loop    -- do LF in loop
                 if Trace_All then
                     Log_Here ("Index" & Index'img &
                         (if Index <= Line'last then " '" & Line (Index) & "'" else " CR"));
                 end if;

                 Character'Write (Database.Stream, (if Index <= Line'last then
                         Line (index)
                      else
                         Ada.Characters.Latin_1.LF));
             end loop;
         end if;

         Log (Trace_All, Here, Who & " exit");

    exception
        when Fault: others =>
            declare
                Message         : constant String :=
                                    Ada.Exceptions.Exception_Message (Fault);

            begin
                if Trace then
                    Log_Here (Ada.Exceptions.Exception_Name (Fault) &
                        " " & Message);
                end if;

                Ada.Exceptions.Raise_Exception (Failed'identity,
                    "Write to database socket " & Ada_Lib.Strings.Image (Database.Socket'address) &
                    " failed with: '" & Message & "'");
            end;
    end Unlocked_Post;
    -------------------------------------------------------------------

--    package body Abstract_Subscription_Attribute is
--
--      ---------------------------------------------------------------
--      function Index (
--         Attributes              : in     Attribute_Type
--      ) return Optional_Vector_Index_Type is
--      ---------------------------------------------------------------
--
--      begin
--         return Attributes.Index;
--      end Index;
--
----    ---------------------------------------------------------------
----     procedure Initialize (
----       Attributes              :    out Attribute_Type;
----       Index                   : in     Optional_Vector_Index_Type) is
----    ---------------------------------------------------------------
----
----     begin
----        Attributes.Id := Next_Subscription_Id;
----        Attributes.Index := Index;
----        Next_Subscription_Id := Next_Subscription_Id + 1;
----     end Initialize;
--
--    end Abstract_Subscription_Attribute;

begin
--Elaborate := True;
-- Trace_All := True;
   Log_Here (Elaborate or Trace_All or Trace);
end Ada_Lib.Database;

