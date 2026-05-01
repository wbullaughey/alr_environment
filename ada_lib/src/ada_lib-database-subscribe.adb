with Ada.Text_IO; use Ada.Text_IO;
with Ada_Lib.Options;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace; use Ada_Lib.Trace;

package body Ada_Lib.Database.Subscribe is

   use type Ada_Lib.Database.Updater.Updater_Interface_Class_Access;
   use type Ada_Lib.Database.Updater.Update_Mode_Type;
-- use type Ada_Lib.Strings.Unlimited.String_Type;

-- function Subscription_Name (
--    Name                       : in     String;
--    Index                      : in     Optional_Vector_Index_Type
-- ) return String;

-- procedure Update_Indexed_Value (
--    Cursor                     : in out Ada_Lib.DAtabase.Subscribe.Vector_Cursor_Type;
--    Index                      : in     Optional_Vector_Index_Type;
--    Value                      : in     String);

-- function Create_Key (
--    Name                       : in     String;
--    Index                      : in     Optional_Vector_Index_Type;
--    Tag                        : in     String;
--    Variant_Tag                : in     Ada.Tags.Tag
-- ) return Key_Type;

-- function Create_Key (
--    Updater                    : in     Ada_Lib.Database.Updater.Updater_Interface_Class_Access
-- ) return Key_Type;

   Debug_Subscribe   : Boolean renames Options.Ada_Lib_Database.
                        Debug_Subscribe;

   Null_Address      : Ada_Lib.Database.Updater.Null_Address_Type renames
                        Ada_Lib.Database.Updater.Null_Address;

   ---------------------------------------------------------------------------------
   procedure Add_Subscription (
      Table                      : in out Table_Type;
      Updater                    : in     Ada_Lib.Database.Updater.Updater_Interface_Class_Access) is
--    Timeout                    : in     Duration := Default_Post_Timeout) is
   ---------------------------------------------------------------------------------

   begin
      Log_In (Debug_Subscribe, Tag_Name ("Updater", Updater.all'tag) & "  " &
         Updater.Image &
         " Updater Address " & Ada_Lib.Strings.Image (Updater.all'address));

      declare
         Inserted             : Boolean;
         Key                  : constant String := Updater.Updater_ID;
         Table_Cursor         : Table_Cursor_Type;

      begin
         Table.Map.Insert (Key, Updater, Table_Cursor, Inserted);

         if not Inserted then
            Log_Exception (Debug_Subscribe, Quote ("duplicate Updater", Key) &
               " Update_Mode " & Updater.Update_Mode'img);
            raise Duplicate with Quote ("duplicate Updater", Key);
         end if;

      end;
      Log_Out (Debug_Subscribe);
   end Add_Subscription;

--   ---------------------------------------------------------------------------------
--   function Compare_Vectors (
----    Left                       : Subscription_Vector_Package.Vector;
----    Right                      : Subscription_Vector_Package.Vector
--      Left, Right                : Vector_Type
--   ) return Boolean is
--   ---------------------------------------------------------------------------------
--
--   begin
--      return Left = Right;
--   end Compare_Vectors;

   ---------------------------------------------------------------------------------
   -- delete all subscriptions for named item
   function Delete (
      Table                      : in out Table_Type;
      Updater               : in     Ada_Lib.Database.Updater.Updater_Interface_Class_Access
   ) return Boolean is
   ---------------------------------------------------------------------------------

      Cursor                     : Hash_Table_Package.Cursor := Hash_Table_Package.First (Table.Map);

   begin
      Log_In (Debug_Subscribe, Quote (" name", Updater.Image));

      while Hash_Table_Package.Has_Element (Cursor) loop
         declare
--          Element_Key          : constant Key_Type := Hash_Table_Package.Key (Cursor);
            Next                 : constant Hash_Table_Package.Cursor := Hash_Table_Package.Next (Cursor);

         begin
            if Hash_Table_Package.Element (Cursor) = Updater then
               Hash_Table_Package.Delete (Table.Map, Cursor);
               Log_Out (Debug_Subscribe, "found address " & Ada_Lib.Strings.Image (Updater.all'address));
               return True;
            end if;

            Cursor := Next;
         end;
      end loop;

      Log_Out (Debug_Subscribe, "not found ");
      return False;
   end Delete;

   ---------------------------------------------------------------------------------
   -- delete all subscriptions for named item
   function Delete (
      Table                      : in out Table_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag
   ) return Boolean is
   ---------------------------------------------------------------------------------

      Key              : constant String := Ada_Lib.Database.Updater.Updater_ID (Name, Index, DBDaemon_Tag, Ada_Tag);
      Cursor                     : Hash_Table_Package.Cursor := Hash_Table_Package.First (Table.Map);
      Found                      : Boolean := False;

   begin
      Log_In (Debug_Subscribe, Quote (" name", Name) & " index " & Index'img);

      while Hash_Table_Package.Has_Element (Cursor) loop
         declare
            Element_Key          : constant String := Hash_Table_Package.Key (Cursor);
            Next                 : constant Hash_Table_Package.Cursor := Hash_Table_Package.Next (Cursor);

         begin
            if Element_Key = Key then
               Hash_Table_Package.Delete (Table.Map, Cursor);
               Found := True;
            end if;

            Cursor := Next;
         end;
      end loop;

      Log_Out (Debug_Subscribe, "found " & Found'img);
      return Found;
   end Delete;

   ---------------------------------------------------------------------------------
   procedure Delete_All (
      Table                      : in out Table_Type;
      Unsubscribed_Only          : in     Boolean := False) is
   ---------------------------------------------------------------------------------

   begin
      Log (Debug_Subscribe, Here, Who & " enter");
      if Unsubscribed_Only then
         declare
            Cursor               : Table_Cursor_Type := Hash_Table_Package.First (Table.Map);

         begin
            while Hash_Table_Package.Has_Element (Cursor) loop
               if Hash_Table_Package.Element (Cursor).Update_Mode = Ada_Lib.Database.Updater.Never then
                  Hash_Table_Package.Delete (Table.Map, Cursor);
               end if;

               Cursor := Hash_Table_Package.Next (Cursor);
            end loop;
         end;
      else
         Table.Map.Clear;
      end if;

      Log (Debug_Subscribe, Here, Who & " exit");
   end Delete_All;

--   ---------------------------------------------------------------------------------
--   procedure Delete_Row (
--      Table                      : in out Table_Type;
--      Name                       : in     String) is
--   ---------------------------------------------------------------------------------
--
--   begin
-- pragma assert (false, "unimplmented");
-- null;
--   end Delete_Row;

   ---------------------------------------------------------------------------------
   procedure Dump (
      Table                      : in     Table_Type;
      Title                      : in     String := "";
      From                       : in     String := Here) is
   ---------------------------------------------------------------------------------

   begin
      Put_Line ("Dump " & Title);
      for Subscription of Table.Map loop
         Subscription.Dump;
      end loop;
   end Dump;

-- ---------------------------------------------------------------------------------
-- function Equal (
--    Left, Right                : in     Ada_Lib.Database.Updater.Updater_Interface_Class_Access
-- ) return Boolean is
-- ---------------------------------------------------------------------------------
--
-- begin
--    return Left.Equal (Right.all);
-- end Equal;

   ---------------------------------------------------------------------------------
   function Get_Number_Subscriptions (
      Table                      : in out Table_Type
   ) return Natural is
   ---------------------------------------------------------------------------------

   begin
      Log (Debug_Subscribe, Here, Who);

      return Natural (Table.Map.Length);
   end Get_Number_Subscriptions;

-- ---------------------------------------------------------------------------------
-- function Get_Subscription (
--    Cursor                     : in     Vector_Cursor_Type
-- ) return Ada_Lib.Database.Updater.Updater_Interface_Class_Access is
-- ---------------------------------------------------------------------------------
--
-- begin
--    return Subscription_Vector_Package.Element (
--       Subscription_Vector_Package.Cursor (Cursor)).Get_Subscription;
-- end Get_Subscription;

   ---------------------------------------------------------------------------------
   function Get_Subscription (
      Table                      : in out Table_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag
   ) return Ada_Lib.Database.Updater.Updater_Interface_Class_Access is
   ---------------------------------------------------------------------------------

      Map_Key                    : constant String := Ada_Lib.Database.Updater.Updater_ID (Name, Index,
                                    DBDaemon_Tag, Ada_Tag);
      Table_Cursor               : constant Table_Cursor_Type := Table.Map.Find (Map_Key);

   begin
      Log_In (Debug_Subscribe, Quote ("key", Map_Key));

      if Hash_Table_Package.Has_Element (Table_Cursor) then
         Log_Out (Debug_Subscribe);
         return Ada_Lib.Database.Updater.Updater_Interface_Class_Access (
            Hash_Table_Package.Element (Table_Cursor));
      end if;
      Log_Exception (Debug_Subscribe);
      raise Failed with "No subscription for " & Name & " index " & Index'img;
   end Get_Subscription;

   ---------------------------------------------------------------------------------
   procedure Get_Subscription_Update_Mode (
      Table                   : in out Table_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag;
      Update_Mode                :    out Ada_Lib.Database.Updater.Update_Mode_Type;
      Result                     :    out Boolean) is
   ---------------------------------------------------------------------------------

   begin
      Log (Debug_Subscribe, Here, Who & " enter");
      if Table.Has_Subscription (Name, Index, DBDaemon_Tag, Ada_Tag) then
         Update_Mode := Get_Subscription (Table, Name,Index, DBDaemon_Tag, Ada_Tag).Update_Mode;
         Result := True;
      else
         Result := False;
      end if;
   end Get_Subscription_Update_Mode;

   ---------------------------------------------------------------------------------
   function Has_Row (
      Table                      : in out Table_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type
   ) return Boolean is
   ---------------------------------------------------------------------------------

   begin
      Not_Implemented ("may be same as Has_Subscription");
      return False;
   end Has_Row;

   ---------------------------------------------------------------------------------
   function Has_Subscription (
      Table                      : in out Table_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag
   ) return Boolean is
   ---------------------------------------------------------------------------------

      Key                        : constant String := Ada_Lib.Database.Updater.Updater_ID (Name, Index,
                                    DBDaemon_Tag, Ada_Tag);
      Result                     : Boolean;
      Table_Cursor               : constant Table_Cursor_Type := Table.Map.Find (Key);

   begin
      Result := Hash_Table_Package.Has_Element (Table_Cursor);
      Log (Debug_Subscribe, Here, Who & " name '" & Name & "' index " & Index'img &
         Quote ("Key", Key) & " has " & Result'img);
      return Result;
   end Has_Subscription;

-- ---------------------------------------------------------------------------------
-- function Hash (
--    Key                        : in     Ada_Lib.Database.Updater.Key_Type
-- ) return Ada.Containers.Hash_Type is
-- ---------------------------------------------------------------------------------
--
-- begin
--    return Ada.Strings.Hash (Key.Composit_Name.Coerce & Ada.Tags.External_Tag (Key.Tag));
-- end Hash;
--
-- ---------------------------------------------------------------------------------
-- function Image (
--    Key                        : in     Ada_Lib.Database.Updater.Key_Type
-- ) return String is
-- ---------------------------------------------------------------------------------
--
-- begin
--    return Quote (Tag_Name (" Key name", Key.Composit_Name.Coerce) & "", Key.Tag);
-- end Image;
--
-- ---------------------------------------------------------------------------------
-- function Log (
--    Key                        : in     Ada_Lib.Database.Updater.Key_Type;
--    From                       : in     String := Here) return Ada_Lib.Database.Updater.Key_Type is
-- ---------------------------------------------------------------------------------
--
-- begin
--    Log_Here (Debug_Subscribe, Key.Image & " from " & From);
--    return Key;
-- end Log;

   ---------------------------------------------------------------------------------
-- procedure Insert (
--    Table                      : in out Table_Type;
--    Subscription               : in     Ada_Lib.Database.Updater.Updater_Interface_Class_Access) is
-- ---------------------------------------------------------------------------------
--
-- begin
--    Table.Map.Insert (Subscription.Name_Value.Name.Coerce, Subscription);
-- end Insert;

   ---------------------------------------------------------------------------------
   procedure Iterate (
      Table                      : in out Table_Type;
      Cursor                     : in out Subscription_Cursor_Type'Class) is
   ---------------------------------------------------------------------------------

   begin
      for Table_Cursor in Table.Map.Iterate loop
         Cursor.Updater := Hash_Table_Package.Element (Table_Cursor);

         if not Cursor.Process then -- quit after finding one
            exit;
         end if;
      end loop;
   end Iterate;

-- ---------------------------------------------------------------------------------
-- function Create_Key (
--    Updater               : in     Ada_Lib.Database.Updater.Updater_Interface_Class_Access
-- ) return Key_Type is
-- ---------------------------------------------------------------------------------
--
-- begin
--    return Key_Type'(
--       Composit_Name  => Ada_Lib.Strings.Unlimited.Coerce (
--                         Indexed_Tagged_Name (Updater.Name,
--                         Updater.Index, Updater.Tag)),
--       Tag            => Updater'tag);
-- end Create_Key;

-- ---------------------------------------------------------------------------------
-- function Create_Key (
--    Name                       : in     String;
--    Index                      : in     Optional_Vector_Index_Type;
--    Tag                        : in     String;
--    Variant_Tag                : in     Ada.Tags.Tag
-- ) return Key_Type is
-- ---------------------------------------------------------------------------------
--
-- begin
--    return Log (Key_Type'(Ada_Lib.Strings.Unlimited.Coerce (Indexed_Tagged_Name (Name, Index, Tag)),
--       Variant_Tag));
-- end Create_Key;

-- ---------------------------------------------------------------------------------
-- function Last_Value (
--    Cursor                     : in     Subscription_Cursor_Type
-- ) return Ada_Lib.Strings.Unlimited.String_Type is
-- ---------------------------------------------------------------------------------
--
-- begin
--    return Cursor.Subscription.Last_Value;
-- end Last_Value;

--   ---------------------------------------------------------------------------------
--   procedure Load (
--      Table                      : in out Table_Type;
--      Path                       : in     String) is
--   ---------------------------------------------------------------------------------
--
--      File                       : Ada.Text_IO.File_Type;
--
--   begin
--      Log_In (Debug_Subscribe, Quote ("Path", Path));
--      Ada.Text_IO.Open (File, Ada.Text_IO.In_File, Path);
--
--      loop
--         declare
--            Got_Subscription     : Boolean;
--            Subscription         : Ada_Lib.Database.Updater.Updater_Interface_Class_Access :=
--                                    new Ada_Lib.Database.Updater.Abstract_Updater_Type;
--
--         begin
--            Subscription.Load (File, Got_Subscription);
--            if Got_Subscription then
--               Table.Map.Insert (Create_Key (Subscription.all),
--                  Ada_Lib.Database.Updater.Updater_Interface_Class_Access (Subscription));
----             Table.Insert (Subscription);
----             Widget.Add_Named_Row (Subscription.Name_Value.Name.Coerce);
--            else
--               Ada_Lib.Database.Subscription.Free (Subscription);
--               exit;
--            end if;
--         end;
--      end loop;
--      Log_OUt (Debug_Subscribe);
--    end Load;
--
-- ---------------------------------------------------------------------------------
-- function Name_Value (
--    Cursor                     : in     Subscription_Cursor_Type
-- ) return Name_Value_Type is
-- ---------------------------------------------------------------------------------
--
-- begin
--    return Cursor.Updater.Name_Value;
-- end Name_Value;

   ---------------------------------------------------------------------------------
   -- send value to subscriptions
   procedure Notify (
      Table                      : in out Table_Type;
      Name_Value                 : in     Name_Value_Type'class) is
   ---------------------------------------------------------------------------------

--    Table_Cursor               : constant Table_Cursor_Type := Table.Map.Find (Name_Value.Name.Coerce);
--    Has_Element                : constant Boolean := Hash_Table_Package.Has_Element (Table_Cursor);
      Name                       : constant String := Name_Value.Name.Coerce;

   begin
      Log (Debug_Subscribe, Here, Who & " notify of " & Name_Value.To_String);
      for Cursor in Table.Map.Iterate loop
           declare
              Send_Update        : Boolean;
              Updater            : constant Ada_Lib.Database.Updater.Updater_Interface_Class_Access :=
                                    Ada_Lib.Database.Updater.Updater_Interface_Class_Access  (
                                       Hash_Table_Package.Element (Cursor));
           begin
              Log (Debug_Subscribe, Here, Who & Quote (" notify name", Name_Value.Name) &
                 Quote (" Updater name value", Updater.Image) &
                 " update mode " & Updater.Update_Mode'img &
                 Quote (" notify tag", Name_Value.Tag));

              if    Updater.Name = Name and then
                    Name_Value.Tag = Updater.DBDaemon_Tag then

                 case Updater.Update_Mode is

                    when Ada_Lib.Database.Updater.Always =>
                       Send_Update := True;

                    when Ada_Lib.Database.Updater.Unique =>
                       Send_Update := Updater.Value /= Name_Value.Value.Coerce;

                    when Ada_Lib.Database.Updater.Never =>
                       Send_Update := False;

                 end case;

                 Log (Debug_Subscribe, Here, Who & " Send_Update " & Send_Update'img &
                     Tag_Name (" Updater", Updater'tag));
                 if Send_Update then
                    Updater.Update (Null_Address, Name_Value.Tag.Coerce, Name_Value.Value.Coerce,
                     Ada_Lib.Database.Updater.External);
--                else
--                   Updater.Increment_Count;
                 end if;
              end if;
           end;
      end loop;

      Log (Debug_Subscribe, Here, Who & " exit");
   end Notify;

   ---------------------------------------------------------------------------------
   function Number_Subscriptions (
      Table                   : in     Table_Type
   ) return Natural is
   ---------------------------------------------------------------------------------

   begin
      return Natural (Table.Map.Length);
   end Number_Subscriptions;

   ---------------------------------------------------------------------------------
   -- updates name/value to table
   -- returns false if name does not exist
   function Set (
      Table                      : in out Table_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag;
      Value                      : in     String
   ) return boolean is
   ---------------------------------------------------------------------------------

--    use Ada_Lib.Database.Subscription;


      Tag                         : constant String := Ada_Lib.Database.Updater.Updater_ID (Name, Index,
                                    DBDaemon_Tag, Ada_Tag);
      Result                      : Boolean := False;

      -----------------------------------------------------------------------------
      procedure Process (
         Cursor                  : in     Hash_Table_Package.Cursor) is
      -----------------------------------------------------------------------------

         Element_Key             : constant String := Hash_Table_Package.Key (Cursor);

      begin
         Log_In (Debug_Subscribe, Quote ("key", Element_Key) & " result " & Result'img);

         if Element_Key = Tag then
            declare
               Updater           : constant Ada_Lib.Database.Updater.Updater_Interface_Class_Access :=
                                    Hash_Table_Package.Element (Cursor);
            begin
               Updater.Update (Null_Address, Tag, Value, Ada_Lib.Database.Updater.Internal);
               Result := True;
            end;
         end if;

         Log_Out (Debug_Subscribe);
      end Process;
      -----------------------------------------------------------------------------

   begin
      Log_In (Debug_Subscribe, Quote (" name", Name) & " index " & Index'img);

      Table.Map.Iterate (Process'access);
      Log_Out (Debug_Subscribe, "result " & Result'img);
      return Result;
   end Set;

   ---------------------------------------------------------------------------------
   function Set_Subscription_Mode (
      Table                      : in out Table_Type;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag;
      Update_Mode                : in     Ada_Lib.Database.Updater.Update_Mode_Type
   ) return Ada_Lib.Database.Updater_Result_Type is
   ---------------------------------------------------------------------------------

--    use Ada_Lib.Database.Subscription;


      Key                        : constant String := Ada_Lib.Database.Updater.Updater_ID (Name, Index,
                                    DBDaemon_Tag, Ada_Tag);
      Current_Mode               : Ada_Lib.Database.Updater.Update_Mode_Type := Ada_Lib.Database.Updater.Never;
      Result                      : Updater_Result_Type := Update_Failed;

      -----------------------------------------------------------------------------
      procedure Process (
         Cursor                  : in     Hash_Table_Package.Cursor) is
      -----------------------------------------------------------------------------

         Element_Key             : constant String := Hash_Table_Package.Key (Cursor);

      begin
         Log_In (Debug_Subscribe, Quote ("key", Element_Key) & " current mode " & Current_Mode'img & " result " & Result'img);

         if Element_Key = Key then
            declare
               Updater           : constant Ada_Lib.Database.Updater.Updater_Interface_Class_Access :=
                                    Hash_Table_Package.Element (Cursor);
            begin
               if Result = Update_Failed then  -- 1st Updater with matching key
                  Current_Mode := Update_Mode;
                  if Updater.Update_Mode = Update_Mode then  -- same update mode
                     Result := No_Change;
                  else                          -- different update mode
                     Result := Updated;
                  end if;
               else                             -- already found a Subscription with key
                  if Current_Mode /= Updater.Update_Mode then   -- different update modes should not happen
                     raise Failed with "different update modes " & Current_Mode'img &
                        " " & Update_Mode'img;
                  end if;
               end if;

               if Result /= No_Change then      -- set the new mode
                  Updater.Set_Mode (Update_Mode);
               end if;
            end;
         end if;

         Log_Out (Debug_Subscribe);
      end Process;
      -----------------------------------------------------------------------------

   begin
      Log_In (Debug_Subscribe, Quote (" name", Name) & " index " & Index'img & " mode " & Update_Mode'img);

      Table.Map.Iterate (Process'access);
      Log_Out (Debug_Subscribe, "result " & Result'img);
      return Result;
   end Set_Subscription_Mode;

-- ---------------------------------------------------------------------------------
-- function Set_Subscription_Mode (
--    Table                      : in out Table_Type;
--    Name_Value                 : in     Name_Value_Type;
--    Index                      : in     Optional_Vector_Index_Type;
--    Update_Mode                : in     Ada_Lib.Database.Updater.Update_Mode_Type;
--    Timeout                    : in     Duration := Default_Post_Timeout
-- ) return Boolean is
-- ---------------------------------------------------------------------------------
--
--    Name_Index                 : constant String := Subscription_Name (Name_Value, Index);
--
-- begin
--    Log (Debug_Subscribe, Here, Who & " enter for" & Name_Value.Image &
--       " on change " & Update_Mode'img & " index " & Index'img);
--
--    if Table.Has_Subscription (Name_Value.Name.Coerce, Index) then
--       declare
--          Subscription         : constant Ada_Lib.Database.Updater.Updater_Interface_Class_Access :=
--                                  Table.Get_Subscription (Name_Index);
--
--       begin
--          Subscription.Set (Name_Value);
--          Subscription.Set_Mode (Update_Mode);
--       end;
--
--       Log (Debug_Subscribe, Here, Who & " exit");
--       return True;
--    else
--       Log (Debug_Subscribe, Here, Who & " exit");
--       return False;
--    end if;
--
-- end Set_Subscription_Mode;

   ---------------------------------------------------------------------------------
   procedure Store (
      Table                      : in     Table_Type;
      Path                       : in     String) is
   ---------------------------------------------------------------------------------

      File                       : Ada.Text_IO.File_Type;

   begin
      Log_In (Debug_Subscribe, Quote ("path", Path));
      Ada.Text_IO.Create (File, Ada.Text_IO.Out_File, Path);

      for Element of Table.Map loop
         Log (Debug_Subscribe, Here, Who & " name value " & Element.Image);
         Element.Store (File);
      end loop;
      Ada.Text_IO.Close (File);
      Log_OUt (Debug_Subscribe);
    end Store;

-- ---------------------------------------------------------------------------------
-- -- add a subscription returns false if one already exists
-- function Subscribe (
--    Table                      : in out Table_Type;
--    Subscription               : in     Ada_Lib.Database.Updater.Updater_Interface_Class_Access;
--    Name                       : in     String;
--    Index                      : in     Optional_Vector_Index_Type;
--    Tag                        : in     String;
--    Value                      : in     String;
--    Update_Mode                : in     Ada_Lib.Database.Updater.Update_Mode_Type
-- ) return Boolean is
-- ---------------------------------------------------------------------------------
--
--    Name_Index                 : constant String := Subscription_Name (Name, Index);
--    Table_Cursor               : constant Table_Cursor_Type := Table.Map.Find (Name_Index);
--    Has_Element                : constant Boolean := Hash_Table_Package.Has_Element (Table_Cursor);
--
-- begin
--    Log (Debug_Subscribe, Here, Who & " enter for" & Quote (" name", Name) & Quote (" value", Value) &
--       "' on change " & Update_Mode'img & " index " & Index'img);
--
--    if Has_Element then -- create the list
--       Log_Here (Debug_Subscribe, "duplicate subscription " & Quote ("name", Name) & " index" & Index'img);
--       return False;
--    end if;
--
--    Subscription.Initialize (Name, Index, Tag, Value, Update_Mode);
--    Table.Map.Insert (Name_Index, Subscription);
--    Log (Debug_Subscribe, Here, Who & " exit");
--    return True;
-- end Subscribe;
--
   ---------------------------------------------------------------------------------
   function Subscription (
      Cursor                     : in out Subscription_Cursor_Type
   ) return Ada_Lib.Database.Updater.Updater_Interface_Class_Access is
   ---------------------------------------------------------------------------------

   begin
      return Cursor.Updater;
   end Subscription;

   ---------------------------------------------------------------------------------
   function Subscription_Protected (
      Cursor                     : in out Subscription_Cursor_Type
   ) return Ada_Lib.Database.Updater.Updater_Interface_Class_Access is
   ---------------------------------------------------------------------------------

   begin
      return Cursor.Updater;
   end Subscription_Protected;

--   --------------------------------------
--   function Subscription_Name (
--      Name                       : in     String;
--      Index                      : in     Optional_Vector_Index_Type
--   ) return String is
--   ---------------------------------------------------------------------------------
--
--   begin
----    Log (Here, Who & Quote (" Name", Name)  & " index" & Index'img);
--      return Name & (if Index = No_Vector_Index then "" else ":" & Ada_Lib.Strings.Trim (Index'img));
--   end Subscription_Name;

   ---------------------------------------------------------------------------------
   function Unsubscribe (
      Table                      : in out Table_Type;
      Remove                     : in     Boolean;
      Name                       : in     String;
      Index                      : in     Optional_Vector_Index_Type;
      DBDaemon_Tag               : in     String;
      Ada_Tag                    : in     Ada.Tags.Tag
   ) return Boolean is
   ---------------------------------------------------------------------------------

      Table_Cursor            : Table_Cursor_Type := Table.Map.Find (Ada_Lib.Database.Updater.Updater_ID (
                                 Name, Index, DBDaemon_Tag, Ada_Tag));
      Has_Element             : constant Boolean := Hash_Table_Package.Has_Element (Table_Cursor);

   begin
      Log (Debug_Subscribe, Here, Who & " enter");
      if not Has_Element then
         return False;
      end if;

      if Remove then
         Table.Map.Delete (Table_Cursor);
      else
         Hash_Table_Package.Element (Table_Cursor).Set_Mode (Ada_Lib.Database.Updater.Never);
      end if;

      return True;
   end Unsubscribe;

-- ---------------------------------------------------------------------------------
-- function Update (
--    Table                      : in out Table_Type;
--    Name                       : in     String;
--    Index                      : in     Optional_Vector_Index_Type;
--    Cursor                     : in out Subscription_Cursor_Type'Class
-- ) return Boolean is
-- ---------------------------------------------------------------------------------
--
--    Table_Cursor            : constant Table_Cursor_Type := Table.Map.Find (Subscription_Name (Name, Index));
--    Has_Element             : constant Boolean := Hash_Table_Package.Has_Element (Table_Cursor);
--
-- begin
--    Log (Debug_Subscribe, Here, Who & " enter");
--    if not Has_Element then -- create the list
--       Log (Debug_Subscribe, Here, Who & " no subscription for '" & Name & "'");
--       return False;
--    end if;
--
--    declare
--       Vector_Reference        : constant Hash_Table_Package.Reference_Type :=
--                                  Table.Map.Reference (Table_Cursor);
--       Vector_Cursor           : constant Vector_Cursor_Type := Vector_Reference.To_Cursor (Index);
--
--
--    begin
--       if not Subscription_Vector_Package.Has_Element (Vector_Cursor) then
--          Log (Debug_Subscribe, Here, Who & "no subscription for '" & Name & "' index" & Index'img);
--          return False;
--       else
--          Cursor.Subscription := Subscription_Vector_Package.Element (Vector_Cursor);
--          return Cursor.Process;
--       end if;
--    end;
-- end Update;

--   ---------------------------------------------------------------------------------
--   procedure Update_All (
--      Table                      : in out Table_Type;
--      Cursor                     : in out Subscription_Cursor_Type'Class) is
--   ---------------------------------------------------------------------------------
--
--   begin
-- null;
-- pragma Assert (False, "not implemented at " & Here);
--   end Update_All;

-- ---------------------------------------------------------------------------------
-- procedure Update_Indexed_Value (
--    Cursor                     : in out Ada_Lib.DAtabase.Subscribe.Vector_Cursor_Type;
--    Index                      : in     Optional_Vector_Index_Type;
--    Value                      : in     String) is
-- ---------------------------------------------------------------------------------
--
-- begin
--    Subscription_Vector_Package.Element (Cursor).Name_Value.Value := Ada_Lib.Strings.Unlimited.Coerce (Value);
-- end Update_Indexed_Value;

   ---------------------------------------------------------------------------------
   function Update_Mode (
      Cursor                     : in     Subscription_Cursor_Type
   ) return Ada_Lib.Database.Updater.Update_Mode_Type is
   ---------------------------------------------------------------------------------

   begin
      return Cursor.Updater.Update_Mode;
   end Update_Mode;

begin
-- Debug_Subscribe := True;
   Log_Here (Elaborate or Trace_Options);
end Ada_Lib.DAtabase.Subscribe;
