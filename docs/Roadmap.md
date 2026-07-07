# LootClicker Roadmap (Skill-Aligned)

Data aktualizacji: 2026-06-15

---

## 🔝 STAN OBECNY (2026-06-15) — Phase 1 + UI/Art Overhaul

- **Wersja:** `v0.7.0` (Phase 1 release — Desert biome + monetyzacja + bugfixy).
- **Dystrybucja:** AAB — Google Play Closed Alpha.

### Treść gry (Phase 1)
- **3 biomy:** Jungle (1-14), Temple (15-35), **Desert (36-55, NOWY w v0.7.0)** — tła + roster + boss.
- **Roster wrogów: 15 unikalnych** (8 core + Jaguar Influencer + Cursed Tourist + 5 Desert) + bossy (Idol/Brad/Sphinx/Saddam/Ramboses).
- **Monetyzacja:** rewarded ads (offline x2, revive) — patrz ISSUE-26/27.

### UI / Art (sesja 2026-06-15)
- **Custom UI „Joana Indiana"** zastąpił generyczne Kenney: paski HP/XP/wroga (wspólna rama + tintowalny fill), przyciski, panele, ikony nawigacji/zasobów.
- **Paski HP/XP** przesuwalne (`TextureProgressBar` na `CanvasLayer`); **enemy HP bar** w stylu Tap Titans 2 (nazwa na fillu, wartość HP po prawej).
- **StageBar** (`StageBar.tscn`) — wizualny pasek progresji 5 węzłów z miniaturami biomów i pierścieniami.
- **Regeneracja artu wrogów V2** — wszystkie 15 wrogów w nowym stylu pixel-art mix + agresja (anchor = Angry Kaboom Squirrel). Bossy: prompty gotowe, regeneracja w toku. Patrz `ART_PLAN_V2.md` + ISSUE-11.
- **Coins/DPS** pozycjonowane z kodu (`MID_HUD_OFFSET_TOP`); usunięty stały opis „Jungle 1/15 …" (StageBar go zastąpił).

### Najbliższe kroki
1. Regeneracja bossów (B1-B4 + B55) wg `ART_PLAN_V2.md` §3.6.
2. Test in-game całości UI + nowego rosteru na urządzeniu → build AAB.
3. `hand_cursor.png` → mobilna ikona palca (wciąż otwarte P0).

---

## 0. Historia projektu

LootClicker (wewnętrzna nazwa: *Joana Indiana*) powstał jako eksperyment edukacyjny — autor nie miał wcześniej doświadczenia z programowaniem ani tworzeniem gier. Cały projekt zbudowany od zera z pomocą AI (GitHub Copilot, potem Claude): GDScript, Godot 4.6, eksport Android, podpisywanie AAB, AdMob, Google Play Console.

**Kamienie milowe:**
- `0.4.1-hotfix` — rollback parallax (ruchome tło nie pasowało stylistycznie, wrócono do statycznych warstw Jungle/Temple), pierwszy stabilny Android build.
- `0.6.3` — Closed Alpha na Google Play. Sprint testów wewnętrznych (2026-03-19, 8 bugfixów: scene transition bleedthrough, Privacy Policy raw HTML, Skill Tree layout, inventory empty state, z-order ustawień, boss UI z-fighting, card choice sizing, toast pozycjonowanie).
- `v0.7.0` (aktualna) — Phase 1 release: Desert biome, UI/Art overhaul „Joana Indiana", monetyzacja rewarded ads. Patrz STAN OBECNY na górze tego pliku.

Pełna lista zamknietych ticketów: [docs/issues/ARCHIVE.md](issues/ARCHIVE.md).

## 1. Otwarte tematy (carry-over, nie zweryfikowane od dawna)

- `hand_cursor.png` → mobilna ikona palca do tutoriala (pixel art 32x32/48x48) — TODO od ~v0.4, status nieznany, sprawdzić przy następnej sesji UI.
- TitleScreen — zgłoszony przez testera zgrzyt stylistyczny (anime-style ekran startowy vs. pixel-art gameplay). Nie sprawdzone, czy UI/Art overhaul z 2026-06-15 to rozwiązał — zweryfikować wizualnie przed zamknięciem.
- Privacy Policy hosting (`htmlpreview.github.io`) wymaga publicznego repo — jeśli repo stanie się prywatne, link się zepsuje.

## 2. Plan na kolejne iteracje

### P0
1. Regeneracja bossów (B1-B4 + B55) wg `ART_PLAN_V2.md` §3.6 — zweryfikowane wizualnie 2026-06-18, wciąż na starym stylu (smooth/painterly, brak ciężkiego konturu).
2. Test in-game całości UI + nowego rosteru na urządzeniu → build AAB.
3. `hand_cursor.png` (patrz §1).

### P1
- Profiler debug (FPS/frame time/aktywny tween count).
- Lokalne eventy telemetryczne: czas do pierwszego level-up, średni czas walki, potion usage rate (patrz też ISSUE-19 Firebase Analytics — backlog).

### P2
- Ujednolicić source of truth assetów UI (ikony/rozmiary/kolory) przez jeden config.
- Audio variation set (3-5 wariantów hit/coin/ui).

## 3. Definition of Done (na sprint)

- Android build i instalacja przechodzą bez regresji.
- Dokumentacja (`Roadmap`, `issues/`, `SessionSummary`) odpowiada aktualnemu stanowi kodu — nie zgaduj statusu, sprawdź w kodzie/git przed wpisaniem ✅.
