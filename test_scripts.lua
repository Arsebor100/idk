-- ТЕСТ ЗАГРУЗКИ СКРИПТА
local player = game.Players.LocalPlayer

-- Создаём GUI который точно покажется
local gui = Instance.new("ScreenGui")
gui.Name = "ScriptLoaderTest"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Фон (чтобы точно было видно)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 120)
frame.Position = UDim2.new(0.5, -175, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.3
frame.Parent = gui

-- Версия скрипта (МЕНЯЙ ЭТО ЧИСЛО КАЖДЫЙ РАЗ)
local VERSION = "1.0"

-- Основной текст
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.Position = UDim2.new(0, 0, 0, 0)
label.BackgroundTransparency = 1
label.Text = "✅ СКРИПТ ЗАГРУЖЕН!\nВерсия: " .. VERSION .. "\nВремя: " .. os.date("%H:%M:%S")
label.TextColor3 = Color3.new(0, 1, 0)
label.Font = Enum.Font.SourceSansBold
label.TextSize = 22
label.TextWrapped = true
label.Parent = frame

-- Кнопка закрыть
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 80, 0, 30)
closeBtn.Position = UDim2.new(1, -85, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "ЗАКРЫТЬ"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 14
closeBtn.BorderSizePixel = 0
closeBtn.Parent = frame
closeBtn.Activated:Connect(function()
    gui:Destroy()
end)

-- Звуковой сигнал (если игра позволяет)
task.spawn(function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://4590662766" -- звук уведомления
        sound.Volume = 1
        sound.Parent = player.Character or workspace
        sound:Play()
    end)
end)

print("СКРИПТ ЗАГРУЖЕН! Версия: " .. VERSION .. " Время: " .. os.date("%H:%M:%S"))closeBtn.Position = UDim2.new(1, -85, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "ЗАКРЫТЬ"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 14
closeBtn.BorderSizePixel = 0
closeBtn.Parent = frame
closeBtn.Activated:Connect(function()
    gui:Destroy()
end)

-- Звуковой сигнал (если игра позволяет)
task.spawn(function()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://4590662766" -- звук уведомления
        sound.Volume = 1
        sound.Parent = player.Character or workspace
        sound:Play()
    end)
end)

print("СКРИПТ ЗАГРУЖЕН! Версия: " .. VERSION .. " Время: " .. os.date("%H:%M:%S"))    return nil
end
reviveEvent = findRevive()

-- ====== АВТОМАТИЧЕСКОЕ ВОСКРЕШЕНИЕ ======
task.spawn(function()
    while task.wait(0.5) do
        local char = player.Character
        if char then
            local hum = char:FindFirstChildWhichIsA("Humanoid")
            if hum and hum.Health <= 0 then
                -- Пытаемся оживить через Revive remote
                if reviveEvent then
                    reviveEvent:FireServer()
                elseif mainEvent then
                    mainEvent:FireServer("Revive")
                end
                -- Если не помогло, ждём, сервер сам реснет
            end
        end
    end
end)

-- При респавне телепортируемся обратно на сохранённую точку
player.CharacterAdded:Connect(function(char)
    if savedPos then
        task.wait(0.3) -- даём загрузиться
        local root = char:WaitForChild("HumanoidRootPart")
        -- Используем Remote для точного телепорта
        if mainEvent then
            mainEvent:FireServer("Teleport", savedPos) -- предположительный формат
        else
            root.CFrame = CFrame.new(savedPos) + Vector3.new(0, 3, 0)
        end
    end
end)

-- ====== ФУНКЦИЯ ЗАХВАТА ======
local function grabNearest()
    local myChar = player.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    -- Сохраняем позицию, куда вернёмся
    savedPos = myRoot.Position

    -- Ищем ближайшего живого игрока
    local nearest = nil
    local minDist = math.huge
    for _, other in pairs(game.Players:GetPlayers()) do
        if other ~= player and other.Character then
            local otherRoot = other.Character:FindFirstChild("HumanoidRootPart")
            local otherHum = other.Character:FindFirstChildWhichIsA("Humanoid")
            if otherRoot and otherHum and otherHum.Health > 0 then
                local dist = (myRoot.Position - otherRoot.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = other
                end
            end
        end
    end

    if not nearest then return end

    -- Телепортируем себя к цели (через Remote или напрямую)
    local targetRoot = nearest.Character.HumanoidRootPart
    local targetPos = targetRoot.Position

    if mainEvent then
        -- Пробуем функцию Bring или Teleport
        mainEvent:FireServer("Bring", nearest.Name)  -- телепорт меня к игроку
    else
        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 2)
    end

    task.wait(0.2)

    -- Возвращаемся вместе с целью на сохранённую точку
    if mainEvent then
        mainEvent:FireServer("BringBack", nearest.Name, savedPos) -- если есть
        -- Если такой функции нет, просто телепортируем себя и игрока по отдельности
        mainEvent:FireServer("Teleport", savedPos)  -- себя
        task.wait(0.1)
        -- Телепортируем цель
        mainEvent:FireServer("TeleportPlayer", nearest.Name, savedPos)
    else
        -- Fallback: двигаем напрямую (может не сработать)
        targetRoot.CFrame = CFrame.new(savedPos)
        myRoot.CFrame = CFrame.new(savedPos)
    end
end

-- ====== ИНТЕРФЕЙС (КНОПКА) ======
local gui = Instance.new("ScreenGui")
gui.Name = "EvadeGrabGUI"
gui.ResetOnSpawn = false
gui.Parent = (game:GetService("CoreGui") or player:WaitForChild("PlayerGui"))

-- Кнопка захвата
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 120, 0, 50)
btn.Position = UDim2.new(0, 20, 0, 20)  -- слева сверху
btn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
btn.Text = "ЗАХВАТ"
btn.TextColor3 = Color3.new(1,1,1)
btn.Font = Enum.Font.SourceSansBold
btn.TextSize = 18
btn.BorderSizePixel = 0
btn.AutoButtonColor = true
btn.Parent = gui

-- Надпись "Скрипт загружен"
local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 200, 0, 30)
label.Position = UDim2.new(0, 20, 0, 80)
label.BackgroundTransparency = 1
label.Text = "✅ Скрипт загружен"
label.TextColor3 = Color3.new(1,1,0)
label.Font = Enum.Font.SourceSansBold
label.TextSize = 16
label.Parent = gui

-- Исчезающая подсказка
task.delay(5, function()
    label:Destroy()
end)

-- Делаем кнопку перетаскиваемой (для удобства на эмуляторе)
local UIS = game:GetService("UserInputService")
local dragging = false
local dragStart, startPos

btn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = btn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

btn.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Нажатие (активация)
btn.Activated:Connect(function()
    grabNearest()
end)

print("Evade Grab скрипт готов. Используй кнопку ЗАХВАТ.")                        -- запасной вариант – полный респавн
                        player:LoadCharacter()
                    end
                end
            end
        end
    end
end)

-- При респавне телепортируемся обратно в сохранённую точку
player.CharacterAdded:Connect(function(char)
    if savedCFrame then
        task.wait(0.5) -- даём персонажу загрузиться
        local root = char:WaitForChild("HumanoidRootPart")
        root.CFrame = savedCFrame + Vector3.new(0, 3, 0) -- чуть выше, чтобы не провалиться
    end
end)

-- Главная функция: захват ближайшего игрока
local function grabNearestPlayer()
    local myChar = player.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    -- Сохраняем текущую позицию (куда вернёмся)
    savedCFrame = myRoot.CFrame

    -- Ищем ближайшего живого игрока (не себя)
    local nearest = nil
    local minDist = math.huge
    for _, other in pairs(game.Players:GetPlayers()) do
        if other ~= player and other.Character then
            local otherRoot = other.Character:FindFirstChild("HumanoidRootPart")
            local otherHum = other.Character:FindFirstChildWhichIsA("Humanoid")
            if otherRoot and otherHum and otherHum.Health > 0 then
                local dist = (myRoot.Position - otherRoot.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = other
                end
            end
        end
    end

    if not nearest then return end

    local targetRoot = nearest.Character.HumanoidRootPart

    -- Телепортируемся к цели
    myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 2) -- чуть спереди
    task.wait(0.1)

    -- Хватаем цель и вместе возвращаемся
    targetRoot.CFrame = savedCFrame
    task.wait(0.05)
    myRoot.CFrame = savedCFrame
end

-- Привязка к клавише E
uis.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then
        grabNearestPlayer()
    end
end)

print("Скрипт запущен. Нажимай E для захвата.")}

-- UI Settings: Main
Tabs.Main:AddToggle("ESP_Master", {Title = "Enable ESP", Default = true}):OnChanged(function(Value)
    ESP_Config.Enabled = Value
end)

Tabs.Main:AddToggle("Enemy_Box", {Title = "Boxes", Default = true}):OnChanged(function(Value)
    ESP_Config.Enemies.Box = Value
end)

Tabs.Main:AddToggle("Enemy_Name", {Title = "Names", Default = true}):OnChanged(function(Value)
    ESP_Config.Enemies.Name = Value
end)

Tabs.Main:AddToggle("Enemy_Dist", {Title = "Distance", Default = true}):OnChanged(function(Value)
    ESP_Config.Enemies.Distance = Value
end)

Tabs.Main:AddToggle("Enemy_Tracer", {Title = "Tracers", Default = false}):OnChanged(function(Value)
    ESP_Config.Enemies.Tracer = Value
end)

Tabs.Main:AddColorpicker("Enemy_Color", {Title = "Enemies Color", Default = Color3.fromRGB(255, 30, 30)}):OnChanged(function(Value)
    ESP_Config.Enemies.Color = Value
end)

-- UI Settings: Friends
Tabs.Friends:AddToggle("Friend_Box", {Title = "Boxes", Default = true}):OnChanged(function(Value)
    ESP_Config.Allies.Box = Value
end)

Tabs.Friends:AddToggle("Friend_Name", {Title = "Names", Default = true}):OnChanged(function(Value)
    ESP_Config.Allies.Name = Value
end)

Tabs.Friends:AddToggle("Friend_Dist", {Title = "Distance", Default = true}):OnChanged(function(Value)
    ESP_Config.Allies.Distance = Value
end)

Tabs.Friends:AddToggle("Friend_Tracer", {Title = "Tracers", Default = false}):OnChanged(function(Value)
    ESP_Config.Allies.Tracer = Value
end)

Tabs.Friends:AddColorpicker("Friend_Color", {Title = "Friends Color", Default = Color3.fromRGB(0, 255, 127)}):OnChanged(function(Value)
    ESP_Config.Allies.Color = Value
end)

-- ESP Engine
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function IsFriend(player)
    if player == LocalPlayer then return false end
    local success, result = pcall(function()
        return LocalPlayer:IsFriendsWith(player.UserId)
    end)
    return success and result
end

local function CreateESP(player)
    if player == LocalPlayer then return end

    local BoxOutline = Drawing.new("Square")
    BoxOutline.Visible = false
    BoxOutline.Thickness = 3
    BoxOutline.Color = Color3.fromRGB(0, 0, 0)

    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Thickness = 1

    local NameTag = Drawing.new("Text")
    NameTag.Visible = false
    NameTag.Center = true
    NameTag.Outline = true
    NameTag.Size = ESP_Config.TextSize

    local DistanceTag = Drawing.new("Text")
    DistanceTag.Visible = false
    DistanceTag.Center = true
    DistanceTag.Outline = true
    DistanceTag.Size = ESP_Config.TextSize - 2

    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Thickness = 1

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not ESP_Config.Enabled or not player.Parent or not player.Character then
            Box.Visible = false
            BoxOutline.Visible = false
            NameTag.Visible = false
            DistanceTag.Visible = false
            Tracer.Visible = false
            if not player.Parent then
                Box:Remove()
                BoxOutline:Remove()
                NameTag:Remove()
                DistanceTag:Remove()
                Tracer:Remove()
                connection:Disconnect()
            end
            return
        end

        local character = player.Character
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")

        if hrp and humanoid and humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

            if onScreen then
                local isAlly = IsFriend(player)
                local cfg = isAlly and ESP_Config.Allies or ESP_Config.Enemies

                local head = character:FindFirstChild("Head")
                local headPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or pos
                local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

                local height = math.abs(headPos.Y - legPos.Y)
                local width = height / 2

                if cfg.Box then
                    BoxOutline.Size = Vector2.new(width, height)
                    BoxOutline.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
                    BoxOutline.Visible = true

                    Box.Size = Vector2.new(width, height)
                    Box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
                    Box.Color = cfg.Color
                    Box.Visible = true
                else
                    Box.Visible = false
                    BoxOutline.Visible = false
                end

                if cfg.Name then
                    NameTag.Text = (isAlly and "[Friend] " or "") .. player.Name
                    NameTag.Position = Vector2.new(pos.X, (pos.Y - height / 2) - 16)
                    NameTag.Color = cfg.Color
                    NameTag.Visible = true
                else
                    NameTag.Visible = false
                end

                if cfg.Distance then
                    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local dist = myHrp and math.floor((myHrp.Position - hrp.Position).Magnitude) or 0
                    DistanceTag.Text = tostring(dist) .. "m"
                    DistanceTag.Position = Vector2.new(pos.X, (pos.Y + height / 2) + 2)
                    DistanceTag.Color = Color3.fromRGB(220, 220, 220)
                    DistanceTag.Visible = true
                else
                    DistanceTag.Visible = false
                end

                if cfg.Tracer then
                    Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    Tracer.To = Vector2.new(pos.X, pos.Y + height / 2)
                    Tracer.Color = cfg.Color
                    Tracer.Visible = true
                else
                    Tracer.Visible = false
                end
            else
                Box.Visible = false
                BoxOutline.Visible = false
                NameTag.Visible = false
                DistanceTag.Visible = false
                Tracer.Visible = false
            end
        else
            Box.Visible = false
            BoxOutline.Visible = false
            NameTag.Visible = false
            DistanceTag.Visible = false
            Tracer.Visible = false
        end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    CreateESP(player)
end

Players.PlayerAdded:Connect(CreateESP)
