/*
 * Author: y0014984
 *
 * Initializes animals and adds several event handlers.
 *
 * Arguments:
 * 0: _animal <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_animal] spawn PPS_fnc_animalInit;
 *
 * Public: No
 */

params ["_animal"];

/* ================================================================================ */

if (isMultiplayer) then
{
	/* ================================================================================ */
	
	_index = _animal addMPEventHandler ["MPKilled",
	{
		params ["_unit", "_killer", "_instigator", "_useEffects"];
		
		hint format ["MPKilled Event Handler\n\n_unit: %1\n_killer: %2", _unit, _killer];

		if (local _unit) then
		{
			_unit removeAllEventHandlers "HitPart";
			
			_killerUid = getPlayerUID _killer;
				
			if (_killerUid != "" && PPS_AllowSendingData && PPS_SendingInfantryData) then
			{
				_playerUid = _killerUid;
				_source = "A3";
				_key = "countPlayerAnimalKills";
				_value = 1;
				_type = 2;
				_formatType = 0;
				_formatString = "STR_PPS_Main_Statistics_Count_Player_Animal_Kills";
							
				_updatedData = [_playerUid, [[_key, _value, _type, _formatType, _formatString, _source]]];
				_update = _playerUid + "-updateStatistics";
				missionNamespace setVariable [_update, _updatedData, false];
				publicVariableServer _update;				
			};
		};
	}];
	
	[format ["[%1] PPS Event Handler 'MPKilled' added to Animal: (%2)", serverTime, _animal]] call PPS_fnc_log;
	
	/* ================================================================================ */
};

/* ================================================================================ */
