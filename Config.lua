local _, CombatState = ...

local configFrame
local fontSizeInput
local fontSizeSlider
local positionXInput
local positionYInput
local enterCombatMessageInput
local leaveCombatMessageInput
local enterCombatColorSwatch
local leaveCombatColorSwatch
local positionXSlider
local positionYSlider
local CommitInput
local isRegisteredSpecialFrame = false
local DEFAULT_ENTER_COMBAT_COLOR = { r = 1, g = 0.2, b = 0.2, a = 1 }
local DEFAULT_LEAVE_COMBAT_COLOR = { r = 0.2, g = 1, b = 0.2, a = 1 }

local function CreateButton(parent, text, width, height, point, relativeTo, relativePoint, x, y)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width, height)
    button:SetPoint(point, relativeTo, relativePoint, x, y)
    button:SetText(text)

    return button
end

local function CreateNumberInput(parent, width, fallbackGetter, onCommit)
    local input = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    input:SetSize(width, 24)
    input:SetAutoFocus(false)
    input:SetJustifyH("CENTER")

    input:SetScript("OnEnterPressed", function()
        CommitInput(input, fallbackGetter(), onCommit)
    end)

    input:SetScript("OnEscapePressed", function()
        input:SetText(tostring(fallbackGetter()))
        input:ClearFocus()
    end)

    input:SetScript("OnEditFocusLost", function()
        CommitInput(input, fallbackGetter(), onCommit)
    end)

    return input
end

local function CreateTextInput(parent, width, fallbackGetter, onCommit)
    local input = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    input:SetSize(width, 24)
    input:SetAutoFocus(false)

    input:SetScript("OnEnterPressed", function()
        onCommit(input:GetText())
        input:ClearFocus()
    end)

    input:SetScript("OnEscapePressed", function()
        input:SetText(fallbackGetter())
        input:ClearFocus()
    end)

    input:SetScript("OnEditFocusLost", function()
        onCommit(input:GetText())
    end)

    return input
end

local function CreateColorSwatch(parent, onClick)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(22, 22)

    button.border = button:CreateTexture(nil, "BACKGROUND")
    button.border:SetAllPoints()
    button.border:SetColorTexture(0.05, 0.05, 0.05, 1)

    button.color = button:CreateTexture(nil, "ARTWORK")
    button.color:SetPoint("TOPLEFT", 3, -3)
    button.color:SetPoint("BOTTOMRIGHT", -3, 3)

    button.highlight = button:CreateTexture(nil, "HIGHLIGHT")
    button.highlight:SetAllPoints(button.color)
    button.highlight:SetColorTexture(1, 1, 1, 0.2)

    button:SetScript("OnClick", onClick)

    return button
end

local function SetSliderValue(slider, value)
    if slider and slider:GetValue() ~= value then
        slider:SetValue(value)
    end
end

local function SetInputValue(input, value)
    if input and not input:HasFocus() then
        input:SetText(tostring(math.floor(value + 0.5)))
    end
end

local function SetTextInputValue(input, value)
    if input and not input:HasFocus() then
        input:SetText(value)
    end
end

local function SetColorSwatchValue(swatch, color)
    if swatch then
        swatch.color:SetColorTexture(color.r, color.g, color.b, 1)
    end
end

local function Clamp(value, minValue, maxValue)
    return math.max(minValue, math.min(maxValue, value))
end

function CommitInput(input, fallbackValue, onCommit)
    local value = tonumber(input:GetText())

    if value then
        onCommit(math.floor(value + 0.5))
    else
        input:SetText(tostring(fallbackValue))
    end

    input:ClearFocus()
end

function CombatState:ApplyConfigSettings()
    SetInputValue(fontSizeInput, CombatStateDB.fontSize)
    SetInputValue(positionXInput, CombatStateDB.x)
    SetInputValue(positionYInput, CombatStateDB.y)
    SetTextInputValue(enterCombatMessageInput, CombatStateDB.enterCombatMessage)
    SetTextInputValue(leaveCombatMessageInput, CombatStateDB.leaveCombatMessage)
    SetColorSwatchValue(enterCombatColorSwatch, CombatStateDB.enterCombatColor)
    SetColorSwatchValue(leaveCombatColorSwatch, CombatStateDB.leaveCombatColor)
    SetSliderValue(fontSizeSlider, CombatStateDB.fontSize)
    SetSliderValue(positionXSlider, CombatStateDB.x)
    SetSliderValue(positionYSlider, CombatStateDB.y)
end

function CombatState:ApplySettings()
    self:EnsureDB()
    self:ApplyAlertSettings()
    self:ApplyConfigSettings()
end

function CombatState:SetFontSize(fontSize)
    self:EnsureDB()
    CombatStateDB.fontSize = Clamp(fontSize, 12, 96)
    self:ApplySettings()
    self:UpdatePreview()
end

function CombatState:SetPosition(axis, value)
    self:EnsureDB()

    if axis == "x" then
        CombatStateDB.x = Clamp(value, -1000, 1000)
    elseif axis == "y" then
        CombatStateDB.y = Clamp(value, -1000, 1000)
    end

    self:ApplySettings()
    self:UpdatePreview()
end

function CombatState:SetCombatMessage(messageType, message)
    self:EnsureDB()

    if message == "" then
        if messageType == "enter" then
            message = self.defaults.enterCombatMessage
        elseif messageType == "leave" then
            message = self.defaults.leaveCombatMessage
        end
    end

    if messageType == "enter" then
        CombatStateDB.enterCombatMessage = message
        self:ApplySettings()
        self:PreviewEnterCombat()
    elseif messageType == "leave" then
        CombatStateDB.leaveCombatMessage = message
        self:ApplySettings()
        self:PreviewLeaveCombat()
    end
end

function CombatState:SetCombatColor(messageType, red, green, blue, alpha)
    local color = self:GetCombatColor(messageType)

    color.r = Clamp(red, 0, 1)
    color.g = Clamp(green, 0, 1)
    color.b = Clamp(blue, 0, 1)
    color.a = Clamp(alpha or 1, 0, 1)

    self:ApplySettings()

    if messageType == "leave" then
        self:PreviewLeaveCombat()
    else
        self:PreviewEnterCombat()
    end
end

function CombatState:ResetCombatColor(messageType)
    local defaultColor = messageType == "leave" and DEFAULT_LEAVE_COMBAT_COLOR or DEFAULT_ENTER_COMBAT_COLOR

    self:SetCombatColor(messageType, defaultColor.r, defaultColor.g, defaultColor.b, defaultColor.a)
end

function CombatState:OpenCombatColorPicker(messageType)
    local color = self:GetCombatColor(messageType)
    local previousColor = { r = color.r, g = color.g, b = color.b, a = color.a }
    local usesModernColorPicker = ColorPickerFrame.SetupColorPickerAndShow ~= nil

    local function SetPickerColor(red, green, blue, alpha)
        if usesModernColorPicker and ColorPickerFrame.SetColorAlpha then
            ColorPickerFrame:SetColorAlpha(alpha)
        elseif usesModernColorPicker then
            ColorPickerFrame.opacity = alpha
        else
            ColorPickerFrame.opacity = 1 - alpha
        end

        if ColorPickerFrame.SetColorRGB then
            ColorPickerFrame:SetColorRGB(red, green, blue)
        end
    end

    local function GetPickerAlpha()
        if usesModernColorPicker and ColorPickerFrame.GetColorAlpha then
            return ColorPickerFrame:GetColorAlpha()
        end

        return 1 - (ColorPickerFrame.opacity or 0)
    end

    local function UpdateColor()
        local red, green, blue = ColorPickerFrame:GetColorRGB()
        local alpha = GetPickerAlpha()

        self:SetCombatColor(messageType, red, green, blue, alpha)
    end

    local function CancelColor()
        self:SetCombatColor(messageType, previousColor.r, previousColor.g, previousColor.b, previousColor.a)
    end

    if usesModernColorPicker then
        ColorPickerFrame:SetupColorPickerAndShow({
            r = color.r,
            g = color.g,
            b = color.b,
            opacity = color.a,
            hasOpacity = true,
            swatchFunc = UpdateColor,
            opacityFunc = UpdateColor,
            cancelFunc = CancelColor,
        })

        return
    end

    ColorPickerFrame.func = UpdateColor
    ColorPickerFrame.opacityFunc = UpdateColor
    ColorPickerFrame.cancelFunc = CancelColor
    ColorPickerFrame.hasOpacity = true
    ColorPickerFrame.opacity = 1 - color.a
    ColorPickerFrame.previousValues = previousColor
    ColorPickerFrame:SetColorRGB(color.r, color.g, color.b)
    ColorPickerFrame:Hide()
    ColorPickerFrame:Show()
end

local function CreateFontSizeSlider(parent, relativeTo)
    fontSizeSlider = CreateFrame("Slider", "CombatStateFontSizeSlider", parent, "OptionsSliderTemplate")
    fontSizeSlider:SetSize(220, 20)
    fontSizeSlider:SetPoint("TOPLEFT", relativeTo, "BOTTOMLEFT", 0, -18)
    fontSizeSlider:SetMinMaxValues(12, 96)
    fontSizeSlider:SetValueStep(1)
    fontSizeSlider:SetObeyStepOnDrag(true)

    _G[fontSizeSlider:GetName() .. "Low"]:SetText("12")
    _G[fontSizeSlider:GetName() .. "High"]:SetText("96")
    _G[fontSizeSlider:GetName() .. "Text"]:SetText("")

    fontSizeSlider:SetScript("OnValueChanged", function(_, value)
        CombatState:SetFontSize(math.floor(value + 0.5))
    end)
end

local function CreatePositionSlider(parent, name, label, input, point, relativeTo, relativePoint, x, y, axis)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetSize(220, 20)
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
        CombatState:SetPosition(axis, math.floor(value + 0.5))
    end)

    return slider
end

function CombatState:CreateConfigFrame()
    if configFrame then
        return
    end

    local L = self.L

    configFrame = CreateFrame("Frame", "CombatStateConfigFrame", UIParent, "BasicFrameTemplateWithInset")
    configFrame:SetSize(380, 520)
    configFrame:SetPoint("CENTER")
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
    titleIcon:SetTexture("Interface\\AddOns\\CombatState\\Media\\Icon.tga")

    local title = configFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("LEFT", titleIcon, "RIGHT", 6, 0)
    title:SetText(L.title)

    local sizeLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sizeLabel:SetPoint("TOPLEFT", 18, -244)
    sizeLabel:SetText(L.fontSize)

    local enterCombatMessageLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enterCombatMessageLabel:SetPoint("TOPLEFT", 18, -44)
    enterCombatMessageLabel:SetText(L.enterCombatMessage)

    enterCombatMessageInput = CreateTextInput(configFrame, 320, function()
        return CombatStateDB.enterCombatMessage
    end, function(value)
        CombatState:SetCombatMessage("enter", value)
    end)
    enterCombatMessageInput:SetPoint("TOPLEFT", enterCombatMessageLabel, "BOTTOMLEFT", 0, -6)

    local leaveCombatMessageLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    leaveCombatMessageLabel:SetPoint("TOPLEFT", enterCombatMessageInput, "BOTTOMLEFT", 0, -12)
    leaveCombatMessageLabel:SetText(L.leaveCombatMessage)

    leaveCombatMessageInput = CreateTextInput(configFrame, 320, function()
        return CombatStateDB.leaveCombatMessage
    end, function(value)
        CombatState:SetCombatMessage("leave", value)
    end)
    leaveCombatMessageInput:SetPoint("TOPLEFT", leaveCombatMessageLabel, "BOTTOMLEFT", 0, -6)

    local enterCombatColorLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enterCombatColorLabel:SetPoint("TOPLEFT", leaveCombatMessageInput, "BOTTOMLEFT", 0, -16)
    enterCombatColorLabel:SetWidth(100)
    enterCombatColorLabel:SetJustifyH("LEFT")
    enterCombatColorLabel:SetText(L.enterCombatColor)

    enterCombatColorSwatch = CreateColorSwatch(configFrame, function()
        CombatState:OpenCombatColorPicker("enter")
    end)
    enterCombatColorSwatch:SetPoint("LEFT", enterCombatColorLabel, "RIGHT", 8, 0)

    local resetEnterCombatColorButton = CreateButton(configFrame, L.reset, 72, 22, "LEFT", enterCombatColorSwatch, "RIGHT", 12, 0)
    resetEnterCombatColorButton:SetScript("OnClick", function()
        CombatState:ResetCombatColor("enter")
    end)

    local leaveCombatColorLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    leaveCombatColorLabel:SetPoint("TOPLEFT", enterCombatColorLabel, "BOTTOMLEFT", 0, -8)
    leaveCombatColorLabel:SetWidth(100)
    leaveCombatColorLabel:SetJustifyH("LEFT")
    leaveCombatColorLabel:SetText(L.leaveCombatColor)

    leaveCombatColorSwatch = CreateColorSwatch(configFrame, function()
        CombatState:OpenCombatColorPicker("leave")
    end)
    leaveCombatColorSwatch:SetPoint("CENTER", enterCombatColorSwatch, "CENTER", 0, -30)

    local resetLeaveCombatColorButton = CreateButton(configFrame, L.reset, 72, 22, "CENTER", resetEnterCombatColorButton, "CENTER", 0, -30)
    resetLeaveCombatColorButton:SetScript("OnClick", function()
        CombatState:ResetCombatColor("leave")
    end)

    fontSizeInput = CreateNumberInput(configFrame, 54, function()
        return CombatStateDB.fontSize
    end, function(value)
        CombatState:SetFontSize(value)
    end)
    fontSizeInput:SetPoint("LEFT", sizeLabel, "RIGHT", 18, 0)

    CreateFontSizeSlider(configFrame, sizeLabel)

    positionXInput = CreateNumberInput(configFrame, 64, function()
        return CombatStateDB.x
    end, function(value)
        CombatState:SetPosition("x", value)
    end)
    positionXSlider = CreatePositionSlider(
        configFrame,
        "CombatStatePositionXSlider",
        L.positionX,
        positionXInput,
        "TOPLEFT",
        fontSizeSlider,
        "BOTTOMLEFT",
        0,
        -36,
        "x"
    )

    positionYInput = CreateNumberInput(configFrame, 64, function()
        return CombatStateDB.y
    end, function(value)
        CombatState:SetPosition("y", value)
    end)
    positionYSlider = CreatePositionSlider(
        configFrame,
        "CombatStatePositionYSlider",
        L.positionY,
        positionYInput,
        "TOPLEFT",
        positionXSlider,
        "BOTTOMLEFT",
        0,
        -36,
        "y"
    )

    local hint = configFrame:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    hint:SetPoint("TOPLEFT", positionYSlider, "BOTTOMLEFT", 0, -18)
    hint:SetWidth(340)
    hint:SetJustifyH("LEFT")
    hint:SetText(L.moveHint)

    local previewEnterButton = CreateButton(configFrame, L.previewEnter, 112, 24, "BOTTOMLEFT", configFrame, "BOTTOMLEFT", 18, 50)
    previewEnterButton:SetScript("OnClick", function()
        CombatState:PreviewEnterCombat()
    end)

    local previewLeaveButton = CreateButton(configFrame, L.previewLeave, 112, 24, "LEFT", previewEnterButton, "RIGHT", 8, 0)
    previewLeaveButton:SetScript("OnClick", function()
        CombatState:PreviewLeaveCombat()
    end)

    local resetButton = CreateButton(configFrame, L.reset, 110, 24, "BOTTOMLEFT", configFrame, "BOTTOMLEFT", 18, 18)
    resetButton:SetScript("OnClick", function()
        CombatState:ResetDB()
        CombatState:ApplySettings()
        CombatState:UpdatePreview()
    end)

    local closeButton = CreateButton(configFrame, L.close, 82, 24, "BOTTOMRIGHT", configFrame, "BOTTOMRIGHT", -18, 18)
    closeButton:SetScript("OnClick", function()
        configFrame:Hide()
    end)

    configFrame:SetScript("OnShow", function()
        CombatState:ApplySettings()
        CombatState:SetConfigMode(true)
        CombatState:UpdatePreview()
    end)

    configFrame:SetScript("OnHide", function()
        CombatState:SetConfigMode(false)
        CombatState:HideAlert()
    end)
end

function CombatState:IsConfigShown()
    return configFrame and configFrame:IsShown()
end

function CombatState:ToggleConfig()
    self:CreateConfigFrame()

    if configFrame:IsShown() then
        configFrame:Hide()
    else
        configFrame:Show()
    end
end
