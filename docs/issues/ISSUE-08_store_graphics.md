# ISSUE-08: Grafiki do Google Play Store (screenshoty, ikona, feature graphic)

**Priorytet:** 🔴 KRYTYCZNY  
**Kategoria:** Grafika / Release  
**Szacowany czas:** 3-4h  
**Najlepszy model AI:** **Gemini 2.5 Pro** (generowanie feature graphic, ikon, banerów) + Claude Sonnet 4.6 (integracja)

## Opis
Google Play wymaga zestawu grafik do listingu. Trzeba przygotować:

## Zadania
1. **Ikona 512x512** — high-res icon (już jest `icon_joana_1024.png`, trzeba wyciąć/skalować)
2. **Feature Graphic 1024x500** — baner promujący grę
3. **Screenshoty telefon** — min. 2, maks. 8 (1080x1920 lub 16:9)
   - Ekran walki z bossem
   - Drzewo umiejętności
   - Ekran wyboru kart
   - Ekran tytułowy
4. **Screenshoty tablet** — min. 1 (opcjonalnie)
5. **Promo text** — krótki tekst marketingowy (80 znaków)

## Narzędzia
- Screenshoty: `adb exec-out screencap -p > screen.png` z urządzenia Android
- Ikona: Istniejący `assets/icons/icon_joana_1024.png` skalować do 512x512
- Feature graphic: Canva/Figma lub wygenerować AI

## Kryteria akceptacji
- [X] Ikona 512x512 PNG
- [X] Feature graphic 1024x500 PNG
- [X] Min. 4 screenshoty telefon
- [X] Screenshoty pokazują kluczowe ekrany gry

## Zależności
- Gra musi być w stanie grywalnym (ISSUE-04 loot buff zastosowany)
