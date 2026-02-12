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
    Core --> B3[Rozwój Postaci]:::done
    B3 --> B3a(System 20 Poziomów/Stage):::done
    B3 --> B3b(Boss co 5 Etapów):::done
    B3 --> B3c(Mechanika Szczęścia/Luck):::done

    %% GAŁĄŹ 4: SKILL TREE (AKTUALIZACJA)
    Core --> B4[Skill Tree 2.0]:::todo
    B4 --> B4a(Logika Zależności Węzłów):::todo
    B4 --> B4b(Skalowanie Kosztów 1.3^L):::done
    B4 --> B4c(Aktywne vs Pasywne Skille):::todo

    %% GAŁĄŹ 5: WIZJA I ANDROID
    Core --> B5[Wizja i Android]:::todo
    B5 --> B5a(Mechanika Dotyku/Tap):::done
    B5 --> B5b(Fabuła i Boss Intro):::todo
    B5 --> B5c(Design z dmcalle Asset):::todo
