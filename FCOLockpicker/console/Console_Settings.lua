------------------------------------------------------------------
-- console/Settings.lua — LibHarvensAddonSettings
------------------------------------------------------------------
local FCOLP = FCOLP

function FCOLP.CreateConsoleSettings()
    local LHAS = LibHarvensAddonSettings
    local FCOLP = FCOLP
    local addonVars = FCOLP.addonVars
    local numVars = FCOLP.numVars
    local fcoLP_loc = FCOLP.localizationVars.FCOLP_loc
    local settings = FCOLP.settingsVars.settings
    local defaultSettings = FCOLP.settingsVars.defaults

    local panel

    local function refreshPanelControls()
        if panel and panel.UpdateControls then
            panel:UpdateControls()
        end
    end

    local function nvl(val)
        if val == nil then return "..." end
        return val
    end

    local function getKeyedColorDefaultArray(colorTable)
        return { colorTable.r, colorTable.g, colorTable.b, colorTable.a }
    end

    local function getDropdownDefaultLabel(items, dataValue)
        for itemIndex = 1, #items do
            local item = items[itemIndex]
            if item.data == dataValue then
                return item.name
            end
        end
        return ""
    end

    local function appendSection(allSettings, sectionLabel, sectionRows)
        allSettings[#allSettings + 1] =
        {
            type = LHAS.ST_SECTION,
            label = sectionLabel,
        }
        if sectionRows then
            for rowIndex = 1, #sectionRows do
                allSettings[#allSettings + 1] = sectionRows[rowIndex]
            end
        end
    end

    local function getLanguageDropdownItems()
        local items = {}
        local LV_Cur = fcoLP_loc
        local LV_Eng = FCOLP.localizationVars.localizationAll[1]
        for languageIndex = 1, numVars.languageCount do
            local selectionKey = "options_language_dropdown_selection" .. languageIndex
            local label
            if LV_Cur == LV_Eng then
                label = nvl(LV_Cur[selectionKey])
            else
                label = nvl(LV_Cur[selectionKey]) .. " (" .. nvl(LV_Eng[selectionKey]) .. ")"
            end
            items[#items + 1] = { name = label, data = languageIndex }
        end
        return items
    end

    local function getLanguageDropdownLabel()
        local languageId = FCOLP.settingsVars.defaultSettings.language
        return getDropdownDefaultLabel(getLanguageDropdownItems(), languageId)
    end

    local function getSaveModeDropdownItems()
        return {
            { name = fcoLP_loc["options_savedVariables_dropdown_selection1"], data = 1 },
            { name = fcoLP_loc["options_savedVariables_dropdown_selection2"], data = 2 },
        }
    end

    local function getSaveModeDropdownLabel()
        return getDropdownDefaultLabel(getSaveModeDropdownItems(), FCOLP.settingsVars.defaultSettings.saveMode)
    end

    local function getChamberStressedSoundDropdownItems()
        local items = {}
        for soundIndex, soundName in ipairs(FCOLP.sounds) do
            items[#items + 1] = { name = soundName, data = soundIndex }
        end
        return items
    end

    local function getChamberStressedSoundDropdownLabel()
        return getDropdownDefaultLabel(getChamberStressedSoundDropdownItems(), settings.chamberStressedSound)
    end

    local languageDropdownItems = getLanguageDropdownItems()
    local saveModeDropdownItems = getSaveModeDropdownItems()
    local chamberSoundDropdownItems = getChamberStressedSoundDropdownItems()

    local generalSectionRows =
    {
        {
            type = LHAS.ST_DROPDOWN,
            label = fcoLP_loc["options_language"],
            tooltip = fcoLP_loc["options_language_tooltip"],
            items = getLanguageDropdownItems,
            getFunction = function()
                return getLanguageDropdownLabel()
            end,
            setFunction = function(combobox, value, item)
                FCOLP.settingsVars.defaultSettings.language = item.data
                settings.languageChoosen = true
                ReloadUI()
            end,
            default = getDropdownDefaultLabel(languageDropdownItems, defaultSettings.language),
            disable = function()
                return settings.alwaysUseClientLanguage
            end,
        },
        {
            type = LHAS.ST_CHECKBOX,
            label = fcoLP_loc["options_language_use_client"],
            tooltip = fcoLP_loc["options_language_use_client_tooltip"],
            getFunction = function()
                return settings.alwaysUseClientLanguage
            end,
            setFunction = function(value)
                settings.alwaysUseClientLanguage = value
                refreshPanelControls()
            end,
            default = defaultSettings.alwaysUseClientLanguage,
        },
        {
            type = LHAS.ST_DROPDOWN,
            label = fcoLP_loc["options_savedvariables"],
            tooltip = fcoLP_loc["options_savedvariables_tooltip"],
            items = getSaveModeDropdownItems,
            getFunction = function()
                return getSaveModeDropdownLabel()
            end,
            setFunction = function(combobox, value, item)
                FCOLP.settingsVars.defaultSettings.saveMode = item.data
                ReloadUI()
            end,
            default = getDropdownDefaultLabel(saveModeDropdownItems, defaultSettings.saveMode),
        },
    }

    local colorSectionRows =
    {
        {
            type = LHAS.ST_COLOR,
            label = fcoLP_loc["options_normal_color"],
            tooltip = fcoLP_loc["options_normal_color_tooltip"],
            getFunction = function()
                local color = settings.warnings.normal.color
                return color.r, color.g, color.b, color.a
            end,
            setFunction = function(red, green, blue, alpha)
                settings.warnings.normal.color = { r = red, g = green, b = blue, a = alpha }
            end,
            default = getKeyedColorDefaultArray(defaultSettings.warnings.normal.color),
        },
        {
            type = LHAS.ST_COLOR,
            label = fcoLP_loc["options_medium_color"],
            tooltip = fcoLP_loc["options_medium_color_tooltip"],
            getFunction = function()
                local color = settings.warnings.medium.color
                return color.r, color.g, color.b, color.a
            end,
            setFunction = function(red, green, blue, alpha)
                settings.warnings.medium.color = { r = red, g = green, b = blue, a = alpha }
            end,
            default = getKeyedColorDefaultArray(defaultSettings.warnings.medium.color),
        },
        {
            type = LHAS.ST_SLIDER,
            label = fcoLP_loc["options_medium_value"],
            tooltip = fcoLP_loc["options_medium_value_tooltip"],
            min = 1,
            max = 999,
            step = 1,
            getFunction = function()
                return settings.warnings.medium.valueMin
            end,
            setFunction = function(value)
                settings.warnings.medium.valueMin = value
            end,
            default = defaultSettings.warnings.medium.valueMin,
        },
        {
            type = LHAS.ST_COLOR,
            label = fcoLP_loc["options_low_color"],
            tooltip = fcoLP_loc["options_low_color_tooltip"],
            getFunction = function()
                local color = settings.warnings.low.color
                return color.r, color.g, color.b, color.a
            end,
            setFunction = function(red, green, blue, alpha)
                settings.warnings.low.color = { r = red, g = green, b = blue, a = alpha }
            end,
            default = getKeyedColorDefaultArray(defaultSettings.warnings.low.color),
        },
        {
            type = LHAS.ST_SLIDER,
            label = fcoLP_loc["options_low_value"],
            tooltip = fcoLP_loc["options_low_value_tooltip"],
            min = 1,
            max = 999,
            step = 1,
            getFunction = function()
                return settings.warnings.low.valueMin
            end,
            setFunction = function(value)
                settings.warnings.low.valueMin = value
            end,
            default = defaultSettings.warnings.low.valueMin,
        },
    }

    local chamberSectionRows =
    {
        {
            type = LHAS.ST_DROPDOWN,
            label = fcoLP_loc["options_chamber_stressed_sound"],
            tooltip = fcoLP_loc["options_chamber_stressed_sound_tooltip"],
            items = getChamberStressedSoundDropdownItems,
            getFunction = function()
                return getChamberStressedSoundDropdownLabel()
            end,
            setFunction = function(combobox, value, item)
                settings.chamberStressedSound = item.data
                FCOLP.UpdateLockpickChamberStressedSound(item.data, true)
            end,
            default = getDropdownDefaultLabel(chamberSoundDropdownItems, defaultSettings.chamberStressedSound),
        },
    }

    local resolvedSectionRows =
    {
        {
            type = LHAS.ST_CHECKBOX,
            label = fcoLP_loc["options_show_chamber_resolved_icon"],
            tooltip = fcoLP_loc["options_show_chamber_resolved_icon_tooltip"],
            getFunction = function()
                return settings.showChamberResolvedIcon
            end,
            setFunction = function(value)
                settings.showChamberResolvedIcon = value
                refreshPanelControls()
            end,
            default = defaultSettings.showChamberResolvedIcon,
        },
        {
            type = LHAS.ST_ICONPICKER,
            label = fcoLP_loc["options_chamber_resolved_icon"],
            tooltip = fcoLP_loc["options_chamber_resolved_icon"],
            items = FCOLP.chamberResolvedIcons,
            getFunction = function()
                return settings.chamberResolvedIcon
            end,
            setFunction = function(iconPickerControl, iconIndex, iconTexturePath)
                settings.chamberResolvedIcon = iconIndex
                FCOLP.UpdateLockpickChamberResolvedIcon()
            end,
            default = defaultSettings.chamberResolvedIcon,
            disable = function()
                return not settings.showChamberResolvedIcon
            end,
        },
        {
            type = LHAS.ST_COLOR,
            label = fcoLP_loc["options_show_chamber_resolved_icon_color"],
            tooltip = fcoLP_loc["options_show_chamber_resolved_icon_color_tooltip"],
            getFunction = function()
                return unpack(settings.chamberResolvedIconColor)
            end,
            setFunction = function(red, green, blue, alpha)
                settings.chamberResolvedIconColor = { red, green, blue, alpha }
                FCOLP.UpdateLockpickChamberResolvedIcon()
            end,
            default = defaultSettings.chamberResolvedIconColor,
            disable = function()
                return not settings.showChamberResolvedIcon
            end,
        },
        {
            type = LHAS.ST_CHECKBOX,
            label = fcoLP_loc["options_show_chamber_resolved_green_springs"],
            tooltip = fcoLP_loc["options_show_chamber_resolved_green_springs_tooltip"],
            getFunction = function()
                return settings.useSpringGreenColor
            end,
            setFunction = function(value)
                settings.useSpringGreenColor = value
                refreshPanelControls()
            end,
            default = defaultSettings.useSpringGreenColor,
        },
        {
            type = LHAS.ST_COLOR,
            label = fcoLP_loc["options_show_chamber_resolved_green_springs_color"],
            tooltip = fcoLP_loc["options_show_chamber_resolved_green_springs_color_tooltip"],
            getFunction = function()
                return unpack(settings.useSpringGreenColorColor)
            end,
            setFunction = function(red, green, blue, alpha)
                settings.useSpringGreenColorColor = { red, green, blue, alpha }
                FCOLP.SetChamberResolvedSpringColor(red, green, blue, alpha)
            end,
            default = defaultSettings.useSpringGreenColorColor,
            disable = function()
                return not settings.useSpringGreenColor
            end,
        },
    }

    local settingsData = {}
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_LABEL,
        label = fcoLP_loc["options_description"],
        canSelect = false,
    }
    appendSection(settingsData, fcoLP_loc["options_header1"], generalSectionRows)
    appendSection(settingsData, fcoLP_loc["options_header_color"], colorSectionRows)
    appendSection(settingsData, fcoLP_loc["options_header_chamber"], chamberSectionRows)
    appendSection(settingsData, fcoLP_loc["options_header_chamber_resolved"], resolvedSectionRows)

    panel = LHAS:AddAddon(addonVars.addonNameMenuDisplay,
                          {
                              allowDefaults = true,
                              allowRefresh = true,
                          })
    if panel then
        panel.author = addonVars.addonAuthor
        panel.version = addonVars.addonVersionOptions
        panel:AddSettings(settingsData)
    end
end
