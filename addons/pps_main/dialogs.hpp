/*

STRG + I für den Import aus dem Config File:
	configfile >> "PPS_Main_Dialog"

*/

class RscListbox;
class RscText;
class RscEdit;
class RscButton;

class PPS_Main_Dialog
{
	idd = 14984;
	movingEnable = true;
	enableSimulation = true;
	class controls
	{	
		////////////////////////////////////////////////////////
		// GUI EDITOR OUTPUT START (by y0014984|Sebastian, v1.063, #Wytyno)
		////////////////////////////////////////////////////////

		class PPS_RscText_1000: RscText
		{
			idc = 1000;
			text = "Persistent Player Statistics - Event in Progress: Unknown"; //--- ToDo: Localize;
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 0 * GUI_GRID_H + GUI_GRID_Y;
			w = 40 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			colorBackground[] = {0,0.5,0,1};
		};
		class PPS_RscText_1001: RscText
		{
			idc = 1001;
			text = "Server Status: Unknown - Database Status: Unknown"; //--- ToDo: Localize;
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 1.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 40 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			colorBackground[] = {0,0,0,0.25};
		};
		class PPS_RscText_1002: RscText
		{
			idc = 1002;
			text = "Players Total: Unknown - Players Online: Unknown - Admins Total: Unknown - Admins Online: Unknown"; //--- ToDo: Localize;
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 3 * GUI_GRID_H + GUI_GRID_Y;
			w = 40 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			colorBackground[] = {0,0,0,0.25};
		};
		class PPS_RscEdit_1400: RscEdit
		{
			idc = 1400;
			text = ""; //--- ToDo: Localize;
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 4.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 14.5 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			colorBackground[] = {0,0.5,0,0.5};
		};
		class PPS_RscEdit_1401: RscEdit
		{
			idc = 1401;
			text = ""; //--- ToDo: Localize;
			x = 15 * GUI_GRID_W + GUI_GRID_X;
			y = 4.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 25 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			colorBackground[] = {0,0.5,0,0.5};
		};
		class PPS_RscListbox_1500: RscListbox
		{
			idc = 1500;
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 6 * GUI_GRID_H + GUI_GRID_Y;
			w = 14.5 * GUI_GRID_W;
			h = 17.5 * GUI_GRID_H;
		};
		class PPS_RscListbox_1501: RscListbox
		{
			idc = 1501;
			x = 15 * GUI_GRID_W + GUI_GRID_X;
			y = 6 * GUI_GRID_H + GUI_GRID_Y;
			w = 25 * GUI_GRID_W;
			h = 17.5 * GUI_GRID_H;
		};
		class PPS_RscButton_1600: RscButton
		{
			idc = 1600;
			text = "Admin"; //--- ToDo: Localize;
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 24 * GUI_GRID_H + GUI_GRID_Y;
			w = 6 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			
			action = "[] call PPS_fnc_dialogButtonAdminExec;";
		};
		class PPS_RscButton_1602: RscButton
		{
			idc = 1602;
			text = "Event"; //--- ToDo: Localize;
			x = 6.5 * GUI_GRID_W + GUI_GRID_X;
			y = 24 * GUI_GRID_H + GUI_GRID_Y;
			w = 6 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			
			action = "[] call PPS_fnc_dialogButtonEventExec;";
		};
		
		class PPS_RscEdit_1603: RscEdit
		{
			idc = 1603;
			text = ""; //--- ToDo: Localize;
			x = 13 * GUI_GRID_W + GUI_GRID_X;
			y = 24 * GUI_GRID_H + GUI_GRID_Y;
			w = 12 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			colorBackground[] = {0,0.5,0,0.5};
		};
		class PPS_RscButton_1604: RscButton
		{
			idc = 1604;
			text = "Track Statistics"; //--- ToDo: Localize;
			x = 25.5 * GUI_GRID_W + GUI_GRID_X;
			y = 24 * GUI_GRID_H + GUI_GRID_Y;
			w = 8 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			
			action = "[] call PPS_fnc_dialogButtonTrackStatisticsExec;";
		};
		class PPS_RscButton_1601: RscButton
		{
			idc = 1601;
			text = "Update"; //--- ToDo: Localize;
			x = 34 * GUI_GRID_W + GUI_GRID_X;
			y = 24 * GUI_GRID_H + GUI_GRID_Y;
			w = 6 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			
			action = "[] call PPS_fnc_dialogUpdate;";
		};
		////////////////////////////////////////////////////////
		// GUI EDITOR OUTPUT END
		////////////////////////////////////////////////////////
	};
};