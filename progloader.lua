local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local CONFIG_FILE = "ADS_Config.json"
local BACKUP_FILE = "ADS_ConfigBackup.json"

local AUTO_PROGRESS_URL =
    "https://raw.githubusercontent.com/Ceepizz/rya/refs/heads/main/AutoProgressV1.lua"

local AETHER_RELOAD_URL =
    "https://raw.githubusercontent.com/DuxiiT/auto-strat/refs/heads/main/Library.lua"

local CONTROLLER_NAME = "RyaProgressController"

local oldController = CoreGui:FindFirstChild(CONTROLLER_NAME)
if oldController then
    oldController:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = CONTROLLER_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 1000000
ScreenGui.Parent = CoreGui

local Colors = {
    Background = Color3.fromRGB(24, 24, 31),
    Surface = Color3.fromRGB(29, 28, 38),
    Border = Color3.fromRGB(36, 35, 48),
    Accent = Color3.fromRGB(108, 30, 210),
    AccentHover = Color3.fromRGB(124, 44, 227),
    AccentPressed = Color3.fromRGB(89, 23, 180),
    Text = Color3.fromRGB(255, 255, 255),
    Muted = Color3.fromRGB(150, 150, 150),
    Running = Color3.fromRGB(110, 220, 140),
}

local function MakeCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function MakeStroke(parent, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Border
    stroke.Thickness = 1
    stroke.Transparency = transparency or 0
    stroke.Parent = parent
    return stroke
end

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.Size = UDim2.new(0, 255, 0, 145)
Main.BackgroundColor3 = Colors.Background
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
MakeCorner(Main, 12)
MakeStroke(Main, 0.15)

local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.AnchorPoint = Main.AnchorPoint
Shadow.Position = Main.Position
Shadow.Size = Main.Size + UDim2.fromOffset(18, 18)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageColor3 = Colors.Accent
Shadow.ImageTransparency = 0.78
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
Shadow.ZIndex = 0
Shadow.Parent = ScreenGui
Main.ZIndex = 2

local Topbar = Instance.new("Frame")
Topbar.Name = "Topbar"
Topbar.Size = UDim2.new(1, 0, 0, 38)
Topbar.BackgroundColor3 = Colors.Surface
Topbar.BorderSizePixel = 0
Topbar.Parent = Main

local TopbarCorner = Instance.new("UICorner")
TopbarCorner.CornerRadius = UDim.new(0, 12)
TopbarCorner.Parent = Topbar

local TopbarFix = Instance.new("Frame")
TopbarFix.BackgroundColor3 = Colors.Surface
TopbarFix.BorderSizePixel = 0
TopbarFix.Position = UDim2.new(0, 0, 1, -12)
TopbarFix.Size = UDim2.new(1, 0, 0, 12)
TopbarFix.Parent = Topbar

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "Rya Auto Progress"
Title.TextColor3 = Colors.Text
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Topbar

local Minimize = Instance.new("TextButton")
Minimize.Name = "Minimize"
Minimize.AnchorPoint = Vector2.new(1, 0.5)
Minimize.Position = UDim2.new(1, -10, 0.5, 0)
Minimize.Size = UDim2.fromOffset(26, 26)
Minimize.BackgroundTransparency = 1
Minimize.BorderSizePixel = 0
Minimize.AutoButtonColor = false
Minimize.Font = Enum.Font.GothamBold
Minimize.Text = "−"
Minimize.TextColor3 = Colors.Muted
Minimize.TextSize = 18
Minimize.Parent = Topbar

local StatusRow = Instance.new("Frame")
StatusRow.BackgroundTransparency = 1
StatusRow.Position = UDim2.new(0, 14, 0, 50)
StatusRow.Size = UDim2.new(1, -28, 0, 28)
StatusRow.Parent = Main

local Dot = Instance.new("Frame")
Dot.AnchorPoint = Vector2.new(0, 0.5)
Dot.Position = UDim2.new(0, 0, 0.5, 0)
Dot.Size = UDim2.fromOffset(9, 9)
Dot.BackgroundColor3 = Colors.Running
Dot.BorderSizePixel = 0
Dot.Parent = StatusRow
MakeCorner(Dot, 99)

local Status = Instance.new("TextLabel")
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0, 17, 0, 0)
Status.Size = UDim2.new(1, -17, 1, 0)
Status.Font = Enum.Font.GothamBold
Status.Text = "Auto Progress Loading"
Status.TextColor3 = Colors.Text
Status.TextSize = 14
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = StatusRow

local Desc = Instance.new("TextLabel")
Desc.BackgroundTransparency = 1
Desc.Position = UDim2.new(0, 14, 0, 78)
Desc.Size = UDim2.new(1, -28, 0, 22)
Desc.Font = Enum.Font.Gotham
Desc.Text = "Please wait while Auto Progress loads."
Desc.TextColor3 = Colors.Muted
Desc.TextSize = 10
Desc.TextXAlignment = Enum.TextXAlignment.Left
Desc.Parent = Main

local Stop = Instance.new("TextButton")
Stop.Name = "Stop"
Stop.AnchorPoint = Vector2.new(0.5, 1)
Stop.Position = UDim2.new(0.5, 0, 1, -12)
Stop.Size = UDim2.new(1, -28, 0, 32)
Stop.BackgroundColor3 = Colors.Accent
Stop.BorderSizePixel = 0
Stop.AutoButtonColor = false
Stop.Font = Enum.Font.GothamBold
Stop.Text = "Stop Auto Progress"
Stop.TextColor3 = Colors.Text
Stop.TextSize = 11
Stop.Parent = Main
MakeCorner(Stop, 8)

local expandedSize = Main.Size
local minimizedSize = UDim2.new(0, 255, 0, 38)
local minimized = false

local function SetMinimized(value)
    minimized = value

    StatusRow.Visible = not value
    Desc.Visible = not value
    Stop.Visible = not value
    TopbarFix.Visible = not value

    if value then
        Main.Size = minimizedSize
        Minimize.Text = "+"
    else
        Main.Size = expandedSize
        Minimize.Text = "−"
    end
end

Minimize.MouseButton1Click:Connect(function()
    SetMinimized(not minimized)
end)

local function SyncShadow()
    if Main.Parent and Shadow.Parent then
        Shadow.Position = Main.Position
        Shadow.Size = Main.Size + UDim2.fromOffset(18, 18)
        Shadow.Visible = Main.Visible
    end
end

Main:GetPropertyChangedSignal("Position"):Connect(SyncShadow)
Main:GetPropertyChangedSignal("Size"):Connect(SyncShadow)

do
    local dragging = false
    local dragStart
    local startPos
    local dragInput

    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPos = Main.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart

            Main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

Stop.MouseEnter:Connect(function()
    TweenService:Create(
        Stop,
        TweenInfo.new(0.12),
        {BackgroundColor3 = Colors.AccentHover}
    ):Play()
end)

Stop.MouseLeave:Connect(function()
    TweenService:Create(
        Stop,
        TweenInfo.new(0.12),
        {BackgroundColor3 = Colors.Accent}
    ):Play()
end)

Stop.MouseButton1Down:Connect(function()
    Stop.BackgroundColor3 = Colors.AccentPressed
end)

Stop.MouseButton1Up:Connect(function()
    Stop.BackgroundColor3 = Colors.AccentHover
end)

local stopping = false

local function SetAetherLoaderSettingOff()
    local data = {}

    if isfile and readfile and isfile(CONFIG_FILE) then
        local ok, decoded = pcall(function()
            return HttpService:JSONDecode(
                readfile(CONFIG_FILE)
            )
        end)

        if ok and type(decoded) == "table" then
            data = decoded
        end
    end

    data.AutoProgressionLoader = false

    if writefile then
        pcall(function()
            writefile(
                CONFIG_FILE,
                HttpService:JSONEncode(data)
            )
        end)
    end

    getgenv().AutoProgressionLoader = false
end

local function DisableAetherToggles()
    if not (isfile and readfile and writefile) then
        return
    end

    if not isfile(CONFIG_FILE) then
        return
    end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(CONFIG_FILE))
    end)

    if not ok or type(data) ~= "table" then
        return
    end

    if not isfile(BACKUP_FILE) then
        local backup = {}

        for key, value in pairs(data) do
            backup[key] = value
        end

        backup.AutoProgressionLoader = false

        pcall(function()
            writefile(BACKUP_FILE, HttpService:JSONEncode(backup))
        end)
    end

    for key, value in pairs(data) do
        if type(value) == "boolean" then
            data[key] = false
            getgenv()[key] = false
        end
    end

    data.AutoProgressionLoader = true
    getgenv().AutoProgressionLoader = true

    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode(data))
    end)
end

local function RestoreAetherConfig()
    if not (isfile and readfile and writefile) then
        getgenv().AutoProgressionLoader = false
        return
    end

    if not isfile(BACKUP_FILE) then
        SetAetherLoaderSettingOff()
        return
    end

    local ok, backup = pcall(function()
        return HttpService:JSONDecode(readfile(BACKUP_FILE))
    end)

    if not ok or type(backup) ~= "table" then
        SetAetherLoaderSettingOff()
        return
    end

    backup.AutoProgressionLoader = false

    for key, value in pairs(backup) do
        getgenv()[key] = value
    end

    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode(backup))
    end)

    if delfile then
        pcall(function()
            delfile(BACKUP_FILE)
        end)
    end
end

local function StopRyaBackendIfAvailable()
    pcall(function()
        if type(shared.AutoProgress) == "table" then
            if shared.AutoProgress.StopAutoMax then
                shared.AutoProgress.StopAutoMax()
            end

            if shared.AutoProgress.Stop then
                shared.AutoProgress.Stop()
            elseif shared.AutoProgress.SetEnabled then
                shared.AutoProgress.SetEnabled(false)
            end
        end
    end)

    pcall(function()
        getgenv().AutoProgressEnabled = false
        getgenv().AutoMaxEnabled = false
        getgenv().AutoProgressionProtectionActive = false
        getgenv().AutoProgressProtectionActive = false
    end)
end

local function ReloadAether()
    shared.TDSTable = nil
    shared["TDS_Table"] = nil

    local ok, result = pcall(function()
        local source = game:HttpGet(AETHER_RELOAD_URL)
        return loadstring(source)()
    end)

    if not ok then
        warn("[Rya Controller] Failed to reload Aether:", result)
        return false
    end

    return true
end

Stop.MouseButton1Click:Connect(function()
    if stopping then
        return
    end

    stopping = true
    Stop.Active = false
    Stop.Text = "Stopping..."
    Status.Text = "Stopping"
    Dot.BackgroundColor3 = Color3.fromRGB(255, 190, 90)
    Desc.Text = "Stopping Auto Progress and restoring Aether..."

    RestoreAetherConfig()
    StopRyaBackendIfAvailable()

    local ryaGui = CoreGui:FindFirstChild("RyaAutoProgress")
    if ryaGui then
        pcall(function()
            ryaGui:Destroy()
        end)
    end

    task.wait(0.15)

    local reloaded = ReloadAether()

    if reloaded then
        Status.Text = "Stopped"
        Dot.BackgroundColor3 = Colors.Running
        Desc.Text = "Aether restored."
        Stop.Text = "Done"

        task.wait(0.4)

        if ScreenGui.Parent then
            ScreenGui:Destroy()
        end
    else
        stopping = false
        Stop.Active = true
        Stop.Text = "Retry Stop"
        Status.Text = "Reload Failed"
        Dot.BackgroundColor3 = Color3.fromRGB(255, 90, 90)
        Desc.Text = "Aether failed to reload. Press Stop to retry."
    end
end)

DisableAetherToggles()

local aetherGui = CoreGui:FindFirstChild("Aether")
if aetherGui then
    aetherGui:Destroy()
end

task.spawn(function()
    task.wait(0.15)

    local ok, err = pcall(function()
        loadstring(game:HttpGet(AUTO_PROGRESS_URL))()
    end)

    if ok then
        Status.Text = "Running\nPress Stop to return to Aether."
        Desc.Text = ""
    else
        warn("[Rya Controller] Auto Progress failed:", err)

        RestoreAetherConfig()

        Status.Text = "Load Failed"
        Dot.BackgroundColor3 = Color3.fromRGB(255, 90, 90)
        Desc.Text = "Auto Progress failed to load."
        Stop.Text = "Restore Aether"
        stopping = false
        Stop.Active = true
    end
end)

return ScreenGui
