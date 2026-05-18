std = "none"
max_line_length = false
max_comment_line_length = 120
self = false

exclude_files = {
	".luacheckrc",
	"ls_Minimap/embeds/",
}

ignore = {
	"111/LS.*", -- Setting an undefined global variable starting with LS
	"112/LS.*", -- Mutating an undefined global variable starting with LS
	"113/LS.*", -- Accessing an undefined global variable starting with LS
	"211/_G", -- Unused local variable _G
	"211/C",  -- Unused local variable C
	"211/D",  -- Unused local variable D
	"211/L",  -- Unused local variable L
	"432", -- Shadowing an upvalue argument
}

globals = {
	-- Lua
	"getfenv",
	"print",

	-- SVars
	"LS_MINIMAP_GLOBAL_CONFIG",
}

read_globals = {
	"ActionStatus",
	"ActionStatus_DisplayMessage",
	"AddonCompartmentFrame",
	"C_AddOns",
	"C_DelvesUI",
	"C_EditMode",
	"C_EncodingUtil",
	"C_Map",
	"C_PvP",
	"C_Timer",
	"ColorMixin",
	"CopyTable",
	"CreateFrame",
	"CreateVector2D",
	"DifficultyUtil",
	"EDIT_MODE_MODERN_SYSTEM_MAP",
	"EditModeSettingDisplayInfoManager",
	"Enum",
	"EventUtil",
	"ExpansionLandingPageMinimapButton",
	"FrameUtil",
	"GameTimeFrame",
	"GameTooltip",
	"GetClientDisplayExpansionLevel",
	"GetDifficultyInfo",
	"GetFrameMetatable",
	"GetGameTime",
	"GetInstanceInfo",
	"GetLocale",
	"HybridMinimap",
	"InGuildParty",
	"IsControlKeyDown",
	"LibStub",
	"Minimap",
	"MinimapBackdrop",
	"MinimapCluster",
	"MinimapCompassTexture",
	"MinimapZoneText",
	"Mixin",
	"PanelTemplates_SetNumTabs",
	"PanelTemplates_SetTab",
	"ScrollingFontMixin",
	"ScrollUtil",
	"Settings",
	"SettingsPanel",
	"tContains",
	"tDeleteItem",
	"TimeManagerClockButton",
	"TimeManagerClockTicker",
	"UIParent",
	"UISpecialFrames",
	"UnitPosition",
}
