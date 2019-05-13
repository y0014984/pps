params ["_unit"];

_playerUid = getPlayerUID _unit;
_playerName = name _unit;

if (local _unit) then
{
	//_unit removeAllEventHandlers "Killed";
	_index = _unit addEventHandler ["Killed",
	{
		params ["_unit", "_killer", "_instigator", "_useEffects"];

		_unit removeAllEventHandlers "HitPart";
		
		_unitUid = getPlayerUID _unit;
		_killerUid = getPlayerUID _killer;
		
		if (getClientState == "BRIEFING READ") then
		{
			if (_unitUid != "" && _unitUid != "_SP_PLAYER_") then
			{
				_playerUid = _unitUid;
				_section = "Event Handler Statistics";
				_key = "countPlayerDeaths";
				_value = 1;
							
				_updatedData = [_playerUid, _section, _key, _value];
				_update = _playerUid + "-updateEventHandlerValue";
				missionNamespace setVariable [_update, _updatedData, false];
				publicVariableServer _update;

				diag_log format ["[%1] PPS Event Death netIds: Unit: %2 Killer: %3", serverTime, netId _unit, netId _killer];
			};
			
			if (_killerUid != "" && _killerUid != "_SP_PLAYER_") then
			{
				_playerUid = _killerUid;
				_section = "Event Handler Statistics";
				_key = "countPlayerKills";
				_value = 1;
							
				_updatedData = [_playerUid, _section, _key, _value];
				_update = _playerUid + "-updateEventHandlerValue";
				missionNamespace setVariable [_update, _updatedData, false];
				publicVariableServer _update;
				
				diag_log format ["[%1] PPS Event Kill netIds: Unit: %2 Killer: %3", serverTime, netId _unit, netId _killer];
			};
			
			if (_killerUid == _unitUid && _unitUid != "_SP_PLAYER_") then
			{
				_playerUid = _killerUid;
				_section = "Event Handler Statistics";
				_key = "countPlayerSuicides";
				_value = 1;
							
				_updatedData = [_playerUid, _section, _key, _value];
				_update = _playerUid + "-updateEventHandlerValue";
				missionNamespace setVariable [_update, _updatedData, false];
				publicVariableServer _update;
				
				diag_log format ["[%1] PPS Event Suicide netIds: Unit: %2 Killer: %3", serverTime, netId _unit, netId _killer];
			};

			if (_killerUid != _unitUid && _killerUid != ""  && _killerUid != "_SP_PLAYER_" && ((side group _unit) == (side group _killer))) then
			{
				_playerUid = _killerUid;
				_section = "Event Handler Statistics";
				_key = "countPlayerTeamKills";
				_value = 1;
							
				_updatedData = [_playerUid, _section, _key, _value];
				_update = _playerUid + "-updateEventHandlerValue";
				missionNamespace setVariable [_update, _updatedData, false];
				publicVariableServer _update;

				diag_log format ["[%1] PPS Event Team Kill netIds: Unit: %2 Killer: %3", serverTime, netId _unit, netId _killer];
			};
		};
	}];
	
	_index = _unit addEventHandler ["HitPart",
	{
		(_this select 0) params ["_target", "_shooter", "_projectile", "_position", "_velocity", "_selection", "_ammo", "_vector", "_radius", "_surfaceType", "_isDirect"];
		
		_targetUid = getPlayerUID _target;
		_shooterUid = getPlayerUID _shooter;
		
		_playerUid = _shooterUid;
		_playerName = name _shooter;
		_section = "Event Handler Statistics";
		
		_key = "";
		
		if ((_shooterUid != "") && (_shooterUid != "_SP_PLAYER_")) then
		{
			if ((side group _shooter) != (side group _target)) then
			{
				if (((_ammo select 4) find "Grenade") > -1) then
				{
					_key = "countGrenadesHitEnemy";	
				}
				else
				{
					_key = "countProjectilesHitEnemy";		
				};
			}
			else
			{
				if (((_ammo select 4) find "Grenade") > -1) then
				{
					_key = "countGrenadesHitFriendly";		
				}
				else
				{
					_key = "countProjectilesHitFriendly";	
				};
			};

			hint format ["Key: %1", _key];
			
			_value = 1;
			_updatedData = [_playerUid, _section, _key, _value];
			_update = _playerUid + "-updateEventHandlerValue";
			missionNamespace setVariable [_update, _updatedData, false];
			publicVariableServer _update;
			
			diag_log format ["[%1] PPS Event Projectile Hit NetIds: Shooter: %2 Target: %3", serverTime, netId _shooter, netId _target];
		};
	}];

	if (_playerUid != "" && _playerUid != "_SP_PLAYER_" && hasInterface) then
	{
		_index = player addEventHandler ["FiredMan",
		{
			params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_vehicle"];
			
			_playerUid = getPlayerUID _unit;
			_playerName = name _unit;
			_section = "Event Handler Statistics";

			_key = "";
			if (_weapon == "Throw") then
			{
				if ((_muzzle find "Grenade") > -1) then {_key = "countGrenadesThrown";};
				if ((_muzzle find "SmokeShell") > -1) then {_key = "countSmokeShellsThrown";};
				if ((_muzzle find "Chemlight") > -1) then {_key = "countChemlightsThrown";};
				if (_key == "") then {_key = "countUnknownThrown";};
			}
			else
			{
				_key = "countProjectilesFired";		
			};
			
			_value = 1;
			
			//hint format ["Weapon: %1\nMuzzle: %2\nMode: %3\nAmmo: %4\nMagazine: %5", _weapon, _muzzle, _mode, _ammo, _magazine];
			
			_updatedData = [_playerUid, _section, _key, _value];
			_update = _playerUid + "-updateEventHandlerValue";
			missionNamespace setVariable [_update, _updatedData, false];
			publicVariableServer _update;
			
			diag_log format ["[%1] PPS Event Projectile Fired: %2 (%3)", serverTime, _playerName, _playerUid];			
		}];
		
		waitUntil {sleep 1; getClientState == "BRIEFING READ";};
		
		(findDisplay 46) displayAddEventHandler ["KeyDown", 
		{
			_playerUid = getPlayerUID player;
			_playerName = name player;
			_section = "Event Handler Statistics";
			
			if (inputAction "CuratorInterface" > 0) then 
			{
				_key = "countCuratorInterfaceOpened";
				_value = 1;
							
				_updatedData = [_playerUid, _section, _key, _value];
				_update = _playerUid + "-updateEventHandlerValue";
				missionNamespace setVariable [_update, _updatedData, false];
				publicVariableServer _update;

				diag_log format ["[%1] PPS Event Curator Interface Opened: Unit: %2 (%3)", serverTime, _playerName, _playerUid];
			};

			if (inputAction "Gear" > 0) then 
			{
				_key = "countGearInterfaceOpened";
				_value = 1;
							
				_updatedData = [_playerUid, _section, _key, _value];
				_update = _playerUid + "-updateEventHandlerValue";
				missionNamespace setVariable [_update, _updatedData, false];
				publicVariableServer _update;

				diag_log format ["[%1] PPS Event Gear Interface Opened: Unit: %2 (%3)", serverTime, _playerName, _playerUid];
			};
					
			if (inputAction "CompassToggle" > 0) then 
			{
				_key = "countCompassInterfaceOpened";
				_value = 1;
							
				_updatedData = [_playerUid, _section, _key, _value];
				_update = _playerUid + "-updateEventHandlerValue";
				missionNamespace setVariable [_update, _updatedData, false];
				publicVariableServer _update;

				diag_log format ["[%1] PPS Event Compass Interface Opened: Unit: %2 (%3)", serverTime, _playerName, _playerUid];
			};
			
			if (inputAction "WatchToggle" > 0) then 
			{
				_key = "countWatchInterfaceOpened";
				_value = 1;
							
				_updatedData = [_playerUid, _section, _key, _value];
				_update = _playerUid + "-updateEventHandlerValue";
				missionNamespace setVariable [_update, _updatedData, false];
				publicVariableServer _update;

				diag_log format ["[%1] PPS Event Watch Interface Opened: Unit: %2 (%3)", serverTime, _playerName, _playerUid];
			};
			
			//Ergänzen: NightVision, Binocular, HoldBreath, Optics, Handgun, ReloadMagazine etc.
		}];
	};
};

if (_playerUid != "" && _playerUid != "_SP_PLAYER_" && hasInterface) then
{
	if (PPS_AllowSendingData) then
	{
		ppsServerHelo = [_playerName, _playerUid];
		publicVariableServer "ppsServerHelo";
	};

	while {true} do
	{
		if (PPS_AllowSendingData) then
		{
			_timeInEvent = PPS_ValuesUpdateInterval;
			
			_stance = stance player;
			_timeStanceStand = 0;
			_timeStanceCrouch = 0;
			_timeStanceProne = 0;

			switch (_stance) do
			{
				case "STAND":
				{
					_timeStanceStand = PPS_ValuesUpdateInterval;
				};
				case "CROUCH":
				{
					_timeStanceCrouch = PPS_ValuesUpdateInterval;
				};
				case "PRONE":
				{
					_timeStanceProne = PPS_ValuesUpdateInterval;
				};
			};
			
			_speed = speed player;
			_timeSpeedStanding = 0;
			_timeSpeedWalking = 0;
			_timeSpeedRunning = 0;
			_timeSpeedSprinting = 0;
			
			if (vehicle player == player) then 
			{
				switch (true) do
				{
					case (_speed == 0):
					{
						_timeSpeedStanding = PPS_ValuesUpdateInterval;
					};
					case (_speed > 0 && _speed < 8):
					{
						_timeSpeedWalking = PPS_ValuesUpdateInterval;
					};
					case (_speed >= 8 && _speed < 15):
					{
						_timeSpeedRunning = PPS_ValuesUpdateInterval;
					};
					case (_speed >= 15):
					{
						_timeSpeedSprinting = PPS_ValuesUpdateInterval;
					};
				};
			};

			_timeMapVisible = 0;
			if (visibleMap) then
			{
				_timeMapVisible = PPS_ValuesUpdateInterval;
			};

			_timeGpsVisible = 0;
			if (visibleGPS) then
			{
				_timeGpsVisible = PPS_ValuesUpdateInterval;
			};
			
			_timeInVehicle = 0;
			_timeInVehicleCar = 0;
			_timeInVehicleTank = 0;
			_timeInVehicleTruck = 0;
			_timeInVehicleMotorcycle = 0;
			_timeInVehicleHelicopter = 0;
			_timeInVehiclePlane = 0;
			_timeInVehicleShip = 0;
			_timeInVehicleBoat = 0;
			_timeInVehicleSeatDriver = 0;
			_timeInVehicleSeatGunner = 0;
			_timeInVehicleSeatCommander = 0;
			_timeInVehicleSeatPassenger = 0;
			
			_vehiclePlayer = vehicle player;
			
			if (_vehiclePlayer != player) then 
			{
				_timeInVehicle = PPS_ValuesUpdateInterval;
				if (_vehiclePlayer isKindOf "Car") then {_timeInVehicleCar = PPS_ValuesUpdateInterval};
				if (_vehiclePlayer isKindOf "Tank") then {_timeInVehicleTank = PPS_ValuesUpdateInterval};
				if (_vehiclePlayer isKindOf "Truck") then {_timeInVehicleTruck = PPS_ValuesUpdateInterval};
				if (_vehiclePlayer isKindOf "Motorcycle") then {_timeInVehicleMotorcycle = PPS_ValuesUpdateInterval};
				if (_vehiclePlayer isKindOf "Helicopter") then {_timeInVehicleHelicopter = PPS_ValuesUpdateInterval};
				if (_vehiclePlayer isKindOf "Plane") then {_timeInVehiclePlane = PPS_ValuesUpdateInterval};
				if (_vehiclePlayer isKindOf "Ship") then {_timeInVehicleShip = PPS_ValuesUpdateInterval};
				if (_vehiclePlayer isKindOf "Boat") then {_timeInVehicleBoat = PPS_ValuesUpdateInterval};
				
				if ((driver _vehiclePlayer) == player) then {_timeInVehicleSeatDriver = PPS_ValuesUpdateInterval};
				if ((gunner _vehiclePlayer) == player) then {_timeInVehicleSeatGunner = PPS_ValuesUpdateInterval};
				//Mit assignedVehicleRole könnte man evtl. ermitteln falls es mehrere Gunenr gibt
				if ((commander _vehiclePlayer) == player) then {_timeInVehicleSeatCommander = PPS_ValuesUpdateInterval};
				if ((_timeInVehicleSeatDriver == 0) && (_timeInVehicleSeatGunner == 0) && (_timeInVehicleSeatCommander == 0)) then {_timeInVehicleSeatPassenger = PPS_ValuesUpdateInterval};
			};
			
			_timeWeaponLowered = 0;
			if (weaponLowered player) then
			{
				_timeWeaponLowered = PPS_ValuesUpdateInterval;
			};
			
			_updatedData = 
			[
				_playerName, _playerUid, _timeInEvent, 
				_timeStanceStand, _timeStanceCrouch, _timeStanceProne, 
				_timeSpeedStanding, _timeSpeedWalking, _timeSpeedRunning, _timeSpeedSprinting, 
				_timeMapVisible, _timeGpsVisible, _timeInVehicle, 
				_timeInVehicleCar, _timeInVehicleTank, _timeInVehicleTruck, 
				_timeInVehicleMotorcycle, _timeInVehicleHelicopter, _timeInVehiclePlane, 
				_timeInVehicleShip, _timeInVehicleBoat, _timeInVehicleSeatDriver, 
				_timeInVehicleSeatGunner, _timeInVehicleSeatCommander, _timeInVehicleSeatPassenger, 
				_timeWeaponLowered
			];
			_update = _playerUid + "-updateIntervalValues";
			missionNamespace setVariable [_update, _updatedData, false];
			publicVariableServer _update;
		};
		sleep PPS_ValuesUpdateInterval;
	};
};

addMissionEventHandler ["EntityRespawned",
{
	params ["_entity", "_corpse"];

	_playerUid = getPlayerUID _entity;

	if (_playerUid != "") then
	{
		//Eigentlich nicht mehr nötig
		//[_entity] spawn PPS_fnc_initUnit;
	};
}];