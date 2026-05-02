# ISSUE-03: Dodanie reklam interstitial (pełnoekranowych)

**Priorytet:** 🟡 ŚREDNI  
**Kategoria:** Monetyzacja / AdMob  
**Szacowany czas:** 2h  
**Najlepszy model AI:** Codex 5.3 (szybkie generowanie powtarzalnego kodu integracji)  
**Status:** ✅ ZAIMPLEMENTOWANE

## Opis
Dodać reklamy interstitial wyświetlane co N zabójstw wroga (np. co 5 lub co 10 zabójstw). Częstotliwość nie może irytować użytkownika.

## Zadania
1. Utworzyć interstitial ad unit w konsoli AdMob
2. Dodać `InterstitialAd` loading/caching w `GameBattleManager.gd`
3. Wyświetlać interstitial po co 8 zabójstwach (konfigurowalny próg)
4. NIE wyświetlać interstitial po bossie (tam jest victory screen + rewarded ad)
5. Preload następnej reklamy po zamknięciu poprzedniej

## Pliki do edycji
- `src/scenes/GameBattleManager.gd`

## Kryteria akceptacji
- [x] Interstitial wyświetla się co N zabójstw (`INTERSTITIAL_FREQUENCY = 8`)
- [x] Nie wyświetla się po bossie
- [x] Preload działa poprawnie (po init i po dismiss)
- [x] Ustawienie `INTERSTITIAL_FREQUENCY` jako const
- [x] Wklejone produkcyjne `INTERSTITIAL_AD_UNIT_ID` w `GameBattleManager.gd`

## Zależności
- ISSUE-01 (produkcyjne AdMob)
