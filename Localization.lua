local _, CombatState = ...

CombatState.translations = {
    enUS = {
        loaded = "loaded. Type /combatstate to configure.",
        title = "CombatState",
        fontSize = "Font size",
        enterCombatMessage = "Enter combat message",
        leaveCombatMessage = "Leave combat message",
        enterCombatColor = "Enter color",
        leaveCombatColor = "Leave color",
        positionX = "Position X",
        positionY = "Position Y",
        moveHint = "Move the preview text on screen to choose its position.",
        previewEnter = "Preview enter",
        previewLeave = "Preview leave",
        reset = "Reset",
        close = "Close",
    },
    frFR = {
        loaded = "charge. Tape /combatstate pour configurer.",
        title = "CombatState",
        fontSize = "Taille de police",
        enterCombatMessage = "Message entree combat",
        leaveCombatMessage = "Message sortie combat",
        enterCombatColor = "Couleur entree",
        leaveCombatColor = "Couleur sortie",
        positionX = "Position X",
        positionY = "Position Y",
        moveHint = "Deplace le texte de preview a l'ecran pour choisir sa position.",
        previewEnter = "Apercu entree",
        previewLeave = "Apercu sortie",
        reset = "Reinitialiser",
        close = "Fermer",
    },
}

CombatState.L = setmetatable(
    CombatState.translations[GetLocale()] or CombatState.translations.enUS,
    { __index = CombatState.translations.enUS }
)
