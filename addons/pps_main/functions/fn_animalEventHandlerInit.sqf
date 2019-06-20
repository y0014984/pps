/*
 * Author: y0014984
 *
 * Adds class event handler to every animal.
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

["Animal", "Init", {params ['_entity']; [_entity] spawn PPS_fnc_animalInit;}, nil, nil, true] call CBA_fnc_addClassEventHandler;
