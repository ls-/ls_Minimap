local addonName, addon = ...
local C, D, L = addon.C, addon.D, addon.L

-- Lua
local _G = getfenv(0)
local next = _G.next
local tonumber = _G.tonumber

-- Mine
addon.VER = {}
addon.VER.string = C_AddOns.GetAddOnMetadata(addonName, "Version")
addon.VER.number = tonumber(addon.VER.string:gsub("%D", ""), nil)

local function updateCallback()
	addon.Flag:Update()

	addon:UpdateLayoutSettings()
end

local function shutdownCallback()
	C.db.profile.version = addon.VER.number
end

addon:RegisterEvent("ADDON_LOADED", function(arg1)
	if arg1 ~= addonName then return end

	-- reset the size
	local info = C_EditMode.GetLayouts()
	for i = 1, #info.layouts do
		for _, v in next, info.layouts[i].systems do
			if v.system == Enum.EditModeSystem.Minimap then
				for _, setting in next, v.settings do
					if setting.setting == Enum.EditModeMinimapSetting.Size then
						setting.value = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.Minimap].settings[Enum.EditModeMinimapSetting.Size]
					end
				end
			end
		end
	end

	C_EditMode.SaveLayouts(info)

	-- nuke the size slider
	for i, setting in next, EditModeSettingDisplayInfoManager.systemSettingDisplayInfo[Enum.EditModeSystem.Minimap] do
		if setting.setting == Enum.EditModeMinimapSetting.Size then
			EditModeSettingDisplayInfoManager.systemSettingDisplayInfo[Enum.EditModeSystem.Minimap][i] = nil
		end
	end

	if LS_MINIMAP_GLOBAL_CONFIG then
		if LS_MINIMAP_GLOBAL_CONFIG.profiles then
			for profile, data in next, LS_MINIMAP_GLOBAL_CONFIG.profiles do
				addon:Modernize(data, profile, "profile")
			end
		end
	end

	C.db = LibStub("AceDB-3.0"):New("LS_MINIMAP_GLOBAL_CONFIG", D, true)
	C.db:RegisterCallback("OnProfileChanged", updateCallback)
	C.db:RegisterCallback("OnProfileCopied", updateCallback)
	C.db:RegisterCallback("OnProfileReset", updateCallback)
	C.db:RegisterCallback("OnProfileShutdown", shutdownCallback)
	C.db:RegisterCallback("OnDatabaseShutdown", shutdownCallback)

	addon.Minimap:Create()

	addon:CreateImportExport()
	addon:CreateEditModeConfig()
	addon:CreateBlizzConfig()
	addon:CreateAceConfig()

	AddonCompartmentFrame:RegisterAddon({
		text = L["ADDON_NAME"],
		icon = "Interface\\AddOns\\ls_Minimap\\assets\\logo-32",
		func = function()
			addon:OpenBlizzConfig()
		end,
	})

	SLASH_LSMINIMAP1 = "/lsminimap"
	SLASH_LSMINIMAP2 = "/lsmm"
	SlashCmdList["LSMINIMAP"] = function(msg)
		if msg == "" then
			addon:OpenBlizzConfig()
		end
	end

	addon:RegisterEvent("PLAYER_LOGIN", function()
		addon.Flag:Update()
	end)
end)
