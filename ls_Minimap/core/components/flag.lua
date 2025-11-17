local _, addon = ...
local C, D, L = addon.C, addon.D, addon.L
addon.Flag = {}

-- Lua
local _G = getfenv(0)
local unpack = _G.unpack

-- Mine
-- local GUILD_ACHIEVEMENTS_ELIGIBLE = _G.GUILD_ACHIEVEMENTS_ELIGIBLE:gsub("(%%.-[sd])", "|cffffffff%1|r")
local NEIGHBORHOOD = _G.HOUSEFINDER_NEIGHBORHOOD_LABEL:gsub("[:：]", "")

local FLAG_INFO = {
	[100] = {
		100 / 2, -- border size
		64 / 2, -- icon size
		["square"] = {1 / 512, 101 / 512, 1 / 256, 101 / 256},
		["round"] = {101 / 512, 201 / 512, 1 / 256, 101 / 256},
		["guild"] = {201 / 512, 301 / 512, 1 / 256, 101 / 256},
	},
	[125] = {
		144 / 2, -- border size
		102 / 2, -- icon size
		["square"] = {1 / 1024, 145 / 1024, 1 / 256, 145 / 256},
		["round"] = {145 / 1024, 289 / 1024, 1 / 256, 145 / 256},
		["guild"] = {289 / 1024, 433 / 1024, 1 / 256, 145 / 256},
	},
	[150] = {
		178 / 2, -- border size
		138 / 2, -- icon size
		["square"] = {1 / 1024, 179 / 1024, 1 / 512, 179 / 512},
		["round"] = {179 / 1024, 357 / 1024, 1 / 512, 179 / 512},
		["guild"] = {357 / 1024, 535 / 1024, 1 / 512, 179 / 512},
	},
}

local FLAG_ICON_INFO = {
	[100] = {
		["lfr"] = {302 / 512, 366 / 512, 1 / 256, 65 / 256},
		["normal"] = {367 / 512, 431 / 512, 1 / 256, 65 / 256},
		["heroic"] = {432 / 512, 496 / 512, 1 / 256, 65 / 256},
		["mythic"] = {302 / 512, 366 / 512, 66 / 256, 130 / 256},
		["challenge"] = {367 / 512, 431 / 512, 66 / 256, 130 / 256},
		["delve"] = {432 / 512, 496 / 512, 66 / 256, 130 / 256},
		["house"] = {302 / 512, 366 / 512, 131 / 256, 195 / 256},
	},
	[125] = {
		["lfr"] = {434 / 1024, 536 / 1024, 1 / 256, 103 / 256},
		["normal"] = {537 / 1024, 639 / 1024, 1 / 256, 103 / 256},
		["heroic"] = {640 / 1024, 742 / 1024, 1 / 256, 103 / 256},
		["mythic"] = {743 / 1024, 845 / 1024, 1 / 256, 103 / 256},
		["challenge"] = {846 / 1024, 948 / 1024, 1 / 256, 103 / 256},
		["delve"] = {434 / 1024, 536 / 1024, 104 / 256, 206 / 256},
		["house"] = {537 / 1024, 639 / 1024, 104 / 256, 206 / 256},
	},
	[150] = {
		["lfr"] = {536 / 1024, 674 / 1024, 1 / 512, 139 / 512},
		["normal"] = {675 / 1024, 813 / 1024, 1 / 512, 139 / 512},
		["heroic"] = {814 / 1024, 952 / 1024, 1 / 512, 139 / 512},
		["mythic"] = {536 / 1024, 674 / 1024, 140 / 512, 278 / 512},
		["challenge"] = {675 / 1024, 813 / 1024, 140 / 512, 278 / 512},
		["delve"] = {814 / 1024, 952 / 1024, 140 / 512, 278 / 512},
		["house"] = {536 / 1024, 674 / 1024, 279 / 512, 417 / 512},
	},
}

local EVENTS = {
	"GROUP_ROSTER_UPDATE",
	"INSTANCE_GROUP_SIZE_CHANGED",
	"PARTY_MEMBER_DISABLE",
	"PARTY_MEMBER_ENABLE",
	"PLAYER_DIFFICULTY_CHANGED",
	"UPDATE_INSTANCE_INFO",
	"ZONE_CHANGED",
}

local function scenarioIsDelve()
	local _, _, _, mapID = UnitPosition("player")
	return C_DelvesUI.HasActiveDelve(mapID)
end

local DIFFICULTY_NAMES = {
	[208] = _G.DELVE_LABEL,
}

-- Blizz don't fully support delves atm
local function getDifficultyName(ID)
	return DifficultyUtil.GetDifficultyName(ID) or DIFFICULTY_NAMES[ID]
end

local flag_proto = {}

local deferredUpdate, timer

function flag_proto:OnEvent(event)
	if not deferredUpdate then
		-- it's static, so avoid creating it again and again
		deferredUpdate = function()
			self:Update()

			timer = nil
		end
	end

	if not timer then
		-- depending on the kind of an instance you enter it can fire 5+ times
		timer = C_Timer.NewTimer(1, deferredUpdate)
	end
end

-- I'll leave them here in case I want to re-add them
-- function flag_proto:OnEnter()
-- 	if self.difficultyID and self.difficultyName then

-- 		GameTooltip:SetOwner(self, "ANCHOR_NONE")
-- 		GameTooltip:SetPoint("TOPRIGHT", self, "CENTER", -2, -2)
-- 		GameTooltip:SetText(self.instanceName, 1, 1, 1)
-- 		GameTooltip:AddLine(self.difficultyName)

-- 		local inGroup, _, numGuildRequired = InGuildParty()
-- 		if inGroup then
-- 			GameTooltip:AddLine(" ")
-- 			GameTooltip:AddLine(GUILD_ACHIEVEMENTS_ELIGIBLE:format(numGuildRequired, self.maxPlayers, GetGuildInfo("player")), nil, nil, nil, true)
-- 		end

-- 		GameTooltip:Show()
-- 	end
-- end

-- function flag_proto:OnLeave()
-- 	GameTooltip:Hide()
-- end

function flag_proto:SetIcon(t)
	self.Icon:SetTexCoord(unpack(self.iconInfo[t]))
end

function flag_proto:SetBorder(t)
	self.Border:SetTexCoord(unpack(self.info[t]))
end

function flag_proto:UpdateTextures(size)
	local info = FLAG_INFO[size]

	self:SetSize(info[1], info[1])

	self.Border:SetTexture("Interface\\AddOns\\ls_Minimap\\assets\\minimap-flags-" .. size)

	self.Icon:SetSize(info[2], info[2])
	self.Icon:SetTexture("Interface\\AddOns\\ls_Minimap\\assets\\minimap-flags-" .. size)

	self.info = info
	self.iconInfo = FLAG_ICON_INFO[size]
end

function flag_proto:Update()
	self.instanceName = nil
	self.difficultyID = nil
	self.difficultyName = nil
	self.maxPlayers = nil
	self:Hide()

	local instanceName, instanceType, difficultyID, _, maxPlayers = GetInstanceInfo()
	if instanceType == "raid" or instanceType == "party" then
		local _, _, isHeroic, isChallengeMode, displayHeroic, displayMythic, _, isLFR = GetDifficultyInfo(difficultyID)

		self.instanceName = instanceName
		self.difficultyID = difficultyID
		self.difficultyName = getDifficultyName(difficultyID)
		self.maxPlayers = maxPlayers

		if isChallengeMode then
			self:SetIcon("challenge")
		elseif isLFR then
			self:SetIcon("lfr")
		elseif displayMythic then
			self:SetIcon("mythic")
		elseif isHeroic or displayHeroic then
			self:SetIcon("heroic")
		else
			self:SetIcon("normal")
		end

		self:Show()
	elseif instanceType == "scenario" then
		local _, _, isHeroic, _, displayHeroic, displayMythic = GetDifficultyInfo(difficultyID)
		local isDelve = scenarioIsDelve()
		if not (isHeroic or displayHeroic or displayMythic or isDelve) then return end

		self.instanceName = instanceName
		self.difficultyID = difficultyID
		self.difficultyName = getDifficultyName(difficultyID)
		self.maxPlayers = maxPlayers

		if displayMythic then
			self:SetIcon("mythic")
		elseif isHeroic or displayHeroic then
			self:SetIcon("heroic")
		elseif isDelve then
			self:SetIcon("delve")
		end

		self:Show()
	elseif instanceType == "neighborhood" or instanceType == "interior" then
		self.instanceName = instanceName
		self.difficultyID = difficultyID
		self.difficultyName = NEIGHBORHOOD
		self.maxPlayers = maxPlayers

		self:SetIcon("house")
		self:Show()
	end

	self:SetBorder(InGuildParty() and "guild" or addon:GetLayout().shape)
end

function addon.Flag:Create()
	addon:ForceHide(MinimapCluster.InstanceDifficulty)

	local flag = Mixin(CreateFrame("Frame", nil, MinimapCluster), flag_proto)
	flag:SetFrameLevel(Minimap:GetFrameLevel() + 2)
	flag:SetScript("OnEvent", flag.OnEvent)
	flag:Hide()

	local flagBorder = flag:CreateTexture(nil, "OVERLAY")
	flagBorder:SetAllPoints()
	flagBorder:SetSnapToPixelGrid(false)
	flagBorder:SetTexelSnappingBias(0)
	flag.Border = flagBorder

	local flagIcon = flag:CreateTexture(nil, "BACKGROUND")
	flagIcon:SetPoint("TOPRIGHT", -8, -4)
	flag.Icon = flagIcon

	FrameUtil.RegisterFrameForEvents(flag, EVENTS)

	flag.info = FLAG_INFO[C.db.profile.layouts["*"].size]
	flag.iconInfo = FLAG_ICON_INFO[C.db.profile.layouts["*"].size]

	return flag
end

function addon.Flag:Update()
	MinimapCluster.DifficultyFlag:Update()
end
