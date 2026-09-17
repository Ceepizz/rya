--// LiveChat.lua
--// GitHub-ready module for the existing Auto Progress "Live Chat" tab.
--// Usage:
--// local LiveChatModule = loadstring(game:HttpGet("RAW_GITHUB_URL"))()
--// LiveChatModule(LiveChatTab, Library)

return function(LiveChatTab, Library)
    local HttpService = game:GetService("HttpService")

    if not LiveChatTab or not LiveChatTab.Container then
        warn("[Live Chat] Missing LiveChatTab.Container")
        return
    end

    --========================================================
    -- CONFIG
    --========================================================

    local CHAT_ROOM = "rbx-livechat-ce16ff31271e696c85c38205dcbb377a"
    local BASE_URL = "https://ntfy.sh"

    local POLL_INTERVAL = 7
    local SEND_COOLDOWN = 10
    local MAX_MESSAGE_LENGTH = 150
    local HISTORY_WINDOW = "2m"

    --========================================================
    -- EXECUTOR HTTP
    --========================================================

    local env = _G

    if typeof(getgenv) == "function" then
        local ok, result = pcall(getgenv)

        if ok and type(result) == "table" then
            env = result
        end
    end

    local httpRequest =
        env.request
        or request
        or http_request
        or (syn and syn.request)
        or (fluxus and fluxus.request)

    local function performRequest(options)
        if not httpRequest then
            return nil, "No supported HTTP request function found."
        end

        local ok, response = pcall(function()
            return httpRequest(options)
        end)

        if not ok then
            return nil, tostring(response)
        end

        return response
    end

    local function responseCode(response)
        if not response then
            return 0
        end

        return tonumber(
            response.StatusCode
            or response.Status
            or response.status_code
            or 0
        ) or 0
    end

    local function responseBody(response)
        if not response then
            return ""
        end

        return response.Body
            or response.body
            or ""
    end

    --========================================================
    -- ANONYMOUS User### ID
    --========================================================

    if type(env.__RyaLiveChatAlias) ~= "string"
        or not env.__RyaLiveChatAlias:match("^User%d%d%d$") then

        env.__RyaLiveChatAlias = string.format(
            "User%03d",
            math.random(0, 999)
        )
    end

    local CHAT_USER = env.__RyaLiveChatAlias

    --========================================================
    -- CLEAN PREVIOUS CHAT INSTANCE
    --========================================================

    local Parent = LiveChatTab.Container

    local oldRoot = Parent:FindFirstChild("RyaLiveChatRoot")

    if oldRoot then
        oldRoot:Destroy()
    end

    -- This tab only contains the live chat root, so disable the
    -- outer tab scroller. The message list itself handles scrolling.
    if Parent:IsA("ScrollingFrame") then
        Parent.ScrollingEnabled = false
        Parent.CanvasPosition = Vector2.zero
        Parent.CanvasSize = UDim2.fromOffset(0, 0)

        pcall(function()
            Parent.AutomaticCanvasSize = Enum.AutomaticSize.None
        end)
    end

    --========================================================
    -- ROOT
    --========================================================

    local Root = Instance.new("Frame")
    Root.Name = "RyaLiveChatRoot"
    Root.Size = UDim2.new(1, -2, 0, 274)
    Root.BackgroundTransparency = 1
    Root.BorderSizePixel = 0
    Root.Parent = Parent

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 32)
    Header.BackgroundColor3 = Color3.fromRGB(30, 27, 38)
    Header.BorderSizePixel = 0
    Header.Parent = Root

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 6)
    HeaderCorner.Parent = Header

    local HeaderStroke = Instance.new("UIStroke")
    HeaderStroke.Color = Color3.fromRGB(62, 55, 78)
    HeaderStroke.Transparency = 0.35
    HeaderStroke.Parent = Header

    local Status = Instance.new("TextLabel")
    Status.Name = "Status"
    Status.Size = UDim2.new(1, -16, 1, 0)
    Status.Position = UDim2.fromOffset(8, 0)
    Status.BackgroundTransparency = 1
    Status.Font = Enum.Font.Gotham
    Status.Text = CHAT_USER .. "  •  Connecting..."
    Status.TextColor3 = Color3.fromRGB(178, 170, 194)
    Status.TextSize = 11
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.Parent = Header

    --========================================================
    -- MESSAGE LIST
    --========================================================

    local Messages = Instance.new("ScrollingFrame")
    Messages.Name = "Messages"
    Messages.Position = UDim2.fromOffset(0, 40)
    Messages.Size = UDim2.new(1, 0, 1, -84)
    Messages.BackgroundColor3 = Color3.fromRGB(22, 20, 28)
    Messages.BackgroundTransparency = 0.12
    Messages.BorderSizePixel = 0
    Messages.ScrollBarThickness = 3
    Messages.ScrollBarImageColor3 = Color3.fromRGB(116, 92, 160)
    Messages.CanvasSize = UDim2.fromOffset(0, 0)
    Messages.AutomaticCanvasSize = Enum.AutomaticSize.None
    Messages.Parent = Root

    local MessagesCorner = Instance.new("UICorner")
    MessagesCorner.CornerRadius = UDim.new(0, 6)
    MessagesCorner.Parent = Messages

    local MessagesStroke = Instance.new("UIStroke")
    MessagesStroke.Color = Color3.fromRGB(58, 52, 72)
    MessagesStroke.Transparency = 0.45
    MessagesStroke.Parent = Messages

    local MessagesPadding = Instance.new("UIPadding")
    MessagesPadding.PaddingTop = UDim.new(0, 7)
    MessagesPadding.PaddingBottom = UDim.new(0, 7)
    MessagesPadding.PaddingLeft = UDim.new(0, 8)
    MessagesPadding.PaddingRight = UDim.new(0, 8)
    MessagesPadding.Parent = Messages

    local MessagesLayout = Instance.new("UIListLayout")
    MessagesLayout.Padding = UDim.new(0, 6)
    MessagesLayout.SortOrder = Enum.SortOrder.LayoutOrder
    MessagesLayout.Parent = Messages

    local function refreshCanvas()
        Messages.CanvasSize = UDim2.fromOffset(
            0,
            MessagesLayout.AbsoluteContentSize.Y + 14
        )
    end

    MessagesLayout:GetPropertyChangedSignal(
        "AbsoluteContentSize"
    ):Connect(refreshCanvas)

    local function scrollToBottom()
        task.defer(function()
            if not Root.Parent then
                return
            end

            task.wait()

            Messages.CanvasPosition = Vector2.new(
                0,
                math.max(
                    0,
                    MessagesLayout.AbsoluteContentSize.Y
                        - Messages.AbsoluteWindowSize.Y
                        + 14
                )
            )
        end)
    end

    --========================================================
    -- FIXED INPUT BAR
    --========================================================

    local InputBar = Instance.new("Frame")
    InputBar.Name = "InputBar"
    InputBar.Size = UDim2.new(1, 0, 0, 42)
    InputBar.Position = UDim2.new(0, 0, 1, -42)
    InputBar.BackgroundTransparency = 1
    InputBar.Parent = Root

    local Input = Instance.new("TextBox")
    Input.Name = "Input"
    Input.Size = UDim2.new(1, -86, 1, 0)
    Input.BackgroundColor3 = Color3.fromRGB(31, 28, 39)
    Input.BorderSizePixel = 0
    Input.ClearTextOnFocus = false
    Input.Font = Enum.Font.Gotham
    Input.PlaceholderText = "Type a message..."
    Input.PlaceholderColor3 = Color3.fromRGB(126, 119, 139)
    Input.Text = ""
    Input.TextColor3 = Color3.fromRGB(238, 235, 244)
    Input.TextSize = 12
    Input.TextXAlignment = Enum.TextXAlignment.Left
    Input.Parent = InputBar

    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 6)
    InputCorner.Parent = Input

    local InputStroke = Instance.new("UIStroke")
    InputStroke.Color = Color3.fromRGB(61, 54, 77)
    InputStroke.Transparency = 0.4
    InputStroke.Parent = Input

    local InputPadding = Instance.new("UIPadding")
    InputPadding.PaddingLeft = UDim.new(0, 10)
    InputPadding.PaddingRight = UDim.new(0, 10)
    InputPadding.Parent = Input

    local Send = Instance.new("TextButton")
    Send.Name = "Send"
    Send.Size = UDim2.fromOffset(78, 42)
    Send.Position = UDim2.new(1, -78, 0, 0)
    Send.BackgroundColor3 = Color3.fromRGB(114, 78, 180)
    Send.BorderSizePixel = 0
    Send.AutoButtonColor = true
    Send.Font = Enum.Font.GothamBold
    Send.Text = "SEND"
    Send.TextColor3 = Color3.fromRGB(255, 255, 255)
    Send.TextSize = 11
    Send.Parent = InputBar

    local SendCorner = Instance.new("UICorner")
    SendCorner.CornerRadius = UDim.new(0, 6)
    SendCorner.Parent = Send

    --========================================================
    -- STATE
    --========================================================

    local alive = true
    local sending = false
    local cooldownUntil = 0

    local lastNtfyID = nil
    local bootstrapped = false

    local seenNtfyMessages = {}
    local seenClientMessages = {}

    local messageIndex = 0

    Root.Destroying:Connect(function()
        alive = false
    end)

    --========================================================
    -- HELPERS
    --========================================================

    local function setStatus(text, color)
        if not alive or not Status.Parent then
            return
        end

        Status.Text = CHAT_USER .. "  •  " .. tostring(text)

        if color then
            Status.TextColor3 = color
        end
    end

    local function decodeJSON(text)
        local ok, result = pcall(function()
            return HttpService:JSONDecode(text)
        end)

        if ok then
            return result
        end

        return nil
    end

    local function escapeRichText(text)
        text = tostring(text or "")
        text = text:gsub("&", "&amp;")
        text = text:gsub("<", "&lt;")
        text = text:gsub(">", "&gt;")
        text = text:gsub('"', "&quot;")
        text = text:gsub("'", "&apos;")
        return text
    end

    local function addMessage(username, message, timestamp)
        if not alive or not Root.Parent then
            return
        end

        username = tostring(username or "User000")
        message = tostring(message or "")

        if not username:match("^User%d%d%d$") then
            return
        end

        messageIndex += 1

        local timeText = "--:--"

        if timestamp then
            local ok, formatted = pcall(function()
                return os.date("%H:%M", timestamp)
            end)

            if ok and formatted then
                timeText = formatted
            end
        end

        local Line = Instance.new("TextLabel")
        Line.Name = "Message_" .. tostring(messageIndex)
        Line.Size = UDim2.new(1, -2, 0, 0)
        Line.AutomaticSize = Enum.AutomaticSize.Y
        Line.BackgroundTransparency = 1
        Line.Font = Enum.Font.Gotham
        Line.RichText = true
        Line.TextWrapped = true
        Line.TextXAlignment = Enum.TextXAlignment.Left
        Line.TextYAlignment = Enum.TextYAlignment.Top
        Line.TextColor3 = Color3.fromRGB(232, 229, 238)
        Line.TextSize = 12
        Line.LayoutOrder = messageIndex

        local nameColor =
            username == CHAT_USER
            and "#C9A7FF"
            or "#AEB3C2"

        Line.Text =
            '<font color="' .. nameColor .. '"><b>'
            .. escapeRichText(username)
            .. '</b></font>'
            .. '  <font color="#7F7F8E">'
            .. escapeRichText(timeText)
            .. '</font>\n'
            .. escapeRichText(message)

        Line.Parent = Messages

        scrollToBottom()
    end

    --========================================================
    -- POLLING
    --========================================================

    local function pollMessages()
        if not alive or not httpRequest then
            return
        end

        local since

        if lastNtfyID then
            since = lastNtfyID
        elseif not bootstrapped then
            since = HISTORY_WINDOW
        else
            since = "1m"
        end

        local url =
            BASE_URL
            .. "/"
            .. CHAT_ROOM
            .. "/json?poll=1&since="
            .. since

        local response = performRequest({
            Url = url,
            Method = "GET",
            Headers = {
                ["Accept"] = "application/json"
            }
        })

        bootstrapped = true

        if not response then
            setStatus(
                "Connection error",
                Color3.fromRGB(255, 125, 125)
            )
            return
        end

        local code = responseCode(response)

        if code == 429 then
            setStatus(
                "Rate limited",
                Color3.fromRGB(255, 196, 94)
            )
            return
        end

        if code < 200 or code >= 300 then
            setStatus(
                "HTTP " .. tostring(code),
                Color3.fromRGB(255, 125, 125)
            )
            return
        end

        setStatus(
            "Connected",
            Color3.fromRGB(117, 225, 151)
        )

        local body = responseBody(response)

        if body == "" then
            return
        end

        for line in body:gmatch("[^\r\n]+") do
            local data = decodeJSON(line)

            if type(data) == "table"
                and data.event == "message"
                and type(data.id) == "string" then

                lastNtfyID = data.id

                if not seenNtfyMessages[data.id] then
                    seenNtfyMessages[data.id] = true

                    local payload = decodeJSON(data.message or "")

                    if type(payload) == "table"
                        and payload.version == 1
                        and type(payload.user) == "string"
                        and payload.user:match("^User%d%d%d$")
                        and type(payload.message) == "string" then

                        local clientMessageID = payload.id

                        if not clientMessageID
                            or not seenClientMessages[clientMessageID] then

                            if clientMessageID then
                                seenClientMessages[clientMessageID] = true
                            end

                            addMessage(
                                payload.user,
                                payload.message:sub(
                                    1,
                                    MAX_MESSAGE_LENGTH
                                ),
                                tonumber(data.time)
                            )
                        end
                    end
                end
            end
        end
    end

    --========================================================
    -- 10 SECOND COOLDOWN
    --========================================================

    local function updateCooldownButton()
        task.spawn(function()
            while alive and Root.Parent do
                local remaining =
                    math.ceil(cooldownUntil - os.clock())

                if remaining <= 0 then
                    if not sending then
                        Send.Text = "SEND"
                        Send.BackgroundColor3 =
                            Color3.fromRGB(114, 78, 180)
                        Send.AutoButtonColor = true
                    end

                    return
                end

                Send.Text = tostring(remaining) .. "s"
                Send.BackgroundColor3 =
                    Color3.fromRGB(67, 62, 76)
                Send.AutoButtonColor = false

                task.wait(0.15)
            end
        end)
    end

    --========================================================
    -- SEND
    --========================================================

    local function sendMessage()
        if sending or not alive then
            return
        end

        if os.clock() < cooldownUntil then
            return
        end

        local text = tostring(Input.Text or "")

        text = text:gsub("^%s+", "")
        text = text:gsub("%s+$", "")

        if text == "" then
            return
        end

        if #text > MAX_MESSAGE_LENGTH then
            text = text:sub(1, MAX_MESSAGE_LENGTH)
        end

        if not httpRequest then
            setStatus(
                "HTTP unsupported",
                Color3.fromRGB(255, 125, 125)
            )
            return
        end

        sending = true
        Send.Text = "..."
        Send.AutoButtonColor = false
        Send.BackgroundColor3 =
            Color3.fromRGB(67, 62, 76)

        local clientMessageID =
            HttpService:GenerateGUID(false)

        local payload = {
            version = 1,
            id = clientMessageID,
            user = CHAT_USER,
            message = text
        }

        local response = performRequest({
            Url = BASE_URL .. "/" .. CHAT_ROOM,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "text/plain"
            },
            Body = HttpService:JSONEncode(payload)
        })

        local code = responseCode(response)

        if response and code >= 200 and code < 300 then
            Input.Text = ""

            seenClientMessages[clientMessageID] = true

            addMessage(
                CHAT_USER,
                text,
                os.time()
            )

            setStatus(
                "Connected",
                Color3.fromRGB(117, 225, 151)
            )

            -- Cooldown begins only after a successful send.
            cooldownUntil =
                os.clock() + SEND_COOLDOWN
        else
            setStatus(
                code == 429
                    and "Rate limited"
                    or "Failed to send",
                Color3.fromRGB(255, 125, 125)
            )
        end

        sending = false
        updateCooldownButton()
    end

    --========================================================
    -- INPUT EVENTS
    --========================================================

    Input:GetPropertyChangedSignal("Text"):Connect(function()
        if #Input.Text > MAX_MESSAGE_LENGTH then
            Input.Text =
                Input.Text:sub(1, MAX_MESSAGE_LENGTH)
        end
    end)

    Send.MouseButton1Click:Connect(function()
        task.spawn(sendMessage)
    end)

    Input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            task.spawn(sendMessage)
        end
    end)

    --========================================================
    -- START
    --========================================================

    if not httpRequest then
        setStatus(
            "Executor has no HTTP API",
            Color3.fromRGB(255, 125, 125)
        )
    else
        task.spawn(function()
            pollMessages()

            while alive and Root.Parent do
                task.wait(POLL_INTERVAL)

                if alive and Root.Parent then
                    pollMessages()
                end
            end
        end)
    end

    return {
        Root = Root,
        User = CHAT_USER,
        Destroy = function()
            alive = false

            if Root and Root.Parent then
                Root:Destroy()
            end
        end
    }
end
