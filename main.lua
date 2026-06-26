-- REMOVE OLD MENU & WINDOWS IF RUNNING
if game.CoreGui:FindFirstChild("Fleecaa4kMenu") then
    game.CoreGui.Fleecaa4kMenu:Destroy()
end

-- CREATE GUI BASIS
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Fleecaa4kMenu"
pcall(function() ScreenGui.Parent = game.CoreGui end)

-- MAIN WINDOW
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 310)
MainFrame.Position = UDim2.new(0.5, -260, 0.4, -155) -- Сдвинут влево, чтобы освободить место справа
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
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

-- CLOSE BUTTON (X)
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

-- =======================================================
-- ДОПОЛНИТЕЛЬНОЕ ОКНО ОПЦИЙ ESP (ИЗНАЧАЛЬНО СКРЫТО)
-- =======================================================
local EspFrame = Instance.new("Frame")
EspFrame.Size = UDim2.new(0, 230, 0, 310)
EspFrame.Position = UDim2.new(0.5, 5, 0.4, -155) -- Спавнится ровно справа от главного меню
EspFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
EspFrame.BorderSizePixel = 0
EspFrame.Active = true
EspFrame.Draggable = true
EspFrame.Visible = false -- Показывается только когда нажали кнопку ESP
EspFrame.Parent = ScreenGui

local EspCorner = Instance.new("UICorner")
EspCorner.CornerRadius = UDim.new(0, 10)
EspCorner.Parent = EspFrame

local EspTitle = Instance.new("TextLabel")
EspTitle.Size = UDim2.new(1, 0, 0, 40)
EspTitle.Text = "ESP Settings"
EspTitle.TextColor3 = Color3.fromRGB(0, 255, 150)
EspTitle.Font = Enum.Font.GothamBold
EspTitle.TextSize = 16
EspTitle.BackgroundTransparency = 1
EspTitle.Parent = EspFrame

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
    EspFrame.Visible = false
    OpenBtn.Visible = true
end)

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenBtn.Visible = false
end)

-- ФУНКЦИЯ ДЛЯ СОЗДАНИЯ КНОПОК
local function createToggle(parentFrame, text, yPos, callback)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 210, 0, 45)
    ToggleBtn.Position = UDim2.new(0, (parentFrame == MainFrame) and 20 or 10, 0, yPos)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ToggleBtn.Text = text .. ": OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    ToggleBtn.Font = Enum.Font.GothamMedium
    ToggleBtn.TextSize = 14
    ToggleBtn.Parent = parentFrame

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
-- 1. AIMBOT SETTINGS (RMB)
-- =======================================================
_G.AimEnabled = false 
local isAiming = false
local currentTarget = nil 
local FOV_RADIUS = 90         
local CIRCLE_COLOR = Color3.fromRGB(255, 0, 50) 
local CIRCLE_THICKNESS = 2.5    

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false 
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

local function getClosestPlayerInFOV()
    local closestPlayer = nil
    local shortestDistance = FOV_RADIUS
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            pcall(function()
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if root and humanoid and humanoid.Health > 0 then
                    local screenPosition, onScreen = camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        local enemyScreenPos = Vector2.new(screenPosition.X, screenPosition.Y)
                        local distanceToCenter = (screenCenter - enemyScreenPos).Magnitude
                        if distanceToCenter < shortestDistance then
                            shortestDistance = distanceToCenter
                            closestPlayer = player
                        end
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
        if isAiming and currentTarget and currentTarget.Character then
            local targetPart = currentTarget.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = currentTarget.Character:FindFirstChild("Humanoid")
            if targetPart and humanoid and humanoid.Health > 0 then
                camera.CFrame = CFrame.new(camera.CFrame.Position, targetPart.Position)
            else
                currentTarget = nil 
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

createToggle(MainFrame, "AIMBOT (RMB)", 50, function(state)
    _G.AimEnabled = state 
end)

-- =======================================================
-- 2. WALL COLLISION SETTINGS (NOCLIP)
-- =======================================================
_G.Noclip = false 
RunService.Stepped:Connect(function()
    if _G.Noclip and localPlayer.Character then
        for _, part in pairs(localPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

createToggle(MainFrame, "NOCLIP", 102, function(state)
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
-- 3. SPEEDHACK SETTINGS
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

createToggle(MainFrame, "SPEEDHACK", 154, function(state)
    speedEnabled = state
end)

-- =======================================================
-- ГЛАВНАЯ КНОПКА ОТКРЫТИЯ ОКНА ESP
-- =======================================================
createToggle(MainFrame, "PLAYER ESP (WH)", 206, function(state)
    EspFrame.Visible = state
end)


-- =======================================================
-- ЛОГИКА ОПЕНСУРСНОГО ESP ИЗ ТВОЕГО КОДА
-- =======================================================
local boxes = {}
local highlights = {}
local beamTracers = {}

local boxESPEnabled = false
local chamsEnabled = false
local tracerEnabled = false
