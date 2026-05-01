with Ada_Lib.Strings;
with Ada_Lib.Socket_IO.Stream_IO;
-- with GNAT.Sockets;

package Ada_Lib.Telnet is

   Failed                  : exception;

   type Telnet_Type (
      Description    : Ada_Lib.Strings.String_Constant_Access
                        ) is tagged limited private;
   procedure Close (
      Telnet               : in out Telnet_Type);

   procedure Open (
      Telnet               :   out Telnet_Type;
      Host              : in   String);

   -- return what ever is in the input buffer (max 4096)
   function Receive (
      Telnet               : access Telnet_Type;
      Wait_Time            : in   Duration := 0.0
   ) return String;

   procedure Send (
      Telnet               : in out Telnet_Type;
      Line              : in   String);

   procedure Set_Trace (
      State             : in   Boolean);

   procedure Wait_For (
      Telnet               : in out Telnet_Type;
      Pattern              : in   String;
      At_End               : in   Boolean := False;
      At_Start          : in   Boolean := False);

private

   type Telnet_Type (
      Description    : Ada_Lib.Strings.String_Constant_Access
                        ) is tagged limited record
      Socket         : Ada_Lib.Socket_IO.Stream_IO.Stream_Socket_Type (
                        Description);
   end record;

end Ada_Lib.Telnet;

