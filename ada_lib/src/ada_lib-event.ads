with Ada_Lib.Strings;
with GNAT.Source_Info;

package Ada_Lib.Event is

   Failed                        : exception;

   type Event_Type (
      Description                : Ada_Lib.Strings.String_Constant_Access
   ) is tagged limited private;

   type Event_Access              is access all Event_Type;
   type Event_Class_Access        is access all Event_Type'class;

   function Event_Occured (
      Object                     : in     Event_Type
   ) return Boolean;

   procedure Reset_Event (
      Object                     : in out Event_Type);

   procedure Set_Event (
      Object                     : in out Event_Type;
      From                       : in     String :=
                                             GNAT.Source_Info.Source_Location);

   procedure Wait_For_Event (
      Object                     : in out Event_Type;
      From                       : in     String :=
                                             GNAT.Source_Info.Source_Location);

   Debug                         : aliased Boolean := False;

private

   protected type Protected_Event (
      Description                : Ada_Lib.Strings.String_Constant_Access
   ) is

      function Did_Occure return Boolean;

      procedure Reset;

      procedure Set_Occured (
         From                    : in     String);

      entry Wait_For_Event (
         From                    : in     String);

   private
      Occured                     : Boolean := False;

   end Protected_Event;

   type Event_Type (
      Description                : Ada_Lib.Strings.String_Constant_Access
   ) is tagged limited record
      Event_Object                : Protected_Event (Description);
   end record;

end Ada_Lib.Event;

