# Session Summary - 2026-02-15 (Part 2)

## Achievements
- **Stability & Bug Fixes**:
    - Resolved persistent "NEW GAME" crashes by fixing `UpgradeManager` and `SkillTreeScene` logic.
    - Fixed "Mixed tabs/spaces" and "Unused Signal" warnings.
    - Safe scene transition implementation in `TitleScreen.gd`.
- **Combat & Balance**:
    - Added **Dodge** and **Block** mechanics to Player and Enemies.
    - Balanced **Saddam Boss** multipliers for better early flow.
    - New Upgrade Cards: **Evasion** (Dodge) and **Bulwark** (Block).
- **UI Improvements**:
    - Fixed XP bar visual sync (max_value update sequence).
    - Added Player HP Bar and Enemy HP numerical labels.

## Planned for Next Session
- **Dynamic UI**: Progress bars changing colors based on % HP.
- **Inventory Overhaul**: Grid system with icons instead of a list.
- **Juice**: Particle systems for combat hits.
- **Audio**: UI interaction sounds.

## GitHub Status
- All changes committed and pushed to `origin/main`.
