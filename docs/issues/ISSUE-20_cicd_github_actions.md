# ISSUE-20: CI/CD — automatyczny build i deploy na Google Play

**Priorytet:** 🟢 NISKI  
**Kategoria:** DevOps / Automatyzacja  
**Szacowany czas:** 4-5h  
**Najlepszy model AI:** Codex 5.3 (GitHub Actions YAML) + Claude Sonnet 4.6 (Godot CLI + Google Play API)

## Opis
Zautomatyzować budowanie AAB i uploading na Google Play za pomocą GitHub Actions. Pozwoli to na szybsze iteracje podczas beta testów.

## Zadania
1. Utworzyć GitHub Actions workflow `.github/workflows/build-android.yml`:
   ```yaml
   on:
     push:
       tags: ['v*']
   jobs:
     build:
       runs-on: ubuntu-latest
       steps:
         - Checkout repo
         - Setup Godot 4.6 headless
         - Setup Android SDK + JDK
         - Import project
         - Export AAB (signed)
         - Upload to Google Play (closed beta) via fastlane/google-play-api
   ```
2. Skonfigurować secrety w GitHub:
   - `KEYSTORE_BASE64` — keystore zakodowany w base64
   - `KEYSTORE_PASSWORD`
   - `GOOGLE_PLAY_JSON_KEY` — service account key
3. Skonfigurować Google Play API service account
4. Dodać `fastlane` lub `google-play-publisher` CLI
5. Testować pipeline na tagach (push tag → auto build → auto upload)

## Pliki do utworzenia
- `.github/workflows/build-android.yml`
- `fastlane/Fastfile` (opcjonalnie)

## Kryteria akceptacji
- [ ] Push tag `v*` → automatyczny build AAB
- [ ] AAB uploadowany na Closed Beta track
- [ ] Secrety bezpieczne (nie w repo)
- [ ] Pipeline przechodzi w < 15 min

## Zależności
- ISSUE-06 (keystore)
- ISSUE-09 (closed beta track)
