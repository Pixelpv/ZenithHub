--[[
    ZenithHub — Modules/BloxFruits.lua
    Módulo completo para Blox Fruits
    Remotes e coordenadas extraídos de OPEN_SOURCE_ZYN_HUB e OPEN_SOURCE_VUA_HUB
    ─────────────────────────────────────────────────────────────────────────────
    REMOTES OFICIAIS
      CommF_ = ReplicatedStorage.Remotes.CommF_  (RemoteFunction → InvokeServer)
      CommE  = ReplicatedStorage.Remotes.CommE   (RemoteEvent    → FireServer  )
]]

local BloxFruits = {}

-- ════════════════════════════════════════════
-- SERVIÇOS
-- ════════════════════════════════════════════
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local Workspace         = game:GetService("Workspace")
local vim               = game:GetService("VirtualInputManager")
local VirtualUser       = game:GetService("VirtualUser")

local plr       = Players.LocalPlayer
local Remotes   = ReplicatedStorage:WaitForChild("Remotes")
local CommF_    = Remotes:WaitForChild("CommF_")
local CommE     = Remotes:WaitForChild("CommE")

-- Detecção de mundo (Sea)
local placeId = game.PlaceId
local World1 = (placeId == 2753915549 or placeId == 85211729168715)
local World2 = (placeId == 4442272183 or placeId == 79091703265657)
local World3 = (placeId == 7449423635 or placeId == 100117331123089)

-- ════════════════════════════════════════════
-- ESTADO INTERNO
-- ════════════════════════════════════════════
local State = {
    -- Main Farm
    AutoFarm        = false,
    AutoQuest       = false,
    AutoStats       = false,
    AutoHaki        = false,       -- Buso (armamento)
    AutoKen         = false,       -- Observation
    AutoRaceAbility = false,       -- V3/V4
    FastAttack      = false,
    BringMobs       = false,
    -- Bosses
    AutoBoss        = false,
    SelectedBoss    = nil,
    -- Sea Events
    AutoSeaBeast    = false,
    AutoTerrorShark = false,
    AutoLeviathan   = false,
    AutoFishBoat    = false,
    AutoPirateBrigade = false,
    AutoPiranha     = false,
    AutoHauntedCrew = false,
    -- Fruits
    AutoFruitSniper = false,
    AutoFruitCollect= false,
    AutoStoreFruits = false,
    FruitESP        = false,
    AutoBuyFruit    = false,
    SelectedFruit   = "Dough-Dough",
    RareFruits      = {"Kitsune-Kitsune","Dragon-Dragon","Leopard-Leopard","Yeti-Yeti","T-Rex-T-Rex","Gas-Gas","Spirit-Spirit"},
    -- Raids
    AutoBuyChip     = false,
    AutoStartRaid   = false,
    AutoRaidFarm    = false,
    SelectedChip    = "Flame",
    -- Races/V4
    AutoRaceV4      = false,
    -- Connections
    Connections     = {},
    -- Quest state
    CurrentQuest    = nil,
    QuestMob        = nil,
    QuestPos        = nil,
    FarmPos         = nil,
    -- Bring
    BringActive     = false,
    BringPos        = nil,
    MobHeight       = 20,
    BringRange      = 235,
}

-- ════════════════════════════════════════════
-- WRAPPERS SEGUROS DE REMOTE
-- ════════════════════════════════════════════
local function invoke(...)
    local ok, r = pcall(function(...) return CommF_:InvokeServer(...) end, ...)
    if not ok then warn("[ZenithHub|BF] invoke erro:", r) end
    return ok and r or nil
end

local function fire(...)
    local ok, e = pcall(function(...) CommE:FireServer(...) end, ...)
    if not ok then warn("[ZenithHub|BF] fire erro:", e) end
end

-- ════════════════════════════════════════════
-- UTILITÁRIOS BASE
-- ════════════════════════════════════════════
local function getChar()  return plr.Character end
local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function getLevel()
    local ok, v = pcall(function() return plr.Data.Level.Value end)
    return ok and v or 0
end
local function hasQuest()
    local gui = plr.PlayerGui:FindFirstChild("Main")
    return gui and gui:FindFirstChild("Quest") and gui.Quest.Visible
end
local function getQuestTitle()
    local gui = plr.PlayerGui:FindFirstChild("Main")
    if gui and gui:FindFirstChild("Quest") and gui.Quest:FindFirstChild("Container") then
        local title = gui.Quest.Container:FindFirstChild("QuestTitle")
        if title and title:FindFirstChild("Title") then
            return title.Title.Text
        end
    end
    return ""
end

-- Teleporte instantâneo
local function notween(cf)
    local hrp = getHRP()
    if hrp then hrp.CFrame = cf end
end

-- Teleporte com tween ajustado por distância (extraído do ZYN hub)
local TweenSpeedFar  = 300
local TweenSpeedNear = 900
local TweenPart      -- Part âncora (como no ZYN hub)

local function initTweenPart()
    if TweenPart and TweenPart.Parent then return end
    TweenPart = Instance.new("Part", Workspace)
    TweenPart.Size      = Vector3.new(1,1,1)
    TweenPart.Anchored  = true
    TweenPart.CanCollide = false
    TweenPart.CanTouch  = false
    TweenPart.Transparency = 1
    TweenPart.Name = "ZenithTweenAnchor"
    local hrp = getHRP()
    if hrp then TweenPart.CFrame = hrp.CFrame end
end

local function _tp(targetCF)
    local hrp = getHRP()
    if not hrp then return end
    initTweenPart()

    local dist  = (targetCF.Position - hrp.Position).Magnitude
    local speed = dist <= 90 and TweenSpeedNear or TweenSpeedFar
    local info  = TweenInfo.new(dist / speed, Enum.EasingStyle.Linear)
    local tw    = TweenService:Create(TweenPart, info, { CFrame = targetCF })
    tw:Play()

    task.spawn(function()
        while tw.PlaybackState == Enum.PlaybackState.Playing do
            local c = getChar()
            if c and c.PrimaryPart then
                c.PrimaryPart.CFrame = TweenPart.CFrame
            end
            task.wait(0.05)
        end
    end)
end

-- Equipa ferramenta pelo ToolTip
local function equipByType(tipType)
    local bp = plr.Backpack
    for _, t in ipairs(bp:GetChildren()) do
        if t:IsA("Tool") and t.ToolTip == tipType then
            local hum = getHum()
            if hum then hum:EquipTool(t) return true end
        end
    end
    return false
end

-- Usa skill de categoria (extraído do ZYN hub)
local function useSkill(category, key)
    equipByType(category)
    task.wait(0.05)
    vim:SendKeyEvent(true,  key, false, game)
    vim:SendKeyEvent(false, key, false, game)
end

-- Ataca mob com ferramenta equipada (Tool.RemoteEvent:FireServer("TAP", pos))
local function attackMob(mobHRP)
    local c = getChar()
    if not c then return end
    local tool = c:FindFirstChildOfClass("Tool")
    if not tool then return end
    local re = tool:FindFirstChildOfClass("RemoteEvent")
    if re then
        pcall(function() re:FireServer("TAP", mobHRP.Position) end)
    end
end

-- Verifica se um modelo é personagem de player
local function isPlayer(model)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == model then return true end
    end
    return false
end

-- Encontra mob/boss vivo pelo nome (busca em Workspace.Enemies e Workspace)
local function findModel(name)
    -- Prioridade: Workspace.Enemies
    local enemies = Workspace:FindFirstChild("Enemies")
    if enemies then
        for _, v in ipairs(enemies:GetChildren()) do
            if v.Name == name then
                local hrp = v:FindFirstChild("HumanoidRootPart")
                local hum = v:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then return v, hrp end
            end
        end
    end
    -- Fallback: Workspace completo
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name == name then
            local hrp = v:FindFirstChild("HumanoidRootPart")
            local hum = v:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then return v, hrp end
        end
    end
    return nil, nil
end

-- Encontra o mob vivo mais próximo de uma lista de nomes
local function findNearestFromList(nameList)
    local hrp = getHRP()
    if not hrp then return nil, nil end
    local best, bestHRP, bestDist = nil, nil, math.huge
    local enemies = Workspace:FindFirstChild("Enemies")
    local pool = enemies and enemies:GetChildren() or Workspace:GetDescendants()
    for _, v in ipairs(pool) do
        if (not enemies and v:IsA("Model")) or enemies then
            local name = v.Name
            local found = false
            for _, n in ipairs(nameList) do if n == name then found = true break end end
            if found then
                local vHRP = v:FindFirstChild("HumanoidRootPart")
                local vHum = v:FindFirstChildOfClass("Humanoid")
                if vHRP and vHum and vHum.Health > 0 then
                    local d = (hrp.Position - vHRP.Position).Magnitude
                    if d < bestDist then
                        best, bestHRP, bestDist = v, vHRP, d
                    end
                end
            end
        end
    end
    return best, bestHRP
end

-- Desconecta uma connection por nome
local function disconnect(name)
    if State.Connections[name] then
        pcall(function() State.Connections[name]:Disconnect() end)
        State.Connections[name] = nil
    end
end

-- ════════════════════════════════════════════
-- BRING MOBS (extraído do ZYN hub — TweenService)
-- ════════════════════════════════════════════
local function bringEnemies()
    if not State.BringActive then return end
    local hrp = getHRP()
    if not hrp then return end

    pcall(function()
        sethiddenproperty(plr, "SimulationRadius", math.huge)
    end)

    local targetPos = State.BringPos or hrp.Position
    local enemies   = Workspace:FindFirstChild("Enemies")
    if not enemies then return end

    local count = 0
    local tweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

    for _, mob in ipairs(enemies:GetChildren()) do
        if count >= 5 then break end
        local hum  = mob:FindFirstChild("Humanoid")
        local root = mob:FindFirstChild("HumanoidRootPart")
        if hum and root and hum.Health > 0 and not isPlayer(mob) then
            local dist = (root.Position - targetPos).Magnitude
            if dist <= State.BringRange and not root:GetAttribute("ZenithTweening") then
                count += 1
                root:SetAttribute("ZenithTweening", true)
                local tw = TweenService:Create(root, tweenInfo, { CFrame = CFrame.new(targetPos) })
                tw:Play()
                tw.Completed:Once(function()
                    if root then root:SetAttribute("ZenithTweening", false) end
                end)
            end
        end
    end
end

-- ════════════════════════════════════════════
-- TABELA COMPLETA DE QUESTS POR NÍVEL
-- Fonte: OPEN_SOURCE_ZYN_HUB (QuestCheck function)
-- Formato: { MinLv, MaxLv, Mob, QuestName, QuestTier, QuestCF, MobCF, EntranceVec3? }
-- ════════════════════════════════════════════

local QuestTable_Sea1 = {
    { 1,   9,   "Trainee",           "MarineQuest",     1, CFrame.new(-2709.68, 24.52, 2104.25),          CFrame.new(-2709.68, 24.52, 2104.25)         },
    { 1,   9,   "Bandit",            "BanditQuest1",    1, CFrame.new(1045.96, 27.00, 1560.82),           CFrame.new(1045.96, 27.00, 1560.82)          },
    { 10,  14,  "Monkey",            "JungleQuest",     1, CFrame.new(-1598.09, 35.55, 153.38),           CFrame.new(-1448.52, 67.85, 11.47)           },
    { 15,  29,  "Gorilla",           "JungleQuest",     2, CFrame.new(-1598.09, 35.55, 153.38),           CFrame.new(-1129.88, 40.46, -525.42)         },
    { 30,  39,  "Pirate",            "BuggyQuest1",     1, CFrame.new(-1141.07, 4.10, 3831.55),           CFrame.new(-1103.51, 13.75, 3896.09)         },
    { 40,  59,  "Brute",             "BuggyQuest1",     2, CFrame.new(-1141.07, 4.10, 3831.55),           CFrame.new(-1140.08, 14.81, 4322.92)         },
    { 60,  74,  "Desert Bandit",     "DesertQuest",     1, CFrame.new(894.49, 5.14, 4392.43),             CFrame.new(924.80, 6.45, 4481.59)            },
    { 75,  89,  "Desert Officer",    "DesertQuest",     2, CFrame.new(894.49, 5.14, 4392.43),             CFrame.new(1608.28, 8.61, 4371.01)           },
    { 90,  99,  "Snow Bandit",       "SnowQuest",       1, CFrame.new(1389.74, 88.15, -1298.91),          CFrame.new(1354.35, 87.27, -1393.95)         },
    { 100, 119, "Snowman",           "SnowQuest",       2, CFrame.new(1389.74, 88.15, -1298.91),          CFrame.new(1201.64, 144.58, -1550.07)        },
    { 120, 149, "Chief Petty Officer","MarineQuest2",   1, CFrame.new(-5039.59, 27.35, 4324.68),          CFrame.new(-4881.23, 22.65, 4273.75)         },
    { 150, 174, "Sky Bandit",        "SkyQuest",        1, CFrame.new(-4839.53, 716.37, -2619.44),        CFrame.new(-4953.21, 295.74, -2899.23)       },
    { 175, 189, "Dark Master",       "SkyQuest",        2, CFrame.new(-4839.53, 716.37, -2619.44),        CFrame.new(-5259.84, 391.40, -2229.04)       },
    { 190, 209, "Prisoner",          "PrisonerQuest",   1, CFrame.new(5308.93, 1.66, 475.12),             CFrame.new(5098.97, -0.32, 474.24)           },
    { 210, 249, "Dangerous Prisoner","PrisonerQuest",   2, CFrame.new(5308.93, 1.66, 475.12),             CFrame.new(5654.56, 15.63, 866.30)           },
    { 250, 274, "Toga Warrior",      "ColosseumQuest",  1, CFrame.new(-1580.05, 6.35, -2986.48),          CFrame.new(-1820.21, 51.68, -2740.67)        },
    { 275, 299, "Gladiator",         "ColosseumQuest",  2, CFrame.new(-1580.05, 6.35, -2986.48),          CFrame.new(-1292.84, 56.38, -3339.03)        },
    { 300, 324, "Military Soldier",  "MagmaQuest",      1, CFrame.new(-5313.37, 10.95, 8515.29),          CFrame.new(-5411.16, 11.08, 8454.29)         },
    { 325, 374, "Military Spy",      "MagmaQuest",      2, CFrame.new(-5313.37, 10.95, 8515.29),          CFrame.new(-5802.87, 86.26, 8828.86)         },
    { 375, 399, "Fishman Warrior",   "FishmanQuest",    1, CFrame.new(61122.65, 18.50, 1569.40),          CFrame.new(60878.30, 18.48, 1543.76),         Vector3.new(61163.8515625, 11.6796875, 1819.7841796875) },
    { 400, 449, "Fishman Commando",  "FishmanQuest",    2, CFrame.new(61122.65, 18.50, 1569.40),          CFrame.new(61922.63, 18.48, 1493.93),         Vector3.new(61163.8515625, 11.6796875, 1819.7841796875) },
    { 450, 474, "God's Guard",       "SkyExp1Quest",    1, CFrame.new(-4721.89, 843.87, -1949.97),        CFrame.new(-4710.04, 845.28, -1927.31),       Vector3.new(-4607.82275, 872.54248, -1667.55688)       },
    { 475, 524, "Shanda",            "SkyExp1Quest",    2, CFrame.new(-7859.10, 5544.19, -381.48),        CFrame.new(-7678.49, 5566.40, -497.22),       Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047) },
    { 525, 549, "Royal Squad",       "SkyExp2Quest",    1, CFrame.new(-7906.82, 5634.66, -1411.99),       CFrame.new(-7624.25, 5658.13, -1467.35)       },
    { 550, 624, "Royal Soldier",     "SkyExp2Quest",    2, CFrame.new(-7906.82, 5634.66, -1411.99),       CFrame.new(-7836.75, 5645.66, -1790.62)       },
    { 625, 649, "Galley Pirate",     "FountainQuest",   1, CFrame.new(5259.82, 37.35, 4050.03),           CFrame.new(5551.02, 78.90, 3930.41)          },
    { 650, 699, "Galley Captain",    "FountainQuest",   2, CFrame.new(5259.82, 37.35, 4050.03),           CFrame.new(5441.95, 42.50, 4950.09)          },
}

local QuestTable_Sea2 = {
    { 700,  724,  "Raider",            "Area1Quest",     1, CFrame.new(-429.54, 71.77, 1836.18),    CFrame.new(-728.33, 52.78, 2345.77)     },
    { 725,  774,  "Mercenary",         "Area1Quest",     2, CFrame.new(-429.54, 71.77, 1836.18),    CFrame.new(-1004.32, 80.16, 1424.62)    },
    { 775,  799,  "Swan Pirate",       "Area2Quest",     1, CFrame.new(638.44, 71.77, 918.28),      CFrame.new(1068.66, 137.61, 1322.11)    },
    { 800,  874,  "Factory Staff",     "Area2Quest",     2, CFrame.new(632.70, 73.11, 918.67),      CFrame.new(73.08, 81.86, -27.47)        },
    { 875,  899,  "Marine Lieutenant", "MarineQuest3",   1, CFrame.new(-2440.80, 71.71, -3216.07),  CFrame.new(-2821.37, 75.90, -3070.09)   },
    { 900,  949,  "Marine Captain",    "MarineQuest3",   2, CFrame.new(-2440.80, 71.71, -3216.07),  CFrame.new(-2010.51, 73.00, -3326.62)   },
    { 950,  974,  "Forest Pirate",     "LawQuest",       1, CFrame.new(-2441.99, 73.36, -3217.53),  CFrame.new(-2821.37, 75.90, -3070.09)   },
    { 975,  999,  "Dark Pirate",       "MarineQuest3",   2, CFrame.new(-2440.80, 71.71, -3216.07),  CFrame.new(-2010.51, 73.00, -3326.62)   },
    { 1000, 1049, "Snow Trooper",      "IceSideQuest",   1, CFrame.new(-5429.05, 15.98, -5297.96),  CFrame.new(-5411.16, 11.08, 8454.29)    },
    { 1050, 1099, "Magma Ninja",       "IceSideQuest",   2, CFrame.new(-5429.05, 15.98, -5297.96),  CFrame.new(-5428.0, 78.0, -5959.0)     },
    { 1100, 1149, "Lava Pirate",       "HotQuest",       1, CFrame.new(-5429.05, 15.98, -5297.96),  CFrame.new(-5428.0, 78.0, -5959.0)     },
    { 1150, 1199, "Horned Warrior",    "ColdQuest",      1, CFrame.new(-5429.05, 15.98, -5297.96),  CFrame.new(-5275.20, 20.76, -5260.67)   },
    { 1200, 1249, "Ship Deckhand",     "Ship1",          1, CFrame.new(911.36, 125.96, 33159.54),   CFrame.new(911.36, 125.96, 33159.54),    Vector3.new(923.21252441406, 126.9760055542, 32852.83203125) },
    { 1250, 1299, "Ship Engineer",     "Ship1",          2, CFrame.new(911.36, 125.96, 33159.54),   CFrame.new(911.36, 125.96, 33159.54),    Vector3.new(923.21252441406, 126.9760055542, 32852.83203125) },
    { 1300, 1349, "Arctic Warrior",    "FrostQuest",     1, CFrame.new(5668.98, 28.52, -6483.35),   CFrame.new(5668.98, 28.52, -6483.35)    },
    { 1350, 1399, "Snow Lurker",       "FrostQuest",     2, CFrame.new(5668.98, 28.52, -6483.35),   CFrame.new(5668.98, 28.52, -6483.35)    },
    { 1400, 1449, "Water Fighter",     "ForgottenQuest", 1, CFrame.new(-3053.98, 237.19, -10145.04),CFrame.new(-3385.0, 239.0, -10542.0)    },
    { 1450, 1499, "Water Fighters",    "ForgottenQuest", 2, CFrame.new(-3053.98, 237.19, -10145.04),CFrame.new(-3795.64, 105.89, -11421.31) },
}

local QuestTable_Sea3 = {
    { 1500, 1524, "Pirate Millionaire", "PiratePortQuest",  1, CFrame.new(-289.77, 43.82, 5579.94),        CFrame.new(-712.83, 98.58, 5711.95)          },
    { 1525, 1574, "Pistol Billionaire", "PiratePortQuest",  2, CFrame.new(-289.77, 43.82, 5579.94),        CFrame.new(-723.43, 147.43, 5931.99)         },
    { 1575, 1624, "Dragon Crew Warrior","AmazonQuest1",     1, CFrame.new(5821.90, 1019.10, -73.72),       CFrame.new(7021.50, 55.76, -730.13)          },
    { 1625, 1699, "Dragon Crew Archer", "AmazonQuest2",     1, CFrame.new(5821.90, 1019.10, -73.72),       CFrame.new(6625.0, 378.0, 244.0)             },
    { 1700, 1774, "Marine Commodore",   "MarineTreeIsland", 1, CFrame.new(2179.30, 28.73, -6739.97),       CFrame.new(2401.0, 123.0, -7589.0)           },
    { 1775, 1824, "Marine Rear Admiral","MarineTreeIsland", 2, CFrame.new(2179.30, 28.73, -6739.97),       CFrame.new(3588.0, 229.0, -7085.0)           },
    { 1825, 1874, "Fishman Raider",     "DeepForestIsland", 1, CFrame.new(-13232.68, 332.40, -7626.01),    CFrame.new(-10941.0, 332.0, -8760.0)         },
    { 1875, 1974, "Fishman Captain",    "DeepForestIsland", 2, CFrame.new(-13232.68, 332.40, -7626.01),    CFrame.new(-11035.0, 332.0, -9087.0)         },
    { 1975, 2024, "Forest Pirate",      "DeepForestIsland2",1, CFrame.new(-12682.10, 390.89, -9902.12),    CFrame.new(-13446.0, 413.0, -7760.0)         },
    { 2025, 2049, "Mythological Pirate","DeepForestIsland2",2, CFrame.new(-12682.10, 390.89, -9902.12),    CFrame.new(-13510.0, 584.0, -6987.0)         },
    { 2050, 2074, "Jungle Pirate",      "HauntedQuest1",    1, CFrame.new(-9516.99, 172.02, 6078.47),      CFrame.new(-11778.0, 426.0, -10592.0)        },
    { 2075, 2099, "Peanut Scout",       "NutsIslandQuest",  1, CFrame.new(-2104.39, 38.10, -10194.22),     CFrame.new(-2143.24, 47.72, -10029.99)       },
    { 2100, 2124, "Peanut President",   "NutsIslandQuest",  2, CFrame.new(-2104.39, 38.10, -10194.22),     CFrame.new(-1859.35, 38.10, -10422.43)       },
    { 2125, 2149, "Ice Cream Chef",     "IceCreamIslandQuest",1,CFrame.new(-820.65, 65.82, -10965.80),    CFrame.new(-872.25, 65.82, -10919.96)        },
    { 2150, 2199, "Ice Cream Commander","IceCreamIslandQuest",2,CFrame.new(-820.65, 65.82, -10965.80),    CFrame.new(-558.06, 112.05, -11290.77)       },
    { 2200, 2224, "Cookie Crafter",     "CakeQuest1",       1, CFrame.new(-2021.32, 37.80, -12028.73),     CFrame.new(-2374.14, 37.80, -12125.31)       },
    { 2225, 2249, "Cake Guard",         "CakeQuest1",       2, CFrame.new(-2021.32, 37.80, -12028.73),     CFrame.new(-1598.31, 43.77, -12244.58)       },
    { 2250, 2274, "Baking Staff",       "CakeQuest2",       1, CFrame.new(-1927.92, 37.80, -12842.54),     CFrame.new(-1887.81, 77.62, -12998.35)       },
    { 2275, 2299, "Head Baker",         "CakeQuest2",       2, CFrame.new(-1927.92, 37.80, -12842.54),     CFrame.new(-2216.19, 82.88, -12869.29)       },
    { 2300, 2324, "Cocoa Warrior",      "ChocQuest1",       1, CFrame.new(233.23, 29.88, -12201.23),       CFrame.new(-21.55, 80.57, -12352.39)         },
    { 2325, 2349, "Chocolate Bar Battler","ChocQuest1",     2, CFrame.new(233.23, 29.88, -12201.23),       CFrame.new(582.59, 77.19, -12463.16)         },
    { 2350, 2374, "Sweet Thief",        "ChocQuest2",       1, CFrame.new(150.51, 30.69, -12774.50),       CFrame.new(165.19, 76.06, -12600.84)         },
    { 2375, 2399, "Candy Rebel",        "ChocQuest2",       2, CFrame.new(150.51, 30.69, -12774.50),       CFrame.new(134.87, 77.25, -12876.55)         },
    { 2400, 2449, "Candy Pirate",       "CandyQuest1",      1, CFrame.new(-1150.04, 20.38, -14446.33),     CFrame.new(-1310.50, 26.02, -14562.40)       },
    { 2450, 2474, "Isle Outlaw",        "TikiQuest1",       1, CFrame.new(-16548.82, 55.61, -172.81),      CFrame.new(-16479.90, 226.61, -300.31)       },
    { 2475, 2499, "Island Boy",         "TikiQuest1",       2, CFrame.new(-16548.82, 55.61, -172.81),      CFrame.new(-16849.40, 192.87, -150.79)       },
    { 2500, 2524, "Sun-kissed Warrior", "TikiQuest2",       1, CFrame.new(-16538.0, 55.0, 1049.0),         CFrame.new(-16347.0, 64.0, 984.0)            },
    { 2525, 2550, "Isle Champion",      "TikiQuest2",       2, CFrame.new(-16541.02, 57.31, 1051.46),      CFrame.new(-16602.10, 130.39, 1087.25)       },
    { 2551, 2574, "Serpent Hunter",     "TikiQuest3",       1, CFrame.new(-16668.03, 105.32, 1568.60),     CFrame.new(-16645.64, 163.09, 1352.87)       },
    { 2575, 2599, "Skull Slayer",       "TikiQuest3",       2, CFrame.new(-16668.03, 105.32, 1568.60),     CFrame.new(-16709.49, 419.68, 1751.09)       },
}

-- Retorna dados da quest para o nível atual
local function getQuestData()
    local lv  = getLevel()
    local tbl = World1 and QuestTable_Sea1 or World2 and QuestTable_Sea2 or QuestTable_Sea3
    for _, q in ipairs(tbl) do
        if lv >= q[1] and lv <= q[2] then
            -- { Mob, QuestName, Tier, QuestCF, MobCF, EntranceVec3? }
            return { Mob=q[3], QuestName=q[4], Tier=q[5], QuestCF=q[6], MobCF=q[7], Entrance=q[8] }
        end
    end
    -- fallback: último da tabela
    local last = tbl[#tbl]
    return { Mob=last[3], QuestName=last[4], Tier=last[5], QuestCF=last[6], MobCF=last[7], Entrance=last[8] }
end

-- ════════════════════════════════════════════
-- BOSSES — posições e quests (ZYN hub)
-- ════════════════════════════════════════════
BloxFruits.BossData = {
    -- Sea 1
    ["The Gorilla King"] = { QuestName="JungleQuest",     Tier=3, QuestCF=CFrame.new(-1601.66, 36.85, 153.39), BossCF=CFrame.new(-1088.76, 8.13, -488.56) },
    ["Bobby"]            = { QuestName="BuggyQuest1",     Tier=3, QuestCF=CFrame.new(-1140.18, 4.75, 3827.41), BossCF=CFrame.new(-1087.38, 46.95, 4040.15) },
    ["The Saw"]          = { QuestName=nil,               Tier=nil,QuestCF=nil,                                 BossCF=CFrame.new(-784.90, 72.43, 1603.58)  },
    ["Yeti"]             = { QuestName="SnowQuest",       Tier=3, QuestCF=CFrame.new(1386.81, 87.27, -1298.36),BossCF=CFrame.new(1218.80, 138.01, -1488.03) },
    ["Vice Admiral"]     = { QuestName="MarineQuest2",    Tier=2, QuestCF=CFrame.new(-5036.25, 28.68, 4324.57),BossCF=CFrame.new(-5006.55, 88.03, 4353.16)  },
    ["Saber Expert"]     = { QuestName=nil,               Tier=nil,QuestCF=nil,                                 BossCF=CFrame.new(-1458.90, 29.89, -50.63)   },
    ["Warden"]           = { QuestName="ImpelQuest",      Tier=1, QuestCF=CFrame.new(5191.86, 2.84, 686.44),   BossCF=CFrame.new(5278.05, 2.15, 944.10)     },
    ["Chief Warden"]     = { QuestName="ImpelQuest",      Tier=2, QuestCF=CFrame.new(5191.86, 2.84, 686.44),   BossCF=CFrame.new(5206.93, 1.00, 814.98)     },
    ["Swan"]             = { QuestName="ImpelQuest",      Tier=3, QuestCF=CFrame.new(5191.86, 2.84, 686.44),   BossCF=CFrame.new(5325.10, 7.04, 719.57)     },
    ["Magma Admiral"]    = { QuestName="MagmaQuest",      Tier=3, QuestCF=CFrame.new(-5314.62, 12.26, 8517.28),BossCF=CFrame.new(-5765.90, 82.92, 8718.30)  },
    ["Fishman Lord"]     = { QuestName="FishmanQuest",    Tier=3, QuestCF=CFrame.new(61122.65, 18.50, 1569.40),BossCF=CFrame.new(61260.15, 30.95, 1193.43)  },
    ["Wysper"]           = { QuestName="SkyExp1Quest",    Tier=3, QuestCF=CFrame.new(-7861.95, 5545.52, -379.86),BossCF=CFrame.new(-7866.13, 5576.43, -546.75), Entrance=Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047) },
    ["Thunder God"]      = { QuestName="SkyExp2Quest",    Tier=3, QuestCF=CFrame.new(-7903.38, 5635.99, -1410.92),BossCF=CFrame.new(-7994.98, 5761.03, -2088.65), Entrance=Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047) },
    ["Cyborg"]           = { QuestName="FountainQuest",   Tier=3, QuestCF=CFrame.new(5258.28, 38.53, 4050.04), BossCF=CFrame.new(6094.02, 73.77, 3825.73)  },
    ["Ice Admiral"]      = { QuestName=nil,               Tier=nil,QuestCF=CFrame.new(1266.09, 26.18, -1399.58),BossCF=CFrame.new(1266.09, 26.18, -1399.58) },
    ["Greybeard"]        = { QuestName=nil,               Tier=nil,QuestCF=CFrame.new(-5081.35, 85.22, 4257.36),BossCF=CFrame.new(-5081.35, 85.22, 4257.36) },
    -- Sea 2
    ["Diamond"]          = { QuestName="Area1Quest",      Tier=3, QuestCF=CFrame.new(-427.57, 73.31, 1835.42), BossCF=CFrame.new(-1576.72, 198.59, 13.72)   },
    ["Jeremy"]           = { QuestName="Area2Quest",      Tier=3, QuestCF=CFrame.new(636.80, 73.41, 918.00),   BossCF=CFrame.new(2006.93, 448.96, 853.98)   },
    ["Fajita"]           = { QuestName="MarineQuest3",    Tier=3, QuestCF=CFrame.new(-2441.99, 73.36, -3217.53),BossCF=CFrame.new(-2172.74, 103.32, -4015.03)},
    ["Don Swan"]         = { QuestName=nil,               Tier=nil,QuestCF=nil,                                 BossCF=CFrame.new(2286.20, 15.18, 863.84)    },
    ["Smoke Admiral"]    = { QuestName="IceSideQuest",    Tier=3, QuestCF=CFrame.new(-5429.05, 15.98, -5297.96),BossCF=CFrame.new(-5275.20, 20.76, -5260.67) },
    ["Awakened Ice Admiral"]={ QuestName="FrostQuest",    Tier=3, QuestCF=CFrame.new(5668.98, 28.52, -6483.35),BossCF=CFrame.new(6403.54, 340.30, -6894.56)  },
    ["Tide Keeper"]      = { QuestName="ForgottenQuest",  Tier=3, QuestCF=CFrame.new(-3053.98, 237.19, -10145.04),BossCF=CFrame.new(-3795.64, 105.89, -11421.31)},
    ["Darkbeard"]        = { QuestName=nil,               Tier=nil,QuestCF=CFrame.new(3677.08, 62.75, -3144.83),BossCF=CFrame.new(3677.08, 62.75, -3144.83)  },
    ["Cursed Captain"]   = { QuestName=nil,               Tier=nil,QuestCF=CFrame.new(916.93, 181.09, 33422.0),BossCF=CFrame.new(916.93, 181.09, 33422.0),    Entrance=Vector3.new(923.21252441406, 126.9760055542, 32852.83203125) },
    ["Order"]            = { QuestName=nil,               Tier=nil,QuestCF=CFrame.new(-6217.20, 28.05, -5053.14),BossCF=CFrame.new(-6217.20, 28.05, -5053.14)},
    -- Sea 3
    ["Stone"]            = { QuestName="PiratePortQuest", Tier=3, QuestCF=CFrame.new(-289.77, 43.82, 5579.94), BossCF=CFrame.new(-1027.65, 92.40, 6578.85)  },
    ["Hydra Leader"]     = { QuestName="AmazonQuest2",    Tier=3, QuestCF=CFrame.new(5821.90, 1019.10, -73.72),BossCF=CFrame.new(5821.90, 1019.10, -73.72)   },
    ["Kilo Admiral"]     = { QuestName="MarineTreeIsland",Tier=3, QuestCF=CFrame.new(2179.30, 28.73, -6739.97),BossCF=CFrame.new(2764.22, 432.46, -7144.46)  },
    ["Captain Elephant"] = { QuestName="DeepForestIsland",Tier=3, QuestCF=CFrame.new(-13232.68, 332.40, -7626.01),BossCF=CFrame.new(-13376.76, 433.29, -8071.39)},
    ["Beautiful Pirate"] = { QuestName="DeepForestIsland2",Tier=3,QuestCF=CFrame.new(-12682.10, 390.89, -9902.12),BossCF=CFrame.new(5283.61, 22.56, -110.78) },
    ["Cake Queen"]       = { QuestName="IceCreamIslandQuest",Tier=3,QuestCF=CFrame.new(-819.38, 64.93, -10967.28),BossCF=CFrame.new(-678.65, 381.35, -11114.20)},
    ["Longma"]           = { QuestName=nil,               Tier=nil,QuestCF=CFrame.new(-10238.88, 389.79, -9549.79),BossCF=CFrame.new(-10238.88, 389.79, -9549.79)},
    ["Soul Reaper"]      = { QuestName=nil,               Tier=nil,QuestCF=CFrame.new(-9524.79, 315.80, 6655.72),BossCF=CFrame.new(-9524.79, 315.80, 6655.72)  },
    -- Especiais
    ["Rip_Indra"]        = { QuestName=nil,               Tier=nil,QuestCF=nil,                                 BossCF=CFrame.new(0, 0, 0)                   },
    ["Leviathan"]        = { QuestName=nil,               Tier=nil,QuestCF=nil,                                 BossCF=CFrame.new(0, 0, 0)                   },
    ["Cake King"]        = { QuestName=nil,               Tier=nil,QuestCF=nil,                                 BossCF=CFrame.new(-2021.32, 37.80, -12028.73) },
    ["Tyrant of the Skies"]=  { QuestName=nil,            Tier=nil,QuestCF=CFrame.new(-16665.09, 105.27, 1577.62),BossCF=CFrame.new(-16709.49, 419.68, 1751.09)},
}

-- ════════════════════════════════════════════
-- ILHAS — coordenadas de teleporte
-- ════════════════════════════════════════════
BloxFruits.Islands = {
    Sea1 = {
        ["Starter Island"]   = { CF=CFrame.new(977.8, 6.5, 1582.9)                                                   },
        ["Marine Starter"]   = { CF=CFrame.new(-967.8, 6.5, 1582.9)                                                  },
        ["Jungle"]           = { CF=CFrame.new(-1766.6, 14.3, -3096.6)                                               },
        ["Pirate Village"]   = { CF=CFrame.new(-1306.4, 4.0, 312.9)                                                  },
        ["Desert"]           = { CF=CFrame.new(941.0, 6.0, -2767.0)                                                  },
        ["Frozen Village"]   = { CF=CFrame.new(1239.7, 9.5, -3011.0)                                                 },
        ["Marine Fortress"]  = { CF=CFrame.new(-4600.0, 10.0, 4068.0)                                                },
        ["Prison"]           = { CF=CFrame.new(4781.7, 5.0, 803.3)                                                   },
        ["Magma Village"]    = { CF=CFrame.new(-4648.3, 46.0, -881.4)                                                },
        ["Skylands"]         = { Entrance=Vector3.new(-4607.82275, 872.54248, -1667.55688)                            },
        ["Skylands 2"]       = { Entrance=Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047)            },
        ["Underwater City"]  = { Entrance=Vector3.new(61163.8515625, 11.6796875, 1819.7841796875)                     },
    },
    Sea2 = {
        ["Kingdom of Rose"]  = { CF=CFrame.new(-789.7, 73.5, -3774.0)                                                },
        ["Green Zone"]       = { CF=CFrame.new(-1887.9, 22.0, -5018.8)                                               },
        ["Graveyard"]        = { CF=CFrame.new(3775.0, 24.0, -4313.0)                                                },
        ["Snow Mountain"]    = { CF=CFrame.new(2117.0, 214.0, -5229.0)                                               },
        ["Hot & Cold"]       = { CF=CFrame.new(441.0, 157.0, -5462.0)                                                },
        ["Cursed Ship"]      = { Entrance=Vector3.new(923.21252441406, 126.9760055542, 32852.83203125)                },
        ["Ice Castle"]       = { CF=CFrame.new(-1500.0, 4.0, -6500.0)                                                },
        ["Forgotten Island"] = { CF=CFrame.new(0.0, 5.0, -7000.0)                                                    },
        ["Zou"]              = { Entrance=Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047)             },
    },
    Sea3 = {
        ["Port Town"]        = { CF=CFrame.new(-8985.0, 6.0, -1873.0)                                                },
        ["Hydra Island"]     = { CF=CFrame.new(-9648.0, 6.0, 786.0)                                                  },
        ["Great Tree"]       = { CF=CFrame.new(-8487.0, 5.0, 5450.0)                                                 },
        ["Floating Turtle"]  = { CF=CFrame.new(-13720.0, 0.0, -3839.0)                                               },
        ["Haunted Castle"]   = { CF=CFrame.new(-11860.0, 5.0, -7490.0)                                               },
        ["Candy Land"]       = { CF=CFrame.new(-1835.0, 5.0, -19000.0)                                               },
        ["Dressrosa"]        = { Entrance=Vector3.new(923.21252441406, 126.9760055542, 32852.83203125)                },
        ["Flame Tower"]      = { Entrance=Vector3.new(5643.4526367188, 1013.0858154297, -340.51025390625)             },
        ["Haunted Castle 2"] = { Entrance=Vector3.new(-12471.169921875, 374.94024658203, -7551.677734375)             },
        ["Mansion"]          = { Entrance=Vector3.new(5314.5463867188, 22.562219619751, -127.06755065918)             },
        ["Tiki Outpost"]     = { CF=CFrame.new(-16548.82, 55.61, -172.81)                                            },
        ["Submerged Island"] = { SubWorker=true }  -- usa RF/SubmarineWorkerSpeak
    },
}

-- Posições de mobs Sea3 (para bring/farm)
BloxFruits.MobPositions = {
    ["Pirate Millionaire"]    = CFrame.new(-712.83, 98.58, 5711.95),
    ["Pistol Billionaire"]    = CFrame.new(-723.43, 147.43, 5931.99),
    ["Dragon Crew Warrior"]   = CFrame.new(7021.50, 55.76, -730.13),
    ["Dragon Crew Archer"]    = CFrame.new(6625.0, 378.0, 244.0),
    ["Female Islander"]       = CFrame.new(4692.79, 797.98, 858.85),
    ["Venomous Assailant"]    = CFrame.new(4902.0, 670.0, 39.0),
    ["Marine Commodore"]      = CFrame.new(2401.0, 123.0, -7589.0),
    ["Marine Rear Admiral"]   = CFrame.new(3588.0, 229.0, -7085.0),
    ["Fishman Raider"]        = CFrame.new(-10941.0, 332.0, -8760.0),
    ["Fishman Captain"]       = CFrame.new(-11035.0, 332.0, -9087.0),
    ["Forest Pirate"]         = CFrame.new(-13446.0, 413.0, -7760.0),
    ["Mythological Pirate"]   = CFrame.new(-13510.0, 584.0, -6987.0),
    ["Jungle Pirate"]         = CFrame.new(-11778.0, 426.0, -10592.0),
    ["Reborn Skeleton"]       = CFrame.new(-8764.0, 142.0, 5963.0),
    ["Living Zombie"]         = CFrame.new(-10227.0, 421.0, 6161.0),
    ["Demonic Soul"]          = CFrame.new(-9579.0, 6.0, 6194.0),
    ["Posessed Mummy"]        = CFrame.new(-9579.0, 6.0, 6194.0),
    ["Cookie Crafter"]        = CFrame.new(-2021.0, 38.0, -12028.0),
    ["Cake Guard"]            = CFrame.new(-2024.0, 38.0, -12026.0),
    ["Baking Staff"]          = CFrame.new(-1932.0, 38.0, -12848.0),
    ["Head Baker"]            = CFrame.new(-1932.0, 38.0, -12848.0),
}

-- ════════════════════════════════════════════
-- 1. AUTO QUEST + AUTO FARM (Smart, por nível)
-- ════════════════════════════════════════════
function BloxFruits.SetAutoFarm(enabled)
    State.AutoFarm = enabled
    if enabled then
        State.Connections["AutoFarm"] = RunService.Heartbeat:Connect(function()
            if not State.AutoFarm then return end
            pcall(function()
                local qd = getQuestData()
                State.CurrentQuest = qd

                -- requestEntrance se necessário (ilhas especiais)
                if qd.Entrance then
                    local hrp = getHRP()
                    if hrp and (hrp.Position - qd.QuestCF.Position).Magnitude > 10000 then
                        invoke("requestEntrance", qd.Entrance)
                        task.wait(2)
                        return
                    end
                end

                -- Pegar quest
                if not hasQuest() then
                    local hrp = getHRP()
                    if hrp and (hrp.Position - qd.QuestCF.Position).Magnitude > 5 then
                        _tp(qd.QuestCF)
                    else
                        invoke("AbandonQuest")
                        task.wait(0.3)
                        invoke("StartQuest", qd.QuestName, qd.Tier)
                        task.wait(0.5)
                    end
                    return
                end

                -- Verificar título da quest
                local title = getQuestTitle()
                if title ~= "" and not string.find(title, qd.Mob, 1, true) then
                    invoke("AbandonQuest")
                    task.wait(0.3)
                    return
                end

                -- Ir para o mob
                local mob, mobHRP = findModel(qd.Mob)
                if mob and mobHRP then
                    State.BringPos = mobHRP.Position
                    _tp(mobHRP.CFrame * CFrame.new(0, State.MobHeight, 0))
                    task.wait(0.05)
                    attackMob(mobHRP)
                    -- Skills de fruta se ativadas
                    if _G and _G.FruitSkills then
                        if _G.FruitSkills.Z then useSkill("Blox Fruit","Z") end
                        if _G.FruitSkills.X then useSkill("Blox Fruit","X") end
                        if _G.FruitSkills.C then useSkill("Blox Fruit","C") end
                        if _G.FruitSkills.V then useSkill("Blox Fruit","V") end
                    end
                else
                    -- Mob não encontrado, vai para posição conhecida
                    if qd.MobCF then _tp(qd.MobCF) end
                end
            end)
            task.wait(0.1)
        end)
    else
        State.AutoFarm   = false
        State.BringPos   = nil
        disconnect("AutoFarm")
    end
end

-- ════════════════════════════════════════════
-- 2. AUTO STATS
-- CommF_:InvokeServer("AddPoint", stat, amount)
-- Stats: "Melee","Defense","Sword","Gun","Demon Fruit"
-- ════════════════════════════════════════════
function BloxFruits.SetAutoStats(enabled, priority)
    priority = priority or "Melee"
    State.AutoStats = enabled
    if enabled then
        State.Connections["AutoStats"] = RunService.Heartbeat:Connect(function()
            if not State.AutoStats then return end
            pcall(function()
                local data = plr:FindFirstChild("Data")
                if not data then return end
                local pts = data:FindFirstChild("Points") or data:FindFirstChild("StatPoints")
                if pts and pts.Value > 0 then
                    invoke("AddPoint", priority, pts.Value)
                end
            end)
            task.wait(1)
        end)
    else
        State.AutoStats = false
        disconnect("AutoStats")
    end
end

-- ════════════════════════════════════════════
-- 3. AUTO HAKI (Buso)
-- CommF_:InvokeServer("Buso") — ativa armamento
-- ════════════════════════════════════════════
function BloxFruits.SetAutoHaki(enabled)
    State.AutoHaki = enabled
    if enabled then
        State.Connections["AutoHaki"] = RunService.Heartbeat:Connect(function()
            if not State.AutoHaki then return end
            pcall(function()
                local c = getChar()
                if c and not c:FindFirstChild("HasBuso") then
                    invoke("Buso")
                end
            end)
            task.wait(0.5)
        end)
    else
        State.AutoHaki = false
        disconnect("AutoHaki")
    end
end

-- ════════════════════════════════════════════
-- 4. AUTO OBSERVATION (Ken)
-- CommE:FireServer("Ken", true)
-- ════════════════════════════════════════════
function BloxFruits.SetAutoKen(enabled)
    State.AutoKen = enabled
    if enabled then
        State.Connections["AutoKen"] = RunService.Heartbeat:Connect(function()
            if not State.AutoKen then return end
            pcall(function()
                local c = getChar()
                if c and not CollectionService:HasTag(c, "Ken") then
                    fire("Ken", true)
                end
            end)
            task.wait(0.2)
        end)
    else
        State.AutoKen = false
        disconnect("AutoKen")
        pcall(function() fire("Ken", false) end)
    end
end

-- ════════════════════════════════════════════
-- 5. AUTO EQUIP BEST WEAPON
-- CommF_:InvokeServer("getInventory") → CommF_:InvokeServer("LoadItem", name)
-- ════════════════════════════════════════════
function BloxFruits.EquipBestWeapon(weaponType)
    -- weaponType: "Sword" | "Gun" | "Blox Fruit"
    pcall(function()
        local inv = invoke("getInventory")
        if not inv then return end
        local best, bestMastery = nil, -1
        for _, item in pairs(inv) do
            if type(item) == "table" and item.Type == weaponType then
                local m = tonumber(item.Mastery) or 0
                if m > bestMastery then
                    bestMastery = m
                    best = item.Name
                end
            end
        end
        if best then invoke("LoadItem", best) end
    end)
end

-- ════════════════════════════════════════════
-- 6. AUTO SKILLS Z/X/C/V/F
-- ════════════════════════════════════════════
function BloxFruits.UseSkill(category, key)
    useSkill(category, key)
end

-- ════════════════════════════════════════════
-- 7. FAST ATTACK (reduz cooldown de tool)
-- ════════════════════════════════════════════
function BloxFruits.SetFastAttack(enabled)
    State.FastAttack = enabled
    pcall(function()
        local c = getChar()
        if not c then return end
        for _, t in ipairs(c:GetDescendants()) do
            if t:IsA("Tool") then
                local cfg = t:FindFirstChild("Config")
                if cfg then
                    local cd = cfg:FindFirstChild("Cooldown")
                    if cd then cd.Value = enabled and 0.01 or 0.5 end
                end
            end
        end
    end)
end

-- ════════════════════════════════════════════
-- 8. BRING MOBS
-- ════════════════════════════════════════════
function BloxFruits.SetBringMobs(enabled, range)
    State.BringMobs = enabled
    State.BringRange = range or 235
    if enabled then
        State.BringActive = true
        State.Connections["BringLoop"] = RunService.Heartbeat:Connect(function()
            if not State.BringMobs then return end
            bringEnemies()
            task.wait(0.5)
        end)
    else
        State.BringMobs   = false
        State.BringActive = false
        disconnect("BringLoop")
    end
end

-- ════════════════════════════════════════════
-- 9. AUTO BOSS FARM
-- ════════════════════════════════════════════
function BloxFruits.SetAutoBoss(enabled, bossName)
    State.AutoBoss = enabled
    State.SelectedBoss = bossName
    if enabled and bossName then
        State.Connections["AutoBoss"] = RunService.Heartbeat:Connect(function()
            if not State.AutoBoss then return end
            pcall(function()
                local data = BloxFruits.BossData[bossName]

                -- requestEntrance para bosses em instâncias especiais
                if data and data.Entrance then
                    local hrp = getHRP()
                    if hrp and (hrp.Position - data.BossCF.Position).Magnitude > 5000 then
                        invoke("requestEntrance", data.Entrance)
                        task.wait(2)
                        return
                    end
                end

                -- Quest do boss (se houver)
                if data and data.QuestName and not hasQuest() then
                    if data.QuestCF then
                        local hrp = getHRP()
                        if hrp and (hrp.Position - data.QuestCF.Position).Magnitude > 5 then
                            _tp(data.QuestCF)
                        else
                            invoke("AbandonQuest")
                            task.wait(0.2)
                            invoke("StartQuest", data.QuestName, data.Tier)
                            task.wait(0.5)
                        end
                    end
                    return
                end

                -- Perseguir e atacar boss
                local boss, bossHRP = findModel(bossName)
                if boss and bossHRP then
                    State.BringPos = bossHRP.Position
                    _tp(bossHRP.CFrame * CFrame.new(0, State.MobHeight, 0))
                    task.wait(0.05)
                    attackMob(bossHRP)
                elseif data and data.BossCF then
                    _tp(data.BossCF)
                end
            end)
            task.wait(0.2)
        end)
    else
        State.AutoBoss    = false
        State.SelectedBoss = nil
        disconnect("AutoBoss")
    end
end

-- ════════════════════════════════════════════
-- 10. SEA EVENTS
-- ════════════════════════════════════════════
local function seaEventLoop(stateName, connName, modelNames, heightOffset)
    heightOffset = heightOffset or 5
    if type(modelNames) == "string" then modelNames = {modelNames} end

    State[stateName] = true
    State.Connections[connName] = RunService.Heartbeat:Connect(function()
        if not State[stateName] then return end
        pcall(function()
            -- Verifica múltiplos nomes possíveis
            local target, targetHRP
            for _, name in ipairs(modelNames) do
                -- Verifica em Workspace.SeaBeasts e Workspace.Enemies
                local sb = Workspace:FindFirstChild("SeaBeasts")
                if sb then
                    local m = sb:FindFirstChild(name)
                    if m then
                        local hrp = m:FindFirstChild("HumanoidRootPart")
                        local hp  = m:FindFirstChild("Health")
                        local hum = m:FindFirstChildOfClass("Humanoid")
                        local alive = (hp and hp.Value > 0) or (hum and hum.Health > 0)
                        if hrp and alive then target, targetHRP = m, hrp break end
                    end
                end
                local v, vHRP = findModel(name)
                if v then target, targetHRP = v, vHRP break end
            end

            if target and targetHRP then
                local hrp = getHRP()
                if hrp then
                    _tp(targetHRP.CFrame * CFrame.new(0, heightOffset, 5))
                    task.wait(0.05)
                    attackMob(targetHRP)
                end
            end
        end)
        task.wait(0.3)
    end)
end

function BloxFruits.SetAutoSeaBeast(enabled)
    if enabled then seaEventLoop("AutoSeaBeast","SeaBeast",{"Sea Beast","SeaBeast1"},50)
    else State.AutoSeaBeast=false disconnect("SeaBeast") end
end
function BloxFruits.SetAutoTerrorShark(enabled)
    if enabled then seaEventLoop("AutoTerrorShark","TerrorShark",{"Terrorshark","Terror Shark"},15)
    else State.AutoTerrorShark=false disconnect("TerrorShark") end
end
function BloxFruits.SetAutoLeviathan(enabled)
    if enabled then seaEventLoop("AutoLeviathan","Leviathan",{"Leviathan"},50)
    else State.AutoLeviathan=false disconnect("Leviathan") end
end
function BloxFruits.SetAutoFishBoat(enabled)
    if enabled then seaEventLoop("AutoFishBoat","FishBoat",{"FishBoat"},10)
    else State.AutoFishBoat=false disconnect("FishBoat") end
end
function BloxFruits.SetAutoPirateBrigade(enabled)
    if enabled then seaEventLoop("AutoPirateBrigade","PirateBrigade",{"PirateGrandBrigade","PirateBrigade"},10)
    else State.AutoPirateBrigade=false disconnect("PirateBrigade") end
end
function BloxFruits.SetAutoPiranha(enabled)
    if enabled then seaEventLoop("AutoPiranha","Piranha",{"Piranha"},5)
    else State.AutoPiranha=false disconnect("Piranha") end
end
function BloxFruits.SetAutoHauntedCrew(enabled)
    if enabled then seaEventLoop("AutoHauntedCrew","HauntedCrew",{"Haunted Crew Member","Fish Crew Member"},5)
    else State.AutoHauntedCrew=false disconnect("HauntedCrew") end
end

-- ════════════════════════════════════════════
-- 11. FRUITS
-- ════════════════════════════════════════════

-- Fruit Sniper: teleporta até a fruta rara e coleta
function BloxFruits.SetFruitSniper(enabled, targetList)
    State.AutoFruitSniper = enabled
    targetList = targetList or State.RareFruits
    if enabled then
        State.Connections["FruitSniper"] = RunService.Heartbeat:Connect(function()
            if not State.AutoFruitSniper then return end
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") then
                        local label = obj:FindFirstChild("FruitName") or obj:FindFirstChild("Name_Tag")
                        local fruitName = (label and (label.Value or label.Text)) or obj.Name
                        for _, target in ipairs(targetList) do
                            if string.find(fruitName, target, 1, true) then
                                local part = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildOfClass("BasePart")
                                if part then
                                    notween(part.CFrame + Vector3.new(0,3,0))
                                    task.wait(0.5)
                                    -- Coleta via EatRemote ou Handle.Touched
                                    local er = obj:FindFirstChild("EatRemote", true)
                                    if er then pcall(function() er:InvokeServer("Pickup") end) end
                                end
                                break
                            end
                        end
                    end
                end
            end)
            task.wait(1)
        end)
    else
        State.AutoFruitSniper = false
        disconnect("FruitSniper")
    end
end

-- Fruit Collect: atrai frutas para o personagem (ZYN hub: collectFruits)
function BloxFruits.SetFruitCollect(enabled)
    State.AutoFruitCollect = enabled
    if enabled then
        State.Connections["FruitCollect"] = RunService.Heartbeat:Connect(function()
            if not State.AutoFruitCollect then return end
            pcall(function()
                local c = getChar()
                if not c then return end
                local hrp = c:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if string.find(obj.Name, "Fruit") then
                        local handle = obj:FindFirstChild("Handle")
                        if handle then handle.CFrame = hrp.CFrame end
                    end
                end
            end)
            task.wait(0.5)
        end)
    else
        State.AutoFruitCollect = false
        disconnect("FruitCollect")
    end
end

-- Store Fruit: CommF_:InvokeServer("StoreFruit", OriginalName, tool)
function BloxFruits.StoreFruits()
    pcall(function()
        for _, item in ipairs(plr.Backpack:GetChildren()) do
            local er = item:FindFirstChild("EatRemote", true)
            if er then
                local orig = item:GetAttribute("OriginalName") or item.Name
                invoke("StoreFruit", orig, item)
                task.wait(0.2)
            end
        end
    end)
end

-- Drop Fruit: EatRemote:InvokeServer("Drop")
function BloxFruits.DropFruits()
    pcall(function()
        local function dropFrom(container)
            for _, item in ipairs(container:GetChildren()) do
                if string.find(item.Name, "Fruit") then
                    local hum = getHum()
                    if hum then hum:EquipTool(item) task.wait(0.1) end
                    local c = getChar()
                    if c then
                        local equipped = c:FindFirstChild(item.Name)
                        if equipped then
                            local er = equipped:FindFirstChild("EatRemote")
                            if er then pcall(function() er:InvokeServer("Drop") end) end
                        end
                    end
                end
            end
        end
        dropFrom(plr.Backpack)
        if getChar() then dropFrom(getChar()) end
    end)
end

-- Fruit ESP
function BloxFruits.SetFruitESP(enabled)
    State.FruitESP = enabled
    if enabled then
        State.Connections["FruitESP"] = RunService.Heartbeat:Connect(function()
            if not State.FruitESP then return end
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if string.find(obj.Name, "Fruit") and obj:FindFirstChild("Handle") then
                        if not obj:FindFirstChild("ZenithFruitESP") then
                            local bb = Instance.new("BillboardGui", obj)
                            bb.Name = "ZenithFruitESP"
                            bb.Size = UDim2.new(0, 120, 0, 30)
                            bb.StudsOffset = Vector3.new(0, 3, 0)
                            bb.AlwaysOnTop = true
                            local lbl = Instance.new("TextLabel", bb)
                            lbl.Size = UDim2.new(1, 0, 1, 0)
                            lbl.BackgroundTransparency = 1
                            lbl.TextColor3 = Color3.fromRGB(255, 220, 50)
                            lbl.TextStrokeTransparency = 0
                            lbl.TextScaled = true
                            lbl.Text = "🍎 " .. obj.Name
                        end
                    end
                end
            end)
            task.wait(2)
        end)
    else
        State.FruitESP = false
        disconnect("FruitESP")
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local e = obj:FindFirstChild("ZenithFruitESP")
            if e then e:Destroy() end
        end
    end
end

-- Rare Fruit Notify
function BloxFruits.SetRareFruitNotify(enabled)
    if enabled then
        State.Connections["RareNotify"] = RunService.Heartbeat:Connect(function()
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if string.find(obj.Name, "Fruit") and obj:FindFirstChild("Handle") then
                        for _, rare in ipairs(State.RareFruits) do
                            if string.find(obj.Name, rare, 1, true) then
                                -- Notifica via StarterGui (compatível com todos os executors)
                                local sg = game:GetService("StarterGui")
                                pcall(function()
                                    sg:SetCore("SendNotification", {
                                        Title   = "🍎 FRUTA RARA!",
                                        Text    = obj.Name .. " apareceu!",
                                        Duration = 8,
                                    })
                                end)
                            end
                        end
                    end
                end
            end)
            task.wait(3)
        end)
    else
        disconnect("RareNotify")
    end
end

-- Auto Buy Fruit (Sniper de loja)
-- CommF_:InvokeServer("GetFruits") → CommF_:InvokeServer("PurchaseRawFruit", name)
function BloxFruits.SetAutoBuyFruit(enabled, fruitName)
    State.AutoBuyFruit = enabled
    if fruitName then State.SelectedFruit = fruitName end
    if enabled then
        State.Connections["AutoBuyFruit"] = RunService.Heartbeat:Connect(function()
            if not State.AutoBuyFruit then return end
            pcall(function()
                invoke("GetFruits") -- atualiza estoque
                invoke("PurchaseRawFruit", State.SelectedFruit)
            end)
            task.wait(5)
        end)
    else
        State.AutoBuyFruit = false
        disconnect("AutoBuyFruit")
    end
end

-- Auto Fruit Mastery (ZYN hub: G.Mas)
function BloxFruits.SetAutoFruitMastery(enabled)
    if enabled then
        State.Connections["FruitMastery"] = RunService.Heartbeat:Connect(function()
            if not State.AutoFarm then return end -- depende do AutoFarm estar ativo
            pcall(function()
                local c = getChar()
                if not c then return end
                -- Equipa fruta e usa skills
                equipByType("Blox Fruit")
                useSkill("Blox Fruit", "Z")
                useSkill("Blox Fruit", "X")
                useSkill("Blox Fruit", "C")
            end)
            task.wait(0.5)
        end)
    else
        disconnect("FruitMastery")
    end
end

-- ════════════════════════════════════════════
-- 12. RAIDS
-- CommF_:InvokeServer("RaidsNpc", "Select", chipName)
-- ════════════════════════════════════════════
function BloxFruits.SetAutoBuyChip(enabled, chipName)
    State.AutoBuyChip = enabled
    if chipName then State.SelectedChip = chipName end
    if enabled then
        State.Connections["AutoBuyChip"] = RunService.Heartbeat:Connect(function()
            if not State.AutoBuyChip then return end
            pcall(function()
                local bp = plr.Backpack
                if not bp:FindFirstChild("Special Microchip") then
                    invoke("RaidsNpc", "Select", State.SelectedChip)
                end
            end)
            task.wait(3)
        end)
    else
        State.AutoBuyChip = false
        disconnect("AutoBuyChip")
    end
end

-- Auto Start Raid
function BloxFruits.SetAutoStartRaid(enabled)
    State.AutoStartRaid = enabled
    if enabled then
        State.Connections["AutoStartRaid"] = RunService.Heartbeat:Connect(function()
            if not State.AutoStartRaid then return end
            pcall(function()
                local bp = plr.Backpack
                if bp:FindFirstChild("Special Microchip") then
                    invoke("RaidsNpc", "Start")
                end
            end)
            task.wait(5)
        end)
    else
        State.AutoStartRaid = false
        disconnect("AutoStartRaid")
    end
end

-- Auto Raid Farm (mata mobs da raid)
function BloxFruits.SetAutoRaidFarm(enabled)
    State.AutoRaidFarm = enabled
    if enabled then
        State.Connections["AutoRaidFarm"] = RunService.Heartbeat:Connect(function()
            if not State.AutoRaidFarm then return end
            pcall(function()
                local hrp = getHRP()
                if not hrp then return end
                local enemies = Workspace:FindFirstChild("Enemies")
                if not enemies then return end
                local best, bestHRP, bestDist = nil, nil, math.huge
                for _, v in ipairs(enemies:GetChildren()) do
                    if not isPlayer(v) then
                        local vHRP = v:FindFirstChild("HumanoidRootPart")
                        local vHum = v:FindFirstChildOfClass("Humanoid")
                        if vHRP and vHum and vHum.Health > 0 then
                            local d = (hrp.Position - vHRP.Position).Magnitude
                            if d < bestDist then bestDist=d best=v bestHRP=vHRP end
                        end
                    end
                end
                if best and bestHRP then
                    State.BringPos = bestHRP.Position
                    _tp(bestHRP.CFrame * CFrame.new(0, State.MobHeight, 0))
                    task.wait(0.05)
                    attackMob(bestHRP)
                end
            end)
            task.wait(0.15)
        end)
    else
        State.AutoRaidFarm = false
        disconnect("AutoRaidFarm")
    end
end

-- Auto Awaken (ativa habilidade awakened da fruta durante raid)
-- CommE:FireServer("ActivateAbility")
function BloxFruits.SetAutoAwaken(enabled)
    if enabled then
        State.Connections["AutoAwaken"] = RunService.Heartbeat:Connect(function()
            pcall(function() fire("ActivateAbility") end)
            task.wait(30)
        end)
    else
        disconnect("AutoAwaken")
    end
end

-- ════════════════════════════════════════════
-- 13. RACES / V4
-- CommE:FireServer("ActivateAbility") → V3
-- VirtualInputManager "Y" → V4 (quando RaceEnergy == 1)
-- ════════════════════════════════════════════
function BloxFruits.SetAutoRaceV3(enabled)
    State.AutoRaceAbility = enabled
    if enabled then
        State.Connections["AutoRaceV3"] = RunService.Heartbeat:Connect(function()
            if not State.AutoRaceAbility then return end
            pcall(function() fire("ActivateAbility") end)
            task.wait(30)
        end)
    else
        State.AutoRaceAbility = false
        disconnect("AutoRaceV3")
    end
end

function BloxFruits.SetAutoRaceV4(enabled)
    State.AutoRaceV4 = enabled
    if enabled then
        State.Connections["AutoRaceV4"] = RunService.Heartbeat:Connect(function()
            if not State.AutoRaceV4 then return end
            pcall(function()
                local c = getChar()
                if not c then return end
                local raceEnergy = c:FindFirstChild("RaceEnergy")
                if raceEnergy and raceEnergy.Value == 1 then
                    vim:SendKeyEvent(true,  "Y", false, game)
                    vim:SendKeyEvent(false, "Y", false, game)
                end
            end)
            task.wait(0.2)
        end)
    else
        State.AutoRaceV4 = false
        disconnect("AutoRaceV4")
    end
end

-- ════════════════════════════════════════════
-- 14. TELEPORT ILHA
-- ════════════════════════════════════════════
function BloxFruits.TeleportIsland(islandName, sea)
    pcall(function()
        local seaStr = "Sea" .. tostring(sea or (World1 and 1 or World2 and 2 or 3))
        local data = BloxFruits.Islands[seaStr] and BloxFruits.Islands[seaStr][islandName]
        if not data then warn("[ZenithHub|BF] Ilha não encontrada:", islandName) return end

        if data.SubWorker then
            -- Ilha Submersa: usa RF/SubmarineWorkerSpeak
            local net = ReplicatedStorage:FindFirstChild("Modules") and
                        ReplicatedStorage.Modules:FindFirstChild("Net")
            if net then
                local rf = net:FindFirstChild("RF/SubmarineWorkerSpeak")
                if rf then rf:InvokeServer("TravelToSubmergedIsland") end
            end
        elseif data.Entrance then
            invoke("requestEntrance", data.Entrance)
        elseif data.CF then
            _tp(data.CF)
        end
    end)
end

-- ════════════════════════════════════════════
-- 15. TELEPORT BOSS
-- ════════════════════════════════════════════
function BloxFruits.TeleportBoss(bossName)
    local data = BloxFruits.BossData[bossName]
    if not data then warn("[ZenithHub|BF] Boss não encontrado:", bossName) return end
    if data.Entrance then invoke("requestEntrance", data.Entrance) end
    _tp(data.BossCF)
end

-- ════════════════════════════════════════════
-- 16. UTILITÁRIOS DE INVENTÁRIO
-- ════════════════════════════════════════════
function BloxFruits.GetInventory()
    return invoke("getInventory")
end
function BloxFruits.LoadItem(itemName)
    invoke("LoadItem", itemName)
end
function BloxFruits.SetTeam(team)
    if team ~= "Marines" and team ~= "Pirates" then return end
    invoke("SetTeam", team)
end

-- ════════════════════════════════════════════
-- 17. LIMPEZA TOTAL
-- ════════════════════════════════════════════
function BloxFruits.Cleanup()
    -- Para todos os estados booleanos
    for k, v in pairs(State) do
        if type(v) == "boolean" then State[k] = false end
    end
    -- Desconecta todas as connections
    for name, conn in pairs(State.Connections) do
        pcall(function() conn:Disconnect() end)
        State.Connections[name] = nil
    end
    State.CurrentQuest = nil
    State.BringPos     = nil
    -- Remove ESPs
    for _, v in ipairs(Workspace:GetDescendants()) do
        local esp = v:FindFirstChild("ZenithFruitESP")
        if esp then esp:Destroy() end
    end
    -- Desativa Ken
    pcall(function() fire("Ken", false) end)
    -- Remove TweenPart
    if TweenPart and TweenPart.Parent then
        TweenPart:Destroy()
        TweenPart = nil
    end
end

-- ════════════════════════════════════════════
-- EXPOSIÇÃO PÚBLICA DE DADOS
-- ════════════════════════════════════════════
BloxFruits.State = State

BloxFruits.Bosses = {
    Sea1 = { "The Gorilla King","Bobby","The Saw","Yeti","Mob Leader","Vice Admiral",
             "Saber Expert","Warden","Chief Warden","Swan","Magma Admiral",
             "Fishman Lord","Wysper","Thunder God","Cyborg","Ice Admiral","Greybeard" },
    Sea2 = { "Diamond","Jeremy","Fajita","Don Swan","Smoke Admiral",
             "Awakened Ice Admiral","Tide Keeper","Darkbeard","Cursed Captain","Order" },
    Sea3 = { "Stone","Hydra Leader","Kilo Admiral","Captain Elephant",
             "Beautiful Pirate","Cake Queen","Longma","Soul Reaper",
             "Rip_Indra","Cake King","Tyrant of the Skies","Leviathan" },
}

BloxFruits.RaidChips = {
    "Flame","Ice","Quake","Light","Dark","String","Rumble","Magma",
    "Human: Buddha","Sand","Bird: Phoenix","Dough",
}

BloxFruits.FightingStyles = {
    "Dark Step","Electric","Water Kung Fu","Dragon Breath",
    "Death Step","Electric Claw","Sharkman Karate",
    "Dragon Talon","Superhuman","Godhuman","Sanguine Art",
}

BloxFruits.Fruits = {
    "Rocket-Rocket","Spin-Spin","Chop-Chop","Spring-Spring","Bomb-Bomb",
    "Smoke-Smoke","Spike-Spike","Flame-Flame","Falcon-Falcon","Ice-Ice",
    "Sand-Sand","Dark-Dark","Diamond-Diamond","Light-Light","Rubber-Rubber",
    "Barrier-Barrier","Ghost-Ghost","Magma-Magma","Quake-Quake","Buddha-Buddha",
    "Love-Love","Spider-Spider","Sound-Sound","Phoenix-Phoenix","Portal-Portal",
    "Rumble-Rumble","Pain-Pain","Blizzard-Blizzard","Gravity-Gravity",
    "Mammoth-Mammoth","T-Rex-T-Rex","Dough-Dough","Shadow-Shadow","Venom-Venom",
    "Control-Control","Spirit-Spirit","Dragon-Dragon","Leopard-Leopard",
    "Kitsune-Kitsune","Gas-Gas","Yeti-Yeti",
}

return BloxFruits
