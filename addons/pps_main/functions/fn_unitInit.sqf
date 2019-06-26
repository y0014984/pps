/*
 * Author: y0014984
 *
 * Initializes units and adds several event handlers.
 *
 * Arguments:
 * 0: _unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit] spawn PPS_fnc_unitInit;
 *
 * Public: No
 */

params ["_unit"];

//waitUntil {time > 15};

_playerUid = getPlayerUID _unit;

/* ================================================================================ */

if (isMultiplayer) then
{
	_index = _unit addMPEventHandler ["MPKilled",
	{
		params ["_unit", "_killer", "_instigator", "_useEffects"];

		_unit removeAllEventHandlers "HitPart";
		
		_unitUid = getPlayerUID _unit;
		_killerUid = getPlayerUID _killer;
		
		if (getClientState == "BRIEFING READ" && PPS_AllowSendingData && PPS_SendingInfantryData) then
		{				
			_source = "A3";
			_value = 1;
			_type = 2;
			_formatType = 0;
			
			_playerUid = "";
			_key = "";
			_formatString = "";
			
			if (_killerUid == _unitUid) then
			{
				_playerUid = _killerUid;
				_key = "countPlayerSuicides";
				_formatString = "STR_PPS_Main_Statistics_Count_Player_Suicides";			
			}
			else
			{
				switch (true) do
				{
					case (_unitUid != ""):
					{
						_playerUid = _unitUid;
						_key = "countPlayerDeaths";
						_formatString = "STR_PPS_Main_Statistics_Count_Player_Deaths";
					};
					case ((_unitUid == "") && (_killerUid != "") && ((side group _unit) != (side group _killer))):
					{
						_playerUid = _killerUid;
						_key = "countPlayerKills";
						_formatString = "STR_PPS_Main_Statistics_Count_Player_Kills";	
					};
					case ((_killerUid != "") && ((side group _unit) == (side group _killer))):
					{
						_playerUid = _killerUid;
						_key = "countPlayerTeamKills";
						_formatString = "STR_PPS_Main_Statistics_Count_Player_Team_Kills";
					};
				};
			};
			
			if (_playerUid != "") then
			{
				_updatedData = [_playerUid, [[_key, _value, _type, _formatType, _formatString, _source]]];
				_update = _playerUid + "-updateStatistics";
				missionNamespace setVariable [_update, _updatedData, false];
				publicVariableServer _update;
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
		
		//hint format ["Target: %1\nShooter: %2\nAmmo: %3", _targetUid, _shooterUid, (_ammo select 4)];
		
		_key = "";
		_value = 1;
		_type = 2;
		_formatType = 0;
		_formatString = "";
		
		if ((local _shooter) && (_shooterUid != "") && PPS_AllowSendingData && PPS_SendingInfantryData) then
		{
			if ((side group _shooter) != (side group _target)) then
			{
				if (((_ammo select 4) find "Grenade") > -1) then
				{
					_key = "countGrenadesHitEnemy";
					_formatType = 4;
					_formatString = "STR_PPS_Main_Statistics_Count_Grenades_Hit_Enemy";
				}
				else
				{
					_key = "countProjectilesHitEnemy";	
					_formatType = 2;					
					_formatString = "STR_PPS_Main_Statistics_Count_Projectiles_Hit_Enemy";
				};
			}
			else
			{
				if (((_ammo select 4) find "Grenade") > -1) then
				{
					_key = "countGrenadesHitFriendly";
					_formatType = 4;
					_formatString = "STR_PPS_Main_Statistics_Count_Grenades_Hit_Friendly";
				}
				else
				{
					_key = "countProjectilesHitFriendly";
					_formatType = 2;
					_formatString = "STR_PPS_Main_Statistics_Count_Projectiles_Hit_Friendly";
				};
			};

			//hint format ["Key: %1", _key];

			_playerUid = _shooterUid;
			_source = "A3";

			_updatedData = [_playerUid, [[_key, _value, _type, _formatType, _formatString, _source]]];
			_update = _playerUid + "-updateStatistics";
			missionNamespace setVariable [_update, _updatedData, false];
			publicVariableServer _update;			
		};
		
		if ((local _target) && (_targetUid != "") && PPS_AllowSendingData && PPS_SendingInfantryData) then
		{
			if ((side group _shooter) != (side group _target)) then
			{
				if (((_ammo select 4) find "Grenade") > -1) then
				{
					_key = "countGrenadesHitByEnemy";
					_formatType = 4;
					_formatString = "STR_PPS_Main_Statistics_Count_Grenades_Hit_By_Enemy";
				}
				else
				{
					_key = "countProjectilesHitByEnemy";	
					_formatType = 2;					
					_formatString = "STR_PPS_Main_Statistics_Count_Projectiles_Hit_By_Enemy";
				};
			}
			else
			{
				if (((_ammo select 4) find "Grenade") > -1) then
				{
					_key = "countGrenadesHitByFriendly";
					_formatType = 4;
					_formatString = "STR_PPS_Main_Statistics_Count_Grenades_Hit_By_Friendly";
				}
				else
				{
					_key = "countProjectilesHitByFriendly";
					_formatType = 2;
					_formatString = "";
				};
			};

			//hint format ["Key: %1", _key];

			_playerUid = _targetUid;
			_source = "A3";

			_updatedData = [_playerUid, [[_key, _value, _type, _formatType, _formatString, _source]]];
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
