local _, CombatState = ...

CombatState.defaults = {
    fontSize = 32,
    x = 0,
    y = 180,
    enterCombatMessage = "++combat++",
    leaveCombatMessage = "--combat--",
    enterCombatColor = { r = 1, g = 0.2, b = 0.2, a = 1 },
    leaveCombatColor = { r = 0.2, g = 1, b = 0.2, a = 1 },
}

local function CopyDefaultValue(value)
    if type(value) ~= "table" then
        return value
    end

    local copy = {}

    for key, nestedValue in pairs(value) do
        copy[key] = nestedValue
    end

    return copy
end

function CombatState:EnsureDB()
    CombatStateDB = CombatStateDB or {}

    for key, value in pairs(self.defaults) do
        if CombatStateDB[key] == nil then
            CombatStateDB[key] = CopyDefaultValue(value)
        elseif type(value) == "table" then
            if type(CombatStateDB[key]) ~= "table" then
                CombatStateDB[key] = CopyDefaultValue(value)
            else
                for nestedKey, nestedValue in pairs(value) do
                    if CombatStateDB[key][nestedKey] == nil then
                        CombatStateDB[key][nestedKey] = nestedValue
                    end
                end
            end
        end
    end

end

function CombatState:ResetDB()
    self:EnsureDB()

    CombatStateDB.fontSize = self.defaults.fontSize
    CombatStateDB.x = self.defaults.x
    CombatStateDB.y = self.defaults.y
    CombatStateDB.enterCombatMessage = self.defaults.enterCombatMessage
    CombatStateDB.leaveCombatMessage = self.defaults.leaveCombatMessage
    CombatStateDB.enterCombatColor = CopyDefaultValue(self.defaults.enterCombatColor)
    CombatStateDB.leaveCombatColor = CopyDefaultValue(self.defaults.leaveCombatColor)
end

function CombatState:GetCombatColor(messageType)
    self:EnsureDB()

    if messageType == "leave" then
        return CombatStateDB.leaveCombatColor
    end

    return CombatStateDB.enterCombatColor
end
