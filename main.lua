-- REMOVE OLD VERSION IF RUNNING
if game.CoreGui:FindFirstChild("Fleecaa4kMenu") then
    game.CoreGui.Fleecaa4kMenu:Destroy()
end

-- CREATE GUI BASIS
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Fleecaa4kMenu"
pcall(function() ScreenGui.Parent = game.CoreGui end)

-- MAIN WINDOW (Compact size for 3 buttons)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 210)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, -105)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Меню можно двигать мышкой!
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

-- TITLE
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 40)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "fleecaa4k'menu"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

-- CLOSE BUTTON (X) IN THE CORNER
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- OPEN BUTTON FOR MINIMIZED MENU
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 150, 0, 35)
OpenBtn.Position = UDim2.new(0, 10, 0, 10) 
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OpenBtn.Text = "[+] Open fleecaa4k"
OpenBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 13
OpenBtn.Visible = false
OpenBtn.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 6)
OpenCorner.Parent = OpenBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenBtn.Visible = true
end)

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenBtn.Visible = false
end)

-- TOGGLE CREATOR FUNCTION
local buttonCount = 0
local function createToggle(text, callback)
    buttonCount = buttonCount + 1
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 210, 0, 45)
    ToggleBtn.Position = UDim2.new(0, 20, 0, 50 + (buttonCount * 52) - 52)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ToggleBtn.Text = text .. ": OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    ToggleBtn.Font = Enum.Font.GothamMedium
    ToggleBtn.TextSize = 14
    ToggleBtn.Parent = MainFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = ToggleBtn

    local enabled = false
    ToggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 75, 45)
            ToggleBtn.Text = text .. ": ON"
            ToggleBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            ToggleBtn.Text = text .. ": OFF"
            ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        callback(enabled)
    end)
end

-- CORE SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- =======================================================
-- 1. НАСТРОЙКА ТВОЕГО ОБНОВЛЕННОГО АИМА (HEAD + AUTO-SWAP)
-- =======================================================
_G.AimEnabled = false 
local isAiming = false
local currentTarget = nil 

-- НАСТРОЙКИ КРУГА
local FOV_RADIUS = 90         
local CIRCLE_COLOR = Color3.fromRGB(255, 0, 50) 
local CIRCLE_THICKNESS = 2.5    

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false -- Скрыт по дефолту
fovCircle.Color = CIRCLE_COLOR
fovCircle.Thickness = CIRCLE_THICKNESS
fovCircle.NumSides = 64 
fovCircle.Radius = FOV_RADIUS
fovCircle.Filled = false 
fovCircle.Transparency = 1 

local function updateCirclePosition()
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    fovCircle.Position = screenCenter
end

local function isValidTarget(player)
    if player and player ~= localPlayer and player.Character then
        local head = player.Character:FindFirstChild("Head")
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if head and humanoid and humanoid.Health > 0 then
            return true
        end
    end
    return false
end

local function getClosestPlayerInFOV()
    local closestPlayer = nil
    local shortestDistance = FOV_RADIUS
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if isValidTarget(player) then
            pcall(function()
                local targetPart = player.Character.Head
                local screenPosition, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                
                if onScreen then
                    local enemyScreenPos = Vector2.new(screenPosition.X, screenPosition.Y)
                    local distanceToCenter = (screenCenter - enemyScreenPos).Magnitude
                    
                    if distanceToCenter < shortestDistance then
                        shortestDistance = distanceToCenter
                        closestPlayer = player
                    end
                end
            end)
        end
    end
    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    if _G.AimEnabled then
        updateCirclePosition() 
        fovCircle.Visible = true

        if isAiming then
            if not currentTarget or not isValidTarget(currentTarget) then
                currentTarget = getClosestPlayerInFOV()
            end

            if currentTarget and currentTarget.Character then
                local targetPart = currentTarget.Character:FindFirstChild("Head")
                if targetPart then
                    camera.CFrame = CFrame.new(camera.CFrame.Position, targetPart.Position)
                end
            end
        end
    else
        fovCircle.Visible = false 
        isAiming = false
        currentTarget = nil
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not _G.AimEnabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isAiming = true
        currentTarget = getClosestPlayerInFOV()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isAiming = false
        currentTarget = nil
    end
end)

createToggle("AIMBOT (RMB)", function(state)
    _G.AimEnabled = state 
end)

-- =======================================================
-- 2. НАСТРОЙКА ТВОЕГО СКВОЗЬ СТЕНЫ (NOCLIP)
-- =======================================================
_G.Noclip = false 
RunService.Stepped:Connect(function()
    if _G.Noclip and localPlayer.Character then
        for _, part in pairs(localPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

createToggle("NOCLIP", function(state)
    _G.Noclip = state 
    if not state and localPlayer.Character then
        pcall(function()
            for _, part in pairs(localPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.CanCollide = true end
            end
        end)
    end
end)

-- =======================================================
-- 3. НАСТРОЙКА СПИДХАКА
-- =======================================================
local speedEnabled = false
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
                localPlayer.Character.Humanoid.WalkSpeed = speedEnabled and 80 or 16
            end
        end)
    end
end)

createToggle("SPEEDHACK", function(state)
    speedEnabled = state
end)
