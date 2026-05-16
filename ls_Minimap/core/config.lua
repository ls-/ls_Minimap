local addonName, addon = ...
local C, D, L = addon.C, addon.D, addon.L

-- Lua
local _G = getfenv(0)
local m_floor = _G.math.floor
local m_random = _G.math.random
local next = _G.next
local s_format = _G.string.format

-- Mine
local LEM = LibStub("LibEditMode-ls", true) or LibStub("LibEditMode")

-- move these elsehwere
local CL_LINK = "https://github.com/ls-/ls_Minimap/blob/master/CHANGELOG.md"
local CURSE_LINK = "https://www.curseforge.com/wow/addons/ls-minimap"
local DISCORD_LINK = "https://discord.gg/7QcJgQkDYD"
local GITHUB_LINK = "https://github.com/ls-/ls_Minimap"
local WAGO_LINK = "https://addons.wago.io/addons/ls-minimap"

local showLinkCopyPopup
do
	local function getStatusMessage()
		local num = m_random(1, 100)
		if num == 27 then
			return "The Cake is a Lie"
		else
			return L["LINK_COPY_SUCCESS"]
		end
	end

	local link = ""

	local popup = CreateFrame("Frame", nil, UIParent)
	popup:Hide()
	popup:SetPoint("CENTER", UIParent, "CENTER")
	popup:SetSize(384, 78)
	popup:EnableMouse(true)
	popup:SetFrameStrata("TOOLTIP")
	popup:SetFixedFrameStrata(true)
	popup:SetFrameLevel(100)
	popup:SetFixedFrameLevel(true)
	popup:EnableKeyboard(true)

	local border = CreateFrame("Frame", nil, popup, "DialogBorderTranslucentTemplate")
	border:SetAllPoints(popup)

	local editBox = CreateFrame("EditBox", nil, popup, "InputBoxTemplate")
	editBox:SetHeight(32)
	editBox:SetPoint("TOPLEFT", 22, -10)
	editBox:SetPoint("TOPRIGHT", -16, -10)
	editBox:EnableKeyboard(true)
	editBox:SetScript("OnChar", function(self)
		self:SetText(link)
		self:HighlightText()
	end)
	editBox:SetScript("OnMouseUp", function(self)
		self:HighlightText()
	end)
	editBox:SetScript("OnEscapePressed", function()
		popup:Hide()
	end)
	editBox:SetScript("OnEnterPressed", function()
		popup:Hide()
	end)
	editBox:SetScript("OnKeyUp", function(_, key)
		if IsControlKeyDown() and (key == "C" or key == "X") then
			ActionStatus:DisplayMessage(getStatusMessage())

			popup:Hide()
		end
	end)

	local button = CreateFrame("Button", nil, popup, "UIPanelButtonNoTooltipTemplate")
	button:SetText(_G.CLOSE)
	button:SetSize(90, 22)
	button:SetPoint("BOTTOM", 0, 16)
	button:SetScript("OnClick", function()
		popup:Hide()
	end)

	popup:SetScript("OnHide", function()
		link = ""
		editBox:SetText(link)
	end)
	popup:SetScript("OnShow", function()
		editBox:SetText(link)
		editBox:SetFocus()
		editBox:HighlightText()
	end)

	function showLinkCopyPopup(text)
		popup:Hide()
		link = text
		popup:Show()
	end
end

function addon:CreateEditModeConfig()
	local function layoutCallback(layoutName)
		-- AceDB takes care of layout table duplication
		local layout = C.db.profile.layouts[layoutName]

		addon.Minimap:UpdateLayout(layout.size, layout.shape)

		Minimap:UpdateBorderColor()

		addon.Coords:Enable(layout.coords.enabled)
		addon.Coords:EnableBackground(layout.coords.background)
		addon.Coords:SetPoint(layout.coords.point[1], layout.coords.point[2])
	end

	function addon:UpdateLayoutSettings()
		layoutCallback(LEM:GetActiveLayoutName())
	end
	LEM:RegisterCallback("layout", layoutCallback)

	LEM:RegisterCallback("create", function(newLayoutName, _, sourceLayoutName)
		if sourceLayoutName then
			addon:CopyTable(C.db.profile.layouts[sourceLayoutName], C.db.profile.layouts[newLayoutName])
		end
	end)

	LEM:RegisterCallback("delete", function(oldLayoutName)
		C.db.profile.layouts[oldLayoutName] = nil
	end)

	LEM:RegisterCallback("rename", function(oldLayoutName, newLayoutName)
		addon:CopyTable(C.db.profile.layouts[oldLayoutName], C.db.profile.layouts[newLayoutName])

		C.db.profile.layouts[oldLayoutName] = nil
	end)

	LEM:AddSystemSettings(Enum.EditModeSystem.Minimap, {
		{
			name = _G.HUD_EDIT_MODE_SETTING_MINIMAP_SIZE,
			kind = LEM.SettingType.Slider,
			default = D.profile.layouts["*"].size,
			get = function(layoutName)
				return C.db.profile.layouts[layoutName].size
			end,
			set = function(layoutName, value)
				if C.db.profile.layouts[layoutName].size ~= value then
					C.db.profile.layouts[layoutName].size = value

					addon.Minimap:UpdateLayout(value, C.db.profile.layouts[layoutName].shape)
				end
			end,
			minValue = 100,
			maxValue = 150,
			valueStep = 25,
		},
		{
			name = L["SHAPE"],
			kind = LEM.SettingType.Dropdown,
			default = D.profile.layouts["*"].shape,
			get = function(layoutName)
				return C.db.profile.layouts[layoutName].shape
			end,
			set = function(layoutName, value)
				if C.db.profile.layouts[layoutName].shape ~= value then
					C.db.profile.layouts[layoutName].shape = value

					addon.Minimap:UpdateLayout(C.db.profile.layouts[layoutName].size, value)
				end
			end,
			values = {
				{
					isRadio = true,
					text = L["ROUND"],
					value = "round",
				},
				{
					isRadio = true,
					text = L["SQUARE"],
					value = "square",
				},
			},
		},
		{
			name = L["COLORED_BORDER"],
			kind = LEM.SettingType.Checkbox,
			default = D.profile.layouts["*"].border_color,
			get = function(layoutName)
				return C.db.profile.layouts[layoutName].border_color
			end,
			set = function(layoutName, value)
				if C.db.profile.layouts[layoutName].border_color ~= value then
					C.db.profile.layouts[layoutName].border_color = value

					Minimap:UpdateBorderColor()
				end
			end,
		},
		{
			name = L["AUTO_ZOOM_OUT"],
			kind = LEM.SettingType.Slider,
			default = D.profile.layouts["*"].auto_zoom,
			get = function(layoutName)
				return C.db.profile.layouts[layoutName].auto_zoom
			end,
			set = function(layoutName, value)
				if C.db.profile.layouts[layoutName].auto_zoom ~= value then
					C.db.profile.layouts[layoutName].auto_zoom = value
				end
			end,
			formatter = function(value)
				return value == 0 and _G.OFF or value
			end,
			minValue = 0,
			maxValue = 30,
			valueStep = 1,
		},
		{
			name = L["COORDS"],
			kind = LEM.SettingType.Divider,
			-- hideLabel = true,
			hidden = function()
				return not C.db.global.settings.coords
			end,
		},
		{
			name = _G.ENABLE,
			kind = LEM.SettingType.Checkbox,
			hidden = function()
				return not C.db.global.settings.coords
			end,
			default = D.profile.layouts["*"].coords.enabled,
			get = function(layoutName)
				return C.db.profile.layouts[layoutName].coords.enabled
			end,
			set = function(layoutName, value)
				if C.db.profile.layouts[layoutName].coords.enabled ~= value then
					C.db.profile.layouts[layoutName].coords.enabled = value

					addon.Coords:Enable(value)
				end

					if value then
						LEM:EnableSystemSetting(Enum.EditModeSystem.Minimap, _G.BACKGROUND)
						LEM:EnableSystemSetting(Enum.EditModeSystem.Minimap, L["X_OFFSET"])
						LEM:EnableSystemSetting(Enum.EditModeSystem.Minimap, L["Y_OFFSET"])
					else
						LEM:DisableSystemSetting(Enum.EditModeSystem.Minimap, _G.BACKGROUND)
						LEM:DisableSystemSetting(Enum.EditModeSystem.Minimap, L["X_OFFSET"])
						LEM:DisableSystemSetting(Enum.EditModeSystem.Minimap, L["Y_OFFSET"])
					end
			end,
		},
		{
			name = _G.BACKGROUND,
			kind = LEM.SettingType.Checkbox,
			hidden = function()
				return not C.db.global.settings.coords
			end,
			disabled = function(layoutName)
				return not C.db.profile.layouts[layoutName].coords.enabled
			end,
			default = D.profile.layouts["*"].coords.background,
			get = function(layoutName)
				return C.db.profile.layouts[layoutName].coords.background
			end,
			set = function(layoutName, value)
				if C.db.profile.layouts[layoutName].coords.background ~= value then
					C.db.profile.layouts[layoutName].coords.background = value

					addon.Coords:EnableBackground(value)
				end
			end,
		},
		{
			name = L["X_OFFSET"],
			kind = LEM.SettingType.Slider,
			hidden = function()
				return not C.db.global.settings.coords
			end,
			disabled = function(layoutName)
				return not C.db.profile.layouts[layoutName].coords.enabled
			end,
			default = D.profile.layouts["*"].coords.point[1],
			get = function(layoutName)
				return C.db.profile.layouts[layoutName].coords.point[1]
			end,
			set = function(layoutName, value)
				if C.db.profile.layouts[layoutName].coords.point[1] ~= value then
					C.db.profile.layouts[layoutName].coords.point[1] = value

					addon.Coords:SetPoint(value, C.db.profile.layouts[layoutName].coords.point[2])
				end
			end,
			minValue = -192,
			maxValue = 192,
			valueStep = 1,
		},
		{
			name = L["Y_OFFSET"],
			kind = LEM.SettingType.Slider,
			hidden = function()
				return not C.db.global.settings.coords
			end,
			disabled = function(layoutName)
				return not C.db.profile.layouts[layoutName].coords.enabled
			end,
			default = D.profile.layouts["*"].coords.point[2],
			get = function(layoutName)
				return C.db.profile.layouts[layoutName].coords.point[2]
			end,
			set = function(layoutName, value)
				if C.db.profile.layouts[layoutName].coords.point[2] ~= value then
					C.db.profile.layouts[layoutName].coords.point[2] = value

					addon.Coords:SetPoint(C.db.profile.layouts[layoutName].coords.point[1], value)
				end
			end,
			minValue = -192,
			maxValue = 192,
			valueStep = 1,
		},
		{
			name = "DNT Coords Settings Expander",
			kind = LEM.SettingType.Expander,
			expandedLabel = L["COLLAPSE_OPTIONS"],
			collapsedLabel = L["COORDS"],
			appendArrow = true,
			default = D.global.settings.coords,
			get = function()
				return C.db.global.settings.coords
			end,
			set = function(_, value)
				C.db.global.settings.coords = value
			end,
		},
	})
end

do
	local header_proto = {}

	do
		function header_proto:OnHyperlinkClick(hyperlink)
			showLinkCopyPopup(hyperlink)
		end
	end

	local function createHeader(parent, text)
		local header = Mixin(CreateFrame("Frame", nil, parent, "InlineHyperlinkFrameTemplate"), header_proto)
		header:SetHeight(50)
		header:SetScript("OnHyperlinkClick", header.OnHyperlinkClick)

		local title = header:CreateFontString(nil, "ARTWORK", "GameFontHighlightHuge")
		title:SetPoint("TOPLEFT", 7, -22)
		title:SetText(text)

		local divider = header:CreateTexture(nil, "ARTWORK")
		divider:SetAtlas("Options_HorizontalDivider", true)
		divider:SetPoint("TOP", 0, -50)

		return header
	end

	local button_proto = {}

	do
		function button_proto:OnEnter()
			self.Icon:SetScale(1.1)

			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:AddLine(self.tooltip)
			GameTooltip:Show()
		end

		function button_proto:OnLeave()
			self.Icon:SetScale(1)

			GameTooltip:Hide()
		end

		function button_proto:OnClick()
			showLinkCopyPopup(self.link)
		end
	end

	local container_proto = {
		numChildren = 0,
	}

	do
		function container_proto:AddButton(texture, tooltip, link)
			self.numChildren = self.numChildren + 1
			self.spacing = m_floor(580 / (self.numChildren + 1))

			local button = Mixin(CreateFrame("Button", nil, self), button_proto)
			button:SetSize(64, 64)
			button:SetScript("OnEnter", button.OnEnter)
			button:SetScript("OnLeave", button.OnLeave)
			button:SetScript("OnClick", button.OnClick)
			button.layoutIndex = self.numChildren

			local icon = button:CreateTexture(nil, "ARTWORK")
			icon:SetPoint("CENTER")
			icon:SetSize(48, 48)
			icon:SetTexture(texture)
			button.Icon = icon

			button.tooltip = tooltip
			button.link = link
		end
	end

	function addon:CreateBlizzConfig()
		local panel = CreateFrame("Frame", "LSMinimapConfigPanel")
		panel:Hide()

		local versionText = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		versionText:SetPoint("TOPRIGHT", -2, 4)
		versionText:SetTextColor(0.4, 0.4, 0.4)
		versionText:SetText(addon.VER.string)

		local supportHeader = createHeader(panel, L["SUPPORT_FEEDBACK"])
		supportHeader:SetPoint("TOPLEFT")
		supportHeader:SetPoint("TOPRIGHT")

		local supportContainer = Mixin(CreateFrame("Frame", nil, panel, "HorizontalLayoutFrame"), container_proto)
		supportContainer:SetPoint("TOP", supportHeader, "BOTTOM", 0, -4)

		supportContainer:AddButton("Interface\\AddOns\\ls_Minimap\\assets\\discord-64", L["DISCORD"], DISCORD_LINK)
		supportContainer:AddButton("Interface\\AddOns\\ls_Minimap\\assets\\github-64", L["GITHUB"], GITHUB_LINK)

		local downloadHeader = createHeader(panel, L["DOWNLOADS"])
		downloadHeader:SetPoint("TOP", supportContainer, "BOTTOM", 0, 8)
		downloadHeader:SetPoint("LEFT")
		downloadHeader:SetPoint("RIGHT")

		local downloadContainer = Mixin(CreateFrame("Frame", nil, panel, "HorizontalLayoutFrame"), container_proto)
		downloadContainer:SetPoint("TOP", downloadHeader, "BOTTOM", 0, -4)

		-- downloadContainer:AddButton("Interface\\AddOns\\ls_Minimap\\assets\\mmoui-64", L["WOWINTERFACE"])
		downloadContainer:AddButton("Interface\\AddOns\\ls_Minimap\\assets\\curseforge-64", L["CURSEFORGE"], CURSE_LINK)
		downloadContainer:AddButton("Interface\\AddOns\\ls_Minimap\\assets\\wago-64", L["WAGO"], WAGO_LINK)

		local changelogHeader = createHeader(panel, s_format("%s |H%s|h[|c%s%s|r]|h", L["CHANGELOG"], CL_LINK, D.global.colors.addon:GetHex(), L["CHANGELOG_FULL"]))
		changelogHeader:SetPoint("TOP", downloadContainer, "BOTTOM", 0, 8)
		changelogHeader:SetPoint("LEFT")
		changelogHeader:SetPoint("RIGHT")

		-- recreation of "ScrollingFontTemplate"
		local changelog = Mixin(CreateFrame("Frame", nil, panel), ScrollingFontMixin)
		changelog:SetPoint("TOPLEFT", changelogHeader, "BOTTOMLEFT", 6, -8)
		changelog:SetPoint("BOTTOMRIGHT", changelogHeader, "BOTTOMRIGHT", -38, -192)
		changelog:SetScript("OnSizeChanged", changelog.OnSizeChanged)
		changelog.fontName = "GameFontHighlight"

		local border = CreateFrame("Frame", nil, changelog, "FloatingBorderedFrame")
		border:SetPoint("TOPLEFT")
		border:SetPoint("BOTTOMRIGHT", 20, 0)
		border:SetUsingParentLevel(true)

		for _, region in next, {border:GetRegions()} do
			region:SetVertexColor(0, 0, 0, 0.3)
		end

		local scrollBox = CreateFrame("Frame", nil, changelog, "WowScrollBox")
		scrollBox:SetAllPoints()
		changelog.ScrollBox = scrollBox

		local fontStringContainer = CreateFrame("Frame", nil, scrollBox)
		fontStringContainer:SetHeight(1)
		fontStringContainer.scrollable = true
		scrollBox.FontStringContainer = fontStringContainer

		local fontString = fontStringContainer:CreateFontString(nil, "ARTWORK")
		fontString:SetPoint("TOPLEFT")
		fontString:SetNonSpaceWrap(true)
		fontString:SetJustifyH("LEFT")
		fontString:SetJustifyV("TOP")
		fontStringContainer.FontString = fontString

		local scrollBar = CreateFrame("EventFrame", nil, panel, "MinimalScrollBar")
		scrollBar:SetPoint("TOPLEFT", scrollBox, "TOPRIGHT", 6, 0)
		scrollBar:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMRIGHT", 6, -3)
		scrollBar:SetHideIfUnscrollable(true)
		changelog.ScrollBar = scrollBar

		ScrollUtil.RegisterScrollBoxWithScrollBar(scrollBox, scrollBar)

		changelog:OnLoad()
		changelog:SetText(addon.CHANGELOG)

		supportContainer:MarkDirty()
		downloadContainer:MarkDirty()

		local category = Settings.RegisterCanvasLayoutCategory(panel, L["ADDON_NAME"])

		Settings.RegisterAddOnCategory(category)

		function addon:GetBlizzCategory()
			return category
		end

		function addon:OpenBlizzConfig()
			Settings.OpenToCategory(category:GetID())
		end
	end
end

do
	function addon:CreateAceConfig()
		C.options = {
			type = "group",
			name = s_format("%s |cffcacaca(%s)|r", L["ADDON_NAME"], addon.VER.string),
			args = {},
		}

		LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, C.options)

		C.options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(C.db, true)
		C.options.args.profiles.order = 100
		C.options.args.profiles.inline = true
		C.options.args.profiles.desc = nil
		C.options.args.profiles.hidden = function()
			return not SettingsPanel:IsShown()
		end

		C.options.args.profiles.args.spacer_1 = {
			order = 100,
			type = "description",
			name = " ",
		}

		C.options.args.profiles.args.importexport = {
			order = 110,
			type = "execute",
			name = s_format("%s / %s", L["IMPORT"], L["EXPORT"]),
			func = addon.OpenImportExport,
			width = "full",
		}

		LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, C.options.args.profiles.name, addon:GetBlizzCategory():GetID(), "profiles")
	end
end
