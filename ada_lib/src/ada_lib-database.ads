-- utility package for interfaceing with data base deamon
with Ada.Characters.Latin_1;
with Ada.Finalization;
with Ada.Text_IO;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace;
with GNAT.Sockets;
with Ada_Lib.Lock;
with Ada_Lib.Strings.Bounded;

pragma Elaborate_All (Ada_Lib.Lock);
pragma Elaborate_All (Ada_Lib.Strings.Unlimited);

package Ada_Lib.Database is

   use type GNAT.Sockets.Port_Type;

    Connection_Closed           : exception;
    Failed                      : exception;
    Invalid                     : exception;
    Timed_Out                   : exception;

    Default_Port                : constant := 2300;
    Default_Connect_Timeout     : constant Duration := 1.0;
    Default_Get_Timeout         : constant Duration := 0.0;             -- when no data return empty string
    Default_Post_Timeout        : constant Duration := 0.25;
    Local_Host_Name             : constant String := "localhost";
    Wait_For_Ever               : constant Duration := Duration'last;

    type Optional_Vector_Index_Type is range -1 .. Positive'last;
    No_Vector_Index              : constant Optional_Vector_Index_Type := Optional_Vector_Index_Type'first; -- - 1
--  Whole_Value_Index            : constant Optional_Vector_Index_Type := No_Vector_Index + 1;              -- 0
    type Updater_Result_Type is (Updated, No_Change, Update_Failed);

    subtype Vector_Index_Type is Optional_Vector_Index_Type range No_Vector_Index ..
                                 Optional_Vector_Index_Type'last;

    type Name_Index_Tag_Type is tagged record
      Name                       : Ada_Lib.Strings.Unlimited.String_Type;
      Index                      : Optional_Vector_Index_Type;
      Tag                        : Ada_Lib.Strings.Unlimited.String_Type;
    end record;

    type Name_Value_Type;

    type Name_Index_Tag_Access is access Name_Index_Tag_Type;
    type Name_Index_Tag_Class_Access is access all Name_Index_Tag_Type'class;

   function Equal (
      Left, Right                : in     Name_Index_Tag_Type
   ) return Boolean;

   function Image (
      Name_Index_Tag             : in     Name_Index_Tag_Type
   ) return String;

   procedure Initialize (
      Name_Index_Tag             :    out Name_Index_Tag_Type;
      Index                      : in     Ada_Lib.Database.Optional_Vector_Index_Type;
      Name                       : in     String;
      Tag                        : in     String);

    procedure Store (
        Name_Index_Tag           : in     Name_Index_Tag_Type;
        File                     : in out Ada.Text_IO.File_Type);

    type Name_Value_Type is new Name_Index_Tag_Type with record
      Value                      : Ada_Lib.Strings.Unlimited.String_Type;
    end record;

    subtype Name_Value_Class_Type
                                 is Name_Value_Type'class;

    type Name_Value_Access is access Name_Value_Type;
    type Name_Value_Class_Access is access Name_Value_Type'class;

   procedure Initialize (
      Name_Value                 :    out Name_Value_Type;
      Index                      : in     Ada_Lib.Database.Optional_Vector_Index_Type;
      Name                       : in     String;
      Tag                        : in     String;
      Value                      : in     String);

   function Name_Value (                      --
      Updater                    : in     Name_Index_Tag_Type'class
   ) return Name_Value_Type;

    overriding
    procedure Store (
        Name_Value               : in     Name_Value_Type;
        File                     : in out Ada.Text_IO.File_Type);

    type Database_Type          is new Ada.Finalization.Limited_Controlled
                                    with private;
    type Database_Access        is access all Database_Type;
    type Database_Class_Access  is access all Database_Type'class;

    type Notify_Mode_Type        is (Normal_Mode, ID_Mode);

    subtype Any_Port_Type        is GNAT.Sockets.Port_Type;
    Invalid_Port                 : constant Any_Port_Type := Any_Port_Type'first;
    subtype Port_Type            is GNAT.Sockets.Port_Type range Invalid_Port + 1 .. GNAT.Sockets.Port_Type'last;

    type Which_Host_Type          is (Local, Remote, No_Host, Unset);
    subtype Valid_Hosts_Type      is Which_Host_Type range Local .. Remote;

    overriding
    function "=" (
       Left, Right            : Name_Value_Type
    ) return Boolean;

    procedure Close (
        Database                : in out Database_Type)
    with pre => Is_Open (Database);

    function Create (
       Name                   : in     String;
       Index                  : in     Optional_Vector_Index_Type;
       Tag                    : in     String;
       Value                  : in     String
    ) return Name_Value_Type;

    procedure Delete (     -- delete value from dbdaemon
        Database                : in out Database_Type;
        Name                    : in     String;
        Index                   : in     Optional_Vector_Index_Type;
        Timeout                 : in     Duration := Default_Post_Timeout)
    with pre => Is_Open (Database);


    procedure Delete_All ( -- delete all values from dbdaemon
        Database                : in out Database_Type;
        Timeout                 : in     Duration := Default_Post_Timeout)
    with pre => Is_Open (Database);

    procedure Dump (
      Name_Value                 : in     Name_Value_Type;
      Title                      : in     String := "";
      From                       : in     String := Ada_Lib.Trace.Here);

    overriding
    procedure Finalize (
        Database                : in out Database_Type);

    procedure Flush_Input (
        Database                : in out Database_Type)
    with pre => Is_Open (Database);

    function Get (
        Database                : in out Database_Type;
        Timeout                 : in     Duration := Default_Get_Timeout
    ) return String
    with pre => Is_Open (Database);

    function Get (
        Database                : in out Database_Type;
        Name                    : in     String;
        Index                   : in     Optional_Vector_Index_Type;
        Tag                     : in     String;
        Timeout                 : in     Duration := Default_Get_Timeout;
        Use_Token               : in     Boolean := False
    ) return String
    with pre => Is_Open (Database);

   function Get (
        Database                : in out Database_Type;
        Timeout                 : in     Duration := Default_Get_Timeout
   ) return Name_Value_Class_Type
    with pre => Is_Open (Database);

   function Get (
        Database                : in out Database_Type;
        Name                    : in     String;
        Index                   : in     Optional_Vector_Index_Type;
        Tag                     : in     String;
        Timeout                 : in     Duration := Default_Get_Timeout;
        Use_Token               : in     Boolean := False
   ) return Name_Value_Class_Type
    with pre => Is_Open (Database);

    function Get_Tag (
        Database                : in      Database_Type
   ) return String;

   overriding
   function Image (
      Name_Value                 : in     Name_Value_Type
   ) return String;

    overriding
    procedure Initialize (
        Database                : in out Database_Type);

    function Is_Open (
        Database                : in     Database_Type
    ) return Boolean;

    function Open (
        Database                :    out Database_Type;
        Host                    : in     String   := "";
        -- use default for connecting to local host
        Port                    : in     Port_Type := Default_Port;
        Reopen                  : in     Boolean := False;
        Connection_Timeout      : in     Duration := Default_Connect_Timeout;
        Use_Locks               : in     Boolean := False;
        Label                   : in     String := ""
      ) return Boolean
        with pre => not Is_Open (Database);


    procedure Post (
        Database                : in out Database_Type;
        Line                    : in     String;
        Timeout                 : in     Duration := Default_Post_Timeout)
    with pre => Is_Open (Database);

    procedure Post (
        Database                : in out Database_Type;
        Name_Value              : in     Name_Value_Type'class;
        Timeout                 : in     Duration := Default_Post_Timeout)
    with pre => Is_Open (Database);

    -- post a string value
    procedure Post (
        Database                : in out Database_Type;
        Name                    : in     String;
        Index                   : in     Optional_Vector_Index_Type;
        Tag                     : in     String;
        Value                   : in     String;
        Timeout                 : in     Duration := Default_Post_Timeout)
    with pre => Is_Open (Database);

    -- post a boolean value
    procedure Post (
        Database                : in out Database_Type;
        Name                    : in     String;
        Index                   : in     Optional_Vector_Index_Type;
        Tag                     : in     String;
        Value                   : in     Boolean;
        Timeout                 : in     Duration := Default_Post_Timeout)
    with pre => Is_Open (Database);

    -- post a integer value
    procedure Post (
        Database                : in out Database_Type;
        Name                    : in     String;
        Index                   : in     Optional_Vector_Index_Type;
        Tag                     : in     String;
        Value                   : in     Integer;
        Timeout                 : in     Duration := Default_Post_Timeout)
    with pre => Is_Open (Database);

    generic
        type Value_Type         is ( <> );

    procedure Post_Discrete (
        Database                : in out Database_Type;
        Name                    : in     String;
        Index                   : in     Optional_Vector_Index_Type;
        Tag                     : in     String;
        Value                   : in     Value_Type;
        Timeout                 : in     Duration := Default_Post_Timeout)
    with pre => Is_Open (Database);

    procedure Set_Notify_Mode (
        Database                : in out Database_Type;
        Notify_Mode             : in     Notify_Mode_Type)
    with pre => Is_Open (Database);

    function Allocate (
       Name                   : in     String;
       Index                  : in     Optional_Vector_Index_Type;
       Value                  : in     String;
       Tag                    : in     String := ""
    ) return Name_Value_Access;

    function Allocate (
       Name_Value             : in     Name_Value_Type
    ) return Name_Value_Access;

    function DeEscape (
        Source                  : in     String
    ) return String;

    function Escape (
        Source                  : in     String
    ) return String;

   function Get_Subscription_Field (
      File                       : in out Ada.Text_IO.File_Type;
      Allow_Null                 : in     Boolean;
      From                       : in     String := Ada_Lib.Trace.Here
   ) return String;

   function Indexed_Tagged_Name (
        Name                    : in     String;
        Index                   : in     Optional_Vector_Index_Type;
        Tag                     : in     String
   ) return String;

   function Parse (
        Line                     : in     String
   ) return Name_Value_Type;

--  procedure Set_Trace (
--      Value                    : in     Boolean;
--      Both                     : in     Boolean := False);

    function To_String (
       Name_Value                : in     Name_Value_Type
    ) return String;

     procedure Trace_Clear;

    Debug_Subscribe              : aliased Boolean := False;
    File_Seperator               : constant Character := '~';
    No_File_Seperator            : constant Character :=
                                    Ada.Characters.Latin_1.NUL;
--  Null_Database_Type           : constant Database_Type;
    Null_Name_Value              : constant Name_Value_Type;
--  Trace                        : aliased Boolean := False;
--  Trace_All                    : aliased Boolean := False;

private
   procedure Unlocked_Post (                   -- does not lock database
      Database             : in out Database_Type;
      Line                 : in     String;
      Timeout              : in     Duration);

    subtype ID_Range_Type  is Natural range 0 .. 12;
    subtype Tag_Range_Type is ID_Range_Type range
                              ID_Range_Type'first + 1 .. ID_Range_Type'last;

    Read_Lock_Description  : aliased constant String := "database read lock";
    Write_Lock_Description : aliased constant String := "database write lock";

    type Database_Type     is new Ada.Finalization.Limited_Controlled with record
        Initialized        : Boolean := False;
        Label              : Ada_Lib.Strings.Bounded.Bounded_Type (64);
        Read_Lock          : aliased Ada_Lib.Lock.Lock_Type (Read_Lock_Description'access);
        Selector           : GNAT.Sockets.Selector_Type;
        Selector_Created   : Boolean := False;
        Socket             : GNAT.Sockets.Socket_Type;
        Socket_Created     : Boolean := False;
        Socket_Opened      : Boolean := False;
        Stream             : GNAT.Sockets.Stream_Access := Null;
        Tag                : String (Tag_Range_Type);
        Tag_Length         : ID_Range_Type := 0;
        Use_Locks          : Boolean;
        Write_Lock         : aliased Ada_Lib.Lock.Lock_Type (Write_Lock_Description'access);
    end record;

    Null_Name_Index_Tag          : constant Name_Index_Tag_Type := Name_Index_Tag_Type'(
                                    Name  => Ada_Lib.Strings.Unlimited.Null_String,
                                    Index => No_Vector_Index,
                                    Tag   => Ada_Lib.Strings.Unlimited.Null_String);

    Null_Name_Value             : constant Name_Value_Type := Name_Value_Type'(
                                    Null_Name_Index_Tag with
                                       Value => Ada_Lib.Strings.Unlimited.Null_String);

end Ada_Lib.Database;
