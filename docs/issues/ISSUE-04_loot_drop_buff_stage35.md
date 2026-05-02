# ISSUE-04: Zwiększenie lootu i dropu o 20% od pierwszego poziomu

**Priorytet:** 🔴 KRYTYCZNY  
**Kategoria:** Balans / Gameplay  
**Szacowany czas:** 1h  
**Najlepszy model AI:** Claude Sonnet 4.6 (precyzyjne edycje w GDScript, rozumie logikę balansu)  
**Status:** ✅ ZAIMPLEMENTOWANE

## Opis
Gracz od pierwszego poziomu zbiera za mało lootu — gra jest zbyt trudna w progresji. Zwiększamy wszystkie nagrody o 20% globalnie od stage 1:
- Gold reward +20%
- Resource drop amount +20% (ceil zaokrąglenie)
- Potion drop chance +20% (z 40% na 48%)
- XP reward +20%

## Zmiany w kodzie (zaimplementowane)

### `src/scenes/GameBattleManager.gd` — funkcja `_on_enemy_died()`

```gdscript
# Gold +20% globalnie
var final_gold = int(gold * 1.2)
kill_gold = final_gold
player.gain_gold(final_gold)

# XP +20% globalnie
var xp_reward = 20 if current_stage == 1 else int((15 + (current_stage * 5)) * 1.2)

# Resource drop +20% (ceil)
drop_amount = int(ceil(drop_amount * 1.2))

# Potion 48% zamiast 40%
if randf() < 0.48:
```

## Kryteria akceptacji
- [x] Gold +20% od stage 1
- [x] Resources +20% od stage 1
- [x] Potion chance 48% od stage 1
- [x] XP +20% od stage 1

## Zależności
- Brak
