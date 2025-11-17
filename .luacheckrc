std = "none"
max_line_length = false
max_comment_line_length = 120
self = false

exclude_files = {
	".luacheckrc",
	"ls_Minimap/embeds/",
}

ignore = {
	"111",
	"112",
	"122",
	"211/_G", -- Unused local variable _G
	"211/C",  -- Unused local variable C
	"211/D",  -- Unused local variable D
	"211/L",  -- Unused local variable L
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
	"AddonCompartmentFrame",
	"C_AddOns",
	"C_DelvesUI",
	"C_EditMode",
	"C_Map",
	"C_PvP",
	"C_Timer",
	"ColorMixin",
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
	"GetDifficultyInfo",
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
	"ScrollingFontMixin",
	"ScrollUtil",
	"Settings",
	"tContains",
	"tDeleteItem",
	"TimeManagerClockButton",
	"TimeManagerClockTicker",
	"UIParent",
	"UnitPosition",
}
