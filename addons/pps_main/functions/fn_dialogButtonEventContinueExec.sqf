/*
 * Author: y0014984
 *
 * Handles the PPS Dialog Continue Event Button pressing event.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call PPS_fnc_dialogButtonEvent ContinueExec;
 *
 * Public: No
 */
 
_playerUid = getPlayerUID player;
_playerName = name player;
_clientId = clientOwner;

_answer = _playerUid + "-answerContinueEvent";
_answer addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];

	//[] call PPS_fnc_dialogUpdate;

	[] call PPS_fnc_triggerServerDialogUpdate;
};

_eventsListBox = (findDisplay 14984) displayCtrl 1501;
_selectedEventIndex = lbCurSel _eventsListBox;
_requestedEventId = _eventsListBox lbData _selectedEventIndex;

if (_selectedEventIndex != -1) then
{
	if (!PPS_isEvent) then
	{
		_request = _playerUid + "-requestContinueEvent";
		missionNamespace setVariable [_request, [_playerUid, _clientId, _requestedEventId], false];
		publicVariableServer _request;
	}
	else
	{
		hint localize "STR_PPS_Main_Notifications_Event_In_Progress";
	};
	
}
else
{
	hint localize "STR_PPS_Main_Notifications_No_Event_Selected";
};