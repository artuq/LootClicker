# LootClicker - Issue Tracking

**Last Updated:** 2026-02-17 | **Synced with:** `Roadmap.md` | **GitHub Link:** [artuq/LootClicker/issues](https://github.com/artuq/LootClicker/issues)

---

## 🟢 Active Issues (In Progress)

> None at the moment - all critical issues resolved!

---

## ✅ Closed Issues (Resolved)

### Critical Bugs (Fixed 2026-02-17)

| ID | Title | Status | Commit | Roadmap Link |
|---|---|---|---|---|
| #1 | **Audio: Master Bus Validation** | ✅ CLOSED | `51fa613` | `G_SYS → S3` |
| #2 | **Crash: Game exits after defeating first enemy** | ✅ CLOSED | `51fa613` | `G_SYS → S5` |
| #3 | **UI: Upgrade cards show wrong icons (dodge/block)** | ✅ CLOSED | `51fa613` | `G_SYS → S6` |
| #4 | **Save/Load: Missing dodge_chance and block_chance** | ✅ CLOSED | `51fa613` | `G_SYS → S1` |

**Documentation:** See [BUGFIX_CHANGELOG_2026-02-17.md](../docs/BUGFIX_CHANGELOG_2026-02-17.md)

---

## 🕒 Open Issues (Backlog)

### Loot System (HIGH PRIORITY)

| ID | Title | Status | Priority | Roadmap Link | Est. Complexity |
|---|---|---|---|---|---|
| #5 | **Implement loot drop system** | 🕒 TODO | 🔴 HIGH | `(NEW)` | Medium |
| #6 | **Design loot table & drop rates** | 🕒 TODO | 🔴 HIGH | `(NEW)` | Low |
| #7 | **Create GameItem prefab system** | 🕒 TODO | 🔴 HIGH | `(NEW)` | Medium |

### Boss System (MEDIUM PRIORITY)

| ID | Title | Status | Priority | Roadmap Link | Est. Complexity |
|---|---|---|---|---|---|
| #8 | **Boss-specific visual effects** | 🕒 TODO | 🟡 MEDIUM | `G_JUICE → J1` | Medium |
| #9 | **Boss-specific audio effects** | 🕒 TODO | 🟡 MEDIUM | `G_SYS → S3` | Low |
| #10 | **Boss health/damage scaling balance** | 🕒 TODO | 🟡 MEDIUM | `G_MECH → M2` | Low |

### Story & Narrative (MEDIUM PRIORITY)

| ID | Title | Status | Priority | Roadmap Link | Est. Complexity |
|---|---|---|---|---|---|
| #11 | **Intro sequence: Skip/Watch option** | 🕒 TODO | 🟡 MEDIUM | `G_LORE → L1` | High |
| #12 | **Lore logs system & UI** | 🕒 TODO | 🟡 MEDIUM | `G_LORE → L5` | High |
| #13 | **Boss dialogue text** | 🕒 TODO | 🟡 MEDIUM | `G_LORE → L2` | Low |

### Prestige System (LOW PRIORITY)

| ID | Title | Status | Priority | Roadmap Link | Est. Complexity |
|---|---|---|---|---|---|
| #14 | **Prestige/New Game+ mechanics** | 🕒 TODO | 🟢 LOW | `G_LORE → L4` | High |
| #15 | **Prestige reward balancing** | 🕒 TODO | 🟢 LOW | `(NEW)` | Medium |

### Performance & Optimization (LOW PRIORITY)

| ID | Title | Status | Priority | Roadmap Link | Est. Complexity |
|---|---|---|---|---|---|
| #16 | **Draw call batching analysis** | 🕒 TODO | 🟢 LOW | `G_OPT → O4` | Medium |
| #17 | **Memory profiling & optimization** | 🕒 TODO | 🟢 LOW | `(NEW)` | High |

### Assets & Polish (LOW PRIORITY)

| ID | Title | Status | Priority | Roadmap Link | Est. Complexity |
|---|---|---|---|---|---|
| #18 | **Custom TTF fonts import** | 🕒 TODO | 🟢 LOW | `G_ASSETS → A2` | Low |
| #19 | **Sprite sheet organization** | 🕒 TODO | 🟢 LOW | `G_ASSETS → A1` | Low |
| #20 | **Equipment icons pack** | 🕒 TODO | 🟢 LOW | `G_ASSETS → A4` | Low |

---

## 📊 Summary Statistics

| Category | Count | Status |
|---|---|---|
| **Total Issues** | 20 | 🎯 |
| **Closed** | 4 | ✅ |
| **In Progress** | 0 | 🟢 |
| **Open (Backlog)** | 16 | 🕒 |
| **High Priority** | 3 | 🔴 |
| **Medium Priority** | 7 | 🟡 |
| **Low Priority** | 6 | 🟢 |

---

## 🔄 Synchronization Rules

1. **Issue Created** → Add to this file → Map to Roadmap.md section
2. **Issue In Progress** → Mark 🟢 IN PROGRESS here + update Project board
3. **Issue Closed** → Move to ✅ CLOSED section + reference commit hash
4. **Roadmap Updated** → Verify issues align with sections
5. **Daily Review** → Check this file before/after each session

---

## 📌 How to Use This File

### Creating a New Issue
```markdown
| #XX | **Feature Name** | 🕒 TODO | 🔴/🟡/🟢 | `Section` | Complexity |
```

### Closing an Issue
1. Move row from **Open Issues** to **Closed Issues**
2. Add commit hash in Status column
3. Update Roadmap.md section (mark as ✅)
4. Commit to git with message: `fix/feat: Close #XX - Description`

### Updating Priority
- 🔴 HIGH - Start next
- 🟡 MEDIUM - Queue for after high priority
- 🟢 LOW - Add to backlog

---

**Last Sync:** 2026-02-17 @ 11:50 UTC  
**Maintained By:** GitHub Copilot + Developer  
**Related Files:** [Roadmap.md](../docs/Roadmap.md) | [SessionSummary.md](../docs/SessionSummary.md) | [PROJECT_TRACKING.md](PROJECT_TRACKING.md)
