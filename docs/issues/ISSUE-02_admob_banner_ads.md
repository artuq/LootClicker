# ISSUE-02: Dodanie reklam banerowych AdMob

**Priorytet:** 🟡 ŚREDNI  
**Kategoria:** Monetyzacja / AdMob  
**Szacowany czas:** 2-3h  
**Najlepszy model AI:** Claude Sonnet 4.6 (integracja kodu + UI layout w Godot)  
**Status:** ✅ ZAIMPLEMENTOWANE (AdView banner w GameBattleManager — show na victory screenie, hide podczas walki)

## Opis
Oprócz rewarded ads (pełny heal) warto dodać banner ad na dole ekranu w ekranach niewalczących (TitleScreen, UpgradeScreen, SettingsScene). Zwiększy to przychody pasywne.

## Zadania
1. Utworzyć banner ad unit w konsoli AdMob
2. Dodać `BannerAd` do `TitleScreen.gd`, `UpgradeScreen.gd` i `SettingsScene.gd`
3. Banner NIE powinien wyświetlać się podczas walki (zasłania UI)
4. Zapewnić prawidłowe position/size na różnych rozdzielczościach (360x640 base)
5. Dodać opcję ukrycia reklam (przyszły IAP)

## Pliki do edycji
- `src/scenes/TitleScreen.gd`
- `src/scenes/UpgradeScreen.gd`
- `src/scenes/SettingsScene.gd`
- `src/scenes/GameBattleManager.gd` (hide banner during combat)

## Kryteria akceptacji
- [x] Banner widoczny na ekranach poza walką (victory screen)
- [x] Banner ukryty podczas walki
- [x] Brak nachodzenia na UI
- [ ] Prawidłowe wyświetlanie na różnych urządzeniach *(wymaga testu na większej liczbie urządzeń)*

## Zależności
- ISSUE-01 (produkcyjne AdMob)
