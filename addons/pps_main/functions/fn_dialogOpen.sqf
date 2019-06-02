if (hasInterface && isMultiplayer) then
{
	if (PPS_AllowSendingData) then
	{
		_ppsDialog = (findDisplay 46) createDisplay "PPS_Main_Dialog";
		
		[_ppsDialog] call PPS_fnc_dialogEventHandlerKeyDownAdd;
		
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
			[_ppsDialog] call PPS_fnc_dialogEventHandlerKeyDownAdd;
		}];

		/* ---------------------------------------- */
		
		_filterStatisticsEditBox = _ppsDialog displayCtrl 1401;
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
			[_ppsDialog] call PPS_fnc_dialogEventHandlerKeyDownAdd;
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
			[_ppsDialog] call PPS_fnc_dialogEventHandlerKeyDownAdd;
		}];
		
		/* ---------------------------------------- */
		
		[] call PPS_fnc_dialogUpdate;
	}
	else
	{
		hint localize "STR_PPS_Main_Notifications_Sending_Data_Not_Allowed";
	};
};