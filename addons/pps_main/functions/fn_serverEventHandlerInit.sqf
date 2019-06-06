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
	_value = _broadcastVariableValue select 2;
	
	_dbName = "pps-players";
	_dbPlayers = ["new", _dbName] call OO_INIDBI;
	
	_isTrackStatisticsActive = ["read", [_playerUid, "isTrackStatisticsActive", false]] call _dbPlayers;
	
	if (_isTrackStatisticsActive) then
	{
		["write", [_playerUid, "isTrackStatisticsActive", false]] call _dbPlayers;
		["write", [_playerUid, "trackStatisticsKey", ""]] call _dbPlayers;
		["write", [_playerUid, "trackStatisticsClientId", ""]] call _dbPlayers;
	}
	else
	{
		["write", [_playerUid, "isTrackStatisticsActive", true]] call _dbPlayers;
		["write", [_playerUid, "trackStatisticsKey", _value]] call _dbPlayers;
		["write", [_playerUid, "trackStatisticsClientId", _clientId]] call _dbPlayers;
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

(_playerUid + "-requestSwitchEvent") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];

	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;
	_eventName = _broadcastVariableValue select 2;

	_dbName = "pps-players";
	_dbPlayers = ["new", _dbName] call OO_INIDBI;
	
	_isAdmin = ["read", [_playerUid, "isAdmin", false]] call _dbPlayers;
	_isAdminLoggedIn = ["read", [_playerUid, "isAdminLoggedIn", false]] call _dbPlayers;
	
	if (_isAdmin && _isAdminLoggedIn) then
	{		
		_dbName = "pps-events";
		_dbEvents = ["new", _dbName] call OO_INIDBI;
		
		_events = "getSections" call _dbEvents;
		_isEvent = false;
		_eventStartTime = [0, 0, 0, 0, 0, 0];
		_eventStopTime = [0, 0, 0, 0, 0, 0];
		{
			_eventStopTime = ["read", [_x, "eventStopTime", [0, 0, 0, 0, 0, 0]]] call _dbEvents;
			if (_eventStopTime isEqualTo [0, 0, 0, 0, 0, 0]) exitWith
			{
				_isEvent = true;
				_eventStartTime = ["read", [_x, "eventStartTime", [0, 0, 0, 0, 0, 0]]] call _dbEvents;
			}; 
		} forEach _events;
		
		if (!_isEvent) then
		{
			_eventStartTime = "getTimeStamp" call _dbEvents;
			
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
					
			["write", [_eventId, "eventId", _eventId]] call _dbEvents;
			["write", [_eventId, "eventName", _eventName]] call _dbEvents;
			["write", [_eventId, "eventPlayerUids", _allActivePlayersIds]] call _dbEvents;
			["write", [_eventId, "eventStartTime", _eventStartTime]] call _dbEvents;
			
			_isEvent = true;
			
			["STR_PPS_Main_Notifications_Event_Started", _eventName] remoteExecCall ["PPS_fnc_hintLocalized"];
		}
		else
		{
			_eventStopTime = "getTimeStamp" call _dbEvents;
			
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
			["write", [_eventId, "eventStopTime", _eventStopTime]] call _dbEvents;
			
			if ((_eventStopTime select 0) == (_eventStartTime select 0)) then
			{
				_eventStartTime set [5, "delete"];
				_eventStartTime = _eventStartTime - ["delete"];
				_eventStopTime set [5, "delete"];
				_eventStopTime = _eventStopTime - ["delete"];
				_eventDuration = (dateToNumber _eventStopTime) - (dateToNumber _eventStartTime);
				_eventDuration = numberToDate [_eventStopTime select 0, _eventDuration];
				if (((_eventDuration select 1) == 1) && ((_eventDuration select 2) == 1)) then
				{
					_eventDuration = ((_eventDuration select 3) * 60) + (_eventDuration select 4);
					["write", [_eventId, "eventDuration", _eventDuration]] call _dbEvents;
				};
			};
			
			_isEvent = false;
			
			["STR_PPS_Main_Notifications_Event_Stopped", _eventName] remoteExecCall ["PPS_fnc_hintLocalized"];
		};
		
		_result = [_isEvent, _eventName, _eventStartTime, _eventStopTime];
		
		_answer = _playerUid + "-answerSwitchEvent";
		missionNamespace setVariable [_answer, _result, false];
		_clientId publicVariableClient _answer;
		
		[format ["[%1] PPS Player Request Switch Event Status: set %2 (%3)", serverTime, _isEvent, _playerUid]] call PPS_fnc_log;
	};
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
		
		_dbName = "pps-player-" + _requestedPlayerUid;
		_dbPlayer = ["new", _dbName] call OO_INIDBI;
		
		_globalInformationsSection = "Global Informations";
		_intervalStatisticsSection = "Interval Statistics";
		_eventHandlerStatisticsSection = "Event Handler Statistics";
		_eventsInformationsSection = "Events Informations";

		_statisticsSectionsAndKeys =
		[
			[_globalInformationsSection, "playerName"], 
			[_globalInformationsSection, "playerUid"], 
			[_intervalStatisticsSection, "countUpdates"], 
			[_intervalStatisticsSection, "timeInEvent"], 
			[_eventHandlerStatisticsSection, "countProjectilesFired"], 
			[_eventHandlerStatisticsSection, "countGrenadesThrown"], 
			[_eventHandlerStatisticsSection, "countSmokeShellsThrown"], 
			[_eventHandlerStatisticsSection, "countChemlightsThrown"], 
			[_eventHandlerStatisticsSection, "countUnknownThrown"], 
			[_eventHandlerStatisticsSection, "countProjectilesHitEnemy"], 
			[_eventHandlerStatisticsSection, "countProjectilesHitFriendly"], 
			[_eventHandlerStatisticsSection, "countGrenadesHitEnemy"], 
			[_eventHandlerStatisticsSection, "countGrenadesHitFriendly"], 
			[_eventHandlerStatisticsSection, "countProjectilesHitByEnemy"], 
			[_eventHandlerStatisticsSection, "countProjectilesHitByFriendly"], 
			[_eventHandlerStatisticsSection, "countGrenadesHitByEnemy"], 
			[_eventHandlerStatisticsSection, "countGrenadesHitByFriendly"], 
			[_eventHandlerStatisticsSection, "countPlayerDeaths"], 
			[_eventHandlerStatisticsSection, "countPlayerKills"], 
			[_eventHandlerStatisticsSection, "countPlayerSuicides"], 
			[_eventHandlerStatisticsSection, "countPlayerTeamKills"], 
			[_eventHandlerStatisticsSection, "countCuratorInterfaceOpened"], 
			[_eventHandlerStatisticsSection, "countGearInterfaceOpened"], 
			[_eventHandlerStatisticsSection, "countCompassInterfaceOpened"], 
			[_eventHandlerStatisticsSection, "countWatchInterfaceOpened"], 
			[_eventHandlerStatisticsSection, "countBinocularUsed"], 
			[_eventHandlerStatisticsSection, "countOpticsUsed"], 
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
			[_intervalStatisticsSection, "timeInVehicleEngineOn"], 
			[_intervalStatisticsSection, "timeInVehicleMoving"], 
			[_intervalStatisticsSection, "timeInVehicleFlying"], 
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
			[_intervalStatisticsSection, "timeVehicleLightOn"], 
			[_intervalStatisticsSection, "timeVehicleLaser"], 
			[_intervalStatisticsSection, "timeVehicleCollisionLightOn"], 
			[_intervalStatisticsSection, "timeVehicleRadarOn"], 
			[_intervalStatisticsSection, "timeMapVisible"], 
			[_intervalStatisticsSection, "timeGpsVisible"], 
			[_intervalStatisticsSection, "timeCompassVisible"], 
			[_intervalStatisticsSection, "timeWatchVisible"], 
			[_intervalStatisticsSection, "timeVisionModeDay"], 
			[_intervalStatisticsSection, "timeVisionModeNight"], 
			[_intervalStatisticsSection, "timeVisionModeThermal"], 
			[_intervalStatisticsSection, "timeWeaponLowered"], 
			[_intervalStatisticsSection, "timeOnRoad"], 
			[_intervalStatisticsSection, "timeIsBleeding"], 
			[_intervalStatisticsSection, "timeIsBurning"], 
			[_intervalStatisticsSection, "timeInjuredNone"], 
			[_intervalStatisticsSection, "timeInjuredLow"], 
			[_intervalStatisticsSection, "timeInjuredMed"], 
			[_intervalStatisticsSection, "timeInjuredHigh"], 
			[_intervalStatisticsSection, "timeInjuredFull"], 
			[_intervalStatisticsSection, "timeIrLaserOn"], 
			[_intervalStatisticsSection, "timeFlashlightOn"], 
			[_intervalStatisticsSection, "timeMagazineFull"], 
			[_intervalStatisticsSection, "timeMagazineFillHigh"], 
			[_intervalStatisticsSection, "timeMagazineFillMid"], 
			[_intervalStatisticsSection, "timeMagazineFillLow"], 
			[_intervalStatisticsSection, "timeMagazineEmpty"], 
			[_intervalStatisticsSection, "timeIsMedic"], 
			[_intervalStatisticsSection, "timeIsEngineer"], 
			[_intervalStatisticsSection, "timeIsExplosiveSpecialist"], 
			[_intervalStatisticsSection, "timeIsUavHacker"], 
			[_eventHandlerStatisticsSection, "countEngineToggle"], 
			[_eventHandlerStatisticsSection, "countMagazineReloaded"], 
			[_eventHandlerStatisticsSection, "countBreathHolded"], 
			[_eventHandlerStatisticsSection, "countZoomUsed"], 
			[_eventHandlerStatisticsSection, "countLeanLeft"], 
			[_eventHandlerStatisticsSection, "countLeanRight"], 
			[_eventHandlerStatisticsSection, "countSalute"], 
			[_eventHandlerStatisticsSection, "countSitDown"], 
			[_eventHandlerStatisticsSection, "countGetOver"], 
			[_intervalStatisticsSection, "timeAddonAceActive"], 
			[_intervalStatisticsSection, "timeAceIsBleeding"], 
			[_eventHandlerStatisticsSection, "countAceCargoLoaded"], 
			[_eventHandlerStatisticsSection, "countAceCargoUnloaded"], 
			[_eventHandlerStatisticsSection, "countAceInteractMenuOpened"], 
			[_eventHandlerStatisticsSection, "countAceUnconscious"], 
			[_intervalStatisticsSection, "timeAddonTfarActive"],
			[_eventHandlerStatisticsSection, "countTfarIsSpeaking"], 
			[_eventHandlerStatisticsSection, "countTfarUsesRadio"], 
			[_intervalStatisticsSection, "timeTfarHasLrRadio"],
			[_intervalStatisticsSection, "timeTfarHasSwRadio"],
			[_intervalStatisticsSection, "timeTfarIsSpeaking"],
			[_intervalStatisticsSection, "timeTfarSpeakVolumeNormal"],
			[_intervalStatisticsSection, "timeTfarSpeakVolumeYelling"],
			[_intervalStatisticsSection, "timeTfarSpeakVolumeWhispering"]
		];
		
		_timeInEvent = ["read", [_intervalStatisticsSection, "timeInEvent", 0]] call _dbPlayer;
		_countProjectilesFired = ["read", [_eventHandlerStatisticsSection, "countProjectilesFired", 0]] call _dbPlayer;
		_countGrenadesThrown = ["read", [_eventHandlerStatisticsSection, "countGrenadesThrown", 0]] call _dbPlayer;
		
		_tmpResult = [];
		{
			_section = _x select 0;
			_key = _x select 1;
			_value = ["read", [_section, _key, ""]] call _dbPlayer;
			_formatType = ["read", [_section, _key + "FormatType", -1]] call _dbPlayer;
			_formatString = ["read", [_section, _key + "FormatString", ""]] call _dbPlayer;
			
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
						_tmpResult = _tmpResult + [[format [localize "STR_PPS_Main_Dialog_List_Value_Not_Recorded", _key], _key]];

					};
				};
				
		} forEach _statisticsSectionsAndKeys;
		
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

(_playerUid + "-requestDialogUpdate") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;
	_filterPlayers = _broadcastVariableValue select 2;
	_filterEvents = _broadcastVariableValue select 3;
	
	/* ---------------------------------------- */
	
	_addons = activatedAddons;
	_isInidbi2Installed = false;
	if ((_addons find "inidbi2") > -1) then {_isInidbi2Installed = true};

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
	
	{
		_tmpPlayerUid = getPlayerUID _x;
		_isAdmin = ["read", [_tmpPlayerUid, "isAdmin", false]] call _dbPlayers;
		if (_isAdmin) then {_countAdminsOnline = _countAdminsOnline + 1};
	} forEach _allActivePlayers;
	
	/* ---------------------------------------- */

	_players = [];
	
	_players = "getSections" call _dbPlayers;
	_countPlayersTotal = count _players;
	
	if (!_isAdmin && !_isAdminLoggedIn) then {_players = [_playerUid];};
	
	_tmpResult = [];
	{
		
	
		_tmpPlayerName = ["read", [_x, "playerName", ""]] call _dbPlayers;
		_tmpPlayerUid = ["read", [_x, "playerUid", ""]] call _dbPlayers;
		_tmpIsAdmin = ["read", [_x, "isAdmin", false]] call _dbPlayers;
		if (_tmpIsAdmin) then {_countAdminsTotal = _countAdminsTotal + 1};
		_tmpIsAdminLoggedIn = ["read", [_x, "isAdminLoggedIn", false]] call _dbPlayers;
		
		_tmpPlayerIsTrackStatisticsActive = ["read", [_x, "isTrackStatisticsActive", false]] call _dbPlayers;
		_tmpPlayerTrackStatisticsKey = ["read", [_x, "trackStatisticsKey", ""]] call _dbPlayers;
		
		_tmpResult = _tmpResult + [[_tmpPlayerName, _tmpPlayerUid, _tmpIsAdmin, _tmpIsAdminLoggedIn, _tmpPlayerIsTrackStatisticsActive, _tmpPlayerTrackStatisticsKey]];
	} forEach _players;
	
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

	_filteredEvents = [];
	_dbName = "pps-events";
	_dbEvents = ["new", _dbName] call OO_INIDBI;
	
	_events = "getSections" call _dbEvents;
	_isEvent = false;
	_activeEventName = "";
	_activeEventStartTime = [0, 0, 0, 0, 0, 0];
	_eventStopTime = [0, 0, 0, 0, 0, 0];
	{
		_eventName = ["read", [_x, "eventName", ""]] call _dbEvents;
		_eventStartTime = ["read", [_x, "eventStartTime", [0, 0, 0, 0, 0, 0]]] call _dbEvents;
		
		_eventPlayerUids = ["read", [_x, "eventPlayerUids", 0]] call _dbEvents;
		if (((_eventPlayerUids find _playerUid) > -1) && ((((toLower _eventName) find (toLower _filterEvents)) > -1) || (_filterEvents == ""))) then
		{
			_eventId = ["read", [_x, "eventId", 0]] call _dbEvents;
			_eventDuration = ["read", [_x, "eventDuration", 0]] call _dbEvents;
			_filteredEvents = _filteredEvents + [[_eventId, _eventName, _eventDuration, _eventStartTime]];
		};
		
		_eventStopTime = ["read", [_x, "eventStopTime", [0, 0, 0, 0, 0, 0]]] call _dbEvents;
		if (_eventStopTime isEqualTo [0, 0, 0, 0, 0, 0]) then
		{
			_isEvent = true;
			_activeEventName = _eventName;
			_activeEventStartTime = _eventStartTime;
			
			//hint format ["_isEvent: %1", _isEvent];
		}; 
	} forEach _events;

	/* ---------------------------------------- */

	_result =
	[
		_playerUid, _clientId, _isAdmin, _isAdminLoggedIn, 
		_isInidbi2Installed, 
		_countPlayersTotal, _countPlayersOnline, _countAdminsTotal, _countAdminsOnline, 
		_isEvent, _activeEventName, _activeEventStartTime,
		_filteredPlayers,
		_filteredEvents
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

	_dbName = "pps-events";
	_dbEvents = ["new", _dbName] call OO_INIDBI;
	
	_events = "getSections" call _dbEvents;
	_isEvent = false;
	_eventStopTime = [0, 0, 0, 0, 0, 0];
	{
		_eventStopTime = ["read", [_x, "eventStopTime", [0, 0, 0, 0, 0, 0]]] call _dbEvents;
		if (_eventStopTime isEqualTo [0, 0, 0, 0, 0, 0]) exitWith
		{
			_isEvent = true;
		}; 
	} forEach _events;

	if (_isEvent) then
	{
		_playerUid = _broadcastVariableValue select 0;
		_intervalStatistics = _broadcastVariableValue select 1;
		
		_dbName = "pps-player-" + _playerUid;
		_dbPlayer = ["new", _dbName] call OO_INIDBI;
		
		_globalInformationsSection = "Global Informations";
		_intervalStatisticsSection = "Interval Statistics";
		_eventHandlerStatisticsSection = "Event Handler Statistics";

		/*
		if ((count _intervalStatistics) == 1) then
		{
			["Einzelwert"] call PPS_fnc_log;
			[count _intervalStatistics] call PPS_fnc_log;
			[_intervalStatistics] call PPS_fnc_log;
			_key = (_intervalStatistics select 0) select 1;
			_value = (_intervalStatistics select 0) select 2;
			_str = format ["Key: %1\nValue: %2", _key, _value];
			_str remoteExec ["hint"];
		}
		else
		{
			["Mehrfachwertwert"] call PPS_fnc_log;
			[count _intervalStatistics] call PPS_fnc_log;
			[_intervalStatistics] call PPS_fnc_log;
		};
		*/
		
		{
			_section = _x select 0;
			_key = _x select 1;
			_value = _x select 2;
			_formatType = _x select 3;
			_formatString = _x select 4;
			
			if (_section == _globalInformationsSection) then
			{
				["write", [_section, _key, _value]] call _dbPlayer;
			};
			if ((_section == _intervalStatisticsSection) || (_section == _eventHandlerStatisticsSection)) then
			{
				_valueOld = ["read", [_section, _key, 0]] call _dbPlayer;
				_value = _valueOld + _value;
				["write", [_section, _key, _value]] call _dbPlayer;
			};			
			["write", [_section, _key + "FormatType", _formatType]] call _dbPlayer;
			["write", [_section, _key + "FormatString", _formatString]] call _dbPlayer;
		} forEach _intervalStatistics;
		
		_countUpdates = ["read", [_intervalStatisticsSection, "countUpdates", 0]] call _dbPlayer;
		_countUpdates = _countUpdates + 1;
		["write", [_intervalStatisticsSection, "countUpdates", _countUpdates]] call _dbPlayer;
		["write", [_intervalStatisticsSection, "countUpdatesFormatType", 0]] call _dbPlayer;
		["write", [_intervalStatisticsSection, "countUpdatesFormatString", "Count Updates: %1"]] call _dbPlayer;
		
		_dbName = "pps-players";
		_dbPlayers = ["new", _dbName] call OO_INIDBI;
		
		_isTrackStatisticsActive = ["read", [_playerUid, "isTrackStatisticsActive", false]] call _dbPlayers;
		_trackStatisticsKey = ["read", [_playerUid, "trackStatisticsKey", ""]] call _dbPlayers;
		_trackStatisticsClientId = ["read", [_playerUid, "trackStatisticsClientId", ""]] call _dbPlayers;
		
		if (_isTrackStatisticsActive) then
		{
			_trackStatisticsValue = ["read", [_intervalStatisticsSection, _trackStatisticsKey, "not set"]] call _dbPlayer;
			if ((str _trackStatisticsValue) == (str "not set")) then
			{
				_trackStatisticsValue = ["read", [_eventHandlerStatisticsSection, _trackStatisticsKey, "not set"]] call _dbPlayer;
			};
			if ((str _trackStatisticsValue) != (str "not set")) then
			{
				["STR_PPS_Main_Notifications_Tracking", _trackStatisticsKey, _trackStatisticsValue] remoteExecCall ["PPS_fnc_hintLocalized", _trackStatisticsClientId];
			};
		};
	
		[format ["[%1] PPS Player Updated Statistics: (%2)", serverTime, _playerUid]] call PPS_fnc_log;
	};
};

/* ================================================================================ */