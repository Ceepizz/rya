-- Rya UI Library
-- Independent implementation for Auto Progress.
-- Does not use, modify, destroy, or depend on CoreGui.Aether.

local Library = {}

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

local GUI_NAME = "RyaAutoProgress"
local old = CoreGui:FindFirstChild(GUI_NAME)
if old then
    old:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 1000
ScreenGui.IgnoreGuiInset = false
ScreenGui.Parent = CoreGui

local C = {
    Background = Color3.fromRGB(29, 28, 38),
    Page = Color3.fromRGB(24, 24, 31),
    Border = Color3.fromRGB(36, 35, 48),
    Secondary = Color3.fromRGB(48, 47, 62),
    Accent = Color3.fromRGB(108, 30, 210),
    AccentHover = Color3.fromRGB(124, 44, 227),
    AccentPressed = Color3.fromRGB(89, 23, 180),
    Selected = Color3.fromRGB(225, 200, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Muted = Color3.fromRGB(150, 150, 150),
}

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = parent
    return c
end

local function stroke(parent, transparency, color)
    local s = Instance.new("UIStroke")
    s.Color = color or C.Border
    s.Transparency = transparency or 0
    s.Thickness = 1
    s.Parent = parent
    return s
end

local function tween(obj, t, props)
    local tw = TweenService:Create(
        obj,
        TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        props
    )
    tw:Play()
    return tw
end

local function makeText(parent, text, size, bold)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.BorderSizePixel = 0
    l.Text = tostring(text or "")
    l.TextColor3 = C.Text
    l.TextSize = size or 12
    l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.TextWrapped = true
    l.Parent = parent
    return l
end

local function makeButtonOverlay(parent)
    local b = Instance.new("TextButton")
    b.BackgroundTransparency = 1
    b.BorderSizePixel = 0
    b.Text = ""
    b.Size = UDim2.fromScale(1, 1)
    b.Parent = parent
    return b
end

local function makeRow(parent, title, desc, height)
    local row = Instance.new("Frame")
    row.Name = "Control"
    row.BackgroundColor3 = C.Background
    row.BorderSizePixel = 0
    row.Size = UDim2.new(1, 0, 0, height or ((desc and desc ~= "") and 52 or 40))
    row.Parent = parent
    corner(row, 7)
    stroke(row, 0.55, C.Border)

    local textArea = Instance.new("Frame")
    textArea.BackgroundTransparency = 1
    textArea.Position = UDim2.new(0, 12, 0, 5)
    textArea.Size = UDim2.new(1, -150, 1, -10)
    textArea.Parent = row

    local titleLabel = makeText(textArea, title, 12, true)
    titleLabel.Size = UDim2.new(1, 0, 0, desc and desc ~= "" and 20 or 30)

    local descLabel = makeText(textArea, desc or "", 10, false)
    descLabel.TextColor3 = C.Muted
    descLabel.Position = UDim2.new(0, 0, 0, 20)
    descLabel.Size = UDim2.new(1, 0, 1, -20)
    descLabel.Visible = desc ~= nil and desc ~= ""

    local api = {}

    function api:SetTitle(v)
        titleLabel.Text = tostring(v or "")
    end

    function api:SetDesc(v)
        v = tostring(v or "")
        descLabel.Text = v
        descLabel.Visible = v ~= ""
    end

    function api:SetVisible(v)
        row.Visible = v == true
    end

    api._Row = row
    api._Title = titleLabel
    api._Desc = descLabel

    return row, api
end

local function enableDrag(handle, target)
    local dragging = false
    local dragStart
    local startPos
    local dragInput

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Library:Window(p)
    p = p or {}
    p.Config = p.Config or {}

    local size = p.Config.Size or UDim2.new(0, 530, 0, 400)
    local keybind = p.Config.Keybind or Enum.KeyCode.LeftControl

    local root = Instance.new("Frame")
    root.Name = "Window"
    root.AnchorPoint = Vector2.new(0.5, 0.5)
    root.Position = UDim2.new(0.5, 0, 0.5, 0)
    root.Size = size
    root.BackgroundColor3 = C.Page
    root.BorderSizePixel = 0
    root.ClipsDescendants = true
    root.Parent = ScreenGui
    corner(root, 14)
    stroke(root, 0.25, C.Border)

    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = root.AnchorPoint
    shadow.Position = root.Position
    shadow.Size = root.Size + UDim2.fromOffset(18, 18)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = C.Accent
    shadow.ImageTransparency = 0.72
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = 0
    shadow.Parent = ScreenGui
    root.ZIndex = 2

    local top = Instance.new("Frame")
    top.Name = "Topbar"
    top.BackgroundColor3 = C.Background
    top.BorderSizePixel = 0
    top.Size = UDim2.new(1, 0, 0, 44)
    top.Parent = root

    local title = makeText(top, p.Title or "Auto Progress", 14, true)
    title.Position = UDim2.new(0, 14, 0, 3)
    title.Size = UDim2.new(1, -110, 0, 20)

    local desc = makeText(top, p.Desc or "", 10, false)
    desc.TextColor3 = C.Muted
    desc.Position = UDim2.new(0, 14, 0, 22)
    desc.Size = UDim2.new(1, -110, 0, 16)

    local min = Instance.new("TextButton")
    min.Name = "Minimize"
    min.AnchorPoint = Vector2.new(1, 0.5)
    min.Position = UDim2.new(1, -46, 0.5, 0)
    min.Size = UDim2.fromOffset(30, 28)
    min.BackgroundColor3 = C.Page
    min.Text = "—"
    min.TextColor3 = C.Text
    min.TextSize = 15
    min.Font = Enum.Font.GothamBold
    min.Parent = top
    corner(min, 6)

    local close = Instance.new("TextButton")
    close.Name = "Close"
    close.AnchorPoint = Vector2.new(1, 0.5)
    close.Position = UDim2.new(1, -10, 0.5, 0)
    close.Size = UDim2.fromOffset(30, 28)
    close.BackgroundColor3 = C.Page
    close.Text = "×"
    close.TextColor3 = C.Text
    close.TextSize = 18
    close.Font = Enum.Font.GothamBold
    close.Parent = top
    corner(close, 6)

    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Position = UDim2.new(0, 0, 0, 44)
    sidebar.Size = UDim2.new(0, 122, 1, -44)
    sidebar.BackgroundColor3 = C.Background
    sidebar.BorderSizePixel = 0
    sidebar.Parent = root

    local tabScroll = Instance.new("ScrollingFrame")
    tabScroll.Name = "Tabs"
    tabScroll.BackgroundTransparency = 1
    tabScroll.BorderSizePixel = 0
    tabScroll.Position = UDim2.new(0, 7, 0, 8)
    tabScroll.Size = UDim2.new(1, -14, 1, -16)
    tabScroll.CanvasSize = UDim2.new()
    tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabScroll.ScrollBarThickness = 0
    tabScroll.Parent = sidebar

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabScroll

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Position = UDim2.new(0, 122, 0, 44)
    content.Size = UDim2.new(1, -122, 1, -44)
    content.BackgroundColor3 = C.Page
    content.BorderSizePixel = 0
    content.Parent = root

    enableDrag(top, root)

    local function syncShadow()
        shadow.Position = root.Position
        shadow.Size = root.Size + UDim2.fromOffset(18, 18)
        shadow.Visible = root.Visible
    end

    root:GetPropertyChangedSignal("Position"):Connect(syncShadow)
    root:GetPropertyChangedSignal("Size"):Connect(syncShadow)
    root:GetPropertyChangedSignal("Visible"):Connect(syncShadow)

    local minimized = false
    local fullSize = size

    min.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            fullSize = root.Size
            sidebar.Visible = false
            content.Visible = false
            tween(root, 0.18, {Size = UDim2.new(0, fullSize.X.Offset, 0, 44)})
        else
            tween(root, 0.18, {Size = fullSize})
            task.delay(0.18, function()
                if root.Parent then
                    sidebar.Visible = true
                    content.Visible = true
                end
            end)
        end
    end)

    close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then
            return
        end
        if input.KeyCode == keybind and ScreenGui.Parent then
            root.Visible = not root.Visible
            shadow.Visible = root.Visible
        end
    end)

    local Window = {
        _Tabs = {},
        _Current = nil,
        _Root = root,
    }

    function Window:Tab(tp)
        tp = tp or {}

        local button = Instance.new("TextButton")
        button.Name = tostring(tp.Title or "Tab")
        button.BackgroundColor3 = C.Background
        button.BackgroundTransparency = 1
        button.BorderSizePixel = 0
        button.Size = UDim2.new(1, 0, 0, 34)
        button.Text = tostring(tp.Title or "Tab")
        button.TextColor3 = C.Muted
        button.TextSize = 11
        button.Font = Enum.Font.GothamBold
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.Parent = tabScroll
        corner(button, 6)

        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 10)
        pad.Parent = button

        local page = Instance.new("ScrollingFrame")
        page.Name = tostring(tp.Title or "Tab") .. "Page"
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.Position = UDim2.new(0, 10, 0, 10)
        page.Size = UDim2.new(1, -20, 1, -20)
        page.CanvasSize = UDim2.new()
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = C.Accent
        page.Visible = false
        page.Parent = content

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 7)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = page

        local bottomPad = Instance.new("UIPadding")
        bottomPad.PaddingBottom = UDim.new(0, 12)
        bottomPad.Parent = page

        local function selectTab()
            for _, t in ipairs(Window._Tabs) do
                t.Page.Visible = false
                t.Button.TextColor3 = C.Muted
                t.Button.BackgroundTransparency = 1
            end
            page.Visible = true
            button.TextColor3 = C.Text
            button.BackgroundColor3 = C.Secondary
            button.BackgroundTransparency = 0.25
            Window._Current = page
        end

        button.MouseButton1Click:Connect(selectTab)

        local Tab = {}

        function Tab:Section(sp)
            sp = sp or {}
            local section = Instance.new("TextLabel")
            section.Name = "Section"
            section.BackgroundTransparency = 1
            section.BorderSizePixel = 0
            section.Size = UDim2.new(1, 0, 0, 26)
            section.Text = tostring(sp.Title or "")
            section.TextColor3 = C.Selected
            section.TextSize = 11
            section.Font = Enum.Font.GothamBold
            section.TextXAlignment = Enum.TextXAlignment.Left
            section.Parent = page
            return section
        end

        function Tab:Label(lp)
            lp = lp or {}
            local row, api = makeRow(page, lp.Title or "", lp.Desc or "", nil)
            row.Size = UDim2.new(1, 0, 0, (lp.Desc and lp.Desc ~= "") and 48 or 38)
            api._Title.Size = UDim2.new(1, 0, 0, (lp.Desc and lp.Desc ~= "") and 18 or 28)
            return api
        end

        function Tab:Button(bp)
            bp = bp or {}
            local row, api = makeRow(page, bp.Title or "Button", bp.Desc or "", nil)

            local action = Instance.new("TextButton")
            action.AnchorPoint = Vector2.new(1, 0.5)
            action.Position = UDim2.new(1, -10, 0.5, 0)
            action.Size = UDim2.fromOffset(78, 26)
            action.BackgroundColor3 = C.Accent
            action.BorderSizePixel = 0
            action.Text = "Run"
            action.TextColor3 = C.Text
            action.TextSize = 11
            action.Font = Enum.Font.GothamBold
            action.Parent = row
            corner(action, 6)

            action.MouseButton1Click:Connect(function()
                if bp.Callback then
                    task.spawn(function()
                        pcall(bp.Callback)
                    end)
                end
            end)

            return api
        end

        function Tab:Toggle(tp2)
            tp2 = tp2 or {}
            local row, api = makeRow(page, tp2.Title or "Toggle", tp2.Desc or "", nil)

            local toggle = Instance.new("TextButton")
            toggle.AnchorPoint = Vector2.new(1, 0.5)
            toggle.Position = UDim2.new(1, -12, 0.5, 0)
            toggle.Size = UDim2.fromOffset(42, 22)
            toggle.BorderSizePixel = 0
            toggle.Text = ""
            toggle.Parent = row
            corner(toggle, 11)

            local knob = Instance.new("Frame")
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.Size = UDim2.fromOffset(16, 16)
            knob.BorderSizePixel = 0
            knob.Parent = toggle
            corner(knob, 8)

            local value = tp2.Value == true
            local disabled = false

            local function render()
                toggle.BackgroundColor3 = value and C.Accent or C.Border
                knob.BackgroundColor3 = value and C.Selected or C.Muted
                knob.Position = value and UDim2.new(1, -11, 0.5, 0)
                    or UDim2.new(0, 11, 0.5, 0)

                row.BackgroundTransparency = disabled and 0.35 or 0
                api._Title.TextTransparency = disabled and 0.45 or 0
                api._Desc.TextTransparency = disabled and 0.55 or 0
            end

            local function setValue(v, fire)
                value = v == true
                render()
                if fire ~= false and tp2.Callback then
                    task.spawn(function()
                        pcall(tp2.Callback, value)
                    end)
                end
            end

            toggle.MouseButton1Click:Connect(function()
                if disabled then
                    return
                end
                setValue(not value, true)
            end)

            function api:SetValue(v)
                setValue(v, true)
            end

            function api:Set(v)
                setValue(v, true)
            end

            function api:SetDisabled(v)
                disabled = v == true
                render()
            end

            function api:SetEnabled(v)
                disabled = v ~= true
                render()
            end

            function api:SetLocked(v)
                disabled = v == true
                render()
            end

            function api:GetValue()
                return value
            end

            render()
            return api
        end

        function Tab:Textbox(xp)
            xp = xp or {}
            local row, api = makeRow(page, xp.Title or "Textbox", xp.Desc or "", nil)

            local box = Instance.new("TextBox")
            box.AnchorPoint = Vector2.new(1, 0.5)
            box.Position = UDim2.new(1, -10, 0.5, 0)
            box.Size = UDim2.fromOffset(120, 26)
            box.BackgroundColor3 = C.Page
            box.BorderSizePixel = 0
            box.Text = tostring(xp.Value or "")
            box.PlaceholderText = tostring(xp.Placeholder or "")
            box.PlaceholderColor3 = C.Muted
            box.TextColor3 = C.Text
            box.TextSize = 10
            box.Font = Enum.Font.Gotham
            box.ClearTextOnFocus = xp.ClearTextOnFocus == true
            box.Parent = row
            corner(box, 6)
            stroke(box, 0.35, C.Border)

            local p = Instance.new("UIPadding")
            p.PaddingLeft = UDim.new(0, 7)
            p.PaddingRight = UDim.new(0, 7)
            p.Parent = box

            box.FocusLost:Connect(function()
                if xp.Callback then
                    task.spawn(function()
                        pcall(xp.Callback, box.Text)
                    end)
                end
            end)

            function api:SetValue(v)
                box.Text = tostring(v or "")
            end

            function api:GetValue()
                return box.Text
            end

            return api
        end

        function Tab:Dropdown(dp)
            dp = dp or {}
            local list = dp.List or {}
            local selected = dp.Value
            if type(selected) == "table" then
                selected = selected[1]
            end
            if selected == nil then
                selected = list[1]
            end

            local row, api = makeRow(page, dp.Title or "Dropdown", dp.Desc or "", nil)

            local selectButton = Instance.new("TextButton")
            selectButton.AnchorPoint = Vector2.new(1, 0.5)
            selectButton.Position = UDim2.new(1, -10, 0.5, 0)
            selectButton.Size = UDim2.fromOffset(120, 26)
            selectButton.BackgroundColor3 = C.Page
            selectButton.BorderSizePixel = 0
            selectButton.Text = tostring(selected or "--")
            selectButton.TextColor3 = C.Text
            selectButton.TextSize = 10
            selectButton.Font = Enum.Font.GothamBold
            selectButton.Parent = row
            corner(selectButton, 6)
            stroke(selectButton, 0.35, C.Border)

            local popup = Instance.new("Frame")
            popup.Name = "RyaDropdown"
            popup.Visible = false
            popup.BackgroundColor3 = C.Page
            popup.BorderSizePixel = 0
            popup.Size = UDim2.fromOffset(150, 10)
            popup.ZIndex = 50
            popup.Parent = ScreenGui
            corner(popup, 7)
            stroke(popup, 0.2, C.Border)

            local popScroll = Instance.new("ScrollingFrame")
            popScroll.BackgroundTransparency = 1
            popScroll.BorderSizePixel = 0
            popScroll.Position = UDim2.fromOffset(5, 5)
            popScroll.Size = UDim2.new(1, -10, 1, -10)
            popScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            popScroll.CanvasSize = UDim2.new()
            popScroll.ScrollBarThickness = 2
            popScroll.ScrollBarImageColor3 = C.Accent
            popScroll.ZIndex = 51
            popScroll.Parent = popup

            local popLayout = Instance.new("UIListLayout")
            popLayout.Padding = UDim.new(0, 3)
            popLayout.Parent = popScroll

            local entries = {}

            local function placePopup()
                popup.Position = UDim2.fromOffset(
                    selectButton.AbsolutePosition.X,
                    selectButton.AbsolutePosition.Y + selectButton.AbsoluteSize.Y + 4
                )
            end

            local function closePopup()
                popup.Visible = false
            end

            local function choose(v, fire)
                selected = v
                selectButton.Text = tostring(v or "--")
                closePopup()
                if fire ~= false and dp.Callback then
                    task.spawn(function()
                        if dp.Multi then
                            pcall(dp.Callback, {v})
                        else
                            pcall(dp.Callback, v)
                        end
                    end)
                end
            end

            local function rebuild(newList)
                for _, e in ipairs(entries) do
                    e:Destroy()
                end
                table.clear(entries)

                list = newList or list

                for _, v in ipairs(list) do
                    local item = Instance.new("TextButton")
                    item.BackgroundColor3 = C.Background
                    item.BorderSizePixel = 0
                    item.Size = UDim2.new(1, -2, 0, 24)
                    item.Text = tostring(v)
                    item.TextColor3 = C.Text
                    item.TextSize = 10
                    item.Font = Enum.Font.Gotham
                    item.ZIndex = 52
                    item.Parent = popScroll
                    corner(item, 5)

                    item.MouseButton1Click:Connect(function()
                        choose(v, true)
                    end)

                    table.insert(entries, item)
                end

                local h = math.min(math.max(#list * 27 + 10, 38), 180)
                popup.Size = UDim2.fromOffset(150, h)
            end

            selectButton.MouseButton1Click:Connect(function()
                placePopup()
                popup.Visible = not popup.Visible
            end)

            function api:SetValue(v)
                if type(v) == "table" then
                    v = v[1]
                end
                choose(v, true)
            end

            function api:Add(v)
                table.insert(list, v)
                rebuild(list)
            end

            function api:Clear(v)
                if v == nil then
                    list = {}
                elseif type(v) == "table" then
                    local remove = {}
                    for _, n in ipairs(v) do
                        remove[tostring(n)] = true
                    end
                    local n = {}
                    for _, item in ipairs(list) do
                        if not remove[tostring(item)] then
                            table.insert(n, item)
                        end
                    end
                    list = n
                else
                    local n = {}
                    for _, item in ipairs(list) do
                        if tostring(item) ~= tostring(v) then
                            table.insert(n, item)
                        end
                    end
                    list = n
                end
                rebuild(list)
            end

            rebuild(list)

            task.defer(function()
                if selected ~= nil and dp.Callback then
                    if dp.Multi then
                        pcall(dp.Callback, {selected})
                    else
                        pcall(dp.Callback, selected)
                    end
                end
            end)

            return api
        end

        table.insert(Window._Tabs, {
            Button = button,
            Page = page,
            Object = Tab,
        })

        if #Window._Tabs == 1 then
            selectTab()
        end

        return Tab
    end

    function Window:Line()
        local line = Instance.new("Frame")
        line.BackgroundColor3 = C.Border
        line.BorderSizePixel = 0
        line.Position = UDim2.new(0, 8, 0, 43)
        line.Size = UDim2.new(1, -16, 0, 1)
        line.Parent = root
        return line
    end

    function Window:Notify(np)
        np = np or {}

        local n = Instance.new("Frame")
        n.AnchorPoint = Vector2.new(1, 1)
        n.Position = UDim2.new(1, -16, 1, -16)
        n.Size = UDim2.fromOffset(280, 64)
        n.BackgroundColor3 = C.Background
        n.BorderSizePixel = 0
        n.Parent = ScreenGui
        corner(n, 8)
        stroke(n, 0.2, C.Border)

        local nt = makeText(n, np.Title or "Notification", 12, true)
        nt.Position = UDim2.new(0, 10, 0, 7)
        nt.Size = UDim2.new(1, -20, 0, 20)

        local nd = makeText(n, np.Desc or "", 10, false)
        nd.TextColor3 = C.Muted
        nd.Position = UDim2.new(0, 10, 0, 27)
        nd.Size = UDim2.new(1, -20, 0, 30)

        task.delay(tonumber(np.Time) or 3, function()
            if n.Parent then
                n:Destroy()
            end
        end)
    end

    function Window:Destroy()
        if ScreenGui.Parent then
            ScreenGui:Destroy()
        end
    end

    return Window
end

return Library
