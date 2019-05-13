_playerUid = getPlayerUID player;
_playerName = name player;
_clientId = clientOwner;

if (_playerUid != "_SP_PLAYER_" && hasInterface && getClientState == "BRIEFING READ") then
{
	if(dialog) then
	{
		closeDialog 1;
	}
	else
	{
		if (PPS_AllowSendingData) then
		{
			_handle = createDialog "PPS_Main_Dialog";

			[_playerUid, _playerName, _clientId] call PPS_fnc_ppsDialogUpdate;
		};
	};
};