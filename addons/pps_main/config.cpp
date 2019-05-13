#include "defines.hpp"
#include "dialogs.hpp"

enableDebugConsole = 1;

class CfgPatches
{
	class pps_main
	{
		// Meta information for editor
		name = "Persistent Player Statistics";
		author = "y0014984";
		url = "https://github.com/y0014984/PPS";

		// Minimum compatible version. When the game's version is lower, pop-up warning will appear when launching the game.
		requiredVersion = 1.92;
		// Required addons, used for setting load order.
		// When any of the addons is missing, pop-up warning will appear when launching the game.
		requiredAddons[] = {"inidbi2", 
		"cba_main", "cba_main_a3", "cba_events", "cba_common", "cba_xeh", "cba_settings", "cba_ui", "cba_keybinding", "cba_versioning", 
		"ace_main", 
		"tfar_core"};
		// List of objects (CfgVehicles classes) contained in the addon. Important also for Zeus content unlocking.
		units[] = {};
		// List of weapons (CfgWeapons classes) contained in the addon.
		weapons[] = {};
		version = 1.0.1;
		versionStr = "1.0.1";
		versionAr[] = {1,0,1};
	};
};

class CfgMods
{
    class PPS
	{

        dir = "@PPS";
        name = "Persistent Player Statistics";
        hideName = "true";
		picture = "A3\Ui_f\data\Logos\arma3_expansion_alpha_ca";
        hidePicture = "true";
        actionName = "Website";
        action = "https://github.com/y0014984/PPS";
        description = "https://github.com/y0014984/PPS";
    };
};

class CfgSettings
{
   class CBA
{
      class Versioning
	  {
         // This registers MyMod with the versioning system and looks for version info at CfgPatches -> MyMod_main
         class PPS
		 {
           // Optional: Manually specify the Main Addon for this mod
           main_addon = "pps_main"; // Uncomment and specify this to manually define the Main Addon (CfgPatches entry) of the mod

           // Optional: Add a custom handler function triggered upon version mismatch
           //handler = "myMod_fnc_mismatch"; // Adds a custom script function that will be triggered on version mismatch. Make sure this function is compiled at a called preInit, not spawn/execVM

           // Optional: Dependencies
           // Example: Dependency on CBA
           /*
            class Dependencies {
               CBA[]={"cba_main", {0,8,0}, "true"};
            };
           */

           // Optional: Removed addons Upgrade registry
           // Example: myMod_addon1 was removed and it's important the user doesn't still have it loaded
           //removed[] = {"myMod_addon1"};
         };
      };
   };
};

class Extended_PreInit_EventHandlers
{
	PPS_PreInit = call compile preprocessFileLineNumbers "y\pps\addons\pps_main\XEH_preInit.sqf";
	
	class PPS_PreInits
	{
        // Like the normal preinit above, this one runs on all machines
        init = "";

        // This code will be executed once and only on the server
        serverInit = "";

        // This snippet runs once and only on client machines
        clientInit = call compile preprocessFileLineNumbers "y\pps\addons\pps_main\XEH_clientInit.sqf";
	};
};

class CfgFunctions
{
	class PPS
	{
		tag = "PPS"; //Custom tag name
		class ppsFunctions
		{
			requiredAddons[] = {}; //Optional requirements of CfgPatches classes. When some addons are missing, functions won't be compiled.
			file = "y\pps\addons\pps_main\functions";

			class initServer
			{
				preInit = 0; //(formerly known as "forced") 1 to call the function upon mission start, before objects are initialized. Passed arguments are ["preInit"]
				postInit = 1; //1 to call the function upon mission start, after objects are initialized. Passed arguments are ["postInit", didJIP]
				preStart = 0; //1 to call the function upon game start, before title screen, but after all addons are loaded (config.cpp only)
				ext = ".sqf"; //Set file type, can be ".sqf" or ".fsm" (meaning scripted FSM). Default is ".sqf".
				headerType = -1; //Set function header type: -1 - no header; 0 - default header; 1 - system header.
				//recompile = 1; //1 to recompile the function upon mission start (config.cpp only; functions in description.ext are compiled upon mission start already)
			};
			class initServerEventHandler
			{
				preInit = 0; //(formerly known as "forced") 1 to call the function upon mission start, before objects are initialized. Passed arguments are ["preInit"]
				postInit = 0; //1 to call the function upon mission start, after objects are initialized. Passed arguments are ["postInit", didJIP]
				preStart = 0; //1 to call the function upon game start, before title screen, but after all addons are loaded (config.cpp only)
				ext = ".sqf"; //Set file type, can be ".sqf" or ".fsm" (meaning scripted FSM). Default is ".sqf".
				headerType = -1; //Set function header type: -1 - no header; 0 - default header; 1 - system header.
				//recompile = 1; //1 to recompile the function upon mission start (config.cpp only; functions in description.ext are compiled upon mission start already)
			};
			class initUnitEventHandler
			{
				preInit = 0; //(formerly known as "forced") 1 to call the function upon mission start, before objects are initialized. Passed arguments are ["preInit"]
				postInit = 1; //1 to call the function upon mission start, after objects are initialized. Passed arguments are ["postInit", didJIP]
				preStart = 0; //1 to call the function upon game start, before title screen, but after all addons are loaded (config.cpp only)
				ext = ".sqf"; //Set file type, can be ".sqf" or ".fsm" (meaning scripted FSM). Default is ".sqf".
				headerType = -1; //Set function header type: -1 - no header; 0 - default header; 1 - system header.
				//recompile = 1; //1 to recompile the function upon mission start (config.cpp only; functions in description.ext are compiled upon mission start already)
			};
			class initUnit
			{
				preInit = 0; //(formerly known as "forced") 1 to call the function upon mission start, before objects are initialized. Passed arguments are ["preInit"]
				postInit = 0; //1 to call the function upon mission start, after objects are initialized. Passed arguments are ["postInit", didJIP]
				preStart = 0; //1 to call the function upon game start, before title screen, but after all addons are loaded (config.cpp only)
				ext = ".sqf"; //Set file type, can be ".sqf" or ".fsm" (meaning scripted FSM). Default is ".sqf".
				headerType = -1; //Set function header type: -1 - no header; 0 - default header; 1 - system header.
				//recompile = 1; //1 to recompile the function upon mission start (config.cpp only; functions in description.ext are compiled upon mission start already)
			};
			class openPpsDialog
			{
				preInit = 0; //(formerly known as "forced") 1 to call the function upon mission start, before objects are initialized. Passed arguments are ["preInit"]
				postInit = 0; //1 to call the function upon mission start, after objects are initialized. Passed arguments are ["postInit", didJIP]
				preStart = 0; //1 to call the function upon game start, before title screen, but after all addons are loaded (config.cpp only)
				ext = ".sqf"; //Set file type, can be ".sqf" or ".fsm" (meaning scripted FSM). Default is ".sqf".
				headerType = -1; //Set function header type: -1 - no header; 0 - default header; 1 - system header.
				//recompile = 1; //1 to recompile the function upon mission start (config.cpp only; functions in description.ext are compiled upon mission start already)
			};
			class ppsDialogEventButton
			{
				preInit = 0; //(formerly known as "forced") 1 to call the function upon mission start, before objects are initialized. Passed arguments are ["preInit"]
				postInit = 0; //1 to call the function upon mission start, after objects are initialized. Passed arguments are ["postInit", didJIP]
				preStart = 0; //1 to call the function upon game start, before title screen, but after all addons are loaded (config.cpp only)
				ext = ".sqf"; //Set file type, can be ".sqf" or ".fsm" (meaning scripted FSM). Default is ".sqf".
				headerType = -1; //Set function header type: -1 - no header; 0 - default header; 1 - system header.
				//recompile = 1; //1 to recompile the function upon mission start (config.cpp only; functions in description.ext are compiled upon mission start already)
			};
			class ppsDialogAdminButton
			{
				preInit = 0; //(formerly known as "forced") 1 to call the function upon mission start, before objects are initialized. Passed arguments are ["preInit"]
				postInit = 0; //1 to call the function upon mission start, after objects are initialized. Passed arguments are ["postInit", didJIP]
				preStart = 0; //1 to call the function upon game start, before title screen, but after all addons are loaded (config.cpp only)
				ext = ".sqf"; //Set file type, can be ".sqf" or ".fsm" (meaning scripted FSM). Default is ".sqf".
				headerType = -1; //Set function header type: -1 - no header; 0 - default header; 1 - system header.
				//recompile = 1; //1 to recompile the function upon mission start (config.cpp only; functions in description.ext are compiled upon mission start already)
			};
			class ppsDialogUpdate
			{
				preInit = 0; //(formerly known as "forced") 1 to call the function upon mission start, before objects are initialized. Passed arguments are ["preInit"]
				postInit = 0; //1 to call the function upon mission start, after objects are initialized. Passed arguments are ["postInit", didJIP]
				preStart = 0; //1 to call the function upon game start, before title screen, but after all addons are loaded (config.cpp only)
				ext = ".sqf"; //Set file type, can be ".sqf" or ".fsm" (meaning scripted FSM). Default is ".sqf".
				headerType = -1; //Set function header type: -1 - no header; 0 - default header; 1 - system header.
				//recompile = 1; //1 to recompile the function upon mission start (config.cpp only; functions in description.ext are compiled upon mission start already)
			};
		};
	};
};