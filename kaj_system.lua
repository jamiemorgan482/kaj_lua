-- KAJ LUA: COORDINATE TRACKER + RIVALS BYPASS (UPDATED)
repeat task.wait() until game:IsLoaded()

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local SaveFileName = "KAJ_Settings.txt"

-- --------------------------
-- SETTINGS & PERSISTENCE
-- --------------------------
local Settings = {
    currentKeyValue = "RightControl",
    YInputValue = "-21827023942",
    isToggled = false,
    isGlitchToggled = false,
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
                    if value == "true" or value == "false" then Settings[key] = (value == "true") else Settings[key] = value end
                end
            end
        end
    end
end

LoadSettings()

-- --------------------------
-- CHARACTER TRACKING (FIXED FOR RESPAWNS)
-- --------------------------
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    RootPart = newChar:WaitForChild("HumanoidRootPart")
end)

-- --------------------------
-- UI CREATION
-- --------------------------
local function CreateUI()
    if CoreGui:FindFirstChild("KAJ_System") then CoreGui.KAJ_System:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KAJ_System"; ScreenGui.Parent = CoreGui; ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local YInput = Instance.new("TextBox")
    local ToggleBtn = Instance.new("TextButton")
    local RandomBtn = Instance.new("TextButton")
    local GlitchBtn = Instance.new("TextButton")
    local SilentBtn = Instance.new("TextButton")
    local VoteBtn = Instance.new("TextButton") 
    local BindInput = Instance.new("TextBox")
    local DetectorLabel = Instance.new("TextLabel")
    local OpenButton = Instance.new("TextButton")
    local CoordLabel = Instance.new("TextLabel")

    local currentKey = Enum.KeyCode[Settings.currentKeyValue] or Enum.KeyCode.RightControl
    MainFrame.Visible = not Settings.silentLoad

    OpenButton.Size = UDim2.new(0, 55, 0, 55); OpenButton.Position = UDim2.new(0.05, 0, 0.4, 0); OpenButton.BackgroundColor3 = Color3.fromRGB(20, 20, 30); OpenButton.Text = "KAJ"; OpenButton.TextColor3 = Color3.fromRGB(150, 255, 200); OpenButton.Visible = UserInputService.TouchEnabled; OpenButton.Parent = ScreenGui; Instance.new("UICorner", OpenButton)
    MainFrame.Size = UDim2.new(0, 850, 0, 120); MainFrame.Position = UDim2.new(0.5, -425, 0.05, 0); MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12); MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Parent = ScreenGui; Instance.new("UICorner", MainFrame)
    Title.Size = UDim2.new(0, 100, 0, 35); Title.Position = UDim2.new(0, 15, 0, 10); Title.Text = "KAJ LUA"; Title.TextColor3 = Color3.new(1,1,1); Title.Font = Enum.Font.Code; Title.TextSize = 22; Title.BackgroundTransparency = 1; Title.Parent = MainFrame
    CoordLabel.Size = UDim2.new(0, 800, 0, 20); CoordLabel.Position = UDim2.new(0, 15, 0, 70); CoordLabel.Text = "X: 0 | Y: 0 | Z: 0"; CoordLabel.TextColor3 = Color3.fromRGB(255, 255, 255); CoordLabel.TextSize = 13; CoordLabel.Font = Enum.Font.Code; CoordLabel.BackgroundTransparency = 1; CoordLabel.TextXAlignment = Enum.TextXAlignment.Left; CoordLabel.Parent = MainFrame
    DetectorLabel.Size = UDim2.new(0, 450, 0, 20); DetectorLabel.Position = UDim2.new(0, 15, 0, 90); DetectorLabel.Text = "RIVALS BYPASS ACTIVE | P TO KILL SCRIPT"; DetectorLabel.TextColor3 = Color3.fromRGB(0, 255, 180); DetectorLabel.TextSize = 11; DetectorLabel.Font = Enum.Font.Code; DetectorLabel.BackgroundTransparency = 1; DetectorLabel.Parent = MainFrame
    
    YInput.Size = UDim2.new(0, 140, 0, 35); YInput.Position = UDim2.new(0, 110, 0, 10); YInput.Text = Settings.YInputValue; YInput.TextColor3 = Color3.fromRGB(150, 255, 200); YInput.Font = Enum.Font.Code; YInput.TextSize = 14; YInput.BackgroundTransparency = 1; YInput.Parent = MainFrame
    BindInput.Size = UDim2.new(0, 90, 0, 35); BindInput.Position = UDim2.new(0, 250, 0.08, 0); BindInput.Text = Settings.currentKeyValue; BindInput.BackgroundColor3 = Color3.fromRGB(30, 30, 45); BindInput.TextColor3 = Color3.new(1,1,1); BindInput.Parent = MainFrame; Instance.new("UICorner", BindInput)
    RandomBtn.Size = UDim2.new(0, 80, 0, 35); RandomBtn.Position = UDim2.new(0, 350, 0.08, 0); RandomBtn.Text = "RANDOM"; RandomBtn.BackgroundColor3 = Color3.fromRGB(45, 75, 140); RandomBtn.TextColor3 = Color3.new(1,1,1); RandomBtn.Parent = MainFrame; Instance.new("UICorner", RandomBtn)
    GlitchBtn.Size = UDim2.new(0, 90, 0, 35); GlitchBtn.Position = UDim2.new(0, 440, 0.08, 0); GlitchBtn.Text = Settings.isGlitchToggled and "GLITCH ON" or "GLITCH OFF"; GlitchBtn.BackgroundColor3 = Settings.isGlitchToggled and Color3.fromRGB(50, 170, 80) or Color3.fromRGB(170, 40, 40); GlitchBtn.TextColor3 = Color3.new(1,1,1); GlitchBtn.Parent = MainFrame; Instance.new("UICorner", GlitchBtn)
    VoteBtn.Size = UDim2.new(0, 95, 0, 35); VoteBtn.Position = UDim2.new(0, 540, 0.08, 0); VoteBtn.Text = Settings.autoVote and "VOTE ON" or "VOTE OFF"; VoteBtn.BackgroundColor3 = Settings.autoVote and Color3.fromRGB(0, 180, 200) or Color3.fromRGB(60, 60, 70); VoteBtn.TextColor3 = Color3.new(1,1,1); VoteBtn.Parent = MainFrame; Instance.new("UICorner", VoteBtn)
    SilentBtn.Size = UDim2.new(0, 95, 0, 35); SilentBtn.Position = UDim2.new(0, 645, 0.08, 0); SilentBtn.Text = Settings.silentLoad and "SILENT ON" or "SILENT OFF"; SilentBtn.BackgroundColor3 = Settings.silentLoad and Color3.fromRGB(100, 50, 150) or Color3.fromRGB(60, 60, 70); SilentBtn.TextColor3 = Color3.new(1,1,1); SilentBtn.Parent = MainFrame; Instance.new("UICorner", SilentBtn)
    ToggleBtn.Size = UDim2.new(0, 80, 0, 35); ToggleBtn.Position = UDim2.new(1, -95, 0.08, 0); ToggleBtn.Text = Settings.isToggled and "ON" or "OFF"; ToggleBtn.BackgroundColor3 = Settings.isToggled and Color3.fromRGB(50, 170, 80) or Color3.fromRGB(170, 40, 40); ToggleBtn.TextColor3 = Color3.new(1,1,1); ToggleBtn.Parent = MainFrame; Instance.new("UICorner", ToggleBtn)

    -- Logic Updates
    RandomBtn.MouseButton1Click:Connect(function() Settings.YInputValue = tostring(math.random(-1e7, 1e7)); YInput.Text = Settings.YInputValue; SaveSettings() end)
    ToggleBtn.MouseButton1Click:Connect(function() Settings.isToggled = not Settings.isToggled; ToggleBtn.Text = Settings.isToggled and "ON" or "OFF"; ToggleBtn.BackgroundColor3 = Settings.isToggled and Color3.fromRGB(50, 170, 80) or Color3.fromRGB(170, 40, 40); SaveSettings() end)
    GlitchBtn.MouseButton1Click:Connect(function() Settings.isGlitchToggled = not Settings.isGlitchToggled; GlitchBtn.Text = Settings.isGlitchToggled and "GLITCH ON" or "GLITCH OFF"; GlitchBtn.BackgroundColor3 = Settings.isGlitchToggled and Color3.fromRGB(50, 170, 80) or Color3.fromRGB(170, 40, 40); SaveSettings() end)
    VoteBtn.MouseButton1Click:Connect(function() Settings.autoVote = not Settings.autoVote; VoteBtn.Text = Settings.autoVote and "VOTE ON" or "VOTE OFF"; VoteBtn.BackgroundColor3 = Settings.autoVote and Color3.fromRGB(0, 180, 200) or Color3.fromRGB(60, 60, 70); SaveSettings() end)
    SilentBtn.MouseButton1Click:Connect(function() Settings.silentLoad = not Settings.silentLoad; SilentBtn.Text = Settings.silentLoad and "SILENT ON" or "SILENT OFF"; SilentBtn.BackgroundColor3 = Settings.silentLoad and Color3.fromRGB(100, 50, 150) or Color3.fromRGB(60, 60, 70); SaveSettings() end)
    
    -- UPDATED LOOP TO BYPASS DETECTION
    RunService.Heartbeat:Connect(function()
        if not RootPart or not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
        CoordLabel.Text = string.format("X: %.0f | Y: %.0f | Z: %.0f", RootPart.Position.X, RootPart.Position.Y, RootPart.Position.Z)
        
        if Settings.isGlitchToggled then
            -- Bypass: Use slightly smaller extremes to avoid instant server kicks
            local rx = math.random(-5e6, 5e6)
            local ry = math.random(-5e6, 5e6)
            local rz = math.random(-5e6, 5e6)
            
            Character:PivotTo(CFrame.new(rx, ry, rz))
            -- Clear Velocity to stop anti-cheat from detecting "unnatural movement speed"
            RootPart.AssemblyLinearVelocity = Vector3.zero
            RootPart.AssemblyAngularVelocity = Vector3.zero
        elseif Settings.isToggled then
            local tY = tonumber(Settings.YInputValue)
            if tY then 
                Character:PivotTo(CFrame.new(RootPart.Position.X, tY, RootPart.Position.Z))
                RootPart.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end)

    -- Controls
    BindInput.FocusLost:Connect(function() local success, kc = pcall(function() return Enum.KeyCode[BindInput.Text:upper()] end) if success then currentKey = kc; Settings.currentKeyValue = BindInput.Text:upper(); SaveSettings() end end)
    UserInputService.InputBegan:Connect(function(i, g) 
        if not g and i.KeyCode == currentKey then 
            MainFrame.Visible = not MainFrame.Visible 
        end 
        if not g and i.KeyCode == Enum.KeyCode.P then 
            ScreenGui:Destroy(); 
            Settings.isToggled = false; 
            Settings.isGlitchToggled = false; 
        end 
    end)
end

task.spawn(CreateUI)
