if (isServer && isMultiplayer) then
{
	_serverStatus = "PPS_ServerStatus";
	missionNamespace setVariable [_serverStatus, true, false];
	publicVariable _serverStatus;
	
	_dbName = "pps-players";
	_inidbi = ["new", _dbName] call OO_INIDBI;
	
	_sections = "getSections" call _inidbi;
	
	{
		[_x] call PPS_fnc_initServerEventHandler;
		_playerUid = ["read", [_x, "playerUid", "<id not set>"]] call _inidbi;
		diag_log format ["[%1] DB PPS Player: (%2)", serverTime, _playerUid];
	} forEach _sections;
	
	"ppsServerHelo" addPublicVariableEventHandler
	{
		params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
		
		_playerName = _broadcastVariableValue select 0;
		_playerUid = _broadcastVariableValue select 1;
		
		diag_log format ["[%1] PPS Player send Helo to server: (%2)", serverTime, _playerUid];
			
		_dbName = "pps-players";
		_inidbi = ["new", _dbName] call OO_INIDBI;
		
		_sections = "getSections" call _inidbi;
		
		_result = _sections find _playerUid;
		
		if (_result == -1) then
		{
			_filter = "0123456789AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZzÜüÖöÄä[]-_.:#*(){}%$§&<>+-,;'~?= ";
			_playerName = [_playerName, _filter] call BIS_fnc_filterString;
			
			["write", [_playerUid, "playerName", _playerName]] call _inidbi;
			["write", [_playerUid, "playerUid", _playerUid]] call _inidbi;
			["write", [_playerUid, "isAdmin", false]] call _inidbi;
			["write", [_playerUid, "isAdminLoggedIn", false]] call _inidbi;
			
			_playerName = ["read", [_playerUid, "playerName", "<name not set>"]] call _inidbi;
			_playerUid = ["read", [_playerUid, "playerUid", "<id not set>"]] call _inidbi;
			_isAdmin = ["read", [_playerUid, "playerName", false]] call _inidbi;
			_isAdminLoggedIn = ["read", [_playerUid, "playerUid", false]] call _inidbi;
			
			[_playerUid] call PPS_fnc_initServerEventHandler;
			
			diag_log format ["[%1] New PPS Player added to DB: (%2)", serverTime, _playerUid];
		};
	};
};