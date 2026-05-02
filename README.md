# LootClicker — Joana Indiana

**Gatunek:** Idle Clicker RPG | **Silnik:** Godot 4.6 | **Platforma:** Android | **Status:** 🔴 Zamknięte Testy Alfa (Google Play)

---

## Historia projektu

Projekt LootClicker (wewnętrzna nazwa: *Joana Indiana*) powstał jako eksperyment edukacyjny. Dwa miesiące temu autor nie miał żadnego doświadczenia ani z programowaniem, ani z tworzeniem gier.

Punkt wyjścia był prosty: skorzystać z okazji, żeby zbadać możliwości modeli AI, agentów AI i umiejętności AI w praktyce — i zbudować coś naprawdę działającego. Od pierwszego dnia gra była tworzona w całości z pomocą **GitHub Copilot w VS Code**.

W ciągu dwóch miesięcy:
- Nauczone od zera: GDScript, Godot 4.6, eksport Android, ADB, podpisywanie AAB
- Zbudowany kompletny core loop gry mobilnej: walka, system umiejętności, loot, bossy
- Zintegrowane: AdMob, Google Play Android App Bundle (AAB), Privacy Policy
- Przeprowadzone testy wewnętrzne — zebrany i wdrożony feedback od testerów
- Gra opublikowana w **zamkniętych testach alfa na Google Play**

To nie jest prototyp. To działająca gra na telefonie.

---

## O grze

Joana Indiana to mobilny idle clicker RPG z walką w czasie rzeczywistym, drzewkiem umiejętności i systemem losowych nagród za pokonanie wrogów.

**Core loop:** `kliknij → zadaj obrażenia → zdobądź łupy → rozwiń postać → następny etap`

### Mechaniki gry

| System | Opis |
|--------|------|
| Walka | Klikasz wroga, zadajesz obrażenia, zdobywasz złoto i zasoby |
| Drzewko umiejętności | STR / HP / SPD / CRIT — maks. poziom 50, premie co 20 poziomów |
| Adrenaline | 50 kliknięć → x2 DMG przez 5 sekund |
| Karty level-up | Losowy wybór 3 kart po zdobyciu poziomu (w tym przeklęte karty) |
| Bossy | Co 5 etapów — boss fight z własną animacją śmierci i efektami |
| Loot | Bandages, Venom, Shards — zasoby zdobywane z wrogów |
| AdMob | Fake Ads fallback (konto AdMob w trakcie weryfikacji przez Google) |

### Wrogowie i biomy

- **Dżungla (etapy 1–24):** 3 unikalne sprite'y, własny boss
- **Świątynia (etapy 25+):** 3 unikalne sprite'y, własny boss
- **Stage 50:** Final boss (Saddam)

---

## Stack technologiczny

| Element | Technologia |
|---------|-------------|
| Silnik | Godot 4.6 (Mobile renderer) |
| Język | GDScript |
| Platforma docelowa | Android (API 24+) |
| Format dystrybucji | AAB (Google Play) + APK (debug) |
| Rozdzielczość | 360×640, portrait |
| AI / Copilot | GitHub Copilot (VS Code) |
| Monetyzacja | AdMob Rewarded Ads (fallback: Fake Ads Tween) |

---

## Status projektu

| Kamień milowy | Status |
|---------------|--------|
| v0.1 — Fundament | ✅ Gotowe |
| v0.2 — MVP (angielski, Stage 50) | ✅ Gotowe |
| v0.3 — Game Feel & Polish | ✅ Gotowe |
| v0.4 — Stabilność Android + AAB | ✅ Gotowe |
| v0.5–0.6 — Testy wewnętrzne + bugfixes | ✅ Gotowe |
| **v0.6.3 — Zamknięte testy alfa (Google Play)** | 🔴 **Aktywne** |
| v1.0 — Pełna premiera | 🕒 Planowane |

**Aktualna wersja:** `0.6.3` (version code `31`) — zamknięte testy alfa Google Play.

---

## Struktura projektu

```
LootClicker/
├── src/
│   ├── scenes/         # Sceny Godot (.tscn) i skrypty (.gd)
│   └── scripts/        # Współdzielone skrypty (PlayerStats, AudioManager, itd.)
├── assets/             # Grafiki, sprite'y, ikony
├── build/              # Artefakty Android (AAB, APK)
├── docs/               # Dokumentacja (Roadmap, SessionSummary, Privacy Policy)
├── directives/         # Instrukcje dla agenta AI (SOP)
├── execution/          # Deterministyczne skrypty narzędziowe
└── .github/            # Śledzenie issues i projektu
```

---

## Jak uruchomić lokalnie

**Wymagania:**
- Godot 4.6 (wersja stabilna)
- Android SDK + NDK (do eksportu)
- ADB (do instalacji na urządzeniu)

**Eksport APK (debug):**
```powershell
& "Godot_v4.6-stable_win64.exe" --path "." --export-debug "Android" "build/LootClicker-debug.apk"
adb install -r "build/LootClicker-debug.apk"
```

Szczegółowy workflow: [`directives/build_apk.md`](directives/build_apk.md)

---

## Dokumentacja

| Plik | Zawartość |
|------|-----------|
| [`docs/Roadmap.md`](docs/Roadmap.md) | Plan i historia wersji |
| [`docs/SessionSummary.md`](docs/SessionSummary.md) | Notatki z sesji deweloperskich |
| [`.github/ISSUES.md`](.github/ISSUES.md) | Śledzenie zadań i bugów |
| [`.github/PROJECT_TRACKING.md`](.github/PROJECT_TRACKING.md) | Board projektu |
| [`directives/game_mechanics.md`](directives/game_mechanics.md) | Mechaniki i balans gry |

---

*Projekt stworzony od zera przez osobę bez doświadczenia w kodowaniu i tworzeniu gier — z pomocą GitHub Copilot i cierpliwości.*
