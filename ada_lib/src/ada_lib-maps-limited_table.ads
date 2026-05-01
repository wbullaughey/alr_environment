with Ada.Containers.Hashed_Maps;
with Ada.Finalization;
with Ada_Lib.Maps.Element;

generic

	type Element_Type			is new Ada_Lib.Maps.Element.Limited_Element_Type with private;
	type Element_Access			is access all Element_Type'class;

	type Initializer_Type		is private;

	with function Allocator (
		Initializer				: in	 Initializer_Type
	) return Element_Access;

	Name						: in String;

package Ada_Lib.Maps.Limited_Table is

	Not_Found					: exception;

	type Cursor_Type			is tagged private;

	function Element (
		Cursor					: in	 Cursor_Type
	) return Element_Access;

	type Map_Type				is new Ada.Finalization.Limited_Controlled with private;

	procedure Add (
		Table					: in out Map_Type;
		Key						: in	 String;
		Initializer				: in	 Initializer_Type;
		New_Element				:	 out Element_Access);

	procedure Delete (
		Table					: in out Map_Type;
		Key						: in	 String);

	function Exists (
		Cursor					: in	 Cursor_Type
	) return Boolean;

	function Find (
		Table					: in	 Map_Type;
		Key						: in	 String
	) return Cursor_Type'class;

	function Get (
		Table					: in	 Map_Type;
		Key						: in	 String
	) return Element_Access;

	function Get (
		Cursor					: in	 Cursor_Type
	) return Element_Access;

	function Is_In (
		Table					: in	 Map_Type;
		Key						: in	 String
	) return Boolean;

	type Callback_Access 		is not null access procedure (
		Position				: in	 Cursor_Type);
	 
   procedure Iterate (
		Table 					: in	 Map_Type;
		Callback   				: in	 Callback_Access);

	function Length (
		Table					: in	 Map_Type
	) return Natural;

private

	function "=" (
		Left, Right				: in	 Element_Access
	) return Boolean;

	package Table_Package 		is new Ada.Containers.Hashed_Maps (
		Key_Type            => Ada_Lib.Maps.Element.Key_Type,
		Element_Type        => Element_Access,
		Hash                => Ada_Lib.Maps.Element.Hash,
		Equivalent_Keys     => Ada_Lib.Maps.Element.Equivalent_Keys,
		"="                 => "=");

	type Cursor_Type		is tagged record
		Cursor				: Table_Package.Cursor;
	end record;

	type Map_Type			is new Ada.Finalization.Limited_Controlled with record
		Map					: Table_Package.Map;
	end record;

end Ada_Lib.Maps.Limited_Table;
