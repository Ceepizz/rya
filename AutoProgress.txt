if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = Player:WaitForChild("PlayerGui")

local AUTO_FARM_URL = "https://api.jnkie.com/api/v1/luascripts/public/b6f94e11cee9f4f5d02f2d41490f2370afdbed8b345834b3b383decb2c386acc/download"
local WEBHOOK_URL = "https://raw.githubusercontent.com/Ceepizz/WEBHOOKSOURCE/refs/heads/main/doakes"

local CONFIG_FILE = "AutoProgressGui_" .. tostring(Player.UserId) .. ".json"
local BACKEND_SETTINGS_FILE =
    "AutoProgression_" .. tostring(Player.UserId) .. ".json"

local Config = {
    AutoFarmRunning = false,
    Webhook = "",
    SavedLevel = 0,
    SavedCoins = 0
}

local function LoadConfig()
    if not isfile or not readfile or not isfile(CONFIG_FILE) then return end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(CONFIG_FILE))
    end)
    if not ok or type(data) ~= "table" then return end
    for k, default in pairs(Config) do
        if data[k] ~= nil then
            Config[k] = data[k]
        else
            Config[k] = default
        end
    end
end

local function SaveConfig()
    if not writefile then return end
    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode(Config))
    end)
end

LoadConfig()

local AutoFarm
local ProgressWebhook
local Running = Config.AutoFarmRunning == true
local GameReady = false

local C = {
    Background = Color3.fromRGB(24,24,31),
    Surface = Color3.fromRGB(29,28,38),
    Border = Color3.fromRGB(36,35,48),
    Accent = Color3.fromRGB(108,30,210),
    AccentHover = Color3.fromRGB(124,44,227),
    AccentPressed = Color3.fromRGB(89,23,180),
    Text = Color3.fromRGB(255,255,255),
    Muted = Color3.fromRGB(150,150,150),
    Green = Color3.fromRGB(86,200,120)
}

local function FormatNumber(n)
    n = math.floor(tonumber(n) or 0)
    local s = tostring(n)
    while true do
        local changed
        s, changed = s:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
        if changed == 0 then break end
    end
    return s
end

local function GetStat(name)
    local obj = Player:FindFirstChild(name)

    if obj and obj.Value ~= nil then
        return tonumber(obj.Value)
    end

    local attr = Player:GetAttribute(name)

    if attr ~= nil then
        return tonumber(attr)
    end

    local leaderstats = Player:FindFirstChild("leaderstats")
    local stat =
        leaderstats
        and leaderstats:FindFirstChild(name)

    if stat and stat.Value ~= nil then
        return tonumber(stat.Value)
    end

    return nil
end

local function ReadBackendSettings()
    if not isfile or not readfile then
        return nil
    end

    if not isfile(BACKEND_SETTINGS_FILE) then
        return nil
    end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(
            readfile(BACKEND_SETTINGS_FILE)
        )
    end)

    if not ok or type(data) ~= "table" then
        return nil
    end

    return data
end

local function GetBackendSavedLevel()
    local data = ReadBackendSettings()

    if not data then
        return nil
    end

    if data.ProgressInitialized ~= true then
        return nil
    end

    local level = tonumber(data.SavedLevel)

    if level and level >= 0 then
        return level
    end

    return nil
end

local function GetLevel()
    local backendLevel = GetBackendSavedLevel()

    if backendLevel ~= nil then
        if backendLevel ~= tonumber(Config.SavedLevel) then
            Config.SavedLevel = backendLevel
            SaveConfig()
        end

        return backendLevel
    end

    if shared.AutoProgress
        and shared.AutoProgress.GetLevel then

        local ok, level = pcall(function()
            return shared.AutoProgress.GetLevel()
        end)

        level = ok and tonumber(level) or nil

        if level and level >= 0 then
            if level ~= tonumber(Config.SavedLevel) then
                Config.SavedLevel = level
                SaveConfig()
            end

            return level
        end
    end

    local liveLevel = GetStat("Level")

    if liveLevel and liveLevel >= 0 then
        if liveLevel ~= tonumber(Config.SavedLevel) then
            Config.SavedLevel = liveLevel
            SaveConfig()
        end

        return liveLevel
    end

    return tonumber(Config.SavedLevel) or 0
end

local MatchStartCoins = tonumber(Config.SavedCoins) or 0
local CurrentTrackedCoins = tonumber(Config.SavedCoins) or 0
local LastGameOverState = false

local function GetPlayerReplicator()
    local stateReplicators =
        ReplicatedStorage:FindFirstChild("StateReplicators")

    if not stateReplicators then
        return nil
    end

    for _, replicator in ipairs(
        stateReplicators:GetChildren()
    ) do
        if replicator.Name == "PlayerReplicator"
            and tonumber(
                replicator:GetAttribute("UserId")
            ) == Player.UserId then

            return replicator
        end
    end

    return nil
end

local function GetGameStateReplicator()
    local stateReplicators =
        ReplicatedStorage:FindFirstChild("StateReplicators")

    return stateReplicators
        and stateReplicators:FindFirstChild(
            "GameStateReplicator"
        )
end

local function GetLiveCoins()
    local coinsObject =
        Player:FindFirstChild("Coins")

    if coinsObject
        and coinsObject.Value ~= nil then

        return tonumber(coinsObject.Value) or 0
    end

    local attr =
        Player:GetAttribute("Coins")

    if attr ~= nil then
        return tonumber(attr) or 0
    end

    local leaderstats =
        Player:FindFirstChild("leaderstats")

    local stat =
        leaderstats
        and leaderstats:FindFirstChild("Coins")

    if stat and stat.Value ~= nil then
        return tonumber(stat.Value) or 0
    end

    return 0
end

local function SaveTrackedCoins(value)
    value = tonumber(value) or 0

    if value < 0 then
        value = 0
    end

    CurrentTrackedCoins = value

    if value ~= tonumber(Config.SavedCoins) then
        Config.SavedCoins = value
        SaveConfig()
    end
end

local function GetTrackedCoins()
    local liveCoins = GetLiveCoins()

    if CurrentTrackedCoins > liveCoins then
        return CurrentTrackedCoins
    end

    if liveCoins > CurrentTrackedCoins then
        SaveTrackedCoins(liveCoins)
    end

    return liveCoins
end

local function RecordMatchStartCoins()
    local liveCoins = GetLiveCoins()

    MatchStartCoins =
        math.max(
            liveCoins,
            CurrentTrackedCoins or 0
        )

    SaveTrackedCoins(MatchStartCoins)

    print(
        "[AUTO PROGRESS GUI] Coins at match start:",
        MatchStartCoins
    )
end

local function UpdateTrackedCoinsFromReward()
    local playerReplicator =
        GetPlayerReplicator()

    local reward =
        playerReplicator
        and tonumber(
            playerReplicator:GetAttribute(
                "CoinsReward"
            )
        )
        or 0

    local newTotal =
        (tonumber(MatchStartCoins) or 0)
        + reward

    SaveTrackedCoins(
        math.max(
            newTotal,
            GetLiveCoins()
        )
    )

    print(
        "[AUTO PROGRESS GUI] Coins start:",
        MatchStartCoins
    )

    print(
        "[AUTO PROGRESS GUI] Coins reward:",
        reward
    )

    print(
        "[AUTO PROGRESS GUI] New tracked coins:",
        CurrentTrackedCoins
    )

    return CurrentTrackedCoins, reward
end

local function GetCoins()
    return GetTrackedCoins()
end

local function StartCoinTracker()
    task.spawn(function()
        while Gui.Parent do
            task.wait(0.1)

            local rep =
                GetGameStateReplicator()

            if rep then
                local isGameOver =
                    rep:GetAttribute(
                        "GameOver"
                    ) == true

                if not isGameOver
                    and LastGameOverState then

                    RecordMatchStartCoins()
                elseif not isGameOver
                    and MatchStartCoins <= 0 then

                    RecordMatchStartCoins()
                end

                if isGameOver
                    and not LastGameOverState then

                    UpdateTrackedCoinsFromReward()
                    Refresh()
                end

                LastGameOverState = isGameOver
            else
                LastGameOverState = false

                local liveCoins =
                    GetLiveCoins()

                if liveCoins > 0
                    and liveCoins
                        ~= CurrentTrackedCoins then

                    SaveTrackedCoins(
                        math.max(
                            liveCoins,
                            CurrentTrackedCoins
                        )
                    )
                end
            end
        end
    end)
end

local function IsGatlingOwned()
    local inventory = PlayerGui:FindFirstChild("ReactUniversalInventoryView")
    if not inventory then return false end

    local holder = inventory:FindFirstChild("Holder")
    local windowFrame = holder and holder:FindFirstChild("windowFrame")
    local towerFrame = windowFrame and windowFrame:FindFirstChild("towersInventoryFrame")
    if not towerFrame then return false end

    for _, tower in ipairs(towerFrame:GetDescendants()) do
        if tower:IsA("Frame") then
            local refLabel = tower:FindFirstChild("refLabel", true)
            local background = tower:FindFirstChild("background", true)

            if refLabel
                and background
                and refLabel.Text == "Gatling Gun"
                and background.Visible == false then
                return true
            end
        end
    end

    return false
end

local function WaitForLoadingScreen()
    local loadingScreen =
        PlayerGui:FindFirstChild("LoadingScreen")

    local content =
        loadingScreen
        and loadingScreen:FindFirstChild("content")

    if content then
        while content.Visible do
            content
                :GetPropertyChangedSignal("Visible")
                :Wait()
        end
    end
end

local function IsLoading()
    local attrLoading =
        Player:GetAttribute("Loading") == true

    local attrTeleporting =
        Player:GetAttribute("Teleporting") == true

    local pg =
        Player:FindFirstChild("PlayerGui")

    local loadingScreen =
        pg
        and pg:FindFirstChild("LoadingScreen")

    local content =
        loadingScreen
        and loadingScreen:FindFirstChild("content")

    local contentVisible =
        content
        and content.Visible == true

    return
        attrLoading
        or attrTeleporting
        or contentVisible
end

local function WaitUntilLoaded()
    print("[AUTO PROGRESS GUI] Waiting for loading screen...")

    while IsLoading() do
        task.wait(1)
    end

    print("[AUTO PROGRESS GUI] Loaded!")
end

local function WaitForGame()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end

    Player:WaitForChild("PlayerGui")

    WaitForLoadingScreen()
    WaitUntilLoaded()

    GameReady = true
end

local function LoadModule(url)
    local ok, source = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok then
        warn("[LOADER] Download failed:", source)
        return nil
    end

    local fn, compileErr = loadstring(source)
    if not fn then
        warn("[LOADER] Compile failed:", compileErr)
        return nil
    end

    local ran, result = pcall(fn)
    if not ran then
        warn("[LOADER] Runtime failed:", result)
        return nil
    end

    return result
end

local function LoadAutoFarm()
    if AutoFarm then return AutoFarm end
    if type(shared.AutoProgress) == "table" then
        AutoFarm = shared.AutoProgress
        return AutoFarm
    end

    AutoFarm = LoadModule(AUTO_FARM_URL)
    if type(AutoFarm) ~= "table" then AutoFarm = shared.AutoProgress end
    return type(AutoFarm) == "table" and AutoFarm or nil
end

local function LoadProgressWebhook()
    if ProgressWebhook then return ProgressWebhook end
    if type(shared.ProgressWebhook) == "table" then
        ProgressWebhook = shared.ProgressWebhook
        return ProgressWebhook
    end

    ProgressWebhook = LoadModule(WEBHOOK_URL)
    if type(ProgressWebhook) ~= "table" then ProgressWebhook = shared.ProgressWebhook end
    return type(ProgressWebhook) == "table" and ProgressWebhook or nil
end

local old = CoreGui:FindFirstChild("AutoProgressGui")
if old then old:Destroy() end

local Gui = Instance.new("ScreenGui")
Gui.Name = "AutoProgressGui"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(430,150)
Main.Position = UDim2.new(0.5,-215,0.5,-75)
Main.BackgroundColor3 = C.Background
Main.BorderSizePixel = 0
Main.Parent = Gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)

local stroke = Instance.new("UIStroke")
stroke.Color = C.Border
stroke.Parent = Main

local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1,0,0,52)
Topbar.BackgroundColor3 = C.Surface
Topbar.BorderSizePixel = 0
Topbar.Parent = Main
Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0,12)

local TopFix = Instance.new("Frame")
TopFix.Size = UDim2.new(1,0,0,12)
TopFix.Position = UDim2.new(0,0,1,-12)
TopFix.BackgroundColor3 = C.Surface
TopFix.BorderSizePixel = 0
TopFix.Parent = Topbar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-100,1,0)
Title.Position = UDim2.fromOffset(18,0)
Title.BackgroundTransparency = 1
Title.Text = "Auto Progress"
Title.TextColor3 = C.Text
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Topbar

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(34,34)
Close.Position = UDim2.new(1,-44,0.5,-17)
Close.BackgroundColor3 = C.Border
Close.Text = "×"
Close.TextColor3 = C.Text
Close.TextSize = 22
Close.Font = Enum.Font.GothamBold
Close.AutoButtonColor = false
Close.Parent = Topbar
Instance.new("UICorner", Close).CornerRadius = UDim.new(0,8)
Close.MouseButton1Click:Connect(function() Gui:Destroy() end)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1,-24,1,-76)
Content.Position = UDim2.fromOffset(12,64)
Content.BackgroundTransparency = 1
Content.Parent = Main

local function Button(parent, text, height)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,height or 42)
    b.BackgroundColor3 = C.Accent
    b.Text = text
    b.TextColor3 = C.Text
    b.TextSize = 14
    b.Font = Enum.Font.GothamSemibold
    b.AutoButtonColor = false
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)

    b.MouseEnter:Connect(function() b.BackgroundColor3 = C.AccentHover end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = C.Accent end)
    b.MouseButton1Down:Connect(function() b.BackgroundColor3 = C.AccentPressed end)
    b.MouseButton1Up:Connect(function() b.BackgroundColor3 = C.AccentHover end)
    return b
end

local function Label(parent, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,0,0,22)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = C.Muted
    l.TextSize = 13
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local Home = Instance.new("Frame")
Home.Size = UDim2.fromScale(1,1)
Home.BackgroundTransparency = 1
Home.Parent = Content

local HomeLayout = Instance.new("UIListLayout")
HomeLayout.Padding = UDim.new(0,12)
HomeLayout.Parent = Home

local Selector = Button(Home, "Auto Farm Until Gatling", 48)

local FarmPage = Instance.new("ScrollingFrame")
FarmPage.Size = UDim2.fromScale(1,1)
FarmPage.BackgroundTransparency = 1
FarmPage.BorderSizePixel = 0
FarmPage.ScrollBarThickness = 3
FarmPage.ScrollBarImageColor3 = C.Accent
FarmPage.CanvasSize = UDim2.new()
FarmPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
FarmPage.Visible = false
FarmPage.Parent = Content

local FarmLayout = Instance.new("UIListLayout")
FarmLayout.Padding = UDim.new(0,10)
FarmLayout.SortOrder = Enum.SortOrder.LayoutOrder
FarmLayout.Parent = FarmPage

local Back = Button(FarmPage, "< BACK", 36)
Back.LayoutOrder = 1

local SectionTitle = Label(FarmPage, "Auto Farm Until Gatling")
SectionTitle.LayoutOrder = 2
SectionTitle.TextColor3 = C.Text
SectionTitle.TextSize = 16
SectionTitle.Font = Enum.Font.GothamBold
SectionTitle.Size = UDim2.new(1,0,0,28)

local Status = Label(FarmPage, "Status: Waiting for game...")
Status.LayoutOrder = 3

local Level = Label(FarmPage, "Level: Loading...")
Level.LayoutOrder = 4

local Coins = Label(FarmPage, "Coins: Loading...")
Coins.LayoutOrder = 5

local Gatling = Label(FarmPage, "Gatling Gun: Checking...")
Gatling.LayoutOrder = 6

local WebhookTitle = Label(FarmPage, "Progress Webhook")
WebhookTitle.LayoutOrder = 7

local WebhookBox = Instance.new("TextBox")
WebhookBox.Size = UDim2.new(1,0,0,40)
WebhookBox.BackgroundColor3 = C.Surface
WebhookBox.PlaceholderText = "Paste Discord webhook..."
WebhookBox.PlaceholderColor3 = C.Muted
WebhookBox.Text = tostring(Config.Webhook or "")
WebhookBox.TextColor3 = C.Text
WebhookBox.TextSize = 13
WebhookBox.Font = Enum.Font.Gotham
WebhookBox.ClearTextOnFocus = false
WebhookBox.TextXAlignment = Enum.TextXAlignment.Left
WebhookBox.LayoutOrder = 8
WebhookBox.Parent = FarmPage
Instance.new("UICorner", WebhookBox).CornerRadius = UDim.new(0,8)

local wbStroke = Instance.new("UIStroke")
wbStroke.Color = C.Border
wbStroke.Parent = WebhookBox

local wbPad = Instance.new("UIPadding")
wbPad.PaddingLeft = UDim.new(0,12)
wbPad.PaddingRight = UDim.new(0,12)
wbPad.Parent = WebhookBox

local Toggle = Button(FarmPage, "START", 42)
Toggle.LayoutOrder = 9

local SendWebhook = Button(FarmPage, "SEND WEBHOOK", 42)
SendWebhook.LayoutOrder = 10

local function ShowHome()
    Home.Visible = true
    FarmPage.Visible = false
    Main.Size = UDim2.fromOffset(430,150)
    Main.Position = UDim2.new(0.5,-215,0.5,-75)
end

local function ShowFarm()
    Home.Visible = false
    FarmPage.Visible = true
    Main.Size = UDim2.fromOffset(430,470)
    Main.Position = UDim2.new(0.5,-215,0.5,-235)
end

Selector.MouseButton1Click:Connect(ShowFarm)
Back.MouseButton1Click:Connect(ShowHome)

local function Refresh()
    local level = GetLevel()
    local coins = GetCoins()
    local owned = IsGatlingOwned()

    Level.Text = "Level: " .. tostring(level)

    if owned then
        Coins.Visible = false
        Gatling.Text = "Gatling Gun: Owned"
        Gatling.TextColor3 = C.Green
        Status.Text = "Status: Completed"
        Status.TextColor3 = C.Green
        Toggle.Text = "COMPLETED"
        Toggle.BackgroundColor3 = C.Border

        Running = false
        Config.AutoFarmRunning = false
        SaveConfig()
        return
    end

    Coins.Visible = true
    Coins.Text = "Coins: " .. FormatNumber(coins) .. " / 35,000"
    Gatling.Text = "Gatling Gun: Not Owned"
    Gatling.TextColor3 = C.Muted
    Status.TextColor3 = C.Muted

    if not GameReady then
        Status.Text = "Status: Waiting for game..."
        Toggle.Text = Running and "STOP" or "START"
        return
    end

    if Running then
        Toggle.Text = "STOP"

        if shared.AutoProgress and shared.AutoProgress.GetStatus then
            local ok, state = pcall(shared.AutoProgress.GetStatus)
            if ok and state then
                Status.Text = tostring(state)
                return
            end
        end

        Status.Text = "Status: Running"
    else
        Toggle.Text = "START"
        Status.Text = "Status: Disabled"
    end
end

local function SetWebhook()
    Config.Webhook = WebhookBox.Text
    SaveConfig()

    local module = LoadProgressWebhook()
    if not module or not module.SetWebhook then
        Status.Text = "Status: Webhook Failed To Load"
        return false
    end

    module.SetWebhook(WebhookBox.Text)
    return true
end

local StartTaskRunning = false

local function StartFarm(resumeExisting)
    if StartTaskRunning then
        return
    end

    if Running and not resumeExisting then
        return
    end

    Running = true
    Config.AutoFarmRunning = true
    SaveConfig()

    Toggle.Text = "STOP"
    Status.Text = "Status: Waiting for game..."

    StartTaskRunning = true

    task.spawn(function()
        WaitForGame()

        if not Running then
            StartTaskRunning = false
            return
        end

        if IsGatlingOwned() then
            Running = false
            Config.AutoFarmRunning = false
            SaveConfig()

            StartTaskRunning = false
            Refresh()
            return
        end

        Status.Text = "Status: Loading Auto Progress..."

        local farm = LoadAutoFarm()

        if not Running then
            StartTaskRunning = false
            return
        end

        if not farm or not farm.Start then
            Running = false
            Config.AutoFarmRunning = false
            SaveConfig()

            Status.Text = "Status: Auto Farm Failed To Load"
            Toggle.Text = "START"

            StartTaskRunning = false
            return
        end

        local webhook = LoadProgressWebhook()

        if webhook
            and WebhookBox.Text ~= ""
            and webhook.SetWebhook then

            Config.Webhook = WebhookBox.Text
            SaveConfig()

            webhook.SetWebhook(
                WebhookBox.Text
            )
        end

        if webhook and webhook.Start then
            webhook.Start()
        end

        local alreadyRunning = false

        if shared.AutoProgress
            and shared.AutoProgress.GetStatus then

            local ok, state =
                pcall(shared.AutoProgress.GetStatus)

            if ok and state then
                local stateText = tostring(state)

                alreadyRunning =
                    stateText ~= ""
                    and stateText ~= "Disabled"
                    and stateText ~= "Status: Disabled"
            end
        end

        if not alreadyRunning and Running then
            farm.Start()
        end

        StartTaskRunning = false
        Refresh()
    end)
end

local function StopFarm()
    Running = false
    Config.AutoFarmRunning = false
    SaveConfig()

    if AutoFarm and AutoFarm.Stop then
        AutoFarm.Stop()
    elseif shared.AutoProgress and shared.AutoProgress.Stop then
        shared.AutoProgress.Stop()
    end

    Refresh()
end

local function ToggleFarm()
    if IsGatlingOwned() then
        Refresh()
        return
    end

    if Running then
        StopFarm()
    else
        StartFarm()
    end
end

local function SendProgressWebhook()
    if not GameReady then
        Status.Text = "Status: Waiting for game..."
        return
    end

    local module = LoadProgressWebhook()
    if not module then
        Status.Text = "Status: Webhook Failed To Load"
        return
    end

    if WebhookBox.Text ~= "" and module.SetWebhook then
        Config.Webhook = WebhookBox.Text
        SaveConfig()
        module.SetWebhook(WebhookBox.Text)
    end

    if module.Send then
        local ok, result = module.Send(true)
        Status.Text = ok and "Status: Webhook Sent" or ("Status: " .. tostring(result))
    else
        Status.Text = "Status: Send Function Missing"
    end
end

Toggle.MouseButton1Click:Connect(ToggleFarm)
SendWebhook.MouseButton1Click:Connect(SendProgressWebhook)

WebhookBox.FocusLost:Connect(function()
    Config.Webhook = WebhookBox.Text
    SaveConfig()
    if WebhookBox.Text ~= "" then SetWebhook() end
end)

if Running then
    ShowFarm()

    task.defer(function()
        StartFarm(true)
    end)
else
    ShowHome()

    task.spawn(function()
        WaitForGame()
        Refresh()
    end)
end

StartCoinTracker()

task.spawn(function()
    local lastBackendLevel =
        tonumber(Config.SavedLevel) or 0

    while Gui.Parent do
        task.wait(0.25)

        local backendLevel =
            GetBackendSavedLevel()

        if backendLevel ~= nil
            and backendLevel ~= lastBackendLevel then

            lastBackendLevel = backendLevel
            Config.SavedLevel = backendLevel
            SaveConfig()

            print(
                "[AUTO PROGRESS GUI] Level updated from backend:",
                backendLevel
            )
        end

        Refresh()
    end
end)

local dragging = false
local dragInput
local dragStart
local startPos

Topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

Topbar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
