[
	"PPS_ValuesUpdateInterval",
	"LIST",
	["Aktualierungsintervall", "Die Dauer in Sekunden zwischen 2 Updates, die der Client an den Server sendet. "],
	"PPS Client Einstellungen",
	[
		[5, 10, 15],
		[["5 sec", "5 Sekunden"], ["10 sec", "10 Sekunden"], ["15 sec", "15 Sekunden"]], 
		0
	],
    nil, // "_isGlobal" flag. Set this to true to always have this setting synchronized between all clients in multiplayer
    {  
        params ["_value"];
		
		_playerName = name player;
		_playerUid = getPlayerUID player;
		
		diag_log format ["[%1] PPS Player changed Setting PPS_ValuesUpdateInterval to %4: %2 (%3)", serverTime, _playerName, _playerUid, _value];
    } // function that will be executed once on mission start and every time the setting is changed.
] call cba_settings_fnc_init;

[
	"PPS_AllowSendingData",
	"Checkbox",
	["Daten senden erlauben", "Nur wenn diese Einstellung aktiv ist werden Daten an den Server gesendet. "],
	"PPS Client Einstellungen",
	true,
    nil, // "_isGlobal" flag. Set this to true to always have this setting synchronized between all clients in multiplayer
    {  
        params ["_value"];
		
		_playerName = name player;
		_playerUid = getPlayerUID player;
		
		diag_log format ["[%1] PPS Player changed Setting PPS_AllowSendingData to %4: %2 (%3)", serverTime, _playerName, _playerUid, _value];
    } // function that will be executed once on mission start and every time the setting is changed.
] call cba_settings_fnc_init;

[
	"PPS_TimeZone",
	"LIST",
	["Zeitzone", "Die Zeitzone, in der sie spielen. Hiervon hängen die Zeitangaben im PPS Menü ab. "],
	"PPS Client Einstellungen",
	[
		[0, 1, 2],
		[["UTC+0", "Großbritannien"], ["UTC+1", "Deutschland"], ["UTC+2", "Ukraine"]], 
		1
	],
    nil, // "_isGlobal" flag. Set this to true to always have this setting synchronized between all clients in multiplayer
    {  
        params ["_value"];
		
		_playerName = name player;
		_playerUid = getPlayerUID player;
		
		diag_log format ["[%1] PPS Player changed Setting PPS_TimeZone to %4: %2 (%3)", serverTime, _playerName, _playerUid, _value];
    } // function that will be executed once on mission start and every time the setting is changed.
] call cba_settings_fnc_init;

[
	"PPS_SummerTime",
	"Checkbox",
	["Sommerzeit", "Befinden sie sich in einem Land mit Sommerzeit? "],
	"PPS Client Einstellungen",
	true,
    nil, // "_isGlobal" flag. Set this to true to always have this setting synchronized between all clients in multiplayer
    {  
        params ["_value"];
		
		_playerName = name player;
		_playerUid = getPlayerUID player;
		
		diag_log format ["[%1] PPS Player changed Setting PPS_SummerTime to %4: %2 (%3)", serverTime, _playerName, _playerUid, _value];
    } // function that will be executed once on mission start and every time the setting is changed.
] call cba_settings_fnc_init;
