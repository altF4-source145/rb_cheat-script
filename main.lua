-- УДАЛЯЕМ СТАРУЮ ВЕРСИЮ ЕСЛИ ОНА БЫЛА ЗАПУЩЕНА
if game.CoreGui:FindFirstChild("QwixzCheatMenu") then
    game.CoreGui.QwixzCheatMenu:Destroy()
end

-- СОЗДАЕМ ОСНОВУ МЕНЮ
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "QwixzCheatMenu"
pcall(function() ScreenGui.Parent = game.CoreGui end)

-- ГЛАВНОЕ ОКНО
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 260)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Меню можно двигать мышкой!
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

-- ЗАГЛОВОК (НАДПИСЬ QWIXZ CHEAT)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "QWIXZ CHEAT"
Title.TextColor3 = Color3.fromRGB(0, 255, 150) -- Красивый неоновый зеленый
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

-- ФУНКЦИЯ ДЛЯ СОЗДАНИЯ КНОПОК-ПЕРЕКЛЮЧАТЕЛЕЙ
local buttonCount = 0
local function createToggle(text, callback)
    buttonCount = buttonCount + 1
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 210, 0, 45)
    ToggleBtn.Position = UDim2.new(0, 20, 0, 40 + (buttonCount * 50) - 40)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ToggleBtn.Text = text .. ": ВЫКЛ"
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
            ToggleBtn.Text = text .. ": ВКЛ"
            ToggleBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            ToggleBtn.Text = text .. ": ВЫКЛ"
            ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        callback(enabled)
    end)
end

-- =======================================================
-- ПЕРЕМЕННЫЕ ДЛЯ ВСЕХ ЧИТОВ
-- =======================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- =======================================================
-- 1. НАСТРОЙКА ТВОЕГО АИМА
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

createToggle("АИМБОТ (ПКМ)", function(state)
    _G.AimEnabled = state 
end)

-- =======================================================
-- 2. НАСТРОЙКА ИСПРАВЛЕННОГО СКВОЗЬ СТЕНЫ (NOCLIP)
-- =======================================================
_G.Noclip = false 

RunService.Stepped:Connect(function()
    if _G.Noclip and localPlayer.Character then
        for _, part in pairs(localPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

createToggle("СКВОЗЬ СТЕНЫ", function(state)
    _G.Noclip = state 
    
    -- ИСПРАВЛЕНИЕ БАГА: если выключили, возвращаем осязаемость моментально
    if not state and localPlayer.Character then
        pcall(function()
            for _, part in pairs(localPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then 
                    part.CanCollide = true
                end
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
                if speedEnabled then
                    localPlayer.Character.Humanoid.WalkSpeed = 80 
                else
                    localPlayer.Character.Humanoid.WalkSpeed = 16 
                end
            end
        end)
    end
end)

createToggle("СПИДХАК", function(state)
    speedEnabled = state
end)
