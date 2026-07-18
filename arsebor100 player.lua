local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local guiName = "DeltaRedPlayer"
if CoreGui:FindFirstChild(guiName) then
    CoreGui[guiName]:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = guiName
gui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 150)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 5, 5)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui
Instance.new("UICorner", mainFrame)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(200, 0, 0)
stroke.Thickness = 2
stroke.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Parent = mainFrame
Instance.new("UICorner", closeBtn)

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -70, 0, 5)
minBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.Parent = mainFrame
Instance.new("UICorner", minBtn)

local idBox = Instance.new("TextBox")
idBox.Size = UDim2.new(0, 180, 0, 30)
idBox.Position = UDim2.new(0, 10, 0, 40)
idBox.BackgroundColor3 = Color3.fromRGB(50, 10, 10)
idBox.TextColor3 = Color3.new(1, 1, 1)
idBox.PlaceholderText = "Audio ID"
idBox.Parent = mainFrame

local addBtn = Instance.new("TextButton")
addBtn.Size = UDim2.new(0, 40, 0, 30)
addBtn.Position = UDim2.new(0, 200, 0, 40)
addBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
addBtn.Text = "ADD"
addBtn.TextColor3 = Color3.new(1, 1, 1)
addBtn.Parent = mainFrame
Instance.new("UICorner", addBtn)

local playBtn = Instance.new("TextButton")
playBtn.Size = UDim2.new(0, 40, 0, 30)
playBtn.Position = UDim2.new(0, 245, 0, 40)
playBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
playBtn.Text = "PLAY"
playBtn.TextColor3 = Color3.new(1, 1, 1)
playBtn.Parent = mainFrame
Instance.new("UICorner", playBtn)

local visFrame = Instance.new("Frame")
visFrame.Size = UDim2.new(0, 280, 0, 60)
visFrame.Position = UDim2.new(0, 10, 0, 80)
visFrame.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
visFrame.Parent = mainFrame

local bars = {}
for i = 1, 14 do
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 15, 0, 5)
    bar.Position = UDim2.new(0, (i - 1) * 20, 1, -5)
    bar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    bar.AnchorPoint = Vector2.new(0, 1)
    bar.Parent = visFrame
    table.insert(bars, bar)
end

local audio = Instance.new("Sound")
audio.Parent = CoreGui

local fileName = "delta_music.json"
local savedSongs = {}

if isfile and readfile then
    if isfile(fileName) then
        local data = readfile(fileName)
        local success, decoded = pcall(function() return HttpService:JSONDecode(data) end)
        if success and type(decoded) == "table" then
            savedSongs = decoded
        end
    end
end

local function saveMemory()
    if writefile then
        writefile(fileName, HttpService:JSONEncode(savedSongs))
    end
end

addBtn.MouseButton1Click:Connect(function()
    local val = idBox.Text
    if tonumber(val) then
        table.insert(savedSongs, val)
        saveMemory()
        idBox.Text = ""
    end
end)

playBtn.MouseButton1Click:Connect(function()
    local val = idBox.Text
    if tonumber(val) then
        audio.SoundId = "rbxassetid://" .. val
        audio:Play()
        playBtn.Text = "PAUSE"
    elseif audio.IsPlaying then
        audio:Pause()
        playBtn.Text = "PLAY"
    elseif audio.TimePosition > 0 then
        audio:Resume()
        playBtn.Text = "PAUSE"
    elseif #savedSongs > 0 then
        audio.SoundId = "rbxassetid://" .. savedSongs[math.random(1, #savedSongs)]
        audio:Play()
        playBtn.Text = "PAUSE"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    audio:Destroy()
    gui:Destroy()
end)

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        mainFrame.Size = UDim2.new(0, 300, 0, 40)
        idBox.Visible = false
        addBtn.Visible = false
        playBtn.Visible = false
        visFrame.Position = UDim2.new(0, 10, 0, 5)
        visFrame.Size = UDim2.new(0, 200, 0, 30)
    else
        mainFrame.Size = UDim2.new(0, 300, 0, 150)
        idBox.Visible = true
        addBtn.Visible = true
        playBtn.Visible = true
        visFrame.Position = UDim2.new(0, 10, 0, 80)
        visFrame.Size = UDim2.new(0, 280, 0, 60)
    end
end)

RunService.RenderStepped:Connect(function()
    if audio and audio.Parent then
        local loudness = audio.PlaybackLoudness
        local maxHeight = visFrame.Size.Y.Offset - 5
        for i, bar in ipairs(bars) do
            local factor = math.clamp((loudness / 1000) * (math.random(50, 150) / 100), 0, 1)
            bar.Size = UDim2.new(0, 15, 0, math.max(5, maxHeight * factor))
        end
    end
end)
