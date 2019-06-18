/*
 * Author: y0014984
 *
 * Adds KeyUp Event Handler to given Dialog
 *
 * Arguments:
 * 1: _ppsDialog <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ppsDialog] call PPS_fnc_dialogEventHandlerKeyUpAdd;
 *
 * Public: No
 */

params ["_ppsDialog"];	

_ppsDialog displayAddEventHandler ["KeyUp", 
{
	params ["_displayorcontrol", "_key", "_shift", "_ctrl", "_alt"];	

	_entry = ["PPS", "ppsDialogOpen"] call CBA_fnc_getKeybind;
	_firstKeybind = _entry select 5;
	
	_ppsKey = _firstKeybind select 0;
	_ppsModifiers = _firstKeybind select 1;
	
	_ppsShift = _ppsModifiers select 0;
	_ppsCtrl = _ppsModifiers select 1;
	_ppsAlt = _ppsModifiers select 2;
	
	_ppsDialog = (findDisplay 14984);
	
	//hint str _displayorcontrol;

	if ((_key == _ppsKey) && (_shift isEqualTo _ppsShift) && (_ctrl isEqualTo _ppsCtrl) && (_alt isEqualTo _ppsAlt)) then	
	{
		_ppsDialog closeDisplay 1;
	};
}];