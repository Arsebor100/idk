-- 🔥 Красный Музыкальный Плеер для Delta Executor 🔥
-- Красивый GUI с визуализатором, плейлистом, памятью, сворачиванием и закрытием
-- Вставь в Delta Executor

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Удаляем старый GUI если есть
if playerGui:FindFirstChild("RedMusicPlayer") then
    playerGui.RedMusicPlayer:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RedMusicPlayer"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Основной фрейм
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 420, 0, 520)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -260)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 50, 50)
stroke.Thickness = 2
stroke.Parent = mainFrame

-- Заголовок
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 16)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -120, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🔥 RED MUSIC PLAYER"
titleLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 20
titleLabel.Parent = titleBar

-- Кнопки управления окном
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 40, 0, 40)
minimizeBtn.Position = UDim2.new(1, -90, 0, 5)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "🗠"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
minimizeBtn.TextSize = 24
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -45, 0, 5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.TextSize = 24
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

-- Визуализатор (основной)
local vizFrame = Instance.new("Frame")
vizFrame.Size = UDim2.new(1, -40, 0, 120)
vizFrame.Position = UDim2.new(0, 20, 0, 70)
vizFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
vizFrame.Parent = mainFrame

local vizCorner = Instance.new("UICorner")
vizCorner.CornerRadius = UDim.new(0, 12)
vizCorner.Parent = vizFrame

local bars = {}
for i = 1, 32 do
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 8, 0, 20)
    bar.Position = UDim2.new(0, 10 + (i-1)*12, 1, -20)
    bar.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    bar.BorderSizePixel = 0
    bar.Parent = vizFrame
    local bCorner = Instance.new("UICorner", bar)
    bCorner.CornerRadius = UDim.new(0, 4)
    table.insert(bars, bar)
end

-- Плейлист
local playlistFrame = Instance.new("ScrollingFrame")
playlistFrame.Size = UDim2.new(1, -40, 0, 180)
playlistFrame.Position = UDim2.new(0, 20, 0, 210)
playlistFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
playlistFrame.ScrollBarThickness = 6
playlistFrame.Parent = mainFrame

local pCorner = Instance.new("UICorner")
pCorner.CornerRadius = UDim.new(0, 12)
pCorner.Parent = playlistFrame

local playlistLayout = Instance.new("UIListLayout")
playlistLayout.SortOrder = Enum.SortOrder.LayoutOrder
playlistLayout.Padding = UDim.new(0, 4)
playlistLayout.Parent = playlistFrame

-- Панель управления
local controlFrame = Instance.new("Frame")
controlFrame.Size = UDim2.new(1, -40, 0, 100)
controlFrame.Position = UDim2.new(0, 20, 1, -120)
controlFrame.BackgroundTransparency = 1
controlFrame.Parent = mainFrame

-- ID ввода
local idBox = Instance.new("TextBox")
idBox.Size = UDim2.new(0.6, 0, 0, 35)
idBox.Position = UDim2.new(0, 0, 0, 0)
idBox.PlaceholderText = "Введи ID песни (rbxassetid://...)"
idBox.Text = ""
idBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
idBox.TextColor3 = Color3.fromRGB(255, 255, 255)
idBox.Font = Enum.Font.Gotham
idBox.TextSize = 14
idBox.Parent = controlFrame

local addBtn = Instance.new("TextButton")
addBtn.Size = UDim2.new(0.35, 0, 0, 35)
addBtn.Position = UDim2.new(0.65, 0, 0, 0)
addBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
addBtn.Text = "➕ Добавить"
addBtn.TextColor3 = Color3.new(1,1,1)
addBtn.Font = Enum.Font.GothamBold
addBtn.Parent = controlFrame

-- Кнопки плеера
local prevBtn = Instance.new("TextButton")
prevBtn.Size = UDim2.new(0, 50, 0, 50)
prevBtn.Position = UDim2.new(0, 20, 0, 45)
prevBtn.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
prevBtn.Text = "⏮"
prevBtn.TextColor3 = Color3.new(1,1,1)
prevBtn.TextSize = 28
prevBtn.Parent = controlFrame

local playBtn = Instance.new("TextButton")
playBtn.Size = UDim2.new(0, 70, 0, 70)
playBtn.Position = UDim2.new(0.5, -35, 0, 35)
playBtn.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
playBtn.Text = "▶"
playBtn.TextColor3 = Color3.new(1,1,1)
playBtn.TextSize = 36
playBtn.Parent = controlFrame

local nextBtn = Instance.new("TextButton")
nextBtn.Size = UDim2.new(0, 50, 0, 50)
nextBtn.Position = UDim2.new(1, -70, 0, 45)
nextBtn.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
nextBtn.Text = "⏭"
nextBtn.TextColor3 = Color3.new(1,1,1)
nextBtn.TextSize = 28
nextBtn.Parent = controlFrame

local volumeSlider = Instance.new("TextBox") -- Простой слайдер через текст
volumeSlider.Size = UDim2.new(0.4, 0, 0, 25)
volumeSlider.Position = UDim2.new(0.3, 0, 0, 70)
volumeSlider.Text = "Громкость: 0.7"
volumeSlider.BackgroundColor3 = Color3.fromRGB(30,30,30)
volumeSlider.Parent = controlFrame

-- Звук
local currentSound = Instance.new("Sound")
currentSound.Parent = SoundService
currentSound.Looped = true
currentSound.Volume = 0.7

local playlist = {}
local currentIndex = 1
local isPlaying = false
local isMinimized = false

-- Сохранение плейлиста (в getgenv)
if not getgenv().RedMusicPlaylist then
    getgenv().RedMusicPlaylist = {}
end
playlist = getgenv().RedMusicPlaylist

-- Обновление списка песен
local function updatePlaylistUI()
    for _, child in pairs(playlistFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for i, song in ipairs(playlist) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 40)
        btn.BackgroundColor3 = (i == currentIndex) and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(40, 40, 40)
        btn.Text = song.name or ("Песня " .. i .. " | ID: " .. song.id)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = playlistFrame
        btn.MouseButton1Click:Connect(function()
            currentIndex = i
            playSong()
            updatePlaylistUI()
        end)
    end
    playlistFrame.CanvasSize = UDim2.new(0, 0, 0, #playlist * 44)
end

local function playSong()
    if #playlist == 0 then return end
    local song = playlist[currentIndex]
    currentSound.SoundId = "rbxassetid://" .. song.id
    currentSound:Play()
    isPlaying = true
    playBtn.Text = "⏸"
end

-- Визуализатор
local function updateVisualizer()
    if not currentSound.IsPlaying then 
        for _, bar in ipairs(bars) do
            TweenService:Create(bar, TweenInfo.new(0.1), {Size = UDim2.new(0, 8, 0, 10)}):Play()
        end
        return 
    end
    
    local loudness = currentSound.PlaybackLoudness / 400
    for i, bar in ipairs(bars) do
        local height = math.clamp(math.random(20, 100) * loudness + math.sin(tick() * 10 + i) * 10, 10, 110)
        TweenService:Create(bar, TweenInfo.new(0.08, Enum.EasingStyle.Sine), {
            Size = UDim2.new(0, 8, 0, height)
        }):Play()
    end
end

-- Drag
local dragging = false
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        update(input)
    end
end)

-- Кнопки
addBtn.MouseButton1Click:Connect(function()
    local id = idBox.Text:match("%d+")
    if id then
        table.insert(playlist, {id = id, name = "Песня #" .. (#playlist + 1)})
        getgenv().RedMusicPlaylist = playlist
        updatePlaylistUI()
        idBox.Text = ""
        if #playlist == 1 then
            currentIndex = 1
            playSong()
        end
    end
end)

playBtn.MouseButton1Click:Connect(function()
    if isPlaying then
        currentSound:Pause()
        playBtn.Text = "▶"
    else
        currentSound:Resume()
        playBtn.Text = "⏸"
    end
    isPlaying = not isPlaying
end)

nextBtn.MouseButton1Click:Connect(function()
    currentIndex = currentIndex % #playlist + 1
    playSong()
    updatePlaylistUI()
end)

prevBtn.MouseButton1Click:Connect(function()
    currentIndex = currentIndex - 1
    if currentIndex < 1 then currentIndex = #playlist end
    playSong()
    updatePlaylistUI()
end)

minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 420, 0, 80)}):Play()
        vizFrame.Visible = false
        playlistFrame.Visible = false
        controlFrame.Visible = false
    else
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 420, 0, 520)}):Play()
        vizFrame.Visible = true
        playlistFrame.Visible = true
        controlFrame.Visible = true
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    currentSound:Stop()
    currentSound:Destroy()
    print("🔥 Red Music Player выгружен!")
end)

volumeSlider.FocusLost:Connect(function()
    local vol = tonumber(volumeSlider.Text:match("%d+%.?%d*")) or 0.7
    currentSound.Volume = math.clamp(vol, 0, 2)
    volumeSlider.Text = "Громкость: " .. currentSound.Volume
end)

-- Запуск
updatePlaylistUI()
if #playlist > 0 then
    currentIndex = 1
    playSong()
end

RunService.RenderStepped:Connect(updateVisualizer)

print("✅ Красный Музыкальный Плеер загружен! Наслаждайся 🔥")
