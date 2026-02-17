# LootClicker - Issue Tracking (GitHub Synced)

**Last Updated:** 2026-02-17 | **Synced with:** GitHub Issues | **GitHub Link:** [artuq/LootClicker/issues](https://github.com/artuq/LootClicker/issues)

---

## ⚠️ Important Note

This file tracks **actual GitHub Issues** (#2-#12) which map to project categories. The separate `.github/ISSUES.md` was created as a local issue tracking system but is now aligned with existing real GitHub Issues.

---

## 🟢 Active Issues (In Progress)

> None at the moment - all critical issues resolved!

---

## ✅ Closed Issues (Resolved)

### Session 2026-02-17 Critical Bugfixes
These were **internal fixes** applied to the codebase. GitHub issues #2-#12 represent broader categories:

| Description | Status | Commit | Notes |
|---|---|---|---|
| **Audio: Master Bus Validation** | ✅ CLOSED | `51fa613` | AudioManager fix - affects #2 (Game Feel) |
| **Crash: Game exits after first enemy** | ✅ CLOSED | `51fa613` | CardChoiceScene fix - affects #3, #6 |
| **UI: Wrong upgrade card icons** | ✅ CLOSED | `51fa613` | UpgradeManager fix - affects #6 (Polish) |
| **Save/Load: Missing new stats** | ✅ CLOSED | `51fa613` | GameBattleManager fix - affects #3, #6 |

**Documentation:** See [BUGFIX_CHANGELOG_2026-02-17.md](../docs/BUGFIX_CHANGELOG_2026-02-17.md)

---

## 🕒 Open Issues (Real GitHub Issues)

### Strategic/Meta Issues

| ID | Title | Status | Opened | Comments |
|---|---|---|---|---|
| #12 | **[ART] Styl Graficzny: Pixel Art (Stardew-like)** | 🕒 OPEN | 4d ago | 7 |
| #11 | **[UI] Combat Arena - Styl "Action Bar"** | 🕒 OPEN | 4d ago | 9 |
| #10 | **[MVP] Zakres wersji 0.2 (English Only Release)** | 🕒 OPEN | 4d ago | 19 |
| #9 | **[ADMIN] Lokalizacja, Licencje i Organizacja** | 🕒 OPEN | 4d ago | 1 |
| #8 | **[ASSETS] Lista Zasobów do wykonania/zdobycia** | 🕒 OPEN | 4d ago | 4 |
| #7 | **[BIZNES] Monetyzacja, Marketing i Analityka** | 🕒 OPEN | 4d ago | 0 |
| #6 | **[POLISH] Ulepszanie istniejących mechanik (Backlog)** | 🕒 OPEN | 4d ago | 20 |
| #5 | *(appears to be missing)* | ❓ | - | - |
| #4 | **[RELEASE] Przygotowanie do publikacji Google Play** | 🕒 OPEN | 4d ago | 0 |
| #3 | **[LORE] Implementacja fabuły i przedmiotów** | 🕒 OPEN | 4d ago | 2 |
| #2 | **[ART] Oprawa audiowizualna i Game Feel** | 🕒 OPEN | 4d ago | 0 |

### Closed Issues (Hidden)
GitHub shows **3 Closed** issues, but they're not visible in the main list view.

---

## 📊 Summary Statistics

| Category | Count | Status |
|---|---|---|
| **Total Open Issues** | 10 visible | 🕒 |
| **Total Closed Issues** | 3 | ✅ |
| **Total Issues** | 13+ | 🎯 |
| **Last Activity** | 4 days ago | 📅 |
| **Most Discussed** | #6 (20 comments), #10 (19 comments) | 💬 |

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
