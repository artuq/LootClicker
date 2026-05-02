# ISSUE-15: Ekran ładowania i splash screen

**Priorytet:** 🟡 ŚREDNI  
**Kategoria:** UI / Polish  
**Szacowany czas:** 1-2h  
**Najlepszy model AI:** Claude Sonnet 4.6 (Godot scene + GDScript)

## Opis
Dodać ekran ładowania z logo gry i progress barem zamiast czarnego ekranu przy starcie.

## Zadania
1. Skonfigurować `boot_splash` w `project.godot`:
   - `boot_splash/image` → logo gry (1024x1024)
   - `boot_splash/bg_color` → ciemny kolor (#1a1a2e)
   - `boot_splash/show_image = true`
2. Dodać animowany splash scene po boot splash:
   - Logo fade in → 1s hold → fade out → TitleScreen
3. Opcjonalnie: dodać progress bar ładowania assetów

## Pliki do edycji
- `project.godot` — boot_splash config
- `assets/icons/` — splash image
- Nowa scena: `src/scenes/SplashScreen.tscn` + `.gd`

## Kryteria akceptacji
- [X] Boot splash wyświetla logo
- [X] Animated splash z fade in/out
- [X] Płynne przejście do TitleScreen
- [X] Dobrze wygląda na 16:9 i 18:9

## Zależności
- Brak
