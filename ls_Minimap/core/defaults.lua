local _, addon = ...
local C, D, L = addon.C, addon.D, addon.L

-- Lua
local _G = getfenv(0)

-- Mine
local LEM = LibStub("LibEditMode")

function addon:GetLayout()
	return C.db.profile.layouts[LEM:GetActiveLayoutName() or "Modern"]
end

function addon:GetDefaultLayout()
	return C.db.profile.layouts["*"]
end

local function rgb(...)
	return addon:CreateColor(...)
end

D.global = {
	colors = {
		addon = rgb(255, 130, 67), -- #FF8243 (Crayola Mango Tango)
		none = rgb(202, 202, 202), -- #CACACA
		contested = rgb(250, 179, 0), -- #FAB300 (Blizzard Colour)
		friendly = rgb(26, 255, 26), -- #1AFF1A (Blizzard Colour)
		hostile = rgb(255, 26, 26), -- #FF1A1A (Blizzard Colour)
		sanctuary = rgb(105, 204, 240) -- #68CCEF (Blizzard Colour)
	},
}

D.profile = {
	layouts = {
		["*"] = {
			size = 100, -- 100, 125, 150
			shape = "square", -- "round", "square"
			border_color = false,
			auto_zoom = 5,
			coords = {
				enabled = false,
				background = true,
				point = {0, -150},
			},
		},
	},
}
