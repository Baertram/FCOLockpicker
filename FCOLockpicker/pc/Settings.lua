------------------------------------------------------------------
-- pc/Settings.lua — LibAddonMenu-2.0
------------------------------------------------------------------
local FCOLP = FCOLP

function FCOLP.CreatePCSettings()
local addonVars = FCOLP.addonVars
local addonName = addonVars.gAddonName
local numVars = FCOLP.numVars
local CM = CALLBACK_MANAGER
local LAM = LibAddonMenu2
local chamberResolvedIcons = FCOLP.chamberResolvedIcons
local chamberResolvedIconsTooltips = FCOLP.chamberResolvedIconsTooltips
local fcoLP_loc = FCOLP.localizationVars.FCOLP_loc

	local panelData = {
		type 				= 'panel',
		name 				= addonVars.addonNameMenu,
		displayName 		= addonVars.addonNameMenuDisplay,
		author 				= addonVars.addonAuthor,
		version 			= addonVars.addonVersionOptions,
		registerForRefresh 	= true,
		registerForDefaults = true,
		slashCommand = "/fcols",
	}

-- !!! RU Patch Section START
--  Add english language description behind language descriptions in other languages
	local function nvl(val) if val == nil then return "..." end return val end
	local LV_Cur = fcoLP_loc
	local LV_Eng = FCOLP.localizationVars.localizationAll[1]
	local languageOptions = {}
	local languageOptionsValues = {}
	for i=1, numVars.languageCount do
		local s="options_language_dropdown_selection"..i
		if LV_Cur==LV_Eng then
			languageOptions[i] = nvl(LV_Cur[s])
		else
			languageOptions[i] = nvl(LV_Cur[s]) .. " (" .. nvl(LV_Eng[s]) .. ")"
		end
		languageOptionsValues[i] = i
	end
-- !!! RU Patch Section END

    local savedVariablesOptions = {
    	[1] = fcoLP_loc["options_savedVariables_dropdown_selection1"],
        [2] = fcoLP_loc["options_savedVariables_dropdown_selection2"],
    }
    local savedVariablesOptionsValues = {
		[1] = 1,
		[2] = 2,
	}

	local settings = FCOLP.settingsVars.settings
	local defaultSettings = FCOLP.settingsVars.defaults

	FCOLP.SettingsPanel = LAM:RegisterAddonPanel(addonName, panelData)

	local function UpdateChamberStressedSoundDescription()
		--New ultimate sound 1
		FCOLockpickerChamberHeader.header:SetFont("ZoFontGameSmall")
		--FCOLockpickerChamberHeader.header:SetText(fcoLP_loc["options_chamber_stressed_sound"] .. ": " .. FCOLP.sounds[settings.chamberStressedSound])
		FCOLockpickerChamberHeader.data.name = fcoLP_loc["options_chamber_stressed_sound"] .. ": " .. FCOLP.sounds[settings.chamberStressedSound]
		FCOLockpickerChamberHeader:UpdateValue()
    end

	local lockPickChamberResolvedPreviewIconColor
	local function UpdateLockpickChamberResolvedPreviewIcon()
		if FCOLockpicker_LAMChamberResolvedPreviewIcon == nil then return end
		lockPickChamberResolvedPreviewIconColor = ZO_ColorDef:New(unpack(settings.chamberResolvedIconColor))
		FCOLockpicker_LAMChamberResolvedPreviewIcon:SetColor(lockPickChamberResolvedPreviewIconColor)
		FCOLockpicker_LAMChamberResolvedPreviewIcon.icon:SetColor(unpack(settings.chamberResolvedIconColor))
	end

--LAM 2.0 callback function if the panel was created
    local FCOLAMPanelCreated
	FCOLAMPanelCreated = function(panel)
        if panel ~= FCOLP.SettingsPanel then return end
        UpdateChamberStressedSoundDescription()
		UpdateLockpickChamberResolvedPreviewIcon()
    end

	local optionsTable =
    {	-- BEGIN OF OPTIONS TABLE

		{
			type = 'description',
			text = fcoLP_loc["options_description"],
		},
--==============================================================================
		{
        	type = 'header',
        	name = fcoLP_loc["options_header1"],
        },
		{
			type = 'dropdown',
			name = fcoLP_loc["options_language"],
			tooltip = fcoLP_loc["options_language_tooltip"],
			choices = languageOptions,
            choicesValues = languageOptionsValues,
			getFunc = function() return FCOLP.settingsVars.defaultSettings.language end,
            setFunc = function(value)
                --[[
				for i,v in pairs(languageOptions) do
                    if v == value then
                        debugMessage("[Settings language] v: " .. tostring(v) .. ", i: " .. tostring(i), false)
                    	FCOLP.settingsVars.defaultSettings.language = i
                        --Tell the FCOLP.settingsVars.settings that you have manually chosen the language and want to keep it
                        --Read in function Localization() after ReloadUI()
                        settings.languageChoosen = true
						--fcoLP_loc			  	 = fcoLP_loc[i]
                        ReloadUI()
                    end
                end
                ]]
				FCOLP.settingsVars.defaultSettings.language = value
				--Tell the FCOLP.settingsVars.settings that you have manually chosen the language and want to keep it
				--Read in function Localization() after ReloadUI()
				settings.languageChoosen = true
				--fcoLP_loc			  	 = fcoLP_loc[i]
				ReloadUI()
            end,
           disabled = function() return settings.alwaysUseClientLanguage end,
           warning = fcoLP_loc["options_language_description1"],
           requiresReload = true,
        },
		{
			type = "checkbox",
			name = fcoLP_loc["options_language_use_client"],
			tooltip = fcoLP_loc["options_language_use_client_tooltip"],
			getFunc = function() return settings.alwaysUseClientLanguage end,
			setFunc = function(value)
				settings.alwaysUseClientLanguage = value
                      --ReloadUI()
		            end,
            default = settings.alwaysUseClientLanguage,
            warning = fcoLP_loc["options_language_description1"],
            requiresReload = true,
		},
		{
			type = 'dropdown',
			name = fcoLP_loc["options_savedvariables"],
			tooltip = fcoLP_loc["options_savedvariables_tooltip"],
			choices = savedVariablesOptions,
			choicesValues = savedVariablesOptionsValues,
            getFunc = function() return FCOLP.settingsVars.defaultSettings.saveMode end,
            setFunc = function(value)
                --[[
				for i,v in pairs(savedVariablesOptions) do
                    if v == value then
                        debugMessage("[Settings save mode] v: " .. tostring(v) .. ", i: " .. tostring(i), false)
                        FCOLP.settingsVars.defaultSettings.saveMode = i
                        ReloadUI()
                    end
                end
                ]]
				FCOLP.settingsVars.defaultSettings.saveMode = value
				ReloadUI()
            end,
            warning = fcoLP_loc["options_language_description1"],
		},
--==============================================================================
		{
			type = "header",
			name = fcoLP_loc["options_header_color"]
		},

		{
			type = "colorpicker",
			name = fcoLP_loc["options_normal_color"],
			tooltip = fcoLP_loc["options_normal_color_tooltip"],
			getFunc = function() return settings.warnings.normal.color.r, settings.warnings.normal.color.g, settings.warnings.normal.color.b, settings.warnings.normal.color.a end,
            setFunc = function(r,g,b,a)
            	settings.warnings.normal.color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
			end,
            width="full",
            default = defaultSettings.warnings.normal.color,
		},
		{
			type = "colorpicker",
			name = fcoLP_loc["options_medium_color"],
			tooltip = fcoLP_loc["options_medium_color_tooltip"],
			getFunc = function() return settings.warnings.medium.color.r, settings.warnings.medium.color.g, settings.warnings.medium.color.b, settings.warnings.medium.color.a end,
            setFunc = function(r,g,b,a)
            	settings.warnings.medium.color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
			end,
            width="half",
            default = defaultSettings.warnings.medium.color,
		},
		{
			type = "slider",
			name = fcoLP_loc["options_medium_value"],
			tooltip = fcoLP_loc["options_medium_value_tooltip"],
			min = 1,
			max = 999,
            step = 1,
			getFunc = function() return settings.warnings.medium.valueMin end,
			setFunc = function(value)
					settings.warnings.medium.valueMin = value
 				end,
            width="full",
			default = defaultSettings.warnings.medium.valueMin,
		},
		{
			type = "colorpicker",
			name = fcoLP_loc["options_low_color"],
			tooltip = fcoLP_loc["options_low_color_tooltip"],
			getFunc = function() return settings.warnings.low.color.r, settings.warnings.low.color.g, settings.warnings.low.color.b, settings.warnings.low.color.a end,
            setFunc = function(r,g,b,a)
            	settings.warnings.low.color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
			end,
            width="half",
            default = defaultSettings.warnings.low.color,
		},
		{
			type = "slider",
			name = fcoLP_loc["options_low_value"],
			tooltip = fcoLP_loc["options_low_value_tooltip"],
			min = 1,
			max = 999,
            step = 1,
			getFunc = function() return settings.warnings.low.valueMin end,
			setFunc = function(value)
					settings.warnings.low.valueMin = value
 				end,
            width="full",
			default = defaultSettings.warnings.low.valueMin,
		},
--==============================================================================
   		{
			type = "header",
			name = fcoLP_loc["options_header_chamber"],
			reference = "FCOLockpickerChamberHeader",
		},
		{
			type = "slider",
			name = fcoLP_loc["options_chamber_stressed_sound"],
			tooltip = fcoLP_loc["options_chamber_stressed_sound_tooltip"],
			min = 1,
			max = #FCOLP.sounds,
			getFunc = function()
				return settings.chamberStressedSound end,
			setFunc = function(idx)
				settings.chamberStressedSound = idx
				UpdateChamberStressedSoundDescription()

				--Update the lockpick chamber stressed sound and play the currently chosen sound
				FCOLP.UpdateLockpickChamberStressedSound(idx, true)
			end,
			width="full",
			default = defaultSettings.chamberStressedSound,
		},
--==============================================================================
   		{
			type = "header",
			name = fcoLP_loc["options_header_chamber_resolved"]
		},
		{
			type = "checkbox",
			name = fcoLP_loc["options_show_chamber_resolved_icon"],
			tooltip = fcoLP_loc["options_show_chamber_resolved_icon_tooltip"],
			getFunc = function() return settings.showChamberResolvedIcon end,
            setFunc = function(value)
            	settings.showChamberResolvedIcon = value
			end,
            width="full",
            default = defaultSettings.showChamberResolvedIcon,
		},
		{
			type = "iconpicker",
			name = fcoLP_loc["options_chamber_resolved_icon"],
			tooltip = fcoLP_loc["options_chamber_resolved_icon"],
			choices = chamberResolvedIcons,
			choicesTooltips = chamberResolvedIconsTooltips,
			defaultColor = ZO_ColorDef:New(settings.chamberResolvedIconColor),
			getFunc = function() return FCOLP.IdToTexturePath(settings.chamberResolvedIcon) end,
            setFunc = function(value)
            	settings.chamberResolvedIcon = FCOLP.TexturePathToId(value)
				FCOLP.UpdateLockpickChamberResolvedIcon()
			end,
            width="half",
            default = defaultSettings.chamberResolvedIcon,
			disabled = function() return not settings.showChamberResolvedIcon end,
			reference = "FCOLockpicker_LAMChamberResolvedPreviewIcon"
		},
		{
			type = "colorpicker",
			name = fcoLP_loc["options_show_chamber_resolved_icon_color"],
			tooltip = fcoLP_loc["options_show_chamber_resolved_icon_color_tooltip"],
			getFunc = function() return unpack(settings.chamberResolvedIconColor) end,
            setFunc = function(r,g,b,a)
            	settings.chamberResolvedIconColor = {r, g, b, a}
				UpdateLockpickChamberResolvedPreviewIcon()
				FCOLP.UpdateLockpickChamberResolvedIcon()
			end,
            width="half",
            default = defaultSettings.chamberResolvedIconColor,
			disabled = function() return not settings.showChamberResolvedIcon end
		},
        {
            type = "checkbox",
            name = fcoLP_loc["options_show_chamber_resolved_green_springs"],
            tooltip = fcoLP_loc["options_show_chamber_resolved_green_springs_tooltip"],
            getFunc = function() return settings.useSpringGreenColor end,
            setFunc = function(value)
                settings.useSpringGreenColor = value
            end,
            width="half",
            default = defaultSettings.useSpringGreenColor,
        },
		{
			type = "colorpicker",
			name = fcoLP_loc["options_show_chamber_resolved_green_springs_color"],
			tooltip = fcoLP_loc["options_show_chamber_resolved_green_springs_color_tooltip"],
			getFunc = function() return unpack(settings.useSpringGreenColorColor) end,
            setFunc = function(r,g,b,a)
            	settings.useSpringGreenColorColor = {r, g, b, a}
				FCOLP.SetChamberResolvedSpringColor(r, g, b, a)
			end,
            width="half",
            default = defaultSettings.useSpringGreenColorColor,
			disabled = function() return not settings.useSpringGreenColor end
		},
	} -- END OF OPTIONS TABLE

	CM:RegisterCallback("LAM-PanelControlsCreated", FCOLAMPanelCreated)
	LAM:RegisterOptionControls(addonName, optionsTable)
end
