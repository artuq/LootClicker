# ISSUE-11: Poprawa grafik wrogów (spójny styl artystyczny)

**Priorytet:** 🟡 ŚREDNI  
**Status:** 🟢 W TOKU — wrogowie ZROBIENI, bossy zostały (aktualizacja 2026-06-15)  
**Kategoria:** Grafika / Art  
**Szacowany czas:** 4-6h  
**Najlepszy model AI:** **Gemini Nano Banana / Imagen 4** (generowanie sprite'ów PNG, chroma key magenta) + Claude Sonnet 4.6 (integracja w Godot)

---

## ✅ AKTUALIZACJA 2026-06-15 — wszystkie 15 wrogów wdrożone (styl V2)

Styl finalny ewoluował z „hi-bit Stardew" (pierwotne założenie) na **pixel-art mix + agresja** z systemem STYLE LOCK (anchor = Angry Kaboom Squirrel). Pełne wytyczne i pipeline: **[ART_PLAN_V2.md](../ART_PLAN_V2.md)**.

**Wdrożone (V2, 384×384, podmienione pod istniejącymi ścieżkami — kod `GameBattleManager.gd` bez zmian):**
- ✅ E1-E8: squirrel, monkey, plant, mummy, snake, skeleton, golem, ghost
- ✅ Jungle: jaguar_influencer · Temple: cursed_tourist
- ✅ Desert (5): sand_karen, cursed_camel, dust_devil_brad, pyramid_scheme_scarab, sandstone_bouncer

**Zostało:**
- ⬜ Bossy: idol, brad, sphinx, saddam, ramboses — regen 512×512, prompty gotowe (ART_PLAN_V2 §3.6)
- ⬜ Zapis anchora `assets/_anchor_squirrel.png`

> Reguły spawnu biomów + roster są już zaimplementowane w `_init_enemy_rosters()` (rozszerzone o Desert w v0.7.0). Sekcje poniżej to pierwotny brief (6 wrogów / 3 bossy, styl Stardew) — zachowane jako kontekst historyczny.

---

## Opis (pierwotny brief)
Obecnie wrogowie używają mieszanki stylów — zdjęcia JPEG z removebg i osobne sprite'y. Potrzebna jest spójna stylistyka.

> **Styl wybrany (GitHub Issue #17):** **Hi-bit pixel art, Stardew Valley-like** — ciepłe kolory, cozy vibe, białe tło (removebg przed importem). NIEPŁATNE — AI prompt = identyczny styl dla wszystkich.

## Zadania
1. ✅ Styl wybrany: hi-bit pixel art, Stardew Valley style, 128×128 lub 256×256 PNG z przezroczystym tłem
2. Wygenerować/zlecić nowe sprite'y dla ALL wrogów (szczegóły poniżej)
3. Podmienić ścieżki w `_init_enemy_rosters()` w `GameBattleManager.gd`
4. Dodać reguły spawnu biomów do `GameBattleManager.gd`
5. Usunąć stare JPEG z `assets/sprites/`

---

## Roster wrogów (szczegółowe dane z GitHub Issue #17)

### DźUNGLA (Stages 1‒20) — *Natura, która próbuje Cię zabić, ale nieudolnie*

#### 1. Angry Kaboom Squirrel (Wsciekła Wiewiórka z Dynamitem)
- **Drop:** Gunpowder (Proch) / Nuts (Orzechy)
- **AI Prompt:** `"Hi-bit pixel art game sprite of a cute red squirrel holding a stick of red dynamite instead of a nut. The squirrel looks stressed and sweaty. Stardew Valley style, funny, vibrant colors, white background, game asset."`

#### 2. Intern Monkey (Małpa-Stażysta)
- **Drop:** Paperclips (Spinacze)
- **AI Prompt:** `"Hi-bit pixel art game sprite of a jungle monkey wearing a loose business tie and holding a briefcase. It looks tired and overworked. Stardew Valley style, humorous character, white background, game asset."`

#### 3. Dieting Plant (Mięsożerna Roślina na Diecie)
- **Drop:** Venom (Jad)
- **AI Prompt:** `"Hi-bit pixel art game sprite of a carnivorous venus flytrap plant wearing dental braces on its teeth. Green jungle plant monster, cute but dangerous, Stardew Valley style, white background, game asset."`

### ŚWIĄTYNIA (Stages 21‒40) — *Starożytne zło, które nie ma budżetu*

#### 4. Tourist Skeleton (Szkielet Turysta)
- **Drop:** Bones (Kości)
- **AI Prompt:** `"Hi-bit pixel art game sprite of a fantasy skeleton enemy wearing a colorful Hawaiian shirt, sunglasses and a straw hat. Holding a camera. Stardew Valley style, funny undead monster, white background, game asset."`

#### 5. Budget Golem (Golem z Kartonu)
- **Drop:** Cardboard (Karton)
- **AI Prompt:** `"Hi-bit pixel art game sprite of a golem monster made entirely of cardboard boxes taped together. It has an angry face drawn on it with a black marker. DIY aesthetic, funny, Stardew Valley style, white background, game asset."`

#### 6. Sheet Ghost (Duch w Przescieradle)
- **Drop:** Ectoplasm (Ektoplazma)
- **AI Prompt:** `"Hi-bit pixel art game sprite of a classic ghost which is clearly just a white bedsheet with eye holes. You can see red sneakers peeking out from under the sheet. Floating pose, cute, Stardew Valley style, white background."`

---

## Bossy (dane z GitHub Issue #18) — 3 unikalni bossowie

### BOSS 1: The Allergic Idol (Stage 10)
- **Opis:** Kamienna głowa (styl Olmeków), gigantyczna, z czerwoną chusteczką i załzawionymi oczami. Atakuje kichnięciem.
- **Greeting:** `"Ah... Ah... CHOO!"`
- **AI Prompt:** `"Hi-bit pixel art game boss sprite of a giant ancient stone head idol (Olmec style). It looks sick, with a runny nose and holding a giant handkerchief. Mossy texture, funny expression, large scale, Stardew Valley style, white background."`

### BOSS 2: Brad the Influencer (Stage 25)
- **Opis:** Stereotypowy napakowany poszukiwacz przygód, ale trzyma telefon na kijku do selfie i robi dziobek.
- **Greeting:** `"Don't forget to like and subscribe!"`
- **AI Prompt:** `"Hi-bit pixel art game boss sprite of a handsome male adventurer. He has perfect hair, huge muscles, shining teeth. He is holding a selfie stick with a phone and posing for a photo while fighting. Arrogant expression, Stardew Valley style, white background."`

### BOSS 3: The Budget Sphinx (Stage 40)
- **Opis:** Zwykły gruby rudy kot siedzący w kartonowym pudełku, który ma doklejone papierowe skrzydła.
- **Greeting:** `"Meow. Give me gold."`
- **AI Prompt:** `"Hi-bit pixel art game boss sprite of a fat ginger cat sitting inside a cardboard box. It is wearing fake paper wings taped to its back, pretending to be a Sphinx. Cute and funny, Stardew Valley style, large sprite, white background."`

---

## Reguły spawnu biomów
- Stages 1–14: tylko Jungle
- Stages 15–20: 80% Jungle / 20% Temple (zapowiedź)
- Stages 21–35: tylko Temple
- Stages 36–40: 80% Temple / 20% Jungle (mix)
- Wrogowie w biome: losowy wybór per stage

---

## Pliki do edycji
- `assets/sprites/enemies/` — sprite'y wrogów (6 plików)
- `assets/sprites/bosses/` — sprite'y bossów (3 pliki, do utworzenia)
- `src/scenes/GameBattleManager.gd` — `_init_enemy_rosters()`: ścieżki + reguły spawnu biomów

## Kryteria akceptacji
- [ ] Wszystkie 6 wrogów (3 Jungle + 3 Temple) mają sprite'y hi-bit pixel art
- [ ] 3 bossowie (Stage 10/25/40) mają dedykowane sprite'y
- [ ] PNG z transparentnym tłem (removebg)
- [ ] Sprite'y w `assets/sprites/enemies/` i `assets/sprites/bosses/`
- [ ] Ścieżki zaktualizowane w `_init_enemy_rosters()`
- [ ] Reguły spawnu biomów zaimplementowane w `GameBattleManager.gd`
- [ ] Brak artefaktów JPG (usunięte stare pliki)
- [ ] Animacja idle (opcjonalnie — SpriteFrames)

## Zależności
- Brak
