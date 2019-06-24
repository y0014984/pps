/*
 * Author: y0014984
 *
 * Initializes vehicles and adds several event handlers.
 *
 * Arguments:
 * 0: _vehicle <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_vehicle] spawn PPS_fnc_vehicleInit;
 *
 * Public: No
 */

params ["_vehicle"];

/* ================================================================================ */

if (isMultiplayer && ((allUnits find _vehicle) == -1)) then
{
	_index = _vehicle addEventHandler ["Engine",
	{
		params ["_vehicle", "_engineState"];
		
		//hint format ["Engine Event Handler\n\nVehicle: %1\nengineState: %2", _vehicle, _engineState];
		
		_driver = driver _vehicle;
		if (local _driver) then
		{	
			_playerUid = getPlayerUID _driver;
			
			if (_playerUid != "") then
			{
				if (_engineState) then
				{
						_source = "A3";
						_key = "countEngineTurnedOn";
						_value = 1;
						_type = 2;
						_formatType = 0;
						_formatString = "STR_PPS_Main_Statistics_Count_Engine_Turned_On";
									
						_updatedData = [_playerUid, [[_key, _value, _type, _formatType, _formatString, _source]]];
						_update = _playerUid + "-updateStatistics";
						missionNamespace setVariable [_update, _updatedData, false];
						publicVariableServer _update;	
				}
				else
				{
						_source = "A3";
						_key = "countEngineTurnedOff";
						_value = 1;
						_type = 2;
						_formatType = 0;
						_formatString = "STR_PPS_Main_Statistics_Count_Engine_Turned_Off";
									
						_updatedData = [_playerUid, [[_key, _value, _type, _formatType, _formatString, _source]]];
						_update = _playerUid + "-updateStatistics";
						missionNamespace setVariable [_update, _updatedData, false];
						publicVariableServer _update;	
				};
			};
		};
	}];
	
	[format ["[%1] PPS Event Handler 'Engine' added to Vehicle: (%2)", serverTime, _vehicle]] call PPS_fnc_log;
	
	/* ================================================================================ */

	_index = _vehicle addEventHandler ["Dammaged", 
	{
		params ["_unit", "_selection", "_damage", "_hitIndex", "_hitPoint", "_shooter", "_projectile"];
		
		//hint format ["Dammaged Event Handler\n\nUnit: %1\nDamage: %2\nShooter: %3\nProjectile: %4", _unit, _damage, _shooter, _projectile];
		
		_shooterUid = getPlayerUID _shooter;
		
		if ((local _shooter) && (_shooterUid != "") && (_damage == 1)) then
		{	
			_source = "A3";
			_key = "countFriendlyVehiclesDestroyed";
			_value = 1;
			_type = 2;
			_formatType = 0;
			_formatString = "STR_PPS_Main_Statistics_Count_Friendly_Vehicles_Destroyed";
			
			if ((side group _shooter) != (side group _unit)) then
			{
				_source = "A3";
				_key = "countEnemyVehiclesDestroyed";
				_value = 1;
				_type = 2;
				_formatType = 0;
				_formatString = "STR_PPS_Main_Statistics_Count_Enemy_Vehicles_Destroyed";
			};

			_playerUid = _shooterUid;
			
			_updatedData = [_playerUid, [[_key, _value, _type, _formatType, _formatString, _source]]];
			_update = _playerUid + "-updateStatistics";
			missionNamespace setVariable [_update, _updatedData, false];
			publicVariableServer _update;

			_unit removeAllEventHandlers "HitPart";
			_unit removeAllEventHandlers "Dammaged";
		};
	}];
	
	[format ["[%1] PPS Event Handler 'Dammaged' added to Vehicle: (%2)", serverTime, _vehicle]] call PPS_fnc_log;

	/* ================================================================================ */

	_index = _vehicle addEventHandler ["HitPart",
	{
		(_this select 0) params ["_target", "_shooter", "_projectile", "_position", "_velocity", "_selection", "_ammo", "_vector", "_radius", "_surfaceType", "_isDirect"];
		
		//hint format ["HitPart Event Handler\n\nTarget: %1\nShooter: %2\nAmmo: %3", _target, _shooter, (_ammo select 4)];
		
		_shooterUid = getPlayerUID _shooter;
		
		_key = "";
		_value = 1;
		_type = 2;
		_formatType = 0;
		_formatString = "";
		
		if ((local _shooter) && (_shooterUid != "")) then
		{
			if ((side group _shooter) != (side group _target)) then
			{
				if (((_ammo select 4) find "Grenade") > -1) then
				{
					_key = "countGrenadesHitEnemyVehicle";
					_formatType = 4;
					_formatString = "STR_PPS_Main_Statistics_Count_Grenades_Hit_Enemy_Vehicle";
				}
				else
				{
					_key = "countProjectilesHitEnemyVehicle";	
					_formatType = 2;					
					_formatString = "STR_PPS_Main_Statistics_Count_Projectiles_Hit_Enemy_Vehicle";
				};
			}
			else
			{
				if (((_ammo select 4) find "Grenade") > -1) then
				{
					_key = "countGrenadesHitFriendlyVehicle";
					_formatType = 4;
					_formatString = "STR_PPS_Main_Statistics_Count_Grenades_Hit_Friendly_Vehicle";
				}
				else
				{
					_key = "countProjectilesHitFriendly";
					_formatType = 2;
					_formatString = "STR_PPS_Main_Statistics_Count_Projectiles_Hit_Friendly_Vehicle";
				};
			};

			_playerUid = _shooterUid;
			_source = "A3";

			_updatedData = [_playerUid, [[_key, _value, _type, _formatType, _formatString, _source]]];
			_update = _playerUid + "-updateStatistics";
			missionNamespace setVariable [_update, _updatedData, false];
			publicVariableServer _update;	
		};
	}];
	
	[format ["[%1] PPS Event Handler 'HitPart' added to Vehicle: (%2)", serverTime, _vehicle]] call PPS_fnc_log;
	
	/* ================================================================================ */

};