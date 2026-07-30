local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "ESP Config",
    SubTitle = "by Arsebor100",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 400),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main ESP", Icon = "eye" }),
    Friends = Window:AddTab({ Title = "Friends ESP", Icon = "user-check" })
}

local ESP_Config = {
    Enabled = true,
    TextSize = 13,
    
    Enemies = {
        Box = true,
        Name = true,
        Distance = true,
        Tracer = false,
        Color = Color3.fromRGB(255, 30, 30)
    },
    
    Allies = {
        Box = true,
        Name = true,
        Distance = true,
        Tracer = false,
        Color = Color3.fromRGB(0, 255, 127)
    }
}

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
