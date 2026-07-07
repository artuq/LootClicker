# ISSUE-12: Poprawa UI — nowy skin interfejsu walki

**Status:** ✅ ZAMKNIETE v1 (2026-03-07) · 🟢 ITERACJA v2 „Joana Indiana" (2026-06-15)

**Priorytet:** 🟡 ŚREDNI  
**Kategoria:** Grafika / UI  
**Szacowany czas:** 3-4h  
**Najlepszy model AI:** Claude Sonnet 4.6 (Godot theme/style edycja) + **Gemini Nano Banana** (generowanie tekstur UI: przyciski, panele, paski, ikony)

---

## 🟢 ITERACJA v2 — custom UI „Joana Indiana" (2026-06-15)

Pierwsza wersja (v1, niżej) opierała się na assetach Kenney + smooth tween. v2 zastąpiła to **własnym, spójnym skinem** (user-generated, Nano Banana → Photopea, chroma key magenta).

- [x] **Paski HP/XP/wroga** — wspólna rama (`HP_BACKGROUND.png`) + jeden tintowalny fill (`HP_FILL.png`), kolor przez `tint_progress`/`modulate_color` (Opcja A). Marginy 9-slice ujednolicone 10/5/10/5.
- [x] **PlayerHP + XP** przeniesione na `CanvasLayer` (poza kontenery) → swobodnie przesuwalne; XP z napisem „XP 0 / 50" na pasku.
- [x] **Enemy HP bar (styl Tap Titans 2)** — nazwa na fillu (lewa), wartość HP po prawej, biała czcionka z konturem.
- [x] **StageBar** (`StageBar.tscn` + `StageBar.gd`) — wizualny pasek progresji 5 węzłów (miniatury biomów, pierścienie normal/boss, kropki ścieżki, skalowanie aktywnego).
- [x] **Assety UI** — przyciski (`btn_normal/pressed`), panel okna, ikony nawigacji (inventory/stats), potion, ikony zasobów (coin/cog/bandage/venom/crystal).
- [x] **Coins/DPS** pozycjonowane z kodu (`MID_HUD_OFFSET_TOP`) — odporne na zapisy sceny z edytora.
- [x] **Usunięty** stały opis „Jungle 1/15 …" (zastąpiony przez StageBar).
- [x] Kolory czcionek (buttony, okno inventory, loot) dostrojone do ciepłej palety parchment.

> Dokumentacja stylu/pipeline UI: **[ART_PLAN.md](../ART_PLAN.md) §12 (U1-U12 style guide)**.

---

## Opis (v1)
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
