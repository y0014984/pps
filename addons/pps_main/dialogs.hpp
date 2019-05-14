/*

STRG + I für den Import aus dem Config File:
	configfile >> "PPS_Main_Dialog"

*/

class PPS_Main_Dialog
{
	idd = -1;
	movingEnable = true;
	enableSimulation = true;
	class controls
	{	
		////////////////////////////////////////////////////////
		// GUI EDITOR OUTPUT START (by y0014984|Sebastian, v1.063, #Wytyno)
		////////////////////////////////////////////////////////

		class PPS_RscText_1000: PPS_RscText
		{
			idc = 1000;
			text = "Persistent Player Statistics - Event in Progress: Unknown"; //--- ToDo: Localize;
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 0 * GUI_GRID_H + GUI_GRID_Y;
			w = 40 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			colorBackground[] = {-1,0.5,-1,1};
		};
		class PPS_RscText_1001: PPS_RscText
		{
			idc = 1001;
			text = "Server Status: Unknown - Database Status: Unknown"; //--- ToDo: Localize;
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 1.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 40 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			colorBackground[] = {0,0,0,0.25};
		};
		class PPS_RscText_1002: PPS_RscText
		{
			idc = 1002;
			text = "Players Total: Unknown - Players Online: Unknown - Admins Total: Unknown - Admins Online: Unknown"; //--- ToDo: Localize;
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 3 * GUI_GRID_H + GUI_GRID_Y;
			w = 40 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			colorBackground[] = {0,0,0,0.25};
		};
		class PPS_RscEdit_1400: PPS_RscEdit
		{
			idc = 1400;
			text = ""; //--- ToDo: Localize;
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 4.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 14.5 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			colorBackground[] = {0,0,0,0.5};
		};
		class PPS_RscEdit_1401: PPS_RscEdit
		{
			idc = 1401;
			text = ""; //--- ToDo: Localize;
			x = 15 * GUI_GRID_W + GUI_GRID_X;
			y = 4.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 25 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			colorBackground[] = {0,0,0,0.5};
		};
		class PPS_RscListbox_1500: PPS_RscListbox
		{
			idc = 1500;
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 6 * GUI_GRID_H + GUI_GRID_Y;
			w = 14.5 * GUI_GRID_W;
			h = 17.5 * GUI_GRID_H;
		};
		class PPS_RscText_1501: PPS_RscListbox
		{
			idc = 1501;
			x = 15 * GUI_GRID_W + GUI_GRID_X;
			y = 6 * GUI_GRID_H + GUI_GRID_Y;
			w = 25 * GUI_GRID_W;
			h = 17.5 * GUI_GRID_H;
		};
		class PPS_RscButton_1600: PPS_RscButton
		{
			idc = 1600;
			text = "Admin"; //--- ToDo: Localize;
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 24 * GUI_GRID_H + GUI_GRID_Y;
			w = 6 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			
			action = "[] call PPS_fnc_ppsDialogAdminButton;";
		};
		class PPS_RscButton_1602: PPS_RscButton
		{
			idc = 1602;
			text = "Event"; //--- ToDo: Localize;
			x = 6.5 * GUI_GRID_W + GUI_GRID_X;
			y = 24 * GUI_GRID_H + GUI_GRID_Y;
			w = 6 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			
			action = "[] call PPS_fnc_ppsDialogEventButton;";
		};
		
		class PPS_RscEdit_1603: PPS_RscEdit
		{
			idc = 1603;
			text = ""; //--- ToDo: Localize;
			x = 13 * GUI_GRID_W + GUI_GRID_X;
			y = 24 * GUI_GRID_H + GUI_GRID_Y;
			w = 14 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
		};
		class PPS_RscButton_1604: PPS_RscButton
		{
			idc = 1604;
			text = "Track Value"; //--- ToDo: Localize;
			x = 27.5 * GUI_GRID_W + GUI_GRID_X;
			y = 24 * GUI_GRID_H + GUI_GRID_Y;
			w = 6 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			
			action = "[] call PPS_fnc_ppsDialogTrackValueButton;";
		};
		class PPS_RscButton_1601: PPS_RscButton
		{
			idc = 1601;
			text = "Update"; //--- ToDo: Localize;
			x = 34 * GUI_GRID_W + GUI_GRID_X;
			y = 24 * GUI_GRID_H + GUI_GRID_Y;
			w = 6 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			
			action = "[] call PPS_fnc_ppsDialogUpdate;";
		};
		////////////////////////////////////////////////////////
		// GUI EDITOR OUTPUT END
		////////////////////////////////////////////////////////
	};
};