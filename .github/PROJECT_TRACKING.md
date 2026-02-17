# LootClicker - Project Tracking Board

**Status:** Active Development | **Last Updated:** 2026-02-17 | **Sprint:** Continuous

---

## 📋 Current Sprint (2026-02-17 → 2026-02-28)

### 🏁 Sprint Goals

1. ✅ **Resolve all critical bugs** (COMPLETED)
2. 🕒 **Implement loot drop system** (CURRENT)
3. 🕒 **Add boss-specific effects** (NEXT)
4. 🕒 **Story/narrative foundations** (PLANNED)

---

## 📊 Project Board: Columns & Cards

### ✅ DONE (Completed Items)

```
┌─────────────────────────────────────────────────────────────┐
│ ✅ AudioManager: Master Bus Validation                      │
│    Commit: 51fa613 | Issue: #1 | Roadmap: G_SYS → S3       │
│    Fixed: bus existence checks + error logging               │
├─────────────────────────────────────────────────────────────┤
│ ✅ CardChoiceScene: Null-check Guards                       │
│    Commit: 51fa613 | Issue: #2 | Roadmap: G_SYS → S5       │
│    Fixed: crash on level-up after defeating first enemy      │
├─────────────────────────────────────────────────────────────┤
│ ✅ UpgradeManager: Card Icons & Validation                  │
│    Commit: 51fa613 | Issue: #3 | Roadmap: G_SYS → S6       │
│    Fixed: dodge/block cards + unknown upgrade handling      │
├─────────────────────────────────────────────────────────────┤
│ ✅ GameBattleManager: Save/Load Sync                        │
│    Commit: 51fa613 | Issue: #4 | Roadmap: G_SYS → S1       │
│    Fixed: dodge_chance & block_chance persistence          │
├─────────────────────────────────────────────────────────────┤
│ ✅ Documentation: Bugfix Changelog                          │
│    Commit: d68d8f5 | Issue: N/A | Roadmap: DOCS            │
│    Added: BUGFIX_CHANGELOG_2026-02-17.md                   │
└─────────────────────────────────────────────────────────────┘
```

┌─────────────────────────────────────────────────────────────┐
│ ✅ AI-Generated Icons: bandage, venom, coin, crystal        │
│    Commit: 2be4035 | Issue: #8, #12 | Roadmap: ART          │
│    Added: Bing Image Creator pixel art icons (4 resources)  │
├─────────────────────────────────────────────────────────────┤
│ ✅ HUD Layout Redesign: Split TopHUD + MidHUD               │
│    Commits: d75edb2..aba8053 | Issue: #11 | Roadmap: UI     │
│    Changed: TopBar+Enemy (top), Gold+HP (mid), Bottom (same)│
├─────────────────────────────────────────────────────────────┤
│ ✅ XP Bar Real-time Updates + Signal System                 │
│    Commit: f3eb983 | Issue: #6 | Roadmap: G_SYS             │
│    Added: xp_changed signal, live XP bar updates            │
├─────────────────────────────────────────────────────────────┤
│ ✅ CardChoiceScene Text Wrapping Fix                        │
│    Commit: f3eb983 | Issue: #6 | Roadmap: UI                │
│    Fixed: custom_minimum_size + font_size for card text     │
└─────────────────────────────────────────────────────────────┘

**Items in DONE:** 9  
**Estimated Hours:** 10h  
**Actual Hours:** ~7h (efficient work)

---

### 🟢 IN PROGRESS (Currently Working)

```
┌─────────────────────────────────────────────────────────────┐
│ (None - Awaiting assignment)                                │
│                                                              │
│ Next up: #5 - Implement loot drop system                   │
│ Estimated Start: 2026-02-18                                 │
│ Assigned to: [Ready for implementation]                     │
└─────────────────────────────────────────────────────────────┘
```

**Items in PROGRESS:** 0

---

### 🕒 TO DO (Backlog - Prioritized)

#### 🔴 CRITICAL (Do First)

```
┌─────────────────────────────────────────────────────────────┐
│ #5 - Implement Loot Drop System                             │
│ Priority: 🔴 CRITICAL | Complexity: MEDIUM                 │
│ Description: Enemies drop GameItem resources on death      │
│ Roadmap: (NEW - Core Mechanic)                             │
│ Subtasks:                                                   │
│   ├─ Design loot table & drop rates (#6)                   │
│   ├─ Create GameItem prefab system (#7)                    │
│   └─ Integrate with inventory UI                           │
│ Estimated: 8h | Start Date: 2026-02-18                    │
├─────────────────────────────────────────────────────────────┤
│ Notes:                                                       │
│ - Will unlock prestige/progression mechanic                 │
│ - Requires new data structure (LootTable)                   │
│ - Should sync with UpgradeManager & InventoryManager       │
└─────────────────────────────────────────────────────────────┘
```

#### 🟡 HIGH (Do Next)

```
┌─────────────────────────────────────────────────────────────┐
│ #8 - Boss-Specific Visual Effects                           │
│ Priority: 🟡 HIGH | Complexity: MEDIUM                     │
│ Roadmap: G_JUICE → J1 (Particle System)                    │
│ Estimated: 6h                                               │
├─────────────────────────────────────────────────────────────┤
│ #9 - Boss-Specific Audio Effects                           │
│ Priority: 🟡 HIGH | Complexity: LOW                        │
│ Roadmap: G_SYS → S3 (Audio Manager)                        │
│ Estimated: 3h                                               │
├─────────────────────────────────────────────────────────────┤
│ #11 - Intro Sequence (Skip/Watch)                          │
│ Priority: 🟡 HIGH | Complexity: HIGH                       │
│ Roadmap: G_LORE → L1 (Scenariusz)                          │
│ Estimated: 8h                                               │
└─────────────────────────────────────────────────────────────┘
```

#### 🟢 OPTIONAL (When Time Permits)

```
┌─────────────────────────────────────────────────────────────┐
│ #14 - Prestige/New Game+ System                             │
│ Priority: 🟢 LOW | Complexity: HIGH                        │
│ Roadmap: G_LORE → L4 (Prestiż)                             │
│ Estimated: 12h                                              │
├─────────────────────────────────────────────────────────────┤
│ #16 - Performance: Draw Call Batching                       │
│ Priority: 🟢 LOW | Complexity: MEDIUM                      │
│ Roadmap: G_OPT → O4 (Batching)                             │
│ Estimated: 6h (if needed)                                   │
└─────────────────────────────────────────────────────────────┘
```

**Total Backlog Items:** 16  
**Total Estimated Hours:** ~60h  
**Estimated Completion (at 2h/day):** ~4 weeks

---

## 📈 Velocity & Metrics

### Current Sprint (2026-02-17)

| Metric | Value | Status |
|---|---|---|
| **Sprint Duration** | 1 day | ⏱️ |
| **Items Completed** | 5 | ✅ |
| **Items Started** | 5 | ✅ |
| **Velocity (items/day)** | 5 | 🚀 |
| **Hour Estimate Accuracy** | ~66% | 📊 |
| **Blockers** | 0 | ✅ Clear |

### Historical Velocity

| Sprint | Items | Hours | Velocity |
|---|---|---|---|
| 2026-02-17 | 9 | 7h | 9 items/day |
| 2026-02-15 | 8 | 12h | 4 items/3 days |
| 2026-02-13 | 6 | 10h | 3 items/2 days |

---

## 🎯 Milestone Tracking

### Q1 2026 Milestones

```
[================================================] 55% Complete

✅ v0.1 - Foundation (DONE)
   └─ Basic combat, HP bars, inventory, save/load
   └─ UI/UX overhaul, code reorganization

🟢 v0.2 - Loot & Progression (IN PROGRESS - Starting)
   └─ Loot drop system
   └─ Boss effects + narrative intro
   └─ Estimated: 2 weeks

🕒 v0.3 - Story & Prestige (PLANNED)
   └─ Full narrative arc
   └─ Prestige mechanics
   └─ Estimated: 2 weeks later

🕒 v1.0 - Polish & Release (FUTURE)
   └─ Performance optimization
   └─ QA/Playtesting
   └─ Estimated: 1 month
```

---

## 🔗 Dependencies & Blockers

### Active Dependencies

| From | To | Type | Status |
|---|---|---|---|
| #8 (Boss VFX) | #10 (Boss Scaling) | "must have" | ✅ No Blocker |
| #5 (Loot) | G_SYS (Inventory) | "uses" | ✅ Ready |
| #11 (Intro) | #13 (Dialogue) | "includes" | 🕒 Awaiting |

### Current Blockers

> None! All systems are ready for next sprint.

---

## 📅 Sprint Planning Template

```
## Sprint: 2026-02-18 → 2026-02-24 (Proposed)

### Goal
- [x] Complete loot drop system (#5, #6, #7)
- [ ] Begin boss-specific effects (#8, #9)

### Backlog Selection
- #5 (8h) - Loot system implementation
- #6 (3h) - Loot table design
- #7 (5h) - GameItem prefab creation
- #8 (6h) - Boss visual effects (if time permits)

### Capacity
- Hours Available: ~16h (2h/day × 8 days)
- Estimated Burn: 16h
- Buffer: 0h (tight schedule)

### Risks
- [ ] Complex loot integration might overrun
- [ ] Requires new data structures
- [ ] May need inventory UI tweaks
```

---

## 🔄 Board Management Rules

1. **Only 1 item may be IN PROGRESS at a time**
2. **Move item to DONE only after:**
   - Code is complete
   - Changes are committed to git
   - Related issue is linked
   - Roadmap is updated
3. **Review backlog weekly** (every Sunday)
4. **Update velocity metrics daily**

---

**Project Owner:** Developer  
**Maintained By:** GitHub Copilot  
**Last Reviewed:** 2026-02-17 @ 13:30 UTC  
**Next Review:** 2026-02-18 @ 10:00 UTC

---

## Related Files

- [ISSUES.md](.github/ISSUES.md) - Issue list & tracking
- [../docs/Roadmap.md](../docs/Roadmap.md) - Long-term vision
- [../docs/SessionSummary.md](../docs/SessionSummary.md) - Session notes
- [../docs/BUGFIX_CHANGELOG_2026-02-17.md](../docs/BUGFIX_CHANGELOG_2026-02-17.md) - Detailed bug info
