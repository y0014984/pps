_playerUid = getPlayerUID player;
_playerName = name player;
_clientId = clientOwner;

_answer = _playerUid + "-answerSwitchTrackValue";
_answer addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	[] call PPS_fnc_ppsDialogUpdate;
};

_detailsListBox = (findDisplay -1) displayCtrl 1501;
_selectedIndex = lbCurSel _detailsListBox;
_data = _detailsListBox lbData _selectedIndex;

_trackValueButton = (findDisplay -1) displayCtrl 1604;
_trackValueButtonText = ctrlText _trackValueButton;

if ((_selectedIndex == -1) && (_trackValueButtonText == "Track Value On")) then
{
	hint "Persistent Player Statistics\n\nNo value for tracking selected.";
}
else
{
	_request = _playerUid + "-requestSwitchTrackValue";
	missionNamespace setVariable [_request, [_playerUid, _clientId, _data], false];
	publicVariableServer _request;
};