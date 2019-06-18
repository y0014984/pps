/*
 * Author: y0014984
 *
 * Displays a localized hint on client machine with optional values.
 *
 * Arguments:
 * 0: _stringTableKey <STRING>
 * 1: Optional _firstVariable <STRING>
 * 2: Optional _secondVariable <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["STR_PPS_Main_Notifications_Login_Denied_Too_Many_Admins"] remoteExecCall ["PPS_fnc_hintLocalized", _clientId];
 * ["STR_PPS_Main_Notifications_Event_Started", _eventName] remoteExecCall ["PPS_fnc_hintLocalized"];
 * ["STR_PPS_Main_Notifications_Tracking", _trackStatisticsKey, _trackStatisticsValue] remoteExecCall ["PPS_fnc_hintLocalized", _trackStatisticsClientId];
 *
 * Public: No
 */

params [
		["_stringTableKey", "STR_PPS_Main_Missing_Stringtable_Key", [""]], 
		["_firstVariable", "", ["", 0, true]], 
		["_secondVariable", "", ["", 0, true]]
	];

hint format [(_stringTableKey call BIS_fnc_localize), _firstVariable, _secondVariable];