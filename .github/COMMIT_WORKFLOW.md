# Commit & Push Workflow

## 🔄 Automatic Push Configuration

After a commit is made, the `.git/hooks/post-commit` hook automatically pushes changes to GitHub.

**Status:** ✅ Configured

**How it works:**
1. You make a commit: `git commit -m "..."`
2. Hook automatically runs: `git push origin main`
3. Changes appear on GitHub within seconds

## 📝 Commit Message Format

Always reference the GitHub Issue in your commit message:

```
<type>: <description> (fixes #<issue-number>)
```

### Examples:

```bash
# Link to issues
git commit -m "feat: Implement loot drop system (fixes #6, #7)"
git commit -m "fix: Repair AudioManager bus validation (fixes #2)"
git commit -m "docs: Update Roadmap with completed tasks (fixes #3)"

# Types: feat, fix, docs, refactor, style, test, chore, ci, perf
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

## 🚀 Quick Workflow

```bash
# 1. Make changes in VS Code
# 2. Stage your changes
git add .

# 3. Commit with issue reference
git commit -m "feat: Add feature name (fixes #3, #6)"

# 4. Hook automatically pushes to GitHub! ✅
# No need to run `git push` manually
```

## ⚠️ If Auto-Push Fails

If auto-push fails (network issues, credentials expired):

```bash
# Manual push
git push origin main

# Or check status
git status
git log --oneline -5
```

## 📊 Documentation in GitHub

Every commit that closes an issue will:
1. **Automatically link** to the GitHub Issue
2. **Update the Issue** when merged/pushed
3. **Show in Project board** if configured
4. **Create commit history** for documentation

Use formats like:
- `fixes #3` - closes issue #3 when merged
- `resolves #6` - same as fixes
- `closes #8, #9` - closes multiple issues

## 🔐 Private Repo Setup

Since project is now private:

1. ✅ Git credentials cached locally
2. ✅ No need for GitHub token setup
3. ✅ Push works automatically with account auth
4. ✅ Auto-push hook configured

---

**Last Updated:** 2026-02-17
