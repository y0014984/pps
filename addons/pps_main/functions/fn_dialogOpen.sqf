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
		_serverAdminStatus = call BIS_fnc_admin;
		if (_serverAdminStatus == 2) then 
		{
			_playerUid = getPlayerUID player;
			_clientId = clientOwner;
			_request = _playerUid + "-requestSetServerAdminToPpsAdmin";
			missionNamespace setVariable [_request, [_playerUid, _clientId], false];
			publicVariableServer _request;
		};
		
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
		
		_eventsListBox = (findDisplay 14984) displayCtrl 1501;
		_eventsListBox ctrlAddEventHandler ["MouseButtonDblClick",
		{
			params ["_control"];

			_playerUid = getPlayerUID player;
			_clientId = clientOwner;
			_dataType = "event";
			
			_eventsListBox = (findDisplay 14984) displayCtrl 1501;
			_selectedEventIndex = lbCurSel _eventsListBox;
			_requestedEventId = _eventsListBox lbData _selectedEventIndex;
			
			_request = _playerUid + "-requestDetails";
			missionNamespace setVariable [_request, [_playerUid, _clientId, _dataType, _requestedEventId], false];
			publicVariableServer _request;
		}];
		
		/* ---------------------------------------- */
		
		_playersListBox = (findDisplay 14984) displayCtrl 1500;
		_playersListBox ctrlAddEventHandler ["MouseButtonDblClick",
		{
			params ["_control"];

			_playerUid = getPlayerUID player;
			_clientId = clientOwner;
			_dataType = "player";
			
			_playersListBox = (findDisplay 14984) displayCtrl 1500;
			_selectedPlayerIndex = lbCurSel _playersListBox;
			_requestedPlayerUid = _playersListBox lbData _selectedPlayerIndex;
			
			_request = _playerUid + "-requestDetails";
			missionNamespace setVariable [_request, [_playerUid, _clientId, _dataType, _requestedPlayerUid], false];
			publicVariableServer _request;
		}];
		
		/* ---------------------------------------- */

		[] call PPS_fnc_dialogUpdate;
	}
	else
	{
		hint localize "STR_PPS_Main_Notifications_Sending_Data_Not_Allowed";
	};
};