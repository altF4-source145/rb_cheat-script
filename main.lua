-- ==========================================
-- ИНИЦИАЛИЗАЦИЯ ИНТЕРФЕЙСА (fleecaa4k'menu)
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FleecaaMenuGui"
-- Безопасный запуск в инжекторе или Студио
ScreenGui.Parent = game:GetService("CoreGui") rescue game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Функция для закругления
local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
    corner.Parent = parent
end

-- ГЛАВНАЯ ПАНЕЛЬ (Левая)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
MainFrame.Position = UDim2.new(0.2, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 240, 0, 320)
MainFrame.Active = true
MainFrame.Draggable = true
addCorner(MainFrame, 14)

-- Название меню
local MenuTitle = Instance.new("TextLabel")
MenuTitle.Parent = MainFrame
MenuTitle.BackgroundTransparency = 1
MenuTitle.Position = UDim2.new(0.08, 0, 0.04, 0)
MenuTitle.Size = UDim2.new(0.7, 0, 0, 30)
MenuTitle.Text = "fleecaa4k'menu"
MenuTitle.TextColor3 = Color3.fromRGB(0, 230, 115)
MenuTitle.TextSize = 18
MenuTitle.Font = Enum.Font.GothamBold
MenuTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка закрытия (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = MainFrame
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 30)
CloseBtn.Position = UDim2.new(0.84, 0, 0.04, 0)
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 75, 75)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
addCorner(CloseBtn, 6)

-- ПАНЕЛЬ НАСТРОЕК ESP (Правая)
local ESPFrame = Instance.new("Frame")
ESPFrame.Name = "ESPFrame"
ESPFrame.Parent = ScreenGui
ESPFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
ESPFrame.Position = UDim2.new(0, MainFrame.AbsolutePosition.X + 255, 0, MainFrame.AbsolutePosition.Y)
ESPFrame.Size = UDim2.new(0, 240, 0, 320)
addCorner(ESPFrame, 14)

-- Заголовок правой панели
local ESPTitle = Instance.new("TextLabel")
ESPTitle.Parent = ESPFrame
ESPTitle.BackgroundTransparency = 1
ESPTitle.Position = UDim2.new(0, 0, 0.04, 0)
ESPTitle.Size = UDim2.new(1, 0, 0, 30)
ESPTitle.Text = "ESP Settings"
ESPTitle.TextColor3 = Color3.fromRGB(0, 230, 115)
ESPTitle.TextSize = 18
ESPTitle.Font = Enum.Font.GothamBold

-- Липкое перемещение окон друг за другом
MainFrame:GetPropertyChangedSignal("Position"):Connect(function()
    ESPFrame.Position = UDim2.new(0, MainFrame.AbsolutePosition.X + 255, 0, MainFrame.AbsolutePosition.Y)
end)

-- ==========================================
-- ФУНКЦИЯ СОЗДАНИЯ КНОПОК
-- ==========================================

local function createMenuButton(text, pos, parentFrame)
    local btn = Instance.new("TextButton")
    btn.Parent = parentFrame -- Важно: привязываем СТРОГО к нужному фрейму
    btn.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
    btn.Position = pos
    btn.Size = UDim2.new(0.88, 0, 0, 48)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(240, 100, 100) -- Красный выключенный
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    addCorner(btn, 10)
    return btn
end

-- Кнопки левой панели
local AimbotBtn = createMenuButton("AIMBOT (RMB): OFF", UDim2.new(0.06, 0, 0.18, 0), MainFrame)
local NoclipBtn = createMenuButton("NOCLIP: OFF", UDim2.new(0.06, 0, 0.38, 0), MainFrame)
local SpeedBtn  = createMenuButton("SPEEDHACK: OFF", UDim2.new(0.06, 0, 0.58, 0), MainFrame)
local EspBtn    = createMenuButton("PLAYER ESP (WH): OFF", UDim2.new(0.06, 0, 0.78, 0), MainFrame)

-- КНОПКИ ДЛЯ ПРАВОЙ ПАНЕЛИ (ESP Settings) - Теперь они точно внутри!
local ChamsBtn   = createMenuButton("CHAMS (HIGHLIGHT): OFF", UDim2.new(0.06, 0, 0.18, 0), ESPFrame)
local NameEspBtn = createMenuButton("SHOW NAMES: OFF", UDim2.new(0.06, 0, 0.38, 0), ESPFrame)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ==========================================
-- ЛОГИКА И СКАНИРОВАНИЕ ИГРОКОВ
-- ==========================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local noclip = false
local speedhack = false
local espMain = false
local espChams = false
local espNames = false

local function toggleBtnStyle(btn, state, textOn, textOff)
    if state then
        btn.Text = textOn
        btn.TextColor3 = Color3.fromRGB(0, 230, 115) -- Зеленый вкл
        btn.BackgroundColor3 = Color3.fromRGB(32, 50, 38)
    else
        btn.Text = textOff
        btn.TextColor3 = Color3.fromRGB(240, 100, 100) -- Красный выкл
        btn.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
    end
end

NoclipBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
    toggleBtnStyle(NoclipBtn, noclip, "NOCLIP: ON", "NOCLIP: OFF")
end)

RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
                if part.Name ~= "HumanoidRootPart" then
                    part.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end
end)

SpeedBtn.MouseButton1Click:Connect(function()
    speedhack = not speedhack
    toggleBtnStyle(SpeedBtn, speedhack, "SPEEDHACK: ON", "SPEEDHACK: OFF")
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = speedhack and 60 or 16
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    if speedhack then char:WaitForChild("Humanoid").WalkSpeed = 60 end
end)

-- Логика переключения кнопок ESP
EspBtn.MouseButton1Click:Connect(function()
    espMain = not espMain
    toggleBtnStyle(EspBtn, espMain, "PLAYER ESP (WH): ON", "PLAYER ESP (WH): OFF")
end)

ChamsBtn.MouseButton1Click:Connect(function()
    espChams = not espChams
    toggleBtnStyle(ChamsBtn, espChams, "CHAMS (HIGHLIGHT): ON", "CHAMS (HIGHLIGHT): OFF")
end)

NameEspBtn.MouseButton1Click:Connect(function()
    espNames = not espNames
    toggleBtnStyle(NameEspBtn, espNames, "SHOW NAMES: ON", "SHOW NAMES: OFF")
end)

-- Постоянное обновление ESP в реальном времени
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            
            if hrp then
                -- 1. Подсветка силуэта (CHAMS)
                local highlight = char:FindFirstChild("Menu_Highlight")
                if espMain and espChams then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "Menu_Highlight"
                        highlight.Parent = char
                        highlight.FillColor = Color3.fromRGB(0, 230, 115)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.FillTransparency = 0.4
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    end
                else
                    if highlight then highlight:Destroy() end
                end
                
                -- 2. Отображение Никнеймов
                local billboard = hrp:FindFirstChild("Menu_NameESP")
                if espMain and espNames then
                    if not billboard then
                        billboard = Instance.new("BillboardGui")
                        billboard.Name = "Menu_NameESP"
                        billboard.Parent = hrp
                        billboard.AlwaysOnTop = true
                        billboard.Size = UDim2.new(0, 200, 0, 50)
                        billboard.StudsOffset = Vector3.new(0, 3, 0)
                        
                        local label = Instance.new("TextLabel")
                        label.Parent = billboard
                        label.BackgroundTransparency = 1
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.Text = player.Name
                        label.TextColor3 = Color3.fromRGB(255, 255, 255)
                        label.TextStrokeTransparency = 0
                        label.TextSize = 14
                        label.Font = Enum.Font.GothamBold
                    end
                else
                    if billboard then billboard:Destroy() end
                end
            end
        end
    end
end)
