# LootClicker — Roadmap Issues

> Zaktualizowano: 2026-06-18. Gra **LIVE** na Google Play (`com.artuq.lootclicker2`),
> v0.7.0 wydane (Desert biome + monetization + bugfixy).
> 20 zamknietych issues skondensowane w [ARCHIVE.md](ARCHIVE.md) — ten plik pokazuje
> tylko to, co realnie jest jeszcze otwarte/w toku.

---

## W toku

| # | Issue | Status |
|---|-------|--------|
| 11 | [Nowe sprite'y wrogów](ISSUE-11_enemy_sprite_upgrade.md) | 🟢 Wrogowie (15/15) zrobieni w stylu V2 — **5 bossów (Idol, Brad, Sphinx, Saddam, Ramboses) wciąż na starym stylu**, zweryfikowane wizualnie 2026-06-18 (smooth/painterly shading, brak ciężkiego czarnego konturu) |
| 12 | [Redesign UI walki](ISSUE-12_ui_battle_redesign.md) | ✅ v1 zamknięte · 🟢 v2 „Joana Indiana" w toku (2026-06-15) |

## Backlog

| # | Issue | Priorytet | Notatka |
|---|-------|-----------|---------|
| 28 | [Late-game content roadmap (stage 50+)](ISSUE-28_late_game_content_roadmap.md) | strategiczny | 5 nowych biomów, 27 wrogów, 6 bossów — dokument operacyjny: `docs/ART_PLAN.md` |
| 14 | [Animacje wrogów](ISSUE-14_enemy_animations.md) | 🟡 ŚREDNI | ⏸️ zawieszone (2026-03-03) |
| 16 | [System feedbacku beta](ISSUE-16_beta_feedback_system.md) | 🟡 ŚREDNI | gra jest już LIVE, nie w beta — zweryfikować czy ten issue ma jeszcze sens, czy jest stale |
| 17 | [Optymalizacja performance](ISSUE-17_performance_optimization.md) | 🟡 ŚREDNI | nie zaimplementowane (sprawdzone w kodzie 2026-06-18) |
| 19 | [Firebase Analytics](ISSUE-19_firebase_analytics.md) | 🟢 NISKI | nie zaimplementowane (sprawdzone w kodzie 2026-06-18) — potrzebne przed Phase 3+ late-game content |
| 20 | [CI/CD GitHub Actions](ISSUE-20_cicd_github_actions.md) | 🟢 NISKI | nie zaimplementowane, brak `.github/workflows/` (sprawdzone w kodzie 2026-06-18) |

---

## Mapowanie GitHub Issues (epickie) → Lokalne Issues (operacyjne)

| GitHub Issue | Stan | Odpowiednik lokalny |
|---|---|---|
| #1 [CORE] Mechaniki gry i save | CLOSED ✅ | Zaimplementowane (brak dedykowanego local issue) |
| #2 [ART] Oprawa audiowizualna | CLOSED ✅ | archiwum: 12, 13, 15 |
| #3 [LORE] Fabuła i przedmioty | CLOSED ✅ | Częściowo (boss Sadam w GameBattleManager) |
| #4 [RELEASE] Google Play | CLOSED ✅ | archiwum: 05, 06, 07, 08, 09, 10 |
| #5 [QA] Testy regresyjne | CLOSED ✅ | Brak dedykowanego local issue |
| #6 [POLISH] Ulepszanie mechanik | CLOSED ✅ | archiwum: 23, 24, 25 |
| #7 [BIZNES] Monetyzacja | OPEN | archiwum: 01, 02, 03, 26, 27 + ISSUE-19 (open) |
| #8 [ASSETS] Lista zasobów | CLOSED ✅ | archiwum: 08 |
| #9 [ADMIN] Lokalizacja | OPEN | Brak — do przyszłej iteracji |
| #10 [MVP] Zakres v0.2 | CLOSED ✅ | archiwum: 10 |
| #11 [UI] Combat Arena | CLOSED ✅ | archiwum: 12 |
| #12 [ART] Pixel Art styl | OPEN ⚠️ | `project.godot` skonfigurowany (filter Nearest, skalowanie); patrz ISSUE-11 (bossy do regenu) |
| #13 Fix startup errors | CLOSED ✅ | Naprawione (GDScript parse errors, addons) |
| #14 [DESIGN] High Stakes Cards | CLOSED ✅ | Cursed cards w CardChoiceScene.gd — częściowo |
| #15 [VFX] Near Death Experience | CLOSED ✅ | Brak local issue (winieta + low-pass filter) |
| #16 [UX] Flavorful Descriptions | OPEN | Brak local issue — backlog |
| #17 Enemy Roster (6 wrogów) | CLOSED ✅ | archiwum: ISSUE-11 historia |
| #18 Boss System (3 bossy) | CLOSED ✅ | archiwum: ISSUE-11 historia |
| #19 Drop/Resource System | CLOSED ✅ | Częściowo w GameBattleManager (_on_enemy_died) |
| #20 MVP Polish (pasek, DPS, tutorial) | CLOSED ✅ | Częściowo (etykiety, DPS, biome indicator) |

## Podsumowanie modeli AI (historyczne, dla referencji)

| Model | Najlepszy do |
|-------|------------|
| **Claude Sonnet/Opus** | Edycja GDScript, balans, konfiguracja Godot, profilowanie, UI |
| **Codex** | Powtarzalny kod, SDK integracja, YAML/CI, formularze |
| **Gemini 2.5 Pro** | Sprite'y PNG, grafiki store, bannery, UI mockupy, tła biomów |
| **Ręcznie** | Konsola Google Play, konfiguracja konta |
