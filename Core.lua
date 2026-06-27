local ADDON_NAME, CombatState = ...

local eventFrame = CreateFrame("Frame")
local prefix = "|cff33ff99CombatState|r:"

local function Print(message)
    DEFAULT_CHAT_FRAME:AddMessage(prefix .. " " .. message)
end

local function OnEvent(_, event, addonName)
    if event == "ADDON_LOADED" then
        if addonName == ADDON_NAME then
            CombatState:EnsureDB()
            CombatState:ApplySettings()
            Print(CombatState.L.loaded)
        end
    elseif event == "PLAYER_REGEN_DISABLED" then
        CombatState:ShowAlert("++combat++", 1, 0.2, 0.2)
    elseif event == "PLAYER_REGEN_ENABLED" then
        CombatState:ShowAlert("--combat--", 0.2, 1, 0.2)
    end
end

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:SetScript("OnEvent", OnEvent)

SLASH_COMBATSTATE1 = "/combatstate"
SLASH_COMBATSTATE2 = "/cs"

SlashCmdList.COMBATSTATE = function()
    CombatState:ToggleConfig()
end
