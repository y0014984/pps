_playerUid = getPlayerUID player;
_playerName = name player;
_clientId = clientOwner;

_answer = _playerUid + "-answerSwitchTrackStatistics";
_answer addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	[] call PPS_fnc_dialogUpdate;
};

_statisticsListBox = (findDisplay 14984) displayCtrl 1502;
_selectedIndex = lbCurSel _statisticsListBox;
_data = _statisticsListBox lbData _selectedIndex;

_trackStatisticsButton = (findDisplay 14984) displayCtrl 1604;
_trackStatisticsButtonText = ctrlText _trackStatisticsButton;

if ((_selectedIndex == -1) && (_trackStatisticsButtonText == localize "STR_PPS_Main_Dialog_Button_Track_Value_On")) then
{
	hint localize "STR_PPS_Main_Notifications_No_Tracking_Value_Selected";
}
else
{
	_request = _playerUid + "-requestSwitchTrackStatistics";
	missionNamespace setVariable [_request, [_playerUid, _clientId, _data], false];
	publicVariableServer _request;
};