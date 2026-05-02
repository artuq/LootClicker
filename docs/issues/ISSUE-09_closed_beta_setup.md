# ISSUE-09: Konfiguracja Closed Beta Testing na Google Play

**Priorytet:** 🔴 KRYTYCZNY  
**Kategoria:** Release / Beta  
**Szacowany czas:** 1h (ręcznie)  
**Najlepszy model AI:** ❌ Ręczne — konfiguracja w konsoli Google Play

## Opis
Skonfigurować zamknięte beta testy w Google Play Console, aby wybrani użytkownicy mogli testować grę.

## Zadania (ręczne w Google Play Console)
1. Przejść do Release > Testing > Closed testing
2. Utworzyć nowy track "Closed Beta"
3. Dodać listę testerów (emaile Google):
   - Utworzyć Google Group lub dodać emaile ręcznie
   - Max. 100 testerów na zamkniętą betę
4. Upload AAB z ISSUE-06
5. Wypełnić release notes (po polsku i angielsku)
6. Przesłać do review
7. Po zatwierdzeniu — wysłać link do testerów:
   `https://play.google.com/apps/testing/com.lootclicker.joanna`

## Kryteria akceptacji
- [ ] Closed beta track utworzony
- [ ] AAB uploadowany
- [ ] Min. 5 testerów dodanych
- [ ] Release notes wypełnione
- [ ] Link testowy wysłany do testerów

## Zależności
- ISSUE-05 (konto Google Play)
- ISSUE-06 (AAB build)
- ISSUE-07 (privacy policy)
- ISSUE-08 (grafiki store)
