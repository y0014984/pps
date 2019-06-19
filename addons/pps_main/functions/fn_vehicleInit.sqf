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

if (isMultiplayer) then
{
	_index = _vehicle addEventHandler ["Engine",
	{
		params ["_vehicle", "_engineState"];
		
		//hint format ["Vehicle: %1\nengineState: %2", _vehicle, _engineState];
		
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
	
	/* ================================================================================ */
};