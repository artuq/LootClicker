# ISSUE-07: Polityka prywatności i strona informacyjna

**Priorytet:** 🔴 KRYTYCZNY  
**Kategoria:** Legal / Release  
**Szacowany czas:** 1h  
**Najlepszy model AI:** Codex 5.3 lub Claude Sonnet 4.6 (generowanie tekstu prawnego + hosting)  
**Status:** ✅ ZAKOŃCZONE (część techniczna gotowa, publikacja URL i Play Console ręcznie)

## Opis
Google Play wymaga URL do polityki prywatności. Trzeba ją stworzyć i opublikować.

## Zadania
1. Wygenerować Privacy Policy obejmującą:
   - Zbieranie danych: AdMob (Google Advertising ID, analytics)
   - Przechowywanie danych lokalnych (save game, szyfrowany)
   - Brak kont użytkownika, brak logowania
   - Brak zbierania danych osobowych przez dewelopera
   - Dane zbierane przez AdMob SDK (link do polityki Google)
2. Opublikować na GitHub Pages lub jako statyczna strona
3. Dodać URL do konsoli Google Play
4. Dodać link w grze (SettingsScene)

## Pliki do edycji/utworzenia
- `docs/privacy-policy.md` lub `docs/privacy-policy.html`
- `src/scenes/SettingsScene.gd` — dodać przycisk "Privacy Policy"

## Kryteria akceptacji
- [x] Polityka prywatności napisana po angielsku
- [x] Opublikowana pod publicznym URL
- [ ] Link dodany w Google Play Console
- [x] Link dodany w ustawieniach gry

Public URL: https://gist.github.com/artuq/24733cc4575012af3ec41bf53d2088cb

## Zależności
- ISSUE-05 (konto Google Play)
