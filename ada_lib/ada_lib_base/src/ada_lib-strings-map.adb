-- package providing utilities for subscribing to database deamon

with Ada.Strings.Hash;
with Ada.Text_IO; use Ada.Text_IO;
with Ada_Lib.Trace; use Ada_Lib.Trace;

package body Ada_Lib.Strings.Map is


    ---------------------------------------------------------------------------
   overriding
   procedure Finalize (
      Element        : in out Abstract_Element_Type) is
    ---------------------------------------------------------------------------

    begin
      Log (Ada_Lib_Lib_Debug, Here, Who & " enter");
      Ada_Lib.Strings.Free_All (Element.Key);
      Log (Ada_Lib_Lib_Debug, Here, Who & " exit");
    end Finalize;

    ---------------------------------------------------------------------------
    function Get_Key (
        Element        : in      Abstract_Element_Type
    ) return String is
    ---------------------------------------------------------------------------

    begin
      return Element.Key.all;
    end Get_Key;

    ---------------------------------------------------------------------------
   function Hash (
      Key                     : in     Key_Type
   ) return Ada.Containers.Hash_Type is
    ---------------------------------------------------------------------------

   begin
      return Ada.Strings.Hash (Key.all);
   end Hash;

    ---------------------------------------------------------------------------
   procedure Iterator_Callback (
      Element                    : in out Abstract_Element_Type;
      Parameter                  : in out Abstract_Iterator_Parameter_Type'class;
      Stop                       :    out Boolean) is
    ---------------------------------------------------------------------------

   begin
      raise Failed with "Iterator_Callback not overriden";
   end Iterator_Callback;

    ---------------------------------------------------------------------------
   function Key_Equal (
      Left                    : in     Key_Type;
      Right                   : in     Key_Type
   ) return Boolean is
    ---------------------------------------------------------------------------

   begin
      return Left.all = Right.all;
   end Key_Equal;

   ---------------------------------------------------------------
   procedure Store_Element (
        Element             : in     Abstract_Element_Type;
        File                     : in out Ada.Text_IO.File_Type) is
   ---------------------------------------------------------------

   begin
      Log (Ada_Lib_Lib_Debug, Here, Who & " " & Element.Key.all);

      Put (File, Element.Key.all);
   end Store_Element;


   package body Generic_Map is

         ---------------------------------------------------------------------------
         procedure Add (
            Map                        : in out Map_Type;
            Name                       : in     String;
            Element                    : in     Element_Class_Access) is
         pragma Unreferenced (Map, Name, Element);
         ---------------------------------------------------------------------------

--       Local_Key                     : constant access String := new String'(Name);

         begin
null;
pragma Assert (False, "not implemented at " & Here);
--          Map_Package.Insert (Map, Local_Key, Element);
         end Add;

       ---------------------------------------------------------------------------
         function Find (
            Map                        : in     Map_Type;
            Key                        : in     String
         ) return Element_Class_Access is
       ---------------------------------------------------------------------------

         Local_Key                     : aliased String := Key;

       begin
          return Map_Package.Element (Map, Local_Key'unchecked_access);
       end Find;

--      ---------------------------------------------------------------
--      function Has_Element (
--         Cursor                     : in     Cursor_Type
--      ) return Boolean is
--      ---------------------------------------------------------------
--
--      begin
-- return false;
--      end Has_Element;

      ---------------------------------------------------------------
      function Has_Element (
         Map                        : in     Map_Type;
         Key                        : in     String
      ) return Boolean is
      ---------------------------------------------------------------

         Local_Key                  : aliased String := Key;

      begin
         return Map_Package.Contains (Map, Local_Key'unchecked_access);
      end Has_Element;

      ---------------------------------------------------------------
      procedure Iterate (
         Map                        : in out Map_Type;
         Parameter                  : in out Iterator_Parameter_Type'class) is
      ---------------------------------------------------------------

         Cursor                     : Cursor_Type := Map.First;
         Last                       : Boolean := not Has_Element (Cursor);

      begin
         Log_Here ("enter");
         Parameter.Map := Map'unchecked_access;

         while not Last loop
            declare
               Current_Element      : constant Element_Class_Access := Map_Package.Element (Cursor);
               Next_Element         : constant Cursor_Type := (if Last then
                                          Map_Package.No_Element
                                       else
                                          Next (Cursor));
               Stop                 : Boolean := False;

            begin
               Current_Element.Iterator_Callback (Parameter, Stop);
               if Stop then
                  return;
               end if;
               Last := not Has_Element (Cursor);
               Cursor := Next_Element;
            end;
         end loop;
      end Iterate;

--    procedure Iterate (
--       Container                  : in     Map;
--       Process                    : not null access procedure (
--          Position                : in     Cursor)) is
--
--    begin
--       return Map.Iterate
--    end Iterate;
--
--    function Iterate (
--       Container                  : in     Map)
--    ) return Map_Iterator_Interfaces.Forward_Iterator'Class;
--    ---------------------------------------------------------------
--    procedure Query_Element (
--          Position                    : in    Cursor_Type;
--          Process                     : not null access procedure (
--              Element                 : in    Element_Class_Access)) is
--    ---------------------------------------------------------------
--
--          ---------------------------------------------------------------
--          procedure Callback (
--              Key                         : in    Key_Type;
--              Element                     : in    Element_Class_Access) is
--          ---------------------------------------------------------------
--
--          begin
--              Log (Ada_Lib_Lib_Debug, Here, Who & " Key '" & Key.all & "'");
--              Process (Element);
--          end Callback;
--          ---------------------------------------------------------------
--
--      begin
--          Map_Package.Query_Element (Position, Callback'access);
--      end Query_Element;

--    ---------------------------------------------------------------
--    procedure Visit_All (
--       Map                        : in out Map_Type;
--       Visit                      : access procedure (
--          Element                 : in out Element_Type'class)) is
--    ---------------------------------------------------------------
--
--       Cursor                     : Cursor_Type := Map.First;
--
--    begin
--      while Map_Package.Has_Element (Cursor) loop
--          Visit (Map_Package.Element (Cursor).all);
--
--          Cursor := Map_Package.Next (Cursor);
--      end loop;
--    end Visit_All;

--    ---------------------------------------------------------------
--    procedure Visit_All_Constant (
--       Map                        : in     Map_Type;
--       Visit                      : access procedure (
--          Element                 : in     Element_Type'class)) is
--    ---------------------------------------------------------------
--
--          Cursor                  : Cursor_Type := Map.First;
--
--    begin
--      while Map_Package.Has_Element (Cursor) loop
--          Visit (Map_Package.Element (Cursor).all);
--
--          Cursor := Map_Package.Next (Cursor);
--      end loop;
--    end Visit_All_Constant;

   end Generic_Map;

end Ada_Lib.Strings.Map;

