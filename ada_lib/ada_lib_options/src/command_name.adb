with Ada.Command_Line;
with Ada.Strings.Fixed;

function Command_Name return String is

   Path              : constant String := Ada.Command_Line.Command_Name;
   Start             : Natural;

begin
   Start := Ada.Strings.Fixed.Index (Path, "/", Ada.Strings.Backward);

   if Start = 0 then
      Start := Path'first;
   else
      Start := Start + 1;
   end if;

   return Path (Start .. Path'last);
end Command_Name;

