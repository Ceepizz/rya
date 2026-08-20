if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = Player:WaitForChild("PlayerGui")
local LOBBY_PLACE_ID = 3260590327

local Stats = {}

local SETTINGS_FILE =
    "AutoProgress_" .. tostring(Player.Name) .. ".json"

local Saved = {
    SavedLevel = 0,
    SavedCoins = 0
}

local MatchStartCoins = 0
local CurrentTrackedCoins = 0
local LastGameOverState = false
local HadGameReplicator = false
local Monitoring = false
local MonitorToken = 0
local RewardTimeout = 3

local function LoadSaved()
    if not isfile
        or not readfile
        or not isfile(SETTINGS_FILE) then
        return
    end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(
            readfile(SETTINGS_FILE)
        )
    end)

    if not ok or type(data) ~= "table" then
        return
    end

    for key, defaultValue in pairs(Saved) do
        if data[key] ~= nil then
            Saved[key] = data[key]
        else
            Saved[key] = defaultValue
        end
    end
end

local function Save()
    if not writefile then
        return
    end

    local data = {}

    if isfile and readfile and isfile(SETTINGS_FILE) then
        pcall(function()
            local existing = HttpService:JSONDecode(readfile(SETTINGS_FILE))
            if type(existing) == "table" then
                data = existing
            end
        end)
    end

    for key, value in pairs(Saved) do
        data[key] = value
    end

    pcall(function()
        writefile(
            SETTINGS_FILE,
            HttpService:JSONEncode(data)
        )
    end)
end

LoadSaved()

MatchStartCoins = tonumber(Saved.SavedCoins) or 0
CurrentTrackedCoins = tonumber(Saved.SavedCoins) or 0

local function ReadNumberStat(name)
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
    if not isfile
        or not readfile
        or not isfile(SETTINGS_FILE) then
        return nil
    end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(
            readfile(SETTINGS_FILE)
        )
    end)

    if not ok or type(data) ~= "table" then
        return nil
    end

    return data
end

function Stats.GetBackendSavedLevel()
    local data = ReadBackendSettings()

    if not data
        or data.ProgressInitialized ~= true then
        return nil
    end

    local level = tonumber(data.SavedLevel)

    if level and level >= 0 then
        return level
    end

    return nil
end

function Stats.GetLevel()
    local backendLevel =
        Stats.GetBackendSavedLevel()

    if backendLevel ~= nil then
        if backendLevel ~= tonumber(Saved.SavedLevel) then
            Saved.SavedLevel = backendLevel
            Save()
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
            if level ~= tonumber(Saved.SavedLevel) then
                Saved.SavedLevel = level
                Save()
            end

            return level
        end
    end

    local liveLevel = ReadNumberStat("Level")

    if liveLevel and liveLevel >= 0 then
        if liveLevel ~= tonumber(Saved.SavedLevel) then
            Saved.SavedLevel = liveLevel
            Save()
        end

        return liveLevel
    end

    return tonumber(Saved.SavedLevel) or 0
end

function Stats.GetPlayerReplicator()
    local stateReplicators =
        ReplicatedStorage:FindFirstChild(
            "StateReplicators"
        )

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

function Stats.GetGameStateReplicator()
    local stateReplicators =
        ReplicatedStorage:FindFirstChild(
            "StateReplicators"
        )

    return stateReplicators
        and stateReplicators:FindFirstChild(
            "GameStateReplicator"
        )
end

function Stats.GetLiveCoins()
    local coinsObject =
        Player:FindFirstChild("Coins")

    if coinsObject
        and coinsObject.Value ~= nil then

        return tonumber(coinsObject.Value)
    end

    local attr = Player:GetAttribute("Coins")

    if attr ~= nil then
        return tonumber(attr)
    end

    local leaderstats =
        Player:FindFirstChild("leaderstats")

    local stat =
        leaderstats
        and leaderstats:FindFirstChild("Coins")

    if stat and stat.Value ~= nil then
        return tonumber(stat.Value)
    end

    return nil
end

local function SaveTrackedCoins(value)
    value = tonumber(value)

    if not value then
        return CurrentTrackedCoins
    end

    value = math.max(value, 0)
    CurrentTrackedCoins = value

    if value ~= tonumber(Saved.SavedCoins) then
        Saved.SavedCoins = value
        Save()
    end

    return value
end

function Stats.GetGems()
    local liveGems = ReadNumberStat("Gems")

    if liveGems ~= nil then
        return math.max(tonumber(liveGems) or 0, 0)
    end

    return 0
end

function Stats.GetCoins()
    local liveCoins = Stats.GetLiveCoins()

    if game.PlaceId == LOBBY_PLACE_ID
        and Stats.GetGameStateReplicator() == nil
        and liveCoins ~= nil then

        SaveTrackedCoins(liveCoins)
        MatchStartCoins = liveCoins
        return liveCoins
    end

    if liveCoins ~= nil
        and liveCoins > CurrentTrackedCoins then

        SaveTrackedCoins(liveCoins)
    end

    return math.max(
        tonumber(CurrentTrackedCoins) or 0,
        tonumber(liveCoins) or 0
    )
end

function Stats.RecordMatchStartCoins()
    local liveCoins = Stats.GetLiveCoins()

    MatchStartCoins = math.max(
        tonumber(liveCoins) or 0,
        tonumber(CurrentTrackedCoins) or 0
    )

    SaveTrackedCoins(MatchStartCoins)

    return MatchStartCoins
end

function Stats.UpdateCoinsFromReward()
    local playerReplicator =
        Stats.GetPlayerReplicator()

    if not playerReplicator then
        warn(
            "[AUTO PROGRESS STATS] PlayerReplicator not found"
        )

        return Stats.GetCoins(), 0
    end

    local reward = 0
    local lastReward = nil
    local stableReads = 0
    local timeoutAt = os.clock() + RewardTimeout

    repeat
        local value = tonumber(
            playerReplicator:GetAttribute(
                "CoinsReward"
            )
        )

        if value ~= nil and value >= 0 then
            reward = value

            if value == lastReward then
                stableReads += 1
            else
                lastReward = value
                stableReads = 1
            end

            if value > 0
                and stableReads >= 3 then
                break
            end
        end

        task.wait(0.1)
    until os.clock() >= timeoutAt

    local newTotal =
        (tonumber(MatchStartCoins) or 0)
        + reward

    local liveCoins = Stats.GetLiveCoins()

    SaveTrackedCoins(
        math.max(
            newTotal,
            tonumber(liveCoins) or 0
        )
    )

    return CurrentTrackedCoins, reward
end

function Stats.IsTowerOwned(towerName)
    local inventory =
        PlayerGui:FindFirstChild(
            "ReactUniversalInventoryView"
        )

    if not inventory then
        return false
    end

    local holder =
        inventory:FindFirstChild("Holder")

    local windowFrame =
        holder
        and holder:FindFirstChild(
            "windowFrame"
        )

    local towerFrame =
        windowFrame
        and windowFrame:FindFirstChild(
            "towersInventoryFrame"
        )

    if not towerFrame then
        return false
    end

    for _, tower in ipairs(
        towerFrame:GetDescendants()
    ) do
        if tower:IsA("Frame") then
            local refLabel =
                tower:FindFirstChild(
                    "refLabel",
                    true
                )

            local background =
                tower:FindFirstChild(
                    "background",
                    true
                )

            if refLabel
                and background
                and refLabel.Text == towerName
                and background.Visible == false then

                return true
            end
        end
    end

    return false
end

function Stats.IsGatlingOwned()
    return Stats.IsTowerOwned("Gatling Gun")
end

function Stats.GetSnapshot()
    return {
        Level = Stats.GetLevel(),
        Coins = Stats.GetCoins(),
        Gems = Stats.GetGems(),
        GatlingOwned = Stats.IsGatlingOwned()
    }
end

function Stats.SetRewardTimeout(seconds)
    RewardTimeout =
        math.max(
            tonumber(seconds) or 3,
            0.5
        )
end

function Stats.Start(callback)
    if Monitoring then
        return false
    end

    Monitoring = true
    MonitorToken += 1
    local myToken = MonitorToken

    task.spawn(function()
        local lastLevel = nil
        local lastCoins = nil
        local lastGems = nil
        local lastGatling = nil
        local lastSnapshotAt = 0

        while Monitoring
            and myToken == MonitorToken do

            task.wait(0.1)

            local rep =
                Stats.GetGameStateReplicator()

            if rep then
                if not HadGameReplicator then
                    HadGameReplicator = true
                    LastGameOverState = false
                    Stats.RecordMatchStartCoins()
                end

                local isGameOver =
                    rep:GetAttribute(
                        "GameOver"
                    ) == true

                if not isGameOver
                    and LastGameOverState then

                    Stats.RecordMatchStartCoins()
                end

                if isGameOver
                    and not LastGameOverState then

                    Stats.UpdateCoinsFromReward()
                end

                LastGameOverState = isGameOver
            else
                HadGameReplicator = false
                LastGameOverState = false

                local liveCoins =
                    Stats.GetLiveCoins()

                if liveCoins ~= nil then
                    SaveTrackedCoins(liveCoins)
                    MatchStartCoins = liveCoins
                end
            end

            if os.clock() - lastSnapshotAt >= 0.25 then
                lastSnapshotAt = os.clock()

                local snapshot =
                    Stats.GetSnapshot()

                local changed =
                    snapshot.Level ~= lastLevel
                    or snapshot.Coins ~= lastCoins
                    or snapshot.Gems ~= lastGems
                    or snapshot.GatlingOwned ~= lastGatling

                if changed then
                    lastLevel = snapshot.Level
                    lastCoins = snapshot.Coins
                    lastGems = snapshot.Gems
                    lastGatling = snapshot.GatlingOwned

                    if callback then
                        task.spawn(
                            callback,
                            snapshot
                        )
                    end
                end
            end
        end
    end)

    return true
end

function Stats.Stop()
    Monitoring = false
    MonitorToken += 1
end

function Stats.GetSavedCoins()
    return tonumber(Saved.SavedCoins) or 0
end

function Stats.GetSavedLevel()
    return tonumber(Saved.SavedLevel) or 0
end

shared.AutoProgressStats = Stats
return Stats
