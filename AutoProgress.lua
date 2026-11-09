
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local LOBBY_PLACE_ID = 3260590327

local LOADING_TIMEOUT = 100
local LOBBY_LOADING_TIMEOUT = 60

local LoaderActive = true
local ReconnectCheckRunning = false

local SavedState = {
    Difficulty = nil,
    DisplayName = nil,
    Mode = "survival"
}

local Executor = identifyexecutor and identifyexecutor()
if Executor == "Solara" or Executor == "Xeno" then
    game:GetService("Players").LocalPlayer:Kick("Unsupported executor: " .. Executor)
end

local function GetRep()
    local stateReplicators =
        ReplicatedStorage:FindFirstChild("StateReplicators")

    return stateReplicators
        and stateReplicators:FindFirstChild("GameStateReplicator")
end

local function IsInGame()
    return GetRep() ~= nil
end

local function CacheState(rep)
    if not rep then
        return
    end

    local difficulty =
        rep:GetAttribute("Difficulty")

    local displayName =
        rep:GetAttribute("DifficultyDisplayName")

    if difficulty ~= nil then
        SavedState.Difficulty =
            tostring(difficulty)
    end

    if displayName ~= nil then
        SavedState.DisplayName =
            tostring(displayName)
    end

    if tostring(SavedState.DisplayName or ""):lower() == "hardcore" then
        SavedState.Mode = "hardcore"
    else
        SavedState.Mode = "survival"
    end
end

local function Matchmake()
    if not IsInGame() then
        return false
    end

    local rep = GetRep()

    if rep then
        CacheState(rep)
    end

    if not SavedState.Difficulty then
        return false
    end

    local remote =
        ReplicatedStorage:FindFirstChild("RemoteFunction")

    if not remote then
        return false
    end

    return pcall(function()
        remote:InvokeServer(
            "Multiplayer",
            "v2:start",
            {
                difficulty = SavedState.Difficulty,
                mode = SavedState.Mode,
                count = 1
            }
        )
    end)
end

local function Reconnect()
    if not LoaderActive or ReconnectCheckRunning then
        return
    end

    ReconnectCheckRunning = true

    task.spawn(function()
        task.wait(2)

        if LoaderActive then
            pcall(function()
                TeleportService:TeleportReconnect()
            end)
        end

        ReconnectCheckRunning = false
    end)
end

local ErrorConnection =
    GuiService.ErrorMessageChanged:Connect(function()
        local code = GuiService:GetErrorCode()

        if code and code ~= Enum.ConnectionError.OK then
            Reconnect()
        end
    end)

local PromptConnection

pcall(function()
    local promptOverlay =
        CoreGui
            :WaitForChild("RobloxPromptGui")
            :WaitForChild("promptOverlay")

    PromptConnection =
        promptOverlay.ChildAdded:Connect(function(child)
            if child.Name == "ErrorPrompt" then
                Reconnect()
            end
        end)
end)

local existingCode = GuiService:GetErrorCode()

if existingCode and existingCode ~= Enum.ConnectionError.OK then
    Reconnect()
end

local function IsLoading()
    local playerGui =
        LocalPlayer:FindFirstChild("PlayerGui")

    local loadingScreen =
        playerGui
        and playerGui:FindFirstChild("LoadingScreen")

    local content =
        loadingScreen
        and loadingScreen:FindFirstChild("content")

    return
        LocalPlayer:GetAttribute("Loading") == true
        or LocalPlayer:GetAttribute("Teleporting") == true
        or (content and content.Visible == true)
end

if game.PlaceId == LOBBY_PLACE_ID then
    local startedAt = os.clock()

    while IsLoading() do
        if game.PlaceId ~= LOBBY_PLACE_ID then
            break
        end

        if os.clock() - startedAt >= LOBBY_LOADING_TIMEOUT then
            pcall(function()
                TeleportService:Teleport(
                    LOBBY_PLACE_ID,
                    LocalPlayer
                )
            end)

            return
        end

        task.wait(1)
    end

elseif IsInGame() then
    local startedAt = os.clock()

    while IsLoading() do
        if not IsInGame() then
            break
        end

        if os.clock() - startedAt >= LOADING_TIMEOUT then
            Matchmake()
            return
        end

        task.wait(1)
    end
end

local ok, err = pcall(function()
    loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/96aa3bb286648b1860f83b0d1dffc8b67b5091050f89341b6384c4450894193d/download"))()
end)

LoaderActive = false

if ErrorConnection then
    ErrorConnection:Disconnect()
end

if PromptConnection then
    PromptConnection:Disconnect()
end

ReconnectCheckRunning = false

if not ok then
    warn(err)
end
