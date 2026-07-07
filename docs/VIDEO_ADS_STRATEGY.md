# 🎬 Joana Indiana — Video/TikTok Scripts

> Gotowe scenariusze na krótkie formy wideo (TikTok / YouTube Shorts / Reels).
> Wydzielone z `GAME_ADS_STRATEGY.md` — tu będą dopisywane kolejne warianty
> i wytyczne do konkretnych filmików.

---

### 📱 TikTok / YouTube Shorts — Script #1: "Level 1 vs Level 50"

**Format:** 15s, 9:16, bez ciszy na starcie — wideo zaczyna się DOKŁADNIE w momencie pierwszego dużego obrażenia.

| Czas | Co na ekranie | Tekst overlay |
|---|---|---|
| 0:00-0:03 | Joana ledwo drapie Angry Kaboom Squirrel, "2 DMG" małą czcionką, powolna animacja | `LEVEL 1...` |
| 0:03-0:04 | Szybkie cięcie, flash biały ekran | *(brak — cisza przed bum)* |
| 0:04-0:08 | Eksplozja koloru, "9999!" ogromną czcionką, złoto sypie się kaskadą, card pick z CURSED aurą | `...LEVEL 50` |
| 0:08-0:12 | Walka z Saddamem na tratwie z gumową kaczką, combo critów | `MEET THE BOSSES` |
| 0:12-0:15 | Logo + CTA | `JOANA INDIANA — Free on Google Play` |

**Caption:**
```
POV: zaczynasz jako słaba archeolożka, kończysz walcząc z facetem na dmuchanym kole 🦆
Free pixel-art clicker — link w bio

#mobilegame #clickergame #idlegame #pixelart #indiegame #fyp
```

---

### 📱 TikTok / YouTube Shorts — Script #2: "Devlog / Solo dev"

**Hook (must land w pierwszej sekundzie):**
```
"Zrobiłem grę, w której walczysz z rolką papieru toaletowego. Oceńcie mojego potwora 💀"
```

**Treść (15-30s):**
- 0:00-0:03 — hook + zbliżenie na sprite "Toilet Paper Mummy"
- 0:03-0:08 — szybki montaż: ekran kodu w Godocie → pierwszy działający sprite → pierwszy crash/błąd (samo-ironiczny moment)
- 0:08-0:13 — gameplay: walka, level up, boss greeting bubble
- 0:13-0:15 — "Free on Google Play, link in bio"

**Caption:**
```
Pracuję na etacie, a wieczorami uczyłem się kodować od zera, żeby zrobić tę grę.
Dziś jest dostępna za darmo. Co o niej myślicie? 👇

#gamedev #indiegame #soloDev #polishgamedev #pixelart
```

---

# EP1 — JOANA INDIANA — Production Package (DIY, real gameplay capture)
**"Tap. Loot. Conquer. — Meet the Memeiest Bosses on Google Play"**
Format: YouTube Shorts / TikTok 9:16 · 30fps · **15s max** · 5 scenes (~3s each)

> 15s = the length already proven in the storyboard in `GAME_ADS_STRATEGY.md`
> ("15-sekundowy storyboard"). Dense cuts, ~3s per beat, no fades.

> **Key difference vs. the Fortnite/Mario EP4 sheet:** that video had to be generated
> from scratch with AI (nano_banana + image-to-video) because the source material
> didn't exist. **Here it does** — Joana Indiana is a finished, playable game with its
> own pixel-art, music and animations. **No AI scene generation needed.** Every "scene"
> below = a real screen recording captured directly from the game. This is faster,
> cheaper (zero generation credits) and 100% authentic — exactly what Reddit/TikTok
> reward in an indie-dev post.

---

## GLOBAL — How to capture footage
- **Android screen recording:** built-in recorder (Quick Settings → Screen record) or
  `adb shell screenrecord /sdcard/clip.mp4` for cleaner capture without the status bar.
- **Record in 1080×1920 (native portrait)** — matches Shorts/TikTok 9:16, no cropping.
- **Capture each moment separately** as its own short clip (10-20s), over-record and
  trim in the edit — easier to find the "perfect crit" than to scrub one long take.
- **What to have ready before recording** (from the existing checklist in
  `GAME_ADS_STRATEGY.md`):
  - [ ] save file at stage 30+ (high-level gear, big damage numbers)
  - [ ] at least one CURSED card active (visual "depth")
  - [ ] full HP / good RNG run queued up so combat looks smooth, not like a struggle

## GLOBAL — Voice settings (ElevenLabs)
- **Voice:** reuse **Henry** (`7wG1Xb86NcD408WGmfbJ`) for channel consistency with EP4
  — same energetic, slightly cheeky read works for comedy-clicker tone. (Alternative:
  pick a more "movie-trailer-narrator" voice if you want a deliberately over-the-top
  90s-game-ad parody read — fits the boss-roster humor angle.)
- Model: **eleven_multilingual_v2** · Speed **1.15** · Stability 0.4 · Similarity 0.8
- Generate per-line (not as one block) — easier to sync each VO line to its scene cut.

## GLOBAL — Music (use the GAME'S OWN tracks — already owned, zero licensing risk)
The game ships with its own OST in `assets/audio/` — using it is free, on-brand, and
doubles as a teaser for the in-game audio:
- `boss_theme.mp3` → boss-roster montage (scene 2)
- `jungle_theme.mp3` / `temple_theme.mp3` → biome-transition montage (scene 3)
- `victory_jingle.mp3` → victory/CTA outro (scene 5)
Mix the chosen track under the VO at ~15-20% volume; let `victory_jingle.mp3` hit at
full volume for the last 1-2s as a punchy outro stinger.

## GLOBAL — On-screen text style
Pixel font **Press Start 2P** (matches the game's own UI), bottom-third or center,
white/yellow with black outline, ≥1.5s hold per line so it's readable on a phone.
Add over the footage in the edit (CapCut/DaVinci) — never relies on in-game UI text.

---

## TIMELINE (15s total — 5 beats × 3s)
| Scene | Time | Source footage |
|-------|------|----------------|
| 0 Hook — big crit number | 0:00–0:03 | combat clip, "9999!" floating text + crit flash |
| 1 Boss flash-cuts | 0:03–0:06 | 2 quick cuts: Brad + Saddam greeting bubbles |
| 2 Cursed card pick | 0:06–0:09 | card-pick screen, landing on CURSED aura |
| 3 Biome jump | 0:09–0:12 | one hard cut Jungle → Desert, stage counter "5" → "50" |
| 4 CTA — logo + install | 0:12–0:15 | victory flash → logo + "FREE — GOOGLE PLAY" |

> Tight 3s beats — no room for slow builds. Each clip = ONE striking moment, trimmed
> to its peak frame. If a beat needs more than 3s to read, it's the wrong footage —
> find a punchier moment instead of stretching the clip.
>
> **Note on the Hook Frame below:** it's NOT an extra beat — it's a ~0.5s freeze
> that leads INTO Scene 0 (shave Scene 0's clip to ~2.5s so the total stays at 15s).

---

## HOOK FRAME / THUMBNAIL — the ONE thing worth generating with AI
Everything else in this package is real captured gameplay — but a "shocked/hyped
Joana" close-up reaction shot almost certainly does NOT exist as in-game footage
(the game has no such cutscene). That's the one frame worth generating, because it
doubles as both the opening 0:00 freeze-frame AND the YouTube/TikTok thumbnail
(proven format from EP4: big expressive face + bold title = scroll-stopper).

**Reference images to feed the model (consistency — same trick as "Peely reference"
in EP4):** `assets/icons/icon_joana_1024.png` (canonical Joana portrait — blonde
wavy hair, brown fedora, green crop top, brown shorts, leather belt + coiled whip,
jungle temple-ruins backdrop) + 1-2 of the in-game **chibi enemy/boss sprites**
(`assets/sprites/enemies/boss_brad.png` is the ART_PLAN reference for "most polished
sprite, use as style guide for all new characters") so the model matches the actual
**in-game chibi pixel-art style** (per `ART_PLAN.md`: "chibi cartoon pixel art, strong
black outlines, flat shading — closer to Stardew Valley/Cult of the Lamb than 16-bit").

**nano banana prompt:**
```
Using the attached Joana Indiana key-art portrait as the character reference (blonde
wavy hair, brown fedora hat, green crop top, brown shorts, leather belt with coiled
whip) and the attached boss sprite as the art-style reference: redraw Joana in the
EXACT SAME chibi cartoon pixel-art style as the style reference — big head, small
body, strong 2-3px black outlines, flat cel-shading, bright saturated colors, hard
pixel edges, no anti-aliasing, no gradients. Pose: huge shocked/hyped expression,
wide eyes, open mouth, both fists raised in excitement, as if she just found a giant
pile of treasure. Background: a bright jungle-temple ruins scene matching the game's
biome backgrounds. Big empty area on the left third of the frame for a title overlay.
NO text, NO UI, NO logos baked in.
ONE single full-screen vertical 9:16 scene, not split into panels, not a sprite
sheet, no dividing line — one continuous image only.
```

**Overlay text (added in edit, pixel font Press Start 2P, bold + black outline):**
`TAP. LOOT.` (yellow) big `CONQUER!` (red) — small `FREE 👀` corner badge.
**Use:** hold as the 0:00 freeze-frame for ~0.5s before the hard-cut into the crit
number (Scene 0), AND export separately as the uploaded video thumbnail.

---

## SCENE 0 — HOOK: big crit number (0:00–0:03)
**Footage:** combat moment where a crit spawns a large floating damage number
(e.g. "9999!" in gold/red) with the crit flash VFX and a coin burst.
**VO:** *"Tap once."* (single beat — let the number do the talking)
**SFX:** the game's own hit/crit sound, pulled straight from the recording.
**On-screen text:** none — the damage number IS the hook. Hard cut in, no fade.

## SCENE 1 — BOSS FLASH-CUTS (0:03–0:06)
**Footage:** 2 cuts (~1.5s each) — Brad the Influencer's greeting bubble
("Don't forget to like and subscribe!") → hard cut to Saddam on the Raft's
ultimate-boss entrance with the rubber duck.
**VO:** *"...meet a pharaoh on a pool float."*
**Music:** `boss_theme.mp3` hits on the cut to Saddam.
**On-screen text:** `MEET THE BOSSES` flashes once across both cuts.

## SCENE 2 — CURSED CARD PICK (0:06–0:09)
**Footage:** level-up screen, hand/cursor lands on the CURSED card, red aura flares.
**VO:** *"Pick a card — if you dare."*
**On-screen text:** `CURSED?!` (red, shake effect).

## SCENE 3 — BIOME JUMP (0:09–0:12)
**Footage:** ONE hard cut from Jungle background/Stage 5 to Desert background/Stage 50
— sells "the world keeps growing" in a single splice, no slow pan.
**VO:** *"Stage 5... Stage 50."*
**Music:** snap-cut from `jungle_theme.mp3` to `boss_theme.mp3` on the splice.
**On-screen text:** `STAGE 5` → instant swap to `STAGE 50`.

## SCENE 4 — CTA: logo + install (0:12–0:15)
**Footage:** 0.5s flash of the victory/loot-explosion screen, then hard-cut to the
**Joana Indiana logo** (`brand_kit/logo_1024x1024.png`) on a clean background.
**VO:** *"Free. On Google Play. Now."*
**Music:** `victory_jingle.mp3` outro stinger at full volume for the last ~1.5s.
**On-screen text:** `JOANA INDIANA` (logo) + `FREE — GOOGLE PLAY` (static, holds
through the freeze frame — matches the CTA pattern from `GAME_ADS_STRATEGY.md`).

---

## FULL VO SCRIPT (one block — ~15s read at speed 1.15)
```
Tap once.
...meet a pharaoh on a pool float.
Pick a card — if you dare.
Stage 5... Stage 50.
Free. On Google Play. Now.
```

## EDIT NOTES
- **Hard cuts only — zero fades.** At 15s every frame counts; fades waste time.
- Each clip = its single peak moment, trimmed tight. No idle frames, no slow builds.
- Add a 1-2 frame white flash on the Scene 3 biome splice — sells the "jump" instantly.
- The crit number in Scene 0 must read within the first 0.3s — that's the make-or-break.
- Captions burned in (most viewers watch muted) — never rely on VO alone.

## TITLE / SEO (upload)
- Title: `This Free Mobile Game Has the Weirdest Bosses Ever 🦆`
- Tags: idle clicker game, mobile rpg, pixel art game, indie game android, loot clicker, free android game, boss fight game

## Cost estimate
**$0 in generation credits** — every frame is real captured gameplay + the game's own
OST. Only cost is your time recording/editing + ~5 short ElevenLabs VO lines (15s read).

---

# 🤖 ALTERNATYWA — One-shot ~10s AI video (Gemini Veo 3)

> **Po co:** zamiast nagrywania + montażu (powyżej), **jeden strzał** w Gemini Veo 3 —
> model generuje **całe wideo + natywne audio** (VO, SFX, muzyka) w jednej generacji.
> My piszemy prompt i dorzucamy **1-3 screeny gry jako referencję stylu**; Veo dogrywa
> ruch, kamerę, głos, dźwięki i (próbuje) napisy. Pionowy 9:16, pod Shorts/TikTok/Reklamy.
>
> ⚠️ **Limity Veo 3, o których trzeba wiedzieć:**
> - Natywny klip Veo 3 to **~8 s** (w Flow można „extend" do ~10s+; jak Twój tier nie
>   pozwala — zrób 8s, i tak wystarczy). Pisz pod 8-10s.
> - **Napisy/tekst Veo renderuje niepewnie** (literówki, krzaki). Daj instrukcję tekstu
>   w prompcie, ale **planuj nałożyć napisy w edycji** (CapCut, Press Start 2P) jeśli Veo
>   je przekręci. Logo na końcu też pewniej wklej w edycji niż liczyć na Veo.
> - Generuj **2-3 warianty** z tym samym promptem i wybierz najlepszy (RNG modelu).

## Screeny do dołączenia (reference / „ingredients" — 1-3 szt.)
1. **WYMAGANY** — klatka walki: wróg na środku + duża żółta liczba crita + monety/loot
   (np. świeży screen z `assets/sprites/enemies/` w akcji, albo zrzut z telefonu sceny walki).
   To ustawia **chibi pixel-art look** całego klipu.
2. *(opcjonalnie)* chibi boss dla beatu „dziwni bossowie" — `boss_brad.png` (selfie-stick)
   albo Saddam z gumową kaczką.
3. *(opcjonalnie)* logo gry `brand_kit/logo_1024x1024.png` jako klatka końcowa.

## Veo 3 prompt (skopiuj, dołącz screeny, audio ON, 9:16)
```
A vertical 9:16, ~8-10 second high-energy mobile-game advertisement, animated in the
EXACT chibi cartoon PIXEL-ART style of the attached game screenshots — big-headed
small-bodied characters, strong 2-3px black outlines, flat cel-shading, bright
saturated colors, hard pixel edges, no anti-aliasing, no gradients (Stardew Valley /
Cult of the Lamb vibe). Keep it lively and punchy, like a juicy idle-RPG.

SHOT / ACTION (one continuous, fast-energy take with quick internal beats):
- 0-3s: dynamic camera PUSH-IN on a lush pixel-art jungle-temple battle scene; a chibi
  enemy (like the attached sprite) takes a hit and a GIANT gold "CRIT" damage number
  bursts out toward the camera with a shower of gold coins, a white impact flash and a
  satisfying screen-shake.
- 3-6s: snappy whip-pan to a goofy chibi BOSS striking a ridiculous pose (smug
  influencer with a selfie-stick / a mustachioed warlord standing on a tiny raft holding
  a yellow rubber duck) — deadpan-funny, exaggerated.
- 6-8s: coins and loot EXPLODE upward; the background flickers from green jungle to
  golden desert ruins in one snappy transition (the world growing).
- 8-10s: smash to a clean end card with the game's logo and a bold call-to-action.

CAMERA: punchy push-ins and whip-pans, slight handheld energy, fast but readable.
LIGHTING / MOOD: bright, vibrant, daytime adventure; high contrast, poppy colors.

AUDIO (generate natively):
- SFX: crunchy arcade hit on the crit, bright "cha-ching" coin cascade, a whoosh on the
  whip-pan, a triumphant chime stinger on the end card.
- MUSIC: upbeat playful chiptune-adventure bed, building to a punchy final hit.
- VOICEOVER (energetic, cheeky male trailer-narrator voice, fast and confident, says
  exactly): "Tap once. Loot everything. Fight the weirdest bosses on mobile — free, on
  Google Play."
- On-screen captions to render (bold pixel font, white with thick black outline):
  "TAP. LOOT. CONQUER!" mid-clip, then "FREE ON GOOGLE PLAY" on the end card.

NO photorealism, NO 3D render, NO live action, NO real human faces — fully cartoon
pixel-art only. One continuous vertical clip, not split-screen, not a grid.
```

## VO — warianty linii (jakby pierwsza nie siadła)
- *Hook/komedia:* „Tap once. Loot everything. And yes — that boss is on a pool float."
- *Trailer-parody:* „One tap. Endless loot. The dumbest bosses ever made. Free on Google Play."
- *Krótki/clean:* „Tap. Loot. Conquer. Free on Google Play."

## Napisy do nałożenia w edycji (jeśli Veo przekręci tekst)
`TAP. LOOT.` (żółty) → `CONQUER!` (czerwony, shake) → end card: `FREE — GOOGLE PLAY`
+ logo `brand_kit/logo_1024x1024.png` wklejone na ostatnie ~1.5s.

## Koszt / workflow
1. Dołącz 1-3 screeny → wklej prompt → wygeneruj **2-3 warianty** (audio ON, 9:16).
2. Wybierz najlepszy; jeśli napisy/logo wyszły krzywo → dorzuć je w CapCut (Press Start 2P).
3. Eksport 1080×1920 → Shorts / TikTok / Play Store promo video.
> Koszt: kilka generacji Veo (kredyty Gemini), bez nagrywania i bez montażu od zera.
