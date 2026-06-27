local _, CombatCue = ...

local function CommitNumberInput(input, fallbackValue, onCommit)
    local value = tonumber(input:GetText())

    if value then
        onCommit(math.floor(value + 0.5))
    else
        input:SetText(tostring(fallbackValue))
    end

    input:ClearFocus()
end

local function CommitDecimalInput(input, fallbackValue, onCommit, decimals)
    local value = tonumber(input:GetText())

    if value then
        onCommit(value)
    else
        input:SetText(string.format("%." .. decimals .. "f", fallbackValue))
    end

    input:ClearFocus()
end

function CombatCue:CreateButton(parent, text, width, height, point, relativeTo, relativePoint, x, y)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width, height)
    button:SetPoint(point, relativeTo, relativePoint, x, y)
    button:SetText(text)

    return button
end

function CombatCue:CreateNumberInput(parent, width, fallbackGetter, onCommit)
    local input = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    input:SetSize(width, 24)
    input:SetAutoFocus(false)
    input:SetJustifyH("CENTER")

    input:SetScript("OnEnterPressed", function()
        CommitNumberInput(input, fallbackGetter(), onCommit)
    end)

    input:SetScript("OnEscapePressed", function()
        input:SetText(tostring(fallbackGetter()))
        input:ClearFocus()
    end)

    input:SetScript("OnEditFocusLost", function()
        CommitNumberInput(input, fallbackGetter(), onCommit)
    end)

    return input
end

function CombatCue:CreateDecimalInput(parent, width, fallbackGetter, onCommit, decimals)
    local input = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    input:SetSize(width, 24)
    input:SetAutoFocus(false)
    input:SetJustifyH("CENTER")

    input:SetScript("OnEnterPressed", function()
        CommitDecimalInput(input, fallbackGetter(), onCommit, decimals)
    end)

    input:SetScript("OnEscapePressed", function()
        input:SetText(string.format("%." .. decimals .. "f", fallbackGetter()))
        input:ClearFocus()
    end)

    input:SetScript("OnEditFocusLost", function()
        CommitDecimalInput(input, fallbackGetter(), onCommit, decimals)
    end)

    return input
end

function CombatCue:CreateTextInput(parent, width, fallbackGetter, onCommit)
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

function CombatCue:CreateColorSwatch(parent, onClick)
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

function CombatCue:CreateCheckbox(parent, label, onClick)
    local checkbox = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    checkbox:SetSize(24, 24)

    checkbox.label = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    checkbox.label:SetPoint("LEFT", checkbox, "RIGHT", 2, 0)
    checkbox.label:SetText(label)

    checkbox:SetHitRectInsets(0, -checkbox.label:GetStringWidth() - 4, 0, 0)
    checkbox:SetScript("OnClick", function(button)
        onClick(button:GetChecked())
    end)

    return checkbox
end

function CombatCue:SetSliderValue(slider, value)
    if slider and (not slider.CombatCueValueInitialized or slider:GetValue() ~= value) then
        slider.CombatCueValueInitialized = true
        slider:SetValue(value)
    end
end

function CombatCue:SetInputValue(input, value)
    if input and not input:HasFocus() then
        input:SetText(tostring(math.floor(value + 0.5)))
    end
end

function CombatCue:SetDecimalInputValue(input, value, decimals)
    if input and not input:HasFocus() then
        input:SetText(string.format("%." .. decimals .. "f", value))
    end
end

function CombatCue:SetTextInputValue(input, value)
    if input and not input:HasFocus() then
        input:SetText(value)
    end
end

function CombatCue:SetColorSwatchValue(swatch, color)
    if swatch then
        swatch.color:SetColorTexture(color.r, color.g, color.b, 1)
    end
end
