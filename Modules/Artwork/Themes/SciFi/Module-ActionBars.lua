local addon = LibStub("AceAddon-3.0"):GetAddon("SpartanUI");
local L = LibStub("AceLocale-3.0"):GetLocale("SpartanUI", true);
local Artwork_Core = addon:GetModule("Artwork_Core");
local module = addon:GetModule("Artwork_SciFi");
----------------------------------------------------------------------------------------------------
local default, plate = {
	popup1 = {anim = true, alpha = 1, enable = 1},
	popup2 = {anim = true, alpha = 1, enable = 1},
	bar1 = {alpha = 1, enable = 1},
	bar2 = {alpha = 1, enable = 1},
	bar3 = {alpha = 1, enable = 1},
	bar4 = {alpha = 1, enable = 1},
	bar5 = {alpha = 1, enable = 1},
	bar6 = {alpha = 1, enable = 1},
};

function module:UpdateSettings()
	DB.ActionBars = DB.ActionBars or {};
	for key,val in pairs(default) do
		if (not DB.ActionBars[key]) then DB.ActionBars[key] = val; end
		setmetatable(DB.ActionBars[key],{__index = default[key]});
	end
end;

function module:SetupProfile()
	if (not select(4, GetAddOnInfo("Bartender4"))) then return; end
	local standard = "SpartanUI 3.3.0 - SciFi";
	local settings = { -- actual settings being inserted into our custom profile
		ActionBars = {
			actionbars = { -- following settings are bare minimum, so that anything not defined is retained between resets
				{enabled = true,	buttons = 12,	rows = 1,	padding = 3,	skin = {Zoom = true},	position = {point = "LEFT",		parent = "SciFi_ActionBarPlate",	x=0,	y=36,	scale = 0.85,	growHorizontal="RIGHT"}}, -- 1
				{enabled = true,	buttons = 12,	rows = 1,	padding = 3,	skin = {Zoom = true},	position = {point = "LEFT",		parent = "SciFi_ActionBarPlate",	x=0,	y=-4,	scale = 0.85,	growHorizontal="RIGHT"}}, -- 2
				{enabled = true,	buttons = 12,	rows = 1,	padding = 3,	skin = {Zoom = true},	position = {point = "RIGHT",	parent = "SciFi_ActionBarPlate",	x=-402,	y=36,	scale = 0.85,	growHorizontal="RIGHT"}}, -- 3
				{enabled = true,	buttons = 12,	rows = 1,	padding = 3,	skin = {Zoom = true},	position = {point = "RIGHT",	parent = "SciFi_ActionBarPlate",	x=-402,	y=-4,	scale = 0.85,	growHorizontal="RIGHT"}}, -- 4
				{enabled = true,	buttons = 12,	rows = 3,	padding = 4,	skin = {Zoom = true},	position = {point = "LEFT",		parent = "SciFi_ActionBarPlate",	x=-135,	y=36,	scale = 0.80,	growHorizontal="RIGHT"}}, -- 5
				{enabled = true,	buttons = 12,	rows = 3,	padding = 4,	skin = {Zoom = true},	position = {point = "RIGHT",	parent = "SciFi_ActionBarPlate",	x=3,	y=36,	scale = 0.80,	growHorizontal="RIGHT"}}, -- 6
				{enabled = false,	buttons = 12,	rows = 1,	padding = 3,	skin = {Zoom = true},	position = {					parent = "SciFi_ActionBarPlate",					scale = 0.85,	growHorizontal="RIGHT"}}, -- 7
				{enabled = false,	buttons = 12,	rows = 1,	padding = 3,	skin = {Zoom = true},	position = {					parent = "SciFi_ActionBarPlate",					scale = 0.85,	growHorizontal="RIGHT"}}, -- 8
				{enabled = false,	buttons = 12,	rows = 1,	padding = 3,	skin = {Zoom = true},	position = {					parent = "SciFi_ActionBarPlate",					scale = 0.85,	growHorizontal="RIGHT"}}, -- 9
				{enabled = false,	buttons = 12,	rows = 1,	padding = 3,	skin = {Zoom = true},	position = {					parent = "SciFi_ActionBarPlate",					scale = 0.85,	growHorizontal="RIGHT"}} -- 10
			}
		},
		BagBar		= {	enabled = true, padding = 0, 		position = {point = "TOPRIGHT",		parent = "SciFi_ActionBarPlate",	x=-6,	y=-2,	scale = 0.70,	growHorizontal="LEFT"},		rows = 1, onebag = false, keyring = true},
		MicroMenu	= {	enabled = true,	padding = -3,		position = {point = "TOPLEFT",		parent = "SciFi_ActionBarPlate",	x=603,	y=0,	scale = 0.80,	growHorizontal="RIGHT"}},
		PetBar		= {	enabled = true, padding = 1, 		position = {point = "TOPLEFT",		parent = "SciFi_ActionBarPlate",	x=5,	y=-6,	scale = 0.70,	growHorizontal="RIGHT"},	rows = 1, skin = {Zoom = true}},
		StanceBar	= {	enabled = true,	padding = 1, 		position = {point = "TOPRIGHT",		parent = "SciFi_ActionBarPlate",	x=-605,	y=-2,	scale = 0.85,	growHorizontal="LEFT"},		rows = 1},
		MultiCast	= {	enabled = true,						position = {point = "TOPRIGHT",		parent = "SciFi_ActionBarPlate",	x=-777,	y=-4,	scale = 0.75}},
		Vehicle		= {	enabled = false,	padding = 3,		position = {point = "CENTER",		parent = "SciFi_ActionBarPlate",	x=-15,	y=213,	scale = 0.85}},
		ExtraActionBar = {	enabled = true,					position = {point = "CENTER",		parent = "SciFi_ActionBarPlate",	x=-32,	y=240}},
		BlizzardArt	= {	enabled = false,	},
	};
		
	module:UpdateSettings();
	-- New check for updating old profiles
	if ( not DB.ActionBars.SpartanUI_Version) then
		DB.ActionBars.SpartanUI_Version = GetAddOnMetadata("SpartanUI", "Version");
		-- Update Blizzard Art Bar settings on the standard profile
		if module:BartenderProfileCheck(standard,false) then
			for k,v in LibStub("AceAddon-3.0"):IterateModulesOfAddon(Bartender4) do -- for each module (BagBar, ActionBars, etc..)
				if v.db and v.db.profile then
					-- Fixup Blizzard Art Bar
					v.db.profile["BlizzardArt"] = module:MergeData(v.db.profile["BlizzardArt"],settings["BlizzardArt"])
					-- Fixup Vehicle Bar
					v.db.profile["Vehicle"] = module:MergeData(v.db.profile["Vehicle"],settings["Vehicle"])
				end
			end
		end
	end
	print("Using this profile: "..Bartender4.db:GetCurrentProfile())
	-- Checking for the standard Profile
	if (not module:BartenderProfileCheck(standard,true)) then DB.ActionBars.Bartender4 = false end
	-- Fixup setting profile to standard if standard profile exist
	if DB.ActionBars.Bartender4 then if profile == standard then Bartender4.db:SetProfile(standard) end return; end
	Bartender4.db:SetProfile(standard);
	for k,v in LibStub("AceAddon-3.0"):IterateModulesOfAddon(Bartender4) do -- for each module (BagBar, ActionBars, etc..)
		if settings[k] and v.db.profile then
			v.db.profile = module:MergeData(v.db.profile,settings[k])
		end
	end
	Bartender4:UpdateModuleConfigs(); -- run ApplyConfig for all modules, so that the new settings are applied
	if module:BartenderProfileCheck(standard,false) then addon:Print(standard.." "..L["BartenderProfileCreated"]) end
	DB.ActionBars.Bartender4 = true;
	plate:HookScript("OnUpdate",function(self,...)
		if (InCombatLockdown()) then return; end
		if (Bartender4.db:GetCurrentProfile() == standard) or (Bartender4.db:GetCurrentProfile() == newtest) then
			if Bartender4.Locked then return; end
			addon:Print(L["BartenderProfileLocked"]);
			Bartender4:Lock();
		end
	end);
end;

function module:BartenderProfileCheck(Input,Report)
	local profiles, r = Bartender4.db:GetProfiles(), false
	for k,v in pairs(profiles) do if v == Input then r = true end end
	if Report then if r ~= true then addon:Print(Input.." "..L["BartenderProfileCheckFail"]) end end
	return r
end

function module:MergeData(target,source)
	if type(target) ~= "table" then target = {} end
	for k,v in pairs(source) do
		if type(v) == "table" then
			target[k] = self:MergeData(target[k], v);
		else
			target[k] = v;
		end
	end
	return target;
end

function module:InitActionBars()
	--SciFi_PopTemplateBG:SetVertexColor(0,.8,.9,.7)
	Artwork_Core:ActionBarPlates("SciFi_ActionBarPlate");
		
	do -- create bar plate and masks
		plate = CreateFrame("Frame","SciFi_ActionBarPlate",SciFi_SpartanUI,"SciFi_ActionBarsTemplate");
		plate:SetFrameStrata("BACKGROUND"); plate:SetFrameLevel(1);
		plate:SetPoint("BOTTOM");
		
		plate.mask1 = CreateFrame("Frame","SciFi_Popup1Mask",SciFi_SpartanUI,"SciFi_Popup1MaskTemplate");
		plate.mask1:SetFrameStrata("MEDIUM"); plate.mask1:SetFrameLevel(0);
		plate.mask1:SetPoint("BOTTOM",SciFi_Popup1,"BOTTOM");
		
		plate.mask2 = CreateFrame("Frame","SciFi_Popup2Mask",SciFi_SpartanUI,"SciFi_Popup2MaskTemplate");
		plate.mask2:SetFrameStrata("MEDIUM"); plate.mask2:SetFrameLevel(0);
		plate.mask2:SetPoint("BOTTOM",SciFi_Popup2,"BOTTOM");
		
	end
end

function module:EnableActionBars()
	do -- create base module frames
		-- Fix CPU leak, use UpdateInterval
		plate.UpdateInterval = 0.5
		plate.TimeSinceLastUpdate = 0
		plate:HookScript("OnUpdate",function(self,...) -- backdrop and popup visibility changes (alpha, animation, hide/show)
			local elapsed = select(1,...)
			self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed; 
			if (self.TimeSinceLastUpdate > self.UpdateInterval) then
				-- Debug
--				print(self.TimeSinceLastUpdate)
				if (DB.ActionBars.bar1) then
					for b = 1,6 do -- for each backdrop
						if DB.ActionBars["bar"..b].enable then -- backdrop enabled
							_G["SciFi_Bar"..b]:SetAlpha(DB.ActionBars["bar"..b].alpha/100 or 1); -- apply alpha
						else -- backdrop disabled
							_G["SciFi_Bar"..b]:SetAlpha(0);
						end
					end
					for p = 1,2 do -- for each popup
						if (DB.ActionBars["popup"..p].enable) then -- popup enabled
							_G["SciFi_Popup"..p]:SetAlpha(DB.ActionBars["popup"..p].alpha/100 or 1); -- apply alpha
							if DB.ActionBars["popup"..p].anim == true then --- animation enabled
								_G["SciFi_Popup"..p.."MaskBG"]:SetAlpha(1);
							else -- animation disabled
								_G["SciFi_Popup"..p.."MaskBG"]:SetAlpha(0);
							end
						else -- popup disabled
							_G["SciFi_Popup"..p]:SetAlpha(0);
							_G["SciFi_Popup"..p.."MaskBG"]:SetAlpha(0);
						end
					end
					if (MouseIsOver(SciFi_Popup1Mask)) then -- popup1 animation
						SciFi_Popup1MaskBG:Hide();
						SciFi_Popup2MaskBG:Show();
					elseif (MouseIsOver(SciFi_Popup2Mask)) then -- popup2 animation
						SciFi_Popup2MaskBG:Hide();
						SciFi_Popup1MaskBG:Show();
					else -- animation at rest
						SciFi_Popup1MaskBG:Show();
						SciFi_Popup2MaskBG:Show();
					end
				end
				self.TimeSinceLastUpdate = 0
			end
		end);
	end
	do -- modify strata / levels of backdrops
		for i = 1,6 do
			_G["SciFi_Bar"..i]:SetFrameStrata("BACKGROUND");
			_G["SciFi_Bar"..i]:SetFrameLevel(3);
		end
		for i = 1,2 do
			_G["SciFi_Popup"..i]:SetFrameStrata("BACKGROUND");
			_G["SciFi_Popup"..i]:SetFrameLevel(3);
		end
	end
	module:SetupProfile();
	-- Do what Bartender isn't - Make the Bag buttons the same size
	do -- modify CharacterBag(0-3) Scale
		for i = 1,4 do
			_G["CharacterBag"..(i-1).."Slot"]:SetScale(1.25);
		end
	end
end