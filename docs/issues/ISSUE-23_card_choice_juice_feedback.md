# ISSUE-23: Satysfakcja z wyboru karty (Juice & Feedback)

**Priorytet:** 🟡 SREDNI  
**Kategoria:** UI / UX / Combat Feedback  
**Szacowany czas:** 2-3h  
**Najlepszy model AI:** Claude Sonnet 4.6 / Codex 5.3

## Opis
Po tapnieciu karty nagrody gracz musi dostac natychmiastowe, czytelne potwierdzenie dotyku (Android-first UX). Obecnie karta znika zbyt "surowo".

## Cel UX
- Jasny feedback: "dotkniecie zarejestrowane".
- Brak podwojnych klikniec.
- Plynne przejscie z wyboru nagrody z powrotem do walki.

## Instrukcje implementacji (Godot 4.x)
1. Podepnij sygnal `pressed()` dla kazdej karty w `CardChoiceScene`.
2. Po wyborze karty ustaw `disabled = true` dla wszystkich kart (blokada multi-tap).
3. Wybrana karta:
   - `create_tween()` -> skala `1.0 -> 1.1` (ok. `0.15s`, `TRANS_BACK` lub `TRANS_BOUNCE`).
   - krotki flash (`modulate` do jasnego koloru i powrot) lub krotka flara na dodatkowym `Sprite2D`.
4. Niewybrane karty (`tween.parallel()`):
   - `modulate.a -> 0.0` i `scale -> Vector2.ZERO` (ok. `0.2s`).
5. Po animacji wybranej karty:
   - szybki ruch karty w dol ekranu (kierunek inventory),
   - jednoczesne zmniejszenie skali do zera,
   - zamkniecie popupu i powrot do gameplay loop.

## Pliki do edycji
- `src/scenes/CardChoiceScene.gd`
- `src/scenes/CardChoiceScene.tscn`
- (opcjonalnie helper) `src/scripts/UIAnimations.gd`

## Kryteria akceptacji
- [X] Po tapnieciu nie da sie kliknac drugi raz (input lock).
- [X] Wybrana karta ma widoczny "bounce + flash".
- [X] Dwie pozostale karty znikaja plynnie i rownolegle.
- [X] Po animacji popup zamyka sie i gra wraca do walki bez laga.
- [X] Calosc dziala plynnie na Androidzie (>=30 FPS).

## Notatki techniczne
- Preferuj `create_tween()` zamiast `AnimationPlayer` dla krotkich efektow.
- Trzymaj laczny czas sekwencji < 0.5s, zeby nie spowalniac loopa.

## Update 2026-03-07 (Bottom Nav Juice)
- Naprawiono brak reakcji przyciskow `INVENTORY`/`STATS` (bledne sciezki do node'ow panelu).
- Dodano animacje "juice" dla dolnych tabow:
   - bounce/pulse kliknietego przycisku,
   - kolor aktywnej zakladki,
   - przejscie tresci `fade + slide`.
- Naprawiono warstwy UI: `BottomPanel` przeniesiony na osobny `CanvasLayer` (`BottomNavLayer`), aby nie renderowal sie pod `VictoryUI`.
