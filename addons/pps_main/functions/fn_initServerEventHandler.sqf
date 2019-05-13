params ["_playerUid"];

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

(_playerUid + "-requestPlayerEvents") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;
	_requestedPlayerUid = _broadcastVariableValue select 2;

	_dbName = "pps-players";
	_inidbi = ["new", _dbName] call OO_INIDBI;
	
	_isAdmin = ["read", [_playerUid, "isAdmin", 0]] call _inidbi;
	_isAdminLoggedIn = ["read", [_playerUid, "isAdminLoggedIn", 0]] call _inidbi;
	
	if((_playerUid == _requestedPlayerUid) || (_isAdmin == 1)) then
	{
		_dbName = "pps-events";
		_inidbi = ["new", _dbName] call OO_INIDBI;
		
		_sections = "getSections" call _inidbi;
		
		_result = [];
		
		{
			_eventName = ["read", [_x, "eventName", ""]] call _inidbi;
			_eventStartTime = ["read", [_x, "eventStartTime", ""]] call _inidbi;
			_eventDuration = ["read", [_x, "eventDuration", ""]] call _inidbi;
			_eventAllActivePlayerIds = ["read", [_x, "eventAllActivePlayerIds", ""]] call _inidbi;
			
			if ((_eventStartTime select 1) < 10) then {_eventStartTime set [1, format["0%1", _eventStartTime select 1]]};
			if ((_eventStartTime select 2) < 10) then {_eventStartTime set [2, format["0%1", _eventStartTime select 2]]};
			
			if ((_eventAllActivePlayerIds find _requestedPlayerUid) > -1) then
			{
				_result = _result + [format ["PPS Event: %1 (%2-%3-%4 >> %5 min)", _eventName, (_eventStartTime select 0), (_eventStartTime select 1), (_eventStartTime select 2), _eventDuration]];
			};
		} forEach _sections;
		
		_answer = _playerUid + "-answerPlayerEvents";
		missionNamespace setVariable [_answer, _result, false];
		_clientId publicVariableClient _answer;
		
		diag_log format ["[%1] PPS Player Request Events: %2 (%3)", serverTime, _requestedPlayerName, _requestedPlayerUid];
	};
};

(_playerUid + "-requestPlayerStatistics") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;
	_requestedPlayerUid = _broadcastVariableValue select 2;
	
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
		
		_timeStanceStand = ["read", [_intervalSection, "timeStanceStand", 0]] call _inidbi;
		_timeStanceCrouch = ["read", [_intervalSection, "timeStanceCrouch", 0]] call _inidbi;
		_timeStanceProne = ["read", [_intervalSection, "timeStanceProne", 0]] call _inidbi;
		_roundTimeStanceStand = parseNumber ((_timeStanceStand / 3600) toFixed 2);
		_roundTimeStanceCrouch = parseNumber ((_timeStanceCrouch / 3600) toFixed 2);
		_roundTimeStanceProne = parseNumber ((_timeStanceProne / 3600) toFixed 2);
		_roundTimeStanceStandPercent = parseNumber ((100 / _timeInEvent * _timeStanceStand) toFixed 2);
		_roundTimeStanceCrouchPercent = parseNumber ((100 / _timeInEvent * _timeStanceCrouch) toFixed 2);
		_roundTimeStancePronePercent = parseNumber ((100 / _timeInEvent * _timeStanceProne) toFixed 2);
		
		_timeSpeedStanding = ["read", [_intervalSection, "timeSpeedStanding", 0]] call _inidbi;
		_timeSpeedWalking = ["read", [_intervalSection, "timeSpeedWalking", 0]] call _inidbi;
		_timeSpeedRunning = ["read", [_intervalSection, "timeSpeedRunning", 0]] call _inidbi;
		_timeSpeedSprinting = ["read", [_intervalSection, "timeSpeedSprinting", 0]] call _inidbi;
		_roundTimeSpeedStanding = parseNumber ((_timeSpeedStanding / 3600) toFixed 2);
		_roundTimeSpeedWalking = parseNumber ((_timeSpeedWalking / 3600) toFixed 2);
		_roundTimeSpeedRunning = parseNumber ((_timeSpeedRunning / 3600) toFixed 2);
		_roundTimeSpeedSprinting = parseNumber ((_timeSpeedSprinting / 3600) toFixed 2);
		_roundTimeSpeedStandingPercent = parseNumber ((100 / _timeInEvent * _timeSpeedStanding) toFixed 2);
		_roundTimeSpeedWalkingPercent = parseNumber ((100 / _timeInEvent * _timeSpeedWalking) toFixed 2);
		_roundTimeSpeedRunningPercent = parseNumber ((100 / _timeInEvent * _timeSpeedRunning) toFixed 2);
		_roundTimeSpeedSprintingPercent = parseNumber ((100 / _timeInEvent * _timeSpeedSprinting) toFixed 2);
		
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
		
		_timeMapVisible = ["read", [_intervalSection, "timeMapVisible", 0]] call _inidbi;
		_roundTimeMapVisible = parseNumber ((_timeMapVisible / 3600) toFixed 2);
		_roundTimeMapVisiblePercent = parseNumber ((100 / _timeInEvent * _timeMapVisible) toFixed 2);
		_timeGpsVisible = ["read", [_intervalSection, "timeGpsVisible", 0]] call _inidbi;
		_roundTimeGpsVisible = parseNumber ((_timeGpsVisible / 3600) toFixed 2);
		_roundTimeGpsVisiblePercent = parseNumber ((100 / _timeInEvent * _timeGpsVisible) toFixed 2);
		
		_timeInVehicle = ["read", [_intervalSection, "timeInVehicle", 0]] call _inidbi;
		_roundTimeInVehicle = parseNumber ((_timeInVehicle / 3600) toFixed 2);
		_roundTimeInVehiclePercent = parseNumber ((100 / _timeInEvent * _timeInVehicle) toFixed 2);
		_timeInVehicleCar = ["read", [_intervalSection, "timeInVehicleCar", 0]] call _inidbi;
		_roundTimeInVehicleCar = parseNumber ((_timeInVehicleCar / 3600) toFixed 2);
		_roundTimeInVehicleCarPercent = parseNumber ((100 / _timeInEvent * _timeInVehicleCar) toFixed 2);
		_timeInVehicleTank = ["read", [_intervalSection, "timeInVehicleTank", 0]] call _inidbi;
		_roundTimeInVehicleTank = parseNumber ((_timeInVehicleTank / 3600) toFixed 2);
		_roundTimeInVehicleTankPercent = parseNumber ((100 / _timeInEvent * _timeInVehicleTank) toFixed 2);
		_timeInVehicleTruck = ["read", [_intervalSection, "timeInVehicleTruck", 0]] call _inidbi;
		_roundTimeInVehicleTruck = parseNumber ((_timeInVehicleTruck / 3600) toFixed 2);
		_roundTimeInVehicleTruckPercent = parseNumber ((100 / _timeInEvent * _timeInVehicleTruck) toFixed 2);
		_timeInVehicleMotorcycle = ["read", [_intervalSection, "timeInVehicleMotorcycle", 0]] call _inidbi;
		_roundTimeInVehicleMotorcycle = parseNumber ((_timeInVehicleMotorcycle / 3600) toFixed 2);
		_roundTimeInVehicleMotorcyclePercent = parseNumber ((100 / _timeInEvent * _timeInVehicleMotorcycle) toFixed 2);
		_timeInVehicleHelicopter = ["read", [_intervalSection, "timeInVehicleHelicopter", 0]] call _inidbi;
		_roundTimeInVehicleHelicopter = parseNumber ((_timeInVehicleHelicopter / 3600) toFixed 2);
		_roundTimeInVehicleHelicopterPercent = parseNumber ((100 / _timeInEvent * _timeInVehicleHelicopter) toFixed 2);	
		_timeInVehiclePlane = ["read", [_intervalSection, "timeInVehiclePlane", 0]] call _inidbi;
		_roundTimeInVehiclePlane = parseNumber ((_timeInVehiclePlane / 3600) toFixed 2);
		_roundTimeInVehiclePlanePercent = parseNumber ((100 / _timeInEvent * _timeInVehiclePlane) toFixed 2);
		_timeInVehicleShip = ["read", [_intervalSection, "timeInVehicleShip", 0]] call _inidbi;
		_roundTimeInVehicleShip = parseNumber ((_timeInVehicleShip / 3600) toFixed 2);
		_roundTimeInVehicleShipPercent = parseNumber ((100 / _timeInEvent * _timeInVehicleShip) toFixed 2);
		_timeInVehicleBoat = ["read", [_intervalSection, "timeInVehicleBoat", 0]] call _inidbi;
		_roundTimeInVehicleBoat = parseNumber ((_timeInVehicleBoat / 3600) toFixed 2);
		_roundTimeInVehicleBoatPercent = parseNumber ((100 / _timeInEvent * _timeInVehicleBoat) toFixed 2);
		_timeInVehicleSeatDriver = ["read", [_intervalSection, "timeInVehicleSeatDriver", 0]] call _inidbi;
		_roundTimeInVehicleSeatDriver = parseNumber ((_timeInVehicleSeatDriver / 3600) toFixed 2);
		_roundTimeInVehicleSeatDriverPercent = parseNumber ((100 / _timeInEvent * _timeInVehicleSeatDriver) toFixed 2);
		_timeInVehicleSeatGunner = ["read", [_intervalSection, "timeInVehicleSeatGunner", 0]] call _inidbi;
		_roundTimeInVehicleSeatGunner = parseNumber ((_timeInVehicleSeatGunner / 3600) toFixed 2);
		_roundTimeInVehicleSeatGunnerPercent = parseNumber ((100 / _timeInEvent * _timeInVehicleSeatGunner) toFixed 2);
		_timeInVehicleSeatCommander = ["read", [_intervalSection, "timeInVehicleSeatCommander", 0]] call _inidbi;
		_roundTimeInVehicleSeatCommander = parseNumber ((_timeInVehicleSeatCommander / 3600) toFixed 2);
		_roundTimeInVehicleSeatCommanderPercent = parseNumber ((100 / _timeInEvent * _timeInVehicleSeatCommander) toFixed 2);
		_timeInVehicleSeatPassenger = ["read", [_intervalSection, "timeInVehicleSeatPassenger", 0]] call _inidbi;
		_roundTimeInVehicleSeatPassenger = parseNumber ((_timeInVehicleSeatPassenger / 3600) toFixed 2);
		_roundTimeInVehicleSeatPassengerPercent = parseNumber ((100 / _timeInEvent * _timeInVehicleSeatPassenger) toFixed 2);
		
		_timeWeaponLowered = ["read", [_intervalSection, "timeWeaponLowered", 0]] call _inidbi;
		_roundTimeWeaponLowered = parseNumber ((_timeWeaponLowered / 3600) toFixed 2);
		_roundTimeWeaponLoweredPercent = parseNumber ((100 / _timeInEvent * _timeWeaponLowered) toFixed 2);
		
		_result = [];
		_result = _result + [format ["Player Name: %1", _requestedPlayerName]];
		_result = _result + [format ["Player UID: %1", _requestedPlayerUid]];
		_result = _result + [format ["Count Updates: %1", _countUpdates]];
		_result = _result + [format ["Time in Game: %1 hrs", str _roundTimeInEvent]];
		
		_result = _result + [format ["Count Projectiles Fired: %1", _countProjectilesFired]];
		_result = _result + [format ["Count Grenades Thrown: %1", _countGrenadesThrown]];
		_result = _result + [format ["Count Smoke Shells Thrown: %1", _countSmokeShellsThrown]];
		_result = _result + [format ["Count Chemlights Thrown: %1", _countChemlightsThrown]];
		_result = _result + [format ["Count Unknown Thrown: %1", _countUnknownThrown]];

		_result = _result + [format ["Count Projectiles Hit Enemy: %2 (%3%1)", "%", _countProjectilesHitEnemy, _roundCountProjectilesHitEnemyPercent]];
		_result = _result + [format ["Count Projectiles Hit Friendly: %2 (%3%1)", "%", _countProjectilesHitFriendly, _roundCountProjectilesHitFriendlyPercent]];		
		_result = _result + [format ["Count Grenades Hit Enemy: %2 (%3%1)", "%", _countGrenadesHitEnemy, _roundCountGrenadesHitEnemyPercent]];
		_result = _result + [format ["Count Grenades Hit Friendly: %2 (%3%1)", "%", _countGrenadesHitFriendly, _roundCountGrenadesHitFriendlyPercent]];	
		
		_result = _result + [format ["Count Kills: %1", _countPlayerKills]];
		_result = _result + [format ["Count Deaths: %1", _countPlayerDeaths]];
		_result = _result + [format ["Count Suicides: %1", _countPlayerSuicides]];
		_result = _result + [format ["Count Team Kills: %1", _countPlayerTeamKills]];
		
		_result = _result + [format ["Interface Zeus Opened: %1", _countCuratorInterfaceOpened]];
		_result = _result + [format ["Interface Gear Opened: %1", round (_countGearInterfaceOpened / 2)]];
		_result = _result + [format ["Interface Compass Opened: %1", _countCompassInterfaceOpened]];
		_result = _result + [format ["Interface Watch Opened: %1", _countWatchInterfaceOpened]];
		
		_result = _result + [format ["Time Stance Stand: %2 hrs (%3%1)", "%", str _roundTimeStanceStand, str _roundTimeStanceStandPercent]];
		_result = _result + [format ["Time Stance Crouch: %2 hrs (%3%1)", "%", str _roundTimeStanceCrouch, str _roundTimeStanceCrouchPercent]];
		_result = _result + [format ["Time Stance Prone: %2 hrs (%3%1)", "%", str _roundTimeStanceProne, str _roundTimeStancePronePercent]];
		_result = _result + [format ["Time Speed Standing: %2 hrs (%3%1)", "%", str _roundTimeSpeedStanding, str _roundTimeSpeedStandingPercent]];
		_result = _result + [format ["Time Speed Walking: %2 hrs (%3%1)", "%", str _roundTimeSpeedWalking, str _roundTimeSpeedWalkingPercent]];
		_result = _result + [format ["Time Speed Running: %2 hrs (%3%1)", "%", str _roundTimeSpeedRunning, str _roundTimeSpeedRunningPercent]];
		_result = _result + [format ["Time Speed Sprinting: %2 hrs (%3%1)", "%", str _roundTimeSpeedSprinting, str _roundTimeSpeedSprintingPercent]];
		
		_result = _result + [format ["Time Map Visible: %2 hrs (%3%1)", "%", str _roundTimeMapVisible, str _roundTimeMapVisiblePercent]];
		_result = _result + [format ["Time Gps Visible: %2 hrs (%3%1)", "%", str _roundTimeGpsVisible, str _roundTimeGpsVisiblePercent]];
		
		_result = _result + [format ["Time In Vehicle: %2 hrs (%3%1)", "%", str _roundTimeInVehicle, str _roundTimeInVehiclePercent]];
		_result = _result + [format ["Time In Vehicle Car: %2 hrs (%3%1)", "%", str _roundTimeInVehicleCar, str _roundTimeInVehicleCarPercent]];
		_result = _result + [format ["Time In Vehicle Tank: %2 hrs (%3%1)", "%", str _roundTimeInVehicleTank, str _roundTimeInVehicleTankPercent]];
		_result = _result + [format ["Time In Vehicle Truck: %2 hrs (%3%1)", "%", str _roundTimeInVehicleTruck, str _roundTimeInVehicleTruckPercent]];
		_result = _result + [format ["Time In Vehicle Motorcycle: %2 hrs (%3%1)", "%", str _roundTimeInVehicleMotorcycle, str _roundTimeInVehicleMotorcyclePercent]];
		_result = _result + [format ["Time In Vehicle Helicopter: %2 hrs (%3%1)", "%", str _roundTimeInVehicleHelicopter, str _roundTimeInVehicleHelicopterPercent]];
		_result = _result + [format ["Time In Vehicle Plane: %2 hrs (%3%1)", "%", str _roundTimeInVehiclePlane, str _roundTimeInVehiclePlanePercent]];
		_result = _result + [format ["Time In Vehicle Ship: %2 hrs (%3%1)", "%", str _roundTimeInVehicleShip, str _roundTimeInVehicleShipPercent]];
		_result = _result + [format ["Time In Vehicle Boat: %2 hrs (%3%1)", "%", str _roundTimeInVehicleBoat, str _roundTimeInVehicleBoatPercent]];
		_result = _result + [format ["Time In Vehicle Seat Driver: %2 hrs (%3%1)", "%", str _roundTimeInVehicleSeatDriver, str _roundTimeInVehicleSeatDriverPercent]];
		_result = _result + [format ["Time In Vehicle Seat Gunner: %2 hrs (%3%1)", "%", str _roundTimeInVehicleSeatGunner, str _roundTimeInVehicleSeatGunnerPercent]];
		_result = _result + [format ["Time In Vehicle Seat Commander: %2 hrs (%3%1)", "%", str _roundTimeInVehicleSeatCommander, str _roundTimeInVehicleSeatCommanderPercent]];
		_result = _result + [format ["Time In Vehicle Seat Passenger: %2 hrs (%3%1)", "%", str _roundTimeInVehicleSeatPassenger, str _roundTimeInVehicleSeatPassengerPercent]];
		
		_result = _result + [format ["Time Weapon Lowered: %2 hrs (%3%1)", "%", str _roundTimeWeaponLowered, str _roundTimeWeaponLoweredPercent]];
		
		_answer = _playerUid + "-answerPlayerStatistics";
		missionNamespace setVariable [_answer, _result, false];
		_clientId publicVariableClient _answer;
		
		diag_log format ["[%1] PPS Player Request Statistics: %2 (%3)", serverTime, _requestedPlayerName, _requestedPlayerUid];
	};
};

(_playerUid + "-requestPlayerDetails") addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;
	_request = _broadcastVariableValue select 2;
	
	_dbName = "pps-players";
	_inidbi = ["new", _dbName] call OO_INIDBI;
	
	_sections = [];
	
	if (_request == "all") then
	{
		_sections = "getSections" call _inidbi;
	}
	else
	{
		_sections = [_request];
	};
	
	_result = [];
	{
		_playerName = ["read", [_x, "playerName", ""]] call _inidbi;
		_playerUid = ["read", [_x, "playerUid", ""]] call _inidbi;
		_isAdmin = ["read", [_playerUid, "isAdmin", 0]] call _inidbi;
		_isAdminLoggedIn = ["read", [_playerUid, "isAdminLoggedIn", 0]] call _inidbi;
		
		_result = _result + [[_playerName, _playerUid, _isAdmin, _isAdminLoggedIn]];
	} forEach _sections;
	
	_answer = _playerUid + "-answerPlayerDetails";
	missionNamespace setVariable [_answer, _result, false];
	_clientId publicVariableClient _answer;
	
	_dbName = "pps-player-" + _playerUid;
	_inidbi = ["new", _dbName] call OO_INIDBI;		
	_globalSection = "Global Informations";
	_playerName = ["read", [_globalSection, "playerName", ""]] call _inidbi;
	
	diag_log format ["[%1] PPS Player Request Player Details: %2 (%3)", serverTime, _playerName, _playerUid];
};

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
		
		diag_log format ["[%1] PPS Player Updated Event Handler Data: %2 (%3) Key: %4 Value: %5", serverTime, _playerName, _playerUid, _key, _value];
	};
};

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
		
		_timeStanceStandAdd = _broadcastVariableValue select 3;
		_timeStanceCrouchAdd = _broadcastVariableValue select 4;
		_timeStanceProneAdd = _broadcastVariableValue select 5;
		
		_timeSpeedStandingAdd = _broadcastVariableValue select 6;
		_timeSpeedWalkingAdd = _broadcastVariableValue select 7;
		_timeSpeedRunningAdd = _broadcastVariableValue select 8;
		_timeSpeedSprintingAdd = _broadcastVariableValue select 9;
		
		_timeMapVisibleAdd = _broadcastVariableValue select 10;
		_timeGpsVisibleAdd = _broadcastVariableValue select 11;
		
		_timeInVehicleAdd = _broadcastVariableValue select 12;
		_timeInVehicleCarAdd = _broadcastVariableValue select 13;
		_timeInVehicleTankAdd = _broadcastVariableValue select 14;
		_timeInVehicleTruckAdd = _broadcastVariableValue select 15;
		_timeInVehicleMotorcycleAdd = _broadcastVariableValue select 16;
		_timeInVehicleHelicopterAdd = _broadcastVariableValue select 17;
		_timeInVehiclePlaneAdd = _broadcastVariableValue select 18;
		_timeInVehicleShipAdd = _broadcastVariableValue select 19;
		_timeInVehicleBoatAdd = _broadcastVariableValue select 20;
		_timeInVehicleSeatDriverAdd = _broadcastVariableValue select 21;
		_timeInVehicleSeatGunnerAdd = _broadcastVariableValue select 22;
		_timeInVehicleSeatCommanderAdd = _broadcastVariableValue select 23;
		_timeInVehicleSeatPassengerAdd = _broadcastVariableValue select 24;
		
		_timeWeaponLoweredAdd = _broadcastVariableValue select 25;
		
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
		
		_timeStanceStandOld = ["read", [_intervalSection, "timeStanceStand", 0]] call _inidbi;
		_timeStanceStand = _timeStanceStandOld + _timeStanceStandAdd;
		["write", [_intervalSection, "timeStanceStand", _timeStanceStand]] call _inidbi;
		_timeStanceCrouchOld = ["read", [_intervalSection, "timeStanceCrouch", 0]] call _inidbi;
		_timeStanceCrouch = _timeStanceCrouchOld + _timeStanceCrouchAdd;
		["write", [_intervalSection, "timeStanceCrouch", _timeStanceCrouch]] call _inidbi;
		_timeStanceProneOld = ["read", [_intervalSection, "timeStanceProne", 0]] call _inidbi;
		_timeStanceProne = _timeStanceProneOld + _timeStanceProneAdd;
		["write", [_intervalSection, "timeStanceProne", _timeStanceProne]] call _inidbi;
		
		_timeSpeedStandingOld = ["read", [_intervalSection, "timeSpeedStanding", 0]] call _inidbi;
		_timeSpeedStanding = _timeSpeedStandingOld + _timeSpeedStandingAdd;
		["write", [_intervalSection, "timeSpeedStanding", _timeSpeedStanding]] call _inidbi;
		_timeSpeedWalkingOld = ["read", [_intervalSection, "timeSpeedWalking", 0]] call _inidbi;
		_timeSpeedWalking = _timeSpeedWalkingOld + _timeSpeedWalkingAdd;
		["write", [_intervalSection, "timeSpeedWalking", _timeSpeedWalking]] call _inidbi;
		_timeSpeedRunningOld = ["read", [_intervalSection, "timeSpeedRunning", 0]] call _inidbi;
		_timeSpeedRunning = _timeSpeedRunningOld + _timeSpeedRunningAdd;
		["write", [_intervalSection, "timeSpeedRunning", _timeSpeedRunning]] call _inidbi;
		_timeSpeedSprintingOld = ["read", [_intervalSection, "timeSpeedSprinting", 0]] call _inidbi;
		_timeSpeedSprinting = _timeSpeedSprintingOld + _timeSpeedSprintingAdd;
		["write", [_intervalSection, "timeSpeedSprinting", _timeSpeedSprinting]] call _inidbi;
		
		_timeMapVisibleOld = ["read", [_intervalSection, "timeMapVisible", 0]] call _inidbi;
		_timeMapVisible = _timeMapVisibleOld + _timeMapVisibleAdd;
		["write", [_intervalSection, "timeMapVisible", _timeMapVisible]] call _inidbi;
		_timeGpsVisibleOld = ["read", [_intervalSection, "timeGpsVisible", 0]] call _inidbi;
		_timeGpsVisible = _timeGpsVisibleOld + _timeGpsVisibleAdd;
		["write", [_intervalSection, "timeGpsVisible", _timeGpsVisible]] call _inidbi;
		
		_timeInVehicleOld = ["read", [_intervalSection, "timeInVehicle", 0]] call _inidbi;
		_timeInVehicle = _timeInVehicleOld + _timeInVehicleAdd;
		["write", [_intervalSection, "timeInVehicle", _timeInVehicle]] call _inidbi;
		_timeInVehicleCarOld = ["read", [_intervalSection, "timeInVehicleCar", 0]] call _inidbi;
		_timeInVehicleCar = _timeInVehicleCarOld + _timeInVehicleCarAdd;
		["write", [_intervalSection, "timeInVehicleCar", _timeInVehicleCar]] call _inidbi;
		_timeInVehicleTankOld = ["read", [_intervalSection, "timeInVehicleTank", 0]] call _inidbi;
		_timeInVehicleTank = _timeInVehicleTankOld + _timeInVehicleTankAdd;
		["write", [_intervalSection, "timeInVehicleTank", _timeInVehicleTank]] call _inidbi;
		_timeInVehicleTruckOld = ["read", [_intervalSection, "timeInVehicleTruck", 0]] call _inidbi;
		_timeInVehicleTruck = _timeInVehicleTruckOld + _timeInVehicleTruckAdd;
		["write", [_intervalSection, "timeInVehicleTruck", _timeInVehicleTruck]] call _inidbi;
		_timeInVehicleMotorcycleOld = ["read", [_intervalSection, "timeInVehicleMotorcycle", 0]] call _inidbi;
		_timeInVehicleMotorcycle = _timeInVehicleMotorcycleOld + _timeInVehicleMotorcycleAdd;
		["write", [_intervalSection, "timeInVehicleMotorcycle", _timeInVehicleMotorcycle]] call _inidbi;
		_timeInVehicleHelicopterOld = ["read", [_intervalSection, "timeInVehicleHelicopter", 0]] call _inidbi;
		_timeInVehicleHelicopter = _timeInVehicleHelicopterOld + _timeInVehicleHelicopterAdd;
		["write", [_intervalSection, "timeInVehicleHelicopter", _timeInVehicleHelicopter]] call _inidbi;
		_timeInVehiclePlaneOld = ["read", [_intervalSection, "timeInVehiclePlane", 0]] call _inidbi;
		_timeInVehiclePlane = _timeInVehiclePlaneOld + _timeInVehiclePlaneAdd;
		["write", [_intervalSection, "timeInVehiclePlane", _timeInVehiclePlane]] call _inidbi;
		_timeInVehicleShipOld = ["read", [_intervalSection, "timeInVehicleShip", 0]] call _inidbi;
		_timeInVehicleShip = _timeInVehicleShipOld + _timeInVehicleShipAdd;
		["write", [_intervalSection, "timeInVehicleShip", _timeInVehicleShip]] call _inidbi;
		_timeInVehicleBoatOld = ["read", [_intervalSection, "timeInVehicleBoat", 0]] call _inidbi;
		_timeInVehicleBoat = _timeInVehicleBoatOld + _timeInVehicleBoatAdd;
		["write", [_intervalSection, "timeInVehicleBoat", _timeInVehicleBoat]] call _inidbi;
		
		_timeInVehicleSeatDriverOld = ["read", [_intervalSection, "timeInVehicleSeatDriver", 0]] call _inidbi;
		_timeInVehicleSeatDriver = _timeInVehicleSeatDriverOld + _timeInVehicleSeatDriverAdd;
		["write", [_intervalSection, "timeInVehicleSeatDriver", _timeInVehicleSeatDriver]] call _inidbi;
		_timeInVehicleSeatGunnerOld = ["read", [_intervalSection, "timeInVehicleSeatGunner", 0]] call _inidbi;
		_timeInVehicleSeatGunner = _timeInVehicleSeatGunnerOld + _timeInVehicleSeatGunnerAdd;
		["write", [_intervalSection, "timeInVehicleSeatGunner", _timeInVehicleSeatGunner]] call _inidbi;
		_timeInVehicleSeatCommanderOld = ["read", [_intervalSection, "timeInVehicleSeatCommander", 0]] call _inidbi;
		_timeInVehicleSeatCommander = _timeInVehicleSeatCommanderOld + _timeInVehicleSeatCommanderAdd;
		["write", [_intervalSection, "timeInVehicleSeatCommander", _timeInVehicleSeatCommander]] call _inidbi;
		_timeInVehicleSeatPassengerOld = ["read", [_intervalSection, "timeInVehicleSeatPassenger", 0]] call _inidbi;
		_timeInVehicleSeatPassenger = _timeInVehicleSeatPassengerOld + _timeInVehicleSeatPassengerAdd;
		["write", [_intervalSection, "timeInVehicleSeatPassenger", _timeInVehicleSeatPassenger]] call _inidbi;
		
		_timeWeaponLoweredOld = ["read", [_intervalSection, "timeWeaponLowered", 0]] call _inidbi;
		_timeWeaponLowered = _timeWeaponLoweredOld + _timeWeaponLoweredAdd;
		["write", [_intervalSection, "timeWeaponLowered", _timeWeaponLowered]] call _inidbi;
		
		diag_log format ["[%1] PPS Player Updated Interval Data: %2 (%3)", serverTime, _playerName, _playerUid];
	};
};