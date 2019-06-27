/*
 * Author: y0014984
 *
 * Adds 'HitPart' event handler to all units. Nesseccary in case of respawn.
 *
 * Arguments:
 * 0: _unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit] call PPS_fnc_unitEventHandlerHitPartAdd;
 *
 * Public: No
 */
 
params ["_unit"];

/* ================================================================================ */

if (local _unit) then
{
	_index = _unit addEventHandler ["HitPart",
	{
		(_this select 0) params ["_target", "_shooter", "_projectile", "_position", "_velocity", "_selection", "_ammo", "_vector", "_radius", "_surfaceType", "_isDirect"];

		//hint format ["Target: %1\nShooter: %2\nAmmo: %3", _targetUid, _shooterUid, (_ammo select 4)];

		_targetUid = getPlayerUID _target;
		_targetSide = side group _target;
		_shooterUid = getPlayerUID _shooter;
		_shooterSide = side group _shooter;
		
		_clientId = clientOwner;
		
		_key = "";
		_value = 1;
		_type = 2;
		_formatType = 0;
		_formatString = "";
		
		if ((local _shooter) && (_shooterUid != "") && PPS_AllowSendingData && PPS_SendingInfantryData) then
		{
			_playerUid = _shooterUid;
			_source = "A3";
			
			// _eventHandlerInformation = format ["Event Handler 'HitPart' fired for local _shooter.\n\n_target: %1 (%2 - %3)\n_shooter: %4 (%5 - %6)\n\nclientId: %7", _target, _targetUid, _targetSide, _shooter, _shooterUid, _shooterSide, _clientId];
			// hint _eventHandlerInformation;
			// [_eventHandlerInformation] call PPS_fnc_log;
			
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

			_updatedData = [_playerUid, [[_key, _value, _type, _formatType, _formatString, _source]]];
			_update = _playerUid + "-updateStatistics";
			missionNamespace setVariable [_update, _updatedData, false];
			publicVariableServer _update;			
		};
		
		if ((_target != "") && PPS_AllowSendingData && PPS_SendingInfantryData) then
		{
			_playerUid = _targetUid;
			_source = "A3";
			
			// _eventHandlerInformation = format ["Event Handler 'HitPart' fired for local _target.\n\n_target: %1 (%2 - %3)\n_shooter: %4 (%5 - %6)\n\nclientId: %7", _target, _targetUid, _targetSide, _shooter, _shooterUid, _shooterSide, _clientId];
			// hint _eventHandlerInformation;
			// [_eventHandlerInformation] call PPS_fnc_log;
			
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
					_formatString = "STR_PPS_Main_Statistics_Count_Projectiles_Hit_By_Friendly";
				};
			};

			_updatedData = [_playerUid, [[_key, _value, _type, _formatType, _formatString, _source]]];
			_update = _playerUid + "-updateStatistics";
			missionNamespace setVariable [_update, _updatedData, false];
			publicVariableServer _update;	
		};
	}];
};

[format ["[%1] PPS Event Handler 'HitPart' added to Unit: (%2)", serverTime, (getPlayerUID _unit)]] call PPS_fnc_log;