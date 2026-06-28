local _, CombatCue = ...

local configFrame
local fontSizeInput
local fontSizeSlider
local positionXInput
local positionYInput
local enterCombatMessageInput
local leaveCombatMessageInput
local enterCombatColorSwatch
local leaveCombatColorSwatch
local animationEnabledCheckbox
local animationStyleButton
local displayDurationInput
local displayDurationSlider
local animationDurationInput
local animationDurationSlider
local animationScaleInput
local animationScaleSlider
local positionXSlider
local positionYSlider
local isRegisteredSpecialFrame = false
local tabButtons = {}
local tabFrames = {}
local activeConfigTab = "messages"

local function GetAnimationStyleText(style)
    local L = CombatCue.L

    if style == "scale" then
        return L.animationStyleScale
    elseif style == "flash" then
        return L.animationStyleFlash
    end

    return L.animationStyleFade
end

local function ShowConfigTab(tabName)
    activeConfigTab = tabName

    for name, frame in pairs(tabFrames) do
        if name == tabName then
            frame:Show()
        else
            frame:Hide()
        end
    end

    for name, button in pairs(tabButtons) do
        if name == tabName then
            button:SetButtonState("PUSHED", true)
        else
            button:SetButtonState("NORMAL", false)
        end
    end
end

function CombatCue:ApplyConfigSettings()
    self:SetInputValue(fontSizeInput, CombatCueDB.fontSize)
    self:SetInputValue(positionXInput, CombatCueDB.x)
    self:SetInputValue(positionYInput, CombatCueDB.y)
    self:SetTextInputValue(enterCombatMessageInput, CombatCueDB.enterCombatMessage)
    self:SetTextInputValue(leaveCombatMessageInput, CombatCueDB.leaveCombatMessage)
    self:SetColorSwatchValue(enterCombatColorSwatch, CombatCueDB.enterCombatColor)
    self:SetColorSwatchValue(leaveCombatColorSwatch, CombatCueDB.leaveCombatColor)
    self:SetDecimalInputValue(displayDurationInput, CombatCueDB.displayDuration, 1)
    self:SetDecimalInputValue(animationDurationInput, CombatCueDB.animationDuration, 1)
    self:SetDecimalInputValue(animationScaleInput, CombatCueDB.animationScale, 1)
    self:SetSliderValue(fontSizeSlider, CombatCueDB.fontSize)
    self:SetSliderValue(displayDurationSlider, CombatCueDB.displayDuration)
    self:SetSliderValue(animationDurationSlider, CombatCueDB.animationDuration)
    self:SetSliderValue(animationScaleSlider, CombatCueDB.animationScale)
    self:SetSliderValue(positionXSlider, CombatCueDB.x)
    self:SetSliderValue(positionYSlider, CombatCueDB.y)

    if animationEnabledCheckbox then
        animationEnabledCheckbox:SetChecked(CombatCueDB.animationEnabled)
    end

    if animationStyleButton then
        animationStyleButton:SetText(GetAnimationStyleText(CombatCueDB.animationStyle))
    end
end

function CombatCue:ApplySettings()
    self:EnsureDB()
    self:ApplyAlertSettings()
    self:ApplyConfigSettings()
end

local function CreateFontSizeSlider(parent, relativeTo)
    fontSizeSlider = CreateFrame("Slider", "CombatCueFontSizeSlider", parent, "OptionsSliderTemplate")
    fontSizeSlider:SetSize(300, 20)
    fontSizeSlider:SetPoint("TOPLEFT", relativeTo, "BOTTOMLEFT", 0, -18)
    fontSizeSlider:SetMinMaxValues(12, 96)
    fontSizeSlider:SetValueStep(1)
    fontSizeSlider:SetObeyStepOnDrag(true)

    _G[fontSizeSlider:GetName() .. "Low"]:SetText("12")
    _G[fontSizeSlider:GetName() .. "High"]:SetText("96")
    _G[fontSizeSlider:GetName() .. "Text"]:SetText("")

    fontSizeSlider:SetScript("OnValueChanged", function(_, value)
        CombatCue:SetFontSize(math.floor(value + 0.5))
    end)
end

local function CreatePositionSlider(parent, name, label, input, point, relativeTo, relativePoint, x, y, axis)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetSize(300, 20)
    slider:SetPoint(point, relativeTo, relativePoint, x, y)
    slider:SetMinMaxValues(-1000, 1000)
    slider:SetValueStep(1)
    slider:SetObeyStepOnDrag(true)

    _G[slider:GetName() .. "Low"]:SetText("-1000")
    _G[slider:GetName() .. "High"]:SetText("1000")
    _G[slider:GetName() .. "Text"]:SetText("")

    local labelText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelText:SetPoint("BOTTOMLEFT", slider, "TOPLEFT", 0, 4)
    labelText:SetText(label)

    input:SetPoint("LEFT", labelText, "RIGHT", 18, 0)

    slider:SetScript("OnValueChanged", function(_, value)
        CombatCue:SetPosition(axis, math.floor(value + 0.5))
    end)

    return slider
end

local function CreateDecimalSlider(parent, name, label, input, point, relativeTo, relativePoint, x, y, minValue, maxValue, step, onValueChanged)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetSize(300, 20)
    slider:SetPoint(point, relativeTo, relativePoint, x, y)
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)

    _G[slider:GetName() .. "Low"]:SetText(tostring(minValue))
    _G[slider:GetName() .. "High"]:SetText(tostring(maxValue))
    _G[slider:GetName() .. "Text"]:SetText("")

    local labelText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelText:SetPoint("BOTTOMLEFT", slider, "TOPLEFT", 0, 4)
    labelText:SetText(label)

    input:SetPoint("LEFT", labelText, "RIGHT", 18, 0)

    slider:SetScript("OnValueChanged", function(_, value)
        onValueChanged(math.floor((value / step) + 0.5) * step)
    end)

    return slider
end

function CombatCue:CreateConfigFrame()
    if configFrame then
        return
    end

    local L = self.L

    configFrame = CreateFrame("Frame", "CombatCueConfigFrame", UIParent, "BasicFrameTemplateWithInset")
    configFrame:SetSize(610, 610)
    configFrame:SetPoint("CENTER")
    configFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    configFrame:SetFrameLevel(100)
    configFrame:SetToplevel(true)
    configFrame:SetMovable(true)
    configFrame:EnableMouse(true)
    configFrame:RegisterForDrag("LeftButton")
    configFrame:SetScript("OnDragStart", configFrame.StartMoving)
    configFrame:SetScript("OnDragStop", configFrame.StopMovingOrSizing)
    configFrame:Hide()

    if not isRegisteredSpecialFrame then
        table.insert(UISpecialFrames, configFrame:GetName())
        isRegisteredSpecialFrame = true
    end

    local titleIcon = configFrame:CreateTexture(nil, "OVERLAY")
    titleIcon:SetSize(18, 18)
    titleIcon:SetPoint("LEFT", configFrame.TitleBg, "LEFT", 6, 0)
    titleIcon:SetTexture("Interface\\AddOns\\CombatCue\\Media\\Icon.tga")

    local title = configFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("CENTER", configFrame.TitleBg, "CENTER", 0, 0)
    title:SetText(L.title)

    local contentPanel = CreateFrame("Frame", nil, configFrame, "BackdropTemplate")
    contentPanel:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 18, -64)
    contentPanel:SetPoint("BOTTOMRIGHT", configFrame, "BOTTOMRIGHT", -18, 70)
    contentPanel:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 14,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    contentPanel:SetBackdropColor(0.06, 0.055, 0.045, 0.78)
    contentPanel:SetBackdropBorderColor(0.55, 0.55, 0.5, 0.9)

    local header = CreateFrame("Frame", nil, contentPanel, "BackdropTemplate")
    header:SetPoint("TOPLEFT", contentPanel, "TOPLEFT", 12, -10)
    header:SetPoint("TOPRIGHT", contentPanel, "TOPRIGHT", -12, -10)
    header:SetHeight(72)
    header:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    header:SetBackdropColor(0.02, 0.02, 0.018, 0.88)
    header:SetBackdropBorderColor(0.45, 0.45, 0.42, 0.85)

    local headerIcon = header:CreateTexture(nil, "ARTWORK")
    headerIcon:SetSize(48, 48)
    headerIcon:SetPoint("LEFT", header, "LEFT", 16, 0)
    headerIcon:SetTexture("Interface\\AddOns\\CombatCue\\Media\\Icon.tga")

    local headerTitle = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    headerTitle:SetPoint("TOPLEFT", headerIcon, "TOPRIGHT", 14, -8)
    headerTitle:SetText(L.title)

    local headerSubtitle = header:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    headerSubtitle:SetPoint("TOPLEFT", headerTitle, "BOTTOMLEFT", 0, -8)
    headerSubtitle:SetText(L.subtitle)

    local function CreateTab(name, label, relativeTo)
        local point = relativeTo and "LEFT" or "TOPLEFT"
        local relativePoint = relativeTo and "RIGHT" or "TOPLEFT"
        local x = relativeTo and 4 or 22
        local y = relativeTo and 0 or -36
        local button = self:CreateButton(configFrame, label, 132, 24, point, relativeTo or configFrame, relativePoint, x, y)

        button:SetScript("OnClick", function()
            ShowConfigTab(name)
        end)

        tabButtons[name] = button

        local frame = CreateFrame("Frame", nil, contentPanel)
        frame:SetPoint("TOPLEFT", contentPanel, "TOPLEFT", 24, -104)
        frame:SetPoint("BOTTOMRIGHT", contentPanel, "BOTTOMRIGHT", -24, 18)
        frame:Hide()
        tabFrames[name] = frame

        return button, frame
    end

    local messagesTabButton, messagesTab = CreateTab("messages", L.tabMessages)
    local appearanceTabButton, appearanceTab = CreateTab("appearance", L.tabAppearance, messagesTabButton)
    local animationTabButton, animationTab = CreateTab("animation", L.tabAnimation, appearanceTabButton)
    local _, positionTab = CreateTab("position", L.tabPosition, animationTabButton)

    local enterCombatMessageLabel = messagesTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enterCombatMessageLabel:SetPoint("TOPLEFT", 0, 0)
    enterCombatMessageLabel:SetText(L.enterCombatMessage)

    enterCombatMessageInput = self:CreateTextInput(messagesTab, 520, function()
        return CombatCueDB.enterCombatMessage
    end, function(value)
        CombatCue:SetCombatMessage("enter", value)
    end)
    enterCombatMessageInput:SetPoint("TOPLEFT", enterCombatMessageLabel, "BOTTOMLEFT", 0, -6)

    local leaveCombatMessageLabel = messagesTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    leaveCombatMessageLabel:SetPoint("TOPLEFT", enterCombatMessageInput, "BOTTOMLEFT", 0, -18)
    leaveCombatMessageLabel:SetText(L.leaveCombatMessage)

    leaveCombatMessageInput = self:CreateTextInput(messagesTab, 520, function()
        return CombatCueDB.leaveCombatMessage
    end, function(value)
        CombatCue:SetCombatMessage("leave", value)
    end)
    leaveCombatMessageInput:SetPoint("TOPLEFT", leaveCombatMessageLabel, "BOTTOMLEFT", 0, -6)

    local enterCombatColorLabel = appearanceTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enterCombatColorLabel:SetPoint("TOPLEFT", 0, 0)
    enterCombatColorLabel:SetWidth(100)
    enterCombatColorLabel:SetJustifyH("LEFT")
    enterCombatColorLabel:SetText(L.enterCombatColor)

    enterCombatColorSwatch = self:CreateColorSwatch(appearanceTab, function()
        CombatCue:OpenCombatColorPicker("enter")
    end)
    enterCombatColorSwatch:SetPoint("LEFT", enterCombatColorLabel, "RIGHT", 8, 0)

    local resetEnterCombatColorButton = self:CreateButton(appearanceTab, L.reset, 72, 22, "LEFT", enterCombatColorSwatch, "RIGHT", 12, 0)
    resetEnterCombatColorButton:SetScript("OnClick", function()
        CombatCue:ResetCombatColor("enter")
    end)

    local leaveCombatColorLabel = appearanceTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    leaveCombatColorLabel:SetPoint("TOPLEFT", enterCombatColorLabel, "BOTTOMLEFT", 0, -8)
    leaveCombatColorLabel:SetWidth(100)
    leaveCombatColorLabel:SetJustifyH("LEFT")
    leaveCombatColorLabel:SetText(L.leaveCombatColor)

    leaveCombatColorSwatch = self:CreateColorSwatch(appearanceTab, function()
        CombatCue:OpenCombatColorPicker("leave")
    end)
    leaveCombatColorSwatch:SetPoint("CENTER", enterCombatColorSwatch, "CENTER", 0, -30)

    local resetLeaveCombatColorButton = self:CreateButton(appearanceTab, L.reset, 72, 22, "CENTER", resetEnterCombatColorButton, "CENTER", 0, -30)
    resetLeaveCombatColorButton:SetScript("OnClick", function()
        CombatCue:ResetCombatColor("leave")
    end)

    local sizeLabel = appearanceTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sizeLabel:SetPoint("TOPLEFT", leaveCombatColorLabel, "BOTTOMLEFT", 0, -42)
    sizeLabel:SetText(L.fontSize)

    fontSizeInput = self:CreateNumberInput(appearanceTab, 54, function()
        return CombatCueDB.fontSize
    end, function(value)
        CombatCue:SetFontSize(value)
    end)
    fontSizeInput:SetPoint("LEFT", sizeLabel, "RIGHT", 18, 0)

    CreateFontSizeSlider(appearanceTab, sizeLabel)

    animationEnabledCheckbox = self:CreateCheckbox(animationTab, L.animationEnabled, function(checked)
        CombatCue:SetAnimationEnabled(checked)
    end)
    animationEnabledCheckbox:SetPoint("TOPLEFT", -4, 0)

    local animationStyleLabel = animationTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    animationStyleLabel:SetPoint("TOPLEFT", animationEnabledCheckbox, "BOTTOMLEFT", 4, -14)
    animationStyleLabel:SetText(L.animationStyle)

    animationStyleButton = self:CreateButton(animationTab, "", 96, 24, "LEFT", animationStyleLabel, "RIGHT", 18, 0)
    animationStyleButton:SetScript("OnClick", function()
        CombatCue:CycleAnimationStyle()
        CombatCue:PreviewEnterCombat(true)
    end)

    displayDurationInput = self:CreateDecimalInput(animationTab, 54, function()
        return CombatCueDB.displayDuration
    end, function(value)
        CombatCue:SetDisplayDuration(value)
    end, 1)
    displayDurationSlider = CreateDecimalSlider(
        animationTab,
        "CombatCueDisplayDurationSlider",
        L.displayDuration,
        displayDurationInput,
        "TOPLEFT",
        animationStyleLabel,
        "BOTTOMLEFT",
        0,
        -36,
        0.5,
        10,
        0.1,
        function(value)
            CombatCue:SetDisplayDuration(value)
        end
    )

    animationDurationInput = self:CreateDecimalInput(animationTab, 54, function()
        return CombatCueDB.animationDuration
    end, function(value)
        CombatCue:SetAnimationDuration(value)
    end, 1)
    animationDurationSlider = CreateDecimalSlider(
        animationTab,
        "CombatCueAnimationDurationSlider",
        L.animationDuration,
        animationDurationInput,
        "TOPLEFT",
        displayDurationSlider,
        "BOTTOMLEFT",
        0,
        -38,
        0.1,
        2,
        0.1,
        function(value)
            CombatCue:SetAnimationDuration(value)
        end
    )

    animationScaleInput = self:CreateDecimalInput(animationTab, 54, function()
        return CombatCueDB.animationScale
    end, function(value)
        CombatCue:SetAnimationScale(value)
    end, 1)
    animationScaleSlider = CreateDecimalSlider(
        animationTab,
        "CombatCueAnimationScaleSlider",
        L.animationScale,
        animationScaleInput,
        "TOPLEFT",
        animationDurationSlider,
        "BOTTOMLEFT",
        0,
        -38,
        1,
        2,
        0.1,
        function(value)
            CombatCue:SetAnimationScale(value)
        end
    )

    positionXInput = self:CreateNumberInput(positionTab, 64, function()
        return CombatCueDB.x
    end, function(value)
        CombatCue:SetPosition("x", value)
    end)
    positionXSlider = CreatePositionSlider(
        positionTab,
        "CombatCuePositionXSlider",
        L.positionX,
        positionXInput,
        "TOPLEFT",
        positionTab,
        "TOPLEFT",
        0,
        -20,
        "x"
    )

    positionYInput = self:CreateNumberInput(positionTab, 64, function()
        return CombatCueDB.y
    end, function(value)
        CombatCue:SetPosition("y", value)
    end)
    positionYSlider = CreatePositionSlider(
        positionTab,
        "CombatCuePositionYSlider",
        L.positionY,
        positionYInput,
        "TOPLEFT",
        positionXSlider,
        "BOTTOMLEFT",
        0,
        -36,
        "y"
    )

    local hint = positionTab:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    hint:SetPoint("TOPLEFT", positionYSlider, "BOTTOMLEFT", 0, -18)
    hint:SetWidth(340)
    hint:SetJustifyH("LEFT")
    hint:SetText(L.moveHint)

    local previewEnterButton = self:CreateButton(configFrame, L.previewEnter, 112, 24, "BOTTOMLEFT", configFrame, "BOTTOMLEFT", 18, 50)
    previewEnterButton:SetScript("OnClick", function()
        CombatCue:PreviewEnterCombat(true)
    end)

    local previewLeaveButton = self:CreateButton(configFrame, L.previewLeave, 112, 24, "LEFT", previewEnterButton, "RIGHT", 8, 0)
    previewLeaveButton:SetScript("OnClick", function()
        CombatCue:PreviewLeaveCombat(true)
    end)

    local resetButton = self:CreateButton(configFrame, L.reset, 110, 24, "BOTTOMLEFT", configFrame, "BOTTOMLEFT", 18, 18)
    resetButton:SetScript("OnClick", function()
        CombatCue:ResetDB()
        CombatCue:ApplySettings()
        CombatCue:UpdatePreview()
    end)

    local closeButton = self:CreateButton(configFrame, L.close, 82, 24, "BOTTOMRIGHT", configFrame, "BOTTOMRIGHT", -18, 18)
    closeButton:SetScript("OnClick", function()
        configFrame:Hide()
    end)

    ShowConfigTab(activeConfigTab)

    configFrame:SetScript("OnShow", function()
        CombatCue:ApplySettings()
        ShowConfigTab(activeConfigTab)
        CombatCue:SetConfigMode(true)
        CombatCue:UpdatePreview()
    end)

    configFrame:SetScript("OnHide", function()
        CombatCue:SetConfigMode(false)
        CombatCue:HideAlert()
    end)
end

function CombatCue:IsConfigShown()
    return configFrame and configFrame:IsShown()
end

function CombatCue:ToggleConfig()
    self:CreateConfigFrame()

    if configFrame:IsShown() then
        configFrame:Hide()
    else
        configFrame:Show()
    end
end
