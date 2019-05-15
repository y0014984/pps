_playerUid = getPlayerUID player;
_playerName = name player;
_clientId = clientOwner;

_answer = _playerUid + "-answerSwitchAdmin";
_answer addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];

	[] call PPS_fnc_ppsDialogUpdate;
};

_request = _playerUid + "-requestSwitchAdmin";
missionNamespace setVariable [_request, [_playerUid, _clientId], false];
publicVariableServer _request;