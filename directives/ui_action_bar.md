# Directive: Combat Arena Action Bar UI (Issue #11)

## Objective
Implement a dynamic Action Bar UI for combat, complete with visual feedback (shadows, white flashes) to improve "Game Feel".

## Requirements
1.  **Action Bar Logic:** A visual indicator (likely a `ProgressBar` or `TextureProgressBar`) that fills up over time, representing when the enemy (or player) will attack.
2.  **Shadow:** Add a shadow effect under the enemy sprite to ground it in the scene.
3.  **White Flash:** Implement a shader or modulate effect to make the enemy flash white when taking damage.

## Context (Godot)
- The main combat scene is likely `src/scenes/node_2d.tscn`.
- Combat logic is handled in `src/scripts/GameBattleManager.gd`.

## Procedure
1.  **Locate Assets:** Find the existing enemy node in the main scene.
2.  **Add Nodes:**
    - Add a `Sprite2D` for the shadow (using a simple oval or existing asset).
    - Add a `ProgressBar` (or `TextureProgressBar`) above/below the enemy for the action timer.
3.  **Implement Logic (GDScript):**
    - Update the action bar value in `_process` or using a `Timer`/`Tween` based on enemy attack speed.
    - Create a flash function (e.g., using a Tween to animate `modulate` or a custom CanvasItem shader).
4.  **Testing:** Ensure the bar fills correctly and the flash triggers on hit.

## Outputs
- Modified `.tscn` file(s) containing the new UI nodes.
- Modified `.gd` script(s) containing the logic for the bar and flash.