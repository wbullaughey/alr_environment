with Ada_Lib.Options;
with Ada_Lib.Trace; use Ada_Lib.Trace;

package body Ada_Lib.Database.Event is

   use type Content_Package.Content_Class_Access;

   Trace    : Boolean renames Options.Ada_Lib_Database.Event_Trace;

   ---------------------------------------------------------------------------------
   function Is_Valid (
      Event                      : in     Event_Type
   ) return Boolean is
   ---------------------------------------------------------------------------------

   begin
      return Event.Ptr /= Null;
   end Is_Valid;

   package body Content_Package is

      ---------------------------------------------------------------------------------
      function Index (
         Content                      : in     Content_Type
      ) return Optional_Vector_Index_Type is
      ---------------------------------------------------------------------------------

      begin
         return Content.Index;
      end Index;

      ---------------------------------------------------------------------------------
      procedure Initialize (
         Content                 : in out Content_Type;
         Name_Value              : in     Name_Value_Type;
         Index                   : in     Optional_Vector_Index_Type;
         Update_Mode             : in     Ada_Lib.Database.Updater.Update_Mode_Type) is
      ---------------------------------------------------------------------------------

      begin
         Log (Trace, Here, Who & " enter " & Ada_Lib.Strings.Image (Content'address));
         Content.Name_Value := Name_Value;
         Content.Index := Index;
         Content.Update_Mode := Update_Mode;

      end Initialize;
      ---------------------------------------------------------------------------------
      function Name_Value (
         Content                      : in     Content_Type
      ) return Name_Value_Type is
      ---------------------------------------------------------------------------------

      begin
         return Content.Name_Value;
      end Name_Value;

      ---------------------------------------------------------------------------------
      procedure Signal (
         Content                      : in out Content_Type)is
      ---------------------------------------------------------------------------------

      begin
         Log (Trace, Here, Who & " enter " & Ada_Lib.Strings.Image (Content'address));
         Content.Was_Signaled := True;
         Content_Type'class (Content).Signaled;
         Log (Trace, Here, Who & " exit");
      end Signal;

      ---------------------------------------------------------------------------------
      function Update_Mode (
         Content                      : in     Content_Type
      ) return Ada_Lib.Database.Updater.Update_Mode_Type is
      ---------------------------------------------------------------------------------

      begin
         return Content.Update_Mode;
      end Update_Mode;

      ---------------------------------------------------------------------------------
      function Was_Signaled (
         Content                      : in     Content_Type
      ) return Boolean is
      ---------------------------------------------------------------------------------

      begin
         Log (Trace, Here, Who & " enter was signaled " & Content.Was_Signaled'img & " address " & Ada_Lib.Strings.Image (Content'address));
         return Content.Was_Signaled;
      end Was_Signaled;

   end Content_Package;


end Ada_Lib.Database.Event;
