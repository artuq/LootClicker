``` mermaid
flowchart TD
    %% --- STYLE DEFINITIONS ---
    classDef done fill:#2da44e,stroke:#1e7d3a,color:white,font-weight:bold;
    classDef todo fill:#d29922,stroke:#a4771b,color:white;
    classDef art fill:#6f42c1,stroke:#4a2c82,color:white,font-weight:bold;
    classDef story fill:#bf3989,stroke:#86265f,color:white,font-style:italic;
    classDef main fill:#0969da,stroke:#054ada,color:white,font-weight:bold,font-size:20px;
    classDef in_progress fill:#ffc107,stroke:#e0a800,color:black,font-weight:bold;

    %% --- GŁÓWNY WĘZEŁ ---
    Root((JOANNA INDIANA:<br/>LOOT CLICKER PRO)):::main

    %% --- FILAR 1: KOD I MECHANIKA (CORE) ---
    Root --> COL1[CORE & CODE]:::done
    
    subgraph G_CORE [Fundamenty]
        direction TB
        C1(✅ Fix: setup_enemy crash):::done
        C2(✅ Sygnały & Event Bus):::done
        C3(✅ Sync: HP/Gold/Timery):::done
    end
    
    subgraph G_MECH [Mechanika RPG]
        direction TB
        M1(✅ Floating Text System):::done
        M2(✅ Boss System co 5 Stage):::done
        M3(✅ Roguelite: 3 Cards Choice):::done
        M4(✅ Resources: Mummy Bandages etc.):::done
        M5(✅ Skalowanie x1.2):::done
        M6(✅ Dodge & Block Mechanic):::done
    end
    COL1 --> G_CORE
    COL1 --> G_MECH

    %% --- FILAR 2: GRAFIKA I OPTYMALIZACJA (TECH-ART) ---
    Root --> COL2[GRAFIKA I OPTYMALIZACJA]:::art

    subgraph G_OPT [Wydajność i Styl]
        direction TB
        O1(✅ Pixel Art Config):::done
        O2(✅ Kenney UI Skinning):::done
        O3(✅ Smart Scaling Fixes):::done
        O4(⚙️ Batching Draw Calls):::art
    end

    subgraph G_JUICE [Game Feel & FX]
        direction TB
        J1(🎨 Particle System):::art
        J2(✅ Screen Shake):::done
        J3(✅ Squash & Stretch):::done
        J4(✅ Hit Flash):::done
    end
    COL2 --> G_OPT
    COL2 --> G_JUICE

    %% --- FILAR 3: ZARZĄDZANIE ASSETAMI (PIPELINE) ---
    Root --> COL3[ASSETY I SYSTEMY]:::todo

    subgraph G_SYS [Systemy Danych]
        direction TB
        S1(✅ JSON Save/Load):::done
        S2(✅ Szyfrowanie Danych):::done
        S3(✅ Audio Manager: Procedural + Bus Fix):::done
        S4(✅ Inventory Grid & Potions):::done
        S5(✅ CardChoiceScene Null-checks):::done
        S6(✅ UpgradeManager Validation):::done
    end

    subgraph G_ASSETS [Zasoby]
        direction TB
        A1(🕒 Import: Sprite Sheets):::todo
        A2(🕒 Fonty: Custom .ttf):::todo
        A3(🕒 SFX & Music Bus):::todo
        A4(🕒 Ikony Ekwipunku):::todo
    end
    COL3 --> G_SYS
    COL3 --> G_ASSETS

    %% --- FILAR 4: FABUŁA I LORE (NARRACJA) ---
    Root --> COL4[FABUŁA: JOANNA INDIANA]:::story

    subgraph G_LORE [Scenariusz]
        direction TB
        L1(🎬 Intro: Skok w siano):::story
        L2(💀 Boss: Saddam):::story
        L3(🎒 Loot: Bicz z gumy):::story
        L4(🔄 Prestiż: Sequel):::story
        L5(📜 Dziennik: 20 wpisów):::story
    end
    COL4 --> G_LORE
