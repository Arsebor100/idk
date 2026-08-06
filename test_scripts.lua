--[[
   ТАБЛИЧКА В РУКАХ ДЛЯ EVADE (ВИДНА ВСЕМ ИГРОКАМ)
   Версия 3.0 – BillboardGui на правой руке
]]

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local VERSION = "3.0"

-- ================== НАСТРОЙКИ ==================
local HOLD_HAND = "RightHand"  -- Можно "LeftHand", если хочешь в левой руке
local TABLE_SIZE = Vector3.new(2, 1.2, 0.2)  -- Размер доски (для красоты, если бы могли)
local OFFSET_POSITION = Vector3.new(0, -1.5, -2)  -- Позиция относительно руки (подбери под себя)
-- =================================================

-- GUI (только для тебя)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HandSignGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 300, 0, 200)
panel.Position = UDim2.new(0, 10, 0.5, -100)
panel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
panel.BorderSizePixel = 0
panel.BackgroundTransparency = 0.15
panel.Parent = screenGui

-- Заголовок (перетаскиваемый)
local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
titleBar.Text = "📋 ТАБЛИЧКА v" .. VERSION
titleBar.TextColor3 = Color3.new(1, 1, 1)
titleBar.Font = Enum.Font.SourceSansBold
titleBar.TextSize = 16
titleBar.Parent = panel

-- Поле текста
local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, -20, 0, 80)
textBox.Position = UDim2.new(0, 10, 0, 40)
textBox.BackgroundColor3 = Color3.new(1, 1, 1)
textBox.Text = "Я КРУТОЙ!"
textBox.TextColor3 = Color3.new(0, 0, 0)
textBox.Font = Enum.Font.SourceSansBold
textBox.TextSize = 18
textBox.TextWrapped = true
textBox.ClearTextOnFocus = false
textBox.PlaceholderText = "Введи текст..."
textBox.Parent = panel

-- Кнопка "Показать"
local showBtn = Instance.new("TextButton")
showBtn.Size = UDim2.new(0, 120, 0, 35)
showBtn.Position = UDim2.new(0, 10, 0, 135)
showBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
showBtn.Text = "ОБНОВИТЬ"
showBtn.TextColor3 = Color3.new(1, 1, 1)
showBtn.Font = Enum.Font.SourceSansBold
showBtn.TextSize = 16
showBtn.Parent = panel

-- Кнопка "Спрятать"
local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(0, 120, 0, 35)
hideBtn.Position = UDim2.new(0, 160, 0, 135)
hideBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
hideBtn.Text = "СПРЯТАТЬ"
hideBtn.TextColor3 = Color3.new(1, 1, 1)
hideBtn.Font = Enum.Font.SourceSansBold
hideBtn.TextSize = 16
hideBtn.Parent = panel

-- Подсказка
local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(1, -20, 0, 20)
hint.Position = UDim2.new(0, 10, 0, 175)
hint.BackgroundTransparency = 1
hint.Text = "Табличку видят ВСЕ игроки"
hint.TextColor3 = Color3.new(0.8, 0.8, 0.8)
hint.Font = Enum.Font.SourceSans
hint.TextSize = 12
hint.Parent = panel

-- Перетаскивание панели за заголовок
local dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = input.Position
        startPos = panel.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragStart = nil
            end
        end)
    end
end)
titleBar.InputChanged:Connect(function(input)
    if dragStart and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ================== РАБОТА С ТАБЛИЧКОЙ ==================
local currentBillboard = nil
local isActive = false

local function createBillboard(text)
    local char = player.Character
    if not char then return end
    
    local hand = char:FindFirstChild(HOLD_HAND)
    if not hand then
        -- Если рука не найдена, пробуем другую
        hand = char:FindFirstChild("LeftHand") or char:FindFirstChild("RightHand")
    end
    if not hand then return end
    
    -- Удаляем старую
    if currentBillboard then
        currentBillboard:Destroy()
    end
    
    -- Создаём BillboardGui на руке (ВИДНА ВСЕМ!)
    local bill = Instance.new("BillboardGui")
    bill.Name = "HandSign"
    bill.Size = UDim2.new(0, 300, 0, 100)
    bill.StudsOffset = OFFSET_POSITION  -- настрой положение!
    bill.AlwaysOnTop = true
    bill.MaxDistance = 200  -- дальность видимости
    bill.Adornee = hand
    bill.Parent = hand  -- <-- родитель - часть тела в Workspace → репликация на всех!
    
    -- Рамка "доски"
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(245, 225, 180)  -- цвет дерева
    frame.BorderSizePixel = 3
    frame.BorderColor3 = Color3.fromRGB(80, 50, 20)
    frame.BackgroundTransparency = 0.1
    frame.Parent = bill
    
    -- Сам текст
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 1, -16)
    label.Position = UDim2.new(0, 8, 0, 8)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(0, 0, 0)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 22
    label.TextWrapped = true
    label.Parent = frame
    
    -- Имитация ручки (палочка, идущая вниз к руке)
    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 6, 0, 50)
    handle.Position = UDim2.new(0.5, -3, 1, 0)
    handle.BackgroundColor3 = Color3.fromRGB(80, 50, 20)
    handle.BorderSizePixel = 0
    handle.Parent = frame
    
    currentBillboard = bill
end

local function removeBillboard()
    if currentBillboard then
        currentBillboard:Destroy()
        currentBillboard = nil
    end
end

-- Кнопки
showBtn.Activated:Connect(function()
    local text = textBox.Text
    if text ~= "" then
        isActive = true
        createBillboard(text)
    end
end)

hideBtn.Activated:Connect(function()
    isActive = false
    removeBillboard()
end)

-- Если персонаж переспавнился - восстанавливаем табличку
player.CharacterAdded:Connect(function(char)
    if isActive and textBox.Text ~= "" then
        task.wait(0.3)  -- ждём прогрузки рук
        createBillboard(textBox.Text)
    end
end)

-- Постоянно следим, что рука не исчезла (иногда при анимациях рука пересоздаётся)
task.spawn(function()
    while task.wait(1) do
        if isActive and currentBillboard then
            local char = player.Character
            if char then
                local hand = char:FindFirstChild(HOLD_HAND)
                if hand and currentBillboard.Parent ~= hand then
                    -- перепривязываем
                    currentBillboard.Parent = hand
                    currentBillboard.Adornee = hand
                end
            end
        end
    end
end)

print("✅ СКРИПТ ТАБЛИЧКИ В РУКАХ ЗАГРУЖЕН v" .. VERSION)
