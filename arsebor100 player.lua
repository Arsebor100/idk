-- 🔥 ULTIMATE RED MUSIC PLAYER v2 для Delta 🔥
-- Последняя версия — сделал максимально красиво

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("RedMusicPro") then
    playerGui.RedMusicPro:Destroy()
end

local sg = Instance.new("ScreenGui")
sg.Name = "RedMusicPro"
sg.ResetOnSpawn = false
sg.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 460, 0, 580)
main.Position = UDim2.new(0.5, -230, 0.5, -290)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.BorderSizePixel = 0
main.Parent = sg

local mainCorner = Instance.new("UICorner", main)
mainCorner.CornerRadius = UDim.new(0, 20)

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = Color3.fromRGB(220, 20, 60)
mainStroke.Thickness = 2.5

-- Title Bar
local title = Instance.new("Frame", main)
title.Size = UDim2.new(1, 0, 0, 55)
title.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
title.Parent = main

Instance.new("UICorner", title).CornerRadius = UDim.new(0, 20)

local titleText = Instance.new("TextLabel", title)
titleText.Size = UDim2.new(1, -140, 1, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "🔥 RED MUSIC PRO"
titleText.TextColor3 = Color3.fromRGB(255, 70, 70)
titleText.Font = Enum.Font.GothamBlack
titleText.TextSize = 22
titleText.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопки окна
local minBtn = Instance.new("TextButton", title)
minBtn.Size = UDim2.new(0,45,0,45)
minBtn.Position = UDim2.new(1,-95,0,5)
minBtn.BackgroundTransparency = 1
minBtn.Text = "−"
minBtn.TextColor3 = Color3.fromRGB(255,200,200)
minBtn.TextSize = 30

local closeBtn = Instance.new("TextButton", title)
closeBtn.Size = UDim2.new(0,45,0,45)
closeBtn.Position = UDim2.new(1,-45,0,5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
closeBtn.TextSize = 28

-- Визуализатор
local viz = Instance.new("Frame", main)
viz.Size = UDim2.new(1, -40, 0, 140)
viz.Position = UDim2.new(0,20,0,70)
viz.BackgroundColor3 = Color3.fromRGB(8,8,8)
viz.Parent = main
Instance.new("UICorner", viz).CornerRadius = UDim.new(0,16)

local bars = {}
for i = 1, 48 do
    local b = Instance.new("Frame", viz)
    b.Size = UDim2.new(0, 6, 0, 30)
    b.Position = UDim2.new(0, 12 + (i-1)*8.5, 1, -35)
    b.BackgroundColor3 = Color3.fromRGB(255, 45 + i*3, 45 + i*2)
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,3)
    table.insert(bars, b)
end

-- Плейлист
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -40, 0, 210)
scroll.Position = UDim2.new(0,20,0,225)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 5
scroll.Parent = main

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,6)

-- Управление
local controls = Instance.new("Frame", main)
controls.Size = UDim2.new(1,-40,0,140)
controls.Position = UDim2.new(0,20,1,-160)
controls.BackgroundTransparency = 1
controls.Parent = main

-- ID + Add
local idInput = Instance.new("TextBox", controls)
idInput.Size = UDim2.new(0.65,0,0,38)
idInput.Position = UDim2.new(0,0,0,0)
idInput.PlaceholderText = "Вставь ID песни..."
idInput.BackgroundColor3 = Color3.fromRGB(25,25,25)
idInput.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", idInput).CornerRadius = UDim.new(0,10)

local add = Instance.new("TextButton", controls)
add.Size = UDim2.new(0.32,0,0,38)
add.Position = UDim2.new(0.68,0,0,0)
add.BackgroundColor3 = Color3.fromRGB(180,0,0)
add.Text = "Добавить"
add.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", add).CornerRadius = UDim.new(0,10)

-- Кнопки плеера
local prev = Instance.new("TextButton", controls)
prev.Size = UDim2.new(0,55,0,55)
prev.Position = UDim2.new(0.1,0,0.35,0)
prev.BackgroundColor3 = Color3.fromRGB(40,0,0)
prev.Text = "⏮"
prev.TextSize = 32

local play = Instance.new("TextButton", controls)
play.Size = UDim2.new(0,80,0,80)
play.Position = UDim2.new(0.5,-40,0.25,0)
play.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
play.Text = "▶"
play.TextSize = 42

local nextb = Instance.new("TextButton", controls)
nextb.Size = UDim2.new(0,55,0,55)
nextb.Position = UDim2.new(0.75,0,0.35,0)
nextb.BackgroundColor3 = Color3.fromRGB(40,0,0)
nextb.Text = "⏭"
nextb.TextSize = 32

-- Мини-плеер (при сворачивании)
local mini = Instance.new("Frame", sg)
mini.Size = UDim2.new(0, 380, 0, 70)
mini.Position = UDim2.new(0.5, -190, 1, -90)
mini.BackgroundColor3 = Color3.fromRGB(20,0,0)
mini.Visible = false
Instance.new("UICorner", mini).CornerRadius = UDim.new(0,16)

local miniViz = Instance.new("Frame", mini) -- маленький визуализатор
miniViz.Size = UDim2.new(0, 120, 0, 50)
miniViz.Position = UDim2.new(0,15,0.5,-25)
miniViz.BackgroundTransparency = 1

-- Логика
local sound = Instance.new("Sound", SoundService)
sound.Looped = true
sound.Volume = 0.8

local playlist = getgenv().RedPlaylist or {}
getgenv().RedPlaylist = playlist
local index = 1
local minimized = false
local shuffle = false
local loop = true

local function savePlaylist()
    getgenv().RedPlaylist = playlist
end

local function updatePlaylist()
    for _,v in pairs(scroll:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    for i, song in ipairs(playlist) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 42)
        btn.BackgroundColor3 = (i == index) and Color3.fromRGB(140,0,0) or Color3.fromRGB(35,35,35)
        btn.Text = "  ".. (song.name or "Song "..i) .. "  |  " .. song.id
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Parent = scroll
        btn.MouseButton1Click:Connect(function()
            index = i
            playCurrent()
        end)
    end
    scroll.CanvasSize = UDim2.new(0,0,0,#playlist*48)
end

local function playCurrent()
    if #playlist == 0 then return end
    local s = playlist[index]
    sound.SoundId = "rbxassetid://" .. s.id
    sound:Play()
    play.Text = "⏸"
    updatePlaylist()
end

-- Визуализатор
RunService.RenderStepped:Connect(function()
    if not sound.IsPlaying then return end
    local loud = sound.PlaybackLoudness / 380
    for i, bar in ipairs(bars) do
        local h = 25 + math.random(10,110) * loud + math.sin(tick()*8 + i)*15
        TweenService:Create(bar, TweenInfo.new(0.1), {Size = UDim2.new(0,6,0,math.clamp(h,15,135))}):Play()
    end
end)

-- Кнопки
add.MouseButton1Click:Connect(function()
    local id = idInput.Text:match("%d+")
    if id then
        table.insert(playlist, {id = id, name = "Song "..(#playlist+1)})
        savePlaylist()
        updatePlaylist()
        if #playlist == 1 then playCurrent() end
        idInput.Text = ""
    end
end)

play.MouseButton1Click:Connect(function()
    if sound.IsPlaying then
        sound:Pause()
        play.Text = "▶"
    else
        sound:Resume()
        play.Text = "⏸"
    end
end)

nextb.MouseButton1Click:Connect(function()
    if shuffle then
        index = math.random(1,#playlist)
    else
        index = index % #playlist + 1
    end
    playCurrent()
end)

prev.MouseButton1Click:Connect(function()
    index = index - 1
    if index < 1 then index = #playlist end
    playCurrent()
end)

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = UDim2.new(0,460,0,80)}):Play()
        scroll.Visible = false
        controls.Visible = false
        viz.Visible = false
        mini.Visible = true
    else
        TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = UDim2.new(0,460,0,580)}):Play()
        scroll.Visible = true
        controls.Visible = true
        viz.Visible = true
        mini.Visible = false
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    sg:Destroy()
    sound:Stop()
    print("Red Music Pro закрыт.")
end)

-- Drag
local dragging, dragStart, startPos
title.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = inp.Position
        startPos = main.Position
    end
end)

title.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

UserInputService.InputChanged:Connect(function(inp)
    if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = inp.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Инициализация
updatePlaylist()
if #playlist > 0 then playCurrent() end

print("✅ ULTIMATE RED MUSIC PLAYER ЗАГРУЖЕН. Наслаждайся, брат.")
