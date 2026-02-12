graph TD
    %% Definicja stylów
    classDef done fill:#2da44e,stroke:#2da44e,color:white,stroke-width:2px;
    classDef todo fill:#d29922,stroke:#d29922,color:white,stroke-width:2px;
    classDef main fill:#0969da,stroke:#0969da,color:white,stroke-width:4px;

    %% Główny Węzeł
    Core((LOOT CLICKER)):::main

    %% GAŁĄŹ 1: PODSTAWY
    Core --> B1[Podstawy]:::done
    B1 --> B1a(Walka Automatyczna):::done
    B1 --> B1b(System HP i Złota):::done
    B1 --> B1c(Podstawowe UI):::done

    %% GAŁĄŹ 2: DYNAMIKA WALKI
    Core --> B2[System Walki 2.0]:::done
    B2 --> B2a(Ataki Przeciwników):::done
    B2 --> B2b(Bossowie co 5 Etapów):::done
    B2 --> B2c(Skalowanie Wykładnicze 1.15^L):::done

    %% GAŁĄŹ 3: ROZWÓJ I EKONOMIA
    Core --> B3[Rozwój Postaci]:::done
    B3 --> B3a(Statystyka Defense):::done
    B3 --> B3b(Statystyka Atk Speed):::done
    B3 --> B3c(Skalowanie Kosztów 1.3^L):::done

    %% GAŁĄŹ 4: SKILL TREE (UI)
    Core --> B4[Skill Tree UI]:::todo
    B4 --> B4a(Nowe Buttony: Def/Spd):::todo
    B4 --> B4b(Zależności Węzłów):::todo
    B4 --> B4c(Resetowanie Skilli):::todo

    %% GAŁĄŹ 5: ANDROID I ART
    Core --> B5[Wizja i Android]:::todo
    B5 --> B5a(Mechanika Dotyku):::done
    B5 --> B5b(Fabuła i Intro):::todo
    B5 --> B5c(Design z dmcalle Asset):::todo
