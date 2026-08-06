--[[
   ТАБЛИЧКА В РУКЕ (ВИДНА ВСЕМ) + САМОКОНТРОЛЬ
   Версия FINAL – BillboardGui на RightHand + UI-индикатор
]]

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local VERSION = "FINAL"

-- ============== НАСТРОЙКИ ==============
local HAND_NAME = "RightHand"   -- в какой руке держать
local SIGN_OFFSET = Vector3.new(0, -1.2, -1.8)  -- положение доски относительно руки
-- =======================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SignToolGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Основная панель
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 310, 0, 220)
panel.Position = UDim2.new(0, 20, 0.5, -110)
panel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
panel.BorderSizePixel = 0
panel.BackgroundTransparency = 0.1
panel.Parent = screenGui

-- Заголовок (перетаскивается)
local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
titleBar.Text = "📋 ТАБЛИЧКА v" .. VERSION .. " (держи за заголовок)"
titleBar.TextColor3 = Color3.new(1, 1, 1)
titleBar.Font = Enum.Font.SourceSansBold
titleBar.TextSize = 14
titleBar.Parent = panel

-- Поле ввода текста
local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, -20, 0, 80)
textBox.Position = UDim2.new(0, 10, 0, 42)
textBox.BackgroundColor3 = Color3.new(1, 1, 1)
textBox.Text = "Я здесь главный!"
textBox.TextColor3 = Color3.new(0, 0, 0)
textBox.Font = Enum.Font.SourceSansBold
textBox.TextSize = 18
textBox.TextWrapped = true
textBox.ClearTextOnFocus = false
textBox.PlaceholderText = "Введи что угодно..."
textBox.Parent = panel

-- Кнопка "Показать"
local showBtn = Instance.new("TextButton")
showBtn.Size = UDim2.new(0, 130, 0, 36)
showBtn.Position = UDim2.new(0, 10, 0, 135)
showBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
showBtn.Text = "ПОКАЗАТЬ"
showBtn.TextColor3 = Color3.new(1, 1, 1)
showBtn.Font = Enum.Font.SourceSansBold
showBtn.TextSize = 16
showBtn.Parent = panel

-- Кнопка "Спрятать"
local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(0, 130, 0, 36)
hideBtn.Position = UDim2.new(0, 160, 0, 135)
hideBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
hideBtn.Text = "СПРЯТАТЬ"
hideBtn.TextColor3 = Color3.new(1, 1, 1)
hideBtn.Font = Enum.Font.SourceSansBold
hideBtn.TextSize = 16
hideBtn.Parent = panel

-- Индикатор состояния (виден только тебе)
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 180)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Статус: ❌ Неактивна"
statusLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 14
statusLabel.Parent = panel

-- ============== ПЕРЕТАСКИВАНИЕ ==============
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

-- ============== ЛОГИКА ТАБЛИЧКИ ==============
local currentBillboard = nil
local isActive = false

local function createSign(text)
    local char = player.Character
    if not char then return end
    local hand = char:FindFirstChild(HAND_NAME) or char:FindFirstChild("LeftHand")
    if not hand then return end

    -- Удаляем старую
    if currentBillboard then
        currentBillboard:Destroy()
    end

    -- BillboardGui (видят ВСЕ)
    local bill = Instance.new("BillboardGui")
    bill.Name = "HandSign"
    bill.Size = UDim2.new(0, 250, 0, 90)
    bill.StudsOffset = SIGN_OFFSET
    bill.AlwaysOnTop = true
    bill.MaxDistance = 300
    bill.Adornee = hand
    bill.Parent = hand   -- реплицируется!

    -- Доска (светлое дерево)
    local board = Instance.new("Frame")
    board.Size = UDim2.new(1, 0, 1, 0)
    board.BackgroundColor3 = Color3.fromRGB(245, 225, 180)
    board.BorderSizePixel = 3
    board.BorderColor3 = Color3.fromRGB(80, 50, 20)
    board.BackgroundTransparency = 0.1
    board.Parent = bill

    -- Текст
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 1, -16)
    label.Position = UDim2.new(0, 8, 0, 8)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(0, 0, 0)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 18
    label.TextWrapped = true
    label.Parent = board

    -- Палка (ручка)
    local stick = Instance.new("Frame")
    stick.Size = UDim2.new(0, 6, 0, 40)
    stick.Position = UDim2.new(0.5, -3, 1, 0)
    stick.BackgroundColor3 = Color3.fromRGB(80, 50, 20)
    stick.BorderSizePixel = 0
    stick.Parent = board

    currentBillboard = bill
end

local function removeSign()
    if currentBillboard then
        currentBillboard:Destroy()
        currentBillboard = nil
    end
end

local function updateStatus(active, text)
    if active then
        statusLabel.Text = 'Статус: ✅ Активна ("' .. text .. '")'
        statusLabel.TextColor3 = Color3.new(0, 1, 0)
    else
        statusLabel.Text = "Статус: ❌ Неактивна"
        statusLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    end
end

showBtn.Activated:Connect(function()
    local text = textBox.Text
    if text ~= "" then
        isActive = true
        createSign(text)
        updateStatus(true, text)
        -- Звук активации (только тебе, чтобы убедиться)
        pcall(function()
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://9120386436" -- щелчок
            sound.Volume = 1
            sound.Parent = player.Character and player.Character:FindFirstChild("Head") or workspace
            sound:Play()
        end)
    end
end)

hideBtn.Activated:Connect(function()
    isActive = false
    removeSign()
    updateStatus(false, "")
end)

-- Переспавн: восстанавливаем табличку
player.CharacterAdded:Connect(function(char)
    if isActive and textBox.Text ~= "" then
        task.wait(0.3)
        createSign(textBox.Text)
        updateStatus(true, textBox.Text)
    else
        isActive = false
        updateStatus(false, "")
    end
end)

-- Мониторим, что рука не пропала (анимации)
task.spawn(function()
    while task.wait(1) do
        if isActive and currentBillboard then
            local char = player.Character
            if char then
                local hand = char:FindFirstChild(HAND_NAME) or char:FindFirstChild("LeftHand")
                if hand and currentBillboard.Parent ~= hand then
                    currentBillboard.Parent = hand
                    currentBillboard.Adornee = hand
                end
            end
        end
    end
end)

print("✅ ТАБЛИЧКА ГОТОВА. Жми ПОКАЗАТЬ и зови друга проверять!")titleBar.TextColor3 = Color3.new(1, 1, 1)
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
