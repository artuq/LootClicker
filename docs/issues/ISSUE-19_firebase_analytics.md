# ISSUE-19: Analityka i śledzenie postępu graczy (Firebase Analytics)

**Priorytet:** 🟢 NISKI  
**Kategoria:** Analytics / Monitoring  
**Szacowany czas:** 3h  
**Najlepszy model AI:** Codex 5.3 (integracja SDK) + Claude Sonnet 4.6 (event design)

## Opis
Dodać Firebase Analytics aby śledzić zachowania graczy podczas beta testów. Pozwoli to na optymalizację balansu na podstawie danych.

## Zadania
1. Dodać Firebase SDK do projektu Godot (plugin lub native)
2. Zdefiniować kluczowe eventy:
   - `stage_completed` (stage_number, time_seconds, hp_remaining)
   - `boss_killed` (boss_name, stage, attempts)
   - `boss_failed` (boss_name, stage, player_level)
   - `ad_watched` (stage, ad_type)
   - `card_chosen` (card_name, player_level)
   - `skill_upgraded` (skill_id, new_level)
   - `player_death` (stage, enemy_name, player_level)
   - `session_start` / `session_end` (duration)
3. Dodać `AnalyticsManager` autoload singleton
4. Wywołać eventy w odpowiednich miejscach w kodzie

## Pliki do utworzenia
- `src/scripts/AnalyticsManager.gd`
- `google-services.json` (z Firebase Console)

## Pliki do edycji
- `project.godot` — dodać autoload
- `src/scenes/GameBattleManager.gd` — track events
- `export_presets.cfg` — permissions

## Kryteria akceptacji
- [ ] Firebase podpięty i działa na Android
- [ ] Min. 5 eventów trackowanych
- [ ] Dashboard w Firebase Console pokazuje dane
- [ ] Brak wpływu na performance

## Zależności
- ISSUE-09 (beta testy — dane od testerów)
