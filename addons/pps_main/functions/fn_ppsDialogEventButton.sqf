_playerUid = getPlayerUID player;
_playerName = name player;
_clientId = clientOwner;

_answer = _playerUid + "-answerSwitchEvent";
_answer addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];

	_playerUid = getPlayerUID player;
	_playerName = name player;
	_clientId = clientOwner;
	
	[_playerUid, _playerName, _clientId] call PPS_fnc_ppsDialogUpdate;
};

_eventText = (findDisplay -1) displayCtrl 1603;
_nameEvent = ctrlText _eventText;

if (_nameEvent == "") then
{
	hint "Missing Event Name";
}
else
{
	_request = _playerUid + "-requestSwitchEvent";
	missionNamespace setVariable [_request, [_playerUid, _clientId, _nameEvent], false];
	publicVariableServer _request;
};