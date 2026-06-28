# Changelog
## Unreleased

### Changed
- Moved the configuration UI into the native WoW Retail AddOns settings panel.
- Replaced the custom skinned configuration window with native controls and a two-column settings layout.
- Adjusted the settings panel to a narrower single-column layout for the native options view.
- Added an internal scroll frame to prevent settings controls from overflowing the options window.
- Fixed settings input fields so their current values are visible on dark option backgrounds.
- Added a preview placement mode that closes the options panel and lets the alert text be moved above the UI.
- Replaced the animation style button with a previous/current/next selector.
- Added subtle section bands and dividers to make settings groups easier to distinguish.
- Reduced settings control widths to prevent section dividers and inputs from overflowing.
- Increased vertical spacing between settings sections to prevent dividers from overlapping controls.
- Anchored section dividers below the previous controls to prevent message fields from overlapping section headers.

## [1.0.2](https://github.com/vikarious94-dot/CombatCue/tree/v1.0.2) - 2026-06-28

### Added
- Added GitHub Actions packaging for tagged releases.

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
