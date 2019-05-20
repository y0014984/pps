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
_nameEvent = ctrlText _eventEditBox;

if (_nameEvent == "") then
{
	hint "Persistent Player Statistics\n\nMissing event name.";
}
else
{
	_request = _playerUid + "-requestSwitchEvent";
	missionNamespace setVariable [_request, [_playerUid, _clientId, _nameEvent], false];
	publicVariableServer _request;
};