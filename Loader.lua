--[[
    ZenithHub - Loader.lua
    Loader remoto/local corrigido
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
-- CONFIGURAÇÃO
-- ════════════════════════════════════════════

local LOADER_CONFIG = {

    -- false = baixa do GitHub automaticamente
    -- true = usa arquivos já existentes no executor
    UseLocal = false,

    -- LINK RAW DO GITHUB
    RemoteBase = "https://raw.githubusercontent.com/Pixelpv/Zenith-Hub/main/",

    -- Arquivos necessários
    Files = {
        "Config.lua",
        "Modules/Universal.lua",
        "Modules/BloxFruits.lua",
        "UI.lua",
        "Main.lua",
    },

    -- Pasta local
    LocalBase = "ZenithHub/",
}

-- ════════════════════════════════════════════
-- SERVIÇOS
-- ════════════════════════════════════════════

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

-- ════════════════════════════════════════════
-- NOTIFICAÇÃO
-- ════════════════════════════════════════════

local function notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Zenith Hub",
            Text = text,
            Duration = 5
        })
    end)

    print("[ZenithHub] " .. text)
end

-- ════════════════════════════════════════════
-- VERIFICAR EXECUTOR
-- ════════════════════════════════════════════

local function checkExecutor()

    local required = {
        "loadstring",
        "readfile",
        "writefile",
        "isfile",
        "makefolder"
    }

    local missing = {}

    for _, func in ipairs(required) do
        if type(getgenv()[func]) ~= "function" then
            table.insert(missing, func)
        end
    end

    if #missing > 0 then
        warn("[ZenithHub] Funções faltando: " .. table.concat(missing, ", "))
        return false
    end

    return true
end

-- ════════════════════════════════════════════
-- CRIAR PASTAS
-- ════════════════════════════════════════════

local function createFolders()

    local folders = {
        "ZenithHub",
        "ZenithHub/Modules",
        "ZenithHub/Assets"
    }

    for _, folder in ipairs(folders) do

        if makefolder and not isfolder(folder) then
            pcall(function()
                makefolder(folder)
            end)
        end
    end
end

-- ════════════════════════════════════════════
-- DOWNLOAD DOS ARQUIVOS
-- ════════════════════════════════════════════

local function downloadFiles()

    notify("Baixando arquivos...")

    for _, file in ipairs(LOADER_CONFIG.Files) do

        local url = LOADER_CONFIG.RemoteBase .. file
        local path = LOADER_CONFIG.LocalBase .. file

        local success, result = pcall(function()

            local content = game:HttpGet(url)

            if not content or content == "" then
                error("Arquivo vazio")
            end

            writefile(path, content)
        end)

        if success then
            print("[ZenithHub] Baixado -> " .. file)
        else
            warn("[ZenithHub] Erro ao baixar " .. file)
            warn(result)

            notify("Erro ao baixar: " .. file)

            return false
        end

        task.wait(0.1)
    end

    return true
end

-- ════════════════════════════════════════════
-- VERIFICAR ARQUIVOS
-- ════════════════════════════════════════════

local function checkFiles()

    for _, file in ipairs(LOADER_CONFIG.Files) do

        local path = LOADER_CONFIG.LocalBase .. file

        if not isfile(path) then
            return false, path
        end
    end

    return true
end

-- ════════════════════════════════════════════
-- INICIAR HUB
-- ════════════════════════════════════════════

local function startHub()

    createFolders()

    if not LOADER_CONFIG.UseLocal then

        local ok = downloadFiles()

        if not ok then
            _G.ZenithHubLoading = false
            return
        end
    end

    local filesOk, missing = checkFiles()

    if not filesOk then

        warn("[ZenithHub] Arquivo não encontrado: " .. tostring(missing))

        notify("Arquivo faltando")

        _G.ZenithHubLoading = false
        return
    end

    notify("Iniciando Zenith Hub...")

    local success, err = pcall(function()

        local source = readfile("ZenithHub/Main.lua")

        local func, compileError = loadstring(source)

        if not func then
            error(compileError)
        end

        func()
    end)

    if not success then

        warn("[ZenithHub] Erro ao iniciar:")
        warn(err)

        notify("Erro ao iniciar hub")

        _G.ZenithHubLoading = false
        return
    end

    notify("Hub carregado!")

    _G.ZenithHubLoading = false
end

-- ════════════════════════════════════════════
-- START
-- ════════════════════════════════════════════

if not checkExecutor() then

    notify("Executor incompatível")

    _G.ZenithHubLoading = false

    return
end

local LocalPlayer = Players.LocalPlayer

if not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end

task.wait(1)

task.spawn(startHub)
