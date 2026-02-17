# Session Summary - LootClicker

## Session 2 — 2026-02-17 (Evening)

### Features Implemented

#### 1. Near Death Experience VFX (#15) ✅
- Radial vignette overlay (custom canvas_item shader, CanvasLayer 100)
- Low-pass audio filter when HP < 20%
- Procedural heartbeat SFX (16-bit WAV "lub-dub")
- Commit: `afcd2ee`

#### 2. Cursed Cards System (#14) ✅
- 6 cursed cards: Berserker, Glass Cannon, Blood Price, Frenzy, Toxic Surge, Thorns
- 25% curse chance per card draw
- Confirmation popup with debuff description
- Dark-red card styling with "CURSED" tag
- Commits: `e110774`, `11df1cc` (viewport fix), `f742bb1` (font fix), `36a0f00` (between-stages fix)

#### 3. Enemy Roster & Biome System (#17) ✅
- 9 unique enemies across 2 biomes (Jungle + Temple)
- Jungle: Squirrel, Monkey, Carnivorous Plant, Mummy, Snake
- Temple: Skeleton Warrior, Stone Golem, Ghost, Mummy, Snake
- Biome spawning rules: S1-14 jungle, S15-20 mixed (80/20), S21-35 temple, S36-40 mixed, S41+ 50/50
- Dynamic texture loading from `assets/sprites/enemies/`
- Commit: `8c5c1cf`

#### 4. Boss System (#18) ✅
- 3 bosses: Jungle Idol (S10), Temple Guardian Brad (S25), Sphinx (S40)
- Boss greeting UI: dark overlay + gold text + fade animation
- Final Boss at Stage 50 uses legacy Sadam texture
- Commit: `8c5c1cf`

#### 5. Resource Simplification ✅
- Reduced from 6 to 3 resource types: bandages, venom, relic_shards
- Scaling drops: S15+ 1-2, S30+ 1-3
- Added Mummy + Snake to both biome rosters
- Commit: `b6ccd2c`

#### 6. Complete Balance Rewrite ✅
- **DMG scaling**: Multiplicative STR bonus `(1 + str_lvl) * (1 + str_lvl * 0.025)`
- **Defense**: % damage reduction `min(0.50, def_lvl * 0.02)` instead of flat
- **Crit damage**: Scales `2.0 + crit_lvl * 0.02`
- **Speed**: Diminishing returns `max(0.15, 1.0 / (1.0 + speed_lvl * 0.08))`
- **Potions**: Heal `max(30, max_hp * 0.2)` (20% of max HP)
- **XP curve**: Exponent 1.3 (was 1.4)
- Commit: `a3d0f93`

#### 7. MVP Polish (#20) ✅
- Boss progress bar in HUD
- Biome indicator label
- Loot summary on victory screen
- DPS display
- Tutorial overlay on first play
- Commit: `3a67b51`

#### 8. HUD Layout Overhaul ✅
- **v1** (`055ea31`): Split TopBar into 2 rows to prevent 360px overflow
- **v2** (`5babb1d`): Replaced Row2 containers (BiomeLabel, BossProgressBar, XPBar) with single `InfoLabel` — formatted from `_update_info_label()` as `"Jungle  1/10 The Allergic Idol  XP 3/50"` — eliminates layout overflow entirely
- Gold icon: `gold_coin_custom.svg` → `coin.png` (user-provided asset)
- DPS label moved to its own row below gold
- `clip_text = true` as safety net

### Bug Fixes
- `xp_changed` signal arg mismatch — lambda with default params
- `enemy_attack` indentation — mixed tab/space caused AudioManager scene tree error
- Card viewport overflow — cards 105×200px, container 350px
- Curse effects between stages — `in_combat` flag + poison timer cleanup
- `gold_coin_custom.svg` import `valid=false` — set to `true`
- `CanvasLayer` has no `modulate` — animate backdrop/panel instead
- `SkillNode.gd:75` integer division — `int(... / 20.0)`
- Commits: `12dcc92`, `36a0f00`, `4cb7c8d`

### Git Commits (Session 2)
| Hash | Description |
|------|-------------|
| `afcd2ee` | feat: Near death vignette + heartbeat + low-pass |
| `e110774` | feat: Cursed cards system (6 cards, 25% chance) |
| `11df1cc` | fix: Card viewport size overflow |
| `f742bb1` | fix: Card font size split name/desc |
| `36a0f00` | fix: Disable curse effects between stages |
| `8c5c1cf` | feat: Biome enemy roster + boss system (9 sprites) |
| `b6ccd2c` | fix: Keep 3 resource types, add Mummy+Snake |
| `12dcc92` | fix: xp_changed signal + enemy_attack indentation |
| `a3d0f93` | balance: Complete rebalance pass (6 changes) |
| `3a67b51` | feat: MVP polish — boss bar, biome, DPS, tutorial |
| `4cb7c8d` | fix: SVG import, CanvasLayer modulate, int division |
| `055ea31` | fix: HUD layout overhaul v1 — 2-row TopBar |
| `5babb1d` | fix: Replace Row2 with single InfoLabel + coin.png |

---

## Session 1 — 2026-02-17 (Morning)

### Critical Bugfixes ✅
1. **AudioManager Master Bus** — bus existence check + error logging
2. **CardChoiceScene Crash** — null-check guards in setup() and _on_card_selected()
3. **UpgradeManager Icons** — dodge/block card icon swap fix
4. **Save/Load** — added dodge_chance/block_chance with backward compat

Commits: `51fa613` (bugfixes) + `d68d8f5` (documentation)

---

## Previous Sessions (2026-02-15 to 2026-02-16)

### Achievements
- **UI/UX Overhaul**: Dynamic HP bars, inventory grid, hit particles, UI audio, HUD TopBar
- **Codebase Reorganization**: Professional folder structure, path updates, asset consolidation
- Commits: `9324e33` (restructuring)

---

## Current Project Status
- ✅ 4 major features implemented (#14, #15, #17, #18)
- ✅ Full balance pass complete
- ✅ 9 unique enemy sprites integrated
- ✅ All critical bugs fixed and documented
- ✅ GitHub issues #1-#19 tracked, project board synced

## GitHub Issues Summary
| Status | Issues |
|--------|--------|
| **Done** | #1, #2, #6, #8, #13 |
| **In Progress** | #5, #10, #11, #12 |
| **Todo** | #3, #4, #7, #14, #15, #16, #17, #18, #19 |
| **Ice Box** | #9 |

## Next Priority Queue
1. 🕒 Close issues #14, #15, #17, #18 on GitHub (implemented, need closing)
2. 🕒 **Flavorful Descriptions** (#16) — Lore text for enemies/items
3. 🕒 **Drop System Expansion** (#19) — Unique item drops from enemies
4. 🕒 **Lore & Narrative** (#3) — Intro sequence, dialogue
5. 🕒 **Pixel Art Polish** (#12) — Replace placeholder sprites
