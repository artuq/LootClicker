# ISSUE-18: Desert biome (stage 36-55) + boss Ramzes the Influencer

**Priorytet:** 🟡 ŚREDNI (post-launch content — Phase 1)
**Kategoria:** Content / Gameplay
**Szacowany czas:** 4-6h (kod) + 2-4h (grafiki w Google AI Studio)
**Najlepszy model AI:**
- Kod: **Claude Sonnet 4.6 / Opus 4.7**
- Grafiki: **Google AI Studio (Imagen 4)** — patrz [ISSUE-28](ISSUE-28_late_game_content_roadmap.md#5-generowanie-grafik--google-ai-studio-settings)
**Status:** 🔜 BACKLOG (Phase 1 z [ISSUE-28](ISSUE-28_late_game_content_roadmap.md))
**Data ostatniej rewizji:** 2026-05-25

> ⚠️ **Rewizja:** Ten ticket został zaktualizowany 2026-05-25 — wcześniejsza wersja zakładała stage 40+ i bossów co 5 stage'y, co nie pasowało do faktycznego kodu (bossy na 10/25/40, biome jungle/temple do stage 35). Nowy plan dopasowany do stanu kodu po publikacji v0.6.5.

## Kontekst

Po stage 40 gracz wpada w "mixed biome" (Jungle+Temple roster, tło Temple) bez progresji wizualnej. Brakuje 3. biomu i nowych wrogów. Desert to pierwszy biom z content roadmap'u opisanego w [ISSUE-28](ISSUE-28_late_game_content_roadmap.md).

Klimat tematyczny: pustynia egipska, ruiny piramid, archeologiczne tropy. Pasuje do Joany Indiany (Indiana Jones → Egypt).

## Opis

Dodać 3. biom "Desert" obejmujący stage 36-55 z 5 nowymi wrogami i nowym bossem.

## Stage progression (po zmianie)

| Stage range | Biome / event | Status |
|---|---|---|
| 1-14 | Jungle (pure) | ✅ |
| 15-20 | Jungle 80% / Temple 20% | ✅ |
| 21-35 | Temple (pure) | ✅ |
| **36-40** | **Temple 80% / Desert 20%** (transition) | 🔜 NEW |
| **41-49** | **Desert (pure)** | 🔜 NEW |
| **50** | **ULTIMATE BOSS: Saddam on the Raft** (istniejący v0.6.5 — bez zmian) | ✅ |
| **51-54** | **Desert (pure, post-Saddam)** | 🔜 NEW |
| **55** | **BOSS: Ramboses, Pharaoh of Vengeance** (koniec Desert biomu) | 🔜 NEW |
| 56+ | Frozen Peaks (Phase 2 — ISSUE-29) | 🔜 BACKLOG |

## Zadania

### Kod ([src/scenes/GameBattleManager.gd](../../src/scenes/GameBattleManager.gd))

1. Dodać `enemy_roster_desert: Array[Dictionary] = []` jako field klasy (linia ~25 obok jungle/temple).
2. Wypełnić `_init_enemy_rosters()` 5 nowymi wpisami desert (patrz "Nowi wrogowie" niżej).
3. Update `_get_enemy_for_stage(stage)` (~linia 551):
   - Stage 36-40: 80% temple, 20% desert
   - Stage 41-55: pure desert
   - Stage 56+: keep desert pool (na razie, zanim Phase 2)
4. Update `_get_biome_track()` (~linia 514): jeśli stage 41+ → "desert" (wymaga `desert_theme.mp3`).
5. Update `_update_biome_bg()` (~linia 522): wyświetlać `Desert.jpeg` dla stage 41+.
6. Dodać boss "Ramzes the Influencer" na stage 50 w `boss_roster` (~linia 473).
7. Dodać preload `bg_desert: Texture2D = preload("res://assets/sprites/Desert.jpeg")` (linia ~80).

### Assety

8. Wygenerować 5 sprite'ów wrogów + 1 boss (patrz prompty w [ISSUE-28 sekcja 5](ISSUE-28_late_game_content_roadmap.md#5-generowanie-grafik--google-ai-studio-settings)).
9. Wygenerować tło `Desert.jpeg` (9:16, prompt w ISSUE-28).
10. Skomponować `desert_theme.mp3` (opcjonalnie — można na razie reuse temple_theme).

## Nowi wrogowie (skrót z ISSUE-28 sekcja 3.2)

| ID | Name | Resource | File |
|---|---|---|---|
| D1 | Sand Karen | venom | `sand_karen.png` |
| D2 | Cursed Camel | bandages | `cursed_camel.png` |
| D3 | Dust Devil Brad | venom | `dust_devil_brad.png` |
| D4 | Pyramid Scheme Scarab | relic_shards | `pyramid_scheme_scarab.png` |
| D5 | Sandstone Bouncer | relic_shards | `sandstone_bouncer.png` |

**Pełne opisy + lore jokes:** [ISSUE-28 sekcja 3.2](ISSUE-28_late_game_content_roadmap.md#32-desert-biome-stage-36-55--5-nowych-wrogów).

## Nowy boss — **Ramboses, Pharaoh of Vengeance**

> 🎬 **Klimat:** parodia akcji 80s — **Hot Shots! Part Deux** + **Naked Gun**. Shirtless muscle-bound faraon-Rambo z gigantycznym minigunem, deadpan tough-guy energy.
>
> **Pełny opis wizualny + prompt do AI Studio:** [docs/ART_PLAN.md sekcja 3.3](../ART_PLAN.md#33-boss-ramboses--pharaoh-of-vengeance-stage-50)

```gdscript
55: {
    "name": "Ramboses",
    "texture": "res://assets/sprites/enemies/desert/boss_ramboses.png",
    "resource": "relic_shards",
    "greeting": "Surely you can't be serious. I am Pharaoh. And don't call me Sherbet.",
    "scale": 280.0,
},
```

> ℹ️ **Stage 50 zostaje bez zmian** — istniejący ULTIMATE BOSS Saddam on the Raft (kod handluje go przez `is_final_boss = (current_stage == 50)` w [GameBattleManager.gd:989](../../src/scenes/GameBattleManager.gd#L989), nie przez `boss_roster`). Ramboses na stage 55 wchodzi przez standardowy `is_named_boss` flow.

**Wizualnie (skrót):** Shirtless ripped faraon z czerwoną opaską (Rambo bandana), nemes przesunięty do tyłu jak peleryna, gigantyczny złoty minigun w prawej ręce, mała żółta gumowa kaczka w lewej (Naked Gun absurd prop), bullet belt z ankh-bullets, kohl makeup smeared like war paint, deadpan tough-guy squint. Kolory: gold + sandy + red bandana accent.

## Pliki do edycji / utworzenia

- `src/scenes/GameBattleManager.gd` (edit) — rosters + biome logic
- `assets/sprites/Desert.jpeg` (new) — tło biomu
- `assets/sprites/enemies/sand_karen.png` (new)
- `assets/sprites/enemies/cursed_camel.png` (new)
- `assets/sprites/enemies/dust_devil_brad.png` (new)
- `assets/sprites/enemies/pyramid_scheme_scarab.png` (new)
- `assets/sprites/enemies/sandstone_bouncer.png` (new)
- `assets/sprites/enemies/boss_ramzes.png` (new)
- `assets/audio/desert_theme.mp3` (optional, new)

## Kryteria akceptacji

- [ ] 5 nowych wrogów desert z grafikami w spójnym pixel-art style
- [ ] Tło Desert.jpeg wyświetla się od stage 41 (z transitionem 36-40)
- [ ] Boss "Ramzes" działa na stage 50 z poprawnym greeting + scale
- [ ] Resource drops zbalansowane (mix bandages/venom/relic_shards)
- [ ] Test progresji 35 → 60 — gracz widzi wszystkich nowych wrogów + bossa
- [ ] Brak regresji na stage 1-35 (Jungle/Temple działa jak dotąd)
- [ ] (Opcjonalnie) nowy desert_theme.mp3 muzyka

## Zależności

- [ISSUE-28](ISSUE-28_late_game_content_roadmap.md) — content roadmap, ten ticket jest Phase 1
- Wymagana publikacja v0.6.5 ✅
- Sugerowane: ISSUE-19 (Firebase Analytics) — żeby zmierzyć ilu graczy dochodzi do stage 36+

## Open questions

1. **Czy dodać nowy resource `gold_dust` dla Desert?** Decyzja w [ISSUE-28 sekcja 7](ISSUE-28_late_game_content_roadmap.md#7-resource-balance-do-przemyślenia-podczas-phase-1). Sugestia: na razie trzymać 3 obecne, dodać nowy resource później jak gracz dojdzie do Phase 2.
2. **Czy stage 50 boss = mid-difficulty czy hard?** Sugestia: pomiędzy Brad (stage 25) a Sphinx (stage 40), HP scaling ~1.5× zwykłego wroga stage 50.
