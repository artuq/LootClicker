# Roadmap ↔ Issues/Projects Synchronization Map

**Purpose:** Link Roadmap.md sections to GitHub Issues and Projects  
**Last Updated:** 2026-02-17  
**Sync Status:** ✅ Current

---

## 🗺️ Roadmap Sections → GitHub Issues

### FILAR 1: KOD I MECHANIKA (CORE)

#### Subgraph: Fundamenty (G_CORE)

| Roadmap Item | Issue(s) | Status | Notes |
|---|---|---|---|
| ✅ Fix: setup_enemy crash | Historical | ✅ CLOSED | Fixed in earlier session |
| ✅ Sygnały & Event Bus | Historical | ✅ CLOSED | Implemented in v0.1 |
| ✅ Sync: HP/Gold/Timery | Historical | ✅ CLOSED | Core system working |

#### Subgraph: Mechanika RPG (G_MECH)

| Roadmap Item | Issue(s) | Status | Notes |
|---|---|---|---|
| ✅ Floating Text System | Historical | ✅ CLOSED | Implemented in v0.1 |
| ✅ Boss System co 5 Stage | #10 | ✅ CLOSED | Working, needs visual/audio fixes |
| ✅ Roguelite: 3 Cards Choice | #2 | ✅ CLOSED | Bug fixed 2026-02-17 |
| ✅ Resources: Mummy Bandages | Historical | ✅ CLOSED | Drop system in v0.1 |
| ✅ Skalowanie x1.2 | Historical | ✅ CLOSED | Implemented math scaling |
| ✅ Dodge & Block Mechanic | #4 | ✅ CLOSED | Save/load fixed 2026-02-17 |

---

### FILAR 2: GRAFIKA I OPTYMALIZACJA (TECH-ART)

#### Subgraph: Wydajność i Styl (G_OPT)

| Roadmap Item | Issue(s) | Status | Notes |
|---|---|---|---|
| ✅ Pixel Art Config | Historical | ✅ CLOSED | 2D pixel perfect enabled |
| ✅ Kenney UI Skinning | Historical | ✅ CLOSED | All UI buttons styled |
| ✅ Smart Scaling Fixes | Historical | ✅ CLOSED | Automatic sprite scaling |
| ⚙️ Batching Draw Calls | #16 | 🕒 TODO | Performance optimization |

#### Subgraph: Game Feel & FX (G_JUICE)

| Roadmap Item | Issue(s) | Status | Notes |
|---|---|---|---|
| 🎨 Particle System | #8 | 🕒 TODO | Boss combat particles |
| ✅ Screen Shake | Historical | ✅ CLOSED | Implemented in core |
| ✅ Squash & Stretch | Historical | ✅ CLOSED | Enemy sprite animations |
| ✅ Hit Flash | Historical | ✅ CLOSED | Visual feedback on hits |

---

### FILAR 3: ASSETY I SYSTEMY (PIPELINE)

#### Subgraph: Systemy Danych (G_SYS)

| Roadmap Item | Issue(s) | Status | Commit | Notes |
|---|---|---|---|---|
| ✅ JSON Save/Load | #4 | ✅ CLOSED | 9324e33 | Working system |
| ✅ Szyfrowanie Danych | #4 | ✅ CLOSED | 9324e33 | Encrypted saves |
| ✅ Audio Manager: Procedural + Bus Fix | #1 | ✅ CLOSED | **51fa613** | **Fixed today** |
| ✅ Inventory Grid & Potions | Historical | ✅ CLOSED | 34e7c4d | UI grid system |
| ✅ CardChoiceScene Null-checks | #2 | ✅ CLOSED | **51fa613** | **Fixed today** |
| ✅ UpgradeManager Validation | #3 | ✅ CLOSED | **51fa613** | **Fixed today** |

#### Subgraph: Zasoby (G_ASSETS)

| Roadmap Item | Issue(s) | Status | Notes |
|---|---|---|---|
| 🕒 Import: Sprite Sheets | #19 | 🕒 TODO | Organization needed |
| 🕒 Fonty: Custom .ttf | #18 | 🕒 TODO | Low priority |
| 🕒 SFX & Music Bus | #9 | 🕒 TODO | Boss audio effects |
| 🕒 Ikony Ekwipunku | #20 | 🕒 TODO | Equipment icons |

---

### FILAR 4: FABUŁA (NARRATIVE)

#### Subgraph: Scenariusz (G_LORE)

| Roadmap Item | Issue(s) | Status | Notes |
|---|---|---|---|
| 🎬 Intro: Skok w siano | #11 | 🕒 TODO | Complex animation needed |
| 💀 Boss: Saddam | #8, #9, #13 | 🕒 TODO | Visual/audio/dialogue |
| 🎒 Loot: Bicz z gumy | #5, #6, #7 | 🕒 TODO | Loot system foundation |
| 🔄 Prestiż: Sequel | #14, #15 | 🕒 TODO | New Game+ mechanics |
| 📜 Dziennik: 20 wpisów | #12 | 🕒 TODO | Lore log system |

---

## 📊 Issue Distribution by Roadmap Section

```
FILAR 1 (CORE):           5 issues ✅ (100% done)
├─ G_CORE               3 closed
└─ G_MECH               5 closed + 1 in-progress

FILAR 2 (TECH-ART):       9 issues (67% done)
├─ G_OPT                4 items (3 done, 1 todo)
└─ G_JUICE              4 items (3 done, 1 todo)

FILAR 3 (ASSETS):        10 issues (60% done)
├─ G_SYS                6 done, 0 todo
└─ G_ASSETS             0 done, 4 todo

FILAR 4 (NARRATIVE):      5 issues (0% done)
└─ G_LORE               0 done, 5 todo

TOTAL:                   29 issues & epics
Completed:              18+ ✅
In Progress:            0 🟢
Todo:                   11+ 🕒
```

---

## 🔄 Synchronization Workflow

### When Creating New Issue:
1. Determine which Roadmap section it belongs to
2. Reference in ISSUES.md as `[Roadmap: SECTION → ITEM]`
3. Update this file with issue mapping
4. Add issue to PROJECT_TRACKING.md board

### When Closing Issue:
1. Create commit with `fix/feat: Close #XX`
2. Reference roadmap item as resolved
3. Mark item as ✅ in Roadmap.md
4. Move from TODO to CLOSED in ISSUES.md
5. Update PROJECT_TRACKING.md metrics

### Weekly Sync Check:
- [ ] All CLOSED issues reflect roadmap ✅ items
- [ ] All TODO issues appear in ISSUES.md 🕒
- [ ] Backlog prioritization matches roadmap importance
- [ ] Velocity metrics are current

---

## 🎯 Current Sprint Focus → Roadmap Alignment

### Sprint: 2026-02-18 → 2026-02-28

**Planned Issues**
- #5, #6, #7 → G_LORE → L3 (Loot system)
- #8, #9 → G_JUICE + G_LORE → L2 (Boss effects)

**Roadmap Impact**
- Will move "🎒 Loot" from 🕒 to ✅
- Will move "💀 Boss FX" from 🕒 to 🟢 (in progress)

---

## 🚦 Status Legend

| Symbol | Meaning | Roadmap | Issues |
|---|---|---|---|
| ✅ | Complete | Green check | CLOSED |
| 🟢 | In Progress | Yellow circle | IN PROGRESS |
| 🕒 | Todo/Planned | Orange circle | TODO |
| 🎨 | Partial/In Design | Purple circle | DESIGN |
| ⚙️ | Technical Debt | Blue circle | TECH-DEBT |

---

## 📚 Reference Documents

1. **Roadmap.md** → Strategic planning (mermaid diagram)
2. **ISSUES.md** → Issue tracking & details
3. **PROJECT_TRACKING.md** → Sprint board & velocity
4. **SESSION_SUMMARY.md** → Session notes
5. **BUGFIX_CHANGELOG_2026-02-17.md** → Detailed fixes

---

**Maintained By:** GitHub Copilot + Developer Team  
**Update Frequency:** After each commit  
**Last Check:** 2026-02-17 @ 12:00 UTC  
**Next Check:** 2026-02-18 @ 10:00 UTC
