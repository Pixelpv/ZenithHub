--[[
    ZenithHub - Modules/Universal.lua
    Módulo Universal: funções que funcionam em qualquer jogo
    Fly, Speed, NoClip, InfiniteJump, etc.
]]

local Universal = {}

-- ════════════════════════════════════════════
-- SERVIÇOS
-- ════════════════════════════════════════════
local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService    = game:GetService("TweenService")
local Workspace       = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

-- ════════════════════════════════════════════
-- ESTADO INTERNO
-- ════════════════════════════════════════════
local State = {
    Flying       = false,
    NoClip       = false,
    InfiniteJump = false,
    FPSBoost     = false,
    Connections  = {},
    FlyBody      = nil,
    FlyGyro      = nil,
}

-- ════════════════════════════════════════════
-- UTILITÁRIOS
-- ════════════════════════════════════════════

local function getCharacter()
    return LocalPlayer.Character
end

local function getHRP()
    local char = getCharacter()
    if char then return char:FindFirstChild("HumanoidRootPart") end
end

local function getHumanoid()
    local char = getCharacter()
    if char then return char:FindFirstChildOfClass("Humanoid") end
end

local function disconnect(name)
    if State.Connections[name] then
        pcall(function() State.Connections[name]:Disconnect() end)
        State.Connections[name] = nil
    end
end

-- ════════════════════════════════════════════
-- SPEED
-- ════════════════════════════════════════════

function Universal.SetSpeed(value)
    local ok, err = pcall(function()
        local hum = getHumanoid()
        if hum then
            hum.WalkSpeed = value
        end
    end)
    if not ok then warn("[Universal] SetSpeed erro: " .. tostring(err)) end
end

-- ════════════════════════════════════════════
-- FLY
-- ════════════════════════════════════════════

function Universal.SetFly(enabled)
    local ok, err = pcall(function()
        if enabled then
            if State.Flying then return end
            State.Flying = true

            local hrp = getHRP()
            if not hrp then return end

            -- Body Velocity
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bv.Parent = hrp
            State.FlyBody = bv

            -- Body Gyro
            local bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            bg.P = 1e4
            bg.CFrame = hrp.CFrame
            bg.Parent = hrp
            State.FlyGyro = bg

            local hum = getHumanoid()
            if hum then hum.PlatformStand = true end

            State.Connections["Fly"] = RunService.Heartbeat:Connect(function()
                local hrpNow = getHRP()
                if not hrpNow or not State.Flying then return end

                local speed = 50
                local moveVec = Vector3.new(0, 0, 0)
                local camCF   = Camera.CFrame

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveVec = moveVec + camCF.LookVector * speed
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveVec = moveVec - camCF.LookVector * speed
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveVec = moveVec - camCF.RightVector * speed
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveVec = moveVec + camCF.RightVector * speed
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveVec = moveVec + Vector3.new(0, speed, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    moveVec = moveVec - Vector3.new(0, speed, 0)
                end

                bv.Velocity = moveVec
                bg.CFrame = CFrame.new(hrpNow.Position, hrpNow.Position + camCF.LookVector)
            end)
        else
            State.Flying = false
            disconnect("Fly")
            if State.FlyBody  then State.FlyBody:Destroy()  State.FlyBody  = nil end
            if State.FlyGyro  then State.FlyGyro:Destroy()  State.FlyGyro  = nil end
            local hum = getHumanoid()
            if hum then hum.PlatformStand = false end
        end
    end)
    if not ok then warn("[Universal] SetFly erro: " .. tostring(err)) end
end

-- ════════════════════════════════════════════
-- NO CLIP
-- ════════════════════════════════════════════

function Universal.SetNoClip(enabled)
    local ok, err = pcall(function()
        if enabled then
            State.NoClip = true
            State.Connections["NoClip"] = RunService.Stepped:Connect(function()
                if not State.NoClip then return end
                local char = getCharacter()
                if not char then return end
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end)
        else
            State.NoClip = false
            disconnect("NoClip")
            local char = getCharacter()
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end)
    if not ok then warn("[Universal] SetNoClip erro: " .. tostring(err)) end
end

-- ════════════════════════════════════════════
-- INFINITE JUMP
-- ════════════════════════════════════════════

function Universal.SetInfiniteJump(enabled)
    local ok, err = pcall(function()
        if enabled then
            State.InfiniteJump = true
            State.Connections["InfJump"] = UserInputService.JumpRequest:Connect(function()
                if not State.InfiniteJump then return end
                local hum = getHumanoid()
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        else
            State.InfiniteJump = false
            disconnect("InfJump")
        end
    end)
    if not ok then warn("[Universal] InfiniteJump erro: " .. tostring(err)) end
end

-- ════════════════════════════════════════════
-- FPS BOOST
-- ════════════════════════════════════════════

function Universal.SetFPSBoost(enabled)
    local ok, err = pcall(function()
        if enabled then
            State.FPSBoost = true
            -- Reduz qualidade de renderização para melhorar FPS
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            -- Remove partículas e efeitos pesados
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
                    v.Enabled = false
                end
            end
        else
            State.FPSBoost = false
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
                    v.Enabled = true
                end
            end
        end
    end)
    if not ok then warn("[Universal] FPSBoost erro: " .. tostring(err)) end
end

-- ════════════════════════════════════════════
-- TWEEN TELEPORT
-- ════════════════════════════════════════════

function Universal.TweenTo(position, duration)
    local ok, err = pcall(function()
        duration = duration or 1.5
        local hrp = getHRP()
        if not hrp then return end

        local goal = { CFrame = CFrame.new(position) }
        local info  = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(hrp, info, goal)
        tween:Play()
    end)
    if not ok then warn("[Universal] TweenTo erro: " .. tostring(err)) end
end

function Universal.TeleportTo(position)
    local ok, err = pcall(function()
        local hrp = getHRP()
        if hrp then
            hrp.CFrame = CFrame.new(position)
        end
    end)
    if not ok then warn("[Universal] TeleportTo erro: " .. tostring(err)) end
end

-- ════════════════════════════════════════════
-- SERVER HOP
-- ════════════════════════════════════════════

function Universal.ServerHop()
    local ok, err = pcall(function()
        local TeleportService = game:GetService("TeleportService")
        local placeId = game.PlaceId
        TeleportService:Teleport(placeId, LocalPlayer)
    end)
    if not ok then warn("[Universal] ServerHop erro: " .. tostring(err)) end
end

-- ════════════════════════════════════════════
-- REJOIN
-- ════════════════════════════════════════════

function Universal.Rejoin()
    local ok, err = pcall(function()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
    if not ok then warn("[Universal] Rejoin erro: " .. tostring(err)) end
end

-- ════════════════════════════════════════════
-- LIMPEZA GERAL
-- ════════════════════════════════════════════

function Universal.Cleanup()
    Universal.SetFly(false)
    Universal.SetNoClip(false)
    Universal.SetInfiniteJump(false)
    Universal.SetFPSBoost(false)
    for name, conn in pairs(State.Connections) do
        pcall(function() conn:Disconnect() end)
        State.Connections[name] = nil
    end
end

return Universal
