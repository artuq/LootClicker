# Session Summary - 2026-02-15

## Achievements
- **Combat Overhaul**:
    - Added **Dodge** (chance to avoid damage) and **Block** (chance to reduce damage by 50%) mechanics.
    - Floating text now shows "DODGED", "MISS", or "BLOCKED" for better feedback.
    - Updated `Enemy.gd` to allow enemies to dodge (after Stage 10).
    - New Upgrade Cards: "Evasion" and "Bulwark".
- **Rebalancing**:
    - **Saddam Boss Nerfed**: Reduced HP multiplier (4x -> 2.5x) and DMG multiplier (2x -> 1.5x) to make early progression smoother.
    - Increased starting gold gain to help with early upgrades.
    - Smoothed out overall HP/DMG scaling.
- **UI/UX Polish**:
    - **XP Bug Fixed**: Reordered UI update sequence so `max_value` is set before `value`, preventing visual glitches where the bar looked full at 0 XP.
    - Moved XP label onto the progress bar for a cleaner look.

## Technical Notes
- `GameBattleManager.gd` was completely reformatted to ensure strict tab indentation.
- Scene communication improved using static class members for `startup_mode`.

## Next Steps
- Implement Particle Systems for clicks/hits.
- Expand Inventory system for equipment items.
- Add sound effects for UI interactions.
