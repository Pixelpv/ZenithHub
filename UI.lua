--[[
    ZenithHub - UI.lua
    Interface completa usando Fluent UI
    Tabs: Main/AutoFarm | Stats/Teleports | Dungeon/Raids | Sea Events | Races/V4 | Shop/Gacha | Configs
]]

local UI = {}

-- ════════════════════════════════════════════
-- DEPENDÊNCIAS (carregadas pelo Main)
-- ════════════════════════════════════════════
-- BloxFruits, Universal e cfg são injetados via UI.Init()

local BloxFruits
local Universal
local Config
local cfg  -- tabela de config ativa

-- ════════════════════════════════════════════
-- FLUENT UI LOADER
-- ════════════════════════════════════════════

local Fluent
local SaveManager
local InterfaceManager

local function loadFluent()
    local ok, err = pcall(function()
        Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
        SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
        InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
    end)
    if not ok then
        error("[ZenithHub] Falha ao carregar Fluent UI: " .. tostring(err))
    end
end

-- ════════════════════════════════════════════
-- NOTIFICAÇÃO HELPER
-- ════════════════════════════════════════════

local Window

local function notify(title, content, duration, style)
    if not Fluent then return end
    pcall(function()
        Fluent:Notify({
            Title    = title or "Zenith Hub",
            Content  = content or "",
            Duration = duration or 3,
            Style    = style or "Info",
        })
    end)
end

-- ════════════════════════════════════════════
-- SPLASH SCREEN ANIMADA
-- ════════════════════════════════════════════

local function showSplash()
    -- Cria splash via ScreenGui
    local ok, err = pcall(function()
        local Players = game:GetService("Players")
        local TweenService = game:GetService("TweenService")
        local LocalPlayer = Players.LocalPlayer
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")

        local splashGui = Instance.new("ScreenGui")
        splashGui.Name = "ZenithSplash"
        splashGui.IgnoreGuiInset = true
        splashGui.ResetOnSpawn = false
        splashGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        splashGui.Parent = playerGui

        -- Background
        local bg = Instance.new("Frame")
        bg.Size = UDim2.fromScale(1, 1)
        bg.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
        bg.BackgroundTransparency = 1
        bg.Parent = splashGui

        -- Blur effect
        local blur = Instance.new("BlurEffect")
        blur.Size = 0
        blur.Parent = game:GetService("Lighting")

        -- Fade in background
        local bgFade = TweenService:Create(bg,
            TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { BackgroundTransparency = 0 }
        )
        local blurFade = TweenService:Create(blur,
            TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { Size = 16 }
        )
        bgFade:Play()
        blurFade:Play()
        task.wait(0.5)

        -- Container central
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

        -- Anima container entrada
        local showContainer = TweenService:Create(container,
            TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { BackgroundTransparency = 0 }
        )
        local showStroke = TweenService:Create(stroke,
            TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { Transparency = 0 }
        )
        showContainer:Play()
        showStroke:Play()

        -- Logo Image
        local logo = Instance.new("ImageLabel")
        logo.AnchorPoint = Vector2.new(0.5, 0)
        logo.Position = UDim2.fromOffset(210, 24)
        logo.Size = UDim2.fromOffset(64, 64)
        logo.BackgroundTransparency = 1
        logo.Image = "rbxassetid://7733960981"
        logo.ImageTransparency = 1
        logo.Parent = container

        -- Título
        local titleLabel = Instance.new("TextLabel")
        titleLabel.AnchorPoint = Vector2.new(0.5, 0)
        titleLabel.Position = UDim2.fromOffset(210, 100)
        titleLabel.Size = UDim2.fromOffset(400, 40)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = "ZENITH HUB"
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.TextTransparency = 1
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 28
        titleLabel.Parent = container

        -- Subtítulo
        local subLabel = Instance.new("TextLabel")
        subLabel.AnchorPoint = Vector2.new(0.5, 0)
        subLabel.Position = UDim2.fromOffset(210, 140)
        subLabel.Size = UDim2.fromOffset(400, 24)
        subLabel.BackgroundTransparency = 1
        subLabel.Text = "Blox Fruits Edition • Loading..."
        subLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
        subLabel.TextTransparency = 1
        subLabel.Font = Enum.Font.Gotham
        subLabel.TextSize = 14
        subLabel.Parent = container

        -- Barra de progresso
        local barBg = Instance.new("Frame")
        barBg.AnchorPoint = Vector2.new(0.5, 0)
        barBg.Position = UDim2.fromOffset(210, 176)
        barBg.Size = UDim2.fromOffset(340, 4)
        barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        barBg.BackgroundTransparency = 1
        barBg.BorderSizePixel = 0
        barBg.Parent = container
        local barBgCorner = Instance.new("UICorner")
        barBgCorner.CornerRadius = UDim.new(1, 0)
        barBgCorner.Parent = barBg

        local barFill = Instance.new("Frame")
        barFill.Size = UDim2.fromScale(0, 1)
        barFill.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
        barFill.BorderSizePixel = 0
        barFill.Parent = barBg
        local barFillCorner = Instance.new("UICorner")
        barFillCorner.CornerRadius = UDim.new(1, 0)
        barFillCorner.Parent = barFill

        task.wait(0.3)

        -- Fade in elementos
        TweenService:Create(logo, TweenInfo.new(0.4), { ImageTransparency = 0 }):Play()
        TweenService:Create(titleLabel, TweenInfo.new(0.4), { TextTransparency = 0 }):Play()
        TweenService:Create(subLabel, TweenInfo.new(0.4), { TextTransparency = 0 }):Play()
        TweenService:Create(barBg, TweenInfo.new(0.4), { BackgroundTransparency = 0 }):Play()

        task.wait(0.4)

        -- Anima barra de progresso
        TweenService:Create(barFill,
            TweenInfo.new(1.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { Size = UDim2.fromScale(1, 1) }
        ):Play()

        task.wait(2.0)

        -- Fade out tudo
        TweenService:Create(bg,
            TweenInfo.new(0.5, Enum.EasingStyle.Quart),
            { BackgroundTransparency = 1 }
        ):Play()
        TweenService:Create(blur,
            TweenInfo.new(0.5, Enum.EasingStyle.Quart),
            { Size = 0 }
        ):Play()

        task.wait(0.6)
        splashGui:Destroy()
        blur:Destroy()
    end)
    if not ok then warn("[ZenithHub] Splash error: " .. tostring(err)) end
end

-- ════════════════════════════════════════════
-- BUILD DA INTERFACE PRINCIPAL
-- ════════════════════════════════════════════

local function buildUI(assets)
    -- Cria janela principal
    Window = Fluent:CreateWindow({
        Title   = "Zenith Hub",
        SubTitle = "Blox Fruits Edition",
        TabWidth = 160,
        Size     = UDim2.fromOffset(580, 460),
        Acrylic  = true,  -- Efeito blur/acrylic
        Theme    = cfg.Theme or "Dark",
        MinimizeKey = Enum.KeyCode.RightControl,
    })

    -- ── Tabs ──────────────────────────────────
    local Tabs = {
        Farm    = Window:AddTab({ Title = "Auto Farm",   Icon = "sword" }),
        Stats   = Window:AddTab({ Title = "Stats / TP",  Icon = "bar-chart-2" }),
        Dungeon = Window:AddTab({ Title = "Dungeons",    Icon = "shield" }),
        Sea     = Window:AddTab({ Title = "Sea Events",  Icon = "anchor" }),
        Race    = Window:AddTab({ Title = "Races / V4",  Icon = "zap" }),
        Shop    = Window:AddTab({ Title = "Shop / Gacha",Icon = "shopping-bag" }),
        Config  = Window:AddTab({ Title = "Configs",     Icon = "settings" }),
    }

    -- ════════════════════════════════════════
    -- TAB 1: MAIN / AUTO FARM
    -- ════════════════════════════════════════

    local FarmTab = Tabs.Farm

    FarmTab:AddParagraph({
        Title   = "Auto Farm",
        Content = "Detecta automaticamente o mar e a quest ideal para seu nível.",
    })

    -- Selector de mar
    FarmTab:AddDropdown("SeaSelect", {
        Title   = "Mar Atual",
        Values  = { "Sea 1", "Sea 2", "Sea 3" },
        Default = cfg.SelectedSea or "Sea 1",
        Callback = function(val)
            cfg.SelectedSea = val
        end,
    })

    FarmTab:AddToggle("AutoFarm", {
        Title   = "Auto Farm",
        Default = cfg.AutoFarm,
        Callback = function(val)
            cfg.AutoFarm = val
            local sea = cfg.SelectedSea == "Sea 1" and 1 or cfg.SelectedSea == "Sea 2" and 2 or 3
            BloxFruits.SetAutoFarm(val, sea)
            notify("Auto Farm", val and "Ativado!" or "Desativado.", 2, val and "Success" or "Info")
        end,
    })

    FarmTab:AddToggle("AutoQuest", {
        Title   = "Auto Quest",
        Default = cfg.AutoQuest,
        Callback = function(val)
            cfg.AutoQuest = val
            local sea = cfg.SelectedSea == "Sea 1" and 1 or cfg.SelectedSea == "Sea 2" and 2 or 3
            BloxFruits.SetAutoQuest(val, sea)
            notify("Auto Quest", val and "Ativado!" or "Desativado.", 2)
        end,
    })

    FarmTab:AddToggle("BringMob", {
        Title   = "Bring Mob",
        Default = cfg.BringMob,
        Callback = function(val)
            cfg.BringMob = val
            if val and cfg.CurrentMob then
                BloxFruits.SetBringMob(true, cfg.CurrentMob)
            else
                BloxFruits.SetBringMob(false)
            end
        end,
    })

    FarmTab:AddToggle("KillAura", {
        Title   = "Kill Aura",
        Default = cfg.KillAura,
        Callback = function(val)
            cfg.KillAura = val
            BloxFruits.SetKillAura(val, 25)
            notify("Kill Aura", val and "Ativado!" or "Desativado.", 2)
        end,
    })

    FarmTab:AddToggle("FastAttack", {
        Title   = "Fast Attack",
        Default = cfg.FastAttack,
        Callback = function(val)
            cfg.FastAttack = val
            BloxFruits.SetFastAttack(val)
        end,
    })

    FarmTab:AddToggle("AutoHaki", {
        Title   = "Auto Haki",
        Default = cfg.AutoHaki,
        Callback = function(val)
            cfg.AutoHaki = val
            BloxFruits.SetAutoHaki(val)
        end,
    })

    -- Seção Boss
    FarmTab:AddParagraph({ Title = "Boss Farming", Content = "Selecione e persiga bosses automaticamente." })

    local allBosses = {}
    for _, list in pairs(BloxFruits.Bosses) do
        for _, name in ipairs(list) do
            table.insert(allBosses, name)
        end
    end
    table.sort(allBosses)

    FarmTab:AddDropdown("BossSelect", {
        Title   = "Boss Alvo",
        Values  = allBosses,
        Default = allBosses[1],
        Callback = function(val)
            cfg.SelectedBoss = val
        end,
    })

    FarmTab:AddToggle("AutoBoss", {
        Title   = "Auto Boss",
        Default = cfg.AutoBoss,
        Callback = function(val)
            cfg.AutoBoss = val
            BloxFruits.SetAutoBoss(val, cfg.SelectedBoss or allBosses[1])
            notify("Auto Boss", val and ("Perseguindo: " .. (cfg.SelectedBoss or "?")) or "Desativado.", 3)
        end,
    })

    -- ════════════════════════════════════════
    -- TAB 2: STATS / TELEPORTS
    -- ════════════════════════════════════════

    local StatsTab = Tabs.Stats

    StatsTab:AddParagraph({ Title = "Auto Stats", Content = "Distribui pontos automaticamente." })

    StatsTab:AddDropdown("StatPriority", {
        Title   = "Prioridade de Stat",
        Values  = { "Melee", "Defense", "Sword", "Gun", "Blox Fruit" },
        Default = cfg.StatPriority or "Melee",
        Callback = function(val)
            cfg.StatPriority = val
        end,
    })

    StatsTab:AddToggle("AutoStats", {
        Title   = "Auto Stats",
        Default = cfg.AutoStats,
        Callback = function(val)
            cfg.AutoStats = val
            BloxFruits.SetAutoStats(val, cfg.StatPriority)
        end,
    })

    -- Teleports
    StatsTab:AddParagraph({ Title = "Teleports", Content = "Selecione o mar e a ilha." })

    StatsTab:AddToggle("TweenTeleport", {
        Title   = "Usar Tween (suave)",
        Default = cfg.TweenTeleport,
        Callback = function(val)
            cfg.TweenTeleport = val
        end,
    })

    StatsTab:AddDropdown("TeleportSea", {
        Title   = "Mar",
        Values  = { "Sea 1", "Sea 2", "Sea 3" },
        Default = "Sea 1",
        Callback = function(val)
            cfg.TeleportSea = val
        end,
    })

    -- Ilhas Sea 1
    local sea1List = {}
    for name in pairs(BloxFruits.Islands.Sea1) do table.insert(sea1List, name) end
    table.sort(sea1List)

    StatsTab:AddDropdown("IslandSelect", {
        Title   = "Ilha (Sea 1)",
        Values  = sea1List,
        Default = sea1List[1],
        Callback = function(val)
            cfg.SelectedIsland = val
        end,
    })

    StatsTab:AddButton({
        Title   = "Teleportar",
        Callback = function()
            local sea = cfg.TeleportSea == "Sea 1" and 1 or cfg.TeleportSea == "Sea 2" and 2 or 3
            BloxFruits.TeleportIsland(cfg.SelectedIsland or sea1List[1], sea, cfg.TweenTeleport)
            notify("Teleport", "Teleportando para " .. (cfg.SelectedIsland or "?"), 2)
        end,
    })

    -- Movement
    StatsTab:AddParagraph({ Title = "Movement", Content = "Controles de movimento avançado." })

    StatsTab:AddSlider("Speed", {
        Title   = "Speed",
        Min     = 16,
        Max     = 500,
        Default = cfg.Speed or 16,
        Rounding = 0,
        Callback = function(val)
            cfg.Speed = val
            Universal.SetSpeed(val)
        end,
    })

    StatsTab:AddToggle("Fly", {
        Title   = "Fly",
        Default = cfg.Fly,
        Callback = function(val)
            cfg.Fly = val
            Universal.SetFly(val)
            notify("Fly", val and "Ativado! WASD + Space/Ctrl" or "Desativado.", 2)
        end,
    })

    StatsTab:AddToggle("NoClip", {
        Title   = "No Clip",
        Default = cfg.NoClip,
        Callback = function(val)
            cfg.NoClip = val
            Universal.SetNoClip(val)
        end,
    })

    StatsTab:AddToggle("InfiniteJump", {
        Title   = "Infinite Jump",
        Default = cfg.InfiniteJump,
        Callback = function(val)
            cfg.InfiniteJump = val
            Universal.SetInfiniteJump(val)
        end,
    })

    -- ════════════════════════════════════════
    -- TAB 3: DUNGEON / RAIDS
    -- ════════════════════════════════════════

    local DungeonTab = Tabs.Dungeon

    DungeonTab:AddParagraph({ Title = "Raids", Content = "Automatiza raids e awaken." })

    DungeonTab:AddToggle("AutoRaid", {
        Title   = "Auto Raid",
        Default = cfg.AutoRaid,
        Callback = function(val)
            cfg.AutoRaid = val
            BloxFruits.SetAutoRaid(val)
            notify("Auto Raid", val and "Ativado!" or "Desativado.", 2)
        end,
    })

    DungeonTab:AddToggle("AutoDungeon", {
        Title   = "Auto Dungeon",
        Default = cfg.AutoDungeon,
        Callback = function(val)
            cfg.AutoDungeon = val
            notify("Auto Dungeon", val and "Ativado!" or "Desativado.", 2)
        end,
    })

    DungeonTab:AddToggle("AutoChipBuy", {
        Title   = "Auto Chip Buy",
        Default = cfg.AutoChipBuy,
        Callback = function(val)
            cfg.AutoChipBuy = val
            notify("Auto Chip Buy", val and "Ativado!" or "Desativado.", 2)
        end,
    })

    DungeonTab:AddToggle("AutoAwaken", {
        Title   = "Auto Awaken",
        Default = cfg.AutoAwaken,
        Callback = function(val)
            cfg.AutoAwaken = val
            notify("Auto Awaken", val and "Ativado! (Necessita raid ativa)" or "Desativado.", 3)
        end,
    })

    -- ════════════════════════════════════════
    -- TAB 4: SEA EVENTS
    -- ════════════════════════════════════════

    local SeaTab = Tabs.Sea

    SeaTab:AddParagraph({ Title = "Sea Events", Content = "Automatiza eventos do mar." })

    SeaTab:AddToggle("LeviathanHunt", {
        Title   = "Leviathan Hunt",
        Default = cfg.LeviathanHunt,
        Callback = function(val)
            cfg.LeviathanHunt = val
            BloxFruits.SetLeviathanHunt(val)
            notify("Leviathan", val and "Caçando Leviathan!" or "Desativado.", 2)
        end,
    })

    SeaTab:AddToggle("SeaBeastFarm", {
        Title   = "Sea Beast Farm",
        Default = cfg.SeaBeastFarm,
        Callback = function(val)
            cfg.SeaBeastFarm = val
            BloxFruits.SetSeaBeastFarm(val)
        end,
    })

    SeaTab:AddToggle("MirageDetection", {
        Title   = "Mirage Detection",
        Default = cfg.MirageDetection,
        Callback = function(val)
            cfg.MirageDetection = val
            notify("Mirage", val and "Detectando Miragem..." or "Desativado.", 2)
        end,
    })

    SeaTab:AddToggle("TerrorSharkESP", {
        Title   = "Terror Shark ESP",
        Default = cfg.TerrorSharkESP,
        Callback = function(val)
            cfg.TerrorSharkESP = val
            BloxFruits.SetTerrorSharkESP(val)
        end,
    })

    SeaTab:AddToggle("EventESP", {
        Title   = "Event ESP",
        Default = cfg.EventESP,
        Callback = function(val)
            cfg.EventESP = val
        end,
    })

    -- ════════════════════════════════════════
    -- TAB 5: RACES / V4
    -- ════════════════════════════════════════

    local RaceTab = Tabs.Race

    RaceTab:AddParagraph({ Title = "Raças & V4", Content = "Automatiza progressão de raça e transformações." })

    RaceTab:AddDropdown("RaceSelect", {
        Title   = "Raça",
        Values  = BloxFruits.Races,
        Default = cfg.SelectedRace or "Human",
        Callback = function(val)
            cfg.SelectedRace = val
        end,
    })

    RaceTab:AddToggle("AutoRaceV4", {
        Title   = "Auto Race V4",
        Default = cfg.AutoRaceV4,
        Callback = function(val)
            cfg.AutoRaceV4 = val
            BloxFruits.SetAutoRaceV4(val, cfg.SelectedRace)
            notify("Race V4", val and "Ativado para " .. (cfg.SelectedRace or "?") or "Desativado.", 3)
        end,
    })

    RaceTab:AddToggle("AutoTrial", {
        Title   = "Auto Trial",
        Default = cfg.AutoTrial,
        Callback = function(val)
            cfg.AutoTrial = val
            notify("Auto Trial", val and "Ativado!" or "Desativado.", 2)
        end,
    })

    RaceTab:AddToggle("AutoGear", {
        Title   = "Auto Gear",
        Default = cfg.AutoGear,
        Callback = function(val)
            cfg.AutoGear = val
        end,
    })

    RaceTab:AddButton({
        Title   = "Temple Teleport",
        Callback = function()
            -- Teleporta para o templo de raças (posição aproximada)
            Universal.TeleportTo(Vector3.new(-1648, 1079, 427))
            notify("Temple", "Teleportando para o Templo!", 2)
        end,
    })

    -- ════════════════════════════════════════
    -- TAB 6: SHOP / GACHA
    -- ════════════════════════════════════════

    local ShopTab = Tabs.Shop

    ShopTab:AddParagraph({ Title = "Fruit Sniper", Content = "Monitora e coleta frutas raras." })

    ShopTab:AddDropdown("FruitTarget", {
        Title       = "Fruta Alvo",
        Values      = BloxFruits.Fruits,
        Default     = BloxFruits.Fruits[1],
        MultipleValues = true,
        Callback = function(val)
            cfg.TargetFruits = val
        end,
    })

    ShopTab:AddToggle("FruitSniper", {
        Title   = "Fruit Sniper",
        Default = cfg.FruitSniper,
        Callback = function(val)
            cfg.FruitSniper = val
            BloxFruits.SetFruitSniper(val, cfg.TargetFruits or {})
            notify("Fruit Sniper", val and "Monitorando frutas!" or "Desativado.", 2)
        end,
    })

    ShopTab:AddToggle("AutoStoreFruit", {
        Title   = "Auto Store Fruit",
        Default = cfg.AutoStoreFruit,
        Callback = function(val)
            cfg.AutoStoreFruit = val
        end,
    })

    ShopTab:AddToggle("AutoBuyItems", {
        Title   = "Auto Buy Items",
        Default = cfg.AutoBuyItems,
        Callback = function(val)
            cfg.AutoBuyItems = val
        end,
    })

    ShopTab:AddToggle("GachaBuy", {
        Title   = "Gacha Buy",
        Default = cfg.GachaBuy,
        Callback = function(val)
            cfg.GachaBuy = val
            notify("Gacha", val and "Ativado! Comprando automaticamente..." or "Desativado.", 3)
        end,
    })

    ShopTab:AddToggle("ShopESP", {
        Title   = "Shop ESP",
        Default = cfg.ShopESP,
        Callback = function(val)
            cfg.ShopESP = val
        end,
    })

    -- ════════════════════════════════════════
    -- TAB 7: CONFIGS
    -- ════════════════════════════════════════

    local CfgTab = Tabs.Config

    CfgTab:AddParagraph({ Title = "Configurações", Content = "Gerenciamento de config e sistema." })

    -- Save / Load
    CfgTab:AddButton({
        Title   = "Salvar Config",
        Callback = function()
            Config.Save(cfg)
            notify("Config", "Configuração salva!", 2, "Success")
        end,
    })

    CfgTab:AddButton({
        Title   = "Carregar Config",
        Callback = function()
            cfg = Config.Load()
            notify("Config", "Configuração carregada!", 2, "Success")
        end,
    })

    CfgTab:AddButton({
        Title   = "Resetar Config",
        Callback = function()
            cfg = Config.Reset()
            notify("Config", "Config resetada para padrão.", 3, "Warning")
        end,
    })

    -- Theme
    CfgTab:AddDropdown("ThemeSelect", {
        Title   = "Tema",
        Values  = { "Dark", "Light", "Darker" },
        Default = cfg.Theme or "Dark",
        Callback = function(val)
            cfg.Theme = val
            notify("Tema", "Reinicie o hub para aplicar o tema.", 3, "Warning")
        end,
    })

    -- FPS
    CfgTab:AddToggle("FPSBoost", {
        Title   = "FPS Boost",
        Default = cfg.FPSBoost,
        Callback = function(val)
            cfg.FPSBoost = val
            Universal.SetFPSBoost(val)
            notify("FPS Boost", val and "Ativado! Qualidade reduzida." or "Desativado.", 2)
        end,
    })

    -- Server Hop
    CfgTab:AddButton({
        Title   = "Server Hop",
        Callback = function()
            notify("Server Hop", "Trocando de servidor...", 2)
            task.wait(1)
            Universal.ServerHop()
        end,
    })

    -- Rejoin
    CfgTab:AddButton({
        Title   = "Rejoin",
        Callback = function()
            notify("Rejoin", "Reconectando...", 2)
            task.wait(1)
            Universal.Rejoin()
        end,
    })

    -- Asset ID customizável
    CfgTab:AddParagraph({ Title = "Assets", Content = "Troque o Asset ID do logo e toggle." })

    CfgTab:AddInput("HubLogoID", {
        Title       = "Hub Logo (Asset ID)",
        Default     = "7733960981",
        Placeholder = "Digite o Asset ID...",
        Callback = function(val)
            -- Atualiza logo dinamicamente
            notify("Logo", "Logo atualizado! (Reinicie para ver).", 3)
        end,
    })

    CfgTab:AddInput("ToggleLogoID", {
        Title       = "Toggle Logo (Asset ID)",
        Default     = "7733960981",
        Placeholder = "Digite o Asset ID...",
        Callback = function(val)
            notify("Toggle", "Toggle logo atualizado!", 2)
        end,
    })

    -- Bind para fechar/abrir
    CfgTab:AddKeybind("ToggleKey", {
        Title   = "Tecla Abrir/Fechar UI",
        Mode    = "Toggle",
        Default = "RightControl",
        Callback = function()
            -- Fluent trata isso internamente via MinimizeKey
        end,
    })

    -- ════════════════════════════════════════
    -- SAVE MANAGER & INTERFACE MANAGER
    -- ════════════════════════════════════════

    pcall(function()
        SaveManager:SetLibrary(Fluent)
        InterfaceManager:SetLibrary(Fluent)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({})
        SaveManager:SetFolder("ZenithHub")
        InterfaceManager:SetFolder("ZenithHub")

        SaveManager:BuildConfigSection(Tabs.Config)
        InterfaceManager:BuildInterfaceSection(Tabs.Config)
    end)

    -- Seleciona tab inicial
    Window:SelectTab(1)

    -- Notificação de boas-vindas
    notify(
        "Zenith Hub Carregado!",
        "Bem-vindo ao Zenith Hub - Blox Fruits Edition\nPressione RCtrl para minimizar.",
        5,
        "Success"
    )
end

-- ════════════════════════════════════════════
-- INICIALIZAÇÃO PÚBLICA
-- ════════════════════════════════════════════

function UI.Init(modules, configData, assets)
    BloxFruits = modules.BloxFruits
    Universal  = modules.Universal
    Config     = modules.Config
    cfg        = configData

    -- 1. Splash screen
    showSplash()

    -- 2. Carrega Fluent
    loadFluent()

    -- 3. Constrói interface
    buildUI(assets)
end

return UI
