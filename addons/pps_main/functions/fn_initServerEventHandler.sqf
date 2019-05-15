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
		
		_globalInformationsSection = "Global Informations";
		_intervalStatisticsSection = "Interval Statistics";
		_eventHandlerSection = "Event Handler Statistics";
		_eventsInformationsSection = "Events Informations";

		_statisticsSectionsAndKeys =
		[
			[_globalInformationsSection, "playerName"], 
			[_globalInformationsSection, "playerUid"], 
			[_intervalStatisticsSection, "countUpdates"], 
			[_intervalStatisticsSection, "timeInEvent"], 
			[_eventHandlerSection, "countProjectilesFired"], 
			[_eventHandlerSection, "countGrenadesThrown"], 
			[_eventHandlerSection, "countSmokeShellsThrown"], 
			[_eventHandlerSection, "countChemlightsThrown"], 
			[_eventHandlerSection, "countUnknownThrown"], 
			[_eventHandlerSection, "countProjectilesHitEnemy"], 
			[_eventHandlerSection, "countProjectilesHitFriendly"], 
			[_eventHandlerSection, "countGrenadesHitEnemy"], 
			[_eventHandlerSection, "countGrenadesHitFriendly"], 
			[_eventHandlerSection, "countPlayerDeaths"], 
			[_eventHandlerSection, "countPlayerKills"], 
			[_eventHandlerSection, "countPlayerSuicides"], 
			[_eventHandlerSection, "countPlayerTeamKills"], 
			[_eventHandlerSection, "countCuratorInterfaceOpened"], 
			[_eventHandlerSection, "countGearInterfaceOpened"], 
			[_eventHandlerSection, "countCompassInterfaceOpened"], 
			[_eventHandlerSection, "countWatchInterfaceOpened"], 
			[_intervalStatisticsSection, "timeOnFoot"], 
			[_intervalStatisticsSection, "timeStandNoSpeed"], 
			[_intervalStatisticsSection, "timeCrouchNoSpeed"], 
			[_intervalStatisticsSection, "timeProneNoSpeed"], 
			[_intervalStatisticsSection, "timeStandLowSpeed"], 
			[_intervalStatisticsSection, "timeCrouchLowSpeed"], 
			[_intervalStatisticsSection, "timeProneLowSpeed"], 
			[_intervalStatisticsSection, "timeStandMidSpeed"], 
			[_intervalStatisticsSection, "timeCrouchMidSpeed"], 
			[_intervalStatisticsSection, "timeProneMidSpeed"], 
			[_intervalStatisticsSection, "timeStandHighSpeed"], 
			[_intervalStatisticsSection, "timeCrouchHighSpeed"], 
			[_intervalStatisticsSection, "timeProneHighSpeed"], 
			[_intervalStatisticsSection, "timeInVehicle"], 
			[_intervalStatisticsSection, "timeCarDriver"], 
			[_intervalStatisticsSection, "timeCarGunner"], 
			[_intervalStatisticsSection, "timeCarCommander"],
			[_intervalStatisticsSection, "timeCarPassenger"], 
			[_intervalStatisticsSection, "timeTankDriver"], 
			[_intervalStatisticsSection, "timeTankGunner"], 
			[_intervalStatisticsSection, "timeTankCommander"], 
			[_intervalStatisticsSection, "timeTankPassenger"], 
			[_intervalStatisticsSection, "timeTruckDriver"], 
			[_intervalStatisticsSection, "timeTruckGunner"], 
			[_intervalStatisticsSection, "timeTruckCommander"], 
			[_intervalStatisticsSection, "timeTruckPassenger"], 
			[_intervalStatisticsSection, "timeMotorcycleDriver"], 
			[_intervalStatisticsSection, "timeMotorcycleGunner"], 
			[_intervalStatisticsSection, "timeMotorcycleCommander"], 
			[_intervalStatisticsSection, "timeMotorcyclePassenger"], 
			[_intervalStatisticsSection, "timeHelicopterDriver"], 
			[_intervalStatisticsSection, "timeHelicopterGunner"], 
			[_intervalStatisticsSection, "timeHelicopterCommander"], 
			[_intervalStatisticsSection, "timeHelicopterPassenger"], 
			[_intervalStatisticsSection, "timePlaneDriver"], 
			[_intervalStatisticsSection, "timePlaneGunner"], 
			[_intervalStatisticsSection, "timePlaneCommander"], 
			[_intervalStatisticsSection, "timePlanePassenger"], 
			[_intervalStatisticsSection, "timeShipDriver"], 
			[_intervalStatisticsSection, "timeShipGunner"], 
			[_intervalStatisticsSection, "timeShipCommander"], 
			[_intervalStatisticsSection, "timeShipPassenger"], 
			[_intervalStatisticsSection, "timeBoatDriver"], 
			[_intervalStatisticsSection, "timeBoatGunner"], 
			[_intervalStatisticsSection, "timeBoatCommander"], 
			[_intervalStatisticsSection, "timeBoatPassenger"], 
			[_intervalStatisticsSection, "timeMapVisible"], 
			[_intervalStatisticsSection, "timeGpsVisible"], 
			[_intervalStatisticsSection, "timeWeaponLowered"], 
			[_intervalStatisticsSection, "timeAddonAceActive"], 
			[_intervalStatisticsSection, "timeAddonTfarActive"]
		];
		
		_timeInEvent = ["read", [_intervalStatisticsSection, "timeInEvent", 0]] call _inidbi;
		_countProjectilesFired = ["read", [_eventHandlerSection, "countProjectilesFired", 0]] call _inidbi;
		_countGrenadesThrown = ["read", [_eventHandlerSection, "countGrenadesThrown", 0]] call _inidbi;
		
		_tmpResult = [];
		{
			_section = _x select 0;
			_key = _x select 1;
			_value = ["read", [_section, _key, ""]] call _inidbi;
			_formatType = ["read", [_section, _key + "FormatType", -1]] call _inidbi;
			_formatString = ["read", [_section, _key + "FormatString", ""]] call _inidbi;
			
				switch (_formatType) do
				{
					case 0:
					{
						_tmpResult = _tmpResult + [[format [_formatString, _value], _key]];
					};
					case 1:
					{
						_roundValue = parseNumber ((_value / 3600) toFixed 2);
						_roundValuePercent = parseNumber ((100 / _timeInEvent * _value) toFixed 2);
						_tmpResult = _tmpResult + [[format [_formatString, "%", str _roundValue, str _roundValuePercent], _key]];
					};
					case 2:
					{
						_roundValuePercent = parseNumber ((100 / _countProjectilesFired * _value) toFixed 2);
						_tmpResult = _tmpResult + [[format [_formatString, "%", _value, _roundValuePercent], _key]];

					};
					case 3:
					{
						_roundValue = parseNumber ((_value / 3600) toFixed 2);
						_tmpResult = _tmpResult + [[format [_formatString, str _roundValue], _key]];
					};
					case 4:
					{
						_roundValuePercent = parseNumber ((100 / _countGrenadesThrown * _value) toFixed 2);
						_tmpResult = _tmpResult + [[format [_formatString, "%", _value, _roundValuePercent], _key]];

					};
					case -1:
					{
						_tmpResult = _tmpResult + [[format ["Key: %1 not recorded yet", _key], _key]];

					};
				};
				
		} forEach _statisticsSectionsAndKeys;
		
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

(_playerUid + "-updateStatistics") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];

	_dbName = "pps-server-settings";
	_inidbi = ["new", _dbName] call OO_INIDBI;		
	_settingsSection = "Settings";			
	_isEvent = ["read", [_settingsSection, "isEvent", ""]] call _inidbi;
	
	if (_isEvent == 1) then
	{
		_playerUid = _broadcastVariableValue select 0;
		_intervalStatistics = _broadcastVariableValue select 1;
		
		_dbName = "pps-player-" + _playerUid;
		_inidbi = ["new", _dbName] call OO_INIDBI;
		
		_globalInformationsSection = "Global Informations";
		_intervalStatisticsSection = "Interval Statistics";
				
		{
			_section = _x select 0;
			_key = _x select 1;
			_value = _x select 2;
			_formatType = _x select 3;
			_formatString = _x select 4;
			
			
			if (_section == _globalInformationsSection) then
			{
				["write", [_section, _key, _value]] call _inidbi;
			};
			if (_section == _intervalStatisticsSection) then
			{
				_valueOld = ["read", [_section, _key, 0]] call _inidbi;
				_value = _valueOld + _value;
				["write", [_section, _key, _value]] call _inidbi;
			};			
			["write", [_section, _key + "FormatType", _formatType]] call _inidbi;
			["write", [_section, _key + "FormatString", _formatString]] call _inidbi;
		} forEach _intervalStatistics;
		
		_countUpdates = ["read", [_intervalStatisticsSection, "countUpdates", 0]] call _inidbi;
		_countUpdates = _countUpdates + 1;
		["write", [_intervalStatisticsSection, "countUpdates", _countUpdates]] call _inidbi;
		["write", [_intervalStatisticsSection, "countUpdatesFormatType", 0]] call _inidbi;
		["write", [_intervalStatisticsSection, "countUpdatesFormatString", "Count Updates: %1"]] call _inidbi;
		
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
			
			_trackValueValue = ["read", [_intervalStatisticsSection, _trackValueVariable, "not set"]] call _inidbi;
			if ((str _trackValueValue) != (str "not set")) then
			{
				_trackValueString = format ["Variable: %1\nValue: %2", _trackValueVariable, _trackValueValue];
				_trackValueString remoteExec ["hint", _trackValueClientId];			
			};
		};
	
		diag_log format ["[%1] PPS Player Updated Interval Data: (%2)", serverTime, _playerUid];
	};
};

/* ================================================================================ */