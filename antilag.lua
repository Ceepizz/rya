local Globals = getgenv()

local CoreGui = game:GetService("CoreGui")

local AntiLagRunning = false

--------------------------------------------------
-- LUNA UI HIDER
--------------------------------------------------

local LockedGuiObjects =
    setmetatable({}, {__mode = "k"})

local WatchedLunaRoots =
    setmetatable({}, {__mode = "k"})

local function LockGuiObject(object)
    if LockedGuiObjects[object] then
        return
    end

    if object:IsA("ScreenGui") then
        LockedGuiObjects[object] = true

        object
            :GetPropertyChangedSignal("Enabled")
            :Connect(function()
                if object.Enabled then
                    object.Enabled = false
                end
            end)

        object.Enabled = false

    elseif object:IsA("GuiObject") then
        LockedGuiObjects[object] = true

        object
            :GetPropertyChangedSignal("Visible")
            :Connect(function()
                if object.Visible then
                    object.Visible = false
                end
            end)

        object.Visible = false
    end
end

local function HideLunaPass(LunaUI)
    LockGuiObject(LunaUI)

    for _, object in ipairs(
        LunaUI:GetDescendants()
    ) do
        LockGuiObject(object)
    end
end

local function HideLunaUI(LunaUI)
    if WatchedLunaRoots[LunaUI] then
        HideLunaPass(LunaUI)
        return
    end

    WatchedLunaRoots[LunaUI] = true

    LunaUI.DescendantAdded:Connect(function(object)
        LockGuiObject(object)
    end)

    HideLunaPass(LunaUI)

    task.delay(1, function()
        if LunaUI.Parent then
            HideLunaPass(LunaUI)
        end
    end)
end

local function WatchRobloxGui(RobloxGui)
    local function CheckLuna()
        for _, child in ipairs(
            RobloxGui:GetChildren()
        ) do
            if child.Name == "Luna UI" then
                HideLunaUI(child)
            end
        end
    end

    RobloxGui.ChildAdded:Connect(function(child)
        if child.Name == "Luna UI" then
            HideLunaUI(child)
        end
    end)

    CheckLuna()

    task.delay(1, CheckLuna)
end

local RobloxGui =
    CoreGui:FindFirstChild("RobloxGui")

if RobloxGui then
    WatchRobloxGui(RobloxGui)
end

CoreGui.ChildAdded:Connect(function(child)
    if child.Name == "RobloxGui" then
        WatchRobloxGui(child)
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
