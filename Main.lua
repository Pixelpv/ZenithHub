--[[
    ZenithHub - Main.lua
    Ponto de entrada principal do hub
    Inicializa módulos, config e UI
]]

-- ════════════════════════════════════════════
-- PROTEÇÃO ANTI-DUPLICATA
-- ════════════════════════════════════════════
if _G.ZenithHubLoaded then
    warn("[ZenithHub] Hub já está carregado! Ignorando reinicialização.")
    return
end
_G.ZenithHubLoaded = true

-- ════════════════════════════════════════════
-- INFORMAÇÕES DO HUB
-- ════════════════════════════════════════════
local HUB_NAME    = "Zenith Hub"
local HUB_VERSION = "1.0.0"
local HUB_AUTHOR  = "ZenithDev"

print(string.format("[%s] v%s by %s - Inicializando...", HUB_NAME, HUB_VERSION, HUB_AUTHOR))

-- ════════════════════════════════════════════
-- SERVIÇOS
-- ════════════════════════════════════════════
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ════════════════════════════════════════════
-- DETECÇÃO DE PLATAFORMA
-- ════════════════════════════════════════════
local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

print("[ZenithHub] Plataforma: " .. (isMobile and "Mobile" or "PC"))

-- ════════════════════════════════════════════
-- CARREGAMENTO DE MÓDULOS LOCAIS
-- ════════════════════════════════════════════
-- Em ambiente de executor, use loadstring(readfile(...)) para carregar arquivos locais.
-- Aqui usamos require() para compatibilidade com ambiente de desenvolvimento.

local function safeLoad(path, fallback)
    local ok, result = pcall(function()
        -- Tenta via readfile (executor)
        if readfile then
            local src = readfile(path)
            return loadstring(src)()
        end
        -- Fallback: require (dev)
        return require(path)
    end)
    if ok and result then
        return result
    else
        warn("[ZenithHub] Falha ao carregar " .. path .. ": " .. tostring(result))
        return fallback or {}
    end
end

-- Diretório base (ajuste se necessário)
local BASE = "ZenithHub/"

local Config     = safeLoad(BASE .. "Config.lua",         {})
local Universal  = safeLoad(BASE .. "Modules/Universal.lua", {})
local UI         = safeLoad(BASE .. "UI.lua",             {})

-- ════════════════════════════════════════════
-- DETECÇÃO DE JOGO (MULTI GAME SYSTEM)
-- ════════════════════════════════════════════

-- IDs de Place conhecidos para Blox Fruits
local BLOX_FRUITS_PLACE_IDS = {
    [2753915549] = true,  -- Blox Fruits (Principal)
    [4442272298] = true,  -- Blox Fruits (Versão alternativa)
}

local currentPlaceId = game.PlaceId
local isBloxFruits   = BLOX_FRUITS_PLACE_IDS[currentPlaceId] ~= nil

print("[ZenithHub] Place ID: " .. tostring(currentPlaceId))
print("[ZenithHub] Jogo: " .. (isBloxFruits and "Blox Fruits ✓" or "Universal"))

-- Carrega módulo do jogo correto
local GameModule

if isBloxFruits then
    GameModule = safeLoad(BASE .. "Modules/BloxFruits.lua", {})
    print("[ZenithHub] Módulo Blox Fruits carregado.")
else
    -- Para outros jogos, usa módulo Universal básico
    GameModule = {}
    print("[ZenithHub] Módulo Universal ativado (jogo não suportado especificamente).")
end

-- ════════════════════════════════════════════
-- CARREGAMENTO DE CONFIG
-- ════════════════════════════════════════════

local cfg = Config.Load()
print("[ZenithHub] Config carregada.")

-- ════════════════════════════════════════════
-- PACOTE DE MÓDULOS
-- ════════════════════════════════════════════

local Modules = {
    BloxFruits = GameModule,
    Universal  = Universal,
    Config     = Config,
}

-- ════════════════════════════════════════════
-- INICIALIZAÇÃO DA UI
-- ════════════════════════════════════════════

local ok, err = pcall(function()
    UI.Init(Modules, cfg, Config.Assets)
end)

if not ok then
    warn("[ZenithHub] Falha ao inicializar UI: " .. tostring(err))
    _G.ZenithHubLoaded = false
    return
end

-- ════════════════════════════════════════════
-- SALVAMENTO AUTOMÁTICO DE CONFIG (a cada 60s)
-- ════════════════════════════════════════════

task.spawn(function()
    while _G.ZenithHubLoaded do
        task.wait(60)
        local saveOk, saveErr = pcall(function()
            Config.Save(cfg)
        end)
        if not saveOk then
            warn("[ZenithHub] Autosave falhou: " .. tostring(saveErr))
        end
    end
end)

-- ════════════════════════════════════════════
-- LIMPEZA AO SAIR
-- ════════════════════════════════════════════

LocalPlayer.AncestryChanged:Connect(function()
    pcall(function()
        _G.ZenithHubLoaded = false
        Universal.Cleanup()
        if GameModule and GameModule.Cleanup then
            GameModule.Cleanup()
        end
        Config.Save(cfg)
        print("[ZenithHub] Limpeza realizada.")
    end)
end)

print(string.format("[%s] v%s - Carregado com sucesso!", HUB_NAME, HUB_VERSION))
