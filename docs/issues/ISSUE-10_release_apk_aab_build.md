# ISSUE-10: Build i test finalny APK/AAB przed beta release

> Aktualizacja operacyjna: 2026-03-07 (hotfix Android export)

**Priorytet:** 🔴 KRYTYCZNY  
**Kategoria:** Build / QA  
**Szacowany czas:** 2h  
**Najlepszy model AI:** Claude Sonnet 4.6 (automatyzacja buildów, logcat debug)

## Opis
Ostateczny build produkcyjny po zastosowaniu wszystkich zmian (AdMob, loot buff, grafiki).

## Zadania
1. Upewnić się, że `DEBUG_FORCE_FAKE_ADS = false` (ISSUE-01)
2. Upewnić się, że loot buff stage 35+ działa (ISSUE-04)
3. Ustawic aktualna wersje release/hotfix w `export_presets.cfg`:
   - `version/code = 4`
   - `version/name = "0.4.1-hotfix"`
   - `gradle_build/use_gradle_build = false` (dla obecnej konfiguracji lokalnej)
4. Build AAB: `godot --headless --export-release "Android" lootclicker.aab`
5. Build APK (do testów wewnętrznych): `godot --headless --export-release "Android" lootclicker.apk`
6. Zainstalować APK na telefonie, przetestować:
   - [X] Gra się uruchamia
   - [X] Save/load działa
   - [X] Reklamy wyświetlają się (lub mają fallback)
   - [X] Boss na stage 25 jest pokonywany
   - [X] Stage 35+ daje więcej lootu
   - [X] Drzewo umiejętności działa
   - [X] Karty po level up się wyświetlają
7. Logcat check: `adb logcat | findstr "ERROR\|CRASH\|AdMob"`
8. Git tag: `v0.4.0-beta`

## Pliki do edycji
- `export_presets.cfg` — version code/name

## Kryteria akceptacji
- [X] Zerowe crashe podczas 10-minutowego testplay
- [X] Wszystkie systemy działają
- [X] AAB gotowe do uploadu

## Zależności
- ISSUE-01, ISSUE-04, ISSUE-06
