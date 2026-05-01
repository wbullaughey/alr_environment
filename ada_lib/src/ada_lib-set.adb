with Ada_Lib.Strings;

package body Ada_Lib.Set is

   ---------------------------------------------------------------------------
   function Count (
      Set                  : in   Unconstrained_Type
   ) return Natural is
   ---------------------------------------------------------------------------

      Result               : Natural := 0;

   begin
      for Index in Set'range loop
         if Set (Index) then
            Result := Result + 1;
         end if;
      end loop;

      return Result;
   end Count;

   ---------------------------------------------------------------------------
   overriding
   function "=" (
      Left              : in   Unconstrained_Type;
      Right             : in   Unconstrained_Type
   ) return Boolean is
   ---------------------------------------------------------------------------

   begin
      if Left'Length /= Right'length then
         return False;
      end if;

       for Index in Left'range loop
         if Left (Index) /= Right (Index) then
            return False;
         end if;
      end loop;

      return True;
   end "=";

   ---------------------------------------------------------------------------
   overriding
   function "and" (
      Left              : in   Unconstrained_Type;
      Right             : in   Unconstrained_Type
   ) return Unconstrained_Type is
   ---------------------------------------------------------------------------

      Result               : Unconstrained_Type (Left'range);
      Right_Index          : Index_Type := Right'first;

   begin
      pragma Assert (Left'length = Right'length);

      for Left_Index in Left'range loop
         Result (Left_Index) := Left (Left_Index) and then Right (Right_Index);
         if Right_Index < Right'last then
            Right_Index := Index_Type'succ (Right_Index);
         end if;
      end loop;

      return Result;
   end "and";

   ---------------------------------------------------------------------------
   overriding
   function "or" (
      Left              : in   Unconstrained_Type;
      Right             : in   Unconstrained_Type
   ) return Unconstrained_Type is
   ---------------------------------------------------------------------------

      Result               : Unconstrained_Type (Left'range);
      Right_Index          : Index_Type := Right'first;

   begin
      pragma Assert (Left'length = Right'length);

      for Left_Index in Left'range loop
         Result (Left_Index) := Left (Left_Index) or else Right (Right_Index);
         if Right_Index < Right'last then
            Right_Index := Index_Type'succ (Right_Index);
         end if;
      end loop;

      return Result;
   end "or";

   ---------------------------------------------------------------------------
   overriding
   function "not" (
      Set                  : in   Unconstrained_Type
   ) return Unconstrained_Type is
   ---------------------------------------------------------------------------

      Result               : Unconstrained_Type (Set'range);

   begin
      for Index in Set'range loop
         Result (Index) := not Set (Index);
      end loop;

      return Result;
   end "not";

   ---------------------------------------------------------------------------
   function Image (
      Set                  : in   Unconstrained_Type
   ) return String is
   ---------------------------------------------------------------------------

      ---------------------------------------------------------------------------
      function Format_Range (
         Start          : in   Index_Type;
         Stop           : in   Index_Type
      ) return String is
      ---------------------------------------------------------------------------

      begin
         if Start = Stop then
            return "," & Ada_Lib.Strings.Trim (Start'img);
         else
            return "," & Ada_Lib.Strings.Trim (Start'img) &
               "-" & Ada_Lib.Strings.Trim (Stop'img);
         end if;
      end Format_Range;

      ---------------------------------------------------------------------------
      function Starting_From (
         Start          : in   Index_Type
      ) return String is
      ---------------------------------------------------------------------------

      begin
         for Start_Index in Start .. Set'last loop
            if Set (Start_Index) then
               if Start_Index = Set'last then
                  return Format_Range (Start_Index, Start_Index);
               else
                  for End_Index in Index_Type'succ (Start_Index) .. Set'last loop
                     if not Set (End_Index) then
                        declare
                           This_Range  : constant String :=
                                       Format_Range (Start_Index,
                                          Index_Type'pred (End_Index));

                        begin
                           if End_Index = Set'last then
                              return This_Range;
                           else
                              return This_Range &
                                 Starting_From (Index_Type'succ (End_Index));
                           end if;
                        end;
                     end if;
                  end loop;

                  return Format_Range (Start_Index, Set'last);
               end if;
            end if;
         end loop;

         return "";
      end Starting_From;

      Result               : constant String := Starting_From (Set'first);

   begin
      return Result (Result'first + 1 .. Result'last);
         -- remove leading comma
   end Image;

   ---------------------------------------------------------------------------
   function Image (
      Vector               : in   Vector_Type
   ) return String is
   ---------------------------------------------------------------------------

   begin
      return Image (To_Set (Vector));
   end Image;

   ---------------------------------------------------------------------------
   function Is_In (
      Set                  : in   Unconstrained_Type;
      Item              : in   Index_Type
   ) return Boolean is
   ---------------------------------------------------------------------------

   begin
      return Set (Item);
   end Is_In;

   ---------------------------------------------------------------------------
   -- test if Set_2 is a subset of Set_1
   function Is_In (
      Set_1             : in   Unconstrained_Type;
      Set_2             : in   Unconstrained_Type
   ) return Boolean is
   ---------------------------------------------------------------------------

   begin
      for Index in Set_2'range loop
         if Index > Set_1'last then
            return False;
         end if;

         if Set_2 (Index) and then not Set_1 (Index) then
            return False;
         end if;
      end loop;

      return True;
   end Is_In;

   ---------------------------------------------------------------------------
   function Singleton (
      Item              : in   Index_Type
   ) return Set_Type is
   ---------------------------------------------------------------------------

      Result               : Set_Type := (others => False);

   begin
      Result (Item) := True;
      return Result;
   end Singleton;

   ---------------------------------------------------------------------------
   function To_Set (
      Vector               : in   Vector_Type
   ) return Set_Type is
   ---------------------------------------------------------------------------

      Result               : Set_Type := Null_Set;

   begin
      for Index in Vector'range loop
         Result (Vector (Index)) := True;
      end loop;

      return Result;
   end To_Set;

   ---------------------------------------------------------------------------
   function To_Vector (
      Set                  : in   Unconstrained_Type
   ) return Vector_Type is
   ---------------------------------------------------------------------------

      Index             : Positive := 1;
      Result               : Vector_Type (1 .. Count (Set));

   begin
      for Value in Set'range loop
         if Set (Value) then
            Result (Index) := Value;
            Index := Index + 1;
         end if;
      end loop;

      return Result;
   end To_Vector;

end Ada_Lib.Set;

