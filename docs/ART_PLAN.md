# 🎨 LootClicker — Art Plan (Post-Launch Content Expansion)

> **Cel dokumentu:** operacyjny przewodnik generowania assetów do biomów post-launch (Desert → Sky Temple) w Google AI Studio (Nano Banana Pro / Imagen 4).
> **Strategiczny przegląd:** [ISSUE-28](issues/ISSUE-28_late_game_content_roadmap.md) — *czemu* i *co*. Ten dokument: *jak*.
> **Data:** 2026-05-25 — po publikacji v0.6.5 w Google Play.

---

## 0. Style philosophy (LootClicker — Joana Indiana)

### 0.1 Filozofia stylu

- **Tematyka:** humorystyczny archeologiczno-przygodowy (parodia Indiana Jones). Wrogowie to **postacie z grą słów** — "Toilet Paper Mummy", "Brad the Influencer", "Budget Sphinx". Ton: **deadpan ironic** — nikt w grze nie wie że to żart.
- **Estetyka:** chibi cartoon pixel art, **strong black outlines**, flat shading, bright saturated colors. Bliżej Stardew Valley / Cult of the Lamb niż Brotato / Gungeon.
- **Source resolution:** **1024×1024 PNG z alphą** (transparent BG). Godot skaluje przez `scale` w scenie (np. boss scale: 280.0 → renderuje się ~280 px na ekranie 360 px).
- **Widok:** **3/4 front-facing** — postać patrzy na gracza, lekko skręcona w prawo. Twarz widoczna w pełni, oba ramiona widoczne. Pasuje do mobilnej portretowej kompozycji.
- **Proporcje:** **chibi** — duża głowa (40-50% wysokości), małe ciało, wyraziste oczy, czytelna sylwetka. Każdy wróg musi być **rozpoznawalny w 32 px na thumbnailu**.
- **Style anchor:** istniejące sprite'y `monkey.png` / `skeleton.png` / `boss_brad.png` (1024×1024) — używamy ich jako **image reference** w każdym nowym promptu dla zachowania spójności.

### 0.2 Reference sprites (image conditioning anchors)

| Anchor | Plik | Użycie |
|---|---|---|
| Jungle enemy style | `assets/sprites/enemies/monkey.png` | Reference dla nowych jungle enemies (Jaguar Influencer) |
| Temple enemy style | `assets/sprites/enemies/skeleton.png` | Reference dla nowych temple enemies (Cursed Tourist) |
| Boss style | `assets/sprites/enemies/boss_brad.png` | Reference dla **WSZYSTKICH** nowych bossów (najbardziej dopracowany sprite) |
| Wzorzec dla nowego biomu | **pierwszy wygenerowany sprite biomu** | Każdy kolejny wróg z tego biomu używa pierwszego jako reference |

**Zasada wzorca biomu:** wygeneruj pierwszy sprite biomu (np. Sand Karen dla Desert) **bez image reference** → przejrzyj wynik → jeśli OK, staje się **anchor dla pozostałych 4 wrogów tego biomu**. Jeśli wynik słaby, regeneruj zanim ruszysz dalej.

---

## 0.3 Ustawienia Nano Banana Pro / Imagen — tabela referencyjna

| Typ assetu | Model | Aspect Ratio | Resolution | Image Reference |
|-----------|-------|-------------|------------|-----------------|
| Wróg (nowy biom — pierwszy) | **Imagen 4** | **1:1** | **1K** | Brak (= wzorzec biomu) |
| Wróg (nowy biom — kolejny) | **Imagen 4** | **1:1** | **1K** | Pierwszy wróg tego biomu |
| Wróg (doposażenie istniejących) | **Imagen 4** | **1:1** | **1K** | `monkey.png` (jungle) / `skeleton.png` (temple) |
| Boss | **Imagen 4** | **1:1** | **1K** | `boss_brad.png` |
| Tło biomu | **Imagen 4** | **9:16** | **2K** (jeśli możliwe) | `Jungle.jpeg` lub `Temple.jpeg` (dla stylu) |

> ⚠️ **Liczba obrazów:** generuj **4 naraz** i wybierz najlepszy.
> ⚠️ **Negative prompt** (skopiuj DOKŁADNIE do każdego generowania):
> ```
> realistic, 3D rendering, photograph, blurry, smooth shading, gradient,
> anti-aliasing, watermark, signature, text, logo, multiple characters,
> background scenery, complex environment, side profile only, dark gritty,
> horror, blood, gore
> ```

---

## 0.4 Workflow generowania assetu (per wróg)

1. **Otwórz** Google AI Studio → New chat → wybierz **Imagen 4** (lub Nano Banana Pro jeśli A4 niedostępny).
2. **Ustawienia:** Aspect 1:1 (wrogowie/bossowie) lub 9:16 (tła), 1K resolution, 4 images.
3. **Image reference:** dla pierwszego wroga biomu — brak. Dla kolejnych — przeciągnij wcześniejszy sprite (`monkey.png` lub pierwszy z biomu).
4. **Prompt:** skopiuj z sekcji 2-7, wklej tag `[PREFIX_ENEMY]` lub `[PREFIX_BOSS]` lub `[PREFIX_BG]` z sekcji 1, dodaj `[NEGATIVE]` z sekcji 0.3.
5. **Generate** → przejrzyj 4 warianty → wybierz najlepszy.
6. **Download** PNG → Photopea → wymaż tło (chroma/remove.bg) → **NORMALIZUJ KADR wg sekcji 0.5** (fit-to-box + wyśrodkowanie) → **downscale do 384×384** → save RGBA PNG.
7. **Zapisz** w `assets/sprites/enemies/{biome}/{snake_case_name}.png` (utwórz subfolder per biom).
8. **W Godot:** Import → Texture Filter: Nearest (zachowuje piksele) lub Linear (gładkie skalowanie — preferowane dla mobile), Mipmaps: Off, Fix Alpha Border: ✓.
9. **W kodzie:** dodaj wpis do `enemy_roster_desert` (lub odpowiedni biome) w `src/scenes/GameBattleManager.gd`.
10. **Mark ✅** w trackerze (sekcja 8).

---

## 0.5 Normalizacja sprite'a wroga (kadr + downscale) — SPÓJNY ROZMIAR

> **Cel:** żeby wszyscy wrogowie mieli **spójną obecność na ekranie** bez walki ze skalowaniem. Sam crop nie wystarcza — potrzebny **wspólny kadr**. Po normalizacji istniejący kod (`_get_sprite_content_size` w `GameBattleManager.gd`, skaluje `max(w,h)` do `target_size`) daje identyczny rozmiar dla każdego — **bez zmian w kodzie**.

### Dlaczego (geneza)
Wcześniej sprite'y miały różny padding / różną wielkość treści w canvasie → na ekranie wyglądały na różnej wielkości. Fix w kodzie (bbox-scaling) to ratował, ale to było leczenie objawu. Normalizacja kadru leczy **źródło** + zostawia kod jako **safety net** (pas i szelki).

### Przepis w Photopea (per sprite)

1. **Wytnij tło** (chroma/remove.bg) → przezroczystość.
2. **`Image → Trim`** (Transparent Pixels) → canvas ciasno na postaci.
3. **Zapamiętaj proporcje** postaci (np. wysoka mumia vs szeroki wąż — to OK, kształty się różnią).
4. **`Image → Canvas Size`** → ustaw **kwadrat** (większy bok postaci × ~1.14, np. jeśli postać 700px wys → canvas ~800), **Anchor: środek**. To daje **~88% wypełnienia** (margines ~6% z każdej strony) i **wyśrodkowanie w obu osiach**.
   - Kluczowe: **postać wyśrodkowana** → środek tekstury = środek postaci → gra (która pozycjonuje sprite po środku) ustawi wszystkich spójnie.
   - **Najdłuższy bok postaci = ~88% canvasu** → bbox-scaling skaluje wszystkich tak samo.
5. **`Image → Image Size`** → **384 × 384**, Resample **Bilinear** (gładko — to nie pixel-art UI, to sprite postaci).
6. **Export PNG** (RGBA, przezroczyste).

### Standard (trzymaj się go dla WSZYSTKICH wrogów)

| Parametr | Wartość |
|---|---|
| Canvas | **kwadrat**, postać wyśrodkowana |
| Wypełnienie | **najdłuższy bok postaci ≈ 88%** canvasu (margines ~6%) |
| Eksport | **384×384** (bossy: 512×512 jeśli chcesz ostrzej) |
| Filtr w Godot | **Linear**, Mipmaps Off, Fix Alpha Border ✓ |

> ⚠️ **Wypełnienie ZAWSZE 88%** — to jest sedno spójności. Jeśli jeden sprite da 70% a drugi 95%, znów będą różnej wielkości. Ten jeden parametr trzymaj sztywno.

### Co z kodem
**Nic nie zmieniasz.** `_get_sprite_content_size` mierzy bbox i skaluje `max(w,h) → target_size`. Przy spójnym 88% wypełnieniu wszystkie wychodzą równo. Kod zostaje jako zabezpieczenie gdyby któryś sprite miał inny kadr.

### Pilot (zanim zrobisz kilkadziesiąt)
1. Zregeneruj **2 wrogów** (np. 1 wysoki + 1 szeroki — najtrudniejszy test spójności).
2. Znormalizuj wg przepisu (oba 88% wypełnienia, 384×384).
3. Podmień w grze, odpal — sprawdź czy **oba wyglądają na tę samą wielkość/obecność**.
4. Jeśli OK → przepis zatwierdzony, lecisz z resztą. Jeśli nie → korygujemy % wypełnienia lub metrykę skalowania.

---

## 1. PREFIX-y (uniwersalne fragmenty promptów)

> **WAŻNE:** Zawsze wklejaj odpowiedni PREFIX **na początku** promptu, przed opisem konkretnego wroga.

### 1.1 PREFIX_ENEMY (zwykli wrogowie, biomy 3-7)

```
2D mobile game enemy sprite, chibi cartoon pixel art style,
3/4 front-facing view (character looks at viewer, slightly angled right,
both shoulders and full face visible). Hard pixel edges, NO anti-aliasing.
Strong black outline 2-3px on all visible shapes. Flat cel-shading,
max 3 tones per element (highlight + base + shadow), NO gradients.
CHIBI PROPORTIONS — oversized head (40-50% of total height), small
expressive body, large readable eyes. Single character centered,
fills ~85% of canvas. NO weapon, NO ground shadow, NO background scenery —
isolated subject on a clean flat solid MAGENTA background #FF00FF
(chroma key — cut to transparent in Photopea; magenta works even for
white parts of the character. The character has NO magenta on its body).
Square 1:1 canvas 1024×1024 source resolution. Style consistent with existing LootClicker
enemies (cartoon humorous tone, recognizable silhouette at 32px thumbnail).
LootClicker palette base (universal): black outline #1a1a2e,
white #ffffff, gold accent #ffd700, red accent #cc0000, blue accent
#4a9eff. Biome-specific palette OVERRIDES below.
```

### 1.2 PREFIX_BOSS (bossowie, milestone stages)

```
2D mobile game BOSS sprite, chibi cartoon pixel art style,
3/4 front-facing view (boss looks at viewer with imposing presence,
slightly angled right). LARGER and MORE DETAILED than regular enemies.
Dramatic posture, glowing eyes or aura, intimidating but still cartoon-cute
(not horror). Hard pixel edges, NO anti-aliasing. Strong black outline
3-4px (thicker than regular enemies) on all visible shapes. Flat cel-shading,
max 4 tones per element, NO gradients. CHIBI-BUT-MENACING PROPORTIONS —
large detailed head, more body presence than regular enemies, props/accessories
visible (crown, weapon, gear). Single boss centered, fills ~90% of canvas.
NO ground shadow, NO background scenery — isolated subject on a clean
flat solid MAGENTA background #FF00FF (chroma key — cut to transparent
in Photopea; works even for white parts of the boss; boss has NO magenta
on its body). Square 1:1 canvas 1024×1024 source
resolution. Style consistent with existing LootClicker bosses (boss_brad.png
as primary reference — humorous yet imposing). Biome-specific palette
OVERRIDES below.
```

### 1.3 PREFIX_BG (tła biomów)

```
2D mobile game background, pixel art landscape, portrait orientation
9:16 aspect ratio (vertical mobile screen). Painted pixel-art style
similar to classic Square Enix / Stardew Valley landscapes. Atmospheric
depth with clear foreground / midground / background layers. NO characters,
NO UI elements, NO text, NO logos. Soft ambient lighting, no harsh
shadows. Vibrant saturated colors but readable behind game UI overlays
(combat HUD will sit on top). Mobile-optimized composition — main visual
focus in upper 60% of frame (lower 40% will be covered by HUD).
1024×1820 source resolution (or 2048×3640 if 2K available). Style
consistent with existing LootClicker backgrounds (Jungle.jpeg / Temple.jpeg
as reference for technique). Biome-specific atmosphere below.
```

---

## 1.4 Palety per biome

| Biome | Kolor dominujący | Akcent 1 | Akcent 2 | Cień | Highlight |
|---|---|---|---|---|---|
| **Jungle** (1-14) ✅ | Zieleń lasu `#3d6e3a` | Brąz pnia `#8b6914` | Żółć liścia `#c8a64b` | `#1e3a1e` | `#5a8a5a` |
| **Temple** (15-35) ✅ | Szarość kamienia `#8c8378` | Złoto `#ffd700` | Turkus mchu `#4a9e6b` | `#3a3530` | `#c4b8a0` |
| **Desert** (36-55) 🔜 | Piaskowy `#e4b872` | Turkus oazy `#4fb3bf` | Pomarańcz słońca `#f58a4a` | `#a67c3a` | `#f5dca0` |
| **Frozen Peaks** (56-75) 🔜 | Lodowy biały `#e8f4f8` | Niebieski lodu `#5c9cc4` | Szary skały `#8e9aab` | `#3a5870` | `#ffffff` |
| **Catacombs** (76-95) 🔜 | Ciemny brąz `#3d2e1f` | Pomarańcz lawy `#ff6b35` | Fiolet runy `#5a2c82` | `#1a0e08` | `#ff9a5a` |
| **Atlantis** (96-120) 🔜 | Turkus wody `#1abc9c` | Głęboki niebieski `#2c3e50` | Koralowy `#ff8674` | `#0d4a3e` | `#88e5cf` |
| **Sky Temple** (121+) 🔜 | Pastelowy róż `#f5c5dd` | Bladobiały `#fafafa` | Złoty `#ffd700` | `#a08aa0` | `#ffffff` |

---

## 2. Doposażenie istniejących biomów (Phase 5 — warm-up)

> 🎯 **Cel:** sprawdzić workflow generowania **zanim** ruszysz duży biom. 2 wrogów = ~30 minut.

### 2.1 Jungle: **Jaguar Influencer**

- **Plik:** `assets/sprites/enemies/jungle/jaguar_influencer.png`
- **Resource (kod):** `bandages`
- **Image reference:** `assets/sprites/enemies/monkey.png`
- **Prompt:**

```
[PREFIX_ENEMY]
Subject: a CHIBI cartoon JAGUAR character with the EXACT same art style,
outline thickness, and chibi proportions as the reference image.
Body: small spotted jaguar (yellow-orange fur #e0a050 base, darker orange
shadow #b87838, lighter belly #f5d090, black rosette spots #1a1a2e
sparsely placed). Oversized chibi head facing forward, large expressive
amber eyes (#ffaa44 iris, white #ffffff highlight dot). PROPS — purple
designer sunglasses (#5a2c82 frame, #8855c4 lens highlights) resting on
top of the head, NOT on eyes. Right paw holds up a selfie-stick (gray
metal #6b6b6b shaft, black grip #1a1a2e, small smartphone at top with
glowing blue screen #4a9eff). Slightly bored / unimpressed cartoon
expression. JUNGLE palette: leaf green accent #3d6e3a on background-FREE
silhouette only (no actual scenery). Single character centered.
```

### 2.2 Temple: **Cursed Tourist**

- **Plik:** `assets/sprites/enemies/temple/cursed_tourist.png`
- **Resource (kod):** `relic_shards`
- **Image reference:** `assets/sprites/enemies/skeleton.png`
- **Prompt:**

```
[PREFIX_ENEMY]
Subject: a CHIBI cartoon ZOMBIE TOURIST character with the EXACT same art
style, outline thickness, and chibi proportions as the reference image.
Body: humanoid zombie with pale grayish-green skin (#9aa890 base, #6a7860
shadow, #c4d0b8 highlight on cheekbones). Oversized chibi head, ONE eye
normal (white #ffffff sclera, black #1a1a2e pupil), OTHER eye glowing
bright green (#5aff5a + white #ffffff core dot). Cartoon zombie expression
— slack jaw, slightly tilted head. CLOTHING — bright Hawaiian shirt
(white #ffffff base with red hibiscus pattern #cc3344 + green palm leaves
#3d6e3a, oversized and slightly torn at hem). Khaki shorts (#c4a570).
PROPS — large vintage film camera #2a2a2a hanging on neck strap (brown
leather #6a4a2a strap, silver lens #8c8c8c with #ffffff glint). Tan
backpack straps visible on shoulders (#8b6914). Holding a small ancient
relic stone in one hand (gray stone #8c8378 with glowing turquoise
runes #4a9e6b). TEMPLE palette accent: turquoise moss #4a9e6b on relic.
Single character centered.
```

---

## 2.5 Regeneracja STARYCH sprite'ów wrogów (E1-E8) — odświeżenie artu + normalizacja

> **Cel:** podmiana starych/niespójnych sprite'ów (m.in. `*-removebg-preview.png`, surowe `monkey/snake/plant`) na nowe w jednolitym chibi-stylu, **znormalizowane wg sekcji 0.5** (88% fill, 384×384). Po regeneracji wrogowie będą spójni rozmiarowo i stylistycznie — bez walki ze skalowaniem.
>
> **Workflow per wróg:** `[PREFIX_ENEMY]` (sekcja 1.1) + opis poniżej + **MAGENTA OVERRIDE (niżej)** + `[NEGATIVE]` (0.3) → Imagen 4, 1:1, 4 obrazy → wybierz → **normalizuj (0.5): trim → kwadrat 88% środek → 384×384** → zapisz pod istniejącą nazwą (nadpisuje stary).
>
> ### ✅ MAGENTA BACKGROUND — już w PREFIX_ENEMY (sekcja 1.1)
> Zaktualizowałem `PREFIX_ENEMY` i `PREFIX_BOSS` (sekcja 1.1/1.2): tło = **MAGENTA #FF00FF** (nie białe). Czyli **nic nie dopisujesz do promptów** — magenta jest w prefixie, który i tak wklejasz na początku. Powód: ci wrogowie mają **białe elementy** (papier mumii, prześcieradło, kości, koszula) → biel-na-bieli nie da się wyciąć; magenta tak.
> **Jedyne co dodaj ręcznie:** do `[NEGATIVE]` (sekcja 0.3) dopisz `white background`. W Photopea: `Select → Color Range` → magenta → Delete (jak przy U1-U12).
>
> **Image reference (anchor):** użyj `jaguar_influencer.png` (jungle) / `cursed_tourist.png` (temple) — już w nowym stylu. Pierwszy zregenerowany staje się dodatkowym anchorem.
>
> **Kod: bez zmian** — nadpisujesz pliki pod tymi samymi ścieżkami z `enemy_roster_*`, gra podchwytuje automatycznie.

| # | Wróg | Plik (nadpisz) | Biom | Resource |
|---|---|---|---|---|
| E1 | Angry Kaboom Squirrel | `enemies/squirrel.png` | Jungle | bandages |
| E2 | Intern Monkey | `enemies/monkey.png` | Jungle | bandages |
| E3 | Dieting Plant | `enemies/plant.png` | Jungle | venom |
| E4 | Toilet Paper Mummy | `Mumia-removebg-preview.png` → **przenieś na** `enemies/mummy.png` | Jungle/Temple | bandages |
| E5 | Confused Snake | `Snake-removebg-preview.png` → **przenieś na** `enemies/snake.png` | Jungle/Temple | venom |
| E6 | Tourist Skeleton | `enemies/skeleton.png` | Temple | venom |
| E7 | Budget Golem | `enemies/golem.png` | Temple | relic_shards |
| E8 | Sheet Ghost | `enemies/ghost.png` | Temple | venom |

> ⚠️ **E4/E5** mają brzydkie nazwy `*-removebg-preview.png` — przy okazji **zmień nazwę** na `enemies/mummy.png` / `enemies/snake.png` i zaktualizuj ścieżki w `enemy_roster_jungle`/`temple` w `GameBattleManager.gd` (dam znać / zrobię gdy będą gotowe).

> ### 📐 ROZMIAR ZAPISU (wszystkie E1-E8): **384 × 384 px**
> Generujesz w **1024×1024** (Imagen) → w Photopea: wytnij magentę → `Trim` → `Canvas Size` **kwadrat, postać = 88%, wyśrodkowana** → `Image Size` **384×384** (Bilinear) → export RGBA. Bossy: **512×512**. (Pełny przepis: sekcja 0.5.)
> **To jest odpowiednik "→ zapis X×Y px" z U1-U12 — dla wrogów: 384×384.**

#### **E1: Angry Kaboom Squirrel**
```
[PREFIX_ENEMY]
Subject: a CHIBI cartoon ANGRY SQUIRREL — jungle enemy. Body: small round
squirrel, warm brown fur (#a06a3a base, #7a4e28 shadow, #c89060 highlight),
big fluffy tail curled up behind, large furious eyes (#1a1a2e pupils +
#ffffff sclera), furrowed brow (#1a1a2e thick angry lines), buck teeth
(#ffffff) bared in a snarl. PROP: clutching a lit ACORN-BOMB in both paws
— a round dark acorn (#5a3a1a) wrapped like a cartoon bomb with a glowing
sparking fuse on top (#ffd700 spark + #ff6b35 + #ffffff hot dot). Cheeks
puffed with fury. JUNGLE palette: leaf green accent #3d6e3a. Single
character centered.
```

#### **E2: Intern Monkey**
```
[PREFIX_ENEMY]
Subject: a CHIBI cartoon OVERWORKED INTERN MONKEY — jungle enemy. Body:
small monkey, tan-brown fur (#b8895a base, #8a6038 shadow, #d8a878 high-
light), oversized chibi head, big tired eyes with dark under-eye bags
(#1a1a2e + #6a5a7a bags), forced exhausted smile. CLOTHING: a too-big
white dress shirt (#ffffff, #d0d0d0 shadow) with a crooked red clip-on
tie (#cc3344), a company LANYARD with a blank ID badge (#1a1a2e strap,
#ffffff badge, #4a9eff dot). PROPS: holding a tray with a wobbling stack
of papers (#ffffff sheets, #d0d0d0 edges) in one paw and a takeaway
coffee cup (#ffffff + #6a4a2a sleeve) in the other. JUNGLE palette accent
#3d6e3a. Single character centered.
```

#### **E3: Dieting Plant**
```
[PREFIX_ENEMY]
Subject: a CHIBI cartoon VENUS FLYTRAP on a DIET — jungle enemy. Body:
potted carnivorous plant, green bulb-head with a toothy maw (#4a9e3a base,
#2e6e22 shadow, #6ed44a highlight, #cc3344 pink inner mouth, #ffffff
triangular teeth). Two big sad hungry eyes (#1a1a2e pupils + #ffffff +
sad #4a9eff teardrop). Skinny green stem + two leaf-arms. POT: small
terracotta pot (#c0683a base, #8a4a24 shadow). PROP: one leaf-arm holding
a tiny sad SALAD bowl (#ffffff bowl, #4a9e3a lettuce, #cc3344 tomato) it
clearly doesn't want; tummy-rumble look. JUNGLE palette. Single character
centered.
```

#### **E4: Toilet Paper Mummy**
```
[PREFIX_ENEMY]
Subject: a CHIBI cartoon MUMMY wrapped in TOILET PAPER (not bandages) —
jungle/temple enemy. Body: humanoid mummy fully wrapped in soft WHITE
toilet-paper strips (#ffffff base, #e0e0e0 soft shadow, slightly fluffy
perforated edges visible). Oversized chibi head, two round eyes peeking
through the wrapping (#1a1a2e pupils + #ffffff), tiny embarrassed/sneezy
expression. PROP: one hand holding a half-unrolled TOILET PAPER ROLL
(#ffffff roll, #c0a060 cardboard tube), a loose strip trailing to the
ground. A small "achoo" sparkle near the nose (#4a9eff + #ffffff). Single
character centered.
```

#### **E5: Confused Snake**
```
[PREFIX_ENEMY]
Subject: a CHIBI cartoon CONFUSED SNAKE — jungle/temple enemy. Body: small
round green snake coiled up / tied in a loose KNOT in its own body
(#4a9e3a base, #2e6e22 shadow on underside, #6ed44a highlight, #c8e8b0
belly). Oversized chibi head, big CROSS-EYED googly eyes (both pupils
pointing inward, #1a1a2e + #ffffff sclera), tiny forked tongue (#cc3344)
sticking out sideways. Confused spiral / question-mark vibe — a small "?"
floating above head (#ffffff + #1a1a2e outline). Little pink cheek
blush (#ff99aa). Single character centered.
```

#### **E6: Tourist Skeleton**
```
[PREFIX_ENEMY]
Subject: a CHIBI cartoon TOURIST SKELETON — temple enemy. Body: humanoid
skeleton, off-white bones (#e8e8e0 base, #b8b8a8 shadow, #ffffff high-
light), oversized chibi skull with hollow eye sockets (#1a1a2e voids) and
a permanent toothy grin. CLOTHING: a loud Hawaiian shirt (#ffffff base
with #cc3344 hibiscus + #3d6e3a palm leaves), khaki shorts (#c4a570), and
a wide-brim straw SUN HAT (#d8b878 + #8a6038 band). PROPS: a chunky
vintage CAMERA on a neck strap (#2a2a2a body, #6a4a2a strap, #8c8c8c lens
+ #ffffff glint) and oversized sunglasses pushed up on the skull
(#1a1a2e frames, #4a9eff lens). Cheerful clueless-tourist vibe. TEMPLE
palette accent #4a9e6b. Single character centered.
```

#### **E7: Budget Golem**
```
[PREFIX_ENEMY]
Subject: a CHIBI cartoon BUDGET STONE GOLEM — temple enemy. Body: stocky
humanoid golem made of MISMATCHED cheap rocks of different gray-brown
shades poorly stacked (#8c8378 base, #6a6058 shadow, #a89e90 highlight,
plus a couple odd-colored blocks #a67c3a and #7a8a7a to look "budget").
Oversized blocky chibi head, two small glowing eyes (#4a9e6b soft glow +
#ffffff core). Slightly crooked/lopsided build, one arm bigger than the
other, a small crack here and there (#3a3530 lines). PROP: a dangling
yellow PRICE TAG tied to one arm ("50%" or just a tag shape #ffd700 +
#1a1a2e string). Goofy "assembled on a budget" charm. TEMPLE palette
accent #4a9e6b. Single character centered.
```

#### **E8: Sheet Ghost**
```
[PREFIX_ENEMY]
Subject: a CHIBI cartoon BEDSHEET GHOST — temple enemy. Body: classic
floating ghost made of a draped WHITE bedsheet (#ffffff base, #d8d8e0 soft
shadow in folds, #ffffff highlights), rounded top, wavy scalloped bottom
hem floating above the ground. Two simple cut-out eye holes (#1a1a2e
voids) and a small "oooh" round mouth hole (#1a1a2e). Tiny stubby sheet-
arms raised in a half-hearted "boo". PROP (optional, mundane joke): one
sheet-arm loosely holding an everyday object — a small alarm clock or a
cup of tea (#8c8c8c / #ffffff + #6a4a2a) — totally unbothered. Faint
translucent edge glow (#c4dce8, subtle). TEMPLE palette accent #4a9e6b.
Single character centered.
```

> **Bossy** (boss_idol "The Allergic Idol", boss_brad, boss_sphinx): regeneruj analogicznie z `[PREFIX_BOSS]` (sekcja 1.2) + normalizacja 0.5, ale **512×512** (większy detal). Prompty bossów — dopiszemy gdy ruszysz, na razie skup się na E1-E8.

### Pilot E1-E8
Zacznij od **2 kontrastowych** (np. **E2 Intern Monkey** wysoki + **E5 Confused Snake** szeroki/zwinięty) → znormalizuj oba (88%, 384) → wrzuć do gry → sprawdź spójność rozmiaru. OK → reszta.

---

## 2.6 Regeneracja istniejących BOSSÓW (B1-B4)

> **Workflow:** `[PREFIX_BOSS]` (sekcja 1.2, **ma już magentę**) + opis poniżej + `[NEGATIVE]` (0.3, dodaj `white background`) → Imagen 4, 1:1, 4 obrazy → normalizuj (0.5) → **512×512** (bossy = większy detal) → nadpisz plik.
>
> ### 📐 ROZMIAR ZAPISU (B1-B4): **512 × 512 px** (kwadrat, postać 88%, środek — sekcja 0.5)
>
> **Anchor:** `boss_brad.png` to obecny wzorzec bossów (sekcja 0.2). Regenerujesz też Brada → **zacznij od B2 (Brad)**, zatwierdź styl, potem użyj **nowego Brada jako image reference** dla B1/B3/B4. **Kod bez zmian** (nadpisujesz pod tymi samymi ścieżkami; `scale` w `boss_roster` zostaje).

| # | Boss | Plik (nadpisz) | Stage | Greeting |
|---|---|---|---|---|
| B1 | The Allergic Idol | `enemies/boss_idol.png` | 10 | "Ah... Ah... CHOO!" |
| B2 | Brad the Influencer | `enemies/boss_brad.png` | 25 | "Don't forget to like and subscribe!" |
| B3 | The Budget Sphinx | `enemies/boss_sphinx.png` | 40 | "Meow. Give me gold." |
| B4 | Saddam on the Raft (ULTIMATE) | `Sadam-removebg-preview.png` → **przenieś na** `enemies/boss_saddam.png` | 50 | — |

> ⚠️ **B4** ma brzydką nazwę `Sadam-removebg-preview.png` → przy okazji rename na `enemies/boss_saddam.png` + zaktualizuj `@export boss_texture` w scenie (zrobię gdy będzie gotowy).

#### **B1: The Allergic Idol** → zapis `512 × 512`
```
[PREFIX_BOSS]
Subject: a CHIBI cartoon ANCIENT TEMPLE IDOL BOSS that is perpetually
SNEEZING — "The Allergic Idol". Body: a big carved stone TIKI / Aztec-
style idol head-and-torso statue, mossy weathered stone (#8c8378 base,
#5a5048 deep shadow, #b4aa98 highlight) with carved geometric grooves
(#3a3530) and patches of green moss (#4a9e6b). Oversized blocky chibi
idol face: huge round GLOWING eyes (#ffd700 + #ffffff core) now WATERY
and half-squinted (about to sneeze), thick stone brow, wide open carved
mouth mid-"ACHOO". A runny glowing nose-drip (#4a9eff + #ffffff). Clouds
of POLLEN / SPORE DUST puffing around the head (#c8e89a + #ffffff
specks, #4a9e6b green motes). Small stone arms raised. A faint gold aura
(#ffd700, 8px). TEMPLE/JUNGLE palette: stone gray + gold + moss green.
Imposing but comedic (sneezy). Single boss centered.
```

#### **B2: Brad the Influencer** (NOWY ANCHOR — generuj pierwszy) → zapis `512 × 512`
```
[PREFIX_BOSS]
Subject: a CHIBI cartoon SMUG INFLUENCER BOSS — "Brad the Influencer".
Body: a confident young human guy, oversized chibi head, perfect swept-up
dirty-blonde fauxhawk hair (#c4a060 base, #8a6038 shadow, #e8d0a0 high-
light), flawless white grin (#ffffff teeth), expensive mirror sunglasses
(#1a1a2e frames, #4a9eff + #ffffff lens reflection). CLOTHING: trendy
white designer tee (#ffffff, #d0d0d0 shadow) under an open varsity
jacket (#cc3344 + #1a1a2e sleeves), gold chain (#ffd700). PROPS: one hand
thrusting a SMARTPHONE toward viewer (#1a1a2e body, glowing screen
#4a9eff with a red REC dot #cc0000), other hand giving a thumbs-up; a
SELFIE-STICK and a glowing hexagonal RING LIGHT behind his head
(#ffffff core + #ffd700 outer glow). Floating "LIKE" + "♥" + "SUBSCRIBE"
UI bubbles around him (#cc3344 / #4a9eff + #ffffff). Punchable smug
deadpan confidence. Single boss centered.
```

#### **B3: The Budget Sphinx** → zapis `512 × 512`
```
[PREFIX_BOSS]
Subject: a CHIBI cartoon DISCOUNT EGYPTIAN SPHINX BOSS — "The Budget
Sphinx". Body: a small crouching sphinx (lion/cat body + human-ish
pharaoh head) made of CHEAP cracked sandstone, poorly repaired
(#d4a060 sand base, #a67c3a shadow, #f5dca0 highlight, visible crack
lines #6a4a20, a couple mismatched gray patch-stones #8c8378). Oversized
chibi CAT face with a smug bored expression, narrow eyes (#1a1a2e +
#ffd700 glint), tiny whiskers (#1a1a2e), a striped pharaoh NEMES head-
dress (gold #ffd700 + dark blue #2a4a7a stripes) that's chipped and
crooked. PROPS: a small "SALE 50%" cardboard sign hung on one paw
(#ffffff sign, #cc3344 text shape, #1a1a2e string) and a tiny TIP JAR /
coin cup in front (#8c8c8c glass, #ffd700 coins). One paw lazily held
out demanding gold. DESERT/TEMPLE palette: sandstone + gold + blue
accent. Cheap-but-smug vibe. Single boss centered.
```

#### **B4: Saddam on the Raft** (ULTIMATE — istniejący joke boss) → zapis `512 × 512`
```
[PREFIX_BOSS]
Subject: a CHIBI cartoon ABSURD "RAFT WARLORD" BOSS — a deadpan
cartoon mustachioed dictator-parody figure floating on a tiny makeshift
RAFT. Keep it FULLY cartoon, goofy and absurd (Naked Gun / deadpan
parody energy), NOT a realistic likeness of any real person. Body:
oversized chibi head with a big bushy black cartoon MUSTACHE (#1a1a2e),
stern unimpressed expression, beret or military cap (#3a4a2e olive +
#ffd700 tiny star), olive-green military jacket (#4a5238 base, #2e3622
shadow, #6a7250 highlight) with cartoon medals (#ffd700 + #cc3344). He
stands stiff and self-serious. RAFT: a small lopsided raft of lashed
wooden logs (#8b6914 wood, #5a3a10 shadow, #c4a060 highlight, frayed
rope #c4a070) floating on a few cartoon water ripples (#4fb3bf + #ffffff
foam) at the very bottom. PROP (the visual joke): he solemnly holds a
tiny bright yellow RUBBER DUCKY (#ffd700 body + #ff6b00 beak + #1a1a2e
dot eyes) like a serious scepter. A faint gold "final boss" aura
(#ffd700, 8-10px). 100% deadpan — he has no idea he's ridiculous.
Single boss centered.
```

---

## 3. Desert biome (Phase 1 — stage 36-55)

### 3.1 Tło: `assets/sprites/Desert.jpeg`

- **Aspect:** 9:16, 2K jeśli możliwe
- **Image reference:** `assets/sprites/Jungle.jpeg` (dla stylu)
- **Prompt:**

```
[PREFIX_BG]
Desert biome — Egyptian-themed sandstone ruins. Foreground (lower 30%):
warm sandy ground (#e4b872 base, #c49b5c shadow), scattered small rocks,
sparse dry grass tufts. Midground (middle 30%): ancient stone pyramid
ruins (#a67c3a stone with darker shadow #6a4a20), partially buried in
sand, two stone pillars with hieroglyph carvings (#3a3530 carved lines).
Background (upper 40%): vast dune landscape rolling into the distance
(#e4b872 → #d4a060 horizon), partially cloudy sky with warm orange
sunset glow (#f5dca0 lower sky → #4fb3bf upper sky turquoise), distant
silhouette of a SECOND larger pyramid (#8c6a40, atmospheric haze).
Slight visible heat distortion shimmer near ground (subtle, pixel art
style suggestion only). Vibrant saturated desert palette. Atmospheric
depth, painterly pixel art technique.
```

### 3.2 Desert enemies (5 sztuk)

> **Image reference:** wygeneruj **D1 (Sand Karen) PIERWSZY bez image reference** → użyj jej jako anchor dla D2-D5.

#### **D1: Sand Karen** (anchor sprite)

- **Plik:** `assets/sprites/enemies/desert/sand_karen.png`
- **Resource:** `venom`
- **Joke:** "This pyramid does NOT meet my expectations."
- **Prompt (BEZ image reference):**

```
[PREFIX_ENEMY]
Subject: a CHIBI cartoon MUMMY KAREN character — desert biome enemy.
Body: human-shaped mummy with off-white sandy bandage wrappings (#f5dca0
base, #c4a070 shadow, #ffffff highlights), wrapped around limbs and
torso but leaving the face exposed. KAREN HAIRSTYLE — short asymmetric
bob haircut on top of the mummy's head, beige-blonde color (#d4b88a
base, #a08858 shadow), with the signature 2010s Karen flip (longer in
front, shorter in back). Oversized chibi head with FURROUSED EYEBROWS
(#1a1a2e thick angry lines), narrowed disapproving eyes (#1a1a2e pupils,
#ffffff sclera), mouth open mid-complaint. ONE ARM raised and pointing
accusingly forward at the viewer (index finger extended), other arm on
hip. Bandages slightly tattered and frayed at the edges. Small grain
of sand particles floating around (#c4a070 dots, sparse). DESERT
palette: sandy base, accent on her bob hair (slightly darker beige).
```

#### **D2: Cursed Camel**

- **Plik:** `assets/sprites/enemies/desert/cursed_camel.png`
- **Resource:** `bandages`
- **Joke:** "Plot twist: garby to klątwy."
- **Image reference:** `sand_karen.png`
- **Prompt:**

```
[PREFIX_ENEMY]
Generate in the EXACT same chibi cartoon pixel art style, outline
thickness, palette, and proportions as the reference image.
Subject: a CHIBI cartoon CAMEL character — desert biome enemy.
Body: stylized chibi camel with tan-beige fur (#d4a060 base, #a67c3a
shadow on underside, #f5dca0 highlight on top), short stubby legs,
short tail. Oversized chibi camel head with large eyes (#1a1a2e pupils
+ #ffffff sclera + small #ffaa44 amber iris ring), long eyelashes
(#1a1a2e thin lines, 3 per eye), mouth slightly open showing one large
buck tooth (#ffffff). UNIQUE FEATURE — THREE HUMPS on the camel's back
(instead of the normal 1-2), each hump GLOWING with magical curse energy:
first hump pink (#ff66cc + #ffffff core), second hump purple (#5a2c82 +
#8855c4 highlight + #ffffff core), third hump teal (#4fb3bf + #ffffff
core). Subtle dark magical wisps rising from each glowing hump
(#5a2c82 + #ff66cc particle pixels). Cartoon spooked-but-resigned
expression. Single character centered.
```

#### **D3: Dust Devil Brad**

- **Plik:** `assets/sprites/enemies/desert/dust_devil_brad.png`
- **Resource:** `venom`
- **Joke:** "Algorytm mnie tu sprowadził."
- **Image reference:** `sand_karen.png`
- **Prompt:**

```
[PREFIX_ENEMY]
Generate in the EXACT same chibi cartoon pixel art style, outline
thickness, palette, and proportions as the reference image.
Subject: a CHIBI cartoon DUST TORNADO with a HUMAN FACE — desert biome
enemy. Body: small swirling sand tornado / dust devil, conical shape
narrower at base and wider at top, made of swirling sand particles
(#e4b872 base, #c49b5c darker swirl lines indicating motion, #f5dca0
highlight on top). FACE embedded in the upper wider portion of the
tornado — male face with smug INFLUENCER expression (chibi proportions,
oversized head-on-tornado), styled hair (dirty blonde #c4a060, swept up
fauxhawk style), perfect white teeth (#ffffff) showing in a confident
grin, sunglasses (#1a1a2e frames, #4a9eff lens highlights). PROP — a
selfie-stick poking out from the swirling sand at the top of the
tornado (gray metal #6b6b6b, black grip #1a1a2e, small smartphone
#1a1a2e showing recording icon #cc0000). Visible motion: 3-4 curved
sand particle streams arcing around the tornado body. Single character
centered.
```

#### **D4: Pyramid Scheme Scarab**

- **Plik:** `assets/sprites/enemies/desert/pyramid_scheme_scarab.png`
- **Resource:** `relic_shards`
- **Joke:** "Zaufaj mi, to legalne."
- **Image reference:** `sand_karen.png`
- **Prompt:**

```
[PREFIX_ENEMY]
Generate in the EXACT same chibi cartoon pixel art style, outline
thickness, palette, and proportions as the reference image.
Subject: a CHIBI cartoon SCARAB BEETLE character in a BUSINESS SUIT —
desert biome enemy. Body: stylized chibi scarab beetle with iridescent
dark blue-purple shell (#5a2c82 base, #2a1840 shadow, #8855c4 highlight,
small #4a9eff iridescent shimmer dots). Oversized chibi beetle head with
two compound eyes (#1a1a2e segmented + small white #ffffff highlights),
two small antennae poking up. CLOTHING — a black formal business suit
jacket (#1a1a2e) over the beetle's body with white dress shirt collar
visible (#ffffff) and a bright red tie (#cc3344). PROPS — holding a
brown leather briefcase (#6a4a2a base, #4a2a14 shadow, #8c8c8c metal
clasp) in one of its six legs, briefcase has a clearly visible label
"SCAM" written on it in messy white text (#ffffff). Cartoon expression:
forced overly-friendly smile (cartoon mouth), one antenna slightly
twitching suspiciously. Single character centered.
```

#### **D5: Sandstone Bouncer**

- **Plik:** `assets/sprites/enemies/desert/sandstone_bouncer.png`
- **Resource:** `relic_shards`
- **Joke:** "Sorry, not on the guest list, Pharaoh."
- **Image reference:** `sand_karen.png`
- **Prompt:**

```
[PREFIX_ENEMY]
Generate in the EXACT same chibi cartoon pixel art style, outline
thickness, palette, and proportions as the reference image.
Subject: a CHIBI cartoon STONE GOLEM BOUNCER character — desert biome
enemy. Body: muscular humanoid made entirely of carved sandstone blocks
(#a67c3a base, #6a4a20 shadow in carved seams, #d4a070 highlight on
raised surfaces), visible square block carvings on chest and arms
suggesting brick-like construction. CHIBI PROPORTIONS — oversized
square head, but very wide muscular shoulders (~80% of body width), arms
crossed dramatically across chest in classic bouncer pose. PROPS — black
sunglasses (#1a1a2e frames, #4a4a4a opaque lenses), small earpiece in
one ear with thin curly wire (#1a1a2e), red velvet rope loop draped
over one forearm (#cc3344 rope + #ffd700 gold tassel ends). Cartoon
expression: completely stoic, mouth flat line, slightly raised stone
eyebrow (#1a1a2e thick line). EGYPTIAN MOTIF — small hieroglyph carving
visible on chest plate (#3a3530 carved lines: simple ankh symbol).
Single character centered.
```

### 3.3 Boss: **Ramboses — Pharaoh of Vengeance** (stage 55)

> ⚠️ **Stage 50 jest już zajęty** przez ULTIMATE BOSS Saddam on the Raft (istniejący endgame v0.6.5). Ramboses przesunięty na **stage 55** jako "true desert boss" kończący biome. Stage 50 zostaje Saddam (joke milestone "skończyłeś v1.0").
>
> **Visual continuity bonus:** Saddam też ma gumową kaczkę — Ramboses z kaczką to teraz **callback** ("learned from the best"), nie powtórzenie.

> 🎬 **Klimat:** parodia akcji 80s w stylu **Hot Shots! Part Deux** (Rambo parody z Charlie Sheen) + **Naked Gun** (deadpan Leslie Nielsen). Bohater jest śmiertelnie poważny w totalnie absurdalnej sytuacji.

- **Plik:** `assets/sprites/enemies/desert/boss_ramboses.png` *(zmiana nazwy z `boss_ramzes.png` — żeby commit zachował joke; jeśli wolisz stary plik, zostaw `boss_ramzes.png`)*
- **Greeting (3 warianty do wyboru — patrz niżej)**
- **Image reference:** `assets/sprites/enemies/boss_brad.png`
- **Prompt:**

```
[PREFIX_BOSS]
Generate in the EXACT same chibi cartoon pixel art style, outline
thickness, palette, and proportions as the reference boss image.
Subject: a CHIBI cartoon RAMBO-STYLE SHIRTLESS PHARAOH BOSS — Ramboses,
Pharaoh of Vengeance. Style reference: 80s action movie parody (Hot
Shots Part Deux / Rambo / Predator), but kept fully cartoon and
deadpan-serious. The character takes himself COMPLETELY seriously
despite the absurd setup.

BODY: SHIRTLESS muscle-bound humanoid pharaoh, OILED bronze-tan skin
(#c49060 base, #8a6030 deep shadow under muscles, #f5d4a0 highlight on
chest and biceps). EXAGGERATED CARTOON MUSCLES — chest pectorals
ridiculously oversized (rounded bulges with deep #8a6030 shadow lines
between them), biceps the size of his own head, six-pack abs clearly
defined (4-6 squared muscle blocks #8a6030 outlines on lower torso),
forearms thick like tree branches. Painted-on vein details on biceps
(#8a4030 thin curved lines suggesting bulging veins). Slight sweat
sheen suggested with #ffffff highlight dots on chest and forehead.

HEAD: oversized chibi pharaoh head (~50% of height) with deadpan
tough-guy squint — one eye half-closed (#1a1a2e thin line), other eye
fully open showing #ffffff sclera + #1a1a2e pupil + small #ffd700
gold iris glint (intense "I have seen things" stare). Strong jaw,
flat mouth line (no smile, completely serious). EGYPTIAN KOHL EYE
MAKEUP smeared like RAMBO WAR PAINT — thick black streaks (#1a1a2e)
under eyes extending dramatically outward to temples, vaguely
hieroglyph-shaped. A single sweat drop running down one temple
(#4a9eff + #ffffff highlight).

HEADGEAR: red BANDANA / HEADBAND tied around the forehead (#cc3344
base, #8a1a28 shadow on knot, #ff5566 highlight on top of fold) —
the signature Rambo / Hot Shots headband. The traditional pharaoh
NEMES headdress is PUSHED BACK behind the head like a bandana cape
(striped gold #ffd700 and dark blue #2a4a7a stripes visible
trailing behind), instead of properly worn on top. This creates a
"too cool for traditional pharaoh attire" look.

PROPS — RIGHT ARM: holds a MASSIVE GOLD-PLATED MINIGUN / GATLING GUN
(comically oversized, ~40% of canvas width, 6 rotating barrels visible
#ffd700 + #8a6a20 shadow, body with ankh-symbol engravings #2a4a7a
detail, ammunition belt feeding into the side from a small backpack
ammo box). Trigger finger ready. The minigun's barrels SLIGHTLY GLOW
at the tips (#ffaa44 + #ffffff hot core dots).

PROPS — LEFT ARM: hanging at side, casually holding an ABSURDLY SMALL
PROP for contrast — a tiny YELLOW RUBBER DUCKY (#ffd700 + #ff6b00 beak
+ #1a1a2e dot eyes, Naked Gun bath-toy energy). The contrast between
the giant minigun and the tiny rubber ducky is the visual joke.

CROSS-BODY: thick BULLET BELT slung across the bare chest from
shoulder to opposite hip, made of GOLDEN ANKH-SHAPED BULLETS
(#ffd700 ankh shapes with #8a6a20 shadow, 8-10 visible large ankhs
spaced along a #1a1a2e leather strap, the ankhs replace standard
bullet shapes — Egyptian Rambo crossover detail).

LOWER BODY: traditional pharaoh KILT / SHENDYT skirt (striped white
#ffffff and gold #ffd700, traditional Egyptian style), but slightly
tattered at the edges (combat-worn). Heavy military combat BOOTS
(#1a1a2e base, #4a4a4a sole shadow, #6b6b6b highlight on tip) instead
of pharaoh sandals — modern combat boots breaking the Egyptian era
on purpose.

ATMOSPHERE: a SINGLE FALLEN PALM LEAF (#3d6e3a) drifting in front of
him (suggesting he just walked through an explosion), a faint heat
haze around the silhouette (#ff9a4a + #ffaa44 thin wavy lines, sparse).

GLOW: subtle golden aura around the silhouette (#ffd700 + #ffaa44,
6-10 px outer glow). DESERT palette: oiled bronze skin, gold accents,
sandy backdrop tones, red bandana as accent color.

EXPRESSION OVERALL: 100% deadpan serious. He does not know he's a
joke. This is normal Tuesday for him.
```

#### Greeting (wybierz jeden):

1. **🎯 "Surely you can't be serious. I am Pharaoh. And don't call me Sherbet."** *(Naked Gun "Surely / Shirley" reference + pharaoh pun, najbliżej oryginalnego Drebin humoru)*
2. **🎯 "I have a permit for this minigun. Pharaoh's permit."** *(Drebin-style absurd authority — krócej, bardziej "deadpan cop")*
3. **🎯 "Negotiation? Wrong pharaoh."** *(Rambo / Hot Shots tough-guy one-liner — najprostsze, najczytelniejsze)*

**Moja rekomendacja: #1** — najmocniej oddaje vibe Leslie Nielsen + jest długi enough na boss greeting overlay (krótki znika za szybko).

> 💡 **Po wyborze:** zaktualizuj greeting w `boss_roster` w `src/scenes/GameBattleManager.gd` (linia ~482) ORAZ w [ISSUE-18 sekcja "Nowy boss"](issues/ISSUE-18_desert_biome.md#nowy-boss).

---

## 4. Frozen Peaks biome (Phase 2 — stage 56-75)

### 4.1 Tło: `assets/sprites/FrozenPeaks.jpeg`

```
[PREFIX_BG]
Frozen Peaks biome — snowy Himalayan mountains with ancient ice temple
ruins. Foreground (lower 30%): snowy ground (#e8f4f8 base, #c4dce8
shadow, sparse darker rocks #8e9aab poking through snow), small icicles
hanging from a rock ledge in the immediate foreground. Midground
(middle 30%): partially frozen stone temple ruins (#8e9aab stone, ice
overlay #c4dce8 + #ffffff highlights), arched doorway entrance with
icicles hanging from the arch, two stone pillars wrapped in glowing
blue ice crystals (#5c9cc4 ice + #ffffff core glow). Background (upper
40%): towering snow-capped Himalayan mountain peaks (#a8b8c8 rock base,
#ffffff snow caps, atmospheric haze), gray-blue overcast sky (#8e9aab
darker → #c4dce8 lighter) with snowfall (small white #ffffff pixel dots
scattered as falling snow). Cold atmospheric depth. Pixel art painterly
style.
```

### 4.2 Frozen enemies (5 sztuk)

#### **F1: Frostbite Yeti Barista** (anchor)

- **Plik:** `assets/sprites/enemies/frozen/yeti_barista.png`
- **Resource:** `venom`
- **Joke:** "Iced latte? It's all I serve here."
- **Prompt (BEZ image reference):**

```
[PREFIX_ENEMY]
Subject: a CHIBI cartoon YETI BARISTA character — frozen peaks biome
enemy. Body: small fluffy yeti with white-blue tinted fur (#e8f4f8
base, #c4dce8 shadow, #ffffff highlights), short stubby legs, big
furry arms. Oversized chibi yeti head with large round eyes
(#1a1a2e pupils + white #ffffff sclera + small #5c9cc4 ice-blue iris
ring), small black nose (#1a1a2e), open mouth showing two small fangs
(#ffffff) and a cartoon "ready to serve you" expression. CLOTHING — a
brown coffee shop apron (#6a4a2a base, #4a2a14 shadow) tied around the
waist with white #ffffff name tag pinned to chest. PROPS — holding a
large white ceramic coffee cup (#ffffff base, #c4dce8 shadow on lower
half, dark brown coffee inside visible from top #2a1810) in one paw,
ICY MIST visibly rising from the cup (#c4dce8 + #ffffff misty pixels,
spiraling upward in 3-4 wisps), other paw holds a small metal coffee
scoop (#8c8c8c). FROZEN palette: cold blue accents, white fur, brown
apron contrast.
```

#### **F2: Sherpa Skeleton**

- **Plik:** `assets/sprites/enemies/frozen/sherpa_skeleton.png`
- **Resource:** `bandages`
- **Joke:** "I've been climbing for 200 years. Almost there."
- **Image reference:** `yeti_barista.png`
- **Prompt:**

```
[PREFIX_ENEMY]
Generate in the EXACT same chibi cartoon pixel art style, outline
thickness, palette, and proportions as the reference image.
Subject: a CHIBI cartoon SKELETON MOUNTAIN CLIMBER — frozen peaks biome
enemy. Body: humanoid skeleton with off-white bones (#e0e0d8 bone base,
#a8a89c shadow, #ffffff highlight). Oversized chibi skull head with
hollow black eye sockets (#1a1a2e voids), forced grinning teeth.
CLOTHING — a heavy red parka jacket (#cc3344 base, #8a1a28 shadow,
#ff5566 highlight) zipped up over the skeleton's torso, fur-lined hood
(#ffffff fluffy texture) currently down behind the head. PROPS — red
mountain climbing GOGGLES (#cc3344 strap, #1a1a2e frame, #4a9eff
reflective blue lens with #ffffff glint) worn across the skull's eye
sockets. A COILED ROPE slung over one shoulder (#c4a060 tan rope coil,
#8b6914 shadow). An ICE AXE held in one bony hand (#6b6b6b metal head,
#8b6914 wooden handle, sharp pointed pick). Small ice crystals on the
parka shoulders (#c4dce8). Cartoon "still optimistic" expression.
```

#### **F3: Avalanche Penguin**

- **Plik:** `assets/sprites/enemies/frozen/avalanche_penguin.png`
- **Resource:** `venom`
- **Joke:** "Tap-tap-tap. BOOM."
- **Image reference:** `yeti_barista.png`
- **Prompt:**

```
[PREFIX_ENEMY]
Generate in the EXACT same chibi cartoon pixel art style, outline
thickness, palette, and proportions as the reference image.
Subject: a CHIBI cartoon PENGUIN with a FRYING PAN — frozen peaks biome
enemy. Body: small round chibi penguin with black back/head (#1a1a2e
base, #3a3a4a shadow, #5a5a6a highlight on rounded top of head) and
WHITE belly oval (#ffffff base, #c4dce8 shadow at edges). Tiny orange
feet (#f58a4a) and small orange beak (#f58a4a). Oversized chibi penguin
head with large cross-eyed CROSSEYED expression (both pupils pointing
inward toward beak, white #ffffff sclera, #1a1a2e pupils) — comedic
"about to do something dumb" look. PROPS — clutching a LARGE CAST IRON
FRYING PAN with BOTH tiny wings/flippers (#1a1a2e pan base, #4a4a4a
slight highlight rim, brown wooden handle #6a4a2a with #4a2a14 grip
detail), pan held horizontally as if about to slam down. A tiny puff
of snow dust around the penguin's feet (#ffffff + #c4dce8 dots).
Cartoon "about to cause an avalanche" energy.
```

#### **F4: Ice Crystal Mage**

- **Plik:** `assets/sprites/enemies/frozen/ice_crystal_mage.png`
- **Resource:** `relic_shards`
- **Joke:** "Cool. Literally."
- **Image reference:** `yeti_barista.png`
- **Prompt:**

```
[PREFIX_ENEMY]
Generate in the EXACT same chibi cartoon pixel art style, outline
thickness, palette, and proportions as the reference image.
Subject: a CHIBI cartoon ICE MAGE character — frozen peaks biome enemy.
Body: humanoid figure made of TRANSLUCENT ICE (#5c9cc4 ice-blue base,
#88c4e8 highlight, #ffffff frozen interior crystals visible through
the body — suggested with small white pixel clusters inside the
silhouette as if looking into ice). Oversized chibi head with glowing
icy blue eyes (#88c4e8 iris + #ffffff hot core dot, no pupils — pure
glow). Mouth: small icicle-like mouth pixels (#ffffff). CLOTHING — a
flowing wizard ROBE made of darker frozen ice (#5c9cc4 base, #3a5870
shadow folds, #c4dce8 highlight on raised folds), draped to cover most
of the body. A tall pointed wizard HAT made of ice (#5c9cc4 base,
#ffffff frosty highlights, #c4dce8 brim shadow), with a small dark
blue band (#2a4a7a) around the base of the hat. PROPS — holding a wooden
staff (#8b6914 wood, #6a4a2a darker shadow) topped with a glowing
hexagonal ICE CRYSTAL (#88c4e8 + #ffffff bright core + #4a9eff outer
glow, 6-sided geometric shape clearly visible). Magical mist of ice
particles spiraling around the staff tip (#ffffff + #c4dce8 sparse
dots). Cartoon "smugly cold" expression.
```

#### **F5: Frozen Tourist**

- **Plik:** `assets/sprites/enemies/frozen/frozen_tourist.png`
- **Resource:** `bandages`
- **Joke:** "Mówiłem mu żeby wziął kurtkę."
- **Image reference:** `yeti_barista.png`
- **Prompt:**

```
[PREFIX_ENEMY]
Generate in the EXACT same chibi cartoon pixel art style, outline
thickness, palette, and proportions as the reference image.
Subject: a CHIBI cartoon TOURIST FROZEN IN A BLOCK OF ICE — frozen peaks
biome enemy. Body: cubic block of translucent ice (#88c4e8 base, #5c9cc4
shadow on side, #ffffff highlight on top corners, slight #4a9eff inner
glow) with a clearly visible CHIBI TOURIST trapped inside, frozen
mid-pose. Visible through the ice: a chibi human tourist with pale
blue-tinted skin (#a8c4d8 frozen skin tone — clearly cold), wearing a
bright Hawaiian shirt (#ffffff base with #cc3344 hibiscus pattern and
#3d6e3a palm leaves — same shirt style as Cursed Tourist from temple
biome for visual continuity), khaki shorts (#c4a570), and flip-flops
(#3a3530). Expression: shocked surprised face (eyes wide #ffffff sclera
+ #1a1a2e pupils, mouth open in an "O" shape #1a1a2e). The tourist is
posed like he was JUST about to do something casual when he got
frozen instantly. PROPS visible inside ice: a small camera (#2a2a2a)
on a neck strap. The ice block has small frost cracks on the surface
(thin #ffffff lines, geometric). Cartoon "I told him to bring a coat"
absurdity.
```

### 4.3 Boss: **Yeti CEO** (stage 65)

- **Plik:** `assets/sprites/enemies/frozen/boss_yeti_ceo.png`
- **Greeting:** "Q4 results: cold. Very cold."
- **Image reference:** `boss_brad.png`
- **Prompt:**

```
[PREFIX_BOSS]
Generate in the EXACT same chibi cartoon pixel art style, outline
thickness, palette, and proportions as the reference boss image.
Subject: a CHIBI cartoon YETI CEO BOSS — Yeti CEO of "Cold Industries
Inc." Body: large muscular yeti with thick white-blue tinted fur
(#e8f4f8 fur base, #c4dce8 shadow, #ffffff highlights), broad shoulders,
visible muscle definition under the fur. CHIBI BUT IMPOSING — oversized
yeti head (~55% of height) with thick eyebrows (#1a1a2e arched angrily),
piercing icy blue eyes (#5c9cc4 iris + #ffffff core dots), open mouth
showing two prominent canine fangs (#ffffff). CLOTHING — a BUSINESS SUIT
custom-tailored for a yeti: dark navy blue suit jacket (#2a4a7a base,
#1a2a4a shadow, #4a6e9e highlight) with white dress shirt collar visible
(#ffffff), bright red power tie (#cc3344). The suit is stretched over
the massive yeti shoulders. PROPS — left paw holds a corporate AWARD
TROPHY (golden plaque #ffd700 base, #8b6914 wooden base shadow,
engraved with "CEO 2026" #1a1a2e text), right paw holds an ANNUAL
REPORT folder (dark blue folder #2a4a7a with #ffd700 gold trim, white
paper sticking out #ffffff). Pinstripe details on the suit lapels
(#1a2a4a thin stripes). Subtle icy aura around the silhouette (#5c9cc4
+ #ffffff outer glow, 8-10 px). Cartoon "I have bad news for shareholders"
power-pose expression.
```

---

## 5. Catacombs biome (Phase 3 — stage 76-95)

### 5.1 Tło: `assets/sprites/Catacombs.jpeg`

```
[PREFIX_BG]
Catacombs biome — underground stone burial chamber with lava rivers
running through. Foreground (lower 30%): dark cobblestone floor
(#3d2e1f base, #1a0e08 shadow between stones), small skull #c4b8a0
half-buried, glowing CRACKS in the floor revealing molten lava beneath
(#ff6b35 + #ff9a5a glow). Midground (middle 30%): massive carved stone
arch entrance (#5a4030 base, #3d2e1f shadow, #8a6850 highlight),
intricate dark runes carved into the arch glowing PURPLE (#5a2c82 +
#8855c4 + small #ffffff hot core dots). Two stone braziers flanking
the arch with crackling ORANGE flames (#ff6b35 + #ffaa44 + #ffffff
hot core). Background (upper 40%): cavernous ceiling with stalactites
(#3d2e1f base, #1a0e08 shadow), a distant glowing LAVA RIVER snaking
through the cave (#ff6b35 + #ffaa44, partially obscured by mist), the
ceiling shrouded in dark mist (#2a1810 thinning to #3d2e1f). Dark
atmospheric depth, ominous but not horror — pixel art painterly style.
```

### 5.2 Catacombs enemies (5 sztuk)

#### **C1: Lava Lich** (anchor)

- **Plik:** `assets/sprites/enemies/catacombs/lava_lich.png`
- **Resource:** `relic_shards`
- **Joke:** "Im hotter I get, the cooler I look."
- **Prompt (BEZ image reference):**

```
[PREFIX_ENEMY]
Subject: a CHIBI cartoon LAVA LICH — catacombs biome enemy. Body:
humanoid skeleton with charred dark bones (#3a2820 base, #1a0e08 shadow,
#5a4030 highlight on raised edges) — bones that have been baked in lava.
Oversized chibi skull head with GLOWING ORANGE eye sockets (#ff6b35
glow + #ffaa44 inner + #ffffff hot core dots), no jaw movement, fixed
grinning teeth (#c4a070 yellowed teeth). PROPS — a golden CROWN sitting
atop the skull (#ffd700 base, #8a6a20 shadow), but the crown is PARTIALLY
MELTED, with golden molten droplets dripping down the sides of the
skull (#ffd700 + #ffaa44 droplets, suggesting heat). CLOTHING — tattered
dark red robe (#8a1a28 base, #5a0e1a shadow) hanging in scorched strips,
ember sparks visibly glowing through the holes (#ff6b35 + #ffffff sparks).
LAVA POOL at the base — the lich is STANDING IN a small pool of bubbling
lava (#ff6b35 lava base, #ffaa44 highlights, #ffffff hot bubble cores —
3-4 round bubbles forming on the surface). Heat shimmer effect: subtle
wavy distortion lines around the lich (#ff6b35 thin lines, sparse).
CATACOMBS palette: orange lava + charred bone + gold crown contrast.
```

#### **C2: Crypt Bat Influencer**

- **Plik:** `assets/sprites/enemies/catacombs/crypt_bat_influencer.png`
- **Resource:** `venom`
- **Joke:** "Live from the crypt, smash that subscribe."
- **Image reference:** `lava_lich.png`
- **Prompt:**

```
[PREFIX_ENEMY]
Generate in the EXACT same chibi cartoon pixel art style, outline
thickness, palette, and proportions as the reference image.
Subject: a CHIBI cartoon VAMPIRE BAT with a RING LIGHT — catacombs
biome enemy. Body: small chibi bat with dark purple-black fur (#3a2840
base, #1a1028 shadow, #5a4060 highlight), large wings folded
behind/beside body (membrane #5a3060 with #8a4880 wing veins outlined).
Oversized chibi bat head with two large pointy ears (#3a2840 + pink
inner ear #ff66cc) sticking straight up, two large fangs visible in
open mouth (#ffffff). Eyes glowing slightly red (#cc3344 iris +
#ffffff core dot). PROPS — a RING LIGHT (the kind streamers use) on
a small bracket around the bat's neck, the ring light is GLOWING
BRIGHT WHITE-PINK (#ffffff core + #ff66cc outer glow, hexagonal ring
shape clearly visible, modern streamer aesthetic). Holding a small
black MICROPHONE in one wing-hand (#1a1a2e mic body + #8c8c8c mesh top
+ thin #1a1a2e cable trailing off). Cartoon "live now" influencer
energy — beaming forced smile, one fang slightly higher than the other.
A small "LIVE" red badge (#cc3344 + #ffffff "LIVE" text) floating
beside the bat.
```

#### **C3: Skeleton Knight HR**

- **Plik:** `assets/sprites/enemies/catacombs/skeleton_knight_hr.png`
- **Resource:** `bandages`
- **Joke:** "Let's circle back on this dungeon raid."
- **Image reference:** `lava_lich.png`
- **Prompt:**

```
[PREFIX_ENEMY]
Generate in the EXACT same chibi cartoon pixel art style, outline
thickness, palette, and proportions as the reference image.
Subject: a CHIBI cartoon SKELETON KNIGHT in HR PROFESSIONAL ARMOR —
catacombs biome enemy. Body: humanoid skeleton with off-white bones
(#e0e0d8 bone base, #a8a89c shadow, #ffffff highlight). Oversized chibi
skull head with hollow black eye sockets (#1a1a2e voids), but wearing
small reading GLASSES (#4a4a4a frame, #ffffff transparent lenses with
thin #4a9eff reflection lines) perched on the nasal cavity. CLOTHING —
medieval knight ARMOR: gray steel chestplate (#6b6b6b base, #8c8c8c
highlight, #4a4a4a shadow, visible rivets #8c8c8c dots), pauldrons
(shoulder armor #6b6b6b), and a helmet TUCKED UNDER ONE BONY ARM
(showing the unhelmeted skull). PROPS — RIGHT bony hand holds a
traditional medieval sword (#8c8c8c blade with #ffffff edge highlight,
#6a4a2a wooden grip with #4a2a14 wrap details, #ffd700 gold pommel).
LEFT bony hand holds a MANILA FOLDER stuffed with papers (#c4a060
folder base, #a08858 shadow, multiple white #ffffff paper edges
sticking out of the top, a few labels visible: red "URGENT" tag
#cc3344 + #ffffff text on top page). Cartoon "checking your performance
review" expression — slight head tilt, scrutinizing.
```

#### **C4: Magma Slime**

- **Plik:** `assets/sprites/enemies/catacombs/magma_slime.png`
- **Resource:** `venom`
- **Joke:** "Ouch. Don't touch."
- **Image reference:** `lava_lich.png`
- **Prompt:**

```
[PREFIX_ENEMY]
Generate in the EXACT same chibi cartoon pixel art style, outline
thickness, palette, and proportions as the reference image.
Subject: a CHIBI cartoon MAGMA SLIME — catacombs biome enemy. Body:
amorphous blob of molten lava-slime, rounded teardrop shape with a wider
bottom and a slightly pointed top (suggesting it's pulling itself up
into a "creature" shape). Color: bright orange-red molten core (#ff6b35
base, #ffaa44 highlight on top/upper-right, #cc3300 shadow on lower-left,
#ffffff hot core dot visible inside the body). Surface: textured with
small darker hardened patches like cooling lava crust (#8a3010 darker
patches scattered, 4-5 small spots). PROPS — two small chibi cartoon
EYES floating near the top of the blob (#1a1a2e pupils + #ffffff
sclera + small #ffaa44 amber glint), positioned closely together
(creating "two eyes on a blob" look). No mouth visible — pure expressive
eyes only. Bottom of the slime has dripping LAVA DROPLETS falling off
(#ff6b35 droplets + #ffaa44 highlights, 3-4 small drops mid-fall).
HEAT SHIMMER suggested with thin orange wavy lines (#ff6b35) around
the upper silhouette. Subtle inner glow (#ffaa44 + #ffffff) suggesting
heat radiating outward.
```

#### **C5: Cursed Pharaoh DJ**

- **Plik:** `assets/sprites/enemies/catacombs/pharaoh_dj.png`
- **Resource:** `relic_shards`
- **Joke:** "Drop the beat, drop the curse."
- **Image reference:** `lava_lich.png`
- **Prompt:**

```
[PREFIX_ENEMY]
Generate in the EXACT same chibi cartoon pixel art style, outline
thickness, palette, and proportions as the reference image.
Subject: a CHIBI cartoon PHARAOH MUMMY DJ — catacombs biome enemy.
Body: humanoid pharaoh mummy with off-white tattered bandages
(#f5dca0 base, #c4a070 shadow, #ffffff highlights, ragged edges)
wrapped around the body, lower half buried/emerging from an open
SARCOPHAGUS (#ffd700 gold trim + #2a4a7a blue inlay + #1a1a2e dark
interior visible). Oversized chibi mummy head — face wrapped in
bandages except for two glowing EYES (#5a2c82 purple glow +
#ffffff hot core). PROPS — Egyptian pharaoh NEMES headdress (gold
#ffd700 + dark blue stripes #2a4a7a) on top, BUT also wearing modern
LARGE OVER-EAR HEADPHONES over the headdress (#1a1a2e cups, #6b6b6b
band, #4a9eff small glowing logo dot on cups). Hands hovering over a
SARCOPHAGUS-SHAPED DJ TURNTABLE in front (the sarcophagus IS the DJ
booth — golden top #ffd700 with two black vinyl records #1a1a2e + #4a4a4a
inner ring labels, hieroglyphs glowing on the sides #5a2c82). One mummy
hand pressed flat on a vinyl as if SCRATCHING (#f5dca0 bandaged hand
on #1a1a2e record). Musical note pixels floating around the head
(#5a2c82 + #ffd700 note shapes). Cartoon "intense DJ focus"
expression — eyebrows down (#1a1a2e thick lines visible through
bandage gap).
```

### 5.3 Boss: **Skeleton CFO** (stage 80)

- **Plik:** `assets/sprites/enemies/catacombs/boss_skeleton_cfo.png`
- **Greeting:** "I'd love to help but I'm bone-broke."
- **Image reference:** `boss_brad.png`
- **Prompt:**

```
[PREFIX_BOSS]
Generate in the EXACT same chibi cartoon pixel art style, outline
thickness, palette, and proportions as the reference boss image.
Subject: a CHIBI cartoon SKELETON CFO BOSS — corporate finance skeleton
overlord. Body: humanoid skeleton with bleached white bones
(#e8e8e0 bone base, #b8b8a8 shadow, #ffffff highlights), with subtle
gold inlay etched into the bones (#ffd700 thin decorative lines
suggesting wealth). CHIBI BUT IMPOSING — oversized skull head (~55% of
height), hollow black eye sockets with small GLOWING GREEN DOLLAR-SIGN
PUPILS ($ symbols floating in the void: #5a8a3a + #ffffff core),
forced grinning teeth showing one GOLD TOOTH (#ffd700) among the
white teeth. PROPS / CLOTHING — three-piece BUSINESS SUIT: dark
charcoal jacket (#3a3a4a base, #1a1a2e shadow, #5a5a6a highlight)
with matching vest, white dress shirt (#ffffff), and a deep red silk
tie (#8a1a28 base, #cc3344 highlight). A GOLDEN POCKET WATCH
(#ffd700 + #1a1a2e clock face details) on a chain (#ffd700) hanging
from the vest. LEFT bony hand holds a LEDGER BOOK (red leather cover
#8a1a28 + #ffd700 trim, "ACCOUNTS" written on cover #ffd700). RIGHT
bony hand holds a fountain pen (#1a1a2e + #ffd700 nib). On the
skeleton's lap area, a small mound of GOLD COINS spilling
(#ffd700 + #8a6a20 shadow, 5-6 visible coins). Subtle dark green
aura (#5a8a3a money-themed glow, 8-10 px). Cartoon "your soul is now
collateral" expression.
```

### 5.4 Boss: **Anglerfish Tycoon** (stage 95) — boundary boss (Catacombs → Atlantis)

- **Plik:** `assets/sprites/enemies/catacombs/boss_anglerfish_tycoon.png`
- **Greeting:** "Investors! Investors! Investors!"
- **Image reference:** `boss_brad.png`
- **Prompt:**

```
[PREFIX_BOSS]
Generate in the EXACT same chibi cartoon pixel art style, outline
thickness, palette, and proportions as the reference boss image.
Subject: a CHIBI cartoon DEEP-SEA ANGLERFISH TYCOON BOSS — corporate
fish overlord (boundary creature between catacombs and atlantis biomes).
Body: large round chibi anglerfish with very dark blue-black body
(#1a2840 base, #0a1828 shadow, #3a4860 highlight on rounded top),
HUGE oversized mouth opening downward with massive sharp pointed teeth
(#ffffff teeth, #1a1a2e dark interior of mouth — but mouth shape is
cartoon-funny not horror). Tiny stubby fins on sides (#1a2840 + #3a4860).
ICONIC FEATURE — the angler's BIOLUMINESCENT LURE: a thin antenna-like
appendage (#1a1a2e) extending up and forward from the top of the head,
ending in a glowing bulb. BUT instead of a normal glowing bulb, the
lure is a GLOWING DOLLAR SIGN $ (bright green-gold #5a8a3a + #ffd700 +
#ffffff hot core, clearly recognizable $ symbol shape). PROPS — wearing
a tiny BLACK TOP HAT (#1a1a2e + #6b6b6b band with #ffd700 trim) tilted
jauntily on the angler's head. A small bow tie (#cc3344) under the
chin. Holding (with one tiny fin) a CIGAR (#6a4a2a brown + #ff6b35 ember
tip + thin #c4c4d8 smoke wisps) puffing smoke. Cartoon "ready to
acquire your soul" smug grin showing all teeth. Subtle deep underwater
glow around the silhouette (#4a9eff + #5a8a3a outer glow, 8-12 px).
```

---

## 6. Sunken Atlantis biome (Phase 4a — stage 96-120)

### 6.1 Tło: `assets/sprites/Atlantis.jpeg`

```
[PREFIX_BG]
Sunken Atlantis biome — ancient underwater ruined city, view from
within the underwater scene. Foreground (lower 30%): sandy seafloor
(#88e5cf sandy turquoise base, #5a8a78 shadow), scattered shells
(#ff8674 + #ffffff) and coral fragments (#ff8674 pinkish coral, #88e5cf
green coral), partial broken column lying on the floor (#c4c0b8 stone).
Midground (middle 30%): two tall ancient Greek-style stone columns
(#c4c0b8 weathered marble base, #8a8478 shadow, #e8e4d8 highlight,
covered in patches of orange-pink coral #ff8674), arched temple
entrance partially submerged behind them, glowing turquoise runes on
columns (#1abc9c + #ffffff). Background (upper 40%): underwater
twilight scene — deep turquoise water (#1abc9c top → #2c3e50 deeper
darker turquoise at edges), light beams from above piercing down
(#88e5cf semi-transparent rays, 3-4 visible angled diagonal bands),
small schools of fish silhouettes (#2c3e50 simple shape silhouettes,
distant). Air bubbles rising on the sides (#ffffff + #c4dce8 small
dots in vertical streams). Calm but mysterious underwater atmosphere.
```

### 6.2 Atlantis enemies (5 sztuk)

#### **A1: Anglerfish Lawyer** (anchor)

- **Plik:** `assets/sprites/enemies/atlantis/anglerfish_lawyer.png`
- **Resource:** `venom`
- **Joke:** "Sign here. And here. The fine print is fine."
- **Prompt (BEZ image reference):**

```
[PREFIX_ENEMY]
Subject: a CHIBI cartoon DEEP-SEA ANGLERFISH LAWYER — atlantis biome
enemy. Body: small round chibi anglerfish with dark blue-purple body
(#2a2c5a base, #1a1c4a shadow, #4a4c7a highlight on rounded top), small
fins on sides (#2a2c5a + #4a4c7a), oversized mouth showing sharp
pointed teeth (#ffffff teeth, #1a1a2e mouth interior). ICONIC FEATURE —
bioluminescent LURE antenna extending upward and forward (#1a1a2e thin
line) ending in a glowing bulb. The bulb is shaped like a tiny scales
of justice ⚖ icon (#ffd700 + #ffffff hot core glow). EYES — two small
eyes near the upper face (#1a1a2e pupils + #ffffff sclera + #4a9eff
small blue glint each — calculating "billable hours" look). PROPS —
wearing a stiff white legal COLLAR (#ffffff base, #c4dce8 shadow) like
a barrister's neck-band. A small dark briefcase clutched by one tiny
fin (#1a1a2e briefcase + #6b6b6b metal latch + #ffd700 trim, "LEGAL"
visible in tiny white text #ffffff). Holding a quill pen with the
other fin (#ffffff feather + #4a4a4a tip). A small "Sign Here →"
arrow floating beside (#cc3344 + #ffffff text). ATLANTIS palette:
turquoise underwater accents, coral pink contrast on lure.
```

#### **A2: Mermaid Karen**

- **Plik:** `assets/sprites/enemies/atlantis/mermaid_karen.png`
- **Resource:** `bandages`
- **Joke:** "How am I supposed to post this without signal?!"
- **Image reference:** `anglerfish_lawyer.png`
- **Prompt:**

```
[PREFIX_ENEMY]
Generate in the EXACT same chibi cartoon pixel art style, outline
thickness, palette, and proportions as the reference image.
Subject: a CHIBI cartoon MERMAID KAREN — atlantis biome enemy. Body:
chibi mermaid with human upper torso (pale skin #f5d4b8 base, #d4a878
shadow, #ffffff highlight on cheeks) and a long FISH TAIL lower body
(turquoise scales #1abc9c base, #0d8a78 shadow, #88e5cf highlight,
visible scale texture suggested with small darker turquoise spots).
Oversized chibi head with that SIGNATURE KAREN BLONDE BOB haircut
(#d4b88a beige-blonde base, #a08858 shadow, asymmetric flip — longer
in front, shorter at back, exact 2010s Karen style). Eyes: narrow
disapproving (#1a1a2e thick angry eyebrows + #1a1a2e pupils + #ffffff
sclera, mouth open mid-complaint). PROPS — holding a smartphone in one
hand (#1a1a2e phone + #4a9eff screen showing "NO SIGNAL" symbol with
a red ❌ icon #cc3344), the other hand reached up dramatically as if
asking for help. A single TEAR sliding down one cheek (#4a9eff + #ffffff
core dot, dramatic single tear). A small CORAL JEWELRY necklace
(#ff8674 + #88e5cf small bead detail) around the neck. Air bubbles
floating up from the angry sigh out of her mouth (#ffffff + #c4dce8
small dots, 4-5 bubbles in a stream).
```

#### **A3: Coral Reef Goblin**

- **Plik:** `assets/sprites/enemies/atlantis/coral_goblin.png`
- **Resource:** `relic_shards`
- **Joke:** "Tak, jestem skarbnicą NFT z 2017."
- **Image reference:** `anglerfish_lawyer.png`
- **Prompt:**

```
[PREFIX_ENEMY]
Generate in the EXACT same chibi cartoon pixel art style, outline
thickness, palette, and proportions as the reference image.
Subject: a CHIBI cartoon CORAL GOBLIN — atlantis biome enemy. Body:
small humanoid goblin entirely encrusted with CORAL growths instead of
normal skin — vibrant orange-pink coral texture (#ff8674 base,
#cc5a4a shadow in coral crevices, #ffaa90 highlight on raised coral
bumps, visible small holes/pores #cc5a4a). Oversized chibi goblin head
with pointed ears poking through the coral growths, two large round
eyes (#1a1a2e pupils + #ffffff sclera + #ffd700 small gold glint each —
"valuable treasure" eye reflection), wide chibi grin showing tiny teeth
(#ffffff). Body is humanoid but with stubby limbs. PROPS — holding up
a single shiny GOLD COIN (#ffd700 base, #8a6a20 shadow, with engraved
"NFT" text on the coin face #1a1a2e small lettering) toward the viewer
proudly, like a salesperson showing off. The other hand has a small
coin pouch (#8b6914 leather + #ffd700 spilling coins peeking out).
Small bubbles rising from the goblin's head (#ffffff + #c4dce8 dots).
A few coral polyps with tiny tentacles wiggling on the goblin's
shoulders (#ff8674 + #ffaa90).
```

#### **A4: Kraken Intern**

- **Plik:** `assets/sprites/enemies/atlantis/kraken_intern.png`
- **Resource:** `venom`
- **Joke:** "Cały dzień przynosi kawy."
- **Image reference:** `anglerfish_lawyer.png`
- **Prompt:**

```
[PREFIX_ENEMY]
Generate in the EXACT same chibi cartoon pixel art style, outline
thickness, palette, and proportions as the reference image.
Subject: a CHIBI cartoon BABY KRAKEN INTERN — atlantis biome enemy.
Body: small round chibi octopus/kraken with purple skin (#5a2c82 base,
#3a1860 shadow, #8855c4 highlight on rounded top of head), 8 visible
tentacles fanning out from the body (each tentacle shorter than the
body, #5a2c82 base + #8855c4 highlight + #3a1860 shadow on underside,
visible small suction cups #ff66cc dots along the underside of each).
Oversized chibi kraken head (head and body are one shape — typical
octopus design) with two large round eyes (#1a1a2e pupils + #ffffff
sclera + small #ffd700 glint each — overworked-intern expression),
small mouth (#1a1a2e) with a tired half-frown. PROPS — each of the 8
TENTACLES holds a coffee CUP: 4 cups are standard white takeaway cups
with brown coffee visible from top (#ffffff + #c4dce8 + #6a4a2a coffee),
2 cups are larger latte cups (#ffffff with #d4b88a foam art on top),
2 cups are espresso shots (#ffffff small + #2a1810 black coffee). A
small tie around the kraken's neck (#cc3344 — corporate intern uniform
hint). Tiny bubbles around the head from heavy sighing (#ffffff +
#c4dce8 dots). Cartoon "I have a meeting in 5 minutes" energy.
```

#### **A5: Atlantean Karen Queen** (mini-boss / strong enemy)

- **Plik:** `assets/sprites/enemies/atlantis/atlantean_queen.png`
- **Resource:** `relic_shards`
- **Image reference:** `anglerfish_lawyer.png` (mimo że to mini-boss — używamy enemy reference, bo to nie pełny boss)
- **Prompt:**

```
[PREFIX_ENEMY]
Generate in the EXACT same chibi cartoon pixel art style, outline
thickness, palette, and proportions as the reference image. Make this
character slightly LARGER and more detailed than other enemies (this is
a stronger elite enemy).
Subject: a CHIBI cartoon ATLANTEAN KAREN QUEEN — atlantis biome
mini-boss. Body: humanoid woman in an elegant gown made of WATER SILK
(#1abc9c base flowing turquoise fabric, #0d8a78 shadow folds, #88e5cf
highlight, suggested motion lines #ffffff in the silk). Oversized
chibi head with that SIGNATURE KAREN BLONDE BOB haircut (#d4b88a base,
#a08858 shadow, asymmetric flip) but with regal modifications: a
TIARA / CROWN made of SHELLS AND CORAL on top of her head
(#ff8674 coral + #ffffff pearls + #ffd700 gold trim arching upward).
Eyes: piercing turquoise (#1abc9c iris + #ffffff core), thick angry
eyebrows (#1a1a2e arched), mouth open mid-demand. PROPS — both hands
gripping a TRIDENT (a regal underwater scepter: #ffd700 golden shaft,
#88e5cf turquoise blade tines with #ffffff highlights). A regal pose
— one hand high holding the trident, the other hand on hip. JEWELRY:
oversized pearl earrings (#ffffff + #c4dce8 shadow), coral necklace
(#ff8674). Aura of bubbles surrounding her (#ffffff + #c4dce8 small
dots forming a halo around the silhouette). Cartoon "I demand to speak
to whoever runs this OCEAN" expression.
```

---

## 7. Sky Temple biome (Phase 4b — stage 121+, endgame)

### 7.1 Tło: `assets/sprites/SkyTemple.jpeg`

```
[PREFIX_BG]
Sky Temple biome — floating ancient temple in the clouds, endgame
heavenly scene. Foreground (lower 30%): pastel pink-purple fluffy
clouds (#f5c5dd base, #d4a4c4 shadow, #ffffff highlights), the edge of
a floating golden marble platform extending from below (#ffd700 trim +
#ffffff marble + #a08aa0 shadow side). Midground (middle 30%): grand
floating temple structure — golden marble columns with white tops
(#ffd700 + #ffffff + #a08aa0 shadow), arched golden doorway (#ffd700
filigree), ornate temple roof with multiple tiers (#ffffff marble +
#ffd700 trim), strands of glowing golden mist drifting between columns
(#ffd700 + #ffffff semi-transparent). Background (upper 40%): infinite
heavenly sky — gradient from pastel pink (#f5c5dd lower) to soft
lavender (#d4a4c4 mid) to pale blue-white at the very top (#e8f4f8),
floating pastel clouds at various depths (#ffffff + #f5c5dd softer +
#d4a4c4 darker for depth), distant sun glow in upper-right area
(#fafafa + #ffd700 outer ring, soft warm light). A few tiny floating
golden particle sparkles throughout (#ffd700 + #ffffff dots, sparse).
Dreamy peaceful endgame atmosphere — pixel art painterly heavenly
style.
```

### 7.2 Sky Temple enemies (5 sztuk)

#### **S1: Cloud Cultist** (anchor)

- **Plik:** `assets/sprites/enemies/sky/cloud_cultist.png`
- **Resource:** `relic_shards`
- **Joke:** "Up here, the WiFi is divine."
- **Prompt (BEZ image reference):**

```
[PREFIX_ENEMY]
Subject: a CHIBI cartoon CLOUD CULTIST MONK — sky temple biome enemy.
Body: humanoid figure dressed in a long flowing WHITE ROBE (#fafafa
base, #d4d4d4 shadow folds, #ffffff highlight on raised folds) that
hides the legs, making the figure appear to LEVITATE on a small pink
cloud (#f5c5dd cloud base, #d4a4c4 shadow, #ffffff highlight pop).
Oversized chibi head HIDDEN inside a deep hood — only the BOTTOM half
of the face visible (#f5d4b8 pale skin chin, mouth in a serene closed-
lip smile #d4a4a4), the eyes and upper face in deep shadow inside the
hood (#1a1a2e void). PROPS — hands held out in front of the body in a
PRAYING / MEDITATION mudra (#f5d4b8 skin, fingers pressed together
pointing upward). A small GOLDEN AMULET hanging from the neck on a thin
chain (#ffd700 sun/star shape + #ffffff core glow). The robe has a
golden trim along the bottom edge (#ffd700 thin line, slightly wavy as
if blown by breeze). A few small white-pink floating wisps around the
figure (#ffffff + #f5c5dd particle dots). SKY palette: white robe,
pink cloud, gold accents.
```

#### **S2: Sky Pirate Parrot**

- **Plik:** `assets/sprites/enemies/sky/sky_pirate_parrot.png`
- **Resource:** `venom`
- **Joke:** "Polly want a relic, AAARRR!"
- **Image reference:** `cloud_cultist.png`
- **Prompt:**

```
[PREFIX_ENEMY]
Generate in the EXACT same chibi cartoon pixel art style, outline
thickness, palette, and proportions as the reference image.
Subject: a CHIBI cartoon SKY PIRATE PARROT — sky temple biome enemy.
Body: large chibi parrot with vibrant RED body feathers (#cc3344 base,
#8a1a28 shadow, #ff6678 highlight), bright YELLOW wings (#ffd700 base,
#cc9a00 shadow, #ffffa0 highlight) folded against the body, BLUE tail
feathers (#4a9eff base, #2a6acc shadow, #88c4ff highlight). Oversized
chibi parrot head with large curved beak (#ffd700 base, #cc9a00 shadow,
#1a1a2e nostril dot), large round eye (#1a1a2e pupil + #ffffff sclera +
#ffd700 small gold ring iris). PROPS — wearing a small black PIRATE HAT
(#1a1a2e base, #4a4a4a shadow, #ffffff skull-and-crossbones emblem on
front: small white skull + crossed bones). A black EYE PATCH over one
eye (#1a1a2e + thin elastic strap line #1a1a2e). A small GOLD HOOP
EARRING (#ffd700) on one ear feather. On the parrot's shoulder, a TINY
MINI-PARROT (chibi micro version, ~20% size, same red-yellow-blue
colors, also wearing a tiny eye patch — meta joke). Bright cartoon
"AAARRR" energy with beak open as if squawking.
```

#### **S3: Star Mage**

- **Plik:** `assets/sprites/enemies/sky/star_mage.png`
- **Resource:** `relic_shards`
- **Joke:** "Mercury in retrograde. Sorry."
- **Image reference:** `cloud_cultist.png`
- **Prompt:**

```
[PREFIX_ENEMY]
Generate in the EXACT same chibi cartoon pixel art style, outline
thickness, palette, and proportions as the reference image.
Subject: a CHIBI cartoon STAR MAGE / ASTROLOGER — sky temple biome
enemy. Body: humanoid mage in a long flowing COSMIC ROBE — deep purple
(#5a2c82 base, #3a1860 shadow, #8855c4 highlight) with SCATTERED GOLDEN
STARS (#ffd700 + #ffffff small star shapes, 8-12 visible across the
robe) embroidered into the fabric. Oversized chibi head with pale skin
(#f5d4b8 base, #d4a878 shadow), large round eyes glowing slightly
golden (#ffd700 iris + #ffffff core dot — "looking at the cosmos"),
small mouth in a slightly worried frown (#1a1a2e). PROPS — TALL POINTED
WIZARD HAT (#5a2c82 base, #3a1860 shadow folds, #8855c4 highlight, with
3-4 small #ffd700 stars + #ffffff crescent moon embroidered). Both
hands holding a small SPHERICAL DRONE / ORB-FAMILIAR shaped like a
miniature SATURN-LIKE PLANET (rounded #4a9eff blue planet + #ffd700
ring around the equator + #ffffff small sparkle), the orb floats just
above the mage's palms with small magical sparkles (#ffd700 + #ffffff
dots) connecting it to the hands. ZODIAC SYMBOLS faintly visible around
the silhouette (#ffd700 small glowing symbols floating). A long beard
of white-silver hair (#ffffff + #d4d4d4) descending from the chin.
```

#### **S4: Wind Spirit Yoga Instructor**

- **Plik:** `assets/sprites/enemies/sky/wind_spirit_yogi.png`
- **Resource:** `bandages`
- **Joke:** "Breathe in the relic, breathe out the gold."
- **Image reference:** `cloud_cultist.png`
- **Prompt:**

```
[PREFIX_ENEMY]
Generate in the EXACT same chibi cartoon pixel art style, outline
thickness, palette, and proportions as the reference image.
Subject: a CHIBI cartoon WIND SPIRIT YOGI — sky temple biome enemy.
Body: SEMI-TRANSLUCENT humanoid figure made of swirling air/wind energy
(#c4dce8 ghostly base, #88c4e8 deeper translucent areas, #ffffff
highlights, with visible flowing motion lines suggesting wind currents
moving through the body), the figure is clearly NOT solid — slightly
transparent in places. Oversized chibi head with closed peaceful eyes
(curved #1a1a2e lines indicating closed eyes — meditating), small
serene smile (#1a1a2e small curve). POSE — sitting in a perfect YOGA
LOTUS POSITION (legs crossed in front, levitating in mid-air with no
ground beneath), arms held out to sides with palms upward in classic
meditation/receiving pose, fingers in mudra (thumb + index touching).
PROPS — a small cloud BENEATH the figure (#f5c5dd cloud + #d4a4c4
shadow + #ffffff highlight) acting as a meditation cushion. Small WIND
SWIRLS (#ffffff + #c4dce8 thin curved lines) circling around the
figure in 3-4 trail patterns. Wearing a simple yoga headband (#ffd700)
across the forehead. SKY palette: pale blue translucent body, gold
accent, pink cloud.
```

#### **S5: Final Cultist** (mini-boss / strong enemy)

- **Plik:** `assets/sprites/enemies/sky/final_cultist.png`
- **Resource:** `relic_shards`
- **Image reference:** `cloud_cultist.png`
- **Prompt:**

```
[PREFIX_ENEMY]
Generate in the EXACT same chibi cartoon pixel art style, outline
thickness, palette, and proportions as the reference image. Make this
character slightly LARGER and more detailed than other enemies (this is
a stronger elite enemy).
Subject: a CHIBI cartoon DARK CULTIST LORD — sky temple biome
mini-boss, contrasting evil to the peaceful Cloud Cultist. Body:
humanoid figure in a DARK PURPLE-BLACK ROBE (#3a1860 deep purple base,
#1a0830 shadow, #5a2c82 highlight on raised folds), in stark contrast
to the white cloud cultists. Oversized chibi head inside a deep hood,
only the lower face visible (#f5d4b8 pale skin chin, mouth open in a
chaotic grin showing teeth #ffffff), the upper face in pitch black
shadow inside the hood (#1a1a2e void) with TWO GLOWING PURPLE EYES
piercing through the darkness (#8855c4 iris + #ffffff hot core). PROPS
— wearing a CROWN MADE OF LIGHTNING BOLTS (#ffd700 + #ffffff hot core
arcs, 5 jagged bolt shapes radiating upward from the head, looking like
a deranged crown). Both hands raised dramatically, palms forward,
crackling with PURPLE LIGHTNING ENERGY (#5a2c82 + #8855c4 + #ffffff hot
core, jagged arc lines extending from the palms). The robe has a
GOLDEN SUN SYMBOL on the chest (#ffd700 + #1a1a2e radiating sun design)
that is partially CRACKED/CORRUPTED (a thin black crack #1a1a2e running
through the symbol). Dark purple aura around the silhouette (#5a2c82 +
#3a1860 outer glow). Cartoon "ascend with me or perish" final boss
energy.
```

### 7.3 Boss: **Sky Temple Cultist Lord** (stage 125 — endgame boss)

- **Plik:** `assets/sprites/enemies/sky/boss_cultist_lord.png`
- **Greeting:** "You have ascended. Now perish."
- **Image reference:** `boss_brad.png`
- **Prompt:**

```
[PREFIX_BOSS]
Generate in the EXACT same chibi cartoon pixel art style, outline
thickness, palette, and proportions as the reference boss image.
Subject: a CHIBI cartoon SKY TEMPLE CULTIST LORD — endgame final boss.
Body: tall imposing humanoid figure in elaborate dark robes — deep
purple-black ceremonial cloak (#1a0830 deepest, #3a1860 base, #5a2c82
mid, #8855c4 highlight on raised folds) with intricate GOLDEN RUNIC
EMBROIDERY across the entire robe (#ffd700 + #ffffff highlights,
visible swirling rune patterns covering torso and sleeves). CHIBI BUT
IMPOSING — oversized hooded head, deep hood casting full shadow over
the upper face (#1a1a2e void), two MASSIVE glowing eyes piercing through
the void (#ffd700 + #ffffff hot core, larger and more imposing than
regular enemies). Lower face visible showing a wide unsettling grin
(#ffffff teeth, #f5d4b8 pale skin chin). PROPS — A FLOATING CROWN made
entirely of LIGHTNING BOLTS hovering ABOVE the head (not touching the
head — magical levitation, #ffd700 + #ffffff hot core jagged bolts,
5-7 lightning forks radiating upward), with small electrical sparks
arcing between bolts. Both hands raised dramatically: LEFT hand holds
a GOLDEN ANKH-STAFF (#ffd700 ornate staff topped with an ankh symbol
+ #ffffff inner light glow at the cross), RIGHT hand crackles with
purple-gold ENERGY (#5a2c82 + #ffd700 + #ffffff plasma sparks). The
robe is animated as if blown by divine wind, lower edges curling
upward dramatically. Massive aura: BRIGHT GOLDEN-PURPLE OUTER GLOW
(#ffd700 inner + #5a2c82 outer, 12-15 px radius around silhouette).
A few floating ANKH SYMBOLS (#ffd700) around the figure as if magical
familiars. Cartoon "I am the final challenge" boss energy with a hint
of cosmic horror but kept CARTOON not horror.
```

---

## 8. Status tracker

Aktualizuj po każdej generacji. Lista pełna: 27 wrogów + 6 bossów + 5 teł = **38 assetów do wygenerowania**.

### 8.1 Doposażenie istniejących biomów

| ID | Nazwa | Plik | Status |
|---|---|---|---|
| J6 | Jaguar Influencer | `jungle/jaguar_influencer.png` | ✅ 2026-05-25 |
| T6 | Cursed Tourist | `temple/cursed_tourist.png` | ✅ 2026-05-25 |

### 8.2 Desert (Phase 1)

| ID | Nazwa | Plik | Status |
|---|---|---|---|
| BG | Desert background | `sprites/Desert.jpeg` | ✅ 2026-05-25 |
| D1 | Sand Karen (ANCHOR) | `desert/sand_karen.png` | ✅ 2026-05-25 |
| D2 | Cursed Camel | `desert/cursed_camel.png` | ✅ 2026-05-25 |
| D3 | Dust Devil Brad | `desert/dust_devil_brad.png` | ✅ 2026-05-25 |
| D4 | Pyramid Scheme Scarab | `desert/pyramid_scheme_scarab.png` | ✅ 2026-05-25 |
| D5 | Sandstone Bouncer | `desert/sandstone_bouncer.png` | ✅ 2026-05-25 |
| B55 | **Ramboses — Pharaoh of Vengeance** (boss, Hot Shots 2 / Naked Gun parody, **stage 55**) | `desert/boss_ramboses.png` | ✅ 2026-05-25 |

> ⚠️ **Stage 50** zostaje obecnym **ULTIMATE BOSS: Saddam on the Raft** (istniejący w v0.6.5, plik `Sadam-removebg-preview.png`). Ramboses przesunięty na **stage 55** (koniec Desert biomu).

> 🎉 **PHASE 1 ART COMPLETE!** Wszystkie 7 assetów Desert + 2 warm-up = 9 plików gotowych w `assets/sprites/`. Następny krok: implementacja w kodzie (zob. [ISSUE-18](issues/ISSUE-18_desert_biome.md) "Zadania → Kod").

### 8.3 Frozen Peaks (Phase 2)

| ID | Nazwa | Plik | Status |
|---|---|---|---|
| BG | Frozen Peaks background | `sprites/FrozenPeaks.jpeg` | ⬜ |
| F1 | Yeti Barista (ANCHOR) | `frozen/yeti_barista.png` | ⬜ |
| F2 | Sherpa Skeleton | `frozen/sherpa_skeleton.png` | ⬜ |
| F3 | Avalanche Penguin | `frozen/avalanche_penguin.png` | ⬜ |
| F4 | Ice Crystal Mage | `frozen/ice_crystal_mage.png` | ⬜ |
| F5 | Frozen Tourist | `frozen/frozen_tourist.png` | ⬜ |
| B65 | **Yeti CEO** (boss) | `frozen/boss_yeti_ceo.png` | ⬜ |

### 8.4 Catacombs (Phase 3)

| ID | Nazwa | Plik | Status |
|---|---|---|---|
| BG | Catacombs background | `sprites/Catacombs.jpeg` | ⬜ |
| C1 | Lava Lich (ANCHOR) | `catacombs/lava_lich.png` | ⬜ |
| C2 | Crypt Bat Influencer | `catacombs/crypt_bat_influencer.png` | ⬜ |
| C3 | Skeleton Knight HR | `catacombs/skeleton_knight_hr.png` | ⬜ |
| C4 | Magma Slime | `catacombs/magma_slime.png` | ⬜ |
| C5 | Cursed Pharaoh DJ | `catacombs/pharaoh_dj.png` | ⬜ |
| B80 | **Skeleton CFO** (boss) | `catacombs/boss_skeleton_cfo.png` | ⬜ |
| B95 | **Anglerfish Tycoon** (boss) | `catacombs/boss_anglerfish_tycoon.png` | ⬜ |

### 8.5 Atlantis (Phase 4a)

| ID | Nazwa | Plik | Status |
|---|---|---|---|
| BG | Atlantis background | `sprites/Atlantis.jpeg` | ⬜ |
| A1 | Anglerfish Lawyer (ANCHOR) | `atlantis/anglerfish_lawyer.png` | ⬜ |
| A2 | Mermaid Karen | `atlantis/mermaid_karen.png` | ⬜ |
| A3 | Coral Goblin | `atlantis/coral_goblin.png` | ⬜ |
| A4 | Kraken Intern | `atlantis/kraken_intern.png` | ⬜ |
| A5 | Atlantean Karen Queen | `atlantis/atlantean_queen.png` | ⬜ |
| B110 | **Atlantean Karen Queen** (boss promotion?) | TBD | ⬜ |

> ⚠️ **Decyzja open:** A5 i B110 to ten sam koncept. Albo zrobić A5 jako mini-boss + osobnego B110, albo wykorzystać A5 jako finalnego bossa stage 110.

### 8.6 Sky Temple (Phase 4b — endgame)

| ID | Nazwa | Plik | Status |
|---|---|---|---|
| BG | Sky Temple background | `sprites/SkyTemple.jpeg` | ⬜ |
| S1 | Cloud Cultist (ANCHOR) | `sky/cloud_cultist.png` | ⬜ |
| S2 | Sky Pirate Parrot | `sky/sky_pirate_parrot.png` | ⬜ |
| S3 | Star Mage | `sky/star_mage.png` | ⬜ |
| S4 | Wind Spirit Yogi | `sky/wind_spirit_yogi.png` | ⬜ |
| S5 | Final Cultist (mini-boss) | `sky/final_cultist.png` | ⬜ |
| B125 | **Sky Temple Cultist Lord** (endgame boss) | `sky/boss_cultist_lord.png` | ⬜ |

---

## 9. Struktura plików (target po wdrożeniu)

```
assets/sprites/
  Jungle.jpeg                  ✅ (istnieje)
  Temple.jpeg                  ✅ (istnieje)
  Desert.jpeg                  ⬜ NEW
  FrozenPeaks.jpeg             ⬜ NEW
  Catacombs.jpeg               ⬜ NEW
  Atlantis.jpeg                ⬜ NEW
  SkyTemple.jpeg               ⬜ NEW
  enemies/
    [existing: monkey, plant, squirrel, skeleton, ghost, golem, boss_idol, boss_brad, boss_sphinx]  ✅
    jungle/
      jaguar_influencer.png    ⬜
    temple/
      cursed_tourist.png       ⬜
    desert/
      sand_karen.png           ⬜
      cursed_camel.png         ⬜
      dust_devil_brad.png      ⬜
      pyramid_scheme_scarab.png ⬜
      sandstone_bouncer.png    ⬜
      boss_ramboses.png        ⬜ (Hot Shots 2 / Naked Gun parody)
    frozen/
      yeti_barista.png         ⬜
      sherpa_skeleton.png      ⬜
      avalanche_penguin.png    ⬜
      ice_crystal_mage.png     ⬜
      frozen_tourist.png       ⬜
      boss_yeti_ceo.png        ⬜
    catacombs/
      lava_lich.png            ⬜
      crypt_bat_influencer.png ⬜
      skeleton_knight_hr.png   ⬜
      magma_slime.png          ⬜
      pharaoh_dj.png           ⬜
      boss_skeleton_cfo.png    ⬜
      boss_anglerfish_tycoon.png ⬜
    atlantis/
      anglerfish_lawyer.png    ⬜
      mermaid_karen.png        ⬜
      coral_goblin.png         ⬜
      kraken_intern.png        ⬜
      atlantean_queen.png      ⬜
    sky/
      cloud_cultist.png        ⬜
      sky_pirate_parrot.png    ⬜
      star_mage.png            ⬜
      wind_spirit_yogi.png     ⬜
      final_cultist.png        ⬜
      boss_cultist_lord.png    ⬜
```

---

## 10. Quick reference — checklist generowania jednego assetu

1. ⬜ Otwórz Google AI Studio, wybierz Imagen 4 (lub Nano Banana Pro)
2. ⬜ Ustaw Aspect 1:1 (wróg/boss) lub 9:16 (tło), 1K resolution, 4 images
3. ⬜ Dołącz image reference (jeśli wymagane — patrz tabela 0.3)
4. ⬜ Wklej PREFIX (sekcja 1) + opis konkretnego assetu (sekcje 2-7)
5. ⬜ Dodaj NEGATIVE PROMPT (sekcja 0.3)
6. ⬜ Generate → wybierz najlepszy z 4 wariantów
7. ⬜ Download PNG → wytnij tło → **normalizuj kadr (sekcja 0.5: fit-to-box 88% + środek)** → **downscale 384×384** → save RGBA
8. ⬜ Zapisz do `assets/sprites/enemies/{biome}/{snake_case}.png`
9. ⬜ Godot: Texture Filter Linear, Mipmaps Off, Fix Alpha Border ✓
10. ⬜ Update `src/scenes/GameBattleManager.gd` — dodaj wpis do `enemy_roster_*` lub `boss_roster`
11. ⬜ Test in-game — czy sylwetka czytelna, czy skala OK
12. ⬜ Mark ✅ w trackerze (sekcja 8)

---

## 11. Open questions (decyzje przed Phase 1)

1. **Resource per biome** — czy dodać nowe resource'y (`gold_dust`, `frost_crystal`, etc.)? Sugestia: na razie zostać przy 3 (`bandages`/`venom`/`relic_shards`), dodawać dopiero w Phase 3+ jeśli analytics pokażą że gracz długo grindzi.
2. **Atlantean Karen Queen** — A5 (regular enemy) czy B110 (boss)? Sugestia: zrób ją jako bossa (stage 110), a Phase 4a wrogów ogranicz do A1-A4 (4 zwykłych).
3. **Boss scale w kodzie** — istniejące bossy mają scale 260-280. Nowe bossy mogą być większe? Sugestia: standard 280, endgame Cultist Lord 320.
4. **Background music per biom** — czy generujemy nowe audio (np. w Suno/Udio) dla każdego biomu, czy reuse `temple_theme.mp3`? Sugestia: w Phase 1 reuse temple, w Phase 2+ generuj nowe (sekcja TBD do dodania w przyszłej wersji ART_PLAN).

### 11.1 ⚠️ Aspect ratio / cropping starych teł (decyzja: 2026-05-25)

**Stan obecny:** `Jungle.jpeg` i `Temple.jpeg` są w **1:1 (1024×1024)**, renderowane przez TextureRect z `stretch_mode = STRETCH_KEEP_ASPECT_COVERED` na ekranie 9:16 (360×640) → **przycinane ~28% poziomo** (po ~14% z lewej i prawej strony).

**Decyzja (świadoma):** **NIE regenerujemy starych teł.** Nowe biomy (Desert+) generujemy w **9:16** (idealne dopasowanie, zero croppingu).

**Powody pozostawienia starych:**
- Gra już opublikowana — gracze z Closed Alpha mają pamięć wzrokową obecnych biomów
- Cropping nie kasuje kluczowych elementów kompozycji (centrum OK)
- Ryzyko AI style drift między starym a nowym Imagen modelem
- Time budget — 38 nowych assetów ważniejsze niż 2 stare
- Można później jako polish pass jeśli okaże się że nowe biomy wyglądają drastycznie różnie

**Kiedy zrewidować tę decyzję:**
- Po Phase 1 (Desert) — zobaczymy czy nowy biom wizualnie "gryzie się" ze starym Temple → wtedy ewentualnie regeneracja
- Przed v1.0 / Open Beta — jeśli planujesz "visual overhaul" jako część kampanii marketingowej
- Jeśli testerzy zgłoszą problemy z czytelnością starych teł

**TODO przy ewentualnej regeneracji:**
- Użyj `[PREFIX_BG]` z sekcji 1.3
- Aspect 9:16, resolution 2K (2048×3640) jeśli AI Studio pozwoli, inaczej 1K (1024×1820)
- Zachowaj klimat: Jungle = tropikalna dżungla z parą wodną; Temple = ruiny majów/azteków
- Image reference: stary `Jungle.jpeg` / `Temple.jpeg` żeby AI nie zdrydyfowało stylu

---

## 12. UI / GUI Style Guide (paski, przyciski, panele, ikony)

> **Cel sekcji:** spójny styl i **konkretne rozmiary pikseli** dla elementów interfejsu generowanych w **Gemini Nano Banana Pro / Imagen 4**, tak żebyś przy wycinaniu w Photopea wiedział **dokładnie jaki rozmiar PNG zapisać**.
> **Powód powstania:** do tej pory UI było składanką (paczka Kenney + tymczasowy `hpbar2` + improwizacja). Ta sekcja ustala JEDEN punkt odniesienia, żeby nie improwizować przy każdym dotknięciu UI.

### 12.0 Kluczowa zasada rozmiarów (przeczytaj najpierw)

Gra ma **design resolution 360×640** (`viewport_width/height`), a renderuje się **2× = 720×1280** (`window_*_override`), stretch `canvas_items` / `expand`. Z tego wynikają 3 reguły:

1. **Pixel-art UI rysujemy w MAŁEJ natywnej rozdzielczości**, nie w 1024². W AI generujemy duży obraz (1024², bo tyle daje Imagen), ale **w Photopea zmniejszamy do docelowego małego rozmiaru z tabeli 12.1** — używając resamplingu **"Nearest Neighbor" / "Pixels"** (NIE Bilinear!), żeby zachować ostre piksele. Zapisana liczba pikseli = liczba z kolumny **"Zapis PNG"**.

2. **9-slice (StyleBoxTexture) = mały obrazek wystarcza.** Paski, przyciski i panele są **rozciągane** przez Godota — narożniki zostają ostre, środek się rozciąga. Dlatego np. ramka paska 64×16 px obsłuży pasek szeroki na 340 px. **Nie generuj UI w docelowej szerokości ekranu** — generuj mały kafelek z ładnym narożnikiem.

3. **Filtr tekstury w Godot:** dla geometrycznego UI (ramki, paski, przyciski, panele) → **Nearest** (ostre krawędzie pikseli). Dla ikon z miękkim cieniowaniem → **Linear**. To jest **wyjątek** od reguły sprite'ów postaci z sekcji 0.4 (tam Linear) — UI jest geometryczne, więc Nearest wygląda lepiej.

> ⚠️ **Tło do chroma key:** generuj UI na **jednolitym magenta `#FF00FF`**, NIE na białym. Ramki UI mają kremowe/białe wnętrza — na białym tle nie dałoby się ich wyciąć. Magenta = łatwy "Select Color Range → Delete" w Photopea.

### 12.1 Tabela rozmiarów — "jaki PNG zapisać"

| Element | **Zapis PNG (px)** | 9-slice margin L/T/R/B | Filtr Godot | Rozmiar na ekranie (1×) |
|---|---|---|---|---|
| Pasek — ramka/tło (wspólna dla wszystkich pasków) | **64 × 16** | 7 / 3 / 7 / 3 | Nearest | rozciąg → szer. × 8–20 |
| Pasek — wypełnienie (1 neutralny, kolor przez tint) | **48 × 12** | 5 / 1 / 0 / 1 | Nearest | rozciąg (pod ramką) |
| Przycisk — normal | **96 × 36** | 12 / 12 / 12 / 12 | Nearest | ~150 × 44 |
| Przycisk — pressed | **96 × 34** | 12 / 12 / 12 / 12 | Nearest | ~150 × 42 |
| Przycisk — disabled | **96 × 36** | 12 / 12 / 12 / 12 | Nearest | ~150 × 44 |
| Panel duży (okno: sklep, upgrade, dialog) | **96 × 96** | 24 / 24 / 24 / 24 | Nearest | dowolny |
| Panel mały (tooltip / badge / ramka ikony) | **48 × 48** | 14 / 14 / 14 / 14 | Nearest | mały |
| Tło przycisku bottom-nav | **64 × 48** | 14 / 14 / 14 / 14 | Nearest | ~64 × 56 |
| Ikona zasobu / statystyki (kwadrat) | **64 × 64** | — (bez slice) | Linear | 24–32 |
| Ikona waluty / mikstury (feature) | **64 × 64** | — (bez slice) | Linear | 32–44 |

> **Margin = liczba pikseli narożnika/krawędzi, które NIE rozciągają się** (wpisujesz je w `texture_margin_*` w `.tscn`). Małe marginy pionowe pasków (3 / 1 px) są celowe — żeby cienki Attack Bar (8 px) też się nie zniekształcał.

### 12.2 PREFIX_UI (wklej na początku każdego promptu UI)

```
2D mobile game UI element, chibi cartoon pixel art style matching the
LootClicker game (humorous archaeology adventure — "Joana Indiana").
Hard pixel edges, NO anti-aliasing. Strong black outline 2-3px on the
outer silhouette only. Flat cel-shading, max 3 tones per material
(highlight + base + shadow), NO gradients, NO glossy 3D plastic bevels.
Theme: weathered explorer / archaeology aesthetic — aged parchment,
dark leather-brown wood frame, small brass rivets, subtle gold trim.
Single UI element centered, fills ~80% of canvas, isolated on a clean
flat solid MAGENTA background #FF00FF (chroma key — will be cut to
transparent in Photopea). NO drop shadow cast on the background, NO text
baked into the element (the game engine renders all labels), NO extra
props or decorations outside the element bounds. Square 1:1 canvas
1024×1024 source. Shapes must stay crisp and readable when downscaled
to a tiny 16–96px asset. UI palette below.
```

**Negative prompt (do każdego UI generowania):**
```
realistic, 3D render, glossy plastic, soft drop shadow, gradient mesh,
anti-aliasing, blurry, text, letters, numbers, watermark, signature,
photo, skeuomorphic glass, neon glow, busy background, multiple elements
```

> ⚠️ **WYJĄTEK od reguły konturu:** PREFIX_UI wymusza czarny kontur ("Strong black outline") — to dotyczy elementów z **własną obudową** (U1 ramka, U3-U8 przyciski/panele, U9-U10 ikony). **Fill paska (U2) NIE ma konturu** — siedzi wewnątrz kanału ramki, która już daje obramowanie. W promptcie U2 jest to jawnie nadpisane ("ABSOLUTELY NO black outline"). Nie używaj surowego PREFIX_UI do U2 — użyj pełnego promptu z U2 poniżej.

### 12.3 Paleta UI (spójna z motywem Joana Indiana)

| Rola | Hex | Użycie |
|---|---|---|
| Outline zewn. | `#1a1a2e` | czarny kontur wszystkich elementów (jak sprite'y) |
| Rama — drewno/skóra base | `#6b4a2a` | korpus ramek przycisków/paneli |
| Rama — cień | `#3a2614` | dolna/wewn. krawędź ramy |
| Rama — highlight | `#8a6a3a` | górna krawędź ramy |
| Nity / okucia brass | `#ffd700` + cień `#8a6a20` | gold akcent, nity w narożnikach |
| Pergamin wnętrze base | `#f0e0bd` | tło paneli, wnętrze okien |
| Pergamin cień / highlight | `#d4bd8a` / `#fff8e8` | cieniowanie wnętrza |
| Wnętrze paska (empty) | `#e8d4a8` | tło pod fill paska |
| Fill HP (czerwony) | `#c0504a` (cień `#9a3f3a`) | pasek życia gracza/wroga |
| Fill XP (niebieski) | `#4a78c0` (cień `#3a5e9a`) | pasek doświadczenia |
| Fill Attack (bursztyn) | `#d9a441` (cień `#b0832f`) | pasek ataku/castu wroga |
| Fill warn. (zielony/żółty) | `#4a9e6b` / `#d9c441` | progi HP (>50% / 25-50%) |
| Danger / akcent | `#cc3344` | przyciski "delete", alerty |

> 💡 **Spójność z istniejącym:** ta paleta zastępuje tymczasowy `hpbar2` (biało-brązowy) oraz beżowe Kenney (`buttonLong_beige`, `panel_brown`). Po wygenerowaniu nowych assetów podmienimy je w `node_2d.tscn` (tam gdzie teraz są `StyleBoxTexture_btn`, `StyleBoxTexture_panel`, `StyleBoxTexture_hpbar2_*`).

### 12.4 Prompty per element

> ⚠️ **PASKI: TYLKO 2 PLIKI NA WSZYSTKIE PASKI (Opcja A — tint).** W Godot `ProgressBar` renderuje dwie warstwy: **`background`** (tło/ramka — zawsze pełna szerokość) i **`fill`** (wypełnienie — przycinane do wartości). Zamiast generować osobny kolorowy fill na każdy pasek, robimy **jeden neutralny jasny fill** i **kolorujemy go w kodzie** przez `self_modulate`. Dlatego wystarczą **2 assety**:
> - **U1 `bar_frame.png`** — wspólna ramka/tło (generujesz RAZ)
> - **U2 `bar_fill.png`** — jeden neutralny kremowo-biały fill (generujesz RAZ; kolor nadaje silnik)
>
> **Mapa pasków w grze → kolor (tint), nie osobny plik:**
>
> | Pasek (`node_2d.tscn`) | Tint koloru | Źródło koloru |
> |---|---|---|
> | `PlayerHPBar` | czerwony `#c0504a` | stały |
> | `XPBar` | niebieski `#4a78c0` | stały |
> | `EnemyFloatHPBar` | zielony→żółty→czerwony | **dynamicznie** wg % HP w [EnemyHUD.gd](../src/scripts/EnemyHUD.gd) (`update_hp_bar_style`, progi >50% / 25-50% / <25%) |
> | `EnemyFloatAttackBar` | bursztyn `#d9a441` | stały |
>
> ➡️ **Zysk:** dodanie nowego koloru / zmiana progów HP = zmiana liczby w kodzie, **zero nowych plików graficznych**. Nie wycinaj samego fill bez ramki (i odwrotnie) — w grze zawsze działają obie warstwy naraz.

#### **U1: Pasek — ramka/tło (empty bar frame)** → zapis `64 × 16 px`

```
[PREFIX_UI]
A horizontal progress bar FRAME (empty container, no fill inside).
Capsule / rounded-rectangle shape. Outer frame: dark leather-brown wood
(#6b4a2a base, #3a2614 bottom shadow edge, #8a6a3a top highlight edge)
with a 2px black outline #1a1a2e. Rounded end-caps on left and right.
Interior hollow channel is empty parchment-tan (#e8d4a8 base, #c4a878
inner shadow at the top edge to suggest depth), ready to be filled by a
separate colored bar on top. One small brass rivet (#ffd700 + #8a6a20)
near each rounded end. Horizontal element, much wider than tall.
```

#### **U2: Pasek — wypełnienie (1 neutralny fill, kolor przez tint)** → zapis `48 × 12 px`

> **Generujesz TYLKO JEDEN** neutralny jasny fill. Kolory (HP/XP/atak/progi wroga) nadaje silnik przez `self_modulate` — patrz mapa w 12.4. Fill musi być **jasny i nasycony bielą**, żeby tint zadziałał poprawnie (modulate mnoży kolory — ciemny fill = brudny tint).

```
[PREFIX_UI]
OVERRIDE the PREFIX_UI black-outline rule: this fill has NO outline.
A horizontal progress bar FILL strip — the colored liquid that fills a
bar from the left. NEUTRAL near-WHITE creamy color (#fff8e8 base) so the
engine can tint it any color — do NOT make it red/blue/etc. Almost solid
flat fill: ONLY a 1px brighter highlight line along the TOP edge
(#ffffff) and a 1px slightly darker cream shade along the BOTTOM edge
(#e8dcc0), NO gradient. ROUNDED LEFT end-cap (it seats into the rounded
left of the frame channel). FLAT right end (this is the moving liquid
surface, clipped to the HP/XP value). ABSOLUTELY NO black outline
anywhere — not top, bottom, left or right; the frame already provides
the border. Soft clean cream pill, wider than tall.
```

Dodaj do **negative prompt** (oprócz standardowego): `black outline, dark border, heavy black stroke, outlined`

> **Dlaczego lewy zaokrąglony, prawy płaski:** fill to "płyn w pojemniku". Lewy koniec wsuwa się w zaokrąglony lewy kanał ramki U1 → **musi pasować (oba zaokrąglone)**. Prawy koniec to powierzchnia płynu, która przesuwa się gdy HP spada → płaskie pionowe cięcie. Zaokrąglony prawy dałby wędrującą "kroplę" w środku paska.
>
> **Dlaczego BEZ konturu:** fill leży WEWNĄTRZ kanału ramki, która już ma ciemny brzeg. Własny czarny kontur fill = podwójna linia + (przy tincie `modulate` czarny zostaje czarny) gruba brudna obwódka. Ramka robi obramowanie, fill to czysty kolor.

> 💡 **W kodzie** (przy implementacji): `fill_bar.self_modulate = Color("c0504a")` dla HP itd. W `EnemyHUD.gd` zamiast podmieniać `StyleBoxTexture` ustawiasz `self_modulate` na zielony/żółty/czerwony wg progów — ten sam jeden plik. 9-slice fill: `margin L = promień lewego capa, R = 0` (płaski prawy).

#### **U3: Przycisk — normal** → zapis `96 × 36 px`

```
[PREFIX_UI]
A rectangular GAME BUTTON in idle/normal state, slightly raised.
Rounded-rectangle shape. Body: warm wood/leather panel (#6b4a2a base,
#8a6a3a top highlight band suggesting a raised surface, #3a2614 bottom
shadow band), 2-3px black outline #1a1a2e all around. A thin gold trim
line (#ffd700) inset just inside the outline. One small brass rivet
(#ffd700 + #8a6a20) in each of the 4 corners. Center is a flat clean
panel area (empty — no text, label added by engine). Subtle, clean,
readable. Horizontal button shape (~3:1 wide).
```

#### **U4: Przycisk — pressed** → zapis `96 × 34 px`

```
[PREFIX_UI]
The SAME button as the normal-state reference but in PRESSED/pushed-in
state. Inverted depth: now the top edge has the shadow band (#3a2614)
and the bottom is flat — looks pushed inward. Body darkened ~15%
(#5a3d22 base). Same rounded-rectangle, same 4 corner brass rivets, same
black outline #1a1a2e and gold trim. Slightly shorter than the normal
button (pressed-down look). No text. Horizontal button shape.
```

#### **U5: Przycisk — disabled** → zapis `96 × 36 px`

```
[PREFIX_UI]
The SAME button as the normal-state reference but DISABLED/inactive:
fully desaturated to muted gray-brown (#6a5e50 base, #8a8074 highlight,
#4a4038 shadow), gold trim turned dull gray (#9a8c6a), rivets dull
(#9a8c6a). Lower contrast overall (looks "greyed out"). Same shape,
outline, rivets. No text. Horizontal button shape.
```

#### **U6: Panel duży — okno (sklep / upgrade / dialog)** → zapis `96 × 96 px`

```
[PREFIX_UI]
A large 9-slice WINDOW PANEL / frame (for shop, upgrade or dialog
screens). Square. Thick ornate border: dark leather-brown wood frame
(#6b4a2a base, #3a2614 inner shadow, #8a6a3a outer highlight) with a
3px black outline #1a1a2e and a thin gold trim line (#ffd700) running
along the inner edge of the frame. A small brass rivet (#ffd700 +
#8a6a20) in each of the 4 corners. The CENTER is a large flat parchment
fill (#f0e0bd base, very subtle #e4d2a8 mottled texture, #fff8e8 faint
top highlight) — empty, content placed by engine. The corners must hold
ALL the decorative detail (this is 9-sliced — center stretches). Clean,
readable, not busy.
```

#### **U7: Panel mały — tooltip / badge / ramka ikony** → zapis `48 × 48 px`

```
[PREFIX_UI]
A small rounded SQUARE badge/tooltip frame (e.g. an item-slot or icon
border). Simpler than the large window: leather-brown rounded-square
frame (#6b4a2a base, #3a2614 shadow, #8a6a3a highlight), 2px black
outline #1a1a2e, thin gold inner trim (#ffd700), one tiny brass rivet
per corner. Center: flat parchment fill (#f0e0bd). Compact, all detail
in the border (9-sliced). No text.
```

#### **U8: Tło przycisku bottom-nav** → zapis `64 × 48 px`

```
[PREFIX_UI]
A bottom-navigation TAB button background, rounded-top rectangle.
Leather-brown (#6b4a2a base, #8a6a3a top highlight, #3a2614 bottom
shadow), 2px black outline #1a1a2e, thin gold trim (#ffd700) along the
top edge only. Center flat (icon placed by engine on top). Slightly
taller-than-wide tab shape. No text, no icon baked in.
```

#### **U9: Ikony zasobów** (bandages / venom / relic_shards) → zapis `64 × 64 px` każda

```
[PREFIX_UI]
A single small game RESOURCE ICON, centered, NO frame around it (frame
added separately). Chibi cartoon pixel art, 2px black outline #1a1a2e,
max 3 flat tones, readable at 24px. Subject: [WYBIERZ]:
- BANDAGES: a rolled cloth bandage / gauze roll, off-white (#f0e6d0 base,
  #c4b496 shadow, #fff8e8 highlight), one loose end unrolling, tiny
  blood-spot accent optional (#cc3344).
- VENOM: a small glass vial of bright green poison (#4a9e6b liquid +
  #6ed499 highlight + #2a6e4b shadow, #c4dce8 glass glint, dark cork
  #6a4a2a on top).
- RELIC SHARDS: 2-3 broken golden ancient relic fragments (#ffd700 base,
  #8a6a20 shadow, #fff0a0 highlight), faint turquoise rune glow #4a9e6b
  on one shard.
Isolated on magenta #FF00FF. Single icon, no background scenery.
```

#### **U10: Ikony waluty / mikstury** (gold, cog, HP potion) → zapis `64 × 64 px` każda

```
[PREFIX_UI]
A single shiny game CURRENCY/ITEM icon, centered, NO frame. Chibi
cartoon pixel art, 2px black outline #1a1a2e, max 3-4 flat tones,
readable at 32px. Subject: [WYBIERZ]:
- GOLD COIN: round gold coin face-on (#ffd700 base, #8a6a20 rim shadow,
  #fff0a0 top highlight, small engraved ankh or pyramid #8a6a20 in
  center), one #ffffff sparkle dot.
- COG / GEAR (upgrade): silver mechanical cog (#b8b8b8 base, #7a7a7a
  shadow, #e8e8e8 highlight), 8 teeth, central hole.
- HP POTION: small rounded potion bottle with bright red liquid
  (#cc3344 base, #ff6677 highlight, #8a1a28 shadow), cork stopper
  (#6a4a2a), #ffffff glass glint, tiny heart bubble #ff6677 optional.
Isolated on magenta #FF00FF. Single icon.
```

### 12.5 Workflow w Photopea (cut → resize → save)

1. Otwórz pobrany PNG z Nano Banana (1024²) w **Photopea**.
2. **Wytnij tło:** `Select → Color Range` → kliknij magenta `#FF00FF` → `Delete`. Zostaje element na przezroczystości.
3. **Przytnij do elementu:** `Image → Trim` (transparent pixels) — kadr ciasno do krawędzi elementu.
4. **Zmniejsz do rozmiaru z tabeli 12.1:** `Image → Image Size` → wpisz **dokładnie** px z kolumny "Zapis PNG" (np. `64 × 16`) → **Resample: "Nearest Neighbor" / "Preserve hard edges"** (NIE Bilinear — inaczej rozmaże piksele).
5. **Zapisz:** `File → Export as → PNG` → nazwa wg konwencji niżej.
6. **Godot:** zaznacz plik → Import → `Texture Filter: Nearest` (UI geometryczne) lub `Linear` (ikony) → `Mipmaps: Off` → `Fix Alpha Border: ✓` → Reimport.
7. **Wpięcie w scenę:** podmień teksturę w odpowiednim `StyleBoxTexture` w `src/scenes/node_2d.tscn` i ustaw `texture_margin_*` wg kolumny "9-slice margin".

**Konwencja nazw plików** (folder `assets/ui/joana_ui/`):
```
bar_frame.png   bar_fill.png      ← tylko 2 pliki na WSZYSTKIE paski (kolor = tint w kodzie)
btn_normal.png   btn_pressed.png   btn_disabled.png
panel_window.png   panel_small.png   nav_tab.png
icon_bandages.png   icon_venom.png   icon_relic.png
icon_gold.png   icon_cog.png   icon_potion.png
```

### 12.6 Notatki / decyzje

- **9-slice margin musi mieścić się w rozmiarze tekstury.** Jeśli ramka jest 96×96 a margin 24 → środek = 96-48 = 48 px na rozciąganie (OK). Nie ustawiaj marginu > połowa wymiaru.
- **Cienki Attack Bar (8 px on-screen):** używa tej samej `bar_frame.png` co HP, ale ma małe marginy pionowe (3/1) — dlatego się nie zniekształca przy 8 px. Zweryfikować w grze po podmianie.
- **✅ DECYZJA: tint (Opcja A).** Paski = tylko `bar_frame.png` + `bar_fill.png`; kolory (HP/XP/atak/progi wroga) przez `self_modulate` w kodzie. Fill MUSI być jasny (#fff8e8), bo modulate mnoży kolory. Przy wpięciu: w `EnemyHUD.gd` zamień podmianę `StyleBoxTexture` na ustawianie `self_modulate` wg progów % HP.
- **Walidacja w silniku:** po wygenerowaniu pierwszej partii (bar_frame + btn_normal + panel_window) — zanim zrobisz resztę — wrzuć je do gry i sprawdź czy `texture_margin_*` z tabeli 12.1 dają ostre narożniki. Mamy do tego skill `godot-master` (9-slice / StyleBoxTexture patterns) i agenta `game-developer`, który może dograć je do `node_2d.tscn` i dostroić marginy empirycznie.

---

## 12.7 Stage Progression Bar (pasek postępu etapów — model 5-węzłowy)

> **Cel:** zamiana tekstowego „Stage: 7" na wizualny pasek węzłów z miniaturami biomów + ścieżką. **Decyzja: 5 węzłów (current ±2)** — aktywny środkowy powiększony.
> **Zysk UX specyficzny dla nas:** gra cyklu​je biomy (Jungle 1-14, Temple 15-40, Desert 36-55…) — gdy zbliżasz się do przejścia, węzeł `+1`/`+2` pokazuje **miniaturę nowego biomu** → pasek staje się teaserem „nowa strefa". Plus węzły bossów (co 5. etap / `boss_roster`) wyróżnione → telegraf „idzie boss".

### 12.7.1 Layout

```
[gear] (n-2)··(n-1)··(( n ))··(n+1)··(n+2)
        |       |       |        |      |
     biom    biom   AKTYWNY    biom   biom
                    +1.3× scale
   (pod spodem zostaje InfoLabel: "Jungle 7/10 — The Allergic Idol")
```

- Górny pasek ekranu. Aktywny (środkowy) węzeł powiększony ~1.3× (Tween przy zmianie etapu).
- Etapy < 1 (na starcie, np. current=1 → węzły -1, 0) → węzeł **ukryty** (`visible=false`).
- ⚠️ Na 360px szeroko​ści 5 węzłów + gear jest **ciasno** — kręgi małe (~36px), do dostrojenia w silniku.

### 12.7.2 Assety (mało — większość reuse/proceduralnie)

| Element | Zapis PNG | Skąd | Filtr |
|---|---|---|---|
| Ring węzła — normal (U11) | **48 × 48** | Nano Banana (nasz styl) | Nearest |
| Ring węzła — boss (U12) | **48 × 48** | Nano Banana | Nearest |
| Miniatura biomu (kołowa) | **40 × 40** | **reuse teł** (Jungle/Temple/Desert.jpeg) — przycięte do koła proceduralnie, ja robię | Linear |
| Kropka ścieżki | **6 × 6** | proceduralnie, ja robię (tiling) | Nearest |
| Gear (ustawienia) | — | mamy `cog_silver.png` ✅ | — |

> **Maskowanie koła (pixel-art!):** NIE StyleBoxFlat clip (antyaliasuje). Zamiast tego: miniatura biomu **przycięta do koła z twardą krawędzią** (robię w kodzie/PIL z teł) + na wierzchu **ring PNG z przezroczystym środkiem** (dziura) i **przezroczystymi rogami** (węzeł jest okrągły, nie kwadratowy). Oba ostre.

#### **U11: Ring węzła — normal** → zapis `48 × 48 px`

```
[PREFIX_UI]
A small circular UI FRAME RING for a stage/level node icon. PERFECT
CIRCLE, thick rounded ring border ONLY. The whole image background,
the CENTER HOLE, and the 4 CORNERS are ALL the SAME solid MAGENTA
#FF00FF (chroma key — everything magenta is cut to transparent in
Photopea, so the center becomes a see-through hole and the node ends up
round, not square). ONLY the ring band itself is opaque: leather-brown
wood (#6b4a2a base, #3a2614 inner shadow, #8a6a3a outer highlight),
2px black outline #1a1a2e on BOTH inner and outer edges, thin gold trim
line (#ffd700) on the inner rim. Keep the ring band THIN (~20% of the
radius) so a biome thumbnail behind the hole stays clearly visible.
Crisp, readable at 36px. NO text, NO thumbnail inside — just the ring on
magenta.
```
Negative (dodaj): `square frame, filled center, opaque center, transparent background, thumbnail, photo inside`

#### **U12: Ring węzła — boss** → zapis `48 × 48 px`

```
[PREFIX_UI]
Same circular stage-node RING as the normal version but a BOSS variant:
GOLD ring band (#ffd700 base, #8a6a20 shadow, #fff0a0 highlight), black
outline #1a1a2e, slightly thicker than normal. A tiny boss marker at the
TOP of the ring — a small red gem (#cc3344) or a small bone-white skull
(#e8e8e0 + #1a1a2e eye sockets). The whole background, the CENTER HOLE,
and the 4 CORNERS are ALL the same solid MAGENTA #FF00FF (chroma key —
cut to transparent in Photopea). ONLY the ring band + boss marker are
opaque. Crisp at 36px. NO text inside.
```

> **U13 (kropka ścieżki)** — nie generuj, zrobię proceduralnie (6×6, kremowo-brązowa, `Texture Repeat = Enabled`, tiling na ~16px segmentach `TextureRect` `stretch_mode = TILE`).

### 12.7.3 Struktura sceny (do wdrożenia)

```
StageBar (HBoxContainer)            ← góra ekranu (zastępuje TopBar)
├── SettingsHUD (TextureButton)     ← gear (istniejący)
└── StagePath (HBoxContainer, sep ~4)
    ├── StageNode0 (Control)        ← current-2
    │   ├── Thumb (TextureRect)     ← miniatura biomu (kołowa), centered
    │   ├── Ring  (TextureRect)     ← ring PNG na wierzchu
    │   └── NumLabel (Label)        ← numer etapu, dół, outline
    ├── Dot0 (TextureRect, TILE)
    ├── StageNode1 … Dot1 … StageNode2(AKTYWNY) … Dot2 … StageNode3 … Dot3 … StageNode4
```

- **5 stałych slotów** — kod aktualizuje treść (nie przebudowuje drzewa).

### 12.7.4 Zachowanie (kod — `StageBar.gd` lub w `GameBattleManager`)

```gdscript
func update_stage_bar(current: int):
    for i in 5:
        var s = current - 2 + i          # etap w slocie
        var slot = nodes[i]
        if s < 1:
            slot.visible = false
            continue
        slot.visible = true
        slot.num_label.text = str(s)
        slot.thumb.texture = biome_thumb_for_stage(s)   # jungle/temple/desert…
        slot.ring.texture = ring_boss if _is_boss(s) else ring_normal
        var active = (i == 2)
        # Tween scale 1.0 ↔ 1.3 dla aktywnego
        var t = slot.create_tween()
        t.tween_property(slot, "scale", Vector2.ONE * (1.3 if active else 1.0), 0.2)

func _is_boss(s): return boss_roster.has(s) or (s % 5 == 0)
# biome_for_stage: reuse istniejącej logiki (jungle ≤14, temple ≤40, desert ≤55…)
```

- Wołaj `update_stage_bar(current_stage)` w `_advance_stage` / po `current_stage += 1`.
- `InfoLabel` (biom + nazwa bossa) **zostaje** pod paskiem — węzły dają orientację, tekst dookreśla.

### 12.7.5 Kolejność wdrożenia

1. **Ja (proceduralnie, od zaraz jeśli chcesz):** miniatury kołowe z teł (jungle/temple/desert) + kropka ścieżki.
2. **Ty (Nano Banana):** U11 ring normal + U12 ring boss (48×48, środek+rogi przezroczyste).
3. **Wspólnie (zamknij scenę w Godot!):** budowa `StageBar` w `node_2d.tscn` + `StageBar.gd` + podpięcie `update_stage_bar`. Walidacja rozmiarów na 360px.

---

## 13. Następne kroki

1. **Wygeneruj 2 sprite'y warm-upowe** (J6 Jaguar Influencer + T6 Cursed Tourist) — sprawdź czy workflow działa, czy styl jest spójny z istniejącymi.
2. Jeśli OK → **Phase 1: Desert** (BG + D1 anchor → reszta D2-D5 + boss).
3. Po wdrożeniu Phase 1: build APK, wgraj jako update do Closed Alpha → zbierz feedback testerów PRZED Phase 2.
4. Iteruj.

Powodzenia! 🎨
