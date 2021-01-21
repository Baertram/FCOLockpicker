------------------------------------------------------------------
--FCOLockpicker.lua
--Author: Baertram
--[[
Show number of lockpicks left at chests in different colors, depending on the lockpicks left
]]
------------------------------------------------------------------
-- Create the filter object for addon libFilters
local LAM = LibAddonMenu2

--Global addon variable
FCOLP = {}
local FCOLP = FCOLP
--Array for all the variables
FCOLP.locVars = {}
--Number variables
FCOLP.numVars = {}
--Available languages
FCOLP.numVars.languageCount = 7 --English, German, French, Spanish, Italian, Japanese, Russian
FCOLP.langVars = {}
FCOLP.langVars.languages = {}
--Build the languages array
for i=1, FCOLP.numVars.languageCount do
	FCOLP.langVars.languages[i] = true
end

--Uncolored "FCOLP" pre chat text for the chat output
FCOLP.locVars.preChatText = "FCOLockpicker"
--Green colored "FCOLP" pre text for the chat output
FCOLP.locVars.preChatTextGreen = "|c22DD22"..FCOLP.locVars.preChatText.."|r "
--Red colored "FCOLP" pre text for the chat output
FCOLP.locVars.preChatTextRed = "|cDD2222"..FCOLP.locVars.preChatText.."|r "
--Blue colored "FCOLP" pre text for the chat output
FCOLP.locVars.preChatTextBlue = "|c2222DD"..FCOLP.locVars.preChatText.."|r "

--Addon variables
FCOLP.addonVars = {}
FCOLP.addonVars.gAddonName					= "FCOLockpicker"
FCOLP.addonVars.addonNameMenu				= "FCO Lockpicker"
FCOLP.addonVars.addonNameMenuDisplay		= "|c00FF00FCO |cFFFF00Lockpicker|r"
FCOLP.addonVars.addonAuthor 				= '|cFFFF00Baertram|r'
FCOLP.addonVars.addonVersion		   		= 0.01 -- Changing this will reset SavedVariables!
FCOLP.addonVars.addonVersionOptions 		= '0.21' -- version shown in the settings panel
FCOLP.addonVars.addonSavedVariablesName		= "FCOLockpicker_Settings"
FCOLP.addonVars.gAddonLoaded				= false
local addonVars = FCOLP.addonVars
local addonName = addonVars.gAddonName

--Control names of ZO* standard controls etc.
FCOLP.zosVars 					= {}
FCOLP.zosVars.LOCKPICKS_LEFT = ZO_LockpickPanelInfoBarLockpicksLeft

FCOLP.settingsVars		= {}
FCOLP.settingsVars.settings 		 = {}
FCOLP.settingsVars.defaultSettings = {}

FCOLP.preventerVars = {}
FCOLP.preventerVars.gLocalizationDone = false
FCOLP.preventerVars.gLockpickActive                  = false
FCOLP.preventerVars.gOnLockpickChatStateWasMinimized = false
--[[
FCOLP.preventerVars.gOnLockpickChatStateWasMinimized = {
	["kb"] = false,
	["gp"] = false,
}
]]

FCOLP.localizationVars = {}
FCOLP.localizationVars.FCOLP_loc = {}

--===================== FUNCTIONS ==============================================

--Output debug message in chat
local function debugMessage(msg_text, deep)
	if (deep and not FCOLP.settingsVars.settings.deepDebug) then
    	return
    end
	if (FCOLP.settingsVars.settings.debug == true) then
    	if deep then
        	--Blue colored "FCOLockpicker" at the start of the string
	        d(FCOLP.locVars.preChatTextBlue .. msg_text)
        else
        	--Green colored "FCOLockpicker" at the start of the string
	        d(FCOLP.locVars.preChatTextGreen .. msg_text)
        end
	end
end

local function getGamepadOrKeyboardStr(gamePadMode)
	gamePadMode = gamePadMode or false
	local gpOrKbStr ={
		[true]  = "gp",
		[false] = "kb"
	}
	return gpOrKbStr[gamePadMode]
end

local function checkAndRememberChatMinimizedState(gamePadMode, doNotMinimize)
	gamePadMode = gamePadMode or IsInGamepadPreferredMode()
	doNotMinimize = doNotMinimize or false
--d(string.format("checkAndRememberChatMinimizedState - gamePadMode %s, doNotMinimize %s, gOnLockpickChatStateWasMinimized old: %s", tostring(gamePadMode), tostring(doNotMinimize), tostring(FCOLP.preventerVars.gOnLockpickChatStateWasMinimized)))
	local gpOrKbStr = getGamepadOrKeyboardStr(gamePadMode)
	--Get the chat's state (minimized7maximized) before lockpicking
	local isChatMinimized = CHAT_SYSTEM:IsMinimized()
	--FCOLP.preventerVars.gOnLockpickChatStateWasMinimized[gpOrKbStr] = isChatMinimized
	FCOLP.preventerVars.gOnLockpickChatStateWasMinimized = isChatMinimized
--d(string.format(">gOnLockpickChatStateWasMinimized new: %s", tostring(isChatMinimized)))
	--Minimize the chat now if it is not minimized already
	--Gamepadmode will minimize it on it's own already! -> Scene
	if not doNotMinimize and not gamePadMode and not isChatMinimized then CHAT_SYSTEM:Minimize() end
end

local function chatStateRestore(gamePadMode)
	--Maximize or minimize the chat after lockpicking again?
	gamePadMode = gamePadMode or IsInGamepadPreferredMode()
	local gpOrKbStr = getGamepadOrKeyboardStr(gamePadMode)

	local isChatMinimized = CHAT_SYSTEM:IsMinimized()
--d(string.format("chatStateRestore - gamePadMode %s, isChatMinimized %s, stateMinimizedBefore %s", tostring(gamePadMode), tostring(isChatMinimized), tostring(FCOLP.preventerVars.gOnLockpickChatStateWasMinimized)))
    --if FCOLP.preventerVars.gOnLockpickChatStateWasMinimized[gpOrKbStr] == true then
	if FCOLP.preventerVars.gOnLockpickChatStateWasMinimized == true then
		if not isChatMinimized then
			CHAT_SYSTEM:Minimize()
		end
	else
		if isChatMinimized then
			CHAT_SYSTEM:Maximize()
		end
    end
	--checkAndRememberChatMinimizedState(gamePadMode)
end

--Get the current lockpick color by the settings and amounts of lockpicks
local function FCOLockpicker_getLockpickInfoTextColor()
	local lockpicksLeft = GetNumLockpicksLeft()
	local newColor
	local settings = FCOLP.settingsVars.settings
    if lockpicksLeft <= settings.warnings.low.valueMin then
		newColor = settings.warnings.low.color
    elseif lockpicksLeft <= settings.warnings.medium.valueMin then
		newColor = settings.warnings.medium.color
    else
		newColor = settings.warnings.normal.color
    end
    return newColor
end

--Update the lockpicks left text control with the number of lockpicks left
local function FCOLockpicker_updateLockpicksLeftText(lockpickTextCtrl)
    if not lockpickTextCtrl then
		debugMessage("updateLockpicksLeftText", false)
	    return
	else
		debugMessage("updateLockpicksLeftText: " .. lockpickTextCtrl:GetName(), false)
    end

	local newTextColor = FCOLockpicker_getLockpickInfoTextColor()
    lockpickTextCtrl:SetColor(newTextColor.r, newTextColor.g, newTextColor.b, newTextColor.a)
end

local function FCOLockPicker_CreateLockpickChamberResolvedIcon()
	FCOLP.locVars.topLevelWindow = CreateTopLevelWindow(addonName .. "_ChamberResolvedIcon", GuiRoot)
	FCOLP.locVars.topLevelWindow:SetDimensions(240, 240)
	FCOLP.locVars.topLevelWindow:SetHidden(true)
	FCOLP.locVars.topLevelWindow:SetAnchor(CENTER, GuiRoot, CENTER)
	FCOLP.locVars.topLevelWindow:SetDrawLayer(DL_OVERLAY)
	FCOLP.locVars.topLevelWindow:SetDrawTier(DT_HIGH)
	FCOLP.locVars.topLevelWindow:SetDrawLevel(5)--high level to overlay others

	FCOLP.locVars.FCOLockpicker_chamberResolvedIconTexture = WINDOW_MANAGER:CreateControl(addonName .. "_ChamberResolvedIconTexture", FCOLP.locVars.topLevelWindow, CT_TEXTURE)
	FCOLP.locVars.FCOLockpicker_chamberResolvedIconTexture:SetAnchorFill()
	FCOLP.locVars.FCOLockpicker_chamberResolvedIconTexture:SetTexture("/esoui/art/guild/guildheraldry_indexicon_finalize_down.dds")
	FCOLP.locVars.FCOLockpicker_chamberResolvedIconTexture:SetColor(0, 1, 0, 1)
	FCOLP.locVars.FCOLockpicker_chamberResolvedIconTexture:SetDrawLayer(DL_OVERLAY)
	FCOLP.locVars.FCOLockpicker_chamberResolvedIconTexture:SetDrawTier(DT_HIGH)
    FCOLP.locVars.FCOLockpicker_chamberResolvedIconTexture:SetDrawLevel(5) --high level to overlay others

	FCOLP.locVars.FCOLockpicker_chamberResolvedIcon = FCOLP.locVars.topLevelWindow
end

local function FCOLockpicker_CheckLockpickChamberResolved()
	local settings = FCOLP.settingsVars.settings
    local showIcon = settings.showChamberResolvedIcon
    local useColors = settings.useSpringGreenColor
    if not showIcon and not useColors then return false end

    --local isInGamepadMode = IsInGamepadPreferredMode() and SCENE_MANAGER:IsShowing("lockpick_gamepad")
    local pi = LOCK_PICK.settingChamberIndex
	local chamberStress = GetSettingChamberStress()
	local chamberSolved = IsChamberSolved(pi)
    --d("[FCOLP] CheckLockpickChamberResolved - gamepadMode: " .. tostring(isInGamepadMode) .. ", chamberStress: " .. tostring(chamberStress) .. ", chamberSolved: " .. tostring(chamberSolved) .. ", chamberIndex: " .. tostring(pi) .. ", closesIndexGamepad: " .. tostring(LOCK_PICK.closestChamberIndexToLockpick))

	--Check if the current lockpick chamber is resolved
	if chamberStress > 0 and not chamberSolved then
        --Show the lockpick chamber resolved icon
        if showIcon then FCOLP.locVars.FCOLockpicker_chamberResolvedIcon:SetHidden(false) end
        if useColors then
            if LOCK_PICK.springs[pi] ~= nil and LOCK_PICK.springs[pi].pin ~= nil then
                LOCK_PICK.springs[pi].pin:SetColor(0, 1, 0, 1)
            end
        end
	else
        --Hide the lockpick chamber resolved icon
        if showIcon then FCOLP.locVars.FCOLockpicker_chamberResolvedIcon:SetHidden(true) end
        if useColors then
            if LOCK_PICK.springs[pi] ~= nil and LOCK_PICK.springs[pi].pin ~= nil then
                LOCK_PICK.springs[pi].pin:SetColor(1, 1, 1, 1)
            end
        end
	end
end

local function FCOLockpicker_Lockpick_Chamber_OnMouseDown()
	if not FCOLP.settingsVars.settings.showChamberResolvedIcon and not FCOLP.settingsVars.settings.useSpringGreenColor then return end
	if FCOLP.settingsVars.settings.showChamberResolvedIcon and not FCOLP.locVars.FCOLockpicker_chamberResolvedIcon then
		--Create the lockpick chamber resolved icon texture
    	FCOLockPicker_CreateLockpickChamberResolvedIcon()
    end
    --Check every 10 milliseconds if the lockpick chamber is resolved
	EVENT_MANAGER:RegisterForUpdate(addonName .. "_LockPickChamberResolvedCheck", 15, FCOLockpicker_CheckLockpickChamberResolved)
	return false
end

local function FCOLockpicker_Lockpick_Chamber_OnMouseUp()
	--Unregister the repeated check
	EVENT_MANAGER:UnregisterForUpdate(addonName.."_LockPickChamberResolvedCheck")
	--Hide the lockpick chamber resolved icon again
	if FCOLP.settingsVars.settings.showChamberResolvedIcon and FCOLP.locVars.FCOLockpicker_chamberResolvedIcon then
		FCOLP.locVars.FCOLockpicker_chamberResolvedIcon:SetHidden(true)
    end
	return false
end

local function Localization()
--d("[FCOLP] Localization - Start, useClientLang: " .. tostring(FCOLP.settingsVars.settings.alwaysUseClientLanguage))
	--Was localization already done during keybindings? Then abort here
 	if FCOLP.preventerVars.gLocalizationDone == true then return end
    --Fallback to english variable
    local fallbackToEnglish = false
	--Always use the client's language?
    if not FCOLP.settingsVars.settings.alwaysUseClientLanguage then
		--Was a language chosen already?
	    if not FCOLP.settingsVars.settings.languageChosen then
--d("[FCOLP] Localization: Fallback to english. Language chosen: " .. tostring(FCOLP.settingsVars.settings.languageChosen) .. ", defaultLanguage: " .. tostring(FCOLP.settingsVars.defaultSettings.language))
			if FCOLP.settingsVars.defaultSettings.language == nil then
--d("[FCOLP] Localization: defaultSettings.language is NIL -> Fallback to english now")
		    	fallbackToEnglish = true
		    else
				--Is the languages array filled and the language is not valid (not in the language array with the value "true")?
				if FCOLP.langVars.languages ~= nil and #FCOLP.langVars.languages > 0 and not FCOLP.langVars.languages[FCOLP.settingsVars.defaultSettings.language] then
		        	fallbackToEnglish = true
--d("[FCOLP] Localization: defaultSettings.language is ~= " .. i .. ", and this language # is not valid -> Fallback to english now")
				end
		    end
		end
	end
--d("[FCOLP] localization, fallBackToEnglish: " .. tostring(fallbackToEnglish))
	--Fallback to english language now
    if (fallbackToEnglish) then FCOLP.settingsVars.defaultSettings.language = 1 end
	--Is the standard language english set?
    if FCOLP.settingsVars.settings.alwaysUseClientLanguage or (FCOLP.settingsVars.defaultSettings.language == 1 and not FCOLP.settingsVars.settings.languageChosen) then
--d("[FCOLP] localization: Language chosen is false or always use client language is true!")
		local lang = GetCVar("language.2")
		--Check for supported languages
		if(lang == "de") then
	    	FCOLP.settingsVars.defaultSettings.language = 2
	    elseif (lang == "en") then
	    	FCOLP.settingsVars.defaultSettings.language = 1
	    elseif (lang == "fr") then
	    	FCOLP.settingsVars.defaultSettings.language = 3
	    elseif (lang == "es") then
	    	FCOLP.settingsVars.defaultSettings.language = 4
	    elseif (lang == "it") then
	    	FCOLP.settingsVars.defaultSettings.language = 5
	    elseif (lang == "jp") then
	    	FCOLP.settingsVars.defaultSettings.language = 6
	    elseif (lang == "ru") then
	    	FCOLP.settingsVars.defaultSettings.language = 7
		else
	    	FCOLP.settingsVars.defaultSettings.language = 1
	    end
	end
--d("[FCOLP] localization: default settings, language: " .. tostring(FCOLP.settingsVars.defaultSettings.language))
    --Get the localized texts from the localization file
    FCOLP.localizationVars.FCOLP_loc = FCOLP.localizationVars.localizationAll[FCOLP.settingsVars.defaultSettings.language]
end

--Show a help inside the chat
local function help()
	d(FCOLP.localizationVars.FCOLP_loc["chatcommands_info"])
	d("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	d(FCOLP.localizationVars.FCOLP_loc["chatcommands_help"])
    d(FCOLP.localizationVars.FCOLP_loc["chatcommands_debug"])
end

--Check the commands ppl type to the chat
local function command_handler(args)
    --Parse the arguments string
	local options = {}
    local searchResult = { string.match(args, "^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end

	if(#options == 0 or options[1] == "" or options[1] == "help" or options[1] == "hilfe" or options[1] == "list") then
       	help()
    elseif(options[1] == "debug") then
    	FCOLP.settingsVars.settings.debug = not FCOLP.settingsVars.settings.debug
        if (FCOLP.settingsVars.settings.debug == true) then
        	d(FCOLP.localizationVars.FCOLP_loc["chatcommands_debug_on"])
        else
        	FCOLP.settingsVars.settings.deepDebug = false
        	d(FCOLP.localizationVars.FCOLP_loc["chatcommands_debug_off"])
        end
    elseif(options[1] == "deepdebug") then
        FCOLP.settingsVars.settings.deepDebug = not FCOLP.settingsVars.settings.deepDebug
        if (FCOLP.settingsVars.settings.deepDebug == true) then
			FCOLP.settingsVars.settings.debug = true
        	d(FCOLP.localizationVars.FCOLP_loc["chatcommands_deepdebug_on"])
        else
			FCOLP.settingsVars.settings.debug = false
        	d(FCOLP.localizationVars.FCOLP_loc["chatcommands_deepdebug_off"])
        end
    end
end

-- Build the options menu
local function BuildAddonMenu()
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
	local LV_Cur = FCOLP.localizationVars.FCOLP_loc
	local LV_Eng = FCOLP.localizationVars.localizationAll[1]
	local languageOptions = {}
	local languageOptionsValues = {}
	for i=1, FCOLP.numVars.languageCount do
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
    	[1] = FCOLP.localizationVars.FCOLP_loc["options_savedVariables_dropdown_selection1"],
        [2] = FCOLP.localizationVars.FCOLP_loc["options_savedVariables_dropdown_selection2"],
    }
    local savedVariablesOptionsValues = {
		[1] = 1,
		[2] = 2,
	}

	local FCOLPlocVarsLoc = FCOLP.localizationVars.FCOLP_loc
	local settings = FCOLP.settingsVars.settings

	FCOLP.SettingsPanel = LAM:RegisterAddonPanel(addonName, panelData)

	local optionsTable =
    {	-- BEGIN OF OPTIONS TABLE

		{
			type = 'description',
			text = FCOLPlocVarsLoc["options_description"],
		},
--==============================================================================
		{
        	type = 'header',
        	name = FCOLPlocVarsLoc["options_header1"],
        },
		{
			type = 'dropdown',
			name = FCOLPlocVarsLoc["options_language"],
			tooltip = FCOLPlocVarsLoc["options_language_tooltip"],
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
						--FCOLPlocVarsLoc			  	 = FCOLPlocVarsLoc[i]
                        ReloadUI()
                    end
                end
                ]]
				FCOLP.settingsVars.defaultSettings.language = value
				--Tell the FCOLP.settingsVars.settings that you have manually chosen the language and want to keep it
				--Read in function Localization() after ReloadUI()
				settings.languageChoosen = true
				--FCOLPlocVarsLoc			  	 = FCOLPlocVarsLoc[i]
				ReloadUI()
            end,
           disabled = function() return settings.alwaysUseClientLanguage end,
           warning = FCOLPlocVarsLoc["options_language_description1"],
           requiresReload = true,
        },
		{
			type = "checkbox",
			name = FCOLPlocVarsLoc["options_language_use_client"],
			tooltip = FCOLPlocVarsLoc["options_language_use_client_tooltip"],
			getFunc = function() return settings.alwaysUseClientLanguage end,
			setFunc = function(value)
				settings.alwaysUseClientLanguage = value
                      --ReloadUI()
		            end,
            default = settings.alwaysUseClientLanguage,
            warning = FCOLPlocVarsLoc["options_language_description1"],
            requiresReload = true,
		},
		{
			type = 'dropdown',
			name = FCOLPlocVarsLoc["options_savedvariables"],
			tooltip = FCOLPlocVarsLoc["options_savedvariables_tooltip"],
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
            warning = FCOLPlocVarsLoc["options_language_description1"],
		},
--==============================================================================
		{
			type = "header",
			name = FCOLPlocVarsLoc["options_header_color"]
		},

		{
			type = "colorpicker",
			name = FCOLPlocVarsLoc["options_normal_color"],
			tooltip = FCOLPlocVarsLoc["options_normal_color_tooltip"],
			getFunc = function() return settings.warnings.normal.color.r, settings.warnings.normal.color.g, settings.warnings.normal.color.b, settings.warnings.normal.color.a end,
            setFunc = function(r,g,b,a)
            	settings.warnings.normal.color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
			end,
            width="full",
            default = settings.warnings.normal.color,
		},
		{
			type = "colorpicker",
			name = FCOLPlocVarsLoc["options_medium_color"],
			tooltip = FCOLPlocVarsLoc["options_medium_color_tooltip"],
			getFunc = function() return settings.warnings.medium.color.r, settings.warnings.medium.color.g, settings.warnings.medium.color.b, settings.warnings.medium.color.a end,
            setFunc = function(r,g,b,a)
            	settings.warnings.medium.color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
			end,
            width="half",
            default = settings.warnings.medium.color,
		},
		{
			type = "slider",
			name = FCOLPlocVarsLoc["options_medium_value"],
			tooltip = FCOLPlocVarsLoc["options_medium_value_tooltip"],
			min = 1,
			max = 999,
            step = 1,
			getFunc = function() return settings.warnings.medium.valueMin end,
			setFunc = function(value)
					settings.warnings.medium.valueMin = value
 				end,
            width="full",
			default = settings.warnings.medium.valueMin,
		},
		{
			type = "colorpicker",
			name = FCOLPlocVarsLoc["options_low_color"],
			tooltip = FCOLPlocVarsLoc["options_low_color_tooltip"],
			getFunc = function() return settings.warnings.low.color.r, settings.warnings.low.color.g, settings.warnings.low.color.b, settings.warnings.low.color.a end,
            setFunc = function(r,g,b,a)
            	settings.warnings.low.color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
			end,
            width="half",
            default = settings.warnings.low.color,
		},
		{
			type = "slider",
			name = FCOLPlocVarsLoc["options_low_value"],
			tooltip = FCOLPlocVarsLoc["options_low_value_tooltip"],
			min = 1,
			max = 999,
            step = 1,
			getFunc = function() return settings.warnings.low.valueMin end,
			setFunc = function(value)
					settings.warnings.low.valueMin = value
 				end,
            width="full",
			default = settings.warnings.low.valueMin,
		},
--==============================================================================
   		{
			type = "header",
			name = FCOLPlocVarsLoc["options_header_chamber_resolved"]
		},
		{
			type = "checkbox",
			name = FCOLPlocVarsLoc["options_show_chamber_resolved_icon"],
			tooltip = FCOLPlocVarsLoc["options_show_chamber_resolved_icon_tooltip"],
			getFunc = function() return settings.showChamberResolvedIcon end,
            setFunc = function(value)
            	settings.showChamberResolvedIcon = value
			end,
            width="full",
            default = settings.showChamberResolvedIcon,
		},
        {
            type = "checkbox",
            name = FCOLPlocVarsLoc["options_show_chamber_resolved_green_springs"],
            tooltip = FCOLPlocVarsLoc["options_show_chamber_resolved_green_springs_tooltip"],
            getFunc = function() return settings.useSpringGreenColor end,
            setFunc = function(value)
                settings.useSpringGreenColor = value
            end,
            width="full",
            default = settings.useSpringGreenColor,
        },
	} -- END OF OPTIONS TABLE

	LAM:RegisterOptionControls(addonName, optionsTable)
end

--==============================================================================
--============================== END SETTINGS ==================================
--==============================================================================

--Check for other addons and react on them
--[[
local function CheckIfOtherAddonsActive()
	return false
end
]]

--==============================================================================
--==================== START EVENT CALLBACK FUNCTIONS===========================
--==============================================================================

--Event upon end of lockpicking
local function FCOLockpicker_OnEndLockpick(...)
    FCOLP.preventerVars.gLockpickActive = false
    debugMessage("Lockpicking ended", false)
	local settings = FCOLP.settingsVars.settings
	--Hide the lockpick chamber resolved icon again
	if settings.showChamberResolvedIcon and FCOLP.locVars.FCOLockpicker_chamberResolvedIcon then
		FCOLP.locVars.FCOLockpicker_chamberResolvedIcon:SetHidden(true)
    end
    if settings.useSpringGreenColor then
        --Colorize the springs normal again
        for i = 1, 5 do
            if LOCK_PICK.springs[i] ~= nil and LOCK_PICK.springs[i].pin ~= nil then
                LOCK_PICK.springs[i].pin:SetColor(1, 1, 1, 1)
            end
        end
    end

	local gamePadMode = IsInGamepadPreferredMode()
--d(string.format("FCOLockpicker_OnEndLockpick - gamePadMode %s", tostring(gamePadMode)))
	chatStateRestore(gamePadMode)

	EVENT_MANAGER:UnregisterForEvent(addonName.. "_EVENT_LOCKPICK_FAILED", 	EVENT_LOCKPICK_FAILED)
	EVENT_MANAGER:UnregisterForEvent(addonName.. "_EVENT_LOCKPICK_SUCCESS", EVENT_LOCKPICK_SUCCESS)
	EVENT_MANAGER:UnregisterForEvent(addonName.. "_EVENT_LOCKPICK_BROKE", 	EVENT_LOCKPICK_BROKE)
end

--Event upon lockpick broke
local function FCOLockpicker_OnLockpickBroke(...)
    FCOLP.preventerVars.gLockpickActive = true
    debugMessage("Lockpick broke", false)

	FCOLockpicker_updateLockpicksLeftText(FCOLP.zosVars.LOCKPICKS_LEFT)
end

--Event upon begin of lockpicking
local function FCOLockpicker_OnBeginLockpick(...)
	--Gamepad mode
	--d(">[FCOLP]OnBeginLockPick-Chat minimized: " .. tostring(CHAT_SYSTEM:IsMinimized()))

	if not FCOLP.locVars.FCOLockpicker_chamberResolvedIcon and FCOLP.settingsVars.settings.showChamberResolvedIcon then
		--Create the lockpick chamber resolved icon texture
		FCOLockPicker_CreateLockpickChamberResolvedIcon()
	end

	--Remember chat minimized state, if not in gamepad mode. Will be done below in the lockpick scene state change, as
	--the gamepad will minimize the chat autoamtically already
	local gamePadMode = IsInGamepadPreferredMode()
	local isChatMinimized = CHAT_SYSTEM:IsMinimized()
	--d(string.format("FCOLockpicker_OnBeginLockpick - gamePadMode %s, isChatMinimized %s, stateMinimizedBefore %s", tostring(gamePadMode), tostring(isChatMinimized), tostring(FCOLP.preventerVars.gOnLockpickChatStateWasMinimized)))
	if not gamePadMode then
		checkAndRememberChatMinimizedState(gamePadMode)
	end

	FCOLP.preventerVars.gLockpickActive = true
	debugMessage("Lockpicking started", false)

	FCOLockpicker_updateLockpicksLeftText(FCOLP.zosVars.LOCKPICKS_LEFT)

	EVENT_MANAGER:RegisterForEvent(addonName .. "_EVENT_LOCKPICK_FAILED", 	EVENT_LOCKPICK_FAILED, 	FCOLockpicker_OnEndLockpick)
	EVENT_MANAGER:RegisterForEvent(addonName .. "_EVENT_LOCKPICK_SUCCESS", 	EVENT_LOCKPICK_SUCCESS, FCOLockpicker_OnEndLockpick)
	EVENT_MANAGER:RegisterForEvent(addonName .. "_EVENT_LOCKPICK_BROKE", 	EVENT_LOCKPICK_BROKE, 	FCOLockpicker_OnLockpickBroke)
end

--For gamepad mode only to detect the correct chat state
local function OnLockpickGamepadSceneStateChange(oldState, newState)
	local gamePadMode = IsInGamepadPreferredMode()
--d(">[FCOLP]OnLockpickGamepadSceneStateChange-newState: " ..tostring(newState) .. ", chat minimized: " .. tostring(CHAT_SYSTEM:IsMinimized()) ..", gamepadMode: " ..tostring(gamePadMode))
	if not gamePadMode then return end
	if newState == SCENE_SHOWING then
		checkAndRememberChatMinimizedState(gamePadMode)
	end
end

-- Fires each time after addons were loaded and player is ready to move (after each zone change too)
--[[
local function FCOLockpicker_Player_Activated(...)
	--Prevent this event to be fired again and again upon each zone change
	EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_PLAYER_ACTIVATED)

    debugMessage("[EVENT] Player activated", true)

	--Check if other Addons active
    --CheckIfOtherAddonsActive()

    --Minimize the chat window if the lockpicking starts
    --LOCK_PICK_SCENE:AddFragment(MINIMIZE_CHAT_FRAGMENT)

    addonVars.gAddonLoaded = false
end
]]

--==============================================================================
--===== HOOKS BEGIN ============================================================
--==============================================================================
--Create the hooks & pre-hooks
local function CreateHooks()

--======== LOCKPICK ================================================================
    if IsInGamepadPreferredMode() then
        ZO_PreHook(LOCK_PICK, "StartDepressingPin", FCOLockpicker_Lockpick_Chamber_OnMouseDown)
        ZO_PreHook(LOCK_PICK, "EndDepressingPin", 	FCOLockpicker_Lockpick_Chamber_OnMouseUp)
    else
        --PreHook the lockpick on mouse down function -> Lockpicking of a chamber started
        ZO_PreHook("ZO_Lockpick_OnMouseDown", 		FCOLockpicker_Lockpick_Chamber_OnMouseDown)
        --PreHook the lockpick on moues up function -> Lockpicking of a chamber stopped or all chambers are resolved
        ZO_PreHook("ZO_Lockpick_OnMouseUp", 		FCOLockpicker_Lockpick_Chamber_OnMouseUp)
    end
end

--Register the slash commands
local function RegisterSlashCommands()
    -- Register slash commands
	SLASH_COMMANDS["/fcolockpicker"] = command_handler
	SLASH_COMMANDS["/fcol"] 		 = command_handler
end

--Addon loads up
local function FCOLockpicker_Loaded(eventCode, addOnName)
	--Is this addon found?
	if(addOnName ~= addonName) then
        return
    end
	--Unregister this event again so it isn't fired again after this addon has beend reckognized
    EVENT_MANAGER:UnregisterForEvent(addonName .. "_EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED)

    debugMessage("[Addon loading begins...]", true)
	addonVars.gAddonLoaded = false

    --The default values for the language and save mode
    FCOLP.settingsVars.firstRunSettings = {
        language 	 		    = 1, --Standard: English
        saveMode     		    = 2, --Standard: Account wide FCOLP.settingsVars.settings
    }

    --Pre-set the deafult values
    FCOLP.settingsVars.defaults = {
		alwaysUseClientLanguage		= true,
        languageChoosen				= false,
        debug						= false,
        deepDebug					= false,
        warnings					= {
        	normal		= {
					valueMin = 999,
            		color = {
                    	r = 1,
                        g = 1,
                        b = 1,
                        a = 1,
                    },
            },
        	medium 		= {
					valueMin = 10,
            		color = {
                    	r = 0,
                        g = 1,
                        b = 1,
                        a = 1,
                    },
            },
            low 		= {
					valueMin = 5,
            		color = {
                    	r = 1,
                        g = 0,
                        b = 0,
                        a = 1,
                    },
            },
        },
        showChamberResolvedIcon = false,
        useSpringGreenColor = false,
    }

--=============================================================================================================
--	LOAD USER SETTINGS
--=============================================================================================================
    --Load the user's FCOLP.settingsVars.settings from SavedVariables file -> Account wide of basic version 999 at first
	FCOLP.settingsVars.defaultSettings = ZO_SavedVars:NewAccountWide(addonVars.addonSavedVariablesName, 999, "SettingsForAll", FCOLP.settingsVars.firstRunSettings)

	--Check, by help of basic version 999 FCOLP.settingsVars.settings, if the FCOLP.settingsVars.settings should be loaded for each character or account wide
    --Use the current addon version to read the FCOLP.settingsVars.settings now
	if (FCOLP.settingsVars.defaultSettings.saveMode == 1) then
    	FCOLP.settingsVars.settings = ZO_SavedVars:NewCharacterId(addonVars.addonSavedVariablesName, addonVars.addonVersion , "Settings", FCOLP.settingsVars.defaults )
	else
		FCOLP.settingsVars.settings = ZO_SavedVars:NewAccountWide(addonVars.addonSavedVariablesName, addonVars.addonVersion, "Settings", FCOLP.settingsVars.defaults)
	end
--=============================================================================================================

	-- Set Localization
    Localization()

	--Show the menu
	BuildAddonMenu()

	--Create the hooks
    CreateHooks()

    -- Register slash commands
    RegisterSlashCommands()

	--Register for the zone change/player ready event
--	EVENT_MANAGER:RegisterForEvent(addonName, EVENT_PLAYER_ACTIVATED, FCOLockpicker_Player_Activated)
	--Register the events for lockpicking
	EVENT_MANAGER:RegisterForEvent(addonName .. "_EVENT_ADD_ON_LOADED", EVENT_BEGIN_LOCKPICK, FCOLockpicker_OnBeginLockpick)

	LOCK_PICK_GAMEPAD_SCENE:RegisterCallback("StateChange", OnLockpickGamepadSceneStateChange)

    debugMessage("[Addon loading finished. Have fun!]", true)
    addonVars.gAddonLoaded = true
end

-- Register the event "addon loaded" for this addon
local function FCOLockpicker_Initialized()
	EVENT_MANAGER:RegisterForEvent(addonName .. "_EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED, FCOLockpicker_Loaded)
end


--------------------------------------------------------------------------------
--- Call the start function for this addon to register events etc.
--------------------------------------------------------------------------------
FCOLockpicker_Initialized()
