local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Library = {}
local Icons = {
    moon = "10734897102", sun = "10734974297", ["minimize-2"] = "10734895530",
    ["maximize-2"] = "10734886496", x = "10747384394", bot = "10709782230",
    settings = "10734950309", link = "10723426722", eye = "10723346959",
    rocket = "10734934585", coins = "10709811110", wallet = "10747376205",
    camera = "10709789686", terminal = "10734982144", shield = "10734951847",
    ["book-open"] = "10709781717", key = "10723416652", ["gamepad-2"] = "10723395215",
    gem = "10723396000", clock = "10709805144", ["bar-chart"] = "10709773755",
    ["chevron-down"] = "10709790948", ["chevron-right"] = "10709791437",
    ["chevron-left"] = "10709791281", play = "10734923549", pause = "10734919336",
    info = "10723415903", check = "10709790644", ["alert-circle"] = "10709752996",
    menu = "10734887784", keyboard = "10723416765", plus = "10734924532",
    minus = "10734896206", ["wand-2"] = "10747376349",
    ["layout-dashboard"] = "10723424646", ["sliders-horizontal"] = "10734963191",
    crown = "10709818626", ["sun-moon"] = "10734973999", square = "10734965702",
    swords = "10734975692", calendar = "10709789505", code = "10709810463"
}
local Palettes = {
    Dark = {
        Background = Color3.fromRGB(8, 14, 29), Surface = Color3.fromRGB(15, 25, 45),
        Hover = Color3.fromRGB(24, 40, 68), Stroke = Color3.fromRGB(39, 57, 91),
        Text = Color3.fromRGB(239, 245, 255), Sub = Color3.fromRGB(151, 168, 197),
        Accent = Color3.fromRGB(65, 155, 255), Off = Color3.fromRGB(51, 67, 95),
        Input = Color3.fromRGB(9, 19, 36)
    },
    Light = {
        Background = Color3.fromRGB(242, 246, 252), Surface = Color3.fromRGB(255, 255, 255),
        Hover = Color3.fromRGB(224, 236, 252), Stroke = Color3.fromRGB(191, 208, 233),
        Text = Color3.fromRGB(24, 40, 67), Sub = Color3.fromRGB(77, 100, 137),
        Accent = Color3.fromRGB(36, 112, 221), Off = Color3.fromRGB(174, 193, 216),
        Input = Color3.fromRGB(238, 244, 252)
    }
}
local function create(class, props, parent)
    local object = Instance.new(class)
    for key, value in pairs(props or {}) do
        if key ~= "Parent" then object[key] = value end
    end
    object.Parent = parent or (props and props.Parent)
    return object
end
local function round(object, pixels)
    create("UICorner", {CornerRadius = UDim.new(0, pixels or 10)}, object)
    return object
end
local function padding(object, x, y)
    create("UIPadding", {
        PaddingLeft = UDim.new(0, x), PaddingRight = UDim.new(0, x),
        PaddingTop = UDim.new(0, y), PaddingBottom = UDim.new(0, y)
    }, object)
    return object
end
local function animate(object, duration, props)
    local ok, track = pcall(function()
        return TweenService:Create(object, TweenInfo.new(duration or .18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    end)
    if ok then track:Play() end
end
local function iconId(name)
    if type(name) == "number" then return "rbxassetid://" .. tostring(name) end
    if type(name) ~= "string" then return "rbxassetid://" .. Icons["layout-dashboard"] end
    if name:match("^rbxassetid://") then return name end
    local key = name:lower():gsub("^lucide%-", ""):gsub("^phosphor%-", ""):gsub("_", "-")
    local replacements = {
        ["currency"] = "coins", ["tools"] = "settings", ["gamepad"] = "gamepad-2",
        ["description"] = "book-open", ["cash"] = "wallet", ["chart"] = "bar-chart",
        ["flame"] = "rocket", ["star"] = "crown", ["script"] = "terminal",
        ["scroll"] = "book-open"
    }
    key = replacements[key] or key
    return "rbxassetid://" .. (Icons[key] or Icons["layout-dashboard"])
end

function Library:Window(config)
    config = config or {}
    local name = tostring(config.Title or "Macro Hub")
    local keybind = config.Config and config.Config.Keybind or Enum.KeyCode.RightShift
    local requested = config.Config and config.Config.Size or UDim2.fromOffset(740, 480)
    local width = math.max(560, requested.X.Offset > 0 and requested.X.Offset or 740)
    local height = math.max(380, requested.Y.Offset > 0 and requested.Y.Offset or 480)
    local selectedTheme = tostring(config.Theme or "Dark"):lower():find("light", 1, true) and "Light" or "Dark"
    local palette = Palettes[selectedTheme]
    local registered, connections, tabs = {}, {}, {}
    local alive, selected, minimized, maximized, oldSize = true, nil, false, false, nil
    local globalStatus = "Idle"
    local refreshStatusHeader
    local floatingSize = math.clamp(tonumber(config.Config and config.Config.FloatingIconSize) or 96, 56, 144)
    local function listen(signal, callback)
        local c = signal:Connect(callback)
        table.insert(connections, c)
        return c
    end
    local function themed(object, property, key)
        object[property] = palette[key]
        table.insert(registered, {object, property, key})
        return object
    end
    local function makeText(parent, value, size, bold, colorKey)
        local t = create("TextLabel", {
            Text = tostring(value or ""), BackgroundTransparency = 1, BorderSizePixel = 0,
            Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
            TextSize = size or 13, TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd, RichText = true
        }, parent)
        themed(t, "TextColor3", colorKey or "Text")
        return t
    end
    local function makeIcon(parent, value, point, size, colored)
        local image = create("ImageLabel", {
            Image = iconId(value), BackgroundTransparency = 1,
            Position = point or UDim2.new(), Size = UDim2.fromOffset(size or 20, size or 20),
            ScaleType = Enum.ScaleType.Fit
        }, parent)
        themed(image, "ImageColor3", colored or "Sub")
        return image
    end
    local function makeStroke(parent)
        local s = create("UIStroke", {Thickness = 1, Transparency = .18}, parent)
        themed(s, "Color", "Stroke")
        return s
    end
    local old = playerGui:FindFirstChild("MacroHubUI")
    if old then old:Destroy() end
    local gui = create("ScreenGui", {
        Name = "MacroHubUI", ResetOnSpawn = false, IgnoreGuiInset = true,
        DisplayOrder = 150, ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, playerGui)
    local main = round(create("Frame", {
        Name = "Main", AnchorPoint = Vector2.new(.5, .5),
        Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(width, height),
        BorderSizePixel = 0, ClipsDescendants = true
    }, gui), 14)
    themed(main, "BackgroundColor3", "Background")
    makeStroke(main)
    local scale = create("UIScale", {Scale = 1}, main)
    local function fitScale()
        if maximized then return end
        local view = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(900, 600)
        scale.Scale = math.min(1, (view.X - 22) / width, (view.Y - 22) / height)
    end
    fitScale()
    listen(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), fitScale)
    local top = create("Frame", {
        Name = "TitleBar", Size = UDim2.new(1, 0, 0, 56), BackgroundTransparency = 1
    }, main)
    local topLine = create("Frame", {
        Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BorderSizePixel = 0
    }, top)
    themed(topLine, "BackgroundColor3", "Stroke")
    local logo = create("ImageLabel", {Name = "Logo", Image = "rbxassetid://" .. (selectedTheme == "Dark" and "76956733094432" or "95122283075110"), BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 8), Size = UDim2.fromOffset(40, 40), ScaleType = Enum.ScaleType.Fit}, top)
    local title = makeText(top, name, 20, true)
    title.Position, title.Size = UDim2.fromOffset(60, 16), UDim2.new(1, -228, 0, 26)
    local controls = create("Frame", {
        BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, .5),
        Position = UDim2.new(1, -12, .5, 0), Size = UDim2.fromOffset(148, 32)
    }, top)
    local function titleButton(nameIcon, index, callback)
        local b = round(create("TextButton", {
            Name = nameIcon, Text = "", AutoButtonColor = false, BorderSizePixel = 0,
            BackgroundTransparency = 1, Position = UDim2.fromOffset((index - 1) * 37, 0),
            Size = UDim2.fromOffset(32, 32)
        }, controls), 7)
        local img = makeIcon(b, nameIcon, UDim2.fromOffset(8, 8), 16)
        themed(b, "BackgroundColor3", "Hover")
        listen(b.MouseEnter, function() if alive then animate(b, .12, {BackgroundTransparency = 0}) end end)
        listen(b.MouseLeave, function() animate(b, .12, {BackgroundTransparency = 1}) end)
        listen(b.MouseButton1Click, callback)
        return img
    end
    local buttonTheme
    local floating
    local themeSignal = create("BindableEvent", {Name = "ThemeChanged"}, gui)
    local window
    local function setTheme(mode)
        selectedTheme = mode == "Light" and "Light" or "Dark"
        palette = Palettes[selectedTheme]
        for _, entry in ipairs(registered) do
            local obj, prop, key = entry[1], entry[2], entry[3]
            if obj and obj.Parent then animate(obj, .23, {[prop] = palette[key]}) end
        end
        for _, tab in ipairs(tabs) do
            animate(tab.NavButton, .23, {BackgroundColor3 = tab == selected and palette.Hover or palette.Surface})
            animate(tab.NavText, .23, {TextColor3 = tab == selected and palette.Text or palette.Sub})
            animate(tab.ButtonIcon, .23, {ImageColor3 = tab == selected and palette.Accent or palette.Sub})
        end
        if window then window.Theme = selectedTheme end
        if refreshStatusHeader then refreshStatusHeader() end
        themeSignal:Fire(selectedTheme)
        if buttonTheme then buttonTheme.Image = iconId(selectedTheme == "Dark" and "moon" or "sun") end
        if logo then logo.Image = "rbxassetid://" .. (selectedTheme == "Dark" and "76956733094432" or "95122283075110") end
        if floating then floating.Image = "rbxassetid://" .. (selectedTheme == "Dark" and "76956733094432" or "95122283075110") end
    end
    buttonTheme = titleButton("moon", 1, function()
        setTheme(selectedTheme == "Dark" and "Light" or "Dark")
    end)
    window = {Minimized = false, Theme = selectedTheme, ThemeChanged = themeSignal.Event, Instance = gui}
    function window:Minimize()
        minimized = not minimized
        self.Minimized = minimized
        main.Visible = not minimized
        if floating then floating.Visible = minimized end
    end
    titleButton("minus", 2, function() window:Minimize() end)
    titleButton("square", 3, function()
        maximized = not maximized
        if maximized then
            oldSize = main.Size
            scale.Scale = 1
            local view = workspace.CurrentCamera.ViewportSize
            animate(main, .22, {Size = UDim2.fromOffset(view.X - 24, view.Y - 24)})
        else
            animate(main, .22, {Size = oldSize or UDim2.fromOffset(width, height)})
            fitScale()
        end
    end)
    titleButton("x", 4, function() window:Destroy() end)
    floating = create("ImageButton", {
        Name = "FloatingIcon", AnchorPoint = Vector2.new(0, .5),
        Position = UDim2.new(0, 18, .5, 0), Size = UDim2.fromOffset(floatingSize, floatingSize),
        BackgroundTransparency = 1, Image = "rbxassetid://" .. (selectedTheme == "Dark" and "76956733094432" or "95122283075110"),
        ScaleType = Enum.ScaleType.Fit, Visible = false, AutoButtonColor = false, ZIndex = 50
    }, gui)
    local moved = false
    local floatingStart, floatPosition, floatInput
    listen(floating.InputBegan, function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 and i.UserInputType ~= Enum.UserInputType.Touch then return end
        floatingStart, floatPosition, floatInput, moved = i.Position, floating.Position, i, false
    end)
    listen(UserInputService.InputChanged, function(i)
        if not floatingStart then return end
        if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = i.Position - floatingStart
        if delta.Magnitude > 5 then moved = true end
        local view = workspace.CurrentCamera.ViewportSize
        floating.Position = UDim2.fromOffset(
            math.clamp(floatPosition.X.Offset + delta.X, 0, math.max(0, view.X - floatingSize)),
            math.clamp(view.Y * floatPosition.Y.Scale + floatPosition.Y.Offset + delta.Y, 0, math.max(0, view.Y - floatingSize))
        )
    end)
    listen(UserInputService.InputEnded, function(i)
        if floatingStart and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
            floatingStart, floatInput = nil, nil
        end
    end)
    listen(floating.MouseButton1Click, function()
        if not moved then window:Minimize() end
    end)
    local topStart, posStart
    listen(top.InputBegan, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            topStart, posStart = i.Position, main.Position
        end
    end)
    listen(UserInputService.InputChanged, function(i)
        if topStart and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = (i.Position - topStart) / scale.Scale
            main.Position = UDim2.new(posStart.X.Scale, posStart.X.Offset + d.X, posStart.Y.Scale, posStart.Y.Offset + d.Y)
        end
    end)
    listen(UserInputService.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then topStart = nil end
    end)
    local sidebar = create("ScrollingFrame", {
        Name = "Sidebar", BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.fromOffset(12, 68), Size = UDim2.new(0, 176, 1, -80),
        ScrollBarThickness = 0, AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(), ScrollingDirection = Enum.ScrollingDirection.Y
    }, main)
    create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)}, sidebar)
    local content = create("Frame", {
        Name = "Content", Position = UDim2.fromOffset(202, 66),
        Size = UDim2.new(1, -216, 1, -77), BackgroundTransparency = 1
    }, main)
    local tabDisplay = makeText(content, "Description", 22, true)
    tabDisplay.Name = "TabDisplay"
    tabDisplay.Size = UDim2.new(1, 0, 0, 72)
    tabDisplay.TextYAlignment = Enum.TextYAlignment.Top
    tabDisplay.TextWrapped = true
    tabDisplay.TextTruncate = Enum.TextTruncate.None
    window.TabDisplay = tabDisplay
    local function statusTextColor(text)
        local t = tostring(text or ""):lower()
        if t:find("^running") or t:find("^recording") then
            return selectedTheme == "Light" and "#168049" or "#4ADE80"
        elseif t:find("failed", 1, true) or t:find("error", 1, true) then
            return selectedTheme == "Light" and "#B42332" or "#FB7185"
        elseif t:find("waiting", 1, true) or t:find("required", 1, true) then
            return selectedTheme == "Light" and "#986008" or "#FBBF24"
        end
        return selectedTheme == "Light" and "#58708E" or "#94A3B8"
    end
    refreshStatusHeader = function()
        if not selected then return end
        local text = tostring(globalStatus or "Idle")
        text = text:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
        local nextText = selected.Title .. '\n<font size="13" color="' .. statusTextColor(globalStatus) .. '"><b>' .. text .. '</b></font>'
        if tabDisplay.Text ~= nextText then tabDisplay.Text = nextText end
    end
    function window:SetTabDisplayMultiline(value)
        tabDisplay.TextWrapped = value == true
        tabDisplay.TextTruncate = Enum.TextTruncate.None
    end
    local pages = create("Frame", {
        Position = UDim2.fromOffset(0, 79), Size = UDim2.new(1, 0, 1, -79),
        BackgroundTransparency = 1
    }, content)
    local toastFrame = create("Frame", {
        Name = "Toasts", AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -15, 1, -15), Size = UDim2.fromOffset(300, 350),
        BackgroundTransparency = 1, ZIndex = 60
    }, gui)
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical, VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 6)
    }, toastFrame)
    function window:Notify(options)
        options = options or {}
        local box = round(create("Frame", {
            Size = UDim2.new(1, 0, 0, 65), BackgroundTransparency = .03, BorderSizePixel = 0
        }, toastFrame), 10)
        themed(box, "BackgroundColor3", "Surface")
        makeStroke(box)
        local heading = makeText(box, options.Title or "Macro Hub", 14, true, "Accent")
        heading.Position, heading.Size = UDim2.fromOffset(12, 8), UDim2.new(1, -24, 0, 18)
        local desc = makeText(box, options.Content or options.Description or "", 12, false, "Sub")
        desc.Position, desc.Size = UDim2.fromOffset(12, 29), UDim2.new(1, -24, 0, 28)
        desc.TextWrapped, desc.TextTruncate = true, Enum.TextTruncate.None
        task.delay(tonumber(options.Duration) or 3, function()
            if box.Parent then
                animate(box, .2, {BackgroundTransparency = 1})
                task.delay(.22, function() if box.Parent then box:Destroy() end end)
            end
        end)
    end
    function window:SelectTab(which)
        local t = type(which) == "number" and tabs[which] or which
        if not t or not t.Page then return end
        selected = t
        for _, tab in ipairs(tabs) do
            tab.Page.Visible = tab == t
            animate(tab.NavButton, .15, {BackgroundTransparency = tab == t and 0 or .2, BackgroundColor3 = tab == t and palette.Hover or palette.Surface})
            animate(tab.NavText, .15, {TextColor3 = tab == t and palette.Text or palette.Sub})
            animate(tab.Bar, .15, {BackgroundTransparency = tab == t and 0 or 1})
            animate(tab.ButtonIcon, .15, {ImageColor3 = tab == t and palette.Accent or palette.Sub})
        end
        refreshStatusHeader()
    end
    function window:SetTheme(mode)
        setTheme(mode)
        self.Theme = selectedTheme
    end
    function window:Destroy()
        if not alive then return end
        alive = false
        for _, c in ipairs(connections) do c:Disconnect() end
        if gui then gui:Destroy() end
    end
    listen(UserInputService.InputBegan, function(i, processed)
        if processed then return end
        if i.KeyCode == keybind then
            window:Minimize()
        end
    end)
    local Tab = {}
    Tab.__index = Tab
    function window:Tab(options)
        options = type(options) == "table" and options or {Title = options}
        local tabName = tostring(options.Title or "Tab")
        local nav = round(create("TextButton", {
            Name = tabName, Text = "", AutoButtonColor = false, BackgroundTransparency = .34,
            BorderSizePixel = 0, Size = UDim2.new(1, -4, 0, 42), LayoutOrder = #tabs + 1
        }, sidebar), 9)
        themed(nav, "BackgroundColor3", "Surface")
        local navIcon = makeIcon(nav, options.Icon or "layout-dashboard", UDim2.fromOffset(12, 12), 18)
        local navText = makeText(nav, tabName, 13, true, "Sub")
        navText.Position, navText.Size = UDim2.fromOffset(40, 0), UDim2.new(1, -48, 1, 0)
        local bar = round(create("Frame", {
            Position = UDim2.fromOffset(0, 9), Size = UDim2.fromOffset(3, 24),
            BorderSizePixel = 0, BackgroundTransparency = 1
        }, nav), 2)
        themed(bar, "BackgroundColor3", "Accent")
        local page = create("ScrollingFrame", {
            Name = tabName, Size = UDim2.fromScale(1, 1), Visible = false,
            BorderSizePixel = 0, BackgroundTransparency = 1,
            CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 3, ScrollingDirection = Enum.ScrollingDirection.Y
        }, pages)
        themed(page, "ScrollBarImageColor3", "Accent")
        local inner = create("Frame", {
            Size = UDim2.new(1, -8, 0, 0), BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y
        }, page)
        create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 9)}, inner)
        local tab = setmetatable({
            Title = tabName, NavButton = nav, NavText = navText, ButtonIcon = navIcon,
            Bar = bar, Page = page, Container = inner, Count = 0, Status = ""
        }, Tab)
        tabs[#tabs + 1] = tab
        listen(nav.MouseButton1Click, function() window:SelectTab(tab) end)
        if #tabs == 1 then window:SelectTab(tab) end
        return tab
    end
    function Tab:_append(frame)
        self.Count += 1
        frame.LayoutOrder = self.Count
        frame.Parent = self.Container
        return frame
    end
    function Tab:_card(height)
        local frame = round(create("Frame", {
            Size = UDim2.new(1, 0, 0, height or 58), BorderSizePixel = 0
        }), 10)
        themed(frame, "BackgroundColor3", "Surface")
        makeStroke(frame)
        return self:_append(frame)
    end
    function Tab:SetStatus(value)
        self.Status = tostring(value or "Idle")
        globalStatus = self.Status ~= "" and self.Status or "Idle"
        refreshStatusHeader()
    end
    function Tab:Section(options)
        local title = tostring(type(options) == "table" and options.Title or options or "")
        local row = self:_append(create("Frame", {
            Size = UDim2.new(1, 0, 0, 29), BackgroundTransparency = 1
        }))
        local text = makeText(row, title, 12, true, "Sub")
        text.TextXAlignment = Enum.TextXAlignment.Center
        text.TextYAlignment = Enum.TextYAlignment.Center
        text.Position, text.Size = UDim2.new(), UDim2.fromScale(1, 1)
        return {Instance = {Frame = row}}
    end
    local function headings(parent, options, right)
        local titleText = options.Title or options.Name or ""
        local title = makeText(parent, titleText, 14, true)
        title.Position = UDim2.fromOffset(14, options.Desc and 8 or 18)
        title.Size = UDim2.new(1, -(right or 30), 0, 20)
        local desc
        if options.Desc and options.Desc ~= "" then
            desc = makeText(parent, options.Desc, 11, false, "Sub")
            desc.Position, desc.Size = UDim2.fromOffset(14, 29), UDim2.new(1, -(right or 30), 0, 20)
        end
        return title, desc
    end
    function Tab:Label(options)
        options = options or {}
        local text = tostring(options.Desc or options.Content or "")
        local frame = self:_card(text ~= "" and 66 or 46)
        local title = makeText(frame, options.Title or options.Name or "", 14, true)
        title.Name = "TitleLabel"
        title.Position = UDim2.fromOffset(14, text ~= "" and 8 or 13)
        title.Size = UDim2.new(1, -28, 0, 21)
        local holder = create("Frame", {
            Name = "LabelHolder", BackgroundTransparency = 1, BorderSizePixel = 0,
            Position = UDim2.fromOffset(14, 32), Size = UDim2.new(1, -28, 0, 27)
        }, frame)
        local desc = makeText(holder, text, 12, false, "Sub")
        desc.Name = "DescLabel"
        desc.Position = UDim2.fromOffset(0, 0)
        desc.Size = UDim2.new(1, 0, 0, 0)
        desc.AutomaticSize = Enum.AutomaticSize.Y
        desc.TextWrapped = true
        desc.TextTruncate = Enum.TextTruncate.None
        desc.Visible = text ~= ""
        local handle = {Instance = {Frame = frame, LabelHolder = holder, DescLabel = desc, TitleLabel = title}}
        local function resize()
            if not frame.Parent then return end
            local contentsHeight = desc.Visible and math.max(22, desc.TextBounds.Y + 4) or 0
            for _, child in ipairs(holder:GetChildren()) do
                if child:IsA("GuiObject") and child ~= desc and child.Visible then
                    contentsHeight = math.max(contentsHeight, child.Position.Y.Offset + child.Size.Y.Offset)
                end
            end
            holder.Size = UDim2.new(1, -28, 0, contentsHeight)
            frame.Size = UDim2.new(1, 0, 0, math.max(46, 44 + contentsHeight))
        end
        function handle:SetTitle(value)
            title.Text = tostring(value or "")
        end
        function handle:SetDesc(value)
            desc.Text = tostring(value or "")
            desc.Visible = desc.Text ~= ""
            task.defer(resize)
        end
        function handle:SetText(value) self:SetDesc(value) end
        listen(holder.ChildAdded, function() task.defer(resize) end)
        listen(holder.ChildRemoved, function() task.defer(resize) end)
        listen(desc:GetPropertyChangedSignal("Visible"), function() task.defer(resize) end)
        listen(desc:GetPropertyChangedSignal("TextBounds"), function() task.defer(resize) end)
        task.defer(resize)
        return handle
    end
    function Tab:Button(options)
        options = options or {}
        local frame = self:_card(58)
        local title, desc = headings(frame, options, 134)
        local button = round(create("TextButton", {
            Text = tostring(options.Text or "Run"), Font = Enum.Font.GothamBold,
            TextSize = 12, AutoButtonColor = false, TextColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.fromOffset(104, 32), AnchorPoint = Vector2.new(1, .5),
            Position = UDim2.new(1, -12, .5, 0), BorderSizePixel = 0
        }, frame), 8)
        themed(button, "BackgroundColor3", "Accent")
        listen(button.MouseButton1Click, function()
            if type(options.Callback) == "function" then task.spawn(options.Callback) end
        end)
        return {
            Instance = {Frame = frame},
            SetText = function(_, v) button.Text = tostring(v or "") end,
            SetTitle = function(_, v) title.Text = tostring(v or "") end,
            SetDesc = function(_, v) if desc then desc.Text = tostring(v or "") end end
        }
    end
    function Tab:Toggle(options)
        options = options or {}
        local frame = self:_card(58)
        headings(frame, options, 100)
        local switch = round(create("Frame", {
            AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -14, .5, 0),
            Size = UDim2.fromOffset(46, 24), BorderSizePixel = 0
        }, frame), 12)
        themed(switch, "BackgroundColor3", "Off")
        local knob = round(create("Frame", {
            Position = UDim2.fromOffset(3, 3), Size = UDim2.fromOffset(18, 18),
            BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0
        }, switch), 9)
        local hit = create("TextButton", {
            Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1)
        }, frame)
        local val, disabled = options.Value == true or options.Default == true, false
        local handle = {Instance = {Frame = frame}, Value = val}
        local function redraw()
            animate(switch, .16, {BackgroundColor3 = val and palette.Accent or palette.Off})
            animate(knob, .16, {Position = UDim2.fromOffset(val and 25 or 3, 3)})
            hit.Active = not disabled
            animate(frame, .16, {BackgroundTransparency = disabled and .35 or 0})
        end
        function handle:SetValue(value)
            val = value == true
            self.Value = val
            redraw()
        end
        function handle:SetDisabled(value)
            disabled = value == true
            redraw()
        end
        function handle:SetEnabled(value) self:SetDisabled(not value) end
        function handle:SetLocked(value) self:SetDisabled(value) end
        function handle:GetValue() return val end
        listen(hit.MouseButton1Click, function()
            if disabled then return end
            handle:SetValue(not val)
            if type(options.Callback) == "function" then task.spawn(options.Callback, val) end
        end)
        listen(hit.MouseEnter, function() if not disabled then animate(frame, .12, {BackgroundColor3 = palette.Hover}) end end)
        listen(hit.MouseLeave, function() animate(frame, .12, {BackgroundColor3 = palette.Surface}) end)
        redraw()
        return handle
    end
    function Tab:Dropdown(options)
        options = options or {}
        local choices = options.List or options.Options or {}
        local selectedValue = options.Value or options.Default or choices[1]
        local frame = self:_card(58)
        frame.ClipsDescendants = true
        local title, description = headings(frame, options, 205)
        local selector = round(create("Frame", {
            Name = "DropdownSelector", AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -12, 0, 11), Size = UDim2.fromOffset(190, 36),
            BorderSizePixel = 0
        }, frame), 8)
        themed(selector, "BackgroundColor3", "Input")
        local selectorStroke = makeStroke(selector)
        local current = makeText(selector, tostring(selectedValue or ""), 12, true, "Text")
        current.TextXAlignment = Enum.TextXAlignment.Left
        current.Position, current.Size = UDim2.fromOffset(12, 8), UDim2.new(1, -46, 0, 20)
        local arrow = makeIcon(selector, "chevron-down", UDim2.new(1, -27, 0, 11), 15, "Accent")
        local hit = create("TextButton", {
            Text = "", BackgroundTransparency = 1, Position = UDim2.new(),
            Size = UDim2.new(1, 0, 0, 58)
        }, frame)
        listen(hit.MouseEnter, function() animate(selector, .14, {BackgroundColor3 = palette.Hover}) end)
        listen(hit.MouseLeave, function() animate(selector, .14, {BackgroundColor3 = palette.Input}) end)
        local optionList = create("ScrollingFrame", {
            Position = UDim2.fromOffset(8, 58), Size = UDim2.new(1, -16, 0, 0),
            CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2,
            ScrollingDirection = Enum.ScrollingDirection.Y
        }, frame)
        create("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder}, optionList)
        local open = false
        local handle = {Instance = {Frame = frame}, Value = selectedValue}
        local function sizeOpen()
            local count = math.min(#choices, 6)
            local h = count * 31 + (count > 0 and 10 or 0)
            animate(frame, .22, {Size = UDim2.new(1, 0, 0, open and 58 + h or 58)})
            optionList.Size = UDim2.new(1, -16, 0, h)
            arrow.Rotation = open and 180 or 0
            animate(selectorStroke, .2, {Color = open and palette.Accent or palette.Stroke})
        end
        function handle:SetValue(v)
            selectedValue = type(v) == "table" and v[1] or v
            self.Value = selectedValue
            current.Text = tostring(selectedValue or "")
        end
        function handle:SetDesc(v)
            if description then description.Text = tostring(v or "")
            else
                description = makeText(frame, v, 11, false, "Sub")
                description.Position, description.Size = UDim2.fromOffset(14, 30), UDim2.new(1, -190, 0, 19)
            end
        end
        function handle:Close()
            open = false
            sizeOpen()
        end
        function handle:Refresh(list)
            choices = list or {}
            for _, child in ipairs(optionList:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            for i, option in ipairs(choices) do
                local b = round(create("TextButton", {
                    Text = tostring(option), Font = Enum.Font.GothamMedium, TextSize = 12,
                    BorderSizePixel = 0, AutoButtonColor = false, LayoutOrder = i,
                    BackgroundTransparency = .15, Size = UDim2.new(1, 0, 0, 28)
                }, optionList), 6)
                themed(b, "BackgroundColor3", "Hover")
                themed(b, "TextColor3", "Text")
                listen(b.MouseButton1Click, function()
                    handle:SetValue(option)
                    handle:Close()
                    if type(options.Callback) == "function" then task.spawn(options.Callback, option) end
                end)
            end
            sizeOpen()
        end
        listen(hit.MouseButton1Click, function()
            open = not open
            sizeOpen()
        end)
        handle:Refresh(choices)
        handle:SetValue(selectedValue)
        return handle
    end
    function Tab:Textbox(options)
        options = options or {}
        local frame = self:_card(62)
        local labelHolder = create("Frame", {
            BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1)
        }, frame)
        padding(labelHolder, 0, 0)
        headings(labelHolder, options, 215)
        local inputFrame = round(create("Frame", {
            AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -12, .5, 0),
            Size = UDim2.fromOffset(192, 34), BorderSizePixel = 0
        }, frame), 8)
        themed(inputFrame, "BackgroundColor3", "Input")
        makeStroke(inputFrame)
        local input = create("TextBox", {
            Text = tostring(options.Value or options.Default or ""),
            PlaceholderText = tostring(options.Placeholder or "Type here..."),
            Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = options.ClearTextOnFocus == true,
            TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
            Position = UDim2.fromOffset(9, 0), Size = UDim2.new(1, -18, 1, 0)
        }, inputFrame)
        themed(input, "TextColor3", "Text")
        themed(input, "PlaceholderColor3", "Sub")
        local handle = {Instance = {Frame = frame, LabelHolder = labelHolder}, Value = input.Text}
        function handle:SetValue(value)
            input.Text = tostring(value or "")
            self.Value = input.Text
        end
        function handle:GetValue() return input.Text end
        listen(input:GetPropertyChangedSignal("Text"), function()
            handle.Value = input.Text
        end)
        listen(input.FocusLost, function(entered)
            if type(options.Callback) == "function" then task.spawn(options.Callback, input.Text, entered) end
        end)
        return handle
    end
    Tab.Input = Tab.Textbox
    function Tab:Slider(options)
        options = options or {}
        local min = tonumber(options.Min or 0) or 0
        local max = tonumber(options.Max or 100) or 100
        local step = tonumber(options.Increment or options.Step or 1) or 1
        local frame = self:_card(70)
        local title = makeText(frame, options.Title or "Slider", 13, true)
        title.Position, title.Size = UDim2.fromOffset(14, 7), UDim2.new(1, -90, 0, 20)
        local valueLabel = makeText(frame, "", 12, true, "Accent")
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Position, valueLabel.Size = UDim2.new(1, -80, 0, 7), UDim2.fromOffset(66, 20)
        local track = round(create("Frame", {
            Position = UDim2.fromOffset(15, 45), Size = UDim2.new(1, -30, 0, 5),
            BorderSizePixel = 0
        }, frame), 3)
        themed(track, "BackgroundColor3", "Off")
        local fill = round(create("Frame", {
            Size = UDim2.fromScale(0, 1), BorderSizePixel = 0
        }, track), 3)
        themed(fill, "BackgroundColor3", "Accent")
        local hit = create("TextButton", {
            Text = "", BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 32), Size = UDim2.new(1, 0, 0, 30)
        }, frame)
        local handle = {Value = tonumber(options.Value or options.Default or min) or min, Instance = {Frame = frame}}
        local function updateValue(v, callback)
            v = math.clamp(math.floor((v - min) / step + .5) * step + min, min, max)
            handle.Value = v
            valueLabel.Text = tostring(v) .. tostring(options.Suffix or "")
            fill.Size = UDim2.fromScale(max > min and (v - min) / (max - min) or 0, 1)
            if callback and type(options.Callback) == "function" then task.spawn(options.Callback, v) end
        end
        function handle:SetValue(v) updateValue(tonumber(v) or min, false) end
        local down = false
        local function fromX(x)
            local a = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
            updateValue(min + a * (max - min), true)
        end
        listen(hit.InputBegan, function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                down = true
                fromX(i.Position.X)
            end
        end)
        listen(UserInputService.InputChanged, function(i)
            if down and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then fromX(i.Position.X) end
        end)
        listen(UserInputService.InputEnded, function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then down = false end
        end)
        handle:SetValue(handle.Value)
        return handle
    end
    return window
end

function Library:Notify(options)
    if self.ActiveWindow and self.ActiveWindow.Notify then
        self.ActiveWindow:Notify(options)
    end
end
function Library:ToggleTransparency(value)
    self.TransparencyEnabled = value == true
end
local oldWindow = Library.Window
function Library:Window(config)
    local window = oldWindow(self, config)
    self.ActiveWindow = window
    return window
end
return Library
