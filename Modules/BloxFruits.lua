--[[
    ZenithHub - Modules/BloxFruits.lua
    Módulo completo para Blox Fruits
    Auto Farm, Bosses, Raids, Sea Events, Races/V4, Shop
]]

local BloxFruits = {}

-- ════════════════════════════════════════════
-- SERVIÇOS
-- ════════════════════════════════════════════
local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService    = game:GetService("TweenService")
local Workspace       = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- ════════════════════════════════════════════
-- ESTADO INTERNO
-- ════════════════════════════════════════════
local State = {
    AutoFarm      = false,
    AutoQuest     = false,
    BringMob      = false,
    KillAura      = false,
    FastAttack    = false,
    AutoHaki      = false,
    AutoBoss      = false,
    AutoRaid      = false,
    AutoDungeon   = false,
    AutoChipBuy   = false,
    AutoAwaken    = false,
    LeviathanHunt = false,
    SeaBeastFarm  = false,
    MirageDetect  = false,
    TerrorSharkESP= false,
    EventESP      = false,
    AutoRaceV4    = false,
    AutoTrial     = false,
    AutoGear      = false,
    FruitSniper   = false,
    AutoStoreFruit= false,
    AutoBuyItems  = false,
    GachaBuy      = false,
    ShopESP       = false,
    Connections   = {},
    CurrentQuest  = nil,
    CurrentBoss   = nil,
}

-- ════════════════════════════════════════════
-- TABELAS DE QUESTS
-- ════════════════════════════════════════════

local Sea1_Quests = {
    ["Bandit Quest Recruiter"]     = { Level = 0,   QuestName = "Bandits",       Mob = "Bandit"           },
    ["Monkey Quest Recruiter"]     = { Level = 15,  QuestName = "Monkeys",       Mob = "Monkey",  QuestsCount = 2 },
    ["Pirate Quest Recruiter"]     = { Level = 35,  QuestName = "Pirates",       Mob = "Pirate"           },
    ["Desert Quest Recruiter"]     = { Level = 60,  QuestName = "DesertBandits", Mob = "Desert Bandit"    },
    ["Snow Quest Recruiter"]       = { Level = 90,  QuestName = "SnowBandits",   Mob = "Snow Bandit"      },
    ["Marine Quest Recruiter"]     = { Level = 120, QuestName = "Marines",       Mob = "Marine"           },
    ["Sky Quest Recruiter"]        = { Level = 150, QuestName = "SkyBandits",    Mob = "Sky Bandit"       },
    ["Prison Quest Recruiter"]     = { Level = 190, QuestName = "Prisoners",     Mob = "Prisoner"         },
    ["Magma Quest Recruiter"]      = { Level = 300, QuestName = "MagmaSoldiers", Mob = "Magma Soldier"    },
    ["Underwater Quest Recruiter"] = { Level = 375, QuestName = "Fishmen",       Mob = "Fishman Warrior"  },
}

local Sea2_Quests = {
    ["Area 1 Quest Recruiter"]         = { Level = 700,  QuestName = "Area1",        Mob = "Raider"           },
    ["Area 2 Quest Recruiter"]         = { Level = 775,  QuestName = "Area2",        Mob = "Mercenary"        },
    ["Green Bit Quest Recruiter"]      = { Level = 875,  QuestName = "GreenBit1",    Mob = "Plant Subordinate"},
    ["Graveyard Quest Recruiter"]      = { Level = 950,  QuestName = "Graveyard1",   Mob = "Zombie"           },
    ["Snow Mountain Quest Recruiter"]  = { Level = 1000, QuestName = "SnowMountain1",Mob = "Snow Trooper"     },
    ["Hot Quest Recruiter"]            = { Level = 1100, QuestName = "Hot1",         Mob = "Lab Subordinate"  },
    ["Cold Quest Recruiter"]           = { Level = 1150, QuestName = "Cold1",        Mob = "Horned Warrior"   },
    ["Cursed Captain Quest Recruiter"] = { Level = 1250, QuestName = "Ship1",        Mob = "Ship Officer"     },
    ["Ice Castle Quest Recruiter"]     = { Level = 1350, QuestName = "IceCastle1",   Mob = "Arctic Warrior"   },
    ["Forgotten Quest Recruiter"]      = { Level = 1425, QuestName = "Forgotten1",   Mob = "Sea Soldier"      },
}

local Sea3_Quests = {
    ["Port Quest Recruiter"]            = { Level = 1500, QuestName = "PortQuest1",    Mob = "Pirate Millionaire"  },
    ["Hydra Quest Recruiter"]           = { Level = 1575, QuestName = "HydraQuest1",   Mob = "Dragon Crew Warrior" },
    ["Great Tree Quest Recruiter"]      = { Level = 1700, QuestName = "TreeQuest1",    Mob = "Marine Commodore"    },
    ["Floating Turtle Quest Recruiter"] = { Level = 1775, QuestName = "TurtleQuest1",  Mob = "Fishman Raider"      },
    ["Haunted Castle Quest Recruiter"]  = { Level = 1975, QuestName = "HauntedQuest1", Mob = "Reborn Skeleton"     },
    ["Candy Quest Recruiter"]           = { Level = 2075, QuestName = "CandyQuest1",   Mob = "Cookie Crafter"      },
}

-- ════════════════════════════════════════════
-- TABELA DE BOSSES
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

-- ════════════════════════════════════════════
-- RAÇAS DISPONÍVEIS
-- ════════════════════════════════════════════

BloxFruits.Races = {
    "Human", "Fish", "Angel", "Mink", "Cyborg", "Ghoul",
}

-- ════════════════════════════════════════════
-- ESTILOS DE COMBATE
-- ════════════════════════════════════════════

BloxFruits.CombatStyles = {
    "Dark Step", "Electric", "Water Kung Fu", "Dragon Breath",
    "Death Step", "Electric Claw", "Sharkman Karate",
    "Dragon Talon", "Superhuman", "Godhuman", "Sanguine Art",
}

-- ════════════════════════════════════════════
-- FRUTAS
-- ════════════════════════════════════════════

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

-- ════════════════════════════════════════════
-- TELEPORTS (Ilhas)
-- ════════════════════════════════════════════

BloxFruits.Islands = {
    Sea1 = {
        ["Starter Island"]   = Vector3.new(977.8, 6.5, 1582.9),
        ["Marine Starter"]   = Vector3.new(-967.8, 6.5, 1582.9),
        ["Jungle"]           = Vector3.new(-1766.6, 14.3, -3096.6),
        ["Pirate Village"]   = Vector3.new(-1306.4, 4.0, 312.9),
        ["Desert"]           = Vector3.new(941.0, 6.0, -2767.0),
        ["Frozen Village"]   = Vector3.new(1239.7, 9.5, -3011.0),
        ["Marine Fortress"]  = Vector3.new(-4600.0, 10.0, 4068.0),
        ["Skylands"]         = Vector3.new(-4852.0, 3038.0, 1999.0),
        ["Prison"]           = Vector3.new(4781.7, 5.0, 803.3),
        ["Magma Village"]    = Vector3.new(-4648.3, 46.0, -881.4),
        ["Underwater City"]  = Vector3.new(61164.5, -1400.0, 1819.7),
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
        ["Port Town"]        = Vector3.new(-8985.0, 6.0, -1873.0),
        ["Hydra Island"]     = Vector3.new(-9648.0, 6.0, 786.0),
        ["Great Tree"]       = Vector3.new(-8487.0, 5.0, 5450.0),
        ["Floating Turtle"]  = Vector3.new(-13720.0, 0.0, -3839.0),
        ["Haunted Castle"]   = Vector3.new(-11860.0, 5.0, -7490.0),
        ["Candy Land"]       = Vector3.new(-1835.0, 5.0, -19000.0),
    },
}

-- ════════════════════════════════════════════
-- UTILITÁRIOS INTERNOS
-- ════════════════════════════════════════════

local function getChar()
    return LocalPlayer.Character
end

local function getHRP()
    local c = getChar()
    if c then return c:FindFirstChild("HumanoidRootPart") end
end

local function getHumanoid()
    local c = getChar()
    if c then return c:FindFirstChildOfClass("Humanoid") end
end

local function getLevel()
    local ok, lvl = pcall(function()
        return LocalPlayer.Data.Level.Value
    end)
    if ok then return lvl end
    -- Fallback via GUI (alguns executores)
    local ok2, lvl2 = pcall(function()
        return LocalPlayer:FindFirstChild("Data") and
               LocalPlayer.Data:FindFirstChild("Level") and
               LocalPlayer.Data.Level.Value or 0
    end)
    return ok2 and lvl2 or 0
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
    duration = duration or 1.2
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(hrp, info, { CFrame = CFrame.new(pos) })
    tween:Play()
    tween.Completed:Wait()
end

local function disconnect(name)
    if State.Connections[name] then
        pcall(function() State.Connections[name]:Disconnect() end)
        State.Connections[name] = nil
    end
end

-- Encontra quest adequada para o nível atual
local function getBestQuest(sea)
    local level = getLevel()
    local questTable = sea == 1 and Sea1_Quests or sea == 2 and Sea2_Quests or Sea3_Quests

    local bestRecruiter = nil
    local bestLevel = -1

    for recruiter, data in pairs(questTable) do
        if data.Level <= level and data.Level > bestLevel then
            bestLevel = data.Level
            bestRecruiter = recruiter
        end
    end

    if bestRecruiter then
        return bestRecruiter, questTable[bestRecruiter]
    end
    return nil, nil
end

-- Encontra mob no Workspace pelo nome
local function findMob(mobName)
    for _, v in ipairs(Workspace:GetDescendants()) do
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

-- Encontra boss no Workspace
local function findBoss(bossName)
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name == bossName then
            local hrp = v:FindFirstChild("HumanoidRootPart")
            local hum = v:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                return v, hrp
            end
        end
    end
    return nil, nil
end

-- Aceita quest via RemoteEvent/Function
local function acceptQuest(questName)
    local ok, err = pcall(function()
        local remote = ReplicatedStorage:FindFirstChild("Remotes")
        if remote then
            local questRemote = remote:FindFirstChild("StartQuest") or remote:FindFirstChild("AcceptQuest")
            if questRemote then
                questRemote:FireServer(questName)
            end
        end
    end)
    if not ok then warn("[BloxFruits] acceptQuest erro: " .. tostring(err)) end
end

-- ════════════════════════════════════════════
-- AUTO QUEST
-- ════════════════════════════════════════════

function BloxFruits.SetAutoQuest(enabled, sea)
    sea = sea or 1
    if enabled then
        State.AutoQuest = true
        State.Connections["AutoQuest"] = RunService.Heartbeat:Connect(function()
            if not State.AutoQuest then return end

            local ok, err = pcall(function()
                local recruiter, questData = getBestQuest(sea)
                if not recruiter or not questData then return end

                State.CurrentQuest = questData

                -- Verifica se já tem quest ativa
                local hasQuest = false
                local questHolder = LocalPlayer:FindFirstChild("QuestHolder")
                if questHolder and questHolder:FindFirstChild(questData.QuestName) then
                    hasQuest = true
                end

                if not hasQuest then
                    -- Vai até o recruiter
                    local recruiterNPC = nil
                    for _, v in ipairs(Workspace:GetDescendants()) do
                        if v:IsA("Model") and v.Name == recruiter then
                            local hrp = v:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                recruiterNPC = hrp
                                break
                            end
                        end
                    end
                    if recruiterNPC then
                        teleportTo(recruiterNPC.Position)
                        task.wait(0.5)
                        acceptQuest(questData.QuestName)
                        task.wait(0.5)
                    end
                end
            end)

            if not ok then
                warn("[BloxFruits] AutoQuest loop erro: " .. tostring(err))
            end

            task.wait(3)
        end)
    else
        State.AutoQuest = false
        disconnect("AutoQuest")
        State.CurrentQuest = nil
    end
end

-- ════════════════════════════════════════════
-- AUTO FARM
-- ════════════════════════════════════════════

function BloxFruits.SetAutoFarm(enabled, sea)
    sea = sea or 1
    if enabled then
        State.AutoFarm = true
        State.Connections["AutoFarm"] = RunService.Heartbeat:Connect(function()
            if not State.AutoFarm then return end

            local ok, err = pcall(function()
                if not State.CurrentQuest then return end

                local mobName = State.CurrentQuest.Mob
                local mob, mobHRP = findMob(mobName)

                if mob and mobHRP then
                    local hrp = getHRP()
                    if hrp then
                        -- Teleporta para perto do mob
                        hrp.CFrame = CFrame.new(mobHRP.Position + Vector3.new(0, 3, 0))
                        task.wait(0.1)

                        -- Usa tool equipada (ataca)
                        local char = getChar()
                        if char then
                            local tool = char:FindFirstChildOfClass("Tool")
                            if tool then
                                local activate = tool:FindFirstChildOfClass("LocalScript") or tool:FindFirstChild("Activate")
                                -- Simula clique no mob
                                local event = tool:FindFirstChild("Activated")
                                if tool.Activated then
                                    tool.Activated:Fire()
                                end
                            end
                        end
                    end
                end
            end)

            if not ok then
                warn("[BloxFruits] AutoFarm loop erro: " .. tostring(err))
            end

            task.wait(0.1)
        end)
    else
        State.AutoFarm = false
        disconnect("AutoFarm")
    end
end

-- ════════════════════════════════════════════
-- BRING MOB
-- ════════════════════════════════════════════

function BloxFruits.SetBringMob(enabled, mobName)
    if enabled and mobName then
        State.BringMob = true
        State.Connections["BringMob"] = RunService.Heartbeat:Connect(function()
            if not State.BringMob then return end
            local ok, err = pcall(function()
                local hrp = getHRP()
                if not hrp then return end
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if v:IsA("Model") and v.Name == mobName then
                        local mobHRP = v:FindFirstChild("HumanoidRootPart")
                        if mobHRP then
                            mobHRP.CFrame = CFrame.new(hrp.Position + Vector3.new(
                                math.random(-5, 5), 0, math.random(-5, 5)
                            ))
                        end
                    end
                end
            end)
            if not ok then warn("[BloxFruits] BringMob erro: " .. tostring(err)) end
            task.wait(0.5)
        end)
    else
        State.BringMob = false
        disconnect("BringMob")
    end
end

-- ════════════════════════════════════════════
-- KILL AURA
-- ════════════════════════════════════════════

function BloxFruits.SetKillAura(enabled, radius)
    radius = radius or 20
    if enabled then
        State.KillAura = true
        State.Connections["KillAura"] = RunService.Heartbeat:Connect(function()
            if not State.KillAura then return end
            local ok, err = pcall(function()
                local hrp = getHRP()
                if not hrp then return end
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if v:IsA("Model") then
                        local vHRP = v:FindFirstChild("HumanoidRootPart")
                        local vHum = v:FindFirstChildOfClass("Humanoid")
                        if vHRP and vHum and vHum.Health > 0 then
                            local dist = (hrp.Position - vHRP.Position).Magnitude
                            if dist <= radius and v ~= LocalPlayer.Character then
                                -- Verifica que é NPC (sem player)
                                local isPlayer = false
                                for _, p in ipairs(Players:GetPlayers()) do
                                    if p.Character == v then
                                        isPlayer = true
                                        break
                                    end
                                end
                                if not isPlayer then
                                    -- Teleporta para o NPC e ataca
                                    hrp.CFrame = CFrame.new(vHRP.Position + Vector3.new(0, 3, 0))
                                end
                            end
                        end
                    end
                end
            end)
            if not ok then warn("[BloxFruits] KillAura erro: " .. tostring(err)) end
            task.wait(0.1)
        end)
    else
        State.KillAura = false
        disconnect("KillAura")
    end
end

-- ════════════════════════════════════════════
-- FAST ATTACK
-- ════════════════════════════════════════════

function BloxFruits.SetFastAttack(enabled)
    local ok, err = pcall(function()
        if enabled then
            State.FastAttack = true
            -- Reduz cooldown de ataques via propriedades do personagem
            local char = getChar()
            if char then
                for _, v in ipairs(char:GetDescendants()) do
                    if v:IsA("Tool") then
                        local cfg = v:FindFirstChild("Config")
                        if cfg then
                            local cd = cfg:FindFirstChild("Cooldown")
                            if cd then cd.Value = 0.01 end
                        end
                    end
                end
            end
        else
            State.FastAttack = false
        end
    end)
    if not ok then warn("[BloxFruits] FastAttack erro: " .. tostring(err)) end
end

-- ════════════════════════════════════════════
-- AUTO HAKI
-- ════════════════════════════════════════════

function BloxFruits.SetAutoHaki(enabled)
    if enabled then
        State.AutoHaki = true
        State.Connections["AutoHaki"] = RunService.Heartbeat:Connect(function()
            if not State.AutoHaki then return end
            local ok, err = pcall(function()
                -- Ativa Haki via keypress simulado (M no jogo padrão)
                local vim = game:GetService("VirtualInputManager")
                if vim then
                    -- Alguns executores suportam VirtualInputManager
                    vim:SendKeyEvent(true, Enum.KeyCode.M, false, game)
                    task.wait(0.05)
                    vim:SendKeyEvent(false, Enum.KeyCode.M, false, game)
                end
            end)
            if not ok then
                -- Fallback: usa remote
                pcall(function()
                    local remote = ReplicatedStorage:FindFirstChild("Remotes")
                    if remote then
                        local haki = remote:FindFirstChild("Activate_Haki") or remote:FindFirstChild("Haki")
                        if haki then haki:FireServer() end
                    end
                end)
            end
            task.wait(10) -- ativa haki a cada 10 segundos
        end)
    else
        State.AutoHaki = false
        disconnect("AutoHaki")
    end
end

-- ════════════════════════════════════════════
-- AUTO BOSS
-- ════════════════════════════════════════════

function BloxFruits.SetAutoBoss(enabled, bossName)
    if enabled and bossName then
        State.AutoBoss = true
        State.CurrentBoss = bossName
        State.Connections["AutoBoss"] = RunService.Heartbeat:Connect(function()
            if not State.AutoBoss then return end
            local ok, err = pcall(function()
                local boss, bossHRP = findBoss(bossName)
                if boss and bossHRP then
                    local hrp = getHRP()
                    if hrp then
                        hrp.CFrame = CFrame.new(bossHRP.Position + Vector3.new(0, 3, 0))
                    end
                end
            end)
            if not ok then warn("[BloxFruits] AutoBoss erro: " .. tostring(err)) end
            task.wait(0.2)
        end)
    else
        State.AutoBoss = false
        State.CurrentBoss = nil
        disconnect("AutoBoss")
    end
end

-- ════════════════════════════════════════════
-- AUTO STATS
-- ════════════════════════════════════════════

function BloxFruits.SetAutoStats(enabled, priority)
    priority = priority or "Melee"
    if enabled then
        State.Connections["AutoStats"] = RunService.Heartbeat:Connect(function()
            local ok, err = pcall(function()
                local remote = ReplicatedStorage:FindFirstChild("Remotes")
                if not remote then return end

                local statPoints = LocalPlayer.Data and LocalPlayer.Data:FindFirstChild("StatPoints")
                if not statPoints or statPoints.Value <= 0 then return end

                local addStat = remote:FindFirstChild("AddStat") or remote:FindFirstChild("Stat")
                if addStat then
                    addStat:FireServer(priority)
                end
            end)
            if not ok then warn("[BloxFruits] AutoStats erro: " .. tostring(err)) end
            task.wait(1)
        end)
    else
        disconnect("AutoStats")
    end
end

-- ════════════════════════════════════════════
-- AUTO RAID
-- ════════════════════════════════════════════

function BloxFruits.SetAutoRaid(enabled)
    State.AutoRaid = enabled
    if enabled then
        State.Connections["AutoRaid"] = RunService.Heartbeat:Connect(function()
            if not State.AutoRaid then return end
            local ok, err = pcall(function()
                -- Detecta e mata mobs da raid automaticamente
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if v:IsA("Model") then
                        local hum = v:FindFirstChildOfClass("Humanoid")
                        local vHRP = v:FindFirstChild("HumanoidRootPart")
                        if hum and vHRP and hum.Health > 0 then
                            local isPlayer = false
                            for _, p in ipairs(Players:GetPlayers()) do
                                if p.Character == v then isPlayer = true break end
                            end
                            if not isPlayer then
                                local hrp = getHRP()
                                if hrp then
                                    hrp.CFrame = CFrame.new(vHRP.Position + Vector3.new(0, 3, 0))
                                end
                            end
                        end
                    end
                end
            end)
            if not ok then warn("[BloxFruits] AutoRaid erro: " .. tostring(err)) end
            task.wait(0.15)
        end)
    else
        disconnect("AutoRaid")
    end
end

-- ════════════════════════════════════════════
-- SEA EVENTS
-- ════════════════════════════════════════════

function BloxFruits.SetLeviathanHunt(enabled)
    State.LeviathanHunt = enabled
    if enabled then
        State.Connections["Leviathan"] = RunService.Heartbeat:Connect(function()
            if not State.LeviathanHunt then return end
            local ok, err = pcall(function()
                local lev, levHRP = findBoss("Leviathan")
                if lev and levHRP then
                    local hrp = getHRP()
                    if hrp then
                        hrp.CFrame = CFrame.new(levHRP.Position + Vector3.new(0, 5, 5))
                    end
                end
            end)
            if not ok then warn("[BloxFruits] LeviathanHunt erro: " .. tostring(err)) end
            task.wait(0.5)
        end)
    else
        disconnect("Leviathan")
    end
end

function BloxFruits.SetSeaBeastFarm(enabled)
    State.SeaBeastFarm = enabled
    if enabled then
        State.Connections["SeaBeast"] = RunService.Heartbeat:Connect(function()
            if not State.SeaBeastFarm then return end
            local ok, err = pcall(function()
                local seaBeastNames = {"Sea Beast", "Rip_Indra", "Leviathan", "Terror Shark"}
                for _, name in ipairs(seaBeastNames) do
                    local beast, beastHRP = findBoss(name)
                    if beast and beastHRP then
                        local hrp = getHRP()
                        if hrp then
                            hrp.CFrame = CFrame.new(beastHRP.Position + Vector3.new(0, 5, 5))
                        end
                        break
                    end
                end
            end)
            if not ok then warn("[BloxFruits] SeaBeastFarm erro: " .. tostring(err)) end
            task.wait(0.3)
        end)
    else
        disconnect("SeaBeast")
    end
end

function BloxFruits.SetTerrorSharkESP(enabled)
    State.TerrorSharkESP = enabled
    if enabled then
        State.Connections["TerrorSharkESP"] = RunService.Heartbeat:Connect(function()
            if not State.TerrorSharkESP then return end
            local ok, err = pcall(function()
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if v:IsA("Model") and v.Name == "Terror Shark" then
                        local vHRP = v:FindFirstChild("HumanoidRootPart")
                        if vHRP then
                            -- Cria billboard ou highlight
                            if not v:FindFirstChild("ZenithESP_TS") then
                                local hl = Instance.new("SelectionBox")
                                hl.Name = "ZenithESP_TS"
                                hl.Adornee = v
                                hl.Color3 = Color3.fromRGB(255, 0, 0)
                                hl.LineThickness = 0.05
                                hl.Parent = v
                            end
                        end
                    end
                end
            end)
            if not ok then warn("[BloxFruits] TerrorSharkESP erro: " .. tostring(err)) end
            task.wait(1)
        end)
    else
        disconnect("TerrorSharkESP")
        -- Remove highlights
        for _, v in ipairs(Workspace:GetDescendants()) do
            local esp = v:FindFirstChild("ZenithESP_TS")
            if esp then esp:Destroy() end
        end
    end
end

-- ════════════════════════════════════════════
-- RACES / V4
-- ════════════════════════════════════════════

function BloxFruits.SetAutoRaceV4(enabled, race)
    State.AutoRaceV4 = enabled
    if enabled and race then
        State.Connections["AutoRaceV4"] = RunService.Heartbeat:Connect(function()
            if not State.AutoRaceV4 then return end
            local ok, err = pcall(function()
                local remote = ReplicatedStorage:FindFirstChild("Remotes")
                if not remote then return end
                -- Tenta ativar V4 race
                local raceRemote = remote:FindFirstChild("RaceV4") or remote:FindFirstChild("ActivateRace")
                if raceRemote then
                    raceRemote:FireServer(race)
                end
            end)
            if not ok then warn("[BloxFruits] AutoRaceV4 erro: " .. tostring(err)) end
            task.wait(5)
        end)
    else
        disconnect("AutoRaceV4")
    end
end

-- ════════════════════════════════════════════
-- FRUIT SNIPER
-- ════════════════════════════════════════════

function BloxFruits.SetFruitSniper(enabled, targetFruits)
    State.FruitSniper = enabled
    targetFruits = targetFruits or {}
    if enabled then
        State.Connections["FruitSniper"] = RunService.Heartbeat:Connect(function()
            if not State.FruitSniper then return end
            local ok, err = pcall(function()
                -- Procura frutas no workspace
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if v:IsA("Model") then
                        local fruitLabel = v:FindFirstChild("FruitName")
                            or v:FindFirstChild("Name_Tag")
                        if fruitLabel then
                            for _, targetName in ipairs(targetFruits) do
                                if string.find(fruitLabel.Value or v.Name, targetName, 1, true) then
                                    local vHRP = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart
                                    if vHRP then
                                        teleportTo(vHRP.Position)
                                        task.wait(0.5)
                                        -- Tenta pegar a fruta
                                        local touchEvent = v:FindFirstChild("Touch") or v:FindFirstChild("Pickup")
                                        if touchEvent then
                                            pcall(function() touchEvent:FireServer() end)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            if not ok then warn("[BloxFruits] FruitSniper erro: " .. tostring(err)) end
            task.wait(1)
        end)
    else
        disconnect("FruitSniper")
    end
end

-- ════════════════════════════════════════════
-- TELEPORT ISLAND
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
    if not ok then warn("[BloxFruits] TeleportIsland erro: " .. tostring(err)) end
end

-- ════════════════════════════════════════════
-- LIMPEZA
-- ════════════════════════════════════════════

function BloxFruits.Cleanup()
    for k in pairs(State) do
        if type(State[k]) == "boolean" then
            State[k] = false
        end
    end
    for name, conn in pairs(State.Connections) do
        pcall(function() conn:Disconnect() end)
        State.Connections[name] = nil
    end
    -- Remove ESPs
    for _, v in ipairs(Workspace:GetDescendants()) do
        local esp = v:FindFirstChild("ZenithESP_TS")
        if esp then esp:Destroy() end
    end
end

return BloxFruits
