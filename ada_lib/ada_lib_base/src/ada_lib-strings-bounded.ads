-----------------------------------------------------------------------
-- Package implementing a string type with fixed maximum length set
-----------------------------------------------------------------------

with Ada.Containers;

package Ada_Lib.Strings.Bounded is

   Corrupt                 : exception;
   Maximum_Bound_Exceeded     : exception;
   Too_Long             : exception;
   Truncate_Too_Long       : exception;

   type Bounded_Type (
      Bound             : Natural) is tagged private;

   -- raises Maximum_Bound_Exceeded exception
   function Bounded (
      Contents          : in   String;
      Limit             : in   Natural := 0  -- 0 defaults to exact length
   ) return Bounded_Type;

    function Hash (
      Bounded              : in   Bounded_Type
    ) return Ada.Containers.Hash_Type;

   function Length (
      Bounded              : in   Bounded_Type
   ) return Natural;

   -- raises the Too_Long Maximum_Bound_Exceeded and Corrupt exceptions
   function "&" (
      Original          : in   Bounded_Type;
      Appended          : in   String
   ) return Bounded_Type;

   function "&" (
      Original          : in   String;
      Appended          : in   Bounded_Type
   ) return Bounded_Type;

   function "&" (
      Original          : in   Bounded_Type;
      Appended          : in   Bounded_Type
   ) return Bounded_Type;

   -- raises the Too_Long Maximum_Bound_Exceeded and Corrupt exceptions
   function "&" (
      Original          : in   Bounded_Type;
      Appended          : in   Character
   ) return Bounded_Type;

   -- test for 2 values being equal, limit does not need to match
   overriding
   function "=" (
      Bounded_1            : in   Bounded_Type;
      Bounded_2            : in   Bounded_Type
   ) return Boolean;

   procedure Append (
      Original          : in out Bounded_Type;
      Append               : in   String;
      Truncate          : in   Boolean := False;
                        -- when true and new length is longer then the bound
                        -- then the result is truncated to fit
      Truncated_Suffix     : in   String := "");
                        -- when the result is truncted this value is replaces
                        -- the end of the resulting value

   -- raises the Too_Long, Maximum_Bound_Exceeded and Corrupt exceptions
   procedure Set (
      Bounded              : in out Bounded_Type;
      Source               : in   String);

   procedure Set (
      Bounded              : in out Bounded_Type;
      Source               : in   Bounded_Type);

   -- raises Maximum_Bound_Exceeded and Corrupt exceptions
   function To_String (
      Source               : in   Bounded_Type
   ) return String;

   procedure Truncate (
      Bounded              : in out Bounded_Type;
      Length               : in   Natural);

   -- raises the Maximum_Bound_Exceeded and Corrupt exceptions
   function Verify (
      Bounded              : in   Bounded_Type;
      Limit             : in   Natural
   ) return Boolean;

   Null_String             : constant Bounded_Type;

private

   type Bounded_Type (
      Bound             : Natural) is tagged record

      Length               : Natural := 0;   -- keep length before contents
                                    -- so verify works if bound
                                    -- is corrupt
      Contents          : String (1 .. Bound) := (others => ' ');
   end record;

   Null_String             : constant Bounded_Type := (
      Bound       => 0,
      Length      => 0,
      Contents => "");
end Ada_Lib.Strings.Bounded;
