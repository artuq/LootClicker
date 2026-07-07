# Archiwum — zamknięte issues

> Skondensowane podsumowania zamkniętych/zaimplementowanych issues. Pełna oryginalna
> treść (prompty, snippety, kryteria akceptacji) była w `docs/issues/ISSUE-NN_*.md` —
> usunięta po potwierdzeniu w kodzie/git, bo zadania są zrobione i plik nie jest już
> potrzebny jako specyfikacja roboczy. Historia w `git log` jeśli potrzeba szczegółów.
>
> Zaktualizowano: 2026-06-18 (część statusów zweryfikowana bezpośrednio w kodzie, nie
> tylko z deklaracji w README — patrz adnotacje "weryfikacja w kodzie").

## Release pipeline (Google Play)
- **ISSUE-01** AdMob → produkcyjne reklamy — ✅ zrobione
- **ISSUE-02** AdMob banner ads — ✅ zrobione (AdView w GameBattleManager, victory screen)
- **ISSUE-03** AdMob interstitial ads — ✅ zrobione
- **ISSUE-05** Konto Google Play Developer — ✅ gotowe (ręcznie)
- **ISSUE-06** Signing key + AAB build — ✅ gotowe (`gradle_build/export_format=1` w `export_presets.cfg`)
- **ISSUE-07** Polityka prywatności — ✅ gotowe (`docs/privacy-policy.md`)
- **ISSUE-08** Grafiki do store — ✅ gotowe (uploadowane w Play Console, nie w repo)
- **ISSUE-09** Closed Beta setup — ✅ zrobione (ręcznie)
- **ISSUE-10** Final build + test — ✅ zrobione

## Balans i ekonomia
- **ISSUE-04** Loot/drop +20% od stage 1 — ✅ gotowe

## Monetyzacja post-launch (2026-05-25)
- **ISSUE-26** Rewarded ad: x2 Offline Earnings — ✅ DONE 2026-05-25
- **ISSUE-27** Rewarded ad: Revive po śmierci — ✅ DONE 2026-05-25

## Grafika / content
- **ISSUE-13** Parallax tło — ✅ zamknięte jako `DESCOPE` (rollback do statycznego tła, ruchome warstwy nie pasowały stylistycznie)
- **ISSUE-15** Splash screen — ✅ zaimplementowane. Weryfikacja w kodzie 2026-06-18: `boot_splash/*` skonfigurowany w `project.godot`, `SplashScreen.tscn` jako main scene, addon `splash_screen_wizard` aktywny.
- **ISSUE-18** Desert biome + Ramzes — ✅ shipped w v0.7.0 ("Phase 1 release — Desert biome + monetization", najnowszy commit). README z 2026-05-25 błędnie pokazywał to jako `🔜 Phase 1` — nieaktualne, poprawione 2026-06-18.
- **ISSUE-21** Skill Tree visual upgrade (hex redesign) — ✅ 2026-03-02 — własny hex renderer (bez pluginu Tree Maps), 2-tap, tooltip

## UI/UX polish (2026-03-07 pack)
- **ISSUE-22** Animacje UI i przejścia między scenami — ✅ zaimplementowane. Weryfikacja w kodzie 2026-06-18: `src/scripts/UIAnimations.gd` istnieje, `create_tween`/`TRANS_*` używane w większości scen (CardChoiceScene, SettingsScene, SplashLoaderSlide, SkillTreeScene, TitleScreen).
- **ISSUE-23** Satysfakcja z wyboru karty (Juice & Feedback) — ✅ zaimplementowane. Zweryfikowane w tej sesji: `CardChoiceScene.gd` ma realny `TRANS_BACK` ease-out tween na scale/fade. README z 2026-05-25 pokazywał to jako otwarte — nieaktualne.
- **ISSUE-24** Skill Tree mobile UX + purchase feedback — ✅ zaimplementowane. Weryfikacja w kodzie 2026-06-18: `SkillTreeScene.gd` ma min. tap target ~52px (`_upgrade_btn.custom_minimum_size`) i press/release scale-tween z `TRANS_BACK`/`EASE_OUT`.
- **ISSUE-25** UI layer cleanup + toast positioning — ✅ zaimplementowane. Weryfikacja w kodzie 2026-06-18: `NotificationManager.gd` ma `show_toast()` + `queue_notification()`/`_process_notification_queue()`.
