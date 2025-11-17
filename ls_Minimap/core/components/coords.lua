local _, addon = ...
local C, D, L = addon.C, addon.D, addon.L
addon.Coords = {}

-- Lua
local _G = getfenv(0)

-- Mine
local COORDS_FORMAT = "%.1f / %.1f"

-- credit: elcius@WoWInterface
local mapRects = {}
local tempVec2D = CreateVector2D(0, 0)

local function getPlayerMapPosition()
	tempVec2D.x, tempVec2D.y = UnitPosition("player")
	if not tempVec2D.x then return end

	local mapID = C_Map.GetBestMapForUnit("player")
	if not mapID then return end

	local mapRect = mapRects[mapID]
	if not mapRect then
		local _, pos1 = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0))
		local _, pos2 = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1))
		if not (pos1 and pos2) then return end

		mapRect = {pos1, pos2}
		mapRect[2]:Subtract(mapRect[1])

		mapRects[mapID] = mapRect
	end

	tempVec2D:Subtract(mapRect[1])

	return tempVec2D.y / mapRect[2].y * 100, tempVec2D.x / mapRect[2].x * 100
end

local coords_proto = {}

function coords_proto:OnUpdate(elapsed)
	self.elapsed = (self.elapsed or 0) - elapsed
	if self.elapsed < 0 then
		local x, y = getPlayerMapPosition()
		if x then
			self.Text:SetFormattedText(COORDS_FORMAT, x, y)

			self.elapsed = 0.1
		else
			self.Text:SetText(_G.NOT_APPLICABLE)

			self.elapsed = 5
		end
	end
end

function addon.Coords:Create()
	local coords = Mixin(CreateFrame("Frame", nil, MinimapCluster, "BackdropTemplate"), coords_proto)
	coords:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\AddOns\\ls_Minimap\\assets\\coords-border",
		tile = true,
		tileEdge = true,
		tileSize = 8,
		edgeSize = 8,
		-- insets = {left = 4, right = 4, top = 4, bottom = 4},
	})

	-- the way Blizz position it creates really weird gaps, so fix it
	coords.Center:ClearAllPoints()
	coords.Center:SetPoint("TOPLEFT", coords.TopLeftCorner, "BOTTOMRIGHT", 0, 0)
	coords.Center:SetPoint("BOTTOMRIGHT", coords.BottomRightCorner, "TOPLEFT", 0, 0)

	coords:SetBackdropColor(0, 0, 0, 0.6)
	coords:SetBackdropBorderColor(0, 0, 0, 0.6)
	coords:SetFrameLevel(Minimap:GetFrameLevel() + 2)
	coords:SetScript("OnUpdate", coords.OnUpdate)

	local coordsText = coords:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	coordsText:SetPoint("CENTER", 0, 0)
	coordsText:SetText("99.9 / 99.9")
	coordsText:SetJustifyH("CENTER")
	coords.Text = coordsText

	coords:SetSize(coordsText:GetUnboundedStringWidth() + 10, coordsText:GetStringHeight() + 8)

	return coords
end

function addon.Coords:Enable(areEnabled)
	MinimapCluster.Coords:SetShown(areEnabled)
end

function addon.Coords:EnableBackground(isEnabled)
	if isEnabled then
		MinimapCluster.Coords:SetBackdropColor(0, 0, 0, 0.6)
		MinimapCluster.Coords:SetBackdropBorderColor(0, 0, 0, 0.6)
	else
		MinimapCluster.Coords:SetBackdropColor(0, 0, 0, 0)
		MinimapCluster.Coords:SetBackdropBorderColor(0, 0, 0, 0)
	end
end

function addon.Coords:SetPoint(x, y)
	MinimapCluster.Coords:ClearAllPoints()
	MinimapCluster.Coords:SetPoint("CENTER", x, y)
end
