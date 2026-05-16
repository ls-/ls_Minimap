local _, addon = ...
local C, D, L = addon.C, addon.D, addon.L

-- Lua
local _G = getfenv(0)

-- Mine
addon.CHANGELOG = [[
- Added 12.0.5 support.
- Added profile import/export. Available at the "Profiles" tab in Blizz config panel.
- Fixed an issue where the addon could interfere with other addons that were messing with the stopwatch.
]]
