/*
 * Author: y0014984
 *
 * Creates the PPS Dialog and adds multiple event handlers to interface elements.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call PPS_fnc_dialogOpen;
 *
 * Public: No
 */

if (hasInterface && isMultiplayer) then
{
	if (PPS_AllowSendingData) then
	{
		_ppsDialog = (findDisplay 46) createDisplay "PPS_Main_Dialog";
		
		[_ppsDialog] call PPS_fnc_dialogEventHandlerKeyUpAdd;
		
		/* ---------------------------------------- */
		
		_filterPlayersEditBox = _ppsDialog displayCtrl 1400;
		_filterPlayersEditBox ctrlAddEventHandler ["SetFocus",
		{
			params ["_control"];
			
			_ppsDialog = (findDisplay 14984);
			_ppsDialog displayRemoveAllEventHandlers "KeyUp";
		}];
		_filterPlayersEditBox ctrlAddEventHandler ["KillFocus",
		{
			params ["_control"];
			
			_ppsDialog = (findDisplay 14984);
			[_ppsDialog] call PPS_fnc_dialogEventHandlerKeyUpAdd;
		}];
		
		/* ---------------------------------------- */
		
		_filterEventsEditBox = _ppsDialog displayCtrl 1401;
		_filterEventsEditBox ctrlAddEventHandler ["SetFocus",
		{
			params ["_control"];
			
			_ppsDialog = (findDisplay 14984);
			_ppsDialog displayRemoveAllEventHandlers "KeyUp";
		}];
		_filterEventsEditBox ctrlAddEventHandler ["KillFocus",
		{
			params ["_control"];
			
			_ppsDialog = (findDisplay 14984);
			[_ppsDialog] call PPS_fnc_dialogEventHandlerKeyUpAdd;
		}];

		/* ---------------------------------------- */
		
		_filterStatisticsEditBox = _ppsDialog displayCtrl 1402;
		_filterStatisticsEditBox ctrlAddEventHandler ["SetFocus",
		{
			params ["_control"];
			
			_ppsDialog = (findDisplay 14984);
			_ppsDialog displayRemoveAllEventHandlers "KeyUp";
		}];
		_filterStatisticsEditBox ctrlAddEventHandler ["KillFocus",
		{
			params ["_control"];
			
			_ppsDialog = (findDisplay 14984);
			[_ppsDialog] call PPS_fnc_dialogEventHandlerKeyUpAdd;
		}];
		
		/* ---------------------------------------- */
		
		_eventEditBox = _ppsDialog displayCtrl 1603;
		_eventEditBox ctrlAddEventHandler ["SetFocus",
		{
			params ["_control"];
			
			_ppsDialog = (findDisplay 14984);
			_ppsDialog displayRemoveAllEventHandlers "KeyUp";
		}];
		_eventEditBox ctrlAddEventHandler ["KillFocus",
		{
			params ["_control"];
			
			_ppsDialog = (findDisplay 14984);
			[_ppsDialog] call PPS_fnc_dialogEventHandlerKeyUpAdd;
		}];
		
		/* ---------------------------------------- */
		
		[] call PPS_fnc_dialogUpdate;
	}
	else
	{
		hint localize "STR_PPS_Main_Notifications_Sending_Data_Not_Allowed";
	};
};