_playerUid = getPlayerUID player;

if ((_playerUid != "_SP_PLAYER_") && (hasInterface) && (getClientState == "BRIEFING READ")) then
{
	if(dialog) then
	{
		closeDialog 0;
	}
	else
	{
		if (PPS_AllowSendingData) then
		{
			_ok = createDialog "PPS_Main_Dialog";
			if (!_ok) then {hint "createDialog failed"};

			[] call PPS_fnc_ppsDialogUpdate;
		};
	};
};