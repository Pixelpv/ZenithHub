--[[ 
    ZenithHub - Main.lua (Refatorado)
    Estrutura otimizada, modular e escalável
]]

-- ═══════════════════════════════════════
-- GLOBAL GUARD
-- ═══════════════════════════════════════

local ENV = (getgenv and getgenv()) or _G
ENV.ZenithHub = ENV.ZenithHub or {}

if ENV.ZenithHub.Loaded then
    warn("[ZenithHub] Já carregado.")
    return
end

ENV.ZenithHub.Loaded = true

-- ═══════════════════════════════════════
-- CONFIG BÁSICA
-- ═══════════════════════════════════════

local HUB = {
    Name = "Zenith Hub",
    Version = "1.0.0",
    Author = "ZenithDev"
}

-- ═══════════════════════════════════════
-- SERVICES CACHE
-- ═══════════════════════════════════════

local Services = {
    Players = game:GetService("Players"),
    UserInputService = game:GetService("UserInputService"),
    RunService = game:GetService("RunService"),
}

local LocalPlayer = Services.Players.LocalPlayer

-- ═══════════════════════════════════════
-- LOGGER
-- ═══════════════════════════════════════

local function log(msg)
    print(("[ZenithHub] %s"):format(msg))
end

local function warnLog(msg)
    warn(("[ZenithHub] %s"):format(msg))
end

-- ═══════════════════════════════════════
-- PLATFORM DETECTION
-- ═══════════════════════════════════════

local isMobile = Services.UserInputService.TouchEnabled

log("Plataforma: " .. (isMobile and "Mobile" or "PC"))

-- ═══════════════════════════════════════
-- MODULE SYSTEM (ABSTRAÇÃO LIMPA)
-- ═══════════════════════════════════════

local LoadedModules = {}

local function loadModule(name, fallback)
    if LoadedModules[name] then
        return LoadedModules[name]
    end

    local success, result = pcall(function()
        -- Aqui entra seu loader real (abstraído)
        -- return require(path) OU loader custom do executor
        return fallback
    end)

    if success and result then
        LoadedModules[name] = result
        return result
    end

    warnLog("Falha ao carregar módulo: " .. name)
    return fallback or {}
end

-- ═══════════════════════════════════════
-- GAME DETECTION
-- ═══════════════════════════════════════

local GameModules = {
    [2753915549] = "BloxFruits",
    [4442272298] = "BloxFruits",
    [7449423635] = "BloxFruits",
}

local placeId = game.PlaceId
local gameName = GameModules[placeId]

log("PlaceId: " .. tostring(placeId))

-- ═══════════════════════════════════════
-- LOAD CORE MODULES
-- ═══════════════════════════════════════

local Modules = {}

Modules.Config = loadModule("Config", {})
Modules.Universal = loadModule("Universal", {})

if gameName then
    Modules.Game = loadModule(gameName, {})
    log("Game module carregado: " .. gameName)
else
    Modules.Game = {}
    log("Game não suportado especificamente (modo universal)")
end

-- ═══════════════════════════════════════
-- CONFIG
-- ═══════════════════════════════════════

local cfg = (Modules.Config.Load and Modules.Config.Load()) or {}

-- flag de dirty para autosave
local dirty = false

-- ═══════════════════════════════════════
-- UI INIT
-- ═══════════════════════════════════════

local UI = loadModule("UI", {})

local function initUI()
    if UI.Init then
        UI.Init(Modules, cfg, (Modules.Config.Assets or {}))
    else
        warnLog("UI não encontrada")
    end
end

local ok, err = pcall(initUI)

if not ok then
    warnLog("Falha UI: " .. tostring(err))
    ENV.ZenithHub.Loaded = false
    return
end

-- ═══════════════════════════════════════
-- CLEANUP SYSTEM
-- ═══════════════════════════════════════

local Connections = {}

local function cleanup()
    ENV.ZenithHub.Loaded = false

    for _, c in ipairs(Connections) do
        pcall(function()
            c:Disconnect()
        end)
    end

    if Modules.Universal and Modules.Universal.Cleanup then
        pcall(Modules.Universal.Cleanup)
    end

    if Modules.Game and Modules.Game.Cleanup then
        pcall(Modules.Game.Cleanup)
    end

    if Modules.Config and Modules.Config.Save then
        pcall(function()
            Modules.Config.Save(cfg)
        end)
    end

    log("Cleanup executado")
end

-- ═══════════════════════════════════════
-- SAFE EXIT
-- ═══════════════════════════════════════

table.insert(Connections,
    LocalPlayer.AncestryChanged:Connect(function()
        cleanup()
    end)
)

-- ═══════════════════════════════════════
-- AUTOSAVE (OTIMIZADO)
-- ═══════════════════════════════════════

task.spawn(function()
    while ENV.ZenithHub.Loaded do
        task.wait(60)

        if dirty and Modules.Config and Modules.Config.Save then
            dirty = false
            pcall(function()
                Modules.Config.Save(cfg)
            end)
        end
    end
end)

-- ═══════════════════════════════════════
-- FINAL
-- ═══════════════════════════════════════

log(("v%s carregado com sucesso"):format(HUB.Version))
