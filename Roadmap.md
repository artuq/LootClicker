```mermaid
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

    %% GAŁĄŹ 2: LOOT
    Core --> B2[Loot i Ekwipunek]:::done
    B2 --> B2a(Drop Przedmiotów):::done
    B2 --> B2b(Okno Ekwipunku):::done
    B2 --> B2c(Zakładanie Broni):::done

    %% GAŁĄŹ 3: ROZWÓJ POSTACI
    Core --> B3[Rozwój Postaci]:::todo
    B3 --> B3a(Level Up):::done
    B3 --> B3b(Skill Tree UI):::todo
    B3 --> B3c(Logika Kupowania):::todo

    %% GAŁĄŹ 4: SYSTEMY (MOBILE)
    Core --> B4[Systemy]:::todo
    B4 --> B4a(Save Game):::todo
    B4 --> B4b(Mechanika Dotyku):::todo
    B4 --> B4c(Skalowanie Trudności):::todo

    %% GAŁĄŹ 5: WIZJA I ART (NOWE!)
    Core --> B5[Wizja i Art]:::todo
    B5 --> B5a(Polerowanie Grafiki):::todo
    B5 --> B5b(Fabuła / Intro):::todo
    B5 --> B5c(Export na Androida):::todo
