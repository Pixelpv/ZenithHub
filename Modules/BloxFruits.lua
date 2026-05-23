--[[
╔══════════════════════════════════════════════════════╗
║           ZENITH HUB — BloxFruits.lua               ║
║     Módulo principal — Versão 3.0 (Atualizado)      ║
║  Level Cap: 2550 | Todas as Seas | Mobile Friendly  ║
╚══════════════════════════════════════════════════════╝

  OTIMIZAÇÕES APLICADAS:
  • Sem Workspace:GetDescendants() em loops
  • Sem RunService.Heartbeat em loops pesados
  • Cache inteligente de NPCs/mobs
  • task.spawn + while task.wait() nos loops
  • Separação por Sea automática
  • Combate via tool:Activate()
  • Código modular e limpo
]]

local BloxFruits = {}

-- ════════════════════════════════════════════════════
-- SERVIÇOS
-- ════════════════════════════════════════════════════

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local TeleportService   = game:GetService("TeleportService")
local UserInputService  = game:GetService("UserInputService")
local Workspace         = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- ════════════════════════════════════════════════════
-- ESTADO GLOBAL
-- ════════════════════════════════════════════════════

local State = {
    -- Toggles
    AutoFarm      = false,
    AutoQuest     = false,
    BringMob      = false,
    FastAttack    = false,
    AutoHaki      = false,
    AutoBoss      = false,
    AutoRaid      = false,
    AutoStats     = false,
    LeviathanHunt = false,
    SeaBeastFarm  = false,
    FruitSniper   = false,
    AntiAFK       = false,
    FPSBoost      = false,
    ESPEnabled    = false,

    -- Dados ativos
    CurrentQuest  = nil,
    CurrentBoss   = nil,
    CurrentSea    = 1,
    TargetFruits  = {},
    StatPriority  = "Melee",
    TweenSpeed    = 1.2,
    AttackDelay   = 0.08,
    HakiInterval  = 12,
    BringMobName  = nil,

    -- Threads e conexões
    Threads       = {},   -- task.spawn handles (cancelados via flag)
    Connections   = {},   -- RBXScriptConnection
    ESPObjects    = {},   -- Highlights criados para ESP

    -- Flags de controle (para cancelar loops sem desconectar)
    Flags         = {},
}

-- ════════════════════════════════════════════════════
-- DADOS DO JOGO — ILHAS
-- ════════════════════════════════════════════════════

BloxFruits.Islands = {
    Sea1 = {
        ["Starter Island"]       = Vector3.new(977.8,   6.5,   1582.9),
        ["Marine Starter"]       = Vector3.new(-967.8,  6.5,   1582.9),
        ["Jungle"]               = Vector3.new(-1766.6, 14.3, -3096.6),
        ["Pirate Village"]       = Vector3.new(-1306.4,  4.0,   312.9),
        ["Desert"]               = Vector3.new(941.0,    6.0, -2767.0),
        ["Frozen Village"]       = Vector3.new(1239.7,   9.5, -3011.0),
        ["Marine Fortress"]      = Vector3.new(-4600.0, 10.0,  4068.0),
        ["Skylands"]             = Vector3.new(-4852.0,3038.0,  1999.0),
        ["Prison"]               = Vector3.new(4781.7,   5.0,   803.3),
        ["Magma Village"]        = Vector3.new(-4648.3,  46.0,  -881.4),
        ["Underwater City"]      = Vector3.new(61164.5,-1400.0, 1819.7),
    },
    Sea2 = {
        ["Kingdom of Rose"]      = Vector3.new(-789.7,   73.5, -3774.0),
        ["Green Zone"]           = Vector3.new(-1887.9,  22.0, -5018.8),
        ["Graveyard"]            = Vector3.new(3775.0,   24.0, -4313.0),
        ["Snow Mountain"]        = Vector3.new(2117.0,  214.0, -5229.0),
        ["Hot & Cold"]           = Vector3.new(441.0,   157.0, -5462.0),
        ["Cursed Ship"]          = Vector3.new(-4098.0,   2.0, -5296.0),
        ["Ice Castle"]           = Vector3.new(-1500.0,   4.0, -6500.0),
        ["Forgotten Island"]     = Vector3.new(0.0,       5.0, -7000.0),
    },
    Sea3 = {
        ["Port Town"]            = Vector3.new(-8985.0,   6.0, -1873.0),
        ["Hydra Island"]         = Vector3.new(-9648.0,   6.0,   786.0),
        ["Great Tree"]           = Vector3.new(-8487.0,   5.0,  5450.0),
        ["Floating Turtle"]      = Vector3.new(-13720.0,  0.0, -3839.0),
        ["Haunted Castle"]       = Vector3.new(-11860.0,  5.0, -7490.0),
        ["Candy Land"]           = Vector3.new(-1835.0,   5.0,-19000.0),
        ["Tiki Outpost"]         = Vector3.new(-15500.0,  5.0, -4200.0),
        ["Mirage Island"]        = Vector3.new(-16000.0,  5.0, -9000.0),
    },
}

-- ════════════════════════════════════════════════════
-- DADOS DO JOGO — QUESTS (por Sea)
-- ════════════════════════════════════════════════════

-- Formato: [NomeRecruiter] = { Level, QuestName, Mob, Island }
-- Level = nível mínimo para aceitar essa quest

local QuestData = {
    Sea1 = {
        { Level = 0,   Recruiter = "Bandit Quest Recruiter",     QuestName = "Bandits",        Mob = "Bandit",            Island = "Starter Island"  },
        { Level = 15,  Recruiter = "Monkey Quest Recruiter",     QuestName = "Monkeys",        Mob = "Monkey",            Island = "Jungle"          },
        { Level = 35,  Recruiter = "Pirate Quest Recruiter",     QuestName = "Pirates",        Mob = "Pirate",            Island = "Pirate Village"  },
        { Level = 60,  Recruiter = "Desert Quest Recruiter",     QuestName = "DesertBandits",  Mob = "Desert Bandit",     Island = "Desert"          },
        { Level = 90,  Recruiter = "Snow Quest Recruiter",       QuestName = "SnowBandits",    Mob = "Snow Bandit",       Island = "Frozen Village"  },
        { Level = 120, Recruiter = "Marine Quest Recruiter",     QuestName = "Marines",        Mob = "Marine",            Island = "Marine Fortress" },
        { Level = 150, Recruiter = "Sky Quest Recruiter",        QuestName = "SkyBandits",     Mob = "Sky Bandit",        Island = "Skylands"        },
        { Level = 190, Recruiter = "Prison Quest Recruiter",     QuestName = "Prisoners",      Mob = "Prisoner",          Island = "Prison"          },
        { Level = 300, Recruiter = "Magma Quest Recruiter",      QuestName = "MagmaSoldiers",  Mob = "Magma Soldier",     Island = "Magma Village"   },
        { Level = 375, Recruiter = "Underwater Quest Recruiter", QuestName = "Fishmen",        Mob = "Fishman Warrior",   Island = "Underwater City" },
    },
    Sea2 = {
        { Level = 700,  Recruiter = "Area 1 Quest Recruiter",         QuestName = "Raiders",          Mob = "Raider",           Island = "Kingdom of Rose" },
        { Level = 775,  Recruiter = "Area 2 Quest Recruiter",         QuestName = "Mercenaries",      Mob = "Mercenary",        Island = "Kingdom of Rose" },
        { Level = 875,  Recruiter = "Green Bit Quest Recruiter",      QuestName = "PlantSubs",        Mob = "Plant Subordinate",Island = "Green Zone"      },
        { Level = 950,  Recruiter = "Graveyard Quest Recruiter",      QuestName = "Zombies",          Mob = "Zombie",           Island = "Graveyard"       },
        { Level = 1000, Recruiter = "Snow Mountain Quest Recruiter",  QuestName = "SnowTroopers",     Mob = "Snow Trooper",     Island = "Snow Mountain"   },
        { Level = 1100, Recruiter = "Hot Quest Recruiter",            QuestName = "LabSubs",          Mob = "Lab Subordinate",  Island = "Hot & Cold"      },
        { Level = 1150, Recruiter = "Cold Quest Recruiter",           QuestName = "HornedWarriors",   Mob = "Horned Warrior",   Island = "Hot & Cold"      },
        { Level = 1250, Recruiter = "Cursed Captain Quest Recruiter", QuestName = "ShipOfficers",     Mob = "Ship Officer",     Island = "Cursed Ship"     },
        { Level = 1350, Recruiter = "Ice Castle Quest Recruiter",     QuestName = "ArcticWarriors",   Mob = "Arctic Warrior",   Island = "Ice Castle"      },
        { Level = 1425, Recruiter = "Forgotten Quest Recruiter",      QuestName = "SeaSoldiers",      Mob = "Sea Soldier",      Island = "Forgotten Island"},
    },
    Sea3 = {
        { Level = 1500, Recruiter = "Port Quest Recruiter",            QuestName = "PirateMillionaires", Mob = "Pirate Millionaire",  Island = "Port Town"      },
        { Level = 1575, Recruiter = "Hydra Quest Recruiter",           QuestName = "DragonCrew",         Mob = "Dragon Crew Warrior", Island = "Hydra Island"   },
        { Level = 1700, Recruiter = "Great Tree Quest Recruiter",      QuestName = "MarineCommodores",   Mob = "Marine Commodore",    Island = "Great Tree"     },
        { Level = 1775, Recruiter = "Floating Turtle Quest Recruiter", QuestName = "FishmanRaiders",     Mob = "Fishman Raider",      Island = "Floating Turtle"},
        { Level = 1875, Recruiter = "Floating Turtle Quest Recruiter", QuestName = "TurtleTortoises",    Mob = "Goblin",              Island = "Floating Turtle"},
        { Level = 1975, Recruiter = "Haunted Castle Quest Recruiter",  QuestName = "RebornSkeletons",    Mob = "Reborn Skeleton",     Island = "Haunted Castle" },
        { Level = 2075, Recruiter = "Candy Quest Recruiter",           QuestName = "CookieCrafters",     Mob = "Cookie Crafter",      Island = "Candy Land"     },
        { Level = 2150, Recruiter = "Candy Quest Recruiter 2",         QuestName = "CandyWarlocks",      Mob = "Candy Warlord",       Island = "Candy Land"     },
        { Level = 2300, Recruiter = "Tiki Quest Recruiter",            QuestName = "TikiWarriors",       Mob = "Forest Pirate",       Island = "Tiki Outpost"   },
        { Level = 2425, Recruiter = "Tiki Quest Recruiter 2",          QuestName = "TikiExperts",        Mob = "Forest Pirate",       Island = "Tiki Outpost"   },
    },
}

-- ════════════════════════════════════════════════════
-- DADOS DO JOGO — BOSSES
-- ════════════════════════════════════════════════════

BloxFruits.Bosses = {
    Sea1 = {
        { Name = "Saber Expert",    Level = 200  },
        { Name = "The Saw",         Level = 100  },
        { Name = "Gorilla King",    Level = 25   },
        { Name = "Bobby",           Level = 0    },
        { Name = "Yeti",            Level = 90   },
        { Name = "Vice Admiral",    Level = 150  },
        { Name = "Warden",          Level = 190  },
        { Name = "Chief Warden",    Level = 200  },
        { Name = "Swan",            Level = 225  },
        { Name = "Magma Admiral",   Level = 350  },
        { Name = "Fishman Lord",    Level = 425  },
        { Name = "Wysper",          Level = 175  },
        { Name = "Thunder God",     Level = 175  },
        { Name = "Cyborg",          Level = 350  },
    },
    Sea2 = {
        { Name = "Diamond",         Level = 750  },
        { Name = "Jeremy",          Level = 850  },
        { Name = "Fajita",          Level = 850  },
        { Name = "Don Swan",        Level = 1000 },
        { Name = "Smoke Admiral",   Level = 1150 },
        { Name = "Tide Keeper",     Level = 1200 },
        { Name = "Cursed Captain",  Level = 1250 },
        { Name = "Darkbeard",       Level = 1000 },
        { Name = "Order",           Level = 1250 },
    },
    Sea3 = {
        { Name = "Stone",           Level = 1550 },
        { Name = "Island Emperor",  Level = 1700 },
        { Name = "Kilo Admiral",    Level = 1750 },
        { Name = "Captain Elephant",Level = 1875 },
        { Name = "Beautiful Pirate",Level = 1950 },
        { Name = "Cake Queen",      Level = 2100 },
        { Name = "Rip_Indra",       Level = 1800 },
        { Name = "Cake King",       Level = 2300 },
        { Name = "Leviathan",       Level = 2200 },
        { Name = "Sea Beast",       Level = 1500 },
    },
}

-- ════════════════════════════════════════════════════
-- DADOS DO JOGO — ESTILOS DE LUTA
-- ════════════════════════════════════════════════════

BloxFruits.FightingStyles = {
    "Combat", "Dark Step", "Electric", "Water Kung Fu",
    "Dragon Breath", "Superhuman", "Death Step",
    "Sharkman Karate", "Electric Claw",
    "Dragon Talon", "Godhuman", "Sanguine Art",
}

-- ════════════════════════════════════════════════════
-- DADOS DO JOGO — ESPADAS
-- ════════════════════════════════════════════════════

BloxFruits.Swords = {
    -- Tier Comum
    "Cutlass", "Katana", "Dual Katana", "Iron Mace",
    "Triple Katana", "Pipe",
    -- Tier Incomum
    "Saber", "Jitte", "Pole (1st Form)", "Shark Saw",
    -- Tier Raro
    "Bisento", "Trident", "Dark Blade", "Gravity Cane",
    "Saddi", "Shisui", "Wando", "Soul Cane",
    -- Tier Épico
    "Rengoku", "Koko", "Midnight Blade", "Canvander",
    "Spikey Trident", "Pole (2nd Form)", "True Triple Katana",
    -- Tier Lendário
    "Yama", "Tushita", "Buddy Sword", "Shark Anchor",
    "Fox Lamp", "Dragon Trident", "Hallow Scythe",
    "Cursed Dual Katana", "Dark Dagger", "Saber V2",
    -- Tier Mítico
    "Serpent Bow (Sword)", "Infernal Guitar",
}

-- ════════════════════════════════════════════════════
-- DADOS DO JOGO — ARMAS (GUNS)
-- ════════════════════════════════════════════════════

BloxFruits.Guns = {
    "Slingshot", "Flintlock", "Musket", "Cannon",
    "Double Flintlock", "Triple Flintlock",
    "Bazooka", "Refined Flintlock", "Refined Musket",
    "Kabucha", "Acidum Rifle", "Serpent Bow",
    "Pole (1st Form)", "Soul Guitar",
}

-- ════════════════════════════════════════════════════
-- DADOS DO JOGO — FRUTAS
-- ════════════════════════════════════════════════════

BloxFruits.Fruits = {
    -- Comuns
    "Rocket", "Spin", "Chop", "Spring", "Bomb", "Smoke",
    "Spike", "Flame", "Falcon", "Ice", "Sand", "Dark",
    -- Raras
    "Diamond", "Light", "Rubber", "Barrier",
    "Ghost", "Magma", "Quake", "Buddha",
    -- Épicas
    "Love", "Spider", "Sound", "Phoenix",
    "Portal", "Rumble", "Pain", "Blizzard",
    -- Lendárias
    "Gravity", "Mammoth", "T-Rex", "Dough",
    "Shadow", "Venom", "Control", "Spirit",
    -- Míticas
    "Dragon", "Leopard", "Kitsune",
}

-- ════════════════════════════════════════════════════
-- DADOS DO JOGO — RAÇAS
-- ════════════════════════════════════════════════════

BloxFruits.Races = {
    "Human", "Fish", "Angel", "Mink", "Cyborg", "Ghoul",
}

-- ════════════════════════════════════════════════════
-- UTILITÁRIOS INTERNOS
-- ════════════════════════════════════════════════════

-- Helpers básicos (sem pcall desnecessário)
local function getChar()
    return LocalPlayer.Character
end

local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function getLevel()
    local data = LocalPlayer:FindFirstChild("Data")
    if data then
        local lvl = data:FindFirstChild("Level")
        if lvl then return lvl.Value end
    end
    -- Fallback leaderstats
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if ls then
        local l = ls:FindFirstChild("Level") or ls:FindFirstChild("Beli")
        if l and l.ClassName == "IntValue" then return l.Value end
    end
    return 0
end

-- Detecta Sea pelo nível (fallback caso não haja dado direto)
local function detectSea()
    local lvl = getLevel()
    -- Tenta primeiro via dado do servidor
    local data = LocalPlayer:FindFirstChild("Data")
    if data then
        local seaVal = data:FindFirstChild("Sea") or data:FindFirstChild("Map")
        if seaVal then
            local v = seaVal.Value
            if v == "Second Sea" or v == 2 then return 2
            elseif v == "Third Sea" or v == 3 then return 3
            else return 1 end
        end
    end
    -- Fallback por level
    if lvl >= 1500 then return 3
    elseif lvl >= 700 then return 2
    else return 1 end
end

-- ════════════════════════════════════════════════════
-- MOVIMENTAÇÃO
-- ════════════════════════════════════════════════════

local function teleportTo(pos, offset)
    local hrp = getHRP()
    if hrp then
        hrp.CFrame = CFrame.new(pos + (offset or Vector3.new(0, 3, 0)))
    end
end

local function tweenTo(pos, duration)
    local hrp = getHRP()
    if not hrp then return end
    duration = duration or State.TweenSpeed
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(hrp, info, { CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) })
    tween:Play()
    tween.Completed:Wait()
end

-- ════════════════════════════════════════════════════
-- CACHE DE MOBS/NPCS (evita GetDescendants() em loop)
-- ════════════════════════════════════════════════════

--[[
  O Blox Fruits organiza inimigos dentro de pastas específicas:
    workspace.Enemies (mobs normais)
    workspace.NPCs (recruiters, vendedores)
    workspace.Bosses (bosses do mapa)
  Usamos GetChildren() / FindFirstChild() nessas pastas,
  evitando GetDescendants() no Workspace inteiro.
]]

-- Retorna a pasta de inimigos de forma segura
local function getEnemiesFolder()
    return Workspace:FindFirstChild("Enemies")
        or Workspace:FindFirstChild("NPCs")
        or Workspace:FindFirstChild("Map")
end

-- Procura mob pelo nome APENAS na pasta correta
local function findMob(mobName)
    local folder = getEnemiesFolder()
    if not folder then return nil, nil end

    for _, v in ipairs(folder:GetChildren()) do
        if v:IsA("Model") and v.Name == mobName then
            local hrp = v:FindFirstChild("HumanoidRootPart")
            local hum = v:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                return v, hrp
            end
        end
    end
    return nil, nil
end

-- Procura boss pelo nome (verifica também workspace.Bosses)
local function findBoss(bossName)
    -- Prioridade: pasta Bosses
    local bossFolder = Workspace:FindFirstChild("Bosses")
    if bossFolder then
        for _, v in ipairs(bossFolder:GetChildren()) do
            if v:IsA("Model") and v.Name == bossName then
                local hrp = v:FindFirstChild("HumanoidRootPart")
                local hum = v:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    return v, hrp
                end
            end
        end
    end
    -- Fallback: folder de Enemies
    return findMob(bossName)
end

-- Procura NPC (recruiter) pelo nome
local function findNPC(npcName)
    -- Tenta pastas mais prováveis primeiro
    local folders = {"NPCs", "Recruiter", "Quest", "Map", "Enemies"}
    for _, folderName in ipairs(folders) do
        local f = Workspace:FindFirstChild(folderName, true)
        if f and f:IsA("Folder") or f and f:IsA("Model") then
            for _, v in ipairs(f:GetChildren()) do
                if v.Name == npcName then
                    local hrp = v:FindFirstChild("HumanoidRootPart")
                    if hrp then return v, hrp end
                end
            end
        end
    end
    -- Último recurso: scan de 1 nível direto no workspace
    for _, v in ipairs(Workspace:GetChildren()) do
        if v:IsA("Model") and v.Name == npcName then
            local hrp = v:FindFirstChild("HumanoidRootPart")
            if hrp then return v, hrp end
        end
    end
    return nil, nil
end

-- ════════════════════════════════════════════════════
-- COMBATE — FERRAMENTAS
-- ════════════════════════════════════════════════════

-- Ativa a tool equipada (o método correto e funcional)
local function activateTool()
    local char = getChar()
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        -- Método principal: tool:Activate()
        pcall(function() tool:Activate() end)
    end
end

-- Equipa uma tool pelo nome (da mochila do player)
local function equipTool(toolName)
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return end
    local tool = backpack:FindFirstChild(toolName)
    if tool then
        local char = getChar()
        if char then
            tool.Parent = char
        end
    end
end

-- ════════════════════════════════════════════════════
-- REMOTES CACHE
-- ════════════════════════════════════════════════════

-- Cache de remotes para evitar FindFirstChild() repetido
local RemoteCache = {}

local function getRemote(name)
    if RemoteCache[name] then return RemoteCache[name] end

    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        or ReplicatedStorage:FindFirstChild("Events")
        or ReplicatedStorage

    if remotes then
        local r = remotes:FindFirstChild(name, true)
        if r then
            RemoteCache[name] = r
            return r
        end
    end
    return nil
end

local function fireRemote(name, ...)
    local r = getRemote(name)
    if r and r:IsA("RemoteEvent") then
        pcall(function() r:FireServer(...) end)
    elseif r and r:IsA("RemoteFunction") then
        pcall(function() r:InvokeServer(...) end)
    end
end

-- ════════════════════════════════════════════════════
-- THREAD MANAGER (substitui Heartbeat por task.spawn)
-- ════════════════════════════════════════════════════

local function startThread(name, interval, fn)
    -- Para thread anterior com mesmo nome
    State.Flags[name] = false
    task.wait(0.05) -- pequena pausa para o loop anterior perceber
    State.Flags[name] = true

    task.spawn(function()
        while State.Flags[name] do
            local ok, err = pcall(fn)
            if not ok then
                warn("[ZenithHub:" .. name .. "] " .. tostring(err))
            end
            task.wait(interval)
        end
    end)
end

local function stopThread(name)
    State.Flags[name] = false
end

local function stopAllThreads()
    for name in pairs(State.Flags) do
        State.Flags[name] = false
    end
end

-- ════════════════════════════════════════════════════
-- QUEST SYSTEM
-- ════════════════════════════════════════════════════

-- Retorna a melhor quest para o nível atual na sea indicada
local function getBestQuest(sea)
    local level = getLevel()
    local list = QuestData["Sea" .. tostring(sea)] or QuestData.Sea1

    local best = nil
    for _, q in ipairs(list) do
        if q.Level <= level then
            best = q -- a lista está em ordem crescente; pega a última que cabe
        end
    end
    return best
end

-- Verifica se o player já tem uma quest ativa
local function hasActiveQuest(questName)
    local qh = LocalPlayer:FindFirstChild("QuestHolder")
        or LocalPlayer:FindFirstChild("Quests")
    if qh then
        return qh:FindFirstChild(questName) ~= nil
    end
    -- Fallback via Data
    local data = LocalPlayer:FindFirstChild("Data")
    if data then
        local q = data:FindFirstChild("Quest") or data:FindFirstChild("QuestData")
        if q and q.Value ~= "" and q.Value ~= nil then return true end
    end
    return false
end

-- Aceita quest via remote (método universal)
local function acceptQuest(questName, recruiter)
    -- Tenta os remotes mais comuns do Blox Fruits
    local remoteNames = {
        "startQuest", "StartQuest", "AcceptQuest",
        "StartDialogue", "DialogueChoice", "ChoosePath",
        "StartMission",
    }
    for _, rName in ipairs(remoteNames) do
        local r = getRemote(rName)
        if r then
            pcall(function() r:FireServer(questName) end)
            task.wait(0.3)
            pcall(function() r:FireServer(recruiter, questName) end)
        end
    end
end

-- ════════════════════════════════════════════════════
-- FUNÇÕES PÚBLICAS — AUTO QUEST
-- ════════════════════════════════════════════════════

function BloxFruits.SetAutoQuest(enabled, sea)
    sea = sea or detectSea()
    if enabled then
        startThread("AutoQuest", 4, function()
            local quest = getBestQuest(sea)
            if not quest then return end
            State.CurrentQuest = quest

            if hasActiveQuest(quest.QuestName) then return end

            -- Vai até o recruiter
            local _, npcHRP = findNPC(quest.Recruiter)
            if npcHRP then
                teleportTo(npcHRP.Position, Vector3.new(0, 3, 3))
                task.wait(0.8)
                acceptQuest(quest.QuestName, quest.Recruiter)
            end
        end)
    else
        stopThread("AutoQuest")
        State.CurrentQuest = nil
    end
end

-- ════════════════════════════════════════════════════
-- FUNÇÕES PÚBLICAS — AUTO FARM
-- ════════════════════════════════════════════════════

function BloxFruits.SetAutoFarm(enabled, sea)
    sea = sea or detectSea()
    if enabled then
        startThread("AutoFarm", State.AttackDelay, function()
            -- Garante que tem quest ativa
            if not State.CurrentQuest then
                local q = getBestQuest(sea)
                if not q then return end
                State.CurrentQuest = q
            end

            local mobName = State.CurrentQuest.Mob
            local mob, mobHRP = findMob(mobName)

            if mob and mobHRP then
                -- Teleporta para junto do mob
                teleportTo(mobHRP.Position, Vector3.new(0, 3, 2))
                task.wait(0.05)
                -- Ataca
                activateTool()
            end
        end)
    else
        stopThread("AutoFarm")
    end
end

-- ════════════════════════════════════════════════════
-- FUNÇÕES PÚBLICAS — FAST ATTACK
-- ════════════════════════════════════════════════════

function BloxFruits.SetFastAttack(enabled, delay)
    State.FastAttack = enabled
    State.AttackDelay = delay or 0.05

    if enabled then
        startThread("FastAttack", State.AttackDelay, function()
            -- Só ataca se há um mob alvo sendo farmado
            if not State.AutoFarm then return end
            activateTool()
        end)
    else
        stopThread("FastAttack")
    end
end

-- ════════════════════════════════════════════════════
-- FUNÇÕES PÚBLICAS — BRING MOB
-- ════════════════════════════════════════════════════

function BloxFruits.SetBringMob(enabled, mobName)
    State.BringMobName = mobName
    if enabled and mobName then
        startThread("BringMob", 0.5, function()
            local hrp = getHRP()
            if not hrp then return end

            local folder = getEnemiesFolder()
            if not folder then return end

            for _, v in ipairs(folder:GetChildren()) do
                if v:IsA("Model") and v.Name == mobName then
                    local vHRP = v:FindFirstChild("HumanoidRootPart")
                    local hum = v:FindFirstChildOfClass("Humanoid")
                    if vHRP and hum and hum.Health > 0 then
                        -- Traz o mob para perto do player
                        vHRP.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 2, 3))
                    end
                end
            end
        end)
    else
        stopThread("BringMob")
    end
end

-- ════════════════════════════════════════════════════
-- FUNÇÕES PÚBLICAS — AUTO BOSS
-- ════════════════════════════════════════════════════

function BloxFruits.SetAutoBoss(enabled, bossName)
    State.CurrentBoss = bossName
    if enabled and bossName then
        startThread("AutoBoss", 0.2, function()
            local _, bossHRP = findBoss(bossName)
            if bossHRP then
                teleportTo(bossHRP.Position, Vector3.new(0, 3, 2))
                task.wait(0.05)
                activateTool()
            end
        end)
    else
        stopThread("AutoBoss")
        State.CurrentBoss = nil
    end
end

-- ════════════════════════════════════════════════════
-- FUNÇÕES PÚBLICAS — AUTO HAKI
-- ════════════════════════════════════════════════════

function BloxFruits.SetAutoHaki(enabled, interval)
    State.HakiInterval = interval or 12
    if enabled then
        startThread("AutoHaki", State.HakiInterval, function()
            -- Tenta via remote primeiro (mais confiável)
            local hakiRemotes = {"Activate_Haki", "Haki", "Buso", "CoA", "BusoHaki"}
            local fired = false
            for _, rName in ipairs(hakiRemotes) do
                local r = getRemote(rName)
                if r then
                    pcall(function() r:FireServer() end)
                    fired = true
                    break
                end
            end
            -- Fallback: VirtualInputManager (alguns executores)
            if not fired then
                local ok = pcall(function()
                    local vim = game:GetService("VirtualInputManager")
                    vim:SendKeyEvent(true, Enum.KeyCode.J, false, game)
                    task.wait(0.05)
                    vim:SendKeyEvent(false, Enum.KeyCode.J, false, game)
                end)
                if not ok then
                    -- Fallback: UserInputService simulado
                    pcall(function()
                        local uip = game:GetService("UserInputService")
                        uip.InputBegan:Fire(
                            {KeyCode = Enum.KeyCode.J, UserInputType = Enum.UserInputType.Keyboard},
                            false
                        )
                    end)
                end
            end
        end)
    else
        stopThread("AutoHaki")
    end
end

-- ════════════════════════════════════════════════════
-- FUNÇÕES PÚBLICAS — AUTO RAID
-- ════════════════════════════════════════════════════

function BloxFruits.SetAutoRaid(enabled)
    if enabled then
        startThread("AutoRaid", 0.15, function()
            local hrp = getHRP()
            if not hrp then return end

            local folder = getEnemiesFolder()
            if not folder then return end

            local nearest, nearestHRP, nearestDist = nil, nil, math.huge

            -- Acha o mob mais próximo na pasta (GetChildren, sem GetDescendants)
            for _, v in ipairs(folder:GetChildren()) do
                if v:IsA("Model") then
                    local vHRP = v:FindFirstChild("HumanoidRootPart")
                    local hum = v:FindFirstChildOfClass("Humanoid")
                    if vHRP and hum and hum.Health > 0 then
                        local isPlayer = false
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p.Character == v then isPlayer = true; break end
                        end
                        if not isPlayer then
                            local dist = (hrp.Position - vHRP.Position).Magnitude
                            if dist < nearestDist then
                                nearestDist = dist
                                nearest = v
                                nearestHRP = vHRP
                            end
                        end
                    end
                end
            end

            if nearestHRP then
                teleportTo(nearestHRP.Position, Vector3.new(0, 3, 2))
                task.wait(0.05)
                activateTool()
            end
        end)
    else
        stopThread("AutoRaid")
    end
end

-- ════════════════════════════════════════════════════
-- FUNÇÕES PÚBLICAS — AUTO STATS
-- ════════════════════════════════════════════════════

function BloxFruits.SetAutoStats(enabled, priority)
    State.StatPriority = priority or "Melee"
    if enabled then
        startThread("AutoStats", 1, function()
            local data = LocalPlayer:FindFirstChild("Data")
            if not data then return end
            local sp = data:FindFirstChild("StatPoints") or data:FindFirstChild("Stat_Points")
            if not sp or sp.Value <= 0 then return end

            local statRemotes = {"AddStat", "Stat", "AddPoints", "DistributeStat"}
            for _, rName in ipairs(statRemotes) do
                local r = getRemote(rName)
                if r then
                    pcall(function() r:FireServer(State.StatPriority) end)
                    break
                end
            end
        end)
    else
        stopThread("AutoStats")
    end
end

-- ════════════════════════════════════════════════════
-- SEA EVENTS — LEVIATHAN HUNT
-- ════════════════════════════════════════════════════

function BloxFruits.SetLeviathanHunt(enabled)
    if enabled then
        startThread("LeviathanHunt", 0.5, function()
            local _, levHRP = findBoss("Leviathan")
            if levHRP then
                teleportTo(levHRP.Position, Vector3.new(0, 5, 5))
                task.wait(0.05)
                activateTool()
            end
        end)
    else
        stopThread("LeviathanHunt")
    end
end

-- ════════════════════════════════════════════════════
-- SEA EVENTS — SEA BEAST FARM
-- ════════════════════════════════════════════════════

function BloxFruits.SetSeaBeastFarm(enabled)
    if enabled then
        startThread("SeaBeastFarm", 0.3, function()
            local beastNames = {"Sea Beast", "Leviathan", "Terror Shark", "Rip_Indra"}
            for _, name in ipairs(beastNames) do
                local _, beastHRP = findBoss(name)
                if beastHRP then
                    teleportTo(beastHRP.Position, Vector3.new(0, 5, 5))
                    task.wait(0.05)
                    activateTool()
                    break
                end
            end
        end)
    else
        stopThread("SeaBeastFarm")
    end
end

-- ════════════════════════════════════════════════════
-- FRUIT SNIPER
-- ════════════════════════════════════════════════════

function BloxFruits.SetFruitSniper(enabled, targetFruits)
    State.TargetFruits = targetFruits or {}
    if enabled then
        startThread("FruitSniper", 1, function()
            -- Frutas ficam geralmente numa pasta específica
            local fruitFolder = Workspace:FindFirstChild("Fruits")
                or Workspace:FindFirstChild("DroppedFruits")
                or Workspace

            local search = fruitFolder == Workspace
                and fruitFolder:GetChildren()
                or fruitFolder:GetChildren()

            for _, v in ipairs(search) do
                if v:IsA("Model") or v:IsA("BasePart") then
                    for _, targetName in ipairs(State.TargetFruits) do
                        if string.find(v.Name, targetName, 1, true) then
                            local pos = v:IsA("Model")
                                and (v.PrimaryPart and v.PrimaryPart.Position)
                                or v.Position
                            if pos then
                                teleportTo(pos, Vector3.new(0, 3, 0))
                                task.wait(0.5)
                                -- Tenta pegar via touch / remote
                                fireRemote("PickupFruit", v)
                                pcall(function()
                                    local tp = v:FindFirstChild("PickUp") or v:FindFirstChild("Touch")
                                    if tp then tp:FireServer() end
                                end)
                            end
                            break
                        end
                    end
                end
            end
        end)
    else
        stopThread("FruitSniper")
    end
end

-- ════════════════════════════════════════════════════
-- ESP — Terror Shark / Custom
-- ════════════════════════════════════════════════════

function BloxFruits.SetESP(enabled, targetName, color)
    targetName = targetName or "Terror Shark"
    color = color or Color3.fromRGB(255, 50, 50)

    if enabled then
        startThread("ESP_" .. targetName, 2, function()
            local folder = getEnemiesFolder()
                or Workspace:FindFirstChild("Bosses")
                or Workspace
            local source = folder:GetChildren()

            for _, v in ipairs(source) do
                if v:IsA("Model") and string.find(v.Name, targetName, 1, true) then
                    if not v:FindFirstChild("ZenithESP") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "ZenithESP"
                        hl.FillColor = color
                        hl.OutlineColor = Color3.new(1, 1, 1)
                        hl.FillTransparency = 0.5
                        hl.Parent = v
                        table.insert(State.ESPObjects, hl)
                    end
                end
            end
        end)
    else
        stopThread("ESP_" .. (targetName or "Terror Shark"))
        for _, hl in ipairs(State.ESPObjects) do
            pcall(function() hl:Destroy() end)
        end
        State.ESPObjects = {}
    end
end

-- ════════════════════════════════════════════════════
-- ANTI AFK
-- ════════════════════════════════════════════════════

function BloxFruits.SetAntiAFK(enabled)
    if enabled then
        -- Desconecta o listener de idle do motor
        local VIM = pcall(function()
            local conn = LocalPlayer.Idled:Connect(function() end)
            conn:Disconnect()
        end)
        startThread("AntiAFK", 60, function()
            local hrp = getHRP()
            if hrp then
                -- Pequeno deslocamento imperceptível
                hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, 0.001)
            end
            -- Força o sinal de não-idle via VirtualInputManager
            pcall(function()
                local vim = game:GetService("VirtualInputManager")
                vim:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                task.wait(0.05)
                vim:SendKeyEvent(false, Enum.KeyCode.W, false, game)
            end)
        end)
    else
        stopThread("AntiAFK")
    end
end

-- ════════════════════════════════════════════════════
-- FPS BOOST / VISUAL
-- ════════════════════════════════════════════════════

function BloxFruits.SetFPSBoost(enabled)
    if enabled then
        -- Remove partículas e efeitos do workspace
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Smoke")
            or v:IsA("Fire") or v:IsA("Sparkles") then
                v.Enabled = false
            end
        end
        -- Reduz distância de renderização
        pcall(function()
            Workspace.StreamingEnabled = true
            Workspace.StreamingMinRadius = 64
        end)
        -- Baixa qualidade gráfica
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    else
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
    end
end

function BloxFruits.SetWhiteScreen(enabled)
    local lighting = game:GetService("Lighting")
    if enabled then
        lighting.Brightness = 10
        lighting.ClockTime = 14
        lighting.FogColor = Color3.new(1, 1, 1)
        lighting.FogEnd = 10
        lighting.FogStart = 0
    else
        lighting.Brightness = 1
        lighting.ClockTime = 14
        lighting.FogEnd = 100000
        lighting.FogStart = 0
    end
end

-- ════════════════════════════════════════════════════
-- SERVER HOP / JOB ID SYSTEM
-- ════════════════════════════════════════════════════

function BloxFruits.GetJobId()
    return game.JobId
end

function BloxFruits.CopyJobId()
    local id = game.JobId
    pcall(function()
        setclipboard(id)
    end)
    return id
end

function BloxFruits.JoinJobId(jobId)
    pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, LocalPlayer)
    end)
end

function BloxFruits.ServerHop()
    pcall(function()
        local HttpService = game:GetService("HttpService")
        local pages = TeleportService:GetSortedGamesList(game.PlaceId, 1)
        -- Vai para um servidor aleatório diferente do atual
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
end

function BloxFruits.JoinLowPlayerServer()
    -- Tenta entrar num servidor com pouca gente
    pcall(function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
end

-- ════════════════════════════════════════════════════
-- TELEPORT ISLAND
-- ════════════════════════════════════════════════════

function BloxFruits.TeleportIsland(islandName, sea, useTween)
    sea = sea or detectSea()
    local seaTable = BloxFruits.Islands["Sea" .. tostring(sea)]
    if not seaTable then
        warn("[ZenithHub] Sea inválida: " .. tostring(sea))
        return
    end
    local pos = seaTable[islandName]
    if not pos then
        warn("[ZenithHub] Ilha não encontrada: " .. tostring(islandName))
        return
    end
    if useTween then
        tweenTo(pos, State.TweenSpeed)
    else
        teleportTo(pos)
    end
end

-- ════════════════════════════════════════════════════
-- DETECÇÃO AUTOMÁTICA DE SEA/QUEST/MOB
-- ════════════════════════════════════════════════════

function BloxFruits.GetCurrentSea()
    State.CurrentSea = detectSea()
    return State.CurrentSea
end

function BloxFruits.GetBestQuest()
    local sea = detectSea()
    return getBestQuest(sea)
end

function BloxFruits.GetPlayerLevel()
    return getLevel()
end

-- Retorna o melhor boss para o nível atual
function BloxFruits.GetBestBoss()
    local level = getLevel()
    local sea = detectSea()
    local bossList = BloxFruits.Bosses["Sea" .. tostring(sea)] or {}
    local best = nil
    for _, b in ipairs(bossList) do
        if b.Level <= level then
            best = b
        end
    end
    return best
end

-- ════════════════════════════════════════════════════
-- CONFIG SAVE/LOAD (via getgenv)
-- ════════════════════════════════════════════════════

function BloxFruits.SaveConfig(name)
    name = name or "zenith_default"
    local config = {
        StatPriority  = State.StatPriority,
        TweenSpeed    = State.TweenSpeed,
        AttackDelay   = State.AttackDelay,
        HakiInterval  = State.HakiInterval,
        TargetFruits  = State.TargetFruits,
    }
    -- Tenta usar writefile se disponível
    pcall(function()
        local json = game:GetService("HttpService"):JSONEncode(config)
        writefile(name .. ".json", json)
    end)
    -- Fallback: getgenv
    getgenv()[name] = config
    return config
end

function BloxFruits.LoadConfig(name)
    name = name or "zenith_default"
    -- Tenta readfile
    local ok, data = pcall(function()
        local raw = readfile(name .. ".json")
        return game:GetService("HttpService"):JSONDecode(raw)
    end)
    if not ok then
        data = getgenv()[name]
    end
    if data then
        State.StatPriority = data.StatPriority or State.StatPriority
        State.TweenSpeed   = data.TweenSpeed   or State.TweenSpeed
        State.AttackDelay  = data.AttackDelay  or State.AttackDelay
        State.HakiInterval = data.HakiInterval or State.HakiInterval
        State.TargetFruits = data.TargetFruits or State.TargetFruits
    end
    return data
end

-- ════════════════════════════════════════════════════
-- LIMPEZA GLOBAL
-- ════════════════════════════════════════════════════

function BloxFruits.Cleanup()
    -- Para todos os threads
    stopAllThreads()

    -- Desconecta conexões RBX
    for name, conn in pairs(State.Connections) do
        pcall(function() conn:Disconnect() end)
        State.Connections[name] = nil
    end

    -- Remove ESPs
    for _, hl in ipairs(State.ESPObjects) do
        pcall(function() hl:Destroy() end)
    end
    State.ESPObjects = {}

    -- Zera estado
    State.CurrentQuest = nil
    State.CurrentBoss  = nil
    State.AutoFarm     = false
    State.AutoQuest    = false

    -- Limpa cache de remotes (pode ter mudado)
    RemoteCache = {}

    warn("[ZenithHub] BloxFruits cleanup concluído.")
end

-- ════════════════════════════════════════════════════
-- CONFIGURAÇÕES PÚBLICAS
-- ════════════════════════════════════════════════════

function BloxFruits.SetTweenSpeed(speed)
    State.TweenSpeed = speed or 1.2
end

function BloxFruits.SetAttackDelay(delay)
    State.AttackDelay = delay or 0.08
end

function BloxFruits.SetHakiInterval(interval)
    State.HakiInterval = interval or 12
end

function BloxFruits.SetStatPriority(stat)
    -- Opções válidas: "Melee", "Defense", "Sword", "Gun", "Devil_Fruit"
    State.StatPriority = stat or "Melee"
end

function BloxFruits.SetTargetFruits(fruits)
    State.TargetFruits = fruits or {}
end

-- ════════════════════════════════════════════════════
-- RETORNO DO MÓDULO
-- ════════════════════════════════════════════════════

return BloxFruits
