--[[
    ZenithHub - Loader.lua
    Script de carregamento remoto
    Cole este arquivo no executor para iniciar o hub

    COMO USAR:
    - Opção 1 (remoto via GitHub/CDN):
        loadstring(game:HttpGet("https://raw.githubusercontent.com/SEU_USER/ZenithHub/main/Loader.lua"))()

    - Opção 2 (local via executor):
        loadstring(readfile("ZenithHub/Loader.lua"))()
]]

-- ════════════════════════════════════════════
-- PROTEÇÃO ANTI-DUPLICATA
-- ════════════════════════════════════════════
if _G.ZenithHubLoading then
    warn("[ZenithHub Loader] Carregamento já em andamento.")
    return
end
_G.ZenithHubLoading = true

-- ════════════════════════════════════════════
-- CONFIGURAÇÃO DO LOADER
-- ════════════════════════════════════════════

local LOADER_CONFIG = {
    -- Altere para true para usar arquivos locais do executor
    UseLocal = true,

    -- URL base para carregamento remoto (GitHub raw ou CDN)
    -- Apenas usado se UseLocal = false
    RemoteBase = "https://raw.githubusercontent.com/SEU_USER/ZenithHub/main/",

    -- Arquivos a carregar (na ordem correta)
    Files = {
        "Config.lua",
        "Modules/Universal.lua",
        "Modules/BloxFruits.lua",
        "UI.lua",
        "Main.lua",
    },

    -- Pasta local (raiz onde os arquivos .lua estão)
    LocalBase = "ZenithHub/",
}

-- ════════════════════════════════════════════
-- UTILITÁRIOS
-- ════════════════════════════════════════════

local HttpService = game:GetService("HttpService")

-- Notificação simples via game (antes do Fluent carregar)
local function earlyNotify(msg)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title    = "Zenith Hub",
            Text     = msg,
            Duration = 4,
        })
    end)
    print("[ZenithHub] " .. msg)
end

-- Verifica compatibilidade com o executor
local function checkExecutor()
    local features = {
        writefile  = type(writefile)  == "function",
        readfile   = type(readfile)   == "function",
        isfile     = type(isfile)     == "function",
        loadstring = type(loadstring) == "function",
        HttpGet    = type(game.HttpGet) == "function" or
                     type(game["HttpGet"]) == "function",
    }

    local missing = {}
    for feat, has in pairs(features) do
        if not has then table.insert(missing, feat) end
    end

    if #missing > 0 then
        warn("[ZenithHub] Executor não suporta: " .. table.concat(missing, ", "))
        return false, missing
    end
    return true, {}
end

-- Cria pastas necessárias no executor
local function ensureFolders()
    local folders = {
        "ZenithHub",
        "ZenithHub/Modules",
        "ZenithHub/Assets",
    }
    for _, folder in ipairs(folders) do
        if makefolder and not isfolder(folder) then
            pcall(makefolder, folder)
        end
    end
end

-- ════════════════════════════════════════════
-- DOWNLOAD REMOTO (opcional)
-- ════════════════════════════════════════════

local function downloadFiles()
    earlyNotify("Baixando arquivos do Zenith Hub...")
    local success = true

    for _, file in ipairs(LOADER_CONFIG.Files) do
        local url = LOADER_CONFIG.RemoteBase .. file
        local localPath = LOADER_CONFIG.LocalBase .. file

        local ok, err = pcall(function()
            local content = game:HttpGet(url, true)
            writefile(localPath, content)
            print("[ZenithHub] Baixado: " .. file)
        end)

        if not ok then
            warn("[ZenithHub] Falha ao baixar " .. file .. ": " .. tostring(err))
            success = false
        end

        task.wait(0.1)
    end

    return success
end

-- ════════════════════════════════════════════
-- VERIFICAÇÃO DE ARQUIVOS LOCAIS
-- ════════════════════════════════════════════

local function checkLocalFiles()
    for _, file in ipairs(LOADER_CONFIG.Files) do
        local path = LOADER_CONFIG.LocalBase .. file
        if not isfile(path) then
            return false, path
        end
    end
    return true, nil
end

-- ════════════════════════════════════════════
-- CARREGAMENTO PRINCIPAL
-- ════════════════════════════════════════════

local function startHub()
    -- 1. Garante que pastas existam
    ensureFolders()

    -- 2. Verifica/baixa arquivos
    if not LOADER_CONFIG.UseLocal then
        local hasFiles, missingPath = checkLocalFiles()
        if not hasFiles then
            print("[ZenithHub] Arquivo faltando: " .. tostring(missingPath))
            local downloaded = downloadFiles()
            if not downloaded then
                earlyNotify("Falha ao baixar arquivos. Verifique a conexão.")
                _G.ZenithHubLoading = false
                return
            end
        end
    else
        -- Modo local: verifica se os arquivos existem
        local hasFiles, missingPath = checkLocalFiles()
        if not hasFiles then
            earlyNotify("Arquivo não encontrado: " .. tostring(missingPath))
            warn("[ZenithHub] Certifique-se de que os arquivos estão em: " .. LOADER_CONFIG.LocalBase)
            _G.ZenithHubLoading = false
            return
        end
    end

    -- 3. Carrega Main.lua (que inicializa tudo)
    earlyNotify("Iniciando Zenith Hub...")
    task.wait(0.2)

    local mainPath = LOADER_CONFIG.LocalBase .. "Main.lua"
    local ok, err = pcall(function()
        local src = readfile(mainPath)
        local fn, compileErr = loadstring(src, "ZenithHub/Main")
        if not fn then
            error("Compile error: " .. tostring(compileErr))
        end
        fn()
    end)

    if not ok then
        warn("[ZenithHub] Erro ao iniciar Main.lua: " .. tostring(err))
        earlyNotify("Erro ao carregar hub. Ver console.")
        _G.ZenithHubLoading = false
    else
        _G.ZenithHubLoading = false
        print("[ZenithHub] Loader concluído.")
    end
end

-- ════════════════════════════════════════════
-- ENTRY POINT
-- ════════════════════════════════════════════

-- Verificação de compatibilidade
local compatible, missingFeatures = checkExecutor()
if not compatible then
    earlyNotify("Executor incompatível. Faltam: " .. table.concat(missingFeatures, ", "))
    _G.ZenithHubLoading = false
    return
end

-- Aguarda personagem estar pronto
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end
task.wait(1)

-- Inicia em thread separada para não travar
task.spawn(startHub)
