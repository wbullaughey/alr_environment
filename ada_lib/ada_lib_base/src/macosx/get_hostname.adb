with Interfaces.C;
with System;

function Get_Hostname return String is

    use type Interfaces.C.int;

    function gethostname  (
      Name                    : in System.Address;
         Len                     : in Interfaces.C.size_t
    ) return Interfaces.C.int;

    pragma Import (C, gethostname, "gethostname");

    C_Name                       : Interfaces.C.char_array (0 .. 255);

begin
    if gethostname (C_Name'Address, C_Name'Length) >= 0 then
        return Interfaces.C.To_Ada (C_Name);
    else
        return "";
    end if;
end Get_Hostname;

