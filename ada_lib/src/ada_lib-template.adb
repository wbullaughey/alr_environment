with Ada.Characters.Handling;
-- with Ada.Characters.Latin_1;
-- with Ada.Exceptions;
-- with Ada.IO_Exceptions;
with Ada.Strings.Fixed;
with Ada.Strings.Maps.Constants;
-- with Ada.Tags;
-- with Ada.Text_IO; use Ada.Text_IO;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
-- with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
-- with Ada_Lib.Template.Parameters;
-- with Ada_Lib.Template.Token;
with Ada_Lib.Trace; use Ada_Lib.Trace;

package body Ada_Lib.Template is

--   use type Ada.Strings.Maps.Character_Set;
--   use type Unlimited_String_Type;
--   use type Ada.Tags.Tag;
--   use type Ada_Lib.Template.Token.Token_Class;
--
--   type Nested_Type        is (
--      In_Else,
--      In_If,
--      In_Table,
--      Top_Level
--   );
--
--   function Image(
--      Operator          : in   Terminal_Type
--   ) return String;
--
--   type Symbol_Type              is record
--      Name                       : Ada_Lib.Strings.String_Access;
--      Opcode                     : Terminal_Type;
--   end record;
--
--   Symbols                 : constant array (Positive range <>) of
--                           Symbol_Type := (
--      (
--         Name     => new String'("+"),
--         Opcode      => Add_Token
--      ),
--      (
--         Name     => new String'("and"),
--         Opcode      => And_Token
--      ),
--      (
--         Name     => new String'("="),
--         Opcode      => Equal_Token
--      ),
--      (
--         Name     => new String'(">"),
--         Opcode      => Greater_Token
--      ),
--      (
--         Name     => new String'(">="),
--         Opcode      => Greater_Equal_Token
--      ),
--      (
--         Name     => new String'("<"),
--         Opcode      => Less_Token
--      ),
--      (
--         Name     => new String'("<="),
--         Opcode      => Less_Equal_Token
--      ),
--      (
--         Name     => new String'("/="),
--         Opcode      => Not_Equal_Token
--      ),
--      (
--         Name     => new String'("not"),
--         Opcode      => Not_Token
--      ),
--      (
--         Name     => new String'("or"),
--         Opcode      => Or_Token
--      ),
--      (
--         Name     => new String'("-"),
--         Opcode      => Subtract_Token
--      )
--   );
--
--   type Terminal_Definition_Type
--                        is record
--      Name              : Ada_Lib.Strings.String_Access;
--      Terminal          : Terminal_Type;
--   end record;
--
--   Terminal_Table          : constant array (Positive range <>) of
--                           Terminal_Definition_Type := (
--      (
--         Name     => new String'("END_TABLE"),
--         Terminal => End_Table_Token
--      ),
--      (
--         Name     => new String'("ELSE"),
--         Terminal => Else_Token
--      ),
--      (
--         Name     => new String'("ELSIF"),
--         Terminal => Elsif_Token
--      ),
--      (
--         Name     => new String'("IF"),
--         Terminal => If_Token
--      ),
--      (
--         Name     => new String'("END_IF"),
--         Terminal => End_If_Token
--      ),
--      (
--         Name     => new String'("EVAL"),
--         Terminal => Evaluate_Token
--      ),
--      (
--         Name     => new String'("TABLE"),
--         Terminal => Table_Token
--      )
--   );
--
--   White_Space_Set             : constant Ada.Strings.Maps.Character_Set :=
--                           Ada.Strings.Maps.To_Set (' ') or
--                           Ada.Strings.Maps.To_Set (
--                              Ada.Characters.Latin_1.HT) or
--                           Ada.Strings.Maps.To_Set (
--                              Ada.Characters.Latin_1.CR) or
--                           Ada.Strings.Maps.To_Set (
--                              Ada.Characters.Latin_1.LF);
--
--   ----------------------------------------------------------------------
--   function Image(
--      Operator          : in   Terminal_Type
--   ) return String is
--   ----------------------------------------------------------------------
--
--   begin
--      case Operator is
--         when Not_Token => return "not";
--         when Add_Token => return "add";
--         when Subtract_Token => return "sub";
--         when Greater_Token => return "gt";
--         when Greater_Equal_Token => return "ge";
--         when Less_Token => return "lt";
--         when Less_Equal_Token => return "le";
--         when And_Token => return "and";
--         when Or_Token => return "or";
--         when Equal_Token => return "eq";
--         when Not_Equal_Token => return "ne";
--      end case;
--   end;
--
   --------------------------------------------------------------------------
   function Dumpstring (
      Arg                        : in     String
   ) return String is
   --------------------------------------------------------------------------

     begin
         Log_Here (Trace_Expand, Quote (Arg));
         return Arg;
     end Dumpstring;

   --------------------------------------------------------------------------
   function Adjusted_Index (
      Index             : in   Parameter_Index_Type
   ) return Positive is
   --------------------------------------------------------------------------

   begin
      if Index'length = 0 then
         return 1;
      else
         return Index (Index'first);
      end if;
   end Adjusted_Index;

   --------------------------------------------------------------------------
   procedure Initialize (
      Parameter                  : in out Named_Parameter_Type;
      Name                       : in     String) is
   --------------------------------------------------------------------------

   begin
      Parameter.Name := Ada_Lib.Strings.Unlimited.Coerce (Name);
   end Initialize;

  --------------------------------------------------------------------------
  function Is_Numeric (
     Source               : in   String
  ) return Boolean is
  --------------------------------------------------------------------------

  begin
     if Source'length = 0 then
        return False;
     end if;

     declare
        Start          : Positive;
        Trimmed_1         : constant String := Ada_Lib.Strings.Trim (Source);

     begin
        if Trimmed_1 (Trimmed_1'first) = '-' then
           Start := Trimmed_1'first + 1;
        else
           Start := Trimmed_1'first;
        end if;

        declare
           Trimmed_2      : constant String := Ada_Lib.Strings.Trim (
                          Trimmed_1 (Start .. Trimmed_1'last));

        begin
           return Ada.Characters.Handling.Is_Digit (Trimmed_2 (Trimmed_2'first));
        end;
     end;
  end Is_Numeric;

  --------------------------------------------------------------------------
   overriding
   function Name (
      Parameter                  : in     Named_Parameter_Type
   ) return String is
  --------------------------------------------------------------------------

   begin
      return Parameter.Name.Coerce;
   end Name;

  --------------------------------------------------------------------------
  function Numeric_Value (
     Source               : in   String
  ) return Integer is
  --------------------------------------------------------------------------

  begin
     if Source'length = 0 then
        return 0;
     end if;

     declare
        Sign           : Integer := 1;
        Start          : Positive;
        Trimmed_1         : constant String := Ada_Lib.Strings.Trim (Source);

     begin
        if Trimmed_1 (Trimmed_1'first) = '-' then
           Sign := -1;
           Start := Trimmed_1'first + 1;
        else
           Start := Trimmed_1'first;
        end if;

        declare
           Trimmed_2   : constant String := Ada_Lib.Strings.Trim (Trimmed_1 (
                       Start .. Trimmed_1'last));

        begin
           if Ada.Characters.Handling.Is_Digit (Trimmed_2 (Trimmed_2'first)) then
              declare
                 End_Digits     : Natural;

              begin
                 End_Digits := Ada.Strings.Fixed.Index (Trimmed_2,
                       Ada.Strings.Maps.Constants.Decimal_Digit_Set,
                         Ada.Strings.Outside);

                 if End_Digits = 0 then
                    End_Digits := Trimmed_2'last;
                 end if;

                 return Sign *Integer'value (Trimmed_2 (
                    Trimmed_2'first ..End_Digits));
              end;
           else
              return 0;
           end if;
        end;
     end;
  end Numeric_Value;

begin
-- Trace_Compile := True;
   Log_Here (Trace_Compile);
end Ada_Lib.Template;
