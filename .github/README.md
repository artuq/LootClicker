# .github Directory - Project Management

This directory contains all issue tracking, project management, and CI/CD configuration for the LootClicker project.

## 📁 Files

### Core Documentation

| File | Purpose | Update Frequency |
|---|---|---|
| **ISSUES.md** | Central issue tracker linked to Roadmap | Daily (after commits) |
| **PROJECT_TRACKING.md** | Sprint board, velocity metrics, milestones | Daily (after standup) |
| **ROADMAP_ISSUES_MAP.md** | Synchronization map between Roadmap & Issues | Weekly review |

---

## 🔄 How It All Works

### 1. **ISSUES.md** - The Source of Truth for Issues
- Lists all 20+ issues with status, priority, complexity
- 4 sections: Closed ✅ | In Progress 🟢 | Todo 🕒
- Linked to commits and Roadmap sections
- **Update:** Create issue → Add to backlog → Move through columns

### 2. **PROJECT_TRACKING.md** - The Sprint Board
- Visual sprint status with card-style board
- Velocity metrics and historical data
- Dependencies and blockers
- Sprint planning template
- **Update:** Daily sprint standup, move cards, update metrics

### 3. **ROADMAP_ISSUES_MAP.md** - The Synchronization Layer
- Maps each Roadmap section → Issues
- Shows completion status for each FILAR
- Workflow for keeping Roadmap ↔ Issues in sync
- **Update:** Weekly review (Sunday 10:00 UTC)

---

## 📊 Synchronization Rules

### When Creating an Issue:
1. Fork from ROADMAP.md section (FILAR → Subgraph → Item)
2. Add to ISSUES.md backlog
3. Reference in PROJECT_TRACKING.md
4. Update ROADMAP_ISSUES_MAP.md

### When Closing an Issue:
```bash
git commit -m "fix: Close #XX - Description

- Implement feature
- Commit hash: [auto-linked]
- Roadmap section updated
- Issue moved to CLOSED"
```

**Then:**
1. Move from TODO → CLOSED in ISSUES.md
2. Update Roadmap.md section (🕒 → ✅)
3. Update velocity in PROJECT_TRACKING.md
4. Update ROADMAP_ISSUES_MAP.md metrics

---

## 🎯 Project Structure

```
LootClicker/
├── .github/
│   ├── ISSUES.md                  ← Issue tracker
│   ├── PROJECT_TRACKING.md         ← Sprint board
│   ├── ROADMAP_ISSUES_MAP.md       ← Sync map
│   └── workflows/                  ← (Future CI/CD)
│
├── docs/
│   ├── Roadmap.md                 ← Strategic vision (mermaid diagram)
│   ├── SessionSummary.md          ← Session notes
│   ├── BUGFIX_CHANGELOG_2026-02-17.md
│   └── [other docs]
│
├── src/                           ← Source code
├── assets/                        ← Game assets
└── [project files]
```

---

## 📈 Current Status

```
Total Issues:        20
├─ Closed:          4 ✅
├─ In Progress:     0 🟢
└─ Backlog:        16 🕒

Roadmap Coverage:   29 items
├─ Completed:      18 ✅ (62%)
├─ In Progress:     0 🟢 (0%)
└─ Todo:           11 🕒 (38%)

Latest Sprint:     2026-02-17
├─ Items Done:      5
├─ Velocity:        5 items/day
└─ Next Sprint:     2026-02-18
```

---

## 🚀 Quick Start

### For Developers:
1. Read [ROADMAP.md](../docs/Roadmap.md) for the big picture
2. Check [ISSUES.md](ISSUES.md) for what to work on
3. Pick high-priority item from [PROJECT_TRACKING.md](PROJECT_TRACKING.md)

### For Project Managers:
1. Review [PROJECT_TRACKING.md](PROJECT_TRACKING.md) for sprint status
2. Check [ROADMAP_ISSUES_MAP.md](ROADMAP_ISSUES_MAP.md) for alignment
3. Weekly sync: Compare Roadmap ↔ Issues ↔ Projects

### For Setting Up Scripts:
- Use `ISSUES.md` as data source for CI/CD automations
- Reference issue numbers in commits: `#5`, `#8`, etc.
- Workflows in `.github/workflows/` (coming soon)

---

## 📝 Maintenance Schedule

| Task | Frequency | Owner | Checklist |
|---|---|---|---|
| Issue Status Check | Daily | Developer | [ ] Move items in columns |
| Velocity Update | Daily | Developer | [ ] Update metrics |
| Sprint Planning | Weekly (Sun 10:00) | PM | [ ] Pick next sprint items |
| Roadmap Sync | Weekly (Sun 10:00) | PM | [ ] Check Roadmap ↔ Issues |
| Release Planning | Monthly | Owner | [ ] Plan milestone |

---

## 🔗 Related Files

- [Roadmap.md](../docs/Roadmap.md) - Mermaid strategic diagram
- [SessionSummary.md](../docs/SessionSummary.md) - Session notes
- [BUGFIX_CHANGELOG_2026-02-17.md](../docs/BUGFIX_CHANGELOG_2026-02-17.md) - Detailed bug info
- [.gemini_session_checkpoint.json](../.gemini_session_checkpoint.json) - Session state

---

## 💡 Best Practices

### Do's ✅
- ✅ Update issues immediately after commits
- ✅ Link issues in commit messages: `fix: Close #XX`
- ✅ Keep Roadmap and Issues synchronized
- ✅ Regular sync meetings (weekly)
- ✅ Track velocity for sprint planning

### Don'ts ❌
- ❌ Let issues drift from Roadmap
- ❌ Create issues without Roadmap section
- ❌ Forget to move cards through columns
- ❌ Update only one tracking system (sync all 3!)
- ❌ Leave old sprint data - archive it

---

## 📞 Contact

**Project Owner:** Developer  
**Maintained By:** GitHub Copilot + Team  
**Last Updated:** 2026-02-17  
**Next Review:** 2026-02-18 @ 10:00 UTC

---

## 🎓 Learning Resources

### For New Team Members:
1. Start with Roadmap.md (5 min read)
2. Review ISSUES.md backlog (10 min)
3. Check PROJECT_TRACKING.md current sprint (5 min)
4. Read ROADMAP_ISSUES_MAP.md sync workflow (5 min)

### For Questions:
- "What are we building?" → Roadmap.md
- "What needs to be done?" → ISSUES.md
- "What are we doing this week?" → PROJECT_TRACKING.md
- "How does it all fit together?" → ROADMAP_ISSUES_MAP.md
