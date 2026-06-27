local _, CombatCue = ...

CombatCue.defaults = {
    fontSize = 32,
    x = 0,
    y = 180,
    enterCombatMessage = "++combat++",
    leaveCombatMessage = "--combat--",
    enterCombatColor = { r = 1, g = 0.2, b = 0.2, a = 1 },
    leaveCombatColor = { r = 0.2, g = 1, b = 0.2, a = 1 },
    animationEnabled = true,
    animationStyle = "fade",
    displayDuration = 2,
    animationDuration = 0.3,
    animationScale = 1.2,
}

local function CopyDefaultValue(value)
    if type(value) ~= "table" then
        return value
    end

    local copy = {}

    for key, nestedValue in pairs(value) do
        copy[key] = CopyDefaultValue(nestedValue)
    end

    return copy
end

function CombatCue:EnsureDB()
    CombatCueDB = CombatCueDB or {}

    for key, value in pairs(self.defaults) do
        if CombatCueDB[key] == nil then
            CombatCueDB[key] = CopyDefaultValue(value)
        elseif type(value) == "table" then
            if type(CombatCueDB[key]) ~= "table" then
                CombatCueDB[key] = CopyDefaultValue(value)
            else
                for nestedKey, nestedValue in pairs(value) do
                    if CombatCueDB[key][nestedKey] == nil then
                        CombatCueDB[key][nestedKey] = nestedValue
                    end
                end
            end
        end
    end
end

function CombatCue:ResetDB()
    self:EnsureDB()

    CombatCueDB.fontSize = self.defaults.fontSize
    CombatCueDB.x = self.defaults.x
    CombatCueDB.y = self.defaults.y
    CombatCueDB.enterCombatMessage = self.defaults.enterCombatMessage
    CombatCueDB.leaveCombatMessage = self.defaults.leaveCombatMessage
    CombatCueDB.enterCombatColor = CopyDefaultValue(self.defaults.enterCombatColor)
    CombatCueDB.leaveCombatColor = CopyDefaultValue(self.defaults.leaveCombatColor)
    CombatCueDB.animationEnabled = self.defaults.animationEnabled
    CombatCueDB.animationStyle = self.defaults.animationStyle
    CombatCueDB.displayDuration = self.defaults.displayDuration
    CombatCueDB.animationDuration = self.defaults.animationDuration
    CombatCueDB.animationScale = self.defaults.animationScale
end

function CombatCue:GetCombatColor(messageType)
    self:EnsureDB()

    if messageType == "leave" then
        return CombatCueDB.leaveCombatColor
    end

    return CombatCueDB.enterCombatColor
end
