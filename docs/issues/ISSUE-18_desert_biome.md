# ISSUE-18: Nowy biom (Desert) od stage 40+

**Priorytet:** 🟢 NISKI  
**Kategoria:** Content / Gameplay  
**Szacowany czas:** 4-5h  
**Najlepszy model AI:** Codex 5.3 (generowanie kodu) + **Gemini 2.5 Pro** (grafiki wrogów pustynnych, tło)

## Opis
Dodać trzeci biom "Desert" od stage 40+ z nowymi wrogami i tłem, aby gracze mieli nową zawartość po temple.

## Zadania
1. Zaprojektować 5 nowych wrogów pustynnych:
   - Sand Scorpion (venom)
   - Cursed Pharaoh (relic_shards)
   - Dust Devil (bandages)
   - Scarab Swarm (venom)
   - Sandstone Guardian (relic_shards)
2. Wygenerować sprite'y w ustalonym stylu
3. Dodać `enemy_roster_desert` w `GameBattleManager.gd`
4. Nowe tło: `assets/sprites/Desert.jpeg`
5. Dodać logikę zmiany biomu w `spawn_enemy()`:
   - Stage 1-19: Jungle
   - Stage 20-39: Temple
   - Stage 40+: Desert
6. Nowy boss pustynny co 5 stage'y od 40

## Pliki do edycji
- `src/scenes/GameBattleManager.gd` — enemy rosters + biome logic
- `assets/sprites/enemies/` — nowe sprite'y
- `assets/sprites/Desert.jpeg` — tło

## Kryteria akceptacji
- [ ] 5 nowych wrogów z animacjami
- [ ] Tło desert wyświetla się od stage 40
- [ ] Boss desert działa
- [ ] Resource drops zbalansowane

## Zależności
- ISSUE-11 (spójny styl sprite'ów)
- ISSUE-04 (loot buff)
