#include "defines.hpp"
#include "dialog.hpp"

enableDebugConsole = 0;
// 0 - Default behavior, available only in editor
// 1 - Available in SP and for hosts / logged in admins in MP
// 2 - Available for everyone

class CfgPatches
{
	class pps_main
	{
		// Meta information for editor
		name = "Persistent Player Statistics";
		author = "y0014984";
		url = "https://github.com/y0014984/pps";

		// Minimum compatible version. When the game's version is lower, pop-up warning will appear when launching the game.
		requiredVersion = 1.92;
		// Required addons, used for setting load order.
		// When any of the addons is missing, pop-up warning will appear when launching the game.
		requiredAddons[] = {"cba_main", "cba_main_a3", "cba_events", "cba_common", "cba_xeh", "cba_settings", "cba_ui", "cba_keybinding", "cba_versioning"};
		// List of objects (CfgVehicles classes) contained in the addon. Important also for Zeus content unlocking.
		units[] = {};
		// List of weapons (CfgWeapons classes) contained in the addon.
		weapons[] = {};
		version = 0.4.2;
		versionStr = "0.4.2";
		versionAr[] = {0,4,2};
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
        action = "https://github.com/y0014984/pps";
        description = "https://github.com/y0014984/pps";
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

#include "CfgFunctions.hpp"