---
name: feedback-user-doc-conventions
description: User's conventions for where planning/art docs live and how audits should be sourced
metadata:
  type: feedback
---

This user keeps ALL planning docs under `docs/` (not `design/art/` or similar) —
confirmed explicitly for `docs/ART_BIBLE.md`. Default to `docs/` for any new
planning/design markdown in this repo unless told otherwise.

**Why:** Project convention predates this agent; user corrected the default
location assumption explicitly rather than letting the agent infer a structure.

**How to apply:** When creating new project documentation (art bible, design docs,
audits), place it in `docs/` alongside ART_PLAN.md, ART_PLAN_V2.md, and
`docs/issues/`. Do not propose a new top-level docs hierarchy without asking.

Also: this user wants visual/asset audits sourced from DOCUMENTED evidence
(issue statuses, plan status blocks) rather than attempted direct image
inspection — confirmed because PNGs can't be read meaningfully via text tools
anyway, but the user explicitly framed the audit instruction this way. Cross-check
multiple docs (e.g. ART_PLAN_V2 status block AND the corresponding ISSUE-*.md)
since they can drift out of sync with each other and with README.md's roadmap
table — flag contradictions rather than picking one source silently. See
[[project_art_bible]] for an example contradiction found (ISSUE-23 marked done
in its own file's checkboxes, but referenced as still-abrupt in a later prompt).
