local ADDON_NAME, CombatCue = ...

local eventFrame = CreateFrame("Frame")
local prefix = "|cff33ff99CombatCue|r:"

local function Print(message)
    DEFAULT_CHAT_FRAME:AddMessage(prefix .. " " .. message)
end

local function OnEvent(_, event, addonName)
    if event == "ADDON_LOADED" then
        if addonName == ADDON_NAME then
            CombatCue:EnsureDB()
            CombatCue:CreateConfigFrame()
            CombatCue:ApplySettings()
            Print(CombatCue.L.loaded)
        end
    elseif event == "PLAYER_REGEN_DISABLED" then
        local color = CombatCue:GetCombatColor("enter")

        CombatCue:ShowAlert(CombatCueDB.enterCombatMessage, color.r, color.g, color.b, color.a)
    elseif event == "PLAYER_REGEN_ENABLED" then
        local color = CombatCue:GetCombatColor("leave")

        CombatCue:ShowAlert(CombatCueDB.leaveCombatMessage, color.r, color.g, color.b, color.a)
    end
end

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:SetScript("OnEvent", OnEvent)

SLASH_COMBATCUE1 = "/combatcue"
SLASH_COMBATCUE2 = "/cc"
SLASH_COMBATCUE3 = "/cs"

SlashCmdList.COMBATCUE = function()
    CombatCue:ToggleConfig()
end
