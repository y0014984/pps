_playerUid = getPlayerUID player;
_playerName = name player;

//hint "Function initPlayerUnit initialized";

/* ================================================================================ */

if (PPS_AllowSendingData) then
{
	_filter = "0123456789AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZzÜüÖöÄä[]-_.:#*(){}%$§&<>+-,;'~?= ";
	_playerName = [_playerName, _filter] call BIS_fnc_filterString;
	
	ppsServerHelo = [_playerName, _playerUid];
	publicVariableServer "ppsServerHelo";
	
	//hint "PPS_AllowSendingData enabled";

	/* ---------------------------------------- */

	_index = player addEventHandler ["FiredMan",
	{
		params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_vehicle"];
		
		//hint format ["Weapon: %1\nMuzzle: %2\nMode: %3\nAmmo: %4\nMagazine: %5", _weapon, _muzzle, _mode, _ammo, _magazine];
		
		_playerUid = getPlayerUID player;
		_section = "Event Handler Statistics";

		_key = "";
		_formatString = "";
		if (_weapon == "Throw") then
		{
			if ((_muzzle find "Grenade") > -1) then {_key = "countGrenadesThrown"; _formatString = "[A3] Count Grenades Thrown: %1";};
			if ((_muzzle find "SmokeShell") > -1) then {_key = "countSmokeShellsThrown"; _formatString = "[A3] Count Smoke Shells Thrown: %1";};
			if ((_muzzle find "Chemlight") > -1) then {_key = "countChemlightsThrown"; _formatString = "[A3] Count Chemlights Thrown: %1";};
			if (_key == "") then {_key = "countUnknownThrown"; _formatString = "[A3] Count Unknown Thrown: %1";};
		}
		else
		{
			_key = "countProjectilesFired";
			_formatString = "[A3] Count Projectiles Fired: %1";
		};
		
		_value = 1;
		_formatType = 0;
		
		_updatedData = [_playerUid, [[_section, _key, _value, _formatType, _formatString]]];
		_update = _playerUid + "-updateStatistics";
		missionNamespace setVariable [_update, _updatedData, false];
		publicVariableServer _update;			
	}];
	
	/* ---------------------------------------- */
	
	_addons = activatedAddons;
	if ((_addons find "ace_main") > -1) then 
	{
		["ace_cargoLoaded", 
			{
				params ["_item", "_vehicle"];

				_playerUid = getPlayerUID player;
				_section = "Event Handler Statistics";

				_key = "countAceCargoLoaded";
				_value = 1;
				_formatType = 0;
				_formatString = "[ACE] Count Cargo Loaded: %1";		
				
				_updatedData = [_playerUid, [[_section, _key, _value, _formatType, _formatString]]];
				_update = _playerUid + "-updateStatistics";
				missionNamespace setVariable [_update, _updatedData, false];
				publicVariableServer _update;	
			}
		] call CBA_fnc_addEventHandler;
		
		/* -------------------- */
		
		["ace_cargoUnloaded", 
			{
				params ["_item", "_vehicle"];

				_playerUid = getPlayerUID player;
				_section = "Event Handler Statistics";

				_key = "countAceCargoUnloaded";
				_value = 1;
				_formatType = 0;
				_formatString = "[ACE] Count Cargo Unloaded: %1";		
				
				_updatedData = [_playerUid, [[_section, _key, _value, _formatType, _formatString]]];
				_update = _playerUid + "-updateStatistics";
				missionNamespace setVariable [_update, _updatedData, false];
				publicVariableServer _update;	
			}
		] call CBA_fnc_addEventHandler;
		
		/* -------------------- */
		
		["ace_interactMenuOpened", 
			{
				params ["_menuType"];

				_playerUid = getPlayerUID player;
				_section = "Event Handler Statistics";

				_key = "countAceInteractMenuOpened";
				_value = 1;
				_formatType = 0;
				_formatString = "[ACE] Count Interact Menu Opened: %1";		
				
				_updatedData = [_playerUid, [[_section, _key, _value, _formatType, _formatString]]];
				_update = _playerUid + "-updateStatistics";
				missionNamespace setVariable [_update, _updatedData, false];
				publicVariableServer _update;	
			}
		] call CBA_fnc_addEventHandler;

		/* -------------------- */

		["ace_unconscious", 
			{
				params ["_unit", "_state"];

				_playerUid = getPlayerUID player;
				_unitUid = getPlayerUID _unit;
				
				if (_state && (_playerUid == _unitUid)) then
				{
					_section = "Event Handler Statistics";

					_key = "countAceUnconscious";
					_value = 1;
					_formatType = 0;
					_formatString = "[ACE] Count Unconscious: %1";		
					
					_updatedData = [_playerUid, [[_section, _key, _value, _formatType, _formatString]]];
					_update = _playerUid + "-updateStatistics";
					missionNamespace setVariable [_update, _updatedData, false];
					publicVariableServer _update;
				};
			}
		] call CBA_fnc_addEventHandler;
	};
	
	/* ---------------------------------------- */
	
	try
	{
		if ((_addons find "tfar_core") > -1) then 
		{
			waitUntil {time > 15};
			
			_tfarOnSpeakEh = ["ppsIsSpeaking", "OnSpeak", 
			{
				params ["_unit", "_isSpeaking"];
				
				/*
				hint format ["%1 is speaking %2", name _unit, _isSpeaking];
				systemChat format ["%1 is speaking %2", name _unit, _isSpeaking];
				[format ["%1 is speaking %2", name _unit, _isSpeaking]] call PPS_fnc_log;
				*/
				
				if (_isSpeaking) then
				{
					_playerUid = getPlayerUID _unit;
					
					_section = "Event Handler Statistics";

					_key = "countTfarIsSpeaking";
					_value = 1;
					_formatType = 0;
					_formatString = "[TFAR] Count Is Speaking: %1";		
					
					_updatedData = [_playerUid, [[_section, _key, _value, _formatType, _formatString]]];
					_update = _playerUid + "-updateStatistics";
					missionNamespace setVariable [_update, _updatedData, false];
					publicVariableServer _update;
				}
				
			}, player] call TFAR_fnc_addEventHandler;
			
			/* -------------------- */
			
			_tfarOnTangetEh = ["ppsUsesRadio", "OnTangent", 
			{
				params ["_unit", "_radio", "_isSW", "_keyDown"];
				
				/*
				hint format ["Unit: %1\nRadio: %2\nis SW: %3\nKey Down:%4", name _unit, _radio, _isSW, _keyDown];
				systemChat format ["Unit: %1\nRadio: %2\nis SW: %3\nKey Down:%4", name _unit, _radio, _isSW, _keyDown];
				[format ["Unit: %1\nRadio: %2\nis SW: %3\nKey Down:%4", name _unit, _radio, _isSW, _keyDown]] call PPS_fnc_log;
				*/
				
				//_keyDown ist bei mir immer false, daher 0.5 bei _value
				
				_playerUid = getPlayerUID _unit;
				
				_section = "Event Handler Statistics";

				_key = "countTfarUsesRadio";
				_value = 0.5;
				_formatType = 0;
				_formatString = "[TFAR] Count UsesRadio: %1";		
				
				_updatedData = [_playerUid, [[_section, _key, _value, _formatType, _formatString]]];
				_update = _playerUid + "-updateStatistics";
				missionNamespace setVariable [_update, _updatedData, false];
				publicVariableServer _update;
					
			}, player] call TFAR_fnc_addEventHandler;
		};
	}
	catch
	{
		hint format ["Fehler: %1", str _exception];
	};

	/* ---------------------------------------- */
	
	waitUntil {!isNull (findDisplay 46)};
	(findDisplay 46) displayAddEventHandler ["KeyUp", 
	{
		params ["_displayorcontrol", "_key", "_shift", "_ctrl", "_alt"];
		
		//hint format ["Key Up Event\n\Key: %1", _key];
		
		_playerUid = getPlayerUID player;
		_eventHandlerStatisticsSection = "Event Handler Statistics";
		
		_key = "";
		_value = 0;
		_formatType = 0;
		_formatString = "";
		
		if (inputAction "CuratorInterface" > 0) then 
		{
			_key = "countCuratorInterfaceOpened";
			_value = 1;
			_formatType = 0;
			_formatString = "[A3] Count Interface Zeus Opened: %1";
		};

		if (inputAction "Gear" > 0) then 
		{
			_key = "countGearInterfaceOpened";
			_value = 0.5;
			_formatType = 0;
			_formatString = "[A3] Count Interface Gear Opened: %1";
			
			//hint "Inventory opened";
		};
				
		if (inputAction "Compass" > 0) then 
		{
			_key = "countCompassInterfaceOpened";
			_value = 1;
			_formatType = 0;
			_formatString = "[A3] Count Interface Compass Opened: %1";
		};
		
		if (inputAction "Watch" > 0) then 
		{
			_key = "countWatchInterfaceOpened";
			_value = 1;
			_formatType = 0;
			_formatString = "[A3] Count Interface Watch Opened: %1";
		};
		
		if (inputAction "Binocular" > 0) then 
		{
			_key = "countBinocularUsed";
			_value = 0.5;
			_formatType = 0;
			_formatString = "[A3] Count Binocular used: %1";
		};
		if (inputAction "Optics" > 0) then 
		{
			_key = "countOpticsUsed";
			_value = 0.5;
			_formatType = 0;
			_formatString = "[A3] Count Optics used: %1";
		};
		if (inputAction "OpticsTemp" > 0) then 
		{
			_key = "countOpticsUsed";
			_value = 1;
			_formatType = 0;
			_formatString = "[A3] Count Optics used: %1";
		};
		if (inputAction "EngineToggle" > 0) then 
		{
			_key = "countEngineToggle";
			_value = 1;
			_formatType = 0;
			_formatString = "[A3] Count Engine Toggle: %1";
		};
		if (inputAction "ReloadMagazine" > 0) then 
		{
			_key = "countMagazineReloaded";
			_value = 1;
			_formatType = 0;
			_formatString = "[A3] Count Magazine Reloaded: %1";
		};
		if (inputAction "holdBreath" > 0) then 
		{
			_key = "countBreathHolded";
			_value = 1;
			_formatType = 0;
			_formatString = "[A3] Count Breath Holded: %1";
		};
		if (inputAction "ZoomTemp" > 0) then 
		{
			_key = "countZoomUsed";
			_value = 1;
			_formatType = 0;
			_formatString = "[A3] Count Zoom Used: %1";
		};
		if (inputAction "LeanLeft" > 0) then 
		{
			_key = "countLeanLeft";
			_value = 1;
			_formatType = 0;
			_formatString = "[A3] Count Lean Left: %1";
		};
		if (inputAction "LeanRight" > 0) then 
		{
			_key = "countLeanRight";
			_value = 1;
			_formatType = 0;
			_formatString = "[A3] Count Lean Right: %1";
		};
		if (inputAction "Salute" > 0) then 
		{
			_key = "countSalute";
			_value = 0.5;
			_formatType = 0;
			_formatString = "[A3] Count Salute: %1";
		};
		if (inputAction "SitDown" > 0) then 
		{
			_key = "countSitDown";
			_value = 0.5;
			_formatType = 0;
			_formatString = "[A3] Count Sit Down: %1";
		};
		if (inputAction "GetOver" > 0) then 
		{
			_key = "countGetOver";
			_value = 1;
			_formatType = 0;
			_formatString = "[A3] Count Get Over: %1";
		};
		if (_key != "") then
		{
			_updatedData = [_playerUid, [[_eventHandlerStatisticsSection, _key, _value, _formatType, _formatString]]];
			_update = _playerUid + "-updateStatistics";
			missionNamespace setVariable [_update, _updatedData, false];
			publicVariableServer _update;
		};
	}];
	
	/* ---------------------------------------- */
};

/* ================================================================================ */

while {true} do
{
	if (PPS_AllowSendingData) then
	{
		//hint format ["Speed: %1", speed player];
		
		_timeInEvent = PPS_ValuesUpdateInterval;
		
		_timeOnFoot = 0;
		_timeStandNoSpeed = 0;
		_timeCrouchNoSpeed = 0;
		_timeProneNoSpeed = 0;
		_timeStandLowSpeed = 0;
		_timeCrouchLowSpeed = 0;
		_timeProneLowSpeed = 0;
		_timeStandMidSpeed = 0;
		_timeCrouchMidSpeed = 0;
		_timeProneMidSpeed = 0;
		_timeStandHighSpeed = 0;
		_timeCrouchHighSpeed = 0;
		_timeProneHighSpeed = 0;
		
		_timeInVehicle = 0;
		_timeInVehicleEngineOn = 0;
		_timeInVehicleMoving = 0;
		_timeInVehicleFlying = 0;
		
		_timeCarDriver = 0;
		_timeCarGunner = 0;
		_timeCarCommander = 0;
		_timeCarPassenger = 0;
		_timeTankDriver = 0;
		_timeTankGunner = 0;
		_timeTankCommander = 0;
		_timeTankPassenger = 0;
		_timeTruckDriver = 0;
		_timeTruckGunner = 0;
		_timeTruckCommander = 0;
		_timeTruckPassenger = 0;
		_timeMotorcycleDriver = 0;
		_timeMotorcycleGunner = 0;
		_timeMotorcycleCommander = 0;
		_timeMotorcyclePassenger = 0;
		_timeHelicopterDriver = 0;
		_timeHelicopterGunner = 0;
		_timeHelicopterCommander = 0;
		_timeHelicopterPassenger = 0;
		_timePlaneDriver = 0;
		_timePlaneGunner = 0;
		_timePlaneCommander = 0;
		_timePlanePassenger = 0;
		_timeShipDriver = 0;
		_timeShipGunner = 0;
		_timeShipCommander = 0;
		_timeShipPassenger = 0;
		_timeBoatDriver = 0;
		_timeBoatGunner = 0;
		_timeBoatCommander = 0;
		_timeBoatPassenger = 0;
		
		_timeVehicleLightOn = 0;
		_timeVehicleLaser = 0;
		_timeVehicleCollisionLightOn = 0;
		_timeVehicleRadarOn = 0;
		
		_timeMapVisible = 0;
		_timeGpsVisible = 0;
		_timeCompassVisible = 0;
		_timeWatchVisible = 0;
		
		_timeVisionModeDay = 0;
		_timeVisionModeNight = 0;
		_timeVisionModeThermal = 0;
		
		_timeWeaponLowered = 0;
		_timeOnRoad = 0;
		_timeIrLaserOn = 0;
		_timeFlashlightOn = 0;
		
		_timeMagazineFull = 0;
		_timeMagazineFillHigh = 0;
		_timeMagazineFillMid = 0;
		_timeMagazineFillLow = 0;
		_timeMagazineEmpty = 0;
		
		_timeIsBleeding = 0;
		_timeIsBurning = 0;
		_timeInjuredNone = 0;
		_timeInjuredLow = 0;
		_timeInjuredMed = 0;
		_timeInjuredHigh = 0;
		_timeInjuredFull = 0;
		
		_timeIsMedic = 0;
		_timeIsEngineer = 0;
		_timeIsExplosiveSpecialist = 0;
		_timeIsUavHacker = 0;

		_timeAddonAceActive = 0;
		_timeAceIsBleeding = 0;
		_timeAddonTfarActive = 0;
		_timeTfarHasLrRadio = 0;
		_timeTfarHasSwRadio = 0;
		_timeTfarIsSpeaking = 0;
		_timeTfarSpeakVolumeNormal = 0;
		_timeTfarSpeakVolumeYelling = 0;
		_timeTfarSpeakVolumeWhispering = 0;

		_vehiclePlayer = vehicle player;
		_speed = speed player;
		
		if (_vehiclePlayer == player) then 
		{
			_timeOnFoot = PPS_ValuesUpdateInterval;
			
			_stance = stance player;
			
			switch (true) do
			{
				case ((_speed == 0) && (_stance == "STAND")):{_timeStandNoSpeed = PPS_ValuesUpdateInterval;};
				case ((_speed == 0) && (_stance == "CROUCH")):{_timeCrouchNoSpeed = PPS_ValuesUpdateInterval;};
				case ((_speed == 0) && (_stance == "PRONE")):{_timeProneNoSpeed = PPS_ValuesUpdateInterval;};
				case ((_speed > 0 && _speed < 8) && (_stance == "STAND")):{_timeStandLowSpeed = PPS_ValuesUpdateInterval;};
				case ((_speed > 0 && _speed < 8) && (_stance == "CROUCH")):{_timeCrouchLowSpeed = PPS_ValuesUpdateInterval;};
				case ((_speed > 0 && _speed < 2.5) && (_stance == "PRONE")):{_timeProneLowSpeed = PPS_ValuesUpdateInterval;};
				case ((_speed >= 8 && _speed < 15) && (_stance == "STAND")):{_timeStandMidSpeed = PPS_ValuesUpdateInterval;};
				case ((_speed >= 8 && _speed < 15) && (_stance == "CROUCH")):{_timeCrouchMidSpeed = PPS_ValuesUpdateInterval;};
				case ((_speed >= 2.5 && _speed < 4.8) && (_stance == "PRONE")):{_timeProneMidSpeed = PPS_ValuesUpdateInterval;};
				case ((_speed >= 15) && (_stance == "STAND")):{_timeStandHighSpeed = PPS_ValuesUpdateInterval;};
				case ((_speed >= 15) && (_stance == "CROUCH")):{_timeCrouchHighSpeed = PPS_ValuesUpdateInterval;};
				case ((_speed >= 4.8) && (_stance == "PRONE")):{_timeProneHighSpeed = PPS_ValuesUpdateInterval;};
			};
			
			if (weaponLowered player) then {_timeWeaponLowered = PPS_ValuesUpdateInterval;};
			if (player isIRLaserOn (currentWeapon player)) then {_timeIrLaserOn = PPS_ValuesUpdateInterval;};
			if (player isFlashlightOn (currentWeapon player)) then {_timeFlashlightOn = PPS_ValuesUpdateInterval;};
			
			_needReload = needReload player;
			switch (true) do
			{
				case (_needReload == 0):{_timeMagazineFull = PPS_ValuesUpdateInterval};
				case ((_needReload > 0) && (_needReload <= 0.33)):{_timeMagazineFillHigh = PPS_ValuesUpdateInterval};
				case ((_needReload > 0.33) && (_needReload <= 0.66)):{_timeMagazineFillMid = PPS_ValuesUpdateInterval};
				case ((_needReload > 0.66) && (_needReload < 1)):{_timeMagazineFillLow = PPS_ValuesUpdateInterval};
				case (_needReload == 1):{_timeMagazineEmpty = PPS_ValuesUpdateInterval};
			};
		}
		else
		{
			_timeInVehicle = PPS_ValuesUpdateInterval;
			
			if(isEngineOn _vehiclePlayer) then {_timeInVehicleEngineOn = PPS_ValuesUpdateInterval;};
			if(_speed > 0) then {_timeInVehicleMoving = PPS_ValuesUpdateInterval;};
			if(!isTouchingGround _vehiclePlayer) then {_timeInVehicleFlying = PPS_ValuesUpdateInterval;};
			
			switch (true) do
			{
				case ((_vehiclePlayer isKindOf "Car") && ((driver _vehiclePlayer) == player)):{_timeCarDriver = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Car") && ((gunner _vehiclePlayer) == player)):{_timeCarGunner = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Car") && ((commander _vehiclePlayer) == player)):{_timeCarCommander = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Car") && ((_vehiclePlayer getCargoIndex player) != -1)):{_timeCarPassenger = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Tank") && ((driver _vehiclePlayer) == player)):{_timeTankDriver = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Tank") && ((gunner _vehiclePlayer) == player)):{_timeTankGunner = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Tank") && ((commander _vehiclePlayer) == player)):{_timeTankCommander = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Tank") && ((_vehiclePlayer getCargoIndex player) != -1)):{_timeTankPassenger = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Truck") && ((driver _vehiclePlayer) == player)):{_timeTruckDriver = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Truck") && ((gunner _vehiclePlayer) == player)):{_timeTruckGunner = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Truck") && ((commander _vehiclePlayer) == player)):{_timeTruckCommander = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Truck") && ((_vehiclePlayer getCargoIndex player) != -1)):{_timeTruckPassenger = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Motorcycle") && ((driver _vehiclePlayer) == player)):{_timeMotorcycleDriver = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Motorcycle") && ((gunner _vehiclePlayer) == player)):{_timeMotorcycleGunner = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Motorcycle") && ((commander _vehiclePlayer) == player)):{_timeMotorcycleCommander = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Motorcycle") && ((_vehiclePlayer getCargoIndex player) != -1)):{_timeMotorcyclePassenger = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Helicopter") && ((driver _vehiclePlayer) == player)):{_timeHelicopterDriver = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Helicopter") && ((gunner _vehiclePlayer) == player)):{_timeHelicopterGunner = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Helicopter") && ((commander _vehiclePlayer) == player)):{_timeHelicopterCommander = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Helicopter") && ((_vehiclePlayer getCargoIndex player) != -1)):{_timeHelicopterPassenger = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Plane") && ((driver _vehiclePlayer) == player)):{_timePlaneDriver = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Plane") && ((gunner _vehiclePlayer) == player)):{_timePlaneGunner = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Plane") && ((commander _vehiclePlayer) == player)):{_timePlaneCommander = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Plane") && ((_vehiclePlayer getCargoIndex player) != -1)):{_timePlanePassenger = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Ship") && ((driver _vehiclePlayer) == player)):{_timeShipDriver = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Ship") && ((gunner _vehiclePlayer) == player)):{_timeShipGunner = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Ship") && ((commander _vehiclePlayer) == player)):{_timeShipCommander = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Ship") && ((_vehiclePlayer getCargoIndex player) != -1)):{_timeShipPassenger = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Boat") && ((driver _vehiclePlayer) == player)):{_timeBoatDriver = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Boat") && ((gunner _vehiclePlayer) == player)):{_timeBoatGunner = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Boat") && ((commander _vehiclePlayer) == player)):{_timeBoatCommander = PPS_ValuesUpdateInterval};
				case ((_vehiclePlayer isKindOf "Boat") && ((_vehiclePlayer getCargoIndex player) != -1)):{_timeBoatPassenger = PPS_ValuesUpdateInterval};
			};
			
			if (isLightOn (vehicle player)) then {_timeVehicleLightOn = PPS_ValuesUpdateInterval;};
			if (isLaserOn (vehicle player)) then {_timeVehicleLaser = PPS_ValuesUpdateInterval;};
			if (isCollisionLightOn (vehicle player)) then {_timeVehicleCollisionLightOn = PPS_ValuesUpdateInterval;};
			if (isVehicleRadarOn (vehicle player)) then {_timeVehicleRadarOn = PPS_ValuesUpdateInterval;};
		};
		
		if (visibleMap) then {_timeMapVisible = PPS_ValuesUpdateInterval;};
		if (visibleGPS) then {_timeGpsVisible = PPS_ValuesUpdateInterval;};
		if (visibleCompass) then {_timeCompassVisible = PPS_ValuesUpdateInterval;};
		if (visibleWatch) then {_timeWatchVisible = PPS_ValuesUpdateInterval;};
		
		_currentVisionMode = currentVisionMode player;
		switch (_currentVisionMode) do
		{
			case 0:{_timeVisionModeDay = PPS_ValuesUpdateInterval;};
			case 1:{_timeVisionModeNight = PPS_ValuesUpdateInterval;};
			case 2:{_timeVisionModeThermal = PPS_ValuesUpdateInterval;};
		};
		
		if (isOnRoad player) then {_timeOnRoad = PPS_ValuesUpdateInterval;};
		
		if (isBleeding player) then {_timeIsBleeding = PPS_ValuesUpdateInterval;};
		if (isBurning player) then {_timeIsBurning = PPS_ValuesUpdateInterval;};
		
		_damage = damage player;
		switch (true) do
		{
			case (_damage == 0):{_timeInjuredNone = PPS_ValuesUpdateInterval};
			case ((_damage > 0) && (_damage <= 0.33)):{_timeInjuredLow = PPS_ValuesUpdateInterval};
			case ((_damage > 0.33) && (_damage <= 0.66)):{_timeInjuredMed = PPS_ValuesUpdateInterval};
			case ((_damage > 0.66) && (_damage < 1)):{_timeInjuredHigh = PPS_ValuesUpdateInterval};
			case (_damage == 1):{_timeInjuredFull = PPS_ValuesUpdateInterval};
		};
	
		if (player getUnitTrait "Medic") then {_timeIsMedic = PPS_ValuesUpdateInterval;};
		if (player getUnitTrait "Engineer") then {_timeIsEngineer = PPS_ValuesUpdateInterval;};
		if (player getUnitTrait "ExplosiveSpecialist") then {_timeIsExplosiveSpecialist = PPS_ValuesUpdateInterval;};
		if (player getUnitTrait "UAVHacker") then {_timeIsUavHacker = PPS_ValuesUpdateInterval;};
		
		_addons = activatedAddons;
		/*
		_addons = activatedAddons;
		thirdPartyAddons = [];
		{if (([_x, 0, 2] call BIS_fnc_trimString) != "a3_") then {thirdPartyAddons = thirdPartyAddons + [_x];};} forEach _addons;
		thirdPartyAddons;
		["curatoronly_air_f_beta_heli_attack_01","curatoronly_air_f_beta_heli_attack_02","curatoronly_air_f_gamma_uav_01","curatoronly_armor_f_amv","curatoronly_armor_f_beta_apc_tracked_02","curatoronly_armor_f_marid","curatoronly_armor_f_panther","curatoronly_armor_f_slammer","curatoronly_armor_f_t100k","curatoronly_boat_f_boat_armed_01","curatoronly_characters_f_blufor","curatoronly_characters_f_common","curatoronly_characters_f_opfor","curatoronly_modules_f_curator_animals","curatoronly_modules_f_curator_chemlights","curatoronly_modules_f_curator_effects","curatoronly_modules_f_curator_environment","curatoronly_modules_f_curator_flares","curatoronly_modules_f_curator_lightning","curatoronly_modules_f_curator_mines","curatoronly_modules_f_curator_objectives","curatoronly_modules_f_curator_ordnance","curatoronly_modules_f_curator_smokeshells","curatoronly_signs_f","curatoronly_soft_f_crusher_ugv","curatoronly_soft_f_mrap_01","curatoronly_soft_f_mrap_02","curatoronly_soft_f_quadbike","curatoronly_static_f_gamma","curatoronly_static_f_mortar_01","curatoronly_structures_f_civ_ancient","curatoronly_structures_f_civ_camping","curatoronly_structures_f_civ_garbage","curatoronly_structures_f_epa_civ_constructions","curatoronly_structures_f_epb_civ_dead","curatoronly_structures_f_ind_cargo","curatoronly_structures_f_ind_crane","curatoronly_structures_f_ind_reservoirtank","curatoronly_structures_f_ind_transmitter_tower","curatoronly_structures_f_items_vessels","curatoronly_structures_f_mil_bagbunker","curatoronly_structures_f_mil_bagfence","curatoronly_structures_f_mil_cargo","curatoronly_structures_f_mil_fortification","curatoronly_structures_f_mil_radar","curatoronly_structures_f_mil_shelters","curatoronly_structures_f_research","curatoronly_structures_f_walls","curatoronly_structures_f_wrecks","map_vr","3den","ace_optionsmenu","ace_winddeflection","core","a3data","tfar_intercomdummy","cba_common","cba_events","cba_hashes","cba_jam","cba_jr_prep","cba_keybinding","cba_modules","cba_music","cba_network","cba_settings","cba_statemachine","cba_strings","cba_vectors","cba_xeh","cba_extended_eventhandlers","cba_ee","extended_eventhandlers","cba_xeh_a3","cba_accessory","mrt_accfncs","cba_ai","cba_arrays","cba_diagnostic","cba_disposable","cba_help","cba_jr","asdg_jointmuzzles","asdg_jointrails","cba_optics","cba_ui","cba_ui_helper","cba_versioning","ace_main","ace_medical_blood","ace_modules","cba_main","cba_main_a3","ace_apl","ace_common","ace_cookoff","ace_disposable","ace_finger","ace_flashsuppressors","ace_fonts","ace_frag","ace_gforces","ace_goggles","ace_grenades","ace_hitreactions","ace_huntir","ace_huntir_sub","ace_interact_menu","ace_interaction","ace_inventory","ace_laser","ace_laserpointer","ace_logistics_uavbattery","ace_logistics_wirecutter","ace_magazinerepack","ace_map","ace_map_gestures","ace_maptools","ace_markers","ace_medical","ace_medical_ai","ace_medical_menu","ace_microdagr","ace_missileguidance","ace_missionmodules","ace_mk6mortar","ace_movement","ace_mx2a","ace_nametags","ace_nightvision","ace_nlaw","ace_noidle","ace_noradio","ace_norearm","ace_optics","ace_overheating","ace_overpressure","ace_parachute","ace_pylons","ace_quickmount","ace_realisticnames","ace_realisticweights","ace_rearm","ace_recoil","ace_refuel","ace_reload","ace_reloadlaunchers","ace_repair","ace_respawn","ace_safemode","ace_sandbag","ace_scopes","ace_slideshow","ace_smallarms","ace_spectator","ace_spottingscope","ace_switchunits","ace_tacticalladder","ace_tagging","ace_thermals","ace_trenches","ace_tripod","ace_ui","ace_vector","ace_vehiclelock","ace_vehicles","ace_viewdistance","ace_weaponselect","ace_weather","ace_yardage450","tfar_core","task_force_radio","task_force_radio_items","tfar_static_radios","pps_main","ace_advanced_fatigue","ace_advanced_throwing","ace_ai","ace_aircraft","ace_arsenal","ace_attach","ace_backpacks","ace_ballistics","ace_captives","ace_cargo","ace_chemlights","ace_concertina_wire","ace_dagr","ace_disarming","ace_dogtags","ace_dragging","ace_explosives","ace_fastroping","ace_fcs","ace_flashlights","ace_gestures","ace_gunbag","ace_hearing","ace_hellfire","ace_hot","ace_javelin","ace_kestrel4500","ace_maverick","ace_minedetector","ace_zeus","ace_zeus_captives","ace_zeus_medical","ace_zeus_cargo","ace_zeus_repair","ace_zeus_cargoandrepair","ace_zeus_fastroping","ace_zeus_pylons","ace_zeus_arsenal","tfar_ai_hearing","tfar_antennas","tfar_backpacks","tfar_handhelds","ace_advanced_ballistics","ace_atragmx","ace_rangecard"]
		*/
		if ((_addons find "ace_main") > -1) then
		{
			_timeAddonAceActive = PPS_ValuesUpdateInterval;
			
			if([player] call ace_medical_blood_fnc_isBleeding) then {_timeAceIsBleeding = PPS_ValuesUpdateInterval;};
		};
		if ((_addons find "tfar_core") > -1) then 
		{
			_timeAddonTfarActive = PPS_ValuesUpdateInterval;
			try
			{
				_activeLrRadio = player call TFAR_fnc_backpackLR;
				if (!isNil "_activeLrRadio") then {_timeTfarHasLrRadio = PPS_ValuesUpdateInterval;};
				if (call TFAR_fnc_haveSWRadio) then {_timeTfarHasSwRadio = PPS_ValuesUpdateInterval;};
				if (player call TFAR_fnc_isSpeaking) then {_timeTfarIsSpeaking = PPS_ValuesUpdateInterval;};
				switch (TF_speak_volume_level) do
				{
					case "normal":{_timeTfarSpeakVolumeNormal = PPS_ValuesUpdateInterval;};
					case "yelling":{_timeTfarSpeakVolumeYelling = PPS_ValuesUpdateInterval;};
					case "whispering":{_timeTfarSpeakVolumeWhispering = PPS_ValuesUpdateInterval;};
				};
			}
			catch
			{
				hint format ["Fehler: %1", str _exception];
			};
		};
		
		_filter = "0123456789AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZzÜüÖöÄä[]-_.:#*(){}%$§&<>+-,;'~?= ";
		_playerName = [_playerName, _filter] call BIS_fnc_filterString;

		_globalInformationsSection = "Global Informations";
		_intervalStatisticsSection = "Interval Statistics";
		
		_updatedData = 
		[
			_playerUid,
			[
				[_globalInformationsSection, "playerName", _playerName, 0, "Player Name: %1"],  
				[_globalInformationsSection, "playerUid", _playerUid, 0, "Player UID: %1"],  
				[_intervalStatisticsSection, "timeInEvent", _timeInEvent, 3, "Time in Event: %1 hrs"],  
				[_intervalStatisticsSection, "timeOnFoot", _timeOnFoot, 1, "[A3] Time On Foot: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeStandNoSpeed", _timeStandNoSpeed, 1, "[A3] Time Stand No Speed: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeCrouchNoSpeed", _timeCrouchNoSpeed, 1, "[A3] Time Crouch No Speed: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeProneNoSpeed", _timeProneNoSpeed, 1, "[A3] Time Prone No Speed: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeStandLowSpeed", _timeStandLowSpeed, 1, "[A3] Time Stand Low Speed: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeCrouchLowSpeed", _timeCrouchLowSpeed, 1, "[A3] Time Crouch Low Speed: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeProneLowSpeed", _timeProneLowSpeed, 1, "[A3] Time Prone Low Speed: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeStandMidSpeed", _timeStandMidSpeed, 1, "[A3] Time Stand Mid Speed: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeCrouchMidSpeed", _timeCrouchMidSpeed, 1, "[A3] Time Crouch Mid Speed: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeProneMidSpeed", _timeProneMidSpeed, 1, "[A3] Time Prone Mid Speed: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeStandHighSpeed", _timeStandHighSpeed, 1, "[A3] Time Stand High Speed: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeCrouchHighSpeed", _timeCrouchHighSpeed, 1, "[A3] Time Crouch High Speed: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeProneHighSpeed", _timeProneHighSpeed, 1, "[A3] Time Prone High Speed: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeInVehicle", _timeInVehicle, 1, "[A3] Time In Vehicle: %2 hrs (%3%1)"], 
				[_intervalStatisticsSection, "timeInVehicleEngineOn", _timeInVehicleEngineOn, 1, "[A3] Time In Vehicle Engine On: %2 hrs (%3%1)"], 
				[_intervalStatisticsSection, "timeInVehicleMoving", _timeInVehicleMoving, 1, "[A3] Time In Vehicle Moving: %2 hrs (%3%1)"], 
				[_intervalStatisticsSection, "timeInVehicleFlying", _timeInVehicleFlying, 1, "[A3] Time In Vehicle Flying: %2 hrs (%3%1)"], 
				[_intervalStatisticsSection, "timeCarDriver", _timeCarDriver, 1, "[A3] Time Car Driver: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeCarGunner", _timeCarGunner, 1, "[A3] Time Car Gunner: %2 hrs (%3%1)"], 
				[_intervalStatisticsSection, "timeCarCommander", _timeCarCommander, 1, "[A3] Time Car Commander: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeCarPassenger", _timeCarPassenger, 1, "[A3] Time Car Passenger: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeTankDriver", _timeTankDriver, 1, "[A3] Time Tank Driver: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeTankGunner", _timeTankGunner, 1, "[A3] Time Tank Gunner: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeTankCommander", _timeTankCommander, 1, "[A3] Time Tank Commander: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeTankPassenger", _timeTankPassenger, 1, "[A3] Time Tank Passenger: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeTruckDriver", _timeTruckDriver, 1, "[A3] Time Truck Driver: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeTruckGunner", _timeTruckGunner, 1, "[A3] Time Truck Gunner: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeTruckCommander", _timeTruckCommander, 1, "[A3] Time Truck Commander: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeTruckPassenger", _timeTruckPassenger, 1, "[A3] Time Truck Passenger: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeMotorcycleDriver", _timeMotorcycleDriver, 1, "[A3] Time Motorcycle Driver: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeMotorcycleGunner", _timeMotorcycleGunner, 1, "[A3] Time Motorcycle Gunner: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeMotorcycleCommander", _timeMotorcycleCommander, 1, "[A3] Time Motorcycle Commander: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeMotorcyclePassenger", _timeMotorcyclePassenger, 1, "[A3] Time Motorcycle Passenger: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeHelicopterDriver", _timeHelicopterDriver, 1, "[A3] Time Helicopter Driver: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeHelicopterGunner", _timeHelicopterGunner, 1, "[A3] Time Helicopter Gunner: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeHelicopterCommander", _timeHelicopterCommander, 1, "[A3] Time Helicopter Commander: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeHelicopterPassenger", _timeHelicopterPassenger, 1, "[A3] Time Helicopter Passenger: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timePlaneDriver", _timePlaneDriver, 1, "[A3] Time Plane Driver: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timePlaneGunner", _timePlaneGunner, 1, "[A3] Time Plane Gunner: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timePlaneCommander", _timePlaneCommander, 1, "[A3] Time Plane Commander: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timePlanePassenger", _timePlanePassenger, 1, "[A3] Time Plane Passenger: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeShipDriver", _timeShipDriver, 1, "[A3] Time Ship Driver: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeShipGunner", _timeShipGunner, 1, "[A3] Time Ship Gunner: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeShipCommander", _timeShipCommander, 1, "[A3] Time Ship Commander: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeShipPassenger", _timeShipPassenger, 1, "[A3] Time Ship Passenger: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeBoatDriver", _timeBoatDriver, 1, "[A3] Time Boat Driver: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeBoatGunner", _timeBoatGunner, 1, "[A3] Time Boat Gunner: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeBoatCommander", _timeBoatCommander, 1, "[A3] Time Boat Commander: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeBoatPassenger", _timeBoatPassenger, 1, "[A3] Time Boat Passenger: %2 hrs (%3%1)"],
				[_intervalStatisticsSection, "timeVehicleLightOn", _timeVehicleLightOn, 1, "[A3] Time Vehicle Light On: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeVehicleLaser", _timeVehicleLaser, 1, "[A3] Time Vehicle Laser On: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeVehicleCollisionLightOn", _timeVehicleCollisionLightOn, 1, "[A3] Time Vehicle Collision Light On: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeVehicleRadarOn", _timeVehicleRadarOn, 1, "[A3] Time Vehicle Radar On: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeMapVisible", _timeMapVisible, 1, "[A3] Time Map Visible: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeGpsVisible", _timeGpsVisible, 1, "[A3] Time Gps Visible: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeCompassVisible", _timeCompassVisible, 1, "[A3] Time Compass Visible: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeWatchVisible", _timeWatchVisible, 1, "[A3] Time Watch Visible: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeVisionModeDay", _timeVisionModeDay, 1, "[A3] Time Vision Mode Day: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeVisionModeNight", _timeVisionModeNight, 1, "[A3] Time Vision Mode Night: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeVisionModeThermal", _timeVisionModeThermal, 1, "[A3] Time Vision Mode Thermal: %2 hrs (%3%1)"],  
				[_intervalStatisticsSection, "timeWeaponLowered", _timeWeaponLowered, 1, "[A3] Time Weapon Lowered: %2 hrs (%3%1)"], 
				[_intervalStatisticsSection, "timeOnRoad", _timeOnRoad, 1, "[A3] Time On Road: %2 hrs (%3%1)"], 
				[_intervalStatisticsSection, "timeIsBleeding", _timeIsBleeding, 1, "[A3] Time Is Bleeding: %2 hrs (%3%1)"], 
				[_intervalStatisticsSection, "timeIsBurning", _timeIsBurning, 1, "[A3] Time Is Burning: %2 hrs (%3%1)"], 
				[_intervalStatisticsSection, "timeInjuredNone", _timeInjuredNone, 1, "[A3] Time Injured None: %2 hrs (%3%1)"], 
				[_intervalStatisticsSection, "timeInjuredLow", _timeInjuredLow, 1, "[A3] Time Infured Low: %2 hrs (%3%1)"], 
				[_intervalStatisticsSection, "timeInjuredMed", _timeInjuredMed, 1, "[A3] Time Injured Med: %2 hrs (%3%1)"], 
				[_intervalStatisticsSection, "timeInjuredHigh", _timeInjuredHigh, 1, "[A3] Time Injured High: %2 hrs (%3%1)"], 
				[_intervalStatisticsSection, "timeInjuredFull", _timeInjuredFull, 1, "[A3] Time Injured Full: %2 hrs (%3%1)"], 
				[_intervalStatisticsSection, "timeIrLaserOn", _timeIrLaserOn, 1, "[A3] Time IR Laser On: %2 hrs (%3%1)"], 
				[_intervalStatisticsSection, "timeFlashlightOn", _timeFlashlightOn, 1, "[A3] Time Flashlight On: %2 hrs (%3%1)"], 
				[_intervalStatisticsSection, "timeMagazineFull", _timeMagazineFull, 1, "[A3] Time Magazine Full: %2 hrs (%3%1)"], 
				[_intervalStatisticsSection, "timeMagazineFillHigh", _timeMagazineFillHigh, 1, "[A3] Time Magazine Fill High: %2 hrs (%3%1)"], 
				[_intervalStatisticsSection, "timeMagazineFillMid", _timeMagazineFillMid, 1, "[A3] Time Magazine Fill Med: %2 hrs (%3%1)"], 
				[_intervalStatisticsSection, "timeMagazineFillLow", _timeMagazineFillLow, 1, "[A3] Time Magazine Fill Low: %2 hrs (%3%1)"], 
				[_intervalStatisticsSection, "timeMagazineEmpty", _timeMagazineEmpty, 1, "[A3] Time Magazine Empty: %2 hrs (%3%1)"], 
				[_intervalStatisticsSection, "timeIsMedic", _timeIsMedic, 1, "[A3] Time Is Medic: %2 hrs (%3%1)"], 
				[_intervalStatisticsSection, "timeIsEngineer", _timeIsEngineer, 1, "[A3] Time Is Engineer: %2 hrs (%3%1)"], 
				[_intervalStatisticsSection, "timeIsExplosiveSpecialist", _timeIsExplosiveSpecialist, 1, "[A3] Time Is Explosive Specialist: %2 hrs (%3%1)"], 
				[_intervalStatisticsSection, "timeIsUavHacker", _timeIsUavHacker, 1, "[A3] Time Is UAV Hacker: %2 hrs (%3%1)"], 
				[_intervalStatisticsSection, "timeAddonAceActive", _timeAddonAceActive, 1, "[ACE] Time Addon Ace Active: %2 hrs (%3%1)"], 
				[_intervalStatisticsSection, "timeAceIsBleeding", _timeAceIsBleeding, 1, "[ACE] Time Is Bleeding: %2 hrs (%3%1)"], 
				[_intervalStatisticsSection, "timeAddonTfarActive", _timeAddonTfarActive, 1, "[TFAR] Time Addon Tfar Active: %2 hrs (%3%1)"],
				[_intervalStatisticsSection, "timeTfarHasLrRadio", _timeTfarHasLrRadio, 1, "[TFAR] Time Tfar Has LR Radio: %2 hrs (%3%1)"],
				[_intervalStatisticsSection, "timeTfarHasSwRadio", _timeTfarHasSwRadio, 1, "[TFAR] Time Tfar Has SW Radio: %2 hrs (%3%1)"],
				[_intervalStatisticsSection, "timeTfarIsSpeaking", _timeTfarIsSpeaking, 1, "[TFAR] Time Tfar Is Speaking: %2 hrs (%3%1)"],
				[_intervalStatisticsSection, "timeTfarSpeakVolumeNormal", _timeTfarSpeakVolumeNormal, 1, "[TFAR] Time Tfar Speak Volume Normal: %2 hrs (%3%1)"],
				[_intervalStatisticsSection, "timeTfarSpeakVolumeYelling", _timeTfarSpeakVolumeYelling, 1, "[TFAR] Time Tfar Speak Volume Yelling: %2 hrs (%3%1)"],
				[_intervalStatisticsSection, "timeTfarSpeakVolumeWhispering", _timeTfarSpeakVolumeWhispering, 1, "[TFAR] Time Tfar Speak Volume Whispering: %2 hrs (%3%1)"]
			]
		];
		
		_update = _playerUid + "-updateStatistics";
		missionNamespace setVariable [_update, _updatedData, false];
		publicVariableServer _update;
	};
	sleep PPS_ValuesUpdateInterval;
};

/* ================================================================================ */
