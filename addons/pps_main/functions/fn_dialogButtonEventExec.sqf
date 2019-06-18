/*
 * Author: y0014984
 *
 * Handles the PPS Dialog Event Button pressing event.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call PPS_fnc_dialogButtonEventExec;
 *
 * Public: No
 */

_playerUid = getPlayerUID player;
_playerName = name player;
_clientId = clientOwner;

_answer = _playerUid + "-answerSwitchEvent";
_answer addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];

	[] call PPS_fnc_dialogUpdate;
};

_eventEditBox = (findDisplay 14984) displayCtrl 1603;
_eventName = ctrlText _eventEditBox;

if (_eventName == "") then
{
	hint localize "STR_PPS_Main_Notifications_Missing_Event_Name";
}
else
{
	_request = _playerUid + "-requestSwitchEvent";
	missionNamespace setVariable [_request, [_playerUid, _clientId, _eventName], false];
	publicVariableServer _request;
};