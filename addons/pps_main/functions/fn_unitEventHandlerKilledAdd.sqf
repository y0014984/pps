/*
 * Author: y0014984
 *
 * Adds 'Killed' event handler to all units.
 *
 * Arguments:
 * 0: _unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit] call PPS_fnc_unitEventHandlerKilledAdd;
 *
 * Public: No
 */
 
params ["_unit"];

/* ================================================================================ */

if (local _unit) then
{
	_index = _unit addEventHandler ["Killed",
	{
		params ["_unit", "_killer", "_instigator", "_useEffects"];

		//_unit removeAllEventHandlers "HitPart";
		//_unit removeAllEventHandlers "Hit";
		
		_unitUid = getPlayerUID _unit;
		_unitSide = side group _unit;
		_killerUid = getPlayerUID _killer;
		_killerSide = side group _killer;
		_instigatorUid = getPlayerUID _instigator;
		_instigatorSide = side group _instigator;
		
		_clientId = clientOwner;
		
		if (getClientState == "BRIEFING READ" && PPS_AllowSendingData && PPS_SendingInfantryData) then
		{				
			_source = "A3";
			_value = 1;
			_type = 2;
			_formatType = 0;
			
			_playerUid = "";
			_key = "";
			_formatString = "";
			
			if (local _unit) then
			{
				if (_unitUid != "") then
				{
					// _eventHandlerInformation = format ["Event Handler 'Killed' fired for local _unit.\n\n_unit: %1 (%2 - %3)\n_killer: %4 (%5 - %6)\n_instigator: %7 (%8 - %9)\nclientId: %10", _unit, _unitUid, _unitSide, _killer, _killerUid, _killerSide, _instigator, _instigatorUid, _instigatorSide, _clientId];
					// hint _eventHandlerInformation;
					// [_eventHandlerInformation] call PPS_fnc_log;
					
					_playerUid = _unitUid;
					if ((_unitUid != _instigatorUid) && !(isNull _instigator)) then
					{
						_key = "countPlayerDeaths";
						_formatString = "STR_PPS_Main_Statistics_Count_Player_Deaths";	
					}
					else
					{
						_key = "countPlayerSuicides";
						_formatString = "STR_PPS_Main_Statistics_Count_Player_Suicides";	
					};
					_updatedData = [_playerUid, [[_key, _value, _type, _formatType, _formatString, _source]]];
					_update = _playerUid + "-updateStatistics";
					missionNamespace setVariable [_update, _updatedData, false];
					publicVariableServer _update;
					
					[format ["[%1] PPS Event Handler 'Killed' fired for local _unit: %2 (%3)", serverTime, _key, _playerUid]] call PPS_fnc_log;
				};
		
				if (_instigatorUid != "") then
				{
					// _eventHandlerInformation = format ["Event Handler 'MPKilled' fired for local _instigator.\n\n_unit: %1 (%2 - %3)\n_killer: %4 (%5 - %6)\n_instigator: %7 (%8 - %9)\nclientId: %10", _unit, _unitUid, _unitSide, _killer, _killerUid, _killerSide, _instigator, _instigatorUid, _instigatorSide, _clientId];
					// hint _eventHandlerInformation;
					// [_eventHandlerInformation] call PPS_fnc_log;
					
					_playerUid = _instigatorUid;
					if (_instigatorSide != _unitSide) then
					{
						_key = "countPlayerKills";
						_formatString = "STR_PPS_Main_Statistics_Count_Player_Kills";	
					}
					else
					{
						if (_instigatorUid != _unitUid) then
						{
							_key = "countPlayerTeamKills";
							_formatString = "STR_PPS_Main_Statistics_Count_Player_Team_Kills";	
						};
					};
					_updatedData = [_playerUid, [[_key, _value, _type, _formatType, _formatString, _source]]];
					_update = _playerUid + "-updateStatistics";
					missionNamespace setVariable [_update, _updatedData, false];
					publicVariableServer _update;
					
					[format ["[%1] PPS Event Handler 'MPKilled' fired for local _instigator: %2 (%3)", serverTime, _key, _playerUid]] call PPS_fnc_log;
				};
			};
		};
	}];
};

[format ["[%1] PPS Event Handler 'MPKilled' added to Unit: (%2)", serverTime, (getPlayerUID _unit)]] call PPS_fnc_log;