with Ada.Characters.Handling;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace; use Ada_Lib.Trace;

package body Ada_Lib.Strings.Reg_Edit is

   use GNAT.Regpat;
-- use type Ada_Lib.Strings.Unlimited.String_Type;

   ---------------------------------------------------------------
   function Compile (
      Expression              : in     String;
      Flags                   : in     Flags_Type := No_Flags
   ) return Matcher_Access is
   ---------------------------------------------------------------

      Matcher                 : constant Matcher_Type := Compile (Expression, Flags);
      Result                  : constant Matcher_Access := new Matcher_Type(Matcher.size);

   begin
      Log_Here ("expression '" & Expression & "'");
      Result.all := Matcher;
      return Result;
   end Compile;

   ---------------------------------------------------------------
   function Replace (
      Matcher                 : in     Matcher_Type;
      Source                  : in     String;
      Target                  : in     String
   ) return String is
   ---------------------------------------------------------------

      Fields                  : constant Match_Count := Paren_Count (Matcher);
      Matches                 : Match_Array (1 .. Fields);
      Result                  : Ada_Lib.Strings.Unlimited.String_Type;
      Target_Index            : Natural := Target'first;

   begin
      Log (Ada_Lib_LIB_Debug, Here, Who & " source '" & Source & "' target '" & Target & "'");
      Match (Matcher, Source, Matches);

      while Target_Index < Target'last loop
         declare
            C                 : constant Character := Target (Target_Index);
            Stored            : Boolean := False;

         begin
            if C = '\' then
               if Target_Index > Target'last then
                  raise Error with "trailing \";
               end if;

               declare
                  N        : constant Character := Target (Target_Index + 1);

               begin
                  if Ada.Characters.Handling.Is_Digit (N) and then N /= '0' then
                     declare
                        Match_Index : constant Positive := character'pos (N) - character'pos ('0') ;

                     begin
                        Log (Ada_Lib_LIB_Debug, Here, Who & " match_index" & match_index'img & " Fields" & Fields'img);
                        if Match_Index > Natural (Fields) then
                           raise Error with "Non existent \ field" & Match_Index'img;
                        end if;

                        declare
                           Match : Match_Location renames Matches (Match_Index);

                        begin
                           if Match = No_Match then
                              raise Error with "\ field" & Match_Index'img & " did not match";
                           end if;

                           Log (Ada_Lib_LIB_Debug, Here, Who & " first" & Match.First'img & " last " & Match.Last'img);
                           for Index in Match.First .. Match.Last loop
                              Result := Result & Source (Index);
                           end loop;
                           Stored := True;
                           Target_Index := Target_Index + 2;
                        end;
                     end;
                  else
                     raise Error with "invalid character after \";
                  end if;
               end;
            end if;
         if not Stored then
            Result := Result & C;
            Target_Index := Target_Index + 1;
         end if;
         end;
      end loop;

      declare
         Value                : constant String := Result.Coerce;

      begin
         Log (Ada_Lib_LIB_Debug, Here, Who & " result '" & Value & "'");
         return Value;
      end;
   end Replace;

begin
   Ada_Lib_LIB_Debug := False;
end Ada_Lib.Strings.Reg_Edit;
