if (hasInterface && isMultiplayer) then
{
	if (PPS_AllowSendingData) then
	{
		_ppsDialog = (findDisplay 46) createDisplay "PPS_Main_Dialog";
		
		[_ppsDialog] call PPS_fnc_ppsDialogAddKeyDownEventHandler;
		
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
			[_ppsDialog] call PPS_fnc_ppsDialogAddKeyDownEventHandler;
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
			[_ppsDialog] call PPS_fnc_ppsDialogAddKeyDownEventHandler;
		}];
		
		/* ---------------------------------------- */
		
		_eventText = _ppsDialog displayCtrl 1603;
		_eventText ctrlAddEventHandler ["SetFocus",
		{
			params ["_control"];
			
			_ppsDialog = (findDisplay 14984);
			_ppsDialog displayRemoveAllEventHandlers "KeyUp";
		}];
		_eventText ctrlAddEventHandler ["KillFocus",
		{
			params ["_control"];
			
			_ppsDialog = (findDisplay 14984);
			[_ppsDialog] call PPS_fnc_ppsDialogAddKeyDownEventHandler;
		}];
		
		/* ---------------------------------------- */
		
		[] call PPS_fnc_ppsDialogUpdate;
	}
	else
	{
		hint "PPS_AllowSendingData disabled";
	};
};