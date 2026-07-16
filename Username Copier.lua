local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlayerListGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local TweenService = game:GetService("TweenService")

local intro = Instance.new("Frame")
intro.Size = UDim2.fromScale(1,1)
intro.BackgroundColor3 = Color3.fromRGB(0,0,0)
intro.BackgroundTransparency = 1
intro.ZIndex = 999
intro.Parent = screenGui

local flash = Instance.new("Frame")
flash.Size = UDim2.fromScale(1,1)
flash.BackgroundColor3 = Color3.fromRGB(120,0,0)
flash.BackgroundTransparency = 1
flash.ZIndex = 1000
flash.Parent = intro

local text = Instance.new("TextLabel")
text.AnchorPoint = Vector2.new(0.5,0.5)
text.Position = UDim2.fromScale(0.5,0.5)
text.Size = UDim2.new(0,500,0,70)
text.BackgroundTransparency = 1
text.Text = "Created by @arsebor100"
text.Font = Enum.Font.GothamBlack
text.TextScaled = true
text.TextColor3 = Color3.fromRGB(255,40,40)
text.TextTransparency = 1
text.ZIndex = 1001
text.Parent = intro

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255,0,0)
stroke.Thickness = 1.5
stroke.Transparency = 1
stroke.Parent = text

TweenService:Create(flash,TweenInfo.new(0.15),{
	BackgroundTransparency = 0.7
}):Play()

TweenService:Create(text,TweenInfo.new(0.35,Enum.EasingStyle.Quart),{
	TextTransparency = 0
}):Play()

TweenService:Create(stroke,TweenInfo.new(0.35),{
	Transparency = 0
}):Play()

task.wait(0.8)

TweenService:Create(flash,TweenInfo.new(0.35),{
	BackgroundTransparency = 1
}):Play()

TweenService:Create(text,TweenInfo.new(0.35),{
	TextTransparency = 1
}):Play()

TweenService:Create(stroke,TweenInfo.new(0.35),{
	Transparency = 1
}):Play()

task.wait(0.4)
intro:Destroy()

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.Position = UDim2.new(0.5, -160, 0.3, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

mainFrame:TweenSize(UDim2.new(0, 320, 0, 420), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.5, true)

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 0, 50)
title.Position = UDim2.new(0, 15, 0, 0)
title.Text = "Players Server List"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 90, 90)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 16
closeBtn.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -75, 0, 10)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
minimizeBtn.Text = "—"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.TextSize = 14
minimizeBtn.Parent = mainFrame

local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(0, 8)
miniCorner.Parent = minimizeBtn

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -70)
scrollFrame.Position = UDim2.new(0, 10, 0, 60)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 8
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
scrollFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

local notification = Instance.new("TextLabel")
notification.Size = UDim2.new(0, 220, 0, 35)
notification.Position = UDim2.new(0.5, -110, 0.9, 0)
notification.BackgroundColor3 = Color3.fromRGB(35, 150, 80)
notification.TextColor3 = Color3.fromRGB(255, 255, 255)
notification.Font = Enum.Font.SourceSansBold
notification.TextSize = 14
notification.Text = "Copied!"
notification.BackgroundTransparency = 1
notification.TextTransparency = 1
notification.Visible = false
notification.Parent = screenGui

local notifCorner = Instance.new("UICorner")
notifCorner.CornerRadius = UDim.new(0, 6)
notifCorner.Parent = notification

local isMinimized = false
local originalSize = UDim2.new(0, 320, 0, 420)

minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        scrollFrame.Visible = false
        title.Visible = false
        closeBtn.Visible = false
        mainFrame:TweenSize(UDim2.new(0, 50, 0, 50), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.3, true)
        minimizeBtn.Position = UDim2.new(0, 10, 0, 10)
        minimizeBtn.Text = "@"
    else
        mainFrame:TweenSize(originalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.3, true)
        minimizeBtn.Position = UDim2.new(1, -75, 0, 10)
        minimizeBtn.Text = "—"
        task.wait(0.1)
        scrollFrame.Visible = true
        title.Visible = true
        closeBtn.Visible = true
    end
end)

local function showNotification(text)
    notification.Text = text
    notification.Visible = true
    TweenService:Create(notification, TweenInfo.new(0.3), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
    task.wait(1.5)
    local fade = TweenService:Create(notification, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1})
    fade:Play()
    fade.Completed:Connect(function() notification.Visible = false end)
end

local function updateList()
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -15, 0, 55)
        card.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        card.BorderSizePixel = 0
        card.Parent = scrollFrame
        
        local cardCorner = Instance.new("UICorner")
        cardCorner.CornerRadius = UDim.new(0, 8)
        cardCorner.Parent = card
        
        local avatar = Instance.new("ImageLabel")
        avatar.Size = UDim2.new(0, 43, 0, 43)
        avatar.Position = UDim2.new(0, 6, 0.5, -21)
        avatar.BackgroundTransparency = 1
        avatar.Parent = card
        
        task.spawn(function()
            local content = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            avatar.Image = content
        end)
        
        local dispName = Instance.new("TextLabel")
        dispName.Size = UDim2.new(1, -120, 0, 20)
        dispName.Position = UDim2.new(0, 58, 0, 8)
        dispName.Text = p.DisplayName
        dispName.TextColor3 = Color3.fromRGB(255, 255, 255)
        dispName.BackgroundTransparency = 1
        dispName.Font = Enum.Font.SourceSansBold
        dispName.TextSize = 15
        dispName.TextXAlignment = Enum.TextXAlignment.Left
        dispName.Parent = card
        
        local copyBtn = Instance.new("TextButton")
        copyBtn.Size = UDim2.new(0, 60, 0, 30)
        copyBtn.Position = UDim2.new(1, -68, 0.5, -15)
        copyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        copyBtn.Text = "Copy"
        copyBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        copyBtn.Font = Enum.Font.SourceSansBold
        copyBtn.TextSize = 12
        copyBtn.Parent = card
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = copyBtn
        
        copyBtn.MouseButton1Click:Connect(function()
            setclipboard(p.Name)
            showNotification("Copied: " .. p.Name)
        end)
    end
    task.defer(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
    end)
end

updateList()
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)

closeBtn.MouseButton1Click:Connect(function()
    mainFrame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Back, 0.3, true)
    task.wait(0.3)
    screenGui:Destroy()
end)
