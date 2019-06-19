/*
 * Author: y0014984
 *
 * Updates the content of the PPS Dialog.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call PPS_fnc_dialogUpdate;
 *
 * Public: No
 */

_playerUid = getPlayerUID player;
_clientId = clientOwner;

/* ================================================================================ */

_playersListBox = (findDisplay 14984) displayCtrl 1500;
_playersListBox ctrlAddEventHandler ["LBSelChanged",
{
	params ["_control", "_selectedIndex"];

	if (_selectedIndex != -1) then
	{
		_requestedPlayerUid = _control lbData _selectedIndex;
		
		_playerUid = getPlayerUID player;
		_clientId = clientOwner;
		
		_filterEventsEditBox = (findDisplay 14984) displayCtrl 1401;
		_filterEvents = ctrlText _filterEventsEditBox;
	
		_request = _playerUid + "-requestEventsFiltered";
		missionNamespace setVariable [_request, [_playerUid, _clientId, _requestedPlayerUid, _filterEvents], false];
		publicVariableServer _request;
	};
}];

/* ================================================================================ */

_filterPlayersEditBox = (findDisplay 14984) displayCtrl 1400;
_filterPlayersEditBox ctrlAddEventHandler ["KeyUp",
{
	params ["_displayorcontrol", "_key", "_shift", "_ctrl", "_alt"];

	if ((_key == 28) || (_key == 156)) then
	{
		_playerUid = getPlayerUID player;
		_clientId = clientOwner;
		
		_filterPlayersEditBox = (findDisplay 14984) displayCtrl 1400;
		_filterPlayers = ctrlText _filterPlayersEditBox;
	
		_filterEventsEditBox = (findDisplay 14984) displayCtrl 1401;
		_filterEvents = ctrlText _filterEventsEditBox;

		_request = _playerUid + "-requestDialogUpdate";
		missionNamespace setVariable [_request, [_playerUid, _clientId, _filterPlayers, _filterEvents], false];
		publicVariableServer _request;
	};
}];

/* ================================================================================ */

_eventsListBox = (findDisplay 14984) displayCtrl 1501;
_eventsListBox ctrlAddEventHandler ["LBSelChanged",
{
	params ["_control", "_selectedIndex"];

	if (_selectedIndex != -1) then
	{
		_playersListBox = (findDisplay 14984) displayCtrl 1500;
		_selectedPlayerIndex = lbCurSel _playersListBox;
		_requestedPlayerUid = _playersListBox lbData _selectedPlayerIndex;
		
		_requestedEventId = _control lbData _selectedIndex;
		
		_playerUid = getPlayerUID player;
		_clientId = clientOwner;
		
		_filterStatisticsEditBox = (findDisplay 14984) displayCtrl 1402;
		_filterStatistics = ctrlText _filterStatisticsEditBox;
	
		_request = _playerUid + "-requestStatisticsFiltered";
		missionNamespace setVariable [_request, [_playerUid, _clientId, _requestedPlayerUid, _requestedEventId, _filterStatistics], false];
		publicVariableServer _request;
	};
}];

/* ================================================================================ */

_statisticsListBox = (findDisplay 14984) displayCtrl 1502;
_statisticsListBox ctrlAddEventHandler ["LBSelChanged",
{
	params ["_control", "_selectedIndex"];

	if (PPS_isTrackStatisticsActive && (_selectedIndex != -1)) then
	{
		_statisticsListBox = (findDisplay 14984) displayCtrl 1502;
		_statisticsKey = _statisticsListBox lbData _selectedIndex;
		_trackStatisticsButton = (findDisplay 14984) displayCtrl 1604;
		
		if (PPS_trackStatisticsKey == _statisticsKey) then
		{
			_trackStatisticsButton ctrlSetText localize "STR_PPS_Main_Dialog_Button_Track_Value_Off";
		}
		else
		{
			_trackStatisticsButton ctrlSetText localize "STR_PPS_Main_Dialog_Button_Track_Value_On";
		};
	};
}];

/* ================================================================================ */

_filterEventsEditBox = (findDisplay 14984) displayCtrl 1401;
_filterEventsEditBox ctrlAddEventHandler ["KeyUp",
{
	params ["_displayorcontrol", "_key", "_shift", "_ctrl", "_alt"];

	if ((_key == 28) || (_key == 156)) then
	{
		_playerUid = getPlayerUID player;
		_clientId = clientOwner;

		_filterPlayersEditBox = (findDisplay 14984) displayCtrl 1400;
		_filterPlayers = ctrlText _filterPlayersEditBox;

		_filterEventsEditBox = (findDisplay 14984) displayCtrl 1401;
		_filterEvents = ctrlText _filterEventsEditBox;

		_request = _playerUid + "-requestDialogUpdate";
		missionNamespace setVariable [_request, [_playerUid, _clientId, _filterPlayers, _filterEvents], false];
		publicVariableServer _request;
	};
}];

/* ================================================================================ */

_filterStatisticsEditBox = (findDisplay 14984) displayCtrl 1402;
_filterStatisticsEditBox ctrlAddEventHandler ["KeyUp",
{
	params ["_displayorcontrol", "_key", "_shift", "_ctrl", "_alt"];

	_filterStatisticsEditBox = (findDisplay 14984) displayCtrl 1402;
	
	_playersListBox = (findDisplay 14984) displayCtrl 1500;
	_selectedPlayerIndex = lbCurSel _playersListBox;
	_requestedPlayerUid = _playersListBox lbData _selectedPlayerIndex;
	_eventsListBox = (findDisplay 14984) displayCtrl 1501;
	_selectedEventIndex = lbCurSel _eventsListBox;
	_requestedEventId = _eventsListBox lbData _selectedEventIndex;
	
	if ((_key == 28) || (_key == 156)) then
	{
		_playerUid = getPlayerUID player;
		_clientId = clientOwner;
		_filterStatistics = ctrlText _filterStatisticsEditBox;
		
		_request = _playerUid + "-requestStatisticsFiltered";
		missionNamespace setVariable [_request, [_playerUid, _clientId, _requestedPlayerUid, _requestedEventId, _filterStatistics], false];
		publicVariableServer _request;
	};
}];

/* ================================================================================ */

_answer = _playerUid + "-answerDialogUpdate";
_answer addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];

	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;	
	_isAdmin = _broadcastVariableValue select 2;
	_isAdminLoggedIn = _broadcastVariableValue select 3;
	_countPlayersTotal = _broadcastVariableValue select 4;
	_countPlayersOnline = _broadcastVariableValue select 5;
	_countAdminsTotal = _broadcastVariableValue select 6;
	_countAdminsOnline = _broadcastVariableValue select 7;
	_countEventsTotal = _broadcastVariableValue select 8;
	_filteredPlayers = _broadcastVariableValue select 9;

	_activeEventStartTime = +PPS_eventStartTime;
	
	_statusServer = false;
	if (!isNil "PPS_statusServer") then {_statusServer =  PPS_statusServer;};
	_versionServer = localize "STR_PPS_Main_Unknown";
	if (!isNil "PPS_versionServer") then {_versionServer = PPS_versionServer;};
	_statusDatabase = false;
	if (!isNil "PPS_statusDatabase") then {_statusDatabase =  PPS_statusDatabase;};
	_versionDatabase = localize "STR_PPS_Main_Unknown";
	if (!isNil "PPS_versionDatabase") then {_versionDatabase = PPS_versionDatabase;};

	_headlineText = (findDisplay 14984) displayCtrl 1000;
	_serverAndDatabaseStatusText = (findDisplay 14984) displayCtrl 1001;
	_playersAndAdminsCountText = (findDisplay 14984) displayCtrl 1002;
	_playersListBox = (findDisplay 14984) displayCtrl 1500;
	lbClear _playersListBox;
	_playersListBox lbSetCurSel -1;
	_eventsListBox = (findDisplay 14984) displayCtrl 1501;
	lbClear _eventsListBox;
	_eventsListBox lbSetCurSel -1;
	_statisticsListBox = (findDisplay 14984) displayCtrl 1502;
	lbClear _statisticsListBox;
	_statisticsListBox lbSetCurSel -1;
	_adminButton = (findDisplay 14984) displayCtrl 1600;
	_eventStartButton = (findDisplay 14984) displayCtrl 1602;
	_eventStopButton = (findDisplay 14984) displayCtrl 1607;
	_eventContinueButton = (findDisplay 14984) displayCtrl 1606;
	_eventDeleteButton = (findDisplay 14984) displayCtrl 1608;
	_continueButton = (findDisplay 14984) displayCtrl 1606;
	_trackStatisticsButton = (findDisplay 14984) displayCtrl 1604;
	_promoteButton = (findDisplay 14984) displayCtrl 1610;
	
	if (_statusServer) then {_statusServer = localize "STR_PPS_Main_Online"} else {_statusServer = localize "STR_PPS_Main_Offline"};
	if (_statusDatabase) then {_statusDatabase = localize "STR_PPS_Main_Online"} else {_statusDatabase = localize "STR_PPS_Main_Offline"};
	
	_serverAndDatabaseStatusText ctrlSetText format [localize "STR_PPS_Main_Dialog_Server_Status", format ["%1 [%2]", _statusServer, _versionServer],  format ["%1 [%2]", _statusDatabase, _versionDatabase]];
	_playersAndAdminsCountText ctrlSetText format [localize "STR_PPS_Main_Dialog_Player_Status",_countPlayersTotal , _countPlayersOnline, _countAdminsTotal, _countAdminsOnline, _countEventsTotal];

	if (_isAdminLoggedIn) then
	{
		_adminButton ctrlSetText localize "STR_PPS_Main_Dialog_Button_Logout";
		_eventStartButton ctrlShow true;
		_eventStopButton ctrlShow true;
		_eventContinueButton ctrlShow true;
		_eventDeleteButton ctrlShow true;
		_eventEditBox ctrlShow true;
		_continueButton ctrlShow true;
		_promoteButton ctrlShow true;
	}
	else
	{
		_adminButton ctrlSetText localize "STR_PPS_Main_Dialog_Button_Login";
		_eventStartButton ctrlShow false;
		_eventStopButton ctrlShow false;
		_eventContinueButton ctrlShow false;
		_eventDeleteButton ctrlShow false;
		_eventEditBox ctrlShow false;
		_continueButton ctrlShow false;
		_promoteButton ctrlShow false;
	};

	_noEvent = localize "STR_PPS_Main_Dialog_No_Event";
	
	if (PPS_isEvent) then
	{
		{
			if(_x < 10) then
			{
				_activeEventStartTime set [_forEachIndex, format ["0%1", str _x]];
			}
			else
			{
				_activeEventStartTime set [_forEachIndex, str _x];
			};
		} forEach _activeEventStartTime;
		_year = _activeEventStartTime select 0;
		_month = _activeEventStartTime select 1;
		_day = _activeEventStartTime select 2;
		_hours = _activeEventStartTime select 3;
		_minutes = _activeEventStartTime select 4;
		_seconds = _activeEventStartTime select 5;
		_timeZone = PPS_TimeZone;
		if (PPS_SummerTime) then {_timeZone = _timeZone + 1;};
		_headlineText ctrlSetBackgroundColor [0.5, 0, 0, 1];
		_headlineText ctrlSetText format [localize "STR_PPS_Main_Dialog_Head_Time", PPS_eventName, _hours, _minutes, _seconds, _timeZone];
	}
	else
	{
		_headlineText ctrlSetBackgroundColor [0, 0.5, 0, 1];
		_headlineText ctrlSetText format [localize "STR_PPS_Main_Dialog_Head", _noEvent];
	};		

	_filteredPlayers sort true;
	{
		_dbPlayerName = _x select 0;
		_dbPlayerUid = _x select 1;
		_dbPlayerIsAdmin = _x select 2;
		_dbPlayerIsAdminLoggedIn = _x select 3;
		_dbPlayerIsTrackStatisticsActive = _x select 4;
		_dbPlayerTrackStatisticsKey = _x select 5;
		_dbPlayerStatus = _x select 6;
		
		if (_dbPlayerIsAdmin) then {_dbPlayerIsAdmin = localize "STR_PPS_Main_Admin";} else {_dbPlayerIsAdmin = localize "STR_PPS_Main_Player";};

		if (_dbPlayerStatus) then {_dbPlayerStatus = " " + (localize "STR_PPS_Main_Online");} else {_dbPlayerStatus = " " + (localize "STR_PPS_Main_Offline");};

		if (_dbPlayerIsAdminLoggedIn) then {_dbPlayerIsAdminLoggedIn = " " + (localize "STR_PPS_Main_Logged_In");} else {_dbPlayerIsAdminLoggedIn = "";};
		
		if ((_dbPlayerUid == _playerUid) && _dbPlayerIsTrackStatisticsActive) then
		{
			_trackStatisticsButton ctrlSetText localize "STR_PPS_Main_Dialog_Button_Track_Value_Off";
		};
		if ((_dbPlayerUid == _playerUid) && !_dbPlayerIsTrackStatisticsActive) then
		{
			_trackStatisticsButton ctrlSetText localize "STR_PPS_Main_Dialog_Button_Track_Value_On";
		};
		
		_index = _playersListBox lbAdd format ["%1 (%2%3%4)",_dbPlayerName, _dbPlayerIsAdmin, _dbPlayerStatus, _dbPlayerIsAdminLoggedIn];	
		_playersListBox lbSetData [_index, _dbPlayerUid];
		if(_dbPlayerUid == _playerUid) then
		{
			_playersListBox lbSetColor [_index, [1, 0.5, 0.5, 1]];
			_playersListBox lbSetCurSel _index;
		};
	} forEach _filteredPlayers;
	
	ctrlSetFocus _playersListBox;
};

/* ================================================================================ */

_answer = _playerUid + "-answerEventsFiltered";
_answer addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];

	_playerUid = _broadcastVariableValue select 0;
	_clientId = _broadcastVariableValue select 1;	
	_isAdmin = _broadcastVariableValue select 2;
	_isAdminLoggedIn = _broadcastVariableValue select 3;
	_filteredEvents = _broadcastVariableValue select 4;
	
	_eventsListBox = (findDisplay 14984) displayCtrl 1501;
	lbClear _eventsListBox;
	_eventsListBox lbSetCurSel -1;
	
	_statisticsListBox = (findDisplay 14984) displayCtrl 1502;
	lbClear _statisticsListBox;
	_statisticsListBox lbSetCurSel -1;

	_filteredEvents sort true;
	{
		_dbEventId = _x select 0;
		_dbEventName = _x select 1;
		_dbEventStartTime = _x select 2;
		_dbEventDuration = _x select 3;
		
		_year = str (_dbEventStartTime select 0);
		_month = _dbEventStartTime select 1;
		if (_month < 10) then {_month = format ["0%1", _month];} else {_month = str _month};
		_day = _dbEventStartTime select 2;
		if (_day < 10) then {_day = format ["0%1", _day];} else {_day = str _day};
		
		_index = _eventsListBox lbAdd format ["%1-%2-%3 %4 (%5 min.)", _year, _month, _day, _dbEventName, _dbEventDuration];	
		_eventsListBox lbSetData [_index, _dbEventId];

		if(PPS_isEvent &&(_dbEventId == PPS_eventId)) then
		{
			_eventsListBox lbSetColor [_index, [1, 0.5, 0.5, 1]];
			_eventsListBox lbSetCurSel _index;
			_text = _eventsListBox lbText _index;
			_eventsListBox lbSetText [_index, format [localize "STR_PPS_Main_Dialog_List_Event_Active", _text]];
		};
	} forEach _filteredEvents;
	
	ctrlSetFocus _eventsListBox;
};

/* ================================================================================ */

_answer = _playerUid + "-answerStatisticsFiltered";
_answer addPublicVariableEventHandler
{
	params ["_broadcastVariableName", "_broadcastVariableValue", "_broadcastVariableTarget"];
	
	_playerStatistics = _broadcastVariableValue select 0;
	_isTrackStatisticsActive = _broadcastVariableValue select 1;
	_trackStatisticsKey = _broadcastVariableValue select 2;

	_statisticsListBox = (findDisplay 14984) displayCtrl 1502;
	lbClear _statisticsListBox;
	_statisticsListBox lbSetCurSel -1;
	
	_playerStatistics sort true;
	{
		_key = _x select 0;
		_formatString = _x select 1;
		_source = _x select 2;
		_valueOne = _x select 3;
		_valueTwo = _x select 4;
		_valueThree = _x select 5;
		
		_statisticsText = (format ["[%1]", _source]) + " " + (format [(localize _formatString), _valueOne, _valueTwo, _valueThree]);
		
		if ((_isTrackStatisticsActive) && (_trackStatisticsKey == _key)) then
		{
			_index = _statisticsListBox lbAdd (format [localize "STR_PPS_Main_Dialog_List_Tracking_Active", _statisticsText]);
			_statisticsListBox lbSetData [_index, _key];
			
			_statisticsListBox lbSetColor [_index, [1, 0.5, 0.5, 1]];
			_statisticsListBox lbSetCurSel _index;
		}
		else
		{
			_index = _statisticsListBox lbAdd _statisticsText;
			_statisticsListBox lbSetData [_index, _key];
		};
	} forEach _playerStatistics;
};

/* ================================================================================ */

_filterPlayersEditBox = (findDisplay 14984) displayCtrl 1400;
_filterPlayers = ctrlText _filterPlayersEditBox;

_request = _playerUid + "-requestDialogUpdate";
missionNamespace setVariable [_request, [_playerUid, _clientId, _filterPlayers], false];
publicVariableServer _request;

/* ================================================================================ */
