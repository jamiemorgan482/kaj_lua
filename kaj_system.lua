-- KAJ LUA: COORDINATE TRACKER + GLITCH MODE + FULL VERTICAL ORBIT
-- 🎨 UI REDESIGNED • ALL FUNCTIONS / LOGIC EXACTLY ORIGINAL
repeat task.wait() until game:IsLoaded()

local UIS = game:GetService("UserInputService")
local PS = game:GetService("Players")
local RS = game:GetService("RunService")
local CG = game:GetService("CoreGui")
local LP = PS.LocalPlayer

local Settings = {
    currentKeyValue = "RightControl",
    isUIHidden = false,
    YInputValue = "-21827023942",
    isToggled = false,
    isGlitchToggled = false,
    isOrbitToggled = false,
    silentLoad = false,
    orbitDistance = 4,
    orbitSpeed = 14,
    orbitAngle = 0
}

local lastGlitchTime = 0
local GLITCH_SPEED = 1/10
local MAX_RANGE = 10000000

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
    if Input.KeyCode == Enum.KeyCode[Settings.currentKeyValue] then
        Settings.isUIHidden = not Settings.isUIHidden
        if CG:FindFirstChild("KAJ_System") then
            CG.KAJ_System.Enabled = not Settings.isUIHidden
        end
        return
    end
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

    -- ======================
    -- 🎨 NEW REDESIGNED UI
    -- ======================
    local MF = Instance.new("Frame")
    MF.Size = UDim2.new(0, 940, 0, 240)
    MF.Position = UDim2.new(0.5, -470, 0.05, 0)
    MF.BackgroundColor3 = Color3.fromRGB(25, 28, 40)
    MF.BorderSizePixel = 0
    MF.Active, MF.Draggable, MF.Visible = true, true, not Settings.isUIHidden
    MF.Parent = SG

    local MainCorner = Instance.new("UICorner", MF)
    MainCorner.CornerRadius = UDim.new(0, 12)

    local Gradient = Instance.new("UIGradient", MF)
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 38, 52)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 22, 34))
    }
    Gradient.Rotation = 90

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 130, 0, 40)
    Title.Position = UDim2.new(0, 20, 0, 12)
    Title.Text = "KAJ LUA"
    Title.TextColor3 = Color3.fromRGB(120, 210, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 24
    Title.BackgroundTransparency = 1
    Title.ZIndex = 2
    Title.Parent = MF

    local Coord = Instance.new("TextLabel")
    Coord.Size = UDim2.new(0, 900, 0, 24)
    Coord.Position = UDim2.new(0, 20, 0, 70)
    Coord.Text = "X: 0 | Y: 0 | Z: 0"
    Coord.TextColor3 = Color3.fromRGB(230, 230, 230)
    Coord.Font = Enum.Font.GothamSemibold
    Coord.TextSize = 15
    Coord.BackgroundTransparency = 1
    Coord.TextXAlignment = Enum.TextXAlignment.Left
    Coord.ZIndex = 2
    Coord.Parent = MF

    local YBox = Instance.new("TextBox")
    YBox.Size = UDim2.new(0, 120, 0, 38)
    YBox.Position = UDim2.new(0, 20, 0, 110)
    YBox.Text = Settings.YInputValue
    YBox.BackgroundColor3 = Color3.fromRGB(40, 44, 60)
    YBox.TextColor3 = Color3.fromRGB(100, 255, 160)
    YBox.Font = Enum.Font.GothamBold
    YBox.TextSize = 14
    YBox.ClearTextOnFocus = false
    YBox.ZIndex = 2
    YBox.Parent = MF
    Instance.new("UICorner", YBox).CornerRadius = UDim.new(0, 8)

    local BindBox = Instance.new("TextBox")
    BindBox.Size = UDim2.new(0, 130, 0, 38)
    BindBox.Position = UDim2.new(0, 150, 0, 110)
    BindBox.Text = Settings.currentKeyValue
    BindBox.BackgroundColor3 = Color3.fromRGB(45, 50, 70)
    BindBox.TextColor3 = Color3.new(1,1,1)
    BindBox.Font = Enum.Font.GothamBold
    BindBox.TextSize = 14
    BindBox.PlaceholderText = "Set Key..."
    BindBox.ClearTextOnFocus = false
    BindBox.ZIndex = 2
    BindBox.Parent = MF
    Instance.new("UICorner", BindBox).CornerRadius = UDim.new(0, 8)

    local DistBox = Instance.new("TextBox")
    DistBox.Size = UDim2.new(0, 80, 0, 38)
    DistBox.Position = UDim2.new(0, 290, 0, 110)
    DistBox.Text = tostring(Settings.orbitDistance)
    DistBox.BackgroundColor3 = Color3.fromRGB(45, 50, 70)
    DistBox.TextColor3 = Color3.new(1,1,1)
    DistBox.Font = Enum.Font.GothamBold
    DistBox.TextSize = 14
    DistBox.ClearTextOnFocus = false
    DistBox.ZIndex = 2
    DistBox.Parent = MF
    Instance.new("UICorner", DistBox).CornerRadius = UDim.new(0, 8)

    local SpeedBox = Instance.new("TextBox")
    SpeedBox.Size = UDim2.new(0, 70, 0, 38)
    SpeedBox.Position = UDim2.new(0, 380, 0, 110)
    SpeedBox.Text = tostring(Settings.orbitSpeed)
    SpeedBox.BackgroundColor3 = Color3.fromRGB(45, 50, 70)
    SpeedBox.TextColor3 = Color3.new(1,1,1)
    SpeedBox.Font = Enum.Font.GothamBold
    SpeedBox.TextSize = 14
    SpeedBox.ClearTextOnFocus = false
    SpeedBox.ZIndex = 2
    SpeedBox.Parent = MF
    Instance.new("UICorner", SpeedBox).CornerRadius = UDim.new(0, 8)

    local RandomBtn = Instance.new("TextButton")
    RandomBtn.Size = UDim2.new(0, 85, 0, 38)
    RandomBtn.Position = UDim2.new(0, 470, 0, 110)
    RandomBtn.Text = "RANDOM"
    RandomBtn.BackgroundColor3 = Color3.fromRGB(35, 110, 190)
    RandomBtn.TextColor3 = Color3.new(1,1,1)
    RandomBtn.Font = Enum.Font.GothamBold
    RandomBtn.TextSize = 14
    RandomBtn.ZIndex = 3
    RandomBtn.Parent = MF
    Instance.new("UICorner", RandomBtn).CornerRadius = UDim.new(0, 8)

    local GlitchBtn = Instance.new("TextButton")
    GlitchBtn.Size = UDim2.new(0, 95, 0, 38)
    GlitchBtn.Position = UDim2.new(0, 565, 0, 110)
    GlitchBtn.Text = Settings.isGlitchToggled and "GLITCH ON" or "GLITCH OFF"
    GlitchBtn.BackgroundColor3 = Settings.isGlitchToggled and Color3.fromRGB(42, 175, 68) or Color3.fromRGB(175, 42, 42)
    GlitchBtn.TextColor3 = Color3.new(1,1,1)
    GlitchBtn.Font = Enum.Font.GothamBold
    GlitchBtn.TextSize = 14
    GlitchBtn.ZIndex = 3
    GlitchBtn.Parent = MF
    Instance.new("UICorner", GlitchBtn).CornerRadius = UDim.new(0, 8)

    local OrbitBtn = Instance.new("TextButton")
    OrbitBtn.Size = UDim2.new(0, 90, 0, 38)
    OrbitBtn.Position = UDim2.new(0, 670, 0, 110)
    OrbitBtn.Text = Settings.isOrbitToggled and "ORBIT ON" or "ORBIT OFF"
    OrbitBtn.BackgroundColor3 = Settings.isOrbitToggled and Color3.fromRGB(42, 175, 68) or Color3.fromRGB(175, 42, 42)
    OrbitBtn.TextColor3 = Color3.new(1,1,1)
    OrbitBtn.Font = Enum.Font.GothamBold
    OrbitBtn.TextSize = 14
    OrbitBtn.ZIndex = 3
    OrbitBtn.Parent = MF
    Instance.new("UICorner", OrbitBtn).CornerRadius = UDim.new(0, 8)

    local SilentBtn = Instance.new("TextButton")
    SilentBtn.Size = UDim2.new(0, 95, 0, 38)
    SilentBtn.Position = UDim2.new(0, 770, 0, 110)
    SilentBtn.Text = Settings.silentLoad and "SILENT ON" or "SILENT OFF"
    SilentBtn.BackgroundColor3 = Settings.silentLoad and Color3.fromRGB(120, 70, 200) or Color3.fromRGB(80, 80, 95)
    SilentBtn.TextColor3 = Color3.new(1,1,1)
    SilentBtn.Font = Enum.Font.GothamBold
    SilentBtn.TextSize = 14
    SilentBtn.ZIndex = 3
    SilentBtn.Parent = MF
    Instance.new("UICorner", SilentBtn).CornerRadius = UDim.new(0, 8)

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 85, 0, 42)
    ToggleBtn.Position = UDim2.new(0, 20, 0, 165)
    ToggleBtn.Text = Settings.isToggled and "ON" or "OFF"
    ToggleBtn.BackgroundColor3 = Settings.isToggled and Color3.fromRGB(42, 175, 68) or Color3.fromRGB(175, 42, 42)
    ToggleBtn.TextColor3 = Color3.new(1,1,1)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 16
    ToggleBtn.ZIndex = 3
    ToggleBtn.Parent = MF
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)

    -- 🧩 ALL ORIGINAL FUNCTIONS / LOGIC — NO CHANGES
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
        ToggleBtn.BackgroundColor3 = Settings.isToggled and Color3.fromRGB(42, 175, 68) or Color3.fromRGB(175, 42, 42)
    end)

    GlitchBtn.MouseButton1Click:Connect(function()
        Settings.isGlitchToggled = not Settings.isGlitchToggled
        GlitchBtn.Text = Settings.isGlitchToggled and "GLITCH ON" or "GLITCH OFF"
        GlitchBtn.BackgroundColor3 = Settings.isGlitchToggled and Color3.fromRGB(42, 175, 68) or Color3.fromRGB(175, 42, 42)
    end)

    OrbitBtn.MouseButton1Click:Connect(function()
        Settings.isOrbitToggled = not Settings.isOrbitToggled
        if Settings.isOrbitToggled then
            Settings.orbitAngle = 0
        end
        OrbitBtn.Text = Settings.isOrbitToggled and "ORBIT ON" or "ORBIT OFF"
        OrbitBtn.BackgroundColor3 = Settings.isOrbitToggled and Color3.fromRGB(42, 175, 68) or Color3.fromRGB(175, 42, 42)
    end)

    SilentBtn.MouseButton1Click:Connect(function()
        Settings.silentLoad = not Settings.silentLoad
        SilentBtn.Text = Settings.silentLoad and "SILENT ON" or "SILENT OFF"
        SilentBtn.BackgroundColor3 = Settings.silentLoad and Color3.fromRGB(120, 70, 200) or Color3.fromRGB(80, 80, 95)
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
        end        -- ==============================================
        -- ✅ PROPER FULL VERTICAL ORBIT
        -- ==============================================
        if Settings.isOrbitToggled then
            local Target = GetClosestEnemy()
            if Target then
                -- Increase angle over time to make the loop
                Settings.orbitAngle = Settings.orbitAngle + (Settings.orbitSpeed * dt)

                -- Math for vertical circle movement
                local xOffset = math.sin(Settings.orbitAngle) * Settings.orbitDistance
                local yOffset = math.cos(Settings.orbitAngle) * Settings.orbitDistance

                -- Move around the target: goes over head → down side → under feet → up other side → repeat
                RootPart.CFrame = CFrame.new(Target.Position + Vector3.new(xOffset, yOffset, 0))
            end
        end    end)
end

-- RUN THE UI
CreateUI()
