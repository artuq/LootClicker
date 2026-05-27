# ISSUE-27: Rewarded ad — Revive po śmierci ("Continue?")

**Priorytet:** 🔴 WYSOKI (monetyzacja)
**Kategoria:** Monetyzacja / AdMob / Game Design
**Szacowany czas:** 3-5h (większy zakres niż ISSUE-26 — nowy popup, nowy flow, balans)
**Najlepszy model AI:** Claude Sonnet 4.6 / Opus 4.7
**Status:** ✅ ZAIMPLEMENTOWANE (2026-05-25, do testu w Godot)
**Data utworzenia:** 2026-05-25

## Kontekst biznesowy

Drugi rewarded placement w pakiecie monetyzacyjnym (po ISSUE-26 x2 offline earnings). Revive ma **najwyższą konwersję** wśród rewarded ads w gatunku (40-60%) — gracz właśnie zainwestował czas w walkę, strata jest "droga psychicznie", reklama wydaje się darmowa.

Decyzja produktowa (2026-05-25): wdrożyć **PO** ISSUE-26 — większy emocjonalny impact, ale wymaga przemyślenia balansu (szczególnie bossy).

## Opis

Po śmierci gracza (`_handle_player_death` w [src/scenes/GameBattleManager.gd:1586](../../src/scenes/GameBattleManager.gd#L1586)) — zamiast natychmiastowego przejścia do TitleScreen, **pokazać popup "DEFEATED"** z opcją obejrzenia reklamy w zamian za revive na obecnym stage'u.

## Wykorzystywany ad unit

`REWARDED_AD_UNIT_ID = "ca-app-pub-4067533100503154/9484519330"` (Joana Indiana HP — `Z nagrodą`).

Ten sam ad unit co pełny heal i offline x2 — wystarczająco. Nie potrzebujemy nowej jednostki w AdMob.

## Stan obecny (do referencji)

[GameBattleManager.gd:1586](../../src/scenes/GameBattleManager.gd#L1586):
```gdscript
func _handle_player_death():
    print("PLAYER DIED - GAME OVER")
    vfx.vibrate(300)
    vfx.set_near_death(false)
    var title_screen = load("res://src/scenes/TitleScreen.gd")
    if title_screen:
        title_screen.last_run_result = "DEFEAT"
    get_tree().change_scene_to_file("res://src/scenes/TitleScreen.tscn")
```

Brak popupu, brak chance na revive — od razu zmiana sceny.

## Zadania

1. Dodać nowy stan `_revive_used_this_stage: bool = false` (reset przy każdym nowym stage'u, podobnie do `ad_uses_this_stage`).
2. Refactor `_handle_player_death()`:
   - Zatrzymać enemy attack timer (żeby nie wpadał nowy hit podczas popupu).
   - Jeśli `_revive_used_this_stage == false` ORAZ `_admob_available` ORAZ `_rewarded_ad != null` → pokaż popup "DEFEATED" z opcją revive.
   - Inaczej (revive już użyty / brak reklam / pierwsze 3 stage'y) → natychmiastowy fallback do dotychczasowego flow (TitleScreen).
3. Nowy popup `_show_defeat_popup_with_revive()`:
   - Dimmer (z-layer ~160, nad innymi UI), tytuł "DEFEATED" (czerwony, font 18).
   - Stage info: "Stage X — fell to <enemy_name>".
   - Dwa przyciski:
     - `Continue (Watch Ad)` — pokazuje rewarded ad, po reward → revive.
     - `Give Up` — wraca do TitleScreen (current behavior).
   - **Auto-dismiss timer 7s** (countdown widoczny na przycisku Continue): "Continue (6s)... (5s)..." — po wygaśnięciu auto-dismiss → Give Up.
4. Revive flow:
   - `_rewarded_ad.show(listener)` z callbackiem on_user_earned_reward → `_grant_revive()`.
   - `_grant_revive()`:
     - `player.current_hp = player.max_hp` (full HP — bardziej hojne, lepiej konwertuje).
     - `_revive_used_this_stage = true`.
     - Enemy: opcjonalnie `current_enemy.current_hp = current_enemy.max_hp` (decyzja designerska — patrz "Open questions").
     - `vfx.spawn_floating_text("REVIVED!", Color.SPRING_GREEN)`.
     - Wznowić enemy attack timer.
     - `save_game()` żeby revive się zapisał.
5. Fallback przy `on_ad_failed_to_show_full_screen_content` → zamknij popup, idź do TitleScreen.
6. Reset `_revive_used_this_stage` na początku każdego nowego stage'a (analogicznie do `ad_uses_this_stage`).

## UX / Game Design (decyzje z 2026-05-25)

- **Limit: 1 revive na walkę** — żeby nie psuć balansu i nie pozwolić cheesować bossów w nieskończoność.
- **Revive z pełnym HP** (decyzja: hojność > fair). Można zmienić na 50% jeśli testerzy zgłoszą że za łatwo.
- **Enemy HP przy revive — hybryda:**
  - Zwykli wrogowie: zachowują obecne HP (większa nagroda za reklamę, lepsza konwersja).
  - **Bossowie (stage % 5 == 0): RESET do pełnego HP** — zapobiega cheese'owaniu bossa na 1% HP.
- **Okno czasowe 7s** — dłuższe okno = większa konwersja, ale gracz nie może czekać w nieskończoność.
- **Aktywne od stage 6+** (`current_stage >= 6`) — gracz najpierw nauczy się gry, dostaje opcję revive po pierwszym bossie (stage 5). Mniej impressions, ale lepiej przygotowany gracz.
- **Niezależne od full-heala** — jeśli gracz użył już full-heala w tym stage'u, revive nadal dostępny (osobny limit, osobny moment).
- **Vibration:** 300ms przy pokazaniu popupu (jak teraz), 60ms przy revive grant.

## Pliki do edycji

- `src/scenes/GameBattleManager.gd`:
  - `_handle_player_death` (~linia 1586)
  - Nowa funkcja `_show_defeat_popup_with_revive()` (~obok rebirth popupu, ~linia 1616)
  - Nowa funkcja `_grant_revive()` (~obok `_grant_ad_reward`, ~linia 2180)
  - Reset `_revive_used_this_stage = false` w `_advance_to_next_stage()` lub równoważnym miejscu (znaleźć analogicznie do `ad_uses_this_stage = 0` na linii 1323)

## Kryteria akceptacji

- [ ] Po śmierci pokazuje się popup "DEFEATED" z przyciskami Continue + Give Up.
- [ ] Continue → rewarded ad → revive z pełnym HP, kontynuacja walki.
- [ ] Give Up / 7s timeout → TitleScreen (current behavior).
- [ ] Limit 1 revive per stage — drugi raz w tym samym stage'u od razu TitleScreen.
- [ ] Stage <= 5 → bez popupu, od razu TitleScreen (nowi gracze, do pierwszego bossa włącznie).
- [ ] Boss revive (stage % 5 == 0) → enemy HP resetuje się do max.
- [ ] Zwykły mob revive → enemy HP zachowuje obecny stan.
- [ ] Brak revive jeśli AdMob nieavailable.
- [ ] Enemy timer zatrzymany podczas popupu.
- [ ] Auto-save po revive (gracz nie traci progressu przy crashu).
- [ ] Test na bossie (stage 5/10/15) — czy revive nie psuje balansu.
- [ ] Test na zwykłym mobie — szybkość konwersji.

## Edge cases

- **Reklama nie wyświetlona** (fail_to_show) → fallback do TitleScreen z komunikatem "Ad failed".
- **Gracz spamuje Continue podczas ładowania reklamy** → disable przycisku po pierwszym tap.
- **Gracz zamyka apkę podczas reklamy** → next launch wczyta ostatni auto-save (sprzed śmierci, jeśli był).
- **Boss revive cheese** — limit 1× per stage powinien wystarczyć. Jeśli testerzy zgłoszą cheese (np. revive na ostatnim 1% HP bossa) — rozważyć boss-specific limit.
- **Achievement "no death" type** — sprawdzić czy istnieje, revive może go nieświadomie psuć.

## Decyzje (2026-05-25)

1. **Enemy HP przy revive:** Hybryda — zwykli wrogowie zachowują HP, bossowie się resetują. Zapobiega cheese'owaniu boss'ów na 1% HP, jednocześnie maksymalizując nagrodę przy zwykłych walkach.
2. **HP gracza po revive:** 100% (full HP). Można dostroić później na podstawie analytics.
3. **Cutoff:** stage 6+. Nowi gracze (stage 1-5, włącznie z pierwszym bossem) nie są niepokojeni reklamami — najpierw uczą się gry.

## Zależności

- ISSUE-01 (produkcyjne AdMob) ✅
- ISSUE-26 (x2 offline earnings) — best practice: zrobić najpierw, mniej kontrowersyjny.

## Prognoza wpływu

- **+50-100% przychodu z rewarded ads** (revive ma najwyższy conversion rate w gatunku — 40-60% vs 10-15% innych).
- Łącznie z ISSUE-26: monetyzacja gry osiągnie **70-80% potencjału dobrze zoptymalizowanej idle/clickerki**.
- Ryzyko balansowe: bossy mogą być za łatwe. Mitigacja: limit 1×/stage, brak reset enemy HP.
