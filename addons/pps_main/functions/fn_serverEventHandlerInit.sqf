/*
 * Author: y0014984
 *
 * Adds communication event handlers serverside for every player. Main serverside logic.
 *
 * Arguments:
 * 0: _playerUid <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_playerUid] call PPS_fnc_serverEventHandlerInit;
 *
 * Public: No
 */

params ["_playerUid"];

/* ================================================================================ */

(_playerUid + "-requestSwitchAdmin") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];

	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;

	_dbName = "pps-players";
	_dbPlayers = ["new", _dbName] call OO_INIDBI;
	
	_isAdmin = ["read", [_playerUid, "isAdmin", false]] call _dbPlayers;
	_isAdminLoggedIn = ["read", [_playerUid, "isAdminLoggedIn", false]] call _dbPlayers;
	
	if (_isAdmin) then
	{
		_players = "getSections" call _dbPlayers;
		
		_isAnotherAdminLoggedIn = false;
		{
			scopeName "LoopAnotherAdminLoggedIn";
			_tempIsAdminLoggedIn = ["read", [_x, "isAdminLoggedIn", false]] call _dbPlayers;
			_tempPlayerUid = ["read", [_x, "playerUid", 0]] call _dbPlayers;
			if ((_tempIsAdminLoggedIn) && (_tempPlayerUid != _playerUid)) then
			{
				_isAnotherAdminLoggedIn = true;
				breakOut "LoopAnotherAdminLoggedIn";
			};
		} forEach _players;

		if (!_isAnotherAdminLoggedIn) then
		{
			if (_isAdminLoggedIn) then
			{
				["write", [_playerUid, "isAdminLoggedIn", false]] call _dbPlayers;
			}
			else
			{
				["write", [_playerUid, "isAdminLoggedIn", true]] call _dbPlayers;
			};
		}
		else
		{
			["STR_PPS_Main_Notifications_Login_Denied_Too_Many_Admins"] remoteExecCall ["PPS_fnc_hintLocalized", _clientId];
		};
	}
	else
	{
		["STR_PPS_Main_Notifications_Login_Denied_Missing_Permission"] remoteExecCall ["PPS_fnc_hintLocalized", _clientId];
	};
	
	_isAdminLoggedIn = ["read", [_playerUid, "isAdminLoggedIn", false]] call _dbPlayers;
	
	_result = [_isAdmin, _isAdminLoggedIn];
	
	_answer = _playerUid + "-answerSwitchAdmin";
	missionNamespace setVariable [_answer, _result, false];
	_clientId publicVariableClient _answer;
	
	[format ["[%1] PPS Player Request Switch Admin Status: set %2 (%3)", serverTime, _isAdminLoggedIn, _playerUid]] call PPS_fnc_log;
};

/* ================================================================================ */

(_playerUid + "-requestSwitchTrackStatistics") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];

	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;
	_key = _broadcastVariableValue select 2;
	
	_dbName = "pps-players";
	_dbPlayers = ["new", _dbName] call OO_INIDBI;
	
	_isTrackStatisticsActive = ["read", [_playerUid, "isTrackStatisticsActive", false]] call _dbPlayers;
	_trackStatisticsKey = ["read", [_playerUid, "trackStatisticsKey", ""]] call _dbPlayers;

	if (_isTrackStatisticsActive) then
	{
		if (_key != _trackStatisticsKey) then
		{
			["write", [_playerUid, "trackStatisticsKey", _key]] call _dbPlayers;
			
			_value = ["read", [_key, "value", "not set"]] call _dbStatistics;
			if ((str _value) != (str "not set")) then
			{
				["STR_PPS_Main_Notifications_Tracking", _key, _value] remoteExecCall ["PPS_fnc_hintLocalized", _clientId];
			};
		}
		else
		{
			["write", [_playerUid, "isTrackStatisticsActive", false]] call _dbPlayers;
			["write", [_playerUid, "trackStatisticsKey", ""]] call _dbPlayers;
			["write", [_playerUid, "trackStatisticsClientId", ""]] call _dbPlayers;
		};
	}
	else
	{
		["write", [_playerUid, "isTrackStatisticsActive", true]] call _dbPlayers;
		["write", [_playerUid, "trackStatisticsKey", _key]] call _dbPlayers;
		["write", [_playerUid, "trackStatisticsClientId", _clientId]] call _dbPlayers;

		_value = ["read", [_key, "value", "not set"]] call _dbStatistics;
		if ((str _value) != (str "not set")) then
		{
			["STR_PPS_Main_Notifications_Tracking", _key, _value] remoteExecCall ["PPS_fnc_hintLocalized", _clientId];
		};
	};

	_isTrackStatisticsActive = ["read", [_playerUid, "isTrackStatisticsActive", false]] call _dbPlayers;
	_trackStatisticsKey = ["read", [_playerUid, "trackStatisticsKey", ""]] call _dbPlayers;
	_trackStatisticsClientId = ["read", [_playerUid, "trackStatisticsClientId", ""]] call _dbPlayers;

	_result = [_isTrackStatisticsActive, _trackStatisticsKey, _trackStatisticsClientId];
	
	_answer = _playerUid + "-answerSwitchTrackStatistics";
	missionNamespace setVariable [_answer, _result, false];
	_clientId publicVariableClient _answer;
	
	[format ["[%1] PPS Player Request Switch Track Statistics: Active: %2 Value: %3 (%4)", serverTime, _isTrackStatisticsActive, _trackStatisticsKey, _playerUid]] call PPS_fnc_log;
};

/* ================================================================================ */

(_playerUid + "-requestStopEvent") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];

	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;

	_dbName = "pps-players";
	_dbPlayers = ["new", _dbName] call OO_INIDBI;
	_players = "getSections" call _dbPlayers;
	
	_isAdmin = ["read", [_playerUid, "isAdmin", false]] call _dbPlayers;
	_isAdminLoggedIn = ["read", [_playerUid, "isAdminLoggedIn", false]] call _dbPlayers;
	
	if (_isAdmin && _isAdminLoggedIn) then
	{		
		_dbName = "pps-events";
		_dbEvents = ["new", _dbName] call OO_INIDBI;
		
		if (PPS_isEvent) then
		{
			_eventStopTime = "getTimeStamp" call _dbEvents;

			PPS_eventStopTime = +_eventStopTime;
			publicVariable "PPS_eventStopTime";
			PPS_isEvent = false;
			publicVariable "PPS_isEvent";
			
			["write", [PPS_eventId, "eventStopTime", PPS_eventStopTime]] call _dbEvents;
			
			if ((PPS_eventStopTime select 0) == (PPS_eventStartTime select 0)) then
			{
				_tmpEventStartTime = +PPS_eventStartTime;
				_tmpEventStartTime set [5, "delete"];
				_tmpEventStartTime = _tmpEventStartTime - ["delete"];
				_tmpEventStopTime = +PPS_eventStopTime;
				_tmpEventStopTime set [5, "delete"];
				_tmpEventStopTime = _tmpEventStopTime - ["delete"];
				_eventDuration = (dateToNumber _tmpEventStopTime) - (dateToNumber _tmpEventStartTime);
				_eventDuration = numberToDate [_tmpEventStopTime select 0, _eventDuration];
				if (((_eventDuration select 1) == 1) && ((_eventDuration select 2) == 1)) then
				{
					_eventDurationOld = ["read", [PPS_eventId, "eventDuration", 0]] call _dbEvents;
					_eventDuration = _eventDurationOld + (((_eventDuration select 3) * 60) + (_eventDuration select 4));
					["write", [PPS_eventId, "eventDuration", _eventDuration]] call _dbEvents;
				};
			};
			
			["STR_PPS_Main_Notifications_Event_Stopped", PPS_eventName] remoteExecCall ["PPS_fnc_hintLocalized"];
		};
			
		_result = true;
		
		_answer = _playerUid + "-answerStopEvent";
		missionNamespace setVariable [_answer, _result, false];
		_clientId publicVariableClient _answer;
		
		[format ["[%1] PPS Player Request Stop Event: set %2 (%3)", serverTime, _isEvent, _playerUid]] call PPS_fnc_log;
	};
};

/* ================================================================================ */

(_playerUid + "-requestStartEvent") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];

	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;
	_eventName = _broadcastVariableValue select 2;

	_dbName = "pps-players";
	_dbPlayers = ["new", _dbName] call OO_INIDBI;
	_players = "getSections" call _dbPlayers;
	
	_isAdmin = ["read", [_playerUid, "isAdmin", false]] call _dbPlayers;
	_isAdminLoggedIn = ["read", [_playerUid, "isAdminLoggedIn", false]] call _dbPlayers;
	
	if (_isAdmin && _isAdminLoggedIn) then
	{		
		_dbName = "pps-events";
		_dbEvents = ["new", _dbName] call OO_INIDBI;
		
		if (!PPS_isEvent) then
		{
			_eventStartTime = "getTimeStamp" call _dbEvents;
			_eventStopTime = [0, 0, 0, 0, 0, 0];
			
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
			} forEach _eventStartTime;	
						
			_allActivePlayers = allPlayers - entities "HeadlessClient_F";
			_allActivePlayersIds = [];
			{
				_xPlayerUid = getPlayerUID _x;
				_allActivePlayersIds = _allActivePlayersIds + [_xPlayerUid];			
			} forEach _allActivePlayers;
			
			_allActiveDbPlayersIds = [];
			{
				if ((_players find _x) > -1) then {_allActiveDbPlayersIds = _allActiveDbPlayersIds + [_x];};
			} forEach _allActivePlayersIds;
					
			["write", [_eventId, "eventId", _eventId]] call _dbEvents;
			["write", [_eventId, "eventName", _eventName]] call _dbEvents;
			["write", [_eventId, "eventPlayerUids", _allActiveDbPlayersIds]] call _dbEvents;
			["write", [_eventId, "eventStartTime", _eventStartTime]] call _dbEvents;
			["write", [_eventId, "eventStopTime", _eventStopTime]] call _dbEvents;
			
			PPS_isEvent = true;
			publicVariable "PPS_isEvent";
			PPS_eventName = _eventName;
			publicVariable "PPS_eventName";
			PPS_eventId = _eventId;
			publicVariable "PPS_eventId";
			PPS_eventStartTime = +_eventStartTime;
			publicVariable "PPS_eventStartTime";
			PPS_eventStopTime = +_eventStopTime;
			publicVariable "PPS_eventStopTime";
			
			["STR_PPS_Main_Notifications_Event_Started", _eventName] remoteExecCall ["PPS_fnc_hintLocalized"];
		};
			
		_result = true;
		
		_answer = _playerUid + "-answerStartEvent";
		missionNamespace setVariable [_answer, _result, false];
		_clientId publicVariableClient _answer;
		
		[format ["[%1] PPS Player Request Start Event: set %2 (%3)", serverTime, _isEvent, _playerUid]] call PPS_fnc_log;
	};
};

/* ================================================================================ */

(_playerUid + "-requestDeleteEvent") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];

	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;
	_eventId = _broadcastVariableValue select 2;

	_dbName = "pps-players";
	_dbPlayers = ["new", _dbName] call OO_INIDBI;
	
	_isAdmin = ["read", [_playerUid, "isAdmin", false]] call _dbPlayers;
	_isAdminLoggedIn = ["read", [_playerUid, "isAdminLoggedIn", false]] call _dbPlayers;
		
	_dbName = "pps-events";
	_dbEvents = ["new", _dbName] call OO_INIDBI;
	
	if ("exists" call _dbEvents) then
	{
		_eventName = ["read", [_eventId, "eventName", ""]] call _dbEvents;
		_eventPlayerUids = ["read", [_eventId, "eventPlayerUids", ""]] call _dbEvents;
		
		if (_isAdmin && _isAdminLoggedIn) then
		{
			{
				_dbName = "pps-statistics-" + _x + "-" + _eventId;
				_dbStatistics = ["new", _dbName] call OO_INIDBI;
				
				if ("exists" call _dbStatistics) then {"delete" call _dbStatistics;};
			} forEach _eventPlayerUids;
			
			["deleteSection", _eventId] call _dbEvents;
		} 
		else 
		{
			/*this code can't be reached because the delete button is invisible for non admin players*/
			_dbName = "pps-statistics-" + _playerUid + "-" + _eventId;
			_dbStatistics = ["new", _dbName] call OO_INIDBI;
			
			if ("exists" call _dbStatistics) then {"delete" call _dbStatistics;};
			
			_eventPlayerUidsWithoutPlayer = [];
			{
				if (_x != _playerUid) then {_eventPlayerUidsWithoutPlayer = _eventPlayerUidsWithoutPlayer + [_x]};
			} forEach _eventPlayerUids;
			["write", [_eventId, "eventPlayerUids", _eventPlayerUidsWithoutPlayer]] call _dbEvents;
		};
		
		["STR_PPS_Main_Notifications_Event_Deleted", _eventName] remoteExecCall ["PPS_fnc_hintLocalized"];
	};
		
	_result = true;
	
	_answer = _playerUid + "-answerDeleteEvent";
	missionNamespace setVariable [_answer, _result, false];
	_clientId publicVariableClient _answer;
	
	[format ["[%1] PPS Player Request Delete Event: %2 (%3)", serverTime, _eventName, _playerUid]] call PPS_fnc_log;
};

/* ================================================================================ */

(_playerUid + "-requestContinueEvent") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];

	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;
	_eventId = _broadcastVariableValue select 2;

	_dbName = "pps-players";
	_dbPlayers = ["new", _dbName] call OO_INIDBI;
	
	_isAdmin = ["read", [_playerUid, "isAdmin", false]] call _dbPlayers;
	_isAdminLoggedIn = ["read", [_playerUid, "isAdminLoggedIn", false]] call _dbPlayers;
	
	if (_isAdmin && _isAdminLoggedIn && !PPS_isEvent) then
	{		
		_dbName = "pps-events";
		_dbEvents = ["new", _dbName] call OO_INIDBI;
		
		if ("exists" call _dbEvents) then
		{
			_eventName = ["read", [_eventId, "eventName", ""]] call _dbEvents;
			
			_eventStartTime = "getTimeStamp" call _dbEvents;
			_eventStopTime = [0, 0, 0, 0, 0, 0];
			["write", [_eventId, "eventStartTime", _eventStartTime]] call _dbEvents;
			["write", [_eventId, "eventStopTime", _eventStopTime]] call _dbEvents;
			
			PPS_isEvent = true;
			publicVariable "PPS_isEvent";
			PPS_eventName = _eventName;
			publicVariable "PPS_eventName";
			PPS_eventId = _eventId;
			publicVariable "PPS_eventId";
			PPS_eventStartTime = +_eventStartTime;
			publicVariable "PPS_eventStartTime";
			PPS_eventStopTime = +_eventStopTime;
			publicVariable "PPS_eventStopTime";
			
			["STR_PPS_Main_Notifications_Event_Continued", _eventName] remoteExecCall ["PPS_fnc_hintLocalized"];
		};
			
		_result = true;
		
		_answer = _playerUid + "-answerContinueEvent";
		missionNamespace setVariable [_answer, _result, false];
		_clientId publicVariableClient _answer;
		
		[format ["[%1] PPS Player Request Continue Event: %2 (%3)", serverTime, _eventName, _playerUid]] call PPS_fnc_log;
	};
};

/* ================================================================================ */

(_playerUid + "-requestExportStatistics") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;

	_tab = "	";
	_crlf = "
";
	_result = "Player" + _tab + "Event" + _tab + "Statistics Key" + _tab + "Statistics Value" + _crlf;;
	
	_dbName = "pps-players";
	_dbPlayers = ["new", _dbName] call OO_INIDBI;

	_isAdmin = ["read", [_playerUid, "isAdmin", false]] call _dbPlayers;
	_isAdminLoggedIn = ["read", [_playerUid, "isAdminLoggedIn", false]] call _dbPlayers;
	
	_players = [_playerUid];
	if (_isAdmin && _isAdminLoggedIn) then {_players = "getSections" call _dbPlayers;};
	{
		_currentPlayer = _x;
		
		_playerName = ["read", [_currentPlayer, "playerName", 0]] call _dbPlayers;
		
		_dbName = "pps-events";
		_dbEvents = ["new", _dbName] call OO_INIDBI;
		
		if ("exists" call _dbEvents) then
		{
			_events = "getSections" call _dbEvents;
			{
				_currentEvent = _x;
				
				_eventPlayerUids = ["read", [_x, "eventPlayerUids", 0]] call _dbEvents;
				
				_eventId = ["read", [_currentEvent, "eventId", 0]] call _dbEvents;
				_eventName = ["read", [_currentEvent, "eventName", ""]] call _dbEvents;
				_eventDuration = ["read", [_currentEvent, "eventDuration", 0]] call _dbEvents;
				_eventStartTime = ["read", [_currentEvent, "eventStartTime", [0, 0, 0, 0, 0, 0]]] call _dbEvents;
				
				if ((_eventPlayerUids find _currentPlayer) > -1) then
				{
					_dbName = "pps-statistics-" + _currentPlayer + "-" + _eventId;
					_dbStatistics = ["new", _dbName] call OO_INIDBI;
					
					if ("exists" call _dbStatistics) then
					{
						_statistics = "getSections" call _dbStatistics;
						{
							_currentStatistics = _x;
							
							_key = ["read", [_currentStatistics, "key", ""]] call _dbStatistics;
							_value = ["read", [_currentStatistics, "value", ""]] call _dbStatistics;
							
							_result = _result + _playerName + _tab + _eventName + _tab + _key + _tab + (str _value) + _crlf;
								
						} forEach _statistics;
					};
				};
			} forEach _events;
		};
	} forEach _players;

	/* ---------------------------------------- */

	_answer = _playerUid + "-answerExportStatistics";
	missionNamespace setVariable [_answer, _result, false];
	_clientId publicVariableClient _answer;
			
	[format ["[%1] PPS Player Request Export Statistics: (%2)", serverTime, _playerUid]] call PPS_fnc_log;
};

/* ================================================================================ */

(_playerUid + "-requestStatisticsFiltered") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;
	_requestedPlayerUid = _broadcastVariableValue select 2;
	_requestedEventId = _broadcastVariableValue select 3;
	_filterStatistics = _broadcastVariableValue select 4;
	
	_dbName = "pps-players";
	_dbPlayers = ["new", _dbName] call OO_INIDBI;
	
	_isAdmin = ["read", [_playerUid, "isAdmin", false]] call _dbPlayers;
	_isAdminLoggedIn = ["read", [_playerUid, "isAdminLoggedIn", false]] call _dbPlayers;
	_isTrackStatisticsActive = ["read", [_playerUid, "isTrackStatisticsActive", false]] call _dbPlayers;
	_trackStatisticsKey = ["read", [_playerUid, "trackStatisticsKey", ""]] call _dbPlayers;
		
	if ((_playerUid == _requestedPlayerUid) || _isAdmin) then
	{
		if (_playerUid != _requestedPlayerUid) then {_isTrackStatisticsActive = false; _trackStatisticsKey = "";};
		
		_dbName = "pps-statistics-" + _requestedPlayerUid + "-" + _requestedEventId;
		_dbStatistics = ["new", _dbName] call OO_INIDBI;

		_tmpResult = [];
		if ("exists" call _dbStatistics) then
		{
			_statistics = "getSections" call _dbStatistics;
			
			_timeInEvent = ["read", ["timeInEvent", "value", 0]] call _dbStatistics;
			_countProjectilesFired = ["read", ["countProjectilesFired", "value", 0]] call _dbStatistics;
			_countGrenadesThrown = ["read", ["countGrenadesThrown", "value", 0]] call _dbStatistics;
			
			{
				_value = ["read", [_x, "value", ""]] call _dbStatistics;
				_type = ["read", [_x, "type", ""]] call _dbStatistics;
				_formatType = ["read", [_x, "formatType", -1]] call _dbStatistics;
				_formatString = ["read", [_x, "formatString", ""]] call _dbStatistics;
				_source = ["read", [_x, "source", ""]] call _dbStatistics;
				
					switch (_formatType) do
					{
						case 0:
						{
							_tmpResult = _tmpResult + [[_x, _formatString, _source, _value, "", ""]];
						};
						case 1:
						{
							_roundValue = parseNumber ((_value / 3600) toFixed 2);
							_roundValuePercent = parseNumber ((100 / _timeInEvent * _value) toFixed 2);
							_tmpResult = _tmpResult + [[_x, _formatString, _source, "%", str _roundValue, str _roundValuePercent]];
						};
						case 2:
						{
							_roundValuePercent = parseNumber ((100 / _countProjectilesFired * _value) toFixed 2);
							_tmpResult = _tmpResult + [[_x, _formatString, _source, "%", _value, _roundValuePercent]];

						};
						case 3:
						{
							_roundValue = parseNumber ((_value / 3600) toFixed 2);
							_tmpResult = _tmpResult + [[_x, _formatString, _source, str _roundValue, "", ""]];
						};
						case 4:
						{
							_roundValuePercent = parseNumber ((100 / _countGrenadesThrown * _value) toFixed 2);
							_tmpResult = _tmpResult + [[_x, _formatString, _source, "%", _value, _roundValuePercent]];

						};
						case -1:
						{
							_tmpResult = _tmpResult + [[_x, localize "STR_PPS_Main_Dialog_List_Value_Not_Recorded", _source, _value, "", ""]];
						};
					};
					
			} forEach _statistics;
		};
		
		_resultStatistics = [];	
		if(_filterStatistics != "") then
		{
			{
				if (((toLower (_x select 0)) find (toLower _filterStatistics)) > -1) then
				{
					_resultStatistics = _resultStatistics + [_x];
				};
			} forEach _tmpResult;
		}
		else
		{
			_resultStatistics = _tmpResult;
		};

		/* ---------------------------------------- */

		_answer = _playerUid + "-answerStatisticsFiltered";
		missionNamespace setVariable [_answer, [_resultStatistics, _isTrackStatisticsActive, _trackStatisticsKey], false];
		_clientId publicVariableClient _answer;
				
		[format ["[%1] PPS Player Request Statistics: (%2)", serverTime, _requestedPlayerUid]] call PPS_fnc_log;
	};
};

/* ================================================================================ */

(_playerUid + "-requestEventsFiltered") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;
	_requestedPlayerUid = _broadcastVariableValue select 2;
	_filterEvents = _broadcastVariableValue select 3;

	/* ---------------------------------------- */

	_dbName = "pps-players";
	_dbPlayers = ["new", _dbName] call OO_INIDBI;
	
	_isAdmin = ["read", [_playerUid, "isAdmin", false]] call _dbPlayers;
	_isAdminLoggedIn = ["read", [_playerUid, "isAdminLoggedIn", false]] call _dbPlayers;

	/* ---------------------------------------- */

	if (_requestedPlayerUid != _playerUid && !_isAdmin) exitWith {};
	
	_dbName = "pps-events";
	_dbEvents = ["new", _dbName] call OO_INIDBI;
	
	_filteredEvents = [];
	if ("exists" call _dbEvents) then
	{
		_events = "getSections" call _dbEvents;
		{	
			_eventPlayerUids = ["read", [_x, "eventPlayerUids", 0]] call _dbEvents;
			
			_eventId = ["read", [_x, "eventId", 0]] call _dbEvents;
			_eventName = ["read", [_x, "eventName", ""]] call _dbEvents;
			_eventDuration = ["read", [_x, "eventDuration", 0]] call _dbEvents;
			_eventStartTime = ["read", [_x, "eventStartTime", [0, 0, 0, 0, 0, 0]]] call _dbEvents;
			
			if (((_eventPlayerUids find _requestedPlayerUid) > -1) && ((((toLower _eventName) find (toLower _filterEvents)) > -1) || (_filterEvents == ""))) then
			{
				_filteredEvents = _filteredEvents + [[_eventId, _eventName, _eventStartTime, _eventDuration]];
			};
		} forEach _events;
	};

	/* ---------------------------------------- */

	_result = [_playerUid, _clientId, _isAdmin, _isAdminLoggedIn, _filteredEvents];
	
	_answer = _playerUid + "-answerEventsFiltered";
	missionNamespace setVariable [_answer, _result, false];
	_clientId publicVariableClient _answer;

	[format ["[%1] PPS Player Request Events Filtered: (%2)", serverTime, _playerUid]] call PPS_fnc_log;
};

/* ================================================================================ */

(_playerUid + "-requestSetServerAdminToPpsAdmin") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;

	/* ---------------------------------------- */

	_dbName = "pps-players";
	_dbPlayers = ["new", _dbName] call OO_INIDBI;
	
	_isAdmin = ["read", [_playerUid, "isAdmin", false]] call _dbPlayers;
	
	_serverAdminStatus = admin _clientId;

	/* ---------------------------------------- */

	if (!_isAdmin && (_serverAdminStatus == 2)) then
	{
		["write", [_playerUid, "isAdmin", true]] call _dbPlayers;
	};

	/* ---------------------------------------- */

	_result = true;
	
	_answer = _playerUid + "-answerSetServerAdminToPpsAdmin";
	missionNamespace setVariable [_answer, _result, false];
	_clientId publicVariableClient _answer;

	[format ["[%1] PPS Player Request Server Admin to PPS Admin: (%2)", serverTime, _playerUid]] call PPS_fnc_log;
};

/* ================================================================================ */

(_playerUid + "-requestDialogUpdate") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;
	_filterPlayers = _broadcastVariableValue select 2;

	/* ---------------------------------------- */

	_dbName = "pps-players";
	_dbPlayers = ["new", _dbName] call OO_INIDBI;
	
	_isAdmin = ["read", [_playerUid, "isAdmin", false]] call _dbPlayers;
	_isAdminLoggedIn = ["read", [_playerUid, "isAdminLoggedIn", false]] call _dbPlayers;

	/* ---------------------------------------- */

	_countPlayersTotal = 0;
	_countPlayersOnline = 0;
	_countAdminsTotal = 0;
	_countAdminsOnline = 0;
	
	_allActivePlayers = allPlayers - entities "HeadlessClient_F";
	_countPlayersOnline = count _allActivePlayers;
	
	_allActivePlayersIds = [];
	{
		_tmpPlayerUid = getPlayerUID _x;
		_tmpIsAdmin = ["read", [_tmpPlayerUid, "isAdmin", false]] call _dbPlayers;
		if (_tmpIsAdmin) then {_countAdminsOnline = _countAdminsOnline + 1};
		_allActivePlayersIds = _allActivePlayersIds + [_tmpPlayerUid];
	} forEach _allActivePlayers;
	
	/* ---------------------------------------- */

	_players = [];
	
	_players = "getSections" call _dbPlayers;
	_countPlayersTotal = count _players;
	
	_tmpResult = [];
	_playerOnly = [];
	{
		_tmpPlayerName = ["read", [_x, "playerName", ""]] call _dbPlayers;
		_tmpPlayerUid = ["read", [_x, "playerUid", ""]] call _dbPlayers;
		_tmpIsAdmin = ["read", [_x, "isAdmin", false]] call _dbPlayers;
		if (_tmpIsAdmin) then {_countAdminsTotal = _countAdminsTotal + 1};
		_tmpIsAdminLoggedIn = ["read", [_x, "isAdminLoggedIn", false]] call _dbPlayers;
		
		_tmpPlayerIsTrackStatisticsActive = ["read", [_x, "isTrackStatisticsActive", false]] call _dbPlayers;
		_tmpPlayerTrackStatisticsKey = ["read", [_x, "trackStatisticsKey", ""]] call _dbPlayers;

		_tmpPlayerStatus = false;
		if ((_allActivePlayersIds find _tmpPlayerUid) > -1) then {_tmpPlayerStatus = true;};
		
		_tmpResult = _tmpResult + [[_tmpPlayerName, _tmpPlayerUid, _tmpIsAdmin, _tmpIsAdminLoggedIn, _tmpPlayerIsTrackStatisticsActive, _tmpPlayerTrackStatisticsKey, _tmpPlayerStatus]];
		if (_tmpPlayerUid == _playerUid) then
		{
			_playerOnly = [[_tmpPlayerName, _tmpPlayerUid, _tmpIsAdmin, _tmpIsAdminLoggedIn, _tmpPlayerIsTrackStatisticsActive, _tmpPlayerTrackStatisticsKey, _tmpPlayerStatus]];
		};
	} forEach _players;
	
	if (!_isAdminLoggedIn) then {_tmpResult = _playerOnly;};
	
	_filteredPlayers = [];
	if(_filterPlayers != "") then
	{
		{
			if (((toLower (_x select 0)) find (toLower _filterPlayers)) > -1) then
			{
				_filteredPlayers = _filteredPlayers + [_x];
			};
		} forEach _tmpResult;
	}
	else
	{
		_filteredPlayers = _tmpResult;
	};

	/* ---------------------------------------- */

	_result =
	[
		_playerUid, _clientId, _isAdmin, _isAdminLoggedIn,  
		_countPlayersTotal, _countPlayersOnline, _countAdminsTotal, _countAdminsOnline, 
		_filteredPlayers
	];
	
	_answer = _playerUid + "-answerDialogUpdate";
	missionNamespace setVariable [_answer, _result, false];
	_clientId publicVariableClient _answer;

	[format ["[%1] PPS Player Request Dialog Update: (%2)", serverTime, _playerUid]] call PPS_fnc_log;
};

/* ================================================================================ */

(_playerUid + "-updateStatistics") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	if (PPS_isEvent) then
	{
		_playerUid = _broadcastVariableValue select 0;
		_intervalStatistics = _broadcastVariableValue select 1;
		
		_dbName = "pps-statistics-" + _playerUid + "-" + PPS_eventId;
		_dbStatistics = ["new", _dbName] call OO_INIDBI;
		
		{
			_key = _x select 0;
			_value = _x select 1;
			_type = _x select 2;
			_formatType = _x select 3;
			_formatString = _x select 4;
			_source = _x select 5;
			
			if (_value > 0) then
			{
				_valueOld = ["read", [_key, "value", -1]] call _dbStatistics;
				if (_valueOld == -1) then
				{
					_valueOld = 0;
					_value = _valueOld + _value;
					["write", [_key, "key", _key]] call _dbStatistics;
					["write", [_key, "value", _value]] call _dbStatistics;
					["write", [_key, "type", _type]] call _dbStatistics;
					["write", [_key, "formatType", _formatType]] call _dbStatistics;
					["write", [_key, "formatString", _formatString]] call _dbStatistics;
					["write", [_key, "source", _source]] call _dbStatistics;
				}
				else
				{
					_value = _valueOld + _value;
					["write", [_key, "value", _value]] call _dbStatistics;
				};
			};
		} forEach _intervalStatistics;
		
		_dbName = "pps-players";
		_dbPlayers = ["new", _dbName] call OO_INIDBI;
		
		_isTrackStatisticsActive = ["read", [_playerUid, "isTrackStatisticsActive", false]] call _dbPlayers;
		_trackStatisticsKey = ["read", [_playerUid, "trackStatisticsKey", ""]] call _dbPlayers;
		_trackStatisticsClientId = ["read", [_playerUid, "trackStatisticsClientId", ""]] call _dbPlayers;
		
		if (_isTrackStatisticsActive) then
		{
			_trackStatisticsValue = ["read", [_trackStatisticsKey, "value", "not set"]] call _dbStatistics;

			if ((str _trackStatisticsValue) != (str "not set")) then
			{
				["STR_PPS_Main_Notifications_Tracking", _trackStatisticsKey, _trackStatisticsValue] remoteExecCall ["PPS_fnc_hintLocalized", _trackStatisticsClientId];
			};
		};
	
		[format ["[%1] PPS Player Updated Statistics: (%2)", serverTime, _playerUid]] call PPS_fnc_log;
	};
};

/* ================================================================================ */