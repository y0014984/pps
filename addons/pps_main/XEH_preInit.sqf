[
	"PPS_UpdateInterval",
	"LIST",
	[localize "STR_PPS_Main_Settings_Update_Interval", localize "STR_PPS_Main_Settings_Update_Interval_Description"],
	localize "STR_PPS_Main_Settings_Category_Client_Settings",
	[
		[5, 10, 15],
		[
			[localize "STR_PPS_Main_Settings_Update_Interval_Value_5_sec", localize "STR_PPS_Main_Settings_Update_Interval_Value_5_sec_long"], 
			[localize "STR_PPS_Main_Settings_Update_Interval_Value_10_sec", localize "STR_PPS_Main_Settings_Update_Interval_Value_10_sec_long"], 
			[localize "STR_PPS_Main_Settings_Update_Interval_Value_15_sec", localize "STR_PPS_Main_Settings_Update_Interval_Value_15_sec_long"] 
		], 
		0
	],
    nil, // "_isGlobal" flag. Set this to true to always have this setting synchronized between all clients in multiplayer
    {  
        params ["_value"];
    } // function that will be executed once on mission start and every time the setting is changed.
] call cba_settings_fnc_init;

[
	"PPS_AllowSendingData",
	"Checkbox",
	[localize "STR_PPS_Main_Settings_Allow_Sending_Data", localize "STR_PPS_Main_Settings_Allow_Sending_Data_Description"],
	localize "STR_PPS_Main_Settings_Category_Client_Settings",
	false,
    nil, // "_isGlobal" flag. Set this to true to always have this setting synchronized between all clients in multiplayer
    {  
        params ["_value"];
    } // function that will be executed once on mission start and every time the setting is changed.
] call cba_settings_fnc_init;

[
	"PPS_SendingGeneralData",
	"Checkbox",
	[localize "STR_PPS_Main_Settings_Sending_General_Data", localize "STR_PPS_Main_Settings_Sending_General_Data_Description"],
	localize "STR_PPS_Main_Settings_Category_Client_Settings",
	true,
    nil, // "_isGlobal" flag. Set this to true to always have this setting synchronized between all clients in multiplayer
    {  
        params ["_value"];
    } // function that will be executed once on mission start and every time the setting is changed.
] call cba_settings_fnc_init;

[
	"PPS_SendingInfantryData",
	"Checkbox",
	[localize "STR_PPS_Main_Settings_Sending_Infantry_Data", localize "STR_PPS_Main_Settings_Sending_Infantry_Data_Description"],
	localize "STR_PPS_Main_Settings_Category_Client_Settings",
	true,
    nil, // "_isGlobal" flag. Set this to true to always have this setting synchronized between all clients in multiplayer
    {  
        params ["_value"];
    } // function that will be executed once on mission start and every time the setting is changed.
] call cba_settings_fnc_init;

[
	"PPS_SendingVehicleData",
	"Checkbox",
	[localize "STR_PPS_Main_Settings_Sending_Vehicle_Data", localize "STR_PPS_Main_Settings_Sending_Vehicle_Data_Description"],
	localize "STR_PPS_Main_Settings_Category_Client_Settings",
	true,
    nil, // "_isGlobal" flag. Set this to true to always have this setting synchronized between all clients in multiplayer
    {  
        params ["_value"];
    } // function that will be executed once on mission start and every time the setting is changed.
] call cba_settings_fnc_init;

[
	"PPS_SendingAddonData",
	"Checkbox",
	[localize "STR_PPS_Main_Settings_Sending_Addon_Data", localize "STR_PPS_Main_Settings_Sending_Addon_Data_Description"],
	localize "STR_PPS_Main_Settings_Category_Client_Settings",
	true,
    nil, // "_isGlobal" flag. Set this to true to always have this setting synchronized between all clients in multiplayer
    {  
        params ["_value"];
    } // function that will be executed once on mission start and every time the setting is changed.
] call cba_settings_fnc_init;

[
	"PPS_TimeZone",
	"LIST",
	[localize "STR_PPS_Main_Settings_Timezone", localize "STR_PPS_Main_Settings_Timezone_Description"],
	localize "STR_PPS_Main_Settings_Category_Client_Settings",
	[
		[0, 1, 2],
		[["UTC+0", "Großbritannien"], ["UTC+1", "Deutschland"], ["UTC+2", "Ukraine"]], 
		1
	],
    nil, // "_isGlobal" flag. Set this to true to always have this setting synchronized between all clients in multiplayer
    {  
        params ["_value"];
    } // function that will be executed once on mission start and every time the setting is changed.
] call cba_settings_fnc_init;

[
	"PPS_SummerTime",
	"Checkbox",
	[localize "STR_PPS_Main_Settings_Daylight_Saving_Time", localize "STR_PPS_Main_Settings_Daylight_Saving_Time_Description"],
	localize "STR_PPS_Main_Settings_Category_Client_Settings",
	true,
    nil, // "_isGlobal" flag. Set this to true to always have this setting synchronized between all clients in multiplayer
    {  
        params ["_value"];
    } // function that will be executed once on mission start and every time the setting is changed.
] call cba_settings_fnc_init;

[
	"PPS_ClientLogging",
	"Checkbox",
	[localize "STR_PPS_Main_Settings_Client_Logging", "STR_PPS_Main_Settings_Client_Logging_Description"],
	localize "STR_PPS_Main_Settings_Category_Client_Settings",
	false,
    nil, // "_isGlobal" flag. Set this to true to always have this setting synchronized between all clients in multiplayer
    {  
        params ["_value"];
    } // function that will be executed once on mission start and every time the setting is changed.
] call cba_settings_fnc_init;

[
	"PPS_ServerLogging",
	"Checkbox",
	[localize "STR_PPS_Main_Settings_Server_Logging", "STR_PPS_Main_Settings_Server_Logging_Description"],
	localize "STR_PPS_Main_Settings_Category_Server_Settings",
	false,
    nil, // "_isGlobal" flag. Set this to true to always have this setting synchronized between all clients in multiplayer
    {  
        params ["_value"];
    } // function that will be executed once on mission start and every time the setting is changed.
] call cba_settings_fnc_init;
