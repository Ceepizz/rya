local Globals = getgenv()

local CoreGui = game:GetService("CoreGui")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")

local AntiLagRunning = false

--------------------------------------------------
-- LUNA UI BLOCKER
-- Starts IMMEDIATELY when this module loads
--------------------------------------------------

local function DestroyLuna(object)
    if object
        and object.Parent
        and object.Name == "Luna UI" then

        pcall(function()
            object:Destroy()
        end)

        return true
    end

    return false
end

-- Delete it immediately if it already exists
local existingLuna =
    RobloxGui:FindFirstChild("Luna UI")

if existingLuna then
    DestroyLuna(existingLuna)
end

-- Catch objects that are already named Luna UI
RobloxGui.DescendantAdded:Connect(function(object)
    if DestroyLuna(object) then
        return
    end

    -- Some UIs get created first and renamed afterward
    local nameConnection

    nameConnection =
        object:GetPropertyChangedSignal("Name"):Connect(function()
            if not object.Parent then
                if nameConnection then
                    nameConnection:Disconnect()
                end

                return
            end

            if object.Name == "Luna UI" then
                DestroyLuna(object)

                if nameConnection then
                    nameConnection:Disconnect()
                end
            end
        end)
end)

-- Backup checker in case Luna gets inserted weirdly
task.spawn(function()
    while true do
        local luna =
            RobloxGui:FindFirstChild("Luna UI")

        if luna then
            DestroyLuna(luna)
        end

        task.wait(0.05)
    end
end)

--------------------------------------------------
-- ANTI LAG
--------------------------------------------------

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

            task.wait(0.2)
        end

        AntiLagRunning = false
    end)
end

return StartAntiLag
