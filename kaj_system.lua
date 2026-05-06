repeat task.wait() until game:IsLoaded()

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local SaveFileName = "KAJ_Settings.txt"

-- SETTINGS
local Settings = {
    currentKeyValue = "RightControl",
    YInputValue = "-21827023942",
    isToggled = false,
    isGlitchToggled = false,
    isVoidTPToggled = false,
    silentLoad = false,
    autoVote = false
}

local function SaveSettings()
    local dataTable = {}
    for k, v in pairs(Settings) do table.insert(dataTable, k .. "=" .. tostring(v)) end
    if writefile then pcall(function() writefile(SaveFileName, table.concat(dataTable, "\n")) end) end
end

local function LoadSettings()
    if isfile and isfile(SaveFileName) then
        local success, loadedData = pcall(function() return readfile(SaveFileName) end)
        if success then
            for line in loadedData:gmatch("[^\n]+") do
                local key, value = line:match("^(.-)=(.+)$")
                if key and Settings[key] ~= nil then
                    Settings[key] = value == "true" and true or value == "false" and false or value
                end
            end
        end
    end
end

LoadSettings()

-- CHARACTER
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    RootPart = newChar:WaitForChild("HumanoidRootPart")
end)

-- ULTRA FAST FORCE HIT FUNCTION - NO DELAYS
local function ForceHit(part)
    if not part or not part:IsA("BasePart") then return end

    for _ = 1, 15 do
        firetouchinterest(part, workspace.Terrain, false)
        firetouchinterest(part, workspace.Terrain, true)
    end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local function checkDescendants(parent)
                for _, child in pairs(parent:GetChildren()) do
                    if child:IsA("BasePart") then
                        for _ = 1, 12 do
                            firetouchinterest(part, child, false)
                            firetouchinterest(part, child, true)
                        end
                    end
                    checkDescendants(child)
                end
            end
            checkDescendants(plr.Character)
        end
    end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local direction = part.CFrame.LookVector * 100
    local result = Workspace:Raycast(part.Position, direction, raycastParams)
    if result and result.Instance then
        for _ = 1, 10 do
            firetouchinterest(part, result.Instance, false)
            firetouchinterest(part, result.Instance, true)
        end
    end
end

-- PROJECTILE DETECTION WITH ZERO DELAY
local function SetupProjectileDetection()
    Workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("BasePart") and string.find(descendant.Name:lower(), "projectile") then
            task.defer(function()
                pcall(function()
                    local owner = descendant:FindFirstChild("Owner") or descendant:FindFirstChild("Creator") or descendant.Parent:FindFirstChild("Owner") or descendant.Parent:FindFirstChild("Creator")
                    if not owner or owner.Value ~= LocalPlayer then return end

                    task.spawn(function()
                        while descendant and descendant.Parent do
                            ForceHit(descendant)
                        end
                    end)
                end)
            end)
        end
    end)
end

SetupProjectileDetection()

-- VOID TP SYSTEM - TELEPORT TO ENEMIES RAPIDLY
local function VoidTP()
    while task.wait() do
        if Settings.isVoidTPToggled and RootPart then
            local players = Players:GetPlayers()
            for _, targetPlr in pairs(players) do
                if targetPlr ~= LocalPlayer and targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart") then
                    local targetRoot = targetPlr.Character.HumanoidRootPart
                    
                    -- TP TO TARGET
                    RootPart.CFrame = targetRoot.CFrame
                    task.wait(0.01) -- SUPER FAST
                    
                    -- TP AWAY RANDOMLY FAR AWAY
                    RootPart.CFrame = CFrame.new(math.random(-1e7, 1e7), math.random(-1e7, 1e7), math.random(-1e7, 1e7))
                    task.wait(0.01)
                end
            end
        end
    end
end

task.spawn(VoidTP)-- UI CREATION
local function CreateUI()
    if CoreGui:FindFirstChild("KAJ_System") then CoreGui.KAJ_System:Destroy() end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KAJ_System"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local YInput = Instance.new("TextBox")
    local ToggleBtn = Instance.new("TextButton")
    local RandomBtn = Instance.new("TextButton")
    local GlitchBtn = Instance.new("TextButton")
    local VoidTPBtn = Instance.new("TextButton")
    local SilentBtn = Instance.new("TextButton")
    local VoteBtn = Instance.new("TextButton") 
    local BindInput = Instance.new("TextBox")
    local DetectorLabel = Instance.new("TextLabel")
    local OpenButton = Instance.new("TextButton")
    local CoordLabel = Instance.new("TextLabel")

    local currentKey = Enum.KeyCode[Settings.currentKeyValue] or Enum.KeyCode.RightControl
    MainFrame.Visible = true 

    OpenButton.Size = UDim2.new(0, 55, 0, 55)
    OpenButton.Position = UDim2.new(0.05, 0, 0.4, 0)
    OpenButton.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    OpenButton.Text = "KAJ"
    OpenButton.TextColor3 = Color3.fromRGB(150, 255, 200)
    OpenButton.Visible = UserInputService.TouchEnabled
    OpenButton.Parent = ScreenGui
    Instance.new("UICorner", OpenButton)

    MainFrame.Size = UDim2.new(0, 980, 0, 120)
    MainFrame.Position = UDim2.new(0.5, -490, 0.05, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame)

    Title.Size = UDim2.new(0, 100, 0, 35)
    Title.Position = UDim2.new(0, 15, 0, 10)
    Title.Text = "KAJ LUA"
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.Code
    Title.TextSize = 22
    Title.BackgroundTransparency = 1
    Title.Parent = MainFrame

    CoordLabel.Size = UDim2.new(0, 950, 0, 20)
    CoordLabel.Position = UDim2.new(0, 15, 0, 70)
    CoordLabel.Text = "X: 0 | Y: 0 | Z: 0"
    CoordLabel.TextColor3 = Color3.new(1,1,1)
    CoordLabel.TextSize = 13
    CoordLabel.Font = Enum.Font.Code
    CoordLabel.BackgroundTransparency = 1
    CoordLabel.TextXAlignment = Enum.TextXAlignment.Left
    CoordLabel.Parent = MainFrame

    DetectorLabel.Size = UDim2.new(0, 600, 0, 20)
    DetectorLabel.Position = UDim2.new(0, 15, 0, 90)
    DetectorLabel.Text = "FORCE HIT ACTIVE | P TO KILL SCRIPT"
    DetectorLabel.TextColor3 = Color3.fromRGB(0, 255, 180)
    DetectorLabel.TextSize = 11
    DetectorLabel.Font = Enum.Font.Code
    DetectorLabel.BackgroundTransparency = 1
    DetectorLabel.Parent = MainFrame

    YInput.Size = UDim2.new(0, 140, 0, 35)
    YInput.Position = UDim2.new(0, 110, 0, 10)
    YInput.Text = Settings.YInputValue
    YInput.TextColor3 = Color3.fromRGB(150, 255, 200)
    YInput.Font = Enum.Font.Code
    YInput.TextSize = 14
    YInput.BackgroundTransparency = 1
    YInput.Parent = MainFrame

    BindInput.Size = UDim2.new(0, 90, 0, 35)
    BindInput.Position = UDim2.new(0, 250, 0, 10)
    BindInput.Text = Settings.currentKeyValue
    BindInput.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    BindInput.TextColor3 = Color3.new(1,1,1)
    BindInput.Parent = MainFrame
    Instance.new("UICorner", BindInput)

    RandomBtn.Size = UDim2.new(0, 80, 0, 35)
    RandomBtn.Position = UDim2.new(0, 350, 0, 10)
    RandomBtn.Text = "RANDOM"
    RandomBtn.BackgroundColor3 = Color3.fromRGB(45, 75, 140)
    RandomBtn.TextColor3 = Color3.new(1,1,1)
    RandomBtn.Parent = MainFrame
    Instance.new("UICorner", RandomBtn)

    GlitchBtn.Size = UDim2.new(0, 90, 0, 35)
    GlitchBtn.Position = UDim2.new(0, 440, 0, 10)
    GlitchBtn.Text = Settings.isGlitchToggled and "GLITCH ON" or "GLITCH OFF"
    GlitchBtn.BackgroundColor3 = Settings.isGlitchToggled and Color3.fromRGB(50, 170, 80) or Color3.fromRGB(170, 40, 40)
    GlitchBtn.TextColor3 = Color3.new(1,1,1)
    GlitchBtn.Parent = MainFrame
    Instance.new("UICorner", GlitchBtn)

    VoidTPBtn.Size = UDim2.new(0, 100, 0, 35)
    VoidTPBtn.Position = UDim2.new(0, 540, 0, 10)
    VoidTPBtn.Text = Settings.isVoidTPToggled and "VOID TP ON" or "VOID TP OFF"
    VoidTPBtn.BackgroundColor3 = Settings.isVoidTPToggled and Color3.fromRGB(0, 200, 150) or Color3.fromRGB(170, 40, 40)
    VoidTPBtn.TextColor3 = Color3.new(1,1,1)
    VoidTPBtn.Parent = MainFrame
    Instance.new("UICorner", VoidTPBtn)

    VoteBtn.Size = UDim2.new(0, 95, 0, 35)
    VoteBtn.Position = UDim2.new(0, 650, 0, 10)
    VoteBtn.Text = Settings.autoVote and "VOTE ON" or "VOTE OFF"
    VoteBtn.BackgroundColor3 = Settings.autoVote and Color3.fromRGB(0, 180, 200) or Color3.fromRGB(60, 60, 70)
    VoteBtn.TextColor3 = Color3.new(1,1,1)
    VoteBtn.Parent = MainFrame
    Instance.new("UICorner", VoteBtn)

    SilentBtn.Size = UDim2.new(0, 95, 0, 35)
    SilentBtn.Position = UDim2.new(0, 755, 0, 10)
    SilentBtn.Text = Settings.silentLoad and "SILENT ON" or "SILENT OFF"
    SilentBtn.BackgroundColor3 = Settings.silentLoad and Color3.fromRGB(100, 50, 150) or Color3.fromRGB(60, 60, 70)
    SilentBtn.TextColor3 = Color3.new(1,1,1)
    SilentBtn.Parent = MainFrame
    Instance.new("UICorner", SilentBtn)

    ToggleBtn.Size = UDim2.new(0, 80, 0, 35)
    ToggleBtn.Position = UDim2.new(1, -95, 0, 10)
    ToggleBtn.Text = Settings.isToggled and "ON" or "OFF"
    ToggleBtn.BackgroundColor3 = Settings.isToggled and Color3.fromRGB(50, 170, 80) or Color3.fromRGB(170, 40, 40)
    ToggleBtn.TextColor3 = Color3.new(1,1,1)
    ToggleBtn.Parent = MainFrame
    Instance.new("UICorner", ToggleBtn)    -- BUTTONS
    RandomBtn.MouseButton1Click:Connect(function() 
        Settings.YInputValue = tostring(math.random(-1e7, 1e7))
        YInput.Text = Settings.YInputValue
        SaveSettings() 
    end)

    ToggleBtn.MouseButton1Click:Connect(function() 
        Settings.isToggled = not Settings.isToggled
        ToggleBtn.Text = Settings.isToggled and "ON" or "OFF"
        ToggleBtn.BackgroundColor3 = Settings.isToggled and Color3.fromRGB(50, 170, 80) or Color3.fromRGB(170, 40, 40)
        SaveSettings() 
    end)

    GlitchBtn.MouseButton1Click:Connect(function() 
        Settings.isGlitchToggled = not Settings.isGlitchToggled
        GlitchBtn.Text = Settings.isGlitchToggled and "GLITCH ON" or "GLITCH OFF"
        GlitchBtn.BackgroundColor3 = Settings.isGlitchToggled and Color3.fromRGB(50, 170, 80) or Color3.fromRGB(170, 40, 40)
        SaveSettings() 
    end)

    VoidTPBtn.MouseButton1Click:Connect(function() 
        Settings.isVoidTPToggled = not Settings.isVoidTPToggled
        VoidTPBtn.Text = Settings.isVoidTPToggled and "VOID TP ON" or "VOID TP OFF"
        VoidTPBtn.BackgroundColor3 = Settings.isVoidTPToggled and Color3.fromRGB(0, 200, 150) or Color3.fromRGB(170, 40, 40)
        SaveSettings() 
    end)

    VoteBtn.MouseButton1Click:Connect(function() 
        Settings.autoVote = not Settings.autoVote
        VoteBtn.Text = Settings.autoVote and "VOTE ON" or "VOTE OFF"
        VoteBtn.BackgroundColor3 = Settings.autoVote and Color3.fromRGB(0, 180, 200) or Color3.fromRGB(60, 60, 70)
        SaveSettings() 
    end)

    SilentBtn.MouseButton1Click:Connect(function() 
        Settings.silentLoad = not Settings.silentLoad
        SilentBtn.Text = Settings.silentLoad and "SILENT ON" or "SILENT OFF"
        SilentBtn.BackgroundColor3 = Settings.silentLoad and Color3.fromRGB(100, 50, 150) or Color3.fromRGB(60, 60, 70)
        SaveSettings() 
    end)

    -- FAST LOOP - FIXED LOGIC
    local PivotTo = Character.PivotTo
    local Zero = Vector3.zero

    RunService.Heartbeat:Connect(function()
        if not RootPart then return end
        
        local Pos = RootPart.Position
        CoordLabel.Text = string.format("X: %.0f | Y: %.0f | Z: %.0f", Pos.X, Pos.Y, Pos.Z)

        if Settings.isGlitchToggled then
            -- GLITCH MODE: TP RANDOMLY
            PivotTo(CFrame.new(math.random(-1e7, 1e7), math.random(-1e7, 1e7), math.random(-1e7, 1e7)))
        elseif Settings.isToggled then
            -- NORMAL MODE: STAY AT SET Y POSITION
            local tY = tonumber(Settings.YInputValue) or Pos.Y
            PivotTo(CFrame.new(Pos.X, tY, Pos.Z))
        end
    end)

    -- CONTROLS
    BindInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local key = BindInput.Text
            currentKey = Enum.KeyCode[key] or Enum.KeyCode.RightControl
            Settings.currentKeyValue = key
            SaveSettings() 
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == currentKey then
            MainFrame.Visible = not MainFrame.Visible
        elseif input.KeyCode == Enum.KeyCode.P then
            ScreenGui:Destroy()
            Settings.isToggled = false
            Settings.isGlitchToggled = false
            Settings.isVoidTPToggled = false
        end
    end)
end

task.spawn(CreateUI)
