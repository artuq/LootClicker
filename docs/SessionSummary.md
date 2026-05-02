# Status projektu — 2026-05-02 (Zamknięte Testy Alfa Google Play)

## Kontekst

Gra LootClicker (wewnętrzna nazwa: *Joana Indiana*) osiągnęła etap **zamkniętych testów alfa na Google Play**. To kulminacja dwóch miesięcy pracy od zera — autor projektu nie miał wcześniej żadnego doświadczenia ani z programowaniem, ani z tworzeniem gier.

Projekt powstał jako eksperyment z modelami AI, agentami AI i umiejętnościami AI w praktyce. Cały kod, debugowanie i wdrożenie były realizowane z pomocą **GitHub Copilot w VS Code**. W ciągu dwóch miesięcy zbudowano działającą grę mobilną, która trafiła na sklep Google Play.

## Aktualny stan techniczny

- **Wersja:** `0.6.3` (version code `31`)
- **Dystrybucja:** AAB — Google Play Closed Alpha
- **Ostatni fix:** `df7504a` — przywrócenie modułu `assetPackInstallTime` w AAB Play Asset Delivery (bundlowanie PCK)
- **Keystore:** upload key `upload-2026-03-08.jks` aktywny w Google Play Console
- **AdMob:** fallback Fake Ads aktywny (konto AdMob w trakcie weryfikacji przez Google)

## Co zostało zrobione (cały projekt)

### Wersje v0.1–v0.2 (luty 2026)
- Core loop: klikanie wroga, obrażenia, złoto, loot, przejście do następnego etapu
- Drzewko umiejętności (STR/HP/SPD/CRIT), maks. poziom 50
- System kart level-up z przeklętymi kartami i flavor textami w języku angielskim
- 6 unikalnych wrogów w 2 biomach (Dżungla, Świątynia), 3 unikalne bossy
- Mechanika Adrenaline (50 kliknięć → x2 DMG)
- Soft Landing scaling po Stage 30 (liniowy wzrost trudności zamiast wykładniczego)
- AdMob integracja + fallback Fake Ads

### Wersje v0.3–v0.4 (luty–marzec 2026)
- Game feel polish: hit juice, squash & stretch, crit pause, boss death spectacle
- Floating combat text z parabolicznymi łukami
- System kolejki powiadomień (notification queue)
- Bottom Nav UX (przełączanie Inventory/Stats/Skills)
- Eksport Android stabilny: AAB + APK debug

### Testy wewnętrzne + bugfixes (marzec 2026) — łącznie 17 naprawionych błędów
- Scene transition bleedthrough — płynne fade-in przy starcie walki
- Privacy Policy — poprawny URL (htmlpreview.github.io)
- Skill Tree — tooltip przeniesiony na górę, BackButton powiększony
- Inventory — naprawiony martwy kod, dodany empty state
- Settings overlay — poprawiony z-order (layer 150)
- Boss UI — naprawiony z-fighting etykiet
- Card Choice — większe karty, większy tekst
- Toast — przeniesiony na górę ekranu (brak kolizji z nawigacją)
- AAB bundle — przywrócony moduł `assetPackInstallTime` dla Play Asset Delivery

## Znane ograniczenia / TODO

- `hand_cursor.png` (16×16) — wymaga wymiany na mobilną ikonę palca (pixel art 32×32)
- Spójność artystyczna: TitleScreen (anime, Joana) vs. gameplay (pixel-art) — wymaga decyzji o kierunku art
- AdMob: czekamy na zatwierdzenie konta przez Google
- Privacy Policy: wymaga publicznego repo na GitHubie (htmlpreview.github.io)

---

# Session Summary – 2026-03-19 (Round 2: Game Feel & Polish – 8 Fixes)

## Context
Druga runda poprawek po testach na fizycznym telefonie. Fokus na game feel (juice), czytelnosc UI, i spectacle przy bossach. Wszystkie zmiany udokumentowane do latwego rollbacku.

## Zmiany techniczne

### 1. STATS tab – clipping mask (`node_2d.tscn`) [HIGH]
- **Problem:** Tekst w panelu Stats wyjeżdżał poza ramkę ScrollContainer.
- **Fix:** Dodano `clip_contents = true` do ScrollContainer "Stats" w BottomNavLayer.

### 2. Skill Tree – tooltip przeniesiony na górę (`SkillTreeScene.tscn`) [HIGH]
- **Problem:** TooltipBG (anchor bottom) najeżdżał na BackButton.
- **Fix:** Tooltip przeanchored na **górę** TreePanel (`anchor_top=0`, `offset_top=4`, `offset_bottom=62`). BackButton pozostaje na dole bez konfliktu.

### 3. Cursed card – lepszy kontrast tekstu (`CardChoiceScene.gd`) [MEDIUM]
- **Problem:** Ciemny czerwony tekst na ciemnym tle karty cursed był nieczytelny.
- **Fix:**
  - Tag "CURSED": Color(1.0, 0.35, 0.35) — jasny czerwony
  - Nazwa: Color(1.0, 0.65, 0.5) — ciepły pomarańczowo-różowy
  - Opis: LabelSettings z kolorem (1.0, 0.82, 0.78) + outline 2px ciemny czerwony
  - Statystyki: LabelSettings z kolorem (1.0, 0.5, 0.45) + outline 2px

### 4. Boss z-fighting – ukrycie nameplate przy greeting (`GameBattleManager.gd`) [LOW]
- **Problem:** EnemyFloatName nakładał się na boss greeting overlay.
- **Fix:** `_show_boss_greeting()` teraz ukrywa `enemy_nameplate_label` na czas animacji i przywraca po zakończeniu.

### 5. Notification queue system (`GameBattleManager.gd`) [MEDIUM]
- **Problem:** Wielu powiadomień (ad failed, poison, etc.) nadpisywało InfoLabel jednocześnie.
- **Fix:** Nowy system kolejki:
  - `_queue_notification(message, color, duration)` — dodaje do kolejki
  - `_process_notification_queue()` — przetwarza po kolei z fade-in/hold/fade-out
  - Po wyczerpaniu kolejki przywraca domyślny tekst InfoLabel via `_update_info_label()`
  - Ad failure message przepięty na system kolejki

### 6. Hit juice – ulepszony feedback (`GameBattleManager.gd`) [HIGH]
- **Problem:** Uderzenia wyglądały płasko, brakowało "pauzy" przy critach.
- **Fix:**
  - **Flash:** Overbright 12x dla critów (vs 8x normalne), dłuższy czas (0.15s vs 0.08s)
  - **Hit Pause:** Crit zamraża grę na 0.04s (`get_tree().paused = true` z tween na `TWEEN_PAUSE_PROCESS`)
  - **Squash & Stretch:** Prawdziwy squash (0.7x szerokość + 1.25x wysokość dla critów), elastic ease-out
  - **Shake:** Zwiększony z 15→18 (crit) / 5→6 (normal)

### 7. Floating combat text – krzywe paraboliczne (`damage_label.gd`) [MEDIUM]
- **Problem:** Tekst leciał prosto w górę, nudno.
- **Fix:** Kompletna przebudowa animacji:
  - **Normalne** uderzenia: łagodny łuk (random lewo/prawo), drift 15-35px, ease-out w górę, fade po 0.3s delay
  - **Crit** uderzenia: szeroki łuk (40-70px), parabola z grawitacją (góra→dół), skala 1.6x, orange kolor, scale punch elastic
  - Dodano property `_is_crit: bool` — ustawiany przez `_spawn_floating_text()` z parametrem `is_crit`
  - `_spawn_floating_text()` rozszerzone o opcjonalny `is_crit` parameter

### 8. Boss death spectacle (`GameBattleManager.gd`) [MEDIUM]
- **Problem:** Boss umiera tak samo jak zwykły mob — nijak.
- **Fix:** `_play_boss_death_spectacle()` wywoływany przy boss kill (`stage % 5 == 0`):
  - **Heavy shake:** intensity 30 + vibration 200ms
  - **Slow motion:** `Engine.time_scale = 0.3` przez 1.2s (real-time ~0.36s), smooth return to 1.0
  - **White flash:** CanvasLayer(95) z białym ColorRect, fade-out 0.5s
  - **Gold particle burst:** 12 label-particles ($, ★, ✦, ♦, ●) w losowych kolorach Gold/Yellow, rozlatujących się parabolicznie od enemy_sprite, z rotacją i fade-out
  - **Enemy death anim:** Scale punch (1.3x → 0.0x) z TRANS_BACK + fade-out

## Pliki zmodyfikowane
- `src/scenes/GameBattleManager.gd` — hit juice, boss spectacle, notification queue, boss greeting fix
- `src/scenes/damage_label.gd` — parabolic floating text, crit detection
- `src/scenes/CardChoiceScene.gd` — cursed card text contrast + outlines
- `src/scenes/node_2d.tscn` — Stats ScrollContainer clip_contents
- `src/scenes/SkillTreeScene.tscn` — TooltipBG moved to top

## Rollback
Wszystkie zmiany są odwracalne:
- **Stats clipping:** Usuń linię `clip_contents = true` w node_2d.tscn
- **Tooltip position:** Przywróć anchors w SkillTreeScene.tscn (anchor_top=1.0, anchor_bottom=1.0, offset_top=-62, offset_bottom=-4)
- **Card colors:** Przywróć oryginalne Color() values (1.0,0.3,0.3 / 1.0,0.5,0.5 / 1.0,0.7,0.7 / 0.9,0.3,0.3)
- **Boss greeting:** Usuń enemy_nameplate_label.visible toggle w _show_boss_greeting()
- **Notification queue:** Usuń zmienne _notification_*, funkcje _queue_notification/_process_notification_queue, przywróć bezpośredni info_label.text =
- **Hit juice:** Przywróć oryginalny _play_hit_effect (shake 15/5, modulate Color(10,10,10), scale * 0.8)
- **Floating text:** Przywróć oryginalny damage_label.gd (linear tween y-80, scale 1.2)
- **Boss spectacle:** Usuń _play_boss_death_spectacle() i wywołanie w _on_enemy_died()

---

# Session Summary – 2026-03-19 (Internal Test Feedback: 9 Bugfixes)

## Context
Gra wyslana do testow wewnetrznych. Zebrano uwagi z nagrania wideo + zgloszen od testera (kolega). Wszystkie poprawki wdrozone w jednej sesji.

## Najwazniejsza informacja dla testera: Inventory puste
Przypadek: Panel INVENTORY otwiera sie, ale jest pusty (brak slotow). Przyczyna: kod wyswietlania equipment (`for item in player.inventory`) znajdowal sie wewnatrz `_get_resource_icon()` PO instrukcji `return`, czyli nigdy sie nie wykonywal. Blad nie wplywal na renderowanie zasobow, wiec u osob ze zdobytymi zasobami (bandages/venom) dzialal. U gracza na samym poczatku (0 zasobow, 0 equipment) panel byl pusty. **Naprawione.**

## Zmiany techniczne

### 1. Scene transition bleedthrough po "Continue" (`GameBattleManager.gd`)
- **Problem:** TitleScreen znika nagle, nakladajac sie na scene walki ("podwojny ekran").
- **Fix:** Na poczatku `_ready()` dodano `CanvasLayer(200)` z czarnym `ColorRect` (alpha=1), ktory tweenuje do alpha=0 w 0.35s, a nastepnie sie usuwa. Kazda sesja walki startuje od czarnego ekranu, ktory plynnie zanika.

### 2. Privacy Policy wyswietla surowy HTML (`SettingsScene.gd`)
- **Problem:** URL wskazywal na GitHub Gist, ktory zwraca HTML jako tekst.
- **Fix:** URL zmieniony na `https://htmlpreview.github.io/?https://github.com/artuq/LootClicker/blob/main/docs/privacy-policy.html`.
- **Warunek:** Wymaga publicznego repo na GitHubie.

### 3. Skill Tree – tekst nachodzi na tekst (`SkillNode.gd`, `SkillTreeScene.gd`, `SkillTreeScene.tscn`)
- **Problem:** Label "Need: STR Lv.1" najechal na "Cost: 10B" po tym samym area. Przyciski za male i za nisko.
- **Fix:**
  - Zablokowane nody sa teraz **klikalne** zamiast `disabled`; label "Need:" jest ukryty.
  - Po tapnieciu zablokowanego noda tooltip pokazuje `"⚠ Needs STR Lv.1 to unlock"`.
  - Zakup zabezpieczony przed proba kupna zablokowanej umiejetnosci.
  - `BackButton`: szerokosc 200→220px, wysokosc 40→52px, font 15→17px, podniesiony 10px wyzej.

### 4. Inventory – pusty panel (`GameBattleManager.gd`)
- **Problem:** Kod equipment byl martwym kodem (po `return` w innej funkcji); brak empty state.
- **Fix:** Przebudowana `_update_inventory_ui()`: equipment renderuje sie poprawnie, jesli `slots_added == 0` wyswietla sie Label `"No items yet.\nKill enemies to collect resources."`.

### 5. Settings overlay – zly z-order (`GameBattleManager.gd`)
- **Problem:** Settings dodawany do `%CanvasLayer(layer=10)` chowa sie pod `BottomNavLayer(layer=110)`.
- **Fix:** Settings montowany na dedykowanym `CanvasLayer(layer=150)`, automatycznie zwalnianym po zamknieciu przez `tree_exited`.

### 6. Boss UI – z-fighting etykiet (`node_2d.tscn`)
- **Problem:** `EnemyFloatingUI.offset_top = 120` powodowal nakladanie nameplate na TopHUD z "Jungle BOSS".
- **Fix:** `offset_top` zmieniony z `120` na `140`; `offset_bottom` odpowiednio z `182` na `202`.

### 7. Card Choice – wąskie karty, maly tekst (`CardChoiceScene.gd`, `CardChoiceScene.tscn`)
- Szerokosc karty: 108→118px, wysokosc: 168→178px.
- Opis (flavor): font 10→11px.
- Statystyki: font 8→10px.
- Kontener kart: szerokosc 350px→400px.

### 8. Toast na dole zaslanial nawigacje (`GameBattleManager.gd`)
- **Problem:** Default pozycja = `view.y - 88` (dolna strefa).
- **Fix:** Pozycja zmieniona na `target_y = 60.0` (gora ekranu, bezkolizyjne).

### 9. Tutorial cursor – oznaczony do wymiany (`GameBattleManager.gd`)
- `hand_cursor.png` to plik 16×16 — nie wiadomo czy to palec czy mysz PC (wymaga weryfikacji w edytorze graficznym).
- Dodany komentarz `TODO` przy stale `TUTORIAL_HAND_TEXTURE`. Wymaga wymiany assetu na mobilna ikone palca.

## Poza zakresem kodu
- **Spójnosc stylu artystycznego** (anime Joana vs. pixel-art gameplay) — decyzja art direction, wymaga nowego assetu postaci w pixel-arcie.

## Pliki zmodyfikowane
- `src/scenes/GameBattleManager.gd`
- `src/scenes/SettingsScene.gd`
- `src/scripts/SkillNode.gd`
- `src/scenes/SkillTreeScene.gd`
- `src/scenes/SkillTreeScene.tscn`
- `src/scenes/node_2d.tscn`
- `src/scenes/CardChoiceScene.gd`
- `src/scenes/CardChoiceScene.tscn`

---


## Achievements
1. **Bottom Nav UX Fix:** Naprawiono niedzialajace przyciski `INVENTORY` / `STATS` (bledne sciezki node'ow po refaktorze).
2. **Juice Animations:** Dodano satysfakcjonujace animacje przy kliknieciu zakladek:
   - bounce/pulse przycisku,
   - highlight aktywnego taba,
   - slide + fade przy przelaczaniu tresci.
3. **Layering Fix:** Panel dolnej nawigacji przeniesiono na oddzielny `CanvasLayer` (`BottomNavLayer`, layer 110), aby animacje nie chowaly sie pod `VictoryUI`.
4. **Android Build + Deploy:**
   - wygenerowano nowe artefakty Android,
   - podpisano `AAB` lokalnym upload key,
   - zainstalowano najnowszy `APK` na fizycznym telefonie przez `adb`.

## Artifacts (2026-03-07)
- `build/LootClicker-debug-2026-03-07.apk`
- `build/LootClicker-release-2026-03-07.apk`
- `build/LootClicker-release-2026-03-07.aab`
- `build/LootClicker-release-2026-03-07-signed.aab`

## Device Deployment
- Device: `RFCY70WHP1H`
- Command: `adb install -r build/LootClicker-debug-2026-03-07.apk`
- Result: `Success`

---

# Session Summary - 2026-03-07

## Achievements
1. **Background Rollback (Combat Style):** Wycofano parallax z aktywnej sceny walki na rzecz statycznych teł `JUNGLE` i `TEMPLE`, zgodnie z decyzja UX (mniej ruchu, czytelniejszy ekran walki).
2. **Scene + Logic Cleanup:**
   - `src/scenes/node_2d.tscn` uproszczone do statycznych `TextureRect` dla obu biomow.
   - `src/scenes/GameBattleManager.gd` przepisane tak, aby obslugiwalo tylko statyczne tla i proste przelaczanie biomow.
   - Usunieto pozostalosci kodu parallax (scroll, helpery, stale node referencje).
3. **Stability Validation:** Potwierdzono brak bledow parsera i poprawny export Android po zmianach (`EXIT: 0`).

## Technical Changes
- `src/scenes/node_2d.tscn`: usuniete node'y `ParallaxBackground`/`ParallaxLayer`, przywrocone klasyczne `Jungle.jpeg` i `Temple.jpeg`.
- `src/scenes/GameBattleManager.gd`: uproszczone `_fix_parallax_sizes`, `_update_biome_bg`, `_process` pod statyczne tlo.
- `assets/sprites/parallax/`: usuniety katalog po rollbacku.

## Project Status
- **Active Visual Direction:** statyczne tlo walki (bez parallax).
- **Android Export:** stabilny hotfix `0.4.1-hotfix` (`version/code=4`, `use_gradle_build=false`).
- **Next Focus:** porzadkowanie dokumentacji issues i dalsze UX polish bez przywracania ruchomego tla walki.

---

# Session Summary - 2026-02-18

## 🎯 Achievements
1. **AdMob Strategy:** Switched to a robust **Fake Ads** system using Tweens. This bypasses Google's current "Account not approved" (Error 3) and "No fill" issues, allowing development to proceed.
2. **Game Balance:** 
   - Implemented a **Stage 25+ Nerf**. Enemy HP scaling reduced by 15% and Damage scaling by 20% after Stage 25.
   - **Buffed Gold Drop:** Increased base gold (8→12) and scaling (1.1→1.15).
   - **Expanded Skill Tree:** Increased max skill level from 10 to **50**.
   - **Skill Tier Bonuses:** Rewarded specialization (e.g., Level 41+ STR gives +5 DMG instead of +1).
   - **Adrenaline Mechanic:** Added active combat buff (50 clicks -> 5s of Double Damage).
   - **Soft Landing Scaling:** Switched from exponential to linear scaling after Stage 30 to keep late-game challenge fair.
3. **Bug Fixes:** 
   - Resolved **Negative HP display** bug in `Enemy.gd`.
   - Fixed **HP Potion button** getting stuck (now reactive via `health_changed` signal).
   - Fixed **Fake Ad timer** hanging (switched from Timer node to SceneTreeTween).
4. **Inventory Integrity:** Reverted unauthorized random item generation. Cleaned inventory of "junk" items (cogs/gears) to restore original design.

## 🛠 Technical Changes
- `GameBattleManager.gd`: Modified `spawn_enemy` scaling, updated `_init_admob` and `_show_fake_ad`, added inventory cleanup on death.
- `Enemy.gd`: Added `max(0, ...)` to `take_damage` and fixed signal parameters.

## 📈 Project Status
- **Version:** v0.2.1 (Internal Dev)
- **Completion:** ~68%
- **Next Focus:** Action Bar UI (#11) and Flavorful Descriptions (#16).

---
# Session Summary - 2026-02-20

## 🎯 Achievements
1. **Framework Adaptation (CLAUDE.md):** 
   - Agreed to follow the 3-layer architecture for project consistency, but swapped the "Python Execution" layer for **PowerShell/Godot CLI** to better suit game development.
   - Established the **Detailed Logbook Protocol**: I will automatically summarize our discussions and technical decisions in this file to preserve context across sessions.
2. **UI & Android Fixes:** 
   - Fixed the Fake Ad positioning by anchoring it symmetrically inside the main `%CanvasLayer` (`GROW_DIRECTION_BOTH`) instead of a broken separate `CanvasLayer`.
   - Reverted from `TextureButton` back to `Button` for upgrade cards due to Android crashing when styling `normal` states. Instead, overrode ALL states (normal, hover, pressed, focus, disabled) with `StyleBoxEmpty` to eliminate the default gray GUI backgrounds entirely.
   - Fixed a layout issue where buttons in the HBoxContainer became staggered stairs. Enforced uniform physical card heights by changing `btn.size_flags_vertical` to `Control.SIZE_SHRINK_BEGIN` and setting `lbl.custom_minimum_size = Vector2(90, 35)` so single-line descriptions occupy the exact same space as multi-line ones.
3. **Bug Fixes:**
   - Resolved a critical GDScript parser error (`ad_layer` undefined variable) in `GameBattleManager.gd` that silently broke Android deployments.
   - Resolved a strict type mismatch in `CardChoiceScene.gd` (`func create_card(...) -> TextureButton:` vs `Button:`) which initially caused crashes on Android startup.

## 🛠 Technical Changes
- `GameBattleManager.gd`: Modified `_show_fake_ad()` to attach to `%CanvasLayer` and removed faulty tween cleanup.
- `CardChoiceScene.gd`: Changed card base back to `Button`, cleared all StyleBoxes, forced description labels to 35px min-height, and set `SIZE_SHRINK_BEGIN`.
- `.gemini_session_checkpoint.json`: Integrated as our primary state-saver for rapid context restoration.

## 📈 Project Status
- **Next Focus:** Moving on to Action Bar UI (#11) and Flavorful Descriptions (#16) now that the Android crash and layout rendering issues are fully resolved.

---
# Session Summary - 2026-02-23

## 🎯 Achievements
1. **Tutorial UI Fix:** Resolved the issue where tutorial text icons disappeared on Android devices. Replaced the static TTF font with Godot's native `SystemFont`, leveraging Android's built-in emoji fonts (like "Noto Color Emoji") to render standard emojis correctly without bloating the APK.
2. **Flavorful Descriptions (#16):** Implemented the "Solver First" humorous flavor texts for all upgrade and cursed cards.
   - Introduced the English parody style (Indiana Jones/Hot Shots vibe) to match the v0.2 MVP constraints.
   - Restructured the UI in `CardChoiceScene` to show `flavor_name`, `flavor_desc` prominently, while keeping the raw data in a `stat_short` field down below in brackets.
3. **Action Bar UI (#11):** Verified that the Action Bar feature, including enemy shadow and white damage flash, was already fully merged into `GameBattleManager.gd`.
4. **Draft Release (APK):** Used Godot 4.6 headless export to build a new Android APK (`LootClicker.apk`) and pushed it to GitHub as a pre-release Draft (v0.2.0-beta).

## 🛠 Technical Changes
- `UpgradeManager.gd`: Modified the dictionary lists to include detailed `flavor_name`, `flavor_desc`, and `stat_short` instead of simple static text.
- `GameBattleManager.gd`: Rewrote the `_show_tutorial()` screen's Label definitions to employ `SystemFont`.
- `CardChoiceScene.gd`: Redesigned dynamically spawned card texts to utilize the new flavor structure.

## 📈 Project Status
- **Next Focus:** Apply flavor texts to the permanent skill tree/shop (`UpgradeScreen`) and verify balance of the final boss (Stage 50).