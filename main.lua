local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- СОСТОЯНИЕ СИСТЕМ
local isAiming = false
local currentTarget = nil 
local isShiftLockActive = false

-- НАСТРОЙКИ АИМБОТА
local FOV_RADIUS = 90         -- Радиус круга захвата цели
local CIRCLE_COLOR = Color3.fromRGB(255, 0, 50) -- Яркий красно-розовый цвет
local CIRCLE_THICKNESS = 2.5    -- Толщина линии круга

-- НАСТРОЙКИ SHIFT LOCK
local TOGGLE_KEY = Enum.KeyCode.LeftAlt -- Включение Shift Lock на Левый Альт

-- Создаем круг аимбота через Drawing API
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = true
fovCircle.Color = CIRCLE_COLOR
fovCircle.Thickness = CIRCLE_THICKNESS
fovCircle.NumSides = 64 
fovCircle.Radius = FOV_RADIUS
fovCircle.Filled = false 
fovCircle.Transparency = 1 

-- Функция обновления позиции круга по центру экрана
local function updateCirclePosition()
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    fovCircle.Position = screenCenter
end

-- Проверка цели (жива ли она)
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

-- Поиск ближайшей головы внутри круга
local function getClosestPlayerInFOV()
    local closestPlayer = nil
    local shortestDistance = FOV_RADIUS
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if isValidTarget(player) then
            local success, _ = pcall(function()
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

-- Переключение Shift Lock
local function toggleShiftLock()
    isShiftLockActive = not isShiftLockActive
    if isShiftLockActive then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    else
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end

-- ГЛАВНЫЙ ИГРОВОЙ ЦИКЛ (Выполняется каждый кадр)
RunService.RenderStepped:Connect(function()
    updateCirclePosition() -- Центрируем круг аима

    -- 1. ЛОГИКА SHIFT LOCK
    if isShiftLockActive then
        local character = localPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            -- Поворачиваем персонажа лицом туда, куда смотрит камера
            local lookVector = camera.CFrame.LookVector
            rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + Vector3.new(lookVector.X, 0, lookVector.Z))
        end
    end

    -- 2. ЛОГИКА АИМБОТА (Имеет приоритет над поворотом камеры Shift Lock)
    if isAiming then
        -- Автопереключение целей
        if not currentTarget or not isValidTarget(currentTarget) then
            currentTarget = getClosestPlayerInFOV()
        end

        if currentTarget and currentTarget.Character then
            local targetPart = currentTarget.Character:FindFirstChild("Head") -- Целимся в ГОЛОВУ
            if targetPart then
                camera.CFrame = CFrame.new(camera.CFrame.Position, targetPart.Position)
            end
        end
    end
end)

-- НАЖАТИЕ КНОПОК
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Включение Shift Lock на Левый Альт
    if input.KeyCode == TOGGLE_KEY then
        toggleShiftLock()
    end
    
    -- Зажатие ПКМ — Аимбот
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isAiming = true
        currentTarget = getClosestPlayerInFOV()
    end
end)

-- ОТПУСКАНИЕ КНОПОК
UserInputService.InputEnded:Connect(function(input)
    -- Отпускание ПКМ — выключение Аимбота
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isAiming = false
        currentTarget = nil
    end
end)

-- Сброс мышки при смерти
localPlayer.CharacterRemoving:Connect(function()
    isShiftLockActive = false
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
end)
