--[[
   EVADE: ТАБЛИЧКА В РУКАХ (ВИДНА ВСЕМ)
   Пишешь текст в поле - все видят его над твоей головой
   Работает через BillboardGui + часть в Workspace (видна всем)
]]

local player = game.Players.LocalPlayer
local VERSION = "2.0"

-- ====== ГЛАВНЫЙ GUI (ТОЛЬКО ДЛЯ ТЕБЯ) ======
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SignGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Фон панели
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 300, 0, 180)
panel.Position = UDim2.new(0, 10, 0.5, -90)
panel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
panel.BorderSizePixel = 0
panel.BackgroundTransparency = 0.2
panel.Parent = screenGui

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "📋 ТАБЛИЧКА (Версия " .. VERSION .. ")"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Parent = panel

-- Поле ввода текста
local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, -20, 0, 60)
textBox.Position = UDim2.new(0, 10, 0, 40)
textBox.BackgroundColor3 = Color3.new(1, 1, 1)
textBox.Text = "Привет, Evade!"
textBox.TextColor3 = Color3.new(0, 0, 0)
textBox.Font = Enum.Font.SourceSansBold
textBox.TextSize = 18
textBox.TextWrapped = true
textBox.ClearTextOnFocus = false
textBox.PlaceholderText = "Напиши что-нибудь..."
textBox.Parent = panel

-- Кнопка "Обновить табличку"
local updateBtn = Instance.new("TextButton")
updateBtn.Size = UDim2.new(0, 130, 0, 35)
updateBtn.Position = UDim2.new(0, 10, 0, 110)
updateBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
updateBtn.Text = "ОБНОВИТЬ"
updateBtn.TextColor3 = Color3.new(1, 1, 1)
updateBtn.Font = Enum.Font.SourceSansBold
updateBtn.TextSize = 16
updateBtn.Parent = panel

-- Кнопка "Спрятать"
local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(0, 130, 0, 35)
hideBtn.Position = UDim2.new(0, 150, 0, 110)
hideBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
hideBtn.Text = "СПРЯТАТЬ"
hideBtn.TextColor3 = Color3.new(1, 1, 1)
hideBtn.Font = Enum.Font.SourceSansBold
hideBtn.TextSize = 16
hideBtn.Parent = panel

-- ====== ПЕРЕМЕННЫЕ ======
local billboard = nil
local isVisible = true

-- ====== ФУНКЦИЯ: СОЗДАТЬ/ОБНОВИТЬ ТАБЛИЧКУ НАД ГОЛОВОЙ (ВИДНА ВСЕМ) ======
local function updateBillboard(text)
    local char = player.Character
    if not char then return end
    
    local head = char:FindFirstChild("Head")
    if not head then return end
    
    -- Удаляем старую если есть
    if billboard then
        billboard:Destroy()
    end
    
    -- Создаём BillboardGui (её видят все игроки!)
    billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerSign"
    billboard.Size = UDim2.new(0, 300, 0, 80)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)  -- над головой
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 100  -- с какого расстояния видно
    billboard.Adornee = head  -- прикрепляем к голове
    billboard.Parent = head  -- ВАЖНО: Parent = голова в Workspace (видят все)
    
    -- Фон таблички
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(255, 255, 200)  -- светло-жёлтая бумага
    bg.BorderSizePixel = 1
    bg.BorderColor3 = Color3.fromRGB(100, 50, 0)  -- коричневая рамка
    bg.BackgroundTransparency = 0.1
    bg.Parent = billboard
    
    -- Текст на табличке
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 1, -10)
    textLabel.Position = UDim2.new(0, 5, 0, 5)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.new(0, 0, 0)
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 20
    textLabel.TextWrapped = true
    textLabel.Parent = bg
    
    -- Маленькая палочка снизу (типа табличка на палке)
    local stick = Instance.new("Frame")
    stick.Size = UDim2.new(0, 4, 0, 40)
    stick.Position = UDim2.new(0.5, -2, 1, 0)
    stick.BackgroundColor3 = Color3.fromRGB(100, 50, 0)
    stick.BorderSizePixel = 0
    stick.Parent = bg
end

-- ====== ФУНКЦИЯ: СПРЯТАТЬ ТАБЛИЧКУ ======
local function hideBillboard()
    if billboard then
        billboard:Destroy()
        billboard = nil
    end
end

-- ====== КНОПКИ ======
updateBtn.Activated:Connect(function()
    local text = textBox.Text
    if text ~= "" then
        isVisible = true
        updateBillboard(text)
    end
end)

hideBtn.Activated:Connect(function()
    isVisible = false
    hideBillboard()
end)

-- ====== АВТОМАТИЧЕСКОЕ ОБНОВЛЕНИЕ ПРИ РЕСПАВНЕ ======
player.CharacterAdded:Connect(function(char)
    if isVisible and textBox.Text ~= "" then
        task.wait(0.5)  -- ждём загрузки персонажа
        updateBillboard(textBox.Text)
    end
end)

-- ====== ПЕРЕТАСКИВАНИЕ ПАНЕЛИ (ДЛЯ ТЕЛЕФОНА) ======
local UIS = game:GetService("UserInputService")
local dragging = false
local dragStart, startPos

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = panel.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ====== ЗАПУСК ======
print("✅ СКРИПТ ТАБЛИЧКИ ЗАГРУЖЕН! Версия " .. VERSION)
