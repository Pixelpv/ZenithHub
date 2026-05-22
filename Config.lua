--[[
    ZenithHub - Config.lua
    Sistema de configuração e persistência
    Salva/carrega configs via writefile/readfile
]]

local Config = {}

-- ════════════════════════════════════════════
-- ASSETS (substitua pelos seus Asset IDs)
-- ════════════════════════════════════════════
Config.Assets = {
    HubLogo   = "rbxassetid://7733960981",
    ToggleLogo = "rbxassetid://7733960981",
    Icon_Farm  = "rbxassetid://10734950468",
    Icon_Stats = "rbxassetid://10734918743",
    Icon_Dungeon = "rbxassetid://10734918111",
    Icon_Sea   = "rbxassetid://10734916823",
    Icon_Race  = "rbxassetid://10734915942",
    Icon_Shop  = "rbxassetid://10734914673",
    Icon_Config = "rbxassetid://10734912831",
}

-- ════════════════════════════════════════════
-- CONFIGURAÇÕES PADRÃO
-- ════════════════════════════════════════════
Config.Defaults = {
    -- Main / Auto Farm
    AutoFarm         = false,
    AutoQuest        = false,
    BringMob         = false,
    KillAura         = false,
    FastAttack       = false,
    AutoHaki         = false,
    AutoBoss         = false,

    -- Stats / Teleports
    AutoStats        = false,
    TweenTeleport    = true,
    Speed            = 16,
    Fly              = false,
    NoClip           = false,
    InfiniteJump     = false,

    -- Dungeon / Raids
    AutoRaid         = false,
    AutoDungeon      = false,
    AutoChipBuy      = false,
    AutoAwaken       = false,

    -- Sea Events
    LeviathanHunt    = false,
    SeaBeastFarm     = false,
    MirageDetection  = false,
    TerrorSharkESP   = false,
    EventESP         = false,

    -- Races / V4
    AutoRaceV4       = false,
    AutoTrial        = false,
    SelectedRace     = "Human",
    AutoGear         = false,
    TempleTeleport   = false,

    -- Shop / Gacha
    FruitSniper      = false,
    AutoStoreFruit   = false,
    AutoBuyItems     = false,
    GachaBuy         = false,
    ShopESP          = false,

    -- Configs
    Theme            = "Dark",
    FPSBoost         = false,
    ServerHop        = false,
    SelectedSea      = "Sea 1",
    StatPriority     = "Melee",
}

-- ════════════════════════════════════════════
-- CAMINHO DO ARQUIVO DE CONFIG
-- ════════════════════════════════════════════
local CONFIG_PATH = "ZenithHub_Config.json"

-- ════════════════════════════════════════════
-- FUNÇÕES DE SAVE / LOAD
-- ════════════════════════════════════════════

function Config.Save(data)
    local ok, err = pcall(function()
        local json = game:GetService("HttpService"):JSONEncode(data)
        writefile(CONFIG_PATH, json)
    end)
    if not ok then
        warn("[ZenithHub] Falha ao salvar config: " .. tostring(err))
    end
end

function Config.Load()
    local ok, result = pcall(function()
        if isfile(CONFIG_PATH) then
            local json = readfile(CONFIG_PATH)
            return game:GetService("HttpService"):JSONDecode(json)
        end
        return nil
    end)
    if ok and result then
        -- Mescla defaults com o salvo (garante novas chaves)
        for k, v in pairs(Config.Defaults) do
            if result[k] == nil then
                result[k] = v
            end
        end
        return result
    else
        -- Retorna cópia dos defaults
        local copy = {}
        for k, v in pairs(Config.Defaults) do
            copy[k] = v
        end
        return copy
    end
end

function Config.Reset()
    local copy = {}
    for k, v in pairs(Config.Defaults) do
        copy[k] = v
    end
    if isfile(CONFIG_PATH) then
        pcall(delfile, CONFIG_PATH)
    end
    return copy
end

return Config
