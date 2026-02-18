# Roadmap ↔ Issues/Projects Synchronization Map

**Last Updated:** 2026-02-18 | **Sync Status:** ✅ Current

---

## 🗺️ Issue → Implementation Status

### Core Systems (#1) — ✅ CLOSED
All core mechanics implemented.

### Audio/Visual Game Feel (#2) — ✅ CLOSED
Audio, SFX, near-death VFX (Issue #15 integrated here).

### Lore & Items (#3) — 🕒 TODO
Story and prestige system.

### Google Play Release (#4) — 🕒 TODO
Blocked by MVP completion.

### QA & Testing (#5) — 🟢 IN PROGRESS (Project Board)
Ongoing regression testing. Fake Ads system verified.

### Polish Backlog (#6) — ✅ CLOSED
UI polish, XP signals.

### Monetization (#7) — 🕒 TODO
AdMob (Currently using Fake Ads for stability).

### Assets List (#8) — ✅ CLOSED
AI-generated icons.

### Admin/Localization (#9) — 🧊 ICE BOX
Deferred.

### MVP v0.2 (#10) — 🟢 IN PROGRESS
Core loop functional. Nerf Stage 25+ applied.

### Combat Arena UI (#11) — 🟢 IN PROGRESS
HUD redesigned. Next: shadow, white flash, action bar.

### Pixel Art Style (#12) — 🟢 IN PROGRESS
9 sprites imported. Needs character sprites.

### Godot Startup Fix (#13) — ✅ CLOSED
Fixed startup errors.

### Cursed Cards (#14) — ✅ CLOSED
6 cards implemented and verified.

### Near Death VFX (#15) — ✅ CLOSED
Vignette and heartbeat verified.

### Flavorful Descriptions (#16) — 🕒 TODO
Pending copywriting.

### Enemy Roster (#17) — ✅ CLOSED
8 enemies and biome rules verified.

### Boss System (#18) — ✅ CLOSED
3 bosses and greeting UI verified.

### Drop/Resource System (#19) — ✅ CLOSED
Reverted to core resources, cleaned junk inventory.

### MVP Polish (#20) — ✅ CLOSED
Progress bar, biome, loot summary, DPS, tutorial verified.

---

## 🔄 Implementation Map (Recent Changes)

| Issue | Files Modified | Key Changes |
|-------|---------------|-------------|
| #19 | GameBattleManager.gd | Reverted random loot, added auto-cleanup of junk items. |
| Balance | GameBattleManager.gd | Post-Stage 25 Nerf (HP -15%, DMG -20%). |
| Bugfix | GameBattleManager.gd, Enemy.gd | Fixed Negative HP, Potion UI, Fake Ads Tween timer. |

---

**Maintained By:** Gemini Pro | **Last Sync:** 2026-02-18
