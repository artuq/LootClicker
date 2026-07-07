---
name: project-art-bible
description: LootClicker (Joana Indiana) retroactive art bible — structure, status, and doc hierarchy
metadata:
  type: project
---

Created `docs/ART_BIBLE.md` (2026-06-18) as a retroactive art bible for the
already-shipped Joana Indiana mobile idle-battler (Godot 4.6.2, Android). Section 1
(Visual Identity Statement, 4 pillars) is drafted; Sections 2-9 are skeleton-only,
pending future sessions.

**Why:** The project had no single visual source of truth — direction was scattered
across `docs/ART_PLAN.md` (per-character prompts, still canonical, do not duplicate),
`docs/ART_PLAN_V2.md` (style/pipeline revision: pixel-art mix + aggression, "Angry
Kaboom Squirrel" anchor, STYLE LOCK clause, `pixelate.py` post-process — this is the
CURRENT active pipeline), and various `docs/issues/ISSUE-*.md` files.

**How to apply:** Future art-bible work must defer to ART_PLAN/ART_PLAN_V2 for
per-character prompts rather than restate them — the bible only covers
identity/color/UI/specs/hierarchy at the systemic level. See also
[[feedback_user_doc_conventions]] for this user's specific doc-location and audit
preferences.

**Known production state as of 2026-06-15 (verify before reuse — may have moved on):**
- All 15 regular enemies regenerated under V2 pixel-art+aggression pipeline. Confirmed via
  `docs/issues/ISSUE-11_enemy_sprite_upgrade.md` and ART_PLAN_V2 status block.
- 5 bosses (B1 idol, B2 brad, B3 sphinx, B4 saddam, B55 ramboses) NOT yet regenerated —
  still on older smooth/cute render. This is the single biggest documented style-drift gap.
- `assets/_anchor_squirrel.png` (the literal style-lock reference image) has never been
  written to the repo — confirmed via Glob, zero results. The whole STYLE LOCK system
  depends on this file existing; until it does, "match the anchor" is intent, not an
  enforceable check.
- Accepted/deliberate visual debt (not bugs): static enemies (no idle/hit/death anim,
  ISSUE-14 suspended), no scene-transition juice (ISSUE-22 backlog), no parallax/moving
  backgrounds (ISSUE-13, deliberately descoped — do not re-propose without fresh FPS
  benchmark per that issue).
- CAUTION: ISSUE-23 (card-choice tap feedback) acceptance checkboxes are marked `[X]`
  done, and README.md FAZA logs a 2026-03-07 "bottom nav juice" update — this contradicts
  a framing of "card feedback is still abrupt." Re-verify actual current state in
  `src/scenes/CardChoiceScene.gd` before asserting it's still raw/unfinished.
