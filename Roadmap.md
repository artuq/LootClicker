``` mermaid
graph TD
    %% Style kolorystyczne
    classDef done fill:#2da44e,stroke:#1e7d3a,color:white,font-weight:bold;
    classDef todo fill:#d29922,stroke:#a4771b,color:white;
    classDef main fill:#0969da,stroke:#054ada,color:white,font-weight:bold,font-size:18px;
    classDef story fill:#bf3989,stroke:#86265f,color:white,font-style:italic;

    %% Główny punkt
    Center((JOANNA INDIANA:<br/>LOOT CLICKER v0.2)):::main

    %% Gałąź: Fundamenty
    Center --- FUN[FUNDAMENTY TECHNICZNE]:::done
    FUN --- F1(✅ setup_enemy crash fix):::done
    FUN --- F2(✅ Sygnały i Sync is_connected):::done
    FUN --- F3(✅ Synchronizacja Gold i HP):::done
    FUN --- F4(✅ Formatowanie tekstu %):::done
    FUN --- F5(✅ Optymalizacja Android):::done

    %% Gałąź: Mechanika
    Center --- MECH[MECHANIKA ROZGRYWKI]:::done
    MECH --- M1(✅ System ataku i Timery):::done
    MECH --- M2(✅ Floating Text DMG):::done
    MECH --- M3(✅ Skalowanie trudności 1.2x):::done
    MECH --- M4(✅ Boss co 5 Stage):::done
    MECH --- M5(✅ Pasek postępu):::done

    %% Gałąź: Systemy do wdrożenia
    Center --- SYS[ZADANIA DO WDROŻENIA]:::todo
    SYS --- S1(🕒 Struktura JSON):::todo
    SYS --- S2(🕒 Logika Save i Load):::todo
    SYS --- S3(🕒 Automatyczny zapis):::todo

    %% Gałąź: Ekwipunek
    Center --- EQ[EKWIPUNEK]:::todo
    EQ --- E1(🕒 Okno Inventory UI):::todo
    EQ --- E2(🕒 Logika przedmiotów):::todo

    %% Gałąź: Fabuła
    Center --- LORE[FABUŁA: HOT SHOTS STYLE]:::story
    LORE --- L1(🎬 Intro: Skok bez spadochronu):::story
    LORE --- L2(💀 Boss: Saddam z Basenu):::story
    LORE --- L3(🎒 Item: Bicz z gumy do żucia):::story
    LORE --- L4(🔄 Reset: Kolejny Sequel):::story
