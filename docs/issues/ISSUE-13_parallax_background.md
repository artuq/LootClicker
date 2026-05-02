# ISSUE-13: Tlo ekranow z parallax scrolling

**Priorytet:** 🟢 NISKI  
**Kategoria:** Grafika / FX  
**Status:** ✅ `DESCOPE / CLOSED` (2026-03-07)

## Decyzja
Zadanie zostalo celowo wycofane. Docelowy styl walki ma pozostac czytelny i spokojny, bez ruchomego tla.

## Uzasadnienie
- Parallax zwiekszal szum wizualny podczas walki i oslabial focus na enemy/UI.
- Produktowo wybrano prostszy kierunek: statyczne biome tlo (`Jungle` / `Temple`).
- Priorytet sprintu przesunieto na stabilnosc Android deploy i UX core loop.

## Co zostalo wykonane
- Usunieto `ParallaxBackground`/`ParallaxLayer` z aktywnej sceny walki.
- Przywrocono statyczne tlo w `src/scenes/node_2d.tscn`.
- Uproszczono logike przelaczania tla w `src/scenes/GameBattleManager.gd`.
- Usunieto katalog `assets/sprites/parallax` po rollbacku.

## Uwagi
Jesli temat ruchomego tla wroci, nalezy otworzyc nowe issue (np. `ISSUE-23`) z osobnym benchmarkiem UX/FPS na Android.
