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
   - Reverted from `TextureButton` back to `Button` for upgrade cards due to Android crashing when styling `normal` states. Instead, overrode ALL states (normal, hover, pressed, focus, disabled) with `StyleBoxEmpty` to eliminate the default gray GUI backgrounds entirely.
   - Fixed a layout issue where buttons in the HBoxContainer became staggered stairs. Enforced uniform physical card heights by changing `btn.size_flags_vertical` to `Control.SIZE_SHRINK_BEGIN` and setting `lbl.custom_minimum_size = Vector2(90, 35)` so single-line descriptions occupy the exact same space as multi-line ones.
3. **Bug Fixes:**
   - Resolved a critical GDScript parser error (`ad_layer` undefined variable) in `GameBattleManager.gd` that silently broke Android deployments.
   - Resolved a strict type mismatch in `CardChoiceScene.gd` (`func create_card(...) -> TextureButton:` vs `Button:`) which initially caused crashes on Android startup.

## 🛠 Technical Changes
- `GameBattleManager.gd`: Modified `_show_fake_ad()` to attach to `%CanvasLayer` and removed faulty tween cleanup.
- `CardChoiceScene.gd`: Changed card base back to `Button`, cleared all StyleBoxes, forced description labels to 35px min-height, and set `SIZE_SHRINK_BEGIN`.
- `.gemini_session_checkpoint.json`: Integrated as our primary state-saver for rapid context restoration.

## 📈 Project Status
- **Next Focus:** Moving on to Action Bar UI (#11) and Flavorful Descriptions (#16) now that the Android crash and layout rendering issues are fully resolved.

---
# Session Summary - 2026-02-23

## 🎯 Achievements
1. **Tutorial UI Fix:** Resolved the issue where tutorial text icons disappeared on Android devices. Replaced the static TTF font with Godot's native `SystemFont`, leveraging Android's built-in emoji fonts (like "Noto Color Emoji") to render standard emojis correctly without bloating the APK.
2. **Flavorful Descriptions (#16):** Implemented the "Solver First" humorous flavor texts for all upgrade and cursed cards.
   - Introduced the English parody style (Indiana Jones/Hot Shots vibe) to match the v0.2 MVP constraints.
   - Restructured the UI in `CardChoiceScene` to show `flavor_name`, `flavor_desc` prominently, while keeping the raw data in a `stat_short` field down below in brackets.
3. **Action Bar UI (#11):** Verified that the Action Bar feature, including enemy shadow and white damage flash, was already fully merged into `GameBattleManager.gd`.
4. **Draft Release (APK):** Used Godot 4.6 headless export to build a new Android APK (`LootClicker.apk`) and pushed it to GitHub as a pre-release Draft (v0.2.0-beta).

## 🛠 Technical Changes
- `UpgradeManager.gd`: Modified the dictionary lists to include detailed `flavor_name`, `flavor_desc`, and `stat_short` instead of simple static text.
- `GameBattleManager.gd`: Rewrote the `_show_tutorial()` screen's Label definitions to employ `SystemFont`.
- `CardChoiceScene.gd`: Redesigned dynamically spawned card texts to utilize the new flavor structure.

## 📈 Project Status
- **Next Focus:** Apply flavor texts to the permanent skill tree/shop (`UpgradeScreen`) and verify balance of the final boss (Stage 50).