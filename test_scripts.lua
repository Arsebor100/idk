--[[
    СКРИПТ ДЛЯ EVADE: TP GRAB + AUTO REVIVE + SPAWN POINT
    Клавиша E – взять ближайшего игрока и вернуться с ним на место
]]

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local uis = game:GetService("UserInputService")
local replicated = game:GetService("ReplicatedStorage")
local savedCFrame = nil  -- место, откуда начали

-- Функция поиска удалённого события (Revive)
local function getReviveRemote()
    for _, v in pairs(replicated:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name == "Revive" then
            return v
        end
    end
    return nil
end

-- Автоматическое воскрешение (если упал)
task.spawn(function()
    while task.wait(0.5) do
        local char = player.Character
        if char then
            local hum = char:FindFirstChildWhichIsA("Humanoid")
            if hum then
                local state = hum:GetState()
                -- если умер или лежит без сознания (Dead / Ragdoll)
                if state == Enum.HumanoidStateType.Dead or
                   (state == Enum.HumanoidStateType.Physics and hum.Sit) then
                    local remote = getReviveRemote()
                    if remote then
                        remote:FireServer("Revive")
                    else
                        -- запасной вариант – полный респавн
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
