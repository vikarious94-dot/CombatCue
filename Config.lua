local _, CombatCue = ...

local configFrame
local settingsCategory
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
local isApplyingConfigSettings = false

local function GetAnimationStyleText(style)
    local L = CombatCue.L

    if style == "scale" then
        return L.animationStyleScale
    elseif style == "flash" then
        return L.animationStyleFlash
    end

    return L.animationStyleFade
end

local function StyleSectionTitle(parent, title)
    local band = parent:CreateTexture(nil, "BACKGROUND")
    band:SetPoint("TOPLEFT", title, "TOPLEFT", -4, 6)
    band:SetPoint("RIGHT", parent, "RIGHT", -16, 0)
    band:SetHeight(24)
    band:SetColorTexture(0, 0, 0, 0.22)

    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
    line:SetPoint("RIGHT", parent, "RIGHT", -24, 0)
    line:SetHeight(1)
    line:SetColorTexture(1, 0.82, 0.18, 0.45)
end

local function CreateSectionTitle(parent, text, y)
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, y)
    title:SetText(text)

    StyleSectionTitle(parent, title)

    return title
end

local function CreateSectionTitleBelow(parent, text, relativeTo, y)
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", relativeTo, "BOTTOMLEFT", 0, y)
    title:SetText(text)

    StyleSectionTitle(parent, title)

    return title
end

local function CreateFieldLabel(parent, text, relativeTo, y)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", relativeTo, "BOTTOMLEFT", 0, y)
    label:SetText(text)

    return label
end

local function CreateFontSizeSlider(parent, relativeTo)
    fontSizeSlider = CreateFrame("Slider", "CombatCueFontSizeSlider", parent, "OptionsSliderTemplate")
    fontSizeSlider:SetSize(260, 20)
    fontSizeSlider:SetPoint("TOPLEFT", relativeTo, "BOTTOMLEFT", 0, -18)
    fontSizeSlider:SetMinMaxValues(12, 96)
    fontSizeSlider:SetValueStep(1)
    fontSizeSlider:SetObeyStepOnDrag(true)

    _G[fontSizeSlider:GetName() .. "Low"]:SetText("12")
    _G[fontSizeSlider:GetName() .. "High"]:SetText("96")
    _G[fontSizeSlider:GetName() .. "Text"]:SetText("")

    fontSizeSlider:SetScript("OnValueChanged", function(_, value)
        if isApplyingConfigSettings then
            return
        end

        CombatCue:SetFontSize(math.floor(value + 0.5))
    end)
end

local function CreatePositionSlider(parent, name, label, input, point, relativeTo, relativePoint, x, y, axis)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetSize(260, 20)
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
        if isApplyingConfigSettings then
            return
        end

        CombatCue:SetPosition(axis, math.floor(value + 0.5))
    end)

    return slider
end

local function CreateDecimalSlider(parent, name, label, input, point, relativeTo, relativePoint, x, y, minValue, maxValue, step, onValueChanged)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetSize(260, 20)
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
        if isApplyingConfigSettings then
            return
        end

        onValueChanged(math.floor((value / step) + 0.5) * step)
    end)

    return slider
end

local function OpenSettingsCategory()
    if not settingsCategory or not Settings or not Settings.OpenToCategory then
        return false
    end

    local categoryID = settingsCategory.GetID and settingsCategory:GetID() or settingsCategory.ID

    if not categoryID then
        return false
    end

    Settings.OpenToCategory(categoryID)

    return true
end

local function CloseSettingsPanel()
    if SettingsPanel and SettingsPanel:IsShown() then
        if HideUIPanel then
            HideUIPanel(SettingsPanel)
        else
            SettingsPanel:Hide()
        end
    end
end

function CombatCue:ApplyConfigSettings()
    isApplyingConfigSettings = true

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

    isApplyingConfigSettings = false
end

function CombatCue:ApplySettings()
    self:EnsureDB()
    self:ApplyAlertSettings()
    self:ApplyConfigSettings()
end

function CombatCue:CreateConfigFrame()
    if configFrame then
        return
    end

    local L = self.L

    configFrame = CreateFrame("Frame", "CombatCueSettingsPanel")
    configFrame:SetSize(560, 620)

    local scrollFrame = CreateFrame("ScrollFrame", "CombatCueSettingsScrollFrame", configFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 0, -4)
    scrollFrame:SetPoint("BOTTOMRIGHT", configFrame, "BOTTOMRIGHT", -28, 4)

    local contentFrame = CreateFrame("Frame", "CombatCueSettingsContent", scrollFrame)
    contentFrame:SetSize(430, 1080)
    scrollFrame:SetScrollChild(contentFrame)

    local icon = contentFrame:CreateTexture(nil, "ARTWORK")
    icon:SetSize(36, 36)
    icon:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 20, -18)
    icon:SetTexture("Interface\\AddOns\\CombatCue\\Media\\Icon.tga")

    local title = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 12, -2)
    title:SetText(L.title)

    local subtitle = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
    subtitle:SetText(L.subtitle)

    local messagesTitle = CreateSectionTitle(contentFrame, L.tabMessages, -76)

    local enterCombatMessageLabel = CreateFieldLabel(contentFrame, L.enterCombatMessage, messagesTitle, -14)
    enterCombatMessageInput = self:CreateTextInput(contentFrame, 320, function()
        return CombatCueDB.enterCombatMessage
    end, function(value)
        CombatCue:SetCombatMessage("enter", value)
    end)
    enterCombatMessageInput:SetPoint("TOPLEFT", enterCombatMessageLabel, "BOTTOMLEFT", 0, -6)

    local leaveCombatMessageLabel = CreateFieldLabel(contentFrame, L.leaveCombatMessage, enterCombatMessageInput, -16)
    leaveCombatMessageInput = self:CreateTextInput(contentFrame, 320, function()
        return CombatCueDB.leaveCombatMessage
    end, function(value)
        CombatCue:SetCombatMessage("leave", value)
    end)
    leaveCombatMessageInput:SetPoint("TOPLEFT", leaveCombatMessageLabel, "BOTTOMLEFT", 0, -6)

    local appearanceTitle = CreateSectionTitleBelow(contentFrame, L.tabAppearance, leaveCombatMessageInput, -44)

    local enterCombatColorLabel = CreateFieldLabel(contentFrame, L.enterCombatColor, appearanceTitle, -14)
    enterCombatColorLabel:SetWidth(82)
    enterCombatColorLabel:SetJustifyH("LEFT")

    enterCombatColorSwatch = self:CreateColorSwatch(contentFrame, function()
        CombatCue:OpenCombatColorPicker("enter")
    end)
    enterCombatColorSwatch:SetPoint("LEFT", enterCombatColorLabel, "RIGHT", 8, 0)

    local resetEnterCombatColorButton = self:CreateButton(contentFrame, L.reset, 72, 22, "LEFT", enterCombatColorSwatch, "RIGHT", 16, 0)
    resetEnterCombatColorButton:SetScript("OnClick", function()
        CombatCue:ResetCombatColor("enter")
    end)

    local leaveCombatColorLabel = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    leaveCombatColorLabel:SetPoint("TOPLEFT", enterCombatColorLabel, "BOTTOMLEFT", 0, -12)
    leaveCombatColorLabel:SetWidth(82)
    leaveCombatColorLabel:SetJustifyH("LEFT")
    leaveCombatColorLabel:SetText(L.leaveCombatColor)

    leaveCombatColorSwatch = self:CreateColorSwatch(contentFrame, function()
        CombatCue:OpenCombatColorPicker("leave")
    end)
    leaveCombatColorSwatch:SetPoint("CENTER", enterCombatColorSwatch, "CENTER", 0, -34)

    local resetLeaveCombatColorButton = self:CreateButton(contentFrame, L.reset, 72, 22, "CENTER", resetEnterCombatColorButton, "CENTER", 0, -34)
    resetLeaveCombatColorButton:SetScript("OnClick", function()
        CombatCue:ResetCombatColor("leave")
    end)

    local sizeLabel = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sizeLabel:SetPoint("TOPLEFT", leaveCombatColorLabel, "BOTTOMLEFT", 0, -26)
    sizeLabel:SetText(L.fontSize)

    fontSizeInput = self:CreateNumberInput(contentFrame, 54, function()
        return CombatCueDB.fontSize
    end, function(value)
        CombatCue:SetFontSize(value)
    end)
    fontSizeInput:SetPoint("LEFT", sizeLabel, "RIGHT", 18, 0)

    CreateFontSizeSlider(contentFrame, sizeLabel)

    local animationTitle = CreateSectionTitleBelow(contentFrame, L.tabAnimation, fontSizeSlider, -54)

    animationEnabledCheckbox = self:CreateCheckbox(contentFrame, L.animationEnabled, function(checked)
        CombatCue:SetAnimationEnabled(checked)
    end)
    animationEnabledCheckbox:SetPoint("TOPLEFT", animationTitle, "BOTTOMLEFT", -4, -12)

    local animationStyleLabel = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    animationStyleLabel:SetPoint("TOPLEFT", animationEnabledCheckbox, "BOTTOMLEFT", 4, -14)
    animationStyleLabel:SetText(L.animationStyle)

    local previousAnimationStyleButton = self:CreateButton(contentFrame, "<", 24, 24, "LEFT", animationStyleLabel, "RIGHT", 18, 0)
    previousAnimationStyleButton:SetScript("OnClick", function()
        CombatCue:CycleAnimationStyle(-1)
        CombatCue:PreviewEnterCombat(true)
    end)

    animationStyleButton = self:CreateButton(contentFrame, "", 140, 24, "LEFT", previousAnimationStyleButton, "RIGHT", 6, 0)
    animationStyleButton:SetScript("OnClick", function()
        CombatCue:CycleAnimationStyle()
        CombatCue:PreviewEnterCombat(true)
    end)

    local nextAnimationStyleButton = self:CreateButton(contentFrame, ">", 24, 24, "LEFT", animationStyleButton, "RIGHT", 6, 0)
    nextAnimationStyleButton:SetScript("OnClick", function()
        CombatCue:CycleAnimationStyle(1)
        CombatCue:PreviewEnterCombat(true)
    end)

    displayDurationInput = self:CreateDecimalInput(contentFrame, 54, function()
        return CombatCueDB.displayDuration
    end, function(value)
        CombatCue:SetDisplayDuration(value)
    end, 1)
    displayDurationSlider = CreateDecimalSlider(
        contentFrame,
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

    animationDurationInput = self:CreateDecimalInput(contentFrame, 54, function()
        return CombatCueDB.animationDuration
    end, function(value)
        CombatCue:SetAnimationDuration(value)
    end, 1)
    animationDurationSlider = CreateDecimalSlider(
        contentFrame,
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

    animationScaleInput = self:CreateDecimalInput(contentFrame, 54, function()
        return CombatCueDB.animationScale
    end, function(value)
        CombatCue:SetAnimationScale(value)
    end, 1)
    animationScaleSlider = CreateDecimalSlider(
        contentFrame,
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

    local positionTitle = CreateSectionTitleBelow(contentFrame, L.tabPosition, animationScaleSlider, -54)

    positionXInput = self:CreateNumberInput(contentFrame, 64, function()
        return CombatCueDB.x
    end, function(value)
        CombatCue:SetPosition("x", value)
    end)
    positionXSlider = CreatePositionSlider(
        contentFrame,
        "CombatCuePositionXSlider",
        L.positionX,
        positionXInput,
        "TOPLEFT",
        positionTitle,
        "BOTTOMLEFT",
        0,
        -34,
        "x"
    )

    positionYInput = self:CreateNumberInput(contentFrame, 64, function()
        return CombatCueDB.y
    end, function(value)
        CombatCue:SetPosition("y", value)
    end)
    positionYSlider = CreatePositionSlider(
        contentFrame,
        "CombatCuePositionYSlider",
        L.positionY,
        positionYInput,
        "TOPLEFT",
        positionXSlider,
        "BOTTOMLEFT",
        0,
        -40,
        "y"
    )

    local hint = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    hint:SetPoint("TOPLEFT", positionYSlider, "BOTTOMLEFT", 0, -18)
    hint:SetWidth(320)
    hint:SetJustifyH("LEFT")
    hint:SetText(L.moveHint)

    local previewEnterButton = self:CreateButton(contentFrame, L.previewEnter, 112, 24, "TOPLEFT", hint, "BOTTOMLEFT", 0, -18)
    previewEnterButton:SetScript("OnClick", function()
        CombatCue:PreviewEnterCombat(true)
    end)

    local previewLeaveButton = self:CreateButton(contentFrame, L.previewLeave, 112, 24, "LEFT", previewEnterButton, "RIGHT", 8, 0)
    previewLeaveButton:SetScript("OnClick", function()
        CombatCue:PreviewLeaveCombat(true)
    end)

    local resetButton = self:CreateButton(contentFrame, L.reset, 110, 24, "TOPLEFT", previewEnterButton, "BOTTOMLEFT", 0, -8)
    resetButton:SetScript("OnClick", function()
        CombatCue:ResetDB()
        CombatCue:ApplySettings()
        CombatCue:UpdatePreview()
    end)

    local movePreviewButton = self:CreateButton(contentFrame, L.movePreview, 140, 24, "LEFT", resetButton, "RIGHT", 8, 0)
    movePreviewButton:SetScript("OnClick", function()
        CombatCue:StartPreviewPlacement()
        CloseSettingsPanel()
    end)

    configFrame:SetScript("OnShow", function()
        CombatCue:ApplySettings()
        CombatCue:SetConfigMode(true)
        CombatCue:UpdatePreview()
    end)

    configFrame:SetScript("OnHide", function()
        if CombatCue:IsPreviewPlacementActive() then
            return
        end

        CombatCue:SetConfigMode(false)
        CombatCue:HideAlert()
    end)

    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        settingsCategory = Settings.RegisterCanvasLayoutCategory(configFrame, L.title)
        Settings.RegisterAddOnCategory(settingsCategory)
    end
end

function CombatCue:IsConfigShown()
    return configFrame and configFrame:IsShown()
end

function CombatCue:ToggleConfig()
    self:CreateConfigFrame()

    if self:IsPreviewPlacementActive() then
        self:StopPreviewPlacement()
    end

    if OpenSettingsCategory() then
        return
    end

    if configFrame:IsShown() then
        configFrame:Hide()
    else
        configFrame:Show()
    end
end
