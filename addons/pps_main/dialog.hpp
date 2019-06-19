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
		class RscText_1006: RscText
		{
			idc = 1006;
			text = $STR_PPS_Main_Dialog_Players;
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 4 * GUI_GRID_H + GUI_GRID_Y;
			w = 6 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			colorBackground[] = {0,0.5,0,1};
		};
		class RscText_1007: RscText
		{
			idc = 1007;
			text = $STR_PPS_Main_Dialog_Events;
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 14 * GUI_GRID_H + GUI_GRID_Y;
			w = 6 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			colorBackground[] = {0,0.5,0,1};
		};
		class RscText_1008: RscText
		{
			idc = 1008;
			text = $STR_PPS_Main_Dialog_Statistics;
			x = 20 * GUI_GRID_W + GUI_GRID_X;
			y = 4 * GUI_GRID_H + GUI_GRID_Y;
			w = 6 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			colorBackground[] = {0,0.5,0,1};
		};
		class PPS_RscEdit_1400: RscEdit
		{
			idc = 1400;
			text = "";
			x = 6.5 * GUI_GRID_W + GUI_GRID_X;
			y = 4 * GUI_GRID_H + GUI_GRID_Y;
			w = 12.5 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			colorBackground[] = {0,0.5,0,0.5};
		};
		class PPS_RscEdit_1401: RscEdit
		{
			idc = 1401;
			text = "";
			x = 6.5 * GUI_GRID_W + GUI_GRID_X;
			y = 14 * GUI_GRID_H + GUI_GRID_Y;
			w = 12.5 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			colorBackground[] = {0,0.5,0,0.5};
		};
		class PPS_RscEdit_1402: RscEdit
		{
			idc = 1402;
			text = "";
			x = 26.5 * GUI_GRID_W + GUI_GRID_X;
			y = 4 * GUI_GRID_H + GUI_GRID_Y;
			w = 13.5 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			colorBackground[] = {0,0.5,0,0.5};
		};
		class PPS_RscListbox_1500: RscListbox
		{
			idc = 1500;
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 5.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 19 * GUI_GRID_W;
			h = 6.5 * GUI_GRID_H;
		};
		class PPS_RscListbox_1501: RscListbox
		{
			idc = 1501;
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 15.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 19 * GUI_GRID_W;
			h = 6.5 * GUI_GRID_H;
		};
		class PPS_RscListbox_1502: RscListbox
		{
			idc = 1502;
			x = 20 * GUI_GRID_W + GUI_GRID_X;
			y = 5.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 20 * GUI_GRID_W;
			h = 16.5 * GUI_GRID_H;
		};
		class PPS_RscButton_1600: RscButton
		{
			idc = 1600;
			text = $STR_PPS_Main_Dialog_Button_Admin;
			x = 13 * GUI_GRID_W + GUI_GRID_X;
			y = 12.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 6 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			
			action = "[] call PPS_fnc_dialogButtonAdminExec;";
		};
		class PPS_RscButton_1609: RscButton
		{
			idc = 1609;
			text = $STR_PPS_Main_Dialog_Button_Delete;
			x = 6.5 * GUI_GRID_W + GUI_GRID_X;
			y = 12.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 6 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			
			action = "[] call PPS_fnc_dialogButtonPlayerDeleteExec;";
		};
		class PPS_RscButton_1602: RscButton
		{
			idc = 1602;
			text = $STR_PPS_Main_Dialog_Button_Start;
			x = 13 * GUI_GRID_W + GUI_GRID_X;
			y = 22.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 6 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			
			action = "[] call PPS_fnc_dialogButtonEventStartExec;";
		};
		class PPS_RscButton_1606: RscButton
		{
			idc = 1606;
			text = $STR_PPS_Main_Dialog_Button_Continue;
			x = 6.5 * GUI_GRID_W + GUI_GRID_X;
			y = 24 * GUI_GRID_H + GUI_GRID_Y;
			w = 6 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			
			action = "[] call PPS_fnc_dialogButtonEventContinueExec;";
		};	
		class RscButton_1607: RscButton
		{
			idc = 1607;
			text = $STR_PPS_Main_Dialog_Button_Stop;
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 24 * GUI_GRID_H + GUI_GRID_Y;
			w = 6 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;

			action = "[] call PPS_fnc_dialogButtonEventStopExec;";
		};
		class RscButton_1608: RscButton
		{
			idc = 1608;
			text = $STR_PPS_Main_Dialog_Button_Delete;
			x = 13 * GUI_GRID_W + GUI_GRID_X;
			y = 24 * GUI_GRID_H + GUI_GRID_Y;
			w = 6 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			
			action = "[] call PPS_fnc_dialogButtonEventDeleteExec;";
		};		
		class PPS_RscEdit_1603: RscEdit
		{
			idc = 1603;
			text = "";
			x = 0 * GUI_GRID_W + GUI_GRID_X;
			y = 22.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 12.5 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			colorBackground[] = {0,0.5,0,0.5};
		};
		class PPS_RscButton_1604: RscButton
		{
			idc = 1604;
			text = $STR_PPS_Main_Dialog_Button_Track_Value;
			x = 27.5 * GUI_GRID_W + GUI_GRID_X;
			y = 22.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 6 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			
			action = "[] call PPS_fnc_dialogButtonTrackExec;";
		};
		class PPS_RscButton_1601: RscButton
		{
			idc = 1601;
			text = $STR_PPS_Main_Dialog_Button_Update;
			x = 34 * GUI_GRID_W + GUI_GRID_X;
			y = 24 * GUI_GRID_H + GUI_GRID_Y;
			w = 6 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			
			action = "[] call PPS_fnc_triggerServerDialogUpdate;";
		};
		class PPS_RscButton_1605: RscButton
		{
			idc = 1605;
			text = $STR_PPS_Main_Dialog_Button_Export;
			x = 34 * GUI_GRID_W + GUI_GRID_X;
			y = 22.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 6 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			
			action = "[] call PPS_fnc_dialogButtonExportExec;";
		};
		////////////////////////////////////////////////////////
		// GUI EDITOR OUTPUT END
		////////////////////////////////////////////////////////
	};
};
