-- hwrm-anticheat: loads `scripts/hwrm_anticheat/autoexec_guard.lua` (as a UI library, so it runs in the UI state). Changes from the
-- stock screen: that line, a transparent background instead of red, and the `ddHwrmAnticheatLog` and `frmHwrmAnticheatTell`
-- elements.
UI_LoadUILibrary("data:scripts/hwrm_anticheat/autoexec_guard.lua")

dofilepath("data:ui/newui/Styles/HWRM_Style/HWRMDefines.lua")
dofilepath("data:ui/newui/Styles/HWRM_Style/ControlConstructors.lua")

InGameModScreen = {
	stylesheet = "HW2StyleSheet",

	RootElementSettings = {
		clipchildren=0,
		giveParentMouseInput = 1,
		eventOpaque = 0,
	},

	Layout = {
		size_WH = {	w = 1, h = 1, wr = "scr", hr = "scr" },
	},
	giveParentMouseInput = 1,
	eventOpaque = 0,
	backgroundColor = {0,0,0,0},
	;

	{
		type = "DropDownListBox",
		name = "ddHwrmAnticheatLog",
		visible = 0,
		ignored = 1,
		ListBox = {
			type = "ListBox",
			ItemToClone = {
				type = "TextListBoxItem",
			},
		},
	},

	-- (pinned and scaled like `newtaskbar.lua`'s lower-centre frame, so it follows the HUD)
	{
		type = "Frame",
		name = "frmHwrmAnticheatTell",
		ignored = 1,
		giveParentMouseInput = 1,
		eventOpaque = 0,
		Layout = {
			pos_XY = { x = 0.5, y = 1.0, xr = "par", yr = "par" },
			pivot_XY = { 0.5, 1.0 },
			size_WH = { w = 400, h = 200, wr = "px", hr = "px" },
		},
		Anchor_Binds = {
			scale = "Taskbar_BottomMiddle_Scale",
		},
		;
		{
			type = "TextLabel",
			name = "lblHwrmAnticheatTell",
			visible = 0,
			ignored = 1,
			giveParentMouseInput = 1,
			eventOpaque = 0,
			Layout = {
				pos_XY = { x = 300, y = 104, xr = "px", yr = "px" },
				pivot_XY = { 0.0, 0.0 },
			},
			autosize = 1,
			Text = {
				font = "Blender",
				pixels = 24,
				rel = 0,
				color = { 97, 126, 121, 255 },
				hAlign = "Left",
				vAlign = "Top",
				text = ".",
			},
		},
	},
}
