local _, CombatCue = ...

local alertFrame = CreateFrame("Frame", "CombatCueAlertFrame", UIParent)
alertFrame:SetSize(600, 100)
alertFrame:SetMovable(true)
alertFrame:RegisterForDrag("LeftButton")
alertFrame:Hide()

local alertText = alertFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
alertText:SetPoint("CENTER")

local hideToken = 0
local animationElapsed = 0
local activeDisplayDuration = 0
local activeAnimationDuration = 0
local activeAnimationStyle = "fade"
local activeAnimationScale = 1

CombatCue.alertFrame = alertFrame
CombatCue.alertText = alertText

function CombatCue:ApplyAlertSettings()
    self:EnsureDB()

    alertFrame:ClearAllPoints()
    alertFrame:SetPoint("CENTER", UIParent, "CENTER", CombatCueDB.x, CombatCueDB.y)
    alertText:SetFont(STANDARD_TEXT_FONT, CombatCueDB.fontSize, "OUTLINE")
end

local function Clamp(value, minValue, maxValue)
    return math.max(minValue, math.min(maxValue, value))
end

local function ApplyAnimationProgress(elapsed)
    local alpha = 1
    local scale = 1

    if activeAnimationStyle == "fade" then
        if elapsed < activeAnimationDuration then
            alpha = elapsed / activeAnimationDuration
        elseif elapsed > activeDisplayDuration - activeAnimationDuration then
            alpha = (activeDisplayDuration - elapsed) / activeAnimationDuration
        end
    elseif activeAnimationStyle == "scale" then
        if elapsed < activeAnimationDuration then
            local progress = elapsed / activeAnimationDuration

            scale = activeAnimationScale - ((activeAnimationScale - 1) * progress)
            alpha = progress
        elseif elapsed > activeDisplayDuration - activeAnimationDuration then
            alpha = (activeDisplayDuration - elapsed) / activeAnimationDuration
        end
    elseif activeAnimationStyle == "flash" and elapsed < activeAnimationDuration then
        alpha = elapsed % 0.16 < 0.08 and 1 or 0.35
    end

    alertFrame:SetAlpha(Clamp(alpha, 0, 1))
    alertText:SetScale(Clamp(scale, 1, 2))
end

local function StopAnimation()
    alertFrame:SetScript("OnUpdate", nil)
    alertFrame:SetAlpha(1)
    alertText:SetScale(1)
end

function CombatCue:SaveAlertPosition()
    local centerX, centerY = alertFrame:GetCenter()
    local parentCenterX, parentCenterY = UIParent:GetCenter()

    if centerX and centerY and parentCenterX and parentCenterY then
        CombatCueDB.x = centerX - parentCenterX
        CombatCueDB.y = centerY - parentCenterY
    end

    self:ApplySettings()
end

function CombatCue:SetConfigMode(enabled)
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

function CombatCue:ShowAlert(message, red, green, blue, alpha, keepVisible)
    hideToken = hideToken + 1

    StopAnimation()
    alertText:SetText(message)
    alertText:SetTextColor(red, green, blue, alpha or 1)
    alertFrame:Show()

    if keepVisible then
        return
    end

    local token = hideToken

    if not CombatCueDB.animationEnabled then
        C_Timer.After(CombatCueDB.displayDuration, function()
            if token == hideToken then
                alertFrame:Hide()
            end
        end)

        return
    end

    animationElapsed = 0
    activeDisplayDuration = CombatCueDB.displayDuration
    activeAnimationDuration = math.min(CombatCueDB.animationDuration, activeDisplayDuration / 2)
    activeAnimationStyle = CombatCueDB.animationStyle
    activeAnimationScale = CombatCueDB.animationScale
    ApplyAnimationProgress(0)

    alertFrame:SetScript("OnUpdate", function(_, elapsed)
        if token ~= hideToken then
            StopAnimation()
            return
        end

        animationElapsed = animationElapsed + elapsed

        if animationElapsed >= activeDisplayDuration then
            StopAnimation()
            alertFrame:Hide()
            return
        end

        ApplyAnimationProgress(animationElapsed)
    end)
end

function CombatCue:UpdatePreview()
    self:PreviewEnterCombat()
end

function CombatCue:PreviewEnterCombat(playAnimation)
    local color = self:GetCombatColor("enter")

    self:ShowAlert(CombatCueDB.enterCombatMessage, color.r, color.g, color.b, color.a, not playAnimation)
end

function CombatCue:PreviewLeaveCombat(playAnimation)
    local color = self:GetCombatColor("leave")

    self:ShowAlert(CombatCueDB.leaveCombatMessage, color.r, color.g, color.b, color.a, not playAnimation)
end

function CombatCue:HideAlert()
    StopAnimation()
    alertFrame:Hide()
end
