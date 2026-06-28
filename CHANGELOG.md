# Changelog
## [1.0.1](https://github.com/vikarious94-dot/CombatCue/tree/v1.0.1) - 2026-06-28

### Changed
- Refreshed the configuration window with a larger panel, header banner, and wider tab layout.

## [1.0.0](https://github.com/vikarious94-dot/CombatCue/tree/v1.0.0) - 2026-06-27

### Added
- Added combat state alerts when entering and leaving combat.
- Added configurable enter-combat and leave-combat messages.
- Added customizable text colors and alpha values.
- Added font size customization.
- Added X and Y position customization with sliders and direct input fields.
- Added draggable preview text for visual positioning.
- Added configurable alert animations: fade, scale, and flash.
- Added animation controls for enable state, display duration, effect duration, and scale intensity.
- Added configuration tabs for messages, appearance, animation, and position.
- Added English and French localization.
- Added addon icon assets and title bar icon.
- Added `/combatcue`, `/cc`, and `/cs` slash commands.
- Added CurseForge project metadata.

### Changed
- Renamed the addon from CombatState to CombatCue.
- Updated the TOC interface version for WoW 12.0.7.
- Replaced the single test button with dedicated enter-combat and leave-combat preview buttons.
- Reorganized the addon into dedicated modules for localization, database, alerts, settings, config widgets, config UI, and core events.
- Kept the configuration window above other UI layers.

### Fixed
- Fixed color swatch rendering and color picker alpha initialization.
- Removed the color picker reset hook because native picker callbacks can treat custom buttons as cancel actions.
- Fixed slider thumbs not being positioned correctly when their default value is zero.