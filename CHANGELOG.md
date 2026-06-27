# Changelog

## 0.1.0

Initial development version of CombatState.

### Added

- Created the basic WoW addon structure with `CombatState.toc` and Lua source files.
- Added combat state detection:
  - `++combat++` when entering combat.
  - `--combat--` when leaving combat.
- Added slash commands:
  - `/combatstate`
  - `/cs`
- Added a custom on-screen alert frame instead of using the default UI error frame.
- Added saved settings with `CombatStateDB`.
- Added a configuration window.
- Added font size customization.
- Added X and Y position customization.
- Added sliders for:
  - font size
  - position X
  - position Y
- Added direct numeric input fields for:
  - font size
  - position X
  - position Y
- Added draggable preview text for positioning the alert visually.
- Added a test button to preview the alert.
- Added a reset button to restore default settings.
- Added English and French menu localization.

### Changed

- Updated the addon interface version to `120007`.
- Reorganized the addon into separate files:
  - `Localization.lua`
  - `Database.lua`
  - `Alert.lua`
  - `Config.lua`
  - `Core.lua`
- Simplified `Core.lua` so it only handles loading, combat events, and slash commands.
- Moved configuration UI logic into `Config.lua`.
- Moved alert display logic into `Alert.lua`.
- Moved saved variable defaults and reset logic into `Database.lua`.
- Moved translated strings into `Localization.lua`.

### Notes

- French UI text is currently written without accents to avoid encoding issues in Lua/WoW.
- The addon is designed for Retail WoW and is loaded through `CombatState.toc`.
