with Ada.Text_IO; use Ada.Text_IO;
with Ask;
with Ada_Lib.String_Quote; use Ada_Lib.String_Quote;
--with Ada_Lib.Trace; use Ada_Lib.Trace;

procedure Test_Ask is

   Integer_Value           : Integer := 0;
   Float_Value             : Float := 0.0;

begin
   loop
      declare
         Read           : constant Character := Ask.Ask_Character ("prompt");

      begin
         Put_Line ("got '" & Read & "'");

         case Read is
            when 'i' =>
               Ask.Ask_Integer ("integer 1", Integer_Value);
               Put_Line ("integer" & Integer_Value'img);
               Ask.Ask_Integer ("integer 2", Integer_Value);
               Put_Line ("integer" & Integer_Value'img);


            when 'f' =>
               Ask.Ask_float ("float 1", Float_Value, 1, 2);
               Put_Line ("float" & Float_Value'img);
               Ask.Ask_float ("float 2", Float_Value, 1, 2);
               Put_Line ("float" & Float_Value'img);

            when 's' =>
               declare
                  Answer         : constant String := Ask.Ask_String ("enter a string");

               begin
                  Put_Line (Quote ("got string", Answer));
               end;

            when 'x' =>
               Put_Line ("exit");
               exit;

            when others =>
               Put_Line ("huh");

         end case;
      end;
   end loop;
end Test_Ask;