# ISSUE-14: System animacji wrogów (idle, hit, death)

**Priorytet:** 🟡 ŚREDNI  
**Status:** ⏸️ ZAWIESZONE (2026-03-03)  
**Kategoria:** Grafika / Animacja  
**Szacowany czas:** 4-5h  
**Najlepszy model AI:** Codex 5.3 (generowanie kodu AnimationPlayer) + **Gemini 2.5 Pro** (spritesheet / klatki animacji)

## Opis
Wrogowie są obecnie statyczni (jedno zdjęcie). Dodać 3 stany animacji: idle (oddychanie), hit (flash + squash), death (fade + particles).

## Zadania
1. Przygotować spritesheet lub oddzielne klatki dla każdego wroga
2. Utworzyć `AnimatedSprite2D` zamiast `TextureRect` dla wroga
3. Zdefiniować animacje:
   - **idle**: 2-4 klatki, loop, 0.5s per frame
   - **hit**: squeeze + flash biały, 0.15s
   - **death**: fade out + particle burst + scale down
4. Podpiąć w `GameBattleManager.gd`:
   - `_on_enemy_hit()` → play "hit"
   - `_on_enemy_died()` → play "death"

## Pliki do edycji
- `src/scenes/GameBattleManager.gd`
- `node_2d.tscn`
- `assets/sprites/enemies/` — spritesheets

## Kryteria akceptacji
- [ ] Idle animacja dla wszystkich wrogów
- [ ] Hit flash działa
- [ ] Death animation z particles
- [ ] Smooth 60fps na mobile

## Zależności
- ISSUE-11 (nowe sprite'y)
