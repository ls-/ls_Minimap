local _, addon = ...
local C, D, L = addon.C, addon.D, addon.L
addon.Daytime = {}

-- Lua
local _G = getfenv(0)
local m_floor = _G.math.floor

-- Mine
local DELAY = 337.5 -- 256 * 337.5 = 86400 = 24H
-- local DELAY = 0.05 -- 256 * 337.5 = 86400 = 24H
local STEP = 0.00390625 -- 1 / 256

local function checkTexPoint(point, base)
	if point then
		return point >= base / 256 + 1 and base / 256 or point
	else
		return base / 256
	end
end

local function scrollTexture(t, delay, offset)
	t.l = checkTexPoint(t.l, 64) + offset
	t.r = checkTexPoint(t.r, 192) + offset

	t:SetTexCoord(t.l, t.r, 40 / 128, 68 / 128) -- 64, 14

	C_Timer.After(delay, function() scrollTexture(t, DELAY, STEP) end)
end

function addon.Daytime:Create()
	local mask = MinimapCluster.BorderTop:CreateMaskTexture()
	mask:SetTexture("Interface\\AddOns\\ls_Minimap\\assets\\daytime-mask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	mask:SetPoint("TOPRIGHT", -1, -1)
	mask:SetPoint("BOTTOMLEFT", MinimapCluster.BorderTop, "BOTTOMRIGHT", -65, 2)

	local indicator = MinimapCluster.BorderTop:CreateTexture(nil, "BACKGROUND", nil, 1)
	indicator:SetTexture("Interface\\Minimap\\HumanUITile-TimeIndicator", true)
	indicator:SetVertexColor(0.85, 0.85, 0.85, 1)
	indicator:SetPoint("TOPRIGHT", -1, -1)
	indicator:SetPoint("BOTTOMLEFT", MinimapCluster.BorderTop, "BOTTOMRIGHT", -65, 2)
	indicator:AddMaskTexture(mask)

	local h, m = GetGameTime()
	local s = (h * 60 + m) * 60
	local mult = m_floor(s / DELAY)

	scrollTexture(indicator, (mult + 1) * DELAY - s, STEP * mult)

	return indicator
end
