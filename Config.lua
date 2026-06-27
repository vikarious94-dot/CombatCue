local _, CombatState = ...

local configFrame
local fontSizeInput
local fontSizeSlider
local positionXInput
local positionYInput
local positionXSlider
local positionYSlider
local CommitInput

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

local function CreateFontSizeSlider(parent)
    fontSizeSlider = CreateFrame("Slider", "CombatStateFontSizeSlider", parent, "OptionsSliderTemplate")
    fontSizeSlider:SetSize(220, 20)
    fontSizeSlider:SetPoint("TOPLEFT", 18, -74)
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
    configFrame:SetSize(340, 330)
    configFrame:SetPoint("CENTER")
    configFrame:SetMovable(true)
    configFrame:EnableMouse(true)
    configFrame:RegisterForDrag("LeftButton")
    configFrame:SetScript("OnDragStart", configFrame.StartMoving)
    configFrame:SetScript("OnDragStop", configFrame.StopMovingOrSizing)
    configFrame:Hide()

    local title = configFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("LEFT", configFrame.TitleBg, "LEFT", 8, 0)
    title:SetText(L.title)

    local sizeLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sizeLabel:SetPoint("TOPLEFT", 18, -44)
    sizeLabel:SetText(L.fontSize)

    fontSizeInput = CreateNumberInput(configFrame, 54, function()
        return CombatStateDB.fontSize
    end, function(value)
        CombatState:SetFontSize(value)
    end)
    fontSizeInput:SetPoint("LEFT", sizeLabel, "RIGHT", 18, 0)

    CreateFontSizeSlider(configFrame)

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
    hint:SetPoint("TOPLEFT", positionYSlider, "BOTTOMLEFT", 0, -24)
    hint:SetWidth(300)
    hint:SetJustifyH("LEFT")
    hint:SetText(L.moveHint)

    local testButton = CreateButton(configFrame, L.test, 82, 24, "BOTTOMLEFT", configFrame, "BOTTOMLEFT", 18, 18)
    testButton:SetScript("OnClick", function()
        CombatState:UpdatePreview()
    end)

    local resetButton = CreateButton(configFrame, L.reset, 110, 24, "LEFT", testButton, "RIGHT", 8, 0)
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
