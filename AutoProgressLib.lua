
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Library = {}

Library.Theme = {
    Background = Color3.fromRGB(24, 24, 31),
    Surface = Color3.fromRGB(29, 28, 38),
    Border = Color3.fromRGB(36, 35, 48),

    Accent = Color3.fromRGB(108, 30, 210),
    AccentHover = Color3.fromRGB(124, 44, 227),
    AccentPressed = Color3.fromRGB(89, 23, 180),

    Text = Color3.fromRGB(255, 255, 255),
    Muted = Color3.fromRGB(150, 150, 150),

    Green = Color3.fromRGB(86, 200, 120),
    Red = Color3.fromRGB(220, 90, 90)
}

local C = Library.Theme

local function Corner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function Stroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or C.Border
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
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
    button.Font = Enum.Font.GothamSemibold
    button.AutoButtonColor = false
    button.Parent = parent

    Corner(button, 8)

    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = C.AccentHover
    end)

    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = C.Accent
    end)

    button.MouseButton1Down:Connect(function()
        button.BackgroundColor3 = C.AccentPressed
    end)

    button.MouseButton1Up:Connect(function()
        button.BackgroundColor3 = C.AccentHover
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
    label.Font = Enum.Font.Gotham
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
    box.PlaceholderColor3 = C.Muted
    box.Text = options.Text or ""
    box.TextColor3 = C.Text
    box.TextSize = options.TextSize or 13
    box.Font = Enum.Font.Gotham
    box.ClearTextOnFocus = false
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.Parent = parent

    Corner(box, 8)
    Stroke(box, C.Border, 1)

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
    main.Parent = gui

    Corner(main, 12)
    Stroke(main, C.Border, 1)

    local topbar = Instance.new("Frame")
    topbar.Name = "Topbar"
    topbar.Size = UDim2.new(1, 0, 0, 52)
    topbar.BackgroundColor3 = C.Surface
    topbar.BorderSizePixel = 0
    topbar.Active = true
    topbar.Parent = main

    Corner(topbar, 12)

    local topFix = Instance.new("Frame")
    topFix.Size = UDim2.new(1, 0, 0, 12)
    topFix.Position = UDim2.new(0, 0, 1, -12)
    topFix.BackgroundColor3 = C.Surface
    topFix.BorderSizePixel = 0
    topFix.Parent = topbar

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.fromOffset(18, 0)
    title.BackgroundTransparency = 1
    title.Text = options.Title or "Auto Progress"
    title.TextColor3 = C.Text
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = topbar

    local close = Instance.new("TextButton")
    close.Size = UDim2.fromOffset(34, 34)
    close.Position = UDim2.new(1, -44, 0.5, -17)
    close.BackgroundColor3 = C.Border
    close.BorderSizePixel = 0
    close.Text = "×"
    close.TextColor3 = C.Text
    close.TextSize = 22
    close.Font = Enum.Font.GothamBold
    close.AutoButtonColor = false
    close.Parent = topbar

    Corner(close, 8)

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -24, 1, -76)
    content.Position = UDim2.fromOffset(12, 64)
    content.BackgroundTransparency = 1
    content.Parent = main

    close.MouseButton1Click:Connect(function()
        gui:Destroy()
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
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = false
        end
    end)

    local window = {
        Gui = gui,
        Main = main,
        Topbar = topbar,
        Content = content,
        Theme = C,
        Width = options.Width or 430,
        CompactHeight = options.CompactHeight or 150,
        ExpandedHeight = options.ExpandedHeight or 470
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

    return window
end

shared.AutoProgressLibrary = Library
return Library
