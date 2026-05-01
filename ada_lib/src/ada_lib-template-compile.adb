
with Ada.Characters.Latin_1;
with Ada.IO_Exceptions;
with Ada.Strings.Maps.Constants;
with Ada.Strings.Fixed;
with Ada.Tags;
with Ada.Text_IO; use Ada.Text_IO;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
-- with Ada_Lib.Template.Parameters;
with Ada_Lib.Template.Token;
-- with Ada_Lib.Template.Trace;
with Ada_Lib.Trace; use Ada_Lib.Trace;
with GNAT.Directory_Operations;

package body Ada_Lib.Template.Compile is

   use type Ada_Lib.Template.Parameters.List_Access;
-- use type Ada_Lib.Strings.Unlimited.String_Type;

   type Nested_Type        is (
      In_Else,
      In_If,
      In_Table,
      Top_Level
   );

   type String_Access         is access String;

   type Terminal_Definition_Type
                        is record
      Name              : String_Access;
      Terminal          : Terminal_Type;
   end record;

-- type Symbol_Type        is record
--    Name              : String_Access;
--    Opcode               : Terminal_Type;
-- end record;

   use type Ada.Strings.Maps.Character_Set;
   use type Ada.Tags.Tag;
   use type Token.Token_Class;
-- use type Terminal_Type;
-- use type Unlimited_String_Type;

   Terminal_Table          : constant array (Positive range <>) of
                           Terminal_Definition_Type := (
      (
         Name     => new String'("END_TABLE"),
         Terminal => End_Table_Token
      ),
      (
         Name     => new String'("ELSE"),
         Terminal => Else_Token
      ),
      (
         Name     => new String'("ELSIF"),
         Terminal => Elsif_Token
      ),
      (
         Name     => new String'("IF"),
         Terminal => If_Token
      ),
      (
         Name     => new String'("END_IF"),
         Terminal => End_If_Token
      ),
      (
         Name     => new String'("EVAL"),
         Terminal => Evaluate_Token
      ),
      (
         Name     => new String'("TABLE"),
         Terminal => Table_Token
      ),
      (
         Name     => new String'("+"),
         Terminal      => Add_Token
      ),
      (
         Name     => new String'("-"),
         Terminal      => Subtract_Token
      ),
      (
         Name     => new String'("and"),
         Terminal      => And_Token
      ),
      (
         Name     => new String'("="),
         Terminal      => Equal_Token
      ),
      (
         Name     => new String'(">"),
         Terminal      => Greater_Token
      ),
      (
         Name     => new String'(">="),
         Terminal      => Greater_Equal_Token
      ),
      (
         Name     => new String'("<"),
         Terminal      => Less_Token
      ),
      (
         Name     => new String'("<="),
         Terminal      => Less_Equal_Token
      ),
      (
         Name     => new String'("/="),
         Terminal      => Not_Equal_Token
      ),
      (
         Name     => new String'("<>"),
         Terminal      => Not_Equal_Token
      ),
      (
         Name     => new String'("not"),
         Terminal      => Not_Token
      ),
      (
         Name     => new String'("or"),
         Terminal      => Or_Token
      )
   );

   White_Space_Set             : constant Ada.Strings.Maps.Character_Set :=
                           Ada.Strings.Maps.To_Set (' ') or
                           Ada.Strings.Maps.To_Set (
                              Ada.Characters.Latin_1.HT) or
                           Ada.Strings.Maps.To_Set (
                              Ada.Characters.Latin_1.CR) or
                           Ada.Strings.Maps.To_Set (
                              Ada.Characters.Latin_1.LF);

   --------------------------------------------------------------------------
   function Compile (
      Template                   : in out Template_Type;
      File_Contents              : in     String;
      Parameters                 : in     Ada_Lib.Template.Parameters.Parameter_Array :=
                                             Ada_Lib.Template.Parameters.No_Parameters
   ) return String is
   --------------------------------------------------------------------------

      function Next_Token (
         In_Expression     : in   Boolean
      ) return Ada_Lib.Template.Token.Token_Class;

      procedure Parse_Expression (
         Expression        :   out Ada_Lib.Template.Parameters.Expression_Class_Access);

      procedure Process_Source (
         Nesting           : in   Nested_Type;
         List           :   out Ada_Lib.Template.Parameters.List_Access);

      function Parse_Terminal
      return Ada_Lib.Template.Token.Token_Class;

      function Parse_Text (
         In_Expression     : in   Boolean
      ) return Ada_Lib.Template.Token.Token_Class;

      function Parse_Variable
      return Ada_Lib.Template.Token.Token_Class;

      procedure Return_Token (
         Returned       : in   Ada_Lib.Template.Token.Token_Class);

      Parsed               : Unlimited_String_Type;
      Source               : Unlimited_String_Type;

      ----------------------------------------------------------------------
      function Create_Evaluate (
         Expression           : in   Ada_Lib.Template.Parameters.Expression_Class_Access
      ) return Ada_Lib.Template.Parameters.Construct_Class_Access is
      ----------------------------------------------------------------------

         Evaluate          : Ada_Lib.Template.Parameters.Evaluate_Access;

      begin
         Evaluate := new Ada_Lib.Template.Parameters.Evaluate_Type;

         Evaluate.Expression := Expression;
         return Ada_Lib.Template.Parameters.Construct_Class_Access (Evaluate);
      end Create_Evaluate;

      ----------------------------------------------------------------------
      function Create_Table (
         List              : in   Ada_Lib.Template.Parameters.List_Access
      ) return Ada_Lib.Template.Parameters.Construct_Class_Access is
      ----------------------------------------------------------------------

         Table             : Ada_Lib.Template.Parameters.Table_Access;

      begin
         Table := new Ada_Lib.Template.Parameters.Table_Type;
         Table.List := List;
         return Ada_Lib.Template.Parameters.Construct_Class_Access (Table);
      end Create_Table;

      ------------------------------------------------------------------
      procedure Do_If (
         Construct               :   out Ada_Lib.Template.Parameters.Construct_Class_Access) is
      ------------------------------------------------------------------

         If_Else                 : Ada_Lib.Template.Parameters.If_Else_Access;

      begin
         Log_In (Trace_Compile, "do if");

         If_Else := new Ada_Lib.Template.Parameters.If_Else_Type;

         Parse_Expression (If_Else.Condition);
         Process_Source (In_If,If_Else.True_Part); -- get true part of if
         If_Else.False_Part := Null;

         Construct := Ada_Lib.Template.Parameters.Construct_Class_Access (If_Else);

         declare
            Next     : constant Ada_Lib.Template.Token.Token_Class := Next_Token (False);

         begin
            if Next'tag = Ada_Lib.Template.Token.Terminal_Token_Type'tag then
               case Ada_Lib.Template.Token.Terminal (
                     Ada_Lib.Template.Token.Terminal_Token_Type (Next)) is

                  when Ada_Lib.Template.Else_Token =>
                     -- parse else part
                     Process_Source (In_Else, Ada_Lib.Template.Parameters.List_Access (If_Else.False_Part));

                  when Ada_Lib.Template.Elsif_Token =>
                     Do_If (If_Else.False_Part);

                  when Ada_Lib.Template.End_If_Token =>
                     Null;    -- no else part

                  when others =>
                     Log_Out (Trace_Compile, "unexpected Ada_Lib.Template.token " & Ada_Lib.Template.Token.Image (Next));
                     raise Syntax_Error;

               end case;
            else
               Log_Out (Trace_Compile, "unexpected Ada_Lib.Template.token " & Ada_Lib.Template.Token.Image (Next));
               raise Syntax_Error;
            end if;
         end;
      end do_If;

      ----------------------------------------------------------------------
      function Find_Parameter (
         Variable                : in     String
      ) return String is
      ----------------------------------------------------------------------

         Done                    : aliased Boolean;

      begin
         Log_In (Trace_Compile, Quote ("variable", Variable));
         for Parameter of Parameters loop
            Log_Here (Trace_Compile, Quote ("parameter", Parameter.Name));
            if Parameter.Name = Variable then
               declare
                  Result         : constant String :=
                                    Parameter.Value (No_Parameter_Index, Done'unchecked_access);
               begin
                  Log_Out (Trace_Compile, Quote ("result", Result));
                  return Result;
               end;
            end if;
         end loop;

         raise No_Parameter with Variable & " not found at " & Here;
      end Find_Parameter;

      ----------------------------------------------------------------------
      function Next_Token (
         In_Expression     : in   Boolean
      ) return Ada_Lib.Template.Token.Token_Class is
      ----------------------------------------------------------------------

      begin
         Log_In (Trace_Compile, "in expression " & In_Expression'img &
            Quote (" source element 1,2 ", String'(Source.Coerce) (1 .. 2)) &
            " source length" & Source.Length'img);

         if In_Expression then
            Source.Trim (Ada.Strings.Left);
         end if;

         if Source.Length = 0 then
            return Ada_Lib.Template.Token.End_Of_File_Token;
         end if;

         if Source.Element (1) = '@' then  -- start terminal
            Log_Here (Trace_Compile, Quote ("1st", Source.Element (1)) &
               Quote ("2nd", Source.Element (2)));

            case Source.Element (2) is

               when '_' =>                   -- start variable
                  Log_Out (Trace_Compile);
                  return Parse_Variable;

               when '@' =>                   -- start Ada_Lib.Template.token
                  Log_Out (Trace_Compile);
                  return Parse_Terminal;

               when others =>
                  Null;

            end case;
         end if;
         Log_Here (Trace_Compile);
         declare
            Result               : constant Ada_Lib.Template.Token.Token_Class :=
                                    Parse_Text (In_Expression);

         begin
            Log_Out (Trace_Compile, Quote ("result", Result.Image));
            return Result;
         end;
      end Next_Token;

      ----------------------------------------------------------------------
      procedure Parse_Expression (
         Expression        :   out Ada_Lib.Template.Parameters.Expression_Class_Access) is
      ----------------------------------------------------------------------

         Next           : constant Ada_Lib.Template.Token.Token_Class := Next_Token (True);

      begin
         Log_In (Trace_Compile, "parse expression. first Ada_Lib.Template.token " &
            Ada_Lib.Template.Token.Image (Next));

         if Ada_Lib.Template.Token.Simple (Next) then
            declare
               Lookahead   : constant Ada_Lib.Template.Token.Token_Class := Next_Token (True);

            begin
               Log_Here (Trace_Compile, "first Ada_Lib.Template.token is simple. " &
                  Ada_Lib.Template.Token.Image (Next) & " lookahead is " &
                  Ada_Lib.Template.Token.Image (Lookahead));

               if Lookahead'tag = Ada_Lib.Template.Token.Operator_Token_Type'tag and then
                     Ada_Lib.Template.Token.Operator (Ada_Lib.Template.Token.Operator_Token_Type (Lookahead))
                        in Binary_Opcodes_Type then

                  Log_Here (Trace_Compile, "binary operator");

                  declare
                     Right_Expression  : Ada_Lib.Template.Parameters.Expression_Class_Access;

                  begin
                     Parse_Expression (Right_Expression);
                     Expression := Ada_Lib.Template.Token.Create (
                        Ada_Lib.Template.Token.Create (Next),
                        Ada_Lib.Template.Token.Source_Token_Type (Lookahead),
                        Right_Expression);
                  end;
               else
                  Log_Here (Trace_Compile, "final operand of expression");

                  Return_Token (Lookahead);
                  Expression :=  Ada_Lib.Template.Token.Create (Next);
               end if;

            end;
         elsif Next'tag = Ada_Lib.Template.Token.Operator_Token_Type'tag then
            if Ada_Lib.Template.Token.Operator (Ada_Lib.Template.Token.Operator_Token_Type (Next))
                  in Unary_Opcodes_Type then
               declare
                  Operator_Expression : Ada_Lib.Template.Parameters.Expression_Class_Access;

               begin
                  Parse_Expression (Operator_Expression);

                  Expression := Ada_Lib.Template.Token.Create (
                     Ada_Lib.Template.Token.Source_Token_Type (Next),
                     Operator_Expression);
               end;
            else
Expression := null;
            end if;
         else
            Log_Out (Trace_Compile, "unexpected " & Ada_Lib.Template.Token.Image (Next));
            raise Syntax_Error;
         end if;

      end Parse_Expression;

      ----------------------------------------------------------------------
      procedure Process_Source (
         Nesting           : in   Nested_Type;
         List           :   out Ada_Lib.Template.Parameters.List_Access) is
      ----------------------------------------------------------------------

         Head              : Ada_Lib.Template.Parameters.List_Access := Null;
         Tail              : Ada_Lib.Template.Parameters.List_Access;

         ------------------------------------------------------------------
         procedure Create_Entry (
            Value          : in   Ada_Lib.Template.Parameters.Construct_Class_Access) is
         ------------------------------------------------------------------

            New_Entry      : Ada_Lib.Template.Parameters.List_Access;

         begin
            New_Entry := new Ada_Lib.Template.Parameters.List_Type'(
               Cell => Value,
               Next => Null);

            if Head = Null then
               Head := New_Entry;
               Tail := Head;
            else
               Tail.Next := New_Entry;
               Tail := New_Entry;
            end if;
         end Create_Entry;

         ------------------------------------------------------------------

         In_Expression     : constant Boolean := False;

      begin
         Log_In (Trace_Compile, "parse list nesting " & Nesting'img);

         loop
            declare
               Next        : constant Ada_Lib.Template.Token.Token_Class := Next_Token (In_Expression);

            begin
               Log_Here (Trace_Compile, "Ada_Lib.Template.token " & Ada_Lib.Template.Token.Image (Next));

               if Next = Ada_Lib.Template.Token.End_Of_File_Token then
                  Log_Here (Trace_Compile);
                  exit;
               end if;

               if Ada_Lib.Template.Token.Simple (Next) then
                  Log_Here (Trace_Compile, "create simple");

                  Create_Entry (Ada_Lib.Template.Token.Create (Next));
               elsif Next'tag = Ada_Lib.Template.Token.Terminal_Token_Type'tag then
                  Log_Here (Trace_Compile, "next " & Next.Image);

                  case Ada_Lib.Template.Token.Terminal (
                        Ada_Lib.Template.Token.Terminal_Token_Type (Next)) is

                     when Ada_Lib.Template.Else_Token | Ada_Lib.Template.Elsif_Token =>
                        Log_Here (Trace_Compile, "else/elsif");

                        if Nesting /= In_If then
                           Log_Out (Trace_Compile, "no matching @@IF@@ for @@ELSE@@ or @@ELSIF@@");
                           raise Syntax_Error;
                        end if;
                        Return_Token (Next);
                        exit;

                     when Ada_Lib.Template.End_If_Token =>
                        Log_Here (Trace_Compile, "end if nesting " & Nesting'img);

                        case Nesting is

                           when In_If =>
                              Return_Token (Next);

                           when In_Else =>
                              null;

                           when others =>
                              Log_Out (Trace_Compile, "no matching @@IF@@ for @@END_IF@@");
                              raise Syntax_Error;

                        end case;
                        exit;

                     when Ada_Lib.Template.Evaluate_Token =>
                        declare
                           Expression  : Ada_Lib.Template.Parameters.Expression_Class_Access;

                        begin
                           Log_Here (Trace_Compile, "create eval");

                           Parse_Expression (Expression);
                           Create_Entry (Create_Evaluate (
                              Expression));
                        end;

                     when Ada_Lib.Template.If_Token =>
                        Log_Here (Trace_Compile, "create do if");
                        declare
                           Construct : Ada_Lib.Template.Parameters.Construct_Class_Access;

                        begin
                           Do_If (Construct);
                           Create_Entry (Construct);
                        end;

                     when Ada_Lib.Template.End_Table_Token =>
                        Log_Here (Trace_Compile, "end table nesting " & Nesting'img);

                        if Nesting /= In_Table then
                           Log_Out (Trace_Compile, "unmatched @@END_TABLE@@ found");
                           raise Syntax_Error;
                        end if;

                        Log_Here (Trace_Compile, "end table");
                        exit;

                     when Ada_Lib.Template.Table_Token =>
                        declare
                           List     : Ada_Lib.Template.Parameters.List_Access;

                        begin
                           Process_Source (In_Table, List);

                           Log_Here (Trace_Compile, "create table");
                           Create_Entry (Create_Table (List));
                        end;

                     when Ada_Lib.Template.Add_Token |
                           Ada_Lib.Template.And_Token |
                           Ada_Lib.Template.Equal_Token |
                           Ada_Lib.Template.Greater_Token |
                           Ada_Lib.Template.Greater_Equal_Token |
                           Ada_Lib.Template.Less_Token |
                           Ada_Lib.Template.Less_Equal_Token |
                           Ada_Lib.Template.Not_Token |
                           Ada_Lib.Template.Not_Equal_Token |
                           Ada_Lib.Template.Or_Token |
                           Ada_Lib.Template.Subtract_Token =>
not_implemented;
                  end case;
               else
                  pragma Assert (False);
                  null;
               end if;

            end;
         end loop;

         List := Head;
         Log_Out (Trace_Compile, "end list");
      end Process_Source;

      ----------------------------------------------------------------------
      function Parse_Text (
         In_Expression           : in   Boolean
      ) return Ada_Lib.Template.Token.Token_Class is
      ----------------------------------------------------------------------

         End_Field               : Natural;
         First                   : Positive;
         Last                    : Natural;
         Start_Token             : Natural;
         Start_Variable          : Natural;

      begin
         Log_In (Trace_Compile, "parse text in expression " & In_Expression'img);

         Start_Token := Source.Index ("@@");
         Start_Variable := Source.Index ("@_");

         if Start_Token = 0 then
            if Start_Variable = 0 then
               End_Field := 0;
            else
               End_Field := Start_Variable;
            end if;
         else
            if Start_Variable = 0 then
               End_Field := Start_Token;
            else
               End_Field := Natural'Min (Start_Token, Start_Variable);
            end if;
         end if;

         Log_Here (Trace_Compile, "start token" & Start_Token'img & " variable" & Start_Variable'img &
            " in expression " & In_Expression'img);

         Source.Find_Token (White_Space_Set,
            Ada.Strings.Outside, First, Last);
         Log_Here (Trace_Compile, "first" & First'img & " last" & Last'img);

         if Last > 0 and then (
               End_Field = 0 or else First < End_Field) then
            declare
               Symbol   : constant String := Source.Slice (First, Last);

            begin
               Log_Here (Trace_Compile, Quote ("symbol", Symbol));
               for Index in Terminal_Table'range loop
                  if Symbol = Terminal_Table (Index).Name.all then
                     if In_Expression then
                        Parsed.Append (Source.Slice (1, Last));
                        Source.Delete (1, Last);

                        return Ada_Lib.Template.Token.Operator_Token_Type'(
                           Operator         => Terminal_Table (Index).Terminal);
                     else
not_implemented;
                     end if;
                  end if;
               end loop;

               -- not a Terminal, set End_Field to white space after Terminal
               End_Field := Last + 1;
            end;
         end if;

         if End_Field = 0 then         -- all the rest is text
            End_Field := Source.Length;
         else
            End_Field := End_Field - 1;
         end if;

         declare
            Result         : constant Ada_Lib.Template.Token.Token_Class :=
                           Ada_Lib.Template.Token.String_Token (
                              Source.Slice (1, End_Field));

         begin
            Parsed.Append (Source.Slice (1, End_Field));
            Source.Delete (1, End_Field);
            return Result;
         end;
      end Parse_Text;

      ----------------------------------------------------------------------
      function Parse_Terminal
      return Ada_Lib.Template.Token.Token_Class is
      ----------------------------------------------------------------------

         End_Field      : Natural;

      begin
         Log_In (Trace_Compile, "parse terminal");

         Source.Delete (1, 2);
         End_Field := Source.Index ("@");

         if (End_Field = 0 or else Source.Length < End_Field + 1)
               or else  Source.Element (End_Field) /= '@' then
            Log_Out (Trace_Compile, "matching @@ missing");
            raise Syntax_Error;
         end if;

         declare
            Terminal             : constant String := Ada.Strings.Fixed.Translate (
                                    Source.Slice (1, End_Field - 1),
                                    Ada.Strings.Maps.Constants.Upper_Case_Map);

         begin
            Log_Here (Trace_Compile, Quote ("Terminal", Terminal));
            Parsed.Append (Source.Slice (1, End_Field - 1));
            Source.Delete (1, End_Field + 1);

            for Index in Terminal_Table'range loop
               if Terminal = Terminal_Table (Index).Name.all then
                  declare
                     Result      : constant Ada_Lib.Template.Token.Token_Class :=
                                    Ada_Lib.Template.Token.Terminal_Token (
                                       Terminal_Table (Index).Terminal);
                  begin
                     Log_Out (Trace_Compile, Ada_Lib.Template.Token.Terminal_Token (
                        Terminal_Table (Index).Terminal).Image);
                     return Result;
                  end;
               end if;
            end loop;

            Log_Out (Trace_Compile, "Unrecognized terminal @@" & Terminal & "@@");
            raise Syntax_Error;
         end;

--       return Ada_Lib.Template.Null_Token;
      end Parse_Terminal;

      ----------------------------------------------------------------------
      function Parse_Variable
      return Ada_Lib.Template.Token.Token_Class is
      ----------------------------------------------------------------------

         End_Field      : constant Natural := Source.Index ("_@");

      begin
         Log_In (Trace_Compile, "end" & End_Field'img);

         if End_Field = 0 then
            Log_Out (Trace_Compile, "missing closing '_@'");
            raise Syntax_Error with "missing closing '_@'";
         end if;

         declare
            Result               : constant Ada_Lib.Template.Token.Token_Class :=
                                    Ada_Lib.Template.Token.Variable_Token (Source.Slice (3, End_Field - 1));
            Variable             : constant String := Source.Slice (3, End_Field - 1);
            Delete_To            : constant Natural := End_Field + 1;

         begin
            Log_Here (Trace_Compile, Quote ("append", Variable) & " delete to" & Delete_To'img);
            Parsed.Append (Find_Parameter (Variable));
            Source.Delete (1, End_Field + 1);
            Log_Out (Trace_Compile, "result " & Result.Image);
            return Result;
         end;
      end Parse_Variable;
      ----------------------------------------------------------------------
      procedure Return_Token (
         Returned       : in   Ada_Lib.Template.Token.Token_Class) is
      ----------------------------------------------------------------------

         Parsed_Length     : constant Natural := Parsed.Length;
         Returned_Length      : constant Natural := Ada_Lib.Template.Token.Length (Returned);

      begin
         Log_In (Trace_Compile, "return '" & Parsed.Slice (
            Parsed_Length - Returned_Length + 1, Parsed_Length) & "'");

         Source.Insert (1, Parsed.Slice (Parsed_Length - Returned_Length + 1, Parsed_Length));
         Parsed.Delete (Parsed_Length - Returned_Length + 1, Parsed_Length);
      end Return_Token;
      ----------------------------------------------------------------------

   begin
      Source.Construct (File_Contents);
      Process_Source (Top_Level, Template.List);
      return Parsed.Coerce;
   end Compile;

   --------------------------------------------------------------------------
   -- preload templates
   function Load (
      Path                       : in   String
   ) return String is
   --------------------------------------------------------------------------

      Buffer                     : String (1 .. 512);
      Input                      : Ada.Text_IO.File_Type;
      Last                       : Natural;
      Source                     : Unlimited_String_Type;

   begin
      Log_In (Trace_Load, Quote ("path", Path));
      Ada.Text_IO.Open (Input, Ada.Text_IO.In_File, Path);

      while not Ada.Text_IO.End_Of_File (Input) loop
         Ada.Text_IO.Get_Line (Input, Buffer, Last);
         Log_Here (Trace_Load, Quote ("buffer", Buffer (Buffer'first .. Last)) & " last" & Last'img);

         Source := Source & Buffer (Buffer'first .. Last) &
--          Ada.Characters.Latin_1.CR &
            Ada.Characters.Latin_1.LF;
      end loop;

      Ada.Text_IO.Close (Input);
      Log_Out (Trace_Compile, Quote ("loaded", Source));
      return Source.Coerce;

   exception
      when Ada.IO_Exceptions.Name_Error =>
         Log_Out (Trace_Compile, Quote ("could not open template file ", Path));
         raise Not_Found with Quote ("could not open template file ", Path);

      when GNAT.Directory_Operations.Directory_Error =>
         Log_Out (Trace_Compile, "Invalid directory " & Path);
         raise Not_Found;
   end Load;

end Ada_Lib.Template.Compile;
