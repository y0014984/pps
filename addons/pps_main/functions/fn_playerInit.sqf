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

	

	/* ---------------------------------------- */
	
	_index = player addEventHandler ["Reloaded", 
	{
		params ["_unit", "_weapon", "_muzzle", "_newmag", ["_oldmag", ["","","",""]]];
			
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
		_timeIsBleeding = 0;
		
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

		/* ---------------------------------------- */

		_vehiclePlayer = vehicle player;
		_speed = speed player;
		
		/* ---------------------------------------- */

		if (PPS_SendingGeneralData) then
		{
			_timeInEvent = PPS_UpdateInterval;
			
			_playerZoom = (call CBA_fnc_getFOV) select 1;
			_isSpectating = ["IsSpectating", [player]] call BIS_fnc_EGSpectator;
			
			_damagePlayer = damage player;
			switch (true) do
			{
				case (_damagePlayer == 0):{_timeInjuredNone = PPS_UpdateInterval};
				case ((_damagePlayer > 0) && (_damagePlayer <= 0.33)):{_timeInjuredLow = PPS_UpdateInterval};
				case ((_damagePlayer > 0.33) && (_damagePlayer <= 0.66)):{_timeInjuredMed = PPS_UpdateInterval};
				case ((_damagePlayer > 0.66) && (_damagePlayer < 1)):{_timeInjuredHigh = PPS_UpdateInterval};
				case (_damagePlayer == 1):{_timeInjuredFull = PPS_UpdateInterval};
			};

		};

		/* ---------------------------------------- */
		
		if (PPS_SendingGeneralData) then
		{
			_addons = activatedAddons;
			
			if ((_addons find "ace_main") > -1) then
			{
				_timeAddonAceActive = PPS_UpdateInterval;
				
				if([player] call ace_medical_blood_fnc_isBleeding) then {_timeIsBleeding = PPS_UpdateInterval;};
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
				["timeIsBleeding", _timeIsBleeding, 1, 1, "STR_PPS_Main_Statistics_Time_Is_Bleeding", "A3"], 
				["timeInjuredNone", _timeInjuredNone, 1, 1, "STR_PPS_Main_Statistics_Time_Injured_None", "A3"], 
				["timeInjuredLow", _timeInjuredLow, 1, 1, "STR_PPS_Main_Statistics_Time_Injured_Low", "A3"], 
				["timeInjuredMed", _timeInjuredMed, 1, 1, "STR_PPS_Main_Statistics_Time_Injured_Med", "A3"], 
				["timeInjuredHigh", _timeInjuredHigh, 1, 1, "STR_PPS_Main_Statistics_Time_Injured_High", "A3"], 
				["timeInjuredFull", _timeInjuredFull, 1, 1, "STR_PPS_Main_Statistics_Time_Injured_Full", "A3"], 
				["timeDamagedNone", _timeDamagedNone, 1, 1, "STR_PPS_Main_Statistics_Time_Damaged_None", "A3"], 
				["timeDamagedLow", _timeDamagedLow, 1, 1, "STR_PPS_Main_Statistics_Time_Damaged_Low", "A3"], 
				["timeDamagedMed", _timeDamagedMed, 1, 1, "STR_PPS_Main_Statistics_Time_Damaged_Med", "A3"], 
				["timeDamagedHigh", _timeDamagedHigh, 1, 1, "STR_PPS_Main_Statistics_Time_Damaged_High", "A3"], 
				["timeDamagedFull", _timeDamagedFull, 1, 1, "STR_PPS_Main_Statistics_Time_Damaged_Full", "A3"] 
			]
		];
		
		_update = _playerUid + "-updateStatistics";
		missionNamespace setVariable [_update, _updatedData, false];
		publicVariableServer _update;
	};
	sleep PPS_UpdateInterval;
};

/* ================================================================================ */
