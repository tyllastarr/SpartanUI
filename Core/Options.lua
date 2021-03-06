local SUI, L = SUI, SUI.L
local module = SUI:NewModule('Options')

---------------------------------------------------------------------------
function module:InCombatLockdown()
	if InCombatLockdown() then
		SUI:Print('|cffff0000Unable to change setting in combat')
		return true
	end

	return false
end

function module:OnInitialize()
	SUI.opt.args.General.args.style = {
		name = 'Art Style',
		type = 'group',
		order = 100,
		args = {
			description = {type = 'header', name = L['OverallStyle'], order = 1},
			OverallStyle = {
				name = '',
				type = 'group',
				inline = true,
				order = 10,
				args = {}
			},
			description2 = {type = 'header', name = 'Artwork Style', order = 19},
			Artwork = {
				type = 'group',
				name = L['Artwork'],
				inline = true,
				order = 20,
				args = {}
			},
			description3 = {type = 'header', name = 'Unitframe Style', order = 29}
		}
	}
	local Skins = {
		'Classic',
		'War',
		'Tribal',
		'Fel',
		'Digital',
		'Arcane',
		'Transparent',
		'Minimal'
	}

	-- Setup Buttons
	for _, skin in pairs(Skins) do
		-- Create overall skin button
		SUI.opt.args.General.args.style.args.OverallStyle.args[skin] = {
			name = skin,
			type = 'execute',
			image = function()
				return 'interface\\addons\\SpartanUI\\images\\setup\\Style_' .. skin, 120, 60
			end,
			func = function()
				SUI:GetModule('Component_Artwork'):SetActiveStyle(skin)
				SUI:GetModule('Component_UnitFrames'):SetActiveStyle(skin)
				SUI.opt.args.UnitFrames.args.BaseStyle.args[skin].func()
			end
		}
		-- Setup artwork button
		SUI.opt.args.General.args.style.args.Artwork.args[skin] = {
			name = skin,
			type = 'execute',
			image = function()
				return 'interface\\addons\\SpartanUI\\images\\setup\\Style_' .. skin, 120, 60
			end,
			func = function()
				SUI:GetModule('Component_Artwork'):SetActiveStyle(skin)
			end
		}
	end

	SUI.opt.args['Help'] = {
		name = 'Help',
		type = 'group',
		order = 900,
		args = {
			SUIActions = {
				name = 'SUI Core Reset',
				type = 'group',
				inline = true,
				order = 40,
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
						width = 'double',
						desc = 'Start fresh with a new SUI profile',
						order = .5,
						func = function()
							SUI.SpartanUIDB:ResetProfile()
							ReloadUI()
						end
					},
					ResetDB = {
						name = L['ResetDatabase'],
						type = 'execute',
						desc = 'New SUI profile did not work? This is your nucular option. Reset everything SpartanUI related.',
						order = 1,
						func = function()
							SUI.SpartanUIDB:ResetDB()
							ReloadUI()
						end
					}
				}
			},
			line1 = {name = '', type = 'header', order = 40},
			SUIModuleHelp = {
				name = 'SUI Module Resets',
				type = 'group',
				order = 45,
				inline = true,
				args = {
					ResetMovedFrames = {
						name = L['ResetMovableFrames'],
						type = 'execute',
						order = 3,
						func = function()
							SUI:GetModule('Component_MoveIt'):Reset()
						end
					}
				}
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
			line3 = {name = '', type = 'header', order = 500}

			-- description = {name=L["HelpStringDesc1"],type="description",order = 901,fontSize="large"},
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
					return not SUI.DB.DisabledComponents[RealName]
				end,
				set = function(info, val)
					SUI.DB.DisabledComponents[RealName] = (not val)
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
