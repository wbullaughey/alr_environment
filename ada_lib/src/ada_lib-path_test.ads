with Ada.Exceptions;
with Ada_Lib.Strings;
with Ada_Lib.Time;
with GNAT.Source_Info;

generic

   type Kind_Type          is ( <> );

   Maximum_Entities        : in   Positive;

   Stub                 : in Boolean;
      -- if true then the package is stubbed out

   with procedure Idle_Exit_Save;

package Ada_Lib.Path_Test is

   No_File                 : exception;

   type Exception_Array    is array (Positive range <>) of
                           Ada.Exceptions.Exception_Id;

   type Reference_Type (
      Entity_Length        : Natural;
      Source_Location_Length  : Natural)  is record
      Entity               : String (1 .. Entity_Length);
      Source_Location         : String (1 .. Source_Location_Length);
      Instance          : Natural;
   end record;

   function Entity
   return String renames GNAT.Source_Info.Enclosing_Entity;

   procedure Idle_Test;

   procedure Load (
      File_Name            : in   String);

   procedure Not_Idle;

   function Reference (
      Entity               : in   String;
      Source_Location            : in   String;
      Instance          : in   Natural := 0
   ) return Reference_Type;

   pragma Inline (Reference);

   procedure Report;

   procedure Save (
      File_Name            : in   String);

   procedure Set_Criteria (
      Kind              : in   Kind_Type;
      Count             : in   Natural);

   procedure Set_Idle_Time (
      Value             : in   Ada_Lib.Time.Duration_Type);

   procedure Set_Only_ID (
      ID                : in   Integer);

   function Source_Location
   return String renames GNAT.Source_Info.Source_Location;

   procedure Test (
      ID                : in   Positive;
      Caller_Reference     : in   Reference_Type;
      Callie_Reference     : in   Reference_Type;
      Kind              : in   Kind_Type;
      Fire              :   out Boolean;
      Counter              :   out Natural;
      Event_ID          :   out Positive);

   pragma Inline (Test);

   procedure Test_Exception (
      ID                : in   Positive;
      Caller_Reference     : in   Reference_Type;
      Callie_Reference     : in   Reference_Type;
      Kind              : in   Kind_Type;
      Exception_To_Throw      : in   Ada.Exceptions.Exception_Id;
      Extra_Message        : in   String := "");

   type Messages_Array        is array (Positive range <>) of
                          Ada_Lib.Strings.String_Constant_Access;

   procedure Test_Exceptions (
      ID                : in   Positive;
      Caller_Reference     : in   Reference_Type;
      Callie_Reference     : in   Reference_Type;
      Kind              : in   Kind_Type;
      Exceptions_To_Throw     : in   Exception_Array;
      Extra_Messages       : in   Messages_Array := (
         1 => Null));

   pragma Inline (Test_Exception);

private

end Ada_Lib.Path_Test;

-------------------------------------------------------------------------------
------------------------------ Suggestions for use ----------------------------
-- do not use Test_Exception for exception thrown from an exception handler
-------------------------------------------------------------------------------
