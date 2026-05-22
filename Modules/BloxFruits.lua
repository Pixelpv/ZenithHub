--[[
    ZenithHub - Modules/BloxFruits.lua
    Módulo completo para Blox Fruits
    Auto Farm, Bosses, Raids, Sea Events, Races/V4, Shop
    [Reescrito e otimizado]
]]

local BloxFruits = {}

-- ════════════════════════════════════════════
-- SERVIÇOS (cache local evita GetService repetido)
-- ════════════════════════════════════════════
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local Workspace         = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- ════════════════════════════════════════════
-- ESTADO INTERNO
-- ════════════════════════════════════════════
local State = {
    -- Flags de feature
    AutoFarm      = false,
    AutoQuest     = false,
    BringMob      = false,
    KillAura      = false,
    FastAttack    = false,
    AutoHaki      = false,
    AutoBoss      = false,
    AutoRaid      = false,
    AutoRaceV4    = false,
    FruitSniper   = false,
    LeviathanHunt = false,
    SeaBeastFarm  = false,
    TerrorSharkESP= false,
    -- Conexões ativas
    Connections   = {},
    -- Contexto de execução
    CurrentQuest  = nil,
    CurrentBoss   = nil,
}

-- ════════════════════════════════════════════
-- TABELAS DE QUESTS
-- ════════════════════════════════════════════

local QuestTables = {
    [1] = {
        ["Bandit Quest Recruiter"]     = { Level = 0,    QuestName = "Bandits",        Mob = "Bandit"            },
        ["Monkey Quest Recruiter"]     = { Level = 15,   QuestName = "Monkeys",        Mob = "Monkey"            },
        ["Pirate Quest Recruiter"]     = { Level = 35,   QuestName = "Pirates",        Mob = "Pirate"            },
        ["Desert Quest Recruiter"]     = { Level = 60,   QuestName = "DesertBandits",  Mob = "Desert Bandit"     },
        ["Snow Quest Recruiter"]       = { Level = 90,   QuestName = "SnowBandits",    Mob = "Snow Bandit"       },
        ["Marine Quest Recruiter"]     = { Level = 120,  QuestName = "Marines",        Mob = "Marine"            },
        ["Sky Quest Recruiter"]        = { Level = 150,  QuestName = "SkyBandits",     Mob = "Sky Bandit"        },
        ["Prison Quest Recruiter"]     = { Level = 190,  QuestName = "Prisoners",      Mob = "Prisoner"          },
        ["Magma Quest Recruiter"]      = { Level = 300,  QuestName = "MagmaSoldiers",  Mob = "Magma Soldier"     },
        ["Underwater Quest Recruiter"] = { Level = 375,  QuestName = "Fishmen",        Mob = "Fishman Warrior"   },
    },
    [2] = {
        ["Area 1 Quest Recruiter"]         = { Level = 700,  QuestName = "Area1",         Mob = "Raider"            },
        ["Area 2 Quest Recruiter"]         = { Level = 775,  QuestName = "Area2",         Mob = "Mercenary"         },
        ["Green Bit Quest Recruiter"]      = { Level = 875,  QuestName = "GreenBit1",     Mob = "Plant Subordinate" },
        ["Graveyard Quest Recruiter"]      = { Level = 950,  QuestName = "Graveyard1",    Mob = "Zombie"            },
        ["Snow Mountain Quest Recruiter"]  = { Level = 1000, QuestName = "SnowMountain1", Mob = "Snow Trooper"      },
        ["Hot Quest Recruiter"]            = { Level = 1100, QuestName = "Hot1",          Mob = "Lab Subordinate"   },
        ["Cold Quest Recruiter"]           = { Level = 1150, QuestName = "Cold1",         Mob = "Horned Warrior"    },
        ["Cursed Captain Quest Recruiter"] = { Level = 1250, QuestName = "Ship1",         Mob = "Ship Officer"      },
        ["Ice Castle Quest Recruiter"]     = { Level = 1350, QuestName = "IceCastle1",    Mob = "Arctic Warrior"    },
        ["Forgotten Quest Recruiter"]      = { Level = 1425, QuestName = "Forgotten1",    Mob = "Sea Soldier"       },
    },
    [3] = {
        ["Port Quest Recruiter"]            = { Level = 1500, QuestName = "PortQuest1",    Mob = "Pirate Millionaire"  },
        ["Hydra Quest Recruiter"]           = { Level = 1575, QuestName = "HydraQuest1",   Mob = "Dragon Crew Warrior" },
        ["Great Tree Quest Recruiter"]      = { Level = 1700, QuestName = "TreeQuest1",    Mob = "Marine Commodore"    },
        ["Floating Turtle Quest Recruiter"] = { Level = 1775, QuestName = "TurtleQuest1",  Mob = "Fishman Raider"      },
        ["Haunted Castle Quest Recruiter"]  = { Level = 1975, QuestName = "HauntedQuest1", Mob = "Reborn Skeleton"     },
        ["Candy Quest Recruiter"]           = { Level = 2075, QuestName = "CandyQuest1",   Mob = "Cookie Crafter"      },
    },
}

-- ════════════════════════════════════════════
-- DADOS PÚBLICOS
-- ════════════════════════════════════════════

BloxFruits.Bosses = {
    Sea1 = {
        "Saber Expert", "The Saw", "Gorilla King", "Bobby", "Yeti",
        "Vice Admiral", "Warden", "Chief Warden", "Swan",
        "Magma Admiral", "Fishman Lord", "Wysper", "Thunder God", "Cyborg",
    },
    Sea2 = {
        "Diamond", "Jeremy", "Fajita", "Don Swan",
        "Smoke Admiral", "Tide Keeper", "Cursed Captain", "Darkbeard", "Order",
    },
    Sea3 = {
        "Stone", "Island Emperor", "Kilo Admiral", "Captain Elephant",
        "Beautiful Pirate", "Cake Queen", "Rip_Indra", "Cake King", "Leviathan",
    },
}

BloxFruits.Races = {
    "Human", "Fish", "Angel", "Mink", "Cyborg", "Ghoul",
}

BloxFruits.CombatStyles = {
    "Dark Step", "Electric", "Water Kung Fu", "Dragon Breath",
    "Death Step", "Electric Claw", "Sharkman Karate",
    "Dragon Talon", "Superhuman", "Godhuman", "Sanguine Art",
}

BloxFruits.Fruits = {
    "Rocket-Rocket", "Spin-Spin", "Chop-Chop", "Spring-Spring",
    "Bomb-Bomb", "Smoke-Smoke", "Spike-Spike", "Flame-Flame",
    "Falcon-Falcon", "Ice-Ice", "Sand-Sand", "Dark-Dark",
    "Diamond-Diamond", "Light-Light", "Rubber-Rubber", "Barrier-Barrier",
    "Ghost-Ghost", "Magma-Magma", "Quake-Quake", "Buddha-Buddha",
    "Love-Love", "Spider-Spider", "Sound-Sound", "Phoenix-Phoenix",
    "Portal-Portal", "Rumble-Rumble", "Pain-Pain", "Blizzard-Blizzard",
    "Gravity-Gravity", "Mammoth-Mammoth", "T-Rex-T-Rex", "Dough-Dough",
    "Shadow-Shadow", "Venom-Venom", "Control-Control", "Spirit-Spirit",
    "Dragon-Dragon", "Leopard-Leopard", "Kitsune-Kitsune",
}

BloxFruits.Islands = {
    Sea1 = {
        ["Starter Island"]  = Vector3.new(977.8, 6.5, 1582.9),
        ["Marine Starter"]  = Vector3.new(-967.8, 6.5, 1582.9),
        ["Jungle"]          = Vector3.new(-1766.6, 14.3, -3096.6),
        ["Pirate Village"]  = Vector3.new(-1306.4, 4.0, 312.9),
        ["Desert"]          = Vector3.new(941.0, 6.0, -2767.0),
        ["Frozen Village"]  = Vector3.new(1239.7, 9.5, -3011.0),
        ["Marine Fortress"] = Vector3.new(-4600.0, 10.0, 4068.0),
        ["Skylands"]        = Vector3.new(-4852.0, 3038.0, 1999.0),
        ["Prison"]          = Vector3.new(4781.7, 5.0, 803.3),
        ["Magma Village"]   = Vector3.new(-4648.3, 46.0, -881.4),
        ["Underwater City"] = Vector3.new(61164.5, -1400.0, 1819.7),
    },
    Sea2 = {
        ["Kingdom of Rose"] = Vector3.new(-789.7, 73.5, -3774.0),
        ["Green Zone"]      = Vector3.new(-1887.9, 22.0, -5018.8),
        ["Graveyard"]       = Vector3.new(3775.0, 24.0, -4313.0),
        ["Snow Mountain"]   = Vector3.new(2117.0, 214.0, -5229.0),
        ["Hot & Cold"]      = Vector3.new(441.0, 157.0, -5462.0),
        ["Cursed Ship"]     = Vector3.new(-4098.0, 2.0, -5296.0),
        ["Ice Castle"]      = Vector3.new(-1500.0, 4.0, -6500.0),
        ["Forgotten Island"]= Vector3.new(0.0, 5.0, -7000.0),
    },
    Sea3 = {
        ["Port Town"]       = Vector3.new(-8985.0, 6.0, -1873.0),
        ["Hydra Island"]    = Vector3.new(-9648.0, 6.0, 786.0),
        ["Great Tree"]      = Vector3.new(-8487.0, 5.0, 5450.0),
        ["Floating Turtle"] = Vector3.new(-13720.0, 0.0, -3839.0),
        ["Haunted Castle"]  = Vector3.new(-11860.0, 5.0, -7490.0),
        ["Candy Land"]      = Vector3.new(-1835.0, 5.0, -19000.0),
    },
}

-- ════════════════════════════════════════════
-- UTILITÁRIOS INTERNOS
-- ════════════════════════════════════════════

-- Nomes de criaturas do mar (evita tabela inline duplicada)
local SEA_BEAST_NAMES = { "Sea Beast", "Rip_Indra", "Leviathan", "Terror Shark" }

-- Cache do remote Remotes para evitar FindFirstChild repetido por frame
local _remoteCache = nil
local function getRemotes()
    if _remoteCache and _remoteCache.Parent then
        return _remoteCache
    end
    _remoteCache = ReplicatedStorage:FindFirstChild("Remotes")
    return _remoteCache
end

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
    return 0
end

local function teleportTo(pos)
    local hrp = getHRP()
    if hrp then
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    end
end

local function tweenTo(pos, duration)
    local hrp = getHRP()
    if not hrp then return end
    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(duration or 1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { CFrame = CFrame.new(pos) }
    )
    tween:Play()
    tween.Completed:Wait()
end

-- Desconecta e limpa uma conexão pelo nome
local function disconnect(name)
    local conn = State.Connections[name]
    if conn then
        pcall(conn.Disconnect, conn)
        State.Connections[name] = nil
    end
end

-- Verifica se um Model pertence a um jogador
local function isPlayerCharacter(model)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == model then return true end
    end
    return false
end

-- Retorna model + HRP de um NPC vivo pelo nome, ou nil
local function findAliveNPC(name)
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name == name then
            local hrp = v:FindFirstChild("HumanoidRootPart")
            local hum = v:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                return v, hrp
            end
        end
    end
    return nil, nil
end

-- Alias legível para bosses e mobs (mesma lógica)
local findMob  = findAliveNPC
local findBoss = findAliveNPC

-- Retorna recruiter e dados da melhor quest para o nível atual
local function getBestQuest(sea)
    local level = getLevel()
    local questTable = QuestTables[sea] or QuestTables[1]
    local bestRecruiter, bestLevel = nil, -1
    for recruiter, data in pairs(questTable) do
        if data.Level <= level and data.Level > bestLevel then
            bestLevel    = data.Level
            bestRecruiter = recruiter
        end
    end
    return bestRecruiter, bestRecruiter and questTable[bestRecruiter] or nil
end

-- Aceita quest via remote
local function acceptQuest(questName)
    local ok, err = pcall(function()
        local remotes = getRemotes()
        if not remotes then return end
        local r = remotes:FindFirstChild("StartQuest") or remotes:FindFirstChild("AcceptQuest")
        if r then r:FireServer(questName) end
    end)
    if not ok then warn("[BloxFruits] acceptQuest: " .. tostring(err)) end
end

-- Cria/inicia uma loop de Heartbeat com pcall embutido
-- callback recebe delta time; waitTime é o intervalo mínimo entre ciclos
local function startLoop(name, waitTime, callback)
    disconnect(name)
    State.Connections[name] = RunService.Heartbeat:Connect(function()
        if not State.Connections[name] then return end
        local ok, err = pcall(callback)
        if not ok then warn("[BloxFruits] " .. name .. ": " .. tostring(err)) end
        task.wait(waitTime)
    end)
end

-- ════════════════════════════════════════════
-- AUTO QUEST
-- ════════════════════════════════════════════

function BloxFruits.SetAutoQuest(enabled, sea)
    sea = sea or 1
    State.AutoQuest = enabled
    if not enabled then
        disconnect("AutoQuest")
        State.CurrentQuest = nil
        return
    end

    startLoop("AutoQuest", 3, function()
        if not State.AutoQuest then return end

        local recruiter, questData = getBestQuest(sea)
        if not recruiter or not questData then return end
        State.CurrentQuest = questData

        -- Verifica se já tem a quest ativa
        local questHolder = LocalPlayer:FindFirstChild("QuestHolder")
        if questHolder and questHolder:FindFirstChild(questData.QuestName) then return end

        -- Vai até o recruiter e aceita a quest
        local _, recruiterHRP = findAliveNPC(recruiter)
        if recruiterHRP then
            teleportTo(recruiterHRP.Position)
            task.wait(0.5)
            acceptQuest(questData.QuestName)
            task.wait(0.5)
        end
    end)
end

-- ════════════════════════════════════════════
-- AUTO FARM
-- ════════════════════════════════════════════

function BloxFruits.SetAutoFarm(enabled, sea)
    sea = sea or 1
    State.AutoFarm = enabled
    if not enabled then
        disconnect("AutoFarm")
        return
    end

    -- Garante que AutoQuest está ativo no mesmo mar
    if not State.AutoQuest then
        BloxFruits.SetAutoQuest(true, sea)
    end

    startLoop("AutoFarm", 0.1, function()
        if not State.AutoFarm or not State.CurrentQuest then return end

        local _, mobHRP = findMob(State.CurrentQuest.Mob)
        if not mobHRP then return end

        local hrp = getHRP()
        if not hrp then return end

        hrp.CFrame = CFrame.new(mobHRP.Position + Vector3.new(0, 3, 0))
        task.wait(0.1)

        -- Dispara ferramenta equipada
        local char = getChar()
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool and tool.Activated then
                pcall(tool.Activated.Fire, tool.Activated)
            end
        end
    end)
end

-- ════════════════════════════════════════════
-- BRING MOB
-- ════════════════════════════════════════════

function BloxFruits.SetBringMob(enabled, mobName)
    State.BringMob = enabled
    if not enabled or not mobName then
        disconnect("BringMob")
        return
    end

    startLoop("BringMob", 0.5, function()
        if not State.BringMob then return end
        local hrp = getHRP()
        if not hrp then return end
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name == mobName then
                local mobHRP = v:FindFirstChild("HumanoidRootPart")
                if mobHRP then
                    mobHRP.CFrame = CFrame.new(
                        hrp.Position + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
                    )
                end
            end
        end
    end)
end

-- ════════════════════════════════════════════
-- KILL AURA
-- ════════════════════════════════════════════

function BloxFruits.SetKillAura(enabled, radius)
    radius = radius or 20
    State.KillAura = enabled
    if not enabled then
        disconnect("KillAura")
        return
    end

    startLoop("KillAura", 0.1, function()
        if not State.KillAura then return end
        local hrp = getHRP()
        if not hrp then return end

        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and v ~= LocalPlayer.Character then
                local vHRP = v:FindFirstChild("HumanoidRootPart")
                local vHum = v:FindFirstChildOfClass("Humanoid")
                if vHRP and vHum and vHum.Health > 0 then
                    if (hrp.Position - vHRP.Position).Magnitude <= radius then
                        if not isPlayerCharacter(v) then
                            hrp.CFrame = CFrame.new(vHRP.Position + Vector3.new(0, 3, 0))
                        end
                    end
                end
            end
        end
    end)
end

-- ════════════════════════════════════════════
-- FAST ATTACK
-- ════════════════════════════════════════════

function BloxFruits.SetFastAttack(enabled)
    State.FastAttack = enabled
    local ok, err = pcall(function()
        local char = getChar()
        if not char then return end
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("Tool") then
                local cfg = v:FindFirstChild("Config")
                local cd  = cfg and cfg:FindFirstChild("Cooldown")
                if cd then cd.Value = enabled and 0.01 or 0.5 end
            end
        end
    end)
    if not ok then warn("[BloxFruits] FastAttack: " .. tostring(err)) end
end

-- ════════════════════════════════════════════
-- AUTO HAKI
-- ════════════════════════════════════════════

function BloxFruits.SetAutoHaki(enabled)
    State.AutoHaki = enabled
    if not enabled then
        disconnect("AutoHaki")
        return
    end

    startLoop("AutoHaki", 10, function()
        if not State.AutoHaki then return end
        -- Tenta VirtualInputManager primeiro
        local vim = game:GetService("VirtualInputManager")
        if vim then
            pcall(vim.SendKeyEvent, vim, true,  Enum.KeyCode.M, false, game)
            task.wait(0.05)
            pcall(vim.SendKeyEvent, vim, false, Enum.KeyCode.M, false, game)
        else
            -- Fallback via remote
            local remotes = getRemotes()
            if remotes then
                local r = remotes:FindFirstChild("Activate_Haki") or remotes:FindFirstChild("Haki")
                if r then pcall(r.FireServer, r) end
            end
        end
    end)
end

-- ════════════════════════════════════════════
-- AUTO BOSS
-- ════════════════════════════════════════════

function BloxFruits.SetAutoBoss(enabled, bossName)
    State.AutoBoss   = enabled
    State.CurrentBoss = enabled and bossName or nil
    if not enabled or not bossName then
        disconnect("AutoBoss")
        return
    end

    startLoop("AutoBoss", 0.2, function()
        if not State.AutoBoss then return end
        local _, bossHRP = findBoss(bossName)
        if not bossHRP then return end
        local hrp = getHRP()
        if hrp then
            hrp.CFrame = CFrame.new(bossHRP.Position + Vector3.new(0, 3, 0))
        end
    end)
end

-- ════════════════════════════════════════════
-- AUTO STATS
-- ════════════════════════════════════════════

function BloxFruits.SetAutoStats(enabled, priority)
    priority = priority or "Melee"
    if not enabled then
        disconnect("AutoStats")
        return
    end

    startLoop("AutoStats", 1, function()
        local remotes = getRemotes()
        if not remotes then return end
        local data       = LocalPlayer:FindFirstChild("Data")
        local statPoints = data and data:FindFirstChild("StatPoints")
        if not statPoints or statPoints.Value <= 0 then return end
        local r = remotes:FindFirstChild("AddStat") or remotes:FindFirstChild("Stat")
        if r then r:FireServer(priority) end
    end)
end

-- ════════════════════════════════════════════
-- AUTO RAID
-- ════════════════════════════════════════════

function BloxFruits.SetAutoRaid(enabled)
    State.AutoRaid = enabled
    if not enabled then
        disconnect("AutoRaid")
        return
    end

    startLoop("AutoRaid", 0.15, function()
        if not State.AutoRaid then return end
        local hrp = getHRP()
        if not hrp then return end
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Model") then
                local vHRP = v:FindFirstChild("HumanoidRootPart")
                local vHum = v:FindFirstChildOfClass("Humanoid")
                if vHRP and vHum and vHum.Health > 0 and not isPlayerCharacter(v) then
                    hrp.CFrame = CFrame.new(vHRP.Position + Vector3.new(0, 3, 0))
                    break -- ataca um por vez por frame
                end
            end
        end
    end)
end

-- ════════════════════════════════════════════
-- SEA EVENTS
-- ════════════════════════════════════════════

function BloxFruits.SetLeviathanHunt(enabled)
    State.LeviathanHunt = enabled
    if not enabled then
        disconnect("Leviathan")
        return
    end

    startLoop("Leviathan", 0.5, function()
        if not State.LeviathanHunt then return end
        local _, levHRP = findBoss("Leviathan")
        if not levHRP then return end
        local hrp = getHRP()
        if hrp then
            hrp.CFrame = CFrame.new(levHRP.Position + Vector3.new(0, 5, 5))
        end
    end)
end

function BloxFruits.SetSeaBeastFarm(enabled)
    State.SeaBeastFarm = enabled
    if not enabled then
        disconnect("SeaBeast")
        return
    end

    startLoop("SeaBeast", 0.3, function()
        if not State.SeaBeastFarm then return end
        local hrp = getHRP()
        if not hrp then return end
        for _, name in ipairs(SEA_BEAST_NAMES) do
            local _, bHRP = findBoss(name)
            if bHRP then
                hrp.CFrame = CFrame.new(bHRP.Position + Vector3.new(0, 5, 5))
                break
            end
        end
    end)
end

-- ════════════════════════════════════════════
-- TERROR SHARK ESP
-- ════════════════════════════════════════════

local ESP_TAG = "ZenithESP_TS"

local function removeSharkESP()
    for _, v in ipairs(Workspace:GetDescendants()) do
        local esp = v:FindFirstChild(ESP_TAG)
        if esp then esp:Destroy() end
    end
end

function BloxFruits.SetTerrorSharkESP(enabled)
    State.TerrorSharkESP = enabled
    if not enabled then
        disconnect("TerrorSharkESP")
        removeSharkESP()
        return
    end

    startLoop("TerrorSharkESP", 1, function()
        if not State.TerrorSharkESP then return end
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name == "Terror Shark" then
                if v:FindFirstChild("HumanoidRootPart") and not v:FindFirstChild(ESP_TAG) then
                    local box           = Instance.new("SelectionBox")
                    box.Name            = ESP_TAG
                    box.Adornee         = v
                    box.Color3          = Color3.fromRGB(255, 0, 0)
                    box.LineThickness   = 0.05
                    box.Parent          = v
                end
            end
        end
    end)
end

-- ════════════════════════════════════════════
-- AUTO RACE V4
-- ════════════════════════════════════════════

function BloxFruits.SetAutoRaceV4(enabled, race)
    State.AutoRaceV4 = enabled
    if not enabled or not race then
        disconnect("AutoRaceV4")
        return
    end

    startLoop("AutoRaceV4", 5, function()
        if not State.AutoRaceV4 then return end
        local remotes = getRemotes()
        if not remotes then return end
        local r = remotes:FindFirstChild("RaceV4") or remotes:FindFirstChild("ActivateRace")
        if r then r:FireServer(race) end
    end)
end

-- ════════════════════════════════════════════
-- FRUIT SNIPER
-- ════════════════════════════════════════════

function BloxFruits.SetFruitSniper(enabled, targetFruits)
    State.FruitSniper = enabled
    targetFruits = targetFruits or {}
    if not enabled then
        disconnect("FruitSniper")
        return
    end

    startLoop("FruitSniper", 1, function()
        if not State.FruitSniper then return end
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Model") then
                local label = v:FindFirstChild("FruitName") or v:FindFirstChild("Name_Tag")
                local labelValue = label and (label.Value or v.Name) or v.Name
                for _, target in ipairs(targetFruits) do
                    if string.find(labelValue, target, 1, true) then
                        local vHRP = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart
                        if vHRP then
                            teleportTo(vHRP.Position)
                            task.wait(0.5)
                            local pickup = v:FindFirstChild("Touch") or v:FindFirstChild("Pickup")
                            if pickup then pcall(pickup.FireServer, pickup) end
                        end
                        break
                    end
                end
            end
        end
    end)
end

-- ════════════════════════════════════════════
-- TELEPORT PARA ILHA
-- ════════════════════════════════════════════

function BloxFruits.TeleportIsland(islandName, sea, useTween)
    local ok, err = pcall(function()
        local seaTable = BloxFruits.Islands["Sea" .. tostring(sea or 1)]
        if not seaTable then return end
        local pos = seaTable[islandName]
        if not pos then return end
        if useTween then
            tweenTo(pos + Vector3.new(0, 3, 0), 2)
        else
            teleportTo(pos)
        end
    end)
    if not ok then warn("[BloxFruits] TeleportIsland: " .. tostring(err)) end
end

-- ════════════════════════════════════════════
-- LIMPEZA GERAL
-- ════════════════════════════════════════════

function BloxFruits.Cleanup()
    -- Desliga todas as flags
    for k, v in pairs(State) do
        if type(v) == "boolean" then State[k] = false end
    end
    -- Desconecta todos os loops
    for name in pairs(State.Connections) do
        disconnect(name)
    end
    -- Remove ESPs remanescentes
    removeSharkESP()
    -- Invalida cache de remotes
    _remoteCache = nil
end

return BloxFruits
