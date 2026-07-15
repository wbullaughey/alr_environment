with Ada.Streams;

package Ada_Lib.Net is

   -- The default Write operation treats a String as an array of Character
   -- and loops over the String writing each Character. For network
   -- operations this is undesirable as it results in lots of 1-byte
   -- packets. Instead, coerce a String to a Message and use Message'Write
   -- to send the string as a single (or at most a few) packets.

   type Message is new String;

   procedure Message_Write
      (Stream              : access Ada.Streams.Root_Stream_Type'Class;
       Item             : in     Message);

   for Message'Write use Message_Write;

end Ada_Lib.Net;
