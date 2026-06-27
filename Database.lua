local _, CombatState = ...

CombatState.defaults = {
    fontSize = 32,
    x = 0,
    y = 180,
}

function CombatState:EnsureDB()
    CombatStateDB = CombatStateDB or {}

    for key, value in pairs(self.defaults) do
        if CombatStateDB[key] == nil then
            CombatStateDB[key] = value
        end
    end
end

function CombatState:ResetDB()
    self:EnsureDB()

    CombatStateDB.fontSize = self.defaults.fontSize
    CombatStateDB.x = self.defaults.x
    CombatStateDB.y = self.defaults.y
end
