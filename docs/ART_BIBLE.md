# ART BIBLE — Joana Indiana (LootClicker)

> **Status note:** This is a **retroactive art bible**. The game has already shipped
> (v0.7.0, Phase 1 release). This document does not invent a new visual direction —
> it documents and systematizes the direction that emerged organically across prior
> planning docs, so future decisions have one source of truth to check against.
>
> **This file does NOT duplicate per-character prompts.** For individual enemy/boss
> generation prompts, defer to:
> - [`docs/ART_PLAN.md`](ART_PLAN.md) — original per-character prompts (still canonical
>   for biome palettes, individual character briefs, and the normalization/cropping
>   recipe).
> - [`docs/ART_PLAN_V2.md`](ART_PLAN_V2.md) — current style/pipeline revision (pixel-art
>   mix, aggression pass, STYLE LOCK anchor system, `pixelate.py` workflow). **This is
>   the active production pipeline as of 2026-06-15.**
>
> Use this art bible for: visual identity statement, color/material/lighting language,
> UI direction, asset specs, and visual hierarchy rules. Use ART_PLAN / ART_PLAN_V2 for:
> "how do I generate enemy #N."

---

## Table of Contents
1. [Visual Identity Statement](#1-visual-identity-statement)
2. [Mood & Atmosphere](#2-mood--atmosphere)
3. [Shape Language](#3-shape-language)
4. [Color System](#4-color-system)
5. [Character Design Direction](#5-character-design-direction)
6. [Environment Design Language](#6-environment-design-language)
7. [UI/HUD Visual Direction](#7-uihud-visual-direction)
8. [Asset Standards](#8-asset-standards)
9. [Known Limitations & Visual Debt](#9-known-limitations--visual-debt)

---

## 1. Visual Identity Statement

**Joana Indiana** is a mobile idle-battler about an adventurer fighting absurd,
real-world-coded enemies (a burnt-out intern monkey, a sphinx demanding payment,
an influencer mid-meltdown) across pulpy adventure-movie biomes (jungle, temple,
desert). The visual identity exists to serve one promise: **the game is funny
because the threat is real.** Enemies are not cute mascots to pet — they are
genuine, aggressive obstacles whose comedy comes from *what* they are (a satire
of modern annoyances), not from softening *how* they look.

### Core Visual Pillars

**1. Pixel-art-mix readability over illustrative smoothness.**
Rendering uses hard, chunky pixels, a flat limited palette, and visible aliasing —
closer to *Stardew Valley* / *Cult of the Lamb* than to a smooth mobile-game
illustration. This is a deliberate correction (see ART_PLAN_V2 §0) away from the
"AI generator default" of soft cel-shaded chibi art. Smooth gradients, airbrush
shading, and glossy 3D rendering are explicitly prohibited (see §9 Style
Prohibitions below) because they read as generic mobile-gacha rather than
intentional pixel-art.

**2. Aggression is non-negotiable for anything hostile.**
Every enemy and boss must read as a genuine threat at a glance: furrowed brows,
bared teeth, a lunging/attacking pose. Comedy is delivered through context and
props (a briefcase, a selfie stick, a "50% OFF" sign), never through making the
enemy look harmless, sad, or passive. This is the single most-corrected drift in
the project's history (ART_PLAN_V2 was written specifically because V1 enemies
were "too cute, too passive" for a game where they're supposed to be fought) —
treat any future asset that looks adorable-but-toothless as a regression.

**3. Silhouette-first readability for mobile thumbnails.**
Every character must be identifiable by silhouette alone at small scale — this
game is played on phone screens, often one-handed, often with the player's
attention split. Oversized chibi heads (40-50% of body height), bold 2-4px black
outlines, and a single clear "weapon/prop" silhouette per character all exist to
serve this constraint. If a design only reads at full screen size and falls
apart as a 64px battle-arena thumbnail, it fails this pillar before any other
review.

**4. Free-tier visual parity — no pay-to-win signaling through art.**
Cosmetic or visual upgrades must never imply that a paying player's character,
enemies, or UI looks meaningfully more "complete" or "correct" than a free
player's. Monetization in this game (AdMob rewarded/banner/interstitial) is
about *convenience* (offline-earnings x2, revive), not visual exclusivity. Art
direction must not introduce visual tiers, locked color-grades, or "premium-look"
assets gated behind payment — every player should see the same fully-realized
art regardless of spend. This protects the game's stated no-pay-to-win pillar at
the visual layer, not just the systems layer.

---

## 2. Mood & Atmosphere

The game has no idle "exploration" mode — every screen is either a battle
against the current biome's backdrop, a result screen, or a menu/meta screen.
Mood is therefore carried almost entirely by **biome backdrop + UI chrome**,
since enemies themselves are uniformly aggressive regardless of biome (see §5).

### 2.1 Combat — per biome
Static background only (no parallax/animation, ISSUE-13 descoped — see §9).
Each biome's single background image is the *entire* atmospheric budget for
that stretch of stages, so its color temperature has to do real work.

- **Jungle (stages 1-14).** Warm, saturated, mid-bright green-and-gold
  (`#3d6e3a` foliage / `#8b6914` wood / `#c8a64b` light). Energy: scrappy,
  overgrown, slightly chaotic — the "starter zone" feel. Lighting character:
  flat daylight, no strong directional shadow implied (consistent with the
  flat cel-shaded character rendering — see §1 Pillar 1).
- **Temple (stages 15-35).** Cooler and more desaturated — stone gray
  (`#8c8378`) against turquoise moss accent (`#4a9e6b`) and gold trim
  (`#ffd700`). Energy: hushed, ancient, a little eerie (this is where the
  ghost/skeleton/golem roster lives) — but never horror-dark; gold accents
  keep it adventure-pulp rather than grim.
- **Desert (stages 36-55).** Hot, high-contrast, sun-bleached sand
  (`#e4b872`) against oasis turquoise (`#4fb3bf`) and sun-orange
  (`#f58a4a`). Energy: harsh and exposed — the brightest, most saturated
  biome, deliberately the "hardest-feeling" before the late-game.
- Cross-biome read: Jungle = lush/green, Temple = stone/cool, Desert =
  sand/hot. No biome should ever be recolored into another's hue range —
  that cross-check is the cheapest way to catch a mis-tinted asset.

### 2.2 Victory
Victory screen carries the one moment of unambiguous warmth/reward in the
game: golden border (`#c7c219` StyleBoxFlat, ISSUE-12) + loot icons. This is
intentional — combat poses and biome backdrops stay tense/aggressive, so
victory needs to read as a clear emotional release via gold = reward (see
§4 color semantics). No biome-specific victory variant exists; the gold
treatment is constant across all three biomes by design (reward language
should not drift with biome the way threat language does).

### 2.3 Defeat / Revive Prompt
Defeat does not currently have a distinct moody treatment documented in
existing docs — by default it inherits the same instant-appear UI behavior
as other screens (no fade-to-red, no dimming, ISSUE-22 backlog). Functionally
the revive-prompt's job is monetization (rewarded-ad revive), not atmosphere,
so it should read as a *neutral, low-friction utility screen* rather than a
punishing one — consistent with Pillar 4 (no pay-to-win shaming). **Open
question:** if/when ISSUE-22 is picked up, recommend a brief desaturation or
cool-down tint on defeat (signals "loss" without guilt-tripping the player
into a purchase) — flagging this as a future decision, not a current gap to
fix now.

### 2.4 Menus / Skill Tree / Card Draft
- **Menus (inventory, stats, nav).** Carry the custom UI kit's warm parchment
  palette (per ISSUE-12 font-color tuning) — calm, low-energy, legible-first.
  This is deliberately the most neutral mood in the game; menus are where the
  player slows down to make a build decision, so nothing here should compete
  visually with combat's aggression.
- **Card draft (cursed level-up cards).** Highest-energy menu moment by
  design — tween pop-in/scale/fade (`TRANS_BACK` ease-out, confirmed in
  `CardChoiceScene.gd`) gives this screen the only "juiced" non-combat
  interaction currently shipped. Mood target: a quick dopamine beat before
  returning to combat — bright, decisive, fast.
- **Skill tree (hex grid, ISSUE-21).** Treated as a colder, more deliberate
  "planning" mood — no enemy-style aggression language belongs here; this is
  the one screen where the player should feel in control rather than under
  threat.

---

## 3. Shape Language

### 3.1 Character silhouette philosophy
The logical screen is **360×640** — characters render small, often at a
fraction of that height inside the battle arena. Silhouette is therefore not
a nice-to-have, it's the primary identity carrier (Pillar 3, §1). Concretely:

- **Oversized chibi head (40-50% of body height)** is the single biggest
  silhouette lever — it reads at thumbnail size when body detail won't.
- **One clear prop/weapon silhouette per character** (acorn-bomb, selfie
  stick, briefcase, velvet rope) — never two competing props, since a small
  silhouette can only afford one extra "bump" before it turns into noise.
- **Bold 2-4px black outline** (2-3px regular enemy, 3-4px boss) exists
  specifically to hold the silhouette together against any background at
  small scale — this is a readability tool, not a stylistic flourish, so it
  must never be thinned out "for elegance."
- **Pose must be asymmetric and lunging**, not a static idle T-pose-like
  silhouette — symmetric/passive poses are the fastest way to accidentally
  reintroduce the "cute" drift V2 was built to correct (§1 Pillar 2).

### 3.2 Environment geometry
Biome backgrounds are currently **single static painted images**, not
modular/geometric scene-built environments (see §6) — so "environment shape
language" here means the shape language *within* that single image, not a
prop-kit grammar. Each biome's background should favor a few large, clear
shape masses (canopy silhouette / pyramid-and-column silhouette / dune-and-
oasis silhouette) over busy fine detail, so the background stays a quiet
backdrop and never competes with the foreground enemy's silhouette — this is
the same hierarchy principle as ISSUE-13's "keep combat visually quiet"
rationale.

### 3.3 UI shape grammar — distinct HUD language, not world-echo
The custom "Joana Indiana" UI kit (`assets/New sprites/` — WINDOW_PANEL_BIG/
SMALL, GAME_BUTTON_NORMAL/PRESSED/DISABLED, FRAME_RING_NORMAL/BOSS, bottom-nav
tab background, inventory backpack icon) reads as a **distinct HUD language**
from the pixel-art-aggressive world: warm parchment panels, rounded buttons,
soft-edged frames. This is a deliberate (if implicit) split, not an
inconsistency to fix:

- World layer (enemies, bosses, biome backgrounds) = hard pixels, aggressive
  shapes, sharp black outlines.
- HUD layer (panels, buttons, bars, frames) = softer-edged, parchment-styled
  chrome whose job is legibility and touch-target clarity, not pixel-art
  fidelity.

This split is defensible under Gestalt figure-ground principles — a busy
pixel-art HUD competing with pixel-art enemies would collapse the
figure/ground separation the player needs to parse "what's UI vs what's
world" in a fast tap-combat loop. **Recommendation: keep this split
explicit and intentional** rather than pushing the UI kit toward harder
pixel-art rendering — see §7 for the fuller UI direction discussion.

### 3.4 Hero vs supporting shapes
"Hero shape" in this game is the **boss silhouette**, not a player-avatar
silhouette (no on-screen player character exists — see §5.1 open question).
Boss shapes get more silhouette budget than regular enemies: larger canvas
fill (~90% vs ~85%), an extra outline weight step (3-4px vs 2-3px), and a
permitted second silhouette read (aura/glow, per PREFIX_BOSS_V2) that regular
enemies don't get. Regular enemies must stay visually "lighter" than any
boss at a glance — if a regular enemy's silhouette reads as heavier/more
imposing than the upcoming boss on that stage, that's a hierarchy violation.

---

## 4. Color System

### 4.1 Semantic color roles (world + economy)
These meanings are established by existing icon/resource art and should be
treated as fixed vocabulary — reusing them differently elsewhere would
confuse the player's learned associations:

| Color | Hex (anchor use) | Meaning in this world |
|---|---|---|
| Gold/yellow | `#ffd700` | Reward, currency-adjacent, "boss-tier" prestige (boss auras, victory border, coin icon) |
| Red | `#cc3344` | Danger/aggression marker — anger veins, bloodshot eyes, damage-adjacent accents. NOT used for currency or reward. |
| Green (turquoise-leaning) | `#3d6e3a` (jungle) / `#4a9e6b` (temple moss) / `#5aff5a` (glow) | Biome-identity green AND status/venom glow — context-dependent, disambiguated by where it appears (background tint vs. character glow) |
| Black | `#1a1a2e` | Universal outline/structure color — not a semantic "danger" black, just the line-work anchor color used everywhere (see §3.1, §8.3 boss outline fix) |
| Magenta | `#FF00FF` | Production-only chroma key — must never appear in a shipped asset; if magenta is visible on any in-game sprite, that's a cutout bug, not a style choice |

Currency/resource icons (coin, cog, bandage, venom, crystal —
`assets/icons/`) each carry their own material-coded color (gold coin,
silver cog, etc.) rather than a single "currency color" — this works because
each resource has a unique icon shape too, so color is a secondary not
primary cue here.

### 4.2 Per-biome color temperature
(Restating the hex anchors from ART_PLAN.md §1 biome table so this bible is
self-contained for quick reference — ART_PLAN.md remains canonical if these
ever drift.)

- **Jungle (1-14):** warm-mid, `#3d6e3a` green / `#8b6914` wood /
  `#c8a64b` light-gold. Saturated but not hot — "lush," not "harsh."
- **Temple (15-35):** cool-desaturated, `#8c8378` stone / `#ffd700` gold
  accent / `#4a9e6b` turquoise moss. The coolest, quietest biome.
- **Desert (36-55):** hot-saturated, `#e4b872` sand / `#4fb3bf` oasis
  turquoise / `#f58a4a` sun-orange. The hottest, highest-contrast biome.

Temperature should escalate roughly warm→cool→hot across progression rather
than a smooth gradient — this is already the shipped order and gives each
biome transition a clear "we're somewhere new" jolt rather than a gradual
fade.

### 4.3 UI palette vs world palette
Per §3.3, the UI kit intentionally runs a **separate, warmer "parchment"
palette** from the world/combat palette — this is consistent with treating
HUD as a distinct visual language rather than a world-skinned one. UI palette
should stay close to neutral warm tones (cream/parchment/brown) so it never
competes with — or gets mistaken for — biome-specific world color (e.g., UI
should not borrow Temple's turquoise or Desert's orange as its own accent,
or a panel could misread as biome-specific environmental art).

### 4.4 Colorblind-safety notes — rarity tiers
`GameItem.gd` defines rarity colors as **White / Cyan / Purple / Orange**
(`Color.WHITE / Color.CYAN / Color.PURPLE / Color.ORANGE`). Flagging real
risk here:

- **Purple vs. the game's other blues/cyans** is a known deuteranopia/
  tritanopia confusion zone — purple can shift toward gray-blue and become
  hard to distinguish from Cyan for some colorblind players.
- **Orange vs. Gold (`#ffd700`, used for boss/reward semantics elsewhere,
  §4.1)** is a moderate-risk pairing for protanopia/deuteranopia — both can
  desaturate toward a similar yellow-brown.
- **Backup cue already exists and is load-bearing:** rarity is also conveyed
  by the item's **text label** ("Common/Rare/Epic/Legendary") wherever the
  color is shown (confirmed pattern in `InventorySlot.gd` usage of
  `GameItem.get_color()` alongside item name text) — so the system is
  already not color-only by accident. **Recommendation: keep the rarity text
  label mandatory everywhere the rarity color appears** (never ship a
  color-only rarity chip/swatch with no text), since that's the only thing
  standing between this palette and a real accessibility failure. This is
  documentation of an existing safeguard, not a new requirement — flagging
  it so it doesn't get silently dropped in a future UI pass.

---

## 5. Character Design Direction

### 5.1 Player-character visual presence — checked, not assumed
Checked `GameBattleManager.gd` and the scene tree for a player-avatar sprite
reference: **none exists.** This is a tap/idle battler where the player taps
the enemy directly — there is no on-screen "Joana Indiana" character sprite
in combat today (the player's presence is represented by HP/XP bars, the
tap-target enemy, and UI, not by an avatar). Treat this as a **confirmed
current state**, not an open design gap to silently fill. If an on-screen
player character is ever added (e.g., for a future "player attacks" visual
beat), it would need its own pass through this bible (proportions, outline
weight, palette) rather than inheriting enemy specs by default — flagging as
a forward-looking note, not a task.

### 5.2 Enemy vs. boss distinguishing-feature rules
- **Regular enemy:** one joke-prop, one attack-pose, 2-3px outline, 384×384,
  fills ~85% of canvas, 3-tone flat shading. The joke is delivered through
  the prop/context (briefcase, selfie stick), the pose is uniformly
  "lunging forward, ready to attack" — see PREFIX_ENEMY_V2.
- **Named boss:** larger canvas (512×512, ~90% fill), heavier outline
  (3-4px, **must be solid black `#1a1a2e`** — see §8.3 for the B1 gold-
  outline incident this rule was written to prevent), 4-tone shading (one
  more tone step than regular enemies), and a permitted second silhouette
  read via aura/glow effects that regular enemies don't get. Bosses are
  "menacing + imposing" where regular enemies are just "menacing" — the
  imposing half is the differentiator (bigger presence, accessories/props
  that signal authority: crown, headdress, gear).

### 5.3 Expression/pose targets per archetype
Largely locked by the anchor (`assets/_anchor_squirrel.png`) and
PREFIX_ENEMY_V2/PREFIX_BOSS_V2 — restated concretely here for quick recall:

- **Regular enemy:** furrowed angry brows, bared teeth/fangs, wide
  glaring/bloodshot eyes, one dynamic lunging pose toward the viewer.
  Never cute, never passive, never sad — this is the most-corrected drift
  in the project (§1 Pillar 2) and the fastest thing to check at a glance.
- **Named boss:** all of the above, **plus** a confident/dominant posture
  (not just angry — entitled/imposing), and a "performance" beat specific
  to their joke (Idol mid-sneeze-explosion, Brad mid-meltdown, Sphinx
  mid-swipe demanding payment, Saddam deadpan amid chaos). The deadpan
  exception (Saddam/B4) is intentional — not every boss needs a screaming
  face if the joke is "calm in the middle of absurd danger"; the *pose*
  carries the threat instead of the expression in that one case.

### 5.4 Render-detail philosophy (no animation system — see §9)
There is no idle/hit/death animation system yet (ISSUE-14, suspended), so
"LOD" in this bible means **render detail appropriate to actual on-screen
sprite size**, not animation frame budgets. Practically: detail invested in
fine texture (fur strands, fabric folds) that disappears at the in-arena
display size is wasted production time — the `pixelate.py` pass (§8.2)
already enforces a detail ceiling via `--res`/`--colors`, so character
prompts should not over-describe micro-detail that gets quantized away
anyway. Spend detail budget on the silhouette and the one signature prop
(§3.1), not on surface texture fidelity.

---

## 6. Environment Design Language

### 6.1 Per-biome architectural/narrative identity
Each biome's single static background carries the entire "what part of the
world is this" storytelling job (no modular scene-built environment exists
to share that load — see 6.3):

- **Jungle (1-14).** Overgrown, scrappy, low-stakes "starter zone" —
  communicates *this world's threats are everywhide, ordinary annoyances
  taken too far* (intern monkeys, dieting plants). Narrative logic: jungle
  = entry point, comedy is domestic/relatable before it gets mythological.
- **Temple (15-35).** Ancient stone ruin — communicates *this world has a
  buried, slightly cursed history* (mummies, golems, idol bosses). Narrative
  logic: the comedy escalates from "annoying coworker" to "ancient curse
  with modern baggage" (budget golem, allergic idol).
- **Desert (36-55).** Open, exposed, commercialized wasteland —
  communicates *capitalism followed you into the desert* (pyramid-scheme
  scarab, sandstone bouncer, Karen). Narrative logic: the harshest
  environment hosts the most aggressively "annoying modern world" jokes,
  reinforcing biome-as-escalation rather than biome-as-random-skin.

### 6.2 Texture philosophy
Same hard-pixel-mix mandate as characters (§1 Pillar 1) — biome backgrounds
should not be painted/PBR-style illustrations with smooth gradients and soft
ambient occlusion, even though they currently sit a notch closer to
"painted" than the characters do (`Jungle.jpeg`/`Temple.jpeg` predate the V2
pixel-art correction). **Open flag, not a current task:** background art has
not been put through the same V2 pixel-art-mix correction that enemies have
— if/when biome backgrounds are revisited, they should go through an
equivalent hard-pixel pass so character and background don't visually
mismatch (chunky pixel character on a smooth-gradient background is the same
class of inconsistency the V2 pipeline was built to fix for characters).

### 6.3 Prop density — current state, not aspiration
Backgrounds are **single static full-scene images per biome**, not a
prop-kit/modular scene built from individual placeable assets. There is no
prop density standard to define here because there is no prop system —
documenting a "props per square meter" guideline would describe a pipeline
that doesn't exist and shouldn't be invented speculatively. If a modular
prop system is ever built (e.g., to support biome variation within a stage
range), that would warrant a dedicated planning pass with technical-artist
before this section gets a prop-density standard.

### 6.4 Environmental storytelling — guidance for future expansion
If backgrounds ever gain props/layers, prioritize props that reinforce the
biome's narrative logic in 6.1 (e.g., Desert: a cracked "GRAND OPENING" sign
half-buried in sand; Temple: a gift-shop kiosk built into ruins) over purely
decorative scenery — the comedy pillar (§1 Pillar 1, USP) should extend into
environment storytelling the same way it already does in enemy design, not
just stay confined to character props.

---

## 7. UI/HUD Visual Direction

### 7.1 Does pixel-art-aggressive world style conflict with mobile-readable UI?
Reasoned through this directly rather than treating it as settled: pixel-art
rendering and "clean, readable mobile UI" are not inherently in conflict —
*Stardew Valley* and *Cult of the Lamb* (this project's own references, §1)
both ship pixel-art worlds with legible UI. The actual risk is **outline-
weight and color-saturation bleed**, not the pixel-art technique itself: if
HUD elements adopted the same heavy 2-4px black outlines and saturated
flat-shading as enemies, text legibility and touch-target clarity would
suffer at 360×640 logical resolution, because the HUD has a different job
(fast parsing under thumb pressure, not silhouette-at-a-glance threat
reading). The project's existing solution — a **distinct, softer-edged
parchment HUD language** (§3.3, §4.3) sitting visually apart from the hard-
pixel world layer — is the right call, not a compromise to fix. Recommend
keeping this split rather than unifying the two languages.

### 7.2 Current shipped state (verified, not assumed)
- **Custom "Joana Indiana" UI kit is shipped** (ISSUE-12, 2026-06-15
  iteration): shared-frame/tintable-fill HP/XP/enemy bars, `GAME_BUTTON_
  NORMAL/PRESSED/DISABLED`, `WINDOW_PANEL_BIG/SMALL`, `FRAME_RING_NORMAL/
  BOSS`, bottom-nav tab background, inventory backpack icon — all sourced
  from `assets/New sprites/`. This fully replaced the earlier generic
  Kenney UI kit.
- **StageBar (`StageBar.tscn`)** — 5-node progression bar with biome
  thumbnails + rings — shipped, functions as the game's persistent
  "where am I in this run" visual hierarchy anchor.
- **Card-choice tap feedback/juice is shipped** (confirmed in
  `CardChoiceScene.gd`: scale-bounce + modulate-flash on selection,
  `TRANS_BACK` ease-out pop-ins for card entry, fade/scale-out on exit,
  tutorial-hand idle-bounce loop). This is currently the single most
  "polished-feeling" interaction in the game — worth treating as the
  reference quality bar for any future UI juice pass.
- **Scene-transition juice does NOT exist yet** (ISSUE-22, backlog) —
  screens instantly appear/disappear with no fade/slide/scale-in. Do not
  describe transitions as already "snappy" or "polished" in any future
  pitch deck or store material; this is a known, tracked gap.

### 7.3 Visual hierarchy priorities for combat HUD
In descending priority (what the eye must find first):
1. **Current HP (player and enemy)** — life-or-death information, must
   win every visual contest on screen.
2. **Tap target (the enemy itself)** — the actual interaction point.
3. **XP/stage progress (StageBar)** — secondary, persistent but glanceable.
4. **Currency/resource counters** — tertiary, lowest visual weight; these
   should never out-compete HP bars for attention even though they're the
   "exciting" numbers going up.

### 7.4 Open question for ux-designer alignment
Per the collaboration protocol, UI/HUD direction should be cross-checked
with `ux-designer` for interaction-flow concerns this bible doesn't cover
(touch-target sizing validation, one-handed reachability on 360×640,
whether the card-draft juice quality bar should extend to the currently-
un-juiced ISSUE-22 transitions). Flagging this as a recommended next step
rather than resolving it unilaterally here — visual direction and
interaction design are adjacent but distinct responsibilities.

---

## 8. Asset Standards

### 8.1 Resolution & format
- **Regular enemy sprite:** 384×384 PNG, transparent background, character
  fills ~85% of canvas, centered.
- **Boss sprite:** 512×512 PNG, transparent background, character fills
  ~90% of canvas, centered.
- **Source generation canvas:** 1024×1024, solid magenta `#FF00FF`
  background (chroma key) — cut to transparency before normalization, never
  shipped with magenta visible.
- **Godot import settings:** Filter = **NEAREST** (preserves hard pixels),
  Mipmaps = **Off**, Fix Alpha Border = **On**.

### 8.2 The mandatory STYLE LOCK production pipeline
This is the **required workflow for any new character art going forward**
(enemy or boss) — not optional, not a "nice when you remember it" step. Per
ART_PLAN_V2 §1.3/§2:

1. **Generate** with the appropriate prefix (`PREFIX_ENEMY_V2` /
   `PREFIX_BOSS_V2`) + the character brief + the **STYLE LOCK clause**,
   attaching `assets/_anchor_squirrel.png` as an image reference (plus the
   character's own existing PNG as a second reference, if regenerating an
   existing design — identity takes priority over style if only one
   reference slot is available; `pixelate.py` reconciles style after).
2. **Cut** magenta to transparency (Photopea Select→Color Range).
3. **Normalize**: trim, square canvas, character at 88% fill, centered.
4. **Pixelate** — run `execution/pixelate.py` with **identical flags per
   asset class** as the second consistency lock:
   - Enemy: `--res 110 --colors 32 --out 384`
   - Boss: `--res 150 --colors 40 --out 512`
5. **Re-import** into Godot with the settings in §8.1.

This two-lock system (image-reference + style-lock-clause, then identical
pixelate.py settings) exists specifically because text-only prompting drifts
between generations (ART_PLAN_V2 §0) — skipping either lock reintroduces the
drift it was built to kill. **Boss regeneration note:** all 5 pending bosses
(idol, brad, sphinx, saddam, ramboses) must use the current `PREFIX_BOSS_V2`,
which mandates a solid black `#1a1a2e` 3-4px outline — this was added after
B1/Idol shipped with an incorrect gold outline; the prompt fix exists, the
re-render does not yet (see §9).

### 8.3 Naming convention — document reality, do not invent a new scheme
**Actual current convention is plain `snake_case`**, no category/variant/
size tokens: `squirrel.png`, `monkey.png`, `boss_idol.png`, `boss_brad.png`.
Biome-specific enemies live in subfolders (`enemies/jungle/`,
`enemies/temple/`, `enemies/desert/`) rather than encoding biome in the
filename itself.

**Recommendation: keep this convention as-is.** Retrofitting a more
elaborate scheme (e.g. `char_[name]_[variant]_[size].png`) is explicitly
**not recommended right now** — every existing filename is referenced by
exact string path in `GameBattleManager.gd`'s enemy roster arrays and in
`.tscn` scene files. A rename pass would require finding and updating every
reference simultaneously with zero tolerance for a missed path (a missed
rename = a broken/missing sprite in a shipped game), for a purely cosmetic
naming-convention gain. If a naming scheme is ever introduced, it should be
scoped as new content only (new biomes, new bosses) rather than a retroactive
rename of the existing 15 enemies + 5 bosses — flagging this risk explicitly
per the brief's instruction.

### 8.4 UI/HUD asset sourcing
UI kit source files (panels, buttons, frames, nav icons) live in
`assets/New sprites/` — this is the one and only location for that asset
set; it is not duplicated elsewhere in the repo. New UI assets should be
added there following the existing files' naming pattern (descriptive,
mostly UPPERCASE or Title_Case depending on file — e.g. `WINDOW_PANEL_BIG`,
`Game_button_normal`) rather than introducing the enemy-sprite snake_case
convention into the UI kit, since the two asset families are sourced/
versioned independently in current practice.

---

## 9. Known Limitations & Visual Debt

This section exists so the art bible reflects actual shipped production maturity,
not an idealized end-state. Items below are accepted, tracked gaps — not silent
assumptions.

- **Enemies are static single-image sprites.** No idle/hit/death animation system
  exists yet. Tracked and suspended: `docs/issues/ISSUE-14_enemy_animations.md`.
- **No scene-transition or UI-entry juice.** Screens currently appear instantly
  (no fade/slide/scale-in). Tracked, backlog: `docs/issues/ISSUE-22_ui_transitions_and_animations.md`.
- **5 bosses (B1 Idol, B2 Brad, B3 Sphinx, B4 Saddam, B55 Ramboses) are still on
  the pre-V2 smooth/cute render and have not been regenerated under the
  pixel-art-mix + aggression pipeline.** All 15 regular enemies are done. See
  ART_PLAN_V2 §0 status block and `docs/issues/ISSUE-11_enemy_sprite_upgrade.md`.
- **No moving/parallax backgrounds — by deliberate decision, not oversight.**
  Static biome backgrounds only, to keep combat visually quiet and focused.
  Closed as DESCOPE: `docs/issues/ISSUE-13_parallax_background.md`. Do not
  re-propose without a fresh UX/FPS benchmark per that issue's note.
- ~~Style anchor file not yet saved.~~ **Resolved 2026-06-18.**
  `assets/_anchor_squirrel.png` was missing from the repo (the load-bearing
  reference image the whole STYLE LOCK system depends on, per ART_PLAN_V2
  §1.3) and has now been saved from the shipped V2 squirrel sprite. The
  STYLE LOCK pipeline (§8.2) is now actually usable for the pending boss
  regeneration pass.
