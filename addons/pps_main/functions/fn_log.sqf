params ["_logString"];

if (isServer && PPS_ServerLogging) then {diag_log _logString};
if (hasInterface && PPS_ClientLogging) then {diag_log _logString};