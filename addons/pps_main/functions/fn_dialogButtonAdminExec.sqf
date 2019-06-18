/*
 * Author: y0014984
 *
 * Handles the PPS Dialog Admin Button pressing event.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call PPS_fnc_dialogButtonAdminExec;
 *
 * Public: No
 */

_playerUid = getPlayerUID player;
_playerName = name player;
_clientId = clientOwner;

_answer = _playerUid + "-answerSwitchAdmin";
_answer addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];

	[] call PPS_fnc_dialogUpdate;
};

_request = _playerUid + "-requestSwitchAdmin";
missionNamespace setVariable [_request, [_playerUid, _clientId], false];
publicVariableServer _request;