--[[
    ZenithHub — BloxFruits.lua  (v2.0)
    Core logic do Blox Fruits.
    Patterns extraídos dos open sources Zyn Hub e Vua Hub.

    Remotes reais do jogo:
      CommF_  = ReplicatedStorage.Remotes.CommF_  (RemoteFunction → InvokeServer)
      CommE   = ReplicatedStorage.Remotes.CommE   (RemoteEvent   → FireServer)
]]

local BF = {}

-- ═══════════════════════════════════════════════
-- SERVIÇOS (cache local)
-- ═══════════════════════════════════════════════
local Players          = game:GetService("Players")
local RS               = game:GetService("ReplicatedStorage")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local CollectionService= game:GetService("CollectionService")
local TeleportService  = game:GetService("TeleportService")
local VIM              = game:GetService("VirtualInputManager")

local plr     = Players.LocalPlayer
local Enemies = workspace.Enemies   -- pasta correta do BF

-- ═══════════════════════════════════════════════
-- REMOTES (carregados uma vez)
-- ═══════════════════════════════════════════════
local CommF_, CommE

local function loadRemotes()
    local rem = RS:WaitForChild("Remotes", 10)
    if not rem then return end
    CommF_ = rem:WaitForChild("CommF_", 10)
    CommE  = rem:WaitForChild("CommE",  10)
end

local function invoke(...)
    if CommF_ then return pcall(CommF_.InvokeServer, CommF_, ...) end
end

local function fire(...)
    if CommE then pcall(CommE.FireServer, CommE, ...) end
end

-- ═══════════════════════════════════════════════
-- DETECÇÃO DE MUNDO
-- ═══════════════════════════════════════════════
local placeId = game.PlaceId
local World1 = placeId == 2753915549 or placeId == 85211729168715
local World2 = placeId == 4442272183 or placeId == 79091703265657
local World3 = placeId == 7449423635 or placeId == 100117331123089

BF.World = World1 and 1 or World2 and 2 or World3 and 3 or 1

-- ═══════════════════════════════════════════════
-- BOSSES POR MUNDO (nomes reais do jogo)
-- ═══════════════════════════════════════════════
BF.Bosses = World1 and {
    "The Gorilla King","Bobby","The Saw","Yeti","Mob Leader",
    "Vice Admiral","Saber Expert","Warden","Chief Warden","Swan",
    "Magma Admiral","Fishman Lord","Wysper","Thunder God",
    "Cyborg","Ice Admiral","Greybeard",
} or World2 and {
    "Diamond","Jeremy","Fajita","Don Swan",
    "Smoke Admiral","Awakened Ice Admiral","Tide Keeper",
    "Darkbeard","Cursed Captain","Order",
} or {
    "Stone","Hydra Leader","Kilo Admiral","Captain Elephant",
    "Beautiful Pirate","Cake Queen","Longma","Soul Reaper",
}

-- ═══════════════════════════════════════════════
-- MATERIAIS POR MUNDO
-- ═══════════════════════════════════════════════
BF.Materials = World1 and {
    "Leather + Scrap Metal","Angel Wings","Magma Ore","Fish Tail",
} or World2 and {
    "Leather + Scrap Metal","Radioactive Material","Ectoplasm",
    "Mystic Droplet","Magma Ore","Vampire Fang",
} or {
    "Scrap Metal","Demonic Wisp","Conjured Cocoa","Dragon Scale",
    "Gunpowder","Fish Tail","Mini Tusk",
}

-- ═══════════════════════════════════════════════
-- POSIÇÕES DE MOBS (Third Sea — CFrames reais)
-- ═══════════════════════════════════════════════
BF.MobPositions = {
    ["Pirate Millionaire"]  = CFrame.new(-712.82, 98.57, 5711.95),
    ["Pistol Billionaire"]  = CFrame.new(-723.43, 147.42, 5931.99),
    ["Dragon Crew Warrior"] = CFrame.new(7021.50, 55.76, -730.12),
    ["Dragon Crew Archer"]  = CFrame.new(6625, 378, 244),
    ["Female Islander"]     = CFrame.new(4692.79, 797.97, 858.84),
    ["Venomous Assailant"]  = CFrame.new(4902, 670, 39),
    ["Marine Commodore"]    = CFrame.new(2401, 123, -7589),
    ["Marine Rear Admiral"] = CFrame.new(3588, 229, -7085),
    ["Fishman Raider"]      = CFrame.new(-10941, 332, -8760),
    ["Fishman Captain"]     = CFrame.new(-11035, 332, -9087),
    ["Forest Pirate"]       = CFrame.new(-13446, 413, -7760),
    ["Mythological Pirate"] = CFrame.new(-13510, 584, -6987),
    ["Jungle Pirate"]       = CFrame.new(-11778, 426, -10592),
    ["Musketeer Pirate"]    = CFrame.new(-13282, 496, -9565),
    ["Reborn Skeleton"]     = CFrame.new(-8764, 142, 5963),
    ["Living Zombie"]       = CFrame.new(-10227, 421, 6161),
    ["Demonic Soul"]        = CFrame.new(-9579, 6, 6194),
    ["Posessed Mummy"]      = CFrame.new(-9579, 6, 6194),
    ["Peanut Scout"]        = CFrame.new(-1993, 187, -10103),
    ["Peanut President"]    = CFrame.new(-2215, 159, -10474),
    ["Ice Cream Chef"]      = CFrame.new(-877, 118, -11032),
    ["Ice Cream Commander"] = CFrame.new(-877, 118, -11032),
    ["Cookie Crafter"]      = CFrame.new(-2021, 38, -12028),
    ["Cake Guard"]          = CFrame.new(-2024, 38, -12026),
    ["Baking Staff"]        = CFrame.new(-1932, 38, -12848),
    ["Head Baker"]          = CFrame.new(-1932, 38, -12848),
    ["Cocoa Warrior"]       = CFrame.new(95, 73, -12309),
    ["Chocolate Bar Battler"]= CFrame.new(647, 42, -12401),
    ["Sweet Thief"]         = CFrame.new(116, 36, -12478),
    ["Candy Rebel"]         = CFrame.new(47, 61, -12889),
}

-- ═══════════════════════════════════════════════
-- QUESTS POR MUNDO (nível → dados da quest)
-- ═══════════════════════════════════════════════
-- Formato: { lvl, npc, questKey, mob, cfMob, cfNPC }
BF.Quests = World1 and {
    { lvl=1,   npc="Bandit Quest Recruiter",       questKey="Bandits",        mob="Bandit",             cfMob=CFrame.new(977,7,1582),       cfNPC=CFrame.new(971,7,1590)    },
    { lvl=10,  npc="Monkey Quest Recruiter",       questKey="Monkeys",        mob="Monkey",             cfMob=CFrame.new(-1766,14,-3096),    cfNPC=CFrame.new(-1760,14,-3100) },
    { lvl=30,  npc="Pirate Quest Recruiter",       questKey="Pirates",        mob="Pirate",             cfMob=CFrame.new(-1306,4,312),       cfNPC=CFrame.new(-1300,4,318)   },
    { lvl=60,  npc="Desert Quest Recruiter",       questKey="DesertBandits",  mob="Desert Bandit",      cfMob=CFrame.new(941,6,-2767),       cfNPC=CFrame.new(935,6,-2761)   },
    { lvl=90,  npc="Snow Quest Recruiter",         questKey="SnowBandits",    mob="Snow Bandit",        cfMob=CFrame.new(1239,9,-3011),      cfNPC=CFrame.new(1233,9,-3005)  },
    { lvl=120, npc="Marine Quest Recruiter",       questKey="Marines",        mob="Marine",             cfMob=CFrame.new(-4600,10,4068),     cfNPC=CFrame.new(-4594,10,4074) },
    { lvl=150, npc="Sky Quest Recruiter",          questKey="SkyBandits",     mob="Sky Bandit",         cfMob=CFrame.new(-4852,3038,1999),   cfNPC=CFrame.new(-4846,3038,2005)},
    { lvl=190, npc="Prison Quest Recruiter",       questKey="Prisoners",      mob="Prisoner",           cfMob=CFrame.new(4781,5,803),        cfNPC=CFrame.new(4775,5,809)    },
    { lvl=250, npc="Colosseum Quest Recruiter",    questKey="Colosseum",      mob="Toga Warrior",       cfMob=CFrame.new(5071,24,3828),      cfNPC=CFrame.new(5065,24,3834)  },
    { lvl=300, npc="Magma Quest Recruiter",        questKey="MagmaSoldiers",  mob="Magma Soldier",      cfMob=CFrame.new(-4648,46,-881),     cfNPC=CFrame.new(-4642,46,-875) },
    { lvl=375, npc="Underwater Quest Recruiter",   questKey="Fishmen",        mob="Fishman Warrior",    cfMob=CFrame.new(61164,-1400,1819),  cfNPC=CFrame.new(61158,-1400,1825)},
    { lvl=450, npc="Zombie Quest Recruiter",       questKey="Zombies",        mob="Zombie",             cfMob=CFrame.new(61164,-1400,1819),  cfNPC=CFrame.new(61158,-1400,1825)},
    { lvl=575, npc="Dragon Quest Recruiter",       questKey="Dragons",        mob="Dragon",             cfMob=CFrame.new(-7100,25,-2770),    cfNPC=CFrame.new(-7094,25,-2764) },
    { lvl=625, npc="Mythological Quest Recruiter", questKey="Mythological",   mob="Mythological Pirate",cfMob=CFrame.new(-7100,25,-2770),    cfNPC=CFrame.new(-7094,25,-2764) },
} or World2 and {
    { lvl=700,  npc="Area 1 Quest Recruiter",          questKey="Area1",         mob="Raider",            cfMob=CFrame.new(-789,73,-3774),     cfNPC=CFrame.new(-783,73,-3768)  },
    { lvl=775,  npc="Area 2 Quest Recruiter",          questKey="Area2",         mob="Mercenary",         cfMob=CFrame.new(-789,73,-3774),     cfNPC=CFrame.new(-783,73,-3768)  },
    { lvl=875,  npc="Green Bit Quest Recruiter",       questKey="GreenBit1",     mob="Plant Subordinate", cfMob=CFrame.new(-1887,22,-5018),    cfNPC=CFrame.new(-1881,22,-5012) },
    { lvl=950,  npc="Graveyard Quest Recruiter",       questKey="Graveyard1",    mob="Zombie",            cfMob=CFrame.new(3775,24,-4313),     cfNPC=CFrame.new(3781,24,-4307)  },
    { lvl=1000, npc="Snow Mountain Quest Recruiter",   questKey="SnowMountain1", mob="Snow Trooper",      cfMob=CFrame.new(2117,214,-5229),    cfNPC=CFrame.new(2123,214,-5223) },
    { lvl=1100, npc="Hot Quest Recruiter",             questKey="Hot1",          mob="Lab Subordinate",   cfMob=CFrame.new(441,157,-5462),     cfNPC=CFrame.new(447,157,-5456)  },
    { lvl=1150, npc="Cold Quest Recruiter",            questKey="Cold1",         mob="Horned Warrior",    cfMob=CFrame.new(441,157,-5462),     cfNPC=CFrame.new(447,157,-5456)  },
    { lvl=1250, npc="Cursed Captain Quest Recruiter",  questKey="Ship1",         mob="Ship Officer",      cfMob=CFrame.new(-4098,2,-5296),     cfNPC=CFrame.new(-4092,2,-5290)  },
    { lvl=1350, npc="Ice Castle Quest Recruiter",      questKey="IceCastle1",    mob="Arctic Warrior",    cfMob=CFrame.new(-1500,4,-6500),     cfNPC=CFrame.new(-1494,4,-6494)  },
    { lvl=1425, npc="Forgotten Quest Recruiter",       questKey="Forgotten1",    mob="Sea Soldier",       cfMob=CFrame.new(0,5,-7000),         cfNPC=CFrame.new(6,5,-6994)      },
} or {
    { lvl=1500, npc="Port Quest Recruiter",            questKey="PortQuest1",    mob="Pirate Millionaire",   cfMob=CFrame.new(-712.82,98.57,5711.95),  cfNPC=CFrame.new(-706,98,5717)   },
    { lvl=1575, npc="Hydra Quest Recruiter",           questKey="HydraQuest1",   mob="Dragon Crew Warrior",  cfMob=CFrame.new(7021.5,55.76,-730.12),   cfNPC=CFrame.new(7027,55,-724)   },
    { lvl=1650, npc="Jungle Quest Recruiter",          questKey="JungleQuest1",  mob="Jungle Pirate",        cfMob=CFrame.new(-11778,426,-10592),       cfNPC=CFrame.new(-11772,426,-10586)},
    { lvl=1700, npc="Great Tree Quest Recruiter",      questKey="TreeQuest1",    mob="Marine Commodore",     cfMob=CFrame.new(2401,123,-7589),          cfNPC=CFrame.new(2407,123,-7583) },
    { lvl=1775, npc="Floating Turtle Quest Recruiter", questKey="TurtleQuest1",  mob="Fishman Raider",       cfMob=CFrame.new(-10941,332,-8760),        cfNPC=CFrame.new(-10935,332,-8754)},
    { lvl=1875, npc="Mansion Quest Recruiter",         questKey="MansionQuest1", mob="Reborn Skeleton",      cfMob=CFrame.new(-8764,142,5963),          cfNPC=CFrame.new(-8758,142,5969) },
    { lvl=1975, npc="Haunted Quest Recruiter",         questKey="HauntedQuest1", mob="Living Zombie",        cfMob=CFrame.new(-10227,421,6161),         cfNPC=CFrame.new(-10221,421,6167)},
    { lvl=2075, npc="Candy Quest Recruiter",           questKey="CandyQuest1",   mob="Cookie Crafter",       cfMob=CFrame.new(-2021,38,-12028),         cfNPC=CFrame.new(-2015,38,-12022)},
    { lvl=2150, npc="Factory Quest Recruiter",         questKey="FactoryQuest1", mob="Baking Staff",         cfMob=CFrame.new(-1932,38,-12848),         cfNPC=CFrame.new(-1926,38,-12842)},
    { lvl=2225, npc="Tiki Quest Recruiter",            questKey="TikiQuest1",    mob="Peanut Scout",         cfMob=CFrame.new(-1993,187,-10103),        cfNPC=CFrame.new(-1987,187,-10097)},
    { lvl=2300, npc="Usoap Quest Recruiter",           questKey="UsoapQuest1",   mob="Forest Pirate",        cfMob=CFrame.new(-13446,413,-7760),        cfNPC=CFrame.new(-13440,413,-7754)},
    { lvl=2375, npc="Elite Quest Recruiter",           questKey="EliteQuest1",   mob="Musketeer Pirate",     cfMob=CFrame.new(-13282,496,-9565),        cfNPC=CFrame.new(-13276,496,-9559)},
    { lvl=2475, npc="Final Quest Recruiter",           questKey="FinalQuest1",   mob="Mythological Pirate",  cfMob=CFrame.new(-13510,584,-6987),        cfNPC=CFrame.new(-13504,584,-6981)},
}

-- ═══════════════════════════════════════════════
-- ILHAS POR MUNDO
-- ═══════════════════════════════════════════════
BF.Islands = World1 and {
    { name="Starter Island",    cf=CFrame.new(977,7,1582)       },
    { name="Marine Starter",    cf=CFrame.new(-967,7,1582)      },
    { name="Jungle",            cf=CFrame.new(-1766,14,-3096)   },
    { name="Pirate Village",    cf=CFrame.new(-1306,4,312)      },
    { name="Desert",            cf=CFrame.new(941,6,-2767)      },
    { name="Frozen Village",    cf=CFrame.new(1239,9,-3011)     },
    { name="Middle Town",       cf=CFrame.new(0,6,700)          },
    { name="Marine Fortress",   cf=CFrame.new(-4600,10,4068)    },
    { name="Skylands",          cf=CFrame.new(-4852,3038,1999)  },
    { name="Prison",            cf=CFrame.new(4781,5,803)       },
    { name="Colosseum",         cf=CFrame.new(5071,24,3828)     },
    { name="Magma Village",     cf=CFrame.new(-4648,46,-881)    },
    { name="Upper Skylands",    cf=CFrame.new(-4852,5538,1999)  },
    { name="Underwater City",   cf=CFrame.new(61164,-1400,1819) },
    { name="Fountain City",     cf=CFrame.new(61164,0,1819)     },
    { name="Dragon Land",       cf=CFrame.new(-7100,25,-2770)   },
} or World2 and {
    { name="Kingdom of Rose",   cf=CFrame.new(-789,73,-3774)    },
    { name="Green Zone",        cf=CFrame.new(-1887,22,-5018)   },
    { name="Graveyard",         cf=CFrame.new(3775,24,-4313)    },
    { name="Snow Mountain",     cf=CFrame.new(2117,214,-5229)   },
    { name="Hot & Cold",        cf=CFrame.new(441,157,-5462)    },
    { name="Flower Field",      cf=CFrame.new(-400,0,-5500)     },
    { name="Cursed Ship",       cf=CFrame.new(-4098,2,-5296)    },
    { name="Forgotten Island",  cf=CFrame.new(0,5,-7000)        },
    { name="Ice Castle",        cf=CFrame.new(-1500,4,-6500)    },
    { name="Cocoa Island",      cf=CFrame.new(1310,4,-6200)     },
} or {
    { name="Port Town",         cf=CFrame.new(-712,98,5711)     },
    { name="Hydra Island",      cf=CFrame.new(7021,55,-730)     },
    { name="Great Tree",        cf=CFrame.new(2401,123,-7589)   },
    { name="Floating Turtle",   cf=CFrame.new(-10941,332,-8760) },
    { name="Haunted Castle",    cf=CFrame.new(-8764,142,5963)   },
    { name="Candy Land",        cf=CFrame.new(-2021,38,-12028)  },
    { name="Sea of Treats",     cf=CFrame.new(-877,118,-11032)  },
    { name="Tiki Outpost",      cf=CFrame.new(-1993,187,-10103) },
    { name="Mansion",           cf=CFrame.new(-13282,496,-9565) },
}

-- ═══════════════════════════════════════════════
-- FRUTAS DESPERTÁVEIS
-- ═══════════════════════════════════════════════
BF.AwakeningFruits = {
    "Flame","Ice","Quake","Light","Dark","String",
    "Rumble","Magma","Human: Buddha","Sand","Bird: Phoenix","Dough",
}

-- ═══════════════════════════════════════════════
-- UTILITÁRIOS INTERNOS
-- ═══════════════════════════════════════════════
local Threads = {}
local PosMon  = Vector3.zero  -- posição alvo do BringEnemy
local _B      = false         -- flag BringEnemy ativo

local function getChar()   return plr.Character end
local function getHRP()    local c=getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()    local c=getChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function isAlive()   local h=getHum()  return h and h.Health > 0 end

local function getLevel()
    local ok, v = pcall(function() return plr.Data.Level.Value end)
    return (ok and type(v)=="number") and v or 0
end

-- TP imediato
local function _tp(cf)
    local hrp = getHRP()
    if hrp then hrp.CFrame = cf end
end

-- Para thread
local function stopThread(name)
    if Threads[name] then task.cancel(Threads[name]) Threads[name] = nil end
end

-- Inicia thread (cancela anterior)
local function startThread(name, fn)
    stopThread(name)
    Threads[name] = task.spawn(fn)
end

-- Equipa ferramenta pelo nome
local function equipWeapon(name)
    if not name then return end
    local bp = plr.Backpack:FindFirstChild(name)
    if bp then getHum():EquipTool(bp) end
end

-- Equipa pela ToolTip (ex: "Blox Fruit", "Sword", "Melee", "Gun")
local function equipByTip(tip)
    for _, tool in ipairs(plr.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.ToolTip == tip then
            getHum():EquipTool(tool)
            return
        end
    end
end

-- Usa skill via VirtualInputManager
local function useSkill(key)
    VIM:SendKeyEvent(true,  key, false, game)
    task.wait(0.05)
    VIM:SendKeyEvent(false, key, false, game)
end

-- Retorna melhor quest para o nível atual
local function getBestQuest()
    local lv = getLevel()
    local best = nil
    for _, q in ipairs(BF.Quests) do
        if q.lvl <= lv then best = q end
    end
    return best
end

-- ═══════════════════════════════════════════════
-- BRING ENEMY (pattern dos open source)
-- Usa workspace.Enemies, não GetDescendants
-- ═══════════════════════════════════════════════
local function BringEnemy()
    if not _B then return end
    local hrp = getHRP()
    if not hrp then return end
    plr.SimulationRadius = math.huge   -- necessário para mover NPCs

    for _, mob in ipairs(Enemies:GetChildren()) do
        local hum = mob:FindFirstChildOfClass("Humanoid")
        local pp  = mob.PrimaryPart
        if hum and hum.Health > 0 and pp then
            if (pp.Position - PosMon).Magnitude <= 300 then
                pp.CFrame    = CFrame.new(PosMon)
                pp.CanCollide = true
                hum.WalkSpeed = 0
                hum.JumpPower = 0
                local anim = hum:FindFirstChild("Animator")
                if anim then anim:Destroy() end
            end
        end
    end
end

-- ═══════════════════════════════════════════════
-- KILL FUNCTIONS (pattern dos open source)
-- ═══════════════════════════════════════════════

-- Kill padrão (Fruit ou Sword)
local function killMob(mob, weaponName)
    if not mob then return end
    local mobHRP = mob:FindFirstChild("HumanoidRootPart")
    if not mobHRP then return end

    -- Trava posição do mob na primeira vez
    if not mob:GetAttribute("Locked") then
        mob:SetAttribute("Locked", mobHRP.CFrame)
    end
    PosMon = mob:GetAttribute("Locked").Position
    _B = true
    BringEnemy()

    equipWeapon(weaponName)

    local tool = getChar() and getChar():FindFirstChildOfClass("Tool")
    if not tool then return end

    if tool.ToolTip == "Blox Fruit" then
        _tp(mobHRP.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(0, math.rad(90), 0))
    else
        _tp(mobHRP.CFrame * CFrame.new(0, _G.MobHeight or 20, 0))
    end
end

-- Kill com RandomCFrame (anti-detecção)
local function killMobRandom(mob, weaponName)
    if not mob then return end
    local mobHRP = mob:FindFirstChild("HumanoidRootPart")
    if not mobHRP then return end

    if not mob:GetAttribute("Locked") then
        mob:SetAttribute("Locked", mobHRP.CFrame)
    end
    PosMon = mob:GetAttribute("Locked").Position
    _B = true
    BringEnemy()
    equipWeapon(weaponName)

    local offsets = {
        CFrame.new(0,30,25), CFrame.new(25,30,0),
        CFrame.new(-25,30,0), CFrame.new(0,30,-25),
    }
    for _, off in ipairs(offsets) do
        _tp(mobHRP.CFrame * off)
        task.wait(0.1)
    end
end

-- Kill Sea Beast (vai alto para não ser atingido)
local function killSeaMob(mob, weaponName)
    if not mob then return end
    local mobHRP = mob:FindFirstChild("HumanoidRootPart")
    if not mobHRP then return end

    if not mob:GetAttribute("Locked") then
        mob:SetAttribute("Locked", mobHRP.CFrame)
    end
    PosMon = mob:GetAttribute("Locked").Position
    _B = true
    BringEnemy()
    equipWeapon(weaponName)

    local tool = getChar() and getChar():FindFirstChildOfClass("Tool")
    if tool and tool.ToolTip ~= "Blox Fruit" then
        _tp(mobHRP.CFrame * CFrame.new(0, 50, 8))
        task.wait(0.85)
        _tp(mobHRP.CFrame * CFrame.new(0, 400, 0))
        task.wait(1)
    else
        _tp(mobHRP.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(0, math.rad(90), 0))
    end
end

-- ═══════════════════════════════════════════════
-- HOOK FUNCTIONS (anti-detecção e anti-morte)
-- ═══════════════════════════════════════════════
local function applyHooks()
    -- Silencia error e warn
    pcall(hookfunction, error, function() end)
    pcall(hookfunction, warn,  function() end)

    -- Hook de morte (evita tela de morte)
    pcall(function()
        hookfunction(
            require(RS.Effect.Container.Death),
            function() end
        )
    end)

    -- Hook de GuideModule (evita que NPCs de quest mudem)
    pcall(function()
        hookfunction(
            require(RS:WaitForChild("GuideModule")).ChangeDisplayedNPC,
            function() end
        )
    end)
end

-- ═══════════════════════════════════════════════
-- FULL BRIGHT (otimização de visibilidade)
-- ═══════════════════════════════════════════════
local function applyFullBright()
    pcall(function()
        local L = game:GetService("Lighting")
        L.Ambient             = Color3.new(0.695, 0.695, 0.695)
        L.ColorShift_Bottom   = Color3.new(0.695, 0.695, 0.695)
        L.ColorShift_Top      = Color3.new(0.695, 0.695, 0.695)
        L.Brightness          = 2
        L.FogEnd              = 1e10
        -- Remove Foam do mundo
        local foam = workspace:FindFirstChild("_WorldOrigin")
        if foam then
            local f = foam:FindFirstChild("Foam;")
            if f then f:Destroy() end
        end
        -- Remove Rocks
        local rocks = workspace:FindFirstChild("Rocks")
        if rocks then rocks:Destroy() end
    end)
end

-- ═══════════════════════════════════════════════
-- API PÚBLICA
-- ═══════════════════════════════════════════════

-- ─── TEAM ──────────────────────────────────────
function BF.SetTeam(team)
    invoke("SetTeam", team or "Marines")
end

-- ─── AUTO QUEST ────────────────────────────────
function BF.SetAutoQuest(on)
    stopThread("AutoQuest")
    if not on then return end
    startThread("AutoQuest", function()
        while true do
            local q = getBestQuest()
            if q then
                -- Vai até o recruiter
                _tp(q.cfNPC)
                task.wait(0.5)
                -- Aceita quest via CommF_
                invoke("StartQuest", q.questKey)
                task.wait(0.3)
            end
            task.wait(4)
        end
    end)
end

-- ─── AUTO FARM ─────────────────────────────────
function BF.SetAutoFarm(on, weaponName)
    stopThread("AutoFarm")
    _B = on
    if not on then _B = false return end

    startThread("AutoFarm", function()
        while true do
            if not isAlive() then task.wait(1) continue end

            local q = getBestQuest()
            if not q then task.wait(2) continue end

            -- Procura mob na pasta Enemies (eficiente)
            local targetMob = nil
            for _, mob in ipairs(Enemies:GetChildren()) do
                if mob.Name == q.mob then
                    local hm = mob:FindFirstChildOfClass("Humanoid")
                    if hm and hm.Health > 0 then
                        targetMob = mob
                        break
                    end
                end
            end

            if targetMob then
                killMob(targetMob, weaponName or _G.SelectWeapon)
                -- Usa skill Z se for fruta
                local tool = getChar() and getChar():FindFirstChildOfClass("Tool")
                if tool and tool.ToolTip == "Blox Fruit" then
                    task.wait(0.1)
                    useSkill("Z")
                    task.wait(0.1)
                    useSkill("X")
                end
            else
                -- Nenhum mob encontrado: vai até posição conhecida
                if q.cfMob then _tp(q.cfMob) end
                task.wait(1.5)
            end

            task.wait(0.1)
        end
    end)
end

-- ─── BRING MOB ─────────────────────────────────
function BF.SetBringMob(on)
    _B = on
    if not on then
        -- Restaura walkspeeds
        for _, mob in ipairs(Enemies:GetChildren()) do
            local hm = mob:FindFirstChildOfClass("Humanoid")
            if hm then
                hm.WalkSpeed = 14
                hm.JumpPower = 50
            end
        end
    end
end

-- ─── AUTO BOSS ─────────────────────────────────
function BF.SetAutoBoss(on, bossName, weaponName)
    stopThread("AutoBoss")
    if not on or not bossName or bossName == "" then return end

    startThread("AutoBoss", function()
        while true do
            if not isAlive() then task.wait(1) continue end

            -- Busca boss em workspace (bosses ficam fora de Enemies às vezes)
            local boss = nil
            for _, v in ipairs(workspace:GetChildren()) do
                if v:IsA("Model") and v.Name == bossName then
                    local hm = v:FindFirstChildOfClass("Humanoid")
                    if hm and hm.Health > 0 then boss = v break end
                end
            end
            -- Também tenta em Enemies
            if not boss then
                boss = Enemies:FindFirstChild(bossName)
            end

            if boss then
                killMobRandom(boss, weaponName or _G.SelectWeapon)
            end

            task.wait(0.2)
        end
    end)
end

-- ─── AUTO HAKI (Armamento) ─────────────────────
function BF.SetAutoHaki(on)
    stopThread("AutoHaki")
    if not on then return end
    startThread("AutoHaki", function()
        while true do
            pcall(function()
                -- Haki via CommE (padrão mais atual do BF)
                fire("Haki", true)
            end)
            task.wait(12)
        end
    end)
end

-- ─── AUTO OBSERVATION (Ken Haki) ───────────────
function BF.SetAutoKen(on)
    stopThread("AutoKen")
    if not on then return end
    startThread("AutoKen", function()
        while true do
            pcall(function()
                local c = getChar()
                local hasKen = c and CollectionService:HasTag(c, "Ken")
                if not hasKen then
                    fire("Ken", true)
                end
            end)
            task.wait(0.2)
        end
    end)
end

-- ─── AUTO STATS ────────────────────────────────
-- Usa CommF_:InvokeServer("AddPoint", stat, amount) — padrão real do BF
function BF.SetAutoStats(on, stat, amount)
    stopThread("AutoStats")
    if not on then return end
    stat   = stat   or "Melee"
    amount = amount or 1
    startThread("AutoStats", function()
        while true do
            pcall(function()
                if plr.Data.Points.Value ~= 0 then
                    invoke("AddPoint", stat, amount)
                end
            end)
            task.wait(0.8)
        end
    end)
end

-- ─── KILL AURA ─────────────────────────────────
function BF.SetKillAura(on, radius, weaponName)
    stopThread("KillAura")
    if not on then _B = false return end
    radius = radius or 40
    startThread("KillAura", function()
        while true do
            if not isAlive() then task.wait(1) continue end
            local hrp = getHRP()
            if not hrp then task.wait(0.5) continue end

            for _, mob in ipairs(Enemies:GetChildren()) do
                local hm  = mob:FindFirstChildOfClass("Humanoid")
                local pp  = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
                if hm and hm.Health > 0 and pp then
                    if (hrp.Position - pp.Position).Magnitude <= radius then
                        killMob(mob, weaponName or _G.SelectWeapon)
                        task.wait(0.08)
                        break -- um por tick
                    end
                end
            end
            task.wait(0.08)
        end
    end)
end

-- ─── AUTO RAID ─────────────────────────────────
function BF.SetAutoRaid(on, weaponName)
    stopThread("AutoRaid")
    if not on then return end
    startThread("AutoRaid", function()
        while true do
            if not isAlive() then task.wait(1) continue end
            for _, mob in ipairs(Enemies:GetChildren()) do
                local hm = mob:FindFirstChildOfClass("Humanoid")
                if hm and hm.Health > 0 then
                    killMob(mob, weaponName or _G.SelectWeapon)
                    task.wait(0.1)
                    break
                end
            end
            task.wait(0.12)
        end
    end)
end

-- ─── SEA BEAST / LEVIATHAN ─────────────────────
function BF.SetSeaBeast(on, weaponName)
    stopThread("SeaBeast")
    if not on then return end
    local targets = {"Sea Beast","Leviathan","Terrorshark","Sea Monster","Island Empress"}
    startThread("SeaBeast", function()
        while true do
            if not isAlive() then task.wait(1) continue end
            for _, name in ipairs(targets) do
                local mob = workspace:FindFirstChild(name)
                if not mob then mob = Enemies:FindFirstChild(name) end
                if mob then
                    killSeaMob(mob, weaponName or _G.SelectWeapon)
                    break
                end
            end
            task.wait(0.5)
        end
    end)
end

-- ─── TERROR SHARK ESP ──────────────────────────
function BF.SetTerrorSharkESP(on)
    stopThread("TerrorESP")
    if not on then
        for _, v in ipairs(workspace:GetDescendants()) do
            local e = v:FindFirstChild("ZH_ESP")
            if e then e:Destroy() end
        end
        return
    end
    startThread("TerrorESP", function()
        while true do
            for _, v in ipairs(workspace:GetChildren()) do
                if v:IsA("Model") and (v.Name:lower():find("terrorshark") or v.Name == "Terror Shark") then
                    if not v:FindFirstChild("ZH_ESP") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "ZH_ESP"
                        hl.FillColor = Color3.fromRGB(255,50,50)
                        hl.OutlineColor = Color3.fromRGB(255,255,255)
                        hl.FillTransparency = 0.5
                        hl.Parent = v
                    end
                end
            end
            task.wait(2)
        end
    end)
end

-- ─── AUTO RACE V4 ──────────────────────────────
function BF.SetAutoRaceV4(on, race)
    stopThread("AutoRaceV4")
    if not on then return end
    startThread("AutoRaceV4", function()
        while true do
            pcall(function() invoke("ActivateRace", race or "Human") end)
            task.wait(6)
        end
    end)
end

-- ─── FRUIT SNIPER ──────────────────────────────
function BF.SetFruitSniper(on, fruitName)
    stopThread("FruitSniper")
    if not on or not fruitName then return end
    startThread("FruitSniper", function()
        while true do
            for _, v in ipairs(workspace:GetChildren()) do
                if v:IsA("Model") and v.Name:lower():find(fruitName:lower(), 1, true) then
                    local pp = v.PrimaryPart or v:FindFirstChild("HumanoidRootPart")
                    if pp then
                        _tp(pp.CFrame * CFrame.new(0,2,0))
                        task.wait(0.3)
                    end
                end
            end
            task.wait(1.5)
        end
    end)
end

-- ─── TELEPORT (com ou sem tween) ───────────────
function BF.Teleport(cf, useTween, tweenSpeed)
    local hrp = getHRP()
    if not hrp then return end
    if useTween then
        local t = TweenService:Create(hrp,
            TweenInfo.new(tweenSpeed or 1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { CFrame = cf }
        )
        t:Play()
    else
        hrp.CFrame = cf
    end
end

-- ─── USE SKILL ─────────────────────────────────
function BF.UseSkill(weaponType, key)
    equipByTip(weaponType)
    task.wait(0.1)
    useSkill(key)
end

-- ─── MASTERY FARM ──────────────────────────────
-- Usa melee até mob ter pouca HP, depois frutas
function BF.SetMasteryFarm(on, masteryType, healthThreshold)
    stopThread("MasteryFarm")
    if not on then return end
    healthThreshold = healthThreshold or 500

    startThread("MasteryFarm", function()
        while true do
            if not isAlive() then task.wait(1) continue end
            local q = getBestQuest()
            if not q then task.wait(2) continue end

            for _, mob in ipairs(Enemies:GetChildren()) do
                if mob.Name == q.mob then
                    local hm = mob:FindFirstChildOfClass("Humanoid")
                    local pp = mob:FindFirstChild("HumanoidRootPart")
                    if hm and hm.Health > 0 and pp then
                        if hm.Health <= healthThreshold then
                            -- Usa skills da fruta/gun/sword
                            if masteryType == "Blox Fruit" or masteryType == "Fruit" then
                                equipByTip("Blox Fruit")
                                _tp(pp.CFrame * CFrame.new(0, 10, 0))
                                task.wait(0.1)
                                useSkill("Z")
                                useSkill("X")
                            elseif masteryType == "Gun" then
                                equipByTip("Gun")
                                _tp(pp.CFrame * CFrame.new(0, 35, 8))
                                task.wait(0.1)
                                useSkill("Z")
                                useSkill("X")
                            elseif masteryType == "Sword" then
                                equipByTip("Sword")
                                _tp(pp.CFrame * CFrame.new(0, 30, 0))
                            end
                        else
                            equipByTip("Melee")
                            _tp(pp.CFrame * CFrame.new(0, 30, 0))
                        end
                        break
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

-- ─── LIMPEZA GERAL ─────────────────────────────
function BF.Cleanup()
    _B = false
    for name in pairs(Threads) do stopThread(name) end
    -- Remove ESPs
    for _, v in ipairs(workspace:GetDescendants()) do
        local e = v:FindFirstChild("ZH_ESP")
        if e then e:Destroy() end
    end
end

-- ─── INICIALIZAÇÃO ─────────────────────────────
function BF.Init()
    loadRemotes()
    applyHooks()
    applyFullBright()
    _G.MobHeight    = _G.MobHeight    or 20
    _G.SelectWeapon = _G.SelectWeapon or nil
end

return BF
