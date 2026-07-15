-- with Ada_Lib.Database;

package Ada_Lib.Database.Common is

   Failed                        : exception;

   procedure Wild_Get (
      Database                   : in out Ada_Lib.Database.Database_Type'class);

end Ada_Lib.Database.Common;
