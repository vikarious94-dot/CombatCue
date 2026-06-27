local _, CombatState = ...

CombatState.translations = {
    enUS = {
        loaded = "loaded. Type /combatstate to configure.",
        title = "CombatState",
        fontSize = "Font size",
        positionX = "Position X",
        positionY = "Position Y",
        moveHint = "Move the preview text on screen to choose its position.",
        test = "Test",
        reset = "Reset",
        close = "Close",
    },
    frFR = {
        loaded = "charge. Tape /combatstate pour configurer.",
        title = "CombatState",
        fontSize = "Taille de police",
        positionX = "Position X",
        positionY = "Position Y",
        moveHint = "Deplace le texte de preview a l'ecran pour choisir sa position.",
        test = "Tester",
        reset = "Reinitialiser",
        close = "Fermer",
    },
}

CombatState.L = setmetatable(
    CombatState.translations[GetLocale()] or CombatState.translations.enUS,
    { __index = CombatState.translations.enUS }
)
