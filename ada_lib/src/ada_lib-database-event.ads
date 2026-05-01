with Ada_Lib.Database.Updater;
with Ada_Lib.Object.Handle;

pragma Elaborate (Ada_Lib.Object.Handle);

package Ada_Lib.Database.Event is

   type Event_Interface is limited interface;

   -- called when the event is signaled
   procedure Signaled (
      Event                      : in out Event_Interface) is abstract;

   package Content_Package is
      type Content_Type is abstract new Object.Entity and Event_Interface with private;

      type Content_Class_Access is access all Content_Type'class;

      function Index (
         Content                      : in     Content_Type
      ) return Optional_Vector_Index_Type;

      procedure Initialize (
         Content                 : in out Content_Type;
         Name_Value              : in     Name_Value_Type;
         Index                   : in     Optional_Vector_Index_Type;
         Update_Mode             : in     Ada_Lib.Database.Updater.Update_Mode_Type);

      function Name_Value (
         Content                      : in     Content_Type
      ) return Name_Value_Type;

      -- sends a signal
      procedure Signal (
         Content                      : in out Content_Type);

      function Update_Mode (
         Content                      : in     Content_Type
      ) return Ada_Lib.Database.Updater.Update_Mode_Type;

      function Was_Signaled (
         Content                      : in     Content_Type
      ) return Boolean;

   private

      type Content_Type is abstract new Object.Entity and Event_Interface with record
         Index                      : Optional_Vector_Index_Type;
         Name_Value                 : Name_Value_Type;
         Was_Signaled               : Boolean := False;
         Update_Mode                : Ada_Lib.Database.Updater.Update_Mode_Type;
      end record;

   end Content_Package;

   package Event_Package is new Ada_Lib.Object.Handle (
      Content_Package.Content_Type,
      Content_Package.Content_Class_Access);

   subtype Event_Content_Type is Content_Package.Content_Type;
   subtype Event_Content_Class_Access is Content_Package.Content_Class_Access;
   subtype Event_Type is Event_Package.Handle;

   function Is_Valid (
      Event                      : in     Event_Type
   ) return Boolean;

   Null_Handle                   : Event_Type renames Event_Package.Null_Handle;

end Ada_Lib.Database.Event;
