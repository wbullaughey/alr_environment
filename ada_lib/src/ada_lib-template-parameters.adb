with Ada.Exceptions;
with Ada.IO_Exceptions;
with Ada.Tags;
with Ada.Text_IO; use Ada.Text_IO;
with Ada_Lib.Parser;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace; use Ada_Lib.Trace;
-- with GNAT.Directory_Operations;

pragma Elaborate (Ada_Lib.Parser);

package body Ada_Lib.Template.Parameters is

-- use type Unlimited_String_Type;

   function Find (
      Parameters           : in   Parameter_Array;
      Name              : in   String
   ) return Named_Parameter_Class_Access;

   Max_Parameters                : constant Positive := 1000;

   --------------------------------------------------------------------------
   function Boolean_Image (
      Target                     : in     Boolean
   ) return String is
   --------------------------------------------------------------------------

   begin
      return Target'img;
   end Boolean_Image;

-- --------------------------------------------------------------------------
-- function Create (
--    Name              : in   String;
--    Value             : in   Boolean
-- ) return Boolean_Parameter_Type is
-- --------------------------------------------------------------------------
--
--    Result                     : Boolean_Parameter_Type;
--
-- begin
--    Result.Initialize (Name, Value);
--    return Result;
-- end Create;
--
-- --------------------------------------------------------------------------
-- function Create (
--    Name              : in   String;
--    Dimension            : in   Natural;
--    Default_Value        : in   Boolean := False
-- ) return Boolean_Array_Parameter_Type is
-- --------------------------------------------------------------------------
--
-- begin
--    return (
--       Array_Length   => Dimension,
--       Name           => Ada_Lib.Strings.Unlimited.Coerce (Name),
--       Value          => (others => Default_Value));
-- end Create;

-- --------------------------------------------------------------------------
-- function Create (
--    Name                 : in   String;
--    Value                : in   String
-- ) return String_Parameter_Type is
-- --------------------------------------------------------------------------
--
--    Result                     : String_Parameter_Type;
--
-- begin
--    Named_Parameter_Type (Result).Initialize (Name);
--    Result.Value := Ada_Lib.Strings.Unlimited.Coerce (Value);
--    return Result;
-- end Create;

-- --------------------------------------------------------------------------
-- function Create (
--    Name              : in   String;
--    Value             : in   Integer
-- ) return Integer_Parameter_Type is
-- --------------------------------------------------------------------------
-- begin
--    return (
--       Array_Length   => Dimension,
--       Name           => Ada_Lib.Strings.Unlimited.Coerce (Name),
--       Value          => Value;
--
-- end Create;

-- --------------------------------------------------------------------------
-- function Create (
--    Name              : in   String;
--    Dimension            : in   Natural;
--    Default_Value        : in   Integer := 0
-- ) return String_Array_Parameter_Access is
-- --------------------------------------------------------------------------
--
--    Result                     : constant String_Array_Parameter_Access :=
--                                  new Integer_Array_Parameter_Type (Dimension);
--
-- begin
--    Named_Parameter_Type (Result).Initialize (Name);
--    Result.Value := (others => Default_Value);
--    return Result;
-- end Create;

-- --------------------------------------------------------------------------
-- function Create (
--    Name              : in   String;
--    Dimension            : in   Natural;
--    Default_Value        : in   String := ""
-- ) return String_Array_Parameter_Access is
-- --------------------------------------------------------------------------
--
--    Result                     : constant String_Array_Parameter_Access :=
--                                  new String_Array_Parameter_Type (Dimension);
--
-- begin
--    Result.Initialize (Name);
--    Result.Value := (others => Ada_Lib.Strings.Unlimited.Coerce (Default_Value));
--    return Result;
-- end Create;

-- --------------------------------------------------------------------------
-- function Create (
--    Name              : in   String;
--    Contents          : in   Parameter_Array
-- ) return Vector_Parameter_Access is
-- --------------------------------------------------------------------------
--
--    Result                     : Vector_Parameter_Access := new
--                                  Vector_Parameter_Type (Contents'length);
--
-- begin
--    Named_Parameter_Type (Result).Initialize (Name);
--    Result.Contents := Contents;
--    return Result;
-- end Create;
--
   --------------------------------------------------------------------------
   function Evaluate (
      Expression           : in   Expression_Type;
      Parameters           : in   Parameter_Array;
      Index             : in   Parameter_Index_Type;
      Done              : in   Boolean_Access
   ) return Boolean is
   --------------------------------------------------------------------------

   begin
not_implemented;
return false;
   end Evaluate;

   --------------------------------------------------------------------------
   function Evaluate (
      Expression           : in   Expression_Type;
      Parameters           : in   Parameter_Array;
      Index             : in   Parameter_Index_Type;
      Done              : in   Boolean_Access
   ) return Integer is
   pragma Unreferenced (Expression, Parameters, Index, Done);
   --------------------------------------------------------------------------

   begin
not_implemented;
return 0;
   end Evaluate;

   --------------------------------------------------------------------------
   overriding
   function Evaluate (
      Operator                   : in   Binary_Operator_Type;
      Parameters                 : in   Parameter_Array;
      Index                      : in   Parameter_Index_Type;
      Done                       : in   Boolean_Access
   ) return Boolean is
   --------------------------------------------------------------------------

      Left              : constant String := Ada_Lib.Strings.Trim (Operator.Left.Expand (
                           Parameters, Index, Done));
      Right             : constant String := Ada_Lib.Strings.Trim (Operator.Right.Expand (
                           Parameters, Index, Done));

   begin
      if Operator.Operator in Integer_Binary_Opcodes_Type and then
            Is_Numeric (Left) and then
            Is_Numeric (Right) then
         declare
            Left_Value     : constant Integer := Numeric_Value (Left);
            Right_Value    : constant Integer := Numeric_Value (Right);

         begin
            if Trace_Evaluate then
               Put_Line("evaluate boolean-integer " & Left_Value'Img & " " &
                  Operator.Operator'img & " " & Right_Value'Img);
            end if;

            case Operator.Operator is

               when Add_Token =>
                  return Left_Value + Right_Value /= 0;

               when Equal_Token =>
                  return Left_Value = Right_Value;

               when Greater_Token =>
                  return Left_Value > Right_Value;

               when Greater_Equal_Token =>
                  return Left_Value >= Right_Value;

               when Less_Token =>
                  return Left_Value < Right_Value;

               when Less_Equal_Token =>
                  return Left_Value <= Right_Value;

               when Not_Equal_Token =>
                  return Left_Value /= Right_Value;

               when Subtract_Token =>
                  return Left_Value - Right_Value /= 0;

               when others =>
                  pragma Assert (False, "codeing error");
                  null;

            end case;
         end;
      elsif Operator.Operator in Boolean_Binary_Opcodes_Type or else
               Operator.Operator in Integer_Binary_Opcodes_Type then
         declare
            Left        : Boolean;
            Right       : Boolean;

         begin
            Left := Operator.Left.all.Evaluate (Parameters, Index, Done);
            Right := Operator.Right.all.Evaluate (Parameters, Index, Done);

            if Trace_Evaluate then
               Put_Line("evaluate boolean-boolean " & Left'Img & " " & Operator.Operator'img & " " & Right'img);
            end if;

            case Operator.Operator is

               when Add_Token | Or_Token =>
                  return Left or Right;

               when And_Token =>
                  return Left and Right;

               when Greater_Token =>
                  return Left and not Right;

               when Greater_Equal_Token =>
                  return Left or not Right;

               when Less_Token =>
                  return Right and not Left;

               when Less_Equal_Token =>
                  return Right or not Left;

               when Subtract_Token =>
                  return Left and not Right;

               when others =>
                  pragma Assert (False, "codeing error");
                  null;

            end case;
         end;
      else
         if Trace_Evaluate then
            Put_Line("evaluate boolean-string " & Left & " " & Operator.Operator'img & " " & Right);
         end if;
         case Operator.Operator is

            when Equal_Token =>
               return Left = Right;

            when Not_Equal_Token =>
               return Left /= Right;

            when others =>
               pragma Assert (False, "codeing error");
               null;

         end case;
      end if;

      return False;
   end Evaluate;

   --------------------------------------------------------------------------
   overriding
   function Evaluate (
      Operator                : in   Binary_Operator_Type;
      Parameters              : in   Parameter_Array;
      Index                   : in   Parameter_Index_Type;
      Done                    : in   Boolean_Access
   ) return Integer is
   --------------------------------------------------------------------------

      Left              : Integer;
      Right             : Integer;
      Result_Table         : constant array (Boolean) of Integer := (
         False => 0,
         True  => 1);

   begin
      Left := Operator.Left.all.Evaluate (Parameters, Index, Done);
      Right := Operator.Right.all.Evaluate (Parameters, Index, Done);

      if Trace_Evaluate then
         Put_Line("evaluate comb-integer " & Left'Img & " " & Operator.Operator'img & " " & Right'img);
      end if;
      case Operator.Operator is

         when Add_Token =>
            return Left + Right;

         when And_Token =>
            return Result_Table (Left * Right /= 0);

         when Equal_Token =>
            return Result_Table (Left = Right);

         when Greater_Token =>
            return Result_Table (Left > Right);

         when Greater_Equal_Token =>
            return Result_Table (Left >= Right);

         when Less_Token =>
            return Result_Table (Left < Right);

         when Less_Equal_Token =>
            return Result_Table (Left <= Right);

         when Not_Equal_Token =>
            return Result_Table (Left /= Right);

         when Or_Token  =>
            return Result_Table (Left /= 0 or else Right /= 0);

         when Subtract_Token =>
            return Left - Right;

      end case;
   end Evaluate;

   --------------------------------------------------------------------------
   overriding
   function Evaluate (
      Text              : in   Text_Type;
      Parameters           : in   Parameter_Array;
      Index             : in   Parameter_Index_Type;
      Done              : in   Boolean_Access
   ) return Boolean is
   --------------------------------------------------------------------------

      Value                      : constant String := Text.Value;

   begin
      pragma Unreferenced (Done, Index, Parameters);

      if Trace_Evaluate then
         Put_Line("evaluate non-null-string " & Value & "{" & Value'length'img & "} > 0");
      end if;
      return Value'length > 0;
   end Evaluate;

   --------------------------------------------------------------------------
   overriding
   function Evaluate (
      Text              : in   Text_Type;
      Parameters           : in   Parameter_Array;
      Index             : in   Parameter_Index_Type;
      Done              : in   Boolean_Access
   ) return Integer is
   --------------------------------------------------------------------------

      Value                      : constant String := Text.Value;
      Result                     : constant Integer := Numeric_Value(Value);

   begin
      pragma Unreferenced (Done, Index, Parameters);

      if Trace_Evaluate then
            Put_Line("evaluate is-integer " & Value & " is integer " & Result'img);
      end if;
      return Result;
   end Evaluate;

   --------------------------------------------------------------------------
   overriding
   function Evaluate (
      Operator          : in   Unary_Operator_Type;
      Parameters           : in   Parameter_Array;
      Index             : in   Parameter_Index_Type;
      Done              : in   Boolean_Access
   ) return Boolean is
   --------------------------------------------------------------------------

   begin
not_implemented;
return false;
--    case Operator.Operator is
--
--       when Not_Token =>
--          if Trace_Evaluate then
--             Put_Line("evaluate boolean-not " & Boolean'image (not Expression));
--          end if;
--          return not Expression;
--
--       when others =>
--          raise Syntax_Error with "invalid operator " & Operator.Operator'img &
--             " for unary expression";
--
--    end case;
   end Evaluate;

   --------------------------------------------------------------------------
   overriding
   function Evaluate (
      Operator          : in   Unary_Operator_Type;
      Parameters           : in   Parameter_Array;
      Index             : in   Parameter_Index_Type;
      Done              : in   Boolean_Access
   ) return Integer is
   --------------------------------------------------------------------------

      Expression           : Boolean;
      Result_Table         : constant array (Boolean) of Integer := (
         False => 1,
         True  => 0);

   begin
      Expression := Operator.Evaluate (Parameters, Index, Done);

      case Operator.Operator is

         when Not_Token =>
            if Trace_Evaluate then
                    Put_Line("evaluate integer-not " & (Result_Table(Expression)'Img));
            end if;
            return Result_Table (Expression);

      end case;
   end Evaluate;

   --------------------------------------------------------------------------
   overriding
   function Evaluate (
      Variable          : in   Variable_Type;
      Parameters           : in   Parameter_Array;
      Index             : in   Parameter_Index_Type;
      Done              : in   Boolean_Access
   ) return Boolean is
   --------------------------------------------------------------------------

      Value             : constant String := Variable.Expand (Parameters, Index, Done);
      N                 : Integer;
   begin
      if Value = "TRUE" then
         if Trace_Evaluate then
            Put_Line("evaluate unary-truth " & Value & " is True");
         end if;
         return True;
      elsif Value = "FALSE" then
         if Trace_Evaluate then
            Put_Line("evaluate unary-truth " & Value & " is False");
         end if;
         return False;
      elsif Is_Numeric(Value) then
         N := Numeric_Value(Value);
         if N = 0 then
            if Trace_Evaluate then
               Put_Line("evaluate unary-truth " & N'img & " is False");
            end if;
            return False;
         else
            if Trace_Evaluate then
               Put_Line("evaluate unary-truth " & N'img & " is True");
            end if;
            return True;
         end if;
      else
         if Trace_Evaluate then
            Put_Line("evaluate unary-truth " & Value & "{" &
               Integer(Value'Length)'Img & "} > 0 is " &
               Boolean'image (Value'length > 0));
         end if;
         return Value'length > 0;
      end if;
   end Evaluate;

   --------------------------------------------------------------------------
   overriding
   function Evaluate (
      Variable          : in   Variable_Type;
      Parameters           : in   Parameter_Array;
      Index             : in   Parameter_Index_Type;
      Done              : in   Boolean_Access
   ) return Integer is
   --------------------------------------------------------------------------

   begin
      if Trace_Evaluate then
         Put_Line("evaluate is-number " &
            Numeric_Value (Variable.Expand (Parameters, Index, Done))'Img);
      end if;
      return Numeric_Value (Variable.Expand (Parameters, Index, Done));
   end Evaluate;

   --------------------------------------------------------------------------
   function Expand (
      Construct            : in   Construct_Type;
      Parameters           : in   Parameter_Array;
      Index             : in   Parameter_Index_Type;
      Done              : in   Boolean_Access
   ) return String is
   --------------------------------------------------------------------------

   begin
not_Implemented;
return "";
   end Expand;

   --------------------------------------------------------------------------
   function Expand (
      Parameters           : in   Parameter_Array;
      Index             : in   Parameter_Index_Type;
      Done              : in   Boolean_Access
   ) return String is
   pragma Unreferenced (Parameters, Index, Done);
   --------------------------------------------------------------------------

   begin
not_Implemented;
return "";
   end Expand;

   --------------------------------------------------------------------------
   overriding
   function Expand (
      Binary_Operator            : in   Binary_Operator_Type;
      Parameters                 : in   Parameter_Array;
      Index                      : in   Parameter_Index_Type;
      Done                       : in   Boolean_Access
   ) return String is
   --------------------------------------------------------------------------

   begin
      pragma Unreferenced (Done, Index, Parameters);

      if Trace_Expand then
         Put_Line ("expand binary operator: " & Binary_Operator.Operator'img);
      end if;

      return "";
   end Expand;

   --------------------------------------------------------------------------
   overriding
   function Expand (
      Expression                 : in   Evaluate_Type;
      Parameters                 : in   Parameter_Array;
      Index                      : in   Parameter_Index_Type;
      Done                       : in   Boolean_Access
   ) return String is
   --------------------------------------------------------------------------

   begin
      if Trace_Expand then
         Put_Line ("expand evaluate");
      end if;

      return Numeric_Value (Expression.Expression.all.Expand (Parameters,
         Index, Done))'img;
   end Expand;

   --------------------------------------------------------------------------
   overriding
     function Expand (
        Expression               : in   Expression_Type;
        Parameters               : in   Parameter_Array;
        Index                    : in   Parameter_Index_Type;
        Done                     : in   Boolean_Access
     ) return String is
   --------------------------------------------------------------------------

   begin
not_Implemented;
return "";
   end Expand;

   --------------------------------------------------------------------------
   overriding
   function Expand (
      If_Else                    : in   If_Else_Type;
      Parameters                 : in   Parameter_Array;
      Index                      : in   Parameter_Index_Type;
      Done                       : in   Boolean_Access
   ) return String is
   --------------------------------------------------------------------------

   begin
      if Trace_Expand then
         Put_Line ("expand if else");
      end if;

      if If_Else.Condition.all.Evaluate (Parameters, Index, Done) then
         if Trace_Expand then
            Put_Line ("expand if true part");
         end if;

         if If_Else.True_Part = Null then
            if Trace_Expand then
               Put_Line ("empty true part");
            end if;

            return "";
         else
            return If_Else.True_Part.all.Expand (Parameters, Index, Done);
         end if;
      else
         if Trace_Expand then
            Put_Line ("expand if False part");
         end if;

         if If_Else.False_Part = Null then
            if Trace_Expand then
               Put_Line ("empty false part");
            end if;

            return "";
         else
            return If_Else.False_Part.all.Expand (Parameters, Index, Done);
         end if;
      end if;
   end Expand;

   --------------------------------------------------------------------------
   overriding
   function Expand (
      List                       : in   List_Type;
      Parameters                 : in   Parameter_Array;
      Index                      : in   Parameter_Index_Type;
      Done                       : in   Boolean_Access
   ) return String is
   --------------------------------------------------------------------------

   begin
      pragma Assert (List.Cell /= Null);

      if Trace_Expand then
         put_line ("expand list with " & Ada.Tags.Expanded_Name (List.Cell.all'tag));
      end if;

      if List.Next = Null then
         return List.Cell.all.Expand (Parameters, Index, Done);
      else
         return
            List.Cell.all.Expand (Parameters, Index, Done) &
            List.Next.all.Expand (Parameters, Index, Done);
      end if;
   end Expand;

   --------------------------------------------------------------------------
   function Expand (
      List                       : in   List_Type;
      Parameters                 : in   Parameter_Array
   ) return String is
   --------------------------------------------------------------------------

   begin
      return List.Expand (Parameters, No_Parameter_Index, Null);
   end Expand;

   --------------------------------------------------------------------------
   overriding
   function Expand (
      Not_Operator               : in   Not_Operator_Type;
      Parameters                 : in   Parameter_Array;
      Index                      : in   Parameter_Index_Type;
      Done                       : in   Boolean_Access
   ) return String is
   --------------------------------------------------------------------------

   begin
      pragma Unreferenced (Done, Index, Not_Operator, Parameters);
return "";
   end Expand;

   --------------------------------------------------------------------------
   overriding
   function Expand (
      Table                      : in   Table_Type;
      Parameters                 : in   Parameter_Array;
      Index                      : in   Parameter_Index_Type;
      Done                       : in   Boolean_Access
   ) return String is
   --------------------------------------------------------------------------

      ----------------------------------------------------------------------
      function Iterate_Table (
         Parameters        : in   Parameter_Array;
         Table          : in   Table_Type;
         Index          : in   Parameter_Index_Type;
         Done           : in   Boolean_Access
      ) return String is
      ----------------------------------------------------------------------

         Level_Done        : aliased Boolean := True;
         Result            : constant String := Table.List.all.Expand (Parameters,
                           Index, Level_Done'unchecked_access);

      begin
         if Trace_Expand then
            put_line ("done after table list expanded " & level_done'img &
               " top index" & Index (Index'first)'img &
               " levels " & Integer'image (Index'length));
         end if;

         if Done /= Null then
            Done.all := Level_Done;
         end if;

         if Level_Done then
            return "";
         else
            if Index'length = 1 then
               return Result & Iterate_Table (Parameters, Table,
                  (1 => Index (Index'first) + 1), Done);
            else
               return Result & Iterate_Table (Parameters, Table,
                  (1 => Index (Index'first) + 1) &
                  Index (Index'first + 1 .. Index'last),
                  Done);
            end if;
         end if;
      end Iterate_Table;
      ----------------------------------------------------------------------

   begin
      if Trace_Expand then
         put_line ("expand table level " & integer'image (index'length));
      end if;

      if Index'length = 0 then      -- first level table expansion
         return Iterate_Table (Parameters, Table, (1 => 1), Done);
      else                    -- Nested table
         return Iterate_Table (Parameters, Table, (1 => 1) & Index, Done);
      end if;
   end Expand;

   --------------------------------------------------------------------------
   overriding
   function Expand (
      Text              : in   Text_Type;
      Parameters           : in   Parameter_Array;
      Index             : in   Parameter_Index_Type;
      Done              : in   Boolean_Access
   ) return String is
   --------------------------------------------------------------------------

   begin
      pragma Unreferenced (Done, Index, Parameters);

      if Trace_Expand then
         put_line ("expand text");
      end if;

      return Text.Value;
   end Expand;

   --------------------------------------------------------------------------
   overriding
   function Expand (
      Unary_Operator       : in   Unary_Operator_Type;
      Parameters           : in   Parameter_Array;
      Index             : in   Parameter_Index_Type;
      Done              : in   Boolean_Access
   ) return String is
   --------------------------------------------------------------------------

   begin
      pragma Unreferenced (Done, Index, Parameters, Unary_Operator);
return "";
   end Expand;

   --------------------------------------------------------------------------
   overriding
   function Expand (
      Variable          : in   Variable_Type;
      Parameters           : in   Parameter_Array;
      Index             : in   Parameter_Index_Type;
      Done              : in   Boolean_Access
   ) return String is
   --------------------------------------------------------------------------

      Parameter            : Named_Parameter_Class_Access;

   begin
      if Trace_Expand then
         put_line ("expand variable " & Variable.Name.Coerce &
            " with index length " & Integer'image (Index'length));

         if Index'length > 0 then
            Put_Line ("first index" & Index (Index'first)'img);
         end if;
      end if;

      if Variable.Name = "TABLE_LINE"  then  -- return line # in current table
         if Index'length = 0 then         -- not in table
            return DumpString("0");
         else
            return DumpString(Ada_Lib.strings.Trim (Index (Index'first)'img));
         end if;
      end if;

      if Variable.Name = "TABLE_LEVEL"  then -- return table nesting level
         return DumpString(Ada_Lib.Strings.Trim (Integer'image (Index'length)));
      end if;

      Parameter := Find (Parameters, Variable.Name.Coerce);

      if Parameter = Null then
         return DumpString("");
      else
         return DumpString(Parameter.all.Value (Index, Done));
      end if;
   end Expand;

   --------------------------------------------------------------------------
   function Find (
      Parameters           : in   Parameter_Array;
      Name              : in   String
   ) return Named_Parameter_Class_Access is
   --------------------------------------------------------------------------

   begin
      for Index in Parameters'range loop
         if Parameters (Index).Name = Name then
            return Parameters (Index);
         end if;
      end loop;

      if Trace_Expand then
         Put_LIne ("parameter '" & Name & "'" & " not found");
      end if;
      return Null;
   end Find;

   --------------------------------------------------------------------------
   function Integer_Image (
      Target                     : in     Integer
   ) return String is
   --------------------------------------------------------------------------

   begin
      return Target'img;
   end Integer_Image;

   --------------------------------------------------------------------------
   function Load (
      Path                       : in     String
   ) return Parameter_Array is
   --------------------------------------------------------------------------

      Index                      : Positive := 1;
      Input                      : Ada.Text_IO.File_Type;
      Parameters                 : Parameter_Array (1 .. Max_Parameters);

   begin
      Log_In (Trace_Load, Quote ("path", Path));
      Ada.Text_IO.Open (Input, Ada.Text_IO.In_File, Path);

      while not Ada.Text_IO.End_Of_File (Input) loop
         declare
            Buffer               : String (1 .. 512);
            Last                 : Natural;

         begin
            Ada.Text_IO.Get_Line (Input, Buffer, Last);
            Log_Here (Trace_Load, Quote ("buffer", Buffer (Buffer'first .. Last)));

            declare
               Iterator          : Ada_Lib.Parser.Iterator_Type :=
                                    Ada_Lib.Parser.Initialize (
                                       Value    => Buffer (Buffer'first .. Last),
                                       Quotes   => """");

            begin
               while not Iterator.At_End loop
                  declare
                     Name        : constant String := Iterator.Get_Value (Do_Next => True);
                     Kind        : constant String := Iterator.Get_Value (Do_Next => True);
                     Value       : constant String := Iterator.Get_Value (Do_Next => True);

                  begin
                     Log_Here (Trace_Load, Quote ("name", Name) & Quote (" kind", Kind) &
                        Quote (" value", Value));

                     if Kind = "text" then
                        Parameters (Index) := new Ada_Lib.Template.Parameters.String_Parameter_Type'(
                           Name     => Ada_Lib.Strings.Unlimited.Coerce (Name),
                           Value    => Ada_Lib.Strings.Unlimited.Coerce (Value));
                     elsif Kind = "integer" then
                        Parameters (Index) := new Ada_Lib.Template.Parameters.Integer_Parameter_Type'(
                           Name     => Ada_Lib.Strings.Unlimited.Coerce (Name),
                           Target   => Integer'value (Value));
                     else
                        raise Bad_Parameter with Quote ("Unrecognized parameter kind", Kind);
                     end if;

                     Index := Index + 1;
                  end;
               end loop;
            end;
         end;
      end loop;

      Ada.Text_IO.Close (Input);
      Log_Out (Trace_Load);
      return Parameters (1 .. Index - 1);

   exception
      when Ada.IO_Exceptions.Name_Error =>
         declare
            Message              : constant String :=
                                    Quote ("could not open parameter file ", Path);
         begin
            Log_Out (Trace_Compile, Message);
            raise Not_Found with Message;
         end;

--    when GNAT.Directory_Operations.Directory_Error =>
--       Log_Out (Trace_Compile, "Invalid directory " & Path);
--       raise Not_Found;
--    Log_Out (Trace_Load);
--    return Result;
   end Load;

-- --------------------------------------------------------------------------
-- procedure Set (
--    Parameter            : in out Boolean_Parameter_Type;
--    Value             : in   Boolean) is
-- --------------------------------------------------------------------------
--
-- begin
--    Parameter.Target := Value;
-- end Set;

   --------------------------------------------------------------------------
   procedure Set (
      Parameter            : in out Boolean_Array_Parameter_Type;
      Index             : in   Positive;
      Value             : in   Boolean) is
   --------------------------------------------------------------------------

   begin
      if Index > Parameter.Value'length then
         Ada.Exceptions.Raise_Exception (Index_Error'identity,
            "Index" & Index'img & " out of bounds for " & Parameter.Name.Coerce);
      end if;

      Parameter.Value (Index) := Value;
   end Set;

-- --------------------------------------------------------------------------
-- procedure Set (
--    Parameter            : in out Unlimited_String_Type;
--    Value             : in   String) is
-- --------------------------------------------------------------------------
--
-- begin
--    Parameter.Construct (Value);
-- end Set;

-- --------------------------------------------------------------------------
-- procedure Append (
--    Parameter            : in out Unlimited_String_Type;
--    Value             : in   String) is
-- --------------------------------------------------------------------------
--
-- begin
--    Parameter.Append (Value);
-- end Append;

   --------------------------------------------------------------------------
   procedure Set (
      Parameter                  : in out String_Parameter_Type;
      Index                      : in   Positive;
      Value                      : in   String) is
   pragma Unreferenced (Index);
   --------------------------------------------------------------------------

   begin
      Parameter.Value.Construct (Value);
   end Set;

   --------------------------------------------------------------------------
   procedure Set (
      Parameter            : in out Integer_Array_Parameter_Type;
      Index             : in   Positive;
      Value             : in   Integer) is
   --------------------------------------------------------------------------

   begin
      if Index > Parameter.Value'length then
         Ada.Exceptions.Raise_Exception (Index_Error'identity,
            "Index" & Index'img & " out of bounds for " & Parameter.Name.Coerce);
      end if;

      Parameter.Value (Index) := Value;
   end Set;

   --------------------------------------------------------------------------
   procedure Set (
      Parameter            : in out String_Array_Parameter_Type;
      Index             : in   Positive;
      Value             : in   String) is
   --------------------------------------------------------------------------

   begin
      if Index > Parameter.Value'length then
         Ada.Exceptions.Raise_Exception (Index_Error'identity,
            "Index" & Index'img & " out of bounds for " & Parameter.Name.Coerce);
      end if;

      Parameter.Value (Index).Construct (Value);
   end Set;

   --------------------------------------------------------------------------
   procedure Set (
      Parameter                  : in out Vector_Parameter_Type;
      Index                      : in   Positive;
      Pointer                    : in   Named_Parameter_Class_Access) is
   --------------------------------------------------------------------------

   begin
      if Index > Parameter.Contents'length then
         Ada.Exceptions.Raise_Exception (Index_Error'identity,
            "Index" & Index'img & " out of bounds for " & Parameter.Name.Coerce);
      end if;

      Parameter.Contents (Index) := Pointer;
   end Set;

-- --------------------------------------------------------------------------
-- function Value (
--    Parameter            : in   Parameter_Type;
--    Index             : in   Parameter_Index_Type;
--    Done              : in   Boolean_Access
-- ) return String is
-- --------------------------------------------------------------------------
--
-- begin
--    raise Bad_Parameter;
--    return "";
-- end Value;

-- --------------------------------------------------------------------------
-- function Value (
--    Parameter            : in   Boolean_Parameter_Type;
--    Index             : in   Parameter_Index_Type;
--    Done              : in   Boolean_Access
-- ) return String is
-- --------------------------------------------------------------------------
--
-- begin
--    pragma Unreferenced (Done, Index);
--    return Parameter.Target'img;
-- end Value;

   --------------------------------------------------------------------------
   overriding
   function Value (
      Parameter            : in   Boolean_Array_Parameter_Type;
      Index             : in   Parameter_Index_Type;
      Done              : in   Boolean_Access
   ) return String is
   --------------------------------------------------------------------------

      Adjusted          : constant Positive := Adjusted_Index (Index);

   begin
      if Adjusted <= Parameter.Value'last then
         if Done /= Null then
            Done.all := False;
         end if;

         return Parameter.Value (Adjusted)'img;
      else
         return "";
      end if;
   end Value;

-- --------------------------------------------------------------------------
-- function Value (
--    Parameter            : in   Integer_Parameter_Type;
--    Index             : in   Parameter_Index_Type;
--    Done              : in   Boolean_Access
-- ) return String is
-- --------------------------------------------------------------------------
--
-- begin
--    pragma Unreferenced (Done, Index);
--    return Ada_Lib.Strings.Trim (Parameter.Target'img);
-- end Value;

   --------------------------------------------------------------------------
   overriding
   function Value (
      Parameter            : in   Integer_Array_Parameter_Type;
      Index             : in   Parameter_Index_Type;
      Done              : in   Boolean_Access
   ) return String is
   --------------------------------------------------------------------------

      Adjusted          : constant Positive := Adjusted_Index (Index);

   begin
      if Adjusted <= Parameter.Value'last then
         if Done /= Null then
            Done.all := False;
         end if;

-- put_line ("integer array parameter value" & parameter.value(adjusted)'img & " index" & adjusted'img);
         return Ada_Lib.Strings.Trim (
            Parameter.Value (Adjusted)'img);
      else
         return "0";
      end if;
   end Value;

   --------------------------------------------------------------------------
   overriding
   function Value (
      Parameter            : in   String_Parameter_Type;
      Index             : in   Parameter_Index_Type;
      Done              : in   Boolean_Access
   ) return String is
   --------------------------------------------------------------------------

   begin
      pragma Unreferenced (Done, Index);
      return Parameter.Value.Coerce;
   end Value;

   --------------------------------------------------------------------------
   function Value (
      Text                       : in     Text_Type
   ) return String is
   --------------------------------------------------------------------------

   begin
      return Text.Contents.Coerce;
   end Value;

-- --------------------------------------------------------------------------
-- function Value (
--    Parameter            : in   Unlimited_String_Type;
--    Index             : in   Parameter_Index_Type;
--    Done              : in   Boolean_Access
-- ) return String is
-- --------------------------------------------------------------------------
--
-- begin
--    pragma Unreferenced (Done, Index);
--    return Ada_Lib.Strings.Bounded.To_String (Parameter.Value);
-- end Value;

   --------------------------------------------------------------------------
   overriding
   function Value (
      Parameter            : in   String_Array_Parameter_Type;
      Index             : in   Parameter_Index_Type;
      Done              : in   Boolean_Access
   ) return String is
   --------------------------------------------------------------------------

      Result                     : Unlimited_String_Type;

   begin
      for Value of Parameter.Value loop
         Result.Append (Value);
      end loop;

      return Result.Coerce;
   end Value;

   --------------------------------------------------------------------------
   overriding
   function Value (
      Parameter            : in   Vector_Parameter_Type;
      Index             : in   Parameter_Index_Type;
      Done              : in   Boolean_Access
   ) return String is
   --------------------------------------------------------------------------

   begin
      if Trace_Expand then
         put_line ("expand vector level " & integer'image (Index'length));
      end if;

      if Index'length = 0 or else
            Index (Index'first) > Parameter.Vector_Length then
         if Trace_Expand then
            put_Line ("no more values");
         end if;

         return "";
      end if;

      if Done /= Null then
         if Trace_Expand then
            put_line ("not done");
         end if;

         Done.all := False;
      end if;

      if Trace_Expand then
         put_line ("vector index" & Index (Index'first)'img);
      end if;

      if Index'length > 1 then
         return Parameter.Contents (Index (Index'first)).all.Value (
            Index (Index'first + 1 .. Index'last), Done);
      else
         return Parameter.Contents (Index (Index'first)).all.Value (No_Parameter_Index, Done);
      end if;
   end Value;


end Ada_Lib.Template.Parameters;

