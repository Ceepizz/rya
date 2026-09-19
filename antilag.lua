local Globals = getgenv()

local CoreGui = game:GetService("CoreGui")

--------------------------------------------------
-- PERMANENT LUNA UI KILLER
--------------------------------------------------

task.spawn(function()
    while true do
        pcall(function()
            game:GetService("CoreGui")
                .RobloxGui["Luna UI"]
                :Destroy()
        end)

        task.wait(5)
    end
end)

--------------------------------------------------
-- ANTI LAG
--------------------------------------------------

local AntiLagRunning = false

local function StartAntiLag()
    if AntiLagRunning then
        return
    end

    if not Globals.AntiLag then
        return
    end

    AntiLagRunning = true

    pcall(function()
        UserSettings()
            :GetService("UserGameSettings")
            .SavedQualityLevel =
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

            local clientUnits =
                workspace:FindFirstChild("ClientUnits")

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
