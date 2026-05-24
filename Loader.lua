--[[
    ZenithHub - Loader.lua (Optimizado)
]]

-- ════════════════════════════════
-- GLOBAL GUARD
-- ════════════════════════════════

local ENV = getgenv and getgenv() or _G
ENV.ZenithHub = ENV.ZenithHub or {}

if ENV.ZenithHub.Loading then
    warn("[ZenithHub] Loader já ativo.")
    return
end

ENV.ZenithHub.Loading = true

-- ════════════════════════════════
-- CONFIG
-- ════════════════════════════════

local CONFIG = {
    UseLocal = false,

    RemoteBase = "https://raw.githubusercontent.com/Pixelpv/Zenith-Hub/main/",

    LocalBase = "ZenithHub/",

    Files = {
        "Config.lua",
        "Modules/Universal.lua",
        "Modules/BloxFruits.lua",
        "UI.lua",
        "Main.lua",
    }
}

-- ════════════════════════════════
-- SERVICES
-- ════════════════════════════════

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

-- ════════════════════════════════
-- LOG SYSTEM
-- ════════════════════════════════

local function log(msg)
    print("[ZenithHub] " .. msg)
end

local function notify(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Zenith Hub",
            Text = msg,
            Duration = 4
        })
    end)
    log(msg)
end

-- ════════════════════════════════
-- EXECUTOR DETECTION
-- ════════════════════════════════

local function getExecutor()
    local execs = {
        syn = syn,
        fluxus = fluxus,
        krnl = identifyexecutor and identifyexecutor()
    }

    if syn then return "Synapse-like" end
    if fluxus then return "Fluxus" end
    if identifyexecutor then return identifyexecutor() end

    return "Unknown"
end

local function hasFileAPI()
    return typeof(readfile) == "function"
        and typeof(writefile) == "function"
        and typeof(isfile) == "function"
        and typeof(makefolder) == "function"
end

-- ═══════════════════════════════════════════════
-- HTTP REQUEST WRAPPER (IMPORTANTE)
-- ═══════════════════════════════════════════════

local function httpGet(url)
    if syn and syn.request then
        return syn.request({Url = url, Method = "GET"}).Body
    elseif http_request then
        return http_request({Url = url, Method = "GET"}).Body
    elseif request then
        return request({Url = url, Method = "GET"}).Body
    else
        return game:HttpGet(url)
    end
end

-- ═══════════════════════════════════════════════
-- FOLDERS
-- ═══════════════════════════════════════════════

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

-- ═══════════════════════════════════════════════
-- DOWNLOAD SYSTEM (OTIMIZADO)
-- ═══════════════════════════════════════════════

local function downloadFiles()
    notify("Baixando arquivos...")

    for _, file in ipairs(CONFIG.Files) do
        local url = CONFIG.RemoteBase .. file
        local path = CONFIG.LocalBase .. file

        local ok, err = pcall(function()
            local content = httpGet(url)

            if not content or content == "" then
                error("Arquivo vazio: " .. file)
            end

            writefile(path, content)
        end)

        if not ok then
            warn("[ZenithHub] Falha: " .. file, err)
            notify("Erro: " .. file)
            return false
        end
    end

    return true
end

-- ═══════════════════════════════════════════════
-- FILE CHECK
-- ═══════════════════════════════════════════════

local function checkFiles()
    for _, file in ipairs(CONFIG.Files) do
        local path = CONFIG.LocalBase .. file
        if not isfile(path) then
            return false, file
        end
    end
    return true
end

-- ═══════════════════════════════════════════════
-- START HUB
-- ═══════════════════════════════════════════════

local function start()
    createFolders()

    if not CONFIG.UseLocal then
        local ok = downloadFiles()
        if not ok then
            ENV.ZenithHub.Loading = false
            return
        end
    end

    local ok, missing = checkFiles()
    if not ok then
        warn("[ZenithHub] Missing file: " .. tostring(missing))
        notify("Arquivos faltando")
        ENV.ZenithHub.Loading = false
        return
    end

    notify("Iniciando hub...")

    local success, err = pcall(function()
        local source = readfile(CONFIG.LocalBase .. "Main.lua")

        local func, compileErr = loadstring(source)
        if not func then
            error(compileErr)
        end

        return func()
    end)

    if not success then
        warn("[ZenithHub] Crash:", err)
        notify("Erro ao iniciar hub")
        ENV.ZenithHub.Loading = false
        return
    end

    notify("Zenith Hub carregado!")
    ENV.ZenithHub.Loading = false
end

-- ═══════════════════════════════════════════════
-- BOOT CHECK
-- ═══════════════════════════════════════════════

if not hasFileAPI() then
    notify("Executor incompatível (file API)")
    ENV.ZenithHub.Loading = false
    return
end

log("Executor: " .. getExecutor())

if not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end

task.wait(0.8)

task.spawn(start)
