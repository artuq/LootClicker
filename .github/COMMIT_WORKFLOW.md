# Commit & Push Workflow

## 🔄 Automatic Push Configuration

**Status:** ✅ Configured via PowerShell Script

**How it works:**
1. Run: `.\commit.ps1 -message "Your message" -issues "3, 6"`
2. Script automatically stages, commits, and pushes
3. Changes appear on GitHub within seconds

---

## 📝 Using the Commit Script

### Basic Usage

```powershell
# Simple commit without issue reference
.\commit.ps1 -message "feat: Add new feature"

# Commit with single issue
.\commit.ps1 -message "fix: Repair bug" -issues "6"

# Commit with multiple issues (closes all listed)
.\commit.ps1 -message "feat: Implement loot system" -issues "3, 6, 8"

# Just commit message (full example)
.\commit.ps1 -message "docs: Update README and docs" -issues "2, 11"
```

### What the Script Does

```
1. Stages all changes:     git add .
2. Creates commit:         git commit -m "message (fixes #3, #6)"
3. Pushes to GitHub:       git push origin main
4. Shows success message:  ✅ Pushed to GitHub successfully!
```

---

## 📝 Commit Message Format

Always reference the GitHub Issue in your commit message:

```
<type>: <description> (fixes #<issue-number>)
```

### Examples:

```bash
# Single issue
.\commit.ps1 -message "feat: Implement loot drop system" -issues "3"

# Multiple issues (use commas and spaces)
.\commit.ps1 -message "fix: Repair AudioManager and card selection" -issues "2, 6"

# Without issue (not recommended)
.\commit.ps1 -message "chore: Update dependencies"
```

## 🎯 Issue Reference Guide

Link your commits to GitHub Issues:

| Issue | Category | Description |
|---|---|---|
| #2 | [ART] Oprawa audiowizualna i Game Feel | Audio, music, sound effects |
| #3 | [LORE] Implementacja fabuły i przedmiotów | Story, loot, items |
| #4 | [RELEASE] Przygotowanie do publikacji Google Play | Release prep, build |
| #6 | [POLISH] Ulepszanie istniejących mechanik | Bug fixes, improvements |
| #7 | [BIZNES] Monetyzacja, Marketing i Analityka | Business features |
| #8 | [ASSETS] Lista Zasobów do wykonania/zdobycia | Assets, sprites, audio |
| #9 | [ADMIN] Lokalizacja, Licencje i Organizacja | Admin, localization |
| #10 | [MVP] Zakres wersji 0.2 (English Only Release) | MVP features |
| #11 | [UI] Combat Arena - Styl "Action Bar" | UI, UX, layout |
| #12 | [ART] Styl Graficzny: Pixel Art (Stardew-like) | Graphics, pixel art style |

---

## 🚀 Quick Workflow (New Recommended)

```bash
# 1. Make changes in VS Code
# 2. When ready to commit, use script
.\commit.ps1 -message "feat: Feature name" -issues "3, 6"

# That's it! Script automatically:
# ✅ Stages changes
# ✅ Creates commit with issue reference
# ✅ Pushes to GitHub
# ✅ Shows results
```

---

## ⚠️ Troubleshooting

### Issue: "commit.ps1 cannot be loaded because running scripts is disabled"

**Solution:** Enable script execution for current user
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```
Then try again:
```powershell
.\commit.ps1 -message "Your message" -issues "3"
```

### Issue: "cannot spawn .git/hooks/post-commit"

This warning can be ignored - we're using PowerShell script instead.

### Issue: Push failed (credentials/network)

```powershell
# Check status
git status

# Try manual push
git push origin main

# Or check authentication
git config --list | Select-String "credential"
```

---

## 🔐 Private Repo Setup

Since project is now private:

1. ✅ Git credentials cached locally
2. ✅ No need for GitHub token setup
3. ✅ Auto-push script works seamlessly
4. ✅ All commits automatically reference issues

---

## 📊 How GitHub Uses Issue References

When you push with `fixes #3, #6`:
- ✅ Commit links to issues #3 and #6
- ✅ Issues show this commit in their timeline
- ✅ Close issue automatically when PR merged (if using PRs)
- ✅ GitHub projects auto-update status
- ✅ Creates complete audit trail

---

**Last Updated:** 2026-02-17 | **Script:** `commit.ps1`

