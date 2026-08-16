local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Library = {}

Library.Theme = {
    Background = Color3.fromRGB(18, 24, 32),
    Background2 = Color3.fromRGB(21, 31, 42),
    Surface = Color3.fromRGB(24, 35, 46),
    Surface2 = Color3.fromRGB(27, 43, 56),
    Border = Color3.fromRGB(48, 72, 86),
    Accent = Color3.fromRGB(0, 170, 210),
    Accent2 = Color3.fromRGB(0, 115, 155),
    AccentHover = Color3.fromRGB(35, 205, 230),
    AccentPressed = Color3.fromRGB(0, 95, 130),
    Text = Color3.fromRGB(238, 247, 250),
    Muted = Color3.fromRGB(238, 247, 250),
    Green = Color3.fromRGB(92, 190, 130),
    Red = Color3.fromRGB(210, 92, 104)
}

local C = Library.Theme

local function Corner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function Stroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or C.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.Parent = parent
    return stroke
end

local function Gradient(parent, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(1, color2)
    })
    gradient.Rotation = rotation or 90
    gradient.Parent = parent
    return gradient
end

function Library.FormatNumber(value)
    local n = math.floor(tonumber(value) or 0)
    local s = tostring(n)

    while true do
        local changed
        s, changed = s:gsub("^(-?%d+)(%d%d%d)", "%1,%2")

        if changed == 0 then
            break
        end
    end

    return s
end

function Library.CreateButton(parent, text, height)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, height or 42)
    button.BackgroundColor3 = C.Accent
    button.BorderSizePixel = 0
    button.Text = text or "Button"
    button.TextColor3 = C.Text
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.Parent = parent

    Corner(button, 9)
    Stroke(button, Color3.fromRGB(45, 130, 150), 1, 0.45)

    local gradient = Gradient(
        button,
        C.Accent,
        C.Accent2,
        90
    )

    button.MouseEnter:Connect(function()
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, C.AccentHover),
            ColorSequenceKeypoint.new(1, C.Accent)
        })
    end)

    button.MouseLeave:Connect(function()
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, C.Accent),
            ColorSequenceKeypoint.new(1, C.Accent2)
        })
    end)

    button.MouseButton1Down:Connect(function()
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, C.AccentPressed),
            ColorSequenceKeypoint.new(1, C.Accent2)
        })
    end)

    button.MouseButton1Up:Connect(function()
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, C.AccentHover),
            ColorSequenceKeypoint.new(1, C.Accent)
        })
    end)

    return button
end

function Library.CreateLabel(parent, text, height)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, height or 22)
    label.BackgroundTransparency = 1
    label.Text = text or ""
    label.TextColor3 = C.Muted
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

function Library.CreateTextBox(parent, options)
    options = options or {}

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, 0, 0, options.Height or 40)
    box.BackgroundColor3 = C.Surface
    box.BorderSizePixel = 0
    box.PlaceholderText = options.Placeholder or ""
    box.PlaceholderColor3 = C.Text
    box.Text = options.Text or ""
    box.TextColor3 = C.Text
    box.TextSize = options.TextSize or 13
    box.Font = Enum.Font.GothamBold
    box.ClearTextOnFocus = false
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.Parent = parent

    Corner(box, 9)
    Stroke(box, C.Border, 1, 0.2)
    Gradient(box, C.Surface2, C.Surface, 90)

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = box

    return box
end

function Library.CreatePage(parent, scrolling)
    if scrolling then
        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.fromScale(1, 1)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = C.Accent
        page.CanvasSize = UDim2.new()
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.Parent = parent
        return page
    end

    local page = Instance.new("Frame")
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.Parent = parent
    return page
end

function Library.AddListLayout(parent, padding)
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, padding or 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = parent
    return layout
end

function Library.CreateWindow(options)
    options = options or {}

    local old = CoreGui:FindFirstChild(
        options.GuiName or "AutoProgressGui"
    )

    if old then
        old:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = options.GuiName or "AutoProgressGui"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = CoreGui

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.fromOffset(
        options.Width or 430,
        options.CompactHeight or 150
    )
    main.Position = UDim2.new(
        0.5,
        -math.floor((options.Width or 430) / 2),
        0.5,
        -math.floor((options.CompactHeight or 150) / 2)
    )
    main.BackgroundColor3 = C.Background
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = gui

    Corner(main, 13)
    Stroke(main, C.Border, 1, 0.05)
    Gradient(main, C.Background2, C.Background, 90)

    local topbar = Instance.new("Frame")
    topbar.Name = "Topbar"
    topbar.Size = UDim2.new(1, 0, 0, 52)
    topbar.BackgroundColor3 = C.Surface
    topbar.BorderSizePixel = 0
    topbar.Active = true
    topbar.Parent = main

    Gradient(topbar, C.Surface2, C.Surface, 0)

    local topbarLine = Instance.new("Frame")
    topbarLine.Size = UDim2.new(1, 0, 0, 1)
    topbarLine.Position = UDim2.new(0, 0, 1, -1)
    topbarLine.BackgroundColor3 = C.Border
    topbarLine.BackgroundTransparency = 0.15
    topbarLine.BorderSizePixel = 0
    topbarLine.Parent = topbar

    local logo = Instance.new("ImageLabel")
    logo.Name = "Logo"
    logo.Size = UDim2.fromOffset(34, 34)
    logo.Position = UDim2.fromOffset(11, 9)
    logo.BackgroundTransparency = 1
    logo.Image = "rbxassetid://87824587597558"
    logo.ImageColor3 = Color3.fromRGB(255, 255, 255)
    logo.ImageTransparency = 0
    logo.ScaleType = Enum.ScaleType.Fit
    logo.Parent = topbar

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -150, 1, 0)
    title.Position = UDim2.fromOffset(54, 0)
    title.BackgroundTransparency = 1
    title.Text = options.Title or "Auto Progress"
    title.TextColor3 = C.Text
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = topbar

    local minimize = Instance.new("TextButton")
    minimize.Name = "Minimize"
    minimize.Size = UDim2.fromOffset(34, 34)
    minimize.Position = UDim2.new(1, -82, 0.5, -17)
    minimize.BackgroundColor3 = Color3.fromRGB(28, 48, 58)
    minimize.BorderSizePixel = 0
    minimize.Text = "−"
    minimize.TextColor3 = C.Muted
    minimize.TextSize = 22
    minimize.Font = Enum.Font.GothamBold
    minimize.AutoButtonColor = false
    minimize.Parent = topbar

    Corner(minimize, 8)
    Stroke(minimize, C.Border, 1, 0.25)

    local close = Instance.new("TextButton")
    close.Name = "Close"
    close.Size = UDim2.fromOffset(34, 34)
    close.Position = UDim2.new(1, -43, 0.5, -17)
    close.BackgroundColor3 = Color3.fromRGB(28, 48, 58)
    close.BorderSizePixel = 0
    close.Text = "×"
    close.TextColor3 = C.Muted
    close.TextSize = 20
    close.Font = Enum.Font.GothamBold
    close.AutoButtonColor = false
    close.Parent = topbar

    Corner(close, 8)
    Stroke(close, C.Border, 1, 0.25)

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -24, 1, -76)
    content.Position = UDim2.fromOffset(12, 64)
    content.BackgroundTransparency = 1
    content.Parent = main

    local floating = Instance.new("ImageButton")
    floating.Name = "FloatingLogo"
    floating.Size = UDim2.fromOffset(58, 58)
    floating.Position = UDim2.new(0, 18, 0.5, -29)
    floating.BackgroundTransparency = 1
    floating.BorderSizePixel = 0
    floating.AutoButtonColor = false
    floating.Image = "rbxassetid://87824587597558"
    floating.ImageColor3 = Color3.fromRGB(255, 255, 255)
    floating.ImageTransparency = 0
    floating.ScaleType = Enum.ScaleType.Fit
    floating.Visible = false
    floating.Parent = gui


    local floatingPadding = Instance.new("UIPadding")
    floatingPadding.PaddingTop = UDim.new(0, 7)
    floatingPadding.PaddingBottom = UDim.new(0, 7)
    floatingPadding.PaddingLeft = UDim.new(0, 7)
    floatingPadding.PaddingRight = UDim.new(0, 7)
    floatingPadding.Parent = floating

    local function setButtonHover(button, hovering)
        button.BackgroundColor3 =
            hovering
            and Color3.fromRGB(38, 69, 80)
            or Color3.fromRGB(28, 48, 58)
        button.TextColor3 =
            hovering
            and C.Text
            or C.Muted
    end

    minimize.MouseEnter:Connect(function()
        setButtonHover(minimize, true)
    end)

    minimize.MouseLeave:Connect(function()
        setButtonHover(minimize, false)
    end)

    close.MouseEnter:Connect(function()
        close.BackgroundColor3 = Color3.fromRGB(91, 45, 55)
        close.TextColor3 = C.Text
    end)

    close.MouseLeave:Connect(function()
        close.BackgroundColor3 = Color3.fromRGB(28, 48, 58)
        close.TextColor3 = C.Muted
    end)

    close.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    minimize.MouseButton1Click:Connect(function()
        main.Visible = false
        floating.Visible = true
    end)

    local dragging = false
    local dragInput
    local dragStart
    local startPos

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)

    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            dragInput = input
        end
    end)

    local floatingDragging = false
    local floatingDragInput
    local floatingDragStart
    local floatingStartPos
    local floatingMoved = false

    floating.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            floatingDragging = true
            floatingMoved = false
            floatingDragStart = input.Position
            floatingStartPos = floating.Position
        end
    end)

    floating.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            floatingDragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging and main.Parent then
            local delta = input.Position - dragStart

            main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end

        if input == floatingDragInput
            and floatingDragging
            and floating.Parent then

            local delta = input.Position - floatingDragStart

            if math.abs(delta.X) > 5
                or math.abs(delta.Y) > 5 then

                floatingMoved = true
            end

            floating.Position = UDim2.new(
                floatingStartPos.X.Scale,
                floatingStartPos.X.Offset + delta.X,
                floatingStartPos.Y.Scale,
                floatingStartPos.Y.Offset + delta.Y
            )
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = false
            floatingDragging = false
        end
    end)

    local lastFloatingClick = 0

    floating.MouseButton1Click:Connect(function()
        if floatingMoved then
            return
        end

        if os.clock() - lastFloatingClick < 0.1 then
            return
        end

        lastFloatingClick = os.clock()
        floating.Visible = false
        main.Visible = true
    end)

    local window = {
        Gui = gui,
        Main = main,
        Topbar = topbar,
        Content = content,
        Theme = C,
        Width = options.Width or 430,
        CompactHeight = options.CompactHeight or 150,
        ExpandedHeight = options.ExpandedHeight or 470,
        FloatingLogo = floating
    }

    function window:SetCompact()
        local width = self.Width
        local height = self.CompactHeight

        self.Main.Size = UDim2.fromOffset(width, height)
        self.Main.Position = UDim2.new(
            0.5,
            -math.floor(width / 2),
            0.5,
            -math.floor(height / 2)
        )
    end

    function window:SetExpanded()
        local width = self.Width
        local height = self.ExpandedHeight

        self.Main.Size = UDim2.fromOffset(width, height)
        self.Main.Position = UDim2.new(
            0.5,
            -math.floor(width / 2),
            0.5,
            -math.floor(height / 2)
        )
    end

    function window:Minimize()
        self.Main.Visible = false
        self.FloatingLogo.Visible = true
    end

    function window:Restore()
        self.FloatingLogo.Visible = false
        self.Main.Visible = true
    end

    return window
end

shared.AutoProgressLibrary = Library
return Library
