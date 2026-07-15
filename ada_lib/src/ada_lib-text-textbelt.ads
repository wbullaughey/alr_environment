package Ada_Lib.Text.Textbelt is

   Failed                        : exception;

   procedure Send (
      Phone_Number               : in     String;
      Contents                   : in     String;
      Verbose                    : in     Boolean := False);

private

   procedure Parse (
      Line                       : in     String;
      Success                    : in out Boolean;
      Quota                      : in out Natural);

end Ada_Lib.Text.Textbelt;
