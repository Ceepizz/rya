local Globals = getgenv()

local CoreGui = game:GetService("CoreGui")

local AntiLagRunning = false
local LunaUIConnection = nil

local function RemoveLunaUI()
    local RobloxGui =
        CoreGui:FindFirstChild("RobloxGui")

    if not RobloxGui then
        return
    end

    local direct =
        RobloxGui:FindFirstChild("Luna UI")

    if direct then
        direct:Destroy()
    end

    for _, object in ipairs(
        RobloxGui:GetDescendants()
    ) do
        if object.Name == "Luna UI" then
            object:Destroy()
        end
    end
end

local function StartAntiLag()
    if AntiLagRunning or not Globals.AntiLag then
        return
    end

    AntiLagRunning = true

    pcall(function()
        local userGameSettings =
            UserSettings():GetService("UserGameSettings")

        userGameSettings.SavedQualityLevel =
            Enum.SavedQualitySetting.QualityLevel1
    end)

    pcall(function()
        settings().Rendering.QualityLevel =
            Enum.QualityLevel.Level01
    end)

    RemoveLunaUI()

    if LunaUIConnection then
        LunaUIConnection:Disconnect()
        LunaUIConnection = nil
    end

    LunaUIConnection =
        CoreGui.DescendantAdded:Connect(function(object)
            task.defer(function()
                if not object
                    or not object.Parent then
                    return
                end

                if object.Name == "Luna UI" then
                    object:Destroy()
                    return
                end

                task.wait(0.1)

                if object
                    and object.Parent
                    and object.Name == "Luna UI" then

                    object:Destroy()
                end
            end)
        end)

    task.spawn(function()
        while Globals.AntiLag do
            RemoveLunaUI()

            local towersFolder =
                workspace:FindFirstChild("Towers")

            local clientUnits =
                workspace:FindFirstChild("ClientUnits")

            if towersFolder then
                for _, tower in ipairs(
                    towersFolder:GetChildren()
                ) do
                    local animations =
                        tower:FindFirstChild("Animations")

                    local weapon =
                        tower:FindFirstChild("Weapon")

                    local projectiles =
                        tower:FindFirstChild("Projectiles")

                    if animations then
                        animations:Destroy()
                    end

                    if projectiles then
                        projectiles:Destroy()
                    end

                    if weapon then
                        weapon:Destroy()
                    end
                end
            end

            if clientUnits then
                for _, unit in ipairs(
                    clientUnits:GetChildren()
                ) do
                    unit:Destroy()
                end
            end

            task.wait(0.2)
        end

        if LunaUIConnection then
            LunaUIConnection:Disconnect()
            LunaUIConnection = nil
        end

        AntiLagRunning = false
    end)
end

return StartAntiLag
