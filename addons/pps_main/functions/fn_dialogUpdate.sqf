_playerUid = getPlayerUID player;
_playerName = name player;
_clientId = clientOwner;

/* ================================================================================ */

_playersListBox = (findDisplay 14984) displayCtrl 1500;
_playersListBox ctrlAddEventHandler ["LBSelChanged",
{
	params ["_control", "_selectedIndex"];

	if (_selectedIndex != -1) then
	{
		_data = _control lbData _selectedIndex;
		
		_playerUid = getPlayerUID player;
		_playerName = name player;
		_clientId = clientOwner;
		
		_filterStatisticsEditBox = (findDisplay 14984) displayCtrl 1401;
		_filter = ctrlText _filterStatisticsEditBox;
	
		_request = _playerUid + "-requestStatisticsFiltered";
		missionNamespace setVariable [_request, [_playerUid, _clientId, _data, _filter], false];
		publicVariableServer _request;
	};
}];

/* ================================================================================ */

_filterPlayersEditBox = (findDisplay 14984) displayCtrl 1400;
_filterPlayersEditBox ctrlAddEventHandler ["KeyUp",
{
	params ["_displayorcontrol", "_key", "_shift", "_ctrl", "_alt"];

	if ((_key == 28) || (_key == 156)) then
	{
		_playerUid = getPlayerUID player;
		_clientId = clientOwner;
		
		_filterPlayersEditBox = (findDisplay 14984) displayCtrl 1400;
		_filterPlayers = ctrlText _filterPlayersEditBox;

		_request = _playerUid + "-requestDialogUpdate";
		missionNamespace setVariable [_request, [_playerUid, _clientId, _filterPlayers], false];
		publicVariableServer _request;
	};
}];

/* ================================================================================ */

_filterStatisticsEditBox = (findDisplay 14984) displayCtrl 1401;
_filterStatisticsEditBox ctrlAddEventHandler ["KeyUp",
{
	params ["_displayorcontrol", "_key", "_shift", "_ctrl", "_alt"];

	_filterStatisticsEditBox = (findDisplay 14984) displayCtrl 1401;
	_playersListBox = (findDisplay 14984) displayCtrl 1500;
	
	_selectedIndex = lbCurSel _playersListBox;
	_data = _playersListBox lbData _selectedIndex;
	
	if ((_key == 28) || (_key == 156)) then
	{
		_playerUid = getPlayerUID player;
		_clientId = clientOwner;
		_filter = ctrlText _filterStatisticsEditBox;
		
		_request = _playerUid + "-requestStatisticsFiltered";
		missionNamespace setVariable [_request, [_playerUid, _clientId, _data, _filter], false];
		publicVariableServer _request;
	};
}];

/* ================================================================================ */

_answer = _playerUid + "-answerStatisticsFiltered";
_answer addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	_playerStatistics = _broadcastVariableValue select 0;
	_playerEvents = _broadcastVariableValue select 1;
	_isTrackStatisticsActive = _broadcastVariableValue select 2;
	_trackStatisticsKey = _broadcastVariableValue select 3;

	_detailsListBox = (findDisplay 14984) displayCtrl 1501;
	lbClear _detailsListBox;
	{
		_text = _x select 0;
		_key = _x select 1;
		
		if ((_isTrackStatisticsActive) && (_trackStatisticsKey == _key)) then
		{
			_index = _detailsListBox lbAdd (format [localize "STR_PPS_Main_Dialog_List_Tracking_Active", _text]);
			_detailsListBox lbSetData [_index, _key];
			
			_detailsListBox lbSetColor [_index, [1, 0.5, 0.5, 1]];
			_detailsListBox lbSetCurSel _index;
		}
		else
		{
			_index = _detailsListBox lbAdd _text;
			_detailsListBox lbSetData [_index, _key];
		};
	} forEach _playerStatistics;

	{
		_index = _detailsListBox lbAdd (_x select 0);
		_detailsListBox lbSetData [_index, (_x select 1)];
	} forEach _playerEvents;
};

/* ================================================================================ */

_answer = _playerUid + "-answerDialogUpdate";
_answer addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];

	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;	
	_isAdmin = _broadcastVariableValue select 2;
	_isAdminLoggedIn = _broadcastVariableValue select 3;
	_isInidbi2Installed = _broadcastVariableValue select 4;
	_countPlayersTotal = _broadcastVariableValue select 5;
	_countPlayersOnline = _broadcastVariableValue select 6;
	_countAdminsTotal = _broadcastVariableValue select 7;
	_countAdminsOnline = _broadcastVariableValue select 8;
	_isEvent = _broadcastVariableValue select 9;
	_eventName = _broadcastVariableValue select 10;
	_eventStartTime = _broadcastVariableValue select 11;
	_allPlayerDetails = _broadcastVariableValue select 12;
	
	_isServerReachable =  PPS_ServerStatus;

	_headlineText = (findDisplay 14984) displayCtrl 1000;
	_serverAndDatabaseStatusText = (findDisplay 14984) displayCtrl 1001;
	_playersAndAdminsCountText = (findDisplay 14984) displayCtrl 1002;
	_playersListBox = (findDisplay 14984) displayCtrl 1500;
	lbClear _playersListBox;
	_playersListBox lbSetCurSel -1;
	_detailsListBox = (findDisplay 14984) displayCtrl 1501;
	lbClear _detailsListBox;
	_adminButton = (findDisplay 14984) displayCtrl 1600;
	_eventButton = (findDisplay 14984) displayCtrl 1602;
	_eventEditBox = (findDisplay 14984) displayCtrl 1603;
	_eventEditBox ctrlSetText _eventName;
	_trackStatisticsButton = (findDisplay 14984) displayCtrl 1604;
	
	if (_isInidbi2Installed) then {_isInidbi2Installed = localize "STR_PPS_Main_Online"} else {_isInidbi2Installed = localize "STR_PPS_Main_Offline"};
	if (_isServerReachable) then {_isServerReachable = localize "STR_PPS_Main_Online"} else {_isServerReachable = localize "STR_PPS_Main_Offline"};
	
	_serverAndDatabaseStatusText ctrlSetText format [localize "STR_PPS_Main_Dialog_Server_Status",_isServerReachable, _isInidbi2Installed];
	_playersAndAdminsCountText ctrlSetText format [localize "STR_PPS_Main_Dialog_Player_Status",_countPlayersTotal , _countPlayersOnline, _countAdminsTotal, _countAdminsOnline];

	if (_isAdminLoggedIn) then
	{
		_adminButton ctrlSetText localize "STR_PPS_Main_Dialog_Button_Admin_Logout";
		_eventButton ctrlShow true;
		_eventEditBox ctrlShow true;
	}
	else
	{
		_adminButton ctrlSetText localize "STR_PPS_Main_Dialog_Button_Admin_Login";
		_eventButton ctrlShow false;
		_eventEditBox ctrlShow false;
	};

	_noEvent = localize "STR_PPS_Main_Dialog_No_Event";
	
	if (_isEvent) then
	{
		{
			if(_x < 10) then
			{
				_eventStartTime set [_forEachIndex, format ["0%1", str _x]];
			}
			else
			{
				_eventStartTime set [_forEachIndex, str _x];
			};
		} forEach _eventStartTime;
		_year = _eventStartTime select 0;
		_month = _eventStartTime select 1;
		_day = _eventStartTime select 2;
		_hours = _eventStartTime select 3;
		_minutes = _eventStartTime select 4;
		_seconds = _eventStartTime select 5;
		_timeZone = PPS_TimeZone;
		if (PPS_SummerTime) then {_timeZone = _timeZone + 1;};
		_eventButton ctrlSetText localize "STR_PPS_Main_Dialog_Button_Event_Stop";
		_headlineText ctrlSetBackgroundColor [0.5, 0, 0, 1];
		_headlineText ctrlSetText format [localize "STR_PPS_Main_Dialog_Head_Time", _eventName, _year, _month, _day, _hours, _minutes, _seconds, _timeZone];
	}
	else
	{
		_eventButton ctrlSetText localize "STR_PPS_Main_Dialog_Button_Event_Start";
		_headlineText ctrlSetBackgroundColor [0, 0.5, 0, 1];
		_headlineText ctrlSetText format [localize "STR_PPS_Main_Dialog_Head", _noEvent];
	};		

	_allPlayerDetails sort true;
	{
		_dbPlayerName = _x select 0;
		_dbPlayerUid = _x select 1;
		_dbPlayerIsAdmin = _x select 2;
		_dbPlayerIsAdminLoggedIn = _x select 3;
		_dbPlayerIsTrackStatisticsActive = _x select 4;
		_dbPlayerTrackStatisticsKey = _x select 5;
		
		if (_dbPlayerIsAdmin) then
		{
			_dbPlayerIsAdmin = localize "STR_PPS_Main_Admin";
		}
		else
		{
			_dbPlayerIsAdmin = localize "STR_PPS_Main_Player";
		};
		
		if (_dbPlayerIsAdminLoggedIn) then
		{
			_dbPlayerIsAdminLoggedIn = " " + (localize "STR_PPS_Main_Logged_In");
		}
		else
		{
			_dbPlayerIsAdminLoggedIn = "";
		};
		
		if ((_dbPlayerUid == _playerUid) && _dbPlayerIsTrackStatisticsActive) then
		{
			_trackStatisticsButton ctrlSetText localize "STR_PPS_Main_Dialog_Button_Track_Value_Off";
		}
		else
		{
			_trackStatisticsButton ctrlSetText localize "STR_PPS_Main_Dialog_Button_Track_Value_On";
		};
		
		_index = _playersListBox lbAdd format ["%1 (%2%3)",_dbPlayerName, _dbPlayerIsAdmin, _dbPlayerIsAdminLoggedIn];	
		_playersListBox lbSetData [_index, _dbPlayerUid];
		if(_dbPlayerUid == _playerUid) then
		{
			_playersListBox lbSetColor [_index, [1, 0.5, 0.5, 1]];
			_playersListBox lbSetCurSel _index;
		};
	} forEach _allPlayerDetails;
	
	ctrlSetFocus _playersListBox;
};

/* ================================================================================ */

_filterPlayersEditBox = (findDisplay 14984) displayCtrl 1400;
_filterPlayers = ctrlText _filterPlayersEditBox;

_request = _playerUid + "-requestDialogUpdate";
missionNamespace setVariable [_request, [_playerUid, _clientId, _filterPlayers], false];
publicVariableServer _request;

/* ================================================================================ */
