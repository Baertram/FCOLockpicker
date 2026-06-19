------------------------------------------------------------------
-- pc/Initialize.lua
------------------------------------------------------------------

local FCOLP = FCOLP
local addonName = FCOLP.addonVars.gAddonName
local EM = EVENT_MANAGER

local eventName_PC = addonName .. "_EVENT_ADD_ON_LOADED-PC"

local function FCOLockpicker_OnPCAddOnLoaded(eventCode, addOnNameOfEachAddonLoaded)
    if addOnNameOfEachAddonLoaded ~= addonName then return end
    EM:UnregisterForEvent(eventName_PC, EVENT_ADD_ON_LOADED)

    FCOLP.OnAddonLoaded()
    FCOLP.CreatePCSettings()
end

EM:RegisterForEvent(eventName_PC, EVENT_ADD_ON_LOADED, FCOLockpicker_OnPCAddOnLoaded)
