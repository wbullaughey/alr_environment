
with Ada.Exceptions;
with Ada.Numerics.Generic_Elementary_Functions;
with Ada_Lib.Trace;use Ada_Lib.Trace;

package body Ada_Lib.Standard_Deviation is

   package Elementary_Functions  is new Ada.Numerics.Generic_Elementary_Functions (Long_Float);

   Trace                : constant Boolean := False;

    ---------------------------------------------------------------------------
   procedure Add_Value (
      Calculate            : in out Calculate_Type;
      Value             : in   Data_Type) is
    ---------------------------------------------------------------------------

   begin
      Calculate.Count := Calculate.Count + 1;
      Calculate.Sum := Calculate.Sum + Long_Float(Value);
      Calculate.Squares := Calculate.Squares + Long_Float(Value) * Long_Float(Value);
      if Trace then
         Log_Here ("add" & Value'img & " sum" & Calculate.Sum'img &
            " squares" & Calculate.Squares'img);
      end if;

   end Add_Value;

    ---------------------------------------------------------------------------
   function Count (
      Calculate            : in   Calculate_Type
   ) return Natural is
    ---------------------------------------------------------------------------

   begin
      if Trace then
         Log_Here ("count" & Calculate.Count'img & " sum" & Calculate.Sum'img &
            " squares" & Calculate.Squares'img);
      end if;

      return Calculate.Count;
   end Count;

    ---------------------------------------------------------------------------
   function Mean (
      Calculate            : in   Calculate_Type
   ) return Data_Type is
    ---------------------------------------------------------------------------

   begin
      if Trace then
         Log_Here ("count" & Calculate.Count'img & " sum" & Calculate.Sum'img &
            " squares" & Calculate.Squares'img);
      end if;

      if Calculate.Count = 0 then
         raise No_Data;
      end if;

      return Data_Type (Calculate.Sum / Long_Float (Calculate.Count));

   exception
      when Fault: others =>
         if Trace then
            Trace_Exception (Fault, "Could not calculate mean");
         end if;

         Ada.Exceptions.Raise_Exception (Failed'identity,
            Ada.Exceptions.Exception_Name (Fault) &
            " calculating mean");
   end Mean;

    ---------------------------------------------------------------------------
   function Result (
      Calculate            : in   Calculate_Type
   ) return Data_Type is
    ---------------------------------------------------------------------------

   begin
      case Calculate.Count is

         when 0 =>
            raise No_Data;

         when 1 =>
            return 0.0;

         when others =>
            null;

      end case;

      declare
         Distance       : constant Long_Float :=
                           Calculate.Squares / Long_Float (Calculate.Count) -
                           (Calculate.Sum / Long_Float (Calculate.Count)) ** 2;

      begin
         if Trace then
            Log_Here ("count" & Calculate.Count'img & " sum" & Calculate.Sum'img &
               " squares" & Calculate.Squares'img &
               " distance " & Distance'img);
         end if;

         if Distance <= 0.0 then
            return 0.0;
         else
            return Data_Type (Elementary_Functions.Sqrt (Distance));
         end if;
      end;

   exception
      when Fault: others =>
         if Trace then
            Trace_Message_Exception (Fault, "Could not calculate standard deviation");
         end if;

         Ada.Exceptions.Raise_Exception (Failed'identity,
            Ada.Exceptions.Exception_Name (Fault) &
            " calculating standard deviation");
   end Result;

end Ada_Lib.Standard_Deviation;
