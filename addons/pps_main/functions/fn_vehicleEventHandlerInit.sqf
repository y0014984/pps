/*
 * Author: y0014984
 *
 * Adds class event handler to every vehicle.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * None. Is executed on postInit.
 *
 * Public: No
 */

["AllVehicles", "Init", {params ['_entity']; [_entity] spawn PPS_fnc_vehicleInit;}, nil, nil, true] call CBA_fnc_addClassEventHandler;
