local _, addon = ...
local C, D, L = addon.C, addon.D, addon.L

-- Lua
local _G = getfenv(0)

-- Mine
L["ADDON_NAME"] = ("LS: |c%sMinimap|r"):format(D.global.colors.addon:GetHex())
L["CURSEFORGE"] = "CurseForge"
L["DISCORD"] = "Discord"
L["GITHUB"] = "GitHub"
L["WAGO"] = "Wago"
L["WOWINTERFACE"] = "WoWInterface"
L["INFO"] = D.global.colors.addon:WrapTextInColorCode(_G.INFO)

-- Require translation
L["AUTO_ZOOM_OUT"] = "Auto Zoom Out"
L["CHANGELOG"] = "Changelog"
L["CHANGELOG_FULL"] = "Full"
L["COLLAPSE_OPTIONS"] = "Collapse Options"
L["COLORED_BORDER"] = "Colored Border"
L["COORDS"] = "Coordinates"
L["DOWNLOADS"] = "Downloads"
L["LINK_COPY_SUCCESS"] = "Link Copied to Clipboard"
L["ROUND"] = "Round"
L["SHAPE"] = "Shape"
L["SQUARE"] = "Square"
L["SUPPORT_FEEDBACK"] = "Support & Feedback"
L["X_OFFSET"] = "Horiz. Offset"
L["Y_OFFSET"] = "Vert. Offset"
