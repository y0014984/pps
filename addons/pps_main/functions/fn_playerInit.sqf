/*
 * Author: y0014984
 *
 * Initializes player objects, adds event handlers and communicates with server. Local statistics collection.
 * Runs in infinite loop.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call PPS_fnc_playerInit;
 *
 * Public: No
 */

_playerUid = getPlayerUID player;
_playerName = name player;

/* ================================================================================ */

if (PPS_AllowSendingData) then
{
	_filter = "0123456789AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZzÜüÖöÄä[]-_.:#*(){}%$§&<>+-,;'~?= ";
	_playerName = [_playerName, _filter] call BIS_fnc_filterString;
	
	ppsServerHelo = [_playerName, _playerUid];
	publicVariableServer "ppsServerHelo";
	
	/* ---------------------------------------- */
	
	_index = player addEventHandler ["Respawn",
	{
		params ["_unit", "_corpse"];
		
		//hint format ["Respawn Event Handler\n\n_unit: %1\n_corpse: %2", _unit, _corpse];
		
		if ((local _unit) && PPS_AllowSendingData && PPS_SendingGeneralData) then
		{
			_playerUid = getPlayerUID player;
			_key = "countRespawn";
			_value = 1;
			_type = 2;
			_formatType = 0;
			_formatString = "STR_PPS_Main_Statistics_Count_Respawn";
			_source = "A3";

			_updatedData = [_playerUid, [[_key, _value, _type, _formatType, _formatString, _source]]];
			_update = _playerUid + "-updateStatistics";
			missionNamespace setVariable [_update, _updatedData, false];
			publicVariableServer _update;
		};
		
		//[] call PPS_fnc_unitEventHandlerHitPartAdd;
		[] call PPS_fnc_unitEventHandlerHitAdd;
	}];
	
	[format ["[%1] PPS Event Handler 'Respawn' added to Player: (%2)", serverTime, _playerUid]] call PPS_fnc_log;

	/* ---------------------------------------- */

	_index = player addEventHandler ["InventoryOpened",
	{
		params ["_unit", "_container"];
		
		//hint format ["InventoryOpened Event Handler\n\n_unit: %1\n_container: %2", _unit, _container];
	
		if (local _unit) then
		{
			PPS_ehInventoryOpen = true;
			
			if (PPS_AllowSendingData && PPS_SendingGeneralData) then
			{
				_playerUid = getPlayerUID player;
				_key = "countInventoryInterfaceOpened";
				_value = 1;
				_type = 2;
				_formatType = 0;
				_formatString = "STR_PPS_Main_Statistics_Count_Interface_Gear_Opened";
				_source = "A3";
				
				_updatedData = [_playerUid, [[_key, _value, _type, _formatType, _formatString, _source]]];
				_update = _playerUid + "-updateStatistics";
				missionNamespace setVariable [_update, _updatedData, false];
				publicVariableServer _update;
			};
		};
	}];
	
	[format ["[%1] PPS Event Handler 'InventoryOpened' added to Player: (%2)", serverTime, _playerUid]] call PPS_fnc_log;
	
	/* ---------------------------------------- */

	_index = player addEventHandler ["InventoryClosed",
	{
		params ["_unit", "_container"];
		
		//hint format ["InventoryClosed Event Handler\n\n_unit: %1\n_container: %2", _unit, _container];
	
		if (local _unit) then
		{
			PPS_ehInventoryOpen = false;
		};
	}];
	
	[format ["[%1] PPS Event Handler 'InventoryClosed' added to Player: (%2)", serverTime, _playerUid]] call PPS_fnc_log;

	/* ---------------------------------------- */
	
	_index = player addEventHandler ["Reloaded", 
	{
		params ["_unit", "_weapon", "_muzzle", "_newmag", ["_oldmag", ["","","",""]]];
		
		/*
		hint format ["Weapon: %1\nMuzzle: %2\n\n- New Magazine -\nName: %3\nAmmo: %4\nID: %5\nCreator: %6\n\n- Old Magazine -\nName: %7\nAmmo: %8\nID: %9\nCreator: %10", 
			_weapon, 
			_muzzle, 
			_newmag select 0, 
			_newmag select 1, 
			(_newmag select 2) - 1e+007, 
			_newmag select 3,
			_oldmag select 0, 
			_oldmag select 1, 
			if (_oldmag select 2 isEqualType "") then {""} else {(_oldmag select 2) - 1e+007}, 
			_oldmag select 3
		];
		*/
		
		if ((local _unit) && PPS_AllowSendingData && PPS_SendingInfantryData) then
		{
			_playerUid = getPlayerUID _unit;
			_key = "countMagazineReloaded";
			_value = 1;
			_type = 2;
			_formatType = 0;
			_formatString = "STR_PPS_Main_Statistics_Count_Magazine_Reloaded";
			_source = "A3";

			_updatedData = [_playerUid, [[_key, _value, _type, _formatType, _formatString, _source]]];
			_update = _playerUid + "-updateStatistics";
			missionNamespace setVariable [_update, _updatedData, false];
			publicVariableServer _update;
			
			[format ["[%1] PPS Event Handler 'Reloaded' fired: (%2)", serverTime, _playerUid]] call PPS_fnc_log;
		};
	}];
	
	[format ["[%1] PPS Event Handler 'Reloaded' added to Player: (%2)", serverTime, _playerUid]] call PPS_fnc_log;
	
	/* ---------------------------------------- */

	_index = player addEventHandler ["FiredMan",
	{
		params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_vehicle"];
		
		//hint format ["Weapon: %1\nMuzzle: %2\nMode: %3\nAmmo: %4\nMagazine: %5", _weapon, _muzzle, _mode, _ammo, _magazine];
		
		if ((local _unit) && PPS_AllowSendingData && PPS_SendingInfantryData) then
		{
			_playerUid = getPlayerUID player;
			_source = "A3";
			_type = 2;

			_key = "";
			_formatString = "";
			if (_weapon == "Throw") then
			{
				if ((_muzzle find "Grenade") > -1) then {_key = "countGrenadesThrown"; _formatString = "STR_PPS_Main_Statistics_Count_Grenades_Thrown";};
				if ((_muzzle find "SmokeShell") > -1) then {_key = "countSmokeShellsThrown"; _formatString = "STR_PPS_Main_Statistics_Count_Smoke_Shells_Thrown";};
				if ((_muzzle find "Chemlight") > -1) then {_key = "countChemlightsThrown"; _formatString = "STR_PPS_Main_Statistics_Count_Chemlights_Thrown";};
				if (_key == "") then {_key = "countUnknownThrown"; _formatString = "STR_PPS_Main_Statistics_Count_Unknown_Thrown";};
			}
			else
			{
				_key = "countProjectilesFired";
				_formatString = "STR_PPS_Main_Statistics_Count_Projectiles_Fired";
			};
			
			_value = 1;
			_formatType = 0;
			
			_updatedData = [_playerUid, [[_key, _value, _type, _formatType, _formatString, _source]]];
			_update = _playerUid + "-updateStatistics";
			missionNamespace setVariable [_update, _updatedData, false];
			publicVariableServer _update;
		};
	}];
	
	[format ["[%1] PPS Event Handler 'FiredMan' added to Player: (%2)", serverTime, _playerUid]] call PPS_fnc_log;
	
	/* ---------------------------------------- */
	
	_addons = activatedAddons;
	if ((_addons find "ace_main") > -1) then 
	{
		/*
			Cargo Load/Unload Event Handler are not unit specific but event/mission specific. So they can't be used.
		/*
		["ace_cargoLoaded", 
			{
				params ["_item", "_vehicle"];

				if (PPS_AllowSendingData && PPS_SendingAddonData) then
				{
					_playerUid = getPlayerUID player;
					_source = "ACE";
					_type = 2;

					_key = "countAceCargoLoaded";
					_value = 1;
					_formatType = 0;
					_formatString = "STR_PPS_Main_Statistics_Count_Cargo_Loaded";		
					
					_updatedData = [_playerUid, [[_key, _value, _type, _formatType, _formatString, _source]]];
					_update = _playerUid + "-updateStatistics";
					missionNamespace setVariable [_update, _updatedData, false];
					publicVariableServer _update;
				};
			}
		] call CBA_fnc_addEventHandler;
		*/
		
		/* -------------------- */
		
		/*
		["ace_cargoUnloaded", 
			{
				params ["_item", "_vehicle"];

				if (PPS_AllowSendingData && PPS_SendingAddonData) then
				{
					_playerUid = getPlayerUID player;
					_source = "ACE";
					_type = 2;

					_key = "countAceCargoUnloaded";
					_value = 1;
					_formatType = 0;
					_formatString = "STR_PPS_Main_Statistics_Count_Cargo_Unloaded";		
					
					_updatedData = [_playerUid, [[_key, _value, _type, _formatType, _formatString, _source]]];
					_update = _playerUid + "-updateStatistics";
					missionNamespace setVariable [_update, _updatedData, false];
					publicVariableServer _update;
				};
			}
		] call CBA_fnc_addEventHandler;
		*/
		
		/* -------------------- */
		
		["ace_interactMenuOpened", 
			{
				params ["_menuType"];

				if (PPS_AllowSendingData && PPS_SendingAddonData) then
				{
					_playerUid = getPlayerUID player;
					_source = "ACE";
					_type = 2;

					_key = "countAceInteractMenuOpened";
					_value = 1;
					_formatType = 0;
					_formatString = "STR_PPS_Main_Statistics_Count_Interact_Menu_Opened";		
					
					_updatedData = [_playerUid, [[_key, _value, _type, _formatType, _formatString, _source]]];
					_update = _playerUid + "-updateStatistics";
					missionNamespace setVariable [_update, _updatedData, false];
					publicVariableServer _update;
				};
			}
		] call CBA_fnc_addEventHandler;

		/* -------------------- */

		["ace_unconscious", 
			{
				params ["_unit", "_state"];

				if (PPS_AllowSendingData && PPS_SendingAddonData) then
				{
					_playerUid = getPlayerUID player;
					_unitUid = getPlayerUID _unit;
					
					if ((local _unit) && _state && (_playerUid == _unitUid)) then
					{
						_source = "ACE";
						_type = 2;

						_key = "countAceUnconscious";
						_value = 1;
						_formatType = 0;
						_formatString = "STR_PPS_Main_Statistics_Count_Unconscious";		
						
						_updatedData = [_playerUid, [[_key, _value, _type, _formatType, _formatString, _source]]];
						_update = _playerUid + "-updateStatistics";
						missionNamespace setVariable [_update, _updatedData, false];
						publicVariableServer _update;
					};
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
			
			_playerUid = getPlayerUID player;
			
			_tfarOnSpeakEh = ["ppsIsSpeaking", "OnSpeak", 
			{
				params ["_unit", "_isSpeaking"];
				
				/*
				hint format ["%1 is speaking %2", name _unit, _isSpeaking];
				systemChat format ["%1 is speaking %2", name _unit, _isSpeaking];
				[format ["%1 is speaking %2", name _unit, _isSpeaking]] call PPS_fnc_log;
				*/

				if ((local _unit) && PPS_AllowSendingData && PPS_SendingAddonData) then
				{
					if (_isSpeaking) then
					{
						_playerUid = getPlayerUID _unit;
						
						_source = "TFAR";
						_type = 2;

						_key = "countTfarIsSpeaking";
						_value = 1;
						_formatType = 0;
						_formatString = "STR_PPS_Main_Statistics_Count_Is_Speaking";
						
						_updatedData = [_playerUid, [[_key, _value, _type, _formatType, _formatString, _source]]];
						_update = _playerUid + "-updateStatistics";
						missionNamespace setVariable [_update, _updatedData, false];
						publicVariableServer _update;
					};
				};
			}, player] call TFAR_fnc_addEventHandler;
			
			[format ["[%1] PPS Event Handler 'OnSpeak' added to Player: (%2)", serverTime, _playerUid]] call PPS_fnc_log;
			
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
				
				if ((local _unit) && PPS_AllowSendingData && PPS_SendingAddonData) then
				{
					_playerUid = getPlayerUID _unit;
					
					_source = "TFAR";
					_type = 2;

					_key = "countTfarUsesRadio";
					_value = 0.5;
					_formatType = 0;
					_formatString = "STR_PPS_Main_Statistics_Count_Uses_Radio";	
					
					_updatedData = [_playerUid, [[_key, _value, _type, _formatType, _formatString, _source]]];
					_update = _playerUid + "-updateStatistics";
					missionNamespace setVariable [_update, _updatedData, false];
					publicVariableServer _update;
				};
			}, player] call TFAR_fnc_addEventHandler;
			
			[format ["[%1] PPS Event Handler 'OnTangent' added to Player: (%2)", serverTime, _playerUid]] call PPS_fnc_log;
		};
	}
	catch
	{
		hint format [localize "STR_PPS_Main_Error", str _exception];
	};

	/* ---------------------------------------- */
	
	waitUntil {!isNull (findDisplay 46)};
	(findDisplay 46) displayAddEventHandler ["KeyUp", 
	{
		params ["_displayorcontrol", "_key", "_shift", "_ctrl", "_alt"];
		
		//hint format ["Key Up Event\n\Key: %1", _key];
		
		_playerUid = getPlayerUID player;
		_source = "A3";
		_type = 2;
		
		_key = "";
		_value = 0;
		_formatType = 0;
		_formatString = "";
		
		if ((inputAction "CuratorInterface" > 0) && PPS_AllowSendingData && PPS_SendingGeneralData) then 
		{
			_playerUid = getPlayerUID player;
			{
				if (getPlayerUID getAssignedCuratorUnit _x == _playerUid) then
				{
					_key = "countCuratorInterfaceOpened";
					_value = 1;
					_formatType = 0;
					_formatString = "STR_PPS_Main_Statistics_Count_Interface_Zeus_Opened";
				};
			} forEach allCurators;
		};
				
		if ((inputAction "Compass" > 0) && PPS_AllowSendingData && PPS_SendingGeneralData) then 
		{
			_key = "countCompassInterfaceOpened";
			_value = 1;
			_formatType = 0;
			_formatString = "STR_PPS_Main_Statistics_Count_Interface_Compass_Opened";
		};
		
		if ((inputAction "Watch" > 0) && PPS_AllowSendingData && PPS_SendingGeneralData) then 
		{
			_key = "countWatchInterfaceOpened";
			_value = 1;
			_formatType = 0;
			_formatString = "STR_PPS_Main_Statistics_Count_Interface_Watch_Opened";
		};
		
		if ((inputAction "Binocular" > 0) && PPS_AllowSendingData && PPS_SendingGeneralData) then 
		{
			_key = "countBinocularUsed";
			_value = 0.5;
			_formatType = 0;
			_formatString = "STR_PPS_Main_Statistics_Count_Binocular_Used";
		};
		if ((inputAction "Optics" > 0) && PPS_AllowSendingData && PPS_SendingGeneralData) then 
		{
			_key = "countOpticsUsed";
			_value = 0.5;
			_formatType = 0;
			_formatString = "STR_PPS_Main_Statistics_Count_Optics_Used";
		};
		if ((inputAction "OpticsTemp" > 0) && PPS_AllowSendingData && PPS_SendingGeneralData) then 
		{
			_key = "countOpticsUsed";
			_value = 1;
			_formatType = 0;
			_formatString = "STR_PPS_Main_Statistics_Count_Optics_Used";
		};
		if ((inputAction "holdBreath" > 0) && PPS_AllowSendingData && PPS_SendingInfantryData) then 
		{
			_key = "countBreathHolded";
			_value = 1;
			_formatType = 0;
			_formatString = "STR_PPS_Main_Statistics_Count_Breath_Holded";
		};
		if ((inputAction "LeanLeft" > 0) && PPS_AllowSendingData && PPS_SendingInfantryData) then 
		{
			_key = "countLeanLeft";
			_value = 1;
			_formatType = 0;
			_formatString = "STR_PPS_Main_Statistics_Count_Lean_Left";
		};
		if ((inputAction "LeanRight" > 0) && PPS_AllowSendingData && PPS_SendingInfantryData) then 
		{
			_key = "countLeanRight";
			_value = 1;
			_formatType = 0;
			_formatString = "STR_PPS_Main_Statistics_Count_Lean_Right";
		};
		if ((inputAction "Salute" > 0) && PPS_AllowSendingData && PPS_SendingInfantryData) then 
		{
			_key = "countSalute";
			_value = 0.5;
			_formatType = 0;
			_formatString = "STR_PPS_Main_Statistics_Count_Salute";
		};
		if ((inputAction "SitDown" > 0) && PPS_AllowSendingData && PPS_SendingInfantryData) then 
		{
			_key = "countSitDown";
			_value = 0.5;
			_formatType = 0;
			_formatString = "STR_PPS_Main_Statistics_Count_Sit_Down";
		};
		if ((inputAction "GetOver" > 0) && PPS_AllowSendingData && PPS_SendingInfantryData) then 
		{
			_key = "countGetOver";
			_value = 1;
			_formatType = 0;
			_formatString = "STR_PPS_Main_Statistics_Count_Get_Over";
		};
		if (_key != "") then
		{
			_updatedData = [_playerUid, [[_key, _value, _type, _formatType, _formatString, _source]]];
			_update = _playerUid + "-updateStatistics";
			missionNamespace setVariable [_update, _updatedData, false];
			publicVariableServer _update;
		};
	}];
	
	/* ---------------------------------------- */
};

/* ================================================================================ */

PPS_ehInventoryOpen = false;

/* ================================================================================ */

while {true} do
{
	if (PPS_AllowSendingData) then
	{
		//hint format ["Speed: %1", speed player];
		
		_timeInEvent = 0;
		
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
		
		_timeVehicleLightOn = 0;
		_timeVehicleLaser = 0;
		_timeVehicleCollisionLightOn = 0;
		_timeVehicleRadarOn = 0;
		
		_timeZooming = 0;
		_timeSpectatorModeOn = 0;
		_timeInventoryVisible = 0;
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
		
		_timeFuelEmpty = 0;
		_timeFuelFillLow = 0;
		_timeFuelFillMid = 0;
		_timeFuelFillHigh = 0;
		_timeFuelFull = 0;
				
		_timeIsBleeding = 0;
		_timeIsBurning = 0;
		
		_timeInjuredNone = 0;
		_timeInjuredLow = 0;
		_timeInjuredMed = 0;
		_timeInjuredHigh = 0;
		_timeInjuredFull = 0;
		
		_timeDamagedNone = 0;
		_timeDamagedLow = 0;
		_timeDamagedMed = 0;
		_timeDamagedHigh = 0;
		_timeDamagedFull = 0;
		
		_timeIsMedic = 0;
		_timeIsEngineer = 0;
		_timeIsExplosiveSpecialist = 0;
		_timeIsUavHacker = 0;
		
		_timeCurrentChannelGlobal = 0;
		_timeCurrentChannelSide = 0;
		_timeCurrentChannelCommand = 0;
		_timeCurrentChannelGroup = 0;
		_timeCurrentChannelVehicle = 0;
		_timeCurrentChannelDirect = 0;
		_timeCurrentChannelCustomRadio = 0;
		
		_timeFireModeSingle = 0;
		_timeFireModeBurst = 0;
		_timeFireModeFullAuto = 0;
		
		_timeZeroingShortRange = 0;
		_timeZeroingMidRange = 0;
		_timeZeroingLongRange = 0;

		_timeAddonAceActive = 0;
		_timeAceIsBleeding = 0;
		_timeAddonTfarActive = 0;
		_timeTfarHasLrRadio = 0;
		_timeTfarHasSwRadio = 0;
		_timeTfarIsSpeaking = 0;
		_timeTfarSpeakVolumeNormal = 0;
		_timeTfarSpeakVolumeYelling = 0;
		_timeTfarSpeakVolumeWhispering = 0;

		/* ---------------------------------------- */

		_vehiclePlayer = vehicle player;
		_speed = speed player;
		
		/* ---------------------------------------- */

		if (PPS_SendingGeneralData) then
		{
			_timeInEvent = PPS_UpdateInterval;
			
			_playerZoom = (call CBA_fnc_getFOV) select 1;
			_isSpectating = ["IsSpectating", [player]] call BIS_fnc_EGSpectator;
			
			if (_playerZoom > 1.1) then {_timeZooming = PPS_UpdateInterval;};		
			if (_isSpectating) then {_timeSpectatorModeOn = PPS_UpdateInterval;};
			if (PPS_ehInventoryOpen) then {_timeInventoryVisible = PPS_UpdateInterval;};
			if (visibleMap) then {_timeMapVisible = PPS_UpdateInterval;};
			if (visibleGPS) then {_timeGpsVisible = PPS_UpdateInterval;};
			if (visibleCompass) then {_timeCompassVisible = PPS_UpdateInterval;};
			if (visibleWatch) then {_timeWatchVisible = PPS_UpdateInterval;};
			
			_currentVisionMode = currentVisionMode player;
			switch (_currentVisionMode) do
			{
				case 0:{_timeVisionModeDay = PPS_UpdateInterval;};
				case 1:{_timeVisionModeNight = PPS_UpdateInterval;};
				case 2:{_timeVisionModeThermal = PPS_UpdateInterval;};
			};
			
			if (isOnRoad player) then {_timeOnRoad = PPS_UpdateInterval;};
			
			if (isBleeding player) then {_timeIsBleeding = PPS_UpdateInterval;};
			if (isBurning player) then {_timeIsBurning = PPS_UpdateInterval;};
			
			_damagePlayer = damage player;
			switch (true) do
			{
				case (_damagePlayer == 0):{_timeInjuredNone = PPS_UpdateInterval};
				case ((_damagePlayer > 0) && (_damagePlayer <= 0.33)):{_timeInjuredLow = PPS_UpdateInterval};
				case ((_damagePlayer > 0.33) && (_damagePlayer <= 0.66)):{_timeInjuredMed = PPS_UpdateInterval};
				case ((_damagePlayer > 0.66) && (_damagePlayer < 1)):{_timeInjuredHigh = PPS_UpdateInterval};
				case (_damagePlayer == 1):{_timeInjuredFull = PPS_UpdateInterval};
			};
			
			_currentChannel = currentChannel;
			switch (true) do
			{
				case (_currentChannel == 0):{_timeCurrentChannelGlobal = PPS_UpdateInterval};
				case (_currentChannel == 1):{_timeCurrentChannelSide = PPS_UpdateInterval};
				case (_currentChannel == 2):{_timeCurrentChannelCommand = PPS_UpdateInterval};
				case (_currentChannel == 3):{_timeCurrentChannelGroup = PPS_UpdateInterval};
				case (_currentChannel == 4):{_timeCurrentChannelVehicle = PPS_UpdateInterval};
				case (_currentChannel == 5):{_timeCurrentChannelDirect = PPS_UpdateInterval};
				case (_currentChannel >= 6):{_timeCurrentChannelCustomRadio = PPS_UpdateInterval};
			};
		
			if (player getUnitTrait "Medic") then {_timeIsMedic = PPS_UpdateInterval;};
			if (player getUnitTrait "Engineer") then {_timeIsEngineer = PPS_UpdateInterval;};
			if (player getUnitTrait "ExplosiveSpecialist") then {_timeIsExplosiveSpecialist = PPS_UpdateInterval;};
			if (player getUnitTrait "UAVHacker") then {_timeIsUavHacker = PPS_UpdateInterval;};
		};
		
		/* ---------------------------------------- */
		
		if ((_vehiclePlayer == player) && PPS_SendingInfantryData) then 
		{
			_timeOnFoot = PPS_UpdateInterval;
			
			_stance = stance player;
			
			switch (true) do
			{
				case ((_speed == 0) && (_stance == "STAND")):{_timeStandNoSpeed = PPS_UpdateInterval;};
				case ((_speed == 0) && (_stance == "CROUCH")):{_timeCrouchNoSpeed = PPS_UpdateInterval;};
				case ((_speed == 0) && (_stance == "PRONE")):{_timeProneNoSpeed = PPS_UpdateInterval;};
				case ((_speed > 0 && _speed < 8) && (_stance == "STAND")):{_timeStandLowSpeed = PPS_UpdateInterval;};
				case ((_speed > 0 && _speed < 8) && (_stance == "CROUCH")):{_timeCrouchLowSpeed = PPS_UpdateInterval;};
				case ((_speed > 0 && _speed < 2.5) && (_stance == "PRONE")):{_timeProneLowSpeed = PPS_UpdateInterval;};
				case ((_speed >= 8 && _speed < 15) && (_stance == "STAND")):{_timeStandMidSpeed = PPS_UpdateInterval;};
				case ((_speed >= 8 && _speed < 15) && (_stance == "CROUCH")):{_timeCrouchMidSpeed = PPS_UpdateInterval;};
				case ((_speed >= 2.5 && _speed < 4.8) && (_stance == "PRONE")):{_timeProneMidSpeed = PPS_UpdateInterval;};
				case ((_speed >= 15) && (_stance == "STAND")):{_timeStandHighSpeed = PPS_UpdateInterval;};
				case ((_speed >= 15) && (_stance == "CROUCH")):{_timeCrouchHighSpeed = PPS_UpdateInterval;};
				case ((_speed >= 4.8) && (_stance == "PRONE")):{_timeProneHighSpeed = PPS_UpdateInterval;};
			};
			
			if (weaponLowered player) then {_timeWeaponLowered = PPS_UpdateInterval;};
			if (player isIRLaserOn (currentWeapon player)) then {_timeIrLaserOn = PPS_UpdateInterval;};
			if (player isFlashlightOn (currentWeapon player)) then {_timeFlashlightOn = PPS_UpdateInterval;};
			
			_needReload = needReload player;
			switch (true) do
			{
				case (_needReload == 0):{_timeMagazineFull = PPS_UpdateInterval};
				case ((_needReload > 0) && (_needReload <= 0.33)):{_timeMagazineFillHigh = PPS_UpdateInterval};
				case ((_needReload > 0.33) && (_needReload <= 0.66)):{_timeMagazineFillMid = PPS_UpdateInterval};
				case ((_needReload > 0.66) && (_needReload < 1)):{_timeMagazineFillLow = PPS_UpdateInterval};
				case (_needReload == 1):{_timeMagazineEmpty = PPS_UpdateInterval};
			};
			
			_fireMode = (weaponState player) select 2;
			switch (_fireMode) do
			{
				case "Single":{_timeFireModeSingle = PPS_UpdateInterval};
				case "Burst":{_timeFireModeBurst = PPS_UpdateInterval};
				case "FullAuto":{_timeFireModeFullAuto = PPS_UpdateInterval};
			};
			
			_zeroing = currentZeroing player;
			switch (true) do
			{
				case ((_zeroing > 0) && (_zeroing <= 300)):{_timeZeroingShortRange = PPS_UpdateInterval};
				case ((_zeroing > 300) && (_zeroing <= 600)):{_timeZeroingMidRange = PPS_UpdateInterval};
				case (_zeroing > 600):{_timeZeroingLongRange = PPS_UpdateInterval};
			};
		};
		
		/* ---------------------------------------- */
		
		if ((_vehiclePlayer != player) && PPS_SendingVehicleData) then 
		{
			_timeInVehicle = PPS_UpdateInterval;
			
			_fuel = fuel _vehiclePlayer;
			switch (true) do
			{
				case (_fuel == 0):{_timeFuelEmpty = PPS_UpdateInterval};
				case ((_fuel > 0) && (_fuel <= 0.33)):{_timeFuelFillLow = PPS_UpdateInterval};
				case ((_fuel > 0.33) && (_fuel <= 0.66)):{_timeFuelFillMid = PPS_UpdateInterval};
				case ((_fuel > 0.66) && (_fuel < 1)):{_timeFuelFillHigh = PPS_UpdateInterval};
				case (_fuel == 1):{_timeFuelFull = PPS_UpdateInterval};
			};
			
			_damageVehicle = damage _vehiclePlayer;
			switch (true) do
			{
				case (_damageVehicle == 0):{_timeDamagedNone = PPS_UpdateInterval};
				case ((_damageVehicle > 0) && (_damageVehicle <= 0.33)):{_timeDamagedLow = PPS_UpdateInterval};
				case ((_damageVehicle > 0.33) && (_damageVehicle <= 0.66)):{_timeDamagedMed = PPS_UpdateInterval};
				case ((_damageVehicle > 0.66) && (_damageVehicle < 1)):{_timeDamagedHigh = PPS_UpdateInterval};
				case (_damageVehicle == 1):{_timeDamagedFull = PPS_UpdateInterval};
			};
			
			if(isEngineOn _vehiclePlayer) then {_timeInVehicleEngineOn = PPS_UpdateInterval;};
			if(_speed > 0) then {_timeInVehicleMoving = PPS_UpdateInterval;};
			if(!isTouchingGround _vehiclePlayer) then {_timeInVehicleFlying = PPS_UpdateInterval;};
			
			switch (true) do
			{
				case ((_vehiclePlayer isKindOf "Tank") && ((driver _vehiclePlayer) == player)):{_timeTankDriver = PPS_UpdateInterval};
				case ((_vehiclePlayer isKindOf "Tank") && ((gunner _vehiclePlayer) == player)):{_timeTankGunner = PPS_UpdateInterval};
				case ((_vehiclePlayer isKindOf "Tank") && ((commander _vehiclePlayer) == player)):{_timeTankCommander = PPS_UpdateInterval};
				case ((_vehiclePlayer isKindOf "Tank") && ((_vehiclePlayer getCargoIndex player) != -1)):{_timeTankPassenger = PPS_UpdateInterval};
				case ((_vehiclePlayer isKindOf "Truck_F") && ((driver _vehiclePlayer) == player)):{_timeTruckDriver = PPS_UpdateInterval};
				case ((_vehiclePlayer isKindOf "Truck_F") && ((gunner _vehiclePlayer) == player)):{_timeTruckGunner = PPS_UpdateInterval};
				case ((_vehiclePlayer isKindOf "Truck_F") && ((commander _vehiclePlayer) == player)):{_timeTruckCommander = PPS_UpdateInterval};
				case ((_vehiclePlayer isKindOf "Truck_F") && ((_vehiclePlayer getCargoIndex player) != -1)):{_timeTruckPassenger = PPS_UpdateInterval};
				case ((_vehiclePlayer isKindOf "Car") && ((driver _vehiclePlayer) == player)):{_timeCarDriver = PPS_UpdateInterval};
				case ((_vehiclePlayer isKindOf "Car") && ((gunner _vehiclePlayer) == player)):{_timeCarGunner = PPS_UpdateInterval};
				case ((_vehiclePlayer isKindOf "Car") && ((commander _vehiclePlayer) == player)):{_timeCarCommander = PPS_UpdateInterval};
				case ((_vehiclePlayer isKindOf "Car") && ((_vehiclePlayer getCargoIndex player) != -1)):{_timeCarPassenger = PPS_UpdateInterval};
				case ((_vehiclePlayer isKindOf "Helicopter") && ((driver _vehiclePlayer) == player)):{_timeHelicopterDriver = PPS_UpdateInterval};
				case ((_vehiclePlayer isKindOf "Helicopter") && ((gunner _vehiclePlayer) == player)):{_timeHelicopterGunner = PPS_UpdateInterval};
				case ((_vehiclePlayer isKindOf "Helicopter") && ((commander _vehiclePlayer) == player)):{_timeHelicopterCommander = PPS_UpdateInterval};
				case ((_vehiclePlayer isKindOf "Helicopter") && ((_vehiclePlayer getCargoIndex player) != -1)):{_timeHelicopterPassenger = PPS_UpdateInterval};
				case ((_vehiclePlayer isKindOf "Plane") && ((driver _vehiclePlayer) == player)):{_timePlaneDriver = PPS_UpdateInterval};
				case ((_vehiclePlayer isKindOf "Plane") && ((gunner _vehiclePlayer) == player)):{_timePlaneGunner = PPS_UpdateInterval};
				case ((_vehiclePlayer isKindOf "Plane") && ((commander _vehiclePlayer) == player)):{_timePlaneCommander = PPS_UpdateInterval};
				case ((_vehiclePlayer isKindOf "Plane") && ((_vehiclePlayer getCargoIndex player) != -1)):{_timePlanePassenger = PPS_UpdateInterval};
				case ((_vehiclePlayer isKindOf "Ship") && ((driver _vehiclePlayer) == player)):{_timeShipDriver = PPS_UpdateInterval};
				case ((_vehiclePlayer isKindOf "Ship") && ((gunner _vehiclePlayer) == player)):{_timeShipGunner = PPS_UpdateInterval};
				case ((_vehiclePlayer isKindOf "Ship") && ((commander _vehiclePlayer) == player)):{_timeShipCommander = PPS_UpdateInterval};
				case ((_vehiclePlayer isKindOf "Ship") && ((_vehiclePlayer getCargoIndex player) != -1)):{_timeShipPassenger = PPS_UpdateInterval};
			};
			
			if (isLightOn (vehicle player)) then {_timeVehicleLightOn = PPS_UpdateInterval;};
			if (isLaserOn (vehicle player)) then {_timeVehicleLaser = PPS_UpdateInterval;};
			if (isCollisionLightOn (vehicle player)) then {_timeVehicleCollisionLightOn = PPS_UpdateInterval;};
			if (isVehicleRadarOn (vehicle player)) then {_timeVehicleRadarOn = PPS_UpdateInterval;};
		};

		/* ---------------------------------------- */
		
		if (PPS_SendingGeneralData) then
		{
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
				_timeAddonAceActive = PPS_UpdateInterval;
				
				if([player] call ace_medical_blood_fnc_isBleeding) then {_timeAceIsBleeding = PPS_UpdateInterval;};
			};
			if ((_addons find "tfar_core") > -1) then 
			{
				_timeAddonTfarActive = PPS_UpdateInterval;
				try
				{
					_activeLrRadio = player call TFAR_fnc_backpackLR;
					if (!isNil "_activeLrRadio") then {_timeTfarHasLrRadio = PPS_UpdateInterval;};
					if (call TFAR_fnc_haveSWRadio) then {_timeTfarHasSwRadio = PPS_UpdateInterval;};
					if (player call TFAR_fnc_isSpeaking) then {_timeTfarIsSpeaking = PPS_UpdateInterval;};
					switch (TF_speak_volume_level) do
					{
						case "normal":{_timeTfarSpeakVolumeNormal = PPS_UpdateInterval;};
						case "yelling":{_timeTfarSpeakVolumeYelling = PPS_UpdateInterval;};
						case "whispering":{_timeTfarSpeakVolumeWhispering = PPS_UpdateInterval;};
					};
				}
				catch
				{
					hint format [localize "STR_PPS_Main_Error", str _exception];
				};
			};
		};
		
		/* ---------------------------------------- */
		
		_filter = "0123456789AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZzÜüÖöÄä[]-_.:#*(){}%$§&<>+-,;'~?= ";
		_playerName = [_playerName, _filter] call BIS_fnc_filterString;
		
		_updatedData = 
		[
			_playerUid,
			[
				["timeInEvent", _timeInEvent, 1, 3, "STR_PPS_Main_Statistics_Time_In_Event", "A3"],  
				["timeOnFoot", _timeOnFoot, 1, 1, "STR_PPS_Main_Statistics_Time_On_Foot", "A3"],  
				["timeStandNoSpeed", _timeStandNoSpeed, 1, 1, "STR_PPS_Main_Statistics_Time_Stand_No_Speed", "A3"],  
				["timeCrouchNoSpeed", _timeCrouchNoSpeed, 1, 1, "STR_PPS_Main_Statistics_Time_Crouch_No_Speed", "A3"],  
				["timeProneNoSpeed", _timeProneNoSpeed, 1, 1, "STR_PPS_Main_Statistics_Time_Prone_No_Speed", "A3"],  
				["timeStandLowSpeed", _timeStandLowSpeed, 1, 1, "STR_PPS_Main_Statistics_Time_Stand_Low_Speed", "A3"],  
				["timeCrouchLowSpeed", _timeCrouchLowSpeed, 1, 1, "STR_PPS_Main_Statistics_Time_Crouch_Low_Speed", "A3"],  
				["timeProneLowSpeed", _timeProneLowSpeed, 1, 1, "STR_PPS_Main_Statistics_Time_Prone_Low_Speed", "A3"],  
				["timeStandMidSpeed", _timeStandMidSpeed, 1, 1, "STR_PPS_Main_Statistics_Time_Stand_Mid_Speed", "A3"],  
				["timeCrouchMidSpeed", _timeCrouchMidSpeed, 1, 1, "STR_PPS_Main_Statistics_Time_Crouch_Mid_Speed", "A3"],  
				["timeProneMidSpeed", _timeProneMidSpeed, 1, 1, "STR_PPS_Main_Statistics_Time_Prone_Mid_Speed", "A3"],  
				["timeStandHighSpeed", _timeStandHighSpeed, 1, 1, "STR_PPS_Main_Statistics_Time_Stand_High_Speed", "A3"],  
				["timeCrouchHighSpeed", _timeCrouchHighSpeed, 1, 1, "STR_PPS_Main_Statistics_Time_Crouch_High_Speed", "A3"],  
				["timeProneHighSpeed", _timeProneHighSpeed, 1, 1, "STR_PPS_Main_Statistics_Time_Prone_High_Speed", "A3"],  
				["timeInVehicle", _timeInVehicle, 1, 1, "STR_PPS_Main_Statistics_Time_In_Vehicle", "A3"], 
				["timeInVehicleEngineOn", _timeInVehicleEngineOn, 1, 1, "STR_PPS_Main_Statistics_Time_In_Vehicle_Engine_On", "A3"], 
				["timeInVehicleMoving", _timeInVehicleMoving, 1, 1, "STR_PPS_Main_Statistics_Time_In_Vehicle_Moving", "A3"], 
				["timeInVehicleFlying", _timeInVehicleFlying, 1, 1, "STR_PPS_Main_Statistics_Time_In_Vehicle_Flying", "A3"], 
				["timeCarDriver", _timeCarDriver, 1, 1, "STR_PPS_Main_Statistics_Time_Car_Driver", "A3"],  
				["timeCarGunner", _timeCarGunner, 1, 1, "STR_PPS_Main_Statistics_Time_Car_Gunner", "A3"], 
				["timeCarCommander", _timeCarCommander, 1, 1, "STR_PPS_Main_Statistics_Time_Car_Commander", "A3"],  
				["timeCarPassenger", _timeCarPassenger, 1, 1, "STR_PPS_Main_Statistics_Time_Car_Passenger", "A3"],  
				["timeTankDriver", _timeTankDriver, 1, 1, "STR_PPS_Main_Statistics_Time_Tank_Driver", "A3"],  
				["timeTankGunner", _timeTankGunner, 1, 1, "STR_PPS_Main_Statistics_Time_Tank_Gunner", "A3"],  
				["timeTankCommander", _timeTankCommander, 1, 1, "STR_PPS_Main_Statistics_Time_Tank_Commander", "A3"],  
				["timeTankPassenger", _timeTankPassenger, 1, 1, "STR_PPS_Main_Statistics_Time_Tank_Passenger", "A3"],  
				["timeTruckDriver", _timeTruckDriver, 1, 1, "STR_PPS_Main_Statistics_Time_Truck_Driver", "A3"],  
				["timeTruckGunner", _timeTruckGunner, 1, 1, "STR_PPS_Main_Statistics_Time_Truck_Gunner", "A3"],  
				["timeTruckCommander", _timeTruckCommander, 1, 1, "STR_PPS_Main_Statistics_Time_Truck_Commander", "A3"],  
				["timeTruckPassenger", _timeTruckPassenger, 1, 1, "STR_PPS_Main_Statistics_Time_Truck_Passenger", "A3"],  
				["timeHelicopterDriver", _timeHelicopterDriver, 1, 1, "STR_PPS_Main_Statistics_Time_Helicopter_Driver", "A3"],  
				["timeHelicopterGunner", _timeHelicopterGunner, 1, 1, "STR_PPS_Main_Statistics_Time_Helicopter_Gunner", "A3"],  
				["timeHelicopterCommander", _timeHelicopterCommander, 1, 1, "STR_PPS_Main_Statistics_Time_Helicopter_Commander", "A3"],  
				["timeHelicopterPassenger", _timeHelicopterPassenger, 1, 1, "STR_PPS_Main_Statistics_Time_Helicopter_Passenger", "A3"],  
				["timePlaneDriver", _timePlaneDriver, 1, 1, "STR_PPS_Main_Statistics_Time_Plane_Driver", "A3"],  
				["timePlaneGunner", _timePlaneGunner, 1, 1, "STR_PPS_Main_Statistics_Time_Plane_Gunner", "A3"],  
				["timePlaneCommander", _timePlaneCommander, 1, 1, "STR_PPS_Main_Statistics_Time_Plane_Commander", "A3"],  
				["timePlanePassenger", _timePlanePassenger, 1, 1, "STR_PPS_Main_Statistics_Time_Plane_Passenger", "A3"],  
				["timeShipDriver", _timeShipDriver, 1, 1, "STR_PPS_Main_Statistics_Time_Ship_Driver", "A3"],  
				["timeShipGunner", _timeShipGunner, 1, 1, "STR_PPS_Main_Statistics_Time_Ship_Gunner", "A3"],  
				["timeShipCommander", _timeShipCommander, 1, 1, "STR_PPS_Main_Statistics_Time_Ship_Commander", "A3"],  
				["timeShipPassenger", _timeShipPassenger, 1, 1, "STR_PPS_Main_Statistics_Time_Ship_Passenger", "A3"],  
				["timeVehicleLightOn", _timeVehicleLightOn, 1, 1, "STR_PPS_Main_Statistics_Time_Vehicle_Light_On", "A3"],  
				["timeVehicleLaser", _timeVehicleLaser, 1, 1, "STR_PPS_Main_Statistics_Time_Vehicle_Laser_On", "A3"],  
				["timeVehicleCollisionLightOn", _timeVehicleCollisionLightOn, 1, 1, "STR_PPS_Main_Statistics_Time_Vehicle_Collision_Light_On", "A3"],  
				["timeVehicleRadarOn", _timeVehicleRadarOn, 1, 1, "STR_PPS_Main_Statistics_Time_Vehicle_Radar_On", "A3"],  
				["timeSpectatorModeOn", _timeSpectatorModeOn, 1, 1, "STR_PPS_Main_Statistics_Time_Spectator_Mode_On", "A3"],  
				["timeZooming", _timeZooming, 1, 1, "STR_PPS_Main_Statistics_Time_Zooming", "A3"],  
				["timeInventoryVisible", _timeInventoryVisible, 1, 1, "STR_PPS_Main_Statistics_Time_Inventory_Visible", "A3"],  
				["timeMapVisible", _timeMapVisible, 1, 1, "STR_PPS_Main_Statistics_Time_Map_Visible", "A3"],  
				["timeGpsVisible", _timeGpsVisible, 1, 1, "STR_PPS_Main_Statistics_Time_Gps_Visible", "A3"],  
				["timeCompassVisible", _timeCompassVisible, 1, 1, "STR_PPS_Main_Statistics_Time_Compass_Visible", "A3"],  
				["timeWatchVisible", _timeWatchVisible, 1, 1, "STR_PPS_Main_Statistics_Time_Watch_Visible", "A3"],  
				["timeVisionModeDay", _timeVisionModeDay, 1, 1, "STR_PPS_Main_Statistics_Time_Vision_Mode_Day", "A3"],  
				["timeVisionModeNight", _timeVisionModeNight, 1, 1, "STR_PPS_Main_Statistics_Time_Vision_Mode_Night", "A3"],  
				["timeVisionModeThermal", _timeVisionModeThermal, 1, 1, "STR_PPS_Main_Statistics_Time_Vision_Mode_Thermal", "A3"],  
				["timeWeaponLowered", _timeWeaponLowered, 1, 1, "STR_PPS_Main_Statistics_Time_Weapon_Lowered", "A3"], 
				["timeOnRoad", _timeOnRoad, 1, 1, "STR_PPS_Main_Statistics_Time_On_Road", "A3"], 
				["timeIsBleeding", _timeIsBleeding, 1, 1, "STR_PPS_Main_Statistics_Time_Is_Bleeding", "A3"], 
				["timeIsBurning", _timeIsBurning, 1, 1, "STR_PPS_Main_Statistics_Time_Is_Burning", "A3"], 
				["timeInjuredNone", _timeInjuredNone, 1, 1, "STR_PPS_Main_Statistics_Time_Injured_None", "A3"], 
				["timeInjuredLow", _timeInjuredLow, 1, 1, "STR_PPS_Main_Statistics_Time_Injured_Low", "A3"], 
				["timeInjuredMed", _timeInjuredMed, 1, 1, "STR_PPS_Main_Statistics_Time_Injured_Med", "A3"], 
				["timeInjuredHigh", _timeInjuredHigh, 1, 1, "STR_PPS_Main_Statistics_Time_Injured_High", "A3"], 
				["timeInjuredFull", _timeInjuredFull, 1, 1, "STR_PPS_Main_Statistics_Time_Injured_Full", "A3"], 
				["timeDamagedNone", _timeDamagedNone, 1, 1, "STR_PPS_Main_Statistics_Time_Damaged_None", "A3"], 
				["timeDamagedLow", _timeDamagedLow, 1, 1, "STR_PPS_Main_Statistics_Time_Damaged_Low", "A3"], 
				["timeDamagedMed", _timeDamagedMed, 1, 1, "STR_PPS_Main_Statistics_Time_Damaged_Med", "A3"], 
				["timeDamagedHigh", _timeDamagedHigh, 1, 1, "STR_PPS_Main_Statistics_Time_Damaged_High", "A3"], 
				["timeDamagedFull", _timeDamagedFull, 1, 1, "STR_PPS_Main_Statistics_Time_Damaged_Full", "A3"], 
				["timeIrLaserOn", _timeIrLaserOn, 1, 1, "STR_PPS_Main_Statistics_Time_Ir_Laser_On", "A3"], 
				["timeFlashlightOn", _timeFlashlightOn, 1, 1, "STR_PPS_Main_Statistics_Time_Flashlight_On", "A3"], 
				["timeMagazineFull", _timeMagazineFull, 1, 1, "STR_PPS_Main_Statistics_Time_Magazine_Full", "A3"], 
				["timeMagazineFillHigh", _timeMagazineFillHigh, 1, 1, "STR_PPS_Main_Statistics_Time_Magazine_Fill_High", "A3"], 
				["timeMagazineFillMid", _timeMagazineFillMid, 1, 1, "STR_PPS_Main_Statistics_Time_Magazine_Fill_Med", "A3"], 
				["timeMagazineFillLow", _timeMagazineFillLow, 1, 1, "STR_PPS_Main_Statistics_Time_Magazine_Fill_Low", "A3"], 
				["timeMagazineEmpty", _timeMagazineEmpty, 1, 1, "STR_PPS_Main_Statistics_Time_Magazine_Empty", "A3"], 
				["timeFuelEmpty", _timeFuelEmpty, 1, 1, "STR_PPS_Main_Statistics_Time_Fuel_Empty", "A3"], 
				["timeFuelFillLow", _timeFuelFillLow, 1, 1, "STR_PPS_Main_Statistics_Time_Fuel_Fill_Low", "A3"], 
				["timeFuelFillMid", _timeFuelFillMid, 1, 1, "STR_PPS_Main_Statistics_Time_Fuel_Fill_Med", "A3"], 
				["timeFuelFillHigh", _timeFuelFillHigh, 1, 1, "STR_PPS_Main_Statistics_Time_Fuel_Fill_High", "A3"], 
				["timeFuelFull", _timeFuelFull, 1, 1, "STR_PPS_Main_Statistics_Time_Fuel_Full", "A3"], 			
				["timeCurrentChannelGlobal", _timeCurrentChannelGlobal, 1, 1, "STR_PPS_Main_Statistics_Time_Current_Channel_Global", "A3"], 
				["timeCurrentChannelSide", _timeCurrentChannelSide, 1, 1, "STR_PPS_Main_Statistics_Time_Current_Channel_Side", "A3"], 
				["timeCurrentChannelCommand", _timeCurrentChannelCommand, 1, 1, "STR_PPS_Main_Statistics_Time_Current_Channel_Command", "A3"], 
				["timeCurrentChannelGroup", _timeCurrentChannelGroup, 1, 1, "STR_PPS_Main_Statistics_Time_Current_Channel_Group", "A3"], 
				["timeCurrentChannelVehicle", _timeCurrentChannelVehicle, 1, 1, "STR_PPS_Main_Statistics_Time_Current_Channel_Vehicle", "A3"], 
				["timeCurrentChannelDirect", _timeCurrentChannelDirect, 1, 1, "STR_PPS_Main_Statistics_Time_Current_Channel_Direct", "A3"], 
				["timeCurrentChannelCustomRadio", _timeCurrentChannelCustomRadio, 1, 1, "STR_PPS_Main_Statistics_Time_Current_Channel_Custom_Radio", "A3"], 			
				["timeFireModeSingle", _timeFireModeSingle, 1, 1, "STR_PPS_Main_Statistics_Time_Fire_Mode_Single", "A3"], 
				["timeFireModeBurst", _timeFireModeBurst, 1, 1, "STR_PPS_Main_Statistics_Time_Fire_Mode_Burst", "A3"], 
				["timeFireModeFullAuto", _timeFireModeFullAuto, 1, 1, "STR_PPS_Main_Statistics_Time_Fire_Mode_Full_Auto", "A3"], 
				["timeZeroingShortRange", _timeZeroingShortRange, 1, 1, "STR_PPS_Main_Statistics_Time_Zeroing_Short_Range", "A3"], 
				["timeZeroingMidRange", _timeZeroingMidRange, 1, 1, "STR_PPS_Main_Statistics_Time_Zeroing_Mid_Range", "A3"], 
				["timeZeroingLongRange", _timeZeroingLongRange, 1, 1, "STR_PPS_Main_Statistics_Time_Zeroing_Long_Range", "A3"], 			
				["timeIsMedic", _timeIsMedic, 1, 1, "STR_PPS_Main_Statistics_Time_Is_Medic", "A3"], 
				["timeIsEngineer", _timeIsEngineer, 1, 1, "STR_PPS_Main_Statistics_Time_Is_Engineer", "A3"], 
				["timeIsExplosiveSpecialist", _timeIsExplosiveSpecialist, 1, 1, "STR_PPS_Main_Statistics_Time_Is_Explosive_Specialist", "A3"], 
				["timeIsUavHacker", _timeIsUavHacker, 1, 1, "STR_PPS_Main_Statistics_Time_Is_Uav_Hacker", "A3"], 
				["timeAddonAceActive", _timeAddonAceActive, 1, 1, "STR_PPS_Main_Statistics_Time_Addon_Ace_Active", "A3"], 
				["timeAceIsBleeding", _timeAceIsBleeding, 1, 1, "STR_PPS_Main_Statistics_Time_Is_Bleeding_Ace", "ACE"], 
				["timeAddonTfarActive", _timeAddonTfarActive, 1, 1, "STR_PPS_Main_Statistics_Time_Addon_Tfar_Active", "A3"],
				["timeTfarHasLrRadio", _timeTfarHasLrRadio, 1, 1, "STR_PPS_Main_Statistics_Time_Has_Lr_Radio", "TFAR"],
				["timeTfarHasSwRadio", _timeTfarHasSwRadio, 1, 1, "STR_PPS_Main_Statistics_Time_Has_Sw_Radio", "TFAR"],
				["timeTfarIsSpeaking", _timeTfarIsSpeaking, 1, 1, "STR_PPS_Main_Statistics_Time_Is_Speaking", "TFAR"],
				["timeTfarSpeakVolumeNormal", _timeTfarSpeakVolumeNormal, 1, 1, "STR_PPS_Main_Statistics_Time_Speak_Volume_Normal", "TFAR"],
				["timeTfarSpeakVolumeYelling", _timeTfarSpeakVolumeYelling, 1, 1, "STR_PPS_Main_Statistics_Time_Speak_Volume_Yelling", "TFAR"],
				["timeTfarSpeakVolumeWhispering", _timeTfarSpeakVolumeWhispering, 1, 1, "STR_PPS_Main_Statistics_Time_Speak_Volume_Whispering", "TFAR"]
			]
		];
		
		_update = _playerUid + "-updateStatistics";
		missionNamespace setVariable [_update, _updatedData, false];
		publicVariableServer _update;
	};
	sleep PPS_UpdateInterval;
};

/* ================================================================================ */
