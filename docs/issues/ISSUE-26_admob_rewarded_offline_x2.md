# ISSUE-26: Rewarded ad — x2 Offline Earnings ("Welcome Back!")

**Priorytet:** 🔴 WYSOKI (monetyzacja)
**Kategoria:** Monetyzacja / AdMob
**Szacowany czas:** 2-3h
**Najlepszy model AI:** Claude Sonnet 4.6 / Opus 4.7
**Status:** ✅ ZAIMPLEMENTOWANE (2026-05-25, do testu w Godot)
**Data utworzenia:** 2026-05-25

## Kontekst biznesowy

Po publikacji w Closed Alpha (v0.6.5) zauważone:
- W kodzie są już **3 reklamy AdMob**: banner, interstitial, rewarded (full heal).
- Konfiguracja jest konserwatywna — gracze nie są frustrowani, ale **prawdopodobnie zostawiamy 40-60% potencjalnego przychodu na stole**, szczególnie na rewarded ads.
- Decyzja produktowa (2026-05-25): dodać **dwa nowe rewarded placementy** w kolejności:
  1. **x2 offline earnings** (ten ticket) — większy wpływ na retencję i przychód, prostszy w balansie, mniej kontrowersyjny.
  2. **Revive po śmierci** ([ISSUE-27](ISSUE-27_admob_rewarded_revive.md)) — większy emocjonalny impact, ale wymaga przemyślenia balansu (szczególnie bossy).

To są dwa najbardziej dochodowe placementy w gatunku idle/clicker.

## Opis

Dodać przycisk "x2 Gold (Watch Ad)" do popupu "WELCOME BACK!", który już istnieje w kodzie (`_show_offline_reward_popup` w [src/scenes/GameBattleManager.gd:1753](../../src/scenes/GameBattleManager.gd#L1753)).

Aktualnie popup pokazuje offline gold i ma tylko przycisk "Claim" / dismiss. Po dodaniu rewarded ad placementu gracz dostaje wybór:
- **Claim** — odbierz 100% offline gold (bez reklamy).
- **x2 Gold (Watch Ad)** — obejrzyj rewarded ad, dostań 2× offline gold.

## Wykorzystywany ad unit

`REWARDED_AD_UNIT_ID = "ca-app-pub-4067533100503154/9484519330"` (Joana Indiana HP — `Z nagrodą`).

Ten sam ad unit co pełny heal. Nie potrzebujemy nowej jednostki w AdMob — placement jest po stronie kodu, jednostka reklamowa jest neutralna.

## Stan obecny (do referencji)

- `_check_offline_rewards(data: Dictionary)` ([GameBattleManager.gd:1734](../../src/scenes/GameBattleManager.gd#L1734)):
  - Triggeruje na load gry jeśli `last_save_time` > 60s.
  - Cap 12h, 60% efficiency gold/sec stage'a.
  - Auto-przyznaje gold + woła popup.
- `_show_offline_reward_popup(gold_amount, seconds)` ([GameBattleManager.gd:1753](../../src/scenes/GameBattleManager.gd#L1753)):
  - Tworzy `CanvasLayer` z dimmerem i panelem.
  - Wyświetla "+X Gold" + opis "Away for Xh Ym".
  - Auto-dismiss / click dismiss.

## Zadania

1. Refactor `_check_offline_rewards`: nie przyznawać złota od razu — zapamiętać pending amount, przekazać do popupu.
2. Przebudować `_show_offline_reward_popup` — dodać dwa przyciski:
   - `Claim` (zielony) — przyznaje 100% pending gold, zamyka popup.
   - `x2 Gold ▶️` (złoty) — pokazuje rewarded ad. Po reward callback przyznaje `pending * 2`, zamyka popup.
3. Stan AdMob:
   - Jeśli `_admob_available == false` lub `_rewarded_ad == null` → ukryj przycisk x2 (albo pokaż disabled).
   - Po dismiss reklamy (`on_ad_dismissed_full_screen_content`) preload kolejnej rewarded ad.
4. Po pokazaniu reklamy:
   - Jeśli reward dostarczony (`on_user_earned_reward`) → grant `pending * 2`, zamknij popup, `vfx.spawn_floating_text("+X Gold (x2!)")`.
   - Jeśli reklama nie wyświetliła się (`on_ad_failed_to_show_full_screen_content`) → fallback: grant `pending * 1`, powiedz "Ad failed — claimed 1×".
5. Zabezpieczenie przeciw double-claim: flaga `_offline_reward_claimed` lub usunięcie popupu z drzewa po claimie.
6. Reset `_offline_reward_claimed` przy następnym load gry.

## UX / UI

- Layout popupu pozostaje pionowy (`VBoxContainer`).
- Pod opisem "Away for X — your crew kept fighting!" dodać `HBoxContainer` z dwoma przyciskami obok siebie:
  ```
  [ Claim ]   [ x2 Gold ▶️ ]
  ```
- Min. szerokość przycisków: 100px, padding 8px.
- Po kliknięciu któregokolwiek przycisku → animacja fade-out popupu + grant gold.
- Brak limitu dziennego — placement samoograniczający (gracz może claimować tylko raz na sesję offline).

## Pliki do edycji

- `src/scenes/GameBattleManager.gd`:
  - `_check_offline_rewards` (~linia 1734)
  - `_show_offline_reward_popup` (~linia 1753)

## Kryteria akceptacji

- [ ] Popup "WELCOME BACK!" pokazuje dwa przyciski: Claim + x2 Gold.
- [ ] Claim → grant 100% offline gold, popup się zamyka.
- [ ] x2 Gold → pokazuje rewarded ad, po reward grant 200%, popup się zamyka.
- [ ] Jeśli AdMob nieavailable → przycisk x2 ukryty/disabled, tylko Claim widoczny.
- [ ] Fallback przy fail-to-show: grant 100%, komunikat.
- [ ] Brak możliwości double-claim (po claimie popup znika).
- [ ] Preload kolejnej rewarded ad po dismiss.
- [ ] Test na urządzeniu fizycznym (Android) z prawdziwymi reklamami.

## Edge cases

- **Offline < 60s** — popup się nie pokazuje, brak zmian.
- **Brak internetu** — `on_ad_failed_to_show` → fallback 1×.
- **Player tap-spam x2** — pierwszy click disables przycisk.
- **Reklama zamknięta przed reward** (`on_ad_dismissed` przed `on_user_earned_reward`) — Google API gwarantuje że reward przyjdzie pierwszy jeśli gracz obejrzał. Jeśli nie obejrzał = brak rewarda, fallback do dismissal handlera bez double-grant.

## Zależności

- ISSUE-01 (produkcyjne AdMob) ✅
- Offline rewards system już zaimplementowany ✅

## Prognoza wpływu

- **+30-50% przychodu z rewarded ads** (offline x2 ma 30-50% conversion vs ~10-15% full-heal).
- **+10-20% retencji D1/D7** (powód do otwierania apki codziennie).
- Brak negatywnego wpływu na UX — placement dobrowolny w naturalnym momencie satysfakcji.
