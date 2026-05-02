# ISSUE-17: Optymalizacja wydajności na słabszych urządzeniach

**Priorytet:** 🟡 ŚREDNI  
**Kategoria:** Optymalizacja / Performance  
**Szacowany czas:** 3-4h  
**Najlepszy model AI:** Claude Sonnet 4.6 (profilowanie, GDScript optymalizacja, batch rendering)

## Opis
Upewnić się że gra działa płynnie (60fps) na urządzeniach budżetowych (Android 10+, 2GB RAM).

## Zadania
1. **Profiling** — użyć Godot profiler + `adb logcat` z timestampami
2. **Particle pooling** — nie tworzyć nowych `HitParticles` co raz, recyklować
3. **Floating text pooling** — DamageLabel queue zamiast `queue_free` + `instantiate`
4. **Texture atlasing** — połączyć małe sprite'y w atlas
5. **GDScript hot paths** — sprawdzić `_process()` i `_physics_process()` pod kątem alokacji
6. **Timer cleanup** — upewnić się że timery są stopowane poprawnie
7. **Memory leaks** — sprawdzić czy `queue_free()` jest wywoływane wszędzie

## Pliki do edycji
- `src/scenes/GameBattleManager.gd` — particle/label pooling
- `src/scenes/DamageLabel.tscn` — optymalizacja
- `project.godot` — rendering settings

## Kryteria akceptacji
- [ ] Stałe 60fps na urządzeniu z 2GB RAM
- [ ] Brak memory leaks po 30 min grania
- [ ] Particle i label pooling zaimplementowany

## Zależności
- ISSUE-14 (animations mogą wpływać na performance)
