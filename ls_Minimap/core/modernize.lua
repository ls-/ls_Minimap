local _, addon = ...
local C, D, L = addon.C, addon.D, addon.L

-- Lua
local _G = getfenv(0)

-- Mine
function addon:Modernize(data, name, key)
	if not data.version then return end

	if key == "profile" then
		--> 120007.01
		if data.version < 12000701 then
			if data.layouts then
				data.layouts["*"] = nil
			end

			data.version = 12000701
		end
	end
end
