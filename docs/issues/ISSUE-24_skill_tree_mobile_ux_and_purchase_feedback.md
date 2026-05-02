# ISSUE-24: Optymalizacja Drzewka Umiejetnosci (Mobile UX)

**Priorytet:** 🟡 SREDNI  
**Kategoria:** UI / UX / Accessibility  
**Szacowany czas:** 2-4h  
**Najlepszy model AI:** Claude Sonnet 4.6

## Opis
Interfejs drzewka jest za malo czytelny na telefonach, a zakup skilla nie daje wyraznego feedbacku na ikonie.

## Cel UX
- Lepsza czytelnosc tekstu na malych ekranach.
- Natychmiastowy wizualny feedback po udanym zakupie.
- Wygodne trafianie przyciskiem kciukiem.

## Instrukcje implementacji (Godot 4.x)
1. Dla labeli kosztu i opisu statystyk:
   - zwieksz `LabelSettings.font_size` o ok. 30-40%,
   - ustaw `outline_size` i czarny `outline_color`,
   - wlacz `autowrap_mode` tam, gdzie tekst wychodzi poza ramki.
2. Dla udanego zakupu (`on_skill_purchased`):
   - animuj ikone skilla (`TextureRect`/`TextureButton`) przez `create_tween()`:
   - skala `1.0 -> 1.2 -> 1.0` (ok. `0.2s`, `TRANS_SPRING` albo `TRANS_BACK`),
   - szybki flash `modulate -> Color.WHITE -> base`.
3. Hitboxy:
   - upewnij sie, ze aktywny obszar dotyku przycisku kupna ma min. `44x44` px,
   - jesli trzeba, opakuj przycisk przez `MarginContainer` lub ustaw `custom_minimum_size`.

## Pliki do edycji
- `src/scenes/SkillTreeScene.gd`
- `src/scenes/SkillTreeScene.tscn`
- (opcjonalnie) `src/scenes/SkillTree.gd`

## Kryteria akceptacji
- [X] Koszt i opis skilla sa czytelne na typowym ekranie telefonu.
- [X] Zakup skilla daje natychmiastowy feedback ikony (bounce + flash).
- [X] Przycisk zakupu ma touch target min. `44x44`.
- [X] Brak regresji logiki 2-tap purchase flow.

## Notatki techniczne
- Zachowaj istniejacy styl hex-drzewka i nie zmieniaj logiki balansu.
- Priorytet to UX i czytelnosc, nie redesign artystyczny.
