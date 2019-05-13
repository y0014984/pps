[
	"PPS",
	"openPpsDialog",
	["PPS Menü öffnen", "Öffnet das PPS Menü und erlaubt Einsicht der Statisitik"],
	{_this call PPS_fnc_openPpsDialog}, 
	"", 
	[DIK_P, [false, false, true]]
] call CBA_fnc_addKeybind;