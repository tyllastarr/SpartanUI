local SUI = SUI
local PartyFrames = SUI.PartyFrames
----------------------------------------------------------------------------------------------------
local _, classFileName = UnitClass('player')
local colors = setmetatable({}, {__index = SUIUF.colors})

local base_plate1 = 'Interface\\AddOns\\SpartanUI_PartyFrames\\media\\base_1_full.blp'
local base_plate2 = 'Interface\\AddOns\\SpartanUI_PartyFrames\\media\\base_2_dual.blp'
local base_plate3 = 'Interface\\AddOns\\SpartanUI_PartyFrames\\media\\base_3_single.blp'
local base_plate3_Small = 'Interface\\AddOns\\SpartanUI_RaidFrames\\media\\base_3_single.blp'
local base_plate4 = 'Interface\\AddOns\\SpartanUI_PlayerFrames\\media\\classic\\base_plate4.blp' -- TargetTarget small
local base_ring1 = 'Interface\\AddOns\\SpartanUI_PlayerFrames\\media\\base_ring1' -- Player and Target
local base_ring3 = 'Interface\\AddOns\\SpartanUI_PlayerFrames\\media\\base_ring3' -- Pet and TargetTarget
local circle = 'Interface\\AddOns\\SpartanUI_PlayerFrames\\media\\circle.tga'
local base_ring = 'Interface\\AddOns\\SpartanUI_PartyFrames\\media\\base_ring1.blp'

for k, v in pairs(SUIUF.colors) do
	if not colors[k] then
		colors[k] = v
	end
end
do -- setup custom colors that we want to use
	colors.health = {0 / 255, 255 / 255, 50 / 255} -- the color of health bars
	colors.reaction[1] = {1, 50 / 255, 0} -- Hated
	colors.reaction[2] = colors.reaction[1] -- Hostile
	colors.reaction[3] = {1, 150 / 255, 0} -- Unfriendly
	colors.reaction[4] = {1, 220 / 255, 0} -- Neutral
	colors.reaction[5] = colors.health -- Friendly
	colors.reaction[6] = colors.health -- Honored
	colors.reaction[7] = colors.health -- Revered
	colors.reaction[8] = colors.health -- Exalted
end

--	Formatting functions

local OnCastbarUpdate = function(self, elapsed)
	if self.casting then
		self.duration = self.duration + elapsed
		if (self.duration >= self.max) then
			self.casting = nil
			self:Hide()
			if PostCastStop then
				PostCastStop(self:GetParent())
			end
			return
		end
		if self.Time then
			if self.delay ~= 0 then
				self.Time:SetTextColor(1, 0, 0)
			else
				self.Time:SetTextColor(1, 1, 1)
			end
			if SUI.DB.PartyFrames.castbartext == 1 then
				self.Time:SetFormattedText('%.1f', self.max - self.duration)
			else
				self.Time:SetFormattedText('%.1f', self.duration)
			end
		end
		if SUI.DB.PartyFrames.castbar == 1 then
			self:SetValue(self.max - self.duration)
		else
			self:SetValue(self.duration)
		end
	elseif self.channeling then
		self.duration = self.duration - elapsed
		if (self.duration <= 0) then
			self.channeling = nil
			self:Hide()
			if PostChannelStop then
				PostChannelStop(self:GetParent())
			end
			return
		end
		if self.Time then
			if self.delay ~= 0 then
				self.Time:SetTextColor(1, 0, 0)
			else
				self.Time:SetTextColor(1, 1, 1)
			end
			--self.Time:SetFormattedText("%.1f",self.max-self.duration);
			if SUI.DB.PartyFrames.castbartext == 0 then
				self.Time:SetFormattedText('%.1f', self.max - self.duration)
			else
				self.Time:SetFormattedText('%.1f', self.duration)
			end
		end
		if SUI.DB.PartyFrames.castbar == 1 then
			self:SetValue(self.duration)
		else
			self:SetValue(self.max - self.duration)
		end
	else
		self.unitName = nil
		self.channeling = nil
		self:SetValue(1)
		self:Hide()
	end
end

local threat = function(self, event, unit)
	local status
	unit = string.gsub(self.unit, '(.)', string.upper, 1) or string.gsub(unit, '(.)', string.upper, 1)
	if UnitExists(unit) then
		status = UnitThreatSituation(unit)
	else
		status = 0
	end
	if self.Portrait and SUI.DB.PartyFrames.threat then
		if (not self.Portrait:IsObjectType('Texture')) then
			return
		end
		if (status and status > 0) then
			local r, g, b = GetThreatStatusColor(status)
			self.Portrait:SetVertexColor(r, g, b)
		else
			self.Portrait:SetVertexColor(1, 1, 1)
		end
	elseif self.ThreatIndicatorOverlay and SUI.DB.PartyFrames.threat then
		if (status and status > 0) then
			self.ThreatIndicatorOverlay:SetVertexColor(GetThreatStatusColor(status))
			self.ThreatIndicatorOverlay:Show()
		else
			self.ThreatIndicatorOverlay:Hide()
		end
	end
end

local PostCastStop = function(self)
	if self.Time then
		self.Time:SetTextColor(1, 1, 1)
	end
end

local PostCastStart = function(self, unit, name, rank, text, castid)
	self:SetStatusBarColor(1, 0.7, 0)
end

local PostChannelStart = function(self, unit, name, rank, text, castid)
	self:SetStatusBarColor(1, 0.2, 0.7)
	-- self:SetStatusBarColor(0,1,0); --B3
end

local CreatePartyFrame = function(self, unit)
	--self:SetSize(250, 70); -- just make it we will adjust later
	do -- setup base artwork
		self.artwork = CreateFrame('Frame', nil, self)
		self.artwork:SetFrameStrata('BACKGROUND')
		self.artwork:SetFrameLevel(1)
		self.artwork:SetAllPoints(self)

		self.artwork.bg = self.artwork:CreateTexture(nil, 'BACKGROUND')
		self.artwork.bg:SetAllPoints(self)

		--	Portrait.Size = X Size of the Portrait section of the BG texture
		--  Portrait.XTexSize = This is the texcord size of the Portrait it
		-- 						is set by default for if there is no Portrait
		local Portrait = {Size = 0, XTexSize = .3}
		if SUI.DB.PartyFrames.Portrait then
			Portrait.Size = 75
			Portrait.XTexSize = 0
		end

		if SUI.DB.PartyFrames.FrameStyle == 'large' then
			self.artwork.bg:SetTexture(base_plate1)
			self:SetSize(165 + Portrait.Size, 70)
			self.artwork.bg:SetTexCoord(Portrait.XTexSize, .95, 0.015, .59)
		elseif SUI.DB.PartyFrames.FrameStyle == 'medium' then
			self.artwork.bg:SetTexture(base_plate1)
			self:SetSize(165 + Portrait.Size, 50)
			self.artwork.bg:SetTexCoord(Portrait.XTexSize, .95, 0.015, .44)
		elseif SUI.DB.PartyFrames.FrameStyle == 'small' then
			self.artwork.bg:SetTexture(base_plate3)
			self:SetSize(165 + Portrait.Size, 48)
			self.artwork.bg:SetTexCoord(Portrait.XTexSize, .95, 0.015, .77)
		elseif SUI.DB.PartyFrames.FrameStyle == 'xsmall' then
			self.artwork.bg:SetTexture(base_plate2)
			self:SetSize(165 + Portrait.Size, 35)
			self.artwork.bg:SetTexCoord(Portrait.XTexSize, .95, 0.015, .56)
		elseif SUI.DB.PartyFrames.FrameStyle == 'raidsmall' then
			self.artwork.bg:SetTexture(base_plate2)
			self:SetSize(165 + Portrait.Size, 35)
			self.artwork.bg:SetTexCoord(Portrait.XTexSize, .95, 0.015, .56)
		end

		if SUI.DB.PartyFrames.Portrait then
			-- local Portrait = CreateFrame('PlayerModel', nil, self)
			-- Portrait:SetScript("OnShow", function(self) self:SetCamera(0) end)
			-- Portrait.type = "3D"

			self.Portrait = PartyFrames:CreatePortrait(self)
			self.Portrait:SetSize(55, 55)
			self.Portrait:SetPoint('TOPLEFT', self, 'TOPLEFT', 15, -8)

		--self.artwork.ring = self.artwork:CreateTexture(nil,"BORDER");
		--self.artwork.ring:SetPoint("TOPLEFT",self,"TOPLEFT",15,-8);
		end
	end
	do -- setup status bars
		do -- cast bar
			if SUI.DB.PartyFrames.FrameStyle == 'large' then
				local cast = CreateFrame('StatusBar', nil, self)
				cast:SetFrameStrata('BACKGROUND')
				cast:SetFrameLevel(2)
				cast:SetSize(110, 16)
				cast:SetPoint('TOPRIGHT', self, 'TOPRIGHT', -55, -17)

				cast.Text = cast:CreateFontString()
				SUI:FormatFont(cast.Text, 10, 'Party')
				cast.Text:SetSize(100, 11)
				cast.Text:SetJustifyH('LEFT')
				cast.Text:SetJustifyV('BOTTOM')
				cast.Text:SetPoint('RIGHT', cast, 'RIGHT', -2, 0)

				cast.Time = cast:CreateFontString()
				SUI:FormatFont(cast.Time, 10, 'Party')
				cast.Time:SetSize(40, 11)
				cast.Time:SetJustifyH('LEFT')
				cast.Time:SetJustifyV('BOTTOM')
				cast.Time:SetPoint('LEFT', cast, 'RIGHT', 2, 0)

				self.Castbar = cast
				self.Castbar.OnUpdate = OnCastbarUpdate
				self.Castbar.PostCastStart = PostCastStart
				self.Castbar.PostChannelStart = PostChannelStart
				self.Castbar.PostCastStop = PostCastStop
			end
		end
		do -- health bar
			local health = CreateFrame('StatusBar', nil, self)
			health:SetFrameStrata('BACKGROUND')
			health:SetFrameLevel(2)
			health:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar')

			if SUI.DB.PartyFrames.FrameStyle == 'large' then
				health:SetPoint('TOPRIGHT', self.Castbar, 'BOTTOMRIGHT', 0, -2)
				health:SetSize(110, 15)
			elseif SUI.DB.PartyFrames.FrameStyle == 'medium' then
				health:SetPoint('TOPRIGHT', self, 'TOPRIGHT', -55, -19)
				health:SetSize(110, 15)
			elseif SUI.DB.PartyFrames.FrameStyle == 'small' then
				health:SetPoint('TOPRIGHT', self, 'TOPRIGHT', -55, -19)
				health:SetSize(110, 27)
			elseif SUI.DB.PartyFrames.FrameStyle == 'xsmall' then
				health:SetPoint('TOPRIGHT', self, 'TOPRIGHT', -55, -20)
				health:SetSize(110, 13)
			end

			health.value = health:CreateFontString()
			SUI:FormatFont(health.value, 10, 'Party')
			if SUI.DB.PartyFrames.FrameStyle == 'large' then
				health.value:SetSize(100, 11)
			else
				health.value:SetSize(100, 10)
			end
			health.value:SetJustifyH('LEFT')
			health.value:SetJustifyV('BOTTOM')
			health.value:SetPoint('RIGHT', health, 'RIGHT', -2, 0)
			self:Tag(health.value, PartyFrames:TextFormat('health'))

			health.ratio = health:CreateFontString()
			SUI:FormatFont(health.ratio, 10, 'Party')
			health.ratio:SetSize(40, 11)
			health.ratio:SetJustifyH('LEFT')
			health.ratio:SetJustifyV('BOTTOM')
			health.ratio:SetPoint('LEFT', health, 'RIGHT', 2, 0)
			self:Tag(health.ratio, '[perhp]%')

			self.Health = health
			self.Health.frequentUpdates = true
			self.Health.colorDisconnected = true
			self.Health.colorHealth = true
			self.Health.colorSmooth = true

			SUI:oUF_HealPrediction(self)
		end
		do -- power bar
			if
				SUI.DB.PartyFrames.FrameStyle == 'large' or SUI.DB.PartyFrames.FrameStyle == 'medium' or
					SUI.DB.PartyFrames.display.mana == true
			 then
				local power = CreateFrame('StatusBar', nil, self)
				power:SetFrameStrata('BACKGROUND')
				power:SetFrameLevel(2)

				if SUI.DB.PartyFrames.Portrait then
					power:SetSize(123, 14)
				else
					power:SetSize(self.Health:GetWidth(), 14)
				end

				if SUI.DB.PartyFrames.FrameStyle ~= 'small' and SUI.DB.PartyFrames.FrameStyle ~= 'xsmall' then
					power:SetPoint('TOPRIGHT', self.Health, 'BOTTOMRIGHT', 0, -2)
					power.value = power:CreateFontString()
					SUI:FormatFont(power.value, 10, 'Party')
					if SUI.DB.PartyFrames.FrameStyle == 'large' then
						power.value:SetSize(100, 11)
					else
						power.value:SetSize(100, 10)
					end
					power.value:SetJustifyH('LEFT')
					power.value:SetJustifyV('BOTTOM')
					power.value:SetPoint('RIGHT', power, 'RIGHT', -2, 0)
					self:Tag(power.value, PartyFrames:TextFormat('mana'))

					power.ratio = power:CreateFontString()
					SUI:FormatFont(power.ratio, 10, 'Party')
					power.ratio:SetSize(40, 11)
					power.ratio:SetJustifyH('LEFT')
					power.ratio:SetJustifyV('BOTTOM')
					power.ratio:SetPoint('LEFT', power, 'RIGHT', 2, 0)
					self:Tag(power.ratio, '[perpp]%')
				else
					power:SetPoint('TOPRIGHT', self.Health, 'BOTTOMRIGHT', 0, 0)
					power:SetHeight(3)
				end

				self.Power = power
				self.Power.colorPower = true
				self.Power.frequentUpdates = true
			end
		end
	end
	do -- setup text and icons
		local ring = CreateFrame('Frame', nil, self)
		ring:SetFrameStrata('BACKGROUND')

		self.Name = ring:CreateFontString()
		SUI:FormatFont(self.Name, 11, 'Party')
		self.Name:SetSize(140, 10)
		self.Name:SetJustifyH('LEFT')
		self.Name:SetJustifyV('BOTTOM')
		self.Name:SetPoint('TOPRIGHT', self, 'TOPRIGHT', -10, -6)
		if SUI.DB.PartyFrames.showClass then
			self:Tag(self.Name, '[SUI_ColorClass][name]')
		else
			self:Tag(self.Name, '[name]')
		end

		self.SUI_ClassIcon = ring:CreateTexture(nil, 'BORDER')
		self.SUI_ClassIcon:SetSize(20, 20)

		self.LeaderIndicator = ring:CreateTexture(nil, 'BORDER')
		self.LeaderIndicator:SetSize(20, 20)

		self.GroupRoleIndicator = ring:CreateTexture(nil, 'BORDER')
		self.GroupRoleIndicator:SetSize(25, 25)
		self.GroupRoleIndicator:SetTexture('Interface\\AddOns\\SpartanUI_PlayerFrames\\media\\icon_role')

		self.RaidTargetIndicator = ring:CreateTexture(nil, 'ARTWORK')
		self.RaidTargetIndicator:SetSize(20, 20)

		if SUI.DB.PartyFrames.Portrait then
			ring.bg = ring:CreateTexture(nil, 'BACKGROUND')
			ring.bg:SetPoint('TOPLEFT', self, 'TOPLEFT', -2, 4)
			ring.bg:SetTexture(base_ring)

			self.Level = ring:CreateFontString()
			SUI:FormatFont(self.Level, 10, 'Party')
			self.Level:SetSize(40, 12)
			self.Level:SetJustifyH('CENTER')
			self.Level:SetJustifyV('BOTTOM')
			self.Level:SetPoint('CENTER', self.Portrait, 'CENTER', -27, 27)
			self:Tag(self.Level, '[level]')

			self.PvPIndicator = ring:CreateTexture(nil, 'BORDER')
			self.PvPIndicator:SetSize(50, 50)
			self.PvPIndicator:SetPoint('CENTER', self.Portrait, 'BOTTOMLEFT', 5, -10)

			self.StatusText = ring:CreateFontString()
			SUI:FormatFont(self.StatusText, 18, 'Party')
			self.StatusText:SetPoint('CENTER', self.Portrait, 'CENTER')
			self.StatusText:SetJustifyH('CENTER')
			self:Tag(self.StatusText, '[afkdnd]')

			ring:SetAllPoints(self.Portrait)
			ring:SetFrameLevel(5)
			self.RaidTargetIndicator:SetPoint('CENTER', self.Portrait, 'CENTER')
			self.SUI_ClassIcon:SetPoint('CENTER', self.Portrait, 'CENTER', 23, 24)
			self.LeaderIndicator:SetPoint('CENTER', self.Portrait, 'TOP', -1, 6)
			self.GroupRoleIndicator:SetPoint('CENTER', self.Portrait, 'BOTTOM', 0, -10)
		else
			ring:SetAllPoints(self)
			ring:SetFrameLevel(3)
			self.SUI_ClassIcon:SetPoint('CENTER', self, 'TOPLEFT', 5, -5)
			self.LeaderIndicator:SetPoint('CENTER', self, 'LEFT', 0, 0)
			self.GroupRoleIndicator:SetPoint('CENTER', self, 'TOPRIGHT', -25, 0)
			self.RaidTargetIndicator:SetPoint('CENTER', self, 'TOPRIGHT', -15, -15)
		end
	end
	do -- setup buffs and debuffs
		self.Auras = CreateFrame('Frame', nil, self)
		self.Auras:SetSize(self:GetWidth(), 17)
		self.Auras:SetPoint('TOPRIGHT', self, 'BOTTOMRIGHT', -3, -5)
		self.Auras:SetFrameStrata('BACKGROUND')
		self.Auras:SetFrameLevel(4)
		-- settings
		self.Auras.size = SUI.DB.PartyFrames.Auras.size
		self.Auras.spacing = SUI.DB.PartyFrames.Auras.spacing
		self.Auras.showType = SUI.DB.PartyFrames.Auras.showType
		self.Auras.initialAnchor = 'TOPLEFT'
		self.Auras.gap = true -- adds an empty spacer between buffs and debuffs
		self.Auras.numBuffs = SUI.DB.PartyFrames.Auras.NumBuffs
		self.Auras.numDebuffs = SUI.DB.PartyFrames.Auras.NumDebuffs

		self.Auras.PostUpdate = PartyFrames:PostUpdateAura(self, unit)
	end
	do -- HoTs Display
		self.AuraWatch = SUI:oUF_Buffs(self, 'BOTTOMRIGHT', 'TOPRIGHT', 0)
	end
	do --Threat, SpellRange, and Ready Check
		self.Range = {
			insideAlpha = 1,
			outsideAlpha = 1 / 2
		}

		if not SUI.DB.PartyFrames.Portrait then
			local overlay = self:CreateTexture(nil, 'OVERLAY')
			overlay:SetTexture('Interface\\RaidFrame\\Raid-FrameHighlights')
			overlay:SetTexCoord(0.00781250, 0.55468750, 0.00781250, 0.27343750)
			overlay:SetAllPoints(self)
			overlay:SetVertexColor(1, 0, 0)
			overlay:Hide()
			self.ThreatIndicatorOverlay = overlay
		end

		self.ThreatIndicator = CreateFrame('Frame', nil, self)
		self.ThreatIndicator.Override = threat

		local ResurrectIcon = self:CreateTexture(nil, 'OVERLAY')
		ResurrectIcon:SetSize(25, 25)
		ResurrectIcon:SetPoint('RIGHT', self, 'CENTER', 0, 0)
		self.ResurrectIndicator = ResurrectIcon

		local ReadyCheck = self:CreateTexture(nil, 'OVERLAY')
		ReadyCheck:SetSize(30, 30)
		ReadyCheck:SetPoint('RIGHT', self, 'CENTER', 0, 0)
		self.ReadyCheckIndicator = ReadyCheck
	end
	self.TextUpdate = PartyFrames.PostUpdateText
	-- self.TextUpdate = function (self)
	-- self:Untag(self.Health.value)
	-- self:Tag(self.Health.value, PartyFrames:TextFormat("health"))
	-- if self.Power then self:Untag(self.Power.value) end
	-- if self.Power then self:Tag(self.Power.value, PartyFrames:TextFormat("mana")) end
	-- end
	return self
end

local CreateSubFrame = function(self, unit)
	self:SetSize(150, 36)
	do -- setup base artwork
		self.artwork = CreateFrame('Frame', nil, self)
		self.artwork:SetFrameStrata('BACKGROUND')
		self.artwork:SetFrameLevel(0.9)
		self.artwork:SetAllPoints(self)

		self.artwork.bg = self.artwork:CreateTexture(nil, 'BACKGROUND')
		self.artwork.bg:SetAllPoints(self)
		self.artwork.bg:SetTexture(base_plate2)
		self.artwork.bg:SetTexCoord(.3, 1, .01, .55)

		self.ThreatIndicator = CreateFrame('Frame', nil, self)
		self.ThreatIndicator.Override = threat
	end
	do -- setup status bars
		do -- health bar
			local health = CreateFrame('StatusBar', nil, self)
			health:SetFrameStrata('BACKGROUND')
			health:SetFrameLevel(.95)
			health:SetSize(self:GetWidth() / 1.70, self:GetHeight() / 2.97)
			health:SetPoint('BOTTOMLEFT', self.artwork.bg, 'BOTTOMLEFT', 11, 2)

			health.value = health:CreateFontString()
			SUI:FormatFont(health.value, 10, 'Party')
			health.value:SetSize(self:GetWidth() / 2, health:GetHeight() - 2)
			health.value:SetJustifyH('LEFT')
			health.value:SetJustifyV('BOTTOM')
			health.value:SetPoint('RIGHT', health, 'RIGHT', 0, 1)
			self:Tag(health.value, '[curhpshort]/[maxhpshort]')

			health.ratio = health:CreateFontString()
			SUI:FormatFont(health.ratio, 10, 'Party')
			health.ratio:SetSize(self:GetWidth() / 1.85, health:GetHeight() - 2)
			health.ratio:SetJustifyH('LEFT')
			health.ratio:SetJustifyV('BOTTOM')
			health.ratio:SetPoint('LEFT', health, 'RIGHT', 4, 0)
			self:Tag(health.ratio, '[perhp]%')

			self.Health = health
			self.Health.frequentUpdates = true
			self.Health.colorDisconnected = true
			self.Health.colorHealth = true
			self.Health.colorSmooth = true
		end
	end
	do -- setup text and icons
		self.Name = self:CreateFontString()
		SUI:FormatFont(self.Name, 11, 'Party')
		self.Name:SetSize(135, 12)
		self.Name:SetJustifyH('LEFT')
		self.Name:SetJustifyV('BOTTOM')
		self.Name:SetPoint('TOPRIGHT', self.artwork.bg, 'TOPRIGHT', 0, -4)
		if SUI.DB.PartyFrames.showClass then
			self:Tag(self.Name, '[level][SUI_ColorClass][name]')
		else
			self:Tag(self.Name, '[level][name]')
		end
	end
	return self
end

local CreateUnitFrame = function(self, unit)
	if (self:GetAttribute('unitoUFfix') == 'target') and SUI.DB.PartyFrames.display.target then
		self = CreateSubFrame(self, unit)
	elseif
		(self:GetAttribute('unitoUFfix') == 'pet') and
			(SUI.DB.PartyFrames.FrameStyle == 'large' or (not SUI.DB.PartyFrames.display.target)) and
			SUI.DB.PartyFrames.display.pet
	 then
		self = CreateSubFrame(self, unit)
	elseif (unit == 'party') then
		self = CreatePartyFrame(self, unit)
	end

	self = PartyFrames:MakeMovable(self)

	return self
end

SUIUF:RegisterStyle('Spartan_PartyFrames', CreateUnitFrame)

local OptionsSetup = function()
	SUI.opt.args['PartyFrames'].args['auras'] = {
		name = SUI.L['BuffDebuff'],
		type = 'group',
		order = 2,
		args = {
			display = {
				name = SUI.L['DispBuffDebuff'],
				type = 'toggle',
				order = 1,
				get = function(info)
					return SUI.DB.PartyFrames.showAuras
				end,
				set = function(info, val)
					SUI.DB.PartyFrames.showAuras = val
					addon:UpdateAura()
				end
			},
			showType = {
				name = SUI.L['ShowType'],
				type = 'toggle',
				order = 2,
				get = function(info)
					return SUI.DB.PartyFrames.Auras.showType
				end,
				set = function(info, val)
					SUI.DB.PartyFrames.Auras.showType = val
					addon:UpdateAura()
				end
			},
			numBufs = {
				name = SUI.L['NumBuffs'],
				type = 'range',
				width = 'full',
				order = 11,
				min = 0,
				max = 50,
				step = 1,
				get = function(info)
					return SUI.DB.PartyFrames.Auras.NumBuffs
				end,
				set = function(info, val)
					SUI.DB.PartyFrames.Auras.NumBuffs = val
					addon:UpdateAura()
				end
			},
			numDebuffs = {
				name = SUI.L['NumDebuff'],
				type = 'range',
				width = 'full',
				order = 12,
				min = 0,
				max = 50,
				step = 1,
				get = function(info)
					return SUI.DB.PartyFrames.Auras.NumDebuffs
				end,
				set = function(info, val)
					SUI.DB.PartyFrames.Auras.NumDebuffs = val
					addon:UpdateAura()
				end
			},
			size = {
				name = SUI.L['SizeBuff'],
				type = 'range',
				width = 'full',
				order = 13,
				min = 0,
				max = 60,
				step = 1,
				get = function(info)
					return SUI.DB.PartyFrames.Auras.size
				end,
				set = function(info, val)
					SUI.DB.PartyFrames.Auras.size = val
					addon:UpdateAura()
				end
			},
			spacing = {
				name = SUI.L['SpacingBuffDebuffs'],
				type = 'range',
				width = 'full',
				order = 14,
				min = 0,
				max = 50,
				step = 1,
				get = function(info)
					return SUI.DB.PartyFrames.Auras.spacing
				end,
				set = function(info, val)
					SUI.DB.PartyFrames.Auras.spacing = val
					addon:UpdateAura()
				end
			}
		}
	}
	SUI.opt.args['PartyFrames'].args['castbar'] = {
		name = SUI.L['PrtyCast'],
		type = 'group',
		order = 3,
		desc = SUI.L['PrtyCastDesc'],
		args = {
			castbar = {
				name = SUI.L['FillDir'],
				type = 'select',
				style = 'radio',
				values = {[0] = SUI.L['FillLR'], [1] = SUI.L['DepRL']},
				get = function(info)
					return SUI.DB.PartyFrames.castbar
				end,
				set = function(info, val)
					SUI.DB.PartyFrames.castbar = val
				end
			},
			castbartext = {
				name = SUI.L['TextStyle'],
				type = 'select',
				style = 'radio',
				values = {[0] = SUI.L['CountUp'], [1] = SUI.L['CountDown']},
				get = function(info)
					return SUI.DB.PartyFrames.castbartext
				end,
				set = function(info, val)
					SUI.DB.PartyFrames.castbartext = val
				end
			}
		}
	}

	SUI.opt.args['PartyFrames'].args['FramePreSets'] = {
		name = SUI.L['PreSets'],
		type = 'select',
		order = 1,
		values = {
			['custom'] = SUI.L['Custom'],
			['tank'] = SUI.L['Tank'],
			['dps'] = SUI.L['DPS'],
			['healer'] = SUI.L['Healer']
		},
		get = function(info)
			return SUI.DB.PartyFrames.preset
		end,
		set = function(info, val)
			SUI.DB.PartyFrames.preset = val
			if val == 'tank' then
				SUI.DB.PartyFrames.FrameStyle = 'medium'
				SUI.DB.PartyFrames.Portrait = false
			elseif val == 'dps' then
				SUI.DB.PartyFrames.FrameStyle = 'xsmall'
				SUI.DB.PartyFrames.Portrait = false
				SUI.DB.PartyFrames.showAuras = false
			elseif val == 'healer' then
				SUI.DB.PartyFrames.FrameStyle = 'small'
				SUI.DB.PartyFrames.Portrait = false
			end
		end
	}
	SUI.opt.args['PartyFrames'].args['FrameStyle'] = {
		name = SUI.L['FrameStyle'],
		type = 'select',
		order = 2,
		values = {
			['large'] = SUI.L['StyleLarge'],
			['medium'] = SUI.L['StyleMed'],
			['small'] = SUI.L['StyleSmall'],
			['xsmall'] = SUI.L['StyleXSmall']
		},
		get = function(info)
			return SUI.DB.PartyFrames.FrameStyle
		end,
		set = function(info, val)
			if (InCombatLockdown()) then
				return SUI:Print(ERR_NOT_IN_COMBAT)
			end
			SUI.DB.PartyFrames.FrameStyle = val
			SUI.DB.PartyFrames.preset = 'custom'
		end
	}
	SUI.opt.args['PartyFrames'].args['mana'] = {
		name = SUI.L['DispMana'],
		type = 'toggle',
		order = 2.5,
		hidden = function(info)
			if SUI.DB.PartyFrames.FrameStyle == 'xsmall' or SUI.DB.PartyFrames.FrameStyle == 'small' then
				return false
			else
				return true
			end
		end,
		get = function(info)
			return SUI.DB.PartyFrames.display.mana
		end,
		set = function(info, val)
			if (InCombatLockdown()) then
				return SUI:Print(ERR_NOT_IN_COMBAT)
			end
			SUI.DB.PartyFrames.display.mana = val
			SUI.DB.PartyFrames.preset = 'custom'
		end
	}
	SUI.opt.args['PartyFrames'].args['Portrait'] = {
		name = SUI.L['DispPort'],
		type = 'toggle',
		order = 3,
		get = function(info)
			return SUI.DB.PartyFrames.Portrait
		end,
		set = function(info, val)
			if (InCombatLockdown()) then
				return SUI:Print(ERR_NOT_IN_COMBAT)
			end
			SUI.DB.PartyFrames.Portrait = val
			SUI.DB.PartyFrames.preset = 'custom'
		end
	}
	SUI.opt.args['PartyFrames'].args['Portrait3D'] = {
		name = SUI.L['Portrait3D'],
		type = 'toggle',
		order = 3.1,
		get = function(info)
			return SUI.DB.PartyFrames.Portrait3D
		end,
		set = function(info, val)
			SUI.DB.PartyFrames.Portrait3D = val
		end
	}
	SUI.opt.args['PartyFrames'].args['threat'] = {
		name = SUI.L['DispThreat'],
		type = 'toggle',
		order = 4,
		get = function(info)
			return SUI.DB.PartyFrames.threat
		end,
		set = function(info, val)
			SUI.DB.PartyFrames.threat = val
			SUI.DB.PartyFrames.preset = 'custom'
		end
	}
end

function PartyFrames:Classic()
	--Create the options
	OptionsSetup()
	--DB Fix
	if SUI.DB.PartyFrames.FrameStyle == 'Large' then
		SUI.DB.PartyFrames.FrameStyle = 'large'
	end

	--Set the style
	SUIUF:SetActiveStyle('Spartan_PartyFrames')
	--Create the frames
	local party =
		SUIUF:SpawnHeader(
		'SUI_PartyFrameHeader',
		nil,
		nil,
		'showRaid',
		SUI.DB.PartyFrames.showRaid,
		'showParty',
		SUI.DB.PartyFrames.showParty,
		'showPlayer',
		SUI.DB.PartyFrames.showPlayer,
		'showSolo',
		SUI.DB.PartyFrames.showSolo,
		'yOffset',
		-16,
		'xOffset',
		0,
		'columnAnchorPoint',
		'TOPLEFT',
		'initial-anchor',
		'TOPLEFT',
		'template',
		'SUI_PartyMemberTemplate'
	)

	return (party)
end

local function CreatePortrait(self)
	if SUI.DB.PlayerFrames.Portrait3D then
		local Portrait = CreateFrame('PlayerModel', nil, self)
		Portrait:SetScript(
			'OnShow',
			function(self)
				self:SetCamera(1)
			end
		)
		Portrait.type = '3D'
		if SUI.DB.PlayerFrames.Portrait3D then
			Portrait.bg2 = Portrait:CreateTexture(nil, 'BACKGROUND')
			Portrait.bg2:SetTexture(circle)
			Portrait.bg2:SetPoint('TOPLEFT', Portrait, 'TOPLEFT', -10, 10)
			Portrait.bg2:SetPoint('BOTTOMRIGHT', Portrait, 'BOTTOMRIGHT', 10, -10)
		end
		Portrait:SetFrameLevel(1)
		return Portrait
	else
		return self:CreateTexture(nil, 'BORDER')
	end
end

--	Updating functions
local PostUpdateText = function(self, unit)
	self:Untag(self.Health.value)
	if self.Power then
		self:Untag(self.Power.value)
	end
	self:Tag(self.Health.value, PlayerFrames:TextFormat('health'))
	if self.Power then
		self:Tag(self.Power.value, PlayerFrames:TextFormat('mana'))
	end
end

local PostUpdateAura = function(self, unit, mode)
	-- Buffs
	if mode == 'Buffs' then
		if SUI.DB.Styles.Classic.Frames[unit].Buffs.Display then
			self.size = SUI.DB.Styles.Classic.Frames[unit].Buffs.size
			self.spacing = SUI.DB.Styles.Classic.Frames[unit].Buffs.spacing
			self.showType = SUI.DB.Styles.Classic.Frames[unit].Buffs.showType
			self.numBuffs = SUI.DB.Styles.Classic.Frames[unit].Buffs.Number
			self.onlyShowPlayer = SUI.DB.Styles.Classic.Frames[unit].Buffs.onlyShowPlayer
			self:Show()
		else
			self:Hide()
		end
	end

	-- Debuffs
	if mode == 'Debuffs' then
		if SUI.DB.Styles.Classic.Frames[unit].Debuffs.Display then
			self.size = SUI.DB.Styles.Classic.Frames[unit].Debuffs.size
			self.spacing = SUI.DB.Styles.Classic.Frames[unit].Debuffs.spacing
			self.showType = SUI.DB.Styles.Classic.Frames[unit].Debuffs.showType
			self.numDebuffs = SUI.DB.Styles.Classic.Frames[unit].Debuffs.Number
			self.onlyShowPlayer = SUI.DB.Styles.Classic.Frames[unit].Debuffs.onlyShowPlayer
			self:Show()
		else
			self:Hide()
		end
	end
end

local PostUpdateColor = function(self, unit)
	self.Health.frequentUpdates = true
	self.Health.colorDisconnected = true
	if SUI.DB.PlayerFrames.bars[unit].color == 'reaction' then
		self.Health.colorReaction = true
		self.Health.colorClass = false
	elseif SUI.DB.PlayerFrames.bars[unit].color == 'happiness' then
		self.Health.colorHappiness = true
		self.Health.colorReaction = false
		self.Health.colorClass = false
	elseif SUI.DB.PlayerFrames.bars[unit].color == 'class' then
		self.Health.colorClass = true
		self.Health.colorReaction = false
	else
		self.Health.colorClass = false
		self.Health.colorReaction = false
		self.Health.colorSmooth = true
	end
	self.colors.smooth = {1, 0, 0, 1, 1, 0, 0, 1, 0}
	self.Health.colorHealth = true
end

-- Create Frames
local CreatePlayerFrame = function(self, unit)
	self:SetSize(280, 80)
	do -- setup base artwork
		local artwork = CreateFrame('Frame', nil, self)
		artwork:SetFrameStrata('BACKGROUND')
		artwork:SetFrameLevel(2)
		artwork:SetAllPoints(self)

		artwork.bg = artwork:CreateTexture(nil, 'BACKGROUND')
		artwork.bg:SetPoint('CENTER')
		artwork.bg:SetTexture(base_plate1)
		self.artwork = artwork

		self.Portrait = CreatePortrait(self)
		self.Portrait:SetSize(62, 62)
		self.Portrait:SetPoint('CENTER', self, 'CENTER', 80, 3)

		self.ThreatIndicator = CreateFrame('Frame', nil, self)
		self.ThreatIndicator.Override = threat
	end
	do -- setup status bars
		do -- cast bar
			local cast = CreateFrame('StatusBar', nil, self)
			cast:SetFrameStrata('BACKGROUND')
			cast:SetFrameLevel(2)
			cast:SetSize(153, 16)
			cast:SetPoint('TOPLEFT', self, 'TOPLEFT', 36, -23)

			cast.Text = cast:CreateFontString()
			SUI:FormatFont(cast.Text, 10, 'Player')
			cast.Text:SetSize(135, 11)
			cast.Text:SetJustifyH('RIGHT')
			cast.Text:SetJustifyV('MIDDLE')
			cast.Text:SetPoint('LEFT', cast, 'LEFT', 4, 0)

			cast.Time = cast:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
			cast.Time:SetSize(90, 11)
			cast.Time:SetJustifyH('RIGHT')
			cast.Time:SetJustifyV('MIDDLE')
			cast.Time:SetPoint('RIGHT', cast, 'LEFT', -2, 0)

			self.Castbar = cast
			self.Castbar.OnUpdate = OnCastbarUpdate
			self.Castbar.PostCastStart = PostCastStart
			self.Castbar.PostChannelStart = PostChannelStart
			self.Castbar.PostCastStop = PostCastStop
		end
		do -- health bar
			local health = CreateFrame('StatusBar', nil, self)
			health:SetFrameStrata('BACKGROUND')
			health:SetFrameLevel(2)
			health:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar')
			health:SetSize(150, 16)
			health:SetPoint('TOPLEFT', self.Castbar, 'BOTTOMLEFT', 0, -2)

			health.value = health:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
			health.value:SetSize(135, 11)
			health.value:SetJustifyH('RIGHT')
			health.value:SetJustifyV('MIDDLE')
			health.value:SetPoint('LEFT', health, 'LEFT', 4, 0)
			self:Tag(health.value, PlayerFrames:TextFormat('health'))

			health.ratio = health:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
			health.ratio:SetSize(90, 11)
			health.ratio:SetJustifyH('RIGHT')
			health.ratio:SetJustifyV('MIDDLE')
			health.ratio:SetPoint('RIGHT', health, 'LEFT', -2, 0)
			self:Tag(health.ratio, '[perhp]%')

			self.Health = health

			self.Health.frequentUpdates = true
			self.Health.colorDisconnected = true
			if SUI.DB.PlayerFrames.bars[unit].color == 'reaction' then
				self.Health.colorReaction = true
			elseif SUI.DB.PlayerFrames.bars[unit].color == 'happiness' then
				self.Health.colorHappiness = true
			elseif SUI.DB.PlayerFrames.bars[unit].color == 'class' then
				self.Health.colorClass = true
			else
				self.Health.colorSmooth = true
			end
			self.colors.smooth = {1, 0, 0, 1, 1, 0, 0, 1, 0}
			self.Health.colorHealth = true
			self.Health.Smooth = true

			SUI:oUF_HealPrediction(self)
		end
		do -- power bar
			local power = CreateFrame('StatusBar', nil, self)
			power:SetFrameStrata('BACKGROUND')
			power:SetFrameLevel(2)
			power:SetWidth(155)
			power:SetHeight(14)
			power:SetPoint('TOPLEFT', self.Health, 'BOTTOMLEFT', 0, -2)

			power.value = power:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
			power.value:SetWidth(135)
			power.value:SetHeight(11)
			power.value:SetJustifyH('RIGHT')
			power.value:SetJustifyV('MIDDLE')
			power.value:SetPoint('LEFT', power, 'LEFT', 4, 0)
			self:Tag(power.value, PlayerFrames:TextFormat('mana'))

			power.ratio = power:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
			power.ratio:SetWidth(90)
			power.ratio:SetHeight(11)
			power.ratio:SetJustifyH('RIGHT')
			power.ratio:SetJustifyV('MIDDLE')
			power.ratio:SetPoint('RIGHT', power, 'LEFT', -2, 0)
			self:Tag(power.ratio, '[perpp]%')

			self.Power = power
			self.Power.colorPower = true
			self.Power.frequentUpdates = true
		end
	end
	do -- setup ring, icons, and text
		local ring = CreateFrame('Frame', nil, self)
		ring:SetFrameStrata('BACKGROUND')
		ring:SetAllPoints(self.Portrait)
		ring:SetFrameLevel(4)
		ring.bg = ring:CreateTexture(nil, 'BACKGROUND')
		ring.bg:SetPoint('CENTER', ring, 'CENTER', -80, -3)
		ring.bg:SetTexture(base_ring1)

		self.Name = ring:CreateFontString()
		SUI:FormatFont(self.Name, 12, 'Player')
		self.Name:SetSize(170, 12)
		self.Name:SetJustifyH('RIGHT')
		self.Name:SetPoint('TOPLEFT', self, 'TOPLEFT', 5, -6)
		if SUI.DB.PlayerFrames.showClass then
			self:Tag(self.Name, '[SUI_ColorClass][name]')
		else
			self:Tag(self.Name, '[name]')
		end

		self.Level = ring:CreateFontString(nil, 'BORDER', 'SUI_FontOutline10')
		self.Level:SetSize(40, 11)
		self.Level:SetJustifyH('CENTER')
		self.Level:SetJustifyV('MIDDLE')
		self.Level:SetPoint('CENTER', ring, 'CENTER', 53, 12)
		self:Tag(self.Level, '[level]')

		self.SUI_ClassIcon = ring:CreateTexture(nil, 'BORDER')
		self.SUI_ClassIcon:SetSize(19, 19)
		self.SUI_ClassIcon:SetPoint('CENTER', ring, 'CENTER', -29, 21)

		self.LeaderIndicator = ring:CreateTexture(nil, 'BORDER')
		self.LeaderIndicator:SetSize(20, 20)
		self.LeaderIndicator:SetPoint('CENTER', ring, 'TOP')

		self.SUI_RaidGroup = ring:CreateTexture(nil, 'BORDER')
		self.SUI_RaidGroup:SetSize(32, 32)
		self.SUI_RaidGroup:SetPoint('CENTER', ring, 'TOPRIGHT', -6, -6)
		self.SUI_RaidGroup:SetTexture(circle)

		self.SUI_RaidGroup.Text = ring:CreateFontString(nil, 'BORDER', 'SUI_FontOutline11')
		self.SUI_RaidGroup.Text:SetSize(40, 11)
		self.SUI_RaidGroup.Text:SetJustifyH('CENTER')
		self.Level:SetJustifyV('MIDDLE')
		self.SUI_RaidGroup.Text:SetPoint('CENTER', self.SUI_RaidGroup, 'CENTER', 0, 0)
		self:Tag(self.SUI_RaidGroup.Text, '[group]')

		self.PvPIndicator = ring:CreateTexture(nil, 'BORDER')
		self.PvPIndicator:SetSize(48, 48)
		self.PvPIndicator:SetPoint('CENTER', ring, 'CENTER', 32, -40)

		self.GroupRoleIndicator = ring:CreateTexture(nil, 'BORDER')
		self.GroupRoleIndicator:SetSize(28, 28)
		self.GroupRoleIndicator:SetPoint('CENTER', ring, 'CENTER', -20, -35)
		self.GroupRoleIndicator:SetTexture('Interface\\AddOns\\SpartanUI_PlayerFrames\\media\\icon_role')

		self.RestingIndicator = ring:CreateTexture(nil, 'ARTWORK')
		self.RestingIndicator:SetSize(32, 30)
		self.RestingIndicator:SetPoint('CENTER', self.SUI_ClassIcon, 'CENTER')

		self.CombatIndicator = ring:CreateTexture(nil, 'ARTWORK')
		self.CombatIndicator:SetSize(32, 32)
		self.CombatIndicator:SetPoint('CENTER', self.Level, 'CENTER')

		self.RaidTargetIndicator = ring:CreateTexture(nil, 'ARTWORK')
		self.RaidTargetIndicator:SetSize(24, 24)
		self.RaidTargetIndicator:SetPoint('CENTER', ring, 'LEFT', -2, -3)

		self.StatusText = ring:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline22')
		self.StatusText:SetPoint('CENTER', ring, 'CENTER')
		self.StatusText:SetJustifyH('CENTER')
		self:Tag(self.StatusText, '[afkdnd]')

		self.ComboPoints = ring:CreateFontString(nil, 'BORDER', 'SUI_FontOutline13')
		self.ComboPoints:SetPoint('BOTTOMLEFT', self.Name, 'TOPLEFT', 12, -2)
		if unit == 'player' then
			local ClassPower = {}
			for index = 1, 10 do
				local Bar = CreateFrame('StatusBar', nil, self)
				Bar:SetStatusBarTexture(Smoothv2)

				-- Position and size.
				Bar:SetSize(16, 5)
				if (index == 1) then
					Bar:SetPoint('LEFT', self.ComboPoints, 'RIGHT', (index - 1) * Bar:GetWidth(), -1)
				else
					Bar:SetPoint('LEFT', ClassPower[index - 1], 'RIGHT', 3, 0)
				end
				-- Bar:SetPoint('LEFT', self, 'RIGHT', , 0)

				ClassPower[index] = Bar
			end

			-- Register with oUF
			self.ClassPower = ClassPower
		end
	end
	do -- setup buffs and debuffs
		if SUI.DB.Styles.Classic.Frames[unit] and PlayerFrames then
			self.BuffAnchor = CreateFrame('Frame', nil, self)
			self.BuffAnchor:SetSize(self:GetWidth() - 10, 1)
			self.BuffAnchor:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 10, 0)
			self.BuffAnchor:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', 0, 0)

			self = PlayerFrames:Buffs(self, unit)
		end
	end
	self.TextUpdate = PostUpdateText
	self.ColorUpdate = PostUpdateColor
	return self
end

local CreateTargetFrame = function(self, unit)
	self:SetSize(295, 80)
	do --setup base artwork
		local artwork = CreateFrame('Frame', nil, self)
		artwork:SetFrameStrata('BACKGROUND')
		artwork:SetFrameLevel(3)
		artwork:SetAllPoints(self)

		artwork.bg = artwork:CreateTexture(nil, 'BACKGROUND')
		artwork.bg:SetAllPoints(self)
		-- artwork.bg:SetPoint("CENTER",self,"CENTER",0,0);
		artwork.bg:SetTexture(base_plate1)
		artwork.bg:SetTexCoord(0.80859375, 0.2, 0.1953125, 0.8046875)
		self.artwork = artwork

		self.Portrait = CreatePortrait(self)
		self.Portrait:SetSize(64, 64)
		self.Portrait:SetPoint('CENTER', self, 'CENTER', -70, 3)

		self.ThreatIndicator = CreateFrame('Frame', nil, self)
		self.ThreatIndicator.Override = threat
	end
	do -- setup status bars
		do -- cast bar
			local cast = CreateFrame('StatusBar', nil, self)
			cast:SetFrameStrata('BACKGROUND')
			cast:SetFrameLevel(3)
			cast:SetSize(143, 16)
			cast:SetPoint('TOPRIGHT', self, 'TOPRIGHT', -46, -23)

			cast.Text = cast:CreateFontString()
			SUI:FormatFont(cast.Text, 10, 'Player')
			cast.Text:SetSize(125, 11)
			cast.Text:SetJustifyH('LEFT')
			cast.Text:SetJustifyV('MIDDLE')
			cast.Text:SetPoint('RIGHT', cast, 'RIGHT', -4, 0)

			cast.Time = cast:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
			cast.Time:SetSize(90, 11)
			cast.Time:SetJustifyH('LEFT')
			cast.Time:SetJustifyV('MIDDLE')
			cast.Time:SetPoint('LEFT', cast, 'RIGHT', 2, 0)

			self.Castbar = cast
			self.Castbar.OnUpdate = OnCastbarUpdate
			self.Castbar.PostCastStart = PostCastStart
			self.Castbar.PostChannelStart = PostChannelStart
			self.Castbar.PostCastStop = PostCastStop
		end
		do -- health bar
			local health = CreateFrame('StatusBar', nil, self)
			health:SetFrameStrata('BACKGROUND')
			health:SetFrameLevel(3)
			health:SetSize(140, 16)
			health:SetPoint('TOPRIGHT', self.Castbar, 'BOTTOMRIGHT', 0, -2)
			health:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar')

			health.value = health:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
			health.value:SetSize(125, 11)
			health.value:SetJustifyH('LEFT')
			health.value:SetJustifyV('MIDDLE')
			health.value:SetPoint('RIGHT', health, 'RIGHT', -4, 0)
			self:Tag(health.value, PlayerFrames:TextFormat('health'))

			health.ratio = health:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
			health.ratio:SetSize(90, 11)
			health.ratio:SetJustifyH('LEFT')
			health.ratio:SetJustifyV('MIDDLE')
			health.ratio:SetPoint('LEFT', health, 'RIGHT', 2, 0)
			self:Tag(health.ratio, '[perhp]%')

			-- local Background = health:CreateTexture(nil, 'BACKGROUND')
			-- Background:SetAllPoints(health)
			-- Background:SetTexture(1, 1, 1, .08)

			self.Health = health
			--self.Health.bg = Background;
			self.Health.colorTapping = true
			self.Health.frequentUpdates = true
			self.Health.colorDisconnected = true
			if SUI.DB.PlayerFrames.bars[unit].color == 'reaction' then
				self.Health.colorReaction = true
			elseif SUI.DB.PlayerFrames.bars[unit].color == 'happiness' then
				self.Health.colorHappiness = true
			elseif SUI.DB.PlayerFrames.bars[unit].color == 'class' then
				self.Health.colorClass = true
			else
				self.Health.colorSmooth = true
			end

			self.colors.smooth = {1, 0, 0, 1, 1, 0, 0, 1, 0}
			self.Health.colorHealth = true

			SUI:oUF_HealPrediction(self)
		end
		do -- power bar
			local power = CreateFrame('StatusBar', nil, self)
			power:SetFrameStrata('BACKGROUND')
			power:SetFrameLevel(3)
			power:SetSize(145, 14)
			power:SetPoint('TOPRIGHT', self.Health, 'BOTTOMRIGHT', 0, -2)

			power.value = power:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
			power.value:SetSize(125, 11)
			power.value:SetJustifyH('LEFT')
			power.value:SetJustifyV('MIDDLE')
			power.value:SetPoint('RIGHT', power, 'RIGHT', -4, 0)
			self:Tag(power.value, PlayerFrames:TextFormat('mana'))

			power.ratio = power:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
			power.ratio:SetSize(90, 11)
			power.ratio:SetJustifyH('LEFT')
			power.ratio:SetJustifyV('MIDDLE')
			power.ratio:SetPoint('LEFT', power, 'RIGHT', 2, 0)
			self:Tag(power.ratio, '[perpp]%')

			self.Power = power
			self.Power.colorPower = true
			self.Power.frequentUpdates = true
		end
	end
	do -- setup ring, icons, and text
		local ring = CreateFrame('Frame', nil, self)
		ring:SetFrameStrata('BACKGROUND')
		ring:SetAllPoints(self.Portrait)
		ring:SetFrameLevel(4)
		ring.bg = ring:CreateTexture(nil, 'BACKGROUND')
		ring.bg:SetPoint('CENTER', ring, 'CENTER', 80, -3)
		ring.bg:SetTexture(base_ring1)
		ring.bg:SetTexCoord(1, 0, 0, 1)

		self.Name = ring:CreateFontString()
		SUI:FormatFont(self.Name, 12, 'Player')
		self.Name:SetWidth(170)
		self.Name:SetHeight(12)
		self.Name:SetJustifyH('LEFT')
		self.Name:SetJustifyV('MIDDLE')
		self.Name:SetPoint('TOPRIGHT', self, 'TOPRIGHT', -5, -6)
		if SUI.DB.PlayerFrames.showClass then
			self:Tag(self.Name, '[SUI_ColorClass][name]')
		else
			self:Tag(self.Name, '[name]')
		end

		self.Level = ring:CreateFontString(nil, 'BORDER', 'SUI_FontOutline10')
		self.Level:SetWidth(40)
		self.Level:SetHeight(11)
		self.Level:SetJustifyH('CENTER')
		self.Level:SetJustifyV('MIDDLE')
		self.Level:SetPoint('CENTER', ring, 'CENTER', -49, 12)
		self:Tag(self.Level, '[difficulty][level]')

		self.SUI_ClassIcon = ring:CreateTexture(nil, 'BORDER')
		self.SUI_ClassIcon:SetSize(19, 19)
		self.SUI_ClassIcon:SetPoint('CENTER', ring, 'CENTER', 29, 21)

		self.LeaderIndicator = ring:CreateTexture(nil, 'BORDER')
		self.LeaderIndicator:SetWidth(20)
		self.LeaderIndicator:SetHeight(20)
		self.LeaderIndicator:SetPoint('CENTER', ring, 'TOP')

		self.PvPIndicator = ring:CreateTexture(nil, 'BORDER')
		self.PvPIndicator:SetWidth(48)
		self.PvPIndicator:SetHeight(48)
		self.PvPIndicator:SetPoint('CENTER', ring, 'CENTER', -16, -40)

		self.LevelSkull = ring:CreateTexture(nil, 'ARTWORK')
		self.LevelSkull:SetWidth(16)
		self.LevelSkull:SetHeight(16)
		self.LevelSkull:SetPoint('CENTER', self.Level, 'CENTER')

		self.RareElite = ring:CreateTexture(nil, 'ARTWORK')
		self.RareElite:SetWidth(150)
		self.RareElite:SetHeight(150)
		self.RareElite:SetPoint('CENTER', ring, 'CENTER', -12, -4)

		self.RaidTargetIndicator = ring:CreateTexture(nil, 'ARTWORK')
		self.RaidTargetIndicator:SetWidth(24)
		self.RaidTargetIndicator:SetHeight(24)
		self.RaidTargetIndicator:SetPoint('CENTER', ring, 'RIGHT', 2, -4)

		self.StatusText = ring:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline22')
		self.StatusText:SetPoint('CENTER', ring, 'CENTER')
		self.StatusText:SetJustifyH('CENTER')
		self:Tag(self.StatusText, '[afkdnd]')
	end
	do -- setup buffs and debuffs
		if SUI.DB.Styles.Classic.Frames[unit] and PlayerFrames then
			self.BuffAnchor = CreateFrame('Frame', nil, self)
			self.BuffAnchor:SetSize(self:GetWidth() - 35, 1)
			self.BuffAnchor:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 30, 0)
			self.BuffAnchor:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', -5, 0)

			self = PlayerFrames:Buffs(self, unit)
		end
	end
	self.TextUpdate = PostUpdateText
	self.ColorUpdate = PostUpdateColor
	return self
end

local CreatePetFrame = function(self, unit)
	self:SetSize(210, 60)
	do -- setup base artwork
		local artwork = CreateFrame('Frame', nil, self)
		artwork:SetFrameStrata('BACKGROUND')
		artwork:SetFrameLevel(0)
		artwork:SetAllPoints(self)

		artwork.bg = artwork:CreateTexture(nil, 'BACKGROUND')
		artwork.bg:SetPoint('LEFT', self, 'LEFT', -23, 0)
		artwork.bg:SetTexture(base_plate3)
		artwork.bg:SetSize(256, 85)
		artwork.bg:SetTexCoord(0, 1, 0, 85 / 128)
		self.artwork = artwork

		if SUI.DB.PlayerFrames.PetPortrait then
			self.Portrait = CreatePortrait(self)
			self.Portrait:SetSize(56, 50)
			self.Portrait:SetPoint('CENTER', self, 'CENTER', 87, -8)
		end

		self.ThreatIndicator = CreateFrame('Frame', nil, self)
		self.ThreatIndicator.Override = threat
	end
	do -- setup status bars
		do -- cast bar
			local cast = CreateFrame('StatusBar', nil, self)
			cast:SetFrameStrata('BACKGROUND')
			cast:SetFrameLevel(2)
			cast:SetParent(self)
			cast:SetSize(120, 15)
			cast:SetPoint('TOPLEFT', self, 'TOPLEFT', 36, -23)

			cast.Text = cast:CreateFontString()
			SUI:FormatFont(cast.Text, 10, 'Player')
			cast.Text:SetHeight(11)
			cast.Text:SetPoint('LEFT', cast, 'LEFT', 0, 0)
			cast.Text:SetPoint('RIGHT', cast, 'RIGHT', -10, 0)
			cast.Text:SetJustifyH('RIGHT')
			cast.Text:SetJustifyV('MIDDLE')
			cast.Text:SetPoint('LEFT', cast, 'LEFT', 4, 0)

			cast.Time = cast:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
			cast.Time:SetWidth(40)
			cast.Time:SetHeight(11)
			cast.Time:SetJustifyH('RIGHT')
			cast.Time:SetJustifyV('MIDDLE')
			cast.Time:SetPoint('RIGHT', cast, 'LEFT', -2, 0)

			self.Castbar = cast
			self.Castbar.OnUpdate = OnCastbarUpdate
			self.Castbar.PostCastStart = PostCastStart
			self.Castbar.PostChannelStart = PostChannelStart
			self.Castbar.PostCastStop = PostCastStop
		end
		do -- health bar
			local health = CreateFrame('StatusBar', nil, self)
			health:SetFrameStrata('BACKGROUND')
			health:SetFrameLevel(2)
			health:SetSize(120, 16)
			health:SetPoint('TOPLEFT', self.Castbar, 'BOTTOMLEFT', 0, -2)
			health:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar')

			health.value = health:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
			health.value:SetHeight(11)
			health.value:SetPoint('LEFT', health, 'LEFT', 0, 0)
			health.value:SetPoint('RIGHT', health, 'RIGHT', -8, 0)
			health.value:SetJustifyH('RIGHT')
			health.value:SetJustifyV('MIDDLE')
			self:Tag(health.value, PlayerFrames:TextFormat('health'))

			health.ratio = health:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
			health.ratio:SetWidth(40)
			health.ratio:SetHeight(11)
			health.ratio:SetJustifyH('RIGHT')
			health.ratio:SetJustifyV('MIDDLE')
			health.ratio:SetPoint('RIGHT', health, 'LEFT', -2, 0)
			self:Tag(health.ratio, '[perhp]%')

			-- local Background = health:CreateTexture(nil, 'BACKGROUND')
			-- Background:SetAllPoints(health)
			-- Background:SetTexture(1, 1, 1, .08)

			self.Health = health
			--self.Health.bg = Background;

			self.Health.frequentUpdates = true
			self.Health.colorDisconnected = true
			if SUI.DB.PlayerFrames.bars[unit].color == 'reaction' then
				self.Health.colorReaction = true
			elseif SUI.DB.PlayerFrames.bars[unit].color == 'happiness' then
				self.Health.colorHappiness = true
			elseif SUI.DB.PlayerFrames.bars[unit].color == 'class' then
				self.Health.colorClass = true
			else
				self.Health.colorSmooth = true
			end
			self.colors.smooth = {1, 0, 0, 1, 1, 0, 0, 1, 0}
			self.Health.colorHealth = true

			SUI:oUF_HealPrediction(self)
		end
		do -- power bar
			local power = CreateFrame('StatusBar', nil, self)
			power:SetFrameStrata('BACKGROUND')
			power:SetFrameLevel(2)
			power:SetWidth(135)
			power:SetHeight(14)
			power:SetPoint('TOPLEFT', self.Health, 'BOTTOMLEFT', 0, -1)

			power.value = power:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
			power.value:SetHeight(11)
			power.value:SetPoint('LEFT', power, 'LEFT', 0, 0)
			power.value:SetPoint('RIGHT', power, 'RIGHT', -17, 0)
			power.value:SetJustifyH('RIGHT')
			power.value:SetJustifyV('MIDDLE')
			power.value:SetPoint('LEFT', power, 'LEFT', 4, 0)
			self:Tag(power.value, PlayerFrames:TextFormat('mana'))

			power.ratio = power:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
			power.ratio:SetWidth(40)
			power.ratio:SetHeight(11)
			power.ratio:SetJustifyH('RIGHT')
			power.ratio:SetJustifyV('MIDDLE')
			power.ratio:SetPoint('RIGHT', power, 'LEFT', -2, 0)
			self:Tag(power.ratio, '[perpp]%')

			self.Power = power
			self.Power.colorPower = true
			self.Power.frequentUpdates = true
		end
	end
	do -- setup ring, icons, and text
		if SUI.DB.PlayerFrames.PetPortrait then
			local ring = CreateFrame('Frame', nil, self)
			ring:SetParent(self)
			ring:SetFrameStrata('BACKGROUND')
			ring:SetAllPoints(self.Portrait)
			ring:SetFrameLevel(3)
			ring.bg = ring:CreateTexture(nil, 'BACKGROUND')
			ring.bg:SetPoint('CENTER', ring, 'CENTER', -2, -3)
			ring.bg:SetTexture(base_ring3)
			ring.bg:SetTexCoord(1, 0, 0, 1)

			self.Name = ring:CreateFontString()
			SUI:FormatFont(self.Name, 12, 'Player')
			self.Name:SetHeight(12)
			self.Name:SetWidth(150)
			self.Name:SetJustifyH('RIGHT')
			self.Name:SetPoint('TOPLEFT', self, 'TOPLEFT', 3, -5)
			if SUI.DB.PlayerFrames.showClass then
				self:Tag(self.Name, '[SUI_ColorClass][name]')
			else
				self:Tag(self.Name, '[name]')
			end

			self.Level = ring:CreateFontString(nil, 'BORDER', 'SUI_FontOutline10')
			self.Level:SetWidth(36)
			self.Level:SetHeight(11)
			self.Level:SetJustifyH('CENTER')
			self.Level:SetJustifyV('MIDDLE')
			self.Level:SetPoint('CENTER', ring, 'CENTER', 24, 25)
			self:Tag(self.Level, '[level]')

			self.SUI_ClassIcon = ring:CreateTexture(nil, 'BORDER')
			self.SUI_ClassIcon:SetSize(19, 19)
			self.SUI_ClassIcon:SetPoint('CENTER', ring, 'CENTER', -27, 24)

			self.PvPIndicator = ring:CreateTexture(nil, 'BORDER')
			self.PvPIndicator:SetWidth(48)
			self.PvPIndicator:SetHeight(48)
			self.PvPIndicator:SetPoint('CENTER', ring, 'CENTER', 30, -36)

			self.Happiness = ring:CreateTexture(nil, 'ARTWORK')
			self.Happiness:SetWidth(22)
			self.Happiness:SetHeight(22)
			self.Happiness:SetPoint('CENTER', ring, 'CENTER', -27, 24)

			self.RaidTargetIndicator = ring:CreateTexture(nil, 'ARTWORK')
			self.RaidTargetIndicator:SetWidth(20)
			self.RaidTargetIndicator:SetHeight(20)
			self.RaidTargetIndicator:SetAllPoints(self.Portrait)
		else
			self.Name = self.artwork:CreateFontString()
			SUI:FormatFont(self.Name, 12, 'Player')
			self.Name:SetHeight(12)
			self.Name:SetJustifyH('RIGHT')
			self.Name:SetPoint('BOTTOMLEFT', self.Castbar, 'TOPLEFT', 0, 5)
			self.Name:SetPoint('BOTTOMRIGHT', self.Castbar, 'TOPRIGHT', 0, 5)
			if SUI.DB.PlayerFrames.showClass then
				self:Tag(self.Name, '[level] [SUI_ColorClass][name]')
			else
				self:Tag(self.Name, '[level] [name]')
			end
		end
	end
	do -- setup buffs and debuffs
		if SUI.DB.Styles.Classic.Frames[unit] then
			local Buffsize = SUI.DB.Styles.Classic.Frames[unit].Buffs.size
			local Debuffsize = SUI.DB.Styles.Classic.Frames[unit].Buffs.size
			-- Position and size
			local Buffs = CreateFrame('Frame', nil, self)
			Buffs:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 0, 5)
			Buffs.size = Buffsize
			Buffs['growth-y'] = 'UP'
			Buffs.spacing = SUI.DB.Styles.Classic.Frames[unit].Buffs.spacing
			Buffs.showType = SUI.DB.Styles.Classic.Frames[unit].Buffs.showType
			Buffs.numBuffs = SUI.DB.Styles.Classic.Frames[unit].Buffs.Number
			Buffs.onlyShowPlayer = SUI.DB.Styles.Classic.Frames[unit].Buffs.onlyShowPlayer
			Buffs:SetSize(Buffsize * 4, Buffsize * Buffsize)
			Buffs.PostUpdate = PostUpdateAura
			self.Buffs = Buffs

			-- Position and size
			local Debuffs = CreateFrame('Frame', nil, self)
			Debuffs:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', -5, 5)
			Debuffs.size = Debuffsize
			Debuffs.initialAnchor = 'BOTTOMRIGHT'
			Debuffs['growth-x'] = 'LEFT'
			Debuffs['growth-y'] = 'UP'
			Debuffs.spacing = SUI.DB.Styles.Classic.Frames[unit].Debuffs.spacing
			Debuffs.showType = SUI.DB.Styles.Classic.Frames[unit].Debuffs.showType
			Debuffs.numDebuffs = SUI.DB.Styles.Classic.Frames[unit].Debuffs.Number
			Debuffs.onlyShowPlayer = SUI.DB.Styles.Classic.Frames[unit].Debuffs.onlyShowPlayer
			Debuffs:SetSize(Debuffsize * 4, Debuffsize * Debuffsize)
			Debuffs.PostUpdate = PostUpdateAura
			self.Debuffs = Debuffs

			SUI.opt.args['PlayerFrames'].args['auras'].args[unit].disabled = false
		end
	end
	self.TextUpdate = PostUpdateText
	self.ColorUpdate = PostUpdateColor
	if not SUI.DB.PlayerFrames.PetPortrait then
		self.artwork.bg:SetTexCoord(0, .7, 0, 85 / 128)
		self.artwork.bg:SetSize(180, 85)
		self:SetSize(135, 60)
		self.Castbar:SetWidth(100)
		self.Health:SetWidth(99)
		self.Power:SetWidth(98)
	end
	self:SetScale(.87)
	return self
end

local CreateToTFrame = function(self, unit)
	if SUI.DB.PlayerFrames.targettarget.style == 'large' then
		do -- large
			self:SetWidth(210)
			self:SetHeight(60)
			do -- setup base artwork
				local artwork = CreateFrame('Frame', nil, self)
				artwork:SetFrameStrata('BACKGROUND')
				artwork:SetFrameLevel(0)
				artwork:SetAllPoints(self)

				artwork.bg = artwork:CreateTexture(nil, 'BACKGROUND')
				artwork.bg:SetPoint('CENTER')
				artwork.bg:SetTexture(base_plate3)
				artwork.bg:SetSize(256, 85)
				artwork.bg:SetTexCoord(1, 0, 0, 85 / 128)
				self.artwork = artwork

				self.Portrait = CreatePortrait(self)
				self.Portrait:SetWidth(56)
				self.Portrait:SetHeight(50)
				self.Portrait:SetPoint('CENTER', self, 'CENTER', -83, -8)

				self.ThreatIndicator = CreateFrame('Frame', nil, self)
				self.ThreatIndicator.Override = threat
			end
			do -- setup status bars
				do -- cast bar
					local cast = CreateFrame('StatusBar', nil, self)
					cast:SetFrameStrata('BACKGROUND')
					cast:SetFrameLevel(2)
					cast:SetWidth(120)
					cast:SetHeight(15)
					cast:SetPoint('TOPRIGHT', self, 'TOPRIGHT', -36, -23)

					cast.Text = cast:CreateFontString()
					SUI:FormatFont(cast.Text, 10, 'Player')
					cast.Text:SetWidth(110)
					cast.Text:SetHeight(11)
					cast.Text:SetJustifyH('LEFT')
					cast.Text:SetJustifyV('MIDDLE')
					cast.Text:SetPoint('RIGHT', cast, 'RIGHT', -4, 0)

					cast.Time = cast:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
					cast.Time:SetWidth(40)
					cast.Time:SetHeight(11)
					cast.Time:SetJustifyH('LEFT')
					cast.Time:SetJustifyV('MIDDLE')
					cast.Time:SetPoint('LEFT', cast, 'RIGHT', 4, 0)

					self.Castbar = cast
					self.Castbar.OnUpdate = OnCastbarUpdate
					self.Castbar.PostCastStart = PostCastStart
					self.Castbar.PostChannelStart = PostChannelStart
					self.Castbar.PostCastStop = PostCastStop
				end
				do -- health bar
					local health = CreateFrame('StatusBar', nil, self)
					health:SetFrameStrata('BACKGROUND')
					health:SetFrameLevel(2)
					health:SetWidth(120)
					health:SetHeight(16)
					health:SetPoint('TOPRIGHT', self.Castbar, 'BOTTOMRIGHT', 0, -2)
					health:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar')

					health.value = health:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
					health.value:SetWidth(110)
					health.value:SetHeight(11)
					health.value:SetJustifyH('LEFT')
					health.value:SetJustifyV('MIDDLE')
					health.value:SetPoint('RIGHT', health, 'RIGHT', -4, 0)

					self:Tag(health.value, PlayerFrames:TextFormat('health'))

					health.ratio = health:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
					health.ratio:SetWidth(40)
					health.ratio:SetHeight(11)
					health.ratio:SetJustifyH('LEFT')
					health.ratio:SetJustifyV('MIDDLE')
					health.ratio:SetPoint('LEFT', health, 'RIGHT', 4, 0)
					self:Tag(health.ratio, '[perhp]%')

					-- local Background = health:CreateTexture(nil, 'BACKGROUND')
					-- Background:SetAllPoints(health)
					-- Background:SetTexture(1, 1, 1, .08)

					self.Health = health
					--self.Health.bg = Background;

					self.Health.frequentUpdates = true
					self.Health.colorDisconnected = true
					if SUI.DB.PlayerFrames.bars[unit].color == 'reaction' then
						self.Health.colorReaction = true
					elseif SUI.DB.PlayerFrames.bars[unit].color == 'happiness' then
						self.Health.colorHappiness = true
					elseif SUI.DB.PlayerFrames.bars[unit].color == 'class' then
						self.Health.colorClass = true
					else
						self.Health.colorSmooth = true
					end
					self.colors.smooth = {1, 0, 0, 1, 1, 0, 0, 1, 0}
					self.Health.colorHealth = true

					SUI:oUF_HealPrediction(self)
				end
				do -- power bar
					local power = CreateFrame('StatusBar', nil, self)
					power:SetFrameStrata('BACKGROUND')
					power:SetFrameLevel(2)
					power:SetWidth(135)
					power:SetHeight(14)
					power:SetPoint('TOPRIGHT', self.Health, 'BOTTOMRIGHT', 0, -1)

					power.value = power:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
					power.value:SetWidth(110)
					power.value:SetHeight(11)
					power.value:SetJustifyH('LEFT')
					power.value:SetJustifyV('MIDDLE')
					power.value:SetPoint('RIGHT', power, 'RIGHT', -4, 0)
					self:Tag(power.value, PlayerFrames:TextFormat('mana'))

					power.ratio = power:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
					power.ratio:SetWidth(40)
					power.ratio:SetHeight(11)
					power.ratio:SetJustifyH('LEFT')
					power.ratio:SetJustifyV('MIDDLE')
					power.ratio:SetPoint('LEFT', power, 'RIGHT', 4, 0)
					self:Tag(power.ratio, '[perpp]%')

					self.Power = power
					self.Power.colorPower = true
					self.Power.frequentUpdates = true
				end
			end
			do -- setup ring, icons, and text
				local ring = CreateFrame('Frame', nil, self)
				ring:SetFrameStrata('BACKGROUND')
				ring:SetAllPoints(self.Portrait)
				ring:SetFrameLevel(3)
				ring.bg = ring:CreateTexture(nil, 'BACKGROUND')
				ring.bg:SetPoint('CENTER', ring, 'CENTER', -2, -3)
				ring.bg:SetTexture(base_ring3)

				self.Name = ring:CreateFontString()
				SUI:FormatFont(self.Name, 12, 'Player')
				self.Name:SetHeight(12)
				self.Name:SetWidth(150)
				self.Name:SetJustifyH('LEFT')
				self.Name:SetPoint('TOPRIGHT', self, 'TOPRIGHT', -3, -5)
				if SUI.DB.PlayerFrames.showClass then
					self:Tag(self.Name, '[SUI_ColorClass][name]')
				else
					self:Tag(self.Name, '[name]')
				end

				self.Level = ring:CreateFontString(nil, 'BORDER', 'SUI_FontOutline10')
				self.Level:SetWidth(36)
				self.Level:SetHeight(11)
				self.Level:SetJustifyH('CENTER')
				self.Level:SetJustifyV('MIDDLE')
				self.Level:SetPoint('CENTER', ring, 'CENTER', -27, 25)
				self:Tag(self.Level, '[difficulty][level]')

				self.SUI_ClassIcon = ring:CreateTexture(nil, 'BORDER')
				self.SUI_ClassIcon:SetSize(19, 19)
				self.SUI_ClassIcon:SetPoint('CENTER', ring, 'CENTER', 23, 24)

				self.PvPIndicator = ring:CreateTexture(nil, 'BORDER')
				self.PvPIndicator:SetWidth(48)
				self.PvPIndicator:SetHeight(48)
				self.PvPIndicator:SetPoint('CENTER', ring, 'CENTER', -14, -36)

				self.RaidTargetIndicator = ring:CreateTexture(nil, 'ARTWORK')
				self.RaidTargetIndicator:SetWidth(20)
				self.RaidTargetIndicator:SetHeight(20)
				self.RaidTargetIndicator:SetPoint('CENTER', ring, 'RIGHT', 1, -1)

				self.StatusText = ring:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline18')
				self.StatusText:SetPoint('CENTER', ring, 'CENTER')
				self.StatusText:SetJustifyH('CENTER')
				self:Tag(self.StatusText, '[afkdnd]')
			end
			self.TextUpdate = PostUpdateText
			self.ColorUpdate = PostUpdateColor
		end
	elseif SUI.DB.PlayerFrames.targettarget.style == 'medium' then
		do -- medium
			self:SetSize(124, 55)
			do -- setup base artwork
				self.artwork = CreateFrame('Frame', nil, self)
				self.artwork:SetFrameStrata('BACKGROUND')
				self.artwork:SetFrameLevel(0)
				self.artwork:SetAllPoints(self)

				self.artwork.bg = self.artwork:CreateTexture(nil, 'BACKGROUND')
				self.artwork.bg:SetPoint('CENTER')
				self.artwork.bg:SetTexture(base_plate3)
				self.artwork.bg:SetSize(170, 80)
				self.artwork.bg:SetTexCoord(.68, 0, 0, 0.6640625)
				self.artwork = artwork

				self.ThreatIndicator = CreateFrame('Frame', nil, self)
				self.ThreatIndicator.Override = threat
			end
			do -- setup status bars
				do -- cast bar
					local cast = CreateFrame('StatusBar', nil, self)
					cast:SetFrameStrata('BACKGROUND')
					cast:SetFrameLevel(2)
					cast:SetSize(95, 14)
					cast:SetPoint('TOPRIGHT', self, 'TOPRIGHT', -36, -20)

					cast.Text = cast:CreateFontString()
					SUI:FormatFont(cast.Text, 10, 'Player')
					cast.Text:SetSize(90, 11)
					cast.Text:SetJustifyH('LEFT')
					cast.Text:SetJustifyV('MIDDLE')
					cast.Text:SetPoint('RIGHT', cast, 'RIGHT', -4, 0)

					cast.Time = cast:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
					cast.Time:SetSize(40, 11)
					cast.Time:SetJustifyH('LEFT')
					cast.Time:SetJustifyV('MIDDLE')
					cast.Time:SetPoint('LEFT', cast, 'RIGHT', 4, 0)

					self.Castbar = cast
					self.Castbar.OnUpdate = OnCastbarUpdate
					self.Castbar.PostCastStart = PostCastStart
					self.Castbar.PostChannelStart = PostChannelStart
					self.Castbar.PostCastStop = PostCastStop
				end
				do -- health bar
					local health = CreateFrame('StatusBar', nil, self)
					health:SetFrameStrata('BACKGROUND')
					health:SetFrameLevel(2)
					health:SetSize(93, 14)
					health:SetPoint('TOPRIGHT', self.Castbar, 'BOTTOMRIGHT', 0, -2)
					health:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar')

					health.value = health:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
					health.value:SetSize(85, 11)
					health.value:SetJustifyH('LEFT')
					health.value:SetJustifyV('MIDDLE')
					health.value:SetPoint('RIGHT', health, 'RIGHT', -4, 0)

					self:Tag(health.value, PlayerFrames:TextFormat('health'))

					health.ratio = health:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
					health.ratio:SetWidth(40)
					health.ratio:SetHeight(11)
					health.ratio:SetJustifyH('LEFT')
					health.ratio:SetJustifyV('MIDDLE')
					health.ratio:SetPoint('LEFT', health, 'RIGHT', 5, 0)
					self:Tag(health.ratio, '[perhp]%')

					-- local Background = health:CreateTexture(nil, 'BACKGROUND')
					-- Background:SetAllPoints(health)
					-- Background:SetTexture(1, 1, 1, .08)

					self.Health = health
					--self.Health.bg = Background;

					self.Health.frequentUpdates = true
					self.Health.colorDisconnected = true
					if SUI.DB.PlayerFrames.bars[unit].color == 'reaction' then
						self.Health.colorReaction = true
					elseif SUI.DB.PlayerFrames.bars[unit].color == 'happiness' then
						self.Health.colorHappiness = true
					elseif SUI.DB.PlayerFrames.bars[unit].color == 'class' then
						self.Health.colorClass = true
					else
						self.Health.colorSmooth = true
					end
					self.colors.smooth = {1, 0, 0, 1, 1, 0, 0, 1, 0}
					self.Health.colorHealth = true

					SUI:oUF_HealPrediction(self)
				end
				do -- power bar
					local power = CreateFrame('StatusBar', nil, self)
					power:SetFrameStrata('BACKGROUND')
					power:SetFrameLevel(2)
					power:SetSize(90, 14)
					power:SetPoint('TOPRIGHT', self.Health, 'BOTTOMRIGHT', 0, -1)

					power.value = power:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
					power.value:SetSize(85, 11)
					power.value:SetJustifyH('LEFT')
					power.value:SetJustifyV('MIDDLE')
					power.value:SetPoint('RIGHT', power, 'RIGHT', -4, 0)
					self:Tag(power.value, PlayerFrames:TextFormat('mana'))

					power.ratio = power:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
					power.ratio:SetSize(40, 11)
					power.ratio:SetJustifyH('LEFT')
					power.ratio:SetJustifyV('MIDDLE')
					power.ratio:SetPoint('LEFT', power, 'RIGHT', 5, 0)
					self:Tag(power.ratio, '[perpp]%')

					self.Power = power
					self.Power.colorPower = true
					self.Power.frequentUpdates = true
				end
			end
			do -- setup ring, icons, and text
				local ring = CreateFrame('Frame', nil, self)
				ring:SetFrameStrata('BACKGROUND')
				ring:SetPoint('TOPLEFT', self.artwork, 'TOPLEFT', 0, 0)
				ring:SetFrameLevel(3)

				self.Name = ring:CreateFontString()
				SUI:FormatFont(self.Name, 12, 'Player')
				self.Name:SetHeight(12)
				self.Name:SetWidth(132)
				self.Name:SetJustifyH('LEFT')
				self.Name:SetPoint('TOPRIGHT', self, 'TOPRIGHT', 0, -5)
				if SUI.DB.PlayerFrames.showClass then
					self:Tag(self.Name, '[difficulty][level] [SUI_ColorClass][name]')
				else
					self:Tag(self.Name, '[difficulty][level] [name]')
				end

				self.RaidTargetIndicator = ring:CreateTexture(nil, 'ARTWORK')
				self.RaidTargetIndicator:SetWidth(20)
				self.RaidTargetIndicator:SetHeight(20)
				self.RaidTargetIndicator:SetPoint('LEFT', self, 'RIGHT', 3, 0)

				self.PvPIndicator = ring:CreateTexture(nil, 'BORDER')
				self.PvPIndicator:SetWidth(40)
				self.PvPIndicator:SetHeight(40)
				self.PvPIndicator:SetPoint('LEFT', self, 'RIGHT', -5, 24)
			end
			self.TextUpdate = PostUpdateText
			self.ColorUpdate = PostUpdateColor
		end
	elseif SUI.DB.PlayerFrames.targettarget.style == 'small' then
		do -- small
			self:SetSize(200, 65)
			do -- setup base artwork
				self.artwork = CreateFrame('Frame', nil, self)
				self.artwork:SetFrameStrata('BACKGROUND')
				self.artwork:SetFrameLevel(0)
				self.artwork:SetAllPoints(self)

				self.artwork.bg = self.artwork:CreateTexture(nil, 'BACKGROUND')
				self.artwork.bg:SetPoint('BOTTOMLEFT', self, 'BOTTOMLEFT')
				self.artwork.bg:SetTexture(base_plate4)
				self.artwork.bg:SetSize(200, 65)
				self.artwork.bg:SetTexCoord(.24, 1, 0, 1)
				self.artwork = artwork

				self.ThreatIndicator = CreateFrame('Frame', nil, self)
				self.ThreatIndicator.Override = threat
			end
			do -- setup status bars
				do -- health bar
					local health = CreateFrame('StatusBar', nil, self)
					health:SetFrameStrata('BACKGROUND')
					health:SetFrameLevel(1)
					health:SetSize(125, 25)
					health:SetPoint('BOTTOMLEFT', self, 'BOTTOMLEFT', 6, 17)
					health:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar')

					health.value = health:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
					health.value:SetSize(100, 11)
					health.value:SetJustifyH('LEFT')
					health.value:SetJustifyV('MIDDLE')
					health.value:SetPoint('RIGHT', health, 'RIGHT', -4, 0)

					self:Tag(health.value, PlayerFrames:TextFormat('health'))

					health.ratio = health:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
					health.ratio:SetWidth(50)
					health.ratio:SetHeight(11)
					health.ratio:SetJustifyH('LEFT')
					health.ratio:SetJustifyV('MIDDLE')
					health.ratio:SetPoint('LEFT', health, 'RIGHT', 5, 0)
					self:Tag(health.ratio, '[perhp]%')

					-- local Background = health:CreateTexture(nil, 'BACKGROUND')
					-- Background:SetAllPoints(health)
					-- Background:SetTexture(1, 1, 1, .08)

					self.Health = health
					--self.Health.bg = Background;

					self.Health.frequentUpdates = true
					self.Health.colorDisconnected = true
					if SUI.DB.PlayerFrames.bars[unit].color == 'reaction' then
						self.Health.colorReaction = true
					elseif SUI.DB.PlayerFrames.bars[unit].color == 'happiness' then
						self.Health.colorHappiness = true
					elseif SUI.DB.PlayerFrames.bars[unit].color == 'class' then
						self.Health.colorClass = true
					else
						self.Health.colorSmooth = true
					end
					self.colors.smooth = {1, 0, 0, 1, 1, 0, 0, 1, 0}
					self.Health.colorHealth = true

					SUI:oUF_HealPrediction(self)
				end
			end
			do -- setup ring, icons, and text
				local ring = CreateFrame('Frame', nil, self)
				ring:SetFrameStrata('BACKGROUND')
				ring:SetPoint('TOPLEFT', self.artwork, 'TOPLEFT', 0, 0)
				ring:SetFrameLevel(3)

				self.Name = ring:CreateFontString()
				SUI:FormatFont(self.Name, 12, 'Player')
				self.Name:SetSize(132, 12)
				self.Name:SetJustifyH('LEFT')
				self.Name:SetPoint('TOPRIGHT', self, 'TOPRIGHT', -50, -5)
				if SUI.DB.PlayerFrames.showClass then
					self:Tag(self.Name, '[difficulty][level] [SUI_ColorClass][name]')
				else
					self:Tag(self.Name, '[difficulty][level] [name]')
				end

				self.RaidTargetIndicator = ring:CreateTexture(nil, 'ARTWORK')
				self.RaidTargetIndicator:SetSize(15, 15)
				self.RaidTargetIndicator:SetPoint('RIGHT', self, 'RIGHT', -5, 0)

				self.PvPIndicator = ring:CreateTexture(nil, 'BORDER')
				self.PvPIndicator:SetSize(30, 30)
				self.PvPIndicator:SetPoint('RIGHT', self, 'RIGHT', 0, 20)
			end
			self.TextUpdate = PostUpdateText
			self.ColorUpdate = PostUpdateColor
		end
	end
	do -- setup buffs and debuffs
		if SUI.DB.Styles.Classic.Frames[unit] then
			local Buffsize = SUI.DB.Styles.Classic.Frames[unit].Buffs.size
			local Debuffsize = SUI.DB.Styles.Classic.Frames[unit].Buffs.size
			-- Position and size
			local Buffs = CreateFrame('Frame', nil, self)
			Buffs:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 0, 5)
			Buffs.size = Buffsize
			Buffs['growth-y'] = 'UP'
			Buffs.spacing = SUI.DB.Styles.Classic.Frames[unit].Buffs.spacing
			Buffs.showType = SUI.DB.Styles.Classic.Frames[unit].Buffs.showType
			Buffs.numBuffs = SUI.DB.Styles.Classic.Frames[unit].Buffs.Number
			Buffs.onlyShowPlayer = SUI.DB.Styles.Classic.Frames[unit].Buffs.onlyShowPlayer
			Buffs:SetSize(Buffsize * 4, Buffsize * Buffsize)
			Buffs.PostUpdate = PostUpdateAura
			self.Buffs = Buffs

			-- Position and size
			local Debuffs = CreateFrame('Frame', nil, self)
			Debuffs:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', -5, 5)
			Debuffs.size = Debuffsize
			Debuffs.initialAnchor = 'BOTTOMRIGHT'
			Debuffs['growth-x'] = 'LEFT'
			Debuffs['growth-y'] = 'UP'
			Debuffs.spacing = SUI.DB.Styles.Classic.Frames[unit].Debuffs.spacing
			Debuffs.showType = SUI.DB.Styles.Classic.Frames[unit].Debuffs.showType
			Debuffs.numDebuffs = SUI.DB.Styles.Classic.Frames[unit].Debuffs.Number
			Debuffs.onlyShowPlayer = SUI.DB.Styles.Classic.Frames[unit].Debuffs.onlyShowPlayer
			Debuffs:SetSize(Debuffsize * 4, Debuffsize * Debuffsize)
			Debuffs.PostUpdate = PostUpdateAura
			self.Debuffs = Debuffs

			SUI.opt.args['PlayerFrames'].args['auras'].args[unit].disabled = false
		end
	end
	return self
end

local CreateFocusFrame = function(self, unit)
	self:SetWidth(180)
	self:SetHeight(60)
	do --setup base artwork
		local artwork = CreateFrame('Frame', nil, self)
		artwork:SetFrameStrata('BACKGROUND')
		artwork:SetFrameLevel(0)
		artwork:SetAllPoints(self)

		artwork.bg = artwork:CreateTexture(nil, 'BACKGROUND')
		artwork.bg:SetPoint('CENTER')
		artwork.bg:SetTexture(base_plate2)
		artwork.bg:SetWidth(180)
		artwork.bg:SetHeight(60)
		if unit == 'focus' then
			artwork.bg:SetTexCoord(0, 1, 0, 0.4)
		end
		if unit == 'focustarget' then
			artwork.bg:SetTexCoord(0, 1, .5, .9)
		end
		self.artwork = artwork

		self.ThreatIndicator = CreateFrame('Frame', nil, self)
		self.ThreatIndicator.Override = threat
	end
	do -- setup status bars
		do -- health bar
			local health = CreateFrame('StatusBar', nil, self)
			health:SetFrameStrata('BACKGROUND')
			health:SetFrameLevel(2)
			health:SetSize(85, 15)
			if unit == 'focus' then
				health:SetPoint('CENTER', self, 'CENTER', -5, -2)
			end
			if unit == 'focustarget' then
				health:SetPoint('CENTER', self, 'CENTER', -46, -2)
			end
			health:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar')

			health.value = health:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
			health.value:SetSize(80, 11)
			health.value:SetJustifyH('LEFT')
			health.value:SetJustifyV('MIDDLE')
			if unit == 'focus' then
				health.value:SetPoint('RIGHT', health, 'RIGHT', 0, 0)
			end
			if unit == 'focustarget' then
				health.value:SetPoint('LEFT', health, 'LEFT', 0, 0)
			end
			self:Tag(health.value, PlayerFrames:TextFormat('health'))

			health.ratio = health:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
			health.ratio:SetSize(40, 11)
			health.ratio:SetJustifyH('LEFT')
			health.ratio:SetJustifyV('MIDDLE')
			if unit == 'focus' then
				health.ratio:SetPoint('LEFT', health, 'LEFT', -30, 0)
			end
			if unit == 'focustarget' then
				health.ratio:SetPoint('LEFT', health, 'RIGHT', 1, 0)
			end
			self:Tag(health.ratio, '[perhp]%')

			-- local Background = health:CreateTexture(nil, 'BACKGROUND')
			-- Background:SetAllPoints(health)
			-- Background:SetTexture(1, 1, 1, .08)

			self.Health = health
			--self.Health.bg = Background;

			self.Health.frequentUpdates = true
			self.Health.colorDisconnected = true
			-- if SUI.DB.PlayerFrames.bars[unit].color == "reaction" then
			-- self.Health.colorReaction = true;
			-- elseif SUI.DB.PlayerFrames.bars[unit].color == "happiness" then
			-- self.Health.colorHappiness = true;
			-- elseif SUI.DB.PlayerFrames.bars[unit].color == "class" then
			-- self.Health.colorClass = true;
			-- else
			-- self.Health.colorSmooth = true;
			-- end
			self.colors.smooth = {1, 0, 0, 1, 1, 0, 0, 1, 0}
			self.Health.colorHealth = true

			SUI:oUF_HealPrediction(self)
		end
		do -- power bar
			local power = CreateFrame('StatusBar', nil, self)
			power:SetFrameStrata('BACKGROUND')
			power:SetFrameLevel(2)
			power:SetSize(85, 15)
			power:SetPoint('TOP', self.Health, 'BOTTOM', 0, -2)

			power.value = power:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
			power.value:SetSize(85, 11)
			power.value:SetJustifyH('LEFT')
			power.value:SetJustifyV('MIDDLE')
			power.value:SetPoint('TOP', self.Health.value, 'BOTTOM', -1, -6)
			self:Tag(power.value, PlayerFrames:TextFormat('mana'))

			power.ratio = power:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
			power.value:SetSize(40, 11)
			power.ratio:SetJustifyH('LEFT')
			power.ratio:SetJustifyV('MIDDLE')
			power.ratio:SetPoint('TOP', self.Health.ratio, 'BOTTOM', -4, -7)
			self:Tag(power.ratio, '[perpp]%')

			self.Power = power
			self.Power.colorPower = true
			self.Power.frequentUpdates = true
		end
	end
	do -- setup ring, icons, and text
		local ring = CreateFrame('Frame', nil, self)
		--ring:SetFrameStrata("BACKGROUND");
		--ring:SetAllPoints(self); ring:SetFrameLevel(3);
		ring.bg = ring:CreateTexture(nil, 'BACKGROUND')
		ring.bg:SetPoint('LEFT', ring, 'LEFT', -2, -3)

		self.Name = ring:CreateFontString()
		SUI:FormatFont(self.Name, 12, 'Player')
		self.Name:SetSize(110, 12)
		self.Name:SetJustifyH('LEFT')
		if unit == 'focus' then
			self.Name:SetPoint('TOPLEFT', self, 'TOPLEFT', 20, -6)
		elseif unit == 'focustarget' then
			self.Name:SetPoint('TOPLEFT', self, 'TOPLEFT', 2, -6)
		end
		if SUI.DB.PlayerFrames.showClass then
			self:Tag(self.Name, '[difficulty][level] [SUI_ColorClass][name]')
		else
			self:Tag(self.Name, '[difficulty][level] [name]')
		end

		self.LevelSkull = ring:CreateTexture(nil, 'ARTWORK')
		self.LevelSkull:SetSize(16, 16)
		self.LevelSkull:SetPoint('CENTER', self.Name, 'LEFT', 8, 0)
	end
	do -- setup buffs and debuffs
		if SUI.DB.Styles.Classic.Frames[unit] then
			local Buffsize = SUI.DB.Styles.Classic.Frames[unit].Buffs.size
			local Debuffsize = SUI.DB.Styles.Classic.Frames[unit].Buffs.size
			-- Position and size
			local Buffs = CreateFrame('Frame', nil, self)
			Buffs:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 0, 5)
			Buffs.size = Buffsize
			Buffs['growth-y'] = 'UP'
			Buffs.spacing = SUI.DB.Styles.Classic.Frames[unit].Buffs.spacing
			Buffs.showType = SUI.DB.Styles.Classic.Frames[unit].Buffs.showType
			Buffs.numBuffs = SUI.DB.Styles.Classic.Frames[unit].Buffs.Number
			Buffs.onlyShowPlayer = SUI.DB.Styles.Classic.Frames[unit].Buffs.onlyShowPlayer
			Buffs:SetSize(Buffsize * 4, Buffsize * Buffsize)
			Buffs.PostUpdate = PostUpdateAura
			self.Buffs = Buffs

			-- Position and size
			local Debuffs = CreateFrame('Frame', nil, self)
			Debuffs:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', -5, 5)
			Debuffs.size = Debuffsize
			Debuffs.initialAnchor = 'BOTTOMRIGHT'
			Debuffs['growth-x'] = 'LEFT'
			Debuffs['growth-y'] = 'UP'
			Debuffs.spacing = SUI.DB.Styles.Classic.Frames[unit].Debuffs.spacing
			Debuffs.showType = SUI.DB.Styles.Classic.Frames[unit].Debuffs.showType
			Debuffs.numDebuffs = SUI.DB.Styles.Classic.Frames[unit].Debuffs.Number
			Debuffs.onlyShowPlayer = SUI.DB.Styles.Classic.Frames[unit].Debuffs.onlyShowPlayer
			Debuffs:SetSize(Debuffsize * 4, Debuffsize * Debuffsize)
			Debuffs.PostUpdate = PostUpdateAura
			self.Debuffs = Debuffs

			SUI.opt.args['PlayerFrames'].args['auras'].args[unit].disabled = false
		end
	end
	self.TextUpdate = PostUpdateText
	self.ColorUpdate = PostUpdateColor

	return self
end

local CreateBossFrame = function(self, unit)
	self:SetSize(145, 80)
	do --setup base artwork
		local artwork = CreateFrame('Frame', nil, self)
		artwork:SetFrameStrata('BACKGROUND')
		artwork:SetFrameLevel(2)
		artwork:SetAllPoints(self)

		artwork.bg = artwork:CreateTexture(nil, 'BACKGROUND')
		artwork.bg:SetPoint('CENTER')
		artwork.bg:SetTexture(base_plate1)
		artwork.bg:SetTexCoord(.57, .2, .2, 1)
		artwork.bg:SetAllPoints(self)
		self.artwork = artwork

		self.ThreatIndicator = CreateFrame('Frame', nil, self)
		self.ThreatIndicator.Override = threat

		local Bossartwork = CreateFrame('Frame', nil, self)
		Bossartwork:SetFrameStrata('BACKGROUND')
		Bossartwork:SetFrameLevel(1)
		Bossartwork:SetAllPoints(self)

		self.BossGraphic = Bossartwork:CreateTexture(nil, 'ARTWORK')
		self.BossGraphic:SetSize(130, 125)
		self.BossGraphic:SetPoint('TOP', self, 'TOPRIGHT', -25, 36)
	end
	do -- setup status bars
		do -- cast bar
			local cast = CreateFrame('StatusBar', nil, self)
			cast:SetFrameStrata('BACKGROUND')
			cast:SetFrameLevel(3)
			cast:SetSize(105, 12)
			cast:SetPoint('TOPLEFT', self, 'TOPLEFT', 0, -17)

			cast.Text = cast:CreateFontString()
			SUI:FormatFont(cast.Text, 10, 'Player')
			cast.Text:SetSize(97, 10)
			cast.Text:SetJustifyH('LEFT')
			cast.Text:SetJustifyV('MIDDLE')
			cast.Text:SetPoint('LEFT', cast, 'LEFT', 4, 0)

			cast.Time = cast:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
			cast.Time:SetSize(50, 10)
			cast.Time:SetJustifyH('LEFT')
			cast.Time:SetJustifyV('MIDDLE')
			cast.Time:SetPoint('LEFT', cast, 'RIGHT', 2, 0)

			self.Castbar = cast
			self.Castbar.OnUpdate = OnCastbarUpdate
			self.Castbar.PostCastStart = PostCastStart
			self.Castbar.PostChannelStart = PostChannelStart
			self.Castbar.PostCastStop = PostCastStop
		end
		do -- health bar
			local health = CreateFrame('StatusBar', nil, self)
			health:SetFrameStrata('BACKGROUND')
			health:SetFrameLevel(3)
			health:SetSize(105, 12)
			health:SetPoint('TOPRIGHT', self.Castbar, 'BOTTOMRIGHT', 0, -2)
			health:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar')

			health.value = health:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
			health.value:SetSize(97, 10)
			health.value:SetJustifyH('LEFT')
			health.value:SetJustifyV('MIDDLE')
			health.value:SetPoint('LEFT', health, 'LEFT', 4, 0)
			self:Tag(health.value, PlayerFrames:TextFormat('health'))

			health.ratio = health:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
			health.ratio:SetSize(50, 10)
			health.ratio:SetJustifyH('LEFT')
			health.ratio:SetJustifyV('MIDDLE')
			health.ratio:SetPoint('LEFT', health, 'RIGHT', 2, 0)
			self:Tag(health.ratio, '[perhp]%')

			-- local Background = health:CreateTexture(nil, 'BACKGROUND')
			-- Background:SetAllPoints(health)
			-- Background:SetTexture(1, 1, 1, .08)

			self.Health = health
			--self.Health.bg = Background;
			self.Health.colorTapping = true
			self.Health.frequentUpdates = true
			self.Health.colorDisconnected = true
			self.Health.colorReaction = true

			self.colors.smooth = {1, 0, 0, 1, 1, 0, 0, 1, 0}
			self.Health.colorHealth = true

			SUI:oUF_HealPrediction(self)
		end
		do -- power bar
			local power = CreateFrame('StatusBar', nil, self)
			power:SetFrameStrata('BACKGROUND')
			power:SetFrameLevel(3)
			power:SetWidth(105)
			power:SetHeight(12)
			power:SetPoint('TOPRIGHT', self.Health, 'BOTTOMRIGHT', 0, -2)

			power.value = power:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
			power.value:SetSize(70, 10)
			power.value:SetJustifyH('LEFT')
			power.value:SetJustifyV('MIDDLE')
			power.value:SetPoint('RIGHT', power, 'RIGHT', -4, 0)
			self:Tag(power.value, PlayerFrames:TextFormat('mana'))

			power.ratio = power:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline10')
			power.ratio:SetSize(50, 10)
			power.ratio:SetJustifyH('LEFT')
			power.ratio:SetJustifyV('MIDDLE')
			power.ratio:SetPoint('LEFT', power, 'RIGHT', 2, 0)
			self:Tag(power.ratio, '[perpp]%')

			self.Power = power
			self.Power.colorPower = true
			self.Power.frequentUpdates = true
		end
	end
	do -- setup ring, icons, and text
		local ring = CreateFrame('Frame', nil, self)
		ring:SetFrameLevel(4)
		ring:SetFrameStrata('BACKGROUND')
		ring:SetSize(50, 50)
		ring:SetPoint('CENTER', self, 'CENTER', -80, 3)

		self.Name = ring:CreateFontString()
		SUI:FormatFont(self.Name, 10, 'Player')
		self.Name:SetSize(127, 10)
		self.Name:SetJustifyH('LEFT')
		self.Name:SetJustifyV('MIDDLE')
		self.Name:SetPoint('TOPLEFT', self, 'TOPLEFT', 8, -2)
		if SUI.DB.PlayerFrames.showClass then
			self:Tag(self.Name, '[SUI_ColorClass][name]')
		else
			self:Tag(self.Name, '[name]')
		end

		self.LevelSkull = ring:CreateTexture(nil, 'ARTWORK')
		self.LevelSkull:SetSize(16, 16)
		self.LevelSkull:SetPoint('RIGHT', self.Name, 'LEFT', 2, 0)

		self.RaidTargetIndicator = ring:CreateTexture(nil, 'ARTWORK')
		self.RaidTargetIndicator:SetSize(24, 24)
		self.RaidTargetIndicator:SetPoint('CENTER', self, 'BOTTOMLEFT', 0, 23)
	end
	self.TextUpdate = PostUpdateText
	self.ColorUpdate = PostUpdateColor

	return self
end

local CreatePlayerFrames = function(self, unit)
	if (SUI_FramesAnchor:GetParent() == UIParent) then
		self:SetParent(UIParent)
	else
		self:SetParent(SUI_FramesAnchor)
	end

	self =
		((unit == 'target' and CreateTargetFrame(self, unit)) or (unit == 'targettarget' and CreateToTFrame(self, unit)) or
		(unit == 'player' and CreatePlayerFrame(self, unit)) or
		(unit == 'focus' and CreateFocusFrame(self, unit)) or
		(unit == 'focustarget' and CreateFocusFrame(self, unit)) or
		(unit == 'pet' and CreatePetFrame(self, unit)) or
		CreateBossFrame(self, unit))

	if self.Buffs and self.Buffs.PostUpdate then
		self.Buffs:PostUpdate(unit, 'Buffs')
	end
	if self.Debuffs and self.Debuffs.PostUpdate then
		self.Debuffs:PostUpdate(unit, 'Debuffs')
	end

	self = PlayerFrames:MakeMovable(self, unit)

	return self
end

function PlayerFrames:UpdateAltBarPositions()
	-- Druid EclipseBar
	-- EclipseBarFrame:ClearAllPoints();
	-- if SUI.DB.PlayerFrames.ClassBar.movement.moved then
	-- EclipseBarFrame:SetPoint(SUI.DB.PlayerFrames.ClassBar.movement.point,
	-- SUI.DB.PlayerFrames.ClassBar.movement.relativeTo,
	-- SUI.DB.PlayerFrames.ClassBar.movement.relativePoint,
	-- SUI.DB.PlayerFrames.ClassBar.movement.xOffset,
	-- SUI.DB.PlayerFrames.ClassBar.movement.yOffset);
	-- else
	-- EclipseBarFrame:SetPoint("TOPRIGHT",PlayerFrames.player,"TOPRIGHT",157,12);
	-- end

	-- Monk Chi Bar (Hard to move but it is doable.)
	-- MonkHarmonyBar:ClearAllPoints();
	-- if SUI.DB.PlayerFrames.ClassBar.movement.moved then
	-- MonkHarmonyBar:SetPoint(SUI.DB.PlayerFrames.ClassBar.movement.point,
	-- SUI.DB.PlayerFrames.ClassBar.movement.relativeTo,
	-- SUI.DB.PlayerFrames.ClassBar.movement.relativePoint,
	-- SUI.DB.PlayerFrames.ClassBar.movement.xOffset,
	-- SUI.DB.PlayerFrames.ClassBar.movement.yOffset);
	-- else
	-- MonkHarmonyBar:SetPoint("BOTTOMLEFT",PlayerFrames.player,"BOTTOMLEFT",40,-40);
	-- end

	--Paladin Holy Power
	-- PaladinPowerBarFrame:ClearAllPoints();
	-- if SUI.DB.PlayerFrames.ClassBar.movement.moved then
	-- PaladinPowerBarFrame:SetPoint(SUI.DB.PlayerFrames.ClassBar.movement.point,
	-- SUI.DB.PlayerFrames.ClassBar.movement.relativeTo,
	-- SUI.DB.PlayerFrames.ClassBar.movement.relativePoint,
	-- SUI.DB.PlayerFrames.ClassBar.movement.xOffset,
	-- SUI.DB.PlayerFrames.ClassBar.movement.yOffset);
	-- else
	-- PaladinPowerBarFrame:SetPoint("TOPLEFT",PlayerFrames.player,"BOTTOMLEFT",60,12);
	-- end

	--Priest Power Frame
	PriestBarFrame:ClearAllPoints()
	if SUI.DB.PlayerFrames.ClassBar.movement.moved then
		PriestBarFrame:SetPoint(
			SUI.DB.PlayerFrames.ClassBar.movement.point,
			SUI.DB.PlayerFrames.ClassBar.movement.relativeTo,
			SUI.DB.PlayerFrames.ClassBar.movement.relativePoint,
			SUI.DB.PlayerFrames.ClassBar.movement.xOffset,
			SUI.DB.PlayerFrames.ClassBar.movement.yOffset
		)
	else
		PriestBarFrame:SetPoint('TOPLEFT', PlayerFrames.player, 'TOPLEFT', -4, -2)
	end

	--Warlock Power Frame
	-- WarlockPowerFrame:ClearAllPoints();
	-- if SUI.DB.PlayerFrames.ClassBar.movement.moved then
	-- WarlockPowerFrame:SetPoint(SUI.DB.PlayerFrames.ClassBar.movement.point,
	-- SUI.DB.PlayerFrames.ClassBar.movement.relativeTo,
	-- SUI.DB.PlayerFrames.ClassBar.movement.relativePoint,
	-- SUI.DB.PlayerFrames.ClassBar.movement.xOffset,
	-- SUI.DB.PlayerFrames.ClassBar.movement.yOffset);
	-- else
	-- PlayerFrames:WarlockPowerFrame_Relocate();
	-- end

	--Death Knight Runes
	RuneFrame:ClearAllPoints()
	if SUI.DB.PlayerFrames.ClassBar.movement.moved then
		RuneFrame:SetPoint(
			SUI.DB.PlayerFrames.ClassBar.movement.point,
			SUI.DB.PlayerFrames.ClassBar.movement.relativeTo,
			SUI.DB.PlayerFrames.ClassBar.movement.relativePoint,
			SUI.DB.PlayerFrames.ClassBar.movement.xOffset,
			SUI.DB.PlayerFrames.ClassBar.movement.yOffset
		)
	else
		RuneFrame:SetPoint('TOPLEFT', PlayerFrames.player, 'BOTTOMLEFT', 40, 7)
	end

	-- relocate the AlternatePowerBar
	if classFileName ~= 'MONK' then
		PlayerFrameAlternateManaBar:ClearAllPoints()
		if SUI.DB.PlayerFrames.AltManaBar.movement.moved then
			PlayerFrameAlternateManaBar:SetPoint(
				SUI.DB.PlayerFrames.AltManaBar.movement.point,
				SUI.DB.PlayerFrames.AltManaBar.movement.relativeTo,
				SUI.DB.PlayerFrames.AltManaBar.movement.relativePoint,
				SUI.DB.PlayerFrames.AltManaBar.movement.xOffset,
				SUI.DB.PlayerFrames.AltManaBar.movement.yOffset
			)
		else
			PlayerFrameAlternateManaBar:SetPoint('TOPLEFT', PlayerFrames.player, 'BOTTOMLEFT', 40, 0)
		end
	end
end

function PlayerFrames:ResetAltBarPositions()
	SUI.DB.PlayerFrames.AltManaBar.movement.moved = false
	SUI.DB.PlayerFrames.ClassBar.movement.moved = false
	PlayerFrames:UpdateAltBarPositions()
end

function PlayerFrames:WarlockPowerFrame_Relocate() -- Sets the location of the warlock bars based on spec
	local spec = GetSpecialization()
	if (spec == SPEC_WARLOCK_AFFLICTION) then
		-- set up Affliction
		WarlockPowerFrame:SetScale(.85)
		WarlockPowerFrame:SetPoint('TOPLEFT', PlayerFrames.player, 'TOPLEFT', 8, -2)
	elseif (spec == SPEC_WARLOCK_DESTRUCTION) then
		-- set up Destruction
		WarlockPowerFrame:SetScale(0.85)
		WarlockPowerFrame:SetPoint('TOPLEFT', PlayerFrames.player, 'TOPLEFT', 14, -2)
	elseif (spec == SPEC_WARLOCK_DEMONOLOGY) then
		-- set up Demonic
		WarlockPowerFrame:SetScale(1)
		WarlockPowerFrame:SetPoint('TOPLEFT', PlayerFrames.player, 'TOPRIGHT', 15, 15)
	end
end

function PlayerFrames:SetupExtras()
	do -- relocate the AlternatePowerBar
		if classFileName == 'MONK' then
			--Align and shrink to fit under CHI, not movable
			PlayerFrameAlternateManaBar:SetParent(PlayerFrames.player)
			AlternatePowerBar_OnLoad(PlayerFrameAlternateManaBar)
			PlayerFrameAlternateManaBar:SetFrameStrata('MEDIUM')
			PlayerFrameAlternateManaBar:SetFrameLevel(6)
			PlayerFrameAlternateManaBar:SetScale(.7)
			PlayerFrameAlternateManaBar:ClearAllPoints()
			hooksecurefunc(
				PlayerFrameAlternateManaBar,
				'SetPoint',
				function(_, _, parent)
					if (parent ~= PlayerFrames.player) then
						PlayerFrameAlternateManaBar:ClearAllPoints()
						PlayerFrameAlternateManaBar:SetPoint('TOPLEFT', PlayerFrames.player, 'BOTTOMLEFT', -5, -17)
					end
				end
			)
			PlayerFrameAlternateManaBar:SetPoint('TOPLEFT', PlayerFrames.player, 'BOTTOMLEFT', -5, -17)
		else
			--Make it look like a smaller, movable mana bar.
			hooksecurefunc(
				PlayerFrameAlternateManaBar,
				'SetPoint',
				function(_, _, parent)
					if (parent ~= PlayerFrames.player) and (SUI.DB.PlayerFrames.AltManaBar.movement.moved == false) then
						PlayerFrameAlternateManaBar:ClearAllPoints()
						PlayerFrameAlternateManaBar:SetPoint('TOPLEFT', PlayerFrames.player, 'BOTTOMLEFT', 40, 0)
					end
				end
			)
			PlayerFrameAlternateManaBar:SetParent(PlayerFrames.player)
			AlternatePowerBar_OnLoad(PlayerFrameAlternateManaBar)
			PlayerFrameAlternateManaBar:SetFrameStrata('MEDIUM')
			PlayerFrameAlternateManaBar:SetFrameLevel(4)
			PlayerFrameAlternateManaBar:SetScale(1)
			PlayerFrameAlternateManaBar:EnableMouse(enable)
			PlayerFrameAlternateManaBar:SetScript(
				'OnMouseDown',
				function(self, button)
					if button == 'LeftButton' and IsAltKeyDown() then
						SUI.DB.PlayerFrames.AltManaBar.movement.moved = true
						self:SetMovable(true)
						self:StartMoving()
					end
				end
			)
			PlayerFrameAlternateManaBar:SetScript(
				'OnMouseUp',
				function(self, button)
					self:StopMovingOrSizing()
					SUI.DB.PlayerFrames.AltManaBar.movement.point,
						SUI.DB.PlayerFrames.AltManaBar.movement.relativeTo,
						SUI.DB.PlayerFrames.AltManaBar.movement.relativePoint,
						SUI.DB.PlayerFrames.AltManaBar.movement.xOffset,
						SUI.DB.PlayerFrames.AltManaBar.movement.yOffset = self:GetPoint(self:GetNumPoints())
				end
			)
		end

		-- Druid EclipseBar
		-- if classname == "Druid" then
		-- EclipseBarFrame:SetParent(PlayerFrames.player); EclipseBar_OnLoad(EclipseBarFrame); EclipseBarFrame:SetFrameStrata("MEDIUM");
		-- EclipseBarFrame:SetFrameLevel(4); EclipseBarFrame:SetScale(0.8 * SUI.DB.PlayerFrames.ClassBar.scale); EclipseBarFrame:EnableMouse(enable);
		-- EclipseBarFrame:SetScript("OnMouseDown",function(self,button)
		-- if button == "LeftButton" and IsAltKeyDown() then
		-- SUI.DB.PlayerFrames.ClassBar.movement.moved = true;
		-- self:SetMovable(true);
		-- self:StartMoving();
		-- end
		-- end);
		-- EclipseBarFrame:SetScript("OnMouseUp",function(self,button)
		-- self:StopMovingOrSizing();
		-- SUI.DB.PlayerFrames.ClassBar.movement.point,
		-- SUI.DB.PlayerFrames.ClassBar.movement.relativeTo,
		-- SUI.DB.PlayerFrames.ClassBar.movement.relativePoint,
		-- SUI.DB.PlayerFrames.ClassBar.movement.xOffset,
		-- SUI.DB.PlayerFrames.ClassBar.movement.yOffset = self:GetPoint(self:GetNumPoints())
		-- end);
		-- end

		-- PriestBarFrame
		-- if classname == "Priest" then
		PriestBarFrame:SetParent(PlayerFrames.player)
		PriestBarFrame_OnLoad(PriestBarFrame)
		PriestBarFrame:SetFrameStrata('MEDIUM')
		PriestBarFrame:SetFrameLevel(4)
		PriestBarFrame:SetScale(.7 * SUI.DB.PlayerFrames.ClassBar.scale)
		PriestBarFrame:EnableMouse(enable)
		PriestBarFrame:SetScript(
			'OnMouseDown',
			function(self, button)
				if button == 'LeftButton' and IsAltKeyDown() then
					SUI.DB.PlayerFrames.ClassBar.movement.moved = true
					self:SetMovable(true)
					self:StartMoving()
				end
			end
		)
		PriestBarFrame:SetScript(
			'OnMouseUp',
			function(self, button)
				self:StopMovingOrSizing()
				SUI.DB.PlayerFrames.ClassBar.movement.point,
					SUI.DB.PlayerFrames.ClassBar.movement.relativeTo,
					SUI.DB.PlayerFrames.ClassBar.movement.relativePoint,
					SUI.DB.PlayerFrames.ClassBar.movement.xOffset,
					SUI.DB.PlayerFrames.ClassBar.movement.yOffset = self:GetPoint(self:GetNumPoints())
			end
		)
		-- end

		-- Rune Frame
		-- if classname == "DeathKnight" then
		RuneFrame:SetParent(PlayerFrames.player)
		-- RuneFrame_OnLoad(RuneFrame);
		RuneFrame:SetFrameStrata('MEDIUM')
		RuneFrame:SetFrameLevel(4)
		RuneFrame:SetScale(0.97 * SUI.DB.PlayerFrames.ClassBar.scale)
		RuneFrame:EnableMouse(enable)
		-- RuneButtonIndividual1:EnableMouse(enable);
		RuneFrame:SetScript(
			'OnMouseDown',
			function(self, button)
				if button == 'LeftButton' and IsAltKeyDown() then
					SUI.DB.PlayerFrames.ClassBar.movement.moved = true
					self:SetMovable(true)
					self:StartMoving()
				end
			end
		)
		RuneFrame:SetScript(
			'OnMouseUp',
			function(self, button)
				self:StopMovingOrSizing()
				SUI.DB.PlayerFrames.ClassBar.movement.point,
					SUI.DB.PlayerFrames.ClassBar.movement.relativeTo,
					SUI.DB.PlayerFrames.ClassBar.movement.relativePoint,
					SUI.DB.PlayerFrames.ClassBar.movement.xOffset,
					SUI.DB.PlayerFrames.ClassBar.movement.yOffset = self:GetPoint(self:GetNumPoints())
			end
		)
		-- RuneButtonIndividual1:SetScript("OnMouseDown",function(self,button)
		-- if button == "LeftButton" and IsAltKeyDown() then
		-- SUI.DB.PlayerFrames.ClassBar.movement.moved = true;
		-- self:SetMovable(true);
		-- self:StartMoving();
		-- end
		-- end);
		-- RuneButtonIndividual1:SetScript("OnMouseUp",function(self,button)
		-- self:StopMovingOrSizing();
		-- SUI.DB.PlayerFrames.ClassBar.movement.point,
		-- SUI.DB.PlayerFrames.ClassBar.movement.relativeTo,
		-- SUI.DB.PlayerFrames.ClassBar.movement.relativePoint,
		-- SUI.DB.PlayerFrames.ClassBar.movement.xOffset,
		-- SUI.DB.PlayerFrames.ClassBar.movement.yOffset = self:GetPoint(self:GetNumPoints())
		-- end);
		-- end

		-- if classname == "Shaman" then
		-- Totem Frame (Pally Concentration, Shaman Totems, Monk Statues)
		for i = 1, 4 do
			local timer = _G['TotemFrameTotem' .. i .. 'Duration']
			timer.Show = function()
				return
			end
			timer:Hide()
		end
		hooksecurefunc(
			TotemFrame,
			'SetPoint',
			function(_, _, parent)
				if (parent ~= PlayerFrames.player) then
					TotemFrame:ClearAllPoints()
					if classFileName == 'MONK' then
						TotemFrame:SetPoint('TOPLEFT', PlayerFrames.player, 'BOTTOMLEFT', 100, 8)
					elseif classFileName == 'PALADIN' then
						TotemFrame:SetPoint('TOPLEFT', PlayerFrames.player, 'BOTTOMLEFT', 15, 8)
					else
						TotemFrame:SetPoint('TOPLEFT', PlayerFrames.player, 'BOTTOMLEFT', 70, 8)
					end
				end
			end
		)
		TotemFrame:SetParent(PlayerFrames.player)
		TotemFrame_OnLoad(TotemFrame)
		TotemFrame:SetFrameStrata('MEDIUM')
		TotemFrame:SetFrameLevel(4)
		TotemFrame:SetScale(0.7 * SUI.DB.PlayerFrames.ClassBar.scale)
		TotemFrame:ClearAllPoints()
		TotemFrame:SetPoint('TOPLEFT', PlayerFrames.player, 'BOTTOMLEFT', 70, 8)
		-- end

		-- relocate the PlayerPowerBarAlt
		-- hooksecurefunc(
		-- 	PlayerPowerBarAlt,
		-- 	'SetPoint',
		-- 	function(_, _, parent)
		-- 		if (parent ~= PlayerFrames.player) then
		-- 			PlayerPowerBarAlt:ClearAllPoints()
		-- 			PlayerPowerBarAlt:SetPoint('BOTTOMLEFT', PlayerFrames.player, 'TOPLEFT', 10, 40)
		-- 		end
		-- 	end
		-- )
		-- PlayerPowerBarAlt:SetParent(PlayerFrames.player)
		-- PlayerPowerBarAlt:SetFrameStrata('MEDIUM')
		-- PlayerPowerBarAlt:SetFrameLevel(4)
		-- PlayerPowerBarAlt:SetScale(1 * SUI.DB.PlayerFrames.ClassBar.scale)
		-- PlayerPowerBarAlt:ClearAllPoints()
		-- PlayerPowerBarAlt:SetPoint('BOTTOMLEFT', PlayerFrames.player, 'TOPLEFT', 10, 40)

		PlayerFrames:UpdateAltBarPositions()

		--Watch for Spec Changes
		local SpecWatcher = CreateFrame('Frame')
		SpecWatcher:RegisterEvent('PLAYER_TALENT_UPDATE')
		SpecWatcher:SetScript(
			'OnEvent',
			function()
				PlayerFrames:UpdateAltBarPositions()
			end
		)
	end

	do -- create a LFD cooldown frame
		local GetLFGDeserter = GetLFGDeserterExpiration
		local GetLFGRandomCooldown = GetLFGRandomCooldownExpiration

		local UpdateCooldown = function(self)
			local deserterExpiration = GetLFGDeserter()
			local myExpireTime, mode, hasDeserter
			if (deserterExpiration) then
				myExpireTime = deserterExpiration
				hasDeserter = true
			else
				myExpireTime = GetLFGRandomCooldown()
			end
			self.myExpirationTime = myExpireTime or GetTime()
			if (myExpireTime and GetTime() < myExpireTime) then
				if (hasDeserter) then
					self.text:SetText '|CFFEE0000X|r' -- deserter
					mode = 'deserter'
				else
					mode = 'time'
				end
			else
				mode = false
			end
			return mode
		end

		local StartAnimating = EyeTemplate_StartAnimating
		local StopAnimating = EyeTemplate_StopAnimating

		local UpdateIsShown = function(self)
			--	local mode, submode = GetLFGMode();
			local mode = UpdateCooldown(self)
			if (mode) then
				self:Show()
				if (mode == 'time') then
					StartAnimating(self)
				else
					StopAnimating(self)
				end
			else
				self:Hide()
			end
		end

		local OnEnter = function(self)
			local mode = UpdateCooldown(self)
			local DESERTER = 'You recently deserted a Dungeon Finder group|nand may not queue again for:'
			local RANDOM_COOLDOWN = LFG_RANDOM_COOLDOWN_YOU
			if (mode) then
				GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
				GameTooltip:SetText(LOOKING_FOR_DUNGEON)
				local timeRemaining = self.myExpirationTime - GetTime()
				if (timeRemaining > 0) then
					if (mode == 'deserter') then
						GameTooltip:AddLine(string.format(DESERTER .. ' %s', '|CFFEE0000' .. SecondsToTime(ceil(timeRemaining)) .. '|r'))
					else
						GameTooltip:AddLine(
							string.format(RANDOM_COOLDOWN .. ' %s', '|CFFEE0000' .. SecondsToTime(ceil(timeRemaining)) .. '|r')
						)
					end
				else
					GameTooltip:AddLine('Ready')
				end
				GameTooltip:Show()
			end
		end

		local OnLeave = function(self)
			GameTooltip:Hide()
		end

		local LFDCooldown = CreateFrame('Frame', nil, PlayerFrames.player)
		LFDCooldown:SetFrameStrata('BACKGROUND')
		LFDCooldown:SetFrameLevel(10)
		LFDCooldown:SetWidth(38) -- Set these to whatever height/width is needed
		LFDCooldown:SetHeight(38) -- for your Texture

		local t = LFDCooldown:CreateTexture(nil, 'BACKGROUND')
		--	t:SetTexture("Interface\\LFGFrame\\BattlenetWorking19.blp")
		t:SetTexture('Interface\\LFGFrame\\LFG-Eye.blp')
		t:SetAllPoints(LFDCooldown)
		LFDCooldown.texture = t

		local txt = LFDCooldown:CreateFontString(nil, 'OVERLAY', 'SUI_FontOutline18')
		txt:SetWidth(14)
		txt:SetHeight(22)
		txt:SetJustifyH('MIDDLE')
		txt:SetJustifyV('MIDDLE')
		txt:SetPoint('TOPLEFT', LFDCooldown, 'TOPLEFT', 5, 0)
		txt:SetPoint('BOTTOMRIGHT', LFDCooldown, 'BOTTOMRIGHT', 0, 0)
		LFDCooldown.text = txt
		LFDCooldown.text:SetText ''

		--	LFDCooldown.myExpirationTime = "";
		LFDCooldown:SetPoint('CENTER', PlayerFrames.player, 'CENTER', 85, -30)
		LFDCooldown:RegisterEvent('PLAYER_ENTERING_WORLD')
		LFDCooldown:RegisterEvent('UNIT_AURA')
		LFDCooldown:EnableMouse()
		LFDCooldown:SetScript('OnEvent', UpdateIsShown)
		LFDCooldown:SetScript('OnEnter', OnEnter)
		LFDCooldown:SetScript('OnLeave', OnLeave)
		--	LFDCooldown.text:SetText"|CFFEE0000X|r" -- deserter
		--	LFDCooldown:Show() -- on cooldown
		--	PlayerFrames.player.LFDRole:SetTexCoord(20/64, 39/64, 22/64, 41/64) -- set dps lfdrole icon
	end
end

SUIUF:RegisterStyle('SUI_PlayerFrames_Classic', CreatePlayerFrame)

----------------------------------------------------------------------------------------------------
local SpawnRaidFrame = function(self, unit)
	do -- setup base artwork
		self.artwork = CreateFrame('Frame', nil, self)
		self.artwork:SetFrameStrata('BACKGROUND')
		self.artwork:SetFrameLevel(1)
		self.artwork:SetAllPoints(self)

		self.artwork.bg = self.artwork:CreateTexture(nil, 'BACKGROUND')
		self.artwork.bg:SetAllPoints(self)
		self.artwork.bg:SetTexture(base_plate3_Small)
		if SUI.DB.RaidFrames.FrameStyle == 'large' then
			self:SetSize(165, 48)
			self.artwork.bg:SetTexCoord(.3, .95, 0.015, .77)
		elseif SUI.DB.RaidFrames.FrameStyle == 'medium' then
			self:SetSize(140, 35)
			self.artwork.bg:SetTexCoord(.3, .95, 0.015, .56)
		elseif SUI.DB.RaidFrames.FrameStyle == 'small' then
			self.artwork.bg:SetTexCoord(.3, .70, 0.3, .7)
		end
	end
	do -- setup status bars
		do -- health bar
			local health = CreateFrame('StatusBar', nil, self)
			health:SetFrameStrata('BACKGROUND')
			health:SetFrameLevel(2)
			health:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar')

			if SUI.DB.RaidFrames.FrameStyle == 'large' then
				health:SetPoint('TOPRIGHT', self, 'TOPRIGHT', -55, -19)
				health:SetSize(110, 27)
			elseif SUI.DB.RaidFrames.FrameStyle == 'medium' then
				health:SetSize(self:GetWidth() / 1.5, 13)
				health:SetPoint('TOPRIGHT', self, 'TOPRIGHT', -self:GetWidth() / 3, -20)
			elseif SUI.DB.RaidFrames.FrameStyle == 'small' then
				health:SetAllPoints(self)
			end

			health.value = health:CreateFontString()
			SUI:FormatFont(health.value, 10, 'Raid')
			health.value:SetJustifyH('CENTER')
			health.value:SetJustifyV('BOTTOM')
			self:Tag(health.value, RaidFrames:TextFormat('health'))

			health.ratio = health:CreateFontString()
			SUI:FormatFont(health.ratio, 10, 'Raid')
			-- health.ratio:SetSize(35, 11);
			health.ratio:SetJustifyH('RIGHT')
			health.ratio:SetJustifyV('MIDDLE')
			self:Tag(health.ratio, '[perhp]%')

			if SUI.DB.RaidFrames.FrameStyle == 'large' then
				health.ratio:SetPoint('LEFT', health, 'RIGHT', 6, 0)
				health.value:SetPoint('RIGHT', health, 'RIGHT', -2, 0)
				health.value:SetSize(health:GetWidth() / 1.1, 11)
			elseif SUI.DB.RaidFrames.FrameStyle == 'medium' then
				health.ratio:SetPoint('LEFT', health, 'RIGHT', 6, 0)
				health.value:SetPoint('RIGHT', health, 'RIGHT', -2, 0)
				health.value:SetSize(health:GetWidth() / 1.5, 11)
			elseif SUI.DB.RaidFrames.FrameStyle == 'small' then
				health.ratio:SetPoint('BOTTOMRIGHT', health, 'BOTTOMRIGHT', 0, 2)
				health.ratio:SetPoint('TOPLEFT', health, 'BOTTOMRIGHT', -35, 13)
				health.value:Hide()
			end

			-- local Background = health:CreateTexture(nil, 'BACKGROUND')
			-- Background:SetAllPoints(health)
			-- Background:SetTexture(1, 1, 1, .08)

			self.Health = health
			-- self.Health.bg = Background;
			self.Health.frequentUpdates = true
			self.Health.colorDisconnected = true
			self.Health.colorClass = true
			self.Health.colorHealth = true
			self.Health.colorSmooth = true

			SUI:oUF_HealPrediction(self)
		end
		do -- power bar
			local power = CreateFrame('StatusBar', nil, self)
			power:SetFrameStrata('BACKGROUND')
			power:SetFrameLevel(2)
			-- power:SetSize(self.Health:GetWidth(), 3);
			power:SetPoint('TOPRIGHT', self.Health, 'BOTTOMRIGHT', 0, 0)
			power:SetPoint('BOTTOMLEFT', self.Health, 'BOTTOMLEFT', 0, -3)

			self.Power = power
			self.Power.colorPower = true
			self.Power.frequentUpdates = true
		end
	end
	do -- setup text and icons
		local layer5 = CreateFrame('Frame', nil, self)
		layer5:SetAllPoints(self)
		layer5:SetFrameLevel(5)

		self.GroupRoleIndicator = layer5:CreateTexture(nil, 'ARTWORK')
		self.GroupRoleIndicator:SetSize(13, 13)
		self.GroupRoleIndicator:SetPoint('TOPLEFT', self, 'TOPLEFT', 1, -4)
		-- self.GroupRoleIndicator:SetPoint("BOTTOMRIGHT",self,"TOPLEFT",14,-17);

		self.Name = layer5:CreateFontString()
		SUI:FormatFont(self.Name, 11, 'Raid')
		self.Name:SetSize(self:GetWidth() - 30, 12)
		self.Name:SetJustifyH('LEFT')
		self.Name:SetJustifyV('BOTTOM')
		self.Name:SetPoint('TOPLEFT', self.GroupRoleIndicator, 'TOPRIGHT', 1, 1)
		-- self.Name:SetPoint("BOTTOMRIGHT",self.GroupRoleIndicator,"TOPRIGHT",-12,self:GetWidth()-30);
		if SUI.DB.RaidFrames.showClass then
			self:Tag(self.Name, '[SUI_ColorClass][name]')
		else
			self:Tag(self.Name, '[name]')
		end

		self.LeaderIndicator = layer5:CreateTexture(nil, 'ARTWORK')
		self.LeaderIndicator:SetSize(15, 15)
		self.LeaderIndicator:SetPoint('CENTER', self, 'TOP', 0, 0)

		self.RaidTargetIndicator = self:CreateTexture(nil, 'ARTWORK')
		self.RaidTargetIndicator:SetSize(24, 24)
		self.RaidTargetIndicator:SetPoint('CENTER', self, 'CENTER')
	end
	do -- setup debuffs
		self.Debuffs = CreateFrame('Frame', nil, self)
		self.Debuffs:SetWidth(17 * 11)
		self.Debuffs:SetHeight(17 * 1)
		self.Debuffs:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -6, 2)
		self.Debuffs:SetFrameStrata('BACKGROUND')
		self.Debuffs:SetFrameLevel(4)
		-- settings
		self.Debuffs.size = SUI.DB.RaidFrames.Auras.size
		self.Debuffs.spacing = SUI.DB.RaidFrames.Auras.spacing
		self.Debuffs.showType = SUI.DB.RaidFrames.Auras.showType
		self.Debuffs.initialAnchor = 'BOTTOMRIGHT'
		self.Debuffs.num = 5

		self.Debuffs.PostUpdate = RaidFrames:PostUpdateDebuffs(self, unit)
	end
	do -- HoTs Display
		self.AuraWatch = SUI:oUF_Buffs(self, 'TOPRIGHT', 'TOPRIGHT', 0)
	end
	do -- Threat, SpellRange, and Ready Check
		self.Range = {
			insideAlpha = 1,
			outsideAlpha = 1 / 2
		}

		local ResurrectIcon = self:CreateTexture(nil, 'OVERLAY')
		ResurrectIcon:SetSize(30, 30)
		ResurrectIcon:SetPoint('RIGHT', self, 'CENTER', 0, 0)
		self.ResurrectIndicator = ResurrectIcon

		local ReadyCheck = self:CreateTexture(nil, 'OVERLAY')
		ReadyCheck:SetSize(30, 30)
		ReadyCheck:SetPoint('RIGHT', self, 'CENTER', 0, 0)
		self.ReadyCheckIndicator = ReadyCheck

		local overlay = self:CreateTexture(nil, 'OVERLAY')
		overlay:SetTexture('Interface\\RaidFrame\\Raid-FrameHighlights')
		overlay:SetTexCoord(0.00781250, 0.55468750, 0.00781250, 0.27343750)
		overlay:SetAllPoints(self)
		overlay:SetVertexColor(1, 0, 0)
		overlay:Hide()
		self.ThreatIndicatorOverlay = overlay

		self.ThreatIndicator = CreateFrame('Frame', nil, self)
		self.ThreatIndicator.Override = threat
	end
	self.TextUpdate = RaidFrames:PostUpdateText(self, unit)
	return self
end

local CreateRaidFrame = function(self, unit)
	self = SpawnRaidFrame(self, unit)
	self = RaidFrames:MakeMovable(self)
	return self
end

SUIUF:RegisterStyle('Spartan_RaidFrames_Classic', CreateRaidFrame)

function RaidFrames:Classic()
	RaidFrames:ClassicOptions()
	SUIUF:SetActiveStyle('Spartan_RaidFrames_Classic')
	local xoffset = 3
	local yOffset = -5
	local point = 'TOP'
	local columnAnchorPoint = 'LEFT'
	local groupingOrder = 'TANK,HEALER,DAMAGER,NONE'

	if SUI.DB.RaidFrames.mode == 'GROUP' then
		groupingOrder = '1,2,3,4,5,6,7,8'
	end
	-- print(SUI.DB.RaidFrames.mode)
	-- print(groupingOrder)
	local w = 90
	local h = 30

	if SUI.DB.RaidFrames.FrameStyle == 'large' then
		w = 165
		h = 48
	elseif SUI.DB.RaidFrames.FrameStyle == 'medium' then
		w = 140
		h = 35
	end

	local initialConfigFunction = [[
		self:SetWidth(%d)
		self:SetHeight(%d)
	]]

	local raid =
		SUIUF:SpawnHeader(
		nil,
		nil,
		'raid',
		'showRaid',
		SUI.DB.RaidFrames.showRaid,
		'showParty',
		SUI.DB.RaidFrames.showParty,
		'showPlayer',
		SUI.DB.RaidFrames.showPlayer,
		'showSolo',
		SUI.DB.RaidFrames.showSolo,
		'xoffset',
		xoffset,
		'yOffset',
		yOffset,
		'point',
		point,
		'groupBy',
		SUI.DB.RaidFrames.mode,
		'groupingOrder',
		groupingOrder,
		'sortMethod',
		'index',
		'maxColumns',
		SUI.DB.RaidFrames.maxColumns,
		'unitsPerColumn',
		SUI.DB.RaidFrames.unitsPerColumn,
		'columnSpacing',
		SUI.DB.RaidFrames.columnSpacing,
		'columnAnchorPoint',
		columnAnchorPoint,
		'oUF-initialConfigFunction',
		format(initialConfigFunction, w, h)
		-- 'oUF-initialConfigFunction', [[
		-- self:SetHeight(35)
		-- self:SetWidth(90)
		-- ]]
	)
	raid:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', 20, -40)

	if SpartanUI then
		raid:SetParent('SpartanUI')
	else
		raid:SetParent(UIParent)
	end

	raid:SetClampedToScreen(false)

	return (raid)
end

function RaidFrames:ClassicOptions()
	SUI.opt.args['RaidFrames'].args['FrameStyle'] = {
		name = L['FrameStyle'],
		type = 'select',
		order = 2,
		values = {['large'] = L['Large'], ['medium'] = L['Medium'], ['small'] = L['Small']},
		get = function(info)
			return SUI.DB.RaidFrames.FrameStyle
		end,
		set = function(info, val)
			SUI.DB.RaidFrames.FrameStyle = val
			SUI:reloadui()
		end
	}
	SUI.opt.args['RaidFrames'].args['debuffs'] = {
		name = L['Debuffs'],
		type = 'group',
		order = 2,
		args = {
			party = {
				name = L['ShowAuras'],
				type = 'toggle',
				order = 1,
				get = function(info)
					return SUI.DB.RaidFrames.showAuras
				end,
				set = function(info, val)
					SUI.DB.RaidFrames.showAuras = val
					RaidFrames:UpdateAura()
				end
			},
			size = {
				name = L['BuffSize'],
				type = 'range',
				order = 2,
				min = 1,
				max = 30,
				step = 1,
				get = function(info)
					return SUI.DB.RaidFrames.Auras.size
				end,
				set = function(info, val)
					SUI.DB.RaidFrames.Auras.size = val
					RaidFrames:UpdateAura()
				end
			}
		}
	}
	SUI.opt.args['RaidFrames'].args['threat'] = {
		name = L['DispThreat'],
		type = 'toggle',
		order = 4,
		get = function(info)
			return SUI.DB.RaidFrames.threat
		end,
		set = function(info, val)
			SUI.DB.RaidFrames.threat = val
			SUI.DB.RaidFrames.preset = 'custom'
		end
	}
end
