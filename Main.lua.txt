--[[
    ZenithHub — Main.lua  (v2.1)
    Ponto de entrada principal do hub modular.
    Orquestra: Config → Universal → BloxFruits → UI
]]

-- ═══════════════════════════════════════════════
-- ANTI DUPLICATA
-- ═══════════════════════════════════════════════
if _G.ZenithHubLoaded then
    print("[ZenithHub] Já carregado.")
    return
end
_G.ZenithHubLoaded = true

-- ═══════════════════════════════════════════════
-- INFO
-- ═══════════════════════════════════════════════
local HUB_NAME    = "Zenith Hub"
local HUB_VERSION = "2.1"
local HUB_AUTHOR  = "ZenithDev"
print(string.format("[%s] v%s by %s — Inicializando...", HUB_NAME, HUB_VERSION, HUB_AUTHOR))

-- ═══════════════════════════════════════════════
-- SERVIÇOS
-- ═══════════════════════════════════════════════
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer      = Players.LocalPlayer

-- ═══════════════════════════════════════════════
-- PLATAFORMA
-- ═══════════════════════════════════════════════
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
print("[ZenithHub] Plataforma: " .. (isMobile and "Mobile" or "PC"))

-- ═══════════════════════════════════════════════
-- DETECÇÃO DE JOGO
-- ═══════════════════════════════════════════════
local SupportedGames = {
    BloxFruits = {
        2753915549,  -- First Sea
        4442272298,  -- Second Sea
        7449423635,  -- Third Sea
    }
}

local BLOX_FRUITS_PLACE_IDS = {}
for world, id in ipairs(SupportedGames.BloxFruits) do
    BLOX_FRUITS_PLACE_IDS[id] = world
end

local currentPlaceId = game.PlaceId
local worldNum       = BLOX_FRUITS_PLACE_IDS[currentPlaceId]
local isBloxFruits   = worldNum ~= nil

print(string.format("[ZenithHub] PlaceId: %d | Jogo: %s",
    currentPlaceId,
    isBloxFruits and ("Blox Fruits — World " .. worldNum) or "Universal"
))

-- ═══════════════════════════════════════════════
-- CARREGADOR DE MÓDULOS
-- Funciona tanto em executor (readfile) quanto em dev (require)
-- ═══════════════════════════════════════════════
local BASE = "ZenithHub/"

local function safeLoad(path, fallback)
    -- Tenta executor: readfile existe e o arquivo está no disco
    if type(readfile) == "function" then
        local ok, result = pcall(function()
            local src = readfile(path)
            if not src or #src == 0 then error("arquivo vazio") end
            local fn, compileErr = loadstring(src)
            if not fn then error(compileErr) end
            return fn()
        end)
        if ok and result then return result end
        warn("[ZenithHub] readfile falhou para " .. path .. " — tentando require()")
    end

    -- Fallback: require (ambiente de dev / Rojo)
    local ok2, result2 = pcall(require, path)
    if ok2 and result2 then return result2 end

    warn("[ZenithHub] Não foi possível carregar: " .. path)
    return fallback or {}
end

-- ═══════════════════════════════════════════════
-- MÓDULOS (carregados na ordem correta)
-- ═══════════════════════════════════════════════
local Config    = safeLoad(BASE .. "Config.lua",             {})
local Universal = safeLoad(BASE .. "Modules/Universal.lua",  {})
local UI        = safeLoad(BASE .. "UI.lua",                 {})

-- Módulo de jogo: BloxFruits se detectado, senão tabela vazia
local GameModule = {}
if isBloxFruits then
    GameModule = safeLoad(BASE .. "Modules/BloxFruits.lua", {})
    -- Inicializa remotes, hooks e globals do BloxFruits ANTES da UI
    if type(GameModule.Init) == "function" then
        local initOk, initErr = pcall(GameModule.Init, GameModule)
        if not initOk then
            warn("[ZenithHub] BloxFruits.Init() falhou: " .. tostring(initErr))
        else
            print("[ZenithHub] BloxFruits inicializado.")
        end
    end
else
    print("[ZenithHub] Jogo não suportado — modo Universal.")
end

-- ═══════════════════════════════════════════════
-- CONFIG
-- ═══════════════════════════════════════════════
local cfg = type(Config.Load) == "function" and Config.Load() or {}
print("[ZenithHub] Config carregada.")

-- ═══════════════════════════════════════════════
-- UI
-- UI.Init espera (BloxFruits, Config) — assinatura do UI.lua v2.0
-- ═══════════════════════════════════════════════
if type(UI.Init) ~= "function" then
    warn("[ZenithHub] UI.Init não encontrado — UI.lua pode estar corrompido.")
    _G.ZenithHubLoaded = false
    return
end

local uiOk, uiErr = pcall(UI.Init, UI, GameModule, Config)
if not uiOk then
    warn("[ZenithHub] Falha ao inicializar UI: " .. tostring(uiErr))
    _G.ZenithHubLoaded = false
    return
end

print("[ZenithHub] UI carregada.")

-- ═══════════════════════════════════════════════
-- AUTOSAVE DE CONFIG (a cada 60 s)
-- ═══════════════════════════════════════════════
task.spawn(function()
    while _G.ZenithHubLoaded do
        task.wait(60)
        if type(Config.Save) == "function" then
            pcall(Config.Save, Config, cfg)
        end
    end
end)

-- ═══════════════════════════════════════════════
-- LIMPEZA AO SAIR / KICK
-- ═══════════════════════════════════════════════
LocalPlayer.AncestryChanged:Connect(function()
    pcall(function()
        _G.ZenithHubLoaded = false
        if type(Universal.Cleanup)   == "function" then Universal.Cleanup() end
        if type(GameModule.Cleanup)  == "function" then GameModule.Cleanup() end
        if type(Config.Save) == "function" then Config.Save(Config, cfg) end
        print("[ZenithHub] Limpeza concluída.")
    end)
end)

print(string.format("[%s] v%s — Carregado com sucesso!", HUB_NAME, HUB_VERSION))
