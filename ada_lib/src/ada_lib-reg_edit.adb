-- utility to apply a regular expression to a string resulting in a transformation
with Ada.Characters.Handling;
with Ada.Unchecked_Deallocation;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada.Text_IO; use Ada.Text_IO;
with Ada_Lib.Trace; use Ada_Lib.Trace;

package body Ada_Lib.Reg_Edit is

-- use type Ada_Lib.Strings.Unlimited.String_Type;
   use GNAT.Regpat;

   procedure Deallocate is new Ada.Unchecked_Deallocation (
      Object                  => Match_Class'class,
      Name                    => Match_Class_Access);

   procedure Deallocate is new Ada.Unchecked_Deallocation (
      Object                  => Replace_Class'class,
      Name                    => Replace_Class_Access);

   ---------------------------------------------------------------
   procedure Dump (
      Match                   : in     Match_Class;
      Add_New_Line            : in     Boolean := True) is
   ---------------------------------------------------------------

   begin
      Put ("match expression '" & Match.Expression & "'");
      if Add_New_Line then
         New_Line;
      end if;
   end Dump;

   ---------------------------------------------------------------
   overriding
   procedure Dump (
      Replace                 : in     Replace_Class;
      Add_New_Line            : in     Boolean := True) is
   ---------------------------------------------------------------

   begin
      Match_Class (Replace).Dump (False);
      Put (" recipe '" & Replace.Recipe & "'");
      if Add_New_Line then
         New_Line;
      end if;
   end Dump;

   ---------------------------------------------------------------
   procedure Free (
      Match                   : in out Match_Class_Access) is
   ---------------------------------------------------------------

   begin
      Deallocate (Match);
   end Free;

   ---------------------------------------------------------------
   procedure Free (
      Replace                 : in out Replace_Class_Access) is
   ---------------------------------------------------------------

   begin
      Deallocate (Replace);
   end Free;

   ---------------------------------------------------------------
   function Get_Expression (
      Object                  : in     Match_Class
   ) return String is
   ---------------------------------------------------------------

   begin
      return Object.Expression;
   end Get_Expression;

   ---------------------------------------------------------------
   function Get_Recipe (
      Object                  : in     Replace_Class
   ) return String is
   ---------------------------------------------------------------

   begin
      return Object.Recipe;
   end Get_Recipe;

   ---------------------------------------------------------------
   function Initialize (
      Expression              : in     String;
      Flags                   : in     Flags_Type := No_Flags
   ) return Match_Class is
   ---------------------------------------------------------------

      Matcher                 : constant Matcher_Type := Compile (Expression, Flags);

   begin
      declare
         Object                  : Match_Class (Expression'length,  Matcher.Size);

      begin
         Object.Expression := Expression;
         Object.Matcher := Matcher;
         return Object;
      end;
   end Initialize;

   ---------------------------------------------------------------
   function Initialize (
      Expression              : in     String;
      Flags                   : in     Flags_Type := No_Flags
   ) return Match_Class_Access is
   ---------------------------------------------------------------

      Matcher                 : constant Matcher_Type := Compile (Expression, Flags);

   begin
      declare
         Object                  : constant Match_Class_Access :=
                                    new Match_Class (Expression'length,  Matcher.Size);

      begin
         Object.Expression := Expression;
         Object.Matcher := Matcher;
         return Object;
      end;
   end Initialize;

   ---------------------------------------------------------------
   overriding
   function Initialize (
      Expression              : in     String;
      Flags                   : in     Flags_Type := No_Flags
   ) return Replace_Class is
   ---------------------------------------------------------------

   begin
      raise Error with "Replace_Class not supported with no recipe";
      return Initialize (" ", " ");
   end Initialize;

   ---------------------------------------------------------------
   function Initialize (
      Expression              : in     String;
      Recipe                  : in     String;
      Flags                   : in     Flags_Type := No_Flags
   ) return Replace_Class is
   ---------------------------------------------------------------

      Matcher                 : constant Matcher_Type := Compile (Expression, Flags);

   begin
      declare
         Object               : Replace_Class (
                                 Expression'length,  Recipe'length, Matcher.Size);

      begin
         Object.Expression := Expression;
         Object.Matcher := Matcher;
         Object.Recipe := Recipe;
         return Object;
      end;
   end Initialize;

   ---------------------------------------------------------------
   function Initialize (
      Expression              : in     String;
      Recipe                  : in     String;
      Flags                   : in     Flags_Type := No_Flags
   ) return Replace_Class_Access is
   ---------------------------------------------------------------

      Matcher                 : constant Matcher_Type := Compile (Expression, Flags);

   begin
      declare
         Object               : constant Replace_Class_Access :=
                                 new Replace_Class (Expression'length,  Recipe'length, Matcher.Size);

      begin
         Object.Expression := Expression;
         Object.Matcher := Matcher;
         Object.Recipe := Recipe;
         return Object;
      end;
   end Initialize;

   ---------------------------------------------------------------
   function Match (
      Object                  : in     Match_Class;
      Data                    : in     String
   ) return Boolean is
   ---------------------------------------------------------------

   begin
      Log (Ada_Lib_LIB_Debug, Here, Who & " data '" & Data & "'");
      return Match (Object.Matcher, Data);
   end Match;

   ---------------------------------------------------------------
   function Replace (
      Object                  : in     Match_Class;
      Data                    : in     String;
      Recipe                  : in     String
   ) return String is
   ---------------------------------------------------------------

      Fields                  : constant Match_Count := Paren_Count (Object.Matcher);
      Matches                 : Match_Array (1 .. Fields);
      Result                  : Ada_Lib.Strings.Unlimited.String_Type;
      Recipe_Index            : Natural := Recipe'first;

   begin
      Log (Ada_Lib_LIB_Debug, Here, Who & " data '" & Data & "' Recipe '" & Recipe & "'");
      Match (Object.Matcher, Data, Matches);

      while Recipe_Index <= Recipe'last loop
         declare
            C                 : constant Character := Recipe (Recipe_Index);
            Stored            : Boolean := False;

         begin
            if C = '\' then
               if Recipe_Index > Recipe'last then
                  raise Error with "trailing \";
               end if;

               declare
                  N        : constant Character := Recipe (Recipe_Index + 1);

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
                              Result := Result & Data (Index);
                           end loop;
                           Stored := True;
                           Recipe_Index := Recipe_Index + 2;
                        end;
                     end;
                  else
                     raise Error with "invalid character after \";
                  end if;
               end;
            end if;
         if not Stored then
            Result := Result & C;
            Recipe_Index := Recipe_Index + 1;
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

   ---------------------------------------------------------------
   function Replace (
      Object                  : in     Replace_Class;
      Data                    : in     String
   ) return String is
   ---------------------------------------------------------------

   begin
      return Object.Replace (Data, Object.Recipe);
   end Replace;

end Ada_Lib.Reg_Edit;

