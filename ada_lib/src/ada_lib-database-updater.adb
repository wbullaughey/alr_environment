with Ada.Text_IO; use Ada.Text_IO;
with Ada_Lib.Options;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
--with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace; use Ada_Lib.Trace;

package body Ada_Lib.Database.Updater is

--  use type Ada_Lib.Strings.Unlimited.String_Type;

   Delimiter                     : constant Character := '|';
   Trace                         : Boolean renames Options.Ada_Lib_Database.
                                    Updater_Trace;

   -------------------------------------------------------------------
   function Calculate_Update_Mode (
      Subscribe               : in     Boolean;
      On_Change               : in     Boolean
   ) return Update_Mode_Type is
   -------------------------------------------------------------------

   begin
     return (if Subscribe then (if On_Change then Always else Unique) else Never);
   end Calculate_Update_Mode;

    -------------------------------------------------------------------
   overriding
   procedure Dump (
      Updater                    : in     Abstract_Updater_Type;
      Title                      : in     String := "";
      From                       : in     String := Ada_Lib.Trace.Here) is
    -------------------------------------------------------------------

    begin
       Log_In (Trace and Ada_Lib.Trace.Detail, " from " & From);
       Put_Line ("Dump " & Title & " " & Updater.Image);
   end Dump;

    -------------------------------------------------------------------
   overriding
   procedure Dump (
      Address                    : in     Null_Address_Type;
      Title                      : in     String := "";
      From                       : in     String := Ada_Lib.Trace.Here) is
    -------------------------------------------------------------------

    begin
       Log_In (Trace and Detail, " from " & From);
       Put_Line ("Dump " & Title & " " & Address.Image);
   end Dump;

   -------------------------------------------------------------------
   function Equal (
      Left, Right                : in     Updater_Interface_Class_Access
   ) return Boolean is
   -------------------------------------------------------------------

   begin
      return Left.all = Right.all;
   end Equal;

--    -------------------------------------------------------------------
--   function "=" (
--      Left, Right                : in     Abstract_Updater_Type
--   ) return Boolean is
--    -------------------------------------------------------------------
--
--   begin
--      Log_In (Trace);
--      return Base_Updater_Package.Base_Updater_Type (Left).Equal (
--         Base_Updater_Package.Base_Updater_Type (Right));
----    return Left.ID = Right.ID and
----           Left.Update_Mode = Right.Update_Mode and
----           Left.Name_Index_Tag.Equal (Right.Name_Index_Tag);
--   end "=";

   ---------------------------------------------------------------------------------
   overriding
   procedure Load (
      Updater                    : in out Abstract_Updater_Type;
      File                       : in out Ada.Text_IO.File_Type;
      Got_Subscription           :    out Boolean) is
   ---------------------------------------------------------------------------------

   begin
      Base_Updater_Package.Base_Updater_Type (Updater).Load (File, Got_Subscription);
   end Load;

   ---------------------------------------------------------------
   overriding
   function Name_Value (
      Updater                    : in     Abstract_Updater_Type
   ) return Name_Value_Type'class is
   ---------------------------------------------------------------

      Result                     : Name_Value_Type;

   begin
not_implemented;
      return Result;
   end Name_Value;

   -------------------------------------------------------------------
   overriding
   function Value (
      Updater                    : in     Abstract_Updater_Type
   ) return String is
   -------------------------------------------------------------------

   begin
      Log_In (Trace);
      raise Failed with "updater does not have a value";
      return "";
   end Value;

    -------------------------------------------------------------------
   overriding
   function Image (
      Address                    : in     Null_Address_Type
   ) return String is
    -------------------------------------------------------------------

   begin
      return "Null Address";
   end Image;


    -------------------------------------------------------------------
   function Updater_ID (
      Name                    : in     String;
      Index                   : in     Ada_Lib.Database.Optional_Vector_Index_Type;
      DBDaemon_Tag            : in     String;
      Ada_Tag                 : in     Ada.Tags.Tag
   ) return String is
    -------------------------------------------------------------------

   begin
      return Name & Delimiter & Ada_Lib.Strings.Trim (Index'img) & Delimiter & DBDaemon_Tag &
         Delimiter & Ada.Tags.Expanded_Name (Ada_Tag);
   end Updater_ID;

   package body Base_Updater_Package is

       -------------------------------------------------------------------
      function "=" (
         Left, Right             : in     Base_Updater_Type
      ) return Boolean is
       -------------------------------------------------------------------

      begin
         Log_In (Trace, Tag_Name ("left", Base_Updater_Type'class (Left)'tag) &
            Tag_Name (" right", Base_Updater_Type'class (Right)'tag));

         declare
            Result               : constant Boolean := Left.ID = Right.ID and then
                                     Left.Update_Mode = Right.Update_Mode and then
                                     Left.Name_Index_Tag.Equal (Right.Name_Index_Tag);
         begin
            Log_Out (Trace, "result " & Result'img);
            return Result;
         end;
      end "=";

       ----------------------------------------------------------------
      function DBDaemon_Tag (
         Base_Updater               : in     Base_Updater_Type
      ) return String is
       ----------------------------------------------------------------

      begin
         return Base_Updater.Name_Index_Tag.Tag.Coerce;
      end DBDaemon_Tag;

       -------------------------------------------------------------------
      procedure Dump (
         Updater                    : in     Base_Updater_Type;
         Title                      : in     String := "";
         From                       : in     String := Ada_Lib.Trace.Here) is
       -------------------------------------------------------------------

      begin
         Log_In (Trace and Detail, " from " & From);
         Put_Line ("Dump " & Title & " " & Updater.Image);
         Put_LIne (Quote ("   ID", Updater.ID));
         Put_Line ("   name_index_tag " & Base_Updater_Type'class (Updater).Name_Index_Tag.Image);
         Put_Line ("   update mode " & Updater.Update_Mode'img);
      end Dump;

       -------------------------------------------------------------------
      function Image (
         Updater                    : in     Base_Updater_Type
      ) return String is
       -------------------------------------------------------------------

      begin
         return Quote ("ID ", Updater.ID.Coerce) & Quote (" Name", Updater.Name) & " Index" & Updater.Index'img &
            Quote (" Tag", Updater.DBDaemon_Tag) & " Update_Mode " & Updater.Update_Mode'img;
      end Image;

       ----------------------------------------------------------------
      function Index (
         Base_Updater               : in     Base_Updater_Type
      ) return Optional_Vector_Index_Type is
       ----------------------------------------------------------------

      begin
         return Base_Updater.Name_Index_Tag.Index;
      end Index;

      ---------------------------------------------------------------------------------
      procedure Initialize (
         Updater                    : in out Base_Updater_Type;
         Index                      : in     Ada_Lib.Database.Optional_Vector_Index_Type;
         Name                       : in     String;
         DBDaemon_Tag               : in     String;
         Ada_Tag                    : in     Ada.Tags.Tag;
         Update_Mode                : in     Update_Mode_Type) is
      ---------------------------------------------------------------------------------

      begin
         Log_In (Debug_Subscribe, Quote ("name", Name) & " index " & Index'img &
            Quote (" tag", DBDaemon_Tag));
         Updater.Name_Index_Tag.Initialize (Index, Name, DBDaemon_Tag);
         Updater.ID := Ada_Lib.Strings.Unlimited.Coerce (Updater_ID (Name, Index, DBDaemon_Tag, Ada_Tag));
         Updater.Update_Mode := Update_Mode;
         if Debug_Subscribe then
            Updater.Dump ("initialized");
         end if;
         Log_Out (Debug_Subscribe);
      end Initialize;

      ---------------------------------------------------------------------------------
      procedure Load (
         Updater                    : in out Base_Updater_Type;
         File                       : in out Ada.Text_IO.File_Type;
         Got_Subscription           :    out Boolean) is
      ---------------------------------------------------------------------------------

      begin
        Log_In (Debug_Subscribe);
        declare
           Name                    : constant String := Get_Subscription_Field (File, True);

        begin
           if Name'length = 0 then
              Got_Subscription := False;
              Log_Out (Debug_Subscribe, "end of file");
              return;
           end if;

           declare
              Index       : constant String := Get_Subscription_Field (File, False);
              DBDaemon_Tag: constant String := Get_Subscription_Field (File, True);
              Update_Mode : Update_Mode_Type;
              Update_Mode_Field
                          : constant String := Get_Subscription_Field (File, True);

           begin
              Log_Here (Debug_Subscribe, Quote ("name", Name) & Quote (" index", Index) &
                  Quote (" tag", DBDaemon_Tag) & Quote (" update_Mode", Update_Mode_Field));

              begin
                 Update_Mode := Ada_Lib.Database.Updater.Update_Mode_Type'Value (Update_Mode_Field);

              exception
                 when Constraint_Error =>
                     raise Failed with (if Update_Mode_Field'length = 0 then
                           "missing value for Update Mode"
                        else
                           "invalid value for " & Quote ("Update_Mode", Update_Mode_Field)
                        & " field");
              end;

              Updater.Initialize (
                 Index           => Optional_Vector_Index_Type'Value (Index),
                 Name            => Name,
                 DBDaemon_Tag    => DBDaemon_Tag,
                 Ada_Tag         => Base_Updater_Type'class (Updater)'tag,
                 Update_Mode     => Update_Mode);
           end;
        end;

        Got_Subscription := True;
        Log_Out (Debug_Subscribe);

     exception
        when Fault: Failed =>
           Trace_Message_Exception (Debug_Subscribe, Fault, "null subscription field");
           raise;

      end Load;

       ----------------------------------------------------------------
      function Name (
         Base_Updater               : in     Base_Updater_Type
      ) return String is
       ----------------------------------------------------------------

      begin
         return Base_Updater.Name_Index_Tag.Name.Coerce;
      end Name;

      ---------------------------------------------------------------------------------
      procedure Set_Mode (
         Updater                    : in out Base_Updater_Type;
         Mode                       : in     Update_Mode_Type) is
      ---------------------------------------------------------------------------------

      begin
         Updater.Update_Mode := Mode;
      end Set_Mode;

      ---------------------------------------------------------------------------------
      procedure Store (
         Updater                    : in     Base_Updater_Type;
         File                       : in out Ada.Text_IO.File_Type) is
      ---------------------------------------------------------------------------------

      begin
         Log_In (Debug_Subscribe);
         Updater.Name_Index_Tag.Store (File);
         Put_Line (File, File_Seperator & Updater.Update_Mode'img);
         Log_Out (Debug_Subscribe);
      end Store;

       -------------------------------------------------------------------
      function Update_Count (
         Updater                    : in     Base_Updater_Type
      ) return Natural is
       -------------------------------------------------------------------

      begin
         raise Failed with "updater does not have a count";
         return 0;
      end Update_Count;

       ----------------------------------------------------------------
      function Updater_ID (
         Updater                    : in     Base_Updater_Type
      ) return String is
       ----------------------------------------------------------------

      begin
         return Updater.ID.Coerce;
      end Updater_ID;

       ----------------------------------------------------------------
      function Update_Mode (
         Base_Updater               : in     Base_Updater_Type
      ) return Update_Mode_Type is
       ----------------------------------------------------------------

      begin
         return Base_Updater.Update_Mode;
      end Update_Mode;

   end Base_Updater_Package;


end Ada_Lib.Database.Updater;
