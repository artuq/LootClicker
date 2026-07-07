# Game Concept — Joana Indiana (LootClicker)

> **Status:** Retroactive document. The game is already implemented and LIVE on Google Play
> (`com.artuq.lootclicker2`, v0.8.x). This file was written after the fact to unblock
> ccgs-template skills (e.g. `/art-bible`) that require it — it is not a pre-production
> brainstorm output. Source of truth for what's actually shipped remains
> `docs/Roadmap.md`, `docs/ART_PLAN_V2.md`, and the codebase itself.

## Working Title
Joana Indiana (package: LootClicker)

## Elevator Pitch
A free tap/idle RPG where you punch through a jungle, a cursed temple, and an Egyptian
desert full of the dumbest enemies imaginable — a squirrel clutching a lit stick of
dynamite, a burnt-out intern monkey mid-meltdown, a "Sand Karen" mummy demanding to
speak to the pharaoh, an influencer boss screaming "like and subscribe," and a final
boss who's a deadpan warlord standing on a tiny raft holding a rubber duck. Under the
jokes is a real progression loop: skill tree, cursed risk/reward level-up cards, and
50+ scaling stages with a boss every 5th.

## Core Fantasy
You're an adventurer steamrolling an absurd, comedic world — competence and progression
played completely straight, while everything around you is a joke.

## Game Pillars
1. **Absurd comedy roster** — every enemy/boss is a one-line joke made physical; this is
   the game's actual USP and what drives organic sharing/marketing.
2. **Real systems under the jokes** — skill tree (STR/HP/SPD/CRIT to 50), cursed
   level-up card drafts, adrenaline combo window — players who came for the joke stay
   for the loop.
3. **Free, ad-supported, no pay-to-win** — no IAP store, no energy system; monetization
   is rewarded ads (offline x2, revive) plus forced interstitials at a fixed cadence.
4. **Mobile-first, short-session tap loop** — designed for `click -> damage feedback ->
   loot/reward -> next stage`, playable in short bursts.

## Platform
Android (Google Play), mobile-first portrait, Godot 4.6.2.

## Current Content (as shipped, v0.7.0+)
- **3 biomes:** Jungle (stages 1-14), Temple (15-35), Desert (36-55).
- **15 unique enemies** + 5 named bosses (Idol, Brad, Sphinx, Saddam, Ramboses).
- **Systems:** skill tree, cursed level-up cards, adrenaline combo, linear scaling past
  stage 30, inventory/equipment, daily login, offline rewards.

## Visual Identity Anchor (from docs/ART_PLAN_V2.md)
- **Anchor:** "Angry Kaboom Squirrel" — V2 art style reference all other characters must
  match (image-reference + style-lock clause + identical pixelate.py post-process).
- **One-line rule:** chibi-proportioned, hard-pixel (not smooth illustration) cel-shaded
  characters that read as **aggressive and threatening**, not cute/passive — comedy
  comes from concept/props, not from softness.
- Full detail lives in `docs/ART_PLAN_V2.md` — this anchor is referenced, not duplicated,
  here.

## Out of Scope / Explicitly Not This Game
- Not a hardcore/competitive idle game — no PvP, no leaderboards (not currently planned).
- Not pay-to-win — no IAP shop for power.
- Not photorealistic or horror-toned — stays cartoon/comedic even for "scary" bosses.
