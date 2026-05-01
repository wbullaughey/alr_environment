package Ada_Lib.OS.Base64 is

   function Decode (
      Encoded                     : in     String
   ) return String;

   function Encode (
      Source                     : in     String
   ) return String;

end Ada_Lib.OS.Base64;
