local addon = LibStub('AceAddon-3.0'):GetAddon('SpartanUI')

--------------   SUF Functions   ------------------------------------
function addon:HotsListing()
	local _, classFileName = UnitClass('player')
	local LifebloomSpellId = select(7, GetSpellInfo('Lifebloom'))
	if classFileName == 'DRUID' then
		return {
			774, -- Rejuvenation
			LifebloomSpellId, -- Lifebloom
			8936, -- Regrowth
			-- 48438, -- Wild Growth
			-- 155777, -- Germination
			-- 102351, -- Cenarion Ward
			-- 102342 -- Ironbark
		}
	elseif classFileName == 'PRIEST' then
		return {
			139, -- Renew
			17, -- sheild
			33076 -- Prayer of Mending
		}
	elseif classFileName == 'MONK' then
		return {
			119611, -- Renewing Mist
			227345 -- Enveloping Mist
		}
	end
	return {}
end

function addon:SUF_Buffs(self, point, relativePoint, SizeModifier)
	if self == nil then
		return
	end
	if point == nil then
		point = 'TOPRIGHT'
	end
	if relativePoint == nil then
		relativePoint = 'TOPRIGHT'
	end
	if SizeModifier == nil then
		SizeModifier = 0
	end

	local auras = {}
	local spellIDs = addon:HotsListing()
	auras.presentAlpha = 1
	auras.onlyShowPresent = true
	-- auras.PostCreateIcon = myCustomIconSkinnerFunction

	-- Make icons table if needed
	if auras.icons == nil then
		auras.icons = {}
	end

	-- Set any other AuraWatch settings

	for i, sid in pairs(spellIDs) do
		local icon = CreateFrame('Frame', nil, self)
		icon.spellID = sid
		-- set the dimensions and positions
		local size = SUI.DBMod.PartyFrames.Auras.size + SizeModifier
		icon:SetSize(size, size)
		icon:SetPoint(point, self, relativePoint, (-icon:GetWidth() * (i - 1)) - 2, -2)

		local cd = CreateFrame('Cooldown', nil, icon)
		cd:SetAllPoints(icon)
		icon.cd = cd

		auras.icons[sid] = icon
		-- Set any other AuraWatch icon settings
	end
	return auras
end

function addon:pvpIcon(self, event, unit)
	if (unit ~= self.unit) then
		return
	end

	local pvp = self.PvP
	if (pvp.PreUpdate) then
		pvp:PreUpdate()
	end
	pvp:SetFrameStrata('LOW')

	if pvp.shadow == nil then
		pvp.shadow = self:CreateTexture(nil, 'BACKGROUND')
		pvp.shadow:SetSize(pvp:GetSize())
		pvp.shadow:SetParent(pvp)
		pvp.shadow:SetPoint('CENTER', pvp, 'CENTER', 2, -2)
		pvp.shadow:SetVertexColor(0, 0, 0, .9)
	end

	local status
	local factionGroup = UnitFactionGroup(unit)
	if (UnitIsPVPFreeForAll(unit)) then
		-- XXX - WoW5: UnitFactionGroup() can return Neutral as well.
		pvp:SetTexture('Interface\\FriendsFrame\\UI-Toast-FriendOnlineIcon')
		status = 'ffa'
	elseif (factionGroup and factionGroup ~= 'Neutral' and UnitIsPVP(unit)) then
		pvp:SetTexture('Interface\\FriendsFrame\\PlusManz-' .. factionGroup)
		pvp.shadow:SetTexture('Interface\\FriendsFrame\\PlusManz-' .. factionGroup)
		status = factionGroup
	end

	if (status) then
		-- pvp.shadow:Show()
		pvp:Show()
	else
		-- pvp.shadow:Hide()
		pvp:Hide()
	end

	if (pvp.PostUpdate) then
		return pvp:PostUpdate(status)
	end
end

--[[
	Creates all the Player Power Icons
	Converted to Lib item to provide a consistant experiance on SUI styles
]]
function addon:PlayerPowerIcons(frame, attachPoint)
	--Runes
	if select(2, UnitClass('player')) == 'DEATHKNIGHT' then
		frame.Runes = {}
		frame.Runes.colorSpec = true

		for i = 1, 6 do
			frame.Runes[i] = CreateFrame('StatusBar', frame:GetName() .. '_Runes' .. i, frame)
			frame.Runes[i]:SetSize((frame.Health:GetWidth() - 10) / 6, 4)
			if (i == 1) then
				frame.Runes[i]:SetPoint('TOPLEFT', frame[attachPoint], 'BOTTOMLEFT', 0, 0)
			else
				frame.Runes[i]:SetPoint('TOPLEFT', frame.Runes[i - 1], 'TOPRIGHT', 2, 0)
			end
			frame.Runes[i]:SetStatusBarTexture(SUI.BarTextures.smooth)
			frame.Runes[i]:SetStatusBarColor(0, .39, .63, 1)

			frame.Runes[i].bg = frame.Runes[i]:CreateTexture(nil, 'BORDER')
			frame.Runes[i].bg:SetPoint('TOPLEFT', frame.Runes[i], 'TOPLEFT', -0, 0)
			frame.Runes[i].bg:SetPoint('BOTTOMRIGHT', frame.Runes[i], 'BOTTOMRIGHT', 0, -0)
			frame.Runes[i].bg:SetTexture(SUI.BarTextures.smooth)
			frame.Runes[i].bg:SetVertexColor(0, 0, 0, 1)
			frame.Runes[i].bg.multiplier = 0.64
			frame.Runes[i]:Hide()

			DeathKnightResourceOverlayFrame:HookScript(
				'OnShow',
				function()
					DeathKnightResourceOverlayFrame:Hide()
				end
			)
		end
	else
		frame.ComboPoints = frame:CreateFontString(nil, 'BORDER', 'SUI_FontOutline13')
		frame.ComboPoints:SetPoint('TOPLEFT', frame[attachPoint], 'BOTTOMLEFT', 0, -2)
		local MaxPower, ClassPower = 5, {}

		if (select(2, UnitClass('player')) == 'MONK') then
			MaxPower = 6
		end

		for index = 1, MaxPower do
			local Bar = CreateFrame('StatusBar', nil, frame)
			Bar:SetStatusBarTexture(SUI.BarTextures.smooth)

			-- Position and size.
			Bar:SetSize(((frame.Health:GetWidth() - 10) / MaxPower), 6)
			if (index == 1) then
				Bar:SetPoint('TOPLEFT', frame.ComboPoints, 'TOPLEFT')
			else
				Bar:SetPoint('LEFT', ClassPower[index - 1], 'RIGHT', 2, 0)
			end
			Bar:Hide()

			ClassPower[index] = Bar
		end

		-- Register with SUF
		frame.ClassPower = ClassPower
	end
end

do -- ClassIcon as an SUIUF module
	local Update = function(self, event, unit)
		local icon = self.SUI_ClassIcon
		if (icon) then
			local _, class = UnitClass(self.unit)
			if class then
				-- local coords = ClassIconCoord[class or "DEFAULT"];
				-- icon:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
				local path = 'Interface\\AddOns\\SpartanUI\\images\\flat_classicons\\' .. (string.lower(class))
				icon:SetTexture(path)
				icon:Show()
				if icon.shadow then
					icon.shadow:SetTexture(path)
					icon.shadow:Show()
				end
			else
				icon:Hide()
				icon.shadow:Hide()
			end
		end
	end
	local Enable = function(self)
		local icon = self.SUI_ClassIcon
		if (icon) then
			--self:RegisterEvent("PARTY_MEMBERS_CHANGED", Update);
			self:RegisterEvent('PLAYER_TARGET_CHANGED', Update, true)
			self:RegisterEvent('UNIT_PET', Update, true)
			icon:SetTexture('Interface\\AddOns\\SpartanUI\\images\\icon_class')
			if icon.shadow == nil then
				icon.shadow = self:CreateTexture(nil, 'BACKGROUND')
				icon.shadow:SetSize(icon:GetSize())
				icon.shadow:SetPoint('CENTER', icon, 'CENTER', 2, -2)
				icon.shadow:SetVertexColor(0, 0, 0, .9)
			end
			return true
		end
	end
	local Disable = function(self)
		local icon = self.SUI_ClassIcon
		if (icon) then
			--self:UnregisterEvent("PARTY_MEMBERS_CHANGED", Update);
			self:UnregisterEvent('PLAYER_TARGET_CHANGED', Update)
			self:UnregisterEvent('UNIT_PET', Update)
		end
	end
	SUIUF:AddElement('SUI_ClassIcon', Update, Enable, Disable)
end

do -- TargetIndicator as an SUIUF module
	local Update = function(self, event, unit)
		if self.TargetIndicator.bg1:IsVisible() then
			self.TargetIndicator.bg1:Hide()
			self.TargetIndicator.bg2:Hide()
		end
		if UnitExists('target') and C_NamePlate.GetNamePlateForUnit('target') and SUI.DBMod.NamePlates.ShowTarget then
			if self:GetName() == 'SUF_Spartan_NamePlates' .. C_NamePlate.GetNamePlateForUnit('target'):GetName() then
				self.TargetIndicator.bg1:Show()
				self.TargetIndicator.bg2:Show()
			end
		end
	end
	local Enable = function(self)
		local icon = self.TargetIndicator
		if (icon) then
			self:RegisterEvent('PLAYER_TARGET_CHANGED', Update, true)
		end
	end
	local Disable = function(self)
		local icon = self.TargetIndicator
		if (icon) then
			self:UnregisterEvent('PLAYER_TARGET_CHANGED', Update)
		end
	end
	SUIUF:AddElement('TargetIndicator', Update, Enable, Disable)
end

do -- SUI_RaidGroup as an SUIUF module
	local Update = function(self, event, unit)
		if IsInRaid() then
			self.SUI_RaidGroup:Show()
			self.SUI_RaidGroup.Text:Show()
		else
			self.SUI_RaidGroup:Hide()
			self.SUI_RaidGroup.Text:Hide()
		end
	end
	local Enable = function(self)
		if (self.SUI_RaidGroup) then
			self:RegisterEvent('GROUP_ROSTER_UPDATE', Update, true)
			return true
		end
	end
	local Disable = function(self)
		if (self.SUI_RaidGroup) then
			self:UnregisterEvent('GROUP_ROSTER_UPDATE', Update)
		end
	end
	SUIUF:AddElement('SUI_RaidGroup', Update, Enable, Disable)
end

do -- AFK / DND status text, as an SUIUF module
	SUIUF.Tags.Events['afkdnd'] = 'PLAYER_FLAGS_CHANGED PLAYER_TARGET_CHANGED UNIT_TARGET'
	SUIUF.Tags.Methods['afkdnd'] = function(unit)
		if unit then
			return UnitIsAFK(unit) and 'AFK' or UnitIsDND(unit) and 'DND' or ''
		end
	end
end

do --Health Formatting Tags
	-- Current Health Short, as an SUIUF module
	SUIUF.Tags.Events['curhpshort'] = 'UNIT_HEALTH'
	SUIUF.Tags.Methods['curhpshort'] = function(unit)
		local tmp = UnitHealth(unit)
		if tmp >= 1000000 then
			return addon:round(tmp / 1000000, 0) .. 'M'
		end
		if tmp >= 1000 then
			return addon:round(tmp / 1000, 0) .. 'K'
		end
		return addon:comma_value(tmp)
	end
	-- Current Health Dynamic, as an SUIUF module
	SUIUF.Tags.Events['curhpdynamic'] = 'UNIT_HEALTH'
	SUIUF.Tags.Methods['curhpdynamic'] = function(unit)
		local tmp = UnitHealth(unit)
		if tmp >= 1000000 then
			return addon:round(tmp / 1000000, 1) .. 'M '
		else
			return addon:comma_value(tmp)
		end
	end
	-- Total Health Short, as an SUIUF module
	SUIUF.Tags.Events['maxhpshort'] = 'UNIT_HEALTH'
	SUIUF.Tags.Methods['maxhpshort'] = function(unit)
		local tmp = UnitHealthMax(unit)
		if tmp >= 1000000 then
			return addon:round(tmp / 1000000, 0) .. 'M'
		end
		if tmp >= 1000 then
			return addon:round(tmp / 1000, 0) .. 'K'
		end
		return addon:comma_value(tmp)
	end
	-- Total Health Dynamic, as an SUIUF module
	SUIUF.Tags.Events['maxhpdynamic'] = 'UNIT_HEALTH'
	SUIUF.Tags.Methods['maxhpdynamic'] = function(unit)
		local tmp = UnitHealthMax(unit)
		if tmp >= 1000000 then
			return addon:round(tmp / 1000000, 1) .. 'M '
		else
			return addon:comma_value(tmp)
		end
	end
	-- Missing Health Dynamic, as an SUIUF module
	SUIUF.Tags.Events['missinghpdynamic'] = 'UNIT_HEALTH'
	SUIUF.Tags.Methods['missinghpdynamic'] = function(unit)
		local tmp = UnitHealthMax(unit) - UnitHealth(unit)
		if tmp >= 1000000 then
			return addon:round(tmp / 1000000, 1) .. 'M '
		else
			return addon:comma_value(tmp)
		end
	end
	-- Current Health formatted, as an SUIUF module
	SUIUF.Tags.Events['curhpformatted'] = 'UNIT_HEALTH'
	SUIUF.Tags.Methods['curhpformatted'] = function(unit)
		return addon:comma_value(UnitHealth(unit))
	end
	-- Total Health formatted, as an SUIUF module
	SUIUF.Tags.Events['maxhpformatted'] = 'UNIT_HEALTH'
	SUIUF.Tags.Methods['maxhpformatted'] = function(unit)
		return addon:comma_value(UnitHealthMax(unit))
	end
	-- Missing Health formatted, as an SUIUF module
	SUIUF.Tags.Events['missinghpformatted'] = 'UNIT_HEALTH'
	SUIUF.Tags.Methods['missinghpformatted'] = function(unit)
		return addon:comma_value(UnitHealthMax(unit) - UnitHealth(unit))
	end
end

do -- Mana Formatting Tags
	-- Current Mana Dynamic, as an SUIUF module
	SUIUF.Tags.Events['curppdynamic'] = 'UNIT_MAXPOWER UNIT_POWER_FREQUENT'
	SUIUF.Tags.Methods['curppdynamic'] = function(unit)
		local tmp = UnitPower(unit)
		if tmp >= 1000000 then
			return addon:round(tmp / 1000000, 1) .. 'M '
		else
			return addon:comma_value(tmp)
		end
	end
	-- Total Mana Dynamic, as an SUIUF module
	SUIUF.Tags.Events['maxppdynamic'] = 'UNIT_MAXPOWER UNIT_POWER_FREQUENT'
	SUIUF.Tags.Methods['maxppdynamic'] = function(unit)
		local tmp = UnitPowerMax(unit)
		if tmp >= 1000000 then
			return addon:round(tmp / 1000000, 1) .. 'M '
		else
			return addon:comma_value(tmp)
		end
	end
	-- Missing Mana Dynamic, as an SUIUF module
	SUIUF.Tags.Events['missingppdynamic'] = 'UNIT_HEALTH'
	SUIUF.Tags.Methods['missingppdynamic'] = function(unit)
		local tmp = UnitPowerMax(unit) - UnitPower(unit)
		if tmp >= 1000000 then
			return addon:round(tmp / 1000000, 1) .. 'M '
		else
			return addon:comma_value(tmp)
		end
	end
	-- Current Mana formatted, as an SUIUF module
	SUIUF.Tags.Events['curppformatted'] = 'UNIT_MAXPOWER UNIT_POWER_FREQUENT'
	SUIUF.Tags.Methods['curppformatted'] = function(unit)
		return addon:comma_value(UnitPower(unit))
	end
	-- Total Mana formatted, as an SUIUF module
	SUIUF.Tags.Events['maxppformatted'] = 'UNIT_MAXPOWER UNIT_POWER_FREQUENT'
	SUIUF.Tags.Methods['maxppformatted'] = function(unit)
		return addon:comma_value(UnitPowerMax(unit))
	end
	-- Total Mana formatted, as an SUIUF module
	SUIUF.Tags.Events['missingppformatted'] = 'UNIT_MAXPOWER UNIT_POWER_FREQUENT'
	SUIUF.Tags.Methods['missingppformatted'] = function(unit)
		return addon:comma_value(UnitPowerMax(unit) - UnitPower(unit))
	end
end

do --Color name by Class
	local function hex(r, g, b)
		if r then
			if (type(r) == 'table') then
				if (r.r) then
					r, g, b = r.r, r.g, r.b
				else
					r, g, b = unpack(r)
				end
			end
			return ('|cff%02x%02x%02x'):format(r * 255, g * 255, b * 255)
		end
	end

	SUIUF.Tags.Events['SUI_ColorClass'] = 'UNIT_HEALTH'
	SUIUF.Tags.Methods['SUI_ColorClass'] = function(u)
		local _, class = UnitClass(u)

		if (u == 'pet') then
			return hex(SUIUF.colors.class[class])
		elseif (UnitIsPlayer(u)) then
			return hex(SUIUF.colors.class[class])
		else
			return hex(1, 1, 1)
		end
	end
end

do -- Level Skull as an SUIUF module
	local Update = function(self, event, unit)
		if (self.unit ~= unit) then
			return
		end
		if (not self.LevelSkull) then
			return
		end
		local level = UnitLevel(unit)
		self.LevelSkull:SetTexture('Interface\\TargetingFrame\\UI-TargetingFrame-Skull')
		if level < 0 then
			self.LevelSkull:SetTexCoord(0, 1, 0, 1)
			if self.Level then
				self.Level:SetText ''
			end
		else
			self.LevelSkull:SetTexCoord(0, 0.01, 0, 0.01)
		end
	end
	local Enable = function(self)
		if (self.LevelSkull) then
			return true
		end
	end
	local Disable = function(self)
		return
	end
	SUIUF:AddElement('LevelSkull', Update, Enable, Disable)
end

do -- Rare / Elite dragon graphic as an SUIUF module
	local Update = function(self, event, unit)
		if (self.unit ~= unit) then
			return
		end
		if (not self.RareElite) then
			return
		end
		local c = UnitClassification(unit)

		if (self.RareElite:IsObjectType 'Texture' and not self.RareElite:GetTexture()) then
			self.RareElite:SetTexture('Interface\\AddOns\\SpartanUI_PlayerFrames\\media\\elite_rare')
			self.RareElite:SetTexCoord(0, 1, 0, 1)
			self.RareElite:SetAlpha(.75)
			if self.RareElite.short == true then
				self.RareElite:SetTexCoord(0, 1, 0, .7)
			end
			if self.RareElite.small == true then
				self.RareElite:SetTexCoord(0, 1, 0, .4)
			end
		end
		self.RareElite:Show()
		if c == 'worldboss' or c == 'elite' or c == 'rareelite' then
			self.RareElite:SetVertexColor(1, 0.9, 0)
		elseif c == 'rare' then
			self.RareElite:SetVertexColor(1, 1, 1)
		else
			self.RareElite:Hide()
		end
	end
	local Enable = function(self)
		if (self.RareElite) then
			return true
		end
	end
	local Disable = function(self)
		return
	end
	SUIUF:AddElement('RareElite', Update, Enable, Disable)
end