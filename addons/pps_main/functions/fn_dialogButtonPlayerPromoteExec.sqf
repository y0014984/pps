/*
 * Author: y0014984
 *
 * Handles the PPS Dialog Player Promote Button pressing event.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call PPS_fnc_dialogButtonPlayerPromoteExec;
 *
 * Public: No
 */
 
_playerUid = getPlayerUID player;
_playerName = name player;
_clientId = clientOwner;

_answer = _playerUid + "-answerPromotePlayer";
_answer addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];

	//[] call PPS_fnc_dialogUpdate;

	[] call PPS_fnc_triggerServerDialogUpdate;
};

_answer = _playerUid + "-answerDegradePlayer";
_answer addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];

	//[] call PPS_fnc_dialogUpdate;

	[] call PPS_fnc_triggerServerDialogUpdate;
};

_playersListBox = (findDisplay 14984) displayCtrl 1500;
_selectedPlayerIndex = lbCurSel _playersListBox;
_requestedPlayerUid = _playersListBox lbData _selectedPlayerIndex;
_promoteButton = (findDisplay 14984) displayCtrl 1610;
_promoteButtonText = ctrlText _promoteButton;

if (_selectedPlayerIndex != -1) then
{
		if ((_promoteButtonText find (localize "STR_PPS_Main_Dialog_Button_Promote")) > -1) then
		{
			_request = _playerUid + "-requestPromotePlayer";
			missionNamespace setVariable [_request, [_playerUid, _clientId, _requestedPlayerUid], false];
			publicVariableServer _request;
		}
		else
		{
			_request = _playerUid + "-requestDegradePlayer";
			missionNamespace setVariable [_request, [_playerUid, _clientId, _requestedPlayerUid], false];
			publicVariableServer _request;
		};	
}
else
{
	hint localize "STR_PPS_Main_Notifications_No_Player_Selected";
};