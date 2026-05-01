with Ada.Characters.Handling;
with Ada_Lib.Strings.Unlimited;use Ada_Lib.Strings.Unlimited;
with Ada_Lib.Trace; use Ada_Lib.Trace;

package body Ada_Lib.Strings.HTML is

   type Ampersand_Table_Type is record
      C                          : Character;
      S                          : Ada_Lib.Strings.String_Access;
   end record;

   Ampersand_Table               : constant array (Positive range <>) of Ampersand_Table_Type := (
      (
         C => '&',
         S => new String'("&amp;")
      ),(
         C => '"',
         S => new String'("&quot;")
      ),(
         C => '<',
         S => new String'("&lt;")
      ),(
         C => '>',
         S => new String'("&gt;")
      )
   );
   Ada_Lib_LIB_Debug                         : constant Boolean := False;

   function Is_Encoded (
      Source                     : in     String
   ) return Boolean;

   ---------------------------------------------------------------
   function Decode (
      Source                     : in     String
   ) return String is
   ---------------------------------------------------------------

      Result                     : String (1 .. Source'last);
      Result_Index               : Positive := Result'first;
      Source_Index               : Natural := Source'first;

   begin
      Log (Ada_Lib_LIB_Debug, Here, Who & " '" & Source & "'");
      while Source_Index <= Source'last loop
         Log (Ada_Lib_LIB_Debug, Here, Who & Source_Index'img);
         if Is_Encoded (Source (Source_Index .. Source'last))  then
            declare
               Numbers            : Natural := 0;

            begin
               for Index in Source_Index + 2 .. Source_Index + 4 loop
                  if Ada.Characters.Handling.Is_Digit (Source (Index)) then
                     Numbers := Numbers + 1;
                  else
                     Exit;
                  end if;
               end loop;
               Result (Result_Index) := Character'val (Natural'value (
                  Source (Source_Index + 2 .. Source_Index + Numbers + 1)));
               Source_Index := Source_Index + Numbers + 2;
            end;
         else
            declare
               Stored            : Boolean := False;

            begin
               if Source (Source_Index) = '&' then
                  declare
                     Left              : constant Natural := Source'length - Source_Index + 1;

                  begin
                     for Index in Ampersand_Table'range loop
                        declare
                           Data        : Ampersand_Table_Type renames Ampersand_Table (Index);
                           Length      : constant Positive := Data.S.all'length;

                        begin
                           Log (Ada_Lib_LIB_Debug, Here, Who & " " & Data.S.all & " left" & Left'img &
                              " '" & Source (Source_Index .. Source'last));

                           if    Left >= Length and then
                                 Source (Source_Index .. Source_Index + Length - 1) = Data.S.all then
                              Result (Result_Index) := Data.C;
                              Source_Index := Source_Index + Length;
                              Stored := True;
                              exit;
                           end if;
                        end;
                     end loop;
                  end;
               end if;

               if not Stored then
                  Result (Result_Index) := Source (Source_Index);
                  Source_Index := Source_Index + 1;
               end if;
            end;
         end if;
         Result_Index := Result_Index + 1;
      end loop;

      Log (Ada_Lib_LIB_Debug, Here, Who & " '" & Result (Result'first .. Result_Index - 1) & "'");
      return Result (Result'first .. Result_Index - 1);
   end Decode;

   ---------------------------------------------------------------
   function Encode (
      Source                     : in     String
   ) return String is
   ---------------------------------------------------------------

--    use Ada_Lib.Strings.Unlimited;

      Result                     : Ada_Lib.Strings.Unlimited.String_Type;

   begin
      for Index in Source'range loop
         declare
            Letter               : constant Character := Source (Index);

         begin
            if    Ada.Characters.Handling.Is_ISO_646 (Letter) then
               case Letter is
                  when '&' =>
                     Result := Result & "&amp;";

                  when '"' =>
                     Result := Result & "&quot;";

                  when '<' =>
                     Result := Result & "&lt;";

                  when '>' =>
                     Result := Result & "&gt;";

                  when others =>
                     Result := Result & Letter;

               end case;
            else
               Result := Result & "&#" & Trim (Natural'image (Character'pos (Letter)));
            end if;
         end;
      end loop;

      Log (Ada_Lib_LIB_Debug, Here, Who & " '" & Source & "' => '" & Result.Coerce & "'");
      return Result.Coerce;
   end Encode;

   ---------------------------------------------------------------
   function Is_Encoded (
      Source                     : in     String
   ) return Boolean is
   ---------------------------------------------------------------

      Result                     : constant Boolean :=
                                    Source'length >= 3 and then (
                                    Source (Source'first) = '&' and then
                                    Source (Source'first + 1) = '#' and then
                                    Ada.Characters.Handling.Is_Digit (Source (Source'first + 2)));

   begin
      Log (Ada_Lib_LIB_Debug, Here, Who & " '" & Source & "' result " & Result'img);
      return result;
   end Is_Encoded;


end Ada_Lib.Strings.HTML;

