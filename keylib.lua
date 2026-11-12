local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerGui = player:WaitForChild("PlayerGui")

local UI = {}
local Palettes = {
    Dark = {
        Background = Color3.fromRGB(8, 14, 29),
        Surface = Color3.fromRGB(15, 25, 45),
        Input = Color3.fromRGB(9, 19, 36),
        Border = Color3.fromRGB(43, 62, 97),
        Text = Color3.fromRGB(239, 245, 255),
        Sub = Color3.fromRGB(151, 168, 197),
        Accent = Color3.fromRGB(65, 155, 255),
        Positive = Color3.fromRGB(74, 222, 128),
        Negative = Color3.fromRGB(251, 113, 133)
    },
    Light = {
        Background = Color3.fromRGB(242, 246, 252),
        Surface = Color3.fromRGB(255, 255, 255),
        Input = Color3.fromRGB(238, 244, 252),
        Border = Color3.fromRGB(191, 208, 233),
        Text = Color3.fromRGB(24, 40, 67),
        Sub = Color3.fromRGB(77, 100, 137),
        Accent = Color3.fromRGB(36, 112, 221),
        Positive = Color3.fromRGB(19, 130, 77),
        Negative = Color3.fromRGB(177, 43, 67)
    }
}

local function new(class, properties, parent)
    local object = Instance.new(class)
    for property, value in pairs(properties or {}) do
        object[property] = value
    end
    object.Parent = parent
    return object
end

local function rounded(object, radius)
    new("UICorner", {CornerRadius = UDim.new(0, radius or 9)}, object)
    return object
end

function UI:CreateWindow(options)
    options = options or {}
    local self = {
        _theme = options.Theme == "Light" and "Light" or "Dark",
        _bindings = {},
        _connections = {},
        _order = 0,
        _destroyed = false,
        _toastToken = 0,
        _icons = {Dark = options.IconDark or "", Light = options.IconLight or ""}
    }

    local function colors()
        return Palettes[self._theme]
    end

    local function bind(instance, property, color)
        table.insert(self._bindings, {instance, property, color})
        instance[property] = colors()[color]
        return instance
    end

    local function coloredStroke(instance)
        local line = new("UIStroke", {
            Thickness = 1, Transparency = 0.22,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        }, instance)
        bind(line, "Color", "Border")
        return line
    end

    local function label(parent, value, size, bold)
        local component = new("TextLabel", {
            BackgroundTransparency = 1, Text = tostring(value or ""),
            Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
            TextSize = size or 12, TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center
        }, parent)
        bind(component, "TextColor3", bold and "Text" or "Sub")
        return component
    end

    local function interactive(parent, title, style)
        local item = rounded(new("TextButton", {
            Text = tostring(title or "Open"), Font = Enum.Font.GothamBold,
            TextSize = 12, AutoButtonColor = true,
            BorderSizePixel = 0
        }, parent), 9)
        bind(item, "BackgroundColor3", style == "Primary" and "Accent" or "Input")
        if style == "Primary" then
            item.TextColor3 = Color3.new(1, 1, 1)
        else
            bind(item, "TextColor3", "Text")
            coloredStroke(item)
        end
        return item
    end

    local existing = playerGui:FindFirstChild("MacroHubKeyDesign")
    if existing then existing:Destroy() end

    local gui = new("ScreenGui", {
        Name = "MacroHubKeyDesign", IgnoreGuiInset = true,
        ResetOnSpawn = false, DisplayOrder = 1001,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, playerGui)
    self._gui = gui

    local overlay = new("Frame", {
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.52,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1)
    }, gui)

    local card = rounded(new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(490, 478),
        BorderSizePixel = 0
    }, overlay), 16)
    bind(card, "BackgroundColor3", "Surface")
    coloredStroke(card)

    local scale = new("UIScale", {Scale = 1}, card)
    local function resize()
        local screen = overlay.AbsoluteSize
        if screen.X == 0 or screen.Y == 0 then return end
        scale.Scale = math.clamp(math.min((screen.X - 26) / 500, (screen.Y - 26) / 492), 0.45, 1)
    end
    resize()
    table.insert(self._connections, overlay:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize))

    local image = new("ImageLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(22, 22),
        Size = UDim2.fromOffset(44, 44), ScaleType = Enum.ScaleType.Fit
    }, card)
    self._image = image
    local title = label(card, options.Title or "Macro Hub", 20, true)
    title.Position = UDim2.fromOffset(78, 20)
    title.Size = UDim2.fromOffset(265, 30)
    local subtitle = label(card, options.Subtitle or "", 12, false)
    subtitle.Position = UDim2.fromOffset(78, 49)
    subtitle.Size = UDim2.fromOffset(295, 27)

    local themeButton = interactive(card, "Light", "Secondary")
    themeButton.Size = UDim2.fromOffset(56, 29)
    themeButton.Position = UDim2.fromOffset(358, 28)
    themeButton.TextSize = 11
    local closeButton = interactive(card, "×", "Secondary")
    closeButton.Size = UDim2.fromOffset(32, 29)
    closeButton.Position = UDim2.fromOffset(427, 28)

    local line = new("Frame", {
        BorderSizePixel = 0, Position = UDim2.fromOffset(23, 91),
        Size = UDim2.fromOffset(444, 1)
    }, card)
    bind(line, "BackgroundColor3", "Border")

    local body = new("ScrollingFrame", {
        Name = "Components", BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.fromOffset(23, 103),
        Size = UDim2.new(1, -46, 1, -116),
        ScrollBarThickness = 0, ScrollBarImageTransparency = 1,
        ScrollingEnabled = true, ClipsDescendants = true,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.fromOffset(0, 0)
    }, card)
    new("UIPadding", {
        PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 3)
    }, body)
    new("UIListLayout", {
        Padding = UDim.new(0, 9), SortOrder = Enum.SortOrder.LayoutOrder
    }, body)

    local toast = rounded(new("TextLabel", {
        BackgroundTransparency = 0, Visible = false, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(.5, 1), Position = UDim2.new(.5, 0, 1, -15),
        Size = UDim2.fromOffset(415, 39), TextWrapped = true,
        Font = Enum.Font.GothamMedium, TextSize = 12, ZIndex = 6
    }, card), 9)
    bind(toast, "BackgroundColor3", "Input")

    local function refresh()
        if self._destroyed then return end
        for _, record in ipairs(self._bindings) do
            if record[1].Parent then
                record[1][record[2]] = colors()[record[3]]
            end
        end
        image.Image = self._icons[self._theme] ~= ""
            and ("rbxassetid://" .. tostring(self._icons[self._theme])) or ""
        themeButton.Text = self._theme == "Dark" and "Light" or "Dark"
    end

    local function invoke(callback, ...)
        if type(callback) ~= "function" then return end
        local args = table.pack(...)
        task.spawn(function()
            local ok = pcall(callback, table.unpack(args, 1, args.n))
            if not ok and not self._destroyed then
                self:Notify("Action could not be completed.", "error", 4)
            end
        end)
    end

    function self:SetTheme(value)
        if value ~= "Dark" and value ~= "Light" then return end
        self._theme = value
        refresh()
    end

    function self:Notify(message, kind, seconds)
        if self._destroyed then return end
        self._toastToken = self._toastToken + 1
        local token = self._toastToken
        toast.Text = tostring(message or "")
        toast.TextColor3 = colors()[kind == "error" and "Negative"
            or kind == "success" and "Positive" or "Text"]
        toast.Visible = true
        if (tonumber(seconds) or 4) > 0 then
            task.delay(tonumber(seconds) or 4, function()
                if not self._destroyed and token == self._toastToken then
                    toast.Visible = false
                end
            end)
        end
    end

    local function block(height)
        self._order = self._order + 1
        return new("Frame", {
            BackgroundTransparency = 1, LayoutOrder = self._order,
            Size = UDim2.new(1, -3, 0, height or 42)
        }, body)
    end

    function self:Textbox(config)
        config = config or {}
        local box = block(config.Height or 77)
        local heading = label(box, config.Label or "", 11, true)
        heading.Size = UDim2.new(1, 0, 0, 20)
        heading.Position = UDim2.fromOffset(0, 0)
        local field = rounded(new("Frame", {
            BorderSizePixel = 0, Position = UDim2.fromOffset(0, 28),
            Size = UDim2.new(1, 0, 0, 44)
        }, box), 9)
        bind(field, "BackgroundColor3", "Input")
        coloredStroke(field)
        local actionText = config.ActionText
        local actionWidth = actionText and 75 or 0
        local input = new("TextBox", {
            ClearTextOnFocus = false, Text = tostring(config.Value or ""),
            PlaceholderText = tostring(config.Placeholder or ""),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Font = Enum.Font.Code, TextSize = 13,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(12, 0),
            Size = UDim2.new(1, -(20 + actionWidth), 1, 0)
        }, field)
        bind(input, "TextColor3", "Text")
        bind(input, "PlaceholderColor3", "Sub")
        local result = {
            Instance = input,
            GetValue = function() return input.Text end,
            SetValue = function(_, value) input.Text = tostring(value or "") end,
            Focus = function() input:CaptureFocus() end
        }
        if actionText then
            local action = interactive(field, actionText, "Secondary")
            action.Size = UDim2.fromOffset(66, 29)
            action.Position = UDim2.new(1, -73, 0.5, -14)
            action.TextSize = 11
            action.MouseButton1Click:Connect(function()
                invoke(config.OnAction, result)
            end)
        end
        input.FocusLost:Connect(function(enterPressed)
            if enterPressed then invoke(config.OnSubmit, input.Text) end
        end)
        return result
    end

    function self:Status(config)
        config = config or {}
        local frame = block(config.Height or 40)
        local status = label(frame, config.Text or "", 12, false)
        status.Size = UDim2.fromScale(1, 1)
        local function set(value, kind)
            status.Text = tostring(value or "")
            status.TextColor3 = colors()[kind == "error" and "Negative"
                or kind == "success" and "Positive" or "Sub"]
        end
        set(config.Text or "", config.Kind)
        return {Set = function(_, value, kind) set(value, kind) end}
    end

    function self:Text(config)
        config = config or {}
        local frame = block(config.Height or 35)
        local component = label(frame, config.Text or "", config.Size or 11, config.Bold)
        component.Size = UDim2.fromScale(1, 1)
        component.TextXAlignment = config.Align == "Center"
            and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
        return {Set = function(_, value) component.Text = tostring(value or "") end}
    end

    function self:Divider()
        local frame = block(10)
        local line = new("Frame", {
            BorderSizePixel = 0, Position = UDim2.new(0, 0, .5, 0),
            Size = UDim2.new(1, 0, 0, 1)
        }, frame)
        bind(line, "BackgroundColor3", "Border")
    end

    function self:Button(config)
        config = config or {}
        local frame = block(config.Height or 42)
        local item = interactive(frame, config.Text, config.Style)
        item.Size = UDim2.fromScale(1, 1)
        item.MouseButton1Click:Connect(function() invoke(config.Callback) end)
        return {
            SetText = function(_, value) item.Text = tostring(value or "") end,
            SetEnabled = function(_, enabled)
                item.Active = enabled == true
                item.AutoButtonColor = enabled == true
                item.TextTransparency = enabled and 0 or .45
            end
        }
    end

    function self:ButtonRow(buttons)
        buttons = buttons or {}
        local frame = block(40)
        local layout = new("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 9)
        }, frame)
        for index, config in ipairs(buttons) do
            local item = interactive(frame, config.Text, config.Style)
            item.LayoutOrder = index
            item.Size = UDim2.new(1 / #buttons, -9 * (#buttons - 1) / #buttons, 1, 0)
            item.MouseButton1Click:Connect(function() invoke(config.Callback) end)
        end
        return layout
    end

    function self:Destroy()
        if self._destroyed then return end
        self._destroyed = true
        for _, connection in ipairs(self._connections) do
            connection:Disconnect()
        end
        gui:Destroy()
    end

    themeButton.MouseButton1Click:Connect(function()
        self:SetTheme(self._theme == "Dark" and "Light" or "Dark")
    end)
    closeButton.MouseButton1Click:Connect(function()
        self:Destroy()
        invoke(options.OnClose)
    end)

    local dragging, dragStart, startPosition = false, nil, nil
    table.insert(self._connections, card.InputBegan:Connect(function(input)
        if options.Draggable == false then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then return end
        if input.Position.Y - card.AbsolutePosition.Y > 83 * scale.Scale then return end
        dragging = true
        dragStart = input.Position
        startPosition = card.Position
        local endConnection
        endConnection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                endConnection:Disconnect()
            end
        end)
    end))
    table.insert(self._connections, UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = input.Position - dragStart
        card.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end))
    refresh()
    return self
end

return UI
