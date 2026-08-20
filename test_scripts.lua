local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NiceBrowser"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Главное окно
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 620, 0, 380)
main.Position = UDim2.new(0.5, -310, 0.5, -190)
main.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
main.BorderSizePixel = 0
main.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(55, 55, 65)
mainStroke.Thickness = 1.5
mainStroke.Parent = main

-- Верхняя панель
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 48)
topBar.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
topBar.BorderSizePixel = 0
topBar.Parent = main

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 14)
topCorner.Parent = topBar

-- Чтобы нижние углы топбара не были круглыми
local topFix = Instance.new("Frame")
topFix.Size = UDim2.new(1, 0, 0, 16)
topFix.Position = UDim2.new(0, 0, 1, -16)
topFix.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
topFix.BorderSizePixel = 0
topFix.Parent = topBar

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 36, 0, 36)
closeBtn.Position = UDim2.new(1, -42, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = topBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Кнопка Home
local homeBtn = Instance.new("TextButton")
homeBtn.Size = UDim2.new(0, 36, 0, 36)
homeBtn.Position = UDim2.new(0, 12, 0, 6)
homeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
homeBtn.Text = "⌂"
homeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
homeBtn.TextSize = 18
homeBtn.Font = Enum.Font.GothamBold
homeBtn.Parent = topBar

local homeCorner = Instance.new("UICorner")
homeCorner.CornerRadius = UDim.new(0, 8)
homeCorner.Parent = homeBtn

-- Поле адреса
local addressBox = Instance.new("TextBox")
addressBox.Size = UDim2.new(1, -180, 0, 34)
addressBox.Position = UDim2.new(0, 58, 0, 7)
addressBox.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
addressBox.Text = "https://www.google.com"
addressBox.PlaceholderText = "Введите ссылку..."
addressBox.TextColor3 = Color3.fromRGB(240, 240, 240)
addressBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
addressBox.TextSize = 15
addressBox.Font = Enum.Font.Gotham
addressBox.ClearTextOnFocus = false
addressBox.Parent = topBar

local addressCorner = Instance.new("UICorner")
addressCorner.CornerRadius = UDim.new(0, 8)
addressCorner.Parent = addressBox

local addressPadding = Instance.new("UIPadding")
addressPadding.PaddingLeft = UDim.new(0, 12)
addressPadding.Parent = addressBox

-- Кнопка Go
local goBtn = Instance.new("TextButton")
goBtn.Size = UDim2.new(0, 70, 0, 34)
goBtn.Position = UDim2.new(1, -120, 0, 7)
goBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
goBtn.Text = "Открыть"
goBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
goBtn.TextSize = 14
goBtn.Font = Enum.Font.GothamBold
goBtn.Parent = topBar

local goCorner = Instance.new("UICorner")
goCorner.CornerRadius = UDim.new(0, 8)
goCorner.Parent = goBtn

-- Контент (заглушка)
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -24, 1, -70)
content.Position = UDim2.new(0, 12, 0, 58)
content.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
content.BorderSizePixel = 0
content.Parent = main

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 10)
contentCorner.Parent = content

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -40, 1, -40)
infoLabel.Position = UDim2.new(0, 20, 0, 20)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Это интерфейс браузера\n\nВведи ссылку сверху и нажми «Открыть»\nСтраница откроется в твоём обычном браузере (Chrome / Edge и т.д.)\n\nПримеры:\n• google.com\n• youtube.com\n• github.com"
infoLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
infoLabel.TextSize = 16
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextWrapped = true
infoLabel.TextYAlignment = Enum.TextYAlignment.Center
infoLabel.Parent = content

-- Функция открытия
local function openUrl()
	local url = addressBox.Text
	if url == "" then return end
	
	if not url:find("https://") and not url:find("http://") then
		url = "https://" .. url
	end
	
	pcall(function()
		GuiService:OpenBrowserWindow(url)
	end)
	
	infoLabel.Text = "Открываю:\n" .. url .. "\n\nСтраница должна открыться в твоём браузере."
end

goBtn.MouseButton1Click:Connect(openUrl)

addressBox.FocusLost:Connect(function(enter)
	if enter then
		openUrl()
	end
end)

homeBtn.MouseButton1Click:Connect(function()
	addressBox.Text = "https://www.google.com"
	openUrl()
end)

-- Можно двигать окно
local dragging = false
local dragStart
local startPos

topBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
	end
end)

topBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

print("Браузер запущен")
