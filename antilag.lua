local Globals = getgenv()

local CoreGui = game:GetService("CoreGui")

local AntiLagRunning = false

--------------------------------------------------
-- LUNA UI HIDER
--------------------------------------------------

local LockedGuiObjects =
    setmetatable({}, {__mode = "k"})

local function LockGuiObject(object)
    if LockedGuiObjects[object] then
        return
    end

    if object:IsA("ScreenGui") then
        LockedGuiObjects[object] = true

        object.Enabled = false

        object
            :GetPropertyChangedSignal("Enabled")
            :Connect(function()
                if object.Enabled then
                    object.Enabled = false
                end
            end)

    elseif object:IsA("GuiObject") then
        LockedGuiObjects[object] = true

        object.Visible = false

        object
            :GetPropertyChangedSignal("Visible")
            :Connect(function()
                if object.Visible then
                    object.Visible = false
                end
            end)
    end
end

local function HideLunaUI(LunaUI)
    LockGuiObject(LunaUI)

    for _, object in ipairs(
        LunaUI:GetDescendants()
    ) do
        LockGuiObject(object)
    end

    LunaUI.DescendantAdded:Connect(function(object)
        task.defer(function()
            LockGuiObject(object)
        end)
    end)
end

local function WatchRobloxGui(RobloxGui)
    local LunaUI =
        RobloxGui:FindFirstChild("Luna UI")

    if LunaUI then
        HideLunaUI(LunaUI)
    end

    RobloxGui.ChildAdded:Connect(function(child)
        if child.Name == "Luna UI" then
            task.defer(function()
                HideLunaUI(child)
            end)
        end
    end)
end

local RobloxGui =
    CoreGui:FindFirstChild("RobloxGui")

if RobloxGui then
    WatchRobloxGui(RobloxGui)
end

CoreGui.ChildAdded:Connect(function(child)
    if child.Name == "RobloxGui" then
        task.defer(function()
            WatchRobloxGui(child)
        end)
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
