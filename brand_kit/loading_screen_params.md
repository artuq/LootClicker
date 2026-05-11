# Loading Screen — Parametry

## Tło
- Kolor: `#1A1A2E` → `Color(0.101961, 0.101961, 0.180392, 1)`
- Pełny ekran (fullscreen ColorRect)

## Logo
- Plik: `logo_1024x1024.png` (lub `artq_games_logo.png`)
- Pozycja: wyśrodkowane (`PRESET_CENTER`)
- Rozmiar w scenie: 256×256 px (`offset_left=-128, offset_right=128, offset_top=-168, offset_bottom=88`)
- Wejście: fade-in alpha `0.0 → 1.0` + scale `0.92 → 1.0`, czas `0.32s`, easing `TRANS_BACK / EASE_OUT`

## Pasek postępu (Loading Bar)
- Rozmiar: 276×30 px (`offset_left=-138, offset_right=138, offset_top=126, offset_bottom=156`)
- Pozycja: pod logo, wyśrodkowane
- Tło paska:
  - Kolor: `Color(0.08, 0.10, 0.18, 0.9)` (ciemnogranatowy)
  - Zaokrąglenie rogów: 8 px
  - Ramka: 2 px, `Color(0.20, 0.27, 0.42, 1.0)`
- Wypełnienie paska:
  - Kolor: `Color(0.22, 0.82, 0.49, 1.0)` (zielony)
  - Zaokrąglenie rogów: 7 px
- Prędkość animacji postępu: `85.0` jednostek/sekundę (`move_toward`)
- Bez wyświetlania procentów

## Tekst "LOADING..."
- Pozycja: pod paskiem (`offset_top=96, offset_bottom=124`)
- Kolor: `Color(0.86, 0.94, 1.0, 0.95)` (jasnoniebieski)
- Animacja: `"LOADING" + ".".repeat(dots)` — 0 do 3 kropek, zmiana 3×/s
- Pulsowanie alpha: `0.7 + 0.3 * abs(sin(elapsed * 2.5))`

## Dźwięk
- Plik: `loading_sound.mp3` (Crystal System Boot)
- Bus: Master
- Volume: `0.0 dB`
- Odtwarzany jednorazowo przy starcie slajdu

## Czasy
- Minimalny czas wyświetlania: `7.5s`
- Failsafe (max timeout): `10.0s`
- Intro (fade-in logo): `0.32s`

## Silnik / plugin
- Godot 4.6
- Plugin: `splash_screen_wizard` (`addons/splash_screen_wizard/`)
- Klasy bazowe: `SplashScreen`, `SplashScreenSlide`
- Ładowanie sceny docelowej: `ResourceLoader.load_threaded_request()` w tle podczas wyświetlania splasha
