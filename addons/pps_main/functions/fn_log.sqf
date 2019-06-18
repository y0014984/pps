/*
 * Author: y0014984
 *
 * Logging function for client and server. Depends on Logging Setting Value.
 *
 * Arguments:
 * 0: _logString <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [format ["%1 is speaking %2", name _unit, _isSpeaking]] call PPS_fnc_log;
 *
 * Public: No
 */

params ["_logString"];

if (isServer && PPS_ServerLogging) then {diag_log _logString};
if (hasInterface && PPS_ClientLogging) then {diag_log _logString};