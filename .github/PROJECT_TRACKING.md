# LootClicker - Project Tracking Board

**Status:** Active Development | **Last Updated:** 2026-02-17 | **Sprint:** Session 2026-02-17

---

## 📋 Session Goals (2026-02-17)

1. ✅ **Near Death VFX** (#15) — Red vignette, heartbeat, low-pass filter
2. ✅ **Cursed Cards** (#14) — 6 risk/reward cards with debuff system
3. ✅ **Enemy Roster** (#17) — 8 enemies across 2 biomes (Jungle + Temple)
4. ✅ **Boss System** (#18) — 3 unique bosses with greeting text
5. ✅ **Balance Pass** — 6 core balance changes (DMG, DEF, Crit, Speed, Potion, XP)
6. ✅ **Bug Fixes** — Signal mismatch, indentation, curse timing, card UI

---

## 📊 Project Board (GitHub Projects)

### ✅ DONE (6 items)

| # | Title | Key Commits |
|---|-------|-------------|
| #1 | [CORE] Implementacja mechanik gry i systemów danych | `51fa613` |
| #2 | [ART] Oprawa audiowizualna i Game Feel | `51fa613`, `2be4035` |
| #6 | [POLISH] Ulepszanie istniejących mechanik | `f3eb983` |
| #8 | [ASSETS] Lista Zasobów do wykonania/zdobycia | `2be4035` |
| #13 | Fix: Godot startup errors and resource mismatches | bug fix |
| — | Documentation & bugfix changelogs | `d68d8f5`, `2b33e38` |

### 🟢 IN PROGRESS (3 items)

| # | Title | Progress | Notes |
|---|-------|----------|-------|
| #5 | [QA] Testy Regresyjne i Weryfikacja Błędów | ~70% | GitHub closed, board In Progress. Ongoing testing. |
| #10 | [MVP] Zakres wersji 0.2 (English Only Release) | ~40% | Core loop done, enemy roster done. Needs: English texts, Stage 50 boss tuning |
| #11 | [UI] Combat Arena - Styl "Action Bar" | ~50% | HUD redesigned. Missing: shadow, white flash HP, action bar |
| #12 | [ART] Styl Graficzny: Pixel Art (Stardew-like) | ~60% | 9 Stardew-style sprites, pixel perfect config. Needs: 32x32 character sprites |

### 🕒 TODO (9 items)

| # | Title | Priority | Est. Hours |
|---|-------|----------|------------|
| #3 | [LORE] Implementacja fabuły i przedmiotów | 🟡 Medium | 8h |
| #4 | [RELEASE] Przygotowanie do publikacji Google Play | 🔴 Low | 6h |
| #7 | [BIZNES] Monetyzacja, Marketing i Analityka | 🔴 Low | 10h |
| #14 | [DESIGN] High Stakes Cards | ✅ Implemented | — (ready to close) |
| #15 | [VFX] Near Death Experience | ✅ Implemented | — (ready to close) |
| #16 | [UX] Flavorful Descriptions | 🟢 Low | 4h |
| #17 | Enemy Roster: 6 Enemies (2 Biomes) | ✅ Implemented | — (ready to close) |
| #18 | Boss System: 3 Boss Fights | ✅ Implemented | — (ready to close) |
| #19 | Drop/Resource System: Loot Tables | 🟡 Medium | 6h |

### 🧊 ICE BOX (1 item)

| # | Title | Notes |
|---|-------|-------|
| #9 | [ADMIN] Lokalizacja, Licencje i Organizacja | Post-MVP |

---

## 📈 Velocity & Metrics

### Session 2026-02-17

| Metric | Value |
|--------|-------|
| Features Implemented | 4 (#14, #15, #17, #18) |
| Bug Fixes | 5 (card size, font, curse timing, signal, indentation) |
| Balance Changes | 6 (DMG, DEF, Crit, Speed, Potion, XP) |
| Commits | 9 |
| Sprites Added | 9 (6 enemies + 3 bosses) + 6 cursed card PNGs |
| Files Modified | ~10 |
| New Issues Created | 6 (#14-#19) |

### Historical

| Date | Features | Fixes | Commits |
|------|----------|-------|---------|
| 2026-02-17 (session 2) | 4 features | 5 fixes + 6 balance | 9 commits |
| 2026-02-17 (session 1) | HUD redesign, AI icons, XP signals | 6 critical bugs | 9 commits |
| 2026-02-15 | Godot fix, resource repair | 1 bug fix | 2 commits |
| 2026-02-13 | Initial setup, core systems | — | Multiple |

---

## 🎯 Milestone Tracking

```
[================================================================] 65% → v0.2

✅ v0.1 - Foundation (DONE)
   ├─ Basic combat, HP bars, inventory, save/load
   ├─ UI/UX overhaul, code reorganization
   └─ Kenney UI skinning, audio manager

✅ v0.1.5 - Game Feel (DONE - This Session)
   ├─ Near Death VFX (vignette + heartbeat)
   ├─ Cursed Cards (6 cards, debuff system)
   ├─ Enemy Roster (8 enemies, 2 biomes)
   ├─ Boss System (3 bosses with greeting UI)
   └─ Complete balance rewrite

🟢 v0.2 - MVP Release (IN PROGRESS)
   ├─ English texts hardcoded
   ├─ Stage 50 final boss tuned
   ├─ Drop/resource system (#19)
   ├─ Flavorful descriptions (#16)
   └─ Estimated: 1-2 weeks

🕒 v0.3 - Story & Prestige (PLANNED)
   ├─ Full narrative arc (#3)
   ├─ Prestige/New Game+ mechanics
   └─ Estimated: 2-3 weeks after v0.2

🕒 v1.0 - Polish & Release (FUTURE)
   ├─ Google Play prep (#4)
   ├─ Monetization (#7)
   └─ Localization (#9)
```

---

## 🔗 Current Tech Stack

| Component | Status | Details |
|-----------|--------|---------|
| Godot | 4.6 | GDScript, viewport 360x640, portrait |
| GitHub CLI | v2.86.0 | Scopes: gist, project, read:org, repo, workflow |
| Repo | artuq/LootClicker | Branch: main |
| Project Board | PVT_kwHOAYMZ0M4BPEOq | 19 items tracked |

---

**Maintained By:** GitHub Copilot | **Last Reviewed:** 2026-02-17 @ 16:00 UTC
