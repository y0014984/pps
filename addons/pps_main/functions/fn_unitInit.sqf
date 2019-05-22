params ["_unit"];

waitUntil {time > 15};

_playerUid = getPlayerUID _unit;

/* ================================================================================ */

if (local _unit && isMultiplayer) then
{
	_index = _unit addMPEventHandler ["MPKilled",
	{
		params ["_unit", "_killer", "_instigator", "_useEffects"];

		_unit removeAllEventHandlers "HitPart";
		
		_unitUid = getPlayerUID _unit;
		_killerUid = getPlayerUID _killer;
		
		if (local _unit) then
		{
			if (getClientState == "BRIEFING READ") then
			{
				if (_unitUid != "") then
				{
					_playerUid = _unitUid;
					_section = "Event Handler Statistics";
					_key = "countPlayerDeaths";
					_value = 1;
					_formatType = 0;
					_formatString = "[A3] Count Player Deaths: %1";
					
					_updatedData = [_playerUid, [[_section, _key, _value, _formatType, _formatString]]];
					_update = _playerUid + "-updateStatistics";
					missionNamespace setVariable [_update, _updatedData, false];
					publicVariableServer _update;
				};
				
				if (_killerUid != "") then
				{
					_playerUid = _killerUid;
					_section = "Event Handler Statistics";
					_key = "countPlayerKills";
					_value = 1;
					_formatType = 0;
					_formatString = "[A3] Count Player Kills: %1";
								
					_updatedData = [_playerUid, [[_section, _key, _value, _formatType, _formatString]]];
					_update = _playerUid + "-updateStatistics";
					missionNamespace setVariable [_update, _updatedData, false];
					publicVariableServer _update;				
				};
				
				if (_killerUid == _unitUid) then
				{
					_playerUid = _killerUid;
					_section = "Event Handler Statistics";
					_key = "countPlayerSuicides";
					_value = 1;
					_formatType = 0;
					_formatString = "[A3] Count Player Suicides: %1";
								
					_updatedData = [_playerUid, [[_section, _key, _value, _formatType, _formatString]]];
					_update = _playerUid + "-updateStatistics";
					missionNamespace setVariable [_update, _updatedData, false];
					publicVariableServer _update;				
				};

				if (_killerUid != _unitUid && _killerUid != "" && ((side group _unit) == (side group _killer))) then
				{
					_playerUid = _killerUid;
					_section = "Event Handler Statistics";
					_key = "countPlayerTeamKills";
					_value = 1;
					_formatType = 0;
					_formatString = "[A3] Count Player Team Kills: %1";
								
					_updatedData = [_playerUid, [[_section, _key, _value, _formatType, _formatString]]];
					_update = _playerUid + "-updateStatistics";
					missionNamespace setVariable [_update, _updatedData, false];
					publicVariableServer _update;
				};
			};
		};
	}];
	
	[format ["[%1] PPS Event Handler 'MPKilled' added to Unit: (%2)", serverTime, (getPlayerUID _unit)]] call PPS_fnc_log;
	
	/* ================================================================================ */
	
	_index = _unit addEventHandler ["HitPart",
	{
		(_this select 0) params ["_target", "_shooter", "_projectile", "_position", "_velocity", "_selection", "_ammo", "_vector", "_radius", "_surfaceType", "_isDirect"];
		
		_targetUid = getPlayerUID _target;
		_shooterUid = getPlayerUID _shooter;
		
		hint format ["Target: %1\nShooter: %2\nAmmo: %3", _targetUid, _shooterUid, (_ammo select 4)];
		
		_key = "";
		_value = 1;
		_formatType = 0;
		_formatString = "";
		
		if (_shooterUid != "") then
		{
			if ((side group _shooter) != (side group _target)) then
			{
				if (((_ammo select 4) find "Grenade") > -1) then
				{
					_key = "countGrenadesHitEnemy";
					_formatType = 4;
					_formatString = "[A3] Count Grenades Hit Enemy: %2 (%3%1)";
				}
				else
				{
					_key = "countProjectilesHitEnemy";	
					_formatType = 2;					
					_formatString = "[A3] Count Projectiles Hit Enemy: %2 (%3%1)";
				};
			}
			else
			{
				if (((_ammo select 4) find "Grenade") > -1) then
				{
					_key = "countGrenadesHitFriendly";
					_formatType = 4;
					_formatString = "[A3] Count Grenades Hit Friendly: %2 (%3%1)";
				}
				else
				{
					_key = "countProjectilesHitFriendly";
					_formatType = 2;
					_formatString = "[A3] Count Projectiles Hit Friendly: %2 (%3%1)";
				};
			};

			//hint format ["Key: %1", _key];

			_playerUid = _shooterUid;
			_section = "Event Handler Statistics";

			_updatedData = [_playerUid, [[_section, _key, _value, _formatType, _formatString]]];
			_update = _playerUid + "-updateStatistics";
			missionNamespace setVariable [_update, _updatedData, false];
			publicVariableServer _update;			
		};
		
		if (_targetUid != "") then
		{
			if ((side group _shooter) != (side group _target)) then
			{
				if (((_ammo select 4) find "Grenade") > -1) then
				{
					_key = "countGrenadesHitByEnemy";
					_formatType = 4;
					_formatString = "[A3] Count Grenades Hit By Enemy: %2 (%3%1)";
				}
				else
				{
					_key = "countProjectilesHitByEnemy";	
					_formatType = 2;					
					_formatString = "[A3] Count Projectiles Hit By Enemy: %2 (%3%1)";
				};
			}
			else
			{
				if (((_ammo select 4) find "Grenade") > -1) then
				{
					_key = "countGrenadesHitByFriendly";
					_formatType = 4;
					_formatString = "[A3] Count Grenades Hit By Friendly: %2 (%3%1)";
				}
				else
				{
					_key = "countProjectilesHitByFriendly";
					_formatType = 2;
					_formatString = "[A3] Count Projectiles Hit By Friendly: %2 (%3%1)";
				};
			};

			//hint format ["Key: %1", _key];

			_playerUid = _targetUid;
			_section = "Event Handler Statistics";

			_updatedData = [_playerUid, [[_section, _key, _value, _formatType, _formatString]]];
			_update = _playerUid + "-updateStatistics";
			missionNamespace setVariable [_update, _updatedData, false];
			publicVariableServer _update;	
		};
	}];
	
	[format ["[%1] PPS Event Handler 'HitPart' added to Unit: (%2)", serverTime, (getPlayerUID _unit)]] call PPS_fnc_log;
};

/* ================================================================================ */

if (_playerUid != "" && hasInterface && isMultiplayer) then
{
	[] call PPS_fnc_playerInit;
	
};

/* ================================================================================ */
