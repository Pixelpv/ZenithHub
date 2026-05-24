--[[
╔══════════════════════════════════════════════╗
║        ZENITH HUB  v2.1  (SINGLE FILE)      ║
║       Blox Fruits — Executor Ready          ║
║   Patterns: Vua Hub + Zyn Hub open source   ║
╚══════════════════════════════════════════════╝
]]

if _G.ZenithLoaded then print("[ZenithHub] Já carregado!") return end
_G.ZenithLoaded = true

-- ═══════════════════════════════════════════════
-- SERVIÇOS
-- ═══════════════════════════════════════════════
local Players          = game:GetService("Players")
local RS               = game:GetService("ReplicatedStorage")
local TweenService     = game:GetService("TweenService")
local TeleportService  = game:GetService("TeleportService")
local CollectionService= game:GetService("CollectionService")
local Lighting         = game:GetService("Lighting")
local StarterGui       = game:GetService("StarterGui")
local UIS              = game:GetService("UserInputService")
local VIM              = game:GetService("VirtualInputManager")

local plr = Players.LocalPlayer

-- ═══════════════════════════════════════════════
-- AGUARDA JOGO CARREGAR + PERSONAGEM
-- ═══════════════════════════════════════════════
if not plr.Character then plr.CharacterAdded:Wait() end
repeat
    local m = plr.PlayerGui:FindFirstChild("Main")
    m = m and m:FindFirstChild("Loading")
    task.wait()
until game:IsLoaded() and not (m and m.Visible)

-- ═══════════════════════════════════════════════
-- DETECÇÃO DE MUNDO
-- ═══════════════════════════════════════════════
local placeId = game.PlaceId
World1 = placeId == 2753915549 or placeId == 85211729168715
World2 = placeId == 4442272183 or placeId == 79091703265657
World3 = placeId == 7449423635 or placeId == 100117331123089
local WORLD = World1 and 1 or World2 and 2 or World3 and 3 or 1

-- ═══════════════════════════════════════════════
-- REMOTES (CommF_ e CommE — remotes reais do BF)
-- ═══════════════════════════════════════════════
local CommF_ = RS:WaitForChild("Remotes", 15):WaitForChild("CommF_", 15)
local CommE  = RS:WaitForChild("Remotes", 15):WaitForChild("CommE",  15)

local function invoke(...)
    if CommF_ then pcall(CommF_.InvokeServer, CommF_, ...) end
end
local function fire(...)
    if CommE then pcall(CommE.FireServer, CommE, ...) end
end

-- ═══════════════════════════════════════════════
-- HOOK FUNCTIONS — padrão exato dos open sources
-- ═══════════════════════════════════════════════
pcall(function() hookfunction(error, function() end) end)
pcall(function() hookfunction(warn,  function() end) end)
pcall(function() hookfunction(require(RS.Effect.Container.Death), function() end) end)
pcall(function() hookfunction(require(RS:WaitForChild("GuideModule")).ChangeDisplayedNPC, function() end) end)

-- ═══════════════════════════════════════════════
-- FULL BRIGHT + LIMPEZA
-- ═══════════════════════════════════════════════
pcall(function()
    Lighting.Ambient           = Color3.new(0.695,0.695,0.695)
    Lighting.ColorShift_Bottom = Color3.new(0.695,0.695,0.695)
    Lighting.ColorShift_Top    = Color3.new(0.695,0.695,0.695)
    Lighting.Brightness        = 2
    Lighting.FogEnd            = 1e10
    local foam = workspace:FindFirstChild("_WorldOrigin")
    if foam then
        local f2 = foam:FindFirstChild("Foam;")
        if f2 then f2:Destroy() end
    end
    local rocks = workspace:FindFirstChild("Rocks")
    if rocks then rocks:Destroy() end
end)

-- ═══════════════════════════════════════════════
-- GLOBALS OPEN SOURCE
-- ═══════════════════════════════════════════════
_G.MobHeight    = _G.MobHeight    or 20
_G.SelectWeapon = _G.SelectWeapon or nil
RandomCFrame    = false
HealthM         = 500   -- threshold para Mas/Masgun
_B              = false -- flag do BringEnemy
PosMon          = Vector3.zero

-- ═══════════════════════════════════════════════
-- UTILITÁRIOS BASE
-- ═══════════════════════════════════════════════
local function char()  return plr.Character end
local function Root()  local c=char() return c and c:FindFirstChild("HumanoidRootPart") end
local function hum()   local c=char() return c and c:FindFirstChildOfClass("Humanoid") end
local function alive() local h=hum()  return h and h.Health > 0 end
local function level() local ok,v=pcall(function() return plr.Data.Level.Value end) return ok and v or 0 end

-- _tp = notween (padrão dos open sources)
_tp = function(cf)
    local r = Root()
    if r then r.CFrame = cf end
end
notween = _tp

-- ═══════════════════════════════════════════════
-- EQUIP WEAPON — exato do open source
-- ═══════════════════════════════════════════════
EquipWeapon = function(name)
    if not name then return end
    if plr.Backpack:FindFirstChild(name) then
        hum():EquipTool(plr.Backpack:FindFirstChild(name))
    end
end

-- Equipa pela ToolTip ("Melee","Sword","Gun","Blox Fruit")
weaponSc = function(tip)
    for _, t in pairs(plr.Backpack:GetChildren()) do
        if t:IsA("Tool") and t.ToolTip == tip then
            EquipWeapon(t.Name)
        end
    end
end

-- ═══════════════════════════════════════════════
-- BRING ENEMY — exato do open source (Vua Hub)
-- workspace.Enemies:GetChildren() — NUNCA GetDescendants
-- ═══════════════════════════════════════════════
BringEnemy = function()
    if not _B then return end
    for _, mob in pairs(workspace.Enemies:GetChildren()) do
        if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            if mob.PrimaryPart and (mob.PrimaryPart.Position - PosMon).Magnitude <= 300 then
                mob.PrimaryPart.CFrame   = CFrame.new(PosMon)
                mob.PrimaryPart.CanCollide = true
                mob.Humanoid.WalkSpeed   = 0
                mob.Humanoid.JumpPower   = 0
                if mob.Humanoid:FindFirstChild("Animator") then
                    mob.Humanoid.Animator:Destroy()
                end
                plr.SimulationRadius = math.huge
            end
        end
    end
end

-- ═══════════════════════════════════════════════
-- USESKILLS — exato do open source (Vua Hub)
-- ═══════════════════════════════════════════════
Useskills = function(wtype, key)
    weaponSc(wtype)
    task.wait(0.05)
    VIM:SendKeyEvent(true,  key, false, game)
    task.wait(0.05)
    VIM:SendKeyEvent(false, key, false, game)
end

-- ═══════════════════════════════════════════════
-- STATS — exato do open source (CommF_ AddPoint)
-- ═══════════════════════════════════════════════
statsSetings = function(stat, amount)
    if plr.Data.Points.Value ~= 0 then
        local map = { Melee="Melee", Defense="Defense", Sword="Sword", Gun="Gun", Devil="Demon Fruit" }
        local s = map[stat] or stat
        pcall(function() CommF_:InvokeServer("AddPoint", s, amount or 1) end)
    end
end

-- ═══════════════════════════════════════════════
-- KILL FUNCTIONS — tabela f, exato dos open sources
-- ═══════════════════════════════════════════════
local f = {}

-- Kill (Vua Hub: usa MobHeight único)
f.Kill = function(mob, toggle)
    if not (mob and toggle) then return end
    local hrp = mob:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not mob:GetAttribute("Locked") then
        mob:SetAttribute("Locked", hrp.CFrame)
    end
    PosMon = mob:GetAttribute("Locked").Position
    _B = true
    BringEnemy()
    EquipWeapon(_G.SelectWeapon)
    local tool = char() and char():FindFirstChildOfClass("Tool")
    if not tool then return end
    local tip = tool.ToolTip
    if tip == "Blox Fruit" then
        _tp((hrp.CFrame * CFrame.new(0,10,0)) * CFrame.Angles(0, math.rad(90), 0))
    else
        _tp((hrp.CFrame * CFrame.new(0, _G.MobHeight, 0)) * CFrame.Angles(0, math.rad(180), 0))
    end
end

-- Kill2 (RandomCFrame rápido)
f.Kill2 = function(mob, toggle)
    if not (mob and toggle) then return end
    local hrp = mob:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not mob:GetAttribute("Locked") then
        mob:SetAttribute("Locked", hrp.CFrame)
    end
    PosMon = mob:GetAttribute("Locked").Position
    _B = true
    BringEnemy()
    EquipWeapon(_G.SelectWeapon)
    local tool = char() and char():FindFirstChildOfClass("Tool")
    if not tool then return end
    if tool.ToolTip == "Blox Fruit" then
        _tp((hrp.CFrame * CFrame.new(0,10,0)) * CFrame.Angles(0, math.rad(90), 0))
    else
        _tp((hrp.CFrame * CFrame.new(0,20,8)) * CFrame.Angles(0, math.rad(180), 0))
    end
    if RandomCFrame then
        task.wait(.1) _tp(hrp.CFrame * CFrame.new(0,30,25))
        task.wait(.1) _tp(hrp.CFrame * CFrame.new(25,30,0))
        task.wait(.1) _tp(hrp.CFrame * CFrame.new(-25,30,0))
        task.wait(.1) _tp(hrp.CFrame * CFrame.new(0,30,25))
        task.wait(.1) _tp(hrp.CFrame * CFrame.new(-25,30,0))
    end
end

-- KillSea (sobe alto para Sea Beasts)
f.KillSea = function(mob, toggle)
    if not (mob and toggle) then return end
    local hrp = mob:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not mob:GetAttribute("Locked") then
        mob:SetAttribute("Locked", hrp.CFrame)
    end
    PosMon = mob:GetAttribute("Locked").Position
    _B = true
    BringEnemy()
    EquipWeapon(_G.SelectWeapon)
    local tool = char() and char():FindFirstChildOfClass("Tool")
    if not tool then return end
    if tool.ToolTip == "Blox Fruit" then
        _tp((hrp.CFrame * CFrame.new(0,10,0)) * CFrame.Angles(0, math.rad(90), 0))
    else
        notween(hrp.CFrame * CFrame.new(0,50,8))
        task.wait(.85)
        notween(hrp.CFrame * CFrame.new(0,400,0))
        task.wait(1)
    end
end

-- Mas (Mastery: melee até HealthM, depois fruta)
f.Mas = function(mob, toggle)
    if not (mob and toggle) then return end
    local hrp = mob:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not mob:GetAttribute("Locked") then
        mob:SetAttribute("Locked", hrp.CFrame)
    end
    PosMon = mob:GetAttribute("Locked").Position
    _B = true
    BringEnemy()
    if mob.Humanoid.Health <= HealthM then
        _tp(hrp.CFrame * CFrame.new(0,20,0))
        Useskills("Blox Fruit","Z")
        Useskills("Blox Fruit","X")
        Useskills("Blox Fruit","C")
    else
        weaponSc("Melee")
        _tp(hrp.CFrame * CFrame.new(0,30,0))
    end
end

-- Masgun (Mastery: melee até HealthM, depois gun)
f.Masgun = function(mob, toggle)
    if not (mob and toggle) then return end
    local hrp = mob:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not mob:GetAttribute("Locked") then
        mob:SetAttribute("Locked", hrp.CFrame)
    end
    PosMon = mob:GetAttribute("Locked").Position
    _B = true
    BringEnemy()
    if mob.Humanoid.Health <= HealthM then
        _tp(hrp.CFrame * CFrame.new(0,35,8))
        Useskills("Gun","Z")
        Useskills("Gun","X")
    else
        weaponSc("Melee")
        _tp(hrp.CFrame * CFrame.new(0,30,0))
    end
end

-- Sword
f.Sword = function(mob, toggle)
    if not (mob and toggle) then return end
    local hrp = mob:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not mob:GetAttribute("Locked") then
        mob:SetAttribute("Locked", hrp.CFrame)
    end
    PosMon = mob:GetAttribute("Locked").Position
    _B = true
    BringEnemy()
    weaponSc("Sword")
    _tp(hrp.CFrame * CFrame.new(0,30,0))
    if RandomCFrame then
        task.wait(.1) _tp(hrp.CFrame * CFrame.new(0,30,25))
        task.wait(.1) _tp(hrp.CFrame * CFrame.new(25,30,0))
        task.wait(.1) _tp(hrp.CFrame * CFrame.new(-25,30,0))
        task.wait(.1) _tp(hrp.CFrame * CFrame.new(0,30,25))
        task.wait(.1) _tp(hrp.CFrame * CFrame.new(-25,30,0))
    end
end

-- ═══════════════════════════════════════════════
-- DADOS DO JOGO
-- ═══════════════════════════════════════════════

-- Bosses
local BOSSES = World1 and {
    "The Gorilla King","Bobby","The Saw","Yeti","Mob Leader",
    "Vice Admiral","Saber Expert","Warden","Chief Warden","Swan",
    "Magma Admiral","Fishman Lord","Wysper","Thunder God",
    "Cyborg","Ice Admiral","Greybeard",
} or World2 and {
    "Diamond","Jeremy","Fajita","Don Swan","Smoke Admiral",
    "Awakened Ice Admiral","Tide Keeper","Darkbeard","Cursed Captain","Order",
} or {
    "Stone","Hydra Leader","Kilo Admiral","Captain Elephant",
    "Beautiful Pirate","Cake Queen","Longma","Soul Reaper",
}

-- CFrames dos mobs (exato do open source)
local w = {
    ["Pirate Millionaire"]   = CFrame.new(-712.82727050781, 98.577049255371, 5711.9541015625),
    ["Pistol Billionaire"]   = CFrame.new(-723.43316650391, 147.42906188965, 5931.9931640625),
    ["Dragon Crew Warrior"]  = CFrame.new(7021.5043945312, 55.762702941895, -730.12908935547),
    ["Dragon Crew Archer"]   = CFrame.new(6625, 378, 244),
    ["Female Islander"]      = CFrame.new(4692.7939453125, 797.97668457031, 858.84802246094),
    ["Venomous Assailant"]   = CFrame.new(4902, 670, 39),
    ["Marine Commodore"]     = CFrame.new(2401, 123, -7589),
    ["Marine Rear Admiral"]  = CFrame.new(3588, 229, -7085),
    ["Fishman Raider"]       = CFrame.new(-10941, 332, -8760),
    ["Fishman Captain"]      = CFrame.new(-11035, 332, -9087),
    ["Forest Pirate"]        = CFrame.new(-13446, 413, -7760),
    ["Mythological Pirate"]  = CFrame.new(-13510, 584, -6987),
    ["Jungle Pirate"]        = CFrame.new(-11778, 426, -10592),
    ["Musketeer Pirate"]     = CFrame.new(-13282, 496, -9565),
    ["Reborn Skeleton"]      = CFrame.new(-8764, 142, 5963),
    ["Living Zombie"]        = CFrame.new(-10227, 421, 6161),
    ["Demonic Soul"]         = CFrame.new(-9579, 6, 6194),
    ["Posessed Mummy"]       = CFrame.new(-9579, 6, 6194),
    ["Peanut Scout"]         = CFrame.new(-1993, 187, -10103),
    ["Peanut President"]     = CFrame.new(-2215, 159, -10474),
    ["Ice Cream Chef"]       = CFrame.new(-877, 118, -11032),
    ["Ice Cream Commander"]  = CFrame.new(-877, 118, -11032),
    ["Cookie Crafter"]       = CFrame.new(-2021, 38, -12028),
    ["Cake Guard"]           = CFrame.new(-2024, 38, -12026),
    ["Baking Staff"]         = CFrame.new(-1932, 38, -12848),
    ["Head Baker"]           = CFrame.new(-1932, 38, -12848),
    ["Cocoa Warrior"]        = CFrame.new(95, 73, -12309),
    ["Chocolate Bar Battler"]= CFrame.new(647, 42, -12401),
    ["Sweet Thief"]          = CFrame.new(116, 36, -12478),
    ["Candy Rebel"]          = CFrame.new(47, 61, -12889),
    Ghost                    = CFrame.new(5251, 5, 1111),
}

-- Quests por mundo
local QUESTS = World1 and {
    { lvl=1,   quest="Bandits",       mob="Bandit",             cfMob=CFrame.new(977,7,1582),      cfNPC=CFrame.new(971,7,1590)      },
    { lvl=10,  quest="Monkeys",       mob="Monkey",             cfMob=CFrame.new(-1766,14,-3096),  cfNPC=CFrame.new(-1760,14,-3100)  },
    { lvl=30,  quest="Pirates",       mob="Pirate",             cfMob=CFrame.new(-1306,4,312),     cfNPC=CFrame.new(-1300,4,318)     },
    { lvl=60,  quest="DesertBandits", mob="Desert Bandit",      cfMob=CFrame.new(941,6,-2767),     cfNPC=CFrame.new(935,6,-2761)     },
    { lvl=90,  quest="SnowBandits",   mob="Snow Bandit",        cfMob=CFrame.new(1239,9,-3011),    cfNPC=CFrame.new(1233,9,-3005)    },
    { lvl=120, quest="Marines",       mob="Marine",             cfMob=CFrame.new(-4600,10,4068),   cfNPC=CFrame.new(-4594,10,4074)   },
    { lvl=150, quest="SkyBandits",    mob="Sky Bandit",         cfMob=CFrame.new(-4852,3038,1999), cfNPC=CFrame.new(-4846,3038,2005) },
    { lvl=190, quest="Prisoners",     mob="Prisoner",           cfMob=CFrame.new(4781,5,803),      cfNPC=CFrame.new(4775,5,809)      },
    { lvl=250, quest="Colosseum",     mob="Toga Warrior",       cfMob=CFrame.new(5071,24,3828),    cfNPC=CFrame.new(5065,24,3834)    },
    { lvl=300, quest="MagmaSoldiers", mob="Magma Soldier",      cfMob=CFrame.new(-4648,46,-881),   cfNPC=CFrame.new(-4642,46,-875)   },
    { lvl=375, quest="Fishmen",       mob="Fishman Warrior",    cfMob=CFrame.new(61164,-1400,1819),cfNPC=CFrame.new(61158,-1400,1825)},
    { lvl=450, quest="Zombies",       mob="Zombie",             cfMob=CFrame.new(61164,-1400,1819),cfNPC=CFrame.new(61158,-1400,1825)},
    { lvl=575, quest="Dragons",       mob="Dragon",             cfMob=CFrame.new(-7100,25,-2770),  cfNPC=CFrame.new(-7094,25,-2764)  },
    { lvl=625, quest="Mythological",  mob="Mythological Pirate",cfMob=w["Mythological Pirate"],    cfNPC=CFrame.new(-7094,25,-2764)  },
} or World2 and {
    { lvl=700,  quest="Area1",         mob="Raider",            cfMob=CFrame.new(-789,73,-3774),   cfNPC=CFrame.new(-783,73,-3768)   },
    { lvl=775,  quest="Area2",         mob="Mercenary",         cfMob=CFrame.new(-789,73,-3774),   cfNPC=CFrame.new(-783,73,-3768)   },
    { lvl=875,  quest="GreenBit1",     mob="Plant Subordinate", cfMob=CFrame.new(-1887,22,-5018),  cfNPC=CFrame.new(-1881,22,-5012)  },
    { lvl=950,  quest="Graveyard1",    mob="Zombie",            cfMob=CFrame.new(3775,24,-4313),   cfNPC=CFrame.new(3781,24,-4307)   },
    { lvl=1000, quest="SnowMountain1", mob="Snow Trooper",      cfMob=CFrame.new(2117,214,-5229),  cfNPC=CFrame.new(2123,214,-5223)  },
    { lvl=1100, quest="Hot1",          mob="Lab Subordinate",   cfMob=CFrame.new(441,157,-5462),   cfNPC=CFrame.new(447,157,-5456)   },
    { lvl=1150, quest="Cold1",         mob="Horned Warrior",    cfMob=CFrame.new(441,157,-5462),   cfNPC=CFrame.new(447,157,-5456)   },
    { lvl=1250, quest="Ship1",         mob="Ship Officer",      cfMob=CFrame.new(-4098,2,-5296),   cfNPC=CFrame.new(-4092,2,-5290)   },
    { lvl=1350, quest="IceCastle1",    mob="Arctic Warrior",    cfMob=CFrame.new(-1500,4,-6500),   cfNPC=CFrame.new(-1494,4,-6494)   },
    { lvl=1425, quest="Forgotten1",    mob="Sea Soldier",       cfMob=CFrame.new(0,5,-7000),       cfNPC=CFrame.new(6,5,-6994)       },
} or {
    { lvl=1500, quest="PortQuest1",    mob="Pirate Millionaire",  cfMob=w["Pirate Millionaire"],   cfNPC=CFrame.new(-706,98,5717)    },
    { lvl=1575, quest="HydraQuest1",   mob="Dragon Crew Warrior", cfMob=w["Dragon Crew Warrior"],  cfNPC=CFrame.new(7027,55,-724)    },
    { lvl=1650, quest="JungleQuest1",  mob="Jungle Pirate",       cfMob=w["Jungle Pirate"],        cfNPC=CFrame.new(-11772,426,-10586)},
    { lvl=1700, quest="TreeQuest1",    mob="Marine Commodore",    cfMob=w["Marine Commodore"],     cfNPC=CFrame.new(2407,123,-7583)  },
    { lvl=1775, quest="TurtleQuest1",  mob="Fishman Raider",      cfMob=w["Fishman Raider"],       cfNPC=CFrame.new(-10935,332,-8754)},
    { lvl=1875, quest="HauntedQuest1", mob="Reborn Skeleton",     cfMob=w["Reborn Skeleton"],      cfNPC=CFrame.new(-8758,142,5969)  },
    { lvl=1975, quest="HauntedQuest2", mob="Living Zombie",       cfMob=w["Living Zombie"],        cfNPC=CFrame.new(-10221,421,6167) },
    { lvl=2075, quest="CandyQuest1",   mob="Cookie Crafter",      cfMob=w["Cookie Crafter"],       cfNPC=CFrame.new(-2015,38,-12022) },
    { lvl=2150, quest="FactoryQuest1", mob="Baking Staff",        cfMob=w["Baking Staff"],         cfNPC=CFrame.new(-1926,38,-12842) },
    { lvl=2225, quest="TikiQuest1",    mob="Peanut Scout",        cfMob=w["Peanut Scout"],         cfNPC=CFrame.new(-1987,187,-10097)},
    { lvl=2300, quest="UsoapQuest1",   mob="Forest Pirate",       cfMob=w["Forest Pirate"],        cfNPC=CFrame.new(-13440,413,-7754)},
    { lvl=2375, quest="EliteQuest1",   mob="Musketeer Pirate",    cfMob=w["Musketeer Pirate"],     cfNPC=CFrame.new(-13276,496,-9559)},
    { lvl=2475, quest="FinalQuest1",   mob="Mythological Pirate", cfMob=w["Mythological Pirate"],  cfNPC=CFrame.new(-13504,584,-6981)},
}

-- Ilhas
local ISLANDS = World1 and {
    {name="Starter Island",  cf=CFrame.new(977,7,1582)},
    {name="Marine Starter",  cf=CFrame.new(-967,7,1582)},
    {name="Jungle",          cf=CFrame.new(-1766,14,-3096)},
    {name="Pirate Village",  cf=CFrame.new(-1306,4,312)},
    {name="Desert",          cf=CFrame.new(941,6,-2767)},
    {name="Frozen Village",  cf=CFrame.new(1239,9,-3011)},
    {name="Middle Town",     cf=CFrame.new(0,6,700)},
    {name="Marine Fortress", cf=CFrame.new(-4600,10,4068)},
    {name="Skylands",        cf=CFrame.new(-4852,3038,1999)},
    {name="Prison",          cf=CFrame.new(4781,5,803)},
    {name="Colosseum",       cf=CFrame.new(5071,24,3828)},
    {name="Magma Village",   cf=CFrame.new(-4648,46,-881)},
    {name="Upper Skylands",  cf=CFrame.new(-4852,5538,1999)},
    {name="Underwater City", cf=CFrame.new(61164,-1400,1819)},
    {name="Fountain City",   cf=CFrame.new(61164,0,1819)},
    {name="Dragon Land",     cf=CFrame.new(-7100,25,-2770)},
} or World2 and {
    {name="Kingdom of Rose", cf=CFrame.new(-789,73,-3774)},
    {name="Green Zone",      cf=CFrame.new(-1887,22,-5018)},
    {name="Graveyard",       cf=CFrame.new(3775,24,-4313)},
    {name="Snow Mountain",   cf=CFrame.new(2117,214,-5229)},
    {name="Hot & Cold",      cf=CFrame.new(441,157,-5462)},
    {name="Flower Field",    cf=CFrame.new(-400,0,-5500)},
    {name="Cursed Ship",     cf=CFrame.new(-4098,2,-5296)},
    {name="Forgotten Island",cf=CFrame.new(0,5,-7000)},
    {name="Ice Castle",      cf=CFrame.new(-1500,4,-6500)},
    {name="Cocoa Island",    cf=CFrame.new(1310,4,-6200)},
} or {
    {name="Port Town",       cf=w["Pirate Millionaire"]},
    {name="Hydra Island",    cf=w["Dragon Crew Warrior"]},
    {name="Great Tree",      cf=w["Marine Commodore"]},
    {name="Floating Turtle", cf=w["Fishman Raider"]},
    {name="Haunted Castle",  cf=w["Reborn Skeleton"]},
    {name="Candy Land",      cf=w["Cookie Crafter"]},
    {name="Sea of Treats",   cf=w["Ice Cream Chef"]},
    {name="Tiki Outpost",    cf=w["Peanut Scout"]},
    {name="Mansion",         cf=w["Musketeer Pirate"]},
}

local AWAKEN_FRUITS = {"Flame","Ice","Quake","Light","Dark","String","Rumble","Magma","Human: Buddha","Sand","Bird: Phoenix","Dough"}
local ALL_FRUITS = {"Rocket","Spin","Chop","Spring","Bomb","Smoke","Spike","Flame","Falcon","Ice","Sand","Dark","Diamond","Light","Rubber","Barrier","Ghost","Magma","Quake","Buddha","Love","Spider","Sound","Phoenix","Portal","Rumble","Pain","Blizzard","Gravity","Mammoth","T-Rex","Dough","Shadow","Venom","Control","Spirit","Dragon","Leopard","Kitsune","String"}
local FIGHTING_STYLES = {"Combat","Dark Step","Electric","Water Kung Fu","Dragon Breath","Superhuman","Death Step","Sharkman Karate","Electric Claw","Dragon Talon","Godhuman","Sanguine Art","Fishman Karate"}
local SWORDS = {"Dark Blade","Rengoku","Pole (2nd form)","Tushita","Yama","Cursed Dual Katana","Buddy Sword","Hallow Scythe","Canvander","True Triple Katana","Jitte","Shark Anchor","Fox Lamp","Leviathan Blade","Trident"}
local GUNS = {"Flintlock","Musket","Cannon","Bazooka","Refined Slingshot","Kabucha","Acidum Rifle","Serpent Bow","Soul Guitar","Electric Guitar","Slingshot","Corrupted Slingshot","Diable Rifle","Haki Rifle"}

-- ═══════════════════════════════════════════════
-- SISTEMA DE PRIORIDADE
-- ═══════════════════════════════════════════════
--  Tarefas EXCLUSIVAS (só uma por vez):
--    P1 = Sea Beast / Leviathan   ← maior prioridade
--    P2 = Auto Raid
--    P3 = Auto Boss
--    P4 = Auto Farm (quest)
--    P5 = Mastery Farm            ← menor prioridade
--  Tarefas PASSIVAS (sempre em paralelo):
--    AutoKen, AutoHaki, AutoStats, KillAura, AntiAFK
-- ═══════════════════════════════════════════════
local ExThread = nil  -- thread exclusiva atual
local ExName   = nil  -- nome da tarefa exclusiva atual
local ExPrio   = 999  -- prioridade atual (menor = mais prioritário)

local PassiveThreads = {} -- threads passivas pelo nome

-- Para a tarefa exclusiva atual
local function stopExclusive()
    if ExThread then pcall(task.cancel, ExThread) end
    ExThread = nil
    ExName   = nil
    ExPrio   = 999
    _B       = false
end

-- Tenta iniciar tarefa exclusiva; só substitui se tiver prioridade >= atual
local function startExclusive(name, prio, fn)
    if prio <= ExPrio then
        stopExclusive()
        ExName   = name
        ExPrio   = prio
        ExThread = task.spawn(fn)
        return true
    end
    return false
end

-- Para thread passiva
local function stopPassive(name)
    if PassiveThreads[name] then
        pcall(task.cancel, PassiveThreads[name])
        PassiveThreads[name] = nil
    end
end

local function startPassive(name, fn)
    stopPassive(name)
    PassiveThreads[name] = task.spawn(fn)
end

-- Desativa tarefa exclusiva pelo nome
local function disableExclusive(name)
    if ExName == name then stopExclusive() end
end

-- ═══════════════════════════════════════════════
-- HELPER: busca quest pela level atual
-- ═══════════════════════════════════════════════
local function getBestQuest()
    local lv, best = level(), nil
    for _, q in ipairs(QUESTS) do
        if q.lvl <= lv then best = q end
    end
    return best
end

-- Busca mob na pasta Enemies por nome
local function findMob(name)
    for _, mob in ipairs(workspace.Enemies:GetChildren()) do
        if mob.Name == name then
            local hm = mob:FindFirstChildOfClass("Humanoid")
            if hm and hm.Health > 0 then return mob end
        end
    end
    return nil
end

-- Busca mob em workspace (bosses)
local function findBoss(name)
    local mob = findMob(name)
    if mob then return mob end
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Model") and v.Name == name then
            local hm = v:FindFirstChildOfClass("Humanoid")
            if hm and hm.Health > 0 then return v end
        end
    end
    return nil
end

-- ═══════════════════════════════════════════════
-- ESTADO DA UI
-- ═══════════════════════════════════════════════
local S = {
    SelectedBoss   = BOSSES and BOSSES[1] or "",
    SelectedRace   = "Human",
    StatPriority   = "Melee",
    FruitTarget    = "Dragon",
    WeaponName     = "",
    MasteryType    = "Fruit",
    UseTween       = true,
    TweenSpeed     = 1.5,
    SelectedIsland = ISLANDS and ISLANDS[1] and ISLANDS[1].name or "",
    FightingStyle  = "Dark Step",
    SelectedGun    = "Flintlock",
    SelectedSword  = "Dark Blade",
    KillRange      = 40,
}

-- ═══════════════════════════════════════════════
-- FEATURES EXCLUSIVAS
-- ═══════════════════════════════════════════════

-- Sea Beast (P1)
local function setSeaBeast(on)
    if not on then disableExclusive("SeaBeast") return end
    local seaTargets = {"Sea Beast","Leviathan","Terrorshark","Sea Monster","Island Empress"}
    startExclusive("SeaBeast", 1, function()
        while ExName == "SeaBeast" do
            if alive() then
                local found
                for _, name in ipairs(seaTargets) do
                    found = workspace:FindFirstChild(name) or workspace.Enemies:FindFirstChild(name)
                    if found then break end
                end
                if found then f.KillSea(found, true) end
            end
            task.wait(0.5)
        end
    end)
end

-- Auto Raid (P2)
local function setAutoRaid(on)
    if not on then disableExclusive("AutoRaid") return end
    startExclusive("AutoRaid", 2, function()
        while ExName == "AutoRaid" do
            if alive() then
                for _, mob in ipairs(workspace.Enemies:GetChildren()) do
                    local hm = mob:FindFirstChildOfClass("Humanoid")
                    if hm and hm.Health > 0 then
                        f.Kill(mob, true)
                        task.wait(0.1)
                        break
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

-- Auto Boss (P3)
local function setAutoBoss(on)
    if not on then disableExclusive("AutoBoss") return end
    startExclusive("AutoBoss", 3, function()
        while ExName == "AutoBoss" do
            if alive() then
                local boss = findBoss(S.SelectedBoss)
                if boss then f.Kill2(boss, true) end
            end
            task.wait(0.18)
        end
    end)
end

-- Auto Farm (P4) — inclui Auto Quest
local function setAutoFarm(on)
    if not on then disableExclusive("AutoFarm") return end
    startExclusive("AutoFarm", 4, function()
        while ExName == "AutoFarm" do
            if not alive() then task.wait(1) continue end
            local q = getBestQuest()
            if not q then task.wait(2) continue end
            -- Aceita quest
            pcall(function() _tp(q.cfNPC) end)
            task.wait(0.3)
            invoke("StartQuest", q.quest)
            task.wait(0.3)
            -- Mata mob
            local mob = findMob(q.mob)
            if mob then
                f.Kill(mob, true)
            else
                _tp(q.cfMob)
                task.wait(1)
            end
            task.wait(0.08)
        end
    end)
end

-- Mastery Farm (P5)
local function setMasteryFarm(on, mtype)
    if not on then disableExclusive("Mastery") return end
    local fn = (mtype == "Gun") and f.Masgun or f.Mas
    startExclusive("Mastery", 5, function()
        while ExName == "Mastery" do
            if not alive() then task.wait(1) continue end
            local q = getBestQuest()
            if not q then task.wait(2) continue end
            local mob = findMob(q.mob)
            if mob then fn(mob, true) end
            task.wait(0.08)
        end
    end)
end

-- ═══════════════════════════════════════════════
-- FEATURES PASSIVAS (rodam em paralelo)
-- ═══════════════════════════════════════════════

-- Auto Ken (Zyn Hub pattern)
local function setAutoKen(on)
    if not on then stopPassive("Ken") _G.AutoKen=false return end
    _G.AutoKen = true
    startPassive("Ken", function()
        while _G.AutoKen do
            task.wait(0.2)
            pcall(function()
                local c = char()
                if c and not CollectionService:HasTag(c, "Ken") then
                    CommE:FireServer("Ken", true)
                end
            end)
        end
    end)
end

-- Auto Haki (Armamento)
local function setAutoHaki(on)
    if not on then stopPassive("Haki") return end
    startPassive("Haki", function()
        while PassiveThreads["Haki"] do
            pcall(function() CommE:FireServer("Haki", true) end)
            task.wait(12)
        end
    end)
end

-- Auto Stats
local function setAutoStats(on)
    if not on then stopPassive("Stats") return end
    startPassive("Stats", function()
        while PassiveThreads["Stats"] do
            pcall(function() statsSetings(S.StatPriority, 1) end)
            task.wait(0.8)
        end
    end)
end

-- Kill Aura (passiva, age sobre mobs próximos)
local function setKillAura(on)
    if not on then stopPassive("KillAura") return end
    startPassive("KillAura", function()
        while PassiveThreads["KillAura"] do
            if alive() then
                local r = Root()
                if r then
                    for _, mob in ipairs(workspace.Enemies:GetChildren()) do
                        local hm = mob:FindFirstChildOfClass("Humanoid")
                        local pp = mob:FindFirstChild("HumanoidRootPart")
                        if hm and hm.Health > 0 and pp then
                            if (r.Position - pp.Position).Magnitude <= S.KillRange then
                                f.Kill(mob, true)
                                break
                            end
                        end
                    end
                end
            end
            task.wait(0.08)
        end
    end)
end

-- Anti AFK
local function setAntiAFK(on)
    if not on then stopPassive("AntiAFK") return end
    startPassive("AntiAFK", function()
        while PassiveThreads["AntiAFK"] do
            task.wait(60)
            pcall(function()
                VIM:SendKeyEvent(true,  Enum.KeyCode.Space, false, game)
                task.wait(0.1)
                VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end)
        end
    end)
end

-- Terror Shark ESP
local function setTerrorESP(on)
    if not on then
        for _, v in ipairs(workspace:GetDescendants()) do
            local e = v:FindFirstChild("ZH_ESP") if e then e:Destroy() end
        end
        stopPassive("TerrorESP") return
    end
    startPassive("TerrorESP", function()
        while PassiveThreads["TerrorESP"] do
            for _, v in ipairs(workspace:GetChildren()) do
                if v:IsA("Model") and v.Name:lower():find("terrorshark") then
                    if not v:FindFirstChild("ZH_ESP") then
                        local hl = Instance.new("Highlight")
                        hl.Name="ZH_ESP" hl.FillColor=Color3.fromRGB(255,50,50)
                        hl.OutlineColor=Color3.fromRGB(255,255,255) hl.FillTransparency=0.5 hl.Parent=v
                    end
                end
            end
            task.wait(2)
        end
    end)
end

-- ═══════════════════════════════════════════════
-- FLY / NOCLIP / INF JUMP
-- ═══════════════════════════════════════════════
local FlyVel, FlyGyro, IJConn

local function setFly(on)
    if on then
        local r = Root() if not r then return end
        FlyVel = Instance.new("BodyVelocity")
        FlyVel.MaxForce = Vector3.new(1e9,1e9,1e9) FlyVel.Velocity=Vector3.zero FlyVel.Parent=r
        FlyGyro = Instance.new("BodyGyro")
        FlyGyro.MaxTorque=Vector3.new(1e9,1e9,1e9) FlyGyro.P=1e4 FlyGyro.CFrame=r.CFrame FlyGyro.Parent=r
        local h = hum() if h then h.PlatformStand=true end
        startPassive("Fly", function()
            local cam = workspace.CurrentCamera
            while PassiveThreads["Fly"] do
                local r2 = Root()
                if r2 and FlyVel and FlyVel.Parent then
                    local spd, mv = 60, Vector3.zero
                    local cf = cam.CFrame
                    if UIS:IsKeyDown(Enum.KeyCode.W) then mv+=cf.LookVector*spd end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then mv-=cf.LookVector*spd end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then mv-=cf.RightVector*spd end
                    if UIS:IsKeyDown(Enum.KeyCode.D) then mv+=cf.RightVector*spd end
                    if UIS:IsKeyDown(Enum.KeyCode.Space) then mv+=Vector3.new(0,spd,0) end
                    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then mv-=Vector3.new(0,spd,0) end
                    FlyVel.Velocity=mv FlyGyro.CFrame=CFrame.new(r2.Position,r2.Position+cf.LookVector)
                end
                task.wait(0.03)
            end
        end)
    else
        stopPassive("Fly")
        if FlyVel  then FlyVel:Destroy()  FlyVel=nil  end
        if FlyGyro then FlyGyro:Destroy() FlyGyro=nil end
        local h=hum() if h then h.PlatformStand=false end
    end
end

local function setNoClip(on)
    if not on then stopPassive("NoClip") return end
    startPassive("NoClip", function()
        while PassiveThreads["NoClip"] do
            local c=char()
            if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
            task.wait(0.1)
        end
    end)
end

local function setInfJump(on)
    if IJConn then IJConn:Disconnect() IJConn=nil end
    if on then
        IJConn = UIS.JumpRequest:Connect(function()
            local h=hum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end

-- ═══════════════════════════════════════════════
-- SPLASH SCREEN
-- ═══════════════════════════════════════════════
local function showSplash()
    pcall(function()
        local sg = Instance.new("ScreenGui")
        sg.Name="ZenithSplash" sg.IgnoreGuiInset=true sg.ResetOnSpawn=false sg.Parent=plr.PlayerGui
        local bg = Instance.new("Frame",sg)
        bg.Size=UDim2.fromScale(1,1) bg.BackgroundColor3=Color3.fromRGB(10,10,18)
        bg.BackgroundTransparency=1 bg.BorderSizePixel=0
        local blur = Instance.new("BlurEffect",Lighting) blur.Size=0
        local function tw(o,t,p) TweenService:Create(o,TweenInfo.new(t,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),p):Play() end
        tw(bg,0.5,{BackgroundTransparency=0}) tw(blur,0.5,{Size=16}) task.wait(0.5)
        local card = Instance.new("Frame",bg)
        card.AnchorPoint=Vector2.new(0.5,0.5) card.Position=UDim2.fromScale(0.5,0.55)
        card.Size=UDim2.fromOffset(420,200) card.BackgroundColor3=Color3.fromRGB(15,15,25)
        card.BackgroundTransparency=1 card.BorderSizePixel=0
        Instance.new("UICorner",card).CornerRadius=UDim.new(0,16)
        local stroke=Instance.new("UIStroke",card) stroke.Color=Color3.fromRGB(80,120,255) stroke.Thickness=1.5 stroke.Transparency=1
        TweenService:Create(card,TweenInfo.new(0.6,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{BackgroundTransparency=0}):Play()
        tw(stroke,0.6,{Transparency=0})
        local function mkL(pos,text,font,size,col)
            local l=Instance.new("TextLabel",card)
            l.AnchorPoint=Vector2.new(0.5,0) l.Position=UDim2.fromOffset(210,pos)
            l.Size=UDim2.fromOffset(400,30) l.BackgroundTransparency=1
            l.Text=text l.Font=font l.TextSize=size l.TextColor3=col l.TextTransparency=1
            return l
        end
        local t1=mkL(30,"ZENITH HUB",Enum.Font.GothamBold,30,Color3.fromRGB(255,255,255))
        local t2=mkL(72,"Blox Fruits  •  v2.1  •  World "..WORLD,Enum.Font.Gotham,13,Color3.fromRGB(150,150,200))
        local barBg=Instance.new("Frame",card)
        barBg.AnchorPoint=Vector2.new(0.5,0) barBg.Position=UDim2.fromOffset(210,115)
        barBg.Size=UDim2.fromOffset(340,4) barBg.BackgroundColor3=Color3.fromRGB(30,30,50)
        barBg.BackgroundTransparency=1 barBg.BorderSizePixel=0
        Instance.new("UICorner",barBg).CornerRadius=UDim.new(1,0)
        local fill=Instance.new("Frame",barBg)
        fill.Size=UDim2.fromScale(0,1) fill.BackgroundColor3=Color3.fromRGB(80,120,255)
        fill.BorderSizePixel=0 Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
        task.wait(0.3)
        for _,item in ipairs({t1,t2}) do tw(item,0.4,{TextTransparency=0}) end
        tw(barBg,0.4,{BackgroundTransparency=0}) task.wait(0.4)
        TweenService:Create(fill,TweenInfo.new(1.8,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.fromScale(1,1)}):Play()
        task.wait(2) tw(bg,0.5,{BackgroundTransparency=1}) tw(blur,0.5,{Size=0}) task.wait(0.6)
        sg:Destroy() blur:Destroy()
    end)
end

-- ═══════════════════════════════════════════════
-- FLUENT UI
-- ═══════════════════════════════════════════════
local Fluent, SaveManager, InterfaceManager

local function loadFluent()
    Fluent           = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    SaveManager      = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
end

local function buildUI()
    local W = Fluent:CreateWindow({
        Title       = "Zenith Hub",
        SubTitle    = "Blox Fruits  •  v2.1  •  World "..WORLD,
        TabWidth    = 148,
        Size        = UDim2.fromOffset(620, 480),
        Acrylic     = true,
        Theme       = "Dark",
        MinimizeKey = Enum.KeyCode.RightControl,
    })

    local function N(title, text, dur, style)
        pcall(Fluent.Notify, Fluent, {Title=title, Content=text, Duration=dur or 3, Style=style or "Info"})
    end

    -- Cria todas as abas de uma vez (garante que todas existam)
    local T = {}
    T.Farm      = W:AddTab({Title="Main Farm",   Icon="home"      })
    T.Bosses    = W:AddTab({Title="Bosses",       Icon="skull"     })
    T.Sea       = W:AddTab({Title="Sea Events",   Icon="anchor"    })
    T.Fruits    = W:AddTab({Title="Fruits",       Icon="apple"     })
    T.Items     = W:AddTab({Title="Items/Quest",  Icon="scroll"    })
    T.Fighting  = W:AddTab({Title="Fighting",     Icon="flame"     })
    T.Raids     = W:AddTab({Title="Raids",        Icon="sword"     })
    T.Races     = W:AddTab({Title="Races / V4",   Icon="zap"       })
    T.Dragon    = W:AddTab({Title="Dragon/Dojo",  Icon="star"      })
    T.Gun       = W:AddTab({Title="Gun System",   Icon="crosshair" })
    T.Player    = W:AddTab({Title="Player",       Icon="user"      })
    T.Teleports = W:AddTab({Title="Teleports",    Icon="map-pin"   })
    T.Visuals   = W:AddTab({Title="Visuals",      Icon="eye"       })
    T.Server    = W:AddTab({Title="Server",       Icon="globe"     })
    T.Settings  = W:AddTab({Title="Settings",     Icon="settings"  })

    -- Cada tab preenchida em pcall independente
    -- ══ TAB 1 — MAIN FARM ════════════════════════
    pcall(function()
        T.Farm:AddSection("Auto Farm")
        T.Farm:AddToggle("AutoFarm",{Title="Auto Farm (por Level)",Default=false,Callback=function(v)
            setAutoFarm(v) N("Auto Farm",v and "Ativado!" or "Off.",2,v and "Success" or "Info")
        end})
        T.Farm:AddToggle("KillAura",{Title="Kill Aura",Default=false,Callback=function(v)
            setKillAura(v)
        end})
        T.Farm:AddSlider("KillRange",{Title="Kill Aura Range",Min=5,Max=120,Default=40,Rounding=0,Callback=function(v)
            S.KillRange=v
        end})
        T.Farm:AddSection("Stats & Haki")
        T.Farm:AddDropdown("StatPrio",{Title="Stat Priority",Values={"Melee","Defense","Sword","Gun","Devil"},Default="Melee",Callback=function(v)
            S.StatPriority=v
        end})
        T.Farm:AddToggle("AutoStats",{Title="Auto Stats",Default=false,Callback=function(v)
            setAutoStats(v)
        end})
        T.Farm:AddToggle("AutoHaki",{Title="Auto Armamento (Buso)",Default=false,Callback=function(v)
            setAutoHaki(v)
        end})
        T.Farm:AddToggle("AutoKen",{Title="Auto Observation (Ken)",Default=false,Callback=function(v)
            setAutoKen(v)
        end})
        T.Farm:AddSection("Arma & Team")
        T.Farm:AddDropdown("WeaponSel",{Title="Arma Selecionada",Values={"(Nenhuma)","Dark Blade","Rengoku","Pole (2nd form)","Tushita","Yama","Cursed Dual Katana","Buddy Sword","Hallow Scythe","Canvander","True Triple Katana"},Default="(Nenhuma)",Callback=function(v)
            S.WeaponName = v~="(Nenhuma)" and v or nil
            _G.SelectWeapon = S.WeaponName
        end})
        T.Farm:AddButton({Title="Set Marines",Callback=function() invoke("SetTeam","Marines") N("Team","Marines",2) end})
        T.Farm:AddButton({Title="Set Pirates",Callback=function() invoke("SetTeam","Pirates") N("Team","Pirates",2) end})
        T.Farm:AddToggle("RandomCF",{Title="RandomCFrame (Anti-Detect)",Default=false,Callback=function(v)
            RandomCFrame=v
        end})
        T.Farm:AddSlider("MobH",{Title="Mob Height",Min=5,Max=60,Default=20,Rounding=0,Callback=function(v)
            _G.MobHeight=v
        end})
    end)

    -- ══ TAB 2 — BOSSES ═══════════════════════════
    pcall(function()
        T.Bosses:AddSection("Boss Farm — World "..WORLD)
        T.Bosses:AddDropdown("BossSel",{Title="Boss Alvo",Values=BOSSES,Default=BOSSES[1],Callback=function(v)
            S.SelectedBoss=v
        end})
        T.Bosses:AddToggle("AutoBoss",{Title="Auto Boss",Default=false,Callback=function(v)
            setAutoBoss(v) N("Boss",v and "→ "..S.SelectedBoss or "Off.",3)
        end})
        T.Bosses:AddButton({Title="Farm Greybeard",Callback=function()
            S.SelectedBoss="Greybeard" setAutoBoss(true) N("Boss","Farm Greybeard",2,"Success")
        end})
        if World2 then
            T.Bosses:AddButton({Title="Farm Darkbeard",Callback=function()
                S.SelectedBoss="Darkbeard" setAutoBoss(true) N("Boss","Farm Darkbeard",2,"Success")
            end})
        end
        if World3 then
            T.Bosses:AddButton({Title="Farm Soul Reaper",Callback=function()
                S.SelectedBoss="Soul Reaper" setAutoBoss(true) N("Boss","Farm Soul Reaper",2,"Success")
            end})
        end
    end)

    -- ══ TAB 3 — SEA EVENTS ════════════════════════
    pcall(function()
        T.Sea:AddSection("Sea Events")
        T.Sea:AddToggle("SeaBeast",{Title="Sea Beast / Leviathan",Default=false,Callback=function(v)
            setSeaBeast(v) N("Sea Beast",v and "Ativado!" or "Off.",2)
        end})
        T.Sea:AddToggle("TerrorESP",{Title="Terrorshark ESP",Default=false,Callback=function(v)
            setTerrorESP(v)
        end})
        T.Sea:AddToggle("EventESP",{Title="Event ESP",Default=false,Callback=function(v) _G.EventESP=v end})
        T.Sea:AddButton({Title="TP Ghost Ship",Callback=function()
            _tp(w.Ghost) N("Ghost Ship","Teleportando...",2)
        end})
    end)

    -- ══ TAB 4 — FRUITS ════════════════════════════
    pcall(function()
        T.Fruits:AddSection("Fruit Sniper")
        T.Fruits:AddDropdown("FruitTarget",{Title="Fruta Alvo",Values=ALL_FRUITS,Default="Dragon",Callback=function(v)
            S.FruitTarget=v
        end})
        T.Fruits:AddToggle("FruitSniper",{Title="Fruit Sniper",Default=false,Callback=function(v)
            if not v then stopPassive("Sniper") return end
            startPassive("Sniper", function()
                while PassiveThreads["Sniper"] do
                    for _, obj in ipairs(workspace:GetChildren()) do
                        if obj:IsA("Model") and obj.Name:lower():find(S.FruitTarget:lower(),1,true) then
                            local pp = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart")
                            if pp then _tp(pp.CFrame * CFrame.new(0,2,0)) task.wait(0.4) end
                        end
                    end
                    task.wait(1.5)
                end
            end)
            N("Sniper","Monitorando: "..S.FruitTarget,2)
        end})
        T.Fruits:AddSection("Mastery Farm")
        T.Fruits:AddDropdown("MastType",{Title="Tipo de Maestria",Values={"Fruit","Gun","Sword","Melee"},Default="Fruit",Callback=function(v)
            S.MasteryType=v
        end})
        T.Fruits:AddToggle("MastFarm",{Title="Auto Mastery Farm",Default=false,Callback=function(v)
            setMasteryFarm(v, S.MasteryType) N("Mastery",v and S.MasteryType or "Off.",3)
        end})
        T.Fruits:AddSlider("HealthMSl",{Title="HealthM (switch p/ skill)",Min=100,Max=5000,Default=500,Rounding=0,Callback=function(v)
            HealthM=v
        end})
        T.Fruits:AddSection("Despertar")
        T.Fruits:AddDropdown("AwakeSel",{Title="Fruta a Despertar",Values=AWAKEN_FRUITS,Default="Flame",Callback=function(v)
            _G.AwakeFruit=v
        end})
        T.Fruits:AddToggle("AutoAwaken",{Title="Auto Awaken",Default=false,Callback=function(v)
            _G.AutoAwaken=v N("Awaken",v and "Ativado!" or "Off.",3)
        end})
    end)

    -- ══ TAB 5 — ITEMS / QUEST ════════════════════
    pcall(function()
        T.Items:AddSection("Quest System")
        T.Items:AddButton({Title="Aceitar Melhor Quest (Lv "..level()..")",Callback=function()
            local q=getBestQuest()
            if q then
                _tp(q.cfNPC) task.wait(0.5) invoke("StartQuest",q.quest)
                N("Quest","Aceita para Lv "..level(),2,"Success")
            end
        end})
        T.Items:AddToggle("AutoNextIsland",{Title="Auto Next Island",Default=false,Callback=function(v)
            _G.AutoNextIsland=v
        end})
        T.Items:AddSection("Auto Buy / Store")
        T.Items:AddToggle("GachaBuy",{Title="Gacha Buy",Default=false,Callback=function(v)
            _G.GachaBuy=v N("Gacha",v and "Auto comprando!" or "Off.",3)
        end})
        T.Items:AddToggle("AutoStoreFruit",{Title="Auto Store Fruit",Default=false,Callback=function(v)
            _G.AutoStoreFruit=v
        end})
        T.Items:AddToggle("AutoBuyItems",{Title="Auto Buy Items",Default=false,Callback=function(v)
            _G.AutoBuyItems=v
        end})
    end)

    -- ══ TAB 6 — FIGHTING ══════════════════════════
    pcall(function()
        T.Fighting:AddSection("Fighting Style")
        T.Fighting:AddDropdown("FSStyle",{Title="Fighting Style",Values=FIGHTING_STYLES,Default="Dark Step",Callback=function(v)
            S.FightingStyle=v
        end})
        T.Fighting:AddToggle("FSMastery",{Title="Auto Fighting Mastery",Default=false,Callback=function(v)
            _G.FightingMastery=v N("Fighting",v and S.FightingStyle or "Off.",3)
        end})
        T.Fighting:AddSection("Skills Manuais")
        T.Fighting:AddButton({Title="Melee Z + X + C",Callback=function()
            Useskills("Melee","Z") task.wait(0.1)
            Useskills("Melee","X") task.wait(0.1)
            Useskills("Melee","C")
        end})
        T.Fighting:AddButton({Title="Fruit Z + X + C",Callback=function()
            Useskills("Blox Fruit","Z") task.wait(0.1)
            Useskills("Blox Fruit","X") task.wait(0.1)
            Useskills("Blox Fruit","C")
        end})
    end)

    -- ══ TAB 7 — RAIDS ═════════════════════════════
    pcall(function()
        T.Raids:AddSection("Auto Raid")
        T.Raids:AddToggle("AutoRaid",{Title="Auto Raid",Default=false,Callback=function(v)
            setAutoRaid(v) N("Raid",v and "Ativado!" or "Off.",2,v and "Success" or "Info")
        end})
        T.Raids:AddToggle("AutoChipBuy",{Title="Auto Chip Buy",Default=false,Callback=function(v)
            _G.AutoChipBuy=v
        end})
        T.Raids:AddToggle("AutoDungeon",{Title="Auto Dungeon",Default=false,Callback=function(v)
            _G.AutoDungeon=v N("Dungeon",v and "Ativado!" or "Off.",2)
        end})
        T.Raids:AddDropdown("RaidFruitSel",{Title="Fruta da Raid",Values=AWAKEN_FRUITS,Default="Flame",Callback=function(v)
            _G.RaidFruit=v
        end})
        T.Raids:AddButton({Title="Iniciar Raid",Callback=function()
            pcall(function() invoke("StartRaid", _G.RaidFruit or "Flame") end)
            N("Raid","Iniciando: "..((_G.RaidFruit) or "?"),3)
        end})
    end)

    -- ══ TAB 8 — RACES / V4 ════════════════════════
    pcall(function()
        T.Races:AddSection("Raças")
        T.Races:AddDropdown("RaceSel",{Title="Raça",Values={"Human","Fish","Angel","Mink","Cyborg","Ghoul"},Default="Human",Callback=function(v)
            S.SelectedRace=v
        end})
        T.Races:AddToggle("AutoRaceV4",{Title="Auto Race V4",Default=false,Callback=function(v)
            if not v then stopPassive("RaceV4") return end
            startPassive("RaceV4", function()
                while PassiveThreads["RaceV4"] do
                    pcall(function() invoke("ActivateRace", S.SelectedRace) end)
                    task.wait(6)
                end
            end)
            N("Race V4",v and S.SelectedRace or "Off.",2)
        end})
        T.Races:AddToggle("AutoTrial",{Title="Auto Trial",Default=false,Callback=function(v) _G.AutoTrial=v end})
        T.Races:AddSection("Teleports de Raça")
        T.Races:AddButton({Title="Temple of Time",Callback=function()
            _tp(CFrame.new(-1648,1079,427)) N("Temple","Teleportando...",2)
        end})
    end)

    -- ══ TAB 9 — DRAGON / DOJO ════════════════════
    pcall(function()
        T.Dragon:AddSection("Dragon Farm (Longma)")
        T.Dragon:AddToggle("AutoDragon",{Title="Auto Longma Farm",Default=false,Callback=function(v)
            if v then S.SelectedBoss="Longma" setAutoBoss(true)
            else disableExclusive("AutoBoss") end
            N("Dragon",v and "Farm Longma" or "Off.",2)
        end})
        T.Dragon:AddSection("Godhuman — Dojo")
        T.Dragon:AddButton({Title="TP ao Dojo",Callback=function()
            _tp(CFrame.new(1021.5,259.5,490.4)) N("Dojo","Teleportando...",2)
        end})
        T.Dragon:AddToggle("AutoDojo",{Title="Auto Dojo Quest",Default=false,Callback=function(v)
            _G.AutoDojo=v
        end})
        T.Dragon:AddSection("Sanguine Art")
        T.Dragon:AddButton({Title="TP Slayer Altar",Callback=function()
            _tp(CFrame.new(-11857,16,-2786)) N("Slayer","Teleportando...",2)
        end})
    end)

    -- ══ TAB 10 — GUN SYSTEM ══════════════════════
    pcall(function()
        T.Gun:AddSection("Gun Mastery")
        T.Gun:AddDropdown("GunSel",{Title="Gun",Values=GUNS,Default="Flintlock",Callback=function(v)
            S.SelectedGun=v
        end})
        T.Gun:AddToggle("GunMastery",{Title="Auto Gun Mastery",Default=false,Callback=function(v)
            _G.GunMastery=v N("Gun",v and S.SelectedGun or "Off.",3)
        end})
        T.Gun:AddSection("Skills")
        T.Gun:AddButton({Title="Gun Z + X",Callback=function()
            Useskills("Gun","Z") task.wait(0.1) Useskills("Gun","X")
        end})
    end)

    -- ══ TAB 11 — PLAYER ══════════════════════════
    pcall(function()
        T.Player:AddSection("Movimento")
        T.Player:AddSlider("SpeedSl",{Title="Walk Speed",Min=16,Max=500,Default=16,Rounding=0,Callback=function(v)
            local h=hum() if h then h.WalkSpeed=v end
        end})
        T.Player:AddToggle("Fly",{Title="Fly  (WASD + Space / LCtrl)",Default=false,Callback=function(v)
            setFly(v) N("Fly",v and "WASD + Space/LCtrl" or "Off.",3)
        end})
        T.Player:AddToggle("NoClip",{Title="No Clip",Default=false,Callback=function(v) setNoClip(v) end})
        T.Player:AddToggle("InfJump",{Title="Infinite Jump",Default=false,Callback=function(v) setInfJump(v) end})
        T.Player:AddSection("SimulationRadius")
        T.Player:AddToggle("SimRadius",{Title="SimulationRadius (BringEnemy)",Default=false,Callback=function(v)
            if v then
                startPassive("SimRad", function()
                    while PassiveThreads["SimRad"] do
                        plr.SimulationRadius=math.huge task.wait(0.5)
                    end
                end)
            else stopPassive("SimRad") end
        end})
    end)

    -- ══ TAB 12 — TELEPORTS ═══════════════════════
    pcall(function()
        local isleNames = {}
        for _, isle in ipairs(ISLANDS) do table.insert(isleNames, isle.name) end
        T.Teleports:AddSection("Configuração")
        T.Teleports:AddToggle("TweenTP",{Title="Usar Tween (suave)",Default=true,Callback=function(v) S.UseTween=v end})
        T.Teleports:AddSlider("TweenSpd",{Title="Velocidade Tween",Min=0.5,Max=5,Default=1.5,Rounding=1,Callback=function(v) S.TweenSpeed=v end})
        T.Teleports:AddDropdown("IsleSel",{Title="Ilha",Values=isleNames,Default=isleNames[1],Callback=function(v) S.SelectedIsland=v end})
        T.Teleports:AddButton({Title="Teleportar",Callback=function()
            for _, isle in ipairs(ISLANDS) do
                if isle.name==S.SelectedIsland then
                    if S.UseTween then
                        local r=Root() if r then
                            local t=TweenService:Create(r,TweenInfo.new(S.TweenSpeed,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{CFrame=isle.cf})
                            t:Play()
                        end
                    else _tp(isle.cf) end
                    N("TP",isle.name,2) break
                end
            end
        end})
        T.Teleports:AddSection("Especiais")
        T.Teleports:AddButton({Title="Middle Town",Callback=function() _tp(CFrame.new(0,6,700)) N("TP","Middle Town",2) end})
        T.Teleports:AddButton({Title="Colosseum",Callback=function() _tp(CFrame.new(5071,24,3828)) N("TP","Colosseum",2) end})
        T.Teleports:AddButton({Title="Ghost Ship",Callback=function() _tp(w.Ghost) N("TP","Ghost Ship",2) end})
    end)

    -- ══ TAB 13 — VISUALS ══════════════════════════
    pcall(function()
        T.Visuals:AddSection("Performance")
        T.Visuals:AddToggle("FPSBoost",{Title="FPS Boost",Default=false,Callback=function(v)
            pcall(function() settings().Rendering.QualityLevel=v and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic end)
            N("FPS",v and "Qualidade reduzida." or "Normal.",2)
        end})
        T.Visuals:AddToggle("RemoveEff",{Title="Remove Particles / Efeitos",Default=false,Callback=function(v)
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") then
                    obj.Enabled=not v
                end
            end
        end})
        T.Visuals:AddSection("Ambiente")
        T.Visuals:AddToggle("WhiteScreen",{Title="White Screen (farm mais rápido)",Default=false,Callback=function(v)
            local ws=plr.PlayerGui:FindFirstChild("ZH_WS")
            if v then
                if ws then return end
                local sg2=Instance.new("ScreenGui") sg2.Name="ZH_WS" sg2.IgnoreGuiInset=true sg2.ResetOnSpawn=false sg2.Parent=plr.PlayerGui
                local fr=Instance.new("Frame",sg2) fr.Size=UDim2.fromScale(1,1) fr.BackgroundColor3=Color3.fromRGB(255,255,255) fr.BackgroundTransparency=0.45 fr.BorderSizePixel=0
            else if ws then ws:Destroy() end end
        end})
        T.Visuals:AddToggle("FullBright",{Title="Full Bright",Default=false,Callback=function(v)
            if v then
                Lighting.Ambient=Color3.new(0.695,0.695,0.695) Lighting.Brightness=2 Lighting.FogEnd=1e10
            else
                Lighting.Ambient=Color3.new(0,0,0) Lighting.Brightness=1 Lighting.FogEnd=1e4
            end
        end})
        T.Visuals:AddSection("ESP")
        T.Visuals:AddToggle("TerrorESPV",{Title="Terrorshark ESP",Default=false,Callback=function(v) setTerrorESP(v) end})
    end)

    -- ══ TAB 14 — SERVER ═══════════════════════════
    pcall(function()
        T.Server:AddSection("Server")
        T.Server:AddButton({Title="Server Hop",Callback=function()
            N("Server","Trocando...",2) task.wait(0.8)
            pcall(function() TeleportService:Teleport(game.PlaceId,plr) end)
        end})
        T.Server:AddButton({Title="Rejoin",Callback=function()
            N("Rejoin","Reconectando...",2) task.wait(0.8)
            pcall(function() TeleportService:Teleport(game.PlaceId,plr) end)
        end})
        T.Server:AddButton({Title="Join Low Player Server",Callback=function()
            N("Server","Procurando servidor vazio...",3)
            task.spawn(function()
                pcall(function()
                    local HS=game:GetService("HttpService")
                    local cursor,lowJob,lowPop="",nil,math.huge
                    repeat
                        local url=("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100&cursor=%s"):format(game.PlaceId,cursor)
                        local ok2,res=pcall(function() return HS:JSONDecode(game:HttpGet(url,true)) end)
                        if not ok2 or not res then break end
                        for _,srv in ipairs(res.data or {}) do
                            if srv.playing<lowPop and srv.id~=game.JobId then lowPop=srv.playing lowJob=srv.id end
                        end
                        cursor=res.nextPageCursor or ""
                    until cursor=="" or lowJob
                    if lowJob then TeleportService:TeleportToPlaceInstance(game.PlaceId,lowJob,plr) end
                end)
            end)
        end})
        T.Server:AddButton({Title="Copy Job ID",Callback=function()
            local jid=game.JobId
            local ok2=pcall(function() (setclipboard or toclipboard)(jid) end)
            N("Job ID",ok2 and "Copiado!" or ("ID: "..jid),4,ok2 and "Success" or "Info")
        end})
    end)

    -- ══ TAB 15 — SETTINGS ═════════════════════════
    pcall(function()
        T.Settings:AddSection("Configurações de Farm")
        T.Settings:AddToggle("RandomCFSett",{Title="RandomCFrame (Anti-Detect)",Default=false,Callback=function(v) RandomCFrame=v end})
        T.Settings:AddSlider("HealthMSett",{Title="HealthM (Mas/Masgun threshold)",Min=100,Max=5000,Default=500,Rounding=0,Callback=function(v) HealthM=v end})
        T.Settings:AddSlider("MobHSett",{Title="Mob Height",Min=5,Max=60,Default=20,Rounding=0,Callback=function(v) _G.MobHeight=v end})
        T.Settings:AddSection("Utilidades")
        T.Settings:AddToggle("AntiAFK",{Title="Anti AFK",Default=false,Callback=function(v) setAntiAFK(v) end})
        T.Settings:AddToggle("AutoRejoin",{Title="Auto Rejoin on Kick",Default=false,Callback=function(v) _G.AutoRejoin=v end})
        T.Settings:AddToggle("FPSBoostS",{Title="FPS Boost",Default=false,Callback=function(v)
            pcall(function() settings().Rendering.QualityLevel=v and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic end)
        end})
        T.Settings:AddSection("UI")
        T.Settings:AddKeybind("ToggleKey",{Title="Tecla Abrir/Fechar",Mode="Toggle",Default="RightControl",Callback=function() end})
        -- SaveManager
        pcall(function()
            SaveManager:SetLibrary(Fluent)
            InterfaceManager:SetLibrary(Fluent)
            SaveManager:IgnoreThemeSettings()
            SaveManager:SetFolder("ZenithHub")
            InterfaceManager:SetFolder("ZenithHub")
            SaveManager:BuildConfigSection(T.Settings)
            InterfaceManager:BuildInterfaceSection(T.Settings)
            SaveManager:LoadAutoloadConfig()
        end)
    end)

    W:SelectTab(1)
    N("Zenith Hub v2.1","Pronto!  RCtrl para minimizar.",5,"Success")
end

-- ═══════════════════════════════════════════════
-- RESPAWN — mantém passivas ativas
-- ═══════════════════════════════════════════════
plr.CharacterAdded:Connect(function()
    task.wait(1)
    workspace.Enemies = workspace:WaitForChild("Enemies", 10) or workspace.Enemies
    -- Reativa AutoKen se estava ativo
    if _G.AutoKen then setAutoKen(true) end
end)

-- ═══════════════════════════════════════════════
-- LIMPEZA AO SAIR
-- ═══════════════════════════════════════════════
plr.AncestryChanged:Connect(function()
    pcall(function()
        _G.ZenithLoaded = nil
        stopExclusive()
        for name in pairs(PassiveThreads) do stopPassive(name) end
        if IJConn then IJConn:Disconnect() end
        for _, v in ipairs(workspace:GetDescendants()) do
            local e = v:FindFirstChild("ZH_ESP") if e then e:Destroy() end
        end
    end)
end)

-- ═══════════════════════════════════════════════
-- BOOT
-- ═══════════════════════════════════════════════
pcall(function()
    StarterGui:SetCore("SendNotification",{Title="Zenith Hub",Text="Carregando...",Duration=4})
end)

showSplash()

local ok, err = pcall(loadFluent)
if not ok then
    warn("[ZenithHub] Fluent: "..tostring(err))
    pcall(function()
        StarterGui:SetCore("SendNotification",{Title="Zenith Hub",Text="Erro HTTP — verifique o executor.",Duration=8})
    end)
    _G.ZenithLoaded=nil return
end

local ok2, err2 = pcall(buildUI)
if not ok2 then
    warn("[ZenithHub] UI: "..tostring(err2))
    _G.ZenithLoaded=nil return
end

print("[ZenithHub] v2.1 — World "..WORLD.." — Pronto!")
