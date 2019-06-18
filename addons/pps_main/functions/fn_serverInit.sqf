/*
 * Author: y0014984
 *
 * PPS Server Initialization. Sets global vartiables for the first time.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * None. Is started in postInit.
 *
 * Public: No
 */

_activatedAddons = activatedAddons;
_addonInidbi2Activated = false;
if ((_activatedAddons find "inidbi2") > -1) then
{
	_addonInidbi2Activated = true;
}
else
{
	[format ["[%1] PPS server mod INIDBI2 not activated. Server will not start.", serverTime]] call PPS_fnc_log;
};

PPS_statusDatabase = _addonInidbi2Activated;
publicVariable "PPS_statusDatabase";

if (isServer && isMultiplayer && _addonInidbi2Activated) then
{
	/* ---------------------------------------- */
	
	PPS_statusServer = true;
	publicVariable "PPS_statusServer";
	
	_dbName = "pps-players";
	_dbPlayers = ["new", _dbName] call OO_INIDBI;
	
	if ("exists" call _dbPlayers) then
	{
		_players = "getSections" call _dbPlayers;
		
		{
			[_x] call PPS_fnc_serverEventHandlerInit;
			_playerUid = ["read", [_x, "playerUid", "<id not set>"]] call _dbPlayers;
			[format ["[%1] DB PPS Player: (%2)", serverTime, _playerUid]] call PPS_fnc_log;
		} forEach _players;
	};	

	/* ---------------------------------------- */

	"ppsServerHelo" addPublicVariableEventHandler
	{
		params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
		
		_playerName = _broadcastVariableValue select 0;
		_playerUid = _broadcastVariableValue select 1;
		
		[format ["[%1] PPS Player send Helo to server: (%2)", serverTime, _playerUid]] call PPS_fnc_log;
			
		_dbName = "pps-players";
		_dbPlayers = ["new", _dbName] call OO_INIDBI;

		_players = [];
		if ("exists" call _dbPlayers) then
		{
			_players = "getSections" call _dbPlayers;
		};
		
		_result = _players find _playerUid;
		
		if (_result == -1) then
		{
			["write", [_playerUid, "playerName", _playerName]] call _dbPlayers;
			["write", [_playerUid, "playerUid", _playerUid]] call _dbPlayers;
			["write", [_playerUid, "isAdmin", false]] call _dbPlayers;
			["write", [_playerUid, "isAdminLoggedIn", false]] call _dbPlayers;
			
			_playerName = ["read", [_playerUid, "playerName", "<name not set>"]] call _dbPlayers;
			_playerUid = ["read", [_playerUid, "playerUid", "<id not set>"]] call _dbPlayers;
			_isAdmin = ["read", [_playerUid, "playerName", false]] call _dbPlayers;
			_isAdminLoggedIn = ["read", [_playerUid, "playerUid", false]] call _dbPlayers;
			
			[_playerUid] call PPS_fnc_serverEventHandlerInit;
			
			[format ["[%1] New PPS Player added to DB: (%2)", serverTime, _playerUid]] call PPS_fnc_log;
		};
	};
	
	/* ---------------------------------------- */

	_dbName = "pps-events";
	_dbEvents = ["new", _dbName] call OO_INIDBI;
	
	_isEvent = false;
	_eventName = "";
	_eventStartTime = [0, 0, 0, 0, 0, 0];
	_eventStopTime = [0, 0, 0, 0, 0, 0];
	_eventId = "";
	
	if ("exists" call _dbEvents) then
	{
		_events = "getSections" call _dbEvents;
		{
			_eventStopTime = ["read", [_x, "eventStopTime", [0, 0, 0, 0, 0, 0]]] call _dbEvents;
			if (_eventStopTime isEqualTo [0, 0, 0, 0, 0, 0]) exitWith
			{
				_isEvent = true;
				_eventName = ["read", [_x, "eventName", ""]] call _dbEvents;
				_eventStartTime = ["read", [_x, "eventStartTime", [0, 0, 0, 0, 0, 0]]] call _dbEvents;
				_eventId = ["read", [_x, "eventId", ""]] call _dbEvents;
			}; 
		} forEach _events;
	};

	if (_isEvent) then
	{
		_eventStopTime = "getTimeStamp" call _dbEvents;
		
		["write", [_eventId, "eventStopTime", _eventStopTime]] call _dbEvents;
		
		if ((_eventStopTime select 0) == (_eventStartTime select 0)) then
		{
			_tmpEventStartTime = +_eventStartTime;
			_tmpEventStartTime set [5, "delete"];
			_tmpEventStartTime = _tmpEventStartTime - ["delete"];
			_tmpEventStopTime = +_eventStopTime;
			_tmpEventStopTime set [5, "delete"];
			_tmpEventStopTime = _tmpEventStopTime - ["delete"];
			_eventDuration = (dateToNumber _tmpEventStopTime) - (dateToNumber _tmpEventStartTime);
			_eventDuration = numberToDate [_tmpEventStopTime select 0, _eventDuration];
			if (((_eventDuration select 1) == 1) && ((_eventDuration select 2) == 1)) then
			{
				_eventDurationOld = ["read", [_eventId, "eventDuration", 0]] call _dbEvents;
				_eventDuration = _eventDurationOld + (((_eventDuration select 3) * 60) + (_eventDuration select 4));
				["write", [_eventId, "eventDuration", _eventDuration]] call _dbEvents;
			};
		};
		
		_isEvent = false;
		
		["STR_PPS_Main_Notifications_Event_Stopped", _eventName] remoteExecCall ["PPS_fnc_hintLocalized"];
	};

	PPS_isEvent = _isEvent;
	publicVariable "PPS_isEvent";
	PPS_eventName = _eventName;
	publicVariable "PPS_eventName";
	PPS_eventId = _eventId;
	publicVariable "PPS_eventId";
	PPS_eventStartTime = +_eventStartTime;
	publicVariable "PPS_eventStartTime";
	PPS_eventStopTime = +_eventStopTime;
	publicVariable "PPS_eventStopTime";
	
	
	
	/* ---------------------------------------- */
}
else
{
	PPS_statusServer = false;
	publicVariable "PPS_statusServer";
};