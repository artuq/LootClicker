# Session Summary - 2026-02-18

## 🎯 Achievements
1. **AdMob Strategy:** Switched to a robust **Fake Ads** system using Tweens. This bypasses Google's current "Account not approved" (Error 3) and "No fill" issues, allowing development to proceed.
2. **Game Balance:** 
   - Implemented a **Stage 25+ Nerf**. Enemy HP scaling reduced by 15% and Damage scaling by 20% after Stage 25.
   - **Buffed Gold Drop:** Increased base gold (8→12) and scaling (1.1→1.15).
   - **Expanded Skill Tree:** Increased max skill level from 10 to **50**.
   - **Skill Tier Bonuses:** Rewarded specialization (e.g., Level 41+ STR gives +5 DMG instead of +1).
   - **Adrenaline Mechanic:** Added active combat buff (50 clicks -> 5s of Double Damage).
   - **Soft Landing Scaling:** Switched from exponential to linear scaling after Stage 30 to keep late-game challenge fair.
3. **Bug Fixes:** 
   - Resolved **Negative HP display** bug in `Enemy.gd`.
   - Fixed **HP Potion button** getting stuck (now reactive via `health_changed` signal).
   - Fixed **Fake Ad timer** hanging (switched from Timer node to SceneTreeTween).
4. **Inventory Integrity:** Reverted unauthorized random item generation. Cleaned inventory of "junk" items (cogs/gears) to restore original design.

## 🛠 Technical Changes
- `GameBattleManager.gd`: Modified `spawn_enemy` scaling, updated `_init_admob` and `_show_fake_ad`, added inventory cleanup on death.
- `Enemy.gd`: Added `max(0, ...)` to `take_damage` and fixed signal parameters.

## 📈 Project Status
- **Version:** v0.2.1 (Internal Dev)
- **Completion:** ~68%
- **Next Focus:** Action Bar UI (#11) and Flavorful Descriptions (#16).

---
# Session Summary - 2026-02-20

## 🎯 Achievements
1. **Framework Adaptation (CLAUDE.md):** 
   - Agreed to follow the 3-layer architecture for project consistency, but swapped the "Python Execution" layer for **PowerShell/Godot CLI** to better suit game development.
   - Established the **Detailed Logbook Protocol**: I will automatically summarize our discussions and technical decisions in this file to preserve context across sessions.
2. **UI & Android Fixes:** 
   - Fixed the Fake Ad positioning by anchoring it symmetrically inside the main `%CanvasLayer` (`GROW_DIRECTION_BOTH`) instead of a broken separate `CanvasLayer`.
   - Fixed the persistent gray background behind pixel art upgrade cards by swapping the root node from `Button` to `TextureButton` and applying `flat = true`.
3. **Bug Fixes:**
   - Resolved a critical GDScript parser error (`ad_layer` undefined variable) in `GameBattleManager.gd` that silently broke Android deployments.
   - Resolved a strict type mismatch in `CardChoiceScene.gd` (`func create_card(...) -> TextureButton:` instead of `Button:`) which caused immediate crashes on Android startup.

## 🛠 Technical Changes
- `GameBattleManager.gd`: Modified `_show_fake_ad()` to attach to `%CanvasLayer` and removed faulty tween cleanup.
- `CardChoiceScene.gd`: Changed card base from `Button` to `TextureButton` and updated the return type signature to fix the strict typing crash.
- `.gemini_session_checkpoint.json`: Integrated as our primary state-saver for rapid context restoration.

## 📈 Project Status
- **Next Focus:** Verifying the Android build works with the new `TextureButton` type fix, then moving to Action Bar UI (#11).
