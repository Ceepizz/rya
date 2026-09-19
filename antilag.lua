local Globals = getgenv()

local CoreGui = game:GetService("CoreGui")

local AntiLagRunning = false
local LunaUIConnection = nil

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

    pcall(function()
        local RobloxGui =
            CoreGui:WaitForChild("RobloxGui")

        local function RemoveLunaUI()
            local luna =
                RobloxGui:FindFirstChild("Luna UI")

            if luna then
                luna:Destroy()
            end
        end

        RemoveLunaUI()

        if LunaUIConnection then
            LunaUIConnection:Disconnect()
            LunaUIConnection = nil
        end

        LunaUIConnection =
            RobloxGui.ChildAdded:Connect(function(child)
                if child.Name == "Luna UI" then
                    child:Destroy()
                end
            end)
    end)

    task.spawn(function()
        while Globals.AntiLag do
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

            task.wait(0.5)
        end

        if LunaUIConnection then
            LunaUIConnection:Disconnect()
            LunaUIConnection = nil
        end

        AntiLagRunning = false
    end)
end

return StartAntiLag
