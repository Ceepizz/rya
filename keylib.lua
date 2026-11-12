local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerGui = player:WaitForChild("PlayerGui")
local env = getgenv and getgenv() or _G

local KeyUI = {
    Appearance = {Title = "Macro Hub", Subtitle = "Enter your key to continue"},
    Links = {Discord = "", BuyPremium = ""},
    Storage = {Folder = "", FileName = "verified_key.txt", Remember = true, AutoLoad = true},
    Options = {Keyless = nil, KeylessUI = true, Draggable = true, VerificationAttempts = 3, RetryDelay = 1.5},
    Callbacks = {OnSuccess = nil, OnFailure = nil}
}

local themes = {
    Dark = {Background = Color3.fromRGB(8, 14, 29), Card = Color3.fromRGB(15, 25, 45), Input = Color3.fromRGB(9, 19, 36), Border = Color3.fromRGB(43, 62, 97), Text = Color3.fromRGB(239, 245, 255), Sub = Color3.fromRGB(151, 168, 197), Accent = Color3.fromRGB(65, 155, 255), Positive = Color3.fromRGB(74, 222, 128), Negative = Color3.fromRGB(251, 113, 133)},
    Light = {Background = Color3.fromRGB(242, 246, 252), Card = Color3.fromRGB(255, 255, 255), Input = Color3.fromRGB(238, 244, 252), Border = Color3.fromRGB(191, 208, 233), Text = Color3.fromRGB(24, 40, 67), Sub = Color3.fromRGB(77, 100, 137), Accent = Color3.fromRGB(36, 112, 221), Positive = Color3.fromRGB(19, 130, 77), Negative = Color3.fromRGB(177, 43, 67)}
}

local errors = {
    KEY_INVALID = "Key not found. Check your key and try again.",
    KEY_EXPIRED = "This key has expired. Get a new key.",
    KEY_INVALIDATED = "This key has been revoked.",
    REVOKED = "This key has been revoked.",
    HWID_MISMATCH = "Device limit reached. Contact support.",
    ALREADY_USED = "This one-time key has already been used.",
    SERVICE_NOT_FOUND = "Key service not found. Contact support.",
    SERVICE_MISMATCH = "This key belongs to a different service.",
    PREMIUM_REQUIRED = "A Premium key is required.",
    HWID_BANNED = "This device has been banned.",
    ERROR = "Connection error. Please try again.",
    NETWORK = "Connection error. Please try again.",
    RATE_LIMITTED = "Rate limited. Try again in 5 minutes."
}

local function create(class, properties, parent)
    local instance = Instance.new(class)
    for name, value in pairs(properties or {}) do
        instance[name] = value
    end
    instance.Parent = parent
    return instance
end

local function corner(instance, radius)
    create("UICorner", {CornerRadius = UDim.new(0, radius or 10)}, instance)
    return instance
end

local function stroke(instance)
    return create("UIStroke", {Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, instance)
end

local function text(parent, value, size, bold, x, y, width, height)
    return create("TextLabel", {
        BackgroundTransparency = 1, Text = value, Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
        TextSize = size, TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center, TextWrapped = true,
        Position = UDim2.fromOffset(x, y), Size = UDim2.new(1, -width, 0, height)
    }, parent)
end

local function button(parent, value, x, y, width, height)
    return corner(create("TextButton", {
        Text = value, Font = Enum.Font.GothamBold, TextSize = 12,
        AutoButtonColor = true, BorderSizePixel = 0,
        Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(width, height)
    }, parent), 9)
end

local function normalize(key)
    return tostring(key or ""):match("^%s*(.-)%s*$") or ""
end

local function storagePath(self)
    local folder = tostring(self.Storage.Folder or "")
    local file = tostring(self.Storage.FileName or "verified_key.txt")
    return folder ~= "" and (folder .. "/" .. file) or file
end

function KeyUI:GetSavedKey()
    if type(isfile) ~= "function" or type(readfile) ~= "function" then return nil end
    local path = storagePath(self)
    local ok, data = pcall(function()
        if isfile(path) then return readfile(path) end
    end)
    if ok and type(data) == "string" then
        local key = normalize(data)
        if key ~= "" then return key end
    end
    return nil
end

function KeyUI:ClearSavedKey()
    if type(delfile) ~= "function" or type(isfile) ~= "function" then return end
    pcall(function()
        local path = storagePath(self)
        if isfile(path) then delfile(path) end
    end)
end

function KeyUI:SaveKey(key)
    if not self.Storage.Remember or type(writefile) ~= "function" then return end
    pcall(function()
        local dir = tostring(self.Storage.Folder)
        if dir ~= "" and type(makefolder) == "function" and type(isfolder) == "function" and not isfolder(dir) then
            makefolder(dir)
        end
        writefile(storagePath(self), normalize(key))
    end)
end

function KeyUI:Destroy()
    if self._closed then return end
    self._closed = true
    env.UI_CLOSED = true
    if self._connections then
        for _, connection in ipairs(self._connections) do
            connection:Disconnect()
        end
    end
    if self._gui then self._gui:Destroy() end
    self._gui = nil
end

function KeyUI:Notify(title, message, duration, kind)
    if not self._status then return end
    self._status.Text = tostring(title or "") .. (message and ": " .. tostring(message) or "")
    self._status.TextColor3 = kind == "error" and themes[self._theme].Negative or kind == "success" and themes[self._theme].Positive or themes[self._theme].Sub
    if duration and duration > 0 then
        self._notificationToken = (self._notificationToken or 0) + 1
        local token = self._notificationToken
        task.delay(duration, function()
            if self._notificationToken == token and self._status and self._status.Parent then
                self._status.Text = "Enter your key to verify access"
                self._status.TextColor3 = themes[self._theme].Sub
            end
        end)
    end
end

function KeyUI:_mount()
    local previous = playerGui:FindFirstChild("MacroHubKeyUI")
    if previous then previous:Destroy() end
    self._connections = {}
    self._closed = false
    self._theme = self._theme or "Dark"
    self._failed = 0
    self._lockedUntil = 0
    self._busy = false
    env.UI_CLOSED = false
    local gui = create("ScreenGui", {
        Name = "MacroHubKeyUI", IgnoreGuiInset = true, ResetOnSpawn = false,
        DisplayOrder = 1001, ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, playerGui)
    self._gui = gui
    local overlay = create("Frame", {BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = .36, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1)}, gui)
    local card = corner(create("Frame", {
        Name = "KeyCard", AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
        Size = UDim2.fromOffset(480, 440), BorderSizePixel = 0
    }, overlay), 16)
    local cardStroke = stroke(card)
    local scale = create("UIScale", {Scale = 1}, card)
    local icon = corner(create("ImageLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(24, 22),
        Size = UDim2.fromOffset(46, 46), ScaleType = Enum.ScaleType.Fit
    }, card), 9)
    local title = text(card, self.Appearance.Title, 20, true, 84, 23, 166, 28)
    local subtitle = text(card, self.Appearance.Subtitle, 12, false, 84, 53, 166, 22)
    local themeButton = button(card, "☀", 386, 29, 30, 30)
    local closeButton = button(card, "×", 425, 29, 30, 30)
    local separator = create("Frame", {
        BorderSizePixel = 0, Position = UDim2.fromOffset(24, 91), Size = UDim2.fromOffset(432, 1)
    }, card)
    local entryLabel = text(card, "LICENSE KEY", 11, true, 26, 108, 52, 19)
    local entry = corner(create("Frame", {
        Position = UDim2.fromOffset(24, 132), Size = UDim2.fromOffset(432, 45),
        BorderSizePixel = 0
    }, card), 9)
    local entryStroke = stroke(entry)
    local input = create("TextBox", {
        Name = "KeyInput", Text = "", PlaceholderText = "Paste your key here...",
        ClearTextOnFocus = false, Font = Enum.Font.Code, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
        BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(1, -112, 1, 0)
    }, entry)
    local paste = button(entry, "Paste", 352, 7, 68, 31)
    local status = text(card, "Enter your key to verify access", 12, false, 25, 185, 50, 35)
    status.TextWrapped = true
    self._status = status
    local verify = button(card, "Verify Key", 24, 229, 432, 42)
    verify.TextSize = 13
    local separator2 = create("Frame", {BorderSizePixel = 0,
        Position = UDim2.fromOffset(24, 286), Size = UDim2.fromOffset(432, 1)}, card)
    local getKey = button(card, "Get Key", 24, 300, 210, 38)
    local discord = button(card, "Discord / Support", 246, 300, 210, 38)
    local premium = button(card, "Buy Premium Key (Crypto Only)", 24, 347, 432, 38)
    local otherPayments = button(card, "Other Payment Methods - Discord Support", 24, 394, 432, 32)
    otherPayments.TextSize = 11

    local function connection(signal, callback)
        table.insert(self._connections, signal:Connect(callback))
    end
    local function theme()
        local p = themes[self._theme]
        overlay.BackgroundColor3 = p.Background
        card.BackgroundColor3 = p.Card
        cardStroke.Color = p.Border
        separator.BackgroundColor3 = p.Border
        separator2.BackgroundColor3 = p.Border
        entry.BackgroundColor3 = p.Input
        entryStroke.Color = p.Border
        for _, label in ipairs({title, entryLabel}) do label.TextColor3 = p.Text end
        for _, label in ipairs({subtitle}) do label.TextColor3 = p.Sub end
        if not self._busy then status.TextColor3 = p.Sub end
        input.TextColor3 = p.Text
        input.PlaceholderColor3 = p.Sub
        paste.BackgroundColor3 = p.Card
        paste.TextColor3 = p.Accent
        verify.BackgroundColor3 = p.Accent
        verify.TextColor3 = Color3.new(1, 1, 1)
        getKey.BackgroundColor3 = p.Input
        getKey.TextColor3 = p.Text
        discord.BackgroundColor3 = p.Input
        discord.TextColor3 = p.Text
        premium.BackgroundColor3 = p.Input
        premium.TextColor3 = p.Accent
        otherPayments.BackgroundColor3 = p.Input
        otherPayments.TextColor3 = p.Accent
        closeButton.BackgroundColor3 = p.Input
        closeButton.TextColor3 = p.Sub
        themeButton.BackgroundColor3 = p.Input
        themeButton.TextColor3 = p.Sub
        themeButton.Text = self._theme == "Dark" and "☀" or "☾"
        icon.Image = "rbxassetid://" .. (self._theme == "Dark" and "76956733094432" or "95122283075110")
        discord.Visible = self.Links.Discord ~= ""
        getKey.Size = UDim2.fromOffset(discord.Visible and 210 or 432, 38)
        premium.Visible = self.Links.BuyPremium ~= ""
        otherPayments.Visible = discord.Visible
    end
    self._refreshTheme = theme
    theme()
    local function fit()
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(900, 700)
        scale.Scale = math.clamp(math.min((viewport.X - 32) / 500, (viewport.Y - 32) / 456), .55, 1)
    end
    fit()
    connection(overlay:GetPropertyChangedSignal("AbsoluteSize"), fit)
    connection(themeButton.MouseButton1Click, function()
        self._theme = self._theme == "Dark" and "Light" or "Dark"
        theme()
    end)
    connection(closeButton.MouseButton1Click, function() self:Destroy() end)
    local dragStart, origin, dragging, dragInput
    connection(card.InputBegan, function(event)
        if not self.Options.Draggable then return end
        if event.UserInputType == Enum.UserInputType.MouseButton1 or event.UserInputType == Enum.UserInputType.Touch then
            local relativeY = event.Position.Y - card.AbsolutePosition.Y
            if relativeY > 82 * scale.Scale then return end
            dragging = true
            dragStart = event.Position
            origin = card.Position
            dragInput = event
            local changed
            changed = event.Changed:Connect(function()
                if event.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    changed:Disconnect()
                end
            end)
        end
    end)
    connection(UserInputService.InputChanged, function(event)
        if dragging and (event == dragInput or event.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = event.Position - dragStart
            card.Position = UDim2.new(origin.X.Scale, origin.X.Offset + d.X, origin.Y.Scale, origin.Y.Offset + d.Y)
        end
    end)

    local function copy(value)
        local clipboard = setclipboard or toclipboard
        if type(clipboard) == "function" then
            local ok = pcall(clipboard, value)
            if ok then return true end
        end
        input.Text = value
        input:CaptureFocus()
        return false
    end
    connection(paste.MouseButton1Click, function()
        local reader = getclipboard or readclipboard
        if type(reader) ~= "function" then
            self:Notify("Clipboard unavailable", "Paste with your device keyboard.", 4, "error")
            return
        end
        local ok, value = pcall(reader)
        if ok and type(value) == "string" then
            input.Text = normalize(value)
        else
            self:Notify("Paste failed", "Paste using your keyboard.", 4, "error")
        end
    end)
    connection(getKey.MouseButton1Click, function()
        task.spawn(function()
            self:Notify("Get Key", "Requesting key link...", 0)
            local sdk = self:_getJunkie()
            if not sdk then return end
            local ok, link, err = pcall(sdk.get_key_link)
            if ok and type(link) == "string" and link ~= "" then
                local wasCopied = copy(link)
                self:Notify("Get Key", wasCopied and "Link copied to clipboard." or "Select the link in the key field to copy it.", 5, "success")
            else
                self:Notify("Get Key", errors[tostring(err)] or tostring(err or "Could not get the link. Try later."), 5, "error")
            end
        end)
    end)
    local function copyDiscordSupport()
        if self.Links.Discord == "" then return end
        local success = copy(self.Links.Discord)
        self:Notify("Discord Support", success and "Invite copied. Create a ticket to ask about other payment methods." or "Copy the invite shown in the key field.", 5, "success")
    end
    connection(discord.MouseButton1Click, copyDiscordSupport)
    connection(otherPayments.MouseButton1Click, copyDiscordSupport)
    connection(premium.MouseButton1Click, function()
        if self.Links.BuyPremium == "" then return end
        local success = copy(self.Links.BuyPremium)
        self:Notify("Premium", success and "Crypto shop link copied." or "Copy the link shown in the key field.", 5, "success")
    end)
    connection(verify.MouseButton1Click, function()
        task.spawn(function() self:_verify(input.Text, false) end)
    end)
    connection(input.FocusLost, function(enterPressed)
        if enterPressed then task.spawn(function() self:_verify(input.Text, false) end) end
    end)
    self._keyInput = input
    self._verifyButton = verify
end

function KeyUI:_getJunkie()
    if self._junkie then return self._junkie end
    local ok, sdk = pcall(function()
        return loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
    end)
    if not ok or type(sdk) ~= "table" or type(sdk.check_key) ~= "function" then
        self:Notify("Junkie", "Could not load verification SDK.", 5, "error")
        return nil
    end
    sdk.service = self._service or "Key"
    sdk.identifier = self._identifier or "1178501"
    sdk.provider = self._provider or "Key System"
    self._junkie = sdk
    return sdk
end

function KeyUI:_verify(raw, silent)
    if self._busy or self._closed then return false end
    local key = normalize(raw)
    if key == "" then
        if not silent then self:Notify("Missing key", "Paste your key first.", 4, "error") end
        return false
    end
    if os.clock() < self._lockedUntil then
        self:Notify("Slow down", "Please wait before trying again.", 4, "error")
        return false
    end

    self._busy = true
    if self._verifyButton then
        self._verifyButton.Text = "Verifying..."
        self._verifyButton.Active = false
    end

    local attempts = math.clamp(tonumber(self.Options.VerificationAttempts) or 3, 1, 3)
    local delaySeconds = math.max(tonumber(self.Options.RetryDelay) or 1.5, 0.5)
    local result, code, temporary = nil, "ERROR", false

    for attempt = 1, attempts do
        if self._closed then return false end
        self:Notify("Verification", "Checking key (" .. attempt .. "/" .. attempts .. ")...", 0)
        local sdk = self:_getJunkie()
        local ok = false
        result = nil
        if sdk then
            ok, result = pcall(sdk.check_key, key)
        end
        if ok and type(result) == "table" and result.valid == true then
            self._busy = false
            self._failed = 0
            env.SCRIPT_KEY = key
            if key ~= "KEYLESS" then self:SaveKey(key) end
            self:Notify("Verified", "Key accepted.", 0, "success")
            local callback = self.Callbacks.OnSuccess
            self:Destroy()
            if type(callback) == "function" then
                task.spawn(function()
                    local ran, err = pcall(callback, key, result)
                    if not ran then warn("[Macro Hub Key] OnSuccess: " .. tostring(err)) end
                end)
            end
            return true
        end

        code = not sdk and "SDK_UNAVAILABLE" or not ok and "NETWORK"
            or type(result) == "table" and (result.error or result.message)
            or "ERROR"
        code = tostring(code or "ERROR"):upper()
        temporary = code == "ERROR" or code == "NETWORK"
            or code == "SDK_UNAVAILABLE"
            or code:match("^HTTP 5%d%d") ~= nil

        -- Retry only temporary SDK/server errors. Invalid/expired/revoked
        -- keys are definitive responses and should not be spammed.
        if not temporary or attempt == attempts then break end
        self:Notify("Verification", "Temporary error. Retrying verification...", 0)
        task.wait(delaySeconds)
    end

    if self._closed then return false end
    self._busy = false
    if self._verifyButton then
        self._verifyButton.Text = "Verify Key"
        self._verifyButton.Active = true
    end

    if not temporary then
        self._failed = self._failed + 1
        if self._failed >= 5 then
            self._lockedUntil = os.clock() + 15
        elseif self._failed >= 3 then
            self._lockedUntil = os.clock() + 5
        end
    end
    -- Keep verified_key.txt and the prefilled textbox intact, even if
    -- revalidation fails. The user can retry or replace the key.
    self:Notify("Verification failed", errors[code] or (code == "SDK_UNAVAILABLE"
        and "Could not reach the verification service.") or code, 6, "error")
    if type(self.Callbacks.OnFailure) == "function" then
        task.spawn(self.Callbacks.OnFailure, code)
    end
    if code == "HWID_BANNED" then
        task.delay(2, function()
            if player and player.Parent then player:Kick("Hardware banned") end
        end)
    end
    return false
end

function KeyUI:LaunchJunkie(config)
    config = config or {}
    self._service = tostring(config.Service or "Key")
    self._identifier = tostring(config.Identifier or "1178501")
    self._provider = tostring(config.Provider or "Key System")
    self:_mount()
    task.spawn(function()
        local saved = self.Storage.AutoLoad and self:GetSavedKey() or nil
        local current = type(env.SCRIPT_KEY) == "string" and env.SCRIPT_KEY or nil
        local candidate = saved or current
        if candidate and candidate ~= "" and candidate ~= "KEYLESS" then
            if self._keyInput then self._keyInput.Text = candidate end
            if self:_verify(candidate, true) or self._closed then return end
        end
        if self.Options.Keyless ~= false and not self._closed then
            self:_verify("KEYLESS", true)
        end
    end)
    return self
end

function KeyUI:Launch()
    self:_mount()
    self:Notify("Configuration", "Use LaunchJunkie with your Junkie service.", 0, "error")
    return self
end

return KeyUI
