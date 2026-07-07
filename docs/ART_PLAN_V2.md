# 🎨 ART PLAN V2 — Styl & Pipeline (rewizja: pixel-art mix + agresja)

> **Co to jest:** korekta kierunku artystycznego po pierwszej fali regeneracji wrogów (E1-E8).
> **Per-postać prompty** (E1-E8, B1-B4, biomy desert/frozen/...) zostają w **[ART_PLAN.md](ART_PLAN.md)** — V2 zmienia tylko **STYL + PIPELINE**, które się na nie nakładają.
> **Data:** 2026-06-15.

---

## ✅ STATUS (aktualizacja 2026-06-15)

**Wrogowie — wszystkie 15 wdrożone (V2, 384×384, podmienione pod istniejącymi ścieżkami, kod bez zmian):**
- ✅ E1-E8: squirrel, monkey, plant, mummy, snake, skeleton, golem, ghost
- ✅ J6 jaguar_influencer, T6 cursed_tourist
- ✅ D1-D5: sand_karen, cursed_camel, dust_devil_brad, pyramid_scheme_scarab, sandstone_bouncer

**Pozostało:**
- ⬜ Bossy B1-B4 (idol, brad, sphinx, saddam) + B55 ramboses — prompty gotowe (§3.6), regen 512×512
- ⬜ Zapis finalnej wiewiórki jako `assets/_anchor_squirrel.png` (image ref dla kolejnych generacji)
- ⬜ (opcjonalnie) batch `pixelate.py` na komplet — finalne ujednolicenie palety/gridu

**Uwagi z generacji:**
- Plant (E3) był lekkim outlierem (grubszy kontur, gładsze cieniowanie) — przegenerowany z anchorem.
- B1 Idol miał złoty kontur → black-outline fix dopisany na stałe do `PREFIX_BOSS_V2` (§3.2).

---

## 0. Dlaczego V2 (geneza)

Pierwsza regeneracja (E1-E8) ujawniła dwa dryfy:

1. **Za gładko.** Generatory AI (Imagen / Nano Banana) **nie robią prawdziwego pixel-artu** — na "chibi cartoon pixel art" dają gładką ilustrację z lekkim pixel-art *posmakiem*. Efekt: **bardziej chibi cartoon, mniej Stardew Valley / Cult of the Lamb**.
2. **Za słodko.** Wrogowie wyszli uroczy/pasywni (zmęczony monkey, słodki wąż) — a to **WROGOWIE**, mają być groźni.

V2 koryguje oba:
- **Pixel-art mix** wstrzykiwany **post-process** (skrypt `execution/pixelate.py`) — bo prompt sam nie wystarczy.
- **Agresja** wbudowana w PREFIX (gniew, kły, dynamiczne pozy).

---

## 1. Rewizja stylu

### 1.1 Pixel-art mix (twardsze piksele)
- **Cel:** chibi cartoon *proporcje* + **WYRAŹNY pixel-art render** — twarde kwadratowe piksele, ograniczona płaska paleta, brak gładkich gradientów/AA. Bliżej **Stardew Valley / Cult of the Lamb** niż gładkiej ilustracji.
- **Realizm:** AI nie posłucha w 100%. Dlatego **pikselizacja post-process jest OBOWIĄZKOWA** (krok 3 pipeline'u) — to ona wymusza prawdziwe piksele.

### 1.2 Agresja (wrogowie = groźni)
- Wrogowie: **gniewne zmarszczone brwi, obnażone ostre zęby/kły, intensywne wpatrzone oczy, warknięcie**. Dynamiczna **groźna poza** (wypad do przodu, pazury, uniesiona broń).
- **NIE** uroczy, **NIE** pasywny, **NIE** smutny. Wciąż cartoon (nie horror/gore), ale **wyraźnie wrogi i gotowy do walki**.
- Bossy: groźni **+ imponujący** (większa obecność, aura, akcesoria).
- Humor zostaje (deadpan, gra słów) — ale przez *kontekst/props*, nie przez "słodkość".

### 1.3 STYLE LOCK — anchor + image reference (przeciw rozjazdowi/halucynacji) ⭐
**Najważniejsza reguła spójności.** AI samym tekstem **zawsze** zrobi rozjazd między generacjami (różny kontur, gęstość pikseli, cieniowanie). Rozwiązanie: **jeden wzorzec (anchor) + image reference dla reszty.**

**Proces:**
1. **Wygeneruj 1 "hero" wroga** (np. najlepszy z obecnych — Squirrel/Plant/Monkey). Dopracuj aż styl jest IDEALNY. To jest **ANCHOR**.
2. **Każdego kolejnego** wroga generuj **dołączając anchor jako IMAGE REFERENCE** (w Imagen/Nano Banana: wgraj obraz referencyjny / "use as style reference").
3. Do promptu **dopisz STYLE LOCK clause** (niżej) — każe AI trzymać się referencji, zmieniać TYLKO postać/pozę.
4. Pikselizacja `pixelate.py` z **identycznymi** `--res`/`--colors` dla wszystkich = **drugi zamek** (ujednolica grid + paletę).

**STYLE LOCK clause (dopisz do KAŻDEGO promptu poza anchorem):**
```
CRITICAL STYLE LOCK: match the ATTACHED REFERENCE IMAGE exactly — same
outline thickness, same pixel density/resolution, same flat cel-shading
and tone count, same color saturation and palette feel, same chibi
proportions and rendering technique. Do NOT invent or drift the style,
do NOT hallucinate a different look. The ONLY thing that changes from the
reference is the character's species/identity and pose. Same world, same
brush.
```

> ### ✅ WYBRANY ANCHOR: **Angry Kaboom Squirrel**
> Kanon stylu = wiewiórka (V2). Cechy do utrzymania we wszystkich kolejnych:
> - **Kontur:** średni czarny (~2-3px equiv), zbalansowany — nie chunky, nie cienki
> - **Cieniowanie:** detaliczna płaska faktura (futro/materiał), 3 tony, ciepła ograniczona paleta
> - **Gęstość pikseli:** umiarkowana-wysoka (czytelny pixel-art, nie za grube bloki)
> - **Poza:** pełna postać, dynamiczna, agresywna
> - **Plik referencyjny:** zapisz finalnego (znormalizowanego + spikselizowanego) jako `assets/_anchor_squirrel.png` i dołączaj go do KAŻDEJ kolejnej generacji jako image reference.

> 🔑 **Dwa zamki = spójność:** (1) image reference + style lock clause → ujednolica *rendering/kreskę*; (2) `pixelate.py` z tymi samymi ustawieniami → ujednolica *piksele/paletę*. Razem dają spójny zestaw. Sam tekst bez referencji = rozjazd (to co masz teraz).
>
> ⚠️ Nawet z referencją AI nie jest w 100% idealne — ale rozjazd spada z "duży" do "ledwo zauważalny", a pikselizacja domyka resztę.

---

## 2. PIPELINE (pełny, V2)

```
0. ANCHOR (raz)     wygeneruj 1 "hero" wroga, dopracuj styl → to wzorzec
1. GENERUJ (AI)     Imagen 4 / Nano Banana, 1024×1024, tło MAGENTA #FF00FF,
                    prompt = PREFIX_V2 + opis + STYLE LOCK clause (1.3)
                    + DOŁĄCZ ANCHOR jako image reference (oprócz hero)
2. WYTNIJ (Photopea) Select→Color Range magenta → Delete → przezroczystość
3. NORMALIZUJ        Trim → Canvas Size: kwadrat, postać = 88%, WYŚRODKOWANA
                    (przepis: ART_PLAN.md sekcja 0.5)
4. PIKSELIZUJ ⭐      execution/pixelate.py  (wróg: --res 110 --colors 32 --out 384)
   (the "mix")       (boss:  --res 150 --colors 40 --out 512)
5. EXPORT/ZAPISZ     pixelate.py zapisuje od razu w docelowym rozmiarze (384/512)
6. GODOT IMPORT      Filter: NEAREST (teraz to pixel-art!), Mipmaps Off, Fix Alpha Border ✓
```

> ⚠️ **Zmiana vs V1:** krok normalizacji w ART_PLAN 0.5 mówił downscale **Bilinear** — w V2 **pixelizacja (NEAREST + kwantyzacja)** zastępuje ten krok. Bilinear rozmywał piksele, czego teraz NIE chcemy.

### 2.1 Skrypt pikselizacji
```bash
# pojedynczy wróg
python execution/pixelate.py "assets/sprites/enemies/monkey.png" --res 110 --colors 32 --out 384
# cały folder wrogów
python execution/pixelate.py assets/sprites/enemies --res 110 --colors 32 --out 384
# boss (więcej detalu)
python execution/pixelate.py "assets/sprites/enemies/boss_brad.png" --res 150 --colors 40 --out 512
```
- **`--res` mniej = mocniejszy pixel-art** (większe bloki). Wróg ~110, boss ~150. Eksperymentuj 90-130.
- **`--colors` mniej = mocniejszy flat-shading.** 32 to dobry start; 24 mocniej, 48 subtelniej.
- ⚠️ **Nadpisuje plik wejściowy** — `git` przed (mamy historię) albo rób kopię.

### 2.2 Godot — filtr
- **NEAREST** (zachowuje twarde piksele). Jeśli przy skalowaniu wrogów pojawi się "shimmer" na nie-całkowitych skalach → przetestuj, ewentualnie Linear (kompromis: gładsze skalowanie, lekko miększe piksele). Domyślnie celuj w Nearest.

---

## 3. PREFIX_V2 (zastępują PREFIX_ENEMY / PREFIX_BOSS z ART_PLAN sekcja 1)

> Wklejaj na początku promptu, **przed** opisem postaci. Magenta + agresja + pixel emphasis już wbudowane.

### 3.1 PREFIX_ENEMY_V2
```
2D mobile game ENEMY sprite, chibi proportions BUT rendered as TRUE PIXEL
ART — visible chunky square pixels, hard aliased edges, limited flat color
palette (like a 32-bit SNES / Stardew Valley / Cult of the Lamb sprite).
NO smooth gradients, NO airbrush, NO soft anti-aliasing, NO glossy 3D
shading. Flat cel-shading, max 3 tones per element, strong black outline
2-3px. 3/4 front-facing view (looks at viewer, slightly angled right).
CHIBI PROPORTIONS — oversized head (40-50%), but the ATTITUDE is AGGRESSIVE
and MENACING: angry furrowed brows, intense glaring eyes, bared sharp
teeth / fangs, snarling mouth, dynamic threatening pose (lunging forward,
claws/fists ready). The enemy is HOSTILE and ready to fight — NOT cute,
NOT passive, NOT sad, NOT friendly. Still cartoon (no horror, no gore,
no realism). Single character centered, fills ~85% of canvas. NO weapon
unless specified, NO ground shadow, NO background scenery — isolated
subject on a clean flat solid MAGENTA background #FF00FF (chroma key —
cut to transparent in Photopea; magenta works even for white parts; the
character has NO magenta on its body). Square 1:1 canvas 1024×1024.
CRITICAL STYLE LOCK: match the ATTACHED REFERENCE IMAGE exactly — same
outline thickness, same pixel density, same flat cel-shading and tone
count, same color saturation and palette feel, same chibi proportions
and rendering technique. Do NOT invent or drift the style, do NOT
hallucinate a different look. The ONLY thing that changes from the
reference is the character's species/identity and pose. Same world,
same brush. Biome palette OVERRIDES below.
```
> ⚠️ **Generując ANCHOR** (pierwszego, wzorcowego wroga) — **usuń zdania "CRITICAL STYLE LOCK..."** (nie ma jeszcze referencji). Dla WSZYSTKICH kolejnych: zostaw + dołącz `assets/_anchor_squirrel.png` jako image reference.

### 3.2 PREFIX_BOSS_V2
```
2D mobile game BOSS sprite, chibi proportions BUT rendered as TRUE PIXEL
ART — visible chunky pixels, hard aliased edges, limited flat palette
(SNES / Stardew Valley / Cult of the Lamb look). NO smooth gradients,
NO anti-aliasing, NO 3D glossy shading. Strong black outline 3-4px, flat
cel-shading max 4 tones. 3/4 front-facing, LARGER and MORE DETAILED than
regular enemies. MENACING + IMPOSING presence: intense glowing/glaring
eyes, aggressive confident posture, dramatic. Intimidating but still
cartoon (no horror/gore). Props/accessories visible (crown, weapon, gear).
Single boss centered, fills ~90% of canvas. NO ground shadow, NO scenery
— isolated subject on solid MAGENTA background #FF00FF (chroma key — cut
to transparent; works for white parts; boss has NO magenta on body).
Square 1:1 canvas 1024×1024.
CRITICAL STYLE LOCK: match the ATTACHED REFERENCE IMAGE exactly — same
outline thickness, pixel density, flat shading, saturation, palette feel
and rendering. Do NOT drift or hallucinate the style. Only the character
identity and pose change. Biome palette OVERRIDES below.
CRITICAL: the outline around the ENTIRE silhouette MUST be solid BLACK
(#1a1a2e), 3-4px, exactly like the reference image's outline — NOT gold,
NOT colored, NOT glowing. Only eyes/aura/props may glow gold; the body
outline stays black. Flat 3-tone cel-shading on the body/materials — no
smooth gradients or painterly blending.
```
> ⚠️ Dołącz **ten sam anchor** (`_anchor_squirrel.png`) jako image reference też dla bossów — żeby boss był z tego samego świata co wrogowie. (Boss = większy/groźniejszy, ale ta sama kreska/piksele.)
> ⚠️ **Black outline fix (2026-06-15):** B1 Allergic Idol wyszedł ze złotym konturem (AI pomyliło "gold eyes/aura" z kolorem obrysu) — powyższe 2 zdania "CRITICAL: outline... BLACK" dodane na stałe do prefixu, dotyczy B1-B4 i B55. **Przy regeneracji B1 — wygeneruj ponownie z tym prefixem.**

### 3.3 NEGATIVE (V2 — dodaj do każdego)
```
white background, smooth gradient, airbrush, soft anti-aliasing, blurry,
3D render, glossy, photorealistic, cute, adorable, friendly, passive,
chibi mascot, sticker, watermark, text, signature
```
> Doszło: `smooth gradient, airbrush, soft anti-aliasing` (wymuś piksele) + `cute, adorable, friendly, passive` (wymuś agresję).

---

## 3.4 Prompty wrogów E1-E8 (V2 — agresywne, pixel-art)

> To są **przepisane** E1-E8 — ta sama postać/żart, ale **groźna** (V1 były za słodkie). Workflow: `[PREFIX_ENEMY_V2]` + opis → generuj → wytnij → normalizuj → **pixelate.py --res 110 --colors 32 --out 384** → nadpisz plik. Humor zostaje (przez props/kontekst), nie przez słodkość.

#### **E1: Angry Kaboom Squirrel** → `enemies/squirrel.png`
```
[PREFIX_ENEMY_V2]
Subject: a CHIBI cartoon RABID ANGRY SQUIRREL — jungle enemy, FURIOUS and
attacking. Warm brown fur (#a06a3a base, #7a4e28 shadow, #c89060 high-
light), fur bristling/spiky with rage, big bushy tail flared up. Eyes
BULGING with fury (#1a1a2e + #ffffff + tiny bloodshot #cc3344 lines),
deep angry V-brows (#1a1a2e), buck teeth bared in a snarl, mouth wide
mid-screech. POSE: lunging FORWARD, both paws raising a lit ACORN-BOMB
overhead ready to HURL it (#5a3a1a acorn, sparking fuse #ffd700 +
#ff6b35 + #ffffff). Anger vein-mark on forehead (#cc3344). JUNGLE accent
#3d6e3a. Hostile, ready to attack.
```

#### **E2: Intern Monkey** → `enemies/monkey.png`
```
[PREFIX_ENEMY_V2]
Subject: a CHIBI cartoon BURNT-OUT INTERN MONKEY having a RAGE MELTDOWN —
jungle enemy. Tan-brown fur (#b8895a base, #8a6038 shadow, #d8a878
highlight), bloodshot furious eyes with eye-bags (#1a1a2e + #cc3344
veins + #6a5a7a bags), bared gritted teeth, screaming-angry mouth.
CLOTHING: rumpled untucked white shirt (#ffffff, #d0d0d0 shadow), red
tie yanked loose and flung over shoulder (#cc3344), crooked lanyard
badge (#1a1a2e + #ffffff). POSE: one fist CRUSHING a takeaway coffee
cup (coffee splashing #6a4a2a + #ffffff splash droplets), other arm
HURLING a flurry of papers (#ffffff sheets flying). Anger marks (#cc3344)
above head. "I'M DONE" fury. JUNGLE accent #3d6e3a. Aggressive.
```

#### **E3: Dieting Plant** → `enemies/plant.png`
```
[PREFIX_ENEMY_V2]
Subject: a CHIBI cartoon AGGRESSIVE VENUS FLYTRAP lunging to BITE — jungle
enemy. Green bulb-head with a HUGE gaping toothy maw wide open
(#4a9e3a base, #2e6e22 shadow, #6ed44a highlight, #cc3344 pink inner
mouth, rows of sharp #ffffff fangs), drool dripping (#ffffff + #c8e89a).
Furious narrowed eyes (#1a1a2e + #ffd700 hungry glint), angry brow-leaves.
POSE: snapping FORWARD at the viewer, stem arched, two leaf-arms
whipping/reaching like claws, roots tensed. Small terracotta pot at base
(#c0683a + #8a4a24), cracking from the force. A flung-away diet salad
bowl tipping over nearby (#ffffff bowl, #4a9e3a lettuce). HUNGRY FOR YOU,
not for salad. JUNGLE palette. Aggressive.
```

#### **E4: Toilet Paper Mummy** → `enemies/mummy.png`
```
[PREFIX_ENEMY_V2]
Subject: a CHIBI cartoon MENACING MUMMY wrapped in TOILET PAPER, lurching
to GRAB — jungle/temple enemy. Fully wrapped in white toilet-paper strips
(#ffffff base, #e0e0e0 shadow, ragged perforated edges, some strips torn
and flailing). Oversized chibi head, two GLOWING ANGRY eyes burning
through the wrapping (#cc3344 red glow + #ffffff core), furrowed wrap-
brow, snarling gap in the wraps showing gritted teeth. POSE: lurching
FORWARD, both bandaged arms outstretched to grab/strangle, fingers
splayed. Loose toilet-paper strips trailing aggressively behind like
tendrils, half-unrolled roll clutched in one fist (#ffffff + #c0a060
tube). Threatening, undead-angry. Single character centered.
```

#### **E5: Confused Snake** → `enemies/snake.png`
```
[PREFIX_ENEMY_V2]
Subject: a CHIBI cartoon AGGRESSIVE HISSING SNAKE reared to STRIKE —
jungle/temple enemy. Green snake (#4a9e3a base, #2e6e22 belly shadow,
#6ed44a highlight, #c8e8b0 underside), body coiled tight and reared up
ready to lunge. Oversized head, mouth WIDE OPEN showing curved FANGS
(#ffffff) with dripping green VENOM (#6ed44a + #ffffff drops), forked
tongue lashing out (#cc3344). Furious slitted eyes (#ffd700 iris +
#1a1a2e slit pupils + angry V-brows #1a1a2e) — one eye slightly cross
for a touch of dumb-but-deadly humor. Hissing "Sssss" motion lines.
POSE: striking forward at viewer. JUNGLE palette. Aggressive, venomous.
```

#### **E6: Tourist Skeleton** → `enemies/skeleton.png`
```
[PREFIX_ENEMY_V2]
Subject: a CHIBI cartoon AGGRESSIVE SKELETON TOURIST attacking — temple
enemy. Off-white bones (#e8e8e0 base, #b8b8a8 shadow, #ffffff highlight),
oversized skull with hollow eye sockets now GLOWING ANGRY (#5aff5a green
glow + #ffffff core), jaw open in a furious snarl, cracked teeth bared.
CLOTHING (the joke): loud Hawaiian shirt (#ffffff + #cc3344 hibiscus +
#3d6e3a leaves) flapping, straw sun hat knocked askew (#d8b878). POSE:
lunging FORWARD, one bony arm reaching with clawed fingers, the other
SWINGING a vintage camera like a blunt weapon (#2a2a2a body, #6a4a2a
strap, #8c8c8c lens). Angry, on the attack. TEMPLE accent #4a9e6b.
```

#### **E7: Budget Golem** → `enemies/golem.png`
```
[PREFIX_ENEMY_V2]
Subject: a CHIBI cartoon AGGRESSIVE BUDGET STONE GOLEM smashing — temple
enemy. Stocky body of MISMATCHED cheap rocks poorly stacked (#8c8378
base, #6a6058 shadow, #a89e90 highlight, odd blocks #a67c3a / #7a8a7a),
cracks splitting from the strain (#3a3530). Blocky chibi head, eyes
BLAZING angry (#cc3344 red glow + #ffffff core), heavy stone brow
furrowed, jagged stone-teeth grimace. POSE: charging FORWARD, both
oversized rock-fists raised to SMASH down, one foot stomping. Small
chips/dust flying off (#a89e90 specks). A "50% OFF" price tag flapping
on one arm (#ffd700 + #1a1a2e string) — still cheap, now furious.
TEMPLE accent #4a9e6b. Aggressive.
```

#### **E8: Sheet Ghost** → `enemies/ghost.png`
```
[PREFIX_ENEMY_V2]
Subject: a CHIBI cartoon MENACING BEDSHEET GHOST dive-bombing the viewer —
temple enemy. Draped white sheet (#ffffff base, #d8d8e0 shadow folds),
but SHARP and tattered with a jagged torn hem (not soft/cute). Two wide
ANGRY eye-holes glowing (#1a1a2e voids + #5aff5a green glow inside) and
a big jagged SCREAMING mouth-hole (#1a1a2e). POSE: lunging FORWARD/down
with both sheet-arms stretched into clawed points, sheet billowing
violently. Faint eerie green aura (#5aff5a, subtle). Spooky-aggressive,
on the attack — scary but still cartoon (no gore). TEMPLE accent #4a9e6b.
```

> **Bossy:** patrz sekcja **3.6** niżej.

---

## 3.5 Prompty pozostałych wrogów (J6, T6, D1-D5) — V2

> Ci wrogowie **już mają dobry projekt/identity** (jaguar z selfie-stickiem, Karen-mumia, wielbłąd-klątwa itd.) — **NIE wymyślamy ich od nowa**. Cel: przepuścić przez **V2 (pixel-art + agresja)**, zachowując design 1:1.
>
> **Image reference — UŻYJ OBECNEGO PNG postaci jako GŁÓWNEJ referencji** (identity/projekt/proporcje), **+ dołącz `_anchor_squirrel.png`** jako drugą referencję (pixel-style). Jeśli generator przyjmuje tylko 1 obraz referencyjny → priorytet ma **obecny PNG postaci** (zachowanie projektu ważniejsze niż styl — `pixelate.py` i tak ujednolici piksele na końcu).
>
> Workflow: `[PREFIX_ENEMY_V2]` + prompt poniżej + image ref(y) → wygeneruj → wytnij magentę → normalizuj (88%, 384×384) → `pixelate.py --res 110 --colors 32 --out 384` → nadpisz **ten sam plik**.

#### **J6: Jaguar Influencer** → `enemies/jungle/jaguar_influencer.png`
- **Image reference:** `enemies/jungle/jaguar_influencer.png` (obecny) + `_anchor_squirrel.png`
```
[PREFIX_ENEMY_V2]
Subject: a CHIBI cartoon JAGUAR INFLUENCER having a RAGE-QUIT — jungle
enemy, SAME spotted jaguar design as the reference image (yellow-orange
fur #e0a050 base, darker orange shadow #b87838, lighter belly #f5d090,
black rosette spots #1a1a2e). Oversized chibi head, eyes now BLAZING
with fury (#ffaa44 iris + bloodshot #cc3344 veins), bared sharp fangs in
a snarl, ears pinned back angrily. PROPS — purple designer sunglasses
(#5a2c82 frame, #8855c4 lens) knocked askew on his head, gripping the
selfie-stick (gray #6b6b6b shaft, #1a1a2e grip, phone screen #4a9eff
flashing "0 LIKES") raised like a WEAPON about to swing. POSE: lunging
forward, free paw with claws extended toward viewer. JUNGLE accent
#3d6e3a. Aggressive, hostile.
```

#### **T6: Cursed Tourist** → `enemies/temple/cursed_tourist.png`
- **Image reference:** `enemies/temple/cursed_tourist.png` (obecny) + `_anchor_squirrel.png`
```
[PREFIX_ENEMY_V2]
Subject: a CHIBI cartoon ZOMBIE TOURIST mid-lunge — temple enemy, SAME
design as the reference image (pale grayish-green skin #9aa890 base,
#6a7860 shadow, #c4d0b8 highlight; one normal eye #ffffff+#1a1a2e, other
eye glowing bright green #5aff5a+#ffffff core; bright Hawaiian shirt
#ffffff base with red hibiscus #cc3344 and green palm leaves #3d6e3a,
khaki shorts #c4a570; vintage camera #2a2a2a on a brown leather strap
#6a4a2a). Slack jaw replaced by a wide undead SNARL with gritted broken
teeth, both eyes now wide and FURIOUS. POSE: lurching FORWARD with both
arms reaching to grab, one hand brandishing the glowing turquoise relic
stone (#8c8378 + #4a9e6b runes) like a weapon, camera swinging wildly on
its strap. TEMPLE accent #4a9e6b. Hostile undead, ready to attack.
```

#### **D1: Sand Karen** → `enemies/desert/sand_karen.png` (anchor dla D2-D5, generuj pierwszy)
- **Image reference:** `enemies/desert/sand_karen.png` (obecny) + `_anchor_squirrel.png`
```
[PREFIX_ENEMY_V2]
Subject: a CHIBI cartoon MUMMY KAREN mid-RAGE — desert enemy, SAME design
as the reference image (off-white sandy bandage wrappings #f5dca0 base,
#c4a070 shadow, #ffffff highlights; beige-blonde Karen bob haircut
#d4b88a base, #a08858 shadow, signature 2010s flip). FURIOUS narrowed
eyes (#1a1a2e thick angry brows, #ffffff sclera), mouth wide open
SCREAMING. POSE: both arms raised — one fist clenched and shaking, the
other pointing aggressively forward at the viewer — bandages whipping
and unraveling violently with the motion. Small cloud of sand kicked up
around her feet (#c4a070 dust). DESERT palette. Aggressive, demanding,
ready to attack.
```

#### **D2: Cursed Camel** → `enemies/desert/cursed_camel.png`
- **Image reference:** `enemies/desert/cursed_camel.png` (obecny) + nowy `sand_karen.png` (V2) + `_anchor_squirrel.png`
```
[PREFIX_ENEMY_V2]
Subject: a CHIBI cartoon CURSED CAMEL charging — desert enemy, SAME
design as the reference image (tan-beige fur #d4a060 base, #a67c3a
shadow, #f5dca0 highlight, short stubby legs, THREE HUMPS each glowing
with curse energy: first pink #ff66cc, second purple #5a2c82, third teal
#4fb3bf, all with #ffffff cores). Eyes now WIDE and FURIOUS (#1a1a2e
pupils, bloodshot #cc3344 veins), one large buck tooth #ffffff bared in
a snarl, ears pinned back. POSE: charging FORWARD head-down at the
viewer, all three humps pulsing brighter and crackling, dark magical
wisps (#5a2c82 + #ff66cc particles) flaring off violently. DESERT
palette. Aggressive, possessed.
```

#### **D3: Dust Devil Brad** → `enemies/desert/dust_devil_brad.png`
- **Image reference:** `enemies/desert/dust_devil_brad.png` (obecny) + nowy `sand_karen.png` (V2) + `_anchor_squirrel.png`
```
[PREFIX_ENEMY_V2]
Subject: a CHIBI cartoon DUST TORNADO WITH A FURIOUS INFLUENCER FACE —
desert enemy, SAME design as the reference image (small swirling sand
tornado, conical shape, #e4b872 base, #c49b5c darker swirl lines, #f5dca0
highlight on top; male face embedded in the upper portion, dirty-blonde
fauxhawk hair #c4a060). Face now RAGING — hair windswept wild, perfect
white teeth #ffffff bared in a scream, eyes blazing behind cracked
sunglasses (#1a1a2e frames, #4a9eff lens). POSE: tornado leaning/lunging
toward the viewer, selfie-stick (gray #6b6b6b shaft, #1a1a2e grip, phone
screen #1a1a2e showing red REC dot #cc0000) thrust forward like a spear,
3-4 sand particle streams whipping aggressively around the body. DESERT
palette. Aggressive.
```

#### **D4: Pyramid Scheme Scarab** → `enemies/desert/pyramid_scheme_scarab.png`
- **Image reference:** `enemies/desert/pyramid_scheme_scarab.png` (obecny) + nowy `sand_karen.png` (V2) + `_anchor_squirrel.png`
```
[PREFIX_ENEMY_V2]
Subject: a CHIBI cartoon SCARAB BEETLE IN A BUSINESS SUIT, mid-aggressive
sales pitch — desert enemy, SAME design as the reference image
(iridescent dark blue-purple shell #5a2c82 base, #2a1840 shadow, #8855c4
highlight, #4a9eff shimmer dots; compound eyes #1a1a2e + #ffffff
highlights; black suit jacket #1a1a2e, white shirt collar #ffffff, red
tie #cc3344; brown leather briefcase #6a4a2a with "SCAM" text #ffffff).
Forced friendly smile replaced by a MANIC too-wide grin, eyes WIDE and
unsettling, both antennae whipping wildly. POSE: lunging FORWARD, the
"SCAM" briefcase brandished like a weapon mid-swing in one leg, another
leg shoving an "ACT NOW!!!" flyer (#ffffff + #cc3344 text) at the viewer.
DESERT palette. Aggressive, pushy.
```

#### **D5: Sandstone Bouncer** → `enemies/desert/sandstone_bouncer.png`
- **Image reference:** `enemies/desert/sandstone_bouncer.png` (obecny) + nowy `sand_karen.png` (V2) + `_anchor_squirrel.png`
```
[PREFIX_ENEMY_V2]
Subject: a CHIBI cartoon STONE GOLEM BOUNCER mid-SHOVE — desert enemy,
SAME design as the reference image (muscular humanoid of carved sandstone
blocks #a67c3a base, #6a4a20 shadow seams, #d4a070 highlight, oversized
square chibi head, very wide shoulders, black sunglasses #1a1a2e/#4a4a4a,
earpiece, red velvet rope #cc3344 + gold tassels #ffd700, ankh hieroglyph
on chest #3a3530). Stoic expression broken — stone brow furrowed deep,
mouth open in a booming shout, cracks in the stone glowing faintly with
anger (#cc3344 thin lines in the seams). POSE: one massive fist throwing
a forward PUNCH at the viewer, the other arm swinging the velvet rope
like a whip, dust/rock chips flying off (#d4a070 specks). DESERT palette.
Aggressive.
```

---

## 3.6 Bossy (B1-B4, B55, ULTIMATE) — V2

> Workflow identyczny jak wrogowie, ale: **normalizacja 512×512** + `pixelate.py --res 150 --colors 40 --out 512`. **Image reference:** obecny PNG bossa (identity) + `_anchor_squirrel.png` (styl). Jeśli boss już ma porządny projekt i jest imponujący (np. Ramboses) — V2 dopisuje TYLKO pixel-art + STYLE LOCK, bez przepisywania agresji.

   #### **B1: The Allergic Idol** → `enemies/boss_idol.png` (stage 10)
   - **Image reference:** `enemies/boss_idol.png` (obecny) + `_anchor_squirrel.png`
   ```
   [PREFIX_BOSS_V2]
   Subject: a CHIBI cartoon ANCIENT TEMPLE IDOL mid-EXPLOSIVE SNEEZE — SAME
   design as the reference image (mossy weathered stone #8c8378 base,
   #5a5048 deep shadow, #b4aa98 highlight, carved geometric grooves
   #3a3530, moss patches #4a9e6b, oversized glowing gold eyes #ffd700 +
   #ffffff core). Eyes now SQUEEZED SHUT and watery, brow scrunched in
   pre-sneeze fury, wide carved mouth mid-thunderous "ACHOO" with a visible
   shockwave/burst of pollen and spore dust (#c8e89a + #ffffff + #4a9e6b
   motes) exploding outward like an attack. Glowing nose-drip (#4a9eff +
   #ffffff) flung sideways from the force. Stone arms braced. Faint gold
   aura (#ffd700, 8px). TEMPLE/JUNGLE palette. Imposing, comedic-violent.
```

#### **B2: Brad the Influencer** → `enemies/boss_brad.png` (stage 25)
- **Image reference:** `enemies/boss_brad.png` (obecny) + `_anchor_squirrel.png`
```
[PREFIX_BOSS_V2]
Subject: a CHIBI cartoon INFLUENCER BOSS mid-RAGE-MELTDOWN — SAME design
as the reference image (dirty-blonde swept-up fauxhawk #c4a060 base,
#8a6038 shadow, #e8d0a0 highlight; mirror sunglasses #1a1a2e frames +
#4a9eff lens; white designer tee #ffffff under varsity jacket #cc3344 +
#1a1a2e sleeves; gold chain #ffd700). Smug grin replaced by a SCREAMING
RAGE FACE — teeth bared #ffffff, eyes wide and furious with bloodshot
#cc3344 veins behind cracked sunglasses. POSE: hurling the smartphone
(#1a1a2e body, screen #4a9eff with red REC dot #cc0000) toward the viewer
like a weapon, other hand crushing the glowing hexagonal ring light
(#ffffff core + #ffd700 glow, now cracking). Floating "UNSUBSCRIBED" +
broken-heart UI bubbles (#cc3344/#1a1a2e) around him. Aggressive,
ratio'd-and-furious.
```

#### **B3: The Budget Sphinx** → `enemies/boss_sphinx.png` (stage 40)
- **Image reference:** `enemies/boss_sphinx.png` (obecny) + `_anchor_squirrel.png`
```
[PREFIX_BOSS_V2]
Subject: a CHIBI cartoon DISCOUNT EGYPTIAN SPHINX BOSS mid-SWIPE — SAME
design as the reference image (small crouching sphinx, cracked sandstone
body #d4a060 base, #a67c3a shadow, #f5dca0 highlight, visible crack lines
#6a4a20, mismatched gray patch-stones #8c8378, gold+dark-blue striped
NEMES headdress #ffd700/#2a4a7a, chipped and crooked). Smug bored cat
face replaced by a SNARLING furious expression — fangs bared, ears
flattened, narrow eyes (#1a1a2e + #ffd700 glint) blazing wide. POSE: one
paw SWIPING forward with claws extended toward the viewer, the other paw
waving the "SALE 50%" sign (#ffffff + #cc3344) like a club; tip jar
knocked over, gold coins (#ffd700) flying. Cracks in the sandstone
glowing/widening with rage (#cc3344 thin glow lines). DESERT/TEMPLE
palette. Aggressive, demanding payment NOW.
```

#### **B4: Saddam on the Raft** (ULTIMATE) → `assets/sprites/Sadam-removebg-preview.png`
- **Image reference:** `assets/sprites/Sadam-removebg-preview.png` (obecny) + `_anchor_squirrel.png`
```
[PREFIX_BOSS_V2]
Subject: a CHIBI cartoon DEADPAN "RAFT WARLORD" BOSS mid-action-pose —
SAME design as the reference image (big bushy black cartoon mustache
#1a1a2e, beret/military cap #3a4a2e + gold star #ffd700, olive military
jacket #4a5238 base, #2e3622 shadow, #6a7250 highlight, cartoon medals
#ffd700 + #cc3344). Expression STAYS 100% deadpan/stoic — but the small
lopsided raft of lashed logs (#8b6914 wood, #5a3a10 shadow, #c4a060
highlight, frayed rope #c4a070) is now rocking violently on choppy water
(#4fb3bf + #ffffff foam splashing high). POSE: braced in a wide stance
for balance, one hand solemnly pointing the tiny yellow rubber ducky
(#ffd700 body + #ff6b00 beak) at the viewer like a weapon/scepter, other
arm out for balance. Gold "final boss" aura (#ffd700, 8-10px) flickering
intensely. 100% deadpan despite the chaos — he has no idea he's
ridiculous.
```

#### **B55: Ramboses — Pharaoh of Vengeance** → `enemies/desert/boss_ramboses.png` (stage 55)
> Już imponujący/agresywny w oryginalnym opisie (ART_PLAN.md sekcja 3.3, minigun, headband, etc.) — **NIE przepisuj treści**. Po wygenerowaniu wg ART_PLAN.md → tylko podmień `[PREFIX_BOSS]` → `[PREFIX_BOSS_V2]` i dopisz STYLE LOCK + `_anchor_squirrel.png` (i `boss_brad.png` V2, jeśli już gotowy) jako image reference. Pixelate `--res 150 --colors 40 --out 512`.

---

## 4. Co z 8 istniejącymi wrogami (już w grze)

E1-E8 są wgrane jako gładkie 384×384. **Nie trzeba ich regenerować od zera** — wystarczy przepuścić przez pikselizację:
```bash
python execution/pixelate.py assets/sprites/enemies --res 110 --colors 32 --out 384
```
> ⚠️ To spikselizuje **wszystkie** PNG w folderze (też bossów na 384 — bossów rób osobno na 512). Najpierw **pilot na 1-2** żeby dobrać `--res`/`--colors`, potem reszta. Agresji pikselizacja nie doda (to kwestia generacji) — uroczych wrogów trzeba **przegenerować** PREFIX_V2 jeśli chcesz ich groźniejszych.

---

## 5. Workflow decyzji (rekomendacja)

1. **Pilot pikselizacji:** odpal `pixelate.py` na `monkey.png` z 2-3 ustawieniami (`--res 110/96`, `--colors 32/24`) → wrzuć do gry → wybierz poziom "mixu".
2. **Pilot agresji:** przegeneruj 1 wroga PREFIX_ENEMY_V2 (np. E5 Confused Snake → groźny syczący wąż) → porównaj z obecnym słodkim.
3. Zatwierdź oba → **batch**: pikselizacja folderu + regeneracja tych co mają być groźniejsi.
4. Bossy: PREFIX_BOSS_V2, pikselizacja `--res 150 --out 512`.

---

## 6. Stałe (carry-over z ART_PLAN.md, bez zmian)
- **Magenta** tło #FF00FF (chroma key) — teraz też w PREFIX V2.
- **Normalizacja** 88% fill, wyśrodkowanie (sekcja 0.5).
- **Rozmiary:** wróg 384×384, boss 512×512.
- **Kod skalowania** (`_get_sprite_content_size`) — bez zmian, działa.
- **Per-postać prompty** — ART_PLAN.md (E1-E8, B1-B4, biomy). Podmień tylko PREFIX na V2.
