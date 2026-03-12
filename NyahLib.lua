local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local NyahLib = {}
NyahLib.__index = NyahLib

-- Theming Colors (Mentality style)
local Theme = {
    MainBackground = Color3.fromRGB(18, 18, 20),
    SidebarBackground = Color3.fromRGB(22, 22, 25),
    SectionBackground = Color3.fromRGB(25, 25, 28),
    Accent = Color3.fromRGB(0, 150, 255), -- Azure Blue
    TextMain = Color3.fromRGB(240, 240, 240),
    TextMuted = Color3.fromRGB(150, 150, 150),
    Outline = Color3.fromRGB(35, 35, 40),
    ElementHover = Color3.fromRGB(35, 35, 40),
    ElementClick = Color3.fromRGB(45, 45, 50)
}

-- Utility Functions
local function MakeCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

local function MakeStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = color or Theme.Outline
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

local function CreateLabel(parent, text, font, size, color)
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Font = font or Enum.Font.Gotham
    lbl.Text = text
    lbl.TextSize = size or 13
    lbl.TextColor3 = color or Theme.TextMain
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

-- Make Frame draggable
local function MakeDraggable(topbar, main)
    local dragging, dragInput, dragStart, startPos

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function NyahLib:CreateWindow(options)
    options = options or {}
    local Title = options.Title or "Nyah Window"
    
    if CoreGui:FindFirstChild("NyahLibrary") then
        CoreGui["NyahLibrary"]:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NyahLibrary"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 700, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -350, 0.5, -225)
    MainFrame.BackgroundColor3 = Theme.MainBackground
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    MakeCorner(MainFrame, 6)
    MakeStroke(MainFrame, Theme.Outline)

    -- Top bar for dragging
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 30)
    TopBar.BackgroundTransparency = 1
    TopBar.Parent = MainFrame
    
    --- Window Title Area ---
    local HeaderContainer = Instance.new("Frame")
    HeaderContainer.Size = UDim2.new(0, 180, 0, 50) -- Matches sidebar width
    HeaderContainer.Position = UDim2.new(0, 15, 0, 15)
    HeaderContainer.BackgroundTransparency = 1
    HeaderContainer.Parent = MainFrame

    local LogoIcon = Instance.new("TextLabel")
    LogoIcon.Size = UDim2.new(0, 24, 0, 24)
    LogoIcon.BackgroundTransparency = 1
    LogoIcon.Font = Enum.Font.GothamBold
    LogoIcon.Text = "✧"
    LogoIcon.TextColor3 = Theme.Accent
    LogoIcon.TextSize = 20
    LogoIcon.TextXAlignment = Enum.TextXAlignment.Left
    LogoIcon.Parent = HeaderContainer

    local WindowTitle = CreateLabel(HeaderContainer, Title, Enum.Font.GothamBold, 15)
    WindowTitle.Position = UDim2.new(0, 32, 0, 0)
    WindowTitle.Size = UDim2.new(1, -32, 0, 16)
    
    local SubTitle = CreateLabel(HeaderContainer, options.SubTitle or "by nyah lib", Enum.Font.Gotham, 11, Theme.TextMuted)
    SubTitle.Position = UDim2.new(0, 32, 0, 16)
    SubTitle.Size = UDim2.new(1, -32, 0, 12)

    -- Sidebar for Tabs
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 180, 1, -80)
    Sidebar.Position = UDim2.new(0, 10, 0, 70)
    Sidebar.BackgroundTransparency = 1
    Sidebar.ScrollBarThickness = 0
    Sidebar.Parent = MainFrame

    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Padding = UDim.new(0, 5)
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarLayout.Parent = Sidebar

    -- Main Content Area
    local MainContent = Instance.new("Frame")
    MainContent.Name = "MainContent"
    MainContent.Size = UDim2.new(1, -210, 1, -20)
    MainContent.Position = UDim2.new(0, 200, 0, 10)
    MainContent.BackgroundTransparency = 1
    MainContent.Parent = MainFrame

    MakeDraggable(TopBar, MainFrame)

    local WindowObj = {
        Tabs = {},
        CurrentTab = nil,
        Sidebar = Sidebar,
        MainContent = MainContent
    }

    function WindowObj:CreateTab(tabOptions)
        tabOptions = tabOptions or {}
        local TabName = tabOptions.Name or "Tab"
        local Icon = tabOptions.Icon or ""

        -- The Tab Button in the Sidebar
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = TabName.."_Tab"
        TabBtn.Size = UDim2.new(1, -10, 0, 35)
        TabBtn.BackgroundColor3 = Theme.SidebarBackground
        TabBtn.BackgroundTransparency = 1 -- Default inactive state
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = self.Sidebar
        MakeCorner(TabBtn, 6)

        local IconLabel = CreateLabel(TabBtn, Icon, Enum.Font.GothamBold, 14, Theme.Accent)
        IconLabel.Position = UDim2.new(0, 15, 0, 0)
        IconLabel.Size = UDim2.new(0, 20, 1, 0)

        local NameLabel = CreateLabel(TabBtn, TabName, Enum.Font.GothamMedium, 13, Theme.TextMain)
        NameLabel.Position = UDim2.new(0, 40, 0, 0)
        NameLabel.Size = UDim2.new(1, -50, 1, 0)

        -- The Container for the specific Tab's contents (Sections)
        local TabContainer = Instance.new("ScrollingFrame")
        TabContainer.Name = TabName.."_Container"
        TabContainer.Size = UDim2.new(1, 0, 1, 0)
        TabContainer.BackgroundTransparency = 1
        TabContainer.ScrollBarThickness = 2
        TabContainer.ScrollBarImageColor3 = Theme.Outline
        TabContainer.Visible = false
        TabContainer.Parent = self.MainContent

        -- We use a multi-column layout for Mentality (Columns side-by-side)
        local LeftColumn = Instance.new("Frame")
        LeftColumn.Name = "LeftColumn"
        LeftColumn.Size = UDim2.new(0.49, 0, 1, 0)
        LeftColumn.BackgroundTransparency = 1
        LeftColumn.Parent = TabContainer

        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.Padding = UDim.new(0, 10)
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Parent = LeftColumn

        local RightColumn = Instance.new("Frame")
        RightColumn.Name = "RightColumn"
        RightColumn.Size = UDim2.new(0.49, 0, 1, 0)
        RightColumn.Position = UDim2.new(0.51, 0, 0, 0)
        RightColumn.BackgroundTransparency = 1
        RightColumn.Parent = TabContainer

        local RightLayout = Instance.new("UIListLayout")
        RightLayout.Padding = UDim.new(0, 10)
        RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RightLayout.Parent = RightColumn

        local TabObj = {
            Button = TabBtn,
            Container = TabContainer,
            LeftCol = LeftColumn,
            RightCol = RightColumn,
            LeftCount = 0,
            RightCount = 0
        }

        TabBtn.MouseButton1Click:Connect(function()
            -- Hide all tabs, show this one
            for _, t in pairs(WindowObj.Tabs) do
                t.Container.Visible = false
                TweenService:Create(t.Button, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                t.Button.FindFirstChild("TextLabel").TextColor3 = Theme.TextMuted -- The icon
            end
            TabContainer.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
            IconLabel.TextColor3 = Theme.Accent
            WindowObj.CurrentTab = TabObj

            -- Dynamic scrolling size calculation
            local maxH = math.max(LeftLayout.AbsoluteContentSize.Y, RightLayout.AbsoluteContentSize.Y)
            TabContainer.CanvasSize = UDim2.new(0, 0, 0, maxH + 20)
        end)

        table.insert(WindowObj.Tabs, TabObj)

        -- Open the first tab automatically
        if #WindowObj.Tabs == 1 then
            TabBtn.BackgroundColor3 = Theme.SidebarBackground
            TabBtn.BackgroundTransparency = 0
            TabContainer.Visible = true
            WindowObj.CurrentTab = TabObj
        else
            IconLabel.TextColor3 = Theme.TextMuted
        end

        function TabObj:CreateSection(sectionOpts)
            sectionOpts = sectionOpts or {}
            local SectionName = sectionOpts.Name or "Section"

            local Section = Instance.new("Frame")
            Section.Name = "Section"
            Section.BackgroundColor3 = Theme.SectionBackground
            MakeCorner(Section, 6)
            MakeStroke(Section, Theme.Outline)

            local SecTop = Instance.new("Frame")
            SecTop.Size = UDim2.new(1, 0, 0, 35)
            SecTop.BackgroundTransparency = 1
            SecTop.Parent = Section
            
            local SecIcon = CreateLabel(SecTop, "🌐", Enum.Font.Gotham, 14, Theme.Accent)
            SecIcon.Position = UDim2.new(0, 12, 0, 0)
            SecIcon.Size = UDim2.new(0, 20, 1, 0)
            
            local SecTitle = CreateLabel(SecTop, SectionName, Enum.Font.GothamMedium, 13)
            SecTitle.Position = UDim2.new(0, 35, 0, 0)
            SecTitle.Size = UDim2.new(1, -40, 1, 0)

            local SecContent = Instance.new("Frame")
            SecContent.Size = UDim2.new(1, -20, 1, -45)
            SecContent.Position = UDim2.new(0, 10, 0, 40)
            SecContent.BackgroundTransparency = 1
            SecContent.Parent = Section

            local SecLayout = Instance.new("UIListLayout")
            SecLayout.Padding = UDim.new(0, 6)
            SecLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SecLayout.Parent = SecContent

            -- Automatically balance sections between Left and Right columns
            if self.LeftCount <= self.RightCount then
                Section.Parent = self.LeftCol
                self.LeftCount = self.LeftCount + 1
            else
                Section.Parent = self.RightCol
                self.RightCount = self.RightCount + 1
            end

            local SectionObj = {Container = SecContent, ParentSection = Section, Elements = 0}

            local function UpdateSectionHeight()
                Section.Size = UDim2.new(1, 0, 0, SecLayout.AbsoluteContentSize.Y + 50)
                -- Also update canvas size
                local maxH = math.max(LeftLayout.AbsoluteContentSize.Y, RightLayout.AbsoluteContentSize.Y)
                TabContainer.CanvasSize = UDim2.new(0, 0, 0, maxH + 40)
            end
            
            SecLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSectionHeight)

            function SectionObj:CreateToggle(toggleOpts)
                toggleOpts = toggleOpts or {}
                local ToggleName = toggleOpts.Name or "Toggle"
                local Callback = toggleOpts.Callback or function() end
                local State = toggleOpts.Default or false
                self.Elements = self.Elements + 1

                local ToggleBtn = Instance.new("TextButton")
                ToggleBtn.Size = UDim2.new(1, 0, 0, 24)
                ToggleBtn.BackgroundTransparency = 1
                ToggleBtn.Text = ""
                ToggleBtn.LayoutOrder = self.Elements
                ToggleBtn.Parent = self.Container
                
                local TitleLbl = CreateLabel(ToggleBtn, ToggleName, Enum.Font.Gotham, 12)
                TitleLbl.Size = UDim2.new(1, -40, 1, 0)
                
                local SwitchBg = Instance.new("Frame")
                SwitchBg.Size = UDim2.new(0, 30, 0, 16)
                SwitchBg.Position = UDim2.new(1, -30, 0.5, -8)
                SwitchBg.BackgroundColor3 = State and Theme.Accent or Theme.Outline
                SwitchBg.Parent = ToggleBtn
                MakeCorner(SwitchBg, 8)
                
                local SwitchKnob = Instance.new("Frame")
                SwitchKnob.Size = UDim2.new(0, 12, 0, 12)
                SwitchKnob.Position = State and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
                SwitchKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SwitchKnob.Parent = SwitchBg
                MakeCorner(SwitchKnob, 6)

                local function Toggle()
                    State = not State
                    TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = State and Theme.Accent or Theme.Outline}):Play()
                    TweenService:Create(SwitchKnob, TweenInfo.new(0.2), {Position = State and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}):Play()
                    Callback(State)
                end

                ToggleBtn.MouseButton1Click:Connect(Toggle)
                return {
                    Set = function(newState)
                        if State ~= newState then Toggle() end
                    end
                }
            end

            -- Returning the section methods
            return SectionObj
        end

        return TabObj
    end

    return WindowObj
end

return NyahLib
