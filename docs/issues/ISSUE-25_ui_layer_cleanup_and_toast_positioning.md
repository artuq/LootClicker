# ISSUE-25: Czyszczenie ekranu i nakladanie warstw (UI Polish)

**Priorytet:** 🔴 WYSOKI  
**Kategoria:** UI / Stability / Polish  
**Szacowany czas:** 2-3h  
**Najlepszy model AI:** Claude Sonnet 4.6

## Opis
Podczas otwierania waznych popupow (np. Level Up) na ekranie zostaja stale elementy (floating text), a toasty moga zaslaniac dolne UI.

## Cel UX
- Czysty ekran przy popupach wysokiego priorytetu.
- Brak konfliktow warstw (z-index / CanvasLayer).
- Toasty nie zaslaniaja menu i same znikaja.

## Instrukcje implementacji (Godot 4.x)
1. Floating text group:
   - wszystkie latajace napisy (damage, boss quotes) musza trafic do grupy np. `floating_text`.
   - w ich `_ready()` dodaj `add_to_group("floating_text")`.
2. Czyszczenie przed Level Up:
   - tuz przed pokazaniem popupu przeiteruj po `get_tree().get_nodes_in_group("floating_text")`.
   - wykonaj `queue_free()` albo szybki fade-out i `queue_free()`.
3. Toast "Ad not ready":
   - ustaw pozycje tak, by pojawial sie nad dolnym panelem UI,
   - unikaj anchorow, ktore przyklejaja go do samego dołu i nachodza na menu,
   - wymuszone auto-znikanie po ~2s (Tween/Timer + `queue_free()`).

## Pliki do edycji
- `src/scenes/GameBattleManager.gd`
- `src/scenes/node_2d.tscn`
- `src/scenes/damage_label.gd` (lub skrypt odpowiedzialny za floating tekst)

## Kryteria akceptacji
- [X] Przy Level Up na ekranie nie zostaja stale floating teksty.
- [X] Toast nie zaslania dolnego UI.
- [X] Toast zawsze znika automatycznie i nie spamuje ekranu.
- [X] Brak regresji flow reward/victory/combat na Androidzie.

## Krótki snippet referencyjny
```gdscript
func _clear_floating_text_group() -> void:
    for n in get_tree().get_nodes_in_group("floating_text"):
        if is_instance_valid(n):
            n.queue_free()
```
