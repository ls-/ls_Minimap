local _, addon = ...

-- Lua
local _G = getfenv(0)
local error = _G.error
local next= _G.next
local pcall = _G.pcall
local s_format = _G.string.format
local t_insert = _G.table.insert
local type = _G.type

-- Mine
local C, D, L = {}, {}, {}
addon.C, addon.D, addon.L = C, D, L

------------
-- EVENTS --
------------

do
	local oneTimeEvents = {ADDON_LOADED = false, PLAYER_LOGIN = false}
	local registeredEvents = {}

	local dispatcher = CreateFrame("Frame", "LSMinimapEventFrame")
	dispatcher:SetScript("OnEvent", function(_, event, ...)
		for _, func in next, registeredEvents[event] do
			func(...)
		end

		if oneTimeEvents[event] == false then
			oneTimeEvents[event] = true
		end
	end)

	function addon:RegisterEvent(event, func)
		if oneTimeEvents[event] then
			error(s_format("Failed to register for '%s' event, already fired!", event), 3)
		end

		if not func or type(func) ~= "function" then
			error(s_format("Failed to register for '%s' event, no handler!", event), 3)
		end

		if not registeredEvents[event] then
			registeredEvents[event] = {}

			dispatcher:RegisterEvent(event)
		end

		if not tContains(registeredEvents[event], func) then
			t_insert(registeredEvents[event], func)
		end
	end

	function addon:UnregisterEvent(event, func)
		local funcs = registeredEvents[event]
		if funcs then
			tDeleteItem(funcs, func)

			if #funcs == 0 then
				dispatcher:UnregisterEvent(event)
			end
		end
	end
end

----------
-- MISC --
----------

do
	local hiddenFrame = CreateFrame("Frame", nil, UIParent)
	hiddenFrame:Hide()

	function addon:ForceHide(object)
		if not object then return end

		-- EditMode bs
		if object.HideBase then
			object:HideBase(true)
		else
			object:Hide(true)
		end

		if object.EnableMouse then
			object:EnableMouse(false)
		end

		if object.UnregisterAllEvents then
			object:UnregisterAllEvents()
			object:SetAttribute("statehidden", true)
		end

		if object.SetUserPlaced then
			pcall(object.SetUserPlaced, object, true)
			pcall(object.SetDontSavePosition, object, true)
		end

		object:SetParent(hiddenFrame)
	end
end

-------------
-- COLOURS --
-------------

do
	local color_proto = {}

	function color_proto:GetHex()
		return self.hex
	end

	-- override ColorMixin:GetRGBA
	function color_proto:GetRGBA(a)
		return self.r, self.g, self.b, a or self.a
	end

	-- override ColorMixin:SetRGBA
	function color_proto:SetRGBA(r, g, b, a)
		if r > 1 or g > 1 or b > 1 then
			r, g, b = r / 255, g / 255, b / 255
		end

		self.r = r
		self.g = g
		self.b = b
		self.a = a
		self.hex = s_format('ff%02x%02x%02x', self:GetRGBAsBytes())
	end

	-- override ColorMixin:WrapTextInColorCode
	function color_proto:WrapTextInColorCode(text)
		return "|c" .. self.hex .. text .. "|r"
	end

	function addon:CreateColor(r, g, b, a)
		local color = Mixin({}, ColorMixin, color_proto)
		color:SetRGBA(r, g, b, a)

		return color
	end
end
