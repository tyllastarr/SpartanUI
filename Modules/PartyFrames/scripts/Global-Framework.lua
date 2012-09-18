local spartan = LibStub("AceAddon-3.0"):GetAddon("SpartanUI");
local addon = spartan:GetModule("PartyFrames");
----------------------------------------------------------------------------------------------------
local colors = setmetatable({},{__index = oUF.colors});
for k,v in pairs(oUF.colors) do if not colors[k] then colors[k] = v end end
colors.health = {0/255,255/255,50/255};
local base_plate1 = [[Interface\AddOns\SpartanUI_PartyFrames\media\base_1_full.blp]]
local base_plate2 = [[Interface\AddOns\SpartanUI_PartyFrames\media\base_2_dual.blp]]
local base_plate3 = [[Interface\AddOns\SpartanUI_PartyFrames\media\base_3_single.blp]]
local base_ring = [[Interface\AddOns\SpartanUI_PartyFrames\media\base_ring1.blp]]

local menu = function(self)
	if (not self.id) then self.id = self.unit:match"^.-(%d+)" end
	local unit = string.gsub(self.unit,"(.)",string.upper,1);
	if (_G[unit..'FrameDropDown']) then
		ToggleDropDownMenu(1, nil, _G[unit..'FrameDropDown'], 'cursor')
	elseif ( (self.unit:match('party')) and (not self.unit:match('partypet')) ) then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor")
	else
		FriendsDropDown.unit = self.unit
		FriendsDropDown.id = self.id
		FriendsDropDown.initialize = RaidFrameDropDown_Initialize
		ToggleDropDownMenu(1, nil, FriendsDropDown, 'cursor')
	end
end

local simple = function(val)
	if (val >= 1e6) then -- 1 million
		return ("%.1f m"):format(val/1e6);
	else
		return val
	end
end

local threat = function(self,event,unit)
	if (not self.Portrait) then return; end
	if (not self.Portrait:IsObjectType("Texture")) then return; end
	unit = string.gsub(self.unit,"(.)",string.upper,1) or string.gsub(unit,"(.)",string.upper,1)
	local status
	if UnitExists(unit) then status = UnitThreatSituation(unit) else status = 0; end
--	print(unit..' '..status) -- Debug code
	if (status and status > 0) then
		local r,g,b = GetThreatStatusColor(status);
		self.Portrait:SetVertexColor(r,g,b);
	else
		self.Portrait:SetVertexColor(1,1,1);
	end
end

local petinfo = function(self,event)
	if self.Name then self.Name:UpdateTag(self.unit); end
	if self.Level then self.Level:UpdateTag(self.unit); end
end

local PostUpdateAura = function(self,unit)
	if DBMod.PartyFrames.showAuras then
		self:Show();
	else
		self:Hide();
	end
end

local PostUpdateHealth = function(bar, unit, min, max)
	if(UnitIsDead(unit)) then
		bar:SetValue(0);
		bar.value:SetText"Dead"
		bar.ratio:SetText""
	elseif(UnitIsGhost(unit)) then
		bar:SetValue(0)
		bar.value:SetText"Ghost"
		bar.ratio:SetText""
	else
		if ( unit:match('partypet') ) then
			bar.value:SetFormattedText("%s", simple(min))
		else
			bar.value:SetFormattedText("%s / %s", min,max)
		end
		bar.ratio:SetFormattedText("%d%%",(min/max)*100);
	end
end

local PostUpdatePower = function(bar, unit, min, max)
	if (UnitIsDead(unit) or UnitIsGhost(unit) or not UnitIsConnected(unit) or max == 0) then
		bar.value:SetText""
		bar.ratio:SetText""
	else
		if ( unit:match('partypet') ) then
			bar.value:SetFormattedText("%s", simple(min));
		else
			bar.value:SetFormattedText("%s / %s", min,max)
		end
		bar.ratio:SetFormattedText("%d%%",(min/max)*100);
	end
end

local PostCastStop = function(self)
	if self.Time then self.Time:SetTextColor(1,1,1); end
end

local PostCastStart = function(self,unit,name,rank,text,castid)
	self:SetStatusBarColor(1,0.7,0);
end

local PostChannelStart = function(self,unit,name,rank,text,castid)
	self:SetStatusBarColor(1,0.2,0.7);
	-- self:SetStatusBarColor(0,1,0); --B3
end

local OnCastbarUpdate = function(self,elapsed)
	if self.casting then
		self.duration = self.duration + elapsed
		if (self.duration >= self.max) then
			self.casting = nil;
			self:Hide();
			if PostCastStop then PostCastStop(self:GetParent()); end
			return;
		end
		if self.Time then
			if self.delay ~= 0 then self.Time:SetTextColor(1,0,0); else self.Time:SetTextColor(1,1,1); end
			if DBMod.PartyFrames.castbartext == 1 then
				self.Time:SetFormattedText("%.1f",self.max - self.duration);
			else
				self.Time:SetFormattedText("%.1f",self.duration);
			end
		end
		if DBMod.PartyFrames.castbar == 1 then
			self:SetValue(self.max-self.duration)
		else
			self:SetValue(self.duration)
		end
	elseif self.channeling then
		self.duration = self.duration - elapsed;
		if (self.duration <= 0) then
			self.channeling = nil;
			self:Hide();
			if PostChannelStop then PostChannelStop(self:GetParent()); end
			return;
		end
		if self.Time then
			if self.delay ~= 0 then self.Time:SetTextColor(1,0,0); else self.Time:SetTextColor(1,1,1); end
			--self.Time:SetFormattedText("%.1f",self.max-self.duration);
			if DBMod.PartyFrames.castbartext == 0 then
				self.Time:SetFormattedText("%.1f",self.max-self.duration);
			else
				self.Time:SetFormattedText("%.1f",self.duration);
			end
		end
		if DBMod.PartyFrames.castbar == 1 then
			self:SetValue(self.duration)
		else
			self:SetValue(self.max-self.duration)
		end
	else
		self.unitName = nil;
		self.channeling = nil;
		self:SetValue(1);
		self:Hide();
	end
end

local CreatePartyFrame = function(self,unit)
	--self:SetSize(250, 70); -- just make it we will adjust later
	do -- setup base artwork
		self.artwork = CreateFrame("Frame",nil,self);
		self.artwork:SetFrameStrata("BACKGROUND");
		self.artwork:SetFrameLevel(1); self.artwork:SetAllPoints(self);
		
		self.artwork.bg = self.artwork:CreateTexture(nil,"BACKGROUND");
		self.artwork.bg:SetAllPoints(self);

		--	Portrait.Size = X Size of the Portrait section of the BG texture
		--  Portrait.XTexSize = This is the texcord size of the Portrait it
		-- 						is set by default for if there is no Portrait
		local Portrait = {Size=0,XTexSize=.3}
		if DBMod.PartyFrames.Portrait then
			Portrait.Size = 75
			Portrait.XTexSize = 0
		end
		
		if DBMod.PartyFrames.FrameStyle == "large" then
			self.artwork.bg:SetTexture(base_plate1);
			self:SetSize(165+Portrait.Size, 70);
			self.artwork.bg:SetTexCoord(Portrait.XTexSize,.95,0.015,.59);
		elseif DBMod.PartyFrames.FrameStyle == "medium" then
			self.artwork.bg:SetTexture(base_plate1);
			self:SetSize(165+Portrait.Size, 50);
			self.artwork.bg:SetTexCoord(Portrait.XTexSize,.95,0.015,.44);
		elseif DBMod.PartyFrames.FrameStyle == "small" then
			self.artwork.bg:SetTexture(base_plate3);
			self:SetSize(165+Portrait.Size, 48);
			self.artwork.bg:SetTexCoord(Portrait.XTexSize,.95,0.015,.77);
		elseif DBMod.PartyFrames.FrameStyle == "xsmall" then
			self.artwork.bg:SetTexture(base_plate2);
			self:SetSize(165+Portrait.Size, 35);
			self.artwork.bg:SetTexCoord(Portrait.XTexSize,.95,0.015,.56);
			
		end
		
		if DBMod.PartyFrames.Portrait then
			self.Portrait = self.artwork:CreateTexture(nil,"BORDER");
			self.Portrait:SetSize(55, 55);
			self.Portrait:SetPoint("TOPLEFT",self,"TOPLEFT",15,-8);
		end
		
		self.Threat = CreateFrame("Frame",nil,self);
		self.Threat.Override = threat;
	end
	do -- setup status bars
		do -- cast bar
		if DBMod.PartyFrames.FrameStyle == "large" then
			local cast = CreateFrame("StatusBar",nil,self);
			cast:SetFrameStrata("BACKGROUND"); cast:SetFrameLevel(2);
			cast:SetSize(110, 16);
			cast:SetPoint("TOPRIGHT",self,"TOPRIGHT",-55,-17);
			
			cast.Text = cast:CreateFontString();
			spartan:FormatFont(cast.Text, 10, "Party")
			cast.Text:SetSize(100, 11);
			cast.Text:SetJustifyH("LEFT"); cast.Text:SetJustifyV("BOTTOM");
			cast.Text:SetPoint("RIGHT",cast,"RIGHT",-2,0);
			
			cast.Time = cast:CreateFontString();
			spartan:FormatFont(cast.Time, 10, "Party")
			cast.Time:SetSize(40, 11);
			cast.Time:SetJustifyH("LEFT"); cast.Time:SetJustifyV("BOTTOM");
			cast.Time:SetPoint("LEFT",cast,"RIGHT",2,0);
			
			self.Castbar = cast;
			self.Castbar.OnUpdate = OnCastbarUpdate;
			self.Castbar.PostCastStart = PostCastStart;
			self.Castbar.PostChannelStart = PostChannelStart;
			self.Castbar.PostCastStop = PostCastStop;
		end
		end
		do -- health bar
			local health = CreateFrame("StatusBar",nil,self);
			health:SetFrameStrata("BACKGROUND"); health:SetFrameLevel(2);
			
			if DBMod.PartyFrames.FrameStyle == "large" then
				health:SetPoint("TOPRIGHT",self.Castbar,"BOTTOMRIGHT",0,-2);
				health:SetSize(110, 15);
			elseif DBMod.PartyFrames.FrameStyle == "medium" then
				health:SetPoint("TOPRIGHT",self,"TOPRIGHT",-55,-19);
				health:SetSize(110, 15);
			elseif DBMod.PartyFrames.FrameStyle == "small" then
				health:SetPoint("TOPRIGHT",self,"TOPRIGHT",-55,-19);
				health:SetSize(110, 27);
			elseif DBMod.PartyFrames.FrameStyle == "xsmall" then
				health:SetPoint("TOPRIGHT",self,"TOPRIGHT",-55,-20);
				health:SetSize(110, 13);
			end
			
			health.value = health:CreateFontString();
			spartan:FormatFont(health.value, 10, "Party")
			if DBMod.PartyFrames.FrameStyle == "large" then
				health.value:SetSize(100, 11);
			else
				health.value:SetSize(100, 10);
			end
			health.value:SetJustifyH("LEFT"); health.value:SetJustifyV("BOTTOM");
			health.value:SetPoint("RIGHT",health,"RIGHT",-2,0);
			self:Tag(health.value, '[curhpformatted]/[maxhpformatted]')
			
			health.ratio = health:CreateFontString();
			spartan:FormatFont(health.ratio, 10, "Party")
			health.ratio:SetSize(40, 11);
			health.ratio:SetJustifyH("LEFT"); health.ratio:SetJustifyV("BOTTOM");
			health.ratio:SetPoint("LEFT",health,"RIGHT",2,0);
			self:Tag(health.ratio, '[perhp]%')
			
			self.Health = health;
			self.Health.frequentUpdates = true;
			self.Health.colorDisconnected = true;
			self.Health.colorHealth = true;
			self.Health.colorSmooth = true;
		end
		do -- power bar
		if DBMod.PartyFrames.FrameStyle == "large" or DBMod.PartyFrames.FrameStyle == "medium" then
			local power = CreateFrame("StatusBar",nil,self);
			power:SetFrameStrata("BACKGROUND"); power:SetFrameLevel(2);
			
			if DBMod.PartyFrames.Portrait then power:SetSize(123, 14); else power:SetSize(110, 14); end
			
			power:SetPoint("TOPRIGHT",self.Health,"BOTTOMRIGHT",0,-2);
			
			power.value = power:CreateFontString();
			spartan:FormatFont(power.value, 10, "Party")
			if DBMod.PartyFrames.FrameStyle == "large" then
				power.value:SetSize(100, 11);
			elseif DBMod.PartyFrames.FrameStyle == "small" then
				power.value:SetSize(100, 22);
			else
				power.value:SetSize(100, 10);
			end
			power.value:SetJustifyH("LEFT"); power.value:SetJustifyV("BOTTOM");
			power.value:SetPoint("RIGHT",power,"RIGHT",-2,0);
			
			power.ratio = power:CreateFontString();
			spartan:FormatFont(power.ratio, 10, "Party")
			power.ratio:SetSize(40, 11);
			power.ratio:SetJustifyH("LEFT"); power.ratio:SetJustifyV("BOTTOM");
			power.ratio:SetPoint("LEFT",power,"RIGHT",2,0);
			
			self.Power = power;
			self.Power.colorPower = true;
			self.Power.frequentUpdates = true;
			self.Power.PostUpdate = PostUpdatePower;
		end
		end
	end
	do -- setup text and icons	
		local ring = CreateFrame("Frame",nil,self);
		ring:SetFrameStrata("BACKGROUND");
		
		self.Name = ring:CreateFontString();
		spartan:FormatFont(self.Name, 11, "Party")
		self.Name:SetSize(140, 10);
		self.Name:SetJustifyH("LEFT"); self.Name:SetJustifyV("BOTTOM");
		self.Name:SetPoint("TOPRIGHT",self,"TOPRIGHT",-10,-6);
		self:Tag(self.Name, "[name]");
		
		
		self.SUI_ClassIcon = ring:CreateTexture(nil,"BORDER");
		self.SUI_ClassIcon:SetSize(20, 20);
		
		self.Leader = ring:CreateTexture(nil,"BORDER");
		self.Leader:SetSize(20, 20);
		
		self.MasterLooter = ring:CreateTexture(nil,"BORDER");
		self.MasterLooter:SetSize(18, 18);
		
		self.LFDRole = ring:CreateTexture(nil,"BORDER");
		self.LFDRole:SetSize(25, 25);
		self.LFDRole:SetTexture[[Interface\AddOns\SpartanUI_PlayerFrames\media\icon_role]];
		
		self.RaidIcon = ring:CreateTexture(nil,"ARTWORK");
		self.RaidIcon:SetSize(20, 20);
		
		if DBMod.PartyFrames.Portrait then
			ring.bg = ring:CreateTexture(nil,"BACKGROUND");
			ring.bg:SetPoint("TOPLEFT",self,"TOPLEFT",-2,4);
			ring.bg:SetTexture(base_ring);
			
			self.Level = ring:CreateFontString();
			spartan:FormatFont(self.Level, 10, "Party")
			self.Level:SetSize(40, 12);
			self.Level:SetJustifyH("CENTER"); self.Level:SetJustifyV("BOTTOM");
			self.Level:SetPoint("CENTER",self.Portrait,"CENTER",-27,27);
			self:Tag(self.Level, "[level]");
			
			self.PvP = ring:CreateTexture(nil,"BORDER");
			self.PvP:SetSize(50, 50);
			self.PvP:SetPoint("CENTER",self.Portrait,"BOTTOMLEFT",5,-10);
			
			self.StatusText = ring:CreateFontString();
			spartan:FormatFont(self.StatusText, 18, "Party")
			self.StatusText:SetPoint("CENTER",self.Portrait,"CENTER");
			self.StatusText:SetJustifyH("CENTER");
			self:Tag(self.StatusText, '[afkdnd]');
			
			ring:SetAllPoints(self.Portrait); ring:SetFrameLevel(3);
			self.RaidIcon:SetPoint("CENTER",self.Portrait,"CENTER");
			self.SUI_ClassIcon:SetPoint("CENTER",self.Portrait,"CENTER",23,24);
			self.Leader:SetPoint("CENTER",self.Portrait,"TOP",-1,6);
			self.MasterLooter:SetPoint("CENTER",self.Portrait,"LEFT",-10,0);
		else
			ring:SetAllPoints(self); ring:SetFrameLevel(3);
			self.SUI_ClassIcon:SetPoint("CENTER",self,"TOPLEFT",5,-5);
			self.Leader:SetPoint("CENTER",self,"LEFT",0,0);
			self.MasterLooter:SetPoint("CENTER",self,"LEFT",0,-24);
			self.LFDRole:SetPoint("CENTER",self,"TOPRIGHT",-25,0);
			self.RaidIcon:SetPoint("CENTER",self,"TOPRIGHT",-15,-15);
		end
		
	end
	do -- setup buffs and debuffs
		self.Auras = CreateFrame("Frame",nil,self);
		self.Auras:SetSize(187, 17);
		self.Auras:SetPoint("TOPRIGHT",self,"BOTTOMRIGHT",-3,-5);
		self.Auras:SetFrameStrata("BACKGROUND");
		self.Auras:SetFrameLevel(4);
		-- settings
		self.Auras.size = DBMod.PartyFrames.Auras.size;
		self.Auras.spacing = DBMod.PartyFrames.Auras.spacing;
		self.Auras.showType = DBMod.PartyFrames.Auras.showType;
		self.Auras.initialAnchor = "TOPLEFT";
		self.Auras.gap = true; -- adds an empty spacer between buffs and debuffs
		self.Auras.numBuffs = DBMod.PartyFrames.Auras.NumBuffs;
		self.Auras.numDebuffs = DBMod.PartyFrames.Auras.NumDebuffs;
		
		self.Auras.PostUpdate = PostUpdateAura;
	end
	return self;
end

local CreateSubFrame = function(self,unit)
	self:SetSize(150, 36);
	do -- setup base artwork
		self.artwork = CreateFrame("Frame",nil,self);
		self.artwork:SetFrameStrata("BACKGROUND");
		self.artwork:SetFrameLevel(0.9); self.artwork:SetAllPoints(self);
		
		self.artwork.bg = self.artwork:CreateTexture(nil,"BACKGROUND");
		self.artwork.bg:SetAllPoints(self);
		self.artwork.bg:SetTexture(base_plate2);
		self.artwork.bg:SetTexCoord(.3,1,.01,.55);
		
		self.Threat = CreateFrame("Frame",nil,self);
		self.Threat.Override = threat;
	end
	do -- setup status bars
		do -- health bar
			local health = CreateFrame("StatusBar",nil,self);
			health:SetFrameStrata("BACKGROUND"); health:SetFrameLevel(.95);
			health:SetSize(self:GetWidth()/1.70, self:GetHeight()/2.97);
			health:SetPoint("BOTTOMLEFT",self.artwork.bg,"BOTTOMLEFT",11,2);
			
			health.value = health:CreateFontString();
			spartan:FormatFont(health.value, 10, "Party")
			health.value:SetSize(self:GetWidth()/2, health:GetHeight()-2);
			health.value:SetJustifyH("LEFT"); health.value:SetJustifyV("BOTTOM");
			health.value:SetPoint("RIGHT",health,"RIGHT",0,1);
			self:Tag(health.value, '[curhpshort]/[maxhpshort]')
			
			health.ratio = health:CreateFontString();
			spartan:FormatFont(health.ratio, 10, "Party")
			health.ratio:SetSize(self:GetWidth()/1.85, health:GetHeight()-2);
			health.ratio:SetJustifyH("LEFT"); health.ratio:SetJustifyV("BOTTOM");
			health.ratio:SetPoint("LEFT",health,"RIGHT",4,0);
			self:Tag(health.ratio, '[perhp]%')
			
			self.Health = health;
			self.Health.frequentUpdates = true;
			self.Health.colorDisconnected = true;
			self.Health.colorHealth = true;
			self.Health.colorSmooth = true;
		end
	end
	do -- setup text and icons
		self.Name = self:CreateFontString();
		spartan:FormatFont(self.Name, 11, "Party")
		self.Name:SetSize(135, 12);
		self.Name:SetJustifyH("LEFT"); self.Name:SetJustifyV("BOTTOM");
		self.Name:SetPoint("TOPRIGHT",self.artwork.bg,"TOPRIGHT",0,-4);
		self:Tag(self.Name, "[level] [name]");
	end
	return self;
end

local CreateUnitFrame = function(self,unit)
	self.menu = menu;
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	self:RegisterForClicks("AnyDown");
	self.colors = colors;
	self:SetClampedToScreen(true)
	
	self:EnableMouse(enable)
	self:SetScript("OnMouseDown",function(self,button)
		if button == "LeftButton" and IsAltKeyDown() then
			party.mover:Show();
			DBMod.PartyFrames.moved = true;
			party:SetMovable(true);
			party:StartMoving();
		end
	end);
	self:SetScript("OnMouseUp",function(self,button)
		party.mover:Hide();
		party:StopMovingOrSizing();
		local Anchors = {}
		Anchors.point, Anchors.relativeTo, Anchors.relativePoint, Anchors.xOfs, Anchors.yOfs = party:GetPoint()
		for k,v in pairs(Anchors) do
			DBMod.PartyFrames.Anchors[k] = v
		end
	end);
	
	if (self:GetAttribute("unitsuffix") == "target") and DBMod.PartyFrames.display.target then
		return CreateSubFrame(self,unit);
	elseif (self:GetAttribute("unitsuffix") == "pet") and (DBMod.PartyFrames.FrameStyle == "large" or (not DBMod.PartyFrames.display.target)) and DBMod.PartyFrames.display.pet then
		return CreateSubFrame(self,unit);
	elseif (unit == "party") then
		return CreatePartyFrame(self,unit);
	end
end

oUF:RegisterStyle("Spartan_PartyFrames", CreateUnitFrame);