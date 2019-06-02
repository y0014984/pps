params [
		["_stringTableKey", "STR_PPS_Main_Missing_Stringtable_Key", [""]], 
		["_firstVariable", "", ["", 0, true]], 
		["_secondVariable", "", ["", 0, true]]
	];

hint format [(_stringTableKey call BIS_fnc_localize), _firstVariable, _secondVariable];