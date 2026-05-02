# LootClicker — Roadmap Issues (v0.4.1-hotfix)

> Zaktualizowano: 7 marca 2026  
> Cel: Closed Beta na Google Play z prawdziwymi reklamami AdMob

---

## Nowe prompty Senior (2026-03-07)

- [ISSUE-23: Satysfakcja z wyboru karty (Juice & Feedback)](issues/ISSUE-23_card_choice_juice_feedback.md)
- [ISSUE-24: Optymalizacja Drzewka Umiejetnosci (Mobile UX)](issues/ISSUE-24_skill_tree_mobile_ux_and_purchase_feedback.md)
- [ISSUE-25: Czyszczenie ekranu i nakladanie warstw (UI Polish)](issues/ISSUE-25_ui_layer_cleanup_and_toast_positioning.md)

Te zadania sa Android-first i sa gotowe do bezposredniej implementacji.

---

## UI/Flow Hotfix Pack (2026-03-07)

Cel: naprawa hierarchii wizualnej, czytelności UI mobilnego i płynności core loop po ekranie level-up.

### Task 1: Rollback parallax do statycznych teł
- Problem: ruchome warstwy tla nie pasowaly do docelowego stylu walki i wprowadzaly niepotrzebny szum wizualny.
- Wdrozone:
- Usuniety `ParallaxBackground` i `ParallaxLayer` z aktywnej sceny walki.
- Przywrocone statyczne biome tlo: `Jungle.jpeg` i `Temple.jpeg`.
- Usunieta logika scrollowania i pomocnicze funkcje parallax z managera walki.
- Status: `DONE (2026-03-07)`.

### Task 2: Layering level-up overlay
- Problem: przy level-up znika kontekst walki pod UI.
- Wdrozone:
- Overlay reward i victory utrzymuje widoczne tlo pod spodem (bez wylaczania calej sceny gry).
- Dodany refresh biome/parallax przy wejsciu w overlay i przy powrocie do combat.
- HUD `CanvasLayer` ustawiony na wyzsza warstwe (`layer = 10`), aby UI zawsze bylo nad swiatem.
- Pliki:
- `src/scenes/GameBattleManager.gd`
- `src/scenes/node_2d.tscn`

### Task 3: Core loop po wyborze karty
- Problem: twarde ciecie do popupu podsumowania po standardowym level-up.
- Wdrozone:
- Po wyborze karty gra wraca od razu do petli: reward -> next stage -> combat.
- Usuniete wymuszanie ekranu podsumowania po standardowym awansie.
- Dodany staly przycisk `UP` (min. 44x44) w glownym HUD, otwierajacy upgrades takze podczas walki.
- Pliki:
- `src/scenes/GameBattleManager.gd`
- `src/scenes/node_2d.tscn`

### Task 4: Visual UI cleanup
- Problem: nakladanie floating textow i agresywny komunikat `AD NOT READY`.
- Wdrozone:
- Czyszczenie floating textow przy wejsciu na reward popup (queue_free aktywnych napisow).
- Dodany rozrzut i stack offset dla burstow floating text, zeby ograniczyc nakladanie.
- `AD NOT READY` zmienione na dolny toast (auto-hide po 2s), zamiast duzego napisu na srodku.
- Plik:
- `src/scenes/GameBattleManager.gd`

### Szybka checklista QA po deploy
- [X] Stage <= 14: widoczne statyczne tlo Jungle.
- [X] Stage >= 15: widoczne statyczne tlo Temple.
- [X] Brak ruchu parallax i brak migotania tla podczas walki.
- [X] Po wyborze karty: natychmiastowy powrot do walki na kolejnym stage.
- [X] `AD NOT READY` pojawia sie jako dolny toast i znika po ~2s.

---

## Kolejność wykonania (sugerowana)

### FAZA 1: Kod i balans (przed buildem)
| # | Issue | Priorytet | Model AI | Czas |
|---|-------|-----------|----------|------|
| 04 | [Loot/drop +20% od stage 1](issues/ISSUE-04_loot_drop_buff_stage35.md) ✅ | 🔴 KRYTYCZNY | **Claude Sonnet 4.6** | ✅ gotowe |
| 01 | [AdMob → produkcyjne reklamy](issues/ISSUE-01_admob_switch_to_production.md) ✅ | 🔴 KRYTYCZNY | **Claude Sonnet 4.6** | ✅ zrobione |
| 02 | [AdMob banner ads](issues/ISSUE-02_admob_banner_ads.md) ✅ | 🟡 ŚREDNI | **Claude Sonnet 4.6** | ✅ zrobione |
| 03 | [AdMob interstitial ads](issues/ISSUE-03_admob_interstitial_ads.md) ✅ | 🟡 ŚREDNI | **Codex 5.3** | ✅ zrobione |

> 🔨 **BUILD #1 — APK wewnętrzny (lokalny test)**
> Po ISSUE-03. Zbuduj APK (`gradle_build/export_format=0`), zainstaluj na telefonie przez ADB.
> Cel: potwierdzić że reklamy (rewarded + banner + interstitial) działają na prawdziwym urządzeniu przed wysłaniem do Google Play.
> Komenda: `godot --headless --export-debug "Android" build/LootClicker-test.apk`
> Wynik testu (2026-03-02): ✅ boss stage 50 pokonany, ❌ nadal widoczny ekran "FAKE AD" (naprawione w kodzie — wymagany retest APK).

### FAZA 2: Release pipeline (Google Play)
| # | Issue | Priorytet | Model AI | Czas |
|---|-------|-----------|----------|------|
| 05 | [Konto Google Play Developer](issues/ISSUE-05_google_play_developer_account.md) ✅ | 🔴 KRYTYCZNY | ❌ Ręcznie | ✅ gotowe |
| 07 | [Polityka prywatności](issues/ISSUE-07_privacy_policy.md) ✅ | 🔴 KRYTYCZNY | **Codex 5.3** | ✅ gotowe |
| 06 | [Signing key + AAB build](issues/ISSUE-06_signing_key_and_aab.md) ✅ | 🔴 KRYTYCZNY | **Claude Sonnet 4.6** | ✅ AAB gotowe |
| 08 | [Grafiki do store](issues/ISSUE-08_store_graphics.md) ✅ | 🔴 KRYTYCZNY | **Gemini 2.5 Pro** | ✅ gotowe (do poprawy później) |
| 10 | [Final build + test](issues/ISSUE-10_release_apk_aab_build.md) ✅ | 🔴 KRYTYCZNY | **Claude Sonnet 4.6** | ✅ zrobione |
| 09 | [Closed Beta setup](issues/ISSUE-09_closed_beta_setup.md) ✅ | 🔴 KRYTYCZNY | ❌ Ręcznie | ✅ zrobione |

> 🚀 **BUILD #2 — AAB produkcyjny → Google Play Closed Beta (v0.4.1-hotfix)**
> Po ISSUE-10, przed ISSUE-09. Zbuduj podpisany AAB (`export_format=1`), wgraj do Google Play Console → Closed testing.
> To jest pierwszy upload na sklep — testerzy beta otrzymują dostęp.
> Komenda: `godot --headless --export-release "Android" build/LootClicker.aab`

### FAZA 3: Poprawki graficzne
| # | Issue | Priorytet | Model AI | Czas |
|---|-------|-----------|----------|------|
| 11 | [Nowe sprite'y wrogów](issues/ISSUE-11_enemy_sprite_upgrade.md) ⏸️ | 🟡 ŚREDNI | **Gemini 2.5 Pro** + Claude | ⏸️ zawieszone |
| 12 | [Redesign UI walki](issues/ISSUE-12_ui_battle_redesign.md) ✅ | 🟡 ŚREDNI | **Claude Sonnet 4.6** | ✅ zamkniete |
| 13 | [Parallax tło](issues/ISSUE-13_parallax_background.md) ✅ | 🟢 NISKI | **Claude Sonnet 4.6** | ✅ zamkniete jako `DESCOPE` (powrot do statycznego tla) |
| 14 | [Animacje wrogów](issues/ISSUE-14_enemy_animations.md) ⏸️ | 🟡 ŚREDNI | **Codex 5.3** + **Gemini 2.5 Pro** | ⏸️ zawieszone |
| 15 | [Splash screen](issues/ISSUE-15_splash_screen.md) | 🟡 ŚREDNI | **Claude Sonnet 4.6** | 1-2h |
| 21 | [Skill Tree visual upgrade (hex redesign)](issues/ISSUE-21_skill_tree_visual_upgrade.md) ✅ | 🟡 ŚREDNI | **Claude Sonnet 4.6** | ✅ 2026-03-02 — hex grid, 2-tap, tooltip |

> ⏸️ **Status tymczasowy (2026-03-03):** ISSUE-11 i ISSUE-14 są zawieszone do odwołania.

> 🚀 **BUILD #3 — AAB → Google Play Closed Beta (v0.5.0-beta, grafiki)**
> Po ISSUE-21. Wgraj zaktualizowany AAB z nową grafiką na ten sam Closed Beta track (version/code +1).
> Testerzy automatycznie dostaną aktualizację przez sklep.

### FAZA 4: Polish i monitoring
| # | Issue | Priorytet | Model AI | Czas |
|---|-------|-----------|----------|------|
| 16 | [System feedbacku beta](issues/ISSUE-16_beta_feedback_system.md) | 🟡 ŚREDNI | **Codex 5.3** | 2h |
| 23 | [Juice feedback przy wyborze karty](issues/ISSUE-23_card_choice_juice_feedback.md) | 🟡 SREDNI | **Claude Sonnet 4.6** | 2-3h |
| 24 | [Skill Tree mobile UX + feedback zakupu](issues/ISSUE-24_skill_tree_mobile_ux_and_purchase_feedback.md) | 🟡 SREDNI | **Claude Sonnet 4.6** | 2-4h |
| 25 | [UI layer cleanup + toast positioning](issues/ISSUE-25_ui_layer_cleanup_and_toast_positioning.md) | 🔴 WYSOKI | **Claude Sonnet 4.6** | 2-3h |
| 17 | [Optymalizacja performance](issues/ISSUE-17_performance_optimization.md) | 🟡 ŚREDNI | **Claude Sonnet 4.6** | 3-4h |
| 18 | [Nowy biom: Desert](issues/ISSUE-18_desert_biome.md) | 🟢 NISKI | **Codex 5.3** + **Gemini 2.5 Pro** | 4-5h |
| 19 | [Firebase Analytics](issues/ISSUE-19_firebase_analytics.md) | 🟢 NISKI | **Codex 5.3** + Claude | 3h |
| 20 | [CI/CD GitHub Actions](issues/ISSUE-20_cicd_github_actions.md) | 🟢 NISKI | **Codex 5.3** | 4-5h |
| 22 | [Animacje UI i przejścia między scenami](issues/ISSUE-22_ui_transitions_and_animations.md) | 🟢 NISKI | **Claude Sonnet 4.6** | 2-3h |

> 🌍 **BUILD #4 — AAB → Google Play Open Beta / Produkcja (v1.0.0)**
> Po ISSUE-17 i ISSUE-19 (performance OK + analytics działa). Przesuń track z Closed Beta na Open Beta lub Production.
> Od tego momentu budowanie automatyzuje ISSUE-20 (CI/CD) — push taga = auto-upload.

---

## Podsumowanie modeli AI

| Model | Najlepszy do | Issues |
|-------|------------|--------|
| **Claude Sonnet 4.6** | Edycja GDScript, balans, konfiguracja Godot, profilowanie, UI | 01, 02, 04, 06, 10, 12, 13, 15, 17, 21, 22, 23, 24, 25 |
| **Codex 5.3** | Powtarzalny kod, SDK integracja, YAML/CI, formularze | 03, 07, 14, 16, 18, 19, 20 |
| **Gemini 2.5 Pro** + Codex | Spritesheets animowane, wrogowie z nowych biomów | 14, 18 |
| **Gemini 2.5 Pro** | Sprite'y PNG, grafiki store, bannery, UI mockupy, tła biomów, ikony skill tree | 08, 11, 12, 14, 18 |
| **Ręcznie** | Konsola Google Play, konfiguracja konta | 05, 09 |

## Graf zależności

```
ISSUE-04 (loot buff) ──────────────────────┐
ISSUE-01 (AdMob prod) ─────────────────────┤
ISSUE-02 (banner) ← ISSUE-01               ├──→ ISSUE-10 (final build)
ISSUE-03 (interstitial) ← ISSUE-01         │         │
ISSUE-05 (GP account) ─────┐               │         ↓
ISSUE-07 (privacy) ← 05    ├──→ ISSUE-09 (closed beta) ──→ ISSUE-16 (feedback)
ISSUE-06 (AAB) ─────────────┤                                    │
ISSUE-08 (graphics) ────────┘                                    ↓
                                                          ISSUE-19 (analytics)
ISSUE-11 (sprites) ──→ ISSUE-14 (animations) ──→ ISSUE-17 (performance)
         │                                              │
         └──→ ISSUE-12 (UI) ──→ ISSUE-13 (parallax)    │
                                                        ↓
ISSUE-15 (splash) ──────────────────────────────→ ISSUE-18 (desert biome)

ISSUE-22 (UI transitions) ──→ ISSUE-23 (card juice)
ISSUE-21 (skill tree hex) ──→ ISSUE-24 (mobile UX)
ISSUE-23 ──→ ISSUE-25 (layer cleanup)

ISSUE-20 (CI/CD) ← ISSUE-06, ISSUE-09
```

## Szacowany łączny czas: ~58-78h

---

## Mapowanie GitHub Issues (epickie) → Lokalne Issues (operacyjne)

| GitHub Issue | Stan | Odpowiednik lokalny |
|---|---|---|
| #1 [CORE] Mechaniki gry i save | CLOSED ✅ | Zaimplementowane (brak dedykowanego local issue) |
| #2 [ART] Oprawa audiowizualna | CLOSED ✅ | ISSUE-12, ISSUE-13, ISSUE-15 |
| #3 [LORE] Fabuła i przedmioty | CLOSED ✅ | Częściowo (boss Sadam w GameBattleManager) |
| #4 [RELEASE] Google Play | CLOSED ✅ | ISSUE-05, 06, 07, 08, 09, 10 |
| #5 [QA] Testy regresyjne | CLOSED ✅ | Brak dedykowanego local issue |
| #6 [POLISH] Ulepszanie mechanik | CLOSED ✅ | ISSUE-23, ISSUE-24, ISSUE-25 (nowy pakiet UX polish) |
| #7 [BIZNES] Monetyzacja | OPEN | ISSUE-01, 02, 03 (AdMob) + ISSUE-19 |
| #8 [ASSETS] Lista zasobów | CLOSED ✅ | ISSUE-08 |
| #9 [ADMIN] Lokalizacja | OPEN | Brak — do przyszłej iteracji |
| #10 [MVP] Zakres v0.2 | CLOSED ✅ | ISSUE-10 (final build) |
| #11 [UI] Combat Arena | CLOSED ✅ | ISSUE-12 (UI redesign) |
| #12 [ART] Pixel Art styl | OPEN ⚠️ | `project.godot` skonfigurowany (filter Nearest, skalowanie) |
| #13 Fix startup errors | CLOSED ✅ | Naprawione (GDScript parse errors, addons) |
| #14 [DESIGN] High Stakes Cards | CLOSED ✅ | Cursed cards w CardChoiceScene.gd — częściowo |
| #15 [VFX] Near Death Experience | CLOSED ✅ | Brak local issue (winieta + low-pass filter) |
| #16 [UX] Flavorful Descriptions | OPEN | Brak local issue — backlog |
| #17 Enemy Roster (6 wrogów) | CLOSED ✅ | ISSUE-11 (zaktualizowane danymi z GitHub) |
| #18 Boss System (3 bossy) | CLOSED ✅ | ISSUE-11 (dane bossów dodane) |
| #19 Drop/Resource System | CLOSED ✅ | Częściowo w GameBattleManager (_on_enemy_died) |
| #20 MVP Polish (pasek, DPS, tutorial) | CLOSED ✅ | Częściowo (etykiety, DPS, biome indicator) |
