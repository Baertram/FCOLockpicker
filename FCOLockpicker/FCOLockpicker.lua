------------------------------------------------------------------
--FCOLockpicker.lua
--Author: Baertram
------------------------------------------------------------------

--Global addon variable
FCOLP = {}
local FCOLP = FCOLP

--Local game global speed up variables
local CM = CALLBACK_MANAGER
local EM = EVENT_MANAGER
local iigpm = IsInGamepadPreferredMode
local gnll = GetNumLockpicksLeft
local ics = IsChamberSolved
local gscs = GetSettingChamberStress


--Addon variables
FCOLP.addonVars                            = {}
FCOLP.addonVars.gAddonName                 = "FCOLockpicker"
FCOLP.addonVars.addonNameMenu              = "FCO Lockpicker"
FCOLP.addonVars.addonNameMenuDisplay       = "|c00FF00FCO |cFFFF00Lockpicker|r"
FCOLP.addonVars.addonAuthor                = '|cFFFF00Baertram|r'
FCOLP.addonVars.addonVersionOptions        = '0.28' -- version shown in the settings panel
FCOLP.addonVars.addonSavedVariablesName    = "FCOLockpicker_Settings"
FCOLP.addonVars.addonSavedVariablesVersion = 0.01 -- Changing this will reset SavedVariables!
FCOLP.addonVars.gAddonLoaded               = false
local addonVars                            = FCOLP.addonVars
local addonName                            = addonVars.gAddonName

--Libraries
-- Create the addon settings menu
local LAM = LibAddonMenu2

--Original variables
local origChamberStressedSound = SOUNDS["LOCKPICKING_CHAMBER_STRESS"]
FCOLP.sounds = {}
if SOUNDS then
    for soundName, _ in pairs(SOUNDS) do
        if soundName ~= "NONE" and soundName ~= "LOCKPICKING_CHAMBER_STRESS" then
            table.insert(FCOLP.sounds, soundName)
        end
    end
    if #FCOLP.sounds > 0 then
        table.sort(FCOLP.sounds)
        table.insert(FCOLP.sounds, 1, "NONE")
		table.insert(FCOLP.sounds, 2, "LOCKPICKING_CHAMBER_STRESS")
    end
end
if #FCOLP.sounds <= 0 then
    d("[FCOLockpicker] No sounds could be found!")
end

--Control names of ZO* standard controls etc.
FCOLP.zosVars                              = {}
local zosVars = FCOLP.zosVars
zosVars.LOCKPICKS_LEFT  = ZO_LockpickPanelInfoBarLockpicksLeft
local lockPicksLeftCtrl = zosVars.LOCKPICKS_LEFT
zosVars.LOCKPICK = LOCK_PICK
local lockPick = zosVars.LOCKPICK
local lockPickSprings = lockPick.springs
zosVars.LOCKPICK_GP_SCENE = LOCK_PICK_GAMEPAD_SCENE


--Settings
FCOLP.settingsVars					= {}
FCOLP.settingsVars.settings 		= {}
FCOLP.settingsVars.defaultSettings	= {}
local showChamberResolvedIcon

--Prevention booleans
FCOLP.preventerVars = {}
FCOLP.preventerVars.gLocalizationDone 					= false
FCOLP.preventerVars.gLockpickActive                  	= false
FCOLP.preventerVars.gOnLockpickChatStateWasMinimized 	= false
--[[
FCOLP.preventerVars.gOnLockpickChatStateWasMinimized = {
	["kb"] = false,
	["gp"] = false,
}
]]

--Number variables
FCOLP.numVars = {}
--Available languages
FCOLP.numVars.languageCount = 8 --English, German, French, Spanish, Italian, Japanese, Russian, Chinese
FCOLP.langVars = {}
FCOLP.langVars.languages = {}
local numVars = FCOLP.numVars
--Build the languages array
for i=1, numVars.languageCount do
	FCOLP.langVars.languages[i] = true
end

--Localization / translation
FCOLP.localizationVars = {}
FCOLP.localizationVars.FCOLP_loc = {}
local fcoLP_loc

--Uncolored "FCOLP" pre chat text for the chat output
FCOLP.preChatText = "FCOLockpicker"
local preChatText = FCOLP.preChatText
--Green colored "FCOLP" pre text for the chat output
FCOLP.preChatTextGreen = "|c22DD22"..preChatText.."|r "
--Red colored "FCOLP" pre text for the chat output
--FCOLP.preChatTextRed                     = "|cDD2222"..preChatText.."|r "
--Blue colored "FCOLP" pre text for the chat output
FCOLP.preChatTextBlue                    = "|c2222DD"..preChatText.."|r "
--local redText 	= FCOLP.preChatTextRed
local greenText = FCOLP.preChatTextGreen
local blueText 	= FCOLP.preChatTextBlue

--Local speed up variables
local chamberResolvedUniqueName = addonName .. "_LockPickChamberResolvedCheck"
local FCOLockpicker_chamberResolvedIcon
local chamberPinResolvedColor = 	{r=0, g=1, b=0, a=1} -- green chamber pin color
local chamberPinNotResolvedColor =	{r=1, g=1, b=1, a=1} -- normal chamber pin color

--===================== FUNCTIONS ==============================================

--Output debug message in chat
local function debugMessage(msg_text, deep)
	local settings = FCOLP.settingsVars.settings
	if deep and not settings.deepDebug then
    	return
    end
	if settings.debug == true then
    	if deep then
        	--Blue colored "FCOLockpicker" at the start of the string
	        d(blueText .. msg_text)
        else
        	--Green colored "FCOLockpicker" at the start of the string
	        d(greenText .. msg_text)
        end
	end
end

--[[
local function getGamepadOrKeyboardStr(gamePadMode)
	gamePadMode = gamePadMode or false
	local gpOrKbStr ={
		[true]  = "gp",
		[false] = "kb"
	}
	return gpOrKbStr[gamePadMode]
end
]]

local function checkAndRememberChatMinimizedState(gamePadMode, doNotMinimize)
	if gamePadMode == nil then gamePadMode = iigpm() end
	doNotMinimize = doNotMinimize or false
	--d(string.format("checkAndRememberChatMinimizedState - gamePadMode %s, doNotMinimize %s, gOnLockpickChatStateWasMinimized old: %s", tostring(gamePadMode), tostring(doNotMinimize), tostring(FCOLP.preventerVars.gOnLockpickChatStateWasMinimized)))
	--local gpOrKbStr = getGamepadOrKeyboardStr(gamePadMode)
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
	if gamePadMode == nil then gamePadMode = iigpm() end
	--local gpOrKbStr = getGamepadOrKeyboardStr(gamePadMode)

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
	local lockpicksLeft = gnll()
	local newColor
	local settings = FCOLP.settingsVars.settings
	local warnings = settings.warnings
	local lowWarn = warnings.low
	local mediumWarn = warnings.medium
	local normalWarn = warnings.normal
    if lockpicksLeft <= lowWarn.valueMin then
		newColor = lowWarn.color
    elseif lockpicksLeft <= mediumWarn.valueMin then
		newColor = mediumWarn.color
    else
		newColor = normalWarn.color
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

	--fix for PerfectPixel
	if PP ~= nil and lockpickTextCtrl ~= nil then
--d(">PP found!")
		local parentCtrl = ZO_LockpickPanel --lockpickTextCtrl:GetParent()
		if parentCtrl ~= nil then
--d(">>parent found, hidden: " ..tostring(parentCtrl:IsHidden()))
			--<Anchor point="LEFT" relativeTo="$(parent)LockLevel" relativePoint="RIGHT" offsetX="55" />
			lockpickTextCtrl:ClearAnchors()
			lockpickTextCtrl:SetAnchor(TOP, parentCtrl, TOP, 0, 75)
			lockpickTextCtrl:SetHidden(false)
		end
	end
end

local function FCOLockPicker_CreateLockpickChamberResolvedIcon()
	FCOLP.topLevelChamberResolvedIcon = CreateTopLevelWindow(addonName .. "_ChamberResolvedIcon", GuiRoot)
	local tlc = FCOLP.topLevelChamberResolvedIcon
	tlc:SetDimensions(240, 240)
	tlc:SetHidden(true)
	tlc:SetAnchor(CENTER, GuiRoot, CENTER)
	tlc:SetDrawLayer(DL_OVERLAY)
	tlc:SetDrawTier(DT_HIGH)
	tlc:SetDrawLevel(5)--high level to overlay others

	FCOLP.FCOLockpicker_chamberResolvedIconTexture = CreateControl(addonName .. "_ChamberResolvedIconTexture", tlc, CT_TEXTURE)
	local chamberResolvedTexture = FCOLP.FCOLockpicker_chamberResolvedIconTexture
	chamberResolvedTexture:SetAnchorFill()
	chamberResolvedTexture:SetTexture("/esoui/art/guild/guildheraldry_indexicon_finalize_down.dds")
	chamberResolvedTexture:SetColor(0, 1, 0, 1)
	chamberResolvedTexture:SetDrawLayer(DL_OVERLAY)
	chamberResolvedTexture:SetDrawTier(DT_HIGH)
    chamberResolvedTexture:SetDrawLevel(5) --high level to overlay others

	FCOLP.FCOLockpicker_chamberResolvedIcon = FCOLP.topLevelChamberResolvedIcon
	FCOLockpicker_chamberResolvedIcon = FCOLP.topLevelChamberResolvedIcon
end

local function FCOLockpicker_CheckLockpickChamberResolved()
	local settings = FCOLP.settingsVars.settings
	showChamberResolvedIcon = settings.showChamberResolvedIcon
	local useColors = settings.useSpringGreenColor
	if not showChamberResolvedIcon and not useColors then return false end

	--local isInGamepadMode = iigpm() and SCENE_MANAGER:IsShowing("lockpick_gamepad")
	local chamberIndex = lockPick.settingChamberIndex
	local chamberStress = gscs()
	local chamberSolved = ics(chamberIndex)
	--d("[FCOLP] CheckLockpickChamberResolved - gamepadMode: " .. tostring(isInGamepadMode) .. ", chamberStress: " .. tostring(chamberStress) .. ", chamberSolved: " .. tostring(chamberSolved) .. ", settingChamberIndex: " .. tostring(settingChamberIndex) .. ", closesIndexGamepad: " .. tostring(LOCK_PICK.closestChamberIndexToLockpick))

	local currentSpring = lockPickSprings[chamberIndex]
	if not currentSpring then return end
	--Check if the current lockpick chamber is resolved and change color + show "okay" icon
	local chamberWasResolved = (chamberStress > 0 and not chamberSolved) or false

	--Update the lockpick chamber resolved icon's visibility state
	if showChamberResolvedIcon == true then
		FCOLockpicker_chamberResolvedIcon:SetHidden(not chamberWasResolved)
	end

	--Update the chamber's spring color
	if useColors == true then
		local currentSpringPin = currentSpring.pin
		if not currentSpringPin then return end
		local chamberPinColor = (chamberWasResolved == true and chamberPinResolvedColor) or chamberPinNotResolvedColor
		currentSpringPin:SetColor(chamberPinColor.r, chamberPinColor.g, chamberPinColor.b, chamberPinColor.a)
	end
end

local function FCOLockpicker_Lockpick_Chamber_OnMouseDown()
	local settings = FCOLP.settingsVars.settings
	showChamberResolvedIcon = settings.showChamberResolvedIcon
	if not showChamberResolvedIcon and not settings.useSpringGreenColor then return end
	if showChamberResolvedIcon and not FCOLockpicker_chamberResolvedIcon then
		--Create the lockpick chamber resolved icon texture
    	FCOLockPicker_CreateLockpickChamberResolvedIcon()
    end
    --Check every 10 milliseconds if the lockpick chamber is resolved
	EM:RegisterForUpdate(chamberResolvedUniqueName, 15, FCOLockpicker_CheckLockpickChamberResolved)
	return false
end

local function FCOLockpicker_Lockpick_Chamber_OnMouseUp()
	--Unregister the repeated check
	EM:UnregisterForUpdate(chamberResolvedUniqueName)
	--Hide the lockpick chamber resolved icon again
	if showChamberResolvedIcon and FCOLockpicker_chamberResolvedIcon then
		FCOLockpicker_chamberResolvedIcon:SetHidden(true)
    end
	return false
end

local function Localization()
--d("[FCOLP] Localization - Start, useClientLang: " .. tostring(FCOLP.settingsVars.settings.alwaysUseClientLanguage))
	--Was localization already done during keybindings? Then abort here
 	if FCOLP.preventerVars.gLocalizationDone == true then return end
    --Fallback to english variable
    local fallbackToEnglish = false
	local settingsBase = FCOLP.settingsVars
	local settings = settingsBase.settings
	local defSettings = settingsBase.defaultSettings
	local defLang = defSettings.language

	--Always use the client's language?
    if not settings.alwaysUseClientLanguage then
		--Was a language chosen already?
	    if not settings.languageChosen then
--d("[FCOLP] Localization: Fallback to english. Language chosen: " .. tostring(FCOLP.settingsVars.settings.languageChosen) .. ", defaultLanguage: " .. tostring(FCOLP.settingsVars.defaultSettings.language))
			if defLang == nil then
--d("[FCOLP] Localization: defaultSettings.language is NIL -> Fallback to english now")
		    	fallbackToEnglish = true
		    else
				local languages = FCOLP.langVars.languages
				--Is the languages array filled and the language is not valid (not in the language array with the value "true")?
				if languages ~= nil and #languages > 0 and not languages[defLang] then
		        	fallbackToEnglish = true
--d("[FCOLP] Localization: defaultSettings.language is ~= " .. i .. ", and this language # is not valid -> Fallback to english now")
				end
		    end
		end
	end
--d("[FCOLP] localization, fallBackToEnglish: " .. tostring(fallbackToEnglish))
	--Fallback to english language now
    if (fallbackToEnglish) then
		FCOLP.settingsVars.defaultSettings.language = 1
		defLang = FCOLP.settingsVars.defaultSettings.language
	end
	--Is the standard language english set?
    if settings.alwaysUseClientLanguage or (defLang == 1 and not settings.languageChosen) then
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
	    elseif (lang == "zh") then
	    	FCOLP.settingsVars.defaultSettings.language = 8
		else
	    	FCOLP.settingsVars.defaultSettings.language = 1
	    end
	end
--d("[FCOLP] localization: default settings, language: " .. tostring(FCOLP.settingsVars.defaultSettings.language))
    --Get the localized texts from the localization file
    FCOLP.localizationVars.FCOLP_loc = FCOLP.localizationVars.localizationAll[FCOLP.settingsVars.defaultSettings.language]
	fcoLP_loc = FCOLP.localizationVars.FCOLP_loc
end

--Show a help inside the chat
local function help()
	d(fcoLP_loc["chatcommands_info"])
	d("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	d(fcoLP_loc["chatcommands_help"])
    d(fcoLP_loc["chatcommands_debug"])
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

	if #options == 0 or options[1] == "" or options[1] == "help" or options[1] == "hilfe" or options[1] == "aide" or options[1] == "list" then
		help()
	else
		local settings = FCOLP.settingsVars.settings
		if options[1] == "debug" then
			FCOLP.settingsVars.settings.debug = not FCOLP.settingsVars.settings.debug
			if settings.debug == true then
				d(fcoLP_loc["chatcommands_debug_on"])
			else
				FCOLP.settingsVars.settings.deepDebug = false
				d(fcoLP_loc["chatcommands_debug_off"])
			end
		elseif options[1] == "deepdebug" then
			FCOLP.settingsVars.settings.deepDebug = not FCOLP.settingsVars.settings.deepDebug
			if settings.deepDebug == true then
				FCOLP.settingsVars.settings.debug = true
				d(fcoLP_loc["chatcommands_deepdebug_on"])
			else
				FCOLP.settingsVars.settings.debug = false
				d(fcoLP_loc["chatcommands_deepdebug_off"])
			end
		end
	end
end

local function updateLockpickChamberStressedSound(idx, doPlaySound)
	if idx == nil then return end

	doPlaySound = doPlaySound or false
	local newLockpickChamberStressedSound
	if idx > 1 then
		if idx == 2 then
			newLockpickChamberStressedSound = origChamberStressedSound
		else
			local value = FCOLP.sounds[idx]
			newLockpickChamberStressedSound = SOUNDS[value]
		end
		if doPlaySound == true then PlaySound(newLockpickChamberStressedSound) end
	else
		newLockpickChamberStressedSound = SOUNDS["NONE"]
	end
	if newLockpickChamberStressedSound ~= nil and newLockpickChamberStressedSound ~= "" then
		SOUNDS["LOCKPICKING_CHAMBER_STRESS"] = newLockpickChamberStressedSound
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

--LAM 2.0 callback function if the panel was created
    local FCOLAMPanelCreated
	FCOLAMPanelCreated = function(panel)
        if panel ~= FCOLP.SettingsPanel then return end
        UpdateChamberStressedSoundDescription()
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
				updateLockpickChamberStressedSound(idx, true)
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
            type = "checkbox",
            name = fcoLP_loc["options_show_chamber_resolved_green_springs"],
            tooltip = fcoLP_loc["options_show_chamber_resolved_green_springs_tooltip"],
            getFunc = function() return settings.useSpringGreenColor end,
            setFunc = function(value)
                settings.useSpringGreenColor = value
            end,
            width="full",
            default = defaultSettings.useSpringGreenColor,
        },
	} -- END OF OPTIONS TABLE

	CM:RegisterCallback("LAM-PanelControlsCreated", FCOLAMPanelCreated)
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
	EM:UnregisterForEvent(addonName.. "_EVENT_LOCKPICK_FAILED", 	EVENT_LOCKPICK_FAILED)
	EM:UnregisterForEvent(addonName.. "_EVENT_LOCKPICK_SUCCESS", 	EVENT_LOCKPICK_SUCCESS)
	EM:UnregisterForEvent(addonName.. "_EVENT_LOCKPICK_BROKE", 		EVENT_LOCKPICK_BROKE)

    FCOLP.preventerVars.gLockpickActive = false
    debugMessage("Lockpicking ended", false)

	local settings = FCOLP.settingsVars.settings
	showChamberResolvedIcon = settings.showChamberResolvedIcon
	--Hide the lockpick chamber resolved icon again (independent to the settings)
	if FCOLockpicker_chamberResolvedIcon ~= nil then
		FCOLockpicker_chamberResolvedIcon:SetHidden(true)
		FCOLockpicker_chamberResolvedIcon:SetDimensions(0, 0)
    end

	--Springs were colored green? Reset them now
	if settings.useSpringGreenColor == true then
        --Colorize the springs normal again
        for i = 1, NUM_LOCKPICK_CHAMBERS, 1 do
			local lockPickSpringPin = lockPickSprings[i] and lockPickSprings[i].pin
            if lockPickSpringPin ~= nil then
                lockPickSpringPin:SetColor(chamberPinNotResolvedColor.r, chamberPinNotResolvedColor.g, chamberPinNotResolvedColor.b, chamberPinNotResolvedColor.a)
            end
        end
    end
	--Restore the chat state from before lockpicking
	chatStateRestore(nil)
end

--Event upon lockpick broke
local function FCOLockpicker_OnLockpickBroke(...)
    FCOLP.preventerVars.gLockpickActive = true
    debugMessage("Lockpick broke", false)

	FCOLockpicker_updateLockpicksLeftText(lockPicksLeftCtrl)
end

--Event upon begin of lockpicking
local function FCOLockpicker_OnBeginLockpick(...)
	--Gamepad mode
	--d(">[FCOLP]OnBeginLockPick-Chat minimized: " .. tostring(CHAT_SYSTEM:IsMinimized()))

	if showChamberResolvedIcon then
		if not FCOLockpicker_chamberResolvedIcon then
			--Create the lockpick chamber resolved icon texture
			FCOLockPicker_CreateLockpickChamberResolvedIcon()
		else
			FCOLockpicker_chamberResolvedIcon:SetDimensions(240, 240)
		end
	end

	--Remember chat minimized state, if not in gamepad mode. Will be done below in the lockpick scene state change, as
	--the gamepad will minimize the chat autoamtically already
	local gamePadMode = iigpm()
	--local isChatMinimized = CHAT_SYSTEM:IsMinimized()
	--d(string.format("FCOLockpicker_OnBeginLockpick - gamePadMode %s, isChatMinimized %s, stateMinimizedBefore %s", tostring(gamePadMode), tostring(isChatMinimized), tostring(FCOLP.preventerVars.gOnLockpickChatStateWasMinimized)))
	if not gamePadMode then
		checkAndRememberChatMinimizedState(gamePadMode)
	end

	FCOLP.preventerVars.gLockpickActive = true
	debugMessage("Lockpicking started", false)

	FCOLockpicker_updateLockpicksLeftText(lockPicksLeftCtrl)

	EM:RegisterForEvent(addonName .. "_EVENT_LOCKPICK_FAILED",	EVENT_LOCKPICK_FAILED, 	FCOLockpicker_OnEndLockpick)
	EM:RegisterForEvent(addonName .. "_EVENT_LOCKPICK_SUCCESS",	EVENT_LOCKPICK_SUCCESS, FCOLockpicker_OnEndLockpick)
	EM:RegisterForEvent(addonName .. "_EVENT_LOCKPICK_BROKE", 	EVENT_LOCKPICK_BROKE, 	FCOLockpicker_OnLockpickBroke)
end

--For gamepad mode only to detect the correct chat state
local function OnLockpickGamepadSceneStateChange(oldState, newState)
--d(">[FCOLP]OnLockpickGamepadSceneStateChange-newState: " ..tostring(newState) .. ", chat minimized: " .. tostring(CHAT_SYSTEM:IsMinimized()) ..", gamepadMode: " ..tostring(gamePadMode))
	if newState == SCENE_SHOWING then
		--TODO begin 1: Is this needed, as we are at a state change of the gamepad lockpick scene
		local gamePadMode = iigpm()
		if not gamePadMode then return end
		--TODO end 1
		checkAndRememberChatMinimizedState(gamePadMode, nil)
	end
end

-- Fires each time after addons were loaded and player is ready to move (after each zone change too)
--[[
local function FCOLockpicker_Player_Activated(...)
	--Prevent this event to be fired again and again upon each zone change
	EM:UnregisterForEvent(addonName, EVENT_PLAYER_ACTIVATED)

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
local hooksPerInputModeAdded = {
	[true] 	= false, --Gamepad mode
	[false] = false, --Keyboard mode
}

local function addHooksBasedOnInputMode(isGamepadMode)
	if isGamepadMode == nil then isGamepadMode = iigpm() end
	--Hooks for the input mode was not added yet? go on
	if not hooksPerInputModeAdded[isGamepadMode] then
		if isGamepadMode then
			--Gamepad mode
			zosVars.LOCKPICK_GP_SCENE:RegisterCallback("StateChange", OnLockpickGamepadSceneStateChange)
			ZO_PreHook(lockPick, "StartDepressingPin", 	FCOLockpicker_Lockpick_Chamber_OnMouseDown)
			ZO_PreHook(lockPick, "EndDepressingPin", 	FCOLockpicker_Lockpick_Chamber_OnMouseUp)
		else
			--Keyboard mode
			ZO_PreHook("ZO_Lockpick_OnMouseDown", 		FCOLockpicker_Lockpick_Chamber_OnMouseDown)
			ZO_PreHook("ZO_Lockpick_OnMouseUp", 		FCOLockpicker_Lockpick_Chamber_OnMouseUp)
		end
		hooksPerInputModeAdded[isGamepadMode] = true
		--Both hooks were added already cuz both input types were changed already? Unregister the event now
		if hooksPerInputModeAdded[true] == true and hooksPerInputModeAdded[false] == true then
			EM:UnregisterForEvent(addonName .. "_EVENT_INPUT_TYPE_CHANGED", EVENT_INPUT_TYPE_CHANGED)
		end
	end
end

local function onEventInputTypeChanged(eventId, isGamepad)
	addHooksBasedOnInputMode(isGamepad)
end

--Create the hooks & pre-hooks
local function CreateHooks()
--======== LOCKPICK hooks for the chamber resolved ================================================================
	--Initially setup for the currently used input mode
	addHooksBasedOnInputMode(nil)
	--React on an input mode change keyboard->gamepad->keyboard and register the needed hooks
	EM:RegisterForEvent(addonName .. "_EVENT_INPUT_TYPE_CHANGED", EVENT_INPUT_TYPE_CHANGED, onEventInputTypeChanged)
end

--Register the slash commands
local function RegisterSlashCommands()
    -- Register slash commands
	SLASH_COMMANDS["/fcolockpicker"] = command_handler
	SLASH_COMMANDS["/fcol"] 		 = command_handler
end

--Load the SavedVariables
local function LoadUserSettings()
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
		chamberStressedSound = 2, --"LOCKPICKING_CHAMBER_STRESS"
    }
	local defaults = FCOLP.settingsVars.defaults

	local worldName = GetWorldName()
	local addonSavedVariablesName = addonVars.addonSavedVariablesName
	local addonSavedVariablesVersion = addonVars.addonSavedVariablesVersion

--=============================================================================================================
--	LOAD USER SETTINGS
--=============================================================================================================
    --Load the user's FCOLP.settingsVars.settings from SavedVariables file -> Account wide of basic version 999 at first
	FCOLP.settingsVars.defaultSettings = ZO_SavedVars:NewAccountWide(addonSavedVariablesName, 999, "SettingsForAll", FCOLP.settingsVars.firstRunSettings, worldName)

	--Check, by help of basic version 999 FCOLP.settingsVars.settings, if the FCOLP.settingsVars.settings should be loaded for each character or account wide
    --Use the current addon version to read the FCOLP.settingsVars.settings now
	if (FCOLP.settingsVars.defaultSettings.saveMode == 1) then
    	FCOLP.settingsVars.settings = ZO_SavedVars:NewCharacterId(addonSavedVariablesName, addonSavedVariablesVersion, "Settings", defaults, worldName)
	else
		FCOLP.settingsVars.settings = ZO_SavedVars:NewAccountWide(addonSavedVariablesName, addonSavedVariablesVersion, "Settings", defaults, worldName, nil)
	end
--=============================================================================================================
	showChamberResolvedIcon = FCOLP.settingsVars.settings.showChamberResolvedIcon
end

--Addon loads up
local function FCOLockpicker_Loaded(eventCode, addOnNameOfEachAddonLoaded)
	--Is this addon found?
	if addOnNameOfEachAddonLoaded ~= addonName then return end
	--Unregister this event again so it isn't fired again after this addon has beend reckognized
    EM:UnregisterForEvent(addonName .. "_EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED)

    debugMessage("[Addon loading begins...]", true)
	addonVars.gAddonLoaded = false

	--SavedVariables
    LoadUserSettings()

	--Update the lockpick chamber stressed sound, silently
	updateLockpickChamberStressedSound(FCOLP.settingsVars.settings.chamberStressedSound, false)

	-- Set Localization
    Localization()

	--Show the menu
	BuildAddonMenu()

	--Create the hooks
    CreateHooks()

    -- Register slash commands
    RegisterSlashCommands()

	--Register for the zone change/player ready event
--	EM:RegisterForEvent(addonName, EVENT_PLAYER_ACTIVATED, FCOLockpicker_Player_Activated)
	--Register the events for lockpicking
	EM:RegisterForEvent(addonName .. "_EVENT_ADD_ON_LOADED", EVENT_BEGIN_LOCKPICK, FCOLockpicker_OnBeginLockpick)

    debugMessage("[Addon loading finished. Have fun!]", true)
    addonVars.gAddonLoaded = true
end

-- Register the event "addon loaded" for this addon
local function FCOLockpicker_Initialized()
	EM:RegisterForEvent(addonName .. "_EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED, FCOLockpicker_Loaded)
end


--------------------------------------------------------------------------------
--- Call the start function for this addon to register events etc.
--------------------------------------------------------------------------------
FCOLockpicker_Initialized()
