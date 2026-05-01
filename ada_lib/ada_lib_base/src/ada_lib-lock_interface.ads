with GNAT.Source_Info;

package Ada_Lib.Lock_Interface is

   type Lock_Interface           is limited interface;
   type Lock_Interface_Class_Access
                                 is access all Lock_Interface'class;

   function Is_Locked (                -- used value on Object
      Object               : in     Lock_Interface;
      From                 : in     String := GNAT.Source_Info.Source_Location
   ) return Boolean is abstract;

   function Lock (
      Object               : in out Lock_Interface;
      Wait_Time            : in     Duration;
      From                 : in     String := GNAT.Source_Info.Source_Location
   ) return Boolean is abstract;

   -- raises exception if object already locked
   procedure Lock (
      Object               : in out Lock_Interface;
      From                 : in     String := GNAT.Source_Info.Source_Location
   ) is abstract;

-- function Try_Lock (
--    Object               : in out Lock_Interface;
--    From                 : in     String := GNAT.Source_Info.Source_Location
-- ) return Boolean is abstract;

   procedure Unlock (
      Object               : in out Lock_Interface;
      From                 : in     String := GNAT.Source_Info.Source_Location
                                             ) is abstract;

end Ada_Lib.Lock_Interface;

