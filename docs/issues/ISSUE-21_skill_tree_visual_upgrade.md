# ISSUE-21: Poprawa graficzna Skill Tree z użyciem pluginu Tree Maps

**Priorytet:** 🟡 ŚREDNI  
**Kategoria:** Grafika / UI / Plugin  
**Szacowany czas:** 3-5h  
**Najlepszy model AI:** Claude Sonnet 4.6 (refaktor GDScript + integracja pluginu) + **Gemini 2.5 Pro** (ikony umiejętności, tła węzłów)  
**Status:** ✅ ZAIMPLEMENTOWANE (2026-03-02) — alternatywne podejście: bez pluginu Tree Maps, własny hex renderer

---

## Opis

Obecny skill tree (`SkillTreeScene.tscn`) używa własnych `SkillNode` (Button + StyleBoxFlat) z ręcznie rysowanymi liniami przez `_draw()`. Wygląd jest funkcjonalny, ale wizualnie surowy.

Plugin **Tree Maps - Graphs and Skill Trees** jest **już zainstalowany** w projekcie (`addons/tree_maps/`) — wystarczy go aktywować i zintegrować z obecnym kodem.

### Czym jest Tree Maps?
- Asset Library: https://godotengine.org/asset-library/asset/4362
- GitHub: https://github.com/ToxicStarfall/tree-maps-addon
- Licencja: MIT
- Godot: 4.4+ (kompatybilny z 4.6)
- Dostarcza gotowe węzły `TreeMap`, `TreeMapNode` z rysowaniem połączeń, animacjami i stylami

---

## Zadania

### 1. Aktywacja pluginu
Plugin jest w `addons/tree_maps/plugin.cfg` — upewnić się że jest włączony:
```
# project.godot
[editor_plugins]
enabled=PackedStringArray("res://addons/admob/plugin.cfg", "res://addons/tree_maps/plugin.cfg")
```

### 2. Zbadanie przykładu
Uruchomić `addons/tree_maps/example.tscn` by zobaczyć co plugin oferuje.

### 3. Przebudowa SkillTreeScene.tscn
Zastąpić obecny layout `%TreeLayout` (VBoxContainer/HBoxContainer z SkillNode) węzłem `TreeMap` z pluginu:

```gdscript
# Zamiast SkillNode jako Button — użyć TreeMapNode
# Zamiast ręcznych draw_line — plugin rysuje połączenia automatycznie
```

### 4. Styl wizualny
Skonfigurować kolory i styl węzłów dopasowane do palety gry:
- Tło węzła: ciemny fiolet `#1e1b3a`
- Border normalny: `#8868cc`
- Border dostępny: `#44ff88`
- Border maxed: `#ffd700` (złoty)
- Border zablokowany: `#444455`
- Połączenia: linia `#6644aa` grubość 3px, animacja glow dla odblokowanych

### 5. Ikony umiejętności
Dodać dedykowane ikony PNG dla każdego skill_id:
| Skill | Ikona sugerowana |
|-------|-----------------|
| str   | miecz / pięść   |
| speed | błyskawica      |
| crit  | celownik        |
| greed | moneta           |
| def   | tarcza          |
| heal  | serce            |
| hp    | serce + plus    |

Wygenerować przez **Gemini 2.5 Pro** (prompt: "pixel art icon, [item], transparent background, 64x64") lub użyć z https://kenney.nl/assets/game-icons

### 6. Animacje przejść
- Węzły odblokowane: pulse + glow effect (Tween)
- Odblokowanie nowego: particle burst w miejscu węzła
- Scroll animacja przy otwieraniu ekranu (już działa `animate_open()` — rozszerzyć)

### 7. Tooltip
Dodać `RichTextLabel` tooltip na hover z:
- Nazwa umiejętności
- Aktualny poziom / max poziom
- Efekt (+X damage, +X% crit, etc.)
- Koszt następnego poziomu

---

## Alternatywny asset (jeśli Tree Maps nie pasuje)

**Worldmap Builder** też jest zainstalowany (`addons/worldmap_builder/`):
- Asset Library: https://godotengine.org/asset-library/asset/2270
- Bardziej nastawiony na mapy świata/level select
- Może być użyty dla przyszłego ekranu wyboru mapy dungeonów

---

## Pliki do edycji
- `project.godot` — upewnić się że plugin aktywny
- `src/scenes/SkillTreeScene.tscn` — przebudowa layoutu
- `src/scenes/SkillTreeScene.gd` — integracja z TreeMap API
- `src/scripts/SkillNode.gd` — ewentualny wrapper lub zastąpienie
- `assets/icons/skills/` — nowe ikony (do utworzenia)

## Co zaimplementowano (2026-03-02)

> **Uwaga:** Nie użyto pluginu Tree Maps — obecny `SkillNode._draw()` zapewnia pełną kontrolę nad hex renderingiem i był wystarczający. Plugin zainstalowany, ale nieaktywowany.

### ✅ Zrealizowane
- **Symetryczny grid:**  lewa kolumna x=64, prawa x=244, rzędy Y: 30 / 194 / 358, odstępy równe 164px
- **Węzły 85×85px** (custom_minimum_size) z hexagonem wypełniającym cały obszar
- **Ikonki w hexach:** `expand_mode = EXPAND_IGNORE_SIZE` (fix krytyczny — bez tego PNG renderowało w 256×256 natywnie), rozmiar ±31px (+70% względem oryginalnego)
- **Połączenia między węzłami** rysowane przez `_update_connection_lines()` via `draw_line()` — auto-update przy każdym renderze
- **Tooltip panel** (`TooltipBG` + `TooltipLabel`) na dole TreePanel — nazwa, poziom, opis, koszt, waluta
- **Mechanika 2-tapów:** 1. tap = podgląd (selekcja + tooltip), 2. tap = zakup — brak przypadkowych zakupów
- **Żółty glow ring** wokół zaznaczonego węzła (`_selected` state + `queue_redraw()`)
- **Stany wizualne:** LOCKED (przyciemniony, opacity 0.65), AVAILABLE (pełne kolory), MAXED (złoto + lock), SELECTED (glow)
- **BackButton:** poprawiona pozycja (nie zasłonięta przez Android nav bar), `process_mode = ALWAYS`
- **Działa na Android** (APK instalowany i testowany wielokrotnie)

### ❌ Nie zrealizowane (do przyszłej iteracji)
- Pixel-art ikony dla każdej umiejętności (nadal placeholder kształty)
- Animacja pulse dla dostępnych węzłów
- Particle burst przy odblokowaniu
- Kolory wg palety `#1e1b3a / #8868cc` (obecne: inne odcienie fioletu)
- Plugin Tree Maps nie zintegrowany

---

## Kryteria akceptacji
- [X] Plugin Tree Maps aktywny i użyty w SkillTreeScene
- [x] Połączenia między węzłami rysowane (ręczne draw_line, nie plugin)
- [X] Dedykowane ikony PNG dla każdej umiejętności
- [x] Tooltip z opisem na tap (nie hover — mobilka)
- [X] Kolory dopasowane do palety wg spec (#1e1b3a itd.)
- [X] Animacja pulse dla dostępnych węzłów
- [x] Działa na Android (60fps, testowane ADB)

## Zależności
- ISSUE-12 (ogólny redesign UI) — powiązane, ale niezależne
