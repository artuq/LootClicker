# ISSUE-28: Late-Game Content Roadmap (stage 50+)

**Priorytet:** 🟡 ŚREDNI (post-launch content expansion)
**Kategoria:** Content / Gameplay / Art
**Szacowany czas:** 20-40h (cały pakiet — można dzielić na sub-ticket'y per biom)
**Najlepszy model AI:**
- Grafiki: **Google AI Studio** (Imagen 4 / Gemini 2.5 Image) — patrz sekcja "Generowanie grafik"
- Kod: **Claude Sonnet 4.6 / Opus 4.7**
**Status:** 🔜 BACKLOG (planowane post-launch)
**Data utworzenia:** 2026-05-25

## Kontekst biznesowy

Gra w obecnej wersji (v0.6.5, wysłana do publikacji w Google Play 2026-05-25) ma **2 aktywne biomy** (Jungle + Temple) i **3 bossów** (stage 10, 25, 40). Po stage 40 gracz wpada w "mixed" biom z miksem wrogów obu rosterów — brak progresji wizualnej i tematycznej.

Dla **retencji długoterminowej** (D30+, miesięczni gracze) potrzebujemy:
- Nowych biomów = wizualna progresja i poczucie podróży
- Nowych wrogów = świeżość mechanik, więcej osobistego "discovery"
- Nowych bossów = sense of accomplishment przy milestone'ach
- Spójności tematycznej (Joana Indiana — klimat Indiana Jones / archeo-przygody)

Idle/clicker gracze często grają miesiącami — bez nowej zawartości tracimy ich na rzecz konkurencji.

---

## 1. Stan obecny (audit kodu, 2026-05-25)

### Biomy
| Stage range | Biome | Background asset |
|---|---|---|
| 1-14 | Jungle (pure) | `Jungle.jpeg` |
| 15-20 | Jungle 80% / Temple 20% (transition) | Jungle BG, Temple sprite intro |
| 21-35 | Temple (pure) | `Temple.jpeg` |
| 36-40 | Temple 80% / Jungle 20% | Temple BG |
| 41+ | Mixed (both rosters) | Temple BG (no new visuals) |

### Enemy roster (aktualnie)

**Jungle** ([GameBattleManager.gd:419](../../src/scenes/GameBattleManager.gd#L419)):
1. Angry Kaboom Squirrel (squirrel.png) — bandages
2. Intern Monkey (monkey.png) — bandages
3. Dieting Plant (plant.png) — venom
4. Toilet Paper Mummy (Mumia-removebg-preview.png) — bandages
5. Confused Snake (Snake-removebg-preview.png) — venom

**Temple** ([GameBattleManager.gd:446](../../src/scenes/GameBattleManager.gd#L446)):
1. Tourist Skeleton (skeleton.png) — venom
2. Budget Golem (golem.png) — relic_shards
3. Sheet Ghost (ghost.png) — venom
4. Toilet Paper Mummy (shared with Jungle) — bandages
5. Confused Snake (shared with Jungle) — venom

### Bossowie ([GameBattleManager.gd:473](../../src/scenes/GameBattleManager.gd#L473))
| Stage | Name | Greeting | Resource |
|---|---|---|---|
| 10 | The Allergic Idol | "Ah... Ah... CHOO!" | relic_shards |
| 25 | Brad the Influencer | "Don't forget to like and subscribe!" | relic_shards |
| 40 | The Budget Sphinx | "Meow. Give me gold." | relic_shards |

**Styl tematyczny:** humorystyczny pixel-art, parodie tropów Indiana Jones / przygodowych, nazwy oparte na grze słów ("Budget Sphinx", "Brad the Influencer", "Toilet Paper Mummy").

---

## 2. Proponowana progresja biomów (stage 1 → endgame)

| Stage range | Biome | Theme | Status |
|---|---|---|---|
| 1-14 | **Jungle** | Tropikalna dżungla | ✅ DONE |
| 15-35 | **Temple** | Ruiny świątyni Majów/Azteków | ✅ DONE |
| 36-55 | **Desert** | Pustynne ruiny egipskie (Sahara) | 🔜 ISSUE-18 (rewrite) |
| 56-75 | **Frozen Peaks** | Zaśnieżone szczyty himalajskie + zamarznięta świątynia | 🔜 NEW |
| 76-95 | **Catacombs** | Podziemne lochy + krypta + lawa | 🔜 NEW |
| 96-120 | **Sunken Atlantis** | Podwodne ruiny | 🔜 NEW |
| 121+ | **Sky Temple** | Latająca świątynia w chmurach (endgame) | 🔜 NEW |

**Logika progresji:**
- Każdy biom trwa ~20 stage'y → daje gracz ~1-2 dni aktywnej zabawy w danej tematyce
- Strefy przejściowe (5 stage'y z mixem) wygładzają zmiany — gracz nie czuje hard-cuta
- Bossowie co 15 stage'y w nowych biomach: stage 50, 65, 80, 95, 110, 125 (do dostrojenia)
- **Endgame Sky Temple** to bezkresny biome — po stage 121 wrogowie skalują w nieskończoność (rerolly z tej puli)

---

## 3. Nowi wrogowie — opisy do generowania grafik

### 3.1 Rozszerzenie istniejących biomów (1 nowy na biom)

#### **Jungle: "Jaguar Influencer"** (nowy)
- **Resource:** bandages
- **Klimat:** Dżunglowy jaguar z drogim okularem i selfie-stickiem
- **Lore joke:** "Tu się robi content. Z dziką naturą i wszystkim."
- **Wizualnie:** pixel-art jaguar (~256×256), brązowo-czarne futro, fioletowe okulary, łapa trzyma kij od selfie, lekko obrażona mina
- **File:** `assets/sprites/enemies/jaguar_influencer.png`

#### **Temple: "Cursed Tourist"** (nowy)
- **Resource:** relic_shards
- **Klimat:** Zaginiony turysta, który stał się zombie po skradzeniu relikwii — z hawajską koszulą i aparatem fotograficznym
- **Lore joke:** "Mówiłem mu żeby nie dotykał."
- **Wizualnie:** pixel-art zombie-turysta, hawajska koszula w palmy, plecak, aparat na szyi, jedno oko świeci zielono
- **File:** `assets/sprites/enemies/cursed_tourist.png`

### 3.2 Desert biome (stage 36-55) — 5 nowych wrogów

#### **D1: "Sand Karen"**
- **Resource:** venom
- **Klimat:** Mumio-Karen z piaskową fryzurą "I want to speak to your pharaoh"
- **Lore joke:** "This pyramid does NOT meet my expectations."
- **Wizualnie:** mumia z fryzurą Karen, plamy z piasku zamiast bandaży, palec wycelowany oskarżająco

#### **D2: "Cursed Camel"**
- **Resource:** bandages
- **Klimat:** Wielbłąd z trzema garbami z których strzela klątwami
- **Lore joke:** "Plot twist: garby to klątwy."
- **Wizualnie:** wielbłąd, 3 garby świecące różowym/fioletowym, oczy świecące

#### **D3: "Dust Devil Brad"**
- **Resource:** venom
- **Klimat:** Mini-tornado piaskowe z twarzą influencera (callback do Brad'a bossa z Temple)
- **Lore joke:** "Algorytm mnie tu sprowadził."
- **Wizualnie:** wir piaskowy z oczami i ustami, w środku unosi się selfie-stick

#### **D4: "Pyramid Scheme Scarab"**
- **Resource:** relic_shards
- **Klimat:** Żuk skarabeusz w garniturze, sprzedaje "exclusive cursed crypto"
- **Lore joke:** "Zaufaj mi, to legalne."
- **Wizualnie:** skarabeusz z garniturem i krawatem, trzyma teczkę z napisem "SCAM"

#### **D5: "Sandstone Bouncer"**
- **Resource:** relic_shards
- **Klimat:** Olbrzymi golem z piaskowca, wykidajło egipskiej dyskoteki
- **Lore joke:** "Sorry, not on the guest list, Pharaoh."
- **Wizualnie:** muskularny golem z piaskowca, krzyżuje ręce, ciemne okulary, lina (velvet rope) w łapie

### 3.3 Frozen Peaks biome (stage 56-75) — 5 nowych wrogów

#### **F1: "Frostbite Yeti Barista"**
- **Resource:** venom
- **Klimat:** Yeti z fartuchem baristy, serwuje kawę która zamraża
- **Lore joke:** "Iced latte? It's all I serve here."
- **Wizualnie:** biały yeti z brązowym fartuchem, w łapie kubek paruje lodowym dymem

#### **F2: "Sherpa Skeleton"**
- **Resource:** bandages
- **Klimat:** Szkielet z plecakiem himalaisty, lina, czekan, gogle
- **Lore joke:** "I've been climbing for 200 years. Almost there."
- **Wizualnie:** szkielet w sprzęcie wspinaczkowym, czerwone gogle, lina przez ramię

#### **F3: "Avalanche Penguin"**
- **Resource:** venom
- **Klimat:** Pingwin z patelnią — wywołuje lawiny waląc nią o ziemię
- **Lore joke:** "Tap-tap-tap. BOOM."
- **Wizualnie:** mały pingwin, oczy zezowate, dzierży patelnię w obu skrzydłach

#### **F4: "Ice Crystal Mage"**
- **Resource:** relic_shards
- **Klimat:** Mag w przezroczystej szacie z kryształu lodu, każdy ruch tłucze fragmenty
- **Lore joke:** "Cool. Literally."
- **Wizualnie:** humanoidalna postać z lodu, w środku widać kostki lodu, kapelusz maga

#### **F5: "Frozen Tourist"** (callback do Cursed Tourist z Temple)
- **Resource:** bandages
- **Klimat:** Zamrożony turysta z hawajską koszulą, nie wyjmie rąk z kieszeni bo zamarznięte
- **Lore joke:** "Mówiłem mu żeby wziął kurtkę."
- **Wizualnie:** zamrożony w bryle lodu turysta, w środku widać hawajską koszulę, niebieska skóra

### 3.4 Catacombs biome (stage 76-95) — 5 nowych wrogów

#### **C1: "Lava Lich"**
- **Resource:** relic_shards
- **Klimat:** Lich (zły mag) zanurzony w lawie, korona spływa stopionym złotem
- **Lore joke:** "Im hotter I get, the cooler I look."
- **Wizualnie:** szkielet z koroną, stoi w kałuży lawy, oczy świecą pomarańczowo

#### **C2: "Crypt Bat Influencer"**
- **Resource:** venom
- **Klimat:** Nietoperz vampire z RingLightem (lampa do streamingu) zamiast latarni
- **Lore joke:** "Live from the crypt, smash that subscribe."
- **Wizualnie:** nietoperz z czerwonym RingLightem na szyi, kły, mikrofon w łapie

#### **C3: "Skeleton Knight HR"**
- **Resource:** bandages
- **Klimat:** Szkielet w zbroi rycerskiej, ale w łapie trzyma teczkę z PDF'em "Performance Review"
- **Lore joke:** "Let's circle back on this dungeon raid."
- **Wizualnie:** rycerski szkielet z hełmem, jedna ręka z mieczem, druga z teczką dokumentów

#### **C4: "Magma Slime"**
- **Resource:** venom
- **Klimat:** Magma slime — pulsuje, rozlewa się
- **Lore joke:** "Ouch. Don't touch."
- **Wizualnie:** pomarańczowo-czerwony kleisty stwór, krople lawy odpadają, dwie oczka

#### **C5: "Cursed Pharaoh DJ"**
- **Resource:** relic_shards
- **Klimat:** Faraon wstał z grobu jako rave DJ, scratching na płycie szlifierskiej
- **Lore joke:** "Drop the beat, drop the curse."
- **Wizualnie:** mumia z headphonesami, scratchuje gramofon, sarkofag w tle jako "DJ booth"

### 3.5 Sunken Atlantis biome (stage 96-120) — 5 nowych wrogów

#### **A1: "Anglerfish Lawyer"**
- **Resource:** venom
- **Klimat:** Głębinowa ryba z latarką nad głową — w teczce kontrakty
- **Lore joke:** "Sign here. And here. The fine print is fine."
- **Wizualnie:** anglerfish z teczką, latarka świeci niebieskim, krawat

#### **A2: "Mermaid Karen"**
- **Resource:** bandages
- **Klimat:** Syrena z fryzurą Karen, krzyczy o brak Wi-Fi pod wodą
- **Lore joke:** "How am I supposed to post this without signal?!"
- **Wizualnie:** syrena z fryzurą Karen, telefon w łapie, łza z oka

#### **A3: "Coral Reef Goblin"**
- **Resource:** relic_shards
- **Klimat:** Mały goblin pokryty koralem zamiast skóry
- **Lore joke:** "Tak, jestem skarbnicą NFT z 2017."
- **Wizualnie:** humanoidalny goblin, ciało z pomarańczowego koralu, w łapie złota moneta

#### **A4: "Kraken Intern"**
- **Resource:** venom
- **Klimat:** Młody kraken, 8 macek, w każdej trzyma kawę
- **Lore joke:** "Cały dzień przynosi kawy."
- **Wizualnie:** mały fioletowy kraken, 8 macek, każda z kubkiem kawy

#### **A5: "Atlantean Boss Karen"** (Mid-tier — może być mini-boss?)
- **Resource:** relic_shards
- **Klimat:** Atlantki w korale, korona z muszli, krzyczy "I want to speak to Poseidon!"
- **Wizualnie:** wysoka kobieta z koroną z muszli, trójząb w łapie

### 3.6 Sky Temple biome (stage 121+, endgame) — 5 nowych wrogów

#### **S1: "Cloud Cultist"**
- **Resource:** relic_shards
- **Klimat:** Mnich w białej szacie, lewituje na chmurce
- **Lore joke:** "Up here, the WiFi is divine."
- **Wizualnie:** mnich z kapturem, lewituje, dłonie w mudrze

#### **S2: "Sky Pirate Parrot"**
- **Resource:** venom
- **Klimat:** Olbrzymia papuga z opaską na oku i kapeluszem pirata
- **Lore joke:** "Polly want a relic, AAARRR!"
- **Wizualnie:** kolorowa papuga z opaską, na ramieniu mini-papuga

#### **S3: "Star Mage"**
- **Resource:** relic_shards
- **Klimat:** Mag z kosmicznym płaszczem, w łapie ma "drone" w kształcie planety
- **Lore joke:** "Mercury in retrograde. Sorry."
- **Wizualnie:** mag w fioletowym płaszczu z gwiazdami, czarodziejski kapelusz

#### **S4: "Wind Spirit Yoga Instructor"**
- **Resource:** bandages
- **Klimat:** Duch wiatru w pozycji yoga, lewituje skrzyżowane nogi
- **Lore joke:** "Breathe in the relic, breathe out the gold."
- **Wizualnie:** półprzezroczysta postać, joga, niebieskie obłoki

#### **S5: "Final Cultist Boss" (Endgame mini-boss)**
- **Resource:** relic_shards
- **Klimat:** Wielki sekciarz z koroną z piorunów, "Witaj w mojej domenie!"
- **Wizualnie:** mroczna postać w peleryniście, korona z piorunów, oczy świecą

---

## 4. Nowi bossowie

| Stage | Boss name | Biome | Greeting | Joke source |
|---|---|---|---|---|
| 50 | **Ramzes the Influencer** | Desert | "I have 10K followers in afterlife." | Pharaoh + Brad callback |
| 65 | **Yeti CEO** | Frozen Peaks | "Q4 results: cold. Very cold." | Corporate yeti |
| 80 | **Skeleton CFO** | Catacombs | "I'd love to help but I'm bone-broke." | Pun + corporate |
| 95 | **Anglerfish Tycoon** | Catacombs/Atlantis boundary | "Investors! Investors! Investors!" | Trump-esque tycoon |
| 110 | **Atlantean Karen Queen** | Atlantis | "I demand to speak to the surface manager!" | Karen + royalty |
| 125 | **Sky Temple Cultist Lord** | Sky Temple (endgame) | "You have ascended. Now perish." | Generic JRPG endgame |

---

## 5. Generowanie grafik — Google AI Studio settings

> 🎨 **GŁÓWNY DOKUMENT OPERACYJNY:** [**docs/ART_PLAN.md**](../ART_PLAN.md) — kompletny przewodnik w stylu War Meat ART_PLAN: tabela ustawień Nano Banana Pro/Imagen 4, PREFIX-y promptów, gotowe do kopiowania prompty per wróg/boss/tło, image reference workflow, palety per biome, status tracker. **Tam idź gdy zaczynasz generować grafiki.**
>
> Sekcja poniżej zostaje jako skrócony przegląd dla osób które najpierw czytają strategiczny ticket.

### Model do użycia
- **Preferowany:** **Imagen 4** (najlepsza jakość pixel-art)
- **Alternatywnie:** **Imagen 3** lub **Gemini 2.5 Flash Image** (szybsze, ale niższa jakość)
- **Nie polecane:** Imagen 2 (przestarzały)

### Ustawienia bazowe dla wrogów

| Parameter | Wartość | Uzasadnienie |
|---|---|---|
| **Aspect ratio** | `1:1` (square) | Sprite'y w grze są kwadratowe, łatwiej crop'ować |
| **Number of images** | 4 | Generuj 4 wersje, wybierz najlepszą |
| **Negative prompt** | `realistic, 3D rendering, photo, blurry, smooth, gradient, anti-aliasing, watermark, text, signature, multiple characters, background scenery` | Eliminuje typowe artefakty |
| **Person generation** | "Allow adult" lub "Don't allow" zależnie od wroga | "Karen" / "Brad" wymaga osób |

### Prompt template dla wrogów

```
Pixel art sprite of {character_concept}, full body facing camera,
chibi proportions with oversized head, clear silhouette on
transparent background, vibrant saturated colors with strong
black outlines, 4-color shading per surface, retro 16-bit JRPG style,
cute cartoon mobile game aesthetic, single character centered,
no background, no text, no logo, 1024x1024 pixel art canvas with
crisp pixels, no anti-aliasing
```

**Zamień `{character_concept}` na pełny opis z sekcji 3** (np. "a humanoid yeti barista with brown apron holding a coffee mug emitting icy steam, white fur, brown apron, googly eyes, mountain background scenery removed").

### Prompt template dla bossów

```
Pixel art sprite of {boss_concept}, IMPOSING boss-tier monster,
larger and more detailed than regular enemies, full body facing
camera with intimidating pose, dramatic lighting from above,
glowing eyes or aura, chibi-but-menacing proportions,
clear silhouette on transparent background, vibrant saturated
colors with strong black outlines, 4-color shading per surface,
retro 16-bit JRPG boss style, cute but dangerous cartoon aesthetic,
single character centered, no background, 1024x1024 pixel art canvas,
crisp pixels, no anti-aliasing
```

### Prompt template dla teł biomów

```
Pixel art mobile game background, {biome_concept}, vertical
portrait orientation 9:16 aspect ratio, no characters,
atmospheric depth with foreground/midground/background layers,
vibrant retro 16-bit JRPG aesthetic, painted pixel-art style
like classic Square Enix games, mobile-optimized clean
composition, no text, no UI elements, ambient ambient lighting
```

**Aspect ratio dla teł:** `9:16` (portrait, mobile-first).

### Style consistency tips

1. **Wygeneruj jednego "reference enemy" jako benchmark stylu** (np. zaczynając od "Jaguar Influencer"). Zachowaj go jako wzór do porównania kolejnych grafik.
2. **W kolejnych promptach dodaj:** `in the same pixel art style as previous character, consistent color palette, same outline weight, same shading style`.
3. **Paleta kolorów per biome:**
   - Desert: piaskowy (#E4B872, #C49B5C), turkus (#4FB3BF), pomarańcz (#F58A4A)
   - Frozen Peaks: lodowy biały (#E8F4F8), niebieski (#5C9CC4), szary (#8E9AAB)
   - Catacombs: ciemny brąz (#3D2E1F), pomarańcz lawy (#FF6B35), fiolet (#5A2C82)
   - Atlantis: turkus (#1ABC9C), głęboki niebieski (#2C3E50), koralowy (#FF8674)
   - Sky Temple: pastelowy róż (#F5C5DD), bladobiały (#FAFAFA), złoty (#FFD700)

4. **Po wygenerowaniu:** użyj GIMP/Photoshop / online tools (remove.bg) do oczyszczenia tła i upewnienia że PNG ma alfa-kanał.

### Workflow per wróg

1. Skopiuj prompt template
2. Wklej "character_concept" z sekcji 3 (pełny opis wraz z kolorystyką)
3. Wygeneruj 4 warianty w Google AI Studio
4. Wybierz najlepszy
5. Pobierz PNG → remove.bg → save jako `assets/sprites/enemies/{file_name}.png`
6. (Opcjonalnie) Pixel-art cleanup: użyj filtru "posterize" + downsample do 256×256 dla spójności rozmiarów

---

## 6. Plan implementacji (sub-tickets)

Sugeruję rozbicie tego epicki na 4 sub-ticket'y, wdrażane sekwencyjnie:

### Phase 1: Desert biome rewrite (stage 36-55) — ISSUE-18 (rewrite)
- Update istniejącego ISSUE-18 — zmiana zakresu z "40+" na "36-55"
- 5 nowych wrogów z sekcji 3.2
- Boss "Ramzes the Influencer" na stage 50
- Nowe tło `Desert.jpeg`
- Logika biome'u w `_update_biome_bg` i `_get_enemy_for_stage`

### Phase 2: Frozen Peaks (stage 56-75) — ISSUE-29 (do utworzenia)
- 5 nowych wrogów z sekcji 3.3
- Boss "Yeti CEO" na stage 65
- Nowe tło `FrozenPeaks.jpeg`
- Nowy audio track `frozen_theme.mp3`

### Phase 3: Catacombs (stage 76-95) — ISSUE-30 (do utworzenia)
- 5 nowych wrogów z sekcji 3.4
- Boss "Skeleton CFO" na stage 80 + "Anglerfish Tycoon" na 95
- Nowe tło `Catacombs.jpeg`

### Phase 4: Atlantis + Sky Temple (stage 96-endgame) — ISSUE-31 (do utworzenia)
- 5+5 wrogów (sekcje 3.5 + 3.6)
- Bossowie Karen Queen + Cultist Lord
- 2 nowe tła
- Endgame scaling (po stage 125 — wrogowie z dużym mnożnikiem HP)

### Phase 5: Resztki — Jaguar Influencer + Cursed Tourist (sekcja 3.1)
- Dodać do istniejących rosterów (Jungle + Temple)
- Minimum zmian kodu, tylko nowe wpisy w `enemy_roster_*`
- Można zrobić razem z Phase 1 jako "warm-up"

---

## 7. Resource balance (do przemyślenia podczas Phase 1)

Obecnie tylko 3 typy resource'ów: `bandages`, `venom`, `relic_shards`. Przy 5 nowych biomach warto rozważyć:
- **Desert:** dodać `gold_dust` (do nowych upgrade'ów / craft'u potion w przyszłości)
- **Frozen Peaks:** `frost_crystal`
- **Catacombs:** `lava_essence`
- **Atlantis:** `pearl`
- **Sky Temple:** `star_fragment`

Lub zostać przy 3 obecnych — prostsza struktura, mniej UX overhead.

**Decyzja przed Phase 1.**

---

## Zależności

- Wymagana publikacja v0.6.5 w Google Play (✅ wysłana 2026-05-25).
- Sugerowane wcześniej: zebrać analytics (ISSUE-19 Firebase) — żeby zobaczyć ile graczy w ogóle dochodzi do stage 40+ przed inwestowaniem w content beyond.

## Prognoza wpływu

- **+100-200% średniego czasu sesji** dla graczy którzy ukończą obecny content (stage 50+).
- **+30-50% retencji D30** — gracze widzą że jest "co robić" długoterminowo.
- Wsparcie monetyzacji długoterminowej (więcej impressions interstitial/rewarded ads).
- Risk: jeśli mało graczy w ogóle dochodzi do stage 40, ten content nie ma dla kogo istnieć — sprawdź analytics zanim wdrożysz Phase 3+.
