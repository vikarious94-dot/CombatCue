local _, CombatState = ...

local alertFrame = CreateFrame("Frame", "CombatStateAlertFrame", UIParent)
alertFrame:SetSize(600, 100)
alertFrame:SetMovable(true)
alertFrame:RegisterForDrag("LeftButton")
alertFrame:Hide()

local alertText = alertFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
alertText:SetPoint("CENTER")

local hideToken = 0

CombatState.alertFrame = alertFrame
CombatState.alertText = alertText

function CombatState:ApplyAlertSettings()
    self:EnsureDB()

    alertFrame:ClearAllPoints()
    alertFrame:SetPoint("CENTER", UIParent, "CENTER", CombatStateDB.x, CombatStateDB.y)
    alertText:SetFont(STANDARD_TEXT_FONT, CombatStateDB.fontSize, "OUTLINE")
end

function CombatState:SaveAlertPosition()
    local centerX, centerY = alertFrame:GetCenter()
    local parentCenterX, parentCenterY = UIParent:GetCenter()

    if centerX and centerY and parentCenterX and parentCenterY then
        CombatStateDB.x = centerX - parentCenterX
        CombatStateDB.y = centerY - parentCenterY
    end

    self:ApplySettings()
end

function CombatState:SetConfigMode(enabled)
    alertFrame:EnableMouse(enabled)

    if enabled then
        alertFrame:SetScript("OnDragStart", alertFrame.StartMoving)
        alertFrame:SetScript("OnDragStop", function()
            alertFrame:StopMovingOrSizing()
            self:SaveAlertPosition()
        end)
    else
        alertFrame:SetScript("OnDragStart", nil)
        alertFrame:SetScript("OnDragStop", nil)
    end
end

function CombatState:ShowAlert(message, red, green, blue, alpha, keepVisible)
    hideToken = hideToken + 1

    alertText:SetText(message)
    alertText:SetTextColor(red, green, blue, alpha or 1)
    alertFrame:Show()

    if not keepVisible then
        local token = hideToken

        C_Timer.After(2, function()
            if token == hideToken and not self:IsConfigShown() then
                alertFrame:Hide()
            end
        end)
    end
end

function CombatState:UpdatePreview()
    self:PreviewEnterCombat()
end

function CombatState:PreviewEnterCombat()
    local color = self:GetCombatColor("enter")

    self:ShowAlert(CombatStateDB.enterCombatMessage, color.r, color.g, color.b, color.a, true)
end

function CombatState:PreviewLeaveCombat()
    local color = self:GetCombatColor("leave")

    self:ShowAlert(CombatStateDB.leaveCombatMessage, color.r, color.g, color.b, color.a, true)
end

function CombatState:HideAlert()
    alertFrame:Hide()
end
