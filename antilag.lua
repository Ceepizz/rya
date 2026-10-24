local Globals = getgenv()

local AntiLagRunning = false
local Connections = {}
local OriginalEffects = {}
local OriginalEmitters = {}

local LOBBY_PLACE_ID = 3260590327

local function ApplyNoFog()
    if game.PlaceId == LOBBY_PLACE_ID then
        return
    end

    local lighting = game:GetService("Lighting")
    lighting.FogEnd = 100000

    for _, descendant in ipairs(lighting:GetDescendants()) do
        if descendant:IsA("Atmosphere") then
            descendant:Destroy()
        end
    end
end

local function HideInstance(descendant)
    if descendant:IsA("BasePart") then
        descendant.LocalTransparencyModifier = 1
        descendant.CastShadow = false
    elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
        descendant.Transparency = 1
    elseif descendant:IsA("Highlight") then
        descendant.Enabled = false
    elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") then
        descendant.Enabled = false
    elseif descendant:IsA("BillboardGui") or descendant:IsA("SurfaceGui") then
        descendant.Enabled = false
    end
end

local function HideModel(model)
    if not model or not model:IsA("Model") then return end
    for _, descendant in ipairs(model:GetDescendants()) do
        HideInstance(descendant)
    end
end

local function HookEffectsController()
    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local EffectsController = require(ReplicatedStorage.Client.Controllers.Game.EffectsController)

        local methodsToMute = {
            "NewDamageIndicator",
            "IndicateDamage",
            "Projectile",
            "Explosion",
            "SmallExplosion",
            "BigExplosion",
            "IceExplosion",
            "HolyExplosion",
            "BloodDrop",
            "Impale",
            "GroundSmash",
            "CreateVines",
            "Radius",
            "StunRaidus",
            "Cash"
        }

        for _, methodName in ipairs(methodsToMute) do
            if EffectsController[methodName] and not OriginalEffects[methodName] then
                OriginalEffects[methodName] = EffectsController[methodName]
                EffectsController[methodName] = function(...)
                    if Globals.AntiLag then
                        return
                    end
                    return OriginalEffects[methodName](...)
                end
            end
        end
    end)
end

local function HookEmitterManager()
    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local EmitterManager = require(ReplicatedStorage.Shared.Modules.EmitterManager)

        local emitterMethods = {
            "Emit",
            "emitParticle",
            "manualEmit"
        }

        for _, methodName in ipairs(emitterMethods) do
            if EmitterManager[methodName] and not OriginalEmitters[methodName] then
                OriginalEmitters[methodName] = EmitterManager[methodName]
                EmitterManager[methodName] = function(...)
                    if Globals.AntiLag then
                        return
                    end
                    return OriginalEmitters[methodName](...)
                end
            end
        end
    end)
end

local function RestoreHooks()
    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local EffectsController = require(ReplicatedStorage.Client.Controllers.Game.EffectsController)

        for methodName, originalFunc in pairs(OriginalEffects) do
            EffectsController[methodName] = originalFunc
        end
        table.clear(OriginalEffects)
    end)

    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local EmitterManager = require(ReplicatedStorage.Shared.Modules.EmitterManager)

        for methodName, originalFunc in pairs(OriginalEmitters) do
            EmitterManager[methodName] = originalFunc
        end
        table.clear(OriginalEmitters)
    end)
end

local function StartAntiLag()
    if AntiLagRunning or not Globals.AntiLag then
        return
    end

    AntiLagRunning = true

    pcall(function()
        local userGameSettings = UserSettings():GetService("UserGameSettings")
        userGameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
    end)

    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)

    pcall(function()
        game:GetService("Lighting").GlobalShadows = false
    end)

    pcall(ApplyNoFog)

    HookEffectsController()
    HookEmitterManager()

    local npcsFolder = workspace:FindFirstChild("NPCs")
    if npcsFolder then
        for _, enemy in ipairs(npcsFolder:GetChildren()) do
            HideModel(enemy)
        end

        table.insert(Connections, npcsFolder.DescendantAdded:Connect(function(descendant)
            if Globals.AntiLag then
                HideInstance(descendant)
            end
        end))
    end

    table.insert(Connections, workspace.Terrain.ChildAdded:Connect(function(child)
        if Globals.AntiLag and child.Name == "DamageIndicator" then
            child:Destroy()
        end
    end))

    task.spawn(function()
        while Globals.AntiLag do
            pcall(ApplyNoFog)

            local towersFolder = workspace:FindFirstChild("Towers")
            if towersFolder then
                for _, tower in ipairs(towersFolder:GetChildren()) do
                    local animations = tower:FindFirstChild("Animations")
                    local weapon = tower:FindFirstChild("Weapon")
                    local projectiles = tower:FindFirstChild("Projectiles")

                    if animations then animations:Destroy() end
                    if weapon then weapon:Destroy() end
                    if projectiles then projectiles:Destroy() end
                end
            end

            local clientUnits = workspace:FindFirstChild("ClientUnits")
            if clientUnits then
                for _, unit in ipairs(clientUnits:GetChildren()) do
                    unit:Destroy()
                end
            end

            local trash = workspace:FindFirstChild("Trash")
            if trash then
                trash:ClearAllChildren()
            end

            local lightning = workspace:FindFirstChild("LightningStorage")
            if lightning then
                lightning:ClearAllChildren()
            end

            for _, child in ipairs(workspace.Terrain:GetChildren()) do
                if child.Name == "DamageIndicator" then
                    child:Destroy()
                end
            end

            task.wait(0.5)
        end

        for _, conn in ipairs(Connections) do
            conn:Disconnect()
        end
        table.clear(Connections)

        RestoreHooks()
        AntiLagRunning = false
    end)
end

return StartAntiLag
