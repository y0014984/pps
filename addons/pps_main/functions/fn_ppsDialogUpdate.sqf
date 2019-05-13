params ["_playerUid", "_playerName", "_clientId"];

_playersListBox = (findDisplay -1) displayCtrl 1500;
_playersListBox ctrlAddEventHandler ["LBSelChanged",
{
	params ["_control", "_selectedIndex"];
	_data = _control lbData _selectedIndex;
	
	_playerUid = getPlayerUID player;
	_playerName = name player;
	_clientId = clientOwner;

	if (_selectedIndex != -1) then
	{
		_request = _playerUid + "-requestPlayerStatistics";
		missionNamespace setVariable [_request, [_playerUid, _clientId, _data], false];
		publicVariableServer _request;
		
		_request = _playerUid + "-requestPlayerEvents";
		missionNamespace setVariable [_request, [_playerUid, _clientId, _data], false];
		publicVariableServer _request;
	};
}];

_answer = _playerUid + "-answerPlayerAdminStatus";
_answer addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];

	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;
	_isAdmin = _broadcastVariableValue select 2;
	_isAdminLoggedIn = _broadcastVariableValue select 3;
	
	_adminButton = (findDisplay -1) displayCtrl 1600;
	
	if (_isAdminLoggedIn == 1) then
	{
		_adminButton ctrlSetText "Logout Admin";

		_request = _playerUid + "-requestPlayerDetails";
		missionNamespace setVariable [_request, [_playerUid, _clientId, "all"], false];
		publicVariableServer _request;
	}
	else
	{
		_adminButton ctrlSetText "Login Admin";

		_request = _playerUid + "-requestPlayerDetails";
		missionNamespace setVariable [_request, [_playerUid, _clientId, _playerUid], false];
		publicVariableServer _request;
	};
	
};

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

_answer = _playerUid + "-answerPlayerStatistics";
_answer addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	_playerStatistics = _broadcastVariableValue;
	
	_detailsListBox = (findDisplay -1) displayCtrl 1501;
	lbClear _detailsListBox;
	{
		_index = _detailsListBox lbAdd _x;
	} forEach _playerStatistics;
};

_answer = _playerUid + "-answerPlayerEvents";
_answer addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	_playerEvents = _broadcastVariableValue;
	
	_detailsListBox = (findDisplay -1) displayCtrl 1501;
	{
		_index = _detailsListBox lbAdd _x;
	} forEach _playerEvents;
};

_answer = _playerUid + "-answerPlayerDetails";
_answer addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	_allPlayerDetails = _broadcastVariableValue;
	
	_playersListBox = (findDisplay -1) displayCtrl 1500;
	lbClear _playersListBox;
	_detailsListBox = (findDisplay -1) displayCtrl 1501;
	lbClear _detailsListBox;
	
	_playerUid = getPlayerUID player;
	
	_allPlayerDetails sort true;
	{
		_dbPlayerName = _x select 0;
		_dbPlayerUid = _x select 1;
		_dbPlayerIsAdmin = _x select 2;
		_dbPlayerIsAdminLoggedIn = _x select 3;
		
		if (_dbPlayerIsAdmin == 1) then
		{
			_dbPlayerIsAdmin = "Admin";
		}
		else
		{
			_dbPlayerIsAdmin = "User";
		};
		
		if (_dbPlayerIsAdminLoggedIn == 1) then
		{
			_dbPlayerIsAdminLoggedIn = " Logged In";
		}
		else
		{
			_dbPlayerIsAdminLoggedIn = "";
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

_request = _playerUid + "-requestPlayerAdminStatus";
missionNamespace setVariable [_request, [_playerUid, _clientId], false];
publicVariableServer _request;

_request = _playerUid + "-requestMissionDetails";
missionNamespace setVariable [_request, [_playerUid, _clientId], false];
publicVariableServer _request;