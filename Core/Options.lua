local SUI, L = SUI, SUI.L
local AceConfigDialog = LibStub('AceConfigDialog-3.0')
local module = SUI:NewModule('Options')

local LDBIcon = LibStub('LibDBIcon-1.0', true)

---------------------------------------------------------------------------
function module:ArtSetup()
	SUI.DBG.BartenderChangesActive = true
	SUI:GetModule('Component_Artwork'):SetupProfile()

	SUI.DBG.BartenderChangesActive = false
end

function module:InCombatLockdown()
	if InCombatLockdown() then
		SUI:Print('|cffff0000Unable to change setting in combat')
		return true
	end

	return false
end

function module:OnInitialize()

	SUI.opt.args['General'].args['style'] = {
		name = L['StyleSettings'],
		type = 'group',
		order = 100,
		args = {
			description = {type = 'header', name = L['OverallStyle'], order = 1},
			OverallStyle = {
				name = '',
				type = 'group',
				inline = true,
				order = 10,
				args = {
					Classic = {
						name = 'Classic',
						type = 'execute',
						image = function()
							return 'interface\\addons\\SpartanUI\\Classic\\Images\\base-center', 120, 60
						end,
						func = function()
							SUI.DBMod.Artwork.Style = 'Classic'
							SUI.DB.Unitframes.Style = SUI.DBMod.Artwork.Style
							module:ArtSetup()
						end
					},
					Fel = {
						name = 'Fel',
						type = 'execute',
						disabled = true,
						image = function()
							return 'interface\\addons\\SpartanUI\\images\\setup\\Style_Fel', 120, 60
						end,
						func = function()
							SUI.DBMod.Artwork.Style = 'Fel'
							SUI.DB.Styles.Fel.SubTheme = 'Fel'
							SUI.DB.Unitframes.Style = SUI.DBMod.Artwork.Style
							module:ArtSetup()
						end
					},
					Transparent = {
						name = 'Transparent',
						type = 'execute',
						disabled = true,
						image = function()
							return 'interface\\addons\\SpartanUI\\images\\setup\\Style_Transparent', 120, 60
						end,
						func = function()
							SUI.DBMod.Artwork.Style = 'Transparent'
							SUI.DB.Unitframes.Style = SUI.DBMod.Artwork.Style
							module:ArtSetup()
						end
					},
					Minimal = {
						name = 'Minimal',
						type = 'execute',
						disabled = true,
						image = function()
							return 'interface\\addons\\SpartanUI\\images\\setup\\Style_Minimal', 120, 60
						end,
						func = function()
							SUI.DBMod.Artwork.Style = 'Minimal'
							SUI.DB.Unitframes.Style = SUI.DBMod.Artwork.Style
							module:ArtSetup()
						end
					},
					Digital = {
						name = 'Digital',
						type = 'execute',
						disabled = true,
						image = function()
							return 'interface\\addons\\SpartanUI\\images\\setup\\Style_Digital', 120, 60
						end,
						func = function()
							SUI.DBMod.Artwork.Style = 'Fel'
							SUI.DB.Styles.Fel.SubTheme = 'Digital'
							SUI.DB.Unitframes.Style = SUI.DBMod.Artwork.Style
							module:ArtSetup()
						end
					},
					War = {
						name = 'War',
						type = 'execute',
						disabled = true,
						image = function()
							return 'interface\\addons\\SpartanUI\\images\\setup\\Style_War', 120, 60
						end,
						func = function()
							SUI.DBMod.Artwork.Style = 'War'
							SUI.DB.Unitframes.Style = SUI.DBMod.Artwork.Style
							module:ArtSetup()
						end
					}
				}
			},
			Artwork = {
				type = 'group',
				name = L['Artwork'],
				order = 100,
				args = {
					Classic = {
						name = 'Classic',
						type = 'execute',
						image = function()
							return 'interface\\addons\\SpartanUI\\Classic\\Images\\base-center', 120, 60
						end,
						func = function()
							SUI.DBMod.Artwork.Style = 'Classic'
							module:ArtSetup()
						end
					},
					Fel = {
						name = 'Fel',
						type = 'execute',
						disabled = true,
						image = function()
							return 'interface\\addons\\SpartanUI\\images\\setup\\Style_Fel', 120, 60
						end,
						func = function()
							SUI.DBMod.Artwork.Style = 'Fel'
							SUI.DB.Styles.Fel.SubTheme = 'Fel'
							module:ArtSetup()
						end
					},
					Transparent = {
						name = 'Transparent',
						type = 'execute',
						disabled = true,
						image = function()
							return 'interface\\addons\\SpartanUI\\images\\setup\\Style_Transparent', 120, 60
						end,
						func = function()
							SUI.DBMod.Artwork.Style = 'Transparent'
							module:ArtSetup()
						end
					},
					Minimal = {
						name = 'Minimal',
						type = 'execute',
						disabled = true,
						image = function()
							return 'interface\\addons\\SpartanUI\\images\\setup\\Style_Minimal', 120, 60
						end,
						func = function()
							SUI.DBMod.Artwork.Style = 'Minimal'
							module:ArtSetup()
						end
					},
					Digital = {
						name = 'Digital',
						type = 'execute',
						disabled = true,
						image = function()
							return 'interface\\addons\\SpartanUI\\images\\setup\\Style_Digital', 120, 60
						end,
						func = function()
							SUI.DBMod.Artwork.Style = 'Minimal'
							SUI.DB.Styles.Fel.SubTheme = 'Digital'
							module:ArtSetup()
						end
					},
					War = {
						name = 'War',
						type = 'execute',
						disabled = true,
						image = function()
							return 'interface\\addons\\SpartanUI\\images\\setup\\Style_War', 120, 60
						end,
						func = function()
							SUI.DBMod.Artwork.Style = 'War'
							module:ArtSetup()
						end
					}
				}
			},
			UnitFrames = {
				type = 'group',
				name = 'Unit frames',
				order = 100,
				args = {
					Classic = {
						name = 'Classic',
						type = 'execute',
						image = function()
							return 'interface\\addons\\SpartanUI\\images\\setup\\Style_Frames_Classic', 120, 60
						end,
						imageCoords = function()
							return {0, .5, 0, .5}
						end,
						func = function()
							SUI.DB.Unitframes.Style = 'Classic'
						end
					},
					War = {
						name = 'War',
						type = 'execute',
						disabled = true,
						image = function()
							return 'interface\\addons\\SpartanUI\\images\\setup\\Style_Frames_Fel', 120, 60
						end,
						imageCoords = function()
							return {.1, .5, .1, .5}
						end,
						func = function()
							SUI.DB.Unitframes.Style = 'War'
						end
					},
					Fel = {
						name = 'Fel',
						type = 'execute',
						disabled = true,
						image = function()
							return 'interface\\addons\\SpartanUI\\images\\setup\\Style_Frames_Fel', 120, 60
						end,
						imageCoords = function()
							return {.1, .5, .1, .5}
						end,
						func = function()
							SUI.DB.Unitframes.Style = 'Fel'
						end
					},
					Transparent = {
						name = 'Transparent',
						type = 'execute',
						disabled = true,
						image = function()
							return 'interface\\addons\\SpartanUI\\images\\setup\\Style_Frames_Transparent', 120, 60
						end,
						imageCoords = function()
							return {0, .5, 0, .5}
						end,
						func = function()
							SUI.DB.Unitframes.Style = 'Transparent'
						end
					},
					Minimal = {
						name = 'Minimal',
						type = 'execute',
						disabled = true,
						image = function()
							return 'interface\\addons\\SpartanUI\\images\\setup\\Style_Frames_Minimal', 120, 60
						end,
						imageCoords = function()
							return {0, .5, 0, .5}
						end,
						func = function()
							SUI.DB.Unitframes.Style = 'Minimal'
						end
					}
				}
			}
		}
	}
	SUI.opt.args['General'].args['Bartender'] = {
		name = 'Bartender',
		type = 'group',
		order = 500,
		args = {
			MoveBars = {
				name = L['Move ActionBars'],
				type = 'execute',
				order = 1,
				func = function()
					Bartender4:Unlock()
				end
			},
			ResetActionBars = {
				name = L['Reset ActionBars'],
				type = 'execute',
				order = 2,
				func = function()
					--Tell SUI to reload config
					SUI.DBMod.Artwork.FirstLoad = true

					--Strip custom BT4 Profile from config
					if SUI.DB.Styles[SUI.DBMod.Artwork.Style].BT4Profile then
						SUI.DB.Styles[SUI.DBMod.Artwork.Style].BT4Profile = nil
					end

					--Force Rebuild of primary bar profile
					SUI:GetModule('Style_' .. SUI.DBMod.Artwork.Style):SetupProfile()

					--Reset Moved bars
					local FrameList = {
						BT4Bar1,
						BT4Bar2,
						BT4Bar3,
						BT4Bar4,
						BT4Bar5,
						BT4Bar6,
						BT4BarBagBar,
						BT4BarExtraActionBar,
						BT4BarStanceBar,
						BT4BarPetBar,
						BT4BarMicroMenu
					}
					for _, v in ipairs(FrameList) do
						-- if SUI.DB.Styles[SUI.DBMod.Artwork.Style].MovedBars[v:GetName()] then
						SUI.DB.Styles[SUI.DBMod.Artwork.Style].MovedBars[v:GetName()] = false
						-- end
					end

					--go!
					ReloadUI()
				end
			},
			line1 = {name = '', type = 'header', order = 2.5},
			LockButtons = {
				name = L['Lock Buttons'],
				type = 'toggle',
				order = 3,
				get = function(info)
					if Bartender4 then
						return Bartender4.db.profile.buttonlock
					else
						SUI.opt.args['Artwork'].args['Base'].args['LockButtons'].disabled = true
						return false
					end
				end,
				set = function(info, value)
					Bartender4.db.profile.buttonlock = value
					Bartender4.Bar:ForAll('ForAll', 'SetAttribute', 'buttonlock', value)
				end
			},
			kb = {
				order = 4,
				type = 'execute',
				name = L['Key Bindings'],
				func = function()
					LibStub('LibKeyBound-1.0'):Toggle()
					AceConfigDialog:Close('Bartender4')
				end
			},
			line2 = {name = '', type = 'header', order = 5.5},
			VehicleUI = {
				name = L['Use Blizzard Vehicle UI'],
				type = 'toggle',
				order = 6,
				get = function(info)
					return SUI.DBMod.Artwork.VehicleUI
				end,
				set = function(info, val)
					if (InCombatLockdown()) then
						SUI:Print(ERR_NOT_IN_COMBAT)
						return
					end
					SUI.DBMod.Artwork.VehicleUI = val
					--Make sure bartender knows to do it, or not...
					if Bartender4 then
						Bartender4.db.profile.blizzardVehicle = val
						Bartender4:UpdateBlizzardVehicle()
					end

					if SUI.DBMod.Artwork.VehicleUI then
						if SUI:GetModule('Style_' .. SUI.DBMod.Artwork.Style).SetupVehicleUI() ~= nil then
							SUI:GetModule('Style_' .. SUI.DBMod.Artwork.Style):SetupVehicleUI()
						end
					else
						if SUI:GetModule('Style_' .. SUI.DBMod.Artwork.Style).RemoveVehicleUI() ~= nil then
							SUI:GetModule('Style_' .. SUI.DBMod.Artwork.Style):RemoveVehicleUI()
						end
					end
				end
			},
			-- MoveBars={name = "Move Bars", type = "toggle",order=0.91,
			-- get = function(info) if Bartender4 then return Bartender4.db.profile.buttonlock else SUI.opt.args["Artwork"].args["Base"].args["LockButtons"].disabled=true; return false; end end,
			-- set = function(info, value)
			-- Bartender4.db.profile.buttonlock = value
			-- Bartender4.Bar:ForAll("ForAll", "SetAttribute", "buttonlock", value)
			-- end,
			-- },
			minimapIcon = {
				order = 7,
				type = 'toggle',
				name = L['Minimap Icon'],
				get = function()
					return not Bartender4.db.profile.minimapIcon.hide
				end,
				set = function(info, value)
					Bartender4.db.profile.minimapIcon.hide = not value
					LDBIcon[value and 'Show' or 'Hide'](LDBIcon, 'Bartender4')
				end,
				disabled = function()
					return not LDBIcon
				end
			}
		}
	}
	SUI.opt.args['Help'] = {
		name = 'Help',
		type = 'group',
		order = 900,
		args = {
			ReRunSetupWizard = {
				name = L['Rerun setup wizard'],
				type = 'execute',
				order = .1,
				func = function()
					SUI:GetModule('SetupWizard'):SetupWizard()
				end
			},
			ResetProfileDB = {
				name = L['Reset profile'],
				type = 'execute',
				order = .5,
				func = function()
					SUI.SpartanUIDB:ResetProfile()
					ReloadUI()
				end
			},
			ResetDB = {
				name = L['ResetDatabase'],
				type = 'execute',
				order = 1,
				func = function()
					SUI.SpartanUIDB:ResetDB()
					ReloadUI()
				end
			},
			ResetActionBars = SUI.opt.args['General'].args['Bartender'].args['ResetActionBars'],
			ResetMovedFrames = {
				name = L['ResetMovableFrames'],
				type = 'execute',
				order = 3,
				func = function()
					SUI:GetModule('Component_MoveIt'):Reset()
				end
			},
			line1 = {name = '', type = 'header', order = 49},
			ver1 = {
				name = 'SUI ' .. L['Version'] .. ': ' .. SUI.Version,
				type = 'description',
				order = 50,
				fontSize = 'large'
			},
			ver2 = {
				name = 'SUI ' .. L['Build'] .. ': ' .. SUI.BuildNum,
				type = 'description',
				order = 51,
				fontSize = 'large'
			},
			ver3 = {
				name = L['Bartender4 version'] .. ': ' .. SUI.Bartender4Version,
				type = 'description',
				order = 53,
				fontSize = 'large'
			},
			line2 = {name = '', type = 'header', order = 99},
			navigationissues = {name = L['HaveQuestion'], type = 'description', order = 100, fontSize = 'large'},
			navigationissues2 = {
				name = '',
				type = 'input',
				order = 101,
				width = 'full',
				get = function(info)
					return 'https://discord.gg/Qc9TRBv'
				end,
				set = function(info, value)
				end
			},
			bugsandfeatures = {
				name = L['Bugs and Feature Requests'] .. ':',
				type = 'description',
				order = 200,
				fontSize = 'large'
			},
			bugsandfeatures2 = {
				name = '',
				type = 'input',
				order = 201,
				width = 'full',
				get = function(info)
					return 'http://bugs.spartanui.net/'
				end,
				set = function(info, value)
				end
			},
			line3 = {name = '', type = 'header', order = 500},
			FAQ = {name = 'F.A.Q', type = 'description', order = 501, fontSize = 'large'},
			FAQQ1 = {name = 'How do I move _________', type = 'description', order = 510, fontSize = 'medium'},
			FAQQ1A1 = {
				name = '- Unit frames can be moved by holding alt down and draging.',
				type = 'description',
				order = 511,
				fontSize = 'small'
			},
			FAQQ1A2 = {
				name = '- If the skin allows it the minimap can be moved by holding alt and dragging.',
				type = 'description',
				order = 512,
				fontSize = 'small'
			},
			FAQQ2 = {
				name = 'Actionbars are appearing in the wrong place',
				type = 'description',
				order = 520,
				fontSize = 'medium'
			},
			FAQQ2A1 = {
				name = '- Most issues can be fixed by reseting the action bars above.',
				type = 'description',
				order = 521,
				fontSize = 'small'
			}

			-- description = {name=L["HelpStringDesc1"],type="description",order = 901,fontSize="large"},
			-- description = {name=L["HelpStringDesc2"],type="description",order = 902,fontSize="small"},
			-- dataDump = {name=L["Export"],type="input",multiline=15,width="full",order=993,get = function(info) return module:enc(module:ExportData()) end},
		}
	}

	SUI.opt.args['General'].args['ver1'] = {
		name = 'SUI Version: ' .. SUI.Version,
		type = 'description',
		order = 50,
		fontSize = 'large'
	}
	SUI.opt.args['General'].args['ver2'] = {
		name = 'SUI Build: ' .. SUI.BuildNum,
		type = 'description',
		order = 51,
		fontSize = 'large'
	}
	SUI.opt.args['General'].args['ver3'] = {
		name = 'Bartender4 Version: ' .. SUI.Bartender4Version,
		type = 'description',
		order = 53,
		fontSize = 'large'
	}

	SUI.opt.args['General'].args['line2'] = {name = '', type = 'header', order = 99}
	SUI.opt.args['General'].args['navigationissues'] = {
		name = L['HaveQuestion'],
		type = 'description',
		order = 100,
		fontSize = 'medium'
	}
	SUI.opt.args['General'].args['navigationissues2'] = {
		name = '',
		type = 'input',
		order = 101,
		width = 'full',
		get = function(info)
			return 'https://discord.gg/Qc9TRBv'
		end,
		set = function(info, value)
		end
	}

	SUI.opt.args['General'].args['bugsandfeatures'] = {
		name = L['Bugs and Feature Requests'] .. ':',
		type = 'description',
		order = 200,
		fontSize = 'medium'
	}
	SUI.opt.args['General'].args['bugsandfeatures2'] = {
		name = '',
		type = 'input',
		order = 201,
		width = 'full',
		get = function(info)
			return 'http://bugs.spartanui.net/'
		end,
		set = function(info, value)
		end
	}

	SUI.opt.args['ModSetting'] = {
		name = L['Modules'],
		type = 'group',
		args = {
			Components = {
				name = 'Components',
				type = 'group',
				inline = true,
				args = {}
			}
		}
	}

	-- List Components
	for name, submodule in SUI:IterateModules() do
		if (string.match(name, 'Component_')) then
			local RealName = string.sub(name, 11)
			if SUI.DB.EnabledComponents == nil then
				SUI.DB.EnabledComponents = {}
			end
			if SUI.DB.EnabledComponents[RealName] == nil then
				SUI.DB.EnabledComponents[RealName] = true
			end

			local Displayname = string.sub(name, 11)
			if submodule.DisplayName then
				Displayname = submodule.DisplayName
			end

			SUI.opt.args.ModSetting.args.Components.args[RealName] = {
				name = Displayname,
				type = 'toggle',
				disabled = submodule.Override or false,
				get = function(info)
					if submodule.Override then
						return false
					end
					return SUI.DB.EnabledComponents[RealName]
				end,
				set = function(info, val)
					SUI.DB.EnabledComponents[RealName] = val
					if submodule.OnDisable then
						if val then
							submodule:OnEnable()
						else
							submodule:OnDisable()
						end
					else
						SUI:reloadui()
					end
				end
			}
		end
	end

	SUI.opt.args.ModSetting.args['enabled'] = {
		name = L['Enabled modules'],
		type = 'group',
		order = .1,
		args = {
			Components = SUI.opt.args.ModSetting.args['Components']
		}
	}
end

function module:OnEnable()
	if not SUI:GetModule('Component_Artwork', true) then
		SUI.opt.args['General'].args['style'].args['OverallStyle'].disabled = true
	end
end

function module:ExportData()
	--Get Character Data
	local CharData = {
		Region = GetCurrentRegion(),
		class = UnitClass('player'),
		Faction = UnitFactionGroup('player'),
		-- PlayerName = UnitName("player"),
		PlayerLevel = UnitLevel('player'),
		ActiveSpec = GetSpecializationInfo(GetSpecialization()),
		Zone = GetRealZoneText() .. ' - ' .. GetSubZoneText()
	}

	--Generate List of Addons
	local AddonsInstalled = {}

	for i = 1, GetNumAddOns() do
		local name, _, _, enabled = GetAddOnInfo(i)
		if enabled == true then
			AddonsInstalled[i] = name
		end
	end

	return '$SUI.' ..
		SUI.Version ..
			'-' ..
				SUI.CurseVersion ..
					'$C.' ..
						module:FlatenTable(CharData) ..
							'$Artwork.Style.' ..
								SUI.DBMod.Artwork.Style ..
									'$UnitFrames.Style.' ..
										SUI.DBMod.UnitFrames.Style ..
											'$PartyFrames.Style.' ..
												SUI.DBMod.PartyFrames.Style ..
													'$RaidFrames.Style.' ..
														SUI.DBMod.RaidFrames.Style .. '$Addons.' .. module:FlatenTable(AddonsInstalled) .. '..$END$..'
	-- .. "$DB." .. module:FlatenTable(SUI.DB)
	-- .. "$DBMod." .. module:FlatenTable(SUI.DBMod)
end

function module:FlatenTable(input)
	local returnval = ''
	for key, value in pairs(input) do
		if (type(value) == 'table') then
			returnval = returnval .. key .. '= {' .. module:FlatenTable(value) .. '},'
		elseif (type(value) ~= 'string') then
			returnval = returnval .. key .. '=' .. tostring(value) .. ','
		else
			returnval = returnval .. key .. '=' .. value .. ','
		end
	end
	return returnval
end

-- encoding
function module:enc(data)
	return ((data:gsub(
		'.',
		function(x)
			local r, b = '', x:byte()
			for i = 8, 1, -1 do
				r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0')
			end
			return r
		end
	) .. '0000'):gsub(
		'%d%d%d?%d?%d?%d?',
		function(x)
			local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
			if (#x < 6) then
				return ''
			end
			local c = 0
			for i = 1, 6 do
				c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0)
			end
			return b:sub(c + 1, c + 1)
		end
	) .. ({'', '==', '='})[#data % 3 + 1])
end

-- decoding
function module:dec(data)
	local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	data = string.gsub(data, '[^' .. b .. '=]', '')
	return (data:gsub(
		'.',
		function(x)
			if (x == '=') then
				return ''
			end
			local r, f = '', (b:find(x) - 1)
			for i = 6, 1, -1 do
				r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and '1' or '0')
			end
			return r
		end
	):gsub(
		'%d%d%d?%d?%d?%d?%d?%d?',
		function(x)
			if (#x ~= 8) then
				return ''
			end
			local c = 0
			for i = 1, 8 do
				c = c + (x:sub(i, i) == '1' and 2 ^ (7 - i) or 0)
			end
			return string.char(c)
		end
	))
end
