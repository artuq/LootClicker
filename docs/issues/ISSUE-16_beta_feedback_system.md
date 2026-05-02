# ISSUE-16: System feedbacku i raportów od beta testerów

**Priorytet:** 🟡 ŚREDNI  
**Kategoria:** QA / Beta  
**Szacowany czas:** 2h  
**Najlepszy model AI:** Codex 5.3 (szybkie tworzenie formularza + integracja)

## Opis
Beta testerzy potrzebują łatwego sposobu na zgłaszanie błędów i sugestii. Dodać in-game feedback button lub link do Google Form.

## Zadania
1. Utworzyć Google Form z polami:
   - Opis problemu (tekst)
   - Typ: Bug / Sugestia / Crash
   - Stage na którym wystąpił
   - Urządzenie (auto-fill jeśli możliwe)
2. Dodać przycisk "Report Bug" w SettingsScene
3. Otwierać formularz w przeglądarce: `OS.shell_open(url)`
4. Opcjonalnie: dodać automatyczny crash reporter (logcat → email)

## Pliki do edycji
- `src/scenes/SettingsScene.gd` — przycisk feedback
- `src/scenes/SettingsScene.tscn` — layout

## Kryteria akceptacji
- [ ] Przycisk "Report Bug" w ustawieniach
- [ ] Google Form z odpowiednimi polami
- [ ] Link otwiera się na Android

## Zależności
- ISSUE-09 (beta testy uruchomione)
