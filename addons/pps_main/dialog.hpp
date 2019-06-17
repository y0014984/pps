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
			text = $STR_PPS_Main_Dialog_Head;
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 0 * GUI_GRID_H + GUI_GRID_Y;
			w = 40 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			colorBackground[] = {0,0.5,0,1};
		};
		class PPS_RscText_1001: RscText
		{
			idc = 1001;
			text = $STR_PPS_Main_Dialog_Server_Status;
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 1.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 40 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			colorBackground[] = {0,0,0,0.25};
		};
		class PPS_RscText_1002: RscText
		{
			idc = 1002;
			text = $STR_PPS_Main_Dialog_Player_Status;
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 2.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 40 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			colorBackground[] = {0,0,0,0.25};
		};
		class PPS_RscEdit_1400: RscEdit
		{
			idc = 1400;
			text = "";
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 4 * GUI_GRID_H + GUI_GRID_Y;
			w = 17.5 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			colorBackground[] = {0,0.5,0,0.5};
		};
		class PPS_RscEdit_1401: RscEdit
		{
			idc = 1401;
			text = "";
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 12.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 17.5 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			colorBackground[] = {0,0.5,0,0.5};
		};
		class PPS_RscEdit_1402: RscEdit
		{
			idc = 1402;
			text = "";
			x = 18 * GUI_GRID_W + GUI_GRID_X;
			y = 4 * GUI_GRID_H + GUI_GRID_Y;
			w = 22 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			colorBackground[] = {0,0.5,0,0.5};
		};
		class PPS_RscListbox_1500: RscListbox
		{
			idc = 1500;
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 5.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 17.5 * GUI_GRID_W;
			h = 6.5 * GUI_GRID_H;
		};
		class PPS_RscListbox_1501: RscListbox
		{
			idc = 1501;
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 14 * GUI_GRID_H + GUI_GRID_Y;
			w = 17.5 * GUI_GRID_W;
			h = 6.5 * GUI_GRID_H;
		};
		class PPS_RscListbox_1502: RscListbox
		{
			idc = 1502;
			x = 18 * GUI_GRID_W + GUI_GRID_X;
			y = 5.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 22 * GUI_GRID_W;
			h = 15 * GUI_GRID_H;
		};
		class PPS_RscButton_1600: RscButton
		{
			idc = 1600;
			text = $STR_PPS_Main_Dialog_Button_Admin;
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 24 * GUI_GRID_H + GUI_GRID_Y;
			w = 7 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			
			action = "[] call PPS_fnc_dialogButtonAdminExec;";
		};
		class PPS_RscButton_1602: RscButton
		{
			idc = 1602;
			text = $STR_PPS_Main_Dialog_Button_Event;
			x = 18 * GUI_GRID_W + GUI_GRID_X;
			y = 21 * GUI_GRID_H + GUI_GRID_Y;
			w = 7 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			
			action = "[] call PPS_fnc_dialogButtonEventExec;";
		};
		class PPS_RscButton_1606: RscButton
		{
			idc = 1606;
			text = $STR_PPS_Main_Dialog_Button_Continue;
			x = 18 * GUI_GRID_W + GUI_GRID_X;
			y = 22.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 7 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			
			action = "[] call PPS_fnc_dialogButtonContinueExec;";
		};		
		class PPS_RscEdit_1603: RscEdit
		{
			idc = 1603;
			text = "";
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 21 * GUI_GRID_H + GUI_GRID_Y;
			w = 17.5 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			colorBackground[] = {0,0.5,0,0.5};
		};
		class PPS_RscButton_1604: RscButton
		{
			idc = 1604;
			text = $STR_PPS_Main_Dialog_Button_Track_Value;
			x = 33 * GUI_GRID_W + GUI_GRID_X;
			y = 21 * GUI_GRID_H + GUI_GRID_Y;
			w = 7 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			
			action = "[] call PPS_fnc_dialogButtonTrackStatisticsExec;";
		};
		class PPS_RscButton_1601: RscButton
		{
			idc = 1601;
			text = $STR_PPS_Main_Dialog_Button_Update;
			x = 25.5 * GUI_GRID_W + GUI_GRID_X;
			y = 21 * GUI_GRID_H + GUI_GRID_Y;
			w = 7 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			
			action = "[] call PPS_fnc_dialogUpdate;";
		};
		class PPS_RscButton_1605: RscButton
		{
			idc = 1605;
			text = $STR_PPS_Main_Dialog_Button_Export;
			x = 33 * GUI_GRID_W + GUI_GRID_X;
			y = 22.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 7 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			
			action = "[] call PPS_fnc_dialogButtonExportExec;";
		};
		////////////////////////////////////////////////////////
		// GUI EDITOR OUTPUT END
		////////////////////////////////////////////////////////
	};
};
