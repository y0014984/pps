if (isServer && isMultiplayer) then
{
	_serverStatus = "PPS_ServerStatus";
	missionNamespace setVariable [_serverStatus, true, false];
	publicVariable _serverStatus;
	
	_dbName = "pps-players";
	_dbPlayers = ["new", _dbName] call OO_INIDBI;
	
	_sections = "getSections" call _dbPlayers;
	
	{
		[_x] call PPS_fnc_serverEventHandlerInit;
		_playerUid = ["read", [_x, "playerUid", "<id not set>"]] call _dbPlayers;
		[format ["[%1] DB PPS Player: (%2)", serverTime, _playerUid]] call PPS_fnc_log;
	} forEach _sections;
	
	"ppsServerHelo" addPublicVariableEventHandler
	{
		params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
		
		_playerName = _broadcastVariableValue select 0;
		_playerUid = _broadcastVariableValue select 1;
		
		[format ["[%1] PPS Player send Helo to server: (%2)", serverTime, _playerUid]] call PPS_fnc_log;
			
		_dbName = "pps-players";
		_dbPlayers = ["new", _dbName] call OO_INIDBI;
		
		_sections = "getSections" call _dbPlayers;
		
		_result = _sections find _playerUid;
		
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
};