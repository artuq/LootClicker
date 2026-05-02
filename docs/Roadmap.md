# LootClicker Roadmap (Skill-Aligned)

Data aktualizacji: 2026-05-02

---

## 0. Historia projektu

LootClicker (wewnętrzna nazwa: *Joana Indiana*) powstał jako eksperyment edukacyjny. Dwa miesiące temu autor nie miał żadnego doświadczenia ani z programowaniem, ani z tworzeniem gier. Okazja była prosta: zbadać możliwości modeli AI, agentów AI i umiejętności AI w praktyce, budując coś działającego od zera.

Cały projekt był tworzony z pomocą **GitHub Copilot w VS Code**. W ciągu dwóch miesięcy:
- nauczone od zera: GDScript, Godot 4.6, eksport Android, ADB, podpisywanie AAB
- zbudowany kompletny core loop gry mobilnej z walką, loot systemem, bossami i drzewkiem umiejętności
- wdrożone: AdMob, AAB bundle, Privacy Policy, Google Play Console
- gra opublikowana w **zamkniętych testach alfa na Google Play** (wersja `0.6.3`, code `31`)

---

## 1. Stan obecny

- Gra opublikowana w **zamknietych testach alfa (Closed Alpha) na Google Play**.
- Aktualna wersja: `0.6.3` (version code `31`).
- Core loop walki stabilny: `click -> damage feedback -> loot/reward -> next stage`.
- Tla walki: statyczne `Jungle.jpeg` i `Temple.jpeg`.
- Android export stabilny: AAB bundle z Play Asset Delivery (PCK).
- Projekt mobile-first: `360x640`, renderer `mobile`, orientacja pionowa.

## 2. Najwazniejsze decyzje produktowe

- Nie uzywamy ruchomego tla w walce (parallax wycofany — czystszy styl, mniej rozpraszajacy).
- Informacje o wymaganiach ("Need:") w Skill Tree sa ukryte domyslnie — pokazuja sie w tooltipie po tapnieciu.
- AdMob: konto w trakcie weryfikacji przez Google — aktywny fallback Fake Ads (Tween-based).
- Priorytet: stabilnosc Closed Alpha, zbieranie feedbacku, przygotowanie do Open Beta.

## 3. Co zostalo zakonczone

### Sprint testow wewnetrznych (2026-03-19) — 8 bugfixow
- Scene transition bleedthrough ("Continue" naklakal stara scene na nowa) — naprawiony fade-to-black.
- Privacy Policy wyswietlalo raw HTML — poprawiony URL na `htmlpreview.github.io`.
- Skill Tree nakladaly sie napisy — naprawiony layout + BackButton powieksozny.
- Inventory puste (dead code blad) — naprawione + empty state.
- Settings overlay chhowal sie pod nawigacja dolna — naprawiony z-order (layer 150).
- Boss UI z-fighting — przesuniety `EnemyFloatingUI.offset_top` 120→140.
- Card Choice: wąskie karty, maly tekst — powiekszone.
- Toast "Ad not ready" zaslaniał nawigacje — przeniesiony na gore ekranu (y=60).

### Wczesniejsze sprinty
- Rollback parallax w `src/scenes/node_2d.tscn`.
- Android APK podpisany i zainstalowany na telefonie.
- Bottom Nav UX fix (przyciski INVENTORY/STATS dzialaja).
- Juice animations przy klikaniu zakladek.
- AdMob Fake Ads (konto nie zatwierdzone, tween-based fallback).
- Game balance: Stage 25+ nerf, Adrenaline mechanic, Soft Landing scaling.

## 4. Plan na kolejne iteracje

### P0 (najpierw)
- **Tutorial:** Podmienic `hand_cursor.png` na mobilna ikone palca (pixel art 32x32 lub 48x48).
- **Art direction:** Zdecydowac — pixel-art Joana na TitleScreen czy zostawic styl anime. Aktualny zgrzyt stylistyczny (anime vs. pixel-art gameplay) odnotowany przez testera.
- **QA:** Smoke-test checklist po kazdym hotfixie (build, install, launch, reward flow, settings, skill tree).
- **Privacy Policy hosting:** Zweryfikowac czy htmlpreview.github.io renderuje poprawnie z publicznego repo.

### P1
- Profiler debug (FPS/frame time/aktywny tween count).
- Lokalne eventy telemetryczne: czas do pierwszego level-up, sredni czas walki.

### P2
- Ujednolicic source of truth assetow UI (ikony/rozmiary/kolory).
- Audio variation set (3-5 wariantow hit/coin/ui).

## 5. Znane ograniczenia

- `hand_cursor.png` — TODO: wymienic na pelna ikone palca do mobilnych tutoriali.
- Spójnosc artystyczna TitleScreen vs. gameplay — wymaga decyzji i nowego assetu.
- htmlpreview.github.io wymaga publicznego repo; jesli repo stanie sie prywatne, URL znow sie zepsuje.


## 1. Stan obecny (po ostatnich wdrozeniach)

- Core loop walki dziala: `click -> damage feedback -> loot/reward -> next stage`.
- Tla walki zostaly uproszczone do statycznych warstw: `Jungle.jpeg` i `Temple.jpeg`.
- Parallax zostal celowo wycofany z aktywnej sceny i logiki managera.
- Android export jest stabilny po hotfixie: `version/code=4`, `version/name=0.4.1-hotfix`, `use_gradle_build=false`.
- Projekt pozostaje mobile-first: `360x640`, renderer `mobile`, orientacja pionowa.

## 2. Najwazniejsze decyzje produktowe

- W walce nie uzywamy ruchomego tla (parallax), aby zachowac czysty, czytelny styl i mniej rozpraszac gracza.
- Priorytet na obecny sprint: stabilnosc deployu Android + jakosc UX walki, a nie dodatkowe efekty tla.

## 3. Co zostalo zakonczone

- Rollback parallax w `src/scenes/node_2d.tscn`.
- Uproszczenie switcha biome tla (Jungle/Temple) w `src/scenes/GameBattleManager.gd`.
- Usuniecie osieroconych hookow po eksperymentach VFX, aby uniknac regresji runtime.
- Potwierdzony headless export APK bez bledow (`EXIT: 0`).

## 4. Plan na kolejne iteracje

### P0 (najpierw)

- Dodac szybki smoke-test checklist pod Android po kazdym hotfixie (build, install, launch, reward flow).
- Domknac dokumentacje release workflow (`APK debug` vs `AAB release`) i utrzymac ja spojną z `export_presets.cfg`.
- Przejrzec i zaktualizowac stale opisy issue, ktore dalej zakladaja parallax jako cel.
- Wdrozyc pakiet UX polish z gotowych ticketow:
	- `ISSUE-23` (juice przy wyborze karty)
	- `ISSUE-24` (czytelnosc Skill Tree + feedback zakupu)
	- `ISSUE-25` (czyszczenie warstw UI + pozycjonowanie toastow)

### P1

- Dodac prosty profiler debug (FPS/frame time/aktywny tween count).
- Dodac lokalne eventy telemetryczne: czas do pierwszego level-up, sredni czas walki, potion usage rate.

### P2

- Ujednolicic source of truth assetow UI (ikony/rozmiary/kolory) przez jeden config.
- Dopracowac audio variation set (3-5 wariantow hit/coin/ui), bez zmian tla walki.

## 5. Definition of Done (na sprint)

- Statyczne tlo biome dziala poprawnie na wszystkich stage (Jungle -> Temple).
- Brak odniesien do `ParallaxBackground`/`ParallaxLayer` w aktywnej scenie i managerze.
- Android build i instalacja przechodza bez regresji.
- Dokumentacja (`Roadmap`, `issues`, `SessionSummary`) odpowiada aktualnemu stanowi kodu.
