/*
 * Author: y0014984
 *
 * Adds 'Hit' event handler to all units. Nesseccary in case of respawn.
 *
 * Arguments:
 * 0: _unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit] call PPS_fnc_unitEventHandlerHitAdd;
 *
 * Public: No
 */
 
params ["_unit"];

/* ================================================================================ */

if (local _unit) then
{
	_index = _unit addEventHandler ["Hit",
	{
		params ["_unit", "_sourceObject", "_damage", "_instigator"];
		
		_unitUid = getPlayerUID _unit;
		_unitSide = side group _unit;
		_instigatorUid = getPlayerUID _instigator;
		_instigatorSide = side group _instigator;
		
		_clientId = clientOwner;
		
		_key = "";
		_value = 1;
		_type = 2;
		_formatType = 0;
		_formatString = "";
		
		if (local _unit) then
		{
			if ((_unitUid != "") && PPS_AllowSendingData && PPS_SendingInfantryData) then
			{
				_playerUid = _unitUid;
				_source = "A3";
				
				// _eventHandlerInformation = format ["Event Handler 'Hit' fired for local _unit.\n\n_unit: %1 (%2 - %3)\n_instigator: %4 (%5 - %6)\n\nclientId: %7\n_source: %8", _unit, _unitUid, _unitSide, _instigator, _instigatorUid, _instigatorSide, _clientId, _sourceObject];
				// hint _eventHandlerInformation;
				// [_eventHandlerInformation] call PPS_fnc_log;
				
				if (_instigatorSide != _unitSide) then
				{
					_key = "countHitsByEnemy";	
					_formatType = 0;				
					_formatString = "STR_PPS_Main_Statistics_Count_Hits_By_Enemy";
				}
				else
				{
					_key = "countHitsByFriendly";
					_formatType = 0;
					_formatString = "STR_PPS_Main_Statistics_Count_Hits_By_Friendly";
				};

				_updatedData = [_playerUid, [[_key, _value, _type, _formatType, _formatString, _source]]];
				_update = _playerUid + "-updateStatistics";
				missionNamespace setVariable [_update, _updatedData, false];
				publicVariableServer _update;	
			};
			if ((_instigatorUid != "") && PPS_AllowSendingData && PPS_SendingInfantryData) then
			{
				_playerUid = _instigatorUid;
				_source = "A3";
				
				// _eventHandlerInformation = format ["Event Handler 'Hit' fired for (not local) _instigator.\n\n_unit: %1 (%2 - %3)\n_instigator: %4 (%5 - %6)\n\nclientId: %7\n_source: %8", _unit, _unitUid, _unitSide, _instigator, _instigatorUid, _instigatorSide, _clientId, _sourceObject];
				// hint _eventHandlerInformation;
				// [_eventHandlerInformation] call PPS_fnc_log;
				
				if (_instigatorSide != _unitSide) then
				{
					_key = "countHitsToEnemy";
					_formatType = 2;
					_formatString = "STR_PPS_Main_Statistics_Count_Hits_To_Enemy";
				}
				else
				{
					_key = "countHitsToFriendly";
					_formatType = 2;
					_formatString = "STR_PPS_Main_Statistics_Count_Hits_To_Friendly";
				};

				_updatedData = [_playerUid, [[_key, _value, _type, _formatType, _formatString, _source]]];
				_update = _playerUid + "-updateStatistics";
				missionNamespace setVariable [_update, _updatedData, false];
				publicVariableServer _update;			
			};
		};
	}];
};

[format ["[%1] PPS Event Handler 'Hit' added to Unit: (%2)", serverTime, (getPlayerUID _unit)]] call PPS_fnc_log;