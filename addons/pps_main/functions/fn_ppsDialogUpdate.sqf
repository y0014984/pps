_playerUid = getPlayerUID player;
_playerName = name player;
_clientId = clientOwner;

/* ================================================================================ */

_playersListBox = (findDisplay -1) displayCtrl 1500;
_playersListBox ctrlAddEventHandler ["LBSelChanged",
{
	params ["_control", "_selectedIndex"];

	if (_selectedIndex != -1) then
	{
		_data = _control lbData _selectedIndex;
		
		_playerUid = getPlayerUID player;
		_playerName = name player;
		_clientId = clientOwner;
		
		_filterStatisticsEditBox = (findDisplay -1) displayCtrl 1401;
		_filter = ctrlText _filterStatisticsEditBox;
	
		_request = _playerUid + "-requestPlayerStatisticsFiltered";
		missionNamespace setVariable [_request, [_playerUid, _clientId, _data, _filter], false];
		publicVariableServer _request;
		
		_request = _playerUid + "-requestPlayerEventsFiltered";
		missionNamespace setVariable [_request, [_playerUid, _clientId, _data, _filter], false];
		publicVariableServer _request;
	};
}];

/* ================================================================================ */

_filterPlayersEditBox = (findDisplay -1) displayCtrl 1400;
_filterPlayersEditBox ctrlAddEventHandler ["KeyUp",
{
	params ["_displayorcontrol", "_key", "_shift", "_ctrl", "_alt"];

	_filterPlayersEditBox = (findDisplay -1) displayCtrl 1400;
	
	if ((_key == 28) || (_key == 156)) then
	{
		_playerUid = getPlayerUID player;
		_clientId = clientOwner;
		_filter = ctrlText _filterPlayersEditBox;
		_request = _playerUid + "-requestPlayerDetailsFiltered";
		missionNamespace setVariable [_request, [_playerUid, _clientId, _filter], false];
		publicVariableServer _request;
	};
}];

/* ================================================================================ */

_filterStatisticsEditBox = (findDisplay -1) displayCtrl 1401;
_filterStatisticsEditBox ctrlAddEventHandler ["KeyUp",
{
	params ["_displayorcontrol", "_key", "_shift", "_ctrl", "_alt"];

	_filterStatisticsEditBox = (findDisplay -1) displayCtrl 1401;
	_playersListBox = (findDisplay -1) displayCtrl 1500;
	
	_selectedIndex = lbCurSel _playersListBox;
	_data = _playersListBox lbData _selectedIndex;
	
	if ((_key == 28) || (_key == 156)) then
	{
		_playerUid = getPlayerUID player;
		_clientId = clientOwner;
		_filter = ctrlText _filterStatisticsEditBox;
		
		_request = _playerUid + "-requestPlayerStatisticsFiltered";
		missionNamespace setVariable [_request, [_playerUid, _clientId, _data, _filter], false];
		publicVariableServer _request;
		
		_request = _playerUid + "-requestPlayerEventsFiltered";
		missionNamespace setVariable [_request, [_playerUid, _clientId, _data, _filter], false];
		publicVariableServer _request;
	};
}];

/* ================================================================================ */

_answer = _playerUid + "-answerServerAndDatabaseStatus";
_answer addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];

	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;	
	_isInidbi2Installed = _broadcastVariableValue select 2;
	
	_isServerReachable =  PPS_ServerStatus;
	
	_serverAndDatabaseStatusText = (findDisplay -1) displayCtrl 1001;
	
	if (_isInidbi2Installed) then {_isInidbi2Installed = "Online"} else {_isInidbi2Installed = "Offline"};
	if (_isServerReachable) then {_isServerReachable = "Online"} else {_isServerReachable = "Offline"};
	
	_serverAndDatabaseStatusText ctrlSetText format ["Server Status: %1 - Database Status: %2",_isServerReachable, _isInidbi2Installed];
};

/* ================================================================================ */

_answer = _playerUid + "-answerPlayersAndAdminsCount";
_answer addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;	
	_countPlayersTotal = _broadcastVariableValue select 2;
	_countPlayersOnline = _broadcastVariableValue select 3;
	_countAdminsTotal = _broadcastVariableValue select 4;
	_countAdminsOnline = _broadcastVariableValue select 5;
	
	_playersAndAdminsCountText = (findDisplay -1) displayCtrl 1002;
	
	_playersAndAdminsCountText ctrlSetText format ["Players Total: %1 - Players Online: %2 - Admins Total: %3 - Admins Online: %4",_countPlayersTotal , _countPlayersOnline, _countAdminsTotal, _countAdminsOnline];
};

/* ================================================================================ */

_answer = _playerUid + "-answerPlayerAdminStatus";
_answer addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];

	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;
	_isAdmin = _broadcastVariableValue select 2;
	_isAdminLoggedIn = _broadcastVariableValue select 3;
	
	_adminButton = (findDisplay -1) displayCtrl 1600;
	
	_eventButton = (findDisplay -1) displayCtrl 1602;
	_eventText = (findDisplay -1) displayCtrl 1603;
	
	_filterPlayersEditBox = (findDisplay -1) displayCtrl 1400;
	_filter = ctrlText _filterPlayersEditBox;
	
	if (_isAdminLoggedIn == 1) then
	{
		_adminButton ctrlSetText "Logout Admin";
		_eventButton ctrlShow true;
		_eventText ctrlShow true;
	}
	else
	{
		_adminButton ctrlSetText "Login Admin";
		_eventButton ctrlShow false;
		_eventText ctrlShow false;
	};
	
	_request = _playerUid + "-requestPlayerDetailsFiltered";
	missionNamespace setVariable [_request, [_playerUid, _clientId, _filter], false];
	publicVariableServer _request;
};

/* ================================================================================ */

_answer = _playerUid + "-answerMissionDetails";
_answer addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	_isEvent = _broadcastVariableValue select 0;
	_nameEvent = _broadcastVariableValue select 1;
	_startTimeEvent = _broadcastVariableValue select 2;
	_noEvent = "None";
	
	_headlineText = (findDisplay -1) displayCtrl 1000;
	_eventButton = (findDisplay -1) displayCtrl 1602;
	
	_eventText = (findDisplay -1) displayCtrl 1603;
	_eventText ctrlSetText _nameEvent;

	if (_isEvent == 1) then
	{
		{
			if(_x < 10) then
			{
				_startTimeEvent set [_forEachIndex, format ["0%1", str _x]];
			}
			else
			{
				_startTimeEvent set [_forEachIndex, str _x];
			};
		} forEach _startTimeEvent;
		_year = _startTimeEvent select 0;
		_month = _startTimeEvent select 1;
		_day = _startTimeEvent select 2;
		_hours = _startTimeEvent select 3;
		_minutes = _startTimeEvent select 4;
		_seconds = _startTimeEvent select 5;
		_timeZone = PPS_TimeZone;
		if (PPS_SummerTime) then
		{
			_timeZone = _timeZone + 1;
		};
		_eventButton ctrlSetText "Stop Event";
		_headlineText ctrlSetBackgroundColor [0.5,-1,-1,1];
		_headlineText ctrlSetText format ["Persistent Player Statistics - Event in Progress: %1 (Start Time %2-%3-%4 %5:%6:%7 UTC+%8)", _nameEvent, _year, _month, _day, _hours, _minutes, _seconds, _timeZone];
	}
	else
	{
		_eventButton ctrlSetText "Start Event";
		_headlineText ctrlSetBackgroundColor [-1,0.5,-1,1];
		_headlineText ctrlSetText format ["Persistent Player Statistics - Event in Progress: %1", _noEvent];
	};		
};

/* ================================================================================ */

_answer = _playerUid + "-answerPlayerStatisticsFiltered";
_answer addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	_playerStatistics = _broadcastVariableValue;
	
	_detailsListBox = (findDisplay -1) displayCtrl 1501;
	lbClear _detailsListBox;
	{
		_index = _detailsListBox lbAdd (_x select 0);
		_detailsListBox lbSetData [_index, (_x select 1)];
	} forEach _playerStatistics;
};

/* ================================================================================ */

_answer = _playerUid + "-answerPlayerEventsFiltered";
_answer addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	_playerEvents = _broadcastVariableValue;
	
	_detailsListBox = (findDisplay -1) displayCtrl 1501;
	{
		_index = _detailsListBox lbAdd (_x select 0);
		_detailsListBox lbSetData [_index, (_x select 1)];
	} forEach _playerEvents;
};

/* ================================================================================ */

_answer = _playerUid + "-answerPlayerDetailsFiltered";
_answer addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	_allPlayerDetails = _broadcastVariableValue;
	
	_playersListBox = (findDisplay -1) displayCtrl 1500;
	lbClear _playersListBox;
	_detailsListBox = (findDisplay -1) displayCtrl 1501;
	lbClear _detailsListBox;
	_trackValueButton = (findDisplay -1) displayCtrl 1604;
	
	_playerUid = getPlayerUID player;
	
	_allPlayerDetails sort true;
	{
		_dbPlayerName = _x select 0;
		_dbPlayerUid = _x select 1;
		_dbPlayerIsAdmin = _x select 2;
		_dbPlayerIsAdminLoggedIn = _x select 3;
		_dbPlayerIsTrackValueActive = _x select 4;
		_dbPlayerTrackValueVariable = _x select 5;
		
		if (_dbPlayerIsAdmin == 1) then
		{
			_dbPlayerIsAdmin = "Admin";
		}
		else
		{
			_dbPlayerIsAdmin = "Player";
		};
		
		if (_dbPlayerIsAdminLoggedIn == 1) then
		{
			_dbPlayerIsAdminLoggedIn = " Logged In";
		}
		else
		{
			_dbPlayerIsAdminLoggedIn = "";
		};
		
		if ((_dbPlayerUid == _playerUid) && (_dbPlayerIsTrackValueActive == 1)) then
		{
			_trackValueButton ctrlSetText "Track Value Off";
		}
		else
		{
			_trackValueButton ctrlSetText "Track Value On";
		};
		
		_index = _playersListBox lbAdd format ["%1 (%2%3)",_dbPlayerName, _dbPlayerIsAdmin, _dbPlayerIsAdminLoggedIn];	
		_playersListBox lbSetData [_index, _dbPlayerUid];
		if(_dbPlayerUid == _playerUid) then
		{
			_playersListBox lbSetColor [_index, [1, 0, 0, 1]];
		};
	} forEach _allPlayerDetails;
	
	_playersListBox lbSetCurSel -1;
};

/* ================================================================================ */

_request = _playerUid + "-requestServerAndDatabaseStatus";
missionNamespace setVariable [_request, [_playerUid, _clientId], false];
publicVariableServer _request;

_request = _playerUid + "-requestPlayersAndAdminsCount";
missionNamespace setVariable [_request, [_playerUid, _clientId], false];
publicVariableServer _request;

_request = _playerUid + "-requestPlayerAdminStatus";
missionNamespace setVariable [_request, [_playerUid, _clientId], false];
publicVariableServer _request;

_request = _playerUid + "-requestMissionDetails";
missionNamespace setVariable [_request, [_playerUid, _clientId], false];
publicVariableServer _request;

/* ================================================================================ */
