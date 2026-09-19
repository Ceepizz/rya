local Globals = getgenv()

local AntiLagRunning = false

--------------------------------------------------
-- LUNA UI DESTROYER
--------------------------------------------------

task.spawn(function()
    while true do
        pcall(function()
            local RobloxGui =
                game:GetService("CoreGui"):FindFirstChild("RobloxGui")

            if RobloxGui then
                local LunaUI =
                    RobloxGui:FindFirstChild("Luna UI")

                if LunaUI then
                    LunaUI:Destroy()
                end
            end
        end)

        task.wait(0.1)
    end
end)

--------------------------------------------------
-- ANTI LAG
--------------------------------------------------

local function StartAntiLag()
    if AntiLagRunning
        or not Globals.AntiLag then

        return
    end

    AntiLagRunning = true

    pcall(function()
        local userGameSettings =
            UserSettings():GetService(
                "UserGameSettings"
            )

        userGameSettings.SavedQualityLevel =
            Enum.SavedQualitySetting.QualityLevel1
    end)

    pcall(function()
        settings().Rendering.QualityLevel =
            Enum.QualityLevel.Level01
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

                    if weapon then
                        weapon:Destroy()
                    end

                    if projectiles then
                        projectiles:Destroy()
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

        AntiLagRunning = false
    end)
end

return StartAntiLag
