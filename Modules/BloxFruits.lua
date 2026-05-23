--[[
    ZenithHub - Modules/BloxFruits.lua
    Módulo completo para Blox Fruits
    Auto Farm, Bosses, Raids, Sea Events, Races/V4, Shop
    Remotes corrigidos via OPEN_SOURCE_VUA_HUB
]]

local BloxFruits = {}

-- ════════════════════════════════════════════
-- SERVIÇOS
-- ════════════════════════════════════════════
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local Workspace         = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- ════════════════════════════════════════════
-- REMOTES OFICIAIS (corrigidos do hub)
-- CommF_ = RemoteFunction  (InvokeServer)
-- CommE  = RemoteEvent     (FireServer)
-- ════════════════════════════════════════════
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommF_  = Remotes:WaitForChild("CommF_")   -- RemoteFunction principal
local CommE   = Remotes:WaitForChild("CommE")     -- RemoteEvent principal

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
    AutoStats     = false,
    LeviathanHunt = false,
    SeaBeastFarm  = false,
    TerrorSharkESP= false,
    AutoRaceV4    = false,
    FruitSniper   = false,
    Connections   = {},
    CurrentQuest  = nil,
    CurrentBoss   = nil,
}

-- ════════════════════════════════════════════
-- TABELAS DE QUESTS
-- Formato: StartQuest(QuestName, QuestTier)
-- ════════════════════════════════════════════
local Sea1_Quests = {
    ["Bandit Quest Recruiter"]     = { Level = 0,   QuestName = "Bandits",       Mob = "Bandit",          Tier = 1 },
    ["Monkey Quest Recruiter"]     = { Level = 15,  QuestName = "Monkeys",       Mob = "Monkey",          Tier = 1 },
    ["Pirate Quest Recruiter"]     = { Level = 35,  QuestName = "Pirates",       Mob = "Pirate",          Tier = 1 },
    ["Desert Quest Recruiter"]     = { Level = 60,  QuestName = "DesertBandits", Mob = "Desert Bandit",   Tier = 1 },
    ["Snow Quest Recruiter"]       = { Level = 90,  QuestName = "SnowBandits",   Mob = "Snow Bandit",     Tier = 1 },
    ["Marine Quest Recruiter"]     = { Level = 120, QuestName = "Marines",       Mob = "Marine",          Tier = 1 },
    ["Sky Quest Recruiter"]        = { Level = 150, QuestName = "SkyBandits",    Mob = "Sky Bandit",      Tier = 1 },
    ["Prison Quest Recruiter"]     = { Level = 190, QuestName = "Prisoners",     Mob = "Prisoner",        Tier = 1 },
    ["Magma Quest Recruiter"]      = { Level = 300, QuestName = "MagmaSoldiers", Mob = "Magma Soldier",   Tier = 1 },
    ["Underwater Quest Recruiter"] = { Level = 375, QuestName = "Fishmen",       Mob = "Fishman Warrior", Tier = 1 },
}

local Sea2_Quests = {
    ["Area 1 Quest Recruiter"]         = { Level = 700,  QuestName = "Area1",         Mob = "Raider",            Tier = 1 },
    ["Area 2 Quest Recruiter"]         = { Level = 775,  QuestName = "Area2",         Mob = "Mercenary",         Tier = 1 },
    ["Green Bit Quest Recruiter"]      = { Level = 875,  QuestName = "GreenBit1",     Mob = "Plant Subordinate", Tier = 1 },
    ["Graveyard Quest Recruiter"]      = { Level = 950,  QuestName = "Graveyard1",    Mob = "Zombie",            Tier = 1 },
    ["Snow Mountain Quest Recruiter"]  = { Level = 1000, QuestName = "SnowMountain1", Mob = "Snow Trooper",      Tier = 1 },
    ["Hot Quest Recruiter"]            = { Level = 1100, QuestName = "Hot1",          Mob = "Lab Subordinate",   Tier = 1 },
    ["Cold Quest Recruiter"]           = { Level = 1150, QuestName = "Cold1",         Mob = "Horned Warrior",    Tier = 1 },
    ["Cursed Captain Quest Recruiter"] = { Level = 1250, QuestName = "Ship1",         Mob = "Ship Officer",      Tier = 1 },
    ["Ice Castle Quest Recruiter"]     = { Level = 1350, QuestName = "IceCastle1",    Mob = "Arctic Warrior",    Tier = 1 },
    ["Forgotten Quest Recruiter"]      = { Level = 1425, QuestName = "Forgotten1",    Mob = "Sea Soldier",       Tier = 1 },
}

local Sea3_Quests = {
    ["Port Quest Recruiter"]            = { Level = 1500, QuestName = "PortQuest1",    Mob = "Pirate Millionaire",  Tier = 1 },
    ["Hydra Quest Recruiter"]           = { Level = 1575, QuestName = "HydraQuest1",   Mob = "Dragon Crew Warrior", Tier = 1 },
    ["Great Tree Quest Recruiter"]      = { Level = 1700, QuestName = "TreeQuest1",    Mob = "Marine Commodore",    Tier = 1 },
    ["Floating Turtle Quest Recruiter"] = { Level = 1775, QuestName = "TurtleQuest1",  Mob = "Fishman Raider",      Tier = 1 },
    ["Haunted Castle Quest Recruiter"]  = { Level = 1975, QuestName = "HauntedQuest1", Mob = "Reborn Skeleton",     Tier = 1 },
    ["Candy Quest Recruiter"]           = { Level = 2075, QuestName = "CandyQuest1",   Mob = "Cookie Crafter",      Tier = 1 },
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
-- TELEPORTS (Ilhas) — coordenadas corrigidas
-- Ilhas com requestEntrance usam CommF_:InvokeServer
-- ════════════════════════════════════════════
BloxFruits.Islands = {
    Sea1 = {
        -- Teleport direto (CFrame)
        ["Starter Island"]   = { pos = Vector3.new(977.8, 6.5, 1582.9),       useEntrance = false },
        ["Marine Starter"]   = { pos = Vector3.new(-967.8, 6.5, 1582.9),      useEntrance = false },
        ["Jungle"]           = { pos = Vector3.new(-1766.6, 14.3, -3096.6),   useEntrance = false },
        ["Pirate Village"]   = { pos = Vector3.new(-1306.4, 4.0, 312.9),      useEntrance = false },
        ["Desert"]           = { pos = Vector3.new(941.0, 6.0, -2767.0),      useEntrance = false },
        ["Frozen Village"]   = { pos = Vector3.new(1239.7, 9.5, -3011.0),     useEntrance = false },
        ["Marine Fortress"]  = { pos = Vector3.new(-4600.0, 10.0, 4068.0),    useEntrance = false },
        ["Prison"]           = { pos = Vector3.new(4781.7, 5.0, 803.3),       useEntrance = false },
        ["Magma Village"]    = { pos = Vector3.new(-4648.3, 46.0, -881.4),    useEntrance = false },
        -- requestEntrance (instâncias especiais)
        ["Skylands"]         = { pos = Vector3.new(-4607.82275, 872.54248, -1667.55688),              useEntrance = true  },
        ["Underwater City"]  = { pos = Vector3.new(61163.8515625, 11.6796875, 1819.7841796875),       useEntrance = true  },
    },
    Sea2 = {
        ["Kingdom of Rose"]  = { pos = Vector3.new(-789.7, 73.5, -3774.0),    useEntrance = false },
        ["Green Zone"]       = { pos = Vector3.new(-1887.9, 22.0, -5018.8),   useEntrance = false },
        ["Graveyard"]        = { pos = Vector3.new(3775.0, 24.0, -4313.0),    useEntrance = false },
        ["Snow Mountain"]    = { pos = Vector3.new(2117.0, 214.0, -5229.0),   useEntrance = false },
        ["Hot & Cold"]       = { pos = Vector3.new(441.0, 157.0, -5462.0),    useEntrance = false },
        ["Cursed Ship"]      = { pos = Vector3.new(-4098.0, 2.0, -5296.0),    useEntrance = false },
        ["Ice Castle"]       = { pos = Vector3.new(-1500.0, 4.0, -6500.0),    useEntrance = false },
        ["Forgotten Island"] = { pos = Vector3.new(0.0, 5.0, -7000.0),        useEntrance = false },
        -- requestEntrance
        ["Zou"]              = { pos = Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047),   useEntrance = true },
    },
    Sea3 = {
        ["Port Town"]        = { pos = Vector3.new(-8985.0, 6.0, -1873.0),    useEntrance = false },
        ["Hydra Island"]     = { pos = Vector3.new(-9648.0, 6.0, 786.0),      useEntrance = false },
        ["Great Tree"]       = { pos = Vector3.new(-8487.0, 5.0, 5450.0),     useEntrance = false },
        ["Floating Turtle"]  = { pos = Vector3.new(-13720.0, 0.0, -3839.0),   useEntrance = false },
        ["Haunted Castle"]   = { pos = Vector3.new(-11860.0, 5.0, -7490.0),   useEntrance = false },
        ["Candy Land"]       = { pos = Vector3.new(-1835.0, 5.0, -19000.0),   useEntrance = false },
        -- requestEntrance
        ["Dressrosa"]        = { pos = Vector3.new(923.21252441406, 126.9760055542, 32852.83203125),       useEntrance = true },
        ["Flame Tower"]      = { pos = Vector3.new(5643.4526367188, 1013.0858154297, -340.51025390625),    useEntrance = true },
        ["Haunted Castle 2"] = { pos = Vector3.new(-12471.169921875, 374.94024658203, -7551.677734375),    useEntrance = true },
        ["Mansion"]          = { pos = Vector3.new(5314.5463867188, 22.562219619751, -127.06755065918),    useEntrance = true },
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
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function getLevel()
    local ok, lvl = pcall(function()
        return LocalPlayer.Data.Level.Value
    end)
    if ok and lvl then return lvl end
    local ok2, lvl2 = pcall(function()
        local data = LocalPlayer:FindFirstChild("Data")
        return data and data:FindFirstChild("Level") and data.Level.Value or 0
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
    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { CFrame = CFrame.new(pos) }
    )
    tween:Play()
    tween.Completed:Wait()
end

local function disconnect(name)
    if State.Connections[name] then
        pcall(function() State.Connections[name]:Disconnect() end)
        State.Connections[name] = nil
    end
end

-- Wrapper seguro para CommF_ (RemoteFunction)
local function invokeServer(...)
    local ok, result = pcall(function(...)
        return CommF_:InvokeServer(...)
    end, ...)
    if not ok then
        warn("[BloxFruits] InvokeServer erro: " .. tostring(result))
    end
    return ok and result or nil
end

-- Wrapper seguro para CommE (RemoteEvent)
local function fireServer(...)
    local ok, err = pcall(function(...)
        CommE:FireServer(...)
    end, ...)
    if not ok then
        warn("[BloxFruits] FireServer erro: " .. tostring(err))
    end
end

-- Encontra quest adequada para o nível atual
local function getBestQuest(sea)
    local level = getLevel()
    local questTable = sea == 1 and Sea1_Quests or sea == 2 and Sea2_Quests or Sea3_Quests
    local bestRecruiter, bestLevel = nil, -1
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

-- Encontra modelo vivo no Workspace pelo nome
local function findModel(name)
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

-- Verifica se um modelo pertence a um player
local function isPlayerCharacter(model)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == model then return true end
    end
    return false
end

-- ════════════════════════════════════════════
-- AUTO QUEST
-- Remote correto: CommF_:InvokeServer("StartQuest", QuestName, Tier)
--                 CommF_:InvokeServer("AbandonQuest")
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

                -- Checa se a quest já está ativa
                local questHolder = LocalPlayer:FindFirstChild("QuestHolder")
                local hasQuest = questHolder and questHolder:FindFirstChild(questData.QuestName)

                if not hasQuest then
                    -- Abandona quest atual (se houver) e aceita a nova
                    invokeServer("AbandonQuest")
                    task.wait(0.3)
                    -- Vai ao recruiter se existir no mapa
                    local _, recHRP = findModel(recruiter)
                    if recHRP then
                        teleportTo(recHRP.Position)
                        task.wait(0.5)
                    end
                    -- Aceita a nova quest via remote correto
                    invokeServer("StartQuest", questData.QuestName, questData.Tier)
                    task.wait(0.5)
                end
            end)
            if not ok then warn("[BloxFruits] AutoQuest erro: " .. tostring(err)) end
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
                local _, mobHRP = findModel(State.CurrentQuest.Mob)
                if mobHRP then
                    local hrp = getHRP()
                    if hrp then
                        hrp.CFrame = CFrame.new(mobHRP.Position + Vector3.new(0, 3, 0))
                        task.wait(0.05)
                        -- Ataca via Tool RemoteEvent
                        local char = getChar()
                        if char then
                            local tool = char:FindFirstChildOfClass("Tool")
                            if tool then
                                local re = tool:FindFirstChildOfClass("RemoteEvent")
                                if re then
                                    pcall(function()
                                        re:FireServer("TAP", mobHRP.Position)
                                    end)
                                end
                            end
                        end
                    end
                end
            end)
            if not ok then warn("[BloxFruits] AutoFarm erro: " .. tostring(err)) end
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
                        local hum    = v:FindFirstChildOfClass("Humanoid")
                        if mobHRP and hum and hum.Health > 0 then
                            mobHRP.CFrame = CFrame.new(
                                hrp.Position + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
                            )
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
                    if v:IsA("Model") and not isPlayerCharacter(v) and v ~= LocalPlayer.Character then
                        local vHRP = v:FindFirstChild("HumanoidRootPart")
                        local vHum = v:FindFirstChildOfClass("Humanoid")
                        if vHRP and vHum and vHum.Health > 0 then
                            if (hrp.Position - vHRP.Position).Magnitude <= radius then
                                hrp.CFrame = CFrame.new(vHRP.Position + Vector3.new(0, 3, 0))
                                -- Ataca via Tool
                                local char = getChar()
                                if char then
                                    local tool = char:FindFirstChildOfClass("Tool")
                                    if tool then
                                        local re = tool:FindFirstChildOfClass("RemoteEvent")
                                        if re then
                                            pcall(function() re:FireServer("TAP", vHRP.Position) end)
                                        end
                                    end
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
    State.FastAttack = enabled
    pcall(function()
        local char = getChar()
        if not char then return end
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("Tool") then
                local cfg = v:FindFirstChild("Config")
                if cfg then
                    local cd = cfg:FindFirstChild("Cooldown")
                    if cd then cd.Value = enabled and 0.01 or 0.5 end
                end
            end
        end
    end)
end

-- ════════════════════════════════════════════
-- AUTO HAKI
-- Remote correto: CommE:FireServer("Ken", true)
-- ════════════════════════════════════════════
function BloxFruits.SetAutoHaki(enabled)
    if enabled then
        State.AutoHaki = true
        State.Connections["AutoHaki"] = RunService.Heartbeat:Connect(function()
            if not State.AutoHaki then return end
            -- Ken (Observation Haki)
            fireServer("Ken", true)
            task.wait(10)
        end)
    else
        State.AutoHaki = false
        disconnect("AutoHaki")
        -- Desativa Ken ao parar
        pcall(function() CommE:FireServer("Ken", false) end)
    end
end

-- ════════════════════════════════════════════
-- AUTO BOSS
-- ════════════════════════════════════════════
function BloxFruits.SetAutoBoss(enabled, bossName)
    if enabled and bossName then
        State.AutoBoss    = true
        State.CurrentBoss = bossName
        State.Connections["AutoBoss"] = RunService.Heartbeat:Connect(function()
            if not State.AutoBoss then return end
            local ok, err = pcall(function()
                local _, bossHRP = findModel(bossName)
                if bossHRP then
                    local hrp = getHRP()
                    if hrp then
                        hrp.CFrame = CFrame.new(bossHRP.Position + Vector3.new(0, 3, 0))
                        -- Ataca
                        local char = getChar()
                        if char then
                            local tool = char:FindFirstChildOfClass("Tool")
                            if tool then
                                local re = tool:FindFirstChildOfClass("RemoteEvent")
                                if re then
                                    pcall(function() re:FireServer("TAP", bossHRP.Position) end)
                                end
                            end
                        end
                    end
                end
            end)
            if not ok then warn("[BloxFruits] AutoBoss erro: " .. tostring(err)) end
            task.wait(0.2)
        end)
    else
        State.AutoBoss    = false
        State.CurrentBoss = nil
        disconnect("AutoBoss")
    end
end

-- ════════════════════════════════════════════
-- AUTO STATS
-- Remote correto: CommF_:InvokeServer("AddPoint", StatName, Amount)
-- Stats: "Melee", "Defense", "Sword", "Gun", "Demon Fruit"
-- ════════════════════════════════════════════
function BloxFruits.SetAutoStats(enabled, priority)
    priority = priority or "Melee"
    if enabled then
        State.AutoStats = true
        State.Connections["AutoStats"] = RunService.Heartbeat:Connect(function()
            if not State.AutoStats then return end
            local ok, err = pcall(function()
                local data = LocalPlayer:FindFirstChild("Data")
                if not data then return end
                local statPoints = data:FindFirstChild("StatPoints")
                if not statPoints or statPoints.Value <= 0 then return end
                invokeServer("AddPoint", priority, statPoints.Value)
            end)
            if not ok then warn("[BloxFruits] AutoStats erro: " .. tostring(err)) end
            task.wait(1)
        end)
    else
        State.AutoStats = false
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
                local hrp = getHRP()
                if not hrp then return end
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if v:IsA("Model") and not isPlayerCharacter(v) and v ~= LocalPlayer.Character then
                        local vHRP = v:FindFirstChild("HumanoidRootPart")
                        local vHum = v:FindFirstChildOfClass("Humanoid")
                        if vHRP and vHum and vHum.Health > 0 then
                            hrp.CFrame = CFrame.new(vHRP.Position + Vector3.new(0, 3, 0))
                            -- Ataca via tool
                            local char = getChar()
                            if char then
                                local tool = char:FindFirstChildOfClass("Tool")
                                if tool then
                                    local re = tool:FindFirstChildOfClass("RemoteEvent")
                                    if re then pcall(function() re:FireServer("TAP", vHRP.Position) end) end
                                end
                            end
                            break -- um mob por tick
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
                local _, levHRP = findModel("Leviathan")
                if levHRP then
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

local SEA_BEAST_NAMES = { "Sea Beast", "Rip_Indra", "Leviathan", "Terror Shark" }

function BloxFruits.SetSeaBeastFarm(enabled)
    State.SeaBeastFarm = enabled
    if enabled then
        State.Connections["SeaBeast"] = RunService.Heartbeat:Connect(function()
            if not State.SeaBeastFarm then return end
            local ok, err = pcall(function()
                for _, name in ipairs(SEA_BEAST_NAMES) do
                    local _, beastHRP = findModel(name)
                    if beastHRP then
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
                        if vHRP and not v:FindFirstChild("ZenithESP_TS") then
                            local sb = Instance.new("SelectionBox")
                            sb.Name          = "ZenithESP_TS"
                            sb.Adornee       = v
                            sb.Color3        = Color3.fromRGB(255, 0, 0)
                            sb.LineThickness = 0.05
                            sb.Parent        = v
                        end
                    end
                end
            end)
            if not ok then warn("[BloxFruits] TerrorSharkESP erro: " .. tostring(err)) end
            task.wait(1)
        end)
    else
        disconnect("TerrorSharkESP")
        for _, v in ipairs(Workspace:GetDescendants()) do
            local esp = v:FindFirstChild("ZenithESP_TS")
            if esp then esp:Destroy() end
        end
    end
end

-- ════════════════════════════════════════════
-- RACES / V4
-- Remote correto: CommE:FireServer("ActivateAbility")
-- ════════════════════════════════════════════
function BloxFruits.SetAutoRaceV4(enabled, race)
    State.AutoRaceV4 = enabled
    if enabled and race then
        State.Connections["AutoRaceV4"] = RunService.Heartbeat:Connect(function()
            if not State.AutoRaceV4 then return end
            -- Ativa a habilidade racial via CommE
            fireServer("ActivateAbility")
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
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if v:IsA("Model") then
                        local fruitLabel = v:FindFirstChild("FruitName") or v:FindFirstChild("Name_Tag")
                        local fruitName  = (fruitLabel and (fruitLabel.Value or fruitLabel.Text)) or v.Name
                        for _, target in ipairs(targetFruits) do
                            if string.find(fruitName, target, 1, true) then
                                local vPart = v.PrimaryPart or v:FindFirstChild("HumanoidRootPart")
                                if vPart then
                                    teleportTo(vPart.Position)
                                    task.wait(0.5)
                                    -- Pega via EatRemote ou touch
                                    local eatRemote = v:FindFirstChild("EatRemote", true)
                                    if eatRemote then
                                        pcall(function() eatRemote:InvokeServer("Pickup") end)
                                    end
                                end
                                break
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
-- STORE / DROP FRUIT
-- Remote correto: CommF_:InvokeServer("StoreFruit", OriginalName, FruitTool)
--                 EatRemote:InvokeServer("Drop")
-- ════════════════════════════════════════════
function BloxFruits.StoreFruit()
    local ok, err = pcall(function()
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if not backpack then return end
        for _, item in ipairs(backpack:GetChildren()) do
            local eatRemote = item:FindFirstChild("EatRemote", true)
            if eatRemote then
                local originalName = item:GetAttribute("OriginalName") or item.Name
                invokeServer("StoreFruit", originalName, item)
                task.wait(0.2)
            end
        end
    end)
    if not ok then warn("[BloxFruits] StoreFruit erro: " .. tostring(err)) end
end

function BloxFruits.DropFruit()
    local ok, err = pcall(function()
        local char = getChar()
        if not char then return end
        for _, item in ipairs(char:GetChildren()) do
            local eatRemote = item:FindFirstChildOfClass("RemoteFunction")
            if eatRemote and eatRemote.Name == "EatRemote" then
                pcall(function() eatRemote:InvokeServer("Drop") end)
            end
        end
    end)
    if not ok then warn("[BloxFruits] DropFruit erro: " .. tostring(err)) end
end

-- ════════════════════════════════════════════
-- TELEPORT ISLAND
-- Ilhas normais: CFrame direto
-- Ilhas especiais: CommF_:InvokeServer("requestEntrance", Vector3)
-- ════════════════════════════════════════════
function BloxFruits.TeleportIsland(islandName, sea, useTween)
    local ok, err = pcall(function()
        local seaTable = BloxFruits.Islands["Sea" .. tostring(sea or 1)]
        if not seaTable then return end
        local data = seaTable[islandName]
        if not data then return end

        if data.useEntrance then
            -- Teleporte via servidor (instâncias: Skylands, Underwater, Zou, etc.)
            invokeServer("requestEntrance", data.pos)
        elseif useTween then
            tweenTo(data.pos + Vector3.new(0, 3, 0), 2)
        else
            teleportTo(data.pos)
        end
    end)
    if not ok then warn("[BloxFruits] TeleportIsland erro: " .. tostring(err)) end
end

-- ════════════════════════════════════════════
-- SET TEAM
-- Remote correto: CommF_:InvokeServer("SetTeam", "Marines"/"Pirates")
-- ════════════════════════════════════════════
function BloxFruits.SetTeam(team)
    if team ~= "Marines" and team ~= "Pirates" then
        warn("[BloxFruits] SetTeam: time inválido. Use 'Marines' ou 'Pirates'.")
        return
    end
    invokeServer("SetTeam", team)
end

-- ════════════════════════════════════════════
-- LOAD ITEM (equipa item do inventário)
-- Remote correto: CommF_:InvokeServer("LoadItem", ItemName)
-- ════════════════════════════════════════════
function BloxFruits.LoadItem(itemName)
    invokeServer("LoadItem", itemName)
end

-- ════════════════════════════════════════════
-- GET INVENTORY
-- Remote correto: CommF_:InvokeServer("getInventory")
-- ════════════════════════════════════════════
function BloxFruits.GetInventory()
    return invokeServer("getInventory")
end

-- ════════════════════════════════════════════
-- LIMPEZA GERAL
-- ════════════════════════════════════════════
function BloxFruits.Cleanup()
    for k, v in pairs(State) do
        if type(v) == "boolean" then
            State[k] = false
        end
    end
    for name, conn in pairs(State.Connections) do
        pcall(function() conn:Disconnect() end)
        State.Connections[name] = nil
    end
    State.CurrentQuest = nil
    State.CurrentBoss  = nil
    -- Remove ESPs
    for _, v in ipairs(Workspace:GetDescendants()) do
        local esp = v:FindFirstChild("ZenithESP_TS")
        if esp then esp:Destroy() end
    end
    -- Desativa Ken ao limpar
    pcall(function() CommE:FireServer("Ken", false) end)
end

return BloxFruits
