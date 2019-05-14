params ["_playerUid"];

/* ================================================================================ */

(_playerUid + "-requestSwitchAdmin") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];

	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;

	_dbName = "pps-players";
	_inidbi = ["new", _dbName] call OO_INIDBI;
	
	_isAdmin = ["read", [_playerUid, "isAdmin", 0]] call _inidbi;
	_isAdminLoggedIn = ["read", [_playerUid, "isAdminLoggedIn", 0]] call _inidbi;
	
	if (_isAdmin == 1) then
	{

		_sections = "getSections" call _inidbi;
		
		_isAnotherAdminLoggedIn = false;
		{
			scopeName "LoopAnotherAdminLoggedIn";
			_tempIsAdminLoggedIn = ["read", [_x, "isAdminLoggedIn", 0]] call _inidbi;
			_tempPlayerUid = ["read", [_x, "playerUid", 0]] call _inidbi;
			if ((_tempIsAdminLoggedIn == 1) && (_tempPlayerUid != _playerUid)) then
			{
				_isAnotherAdminLoggedIn = true;
				breakOut "LoopAnotherAdminLoggedIn";
			};
		} forEach _sections;

		if (!_isAnotherAdminLoggedIn) then
		{
			if (_isAdminLoggedIn == 0) then
			{
				["write", [_playerUid, "isAdminLoggedIn", 1]] call _inidbi;
			}
			else
			{
				["write", [_playerUid, "isAdminLoggedIn", 0]] call _inidbi;
			};
		}
		else
		{
			"Persistent Player Statistics\nAdmin login denied. There ist another admin logged in." remoteExec ["hint", _clientId];
		};
	};
	
	_isAdminLoggedIn = ["read", [_playerUid, "isAdminLoggedIn", 0]] call _inidbi;
	
	_result = [_isAdmin, _isAdminLoggedIn];
	
	_answer = _playerUid + "-answerSwitchAdmin";
	missionNamespace setVariable [_answer, _result, false];
	_clientId publicVariableClient _answer;

	_dbName = "pps-player-" + _playerUid;
	_inidbi = ["new", _dbName] call OO_INIDBI;		
	_globalSection = "Global Informations";
	_playerName = ["read", [_globalSection, "playerName", ""]] call _inidbi;
	
	diag_log format ["[%1] PPS Player Request Switch Admin Status: %2 %3 (%4)", serverTime, _isAdminLoggedIn, _playerName, _playerUid];
};

/* ================================================================================ */

(_playerUid + "-requestSwitchTrackValue") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];

	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;
	_data = _broadcastVariableValue select 2;
	
	_dbName = "pps-players";
	_inidbi = ["new", _dbName] call OO_INIDBI;
	
	_isTrackValueActive = ["read", [_playerUid, "isTrackValueActive", 0]] call _inidbi;
	
	if (_isTrackValueActive == 1) then
	{
		["write", [_playerUid, "isTrackValueActive", 0]] call _inidbi;
		["write", [_playerUid, "trackValueVariable", ""]] call _inidbi;
		["write", [_playerUid, "trackValueClientId", ""]] call _inidbi;
	}
	else
	{
		["write", [_playerUid, "isTrackValueActive", 1]] call _inidbi;
		["write", [_playerUid, "trackValueVariable", _data]] call _inidbi;
		["write", [_playerUid, "trackValueClientId", _clientId]] call _inidbi;
	};

	_isTrackValueActive = ["read", [_playerUid, "isTrackValueActive", 0]] call _inidbi;
	_trackValueVariable = ["read", [_playerUid, "trackValueVariable", ""]] call _inidbi;
	_trackValueClientId = ["read", [_playerUid, "trackValueClientId", ""]] call _inidbi;

	_result = [_isTrackValueActive, _trackValueVariable, _trackValueClientId];
	
	_answer = _playerUid + "-answerSwitchTrackValue";
	missionNamespace setVariable [_answer, _result, false];
	_clientId publicVariableClient _answer;

	_dbName = "pps-player-" + _playerUid;
	_inidbi = ["new", _dbName] call OO_INIDBI;		
	_globalSection = "Global Informations";
	_playerName = ["read", [_globalSection, "playerName", ""]] call _inidbi;
	
	diag_log format ["[%1] PPS Player Request Switch Track Value: %2 %3 (%4)", serverTime, _data, _playerName, _playerUid];
};

/* ================================================================================ */

(_playerUid + "-requestSwitchEvent") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];

	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;
	_nameEvent = _broadcastVariableValue select 2;

	_dbName = "pps-players";
	_inidbi = ["new", _dbName] call OO_INIDBI;
	
	_isAdmin = ["read", [_playerUid, "isAdmin", 0]] call _inidbi;
	_isAdminLoggedIn = ["read", [_playerUid, "isAdminLoggedIn", 0]] call _inidbi;
	
	if ((_isAdmin == 1) && (_isAdminLoggedIn == 1)) then
	{	
		_dbName = "pps-server-settings";
		_inidbi = ["new", _dbName] call OO_INIDBI;
		_settingsSection = "Settings";
		
		_isEvent = ["read", [_settingsSection, "isEvent", ""]] call _inidbi;
		
		if (_isEvent == 0) then
		{
			_startTimeEvent = "getTimeStamp" call _inidbi;
			
			_eventId = "";
			{
				if(_x < 10) then
				{
					_eventId = _eventId + format ["0%1", str _x];
				}
				else
				{
					_eventId = _eventId + (str _x);
				};
			} forEach _startTimeEvent;	
			
			["write", [_settingsSection, "isEvent", 1]] call _inidbi;
			["write", [_settingsSection, "eventId", _eventId]] call _inidbi;
			["write", [_settingsSection, "nameEvent", _nameEvent]] call _inidbi;
			["write", [_settingsSection, "startTimeEvent", _startTimeEvent]] call _inidbi;
			format ["Persistent Player Statistics\nEvent started: %1", _nameEvent] remoteExec ["hint", -2];
			
			_allActivePlayers = allPlayers - entities "HeadlessClient_F";
			_allActivePlayersIds = [];
			{
				_xPlayerUid = getPlayerUID _x;
				_allActivePlayersIds = _allActivePlayersIds + [_xPlayerUid];			
			} forEach _allActivePlayers;
			
			_dbName = "pps-events";
			_inidbi = ["new", _dbName] call OO_INIDBI;
					
			["write", [_eventId, "eventId", _eventId]] call _inidbi;
			["write", [_eventId, "eventName", _nameEvent]] call _inidbi;
			["write", [_eventId, "eventAllActivePlayerIds", _allActivePlayersIds]] call _inidbi;
			["write", [_eventId, "eventStartTime", _startTimeEvent]] call _inidbi;
		}
		else
		{
			_startTimeEvent = ["read", [_settingsSection, "startTimeEvent", [[0],[0],[0],[0],[0],[0]]]] call _inidbi;
			_stopTimeEvent = "getTimeStamp" call _inidbi;
			
			["write", [_settingsSection, "isEvent", 0]] call _inidbi;
			["write", [_settingsSection, "eventId", ""]] call _inidbi;
			["write", [_settingsSection, "nameEvent", ""]] call _inidbi;
			["write", [_settingsSection, "startTimeEvent", -1]] call _inidbi;
			
			format ["Persistent Player Statistics\nEvent stopped: %1", _nameEvent] remoteExec ["hint", -2];
			
			_dbName = "pps-events";
			_inidbi = ["new", _dbName] call OO_INIDBI;

			_eventId = "";
			{
				if(_x < 10) then
				{
					_eventId = _eventId + format ["0%1", str _x];
				}
				else
				{
					_eventId = _eventId + (str _x);
				};
			} forEach _startTimeEvent;
			["write", [_eventId, "eventStopTime", _stopTimeEvent]] call _inidbi;
			
			if ((_stopTimeEvent select 0) == (_startTimeEvent select 0)) then
			{
				_startTimeEvent set [5, "delete"];
				_startTimeEvent = _startTimeEvent - ["delete"];
				_stopTimeEvent set [5, "delete"];
				_stopTimeEvent = _stopTimeEvent - ["delete"];
				_eventDuration = (dateToNumber _stopTimeEvent) - (dateToNumber _startTimeEvent);
				_eventDuration = numberToDate [_stopTimeEvent select 0, _eventDuration];
				if (((_eventDuration select 1) == 1) && ((_eventDuration select 2) == 1)) then
				{
					_eventDuration = ((_eventDuration select 3) * 60) + (_eventDuration select 4);
					["write", [_eventId, "eventDuration", _eventDuration]] call _inidbi;
				};
			};
		};

		_dbName = "pps-server-settings";
		_inidbi = ["new", _dbName] call OO_INIDBI;
		_settingsSection = "Settings";
		
		_isEvent = ["read", [_settingsSection, "isEvent", -1]] call _inidbi;
		_nameEvent = ["read", [_settingsSection, "nameEvent", ""]] call _inidbi;
		_startTimeEvent = ["read", [_settingsSection, "startTimeEvent", -1]] call _inidbi;
		
		_result = [_isEvent, _nameEvent, _startTimeEvent];
		
		_answer = _playerUid + "-answerSwitchEvent";
		missionNamespace setVariable [_answer, _result, false];
		_clientId publicVariableClient _answer;

		_dbName = "pps-player-" + _playerUid;
		_inidbi = ["new", _dbName] call OO_INIDBI;		
		_globalSection = "Global Informations";
		_playerName = ["read", [_globalSection, "playerName", ""]] call _inidbi;
		
		diag_log format ["[%1] PPS Player Request Switch Event Status: %2 %3 (%4)", serverTime, _isEvent, _playerName, _playerUid];
	};
};

/* ================================================================================ */

(_playerUid + "-requestMissionDetails") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];

	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;
	
	_dbName = "pps-server-settings";
	_inidbi = ["new", _dbName] call OO_INIDBI;	
	_settingsSection = "Settings";
	_isEvent = ["read", [_settingsSection, "isEvent", -1]] call _inidbi;
	_nameEvent = ["read", [_settingsSection, "nameEvent", ""]] call _inidbi;
	_startTimeEvent = ["read", [_settingsSection, "startTimeEvent", -1]] call _inidbi;
	
	_result = [_isEvent, _nameEvent, _startTimeEvent];
	
	_answer = _playerUid + "-answerMissionDetails";
	missionNamespace setVariable [_answer, _result, false];
	_clientId publicVariableClient _answer;

	_dbName = "pps-player-" + _playerUid;
	_inidbi = ["new", _dbName] call OO_INIDBI;		
	_globalSection = "Global Informations";
	_playerName = ["read", [_globalSection, "playerName", ""]] call _inidbi;
	
	diag_log format ["[%1] PPS Player Request Mission Details: %2 (%3)", serverTime, _playerName, _playerUid];
};

/* ================================================================================ */

(_playerUid + "-requestPlayerEventsFiltered") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;
	_requestedPlayerUid = _broadcastVariableValue select 2;
	_filter = _broadcastVariableValue select 3;

	_dbName = "pps-players";
	_inidbi = ["new", _dbName] call OO_INIDBI;
	
	_isAdmin = ["read", [_playerUid, "isAdmin", 0]] call _inidbi;
	_isAdminLoggedIn = ["read", [_playerUid, "isAdminLoggedIn", 0]] call _inidbi;
	
	if((_playerUid == _requestedPlayerUid) || (_isAdmin == 1)) then
	{
		_dbName = "pps-events";
		_inidbi = ["new", _dbName] call OO_INIDBI;
		
		_sections = "getSections" call _inidbi;
		
		_tmpResult = [];	
		{
			_eventName = ["read", [_x, "eventName", ""]] call _inidbi;
			_eventStartTime = ["read", [_x, "eventStartTime", ""]] call _inidbi;
			_eventDuration = ["read", [_x, "eventDuration", ""]] call _inidbi;
			_eventAllActivePlayerIds = ["read", [_x, "eventAllActivePlayerIds", ""]] call _inidbi;
			
			if ((_eventStartTime select 1) < 10) then {_eventStartTime set [1, format["0%1", _eventStartTime select 1]]};
			if ((_eventStartTime select 2) < 10) then {_eventStartTime set [2, format["0%1", _eventStartTime select 2]]};
			
			if ((_eventAllActivePlayerIds find _requestedPlayerUid) > -1) then
			{
				_statisticsString = format ["PPS Event: %1 (%2-%3-%4 >> %5 min)", _eventName, (_eventStartTime select 0), (_eventStartTime select 1), (_eventStartTime select 2), _eventDuration];
				_tmpResult = _tmpResult + [[_statisticsString, ""]];
			};
		} forEach _sections;

		_result = [];	
		if(_filter != "") then
		{
			{
				if (((_x select 0) find _filter) > -1) then
				{
					_result = _result + [_x];
				};
			} forEach _tmpResult;
		}
		else
		{
			_result = _tmpResult;
		};

		_answer = _playerUid + "-answerPlayerEventsFiltered";
		missionNamespace setVariable [_answer, _result, false];
		_clientId publicVariableClient _answer;

		_dbName = "pps-player-" + _requestedPlayerUid;
		_inidbi = ["new", _dbName] call OO_INIDBI;		
		_globalSection = "Global Informations";
		_requestedPlayerName = ["read", [_globalSection, "playerName", ""]] call _inidbi;
		
		diag_log format ["[%1] PPS Player Request Events: %2 (%3)", serverTime, _requestedPlayerName, _requestedPlayerUid];
	};
};

/* ================================================================================ */

(_playerUid + "-requestPlayerStatisticsFiltered") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;
	_requestedPlayerUid = _broadcastVariableValue select 2;
	_filter = _broadcastVariableValue select 3;
	
	_dbName = "pps-players";
	_inidbi = ["new", _dbName] call OO_INIDBI;
	
	_isAdmin = ["read", [_playerUid, "isAdmin", 0]] call _inidbi;
	_isAdminLoggedIn = ["read", [_playerUid, "isAdminLoggedIn", 0]] call _inidbi;
	
	if((_playerUid == _requestedPlayerUid) || (_isAdmin == 1)) then
	{
		_dbName = "pps-player-" + _requestedPlayerUid;
		_inidbi = ["new", _dbName] call OO_INIDBI;
		
		_globalSection = "Global Informations";
		_intervalSection = "Interval Statistics";
		_eventSection = "Event Handler Statistics";
		_eventsSection = "Events Informations";
		
		_requestedPlayerName = ["read", [_globalSection, "playerName", ""]] call _inidbi;
		_requestedPlayerUid = ["read", [_globalSection, "playerUid", ""]] call _inidbi;

		_countUpdates = ["read", [_intervalSection, "countUpdates", 0]] call _inidbi;

		_timeInEvent = ["read", [_intervalSection, "timeInEvent", 0]] call _inidbi;
		_roundTimeInEvent = parseNumber ((_timeInEvent / 3600) toFixed 2);
		
		_countProjectilesFired = ["read", [_eventSection, "countProjectilesFired", 0]] call _inidbi;
		_countGrenadesThrown = ["read", [_eventSection, "countGrenadesThrown", 0]] call _inidbi;
		_countSmokeShellsThrown = ["read", [_eventSection, "countSmokeShellsThrown", 0]] call _inidbi;
		_countChemlightsThrown = ["read", [_eventSection, "countChemlightsThrown", 0]] call _inidbi;
		_countUnknownThrown = ["read", [_eventSection, "countUnknownThrown", 0]] call _inidbi;

		_countProjectilesHitEnemy = ["read", [_eventSection, "countProjectilesHitEnemy", 0]] call _inidbi;
		_roundCountProjectilesHitEnemyPercent = parseNumber ((100 / _countProjectilesFired * _countProjectilesHitEnemy) toFixed 2);
		_countProjectilesHitFriendly = ["read", [_eventSection, "countProjectilesHitFriendly", 0]] call _inidbi;
		_roundCountProjectilesHitFriendlyPercent = parseNumber ((100 / _countProjectilesFired * _countProjectilesHitFriendly) toFixed 2);
		_countGrenadesHitEnemy = ["read", [_eventSection, "countGrenadesHitEnemy", 0]] call _inidbi;
		_roundCountGrenadesHitEnemyPercent = parseNumber ((100 / _countGrenadesThrown * _countGrenadesHitEnemy) toFixed 2);
		_countGrenadesHitFriendly = ["read", [_eventSection, "countGrenadesHitFriendly", 0]] call _inidbi;
		_roundCountGrenadesHitFriendlyPercent = parseNumber ((100 / _countGrenadesThrown * _countGrenadesHitFriendly) toFixed 2);

		_countPlayerDeaths = ["read", [_eventSection, "countPlayerDeaths", 0]] call _inidbi;
		_countPlayerKills = ["read", [_eventSection, "countPlayerKills", 0]] call _inidbi;
		_countPlayerSuicides = ["read", [_eventSection, "countPlayerSuicides", 0]] call _inidbi;
		_countPlayerTeamKills = ["read", [_eventSection, "countPlayerTeamKills", 0]] call _inidbi;
		
		_countCuratorInterfaceOpened = ["read", [_eventSection, "countCuratorInterfaceOpened", 0]] call _inidbi;
		_countGearInterfaceOpened = ["read", [_eventSection, "countGearInterfaceOpened", 0]] call _inidbi;
		_countCompassInterfaceOpened = ["read", [_eventSection, "countCompassInterfaceOpened", 0]] call _inidbi;
		_countWatchInterfaceOpened = ["read", [_eventSection, "countWatchInterfaceOpened", 0]] call _inidbi;
		
		_timeOnFoot = ["read", [_intervalSection, "timeOnFoot", 0]] call _inidbi;
		_roundTimeOnFoot = parseNumber ((_timeOnFoot / 3600) toFixed 2);
		_roundTimeOnFootPercent = parseNumber ((100 / _timeInEvent * _timeOnFoot) toFixed 2);

		_timeStandNoSpeed = ["read", [_intervalSection, "timeStandNoSpeed", 0]] call _inidbi;
		_roundTimeStandNoSpeed = parseNumber ((_timeStandNoSpeed / 3600) toFixed 2);
		_roundTimeStandNoSpeedPercent = parseNumber ((100 / _timeInEvent * _timeStandNoSpeed) toFixed 2);
		_timeCrouchNoSpeed = ["read", [_intervalSection, "timeCrouchNoSpeed", 0]] call _inidbi;
		_roundTimeCrouchNoSpeed = parseNumber ((_timeCrouchNoSpeed / 3600) toFixed 2);
		_roundTimeCrouchNoSpeedPercent = parseNumber ((100 / _timeInEvent * _timeCrouchNoSpeed) toFixed 2);
		_timeProneNoSpeed = ["read", [_intervalSection, "timeProneNoSpeed", 0]] call _inidbi;
		_roundTimeProneNoSpeed = parseNumber ((_timeProneNoSpeed / 3600) toFixed 2);
		_roundTimeProneNoSpeedPercent = parseNumber ((100 / _timeInEvent * _timeProneNoSpeed) toFixed 2);

		_timeStandLowSpeed = ["read", [_intervalSection, "timeStandLowSpeed", 0]] call _inidbi;
		_roundTimeStandLowSpeed = parseNumber ((_timeStandLowSpeed / 3600) toFixed 2);
		_roundTimeStandLowSpeedPercent = parseNumber ((100 / _timeInEvent * _timeStandLowSpeed) toFixed 2);
		_timeCrouchLowSpeed = ["read", [_intervalSection, "timeCrouchLowSpeed", 0]] call _inidbi;
		_roundTimeCrouchLowSpeed = parseNumber ((_timeCrouchLowSpeed / 3600) toFixed 2);
		_roundTimeCrouchLowSpeedPercent = parseNumber ((100 / _timeInEvent * _timeCrouchLowSpeed) toFixed 2);
		_timeProneLowSpeed = ["read", [_intervalSection, "timeProneLowSpeed", 0]] call _inidbi;
		_roundTimeProneLowSpeed = parseNumber ((_timeProneLowSpeed / 3600) toFixed 2);
		_roundTimeProneLowSpeedPercent = parseNumber ((100 / _timeInEvent * _timeProneLowSpeed) toFixed 2);

		_timeStandMidSpeed = ["read", [_intervalSection, "timeStandMidSpeed", 0]] call _inidbi;
		_roundTimeStandMidSpeed = parseNumber ((_timeStandMidSpeed / 3600) toFixed 2);
		_roundTimeStandMidSpeedPercent = parseNumber ((100 / _timeInEvent * _timeStandMidSpeed) toFixed 2);
		_timeCrouchMidSpeed = ["read", [_intervalSection, "timeCrouchMidSpeed", 0]] call _inidbi;
		_roundTimeCrouchMidSpeed = parseNumber ((_timeCrouchMidSpeed / 3600) toFixed 2);
		_roundTimeCrouchMidSpeedPercent = parseNumber ((100 / _timeInEvent * _timeCrouchMidSpeed) toFixed 2);
		_timeProneMidSpeed = ["read", [_intervalSection, "timeProneMidSpeed", 0]] call _inidbi;
		_roundTimeProneMidSpeed = parseNumber ((_timeProneMidSpeed / 3600) toFixed 2);
		_roundTimeProneMidSpeedPercent = parseNumber ((100 / _timeInEvent * _timeProneMidSpeed) toFixed 2);

		_timeStandHighSpeed = ["read", [_intervalSection, "timeStandHighSpeed", 0]] call _inidbi;
		_roundTimeStandHighSpeed = parseNumber ((_timeStandHighSpeed / 3600) toFixed 2);
		_roundTimeStandHighSpeedPercent = parseNumber ((100 / _timeInEvent * _timeStandHighSpeed) toFixed 2);
		_timeCrouchHighSpeed = ["read", [_intervalSection, "timeCrouchHighSpeed", 0]] call _inidbi;
		_roundTimeCrouchHighSpeed = parseNumber ((_timeCrouchHighSpeed / 3600) toFixed 2);
		_roundTimeCrouchHighSpeedPercent = parseNumber ((100 / _timeInEvent * _timeCrouchHighSpeed) toFixed 2);
		_timeProneHighSpeed = ["read", [_intervalSection, "timeProneHighSpeed", 0]] call _inidbi;
		_roundTimeProneHighSpeed = parseNumber ((_timeProneHighSpeed / 3600) toFixed 2);
		_roundTimeProneHighSpeedPercent = parseNumber ((100 / _timeInEvent * _timeProneHighSpeed) toFixed 2);
		
		_timeInVehicle = ["read", [_intervalSection, "timeInVehicle", 0]] call _inidbi;
		_roundTimeInVehicle = parseNumber ((_timeInVehicle / 3600) toFixed 2);
		_roundTimeInVehiclePercent = parseNumber ((100 / _timeInEvent * _timeInVehicle) toFixed 2);			

		_timeCarDriver = ["read", [_intervalSection, "timeCarDriver", 0]] call _inidbi;
		_roundTimeCarDriver = parseNumber ((_timeCarDriver / 3600) toFixed 2);
		_roundTimeCarDriverPercent = parseNumber ((100 / _timeInEvent * _timeCarDriver) toFixed 2);
		_timeCarGunner = ["read", [_intervalSection, "timeCarGunner", 0]] call _inidbi;
		_roundTimeCarGunner = parseNumber ((_timeCarGunner / 3600) toFixed 2);
		_roundTimeCarGunnerPercent = parseNumber ((100 / _timeInEvent * _timeCarGunner) toFixed 2);
		_timeCarCommander = ["read", [_intervalSection, "timeCarCommander", 0]] call _inidbi;
		_roundTimeCarCommander = parseNumber ((_timeCarCommander / 3600) toFixed 2);
		_roundTimeCarCommanderPercent = parseNumber ((100 / _timeInEvent * _timeCarCommander) toFixed 2);
		_timeCarPassenger = ["read", [_intervalSection, "timeCarPassenger", 0]] call _inidbi;
		_roundTimeCarPassenger = parseNumber ((_timeCarPassenger / 3600) toFixed 2);
		_roundTimeCarPassengerPercent = parseNumber ((100 / _timeInEvent * _timeCarPassenger) toFixed 2);

		_timeTankDriver = ["read", [_intervalSection, "timeTankDriver", 0]] call _inidbi;
		_roundTimeTankDriver = parseNumber ((_timeTankDriver / 3600) toFixed 2);
		_roundTimeTankDriverPercent = parseNumber ((100 / _timeInEvent * _timeTankDriver) toFixed 2);
		_timeTankGunner = ["read", [_intervalSection, "timeTankGunner", 0]] call _inidbi;
		_roundTimeTankGunner = parseNumber ((_timeTankGunner / 3600) toFixed 2);
		_roundTimeTankGunnerPercent = parseNumber ((100 / _timeInEvent * _timeTankGunner) toFixed 2);
		_timeTankCommander = ["read", [_intervalSection, "timeTankCommander", 0]] call _inidbi;
		_roundTimeTankCommander = parseNumber ((_timeTankCommander / 3600) toFixed 2);
		_roundTimeTankCommanderPercent = parseNumber ((100 / _timeInEvent * _timeTankCommander) toFixed 2);
		_timeTankPassenger = ["read", [_intervalSection, "timeTankPassenger", 0]] call _inidbi;
		_roundTimeTankPassenger = parseNumber ((_timeTankPassenger / 3600) toFixed 2);
		_roundTimeTankPassengerPercent = parseNumber ((100 / _timeInEvent * _timeTankPassenger) toFixed 2);

		_timeTruckDriver = ["read", [_intervalSection, "timeTruckDriver", 0]] call _inidbi;
		_roundTimeTruckDriver = parseNumber ((_timeTruckDriver / 3600) toFixed 2);
		_roundTimeTruckDriverPercent = parseNumber ((100 / _timeInEvent * _timeTruckDriver) toFixed 2);
		_timeTruckGunner = ["read", [_intervalSection, "timeTruckGunner", 0]] call _inidbi;
		_roundTimeTruckGunner = parseNumber ((_timeTruckGunner / 3600) toFixed 2);
		_roundTimeTruckGunnerPercent = parseNumber ((100 / _timeInEvent * _timeTruckGunner) toFixed 2);
		_timeTruckCommander = ["read", [_intervalSection, "timeTruckCommander", 0]] call _inidbi;
		_roundTimeTruckCommander = parseNumber ((_timeTruckCommander / 3600) toFixed 2);
		_roundTimeTruckCommanderPercent = parseNumber ((100 / _timeInEvent * _timeTruckCommander) toFixed 2);
		_timeTruckPassenger = ["read", [_intervalSection, "timeTruckPassenger", 0]] call _inidbi;
		_roundTimeTruckPassenger = parseNumber ((_timeTruckPassenger / 3600) toFixed 2);
		_roundTimeTruckPassengerPercent = parseNumber ((100 / _timeInEvent * _timeTruckPassenger) toFixed 2);
		
		_timeMotorcycleDriver = ["read", [_intervalSection, "timeMotorcycleDriver", 0]] call _inidbi;
		_roundTimeMotorcycleDriver = parseNumber ((_timeMotorcycleDriver / 3600) toFixed 2);
		_roundTimeMotorcycleDriverPercent = parseNumber ((100 / _timeInEvent * _timeMotorcycleDriver) toFixed 2);
		_timeMotorcycleGunner = ["read", [_intervalSection, "timeMotorcycleGunner", 0]] call _inidbi;
		_roundTimeMotorcycleGunner = parseNumber ((_timeMotorcycleGunner / 3600) toFixed 2);
		_roundTimeMotorcycleGunnerPercent = parseNumber ((100 / _timeInEvent * _timeMotorcycleGunner) toFixed 2);
		_timeMotorcycleCommander = ["read", [_intervalSection, "timeMotorcycleCommander", 0]] call _inidbi;
		_roundTimeMotorcycleCommander = parseNumber ((_timeMotorcycleCommander / 3600) toFixed 2);
		_roundTimeMotorcycleCommanderPercent = parseNumber ((100 / _timeInEvent * _timeMotorcycleCommander) toFixed 2);
		_timeMotorcyclePassenger = ["read", [_intervalSection, "timeMotorcyclePassenger", 0]] call _inidbi;
		_roundTimeMotorcyclePassenger = parseNumber ((_timeMotorcyclePassenger / 3600) toFixed 2);
		_roundTimeMotorcyclePassengerPercent = parseNumber ((100 / _timeInEvent * _timeMotorcyclePassenger) toFixed 2);
		
		_timeHelicopterDriver = ["read", [_intervalSection, "timeHelicopterDriver", 0]] call _inidbi;
		_roundTimeHelicopterDriver = parseNumber ((_timeHelicopterDriver / 3600) toFixed 2);
		_roundTimeHelicopterDriverPercent = parseNumber ((100 / _timeInEvent * _timeHelicopterDriver) toFixed 2);
		_timeHelicopterGunner = ["read", [_intervalSection, "timeHelicopterGunner", 0]] call _inidbi;
		_roundTimeHelicopterGunner = parseNumber ((_timeHelicopterGunner / 3600) toFixed 2);
		_roundTimeHelicopterGunnerPercent = parseNumber ((100 / _timeInEvent * _timeHelicopterGunner) toFixed 2);
		_timeHelicopterCommander = ["read", [_intervalSection, "timeHelicopterCommander", 0]] call _inidbi;
		_roundTimeHelicopterCommander = parseNumber ((_timeHelicopterCommander / 3600) toFixed 2);
		_roundTimeHelicopterCommanderPercent = parseNumber ((100 / _timeInEvent * _timeHelicopterCommander) toFixed 2);
		_timeHelicopterPassenger = ["read", [_intervalSection, "timeHelicopterPassenger", 0]] call _inidbi;
		_roundTimeHelicopterPassenger = parseNumber ((_timeHelicopterPassenger / 3600) toFixed 2);
		_roundTimeHelicopterPassengerPercent = parseNumber ((100 / _timeInEvent * _timeHelicopterPassenger) toFixed 2);

		_timePlaneDriver = ["read", [_intervalSection, "timePlaneDriver", 0]] call _inidbi;
		_roundTimePlaneDriver = parseNumber ((_timePlaneDriver / 3600) toFixed 2);
		_roundTimePlaneDriverPercent = parseNumber ((100 / _timeInEvent * _timePlaneDriver) toFixed 2);
		_timePlaneGunner = ["read", [_intervalSection, "timePlaneGunner", 0]] call _inidbi;
		_roundTimePlaneGunner = parseNumber ((_timePlaneGunner / 3600) toFixed 2);
		_roundTimePlaneGunnerPercent = parseNumber ((100 / _timeInEvent * _timePlaneGunner) toFixed 2);
		_timePlaneCommander = ["read", [_intervalSection, "timePlaneCommander", 0]] call _inidbi;
		_roundTimePlaneCommander = parseNumber ((_timePlaneCommander / 3600) toFixed 2);
		_roundTimePlaneCommanderPercent = parseNumber ((100 / _timeInEvent * _timePlaneCommander) toFixed 2);
		_timePlanePassenger = ["read", [_intervalSection, "timePlanePassenger", 0]] call _inidbi;
		_roundTimePlanePassenger = parseNumber ((_timePlanePassenger / 3600) toFixed 2);
		_roundTimePlanePassengerPercent = parseNumber ((100 / _timeInEvent * _timePlanePassenger) toFixed 2);
		
		_timeShipDriver = ["read", [_intervalSection, "timeShipDriver", 0]] call _inidbi;
		_roundTimeShipDriver = parseNumber ((_timeShipDriver / 3600) toFixed 2);
		_roundTimeShipDriverPercent = parseNumber ((100 / _timeInEvent * _timeShipDriver) toFixed 2);
		_timeShipGunner = ["read", [_intervalSection, "timeShipGunner", 0]] call _inidbi;
		_roundTimeShipGunner = parseNumber ((_timeShipGunner / 3600) toFixed 2);
		_roundTimeShipGunnerPercent = parseNumber ((100 / _timeInEvent * _timeShipGunner) toFixed 2);
		_timeShipCommander = ["read", [_intervalSection, "timeShipCommander", 0]] call _inidbi;
		_roundTimeShipCommander = parseNumber ((_timeShipCommander / 3600) toFixed 2);
		_roundTimeShipCommanderPercent = parseNumber ((100 / _timeInEvent * _timeShipCommander) toFixed 2);
		_timeShipPassenger = ["read", [_intervalSection, "timeShipPassenger", 0]] call _inidbi;
		_roundTimeShipPassenger = parseNumber ((_timeShipPassenger / 3600) toFixed 2);
		_roundTimeShipPassengerPercent = parseNumber ((100 / _timeInEvent * _timeShipPassenger) toFixed 2);
		
		_timeBoatDriver = ["read", [_intervalSection, "timeBoatDriver", 0]] call _inidbi;
		_roundTimeBoatDriver = parseNumber ((_timeBoatDriver / 3600) toFixed 2);
		_roundTimeBoatDriverPercent = parseNumber ((100 / _timeInEvent * _timeBoatDriver) toFixed 2);
		_timeBoatGunner = ["read", [_intervalSection, "timeBoatGunner", 0]] call _inidbi;
		_roundTimeBoatGunner = parseNumber ((_timeBoatGunner / 3600) toFixed 2);
		_roundTimeBoatGunnerPercent = parseNumber ((100 / _timeInEvent * _timeBoatGunner) toFixed 2);
		_timeBoatCommander = ["read", [_intervalSection, "timeBoatCommander", 0]] call _inidbi;
		_roundTimeBoatCommander = parseNumber ((_timeBoatCommander / 3600) toFixed 2);
		_roundTimeBoatCommanderPercent = parseNumber ((100 / _timeInEvent * _timeBoatCommander) toFixed 2);
		_timeBoatPassenger = ["read", [_intervalSection, "timeBoatPassenger", 0]] call _inidbi;
		_roundTimeBoatPassenger = parseNumber ((_timeBoatPassenger / 3600) toFixed 2);
		_roundTimeBoatPassengerPercent = parseNumber ((100 / _timeInEvent * _timeBoatPassenger) toFixed 2);
		
		_timeMapVisible = ["read", [_intervalSection, "timeMapVisible", 0]] call _inidbi;
		_roundTimeMapVisible = parseNumber ((_timeMapVisible / 3600) toFixed 2);
		_roundTimeMapVisiblePercent = parseNumber ((100 / _timeInEvent * _timeMapVisible) toFixed 2);
		_timeGpsVisible = ["read", [_intervalSection, "timeGpsVisible", 0]] call _inidbi;
		_roundTimeGpsVisible = parseNumber ((_timeGpsVisible / 3600) toFixed 2);
		_roundTimeGpsVisiblePercent = parseNumber ((100 / _timeInEvent * _timeGpsVisible) toFixed 2);
		_timeWeaponLowered = ["read", [_intervalSection, "timeWeaponLowered", 0]] call _inidbi;
		_roundTimeWeaponLowered = parseNumber ((_timeWeaponLowered / 3600) toFixed 2);
		_roundTimeWeaponLoweredPercent = parseNumber ((100 / _timeInEvent * _timeWeaponLowered) toFixed 2);

		_timeAddonAceActive = ["read", [_intervalSection, "timeAddonAceActive", 0]] call _inidbi;
		_roundTimeAddonAceActive = parseNumber ((_timeAddonAceActive / 3600) toFixed 2);
		_roundTimeAddonAceActivePercent = parseNumber ((100 / _timeInEvent * _timeAddonAceActive) toFixed 2);
		_timeAddonTfarActive = ["read", [_intervalSection, "timeAddonTfarActive", 0]] call _inidbi;
		_roundTimeAddonTfarActive = parseNumber ((_timeAddonTfarActive / 3600) toFixed 2);
		_roundTimeAddonTfarActivePercent = parseNumber ((100 / _timeInEvent * _timeAddonTfarActive) toFixed 2);
		
		_tmpResult = [];
		_tmpResult = _tmpResult + [[format ["Player Name: %1", _requestedPlayerName], "requestedPlayerName"]];
		_tmpResult = _tmpResult + [[format ["Player UID: %1", _requestedPlayerUid], "requestedPlayerUid"]];
		_tmpResult = _tmpResult + [[format ["Count Updates: %1", _countUpdates], "countUpdates"]];
		_tmpResult = _tmpResult + [[format ["Time in Game: %1 hrs", str _roundTimeInEvent], "timeInEvent"]];
		
		_tmpResult = _tmpResult + [[format ["[A3] Count Projectiles Fired: %1", _countProjectilesFired], "countProjectilesFired"]];
		_tmpResult = _tmpResult + [[format ["[A3] Count Grenades Thrown: %1", _countGrenadesThrown], "countGrenadesThrown"]];
		_tmpResult = _tmpResult + [[format ["[A3] Count Smoke Shells Thrown: %1", _countSmokeShellsThrown], "countSmokeShellsThrown"]];
		_tmpResult = _tmpResult + [[format ["[A3] Count Chemlights Thrown: %1", _countChemlightsThrown], "countChemlightsThrown"]];
		_tmpResult = _tmpResult + [[format ["[A3] Count Unknown Thrown: %1", _countUnknownThrown], "countUnknownThrown"]];

		_tmpResult = _tmpResult + [[format ["[A3] Count Projectiles Hit Enemy: %2 (%3%1)", "%", _countProjectilesHitEnemy, _roundCountProjectilesHitEnemyPercent], "countProjectilesHitEnemy"]];
		_tmpResult = _tmpResult + [[format ["[A3] Count Projectiles Hit Friendly: %2 (%3%1)", "%", _countProjectilesHitFriendly, _roundCountProjectilesHitFriendlyPercent], "countProjectilesHitFriendly"]];		
		_tmpResult = _tmpResult + [[format ["[A3] Count Grenades Hit Enemy: %2 (%3%1)", "%", _countGrenadesHitEnemy, _roundCountGrenadesHitEnemyPercent], "countGrenadesHitEnemy"]];
		_tmpResult = _tmpResult + [[format ["[A3] Count Grenades Hit Friendly: %2 (%3%1)", "%", _countGrenadesHitFriendly, _roundCountGrenadesHitFriendlyPercent], "countGrenadesHitFriendly"]];	
		
		_tmpResult = _tmpResult + [[format ["[A3] Count Kills: %1", _countPlayerKills], "countPlayerKills"]];
		_tmpResult = _tmpResult + [[format ["[A3] Count Deaths: %1", _countPlayerDeaths], "countPlayerDeaths"]];
		_tmpResult = _tmpResult + [[format ["[A3] Count Suicides: %1", _countPlayerSuicides], "countPlayerSuicides"]];
		_tmpResult = _tmpResult + [[format ["[A3] Count Team Kills: %1", _countPlayerTeamKills], "countPlayerTeamKills"]];
		
		_tmpResult = _tmpResult + [[format ["[A3] Interface Zeus Opened: %1", _countCuratorInterfaceOpened], "countCuratorInterfaceOpened"]];
		_tmpResult = _tmpResult + [[format ["[A3] Interface Gear Opened: %1", round (_countGearInterfaceOpened / 2)], "countGearInterfaceOpened"]];
		_tmpResult = _tmpResult + [[format ["[A3] Interface Compass Opened: %1", _countCompassInterfaceOpened], "countCompassInterfaceOpened"]];
		_tmpResult = _tmpResult + [[format ["[A3] Interface Watch Opened: %1", _countWatchInterfaceOpened], "countWatchInterfaceOpened"]];

		_tmpResult = _tmpResult + [[format ["[A3] Time On Foot: %2 hrs (%3%1)", "%", str _roundTimeOnFoot, str _roundTimeOnFootPercent], "timeOnFoot"]];

		_tmpResult = _tmpResult + [[format ["[A3] Time Stand No Speed: %2 hrs (%3%1)", "%", str _roundTimeStandNoSpeed, str _roundTimeStandNoSpeedPercent], "timeStandNoSpeed"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Crouch No Speed: %2 hrs (%3%1)", "%", str _roundTimeCrouchNoSpeed, str _roundTimeCrouchNoSpeedPercent], "timeCrouchNoSpeed"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Prone No Speed: %2 hrs (%3%1)", "%", str _roundTimeProneNoSpeed, str _roundTimeProneNoSpeedPercent], "timeProneNoSpeed"]];
		
		_tmpResult = _tmpResult + [[format ["[A3] Time Stand Low Speed: %2 hrs (%3%1)", "%", str _roundTimeStandLowSpeed, str _roundTimeStandLowSpeedPercent], "timeStandLowSpeed"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Crouch Low Speed: %2 hrs (%3%1)", "%", str _roundTimeCrouchLowSpeed, str _roundTimeCrouchLowSpeedPercent], "timeCrouchLowSpeed"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Prone Low Speed: %2 hrs (%3%1)", "%", str _roundTimeProneLowSpeed, str _roundTimeProneLowSpeedPercent], "timeProneLowSpeed"]];
		
		_tmpResult = _tmpResult + [[format ["[A3] Time Stand Mid Speed: %2 hrs (%3%1)", "%", str _roundTimeStandMidSpeed, str _roundTimeStandMidSpeedPercent], "timeStandMidSpeed"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Crouch Mid Speed: %2 hrs (%3%1)", "%", str _roundTimeCrouchMidSpeed, str _roundTimeCrouchMidSpeedPercent], "timeCrouchMidSpeed"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Prone Mid Speed: %2 hrs (%3%1)", "%", str _roundTimeProneMidSpeed, str _roundTimeProneMidSpeedPercent], "timeProneMidSpeed"]];
		
		_tmpResult = _tmpResult + [[format ["[A3] Time Stand High Speed: %2 hrs (%3%1)", "%", str _roundTimeStandHighSpeed, str _roundTimeStandHighSpeedPercent], "timeStandHighSpeed"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Crouch High Speed: %2 hrs (%3%1)", "%", str _roundTimeCrouchHighSpeed, str _roundTimeCrouchHighSpeedPercent], "timeCrouchHighSpeed"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Prone High Speed: %2 hrs (%3%1)", "%", str _roundTimeProneHighSpeed, str _roundTimeProneHighSpeedPercent], "timeProneHighSpeed"]];

		_tmpResult = _tmpResult + [[format ["[A3] Time In Vehicle: %2 hrs (%3%1)", "%", str _roundTimeInVehicle, str _roundTimeInVehiclePercent], "timeInVehicle"]];

		_tmpResult = _tmpResult + [[format ["[A3] Time Car Driver: %2 hrs (%3%1)", "%", str _roundTimeCarDriver, str _roundTimeCarDriverPercent], "timeCarDriver"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Car Gunner: %2 hrs (%3%1)", "%", str _roundTimeCarGunner, str _roundTimeCarGunnerPercent], "timeCarGunner"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Car Commander: %2 hrs (%3%1)", "%", str _roundTimeCarCommander, str _roundTimeCarCommanderPercent], "timeCarCommander"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Car Passenger: %2 hrs (%3%1)", "%", str _roundTimeCarPassenger, str _roundTimeCarPassengerPercent], "timeCarPassenger"]];
		
		_tmpResult = _tmpResult + [[format ["[A3] Time Tank Driver: %2 hrs (%3%1)", "%", str _roundTimeTankDriver, str _roundTimeTankDriverPercent], "timeTankDriver"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Tank Gunner: %2 hrs (%3%1)", "%", str _roundTimeTankGunner, str _roundTimeTankGunnerPercent], "timeTankGunner"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Tank Commander: %2 hrs (%3%1)", "%", str _roundTimeTankCommander, str _roundTimeTankCommanderPercent], "timeTankCommander"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Tank Passenger: %2 hrs (%3%1)", "%", str _roundTimeTankPassenger, str _roundTimeTankPassengerPercent], "timeTankPassenger"]];
		
		_tmpResult = _tmpResult + [[format ["[A3] Time Truck Driver: %2 hrs (%3%1)", "%", str _roundTimeTruckDriver, str _roundTimeTruckDriverPercent], "timeTruckDriver"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Truck Gunner: %2 hrs (%3%1)", "%", str _roundTimeTruckGunner, str _roundTimeTruckGunnerPercent], "timeTruckGunner"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Truck Commander: %2 hrs (%3%1)", "%", str _roundTimeTruckCommander, str _roundTimeTruckCommanderPercent], "timeTruckCommander"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Truck Passenger: %2 hrs (%3%1)", "%", str _roundTimeTruckPassenger, str _roundTimeTruckPassengerPercent], "timeTruckPassenger"]];
		
		_tmpResult = _tmpResult + [[format ["[A3] Time Motorcycle Driver: %2 hrs (%3%1)", "%", str _roundTimeMotorcycleDriver, str _roundTimeMotorcycleDriverPercent], "timeMotorcycleDriver"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Motorcycle Gunner: %2 hrs (%3%1)", "%", str _roundTimeMotorcycleGunner, str _roundTimeMotorcycleGunnerPercent], "timeMotorcycleGunner"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Motorcycle Commander: %2 hrs (%3%1)", "%", str _roundTimeMotorcycleCommander, str _roundTimeMotorcycleCommanderPercent], "timeMotorcycleCommander"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Motorcycle Passenger: %2 hrs (%3%1)", "%", str _roundTimeMotorcyclePassenger, str _roundTimeMotorcyclePassengerPercent], "timeMotorcyclePassenger"]];
		
		_tmpResult = _tmpResult + [[format ["[A3] Time Helicopter Driver: %2 hrs (%3%1)", "%", str _roundTimeHelicopterDriver, str _roundTimeHelicopterDriverPercent], "timeHelicopterDriver"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Helicopter Gunner: %2 hrs (%3%1)", "%", str _roundTimeHelicopterGunner, str _roundTimeHelicopterGunnerPercent], "timeHelicopterGunner"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Helicopter Commander: %2 hrs (%3%1)", "%", str _roundTimeHelicopterCommander, str _roundTimeHelicopterCommanderPercent], "timeHelicopterCommander"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Helicopter Passenger: %2 hrs (%3%1)", "%", str _roundTimeHelicopterPassenger, str _roundTimeHelicopterPassengerPercent], "timeHelicopterPassenger"]];
		
		_tmpResult = _tmpResult + [[format ["[A3] Time Plane Driver: %2 hrs (%3%1)", "%", str _roundTimePlaneDriver, str _roundTimePlaneDriverPercent], "timePlaneDriver"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Plane Gunner: %2 hrs (%3%1)", "%", str _roundTimePlaneGunner, str _roundTimePlaneGunnerPercent], "timePlaneGunner"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Plane Commander: %2 hrs (%3%1)", "%", str _roundTimePlaneCommander, str _roundTimePlaneCommanderPercent], "timePlaneCommander"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Plane Passenger: %2 hrs (%3%1)", "%", str _roundTimePlanePassenger, str _roundTimePlanePassengerPercent], "timePlanePassenger"]];
		
		_tmpResult = _tmpResult + [[format ["[A3] Time Ship Driver: %2 hrs (%3%1)", "%", str _roundTimeShipDriver, str _roundTimeShipDriverPercent], "timeShipDriver"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Ship Gunner: %2 hrs (%3%1)", "%", str _roundTimeShipGunner, str _roundTimeShipGunnerPercent], "timeShipGunner"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Ship Commander: %2 hrs (%3%1)", "%", str _roundTimeShipCommander, str _roundTimeShipCommanderPercent], "timeShipCommander"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Ship Passenger: %2 hrs (%3%1)", "%", str _roundTimeShipPassenger, str _roundTimeShipPassengerPercent], "timeShipPassenger"]];
		
		_tmpResult = _tmpResult + [[format ["[A3] Time Boat Driver: %2 hrs (%3%1)", "%", str _roundTimeBoatDriver, str _roundTimeBoatDriverPercent], "timeBoatDriver"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Boat Gunner: %2 hrs (%3%1)", "%", str _roundTimeBoatGunner, str _roundTimeBoatGunnerPercent], "timeBoatGunner"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Boat Commander: %2 hrs (%3%1)", "%", str _roundTimeBoatCommander, str _roundTimeBoatCommanderPercent], "timeBoatCommander"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Boat Passenger: %2 hrs (%3%1)", "%", str _roundTimeBoatPassenger, str _roundTimeBoatPassengerPercent], "timeBoatPassenger"]];
	
		_tmpResult = _tmpResult + [[format ["[A3] Time Map Visible: %2 hrs (%3%1)", "%", str _roundTimeMapVisible, str _roundTimeMapVisiblePercent], "timeMapVisible"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Gps Visible: %2 hrs (%3%1)", "%", str _roundTimeGpsVisible, str _roundTimeGpsVisiblePercent], "timeGpsVisible"]];
		_tmpResult = _tmpResult + [[format ["[A3] Time Weapon Lowered: %2 hrs (%3%1)", "%", str _roundTimeWeaponLowered, str _roundTimeWeaponLoweredPercent], "timeWeaponLowered"]];

		_tmpResult = _tmpResult + [[format ["[ACE] Time Addon Ace Active: %2 hrs (%3%1)", "%", str _roundTimeAddonAceActive, str _roundTimeAddonAceActivePercent], "timeAddonAceActive"]];
		_tmpResult = _tmpResult + [[format ["[TFAR] Time Addon Tfar Active: %2 hrs (%3%1)", "%", str _roundTimeAddonTfarActive, str _roundTimeAddonTfarActivePercent], "timeAddonTfarActive"]];

		_result = [];	
		if(_filter != "") then
		{
			{
				if (((_x select 0) find _filter) > -1) then
				{
					_result = _result + [_x];
				};
			} forEach _tmpResult;
		}
		else
		{
			_result = _tmpResult;
		};

		_answer = _playerUid + "-answerPlayerStatisticsFiltered";
		missionNamespace setVariable [_answer, _result, false];
		_clientId publicVariableClient _answer;
		
		diag_log format ["[%1] PPS Player Request Statistics: %2 (%3)", serverTime, _requestedPlayerName, _requestedPlayerUid];
	};
};

/* ================================================================================ */

(_playerUid + "-requestPlayerDetailsFiltered") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;
	_filter = _broadcastVariableValue select 2;
	
	_dbName = "pps-players";
	_inidbi = ["new", _dbName] call OO_INIDBI;
	
	_isAdmin = ["read", [_playerUid, "isAdmin", 0]] call _inidbi;
	_isAdminLoggedIn = ["read", [_playerUid, "isAdminLoggedIn", 0]] call _inidbi;
	
	_sections = [];
	
	if ((_isAdmin == 1) && (_isAdminLoggedIn == 1)) then
	{
		_sections = "getSections" call _inidbi;
	}
	else
	{
		_sections = [_playerUid];
	};
	
	_tmpResult = [];
	{
		_tmpPlayerName = ["read", [_x, "playerName", ""]] call _inidbi;
		_tmpPlayerUid = ["read", [_x, "playerUid", ""]] call _inidbi;
		_tmpIsAdmin = ["read", [_x, "isAdmin", 0]] call _inidbi;
		_tmpIsAdminLoggedIn = ["read", [_x, "isAdminLoggedIn", 0]] call _inidbi;
		
		_tmpPlayerIsTrackValueActive = ["read", [_x, "isTrackValueActive", 0]] call _inidbi;
		_tmpPlayerTrackValueVariable = ["read", [_x, "trackValueVariable", ""]] call _inidbi;
		
		_tmpResult = _tmpResult + [[_tmpPlayerName, _tmpPlayerUid, _tmpIsAdmin, _tmpIsAdminLoggedIn, _tmpPlayerIsTrackValueActive, _tmpPlayerTrackValueVariable]];
	} forEach _sections;
	
	_result = [];
	if(_filter != "") then
	{
		{
			if (((_x select 0) find _filter) > -1) then
			{
				_result = _result + [_x];
			};
		} forEach _tmpResult;
	}
	else
	{
		_result = _tmpResult;
	};
	
	_answer = _playerUid + "-answerPlayerDetailsFiltered";
	missionNamespace setVariable [_answer, _result, false];
	_clientId publicVariableClient _answer;
	
	_dbName = "pps-player-" + _playerUid;
	_inidbi = ["new", _dbName] call OO_INIDBI;		
	_globalSection = "Global Informations";
	_playerName = ["read", [_globalSection, "playerName", ""]] call _inidbi;
	
	diag_log format ["[%1] PPS Player Request Player Details: %2 (%3)", serverTime, _playerName, _playerUid];
};

/* ================================================================================ */

(_playerUid + "-requestServerAndDatabaseStatus") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;
	
	_addons = activatedAddons;
	_isInidbi2Installed = false;
	if ((_addons find "inidbi2") > -1) then {_isInidbi2Installed = true};

	_result = [_playerUid, _clientId, _isInidbi2Installed];
	
	_answer = _playerUid + "-answerServerAndDatabaseStatus";
	missionNamespace setVariable [_answer, _result, false];
	_clientId publicVariableClient _answer;

	_dbName = "pps-player-" + _playerUid;
	_inidbi = ["new", _dbName] call OO_INIDBI;		
	_globalSection = "Global Informations";
	_playerName = ["read", [_globalSection, "playerName", ""]] call _inidbi;

	diag_log format ["[%1] PPS Player Request Server And Database Status: %2 (%3)", serverTime, _playerName, _playerUid];
};

/* ================================================================================ */

(_playerUid + "-requestPlayersAndAdminsCount") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;
	
	_countPlayersTotal = 0;
	_countPlayersOnline = 0;
	_countAdminsTotal = 0;
	_countAdminsOnline = 0;

	_dbName = "pps-players";
	_inidbi = ["new", _dbName] call OO_INIDBI;
	
	_sections = "getSections" call _inidbi;
	_countPlayersTotal = count _sections;
	
	_allActivePlayers = allPlayers - entities "HeadlessClient_F";
	_countPlayersOnline = count _allActivePlayers;
	
	{
		_isAdmin = ["read", [_x, "isAdmin", 0]] call _inidbi;
		if (_isAdmin == 1) then {_countAdminsTotal = _countAdminsTotal + 1};
	} forEach _sections;
	
	{
		_tmpPlayerUid = getPlayerUID _x;
		_isAdmin = ["read", [_tmpPlayerUid, "isAdmin", 0]] call _inidbi;
		if (_isAdmin == 1) then {_countAdminsOnline = _countAdminsOnline + 1};
	} forEach _allActivePlayers;

	_result = [_playerUid, _clientId, _countPlayersTotal, _countPlayersOnline, _countAdminsTotal, _countAdminsOnline];
	
	_answer = _playerUid + "-answerPlayersAndAdminsCount";
	missionNamespace setVariable [_answer, _result, false];
	_clientId publicVariableClient _answer;

	_dbName = "pps-player-" + _playerUid;
	_inidbi = ["new", _dbName] call OO_INIDBI;		
	_globalSection = "Global Informations";
	_playerName = ["read", [_globalSection, "playerName", ""]] call _inidbi;

	diag_log format ["[%1] PPS Player Request Players And Admins Count: %2 (%3)", serverTime, _playerName, _playerUid];
};

/* ================================================================================ */

(_playerUid + "-requestPlayerAdminStatus") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;
	
	_dbName = "pps-players";
	_inidbi = ["new", _dbName] call OO_INIDBI;
	
	_isAdmin = ["read", [_playerUid, "isAdmin", ""]] call _inidbi;
	_isAdminLoggedIn = ["read", [_playerUid, "isAdminLoggedIn", ""]] call _inidbi;
	
	_result = [_playerUid, _clientId, _isAdmin, _isAdminLoggedIn];
	
	_answer = _playerUid + "-answerPlayerAdminStatus";
	missionNamespace setVariable [_answer, _result, false];
	_clientId publicVariableClient _answer;

	_dbName = "pps-player-" + _playerUid;
	_inidbi = ["new", _dbName] call OO_INIDBI;		
	_globalSection = "Global Informations";
	_playerName = ["read", [_globalSection, "playerName", ""]] call _inidbi;

	diag_log format ["[%1] PPS Player Request Player Admin Status: Is Admin %2 %3 (%4)", serverTime, _isAdmin, _playerName, _playerUid];
};

/* ================================================================================ */

(_playerUid + "-updateEventHandlerValue") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	_dbName = "pps-server-settings";
	_inidbi = ["new", _dbName] call OO_INIDBI;	
	_settingsSection = "Settings";
	_isEvent = ["read", [_settingsSection, "isEvent", ""]] call _inidbi;
	
	if (_isEvent == 1) then
	{
		_playerUid = _broadcastVariableValue select 0;
		_section = _broadcastVariableValue select 1;
		_key = _broadcastVariableValue select 2;
		_valueAdd = _broadcastVariableValue select 3;

		_dbName = "pps-player-" + _playerUid;
		_inidbi = ["new", _dbName] call OO_INIDBI;
		
		_globalSection = "Global Informations";
		_playerName = ["read", [_globalSection, "playerName", ""]] call _inidbi;
		
		_valueOld = ["read", [_section, _key, 0]] call _inidbi;
		_value = _valueOld + _valueAdd;
		["write", [_section, _key, _value]] call _inidbi;

		_dbName = "pps-players";
		_inidbi = ["new", _dbName] call OO_INIDBI;
		
		_isTrackValueActive = ["read", [_playerUid, "isTrackValueActive", 0]] call _inidbi;
		_trackValueVariable = ["read", [_playerUid, "trackValueVariable", ""]] call _inidbi;
		_trackValueClientId = ["read", [_playerUid, "trackValueClientId", ""]] call _inidbi;
		
		if (_isTrackValueActive == 1) then
		{
			_dbName = "pps-player-" + _playerUid;
			_inidbi = ["new", _dbName] call OO_INIDBI;
			
			_trackValueValue = ["read", [_section, _trackValueVariable, "not set"]] call _inidbi;
			if ((str _trackValueValue) != (str "not set")) then
			{
				_trackValueString = format ["Variable: %1\nValue: %2", _trackValueVariable, _trackValueValue];
				_trackValueString remoteExec ["hint", _trackValueClientId];			
			};
		};

		diag_log format ["[%1] PPS Player Updated Event Handler Data: %2 (%3) Key: %4 Value: %5", serverTime, _playerName, _playerUid, _key, _value];
	};
};

/* ================================================================================ */

(_playerUid + "-updateIntervalValues") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];

	_dbName = "pps-server-settings";
	_inidbi = ["new", _dbName] call OO_INIDBI;		
	_settingsSection = "Settings";			
	_isEvent = ["read", [_settingsSection, "isEvent", ""]] call _inidbi;
	
	if (_isEvent == 1) then
	{
		_playerName = _broadcastVariableValue select 0;
		_playerUid = _broadcastVariableValue select 1;
		
		_timeInEventAdd = _broadcastVariableValue select 2;

		_timeOnFootAdd = _broadcastVariableValue select 3;
		
		_timeStandNoSpeedAdd = _broadcastVariableValue select 4;
		_timeCrouchNoSpeedAdd = _broadcastVariableValue select 5;
		_timeProneNoSpeedAdd = _broadcastVariableValue select 6;
		_timeStandLowSpeedAdd = _broadcastVariableValue select 7;
		_timeCrouchLowSpeedAdd = _broadcastVariableValue select 8;
		_timeProneLowSpeedAdd = _broadcastVariableValue select 9;
		_timeStandMidSpeedAdd = _broadcastVariableValue select 10;
		_timeCrouchMidSpeedAdd = _broadcastVariableValue select 11;
		_timeProneMidSpeedAdd = _broadcastVariableValue select 12;
		_timeStandHighSpeedAdd = _broadcastVariableValue select 13;
		_timeCrouchHighSpeedAdd = _broadcastVariableValue select 14;
		_timeProneHighSpeedAdd = _broadcastVariableValue select 15;
		
		_timeInVehicleAdd = _broadcastVariableValue select 16;
		
		_timeCarDriverAdd = _broadcastVariableValue select 17;
		_timeCarGunnerAdd = _broadcastVariableValue select 18;
		_timeCarCommanderAdd = _broadcastVariableValue select 19;
		_timeCarPassengerAdd = _broadcastVariableValue select 20;
		_timeTankDriverAdd = _broadcastVariableValue select 21;
		_timeTankGunnerAdd = _broadcastVariableValue select 22;
		_timeTankCommanderAdd = _broadcastVariableValue select 23;
		_timeTankPassengerAdd = _broadcastVariableValue select 24;
		_timeTruckDriverAdd = _broadcastVariableValue select 25;
		_timeTruckGunnerAdd = _broadcastVariableValue select 26;
		_timeTruckCommanderAdd = _broadcastVariableValue select 27;
		_timeTruckPassengerAdd = _broadcastVariableValue select 28;
		_timeMotorcycleDriverAdd = _broadcastVariableValue select 29;
		_timeMotorcycleGunnerAdd = _broadcastVariableValue select 30;
		_timeMotorcycleCommanderAdd = _broadcastVariableValue select 31;
		_timeMotorcyclePassengerAdd = _broadcastVariableValue select 32;
		_timeHelicopterDriverAdd = _broadcastVariableValue select 33;
		_timeHelicopterGunnerAdd = _broadcastVariableValue select 34;
		_timeHelicopterCommanderAdd = _broadcastVariableValue select 35;
		_timeHelicopterPassengerAdd = _broadcastVariableValue select 36;
		_timePlaneDriverAdd = _broadcastVariableValue select 37;
		_timePlaneGunnerAdd = _broadcastVariableValue select 38;
		_timePlaneCommanderAdd = _broadcastVariableValue select 39;
		_timePlanePassengerAdd = _broadcastVariableValue select 40;
		_timeShipDriverAdd = _broadcastVariableValue select 41;
		_timeShipGunnerAdd = _broadcastVariableValue select 42;
		_timeShipCommanderAdd = _broadcastVariableValue select 43;
		_timeShipPassengerAdd = _broadcastVariableValue select 44;
		_timeBoatDriverAdd = _broadcastVariableValue select 45;
		_timeBoatGunnerAdd = _broadcastVariableValue select 46;
		_timeBoatCommanderAdd = _broadcastVariableValue select 47;
		_timeBoatPassengerAdd = _broadcastVariableValue select 48;
		
		_timeMapVisibleAdd = _broadcastVariableValue select 49;
		_timeGpsVisibleAdd = _broadcastVariableValue select 50;
		_timeWeaponLoweredAdd = _broadcastVariableValue select 51;
		
		_timeAddonAceActiveAdd = _broadcastVariableValue select 52;
		_timeAddonTfarActiveAdd = _broadcastVariableValue select 53;

		_dbName = "pps-player-" + _playerUid;
		_inidbi = ["new", _dbName] call OO_INIDBI;
		
		_globalSection = "Global Informations";
		_intervalSection = "Interval Statistics";
		
		_filter = "0123456789AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZzÜüÖöÄä[]-_.:#*(){}%$§&<>+-,;'~?= ";
		_playerName = [_playerName, _filter] call BIS_fnc_filterString;
		
		_countUpdates = ["read", [_intervalSection, "countUpdates", 0]] call _inidbi;
		_countUpdates = _countUpdates + 1;
		["write", [_intervalSection, "countUpdates", _countUpdates]] call _inidbi;
		
		["write", [_globalSection, "playerName", _playerName]] call _inidbi;
		["write", [_globalSection, "playerUid", _playerUid]] call _inidbi;
		
		_timeInEventOld = ["read", [_intervalSection, "timeInEvent", 0]] call _inidbi;
		_timeInEvent = _timeInEventOld + _timeInEventAdd;
		["write", [_intervalSection, "timeInEvent", _timeInEvent]] call _inidbi;

		_timeOnFootOld = ["read", [_intervalSection, "timeOnFoot", 0]] call _inidbi;
		_timeOnFoot = _timeOnFootOld + _timeOnFootAdd;
		["write", [_intervalSection, "timeOnFoot", _timeOnFoot]] call _inidbi;		

		_timeStandNoSpeedOld = ["read", [_intervalSection, "timeStandNoSpeed", 0]] call _inidbi;
		_timeStandNoSpeed = _timeStandNoSpeedOld + _timeStandNoSpeedAdd;
		["write", [_intervalSection, "timeStandNoSpeed", _timeStandNoSpeed]] call _inidbi;			
		_timeCrouchNoSpeedOld = ["read", [_intervalSection, "timeCrouchNoSpeed", 0]] call _inidbi;
		_timeCrouchNoSpeed = _timeCrouchNoSpeedOld + _timeCrouchNoSpeedAdd;
		["write", [_intervalSection, "timeCrouchNoSpeed", _timeCrouchNoSpeed]] call _inidbi;	
		_timeProneNoSpeedOld = ["read", [_intervalSection, "timeProneNoSpeed", 0]] call _inidbi;
		_timeProneNoSpeed = _timeProneNoSpeedOld + _timeProneNoSpeedAdd;
		["write", [_intervalSection, "timeProneNoSpeed", _timeProneNoSpeed]] call _inidbi;		
		
		_timeStandLowSpeedOld = ["read", [_intervalSection, "timeStandLowSpeed", 0]] call _inidbi;
		_timeStandLowSpeed = _timeStandLowSpeedOld + _timeStandLowSpeedAdd;
		["write", [_intervalSection, "timeStandLowSpeed", _timeStandLowSpeed]] call _inidbi;		
		_timeCrouchLowSpeedOld = ["read", [_intervalSection, "timeCrouchLowSpeed", 0]] call _inidbi;
		_timeCrouchLowSpeed = _timeCrouchLowSpeedOld + _timeCrouchLowSpeedAdd;
		["write", [_intervalSection, "timeCrouchLowSpeed", _timeCrouchLowSpeed]] call _inidbi;		
		_timeProneLowSpeedOld = ["read", [_intervalSection, "timeProneLowSpeed", 0]] call _inidbi;
		_timeProneLowSpeed = _timeProneLowSpeedOld + _timeProneLowSpeedAdd;
		["write", [_intervalSection, "timeProneLowSpeed", _timeProneLowSpeed]] call _inidbi;		
		
		_timeStandMidSpeedOld = ["read", [_intervalSection, "timeStandMidSpeed", 0]] call _inidbi;
		_timeStandMidSpeed = _timeStandMidSpeedOld + _timeStandMidSpeedAdd;
		["write", [_intervalSection, "timeStandMidSpeed", _timeStandMidSpeed]] call _inidbi;	
		_timeCrouchMidSpeedOld = ["read", [_intervalSection, "timeCrouchMidSpeed", 0]] call _inidbi;
		_timeCrouchMidSpeed = _timeCrouchMidSpeedOld + _timeCrouchMidSpeedAdd;
		["write", [_intervalSection, "timeCrouchMidSpeed", _timeCrouchMidSpeed]] call _inidbi;			
		_timeProneMidSpeedOld = ["read", [_intervalSection, "timeProneMidSpeed", 0]] call _inidbi;
		_timeProneMidSpeed = _timeProneMidSpeedOld + _timeProneMidSpeedAdd;
		["write", [_intervalSection, "timeProneMidSpeed", _timeProneMidSpeed]] call _inidbi;	
		
		_timeStandHighSpeedOld = ["read", [_intervalSection, "timeStandHighSpeed", 0]] call _inidbi;
		_timeStandHighSpeed = _timeStandHighSpeedOld + _timeStandHighSpeedAdd;
		["write", [_intervalSection, "timeStandHighSpeed", _timeStandHighSpeed]] call _inidbi;			
		_timeCrouchHighSpeedOld = ["read", [_intervalSection, "timeCrouchHighSpeed", 0]] call _inidbi;
		_timeCrouchHighSpeed = _timeCrouchHighSpeedOld + _timeCrouchHighSpeedAdd;
		["write", [_intervalSection, "timeCrouchHighSpeed", _timeCrouchHighSpeed]] call _inidbi;	
		_timeProneHighSpeedOld = ["read", [_intervalSection, "timeProneHighSpeed", 0]] call _inidbi;
		_timeProneHighSpeed = _timeProneHighSpeedOld + _timeProneHighSpeedAdd;
		["write", [_intervalSection, "timeProneHighSpeed", _timeProneHighSpeed]] call _inidbi;				

		_timeInVehicleOld = ["read", [_intervalSection, "timeInVehicle", 0]] call _inidbi;
		_timeInVehicle = _timeInVehicleOld + _timeInVehicleAdd;
		["write", [_intervalSection, "timeInVehicle", _timeInVehicle]] call _inidbi;				

		_timeCarDriverOld = ["read", [_intervalSection, "timeCarDriver", 0]] call _inidbi;
		_timeCarDriver = _timeCarDriverOld + _timeCarDriverAdd;
		["write", [_intervalSection, "timeCarDriver", _timeCarDriver]] call _inidbi;				
		_timeCarGunnerOld = ["read", [_intervalSection, "timeCarGunner", 0]] call _inidbi;
		_timeCarGunner = _timeCarGunnerOld + _timeCarGunnerAdd;
		["write", [_intervalSection, "timeCarGunner", _timeCarGunner]] call _inidbi;		
		_timeCarCommanderOld = ["read", [_intervalSection, "timeCarCommander", 0]] call _inidbi;
		_timeCarCommander = _timeCarCommanderOld + _timeCarCommanderAdd;
		["write", [_intervalSection, "timeCarCommander", _timeCarCommander]] call _inidbi;		
		_timeCarPassengerOld = ["read", [_intervalSection, "timeCarPassenger", 0]] call _inidbi;
		_timeCarPassenger = _timeCarPassengerOld + _timeCarPassengerAdd;
		["write", [_intervalSection, "timeCarPassenger", _timeCarPassenger]] call _inidbi;	
		
		_timeTankDriverOld = ["read", [_intervalSection, "timeTankDriver", 0]] call _inidbi;
		_timeTankDriver = _timeTankDriverOld + _timeTankDriverAdd;
		["write", [_intervalSection, "timeTankDriver", _timeTankDriver]] call _inidbi;				
		_timeTankGunnerOld = ["read", [_intervalSection, "timeTankGunner", 0]] call _inidbi;
		_timeTankGunner = _timeTankGunnerOld + _timeTankGunnerAdd;
		["write", [_intervalSection, "timeTankGunner", _timeTankGunner]] call _inidbi;		
		_timeTankCommanderOld = ["read", [_intervalSection, "timeTankCommander", 0]] call _inidbi;
		_timeTankCommander = _timeTankCommanderOld + _timeTankCommanderAdd;
		["write", [_intervalSection, "timeTankCommander", _timeTankCommander]] call _inidbi;		
		_timeTankPassengerOld = ["read", [_intervalSection, "timeTankPassenger", 0]] call _inidbi;
		_timeTankPassenger = _timeTankPassengerOld + _timeTankPassengerAdd;
		["write", [_intervalSection, "timeTankPassenger", _timeTankPassenger]] call _inidbi;		

		_timeTruckDriverOld = ["read", [_intervalSection, "timeTruckDriver", 0]] call _inidbi;
		_timeTruckDriver = _timeTruckDriverOld + _timeTruckDriverAdd;
		["write", [_intervalSection, "timeTruckDriver", _timeTruckDriver]] call _inidbi;				
		_timeTruckGunnerOld = ["read", [_intervalSection, "timeTruckGunner", 0]] call _inidbi;
		_timeTruckGunner = _timeTruckGunnerOld + _timeTruckGunnerAdd;
		["write", [_intervalSection, "timeTruckGunner", _timeTruckGunner]] call _inidbi;		
		_timeTruckCommanderOld = ["read", [_intervalSection, "timeTruckCommander", 0]] call _inidbi;
		_timeTruckCommander = _timeTruckCommanderOld + _timeTruckCommanderAdd;
		["write", [_intervalSection, "timeTruckCommander", _timeTruckCommander]] call _inidbi;		
		_timeTruckPassengerOld = ["read", [_intervalSection, "timeTruckPassenger", 0]] call _inidbi;
		_timeTruckPassenger = _timeTruckPassengerOld + _timeTruckPassengerAdd;
		["write", [_intervalSection, "timeTruckPassenger", _timeTruckPassenger]] call _inidbi;		

		_timeMotorcycleDriverOld = ["read", [_intervalSection, "timeMotorcycleDriver", 0]] call _inidbi;
		_timeMotorcycleDriver = _timeMotorcycleDriverOld + _timeMotorcycleDriverAdd;
		["write", [_intervalSection, "timeMotorcycleDriver", _timeMotorcycleDriver]] call _inidbi;				
		_timeMotorcycleGunnerOld = ["read", [_intervalSection, "timeMotorcycleGunner", 0]] call _inidbi;
		_timeMotorcycleGunner = _timeMotorcycleGunnerOld + _timeMotorcycleGunnerAdd;
		["write", [_intervalSection, "timeMotorcycleGunner", _timeMotorcycleGunner]] call _inidbi;		
		_timeMotorcycleCommanderOld = ["read", [_intervalSection, "timeMotorcycleCommander", 0]] call _inidbi;
		_timeMotorcycleCommander = _timeMotorcycleCommanderOld + _timeMotorcycleCommanderAdd;
		["write", [_intervalSection, "timeMotorcycleCommander", _timeMotorcycleCommander]] call _inidbi;		
		_timeMotorcyclePassengerOld = ["read", [_intervalSection, "timeMotorcyclePassenger", 0]] call _inidbi;
		_timeMotorcyclePassenger = _timeMotorcyclePassengerOld + _timeMotorcyclePassengerAdd;
		["write", [_intervalSection, "timeMotorcyclePassenger", _timeMotorcyclePassenger]] call _inidbi;		

		_timeHelicopterDriverOld = ["read", [_intervalSection, "timeHelicopterDriver", 0]] call _inidbi;
		_timeHelicopterDriver = _timeHelicopterDriverOld + _timeHelicopterDriverAdd;
		["write", [_intervalSection, "timeHelicopterDriver", _timeHelicopterDriver]] call _inidbi;				
		_timeHelicopterGunnerOld = ["read", [_intervalSection, "timeHelicopterGunner", 0]] call _inidbi;
		_timeHelicopterGunner = _timeHelicopterGunnerOld + _timeHelicopterGunnerAdd;
		["write", [_intervalSection, "timeHelicopterGunner", _timeHelicopterGunner]] call _inidbi;		
		_timeHelicopterCommanderOld = ["read", [_intervalSection, "timeHelicopterCommander", 0]] call _inidbi;
		_timeHelicopterCommander = _timeHelicopterCommanderOld + _timeHelicopterCommanderAdd;
		["write", [_intervalSection, "timeHelicopterCommander", _timeHelicopterCommander]] call _inidbi;		
		_timeHelicopterPassengerOld = ["read", [_intervalSection, "timeHelicopterPassenger", 0]] call _inidbi;
		_timeHelicopterPassenger = _timeHelicopterPassengerOld + _timeHelicopterPassengerAdd;
		["write", [_intervalSection, "timeHelicopterPassenger", _timeHelicopterPassenger]] call _inidbi;		

		_timePlaneDriverOld = ["read", [_intervalSection, "timePlaneDriver", 0]] call _inidbi;
		_timePlaneDriver = _timePlaneDriverOld + _timePlaneDriverAdd;
		["write", [_intervalSection, "timePlaneDriver", _timePlaneDriver]] call _inidbi;				
		_timePlaneGunnerOld = ["read", [_intervalSection, "timePlaneGunner", 0]] call _inidbi;
		_timePlaneGunner = _timePlaneGunnerOld + _timePlaneGunnerAdd;
		["write", [_intervalSection, "timePlaneGunner", _timePlaneGunner]] call _inidbi;		
		_timePlaneCommanderOld = ["read", [_intervalSection, "timePlaneCommander", 0]] call _inidbi;
		_timePlaneCommander = _timePlaneCommanderOld + _timePlaneCommanderAdd;
		["write", [_intervalSection, "timePlaneCommander", _timePlaneCommander]] call _inidbi;		
		_timePlanePassengerOld = ["read", [_intervalSection, "timePlanePassenger", 0]] call _inidbi;
		_timePlanePassenger = _timePlanePassengerOld + _timePlanePassengerAdd;
		["write", [_intervalSection, "timePlanePassenger", _timePlanePassenger]] call _inidbi;		

		_timeShipDriverOld = ["read", [_intervalSection, "timeShipDriver", 0]] call _inidbi;
		_timeShipDriver = _timeShipDriverOld + _timeShipDriverAdd;
		["write", [_intervalSection, "timeShipDriver", _timeShipDriver]] call _inidbi;				
		_timeShipGunnerOld = ["read", [_intervalSection, "timeShipGunner", 0]] call _inidbi;
		_timeShipGunner = _timeShipGunnerOld + _timeShipGunnerAdd;
		["write", [_intervalSection, "timeShipGunner", _timeShipGunner]] call _inidbi;		
		_timeShipCommanderOld = ["read", [_intervalSection, "timeShipCommander", 0]] call _inidbi;
		_timeShipCommander = _timeShipCommanderOld + _timeShipCommanderAdd;
		["write", [_intervalSection, "timeShipCommander", _timeShipCommander]] call _inidbi;		
		_timeShipPassengerOld = ["read", [_intervalSection, "timeShipPassenger", 0]] call _inidbi;
		_timeShipPassenger = _timeShipPassengerOld + _timeShipPassengerAdd;
		["write", [_intervalSection, "timeShipPassenger", _timeShipPassenger]] call _inidbi;		

		_timeBoatDriverOld = ["read", [_intervalSection, "timeBoatDriver", 0]] call _inidbi;
		_timeBoatDriver = _timeBoatDriverOld + _timeBoatDriverAdd;
		["write", [_intervalSection, "timeBoatDriver", _timeBoatDriver]] call _inidbi;				
		_timeBoatGunnerOld = ["read", [_intervalSection, "timeBoatGunner", 0]] call _inidbi;
		_timeBoatGunner = _timeBoatGunnerOld + _timeBoatGunnerAdd;
		["write", [_intervalSection, "timeBoatGunner", _timeBoatGunner]] call _inidbi;		
		_timeBoatCommanderOld = ["read", [_intervalSection, "timeBoatCommander", 0]] call _inidbi;
		_timeBoatCommander = _timeBoatCommanderOld + _timeBoatCommanderAdd;
		["write", [_intervalSection, "timeBoatCommander", _timeBoatCommander]] call _inidbi;		
		_timeBoatPassengerOld = ["read", [_intervalSection, "timeBoatPassenger", 0]] call _inidbi;
		_timeBoatPassenger = _timeBoatPassengerOld + _timeBoatPassengerAdd;
		["write", [_intervalSection, "timeBoatPassenger", _timeBoatPassenger]] call _inidbi;		

		_timeMapVisibleOld = ["read", [_intervalSection, "timeMapVisible", 0]] call _inidbi;
		_timeMapVisible = _timeMapVisibleOld + _timeMapVisibleAdd;
		["write", [_intervalSection, "timeMapVisible", _timeMapVisible]] call _inidbi;
		_timeGpsVisibleOld = ["read", [_intervalSection, "timeGpsVisible", 0]] call _inidbi;
		_timeGpsVisible = _timeGpsVisibleOld + _timeGpsVisibleAdd;
		["write", [_intervalSection, "timeGpsVisible", _timeGpsVisible]] call _inidbi;
		_timeWeaponLoweredOld = ["read", [_intervalSection, "timeWeaponLowered", 0]] call _inidbi;
		_timeWeaponLowered = _timeWeaponLoweredOld + _timeWeaponLoweredAdd;
		["write", [_intervalSection, "timeWeaponLowered", _timeWeaponLowered]] call _inidbi;
		
		_timeAddonAceActiveOld = ["read", [_intervalSection, "timeAddonAceActive", 0]] call _inidbi;
		_timeAddonAceActive = _timeAddonAceActiveOld + _timeAddonAceActiveAdd;
		["write", [_intervalSection, "timeAddonAceActive", _timeAddonAceActive]] call _inidbi;
		_timeAddonTfarActiveOld = ["read", [_intervalSection, "timeAddonTfarActive", 0]] call _inidbi;
		_timeAddonTfarActive = _timeAddonTfarActiveOld + _timeAddonTfarActiveAdd;
		["write", [_intervalSection, "timeAddonTfarActive", _timeAddonTfarActive]] call _inidbi;

		_dbName = "pps-players";
		_inidbi = ["new", _dbName] call OO_INIDBI;
		
		_isTrackValueActive = ["read", [_playerUid, "isTrackValueActive", 0]] call _inidbi;
		_trackValueVariable = ["read", [_playerUid, "trackValueVariable", ""]] call _inidbi;
		_trackValueClientId = ["read", [_playerUid, "trackValueClientId", ""]] call _inidbi;
		
		if (_isTrackValueActive == 1) then
		{
			_dbName = "pps-player-" + _playerUid;
			_inidbi = ["new", _dbName] call OO_INIDBI;
			_intervalSection = "Interval Statistics";
			
			_trackValueValue = ["read", [_intervalSection, _trackValueVariable, "not set"]] call _inidbi;
			if ((str _trackValueValue) != (str "not set")) then
			{
				_trackValueString = format ["Variable: %1\nValue: %2", _trackValueVariable, _trackValueValue];
				_trackValueString remoteExec ["hint", _trackValueClientId];			
			};
		};
	
		diag_log format ["[%1] PPS Player Updated Interval Data: %2 (%3)", serverTime, _playerName, _playerUid];
	};
};

/* ================================================================================ */