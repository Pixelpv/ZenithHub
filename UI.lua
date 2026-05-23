--[[
    ZenithHub — UI.lua (Merged & Optimized)
    Arquitetura modular (UI.Init) + todas as tabs do ZenithHub_GUI
    Tabs: Main Farm | Bosses | Sea Events | Fruits | Items/Quest |
          Fighting | Raids | Races/V4 | Dragon/Dojo | Gun | Player |
          Teleports | Visuals | Server | Settings
]]

local UI = {}

-- ════════════════════════════════════════════
-- DEPENDÊNCIAS (injetadas via UI.Init)
-- ════════════════════════════════════════════
local BloxFruits, Universal, Config, cfg

-- ════════════════════════════════════════════
-- SERVIÇOS
-- ════════════════════════════════════════════
local Players        = game:GetService("Players")
local RS             = game:GetService("ReplicatedStorage")
local TweenService   = game:GetService("TweenService")
local RunService     = game:GetService("RunService")
local UIS            = game:GetService("UserInputService")
local TeleportSvc    = game:GetService("TeleportService")
local Lighting       = game:GetService("Lighting")
local plr            = Players.LocalPlayer

-- Remotes (carregados após a janela subir)
local CommF_, CommE
local function invoke(...) pcall(CommF_.InvokeServer, CommF_, ...) end
local function fire(...)   pcall(CommE.FireServer, CommE, ...) end

-- ════════════════════════════════════════════
-- FLUENT UI
-- ════════════════════════════════════════════
local Fluent, SaveManager, InterfaceManager, Window

local function loadFluent()
    local ok, err = pcall(function()
        Fluent           = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
        SaveManager      = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
        InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
    end)
    if not ok then error("[ZenithHub] Falha ao carregar Fluent UI: " .. tostring(err)) end
end

-- ════════════════════════════════════════════
-- HELPER: NOTIFY
-- ════════════════════════════════════════════
local function notify(title, content, duration, style)
    if not Fluent then return end
    pcall(Fluent.Notify, Fluent, {
        Title    = title or "Zenith Hub",
        Content  = content or "",
        Duration = duration or 3,
        Style    = style or "Info",
    })
end

-- ════════════════════════════════════════════
-- SPLASH SCREEN
-- ════════════════════════════════════════════
local function showSplash()
    local ok, err = pcall(function()
        local playerGui = plr:WaitForChild("PlayerGui")
        local splashGui = Instance.new("ScreenGui")
        splashGui.Name = "ZenithSplash"
        splashGui.IgnoreGuiInset = true
        splashGui.ResetOnSpawn = false
        splashGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        splashGui.Parent = playerGui

        local bg = Instance.new("Frame")
        bg.Size = UDim2.fromScale(1, 1)
        bg.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
        bg.BackgroundTransparency = 1
        bg.Parent = splashGui

        local blur = Instance.new("BlurEffect")
        blur.Size = 0
        blur.Parent = Lighting

        local function tween(obj, t, props)
            TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
        end

        tween(bg, 0.5, { BackgroundTransparency = 0 })
        tween(blur, 0.5, { Size = 16 })
        task.wait(0.5)

        local container = Instance.new("Frame")
        container.AnchorPoint = Vector2.new(0.5, 0.5)
        container.Position = UDim2.fromScale(0.5, 0.5)
        container.Size = UDim2.fromOffset(420, 220)
        container.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
        container.BackgroundTransparency = 1
        container.BorderSizePixel = 0
        container.Parent = bg

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 16)
        corner.Parent = container

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(80, 120, 255)
        stroke.Thickness = 1.5
        stroke.Transparency = 1
        stroke.Parent = container

        TweenService:Create(container, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
        tween(stroke, 0.6, { Transparency = 0 })

        local function makeLabel(cls, pos, size, text, font, textSize, color)
            local lbl = Instance.new(cls)
            lbl.AnchorPoint = Vector2.new(0.5, 0)
            lbl.Position = UDim2.fromOffset(210, pos)
            lbl.Size = UDim2.fromOffset(size, 34)
            lbl.BackgroundTransparency = 1
            if cls == "TextLabel" then
                lbl.Text = text
                lbl.Font = font
                lbl.TextSize = textSize
                lbl.TextColor3 = color
                lbl.TextTransparency = 1
            end
            lbl.Parent = container
            return lbl
        end

        local logo = Instance.new("ImageLabel")
        logo.AnchorPoint = Vector2.new(0.5, 0)
        logo.Position = UDim2.fromOffset(210, 24)
        logo.Size = UDim2.fromOffset(64, 64)
        logo.BackgroundTransparency = 1
        logo.Image = "rbxassetid://7733960981"
        logo.ImageTransparency = 1
        logo.Parent = container

        local titleLabel = makeLabel("TextLabel", 100, 400, "ZENITH HUB", Enum.Font.GothamBold, 28, Color3.fromRGB(255, 255, 255))
        local subLabel   = makeLabel("TextLabel", 140, 400, "Blox Fruits Edition • Loading...", Enum.Font.Gotham, 14, Color3.fromRGB(150, 150, 200))

        local barBg = Instance.new("Frame")
        barBg.AnchorPoint = Vector2.new(0.5, 0)
        barBg.Position = UDim2.fromOffset(210, 176)
        barBg.Size = UDim2.fromOffset(340, 4)
        barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        barBg.BackgroundTransparency = 1
        barBg.BorderSizePixel = 0
        barBg.Parent = container
        Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

        local barFill = Instance.new("Frame")
        barFill.Size = UDim2.fromScale(0, 1)
        barFill.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
        barFill.BorderSizePixel = 0
        barFill.Parent = barBg
        Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

        task.wait(0.3)
        for _, item in ipairs({ logo, titleLabel, subLabel }) do
            local prop = item:IsA("ImageLabel") and { ImageTransparency = 0 } or { TextTransparency = 0 }
            TweenService:Create(item, TweenInfo.new(0.4), prop):Play()
        end
        tween(barBg, 0.4, { BackgroundTransparency = 0 })
        task.wait(0.4)
        TweenService:Create(barFill, TweenInfo.new(1.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.fromScale(1, 1) }):Play()
        task.wait(2.0)
        tween(bg, 0.5, { BackgroundTransparency = 1 })
        tween(blur, 0.5, { Size = 0 })
        task.wait(0.6)
        splashGui:Destroy()
        blur:Destroy()
    end)
    if not ok then warn("[ZenithHub] Splash error: " .. tostring(err)) end
end

-- ════════════════════════════════════════════
-- HELPERS DE MUNDO
-- ════════════════════════════════════════════
local function getWorldIndex()
    local pid = game.PlaceId
    if pid == 2753915549 or pid == 85211729168715 then return 1 end
    if pid == 4442272183 or pid == 79091703265657 then return 2 end
    return 3
end

local WORLD = getWorldIndex()
local IS_W1 = WORLD == 1
local IS_W2 = WORLD == 2
local IS_W3 = WORLD == 3

-- ════════════════════════════════════════════
-- BUILD DA INTERFACE PRINCIPAL
-- ════════════════════════════════════════════
local function buildUI()
    Window = Fluent:CreateWindow({
        Title       = "Zenith Hub",
        SubTitle    = "Blox Fruits Edition",
        TabWidth    = 160,
        Size        = UDim2.fromOffset(580, 460),
        Acrylic     = true,
        Theme       = cfg.Theme or "Dark",
        MinimizeKey = Enum.KeyCode.RightControl,
    })

    local Tabs = {
        MainFarm  = Window:AddTab({ Title = "Main Farm",   Icon = "home"       }),
        Bosses    = Window:AddTab({ Title = "Bosses",      Icon = "skull"      }),
        SeaEvents = Window:AddTab({ Title = "Sea Events",  Icon = "waves"      }),
        Fruits    = Window:AddTab({ Title = "Fruits",      Icon = "apple"      }),
        Items     = Window:AddTab({ Title = "Items/Quest", Icon = "scroll"     }),
        Fighting  = Window:AddTab({ Title = "Fighting",    Icon = "flame"      }),
        Raids     = Window:AddTab({ Title = "Raids",       Icon = "sword"      }),
        Races     = Window:AddTab({ Title = "Races / V4",  Icon = "zap"        }),
        Dragon    = Window:AddTab({ Title = "Dragon/Dojo", Icon = "star"       }),
        Gun       = Window:AddTab({ Title = "Gun System",  Icon = "crosshair"  }),
        Player    = Window:AddTab({ Title = "Player",      Icon = "user"       }),
        Teleports = Window:AddTab({ Title = "Teleports",   Icon = "map"        }),
        Visuals   = Window:AddTab({ Title = "Visuals",     Icon = "eye"        }),
        Server    = Window:AddTab({ Title = "Server",      Icon = "globe"      }),
        Settings  = Window:AddTab({ Title = "Settings",    Icon = "settings"   }),
    }

    -- Carrega remotes agora que o ambiente está pronto
    CommF_ = RS:WaitForChild("Remotes"):WaitForChild("CommF_")
    CommE  = RS:WaitForChild("Remotes"):WaitForChild("CommE")

    -- ══════════════════════════════════════════
    -- TAB 1 — MAIN FARM
    -- ══════════════════════════════════════════
    do
        local T = Tabs.MainFarm

        T:AddSection("Auto Farm")
        T:AddToggle("AutoFarmLevel", { Title = "Auto Farm Level", Default = false,
            Callback = function(v) _G.AutoFarmLevel = v; BloxFruits.SetAutoFarm(v) end })
        T:AddToggle("AutoQuest", { Title = "Auto Quest", Default = false,
            Callback = function(v) _G.AutoQuest = v end })
        T:AddToggle("SmartQuest", { Title = "Smart Quest (por nível)", Default = false,
            Callback = function(v) _G.SmartQuest = v end })
        T:AddToggle("AutoNextIsland", { Title = "Auto Next Island", Default = false,
            Callback = function(v) _G.AutoNextIsland = v end })

        T:AddSection("Stats & Haki")
        local SelectedStat = cfg.StatPriority or "Melee"
        T:AddDropdown("SelectStat", { Title = "Stat Priority",
            Values = { "Melee", "Defense", "Sword", "Gun", "Demon Fruit" },
            Default = SelectedStat,
            Callback = function(v) SelectedStat = v; cfg.StatPriority = v end })
        T:AddToggle("AutoStats", { Title = "Auto Stats", Default = cfg.AutoStats,
            Callback = function(v) cfg.AutoStats = v; BloxFruits.SetAutoStats(v, SelectedStat) end })
        T:AddToggle("AutoHaki", { Title = "Auto Haki (Buso/Armamento)", Default = cfg.AutoHaki,
            Callback = function(v) cfg.AutoHaki = v; BloxFruits.SetAutoHaki(v) end })
        T:AddToggle("AutoObservation", { Title = "Auto Observation (Ken)", Default = false,
            Callback = function(v) BloxFruits.SetAutoKen(v) end })

        T:AddSection("Combat")
        T:AddToggle("AutoEquipWeapon", { Title = "Auto Equip Best Weapon", Default = false,
            Callback = function(v) if v then BloxFruits.EquipBestWeapon("Sword") end end })

        T:AddSection("Skills")
        for _, key in ipairs({ "Z", "X", "C", "V", "F" }) do
            local key = key
            T:AddToggle("Skill" .. key, { Title = "Auto Skill " .. key, Default = false,
                Callback = function(v)
                    _G.FruitSkills = _G.FruitSkills or {}
                    _G.FruitSkills[key] = v
                end })
        end

        T:AddSection("Farm Mode")
        T:AddToggle("FastAttack", { Title = "Fast Attack", Default = cfg.FastAttack,
            Callback = function(v) cfg.FastAttack = v; BloxFruits.SetFastAttack(v) end })
        T:AddToggle("BringMobs", { Title = "Bring Mobs", Default = cfg.BringMob,
            Callback = function(v) cfg.BringMob = v; BloxFruits.SetBringMobs(v) end })
        T:AddToggle("MagnetFarm", { Title = "Magnet Farm", Default = false,
            Callback = function(v) _G.MagnetFarm = v end })
        T:AddSlider("TweenSpeed", { Title = "Tween Farm Speed", Min = 50, Max = 1000, Default = 300, Rounding = 0,
            Callback = function(v)
                getgenv().TweenSpeedFar  = v
                getgenv().TweenSpeedNear = v * 3
            end })
        T:AddToggle("SafeFarm", { Title = "Safe Farm (anti-kick)", Default = false,
            Callback = function(v) _G.SafeFarm = v end })
        T:AddSlider("MobHeight", { Title = "Mob Height", Min = 0, Max = 100, Default = 20, Rounding = 0,
            Callback = function(v)
                _G.MobHeight = v
                if BloxFruits.State then BloxFruits.State.MobHeight = v end
            end })
    end

    -- ══════════════════════════════════════════
    -- TAB 2 — BOSSES
    -- ══════════════════════════════════════════
    do
        local T = Tabs.Bosses
        local bossList = IS_W1 and {
            "The Gorilla King","Bobby","The Saw","Yeti","Mob Leader","Vice Admiral",
            "Saber Expert","Warden","Chief Warden","Swan","Magma Admiral",
            "Fishman Lord","Wysper","Thunder God","Cyborg","Ice Admiral","Greybeard"
        } or IS_W2 and {
            "Diamond","Jeremy","Fajita","Don Swan","Smoke Admiral",
            "Awakened Ice Admiral","Tide Keeper","Darkbeard","Cursed Captain","Order"
        } or {
            "Stone","Hydra Leader","Kilo Admiral","Captain Elephant",
            "Beautiful Pirate","Cake Queen","Longma","Soul Reaper",
            "Rip_Indra","Cake King","Tyrant of the Skies","Leviathan"
        }

        T:AddSection("Boss Farm")
        local SelectedBoss = bossList[1]
        T:AddDropdown("SelectBoss", { Title = "Select Boss", Values = bossList, Default = bossList[1],
            Callback = function(v) SelectedBoss = v; _G.FindBoss = v end })
        T:AddToggle("AutoBossFarm", { Title = "Auto Boss Farm", Default = false,
            Callback = function(v) BloxFruits.SetAutoBoss(v, SelectedBoss) end })

        T:AddSection("Bosses Especiais")
        local specials = {
            { id="AutoEliteHunter",  title="Auto Elite Hunter",        fn=function(v) _G.FarmEliteHunt=v; _G.StartFarm=v end },
            { id="AutoCakePrince",   title="Auto Cake Prince",         fn=function(v) _G.Auto_Cake_Prince=v; _G.StartFarm=v end },
            { id="AutoRipIndra",     title="Auto Rip Indra",           fn=function(v) _G.AutoRipIngay=v; _G.StartFarm=v end },
            { id="AutoSoulReaper",   title="Auto Soul Reaper",         fn=function(v) _G.AutoEcBoss=v; _G.StartFarm=v end },
            { id="AutoTyrant",       title="Auto Tyrant of the Skies", fn=function(v) _G.AutoTyrant=v; _G.StartFarm=v end },
            { id="AutoDarkbeard",    title="Auto Darkbeard",           fn=function(v)
                _G.DangerLV=v; BloxFruits.SetAutoBoss(v, v and "Darkbeard" or nil) end },
            { id="AutoSaberExpert",  title="Auto Saber Expert",        fn=function(v)
                _G.AutoSaber=v; BloxFruits.SetAutoBoss(v, v and "Saber Expert" or nil) end },
            { id="AutoDoughKing",    title="Auto Dough King",          fn=function(v) _G.Doughv2=v; _G.StartFarm=v end },
        }
        for _, s in ipairs(specials) do
            local s = s
            T:AddToggle(s.id, { Title = s.title, Default = false, Callback = s.fn })
        end
    end

    -- ══════════════════════════════════════════
    -- TAB 3 — SEA EVENTS
    -- ══════════════════════════════════════════
    do
        local T = Tabs.SeaEvents
        T:AddSection("Sea Beasts")
        T:AddToggle("AutoSeaBeast",    { Title="Auto Sea Beast",    Default=false, Callback=function(v) BloxFruits.SetAutoSeaBeast(v) end })
        T:AddToggle("AutoTerrorShark", { Title="Auto Terror Shark", Default=false, Callback=function(v) BloxFruits.SetAutoTerrorShark(v) end })
        T:AddToggle("AutoLeviathan",   { Title="Auto Leviathan",    Default=false, Callback=function(v) BloxFruits.SetAutoLeviathan(v) end })

        T:AddSection("Boats & Crews")
        T:AddToggle("AutoFishBoat",      { Title="Auto Fish Boat",      Default=false, Callback=function(v) BloxFruits.SetAutoFishBoat(v) end })
        T:AddToggle("AutoPirateBrigade", { Title="Auto Pirate Brigade",  Default=false, Callback=function(v) BloxFruits.SetAutoPirateBrigade(v) end })
        T:AddToggle("AutoPiranha",       { Title="Auto Piranha",         Default=false, Callback=function(v) BloxFruits.SetAutoPiranha(v) end })
        T:AddToggle("AutoHauntedCrew",   { Title="Auto Haunted Crew",    Default=false, Callback=function(v) BloxFruits.SetAutoHauntedCrew(v) end })

        T:AddSection("Eventos Especiais")
        T:AddToggle("AutoPrehistoricIsland", { Title="Auto Prehistoric Island", Default=false,
            Callback=function(v) _G.Prehis_Find=v; _G.StartFarm=v end })
        T:AddToggle("AutoFrozenDimension",   { Title="Auto Frozen Dimension",   Default=false,
            Callback=function(v) _G.FrozenTP=v; _G.StartFarm=v end })
        T:AddToggle("AutoVolcanoEvent",      { Title="Auto Volcano Event",       Default=false,
            Callback=function(v) _G.FarmBlazeEM=v; _G.StartFarm=v end })
    end

    -- ══════════════════════════════════════════
    -- TAB 4 — FRUITS
    -- ══════════════════════════════════════════
    do
        local T = Tabs.Fruits
        local rareFruits = { "Kitsune-Kitsune","Dragon-Dragon","Leopard-Leopard","Yeti-Yeti","T-Rex-T-Rex","Gas-Gas","Spirit-Spirit" }
        local allFruits  = {
            "Rocket-Rocket","Spin-Spin","Chop-Chop","Spring-Spring","Bomb-Bomb","Smoke-Smoke","Spike-Spike","Flame-Flame",
            "Falcon-Falcon","Ice-Ice","Sand-Sand","Dark-Dark","Diamond-Diamond","Light-Light","Rubber-Rubber","Barrier-Barrier",
            "Ghost-Ghost","Magma-Magma","Quake-Quake","Buddha-Buddha","Love-Love","Spider-Spider","Sound-Sound","Phoenix-Phoenix",
            "Portal-Portal","Rumble-Rumble","Pain-Pain","Blizzard-Blizzard","Gravity-Gravity","Mammoth-Mammoth","T-Rex-T-Rex",
            "Dough-Dough","Shadow-Shadow","Venom-Venom","Control-Control","Spirit-Spirit","Dragon-Dragon","Leopard-Leopard",
            "Kitsune-Kitsune","Gas-Gas","Yeti-Yeti",
        }

        T:AddSection("Fruit Sniper")
        T:AddToggle("AutoFruitSniper",  { Title="Auto Fruit Sniper",  Default=false, Callback=function(v) BloxFruits.SetFruitSniper(v, rareFruits) end })
        T:AddToggle("AutoFruitCollect", { Title="Auto Fruit Collect", Default=false, Callback=function(v) BloxFruits.SetFruitCollect(v) end })

        T:AddSection("Store / Drop")
        T:AddButton({ Title="Store Fruits (Agora)", Callback=function() BloxFruits.StoreFruits() end })
        T:AddButton({ Title="Drop Fruits (Agora)",  Callback=function() BloxFruits.DropFruits() end })

        -- Helper para loops de store/drop
        local function makeAutoLoop(key, fn)
            return function(v)
                _G[key] = v
                if v then
                    task.spawn(function()
                        while _G[key] do fn(); task.wait(5) end
                    end)
                end
            end
        end
        T:AddToggle("AutoStoreFruits", { Title="Auto Store Fruits", Default=false,
            Callback = makeAutoLoop("AutoStoreFruits", BloxFruits.StoreFruits) })
        T:AddToggle("AutoDropFruits",  { Title="Auto Drop Fruits",  Default=false,
            Callback = makeAutoLoop("AutoDropFruits", BloxFruits.DropFruits) })

        T:AddSection("ESP & Notify")
        T:AddToggle("FruitESP",        { Title="Fruit ESP",         Default=false, Callback=function(v) BloxFruits.SetFruitESP(v) end })
        T:AddToggle("RareFruitNotify", { Title="Rare Fruit Notify", Default=false, Callback=function(v) BloxFruits.SetRareFruitNotify(v) end })

        T:AddSection("Rare Detect")
        T:AddParagraph({ Title="Frutas Raras Monitoradas",
            Content="🔮 Kitsune  •  🐉 Dragon  •  🐆 Leopard\n🧊 Yeti  •  🦖 T-Rex  •  💨 Gas  •  👻 Spirit" })

        T:AddSection("Auto Buy")
        T:AddDropdown("SelectFruitBuy", { Title="Fruit para Comprar", Values=allFruits, Default="Dough-Dough",
            Callback=function(v) getgenv().SelectFruit=v; BloxFruits.State.SelectedFruit=v end })
        T:AddToggle("AutoBuyRandomFruit", { Title="Auto Buy Random Fruit", Default=false,
            Callback=function(v) getgenv().AutoBuyFruitSniper=v; BloxFruits.SetAutoBuyFruit(v) end })
        T:AddToggle("AutoFruitMastery",   { Title="Auto Fruit Mastery",    Default=false,
            Callback=function(v) BloxFruits.SetAutoFruitMastery(v) end })
    end

    -- ══════════════════════════════════════════
    -- TAB 5 — ITEMS / QUEST
    -- ══════════════════════════════════════════
    do
        local T = Tabs.Items

        T:AddSection("Quest")
        T:AddToggle("AutoQuestItems", { Title="Auto Quest",      Default=false, Callback=function(v) _G.AutoQuest=v end })
        T:AddToggle("QuestByLevel",   { Title="Quest By Level",  Default=false, Callback=function(v) _G.Level=v; _G.StartFarm=v end })
        T:AddToggle("AutoNextQuest",  { Title="Auto Next Quest", Default=false, Callback=function(v) _G.AutoNextIsland=v end })
        T:AddButton({ Title="Quest Teleport (NPC atual)", Callback=function()
            local qd = BloxFruits and BloxFruits.State and BloxFruits.State.CurrentQuest
            if qd and qd.QuestCF then
                plr.Character.HumanoidRootPart.CFrame = qd.QuestCF
            end
        end })

        T:AddSection("Swords Quest")
        local swords = {
            { name="Saber Quest",   fn=function() _G.AutoSaber=true; _G.StartFarm=true end },
            { name="Pole V1",       fn=function() invoke("LoadItem","Pole (1st Form)") end },
            { name="Pole V2",       fn=function() invoke("LoadItem","Pole (2nd Form)") end },
            { name="Rengoku",       fn=function() _G.LongsWord=true; _G.StartFarm=true end },
            { name="TTK",           fn=function() _G.TwinHook=true;  _G.StartFarm=true end },
            { name="CDK",           fn=function() _G.CDK=true;       _G.StartFarm=true end },
            { name="Yama",          fn=function() _G.Auto_Yama=true; _G.StartFarm=true end },
            { name="Tushita",       fn=function() _G.Auto_Tushita=true; _G.StartFarm=true end },
            { name="Shark Anchor",  fn=function() _G.AutoSerpentBow=true; _G.StartFarm=true end },
            { name="Soul Guitar",   fn=function() _G.Auto_Soul_Guitar=true; _G.StartFarm=true end },
            { name="Dark Blade V3", fn=function() _G.DarkBladev3=true; _G.StartFarm=true end },
        }
        for _, sw in ipairs(swords) do
            local sw = sw
            T:AddButton({ Title=sw.name, Callback=sw.fn })
        end
    end

    -- ══════════════════════════════════════════
    -- TAB 6 — FIGHTING STYLES
    -- ══════════════════════════════════════════
    do
        local T = Tabs.Fighting
        T:AddSection("Fighting Styles Quest")
        T:AddParagraph({ Title="Nota", Content="Clique no toggle para iniciar o quest automático do estilo de combate." })

        local styles = {
            { id="Superhuman",      flag="Auto_SuperHuman"      },
            { id="DeathStep",       flag="AutoDeathStep"        },
            { id="SharkmanKarate",  flag="Auto_SharkMan_Karate" },
            { id="ElectricClaw",    flag="Auto_Electric_Claw"   },
            { id="DragonTalon",     flag="AutoDragonTalon"      },
            { id="Godhuman",        flag="Auto_God_Human"       },
            { id="SanguineArt",     flag="snaguine"             },
        }
        for _, s in ipairs(styles) do
            local s = s
            T:AddToggle("Style_" .. s.id, { Title=s.id:gsub("(%l)(%u)","%1 %2"), Default=false,
                Callback=function(v) _G[s.flag]=v; _G.StartFarm=v end })
        end
    end

    -- ══════════════════════════════════════════
    -- TAB 7 — RAIDS
    -- ══════════════════════════════════════════
    do
        local T = Tabs.Raids
        local chipList = {
            "Flame","Ice","Quake","Light","Dark","String","Rumble",
            "Magma","Human: Buddha","Sand","Bird: Phoenix","Dough",
        }

        T:AddSection("Chip")
        T:AddDropdown("SelectChip", { Title="Select Chip", Values=chipList, Default="Flame",
            Callback=function(v) _G.SelectChip=v; BloxFruits.State.SelectedChip=v end })
        T:AddToggle("AutoBuyChip", { Title="Auto Buy Chip", Default=false,
            Callback=function(v) BloxFruits.SetAutoBuyChip(v, _G.SelectChip or "Flame") end })

        T:AddSection("Raid Farm")
        T:AddToggle("AutoStartRaid",  { Title="Auto Start Raid",    Default=false, Callback=function(v) BloxFruits.SetAutoStartRaid(v) end })
        T:AddToggle("AutoRaidFarm",   { Title="Auto Raid Farm",     Default=false, Callback=function(v) BloxFruits.SetAutoRaidFarm(v) end })
        T:AddToggle("AutoDoughRaid",  { Title="Auto Dough Raid",    Default=false,
            Callback=function(v) _G.Doughv2=v; _G.Raiding=v; _G.StartFarm=v end })
        T:AddToggle("KillAuraRaid",   { Title="Kill Aura Raid",     Default=false, Callback=function(v) _G.AutoRaidCastle=v end })
        T:AddToggle("AutoAwaken",     { Title="Auto Awaken (Fruit)", Default=false, Callback=function(v) BloxFruits.SetAutoAwaken(v) end })
    end

    -- ══════════════════════════════════════════
    -- TAB 8 — RACES / V4
    -- ══════════════════════════════════════════
    do
        local T = Tabs.Races
        T:AddSection("Mirage & Gear")
        T:AddToggle("AutoMirage",   { Title="Auto Mirage Island", Default=false,
            Callback=function(v) _G.FindMirage=v; _G.StartFarm=v end })
        T:AddToggle("AutoBlueGear", { Title="Auto Blue Gear",     Default=false,
            Callback=function(v) _G.TPGEAR=v; _G.StartFarm=v end })

        T:AddSection("Trial")
        T:AddToggle("AutoTrial",         { Title="Auto Trial",         Default=false,
            Callback=function(v) _G.Complete_Trials=v; _G.StartFarm=v end })
        T:AddToggle("AutoPullLever",     { Title="Auto Pull Lever",    Default=false,
            Callback=function(v) _G.TPDoor=v end })
        T:AddToggle("AutoCompleteTrial", { Title="Auto Complete Trial", Default=false,
            Callback=function(v) _G.Complete_Trials=v; _G.StartFarm=v end })

        T:AddSection("Race V4")
        T:AddToggle("AutoRaceV3", { Title="Auto Race V3 (ActivateAbility)", Default=false,
            Callback=function(v) BloxFruits.SetAutoRaceV3(v) end })
        T:AddToggle("AutoRaceV4", { Title="Auto Race V4 (Tecla Y)",         Default=false,
            Callback=function(v) BloxFruits.SetAutoRaceV4(v) end })

        T:AddButton({ Title="Temple Teleport", Callback=function()
            Universal.TeleportTo(Vector3.new(-1648, 1079, 427))
            notify("Temple", "Teleportando para o Templo!", 2)
        end })
    end

    -- ══════════════════════════════════════════
    -- TAB 9 — DRAGON / DOJO
    -- ══════════════════════════════════════════
    do
        local T = Tabs.Dragon
        T:AddSection("Dragon Quests")
        local dragonToggles = {
            { id="AutoDragonEggs",       title="Auto Dragon Eggs",       flag="Collect_Ember"    },
            { id="AutoFireFlowers",      title="Auto Fire Flowers",      flag="AutoFireFlowers"  },
            { id="AutoDragonRelics",     title="Auto Dragon Relics",     flag="Relic123"         },
            { id="AutoDracoTrial",       title="Auto Draco Trial",       flag="UPGDrago"         },
            { id="AutoDragonTalonQuest", title="Auto Dragon Talon Quest", flag="AutoDragonTalon" },
        }
        for _, d in ipairs(dragonToggles) do
            local d = d
            T:AddToggle(d.id, { Title=d.title, Default=false,
                Callback=function(v) _G[d.flag]=v; _G.StartFarm=v end })
        end
    end

    -- ══════════════════════════════════════════
    -- TAB 10 — GUN SYSTEM
    -- ══════════════════════════════════════════
    do
        local T = Tabs.Gun
        T:AddSection("Aiming")
        T:AddToggle("GunAura",   { Title="Gun Aura",   Default=false, Callback=function(v) _G.AimMethod=v end })
        T:AddToggle("AutoAim",   { Title="Auto Aim",   Default=false,
            Callback=function(v) _G.AimMethod=v; _G.ABmethod="Auto Aimbots" end })
        T:AddToggle("SilentAim", { Title="Silent Aim", Default=false,
            Callback=function(v) _G.AimMethod=v; _G.ABmethod="AimBots Skill" end })
        T:AddToggle("AutoShoot", { Title="Auto Shoot", Default=false, Callback=function(v) _G.AimMethod=v end })

        T:AddSection("Aura")
        T:AddToggle("DamageAura", { Title="Damage Aura", Default=false, Callback=function(v) _G.AimMethod=v end })
        T:AddToggle("SniperAura", { Title="Sniper Aura", Default=false, Callback=function(v) _G.AimMethod=v end })
        T:AddSlider("GunRange", { Title="Gun Range", Min=50, Max=2000, Default=500, Rounding=0,
            Callback=function(v) _G.GunRange=v end })
    end

    -- ══════════════════════════════════════════
    -- TAB 11 — PLAYER
    -- ══════════════════════════════════════════
    do
        local T = Tabs.Player
        local flySpeed = 50

        T:AddSection("Movement")
        T:AddSlider("FlySpeed", { Title="Fly Speed", Min=10, Max=500, Default=50, Rounding=0,
            Callback=function(v) flySpeed=v end })

        T:AddToggle("Fly", { Title="Fly", Default=cfg.Fly,
            Callback=function(enabled)
                cfg.Fly = enabled
                local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                if enabled then
                    local bv = Instance.new("BodyVelocity", hrp)
                    bv.Name = "ZenithFly"
                    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                    bv.Velocity = Vector3.new(0, 0, 0)
                    _G.FlyActive = true
                    task.spawn(function()
                        local cam = workspace.CurrentCamera
                        while _G.FlyActive do
                            local vel = Vector3.new(0, 0, 0)
                            if UIS:IsKeyDown(Enum.KeyCode.W)         then vel = vel + cam.CFrame.LookVector  * flySpeed end
                            if UIS:IsKeyDown(Enum.KeyCode.S)         then vel = vel - cam.CFrame.LookVector  * flySpeed end
                            if UIS:IsKeyDown(Enum.KeyCode.A)         then vel = vel - cam.CFrame.RightVector * flySpeed end
                            if UIS:IsKeyDown(Enum.KeyCode.D)         then vel = vel + cam.CFrame.RightVector * flySpeed end
                            if UIS:IsKeyDown(Enum.KeyCode.Space)     then vel = vel + Vector3.new(0,  flySpeed, 0) end
                            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel + Vector3.new(0, -flySpeed, 0) end
                            local bvObj = hrp:FindFirstChild("ZenithFly")
                            if bvObj then bvObj.Velocity = vel end
                            RunService.RenderStepped:Wait()
                        end
                    end)
                else
                    _G.FlyActive = false
                    local bvObj = hrp:FindFirstChild("ZenithFly")
                    if bvObj then bvObj:Destroy() end
                end
            end })

        T:AddSlider("WalkSpeed", { Title="Speed", Min=16, Max=500, Default=cfg.Speed or 16, Rounding=0,
            Callback=function(v)
                cfg.Speed = v
                local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = v end
            end })

        T:AddSlider("JumpPower", { Title="Jump Power", Min=50, Max=500, Default=50, Rounding=0,
            Callback=function(v)
                local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.JumpPower = v end
            end })

        T:AddToggle("InfiniteJump", { Title="Infinite Jump", Default=cfg.InfiniteJump,
            Callback=function(v)
                cfg.InfiniteJump = v
                _G.InfiniteJump = v
                if v then
                    UIS.JumpRequest:Connect(function()
                        if _G.InfiniteJump then
                            local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
                            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                        end
                    end)
                end
            end })

        T:AddSection("Physics")
        T:AddToggle("NoClip", { Title="No Clip", Default=cfg.NoClip,
            Callback=function(v)
                cfg.NoClip = v
                _G.NoClip = v
                if v then
                    RunService.Stepped:Connect(function()
                        if _G.NoClip and plr.Character then
                            for _, p in ipairs(plr.Character:GetDescendants()) do
                                if p:IsA("BasePart") then p.CanCollide = false end
                            end
                        end
                    end)
                end
            end })

        T:AddToggle("WalkOnWater", { Title="Walk On Water", Default=false,
            Callback=function(v)
                _G.WalkOnWater = v
                if v then
                    local wp = Instance.new("Part", workspace)
                    wp.Name = "ZenithWaterWalk"
                    wp.Size = Vector3.new(1000, 80, 1000)
                    wp.Position = Vector3.new(0, -34, 0)
                    wp.Anchored = true
                    wp.CanCollide = true
                    wp.Transparency = 1
                else
                    local existing = workspace:FindFirstChild("ZenithWaterWalk")
                    if existing then existing:Destroy() end
                end
            end })

        T:AddToggle("AutoDodge", { Title="Auto Dodge", Default=false, Callback=function(v) _G.AutoDodge=v end })
        T:AddToggle("AntiStun",  { Title="Anti Stun",  Default=false,
            Callback=function(v)
                _G.AntiStun = v
                if v then
                    local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false) end
                end
            end })
    end

    -- ══════════════════════════════════════════
    -- TAB 12 — TELEPORTS
    -- ══════════════════════════════════════════
    do
        local T = Tabs.Teleports
        local islandList = IS_W1 and {
            "Starter Island","Marine Starter","Jungle","Pirate Village","Desert",
            "Frozen Village","Marine Fortress","Prison","Magma Village",
            "Skylands","Skylands 2","Underwater City",
        } or IS_W2 and {
            "Kingdom of Rose","Green Zone","Graveyard","Snow Mountain",
            "Hot & Cold","Cursed Ship","Ice Castle","Forgotten Island","Zou",
        } or {
            "Port Town","Hydra Island","Great Tree","Floating Turtle",
            "Haunted Castle","Candy Land","Dressrosa","Flame Tower",
            "Haunted Castle 2","Mansion","Tiki Outpost","Submerged Island",
        }

        T:AddSection("Island TP")
        local SelectedIsland = islandList[1]
        T:AddDropdown("SelectIsland", { Title="Select Island", Values=islandList, Default=islandList[1],
            Callback=function(v) SelectedIsland=v end })
        T:AddButton({ Title="Teleport to Island", Callback=function()
            BloxFruits.TeleportIsland(SelectedIsland, WORLD)
        end })

        T:AddSection("Boss TP")
        local bossList = IS_W1 and BloxFruits.Bosses.Sea1 or IS_W2 and BloxFruits.Bosses.Sea2 or BloxFruits.Bosses.Sea3
        local SelectedBossTP = bossList[1]
        T:AddDropdown("SelectBossTP", { Title="Select Boss", Values=bossList, Default=bossList[1],
            Callback=function(v) SelectedBossTP=v end })
        T:AddButton({ Title="Teleport to Boss", Callback=function()
            BloxFruits.TeleportBoss(SelectedBossTP)
        end })

        T:AddSection("Player TP")
        local playerNames = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= plr then table.insert(playerNames, p.Name) end
        end
        if #playerNames > 0 then
            local SelectedPlayer = playerNames[1]
            T:AddDropdown("SelectPlayer", { Title="Select Player", Values=playerNames, Default=playerNames[1],
                Callback=function(v) SelectedPlayer=v end })
            T:AddButton({ Title="Teleport to Player", Callback=function()
                local target = Players:FindFirstChild(SelectedPlayer)
                if target and target.Character then
                    local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
                    local hrp  = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                    if tHrp and hrp then hrp.CFrame = tHrp.CFrame + Vector3.new(3, 0, 0) end
                end
            end })
        end

        T:AddSection("Event TP")
        local function tpToModel(path, child)
            local root = workspace
            for _, part in ipairs(path) do root = root:FindFirstChild(part) if not root then return end end
            local model = root:FindFirstChild(child)
            local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if model and model.PrimaryPart and hrp then hrp.CFrame = model.PrimaryPart.CFrame end
        end
        T:AddButton({ Title="TP Mirage Island", Callback=function()
            tpToModel({ "_WorldOrigin", "Locations" }, "Mirage Island")
        end })
        T:AddButton({ Title="TP Kitsune Island", Callback=function()
            tpToModel({ "Map" }, "KitsuneIsland")
        end })
    end

    -- ══════════════════════════════════════════
    -- TAB 13 — VISUALS
    -- ══════════════════════════════════════════
    do
        local T = Tabs.Visuals

        T:AddSection("ESP")
        T:AddToggle("PlayerESP", { Title="Player ESP", Default=false,
            Callback=function(enabled)
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= plr and p.Character then
                        local existing = p.Character:FindFirstChild("ZenithPlayerESP")
                        if enabled and not existing then
                            local hl = Instance.new("Highlight", p.Character)
                            hl.Name = "ZenithPlayerESP"
                            hl.FillColor = Color3.fromRGB(255, 50, 50)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.5
                        elseif not enabled and existing then
                            existing:Destroy()
                        end
                    end
                end
            end })

        T:AddToggle("FruitESPVisuals", { Title="Fruit ESP", Default=false, Callback=function(v) BloxFruits.SetFruitESP(v) end })

        T:AddToggle("BossESP", { Title="Boss ESP", Default=false,
            Callback=function(enabled)
                for _, bossName in ipairs(BloxFruits.Bosses.Sea1) do
                    local boss = workspace:FindFirstChild(bossName, true)
                    if boss then
                        local existing = boss:FindFirstChild("ZenithBossESP")
                        if enabled and not existing then
                            local hl = Instance.new("Highlight", boss)
                            hl.Name = "ZenithBossESP"
                            hl.FillColor = Color3.fromRGB(255, 100, 0)
                            hl.OutlineColor = Color3.fromRGB(255, 200, 0)
                            hl.FillTransparency = 0.4
                        elseif not enabled and existing then
                            existing:Destroy()
                        end
                    end
                end
            end })

        T:AddToggle("ChestESP", { Title="Chest ESP", Default=false,
            Callback=function(enabled)
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and string.find(obj.Name:lower(), "chest") then
                        local existing = obj:FindFirstChild("ZenithChestESP")
                        if enabled and not existing then
                            local bb = Instance.new("BillboardGui", obj)
                            bb.Name = "ZenithChestESP"
                            bb.Size = UDim2.new(0, 80, 0, 25)
                            bb.StudsOffset = Vector3.new(0, 4, 0)
                            bb.AlwaysOnTop = true
                            local lbl = Instance.new("TextLabel", bb)
                            lbl.Size = UDim2.new(1, 0, 1, 0)
                            lbl.BackgroundTransparency = 1
                            lbl.TextColor3 = Color3.fromRGB(255, 220, 50)
                            lbl.TextStrokeTransparency = 0
                            lbl.TextScaled = true
                            lbl.Text = "📦 Chest"
                        elseif not enabled and existing then
                            existing:Destroy()
                        end
                    end
                end
            end })

        T:AddSection("Lighting")
        T:AddToggle("FullBright", { Title="FullBright", Default=false,
            Callback=function(v)
                if v then
                    Lighting.Ambient = Color3.new(1, 1, 1)
                    Lighting.Brightness = 2
                    Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
                    Lighting.ColorShift_Top = Color3.new(1, 1, 1)
                else
                    Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
                    Lighting.Brightness = 1
                end
            end })
        T:AddToggle("RemoveFog", { Title="Remove Fog", Default=false,
            Callback=function(v) Lighting.FogEnd = v and 1e10 or 100000 end })
        T:AddToggle("RemoveEffects", { Title="Remove Effects", Default=false,
            Callback=function(v)
                for _, e in ipairs(Lighting:GetChildren()) do
                    if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or
                       e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") then
                        e.Enabled = not v
                    end
                end
            end })

        T:AddSection("Performance")
        T:AddToggle("FPSBoost", { Title="FPS Boost", Default=cfg.FPSBoost,
            Callback=function(v)
                cfg.FPSBoost = v
                if v then
                    settings().Rendering.QualityLevel = "Level01"
                    workspace.StreamingEnabled = false
                else
                    settings().Rendering.QualityLevel = "Automatic"
                end
            end })
        T:AddSlider("TimeChanger", { Title="Time of Day", Min=0, Max=24, Default=14, Rounding=1,
            Callback=function(v)
                Lighting.TimeOfDay = string.format("%02d:00:00", math.floor(v))
            end })
    end

    -- ══════════════════════════════════════════
    -- TAB 14 — SERVER
    -- ══════════════════════════════════════════
    do
        local T = Tabs.Server
        local RS2 = game:GetService("ReplicatedStorage")

        -- Helper para busca de servidor
        local function findServer(condition)
            pcall(function()
                for i = 1, 100 do
                    local browser = RS2:FindFirstChild("__ServerBrowser")
                    local servers  = browser and browser:InvokeServer(i)
                    if servers then
                        for id, data in next, servers do
                            if condition(data) then
                                TeleportSvc:TeleportToPlaceInstance(game.PlaceId, id)
                                return
                            end
                        end
                    end
                end
            end)
        end

        T:AddSection("Server Hop")
        T:AddButton({ Title="Server Hop", Callback=function()
            findServer(function(d) return tonumber(d.Count) and tonumber(d.Count) < 12 end)
        end })
        T:AddButton({ Title="Rejoin", Callback=function()
            TeleportSvc:Teleport(game.PlaceId)
        end })
        T:AddButton({ Title="Low Server Finder (< 10 jogadores)", Callback=function()
            findServer(function(d) return tonumber(d.Count) and tonumber(d.Count) < 10 end)
        end })
        T:AddButton({ Title="Auto Join Event Server", Callback=function()
            findServer(function(d) return d.EventServer end)
        end })

        T:AddSection("JobId")
        T:AddButton({ Title="Copy JobId", Callback=function()
            if setclipboard then
                setclipboard(game.JobId)
                notify("ZenithHub", "JobId copiado!", 3)
            end
        end })

        local JobIdInput = ""
        T:AddInput("JobIdInput", { Title="Join JobId", Placeholder="Cole o JobId aqui...",
            Callback=function(v) JobIdInput=v end })
        T:AddButton({ Title="Join por JobId", Callback=function()
            if JobIdInput ~= "" then
                TeleportSvc:TeleportToPlaceInstance(game.PlaceId, JobIdInput)
            end
        end })
    end

    -- ══════════════════════════════════════════
    -- TAB 15 — SETTINGS
    -- ══════════════════════════════════════════
    do
        local T = Tabs.Settings

        T:AddSection("Combat Settings")
        T:AddSlider("BringRange", { Title="Bring Range", Min=50, Max=500, Default=235, Rounding=0,
            Callback=function(v)
                _G.BringRange = v
                if BloxFruits.State then BloxFruits.State.BringRange = v end
            end })
        T:AddSlider("MaxBringMobs", { Title="Max Bring Mobs", Min=1, Max=10, Default=3, Rounding=0,
            Callback=function(v) _G.MaxBringMobs=v end })

        T:AddSection("Tween Settings")
        T:AddSlider("TweenFar",  { Title="Tween Speed (longe)", Min=50,  Max=1000, Default=300, Rounding=0,
            Callback=function(v) getgenv().TweenSpeedFar=v end })
        T:AddSlider("TweenNear", { Title="Tween Speed (perto)", Min=100, Max=2000, Default=900, Rounding=0,
            Callback=function(v) getgenv().TweenSpeedNear=v end })

        T:AddSection("Performance Settings")
        T:AddSlider("LoopDelay", { Title="Loop Delay (ms)", Min=50, Max=500, Default=100, Rounding=0,
            Callback=function(v) _G.LoopDelay = v / 1000 end })

        T:AddSection("UI Settings")
        T:AddDropdown("ThemeSelect", { Title="Tema", Values={"Dark","Light","Darker"}, Default=cfg.Theme or "Dark",
            Callback=function(v) cfg.Theme=v; notify("Tema","Reinicie o hub para aplicar o tema.",3,"Warning") end })
        T:AddKeybind("MinimizeKey", { Title="Minimize Key", Mode="Toggle", Default="RightControl",
            Callback=function() end })

        T:AddSection("Config")
        SaveManager:SetLibrary(Fluent)
        InterfaceManager:SetLibrary(Fluent)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreList({ "MinimizeKey" })
        SaveManager:BuildConfigSection(T)
        InterfaceManager:BuildInterfaceSection(T)

        T:AddButton({ Title="Save Config",  Callback=function() SaveManager:Save(); notify("Config","Configuração salva!",2,"Success") end })
        T:AddButton({ Title="Load Config",  Callback=function() SaveManager:Load(); notify("Config","Configuração carregada!",2,"Success") end })
        T:AddButton({ Title="Reset Tudo (Cleanup)", Callback=function()
            BloxFruits.Cleanup()
            notify("ZenithHub","Tudo resetado!",3)
        end })

        T:AddSection("Assets")
        T:AddInput("HubLogoID",    { Title="Hub Logo (Asset ID)",    Default="7733960981", Placeholder="Digite o Asset ID...",
            Callback=function() notify("Logo","Logo atualizado! (Reinicie para ver).",3) end })
        T:AddInput("ToggleLogoID", { Title="Toggle Logo (Asset ID)", Default="7733960981", Placeholder="Digite o Asset ID...",
            Callback=function() notify("Toggle","Toggle logo atualizado!",2) end })
    end

    -- ══════════════════════════════════════════
    -- INIT FINAL
    -- ══════════════════════════════════════════
    SaveManager:LoadAutoloadConfig()
    InterfaceManager:BuildThemesSection(Tabs.Settings)

    BloxFruits.SetAutoKen(true)

    Window:SelectTab(1)
    notify("Zenith Hub Carregado!",
        "Bem-vindo ao Zenith Hub - Blox Fruits Edition\nPressione RCtrl para minimizar.",
        5, "Success")
end

-- ════════════════════════════════════════════
-- INIT PÚBLICA
-- ════════════════════════════════════════════
function UI.Init(modules, configData)
    BloxFruits = modules.BloxFruits
    Universal  = modules.Universal
    Config     = modules.Config
    cfg        = configData

    showSplash()
    loadFluent()
    buildUI()
end

return UI
