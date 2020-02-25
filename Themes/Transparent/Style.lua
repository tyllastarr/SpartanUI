local SUI = SUI
local L = SUI.L
local Artwork_Core = SUI:GetModule('Component_Artwork')
local module = SUI:GetModule('Style_Transparent')
----------------------------------------------------------------------------------------------------
local InitRan = false

function module:OnInitialize()
	--Enable the in the Core options screen
	SUI.opt.args['General'].args['style'].args['OverallStyle'].args['Transparent'].disabled = false
	SUI.opt.args['General'].args['style'].args['Artwork'].args['Transparent'].disabled = false

	local BarHandler = SUI:GetModule('Component_BarHandler')
	BarHandler.BarPosition.BT4.Transparent = {
		['BT4Bar1'] = 'BOTTOM,SUI_ActionBarAnchor,BOTTOM,-349,54',
		['BT4Bar2'] = 'BOTTOM,SUI_ActionBarAnchor,BOTTOM,-349,3',
		['BT4Bar3'] = 'BOTTOM,SUI_ActionBarAnchor,BOTTOM,349,54',
		['BT4Bar4'] = 'BOTTOM,SUI_ActionBarAnchor,BOTTOM,349,3',
		['BT4Bar5'] = 'BOTTOMRIGHT,SUI_ActionBarAnchor,BOTTOMLEFT,47,0',
		['BT4Bar6'] = 'BOTTOMLEFT,SUI_ActionBarAnchor,BOTTOMRIGHT,-47,0',
		--
		['BT4BarStanceBar'] = 'BOTTOM,SUI_ActionBarAnchor,BOTTOM,-243,145',
		['BT4BarPetBar'] = 'BOTTOM,SUI_ActionBarAnchor,BOTTOM,-590,145',
		--
		['BT4BarMicroMenu'] = 'BOTTOM,SUI_ActionBarAnchor,BOTTOM,315,146',
		['BT4BarBagBar'] = 'BOTTOM,SUI_ActionBarAnchor,BOTTOM,638,154',
		--
		['BT4BarExtraActionBar'] = 'BOTTOM,SUI_ActionBarAnchor,TOP,0,15',
		['BT4BarZoneAbilityBar'] = 'BOTTOM,SUI_ActionBarAnchor,TOP,0,15'
	}

	--Init if needed
	if (SUI.DB.Artwork.Style == 'Transparent') then
		module:Init()
	end
end

function module:Init()
	module:SetupMenus()
	module:InitFramework()
	module:InitActionBars()
	module:InitMinimap()
	InitRan = true
end

function module:OnEnable()
	if (SUI.DB.Artwork.Style ~= 'Transparent') then
		module:Disable()
		return
	end
	if (SUI.DB.Artwork.Style == 'Transparent') then
		if (not InitRan) then
			module:Init()
		end
		module:EnableFramework()
		module:EnableActionBars()
		module:EnableMinimap()
	end
end

function module:SetupMenus()
	SUI.opt.args['Artwork'].args['Artwork'] = {
		name = 'Artwork Options',
		type = 'group',
		order = 10,
		args = {
			alpha = {
				name = L['Transparency'],
				type = 'range',
				order = 1,
				width = 'full',
				min = 0,
				max = 100,
				step = 1,
				desc = L['TransparencyDesc'],
				get = function(info)
					return (SUI.DB.alpha * 100)
				end,
				set = function(info, val)
					SUI.DB.alpha = (val / 100)
					module:updateAlpha()
				end
			},
			xOffset = {
				name = L['MoveSideways'],
				type = 'range',
				order = 3,
				width = 'full',
				desc = L['MoveSidewaysDesc'],
				min = -200,
				max = 200,
				step = .1,
				get = function(info)
					return SUI.DB.Offset.Horizontal / 6.25
				end,
				set = function(info, val)
					SUI.DB.Offset.Horizontal = val * 6.25
					module:updateXOffset()
				end
			},
			Color = {
				name = L['ArtColor'],
				type = 'color',
				hasAlpha = true,
				order = 1,
				width = 'full',
				get = function(info)
					return unpack(SUI.DB.Styles.Transparent.Color.Art)
				end,
				set = function(info, r, b, g, a)
					SUI.DB.Styles.Transparent.Color.Art = {r, b, g, a}
					module:SetColor()
				end
			}
		}
	}
end

function module:OnDisable()
	SUI_Art_Transparent:Hide()
end
