graph TD
    %% DEFINICJA STYLÓW (KOLORY)
    classDef done fill:#2da44e,stroke:#2da44e,color:white,stroke-width:2px;
    classDef fix fill:#bf3989,stroke:#bf3989,color:white,stroke-width:2px;
    classDef todo fill:#d29922,stroke:#d29922,color:white,stroke-width:2px;
    classDef main fill:#0969da,stroke:#0969da,color:white,stroke-width:4px;

    %% GŁÓWNY WĘZEŁ
    Core((LOOT CLICKER<br/>v0.2 Alpha)):::main

    %% --- GAŁĄŹ 1: TECHNICZNE (Stabilność) ---
    Core --> B1[Stabilność i Architektura]:::fix
    B1 --> B1a(Naprawa Crashu: setup_enemy):::done
    B1 --> B1b(Bezpieczne Sygnały: is_connected):::done
    B1 --> B1c(Synchronizacja UI: Złoto i HP):::done
    B1 --> B1d(Formatowanie Tekstu: %%):::done

    %% --- GAŁĄŹ 2: WALK (Gameplay) ---
    Core --> B2[System Walki]:::done
    B2 --> B2a(Atak Gracza: Timer + Speed):::done
    B2 --> B2b(Atak Wroga: Timer 1.5s):::done
    B2 --> B2c(Feedback Wizualny):::done
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

    %% --- GAŁĄŹ 5: PLANY (Przyszłość) ---
    Core --> B5[Do Zrobienia - JUTRO]:::todo
    B5 --> B5a(System Zapisu - Save/Load):::todo
    B5 --> B5b(Okno Ekwipunku - Lista Itemów):::todo
    B5 --> B5c(Animacje Sprite'a):::todo
    B5 --> B5d(Export na Androida .apk):::todo
