local _, addon = ...
local C, D, L = addon.C, addon.D, addon.L
addon.Minimap = {}

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next
local unpack = _G.unpack

-- Mine
local LOCAL_FRAME = CopyTable(GetFrameMetatable().__index)

local MINIMAP_INFO = {
	[100] = {
		{1 / 1024, 433 / 1024, 1 / 512, 433 / 512}, -- outer
		{434 / 1024, 866 / 1024, 1 / 512, 433 / 512}, -- inner
		432 / 2,
	},
	[125] = {
		{1 / 2048, 533 / 2048, 1 / 1024, 533 / 1024}, -- outer
		{534 / 2048, 1066 / 2048, 1 / 1024, 533 / 1024}, -- inner
		532 / 2,
	},
	[150] = {
		{1 / 2048, 629 / 2048, 1 / 1024, 629 / 1024}, -- outer
		{630 / 2048, 1258 / 2048, 1 / 1024, 629 / 1024}, -- inner
		628 / 2,
	}
}

local LANDING_PAGE_POINTS = {
	[100] = {
		["square"] = {"BOTTOMLEFT", Minimap, "BOTTOMLEFT", -2, -2},
		["round"] = {"BOTTOMLEFT", Minimap, "BOTTOMLEFT", 2, 2},
	},
	[125] = {
		["square"] = {"BOTTOMLEFT", Minimap, "BOTTOMLEFT", -2, -2},
		["round"] = {"BOTTOMLEFT", Minimap, "BOTTOMLEFT", 9, 9},
	},
	[150] = {
		["square"] = {"BOTTOMLEFT", Minimap, "BOTTOMLEFT", -2, -2},
		["round"] = {"BOTTOMLEFT", Minimap, "BOTTOMLEFT", 16, 15},
	},
}

local isHeaderUnderneath = false

local minimap_proto = {}

do
	local ZONE_TYPE_TO_COLOR = {
		["arena"] = "hostile",
		["combat"] = "hostile",
		["contested"] = "contested",
		["friendly"] = "friendly",
		["hostile"] = "hostile",
		["sanctuary"] = "sanctuary",
	}

	function minimap_proto:SetSmoothVertexColor(r, g, b, a)
		local color = self.ColorAnim.color
		a = a or 1

		if color.r == r and color.g == g and color.b == b and color.a == a then return end

		color.r, color.g, color.b, color.a = self.Border:GetVertexColor()
		self.ColorAnim.Anim:SetStartColor(color)

		color.r, color.g, color.b, color.a = r, g, b, a
		self.ColorAnim.Anim:SetEndColor(color)

		self.ColorAnim:Play()
	end

	function minimap_proto:UpdateBorderColor()
		if addon:GetLayout().border_color then
			self:SetSmoothVertexColor((C.db.global.colors[ZONE_TYPE_TO_COLOR[C_PvP.GetZonePVPInfo() or "contested"]]):GetRGB())
		else
			self:SetSmoothVertexColor(C.db.global.colors.none:GetRGB())
		end
	end

	function minimap_proto:OnEventHook(event)
		if event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA" then
			self:UpdateBorderColor()
		end
	end

	function addon.Minimap:UpdateHybridMinimap()
		if addon:GetLayout().shape == "square" then
			HybridMinimap.CircleMask:SetTexture("Interface\\BUTTONS\\WHITE8X8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		else
			HybridMinimap.CircleMask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		end

		HybridMinimap.MapCanvas:SetMaskTexture(HybridMinimap.CircleMask)
	end
end

function addon.Minimap:Create()
	if not C_AddOns.IsAddOnLoaded("Blizzard_TimeManager") then
		C_AddOns.LoadAddOn("Blizzard_TimeManager")
	end

	hooksecurefunc(MinimapCluster, "SetSize", function()
		local info = MINIMAP_INFO[addon:GetLayout().size]

		LOCAL_FRAME.SetSize(MinimapCluster, info[3] + 24, info[3] + 24)
	end)

	Mixin(Minimap, minimap_proto)

	Minimap:RegisterEvent("ZONE_CHANGED")
	Minimap:RegisterEvent("ZONE_CHANGED_INDOORS")
	Minimap:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	Minimap:HookScript("OnEvent", Minimap.OnEventHook)

	local textureParent = CreateFrame("Frame", nil, Minimap)
	textureParent:SetFrameLevel(Minimap:GetFrameLevel() + 1)
	textureParent:SetPoint("BOTTOMRIGHT", 0, 0)
	textureParent:SetPoint("TOPLEFT", 0, 0)
	Minimap.TextureParent = textureParent

	local border = textureParent:CreateTexture(nil, "BORDER", nil, 1)
	border:SetPoint("CENTER", 0, 0)
	border:SetVertexColor(C.db.global.colors.none:GetRGB())
	border:SetSnapToPixelGrid(false)
	border:SetTexelSnappingBias(0)
	Minimap.Border = border

	local ag = border:CreateAnimationGroup()
	ag.color = {a = 1}
	Minimap.ColorAnim = ag

	local anim = ag:CreateAnimation("VertexColor")
	anim:SetDuration(0.125)
	ag.Anim = anim

	local foreground = textureParent:CreateTexture(nil, "BORDER", nil, 3)
	foreground:SetPoint("CENTER", 0, 0)
	foreground:SetSnapToPixelGrid(false)
	foreground:SetTexelSnappingBias(0)
	Minimap.Foreground = foreground

	local backgroundParent = CreateFrame("Frame", nil, Minimap)
	backgroundParent:SetFrameStrata("BACKGROUND")
	backgroundParent:SetFrameLevel(1)
	backgroundParent:SetPoint("BOTTOMRIGHT", 0, 0)
	backgroundParent:SetPoint("TOPLEFT", 0, 0)
	Minimap.BackgroundParent = backgroundParent

	local background = backgroundParent:CreateTexture(nil, "BACKGROUND", nil, -7)
	background:SetAllPoints(Minimap)
	background:SetTexture("Interface\\HELPFRAME\\DarkSandstone-Tile", "REPEAT", "REPEAT")
	background:SetHorizTile(true)
	background:SetVertTile(true)
	background:Hide()
	Minimap.Background = background

	MinimapCluster.DaytimeIndicator = addon.Daytime:Create()
	MinimapCluster.DifficultyFlag = addon.Flag:Create()
	MinimapCluster.Coords = addon.Coords:Create()

	local zoomer
	local function resetZoom()
		Minimap:SetZoom(0)
	end

	hooksecurefunc(Minimap, "SetZoom", function(_, level)
		if zoomer then
			zoomer:Cancel()
		end

		local auto_zoom = addon:GetLayout().auto_zoom
		if level ~= 0 and auto_zoom ~= 0 then
			zoomer = C_Timer.NewTimer(auto_zoom, resetZoom)
		end
	end)

	hooksecurefunc(MinimapCluster, "SetHeaderUnderneath", function(_, isUnderneath)
		isHeaderUnderneath = isUnderneath

		local config = addon:GetLayout()
		addon.Minimap:UpdateLayout(config.size, config.shape)
	end)

	hooksecurefunc(ExpansionLandingPageMinimapButton, "RefreshButton", addon.Minimap.UpdateLandingPagebutton)
	hooksecurefunc(ExpansionLandingPageMinimapButton, "UpdateIconForGarrison", addon.Minimap.UpdateLandingPagebutton)

	MinimapCompassTexture:SetTexture(0)

	MinimapCluster.BorderTop:SetWidth(0)
	MinimapCluster.BorderTop:SetHeight(17)

	MinimapCluster.Tracking:SetSize(18, 17)
	MinimapCluster.Tracking.Button:SetSize(14, 14)
	MinimapCluster.Tracking.Button:ClearAllPoints()
	MinimapCluster.Tracking.Button:SetPoint("TOPLEFT", 1, -1)

	MinimapCluster.ZoneTextButton:SetSize(0, 16)
	MinimapCluster.ZoneTextButton:ClearAllPoints()
	MinimapCluster.ZoneTextButton:SetPoint("TOPLEFT", MinimapCluster.BorderTop, "TOPLEFT", 4, 0)
	MinimapCluster.ZoneTextButton:SetPoint("TOPRIGHT", MinimapCluster.BorderTop, "TOPRIGHT", -48, 0)

	MinimapZoneText:SetSize(0, 0)
	MinimapZoneText:ClearAllPoints()
	MinimapZoneText:SetPoint("TOPLEFT", 2, 0)
	MinimapZoneText:SetPoint("BOTTOMRIGHT", -2, 0)
	MinimapZoneText:SetJustifyH("LEFT")
	MinimapZoneText:SetJustifyV("MIDDLE")

	TimeManagerClockButton:ClearAllPoints()
	TimeManagerClockButton:SetPoint("TOPRIGHT", MinimapCluster.BorderTop, "TOPRIGHT", -4, 0)

	TimeManagerClockTicker:SetSize(0, 0)
	TimeManagerClockTicker:ClearAllPoints()
	TimeManagerClockTicker:SetPoint("TOPRIGHT", 0, 0)
	TimeManagerClockTicker:SetPoint("BOTTOMLEFT", 0, 0)
	TimeManagerClockTicker:SetFontObject("GameFontNormal")
	TimeManagerClockTicker:SetJustifyH("RIGHT")
	TimeManagerClockTicker:SetJustifyV("MIDDLE")
	TimeManagerClockTicker:SetTextColor(1, 1, 1)

	GameTimeFrame:ClearAllPoints()
	GameTimeFrame:SetPoint("TOPLEFT", MinimapCluster.BorderTop, "TOPRIGHT", 4, 0)

	for _, obj in next, {
			Minimap.ZoomIn,
			Minimap.ZoomOut,
			Minimap.ZoomHitArea,
			MinimapBackdrop.StaticOverlayTexture,
	} do
		addon:ForceHide(obj)
	end

	if not HybridMinimap then
		EventUtil.ContinueOnAddOnLoaded("Blizzard_HybridMinimap", addon.Minimap.UpdateHybridMinimap)
	end
end

-- At odds with the fierce looking face...
local function theBodyIsRound()
	return "ROUND"
end

local function theBodyIsSquare()
	return "SQUARE"
end

function addon.Minimap:UpdateLayout(size, shape)
	local info = MINIMAP_INFO[size]

	Minimap.Border:SetTexture("Interface\\AddOns\\ls_Minimap\\assets\\minimap-" .. shape .. "-" .. size)
	Minimap.Border:SetTexCoord(unpack(info[1]))
	Minimap.Border:SetSize(info[3], info[3])

	Minimap.Foreground:SetTexture("Interface\\AddOns\\ls_Minimap\\assets\\minimap-" .. shape .. "-" .. size)
	Minimap.Foreground:SetTexCoord(unpack(info[2]))
	Minimap.Foreground:SetSize(info[3], info[3])

	if shape == "round" then
		Minimap:SetArchBlobRingScalar(1)
		Minimap:SetQuestBlobRingScalar(1)
		Minimap:SetTaskBlobRingScalar(1)
		Minimap:SetMaskTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")

		Minimap.Background:Hide()

		-- for LDBIcon-1.0
		GetMinimapShape = theBodyIsRound
	else
		Minimap:SetArchBlobRingScalar(0)
		Minimap:SetQuestBlobRingScalar(0)
		Minimap:SetTaskBlobRingScalar(0)
		Minimap:SetMaskTexture("Interface\\BUTTONS\\WHITE8X8")

		Minimap.Background:Show()

		-- for LDBIcon-1.0
		GetMinimapShape = theBodyIsSquare
	end

	LOCAL_FRAME.SetSize(MinimapCluster, info[3] + 24, info[3] + 24)

	Minimap:SetSize(info[3] - 22, info[3] - 22)
	Minimap:ClearAllPoints()

	local LDBIcon = LibStub("LibDBIcon-1.0", true)
	if LDBIcon then
		LDBIcon:SetButtonRadius(LDBIcon.radius)
	end

	MinimapCluster.DifficultyFlag:UpdateTextures(size, shape)
	MinimapCluster.DifficultyFlag:Update()

	MinimapCluster.BorderTop:ClearAllPoints()
	MinimapCluster.BorderTop:SetPoint("LEFT", MinimapCluster, "LEFT", 24, 0)
	MinimapCluster.BorderTop:SetPoint("RIGHT", MinimapCluster, "RIGHT", -24, 0)

	if isHeaderUnderneath then
		Minimap:SetPoint("CENTER", MinimapCluster, "CENTER", 0, 8, true)

		MinimapCluster.BorderTop:SetPoint("BOTTOM", MinimapCluster, "BOTTOM", 0, 1)

		MinimapCluster.IndicatorFrame:ClearAllPoints()
		MinimapCluster.IndicatorFrame:SetPoint("BOTTOMLEFT", MinimapCluster.Tracking, "TOPLEFT", -1, 2)

		MinimapCluster.DifficultyFlag:SetPoint("TOPRIGHT", MinimapCluster, "TOPRIGHT", -20, -16)
	else
		Minimap:SetPoint("CENTER", MinimapCluster, "CENTER", 0, -8, true)

		MinimapCluster.BorderTop:SetPoint("TOP", MinimapCluster, "TOP", 0, -1)

		MinimapCluster.IndicatorFrame:ClearAllPoints()
		MinimapCluster.IndicatorFrame:SetPoint("TOPLEFT", MinimapCluster.Tracking, "BOTTOMLEFT", -1, -2)

		MinimapCluster.DifficultyFlag:SetPoint("TOPRIGHT", MinimapCluster, "TOPRIGHT", -20, -32)
	end

	if HybridMinimap then
		self:UpdateHybridMinimap()
	end

	self:UpdateLandingPagebutton()
end

function addon.Minimap:UpdateLandingPagebutton()
	ExpansionLandingPageMinimapButton:ClearAllPoints()
	ExpansionLandingPageMinimapButton:SetPoint(unpack(LANDING_PAGE_POINTS[addon:GetLayout().size][addon:GetLayout().shape]))
end
