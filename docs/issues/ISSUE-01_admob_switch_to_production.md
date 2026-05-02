# ISSUE-01: Przełączenie AdMob z testowych na produkcyjne reklamy

**Priorytet:** 🔴 KRYTYCZNY  
**Kategoria:** Monetyzacja / AdMob  
**Szacowany czas:** 1-2h  
**Najlepszy model AI:** Claude Sonnet 4.6  
**Status:** ✅ ZAIMPLEMENTOWANE (rozumie kontekst kodu, dobry w edycji GDScript)

## Opis
Obecnie `DEBUG_FORCE_FAKE_ADS = true` w `GameBattleManager.gd` (linia ~1175). Reklamy AdMob używają testowego ID (`ca-app-pub-3940256099942544/5224354917`). Trzeba:

1. Zamienić `DEBUG_FORCE_FAKE_ADS` na `false`
2. Podmienić `REWARDED_AD_UNIT_ID` na prawdziwe produkcyjne ID z konta AdMob
3. Usunąć `test_device_ids` z konfiguracji request (lub zostawić tylko na czas dev)
4. Dodać fallback — jeśli reklama nie załaduje się w 10s, dać użytkownikowi info

## Pliki do edycji
- `src/scenes/GameBattleManager.gd` — linie 1175-1200

## Kryteria akceptacji
- [x] `DEBUG_FORCE_FAKE_ADS = false` w produkcyjnym buildzie
- [x] Produkcyjne ad unit ID wstawione
- [ ] Reklama ładuje się na prawdziwym urządzeniu po zatwierdzeniu konta AdMob *(pending — wymaga zatwierdzenia konta AdMob przez Google)*
- [x] Fallback info jeśli reklama niedostępna

## Zależności
- Konto AdMob musi być zatwierdzone przez Google
- Po zmianie trzeba przebudować APK (ISSUE-10)
