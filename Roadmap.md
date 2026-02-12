``` mermaid
flowchart TD
    %% Definicje stylów dla czytelności
    classDef done fill:#2da44e,stroke:#1e7d3a,color:white,font-weight:bold;
    classDef todo fill:#d29922,stroke:#a4771b,color:white;
    classDef main fill:#0969da,stroke:#054ada,color:white,font-weight:bold,font-size:18px;
    classDef story fill:#bf3989,stroke:#86265f,color:white,font-style:italic;

    %% Główny rdzeń projektu
    Root((JOANNA INDIANA:<br/>LOOT CLICKER v0.2)):::main

    %% FUNDAMENTY TECHNICZNE
    Root --> FUN[FUNDAMENTY TECHNICZNE]:::done
    FUN --> F1(✅ setup_enemy crash fix):::done
    FUN --> F2(✅ Sygnały i Sync is_connected):::done
    FUN --> F3(✅ Synchronizacja Gold i HP):::done
    FUN --> F4(✅ Formatowanie tekstu %):::done
    FUN --> F5(✅ Optymalizacja pod Androida):::done

    %% MECHANIKA ROZGRYWKI
    Root --> MECH[MECHANIKA ROZGRYWKI]:::done
    MECH --> M1(✅ System ataku i Timery):::done
    MECH --> M2(✅ Floating Text DMG):::done
    MECH --> M3(✅ Skalowanie trudności 1.2x):::done
    MECH --> M4(✅ System Bossów co 5 Stage):::done
    MECH --> M5(✅ Pasek postępu poziomu):::done

    %% EKONOMIA I SKLEP
    Root --> SHOP[EKONOMIA I SKLEP]:::done
    SHOP --> S1(✅ Upgrade Siły i Obrony):::done
    SHOP --> S2(✅ Bonusy do Złota i Krytyków):::done
    SHOP --> S3(✅ Redukcja czasu ataku):::done
    SHOP --> S4(✅ System leczenia i limit HP):::done

    %% ZADANIA DO WDROŻENIA
    Root --> NEXT[SYSTEMY DO WDROŻENIA]:::todo
    NEXT --> N1(🕒 Struktura pliku JSON):::todo
    NEXT --> N2(🕒 Logika Save i Load):::todo
    NEXT --> N3(🕒 Automatyczny zapis gry):::todo

    %% EKWIPUNEK
    Root --> EQ[EKWIPUNEK]:::todo
    EQ --> E1(🕒 Okno UI Inventory):::todo
    EQ --> E2(🕒 Tabela łupów - Loot table):::todo
    EQ --> E3(🕒 System zakładania przedmiotów):::todo

    %% FABUŁA I LORE
    Root --> LORE[FABUŁA: JOANNA INDIANA]:::story
    LORE --> L1(🎬 Intro: Skok bez spadochronu):::story
    LORE --> L2(💀 Boss: Saddam z Basenu):::story
    LORE --> L3(🎒 Item: Bicz z gumy do żucia):::story
    LORE --> L4(🔄 Reset: Kolejny Sequel):::story
