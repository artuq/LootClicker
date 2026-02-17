# Roadmap ↔ Issues/Projects Synchronization Map

**Last Updated:** 2026-02-17 | **Sync Status:** ✅ Current

---

## 🗺️ Issue → Implementation Status

### Core Systems (#1) — ✅ CLOSED
All core mechanics implemented: combat, save/load, signals, scaling, boss every 5 stages.

### Audio/Visual Game Feel (#2) — ✅ CLOSED
Audio manager, procedural SFX, hit flash, screen shake, squash & stretch. **Extended by #15 (Near Death VFX).**

### Lore & Items (#3) — 🕒 TODO
Story, loot table design, prestige system. **Partially addressed by enemy roster flavor text.**

### Google Play Release (#4) — 🕒 TODO
Privacy policy, IARC, screenshots, .aab build. Blocked by MVP completion.

### QA & Testing (#5) — 🟢 IN PROGRESS (Project Board)
GitHub closed, but board shows In Progress. Ongoing regression testing with each feature.

### Polish Backlog (#6) — ✅ CLOSED
Floating text, HP bar colors, button juice, XP signals, card text wrapping.

### Monetization (#7) — 🕒 TODO
AdMob, analytics, marketing materials. Post-MVP.

### Assets List (#8) — ✅ CLOSED
AI-generated icons (bandage, venom, crystal, coin), sprites organized.

### Admin/Localization (#9) — 🧊 ICE BOX
Translations, credits, licensing. Deferred.

### MVP v0.2 (#10) — 🟢 IN PROGRESS
Core loop functional. Enemies + bosses done. Needs: English UI text, Stage 50 boss balance.

### Combat Arena UI (#11) — 🟢 IN PROGRESS
HUD redesigned (TopHUD + MidHUD), enemy positioning done. Missing: shadow, white flash HP, action bar.

### Pixel Art Style (#12) — 🟢 IN PROGRESS
9 Stardew Valley-style sprites imported. Pixel perfect config set. Needs: 32x32 character sprites.

### Godot Startup Fix (#13) — ✅ CLOSED
Removed C# addon, fixed tree_background.png mismatch.

### Cursed Cards (#14) — ✅ IMPLEMENTED
6 cursed cards (Berserker, Glass Cannon, Blood Price, Frenzy, Toxic, Thorns). Confirmation popup, debuff timer, between-stage safety. **Ready to close.**

### Near Death VFX (#15) — ✅ IMPLEMENTED
Red vignette shader (radial gradient, pulsing), low-pass audio filter (20500→800 Hz), procedural heartbeat SFX. **Ready to close.**

### Flavorful Descriptions (#16) — 🕒 TODO
Climate-themed card text with flavor + stat. Low priority copywriting task.

### Enemy Roster (#17) — ✅ IMPLEMENTED
8 enemies: Squirrel, Monkey, Plant, Mummy, Snake (Jungle) + Skeleton, Golem, Ghost, Mummy, Snake (Temple). Biome spawning rules. 3 resource types (bandages, venom, relic_shards). **Ready to close.**

### Boss System (#18) — ✅ IMPLEMENTED
3 bosses: The Allergic Idol (S10, "Ah...CHOO!"), Brad the Influencer (S25, "Like and subscribe!"), Budget Sphinx (S40, "Meow. Give me gold."). Greeting text overlay with fade animation. **Ready to close.**

### Drop/Resource System (#19) — 🕒 TODO
Loot tables with scaling drops. Partially implemented (enemies drop bandages/venom/relic_shards with stage-scaled amounts). Needs: crafting system, resource usage.

---

## 📊 Issue Distribution

```
CLOSED (GitHub):           6  (#1, #2, #5, #6, #8, #13)
IMPLEMENTED (ready close): 4  (#14, #15, #17, #18)
IN PROGRESS:               4  (#5*, #10, #11, #12)
TODO:                      5  (#3, #4, #7, #16, #19)
ICE BOX:                   1  (#9)
────────────────────────────
TOTAL:                    19 issues

* #5 is closed on GitHub but In Progress on project board
```

---

## 🔄 Implementation Map (What Code Changed)

| Issue | Files Modified | Key Changes |
|-------|---------------|-------------|
| #14 | PlayerStats.gd, UpgradeManager.gd, CardChoiceScene.gd, GameBattleManager.gd | Curse system, debuff timers, cursed card styling |
| #15 | GameBattleManager.gd, AudioManager.gd | Vignette shader, low-pass filter, heartbeat synth |
| #17 | GameBattleManager.gd, PlayerStats.gd, Enemy.gd | Enemy roster arrays, biome spawning, resource types |
| #18 | GameBattleManager.gd | Boss roster dict, greeting UI, sprite scaling |
| Balance | PlayerStats.gd, GameBattleManager.gd, UpgradeManager.gd | DMG%, DEF%, Crit DMG, Speed curve, Potion%, XP |

---

## Current Codebase Structure

```
src/scripts/
├── AudioManager.gd     — Music, SFX, near-death audio, procedural heartbeat
├── Enemy.gd            — Enemy class with name, HP, damage, resource drop
├── GameItem.gd         — Equipment item class
├── PlayerStats.gd      — All player stats, curses, combat, XP/leveling
├── SettingsManager.gd  — Settings persistence
├── SkillNode.gd        — Skill tree node
├── UpgradeManager.gd   — Card definitions (8 normal + 6 cursed), upgrade application

src/scenes/
├── GameBattleManager.gd — Main battle controller, enemy roster, boss system, vignette
├── CardChoiceScene.gd   — Level-up card selection UI with cursed card styling
├── SkillTree.gd         — Skill tree logic
├── UpgradeScreen.gd     — Upgrade shop screen
├── TitleScreen.gd       — Title/menu screen
├── SettingsScene.gd     — Settings UI
└── damage_label.gd      — Floating damage text

assets/sprites/enemies/  — 9 PNG sprites (6 enemies + 3 bosses)
assets/ui/cards/         — Card icons (8 normal + 6 cursed)
```

---

**Maintained By:** GitHub Copilot | **Last Sync:** 2026-02-17
