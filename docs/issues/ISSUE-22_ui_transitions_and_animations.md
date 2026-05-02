# ISSUE-22: Animacje UI i przejścia między scenami

**Priorytet:** 🟢 NISKI  
**Kategoria:** UI / Polish  
**Szacowany czas:** 2-3h  
**Najlepszy model AI:** Claude Sonnet 4.6

## Opis

Gra nie daje żadnego wizualnego feedbacku podczas przejść — ekrany pojawiają się natychmiastem. Dodać proste, spójne animacje wejścia/wyjścia dla wszystkich głównych scen i elementów UI, inspirowane **Proton Control Animation** ([asset #3721](https://godotengine.org/asset-library/asset/3721)).

Asset **nie musi być instalowany jako plugin** — wystarczy wzorować się na jego podejściu:
- Każdy ekran animuje się sam przez `AnimationPlayer` lub `Tween` przy `_ready()`
- Zero zewnętrznych zależności, czyste GDScript

---

## Miejsca do zaanimowania

### 1. Przejścia między scenami (fade/slide)
| Trigger | Animacja |
|---------|----------|
| Start gry (TitleScreen → Battle) | Czarny overlay fade out |
| Otwarcie Upgrade Screen | Scale in + fade in z dołu ekranu |
| Zamknięcie Upgrade Screen | Slide out → fade |
| Otwarcie Skill Tree | Scale in z centrum (już zaimplementowane — OK ✅) |
| Reklama → powrót do gry | Fade in battle sceny |
| "Next Battle" między stage | Szybki flash + slide |

### 2. Przyciski — juice (już częściowo zrobione)
| Element | Animacja |
|---------|----------|
| Każdy Button | `scale 1.0 → 0.92 → 1.0` przy wciśnięciu (bounce) |
| "FIGHT" / "NEXT BATTLE" | Pulse glow gdy aktywny |
| BackButton | Lekki shake przy hooveru |

### 3. Karta wyboru (CardChoiceScene)
- Karty wlatują z dołu po kolei (stagger 0.08s delay między kartami)
- Wybrana karta „leci" do góry ekranu i znika
- Odrzucone karty fade out

### 4. Liczniki (gold, HP, stage)
- Przy zmianie wartości: krótki scale-up (1.0 → 1.2 → 1.0, 0.15s) + zmiana koloru na żółty → biały

---

## Implementacja (bez pluginu)

### Globalny helper — `src/scripts/UIAnimations.gd`
```gdscript
class_name UIAnimations

# Fade in od alpha=0 do 1
static func fade_in(node: CanvasItem, duration: float = 0.25) -> Tween:
    node.modulate.a = 0.0
    var t = node.create_tween()
    t.tween_property(node, "modulate:a", 1.0, duration)
    return t

# Scale in z centrum
static func scale_in(node: Control, duration: float = 0.3) -> Tween:
    node.pivot_offset = node.size / 2
    node.scale = Vector2(0.85, 0.85)
    node.modulate.a = 0.0
    var t = node.create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    t.tween_property(node, "scale", Vector2.ONE, duration)
    t.tween_property(node, "modulate:a", 1.0, duration * 0.6)
    return t

# Slide in z dołu
static func slide_in_from_bottom(node: Control, duration: float = 0.35) -> Tween:
    var original_y = node.position.y
    node.position.y += 60.0
    node.modulate.a = 0.0
    var t = node.create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
    t.tween_property(node, "position:y", original_y, duration)
    t.tween_property(node, "modulate:a", 1.0, duration * 0.7)
    return t

# Bounce licznika
static func bounce_label(label: Label, duration: float = 0.18):
    var t = label.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    t.tween_property(label, "scale", Vector2(1.25, 1.25), duration * 0.4)
    t.tween_property(label, "scale", Vector2.ONE, duration * 0.6)

# Stagger dla kilku Control nodes
static func stagger_fade_in(nodes: Array, delay_step: float = 0.08, duration: float = 0.25):
    for i in nodes.size():
        var n = nodes[i] as CanvasItem
        n.modulate.a = 0.0
        var t = n.create_tween()
        t.tween_interval(i * delay_step)
        t.tween_property(n, "modulate:a", 1.0, duration)
```

### Użycie w scenach

**UpgradeScreen.gd** — `_ready()`:
```gdscript
func _ready():
    UIAnimations.slide_in_from_bottom(self)
```

**CardChoiceScene.gd** — po zbudowaniu kart:
```gdscript
UIAnimations.stagger_fade_in([card1, card2, card3], 0.08)
```

**GameBattleManager.gd** — przy zmianie wartości gold/HP:
```gdscript
UIAnimations.bounce_label($HUD/GoldLabel)
```

---

## Pliki do edycji
- `src/scripts/UIAnimations.gd` — **NOWY** statyczny helper
- `src/scenes/UpgradeScreen.gd` — `_ready()` + slide in
- `src/scenes/CardChoiceScene.gd` — stagger kart
- `src/scenes/GameBattleManager.gd` — bounce na gold/HP labelach
- `src/scenes/TitleScreen.gd` — fade in przy starcie

## Kryteria akceptacji
- [ ] Otwieranie Upgrade Screen animowane (slide z dołu)
- [ ] Karty wyboru wlatują z staggerem
- [ ] Przyciski mają bounce przy naciśnięciu (wszystkie sceny)
- [ ] Gold i HP label pulsują przy zmianie wartości
- [ ] Żadne animacje nie blokują input powyżej 0.5s
- [ ] Działa płynnie na urządzeniu (≥30 FPS podczas animacji)

## Zależności
- ISSUE-12 (UI battle redesign) — warto zrobić po rebuildzie UI
- Brak zewnętrznych pluginów

## Notatki
- Proton Control Animation (asset #3721) robi to samo przez node'y — my robimy to przez statyczny helper żeby nie dodawać pluginu
- Nie używamy `AnimationPlayer` (zbyt ciężki na małe tweeny) — tylko `Tween` / `create_tween()`
- Czas animacji: max 0.35s wejście, 0.2s wyjście — nie może spowalniać gameplayu
