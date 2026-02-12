```mermaid
mindmap
  root((JOANNA INDIANA:<br/>LOOT CLICKER v0.2))
    ::icon(fa fa-cube)
    STABILNOSC_I_FUNDAMENTY_TRAWA
      (OK) setup_enemy crash fix
      (OK) Sygnaly i Sync: is_connected
      (OK) Synchronizacja Gold i HP
      (OK) Formatowanie tekstu %%
      (OK) Optymalizacja pod Androida
    SYSTEM_WALKI_KAMIEN
      (OK) Mechanika klikania i ataku
      (OK) Timery: Atak Gracza vs Wroga
      (OK) Floating Text DMG (Pop-upy)
      (OK) System Bossow (co 5 etap)
      (OK) Skalowanie HP przeciwnikow 1.2x
      (OK) Pasek postępu Stage
    SKLEP_I_STATYSTYKI_ZIEMIA
      (OK) Upgrade STR (Sila)
      (OK) Upgrade DEF (Obrona)
      (OK) Attack Speed (Skracanie timerow)
      (OK) Crit Chance i Gold Bonus
      (OK) System Leczenia (Heal)
      (OK) Blokada maksymalnego HP
    SYSTEM_ZAPISU_ZELAZO
      TODO Struktura pliku JSON
      TODO Logika Save (Zapis stanu)
      TODO Logika Load (Wczytywanie)
      TODO Auto-Save przy wyjsciu
      TODO Szyfrowanie zapisu (opcjonalnie)
    EKWIPUNEK_DIAMENT
      TODO Okno UI Inventory (Grid)
      TODO Lista przedmiotow (Loot table)
      TODO Logika zakladania (Equip/Unequip)
      TODO Statystyki przedmiotow (Item Lore)
    FABULA_HOT_SHOTS_ZLOTO
      TODO Intro: Skok w siano bez spadochronu
      TODO Postac: Joanna Indiana (Bicz + Fedora)
      TODO Boss: Saddam z Basenu (Absurdalny przeciwnik)
      TODO Item: Bicz z gumy do zucia
      TODO Reset: Kolejny Sequel (System Prestizu)

    B2c --> B2c1(Żółte Liczby - DMG wroga):::done
    B2c --> B2c2(Czerwone Liczby - DMG gracza):::done
    B2 --> B2d(Progresja Wroga):::done
    B2d --> B2d1(Skalowanie HP 1.2x):::done
    B2d --> B2d2(Boss co 5 poziomów):::done

    %% --- GAŁĄŹ 3: SKILL TREE (Ekonomia) ---
    Core --> B3[Skill Tree & Sklep]:::done
    B3 --> B3a(Logika Przycisków):::done
    B3a --> B3a1(Szare gdy brak złota):::done
    B3a --> B3a2(Szare gdy HP FULL):::done
    B3 --> B3b(Dostępne Ulepszenia):::done
    B3b --> B3b1(Siła +1):::done
    B3b --> B3b2(Krytyk +1%):::done
    B3b --> B3b3(Chciwość +5% Gold):::done
    B3b --> B3b4(Attack Speed -0.05s):::done
    B3b --> B3b5(Defense -1 DMG):::done
    B3b --> B3b6(Heal 100%):::done

    %% --- GAŁĄŹ 4: LOOT (Nagrody) ---
    Core --> B4[Loot System]:::done
    B4 --> B4a(Klasa GameItem):::done
    B4 --> B4b(Drop Chance 30%):::done
    B4 --> B4c(Auto-Equip Lepszej Broni):::done

    %% --- GAŁĄŹ 5: PLANY NA JUTRO (Kluczowe) ---
    Core --> B5[Do Zrobienia - JUTRO]:::todo
    B5 --> B5a(System Zapisu - Save/Load):::todo
    B5 --> B5b(Okno Ekwipunku - Lista Itemów):::todo
    B5 --> B5c(Animacje Sprite'a):::todo
    B5 --> B5d(Export na Androida .apk):::todo

    %% --- GAŁĄŹ 6: PRZYSZŁOŚĆ (Inspiracje Tap Titans) ---
    Core --> B6[Rozwój v0.3 / v0.4]:::future
    B6 --> B6a(Game Juice - Czucie Gry):::future
    B6a --> B6a1(Screen Shake przy Crit):::future
    B6a --> B6a2(Particles przy uderzeniu):::future
    B6 --> B6b(Prestige System):::future
    B6b --> B6b1(Reset gry za Relikty):::future
    B6b --> B6b2(Artefakty - stałe bonusy):::future
    B6 --> B6c(Big Numbers System 1aa, 1ab):::future
    B6 --> B6d(Asset: Worldmap Builder - Mapa):::future
