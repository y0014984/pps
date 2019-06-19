/*
 * Author: y0014984
 *
 * Handles the PPS Dialog Statistics Export Button pressing event.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call PPS_fnc_dialogButtonStatisticsExportExec;
 *
 * Public: No
 */
 
_playerUid = getPlayerUID player;
_playerName = name player;
_clientId = clientOwner;

_answer = _playerUid + "-answerExportStatistics";
_answer addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	copyToClipboard _broadcastVariableValue;
	
	hint localize "STR_PPS_Main_Notifications_Statistics_Exported_To_Clipboard";
};

_request = _playerUid + "-requestExportStatistics";
missionNamespace setVariable [_request, [_playerUid, _clientId], false];
publicVariableServer _request;