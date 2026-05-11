# Audio Plan — Joana Indiana

**Data:** 2026-05-11  
**Narzędzie do generowania:** [Suno.ai](https://suno.ai)  
**Format docelowy:** MP3, ~2–3 minuty na track (Suno generuje ~2 min, można wygenerować kilka i zmontować)

---

## Kontekst gry

- Gatunek: Idle Clicker RPG
- Klimat: Indiana Jones parody — przygodowy, lekko humorystyczny
- Dwa biomy: **Dżungla** (stage 1–14) i **Świątynia** (stage 15–40)
- Bossy co 5 stage (nazwane: The Allergic Idol, Brad the Influencer, The Budget Sphinx)
- Styl graficzny: pixel art

---

## Aktualna sytuacja

| Plik | Użycie | Problem |
|------|--------|---------|
| `bg_music.mp3` | Główna pętla przez całą grę | Jedna ścieżka na wszystko — szybko irytuje |
| `Crystal System Boot.mp3` | Splash screen | OK |

**Cel:** 4–5 nowych tracków, rotacja per biom + boss + title screen.

---

## Struktura docelowa

```
assets/audio/
├── bg_music.mp3          ← (zastąpiony przez jungle_theme.mp3)
├── jungle_theme.mp3      ← Stage 1–14
├── temple_theme.mp3      ← Stage 15–40
├── boss_theme.mp3        ← Każdy boss fight (stage % 5 == 0)
├── title_theme.mp3       ← TitleScreen
├── victory_jingle.mp3    ← Krótki (5–8s), po pokonaniu bossa
└── Crystal System Boot.mp3 ← bez zmian
```

---

## Prompty Suno.ai

### 🌿 Track 1 — Jungle Theme (`jungle_theme.mp3`)
**Użycie:** Stage 1–14, główna pętla walki w dżungli  
**Mood:** Przygodowy, energetyczny, lekko humorystyczny — jak Indiana Jones ale w pixel art

```
adventure video game soundtrack, tropical jungle, upbeat and energetic, 
steel drums, marimba, wooden flute, light percussion, pizzicato strings, 
acoustic guitar strumming, playful and heroic, 115 bpm, loopable, 
no vocals, pixel art RPG style, retro-cinematic
```

---

### 🏛️ Track 2 — Temple Theme (`temple_theme.mp3`)
**Użycie:** Stage 15–40, świątynia — klimat tajemniczy i napięty  
**Mood:** Starożytny, nieco złowieszczy, egzotyczny — jak stara świątynia pełna pułapek

```
ancient temple video game music, mysterious and atmospheric, ethnic instruments,
sitar, tabla drums, low brass, haunting flute, ambient pads, deep bass pulses,
suspenseful and exotic, 95 bpm, loopable, no vocals, 
pixel art RPG dungeon style, cinematic orchestral
```

---

### ⚔️ Track 3 — Boss Theme (`boss_theme.mp3`)
**Użycie:** Co 5 stage — boss fight. Musi być intensywny i natychmiastowo zauważalny  
**Mood:** Dramatyczny, pilny, epickie starcie — gracz czuje że to coś poważnego

```
epic boss battle video game music, intense and urgent, heavy drums, 
dramatic brass fanfare, electric guitar riffs, synth stabs, fast tempo,
150 bpm, cinematic action, no vocals, loopable, 
pixel art RPG boss fight, adrenaline, powerful
```

---

### 🎮 Track 4 — Title Screen (`title_theme.mp3`)
**Użycie:** TitleScreen i menu główne — pierwsze wrażenie gracza  
**Mood:** Chwytliwy, przygodowy, zaprasza do gry — lekki i optymistyczny

```
video game title screen music, adventurous and inviting, uplifting,
orchestral with light tropical touches, heroic melody, marimba lead,
strings, light brass, positive and energetic, 105 bpm, 
no vocals, pixel art adventure RPG, memorable theme, loopable
```

---

### 🏆 Track 5 — Victory Jingle (`victory_jingle.mp3`)
**Użycie:** Po pokonaniu bossa (5–8 sekund) — satysfakcja  
**Mood:** Triumfalny, krótki, satysfakcjonujący — jak fanfara po zwycięstwie

```
short victory fanfare, triumphant brass, 5 seconds, 
ascending melody, celebratory, video game jingle, 
pixel art RPG reward sound, no vocals, energetic ending
```

> **Uwaga Suno:** Dla krótkich jingli wygeneruj kilka wersji i wybierz najlepsze pierwsze 5–8 sekund.

---

## Jak wdrożyć w grze

### Krok 1 — Wygeneruj i pobierz MP3 z Suno
- Wejdź na [suno.ai](https://suno.ai)
- Wklej prompt w pole tekstowe
- Wygeneruj 2–3 warianty, wybierz najlepszy
- Pobierz jako MP3
- Nazwij zgodnie z tabelą powyżej

### Krok 2 — Wrzuć pliki do projektu
```
assets/audio/jungle_theme.mp3
assets/audio/temple_theme.mp3
assets/audio/boss_theme.mp3
assets/audio/title_theme.mp3
assets/audio/victory_jingle.mp3
```

### Krok 3 — Powiedz mi że pliki są gotowe
Zaktualizuję `AudioManager.gd` i `GameBattleManager.gd` żeby:
- Odtwarzać `jungle_theme` na stage 1–14
- Przełączać na `temple_theme` na stage 15
- Odtwarzać `boss_theme` przy bossie i wracać po walce
- Odtwarzać `title_theme` na TitleScreen
- Grać `victory_jingle` po zabiciu bossa

---

## Dodatkowe wskazówki do Suno

- Dodaj słowo **"loopable"** do każdego promptu żeby Suno starało się zrobić ścieżkę łatwą do zapętlenia
- Jeśli wynik jest zbyt chaotyczny — dodaj **"calm down, steady tempo, consistent"**
- Jeśli za mało przygodowy — dodaj **"Indiana Jones inspired, swashbuckling"**
- Suno działa lepiej z krótszymi promptami — jeśli coś nie wychodzi, usuń 2–3 tagi i spróbuj ponownie
- Generuj zawsze minimum 2 warianty i porównaj pierwsze 20 sekund
