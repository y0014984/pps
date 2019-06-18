/*
 * Author: y0014984
 *
 * Handles the PPS Dialog Stop Event Button pressing event.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call PPS_fnc_dialogButtonStopExec;
 *
 * Public: No
 */

_playerUid = getPlayerUID player;
_playerName = name player;
_clientId = clientOwner;

_answer = _playerUid + "-answerStopEvent";
_answer addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];

	[] call PPS_fnc_dialogUpdate;
};

_request = _playerUid + "-requestStopEvent";
missionNamespace setVariable [_request, [_playerUid, _clientId], false];
publicVariableServer _request;
