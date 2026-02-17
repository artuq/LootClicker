# LootClicker - Issue Tracking (GitHub Synced)

**Last Updated:** 2026-02-17 (evening) | **Total Issues:** 20 | **GitHub:** [artuq/LootClicker/issues](https://github.com/artuq/LootClicker/issues)

---

## ✅ Closed Issues (7)

| # | Title | Closed | Key Commits |
|---|-------|--------|-------------|
| #1 | [CORE] Implementacja mechanik gry i systemów danych | 2026-02-15 | `51fa613` |
| #2 | [ART] Oprawa audiowizualna i Game Feel | 2026-02-15 | `51fa613`, `2be4035` |
| #5 | [QA] Testy Regresyjne i Weryfikacja Błędów | 2026-02-15 | `51fa613` |
| #6 | [POLISH] Ulepszanie istniejących mechanik | 2026-02-15 | `f3eb983` |
| #8 | [ASSETS] Lista Zasobów do wykonania/zdobycia | 2026-02-15 | `2be4035` |
| #13 | Fix: Godot startup errors and resource mismatches | 2026-02-15 | bug fix |
| #20 | MVP Polish: Progress bar, biome, loot summary, DPS, tutorial | 2026-02-17 | `3a67b51` |

---

## 🟢 Implemented This Session (awaiting close)

Features **fully implemented** on 2026-02-17 but issues remain open on GitHub:

| # | Title | Commits | Notes |
|---|-------|---------|-------|
| #14 | [DESIGN] High Stakes Cards (Karty Ryzyka) | `e110774`, `11df1cc`, `f742bb1`, `36a0f00` | 6 cursed cards, confirmation popup, debuff system, between-stage fix |
| #15 | [VFX] Near Death Experience (Winieta) | `afcd2ee` | Red vignette shader, low-pass filter, procedural heartbeat SFX |
| #17 | Enemy Roster: 6 Unique Enemies (2 Biomes) | `8c5c1cf`, `b6ccd2c` | 8 enemies + Mummy/Snake legacy, biome spawning rules, 3 resource types |
| #18 | Boss System: 3 Unique Boss Fights | `8c5c1cf` | The Allergic Idol (S10), Brad the Influencer (S25), Budget Sphinx (S40), greeting text UI |

### Additional work (no dedicated issue):
- **Balance Pass** (`a3d0f93`): DMG% scaling, potion% heal, defense% reduction, crit damage scaling, speed soft cap, XP curve 1.4→1.3
- **Bug Fixes** (`12dcc92`): xp_changed signal arg mismatch, enemy_attack indentation causing scene tree error

---

## 🕒 Open Issues — Todo (Project Board)

| # | Title | Priority | Label |
|---|-------|----------|-------|
| #3 | [LORE] Implementacja fabuły i przedmiotów | Medium | — |
| #4 | [RELEASE] Przygotowanie do publikacji Google Play | Low | — |
| #7 | [BIZNES] Monetyzacja, Marketing i Analityka | Low | — |
| #16 | [UX] Flavorful Descriptions (Klimatyczne Opisy) | Low | — |
| #19 | Drop/Resource System: Enemy Loot Tables | Medium | enhancement |

---

## 🟢 Open Issues — In Progress (Project Board)

| # | Title | Notes |
|---|-------|-------|
| #10 | [MVP] Zakres wersji 0.2 (English Only Release) | Core loop functional, needs English texts + Stage 50 boss |
| #11 | [UI] Combat Arena - Styl "Action Bar" | HUD redesigned, missing: shadow under characters, white flash HP, action bar |
| #12 | [ART] Styl Graficzny: Pixel Art (Stardew-like) | 9 Stardew-style sprites added, pixel perfect config done |

---

## 🧊 Ice Box

| # | Title | Notes |
|---|-------|-------|
| #9 | [ADMIN] Lokalizacja, Licencje i Organizacja | Deferred to post-MVP |

---

## 📊 Summary

| Category | Count |
|----------|-------|
| Total Issues | 20 |
| Closed (GitHub) | 7 |
| Implemented (awaiting close) | 4 |
| In Progress | 3 |
| Todo | 5 |
| Ice Box | 1 |

---

## Session 2026-02-17 Commits (Chronological)

| Commit | Type | Description |
|--------|------|-------------|
| `afcd2ee` | feat | Near Death Experience — vignette + heartbeat (#15) |
| `e110774` | feat | Cursed Cards system — 6 cards + debuffs (#14) |
| `11df1cc` | fix | Card viewport resize for 360x640 |
| `f742bb1` | fix | Card font size increase |
| `36a0f00` | fix | Disable curse effects between stages |
| `8c5c1cf` | feat | Biome enemy roster + boss system — 9 sprites (#17, #18) |
| `b6ccd2c` | fix | Keep 3 resource types, add Mummy+Snake, balance drops |
| `12dcc92` | fix | xp_changed signal + indentation bug |
| `a3d0f93` | balance | Complete rebalance pass (6 changes) |
| `3a67b51` | feat | MVP polish — boss progress, biome, loot summary, DPS, tutorial (#20) |
