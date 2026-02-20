# Directive: Game Mechanics and Balance

## Objective
Maintain the current game state and ensure new changes do not conflict with existing balance adjustments or AdMob configurations.

## Current Game State
- **AdMob Status:** Fake Ads enabled (DEBUG_FORCE_FAKE_ADS: true). Real AdMob blocked by Google (Error 3: No fill). Use Tween timer for fake ads.
- **Balance Nerf (Stage 25+):** Enemies are significantly stronger after stage 25.
- **Soft Landing (Stage 30+):** Linear scaling applied instead of exponential to avoid extreme difficulty spikes.
- **Gold Scaling:** Base drop 12, multiplier 1.15.
- **Skill Tree:** Max skill level is 50.
- **Special Mechanics:**
  - **Skill Tier Bonuses:** STR/HP boosts at levels 20 and 40.
  - **Adrenaline System:** 50 clicks -> x2 DMG for 5 seconds.
  - **Inventory:** Core resources (Bandages, Venom, Shards) only. Junk cleanup active on death.

## Inputs
- Any proposed changes to balancing, AdMob, or core mechanics.

## Procedure
1. **Research:** Before making changes, read `src/scripts/GameBattleManager.gd` or `src/scenes/SkillTree.gd` to confirm current values.
2. **Strategy:** If adjusting balance, prioritize the "Soft Landing" approach for higher stages.
3. **Execution:** Modify the appropriate GDScript files.
4. **Validation:** Run the game (if possible) or use a script in `execution/` to simulate enemy health vs. player damage to verify the nerf/buff impact.

## Edge Cases
- **AdMob Unblock:** If Google unblocks the app, revert `DEBUG_FORCE_FAKE_ADS` to false and test real AdMob IDs.
- **High Stage Inflation:** If players reach Stage 100+ too easily, review the 1.15 gold scale.
