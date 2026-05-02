# ISSUE-06: Generowanie klucza podpisu i build AAB (Android App Bundle)

**Priorytet:** 🔴 KRYTYCZNY  
**Kategoria:** Release / Build  
**Szacowany czas:** 2-3h  
**Najlepszy model AI:** Claude Sonnet 4.6 (konfiguracja Godot export, Gradle, keystore)

## Opis
Google Play wymaga AAB (nie APK). Trzeba wygenerować keystore do podpisu i skonfigurować Godot export.

## Zadania
1. Wygenerować release keystore:
   ```bash
   keytool -genkey -v -keystore lootclicker-release.keystore -alias lootclicker -keyalg RSA -keysize 2048 -validity 10000
   ```
2. Zapisać hasło do keystore w bezpiecznym miejscu (NIE w repo!)
3. Skonfigurować `export_presets.cfg` dla Android:
   - `keystore/release` → ścieżka do keystore
   - `keystore/release_user` → alias
   - `keystore/release_password` → hasło
   - `gradle_build/use_gradle_build = true`
   - `gradle_build/export_format = 1` (AAB)
4. Ustawić `version/code` i `version/name` w export presets
5. Zbudować AAB: `godot --headless --export-release "Android" lootclicker.aab`
6. Przetestować AAB przez `bundletool` lokalnie

## Pliki do edycji
- `export_presets.cfg` — sekcja Android
- `.gitignore` — dodać `*.keystore`, `*.aab`

## Kryteria akceptacji
- [x] Keystore wygenerowany
- [x] AAB build przechodzi bez błędów
- [x] AAB podpisany release key
- [x] Keystore NIE jest w repozytorium

## Update 2026-03-07
- Wygenerowano upload key lokalnie: `secrets/play-upload-2026.jks` (alias: `lootclicker_upload`).
- Z uwagi na niestabilnosc podpisu release w headless Godot dla tego projektu, zastosowano workflow:
   1. export `AAB`,
   2. podpis `AAB` narzedziem `jarsigner`.
- Potwierdzenie podpisu: `jar verified` (`jarsigner -verify`, exit code 0).
- Gotowy plik do Play Console tests: `build/LootClicker-release-2026-03-07-signed.aab`.

## Klucz kanoniczny (od 2026-03-07)
- Keystore: `secrets/play-upload-2026.jks`
- Alias: `lootclicker_upload`
- Owner: `CN=Loot Clicker, OU=Dev, O=LootClicker, L=Warsaw, ST=Mazowieckie, C=PL`
- SHA1: `E0:70:F5:F4:6C:07:29:55:BA:FA:D4:27:64:E8:A0:9E:7C:1B:D3:05`
- SHA256: `46:F6:26:45:E9:EE:9C:EF:AD:E9:C6:53:BB:FE:CA:E3:6E:60:B4:2E:D1:C9:C5:FC:A3:AD:C4:F2:93:D6:5E:8A`

## Workflow bez pomylki klucza
1. Ustaw `package/signed=false` w `export_presets.cfg`.
2. Eksportuj surowy plik: `build/LootClicker-vX-unsigned.aab`.
3. Podpisz recznie:
   `jarsigner -sigalg SHA256withRSA -digestalg SHA-256 -signedjar build/LootClicker-FINAL-vX-UPLOAD.aab build/LootClicker-vX-unsigned.aab -keystore secrets/play-upload-2026.jks -storepass <HASLO> lootclicker_upload`
4. Zweryfikuj fingerprint:
   `keytool -printcert -jarfile build/LootClicker-FINAL-vX-UPLOAD.aab`
5. Akceptuj tylko pliki, ktore maja SHA1 `E0:70:F5:F4:6C:07:29:55:BA:FA:D4:27:64:E8:A0:9E:7C:1B:D3:05`.

## Ostatni gotowy artefakt
- `build/LootClicker-FINAL-v6-UPLOAD.aab`
- `version/code=6`

## Update 2026-03-07 (runtime fix)
- Objaw po instalacji z Play: `Couldn't load project data at path '/'. Is the .pck file missing?`
- Przyczyna: build bez `assetPackInstallTime` pomijal dane gry (`assets.sparsepck`), przez co aplikacja startowala bez zasobow.
- Poprawka: przywrocono `include ':assetPackInstallTime'` oraz `assetPacks = [":assetPackInstallTime"]` w `android/build` i dodano brakujacy `android/build/assetPackInstallTime/build.gradle`.
- Nowy artefakt po poprawce runtime: `build/LootClicker2-FINAL-v7-UPLOAD.aab` (`version/code=7`, package `com.artuq.lootclicker2`).

## Update 2026-03-07 (provider authority conflict)
- Objaw przy uploadzie: konflikt `com.godot.game.fileprovider`.
- Przyczyna: build Gradle bez parametru `-Pexport_package_name` fallbackowal do domyslnego `com.godot.game`.
- Poprawka: build wykonany z jawnym parametrem `-Pexport_package_name=com.artuq.lootclicker2`.
- Finalny artefakt do uploadu: `build/LootClicker2-FINAL-v8-UPLOAD.aab` (`versionCode=8`).

## Zależności
- Brak

## Update 2026-03-07 (fatal gradle hacks removed)
- Objaw w v8 po instalacji: Nadal brak powiazania .pck (!)
- Przyczyna: Poprzedni build v8 korzystal z czystego gradle omijajac system eksportu zasobow w Godot, co spakowalo cale repozytorium zamiast wymaganych plikow sparsepck i wygenerowalo baze bez poprawnego PAD.
- Poprawka: Usunieto manualne hacki 'assetPackInstallTime' w build.gradle agenta. Uzyto standardowego eksportu headless Godot, ktory bezblednie wygenerowal i osadzil Play Asset Delivery.
- Finalny plik: uild/LootClicker2-FINAL-v10-UPLOAD.aab (ersionCode=9).
