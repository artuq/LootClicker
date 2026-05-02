# ISSUE-12: Poprawa UI — nowy skin interfejsu walki

**Status:** ✅ ZAMKNIETE (2026-03-07)

**Priorytet:** 🟡 ŚREDNI  
**Kategoria:** Grafika / UI  
**Szacowany czas:** 3-4h  
**Najlepszy model AI:** Claude Sonnet 4.6 (Godot theme/style edycja) + **Gemini 2.5 Pro** (mockupy UI, generowanie tekstur przycisków i HP barów)

## Opis
Interfejs walki wymaga odświeżenia wizualnego: lepsze HP bary, czytelniejsze etykiety, spójne tło.

## Zadania
1. **HP Bary** — dodać obramowanie, gradient fill, animacja smooth tween
2. **Etykiety** — użyć custom fontu (np. pixel font .ttf) zamiast domyślnego
3. **Tło walki** — parallax scrolling lub animowane tło zamiast statycznego JPEG
4. **Przyciski** — Kenney UI jest OK, ale dodać hover/press animations
5. **Victory Screen** — dodać złoty border, loot icons zamiast tekstu
6. **Enemy name label** — dodać nad wrogiem z drop shadow

## Pliki do edycji
- `src/scenes/GameBattleManager.gd` — UI creation code
- `node_2d.tscn` — scene layout
- `assets/ui/` — nowe assety UI
- `assets/fonts/` — custom font (do utworzenia)

## Kryteria akceptacji
- [X] Custom font załadowany
- [x] HP bary z smooth tween (`_tween_bar()` helper, TRANS_QUAD 0.2s)
- [x] XP bar — ProgressBar z animowanym tweened fill (0.3s)
- [x] Enemy nameplate — ciemne zaokrąglone tło nad wrogiem, tekst "Nazwa – Lvl X"
- [x] Victory screen z golden border (StyleBoxFlat, kolor #c7c219)
- [x] Victory loot icons — HBoxContainer z Label'ami (emoji + kolor)
- [x] ❤ heart icon przy HP barze gracza
- [x] Victory screen z ikonami TextureRect (scope v0.4.x zamkniety fallbackiem loot-icon labels)

## Zależności
- ISSUE-11 (spójny styl artystyczny)
