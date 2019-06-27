/*
 * Author: y0014984
 *
 * Initializes units and adds several event handlers.
 *
 * Arguments:
 * 0: _unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit] spawn PPS_fnc_unitInit;
 *
 * Public: No
 */

params ["_unit"];

//waitUntil {time > 15};

/* ================================================================================ */

if (isMultiplayer) then
{

	//[_unit] call PPS_fnc_unitEventHandlerMPKilledAdd;
	[_unit] call PPS_fnc_unitEventHandlerKilledAdd;
	
	/* ================================================================================ */

	//[_unit] call PPS_fnc_unitEventHandlerHitPartAdd;
	[_unit] call PPS_fnc_unitEventHandlerHitAdd;
};

/* ================================================================================ */

_player = _unit;
_playerUid = getPlayerUID _unit;

if ((local _player) && _playerUid != "" && hasInterface && isMultiplayer) then
{
	[] call PPS_fnc_playerInit;
};

/* ================================================================================ */
