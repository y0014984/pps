_playerUid = getPlayerUID player;
_playerName = name player;
_clientId = clientOwner;

_answer = _playerUid + "-answerSwitchTrackStatistics";
_answer addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	[] call PPS_fnc_dialogUpdate;
};

_detailsListBox = (findDisplay 14984) displayCtrl 1501;
_selectedIndex = lbCurSel _detailsListBox;
_data = _detailsListBox lbData _selectedIndex;

_trackStatisticsButton = (findDisplay 14984) displayCtrl 1604;
_trackStatisticsButtonText = ctrlText _trackStatisticsButton;

if ((_selectedIndex == -1) && (_trackStatisticsButtonText == "Track Statistics On")) then
{
	hint "Persistent Player Statistics\n\nNo statistics for tracking selected.";
}
else
{
	_request = _playerUid + "-requestSwitchTrackStatistics";
	missionNamespace setVariable [_request, [_playerUid, _clientId, _data], false];
	publicVariableServer _request;
};