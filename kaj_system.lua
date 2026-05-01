-- KAJ LUA: COORDINATE TRACKER + MASSIVE GLITCH MODE + 3D ORBIT + P TO STOP + CUSTOM KEYBIND
repeat task.wait() until game:IsLoaded()

local UIS = game:GetService("UserInputService")
local PS = game:GetService("Players")
local RS = game:GetService("RunService")
local CG = game:GetService("CoreGui")
local LP = PS.LocalPlayer

local Settings = {
    currentKeyValue = "RightControl", -- DEFAULT KEY
    isUIHidden = false,
    YInputValue = "-21827023942",
    isToggled = false,
    isGlitchToggled = false,
    isOrbitToggled = false,
    silentLoad = false,
    -- NEW ORBIT SETTINGS: FURTHER & FASTER + 3D MOVEMENT
    orbitDistance = 30,       -- Was 15 → now 30 studs away
    orbitSpeed = 6,           -- Was 1.5 → 4x faster!
    orbitHeightOffset = 0,
    orbitAngleX = 0,
    orbitAngleY = 0
}

local lastGlitchTime = 0
local GLITCH_SPEED = 1/10 -- 10 teleports per second
local MAX_RANGE = 10000000 -- 10 MILLION studs each axis

local Character = LP.Character or LP.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

LP.CharacterAdded:Connect(function(newChar)
    Character = newChar
    RootPart = newChar:WaitForChild("HumanoidRootPart")
    lastGlitchTime = 0
end)

-- ==============================================
-- PRESS P TO STOP & REMOVE EVERYTHING
-- ==============================================
UIS.InputBegan:Connect(function(Input, gp)
    if gp then return end

    -- === CUSTOM KEYBIND TO TOGGLE UI ===
    if Input.KeyCode == Enum.KeyCode[Settings.currentKeyValue] then
        Settings.isUIHidden = not Settings.isUIHidden
        if CG:FindFirstChild("KAJ_System") then
            CG.KAJ_System.Enabled = not Settings.isUIHidden
        end
        return
    end

    -- === P TO DELETE SCRIPT ===
    if Input.KeyCode == Enum.KeyCode.P then
        if CG:FindFirstChild("KAJ_System") then
            CG.KAJ_System:Destroy()
        end
        RS:UnbindFromRenderStep("KAJ_Loop")
        Settings = nil
        Character = nil
        RootPart = nil
        return
    end
end)

local function GetClosestEnemy()
    local close, dist = nil, math.huge
    for _,p in ipairs(PS:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
            local d = (RootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then
                close = p.Character.HumanoidRootPart
                dist = d
            end
        end
    end
    return close
end

local function CreateUI()
    if CG:FindFirstChild("KAJ_System") then CG.KAJ_System:Destroy() end

    local SG = Instance.new("ScreenGui")
    SG.Name, SG.Parent, SG.ResetOnSpawn = "KAJ_System", CG, false

    local MF = Instance.new("Frame")
    MF.Size, MF.Position, MF.BackgroundColor3 = UDim2.new(0,920,0,230), UDim2.new(0.5,-460,0.05,0), Color3.new(0.04,0.04,0.04)
    MF.Active, MF.Draggable, MF.Visible = true, true, not Settings.isUIHidden
    MF.Parent = SG
    Instance.new("UICorner").Parent = MF

    local Title = Instance.new("TextLabel")
    Title.Size, Title.Position, Title.Text = UDim2.new(0,100,0,35), UDim2.new(0,15,0,10), "KAJ LUA"
    Title.TextColor3, Title.Font, Title.TextSize = Color3.new(1,1,1), Enum.Font.Code, 22
    Title.BackgroundTransparency = 1
    Title.Parent = MF

    local Coord = Instance.new("TextLabel")
    Coord.Size, Coord.Position, Coord.Text = UDim2.new(0,880,0,20), UDim2.new(0,15,0,70), "X: 0 | Y: 0 | Z: 0"
    Coord.TextColor3, Coord.Font, Coord.TextSize = Color3.new(1,1,1), Enum.Font.Code, 13
    Coord.BackgroundTransparency, Coord.TextXAlignment = 1, Enum.TextXAlignment.Left
    Coord.Parent = MF

    -- === KEYBIND BOX ===
    local BindBox = Instance.new("TextBox")
    BindBox.Size, BindBox.Position, BindBox.Text = UDim2.new(0,120,0,35), UDim2.new(0,235,0,100), Settings.currentKeyValue
    BindBox.BackgroundColor3, BindBox.TextColor3 = Color3.new(0.12,0.12,0.18), Color3.new(1,1,1)
    BindBox.Font, BindBox.TextSize = Enum.Font.Code, 14
    BindBox.PlaceholderText = "Set Key..."
    BindBox.Parent = MF
    Instance.new("UICorner").Parent = BindBox

    BindBox.FocusLost:Connect(function(enter)
        if enter then
            local valid = pcall(function() return Enum.KeyCode[BindBox.Text] end)
            if valid then
                Settings.currentKeyValue = BindBox.Text
            else
                BindBox.Text = Settings.currentKeyValue
            end
        end
    end)

    local YBox = Instance.new("TextBox")
    YBox.Size, YBox.Position, YBox.Text = UDim2.new(0,110,0,35), UDim2.new(0,115,0,100), Settings.YInputValue
    YBox.BackgroundTransparency, YBox.TextColor3, YBox.Font = 1, Color3.new(0.6,1,0.8), Enum.Font.Code
    YBox.TextSize = 14
    YBox.Parent = MF

    local DistBox = Instance.new("TextBox")
    DistBox.Size, DistBox.Position, DistBox.Text = UDim2.new(0,70,0,35), UDim2.new(0,325,0,100), tostring(Settings.orbitDistance)
    DistBox.BackgroundColor3, DistBox.TextColor3 = Color3.new(0.12,0.12,0.18), Color3.new(1,1,1)
    DistBox.Font, DistBox.TextSize = Enum.Font.Code,13
    DistBox.Parent = MF
    Instance.new("UICorner").Parent = DistBox

    local SpeedBox = Instance.new("TextBox")
    SpeedBox.Size, SpeedBox.Position, SpeedBox.Text = UDim2.new(0,60,0,35), UDim2.new(0,405,0,100), tostring(Settings.orbitSpeed)
    SpeedBox.BackgroundColor3, SpeedBox.TextColor3 = Color3.new(0.12,0.12,0.18), Color3.new(1,1,1)
    SpeedBox.Font, SpeedBox.TextSize = Enum.Font.Code,13
    SpeedBox.Parent = MF
    Instance.new("UICorner").Parent = SpeedBox

    local HeightBox = Instance.new("TextBox")
    HeightBox.Size, HeightBox.Position, HeightBox.Text = UDim2.new(0,60,0,35), UDim2.new(0,475,0,100), tostring(Settings.orbitHeightOffset)
    HeightBox.BackgroundColor3, HeightBox.TextColor3 = Color3.new(0.12,0.12,0.18), Color3.new(1,1,1)
    HeightBox.Font, HeightBox.TextSize = Enum.Font.Code,13
    HeightBox.Parent = MF
    Instance.new("UICorner").Parent = HeightBox

    local RandomBtn = Instance.new("TextButton")
    RandomBtn.Size, RandomBtn.Position, RandomBtn.Text = UDim2.new(0,75,0,35), UDim2.new(0,545,0,100), "RANDOM"
    RandomBtn.BackgroundColor3, RandomBtn.TextColor3 = Color3.new(0.18,0.29,0.55), Color3.new(1,1,1)
    RandomBtn.Parent = MF
    Instance.new("UICorner").Parent = RandomBtn

    local GlitchBtn = Instance.new("TextButton")
    GlitchBtn.Size, GlitchBtn.Position = UDim2.new(0,85,0,35), UDim2.new(0,630,0,100)
    GlitchBtn.Text = Settings.isGlitchToggled and "GLITCH ON" or "GLITCH OFF"
    GlitchBtn.BackgroundColor3 = Settings.isGlitchToggled and Color3.new(0.2,0.67,0.31) or Color3.new(0.67,0.16,0.16)
    GlitchBtn.TextColor3 = Color3.new(1,1,1)
    GlitchBtn.Parent = MF
    Instance.new("UICorner").Parent = GlitchBtn

    local OrbitBtn = Instance.new("TextButton")
    OrbitBtn.Size, OrbitBtn.Position = UDim2.new(0,80,0,35), UDim2.new(0,725,0,100)
    OrbitBtn.Text = Settings.isOrbitToggled and "ORBIT ON" or "ORBIT OFF"
    OrbitBtn.BackgroundColor3 = Settings.isOrbitToggled and Color3.new(0.2,0.67,0.31) or Color3.new(0.67,0.16,0.16)
    OrbitBtn.TextColor3 = Color3.new(1,1,1)
    OrbitBtn.Parent = MF
    Instance.new("UICorner").Parent = OrbitBtn

    local SilentBtn = Instance.new("TextButton")
    SilentBtn.Size, SilentBtn.Position = UDim2.new(0,85,0,35), UDim2.new(0,815,0,100)
    SilentBtn.Text = Settings.silentLoad and "SILENT ON" or "SILENT OFF"
    SilentBtn.BackgroundColor3 = Settings.silentLoad and Color3.new(0.39,0.2,0.59) or Color3.new(0.38,0.38,0.38)
    SilentBtn.TextColor3 = Color3.new(1,1,1)
    SilentBtn.Parent = MF
    Instance.new("UICorner").Parent = SilentBtn

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size, ToggleBtn.Position = UDim2.new(0,75,0,35), UDim2.new(0,15,0,160)
    ToggleBtn.Text = Settings.isToggled and "ON" or "OFF"
    ToggleBtn.BackgroundColor3 = Settings.isToggled and Color3.new(0.2,0.67,0.31) or Color3.new(0.67,0.16,0.16)
    ToggleBtn.TextColor3 = Color3.new(1,1,1)
    ToggleBtn.Parent = MF
    Instance.new("UICorner").Parent = ToggleBtn

    RandomBtn.MouseButton1Click:Connect(function()
        Settings.YInputValue = tostring(math.random(-100000000,100000000)*10)
        YBox.Text = Settings.YInputValue
        if Settings.isToggled then
            game:GetService("TweenService"):Create(RootPart, TweenInfo.new(1), {CFrame=CFrame.new(RootPart.Position.X,tonumber(Settings.YInputValue),RootPart.Position.Z)}):Play()
        end
    end)

    ToggleBtn.MouseButton1Click:Connect(function()
        Settings.isToggled = not Settings.isToggled
        ToggleBtn.Text = Settings.isToggled and "ON" or "OFF"
        ToggleBtn.BackgroundColor3 = Settings.isToggled and Color3.new(0.2,0.67,0.31) or Color3.new(0.67,0.16,0.16)
    end)

    GlitchBtn.MouseButton1Click:Connect(function()
        Settings.isGlitchToggled = not Settings.isGlitchToggled
        GlitchBtn.Text = Settings.isGlitchToggled and "GLITCH ON" or "GLITCH OFF"
        GlitchBtn.BackgroundColor3 = Settings.isGlitchToggled and Color3.new(0.2,0.67,0.31) or Color3.new(0.67,0.16,0.16)
    end)

    OrbitBtn.MouseButton1Click:Connect(function()
        Settings.isOrbitToggled = not Settings.isOrbitToggled
        if Settings.isOrbitToggled then
            Settings.orbitAngleX = 0
            Settings.orbitAngleY = 0
        end
        OrbitBtn.Text = Settings.isOrbitToggled and "ORBIT ON" or "ORBIT OFF"
        OrbitBtn.BackgroundColor3 = Settings.isOrbitToggled and Color3.new(0.2,0.67,0.31) or Color3.new(0.67,0.16,0.16)
    end)

    SilentBtn.MouseButton1Click:Connect(function()
        Settings.silentLoad = not Settings.silentLoad
        SilentBtn.Text = Settings.silentLoad and "SILENT ON" or "SILENT OFF"
        SilentBtn.BackgroundColor3 = Settings.silentLoad and Color3.new(0.39,0.2,0.59) or Color3.new(0.38,0.38,0.38)
        MF.Visible = not Settings.silentLoad
    end)

    DistBox.FocusLost:Connect(function(enter) 
        if enter and tonumber(DistBox.Text) then 
            Settings.orbitDistance = tonumber(DistBox.Text) 
        end 
    end)
    SpeedBox.FocusLost:Connect(function(enter) 
        if enter and tonumber(SpeedBox.Text) then 
            Settings.orbitSpeed = tonumber(SpeedBox.Text) 
        end 
    end)
    HeightBox.FocusLost:Connect(function(enter) 
        if enter and tonumber(HeightBox.Text) then 
            Settings.orbitHeightOffset = tonumber(HeightBox.Text) 
        end 
    end)

    RS:BindToRenderStep("KAJ_Loop", 1, function(dt)
        local now = os.clock()
        if not RootPart then return end
        local pos = RootPart.Position
        Coord.Text = string.format("X: %.1f | Y: %.1f | Z: %.1f", pos.X, pos.Y, pos.Z)

        if Settings.isToggled then
            local ty = tonumber(Settings.YInputValue) or 0
            RootPart.CFrame = CFrame.new(pos.X, ty, pos.Z)
        end

        -- GLITCH MODE — 10 TIMES PER SECOND, 10 MILLION STUD RANGE
        if Settings.isGlitchToggled and now - lastGlitchTime >= GLITCH_SPEED then
            lastGlitchTime = now
            local randX = math.random(-MAX_RANGE, MAX_RANGE)
            local randY = math.random(-MAX_RANGE, MAX_RANGE)
            local randZ = math.random(-MAX_RANGE, MAX_RANGE)
            RootPart.CFrame = CFrame.new(randX, randY, randZ)
        end

        -- ==============================================
        -- NEW 3D ORBIT: GOES OVER, UNDER & ALL AROUND
        -- ==============================================
        if Settings.isOrbitToggled then
            local Target = GetClosestEnemy()
            if Target then
                -- Increase angles over time for FULL 3D movement
                Settings.orbitAngleY = Settings.orbitAngleY + (Settings.orbitSpeed * dt)
                Settings.orbitAngleX = Settings.orbitAngleX + (Settings.orbitSpeed * dt * 0.7) -- Slight difference for natural loop
                
                -- Calculate position: horizontal AND vertical offset
                local x = math.cos(Settings.orbitAngleY) * math.cos(Settings.orbitAngleX) * Settings.orbitDistance
                local y = math.sin(Settings.orbitAngleX) * Settings.orbitDistance + Settings.orbitHeightOffset
                local z = math.sin(Settings.orbitAngleY) * math.cos(Settings.orbitAngleX) * Settings.orbitDistance

                -- Set position relative to target
                RootPart.CFrame = CFrame.new(Target.Position + Vector3.new(x, y, z))
            end
        end
    end)
end

-- THIS IS THE MOST IMPORTANT LINE — IT ACTUALLY RUNS THE UI!!
CreateUI()
