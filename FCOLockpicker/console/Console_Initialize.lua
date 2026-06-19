------------------------------------------------------------------
-- console/Initialize.lua
------------------------------------------------------------------

local FCOLP = FCOLP
local addonName = FCOLP.addonVars.gAddonName
local EM = EVENT_MANAGER

local eventName_Console = addonName .. "_EVENT_ADD_ON_LOADED-Console"

local function FCOLockpicker_OnConsoleAddOnLoaded(eventCode, addOnNameOfEachAddonLoaded)
    if addOnNameOfEachAddonLoaded ~= addonName then return end
    EM:UnregisterForEvent(eventName_Console, EVENT_ADD_ON_LOADED)

    FCOLP.OnAddonLoaded()
    FCOLP.CreateConsoleSettings()
end

EM:RegisterForEvent(eventName_Console, EVENT_ADD_ON_LOADED, FCOLockpicker_OnConsoleAddOnLoaded)
